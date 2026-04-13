print("ola")
# Módulo 1 (Hardware) - Gossip Garden
# ESP32 + MicroPython

import machine
import network
import dht
import utime
import ssl
import ujson
from umqtt.simple import MQTTClient

# -----------------------------
# Configuración del dispositivo
# -----------------------------
DEVICE_ID = "esp32_01"
PLANT_ID = 1
TOPIC = "plantas/{}/sensores".format(DEVICE_ID)
PUBLISH_INTERVAL_MS = 5000

# WiFi
WIFI_SSID = "Dani"
WIFI_PASSWORD = "danii123"

WIFI_CONNECT_TIMEOUT_MS = 12000
WIFI_RETRY_DELAY_MS = 2000

# MQTT
# MQTT
MQTT_BROKER = "0712cb0c18314a609092dfd3544c234c.s1.eu.hivemq.cloud" # Tu Cluster URL
MQTT_PORT = 8883 # Puerto seguro TLS (no usar 1883)
MQTT_USER = "Danieloide" # El usuario que creaste en "Access Management"
MQTT_PASSWORD = "Danii123" # La contraseña de ese usuario
MQTT_CLIENT_ID = DEVICE_ID

# Pines (ajustado para sensores reales)
DHT22_PIN = 4
SOIL_ADC_PIN = 34   # SEN-0193 (Analógico)
I2C_SDA_PIN = 21    # GY-30 / BH1750 (Digital I2C)
I2C_SCL_PIN = 22    # GY-30 / BH1750 (Digital I2C)

# Dirección I2C del sensor de luz
BH1750_ADDR = 0x23 

# Calibración del sensor de suelo capacitivo (SEN0193)
# NOTA: Revisa estos valores imprimiendo 'raw_avg' en seco y en agua.
SOIL_RAW_DRY = 2450 # Valor aproximado cuando está al aire libre (completamente seco)
SOIL_RAW_WET = 1300 # Valor aproximado cuando está sumergido en agua

# Rangos esperados
TEMP_MIN = -40.0
TEMP_MAX = 80.0
HUM_MIN = 0
HUM_MAX = 100
SOIL_MIN = 0
SOIL_MAX = 100
LIGHT_MIN = 0
LIGHT_MAX = 65535 # Cambiado para el máximo de luxes reales del GY-30

# -----------------------------
# Inicialización de hardware
# -----------------------------
wlan = network.WLAN(network.STA_IF)
wlan.active(True)

dht_sensor = dht.DHT22(machine.Pin(DHT22_PIN))

soil_adc = machine.ADC(machine.Pin(SOIL_ADC_PIN))
# ESP32 ADC range/attenuation para rango amplio de voltaje
soil_adc.atten(machine.ADC.ATTN_11DB)

# Inicializar bus I2C para el sensor de luz GY-30
i2c = machine.I2C(0, scl=machine.Pin(I2C_SCL_PIN), sda=machine.Pin(I2C_SDA_PIN), freq=400000)

mqtt_client = None

# -----------------------------
# Utilidades
# -----------------------------
def log(msg):
    print("[HW] {}".format(msg))

def clamp(value, min_value, max_value):
    if value < min_value:
        return min_value
    if value > max_value:
        return max_value
    return value

def to_iso8601_utc(ts):
    # MicroPython no siempre incluye utilidades completas de datetime.
    # Generamos timestamp UTC básico en formato ISO 8601.
    t = utime.gmtime(ts)
    return "{:04d}-{:02d}-{:02d}T{:02d}:{:02d}:{:02d}Z".format(
        t[0], t[1], t[2], t[3], t[4], t[5]
    )

# -----------------------------
# Lectura de sensores (segura)
# -----------------------------
def read_dht22_safe():
    try:
        dht_sensor.measure()
        temp = float(dht_sensor.temperature())
        hum = float(dht_sensor.humidity())

        # Validación + clamp defensivo
        temp = clamp(temp, TEMP_MIN, TEMP_MAX)
        hum = clamp(hum, HUM_MIN, HUM_MAX)

        return round(temp, 1), int(round(hum))
    except Exception as exc:
        log("Error leyendo DHT22: {}".format(exc))
        return None, None

def read_soil_safe(samples=3):
    values = []
    for _ in range(samples):
        try:
            values.append(soil_adc.read())
        except Exception as exc:
            log("Error lectura ADC suelo: {}".format(exc))
        utime.sleep_ms(15)

    if not values:
        return None

    raw_avg = sum(values) // len(values)
    print("Valor RAW del suelo:", raw_avg)
    
    # Mapeo para el sensor capacitivo físico
    # Se invierte la lógica: más valor = más seco
    if raw_avg > SOIL_RAW_DRY: raw_avg = SOIL_RAW_DRY
    if raw_avg < SOIL_RAW_WET: raw_avg = SOIL_RAW_WET
    
    # Calcular porcentaje (evita división por cero)
    rango = SOIL_RAW_DRY - SOIL_RAW_WET
    if rango == 0:
        return 0
        
    soil_pct = int(((SOIL_RAW_DRY - raw_avg) * 100) / rango)
    return clamp(soil_pct, SOIL_MIN, SOIL_MAX)

def read_light_safe():
    try:
        # Enviar comando de medición continua a alta resolución (1 Lux)
        i2c.writeto(BH1750_ADDR, b'\x10')
        utime.sleep_ms(180) # El sensor GY-30 requiere este tiempo para medir
        
        # Leer 2 bytes de respuesta
        data = i2c.readfrom(BH1750_ADDR, 2)
        
        # Convertir los bytes a Luxes según la hoja de datos
        lux = (data[0] << 8 | data[1]) / 1.2
        return clamp(round(lux, 1), LIGHT_MIN, LIGHT_MAX)
    except Exception as exc:
        log("Error lectura I2C luz: {}".format(exc))
        return None

# -----------------------------
# Conectividad WiFi/MQTT
# -----------------------------
def wifi_connect_if_needed():
    if wlan.isconnected():
        return True

    log("WiFi desconectado, reconectando...")
    wlan.disconnect()
    wlan.connect(WIFI_SSID, WIFI_PASSWORD)

    start = utime.ticks_ms()
    while not wlan.isconnected():
        if utime.ticks_diff(utime.ticks_ms(), start) > WIFI_CONNECT_TIMEOUT_MS:
            log("Timeout conectando WiFi")
            return False
        utime.sleep_ms(250)

    log("WiFi OK: {}".format(wlan.ifconfig()[0]))
    return True

def mqtt_disconnect_safe():
    global mqtt_client
    if mqtt_client is not None:
        try:
            mqtt_client.disconnect()
        except Exception:
            pass
    mqtt_client = None

def mqtt_connect_if_needed():
    global mqtt_client
    # Crear configuración SSL segura
    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    ssl_context.verify_mode = ssl.CERT_NONE

    if not wifi_connect_if_needed():
        return False

    if mqtt_client is not None:
        return True

    try:
        mqtt_client = MQTTClient(
            client_id=MQTT_CLIENT_ID,
            server=MQTT_BROKER,
            port=MQTT_PORT,
            user=MQTT_USER,
            password=MQTT_PASSWORD,
            keepalive=30,
            ssl=ssl_context
        )
        mqtt_client.connect()
        log("MQTT conectado a {}:{}".format(MQTT_BROKER, MQTT_PORT))
        return True
    except Exception as exc:
        log("Error conectando MQTT: {}".format(exc))
        mqtt_disconnect_safe()
        return False

def safe_publish(topic, payload):
    if not mqtt_connect_if_needed():
        return False

    try:
        mqtt_client.publish(topic, payload)
        return True
    except Exception as exc:
        log("Error publicando MQTT: {}".format(exc))
        mqtt_disconnect_safe()
        return False

# -----------------------------
# Payload
# -----------------------------
def build_payload():
    now = utime.time()
    temperature, humidity = read_dht22_safe()
    soil_moisture = read_soil_safe()
    light = read_light_safe()

    payload = {
        "plant_id": PLANT_ID,
        "device_id": DEVICE_ID,
        "timestamp": to_iso8601_utc(now),
        "sensors": {
            "temperature": temperature,
            "humidity": humidity,
            "soil_moisture": soil_moisture,
            "light": light,
        },
    }
    return payload

# -----------------------------
# Bucle principal
# -----------------------------
def main_loop():
    log("Iniciando modulo de hardware...")

    while True:
        loop_start = utime.ticks_ms()

        try:
            payload = build_payload()
            payload_str = ujson.dumps(payload)

            ok = safe_publish(TOPIC, payload_str)
            if ok:
                log("Datos enviados: {}".format(payload_str))
            else:
                log("No se pudo enviar, se reintentara en el siguiente ciclo")

        except Exception as exc:
            # Nunca permitimos que el loop principal colapse
            log("Fallo inesperado en loop: {}".format(exc))
            mqtt_disconnect_safe()

        elapsed = utime.ticks_diff(utime.ticks_ms(), loop_start)
        sleep_ms = PUBLISH_INTERVAL_MS - elapsed
        if sleep_ms < 200:
            sleep_ms = 200
        utime.sleep_ms(sleep_ms)

# Ejecutar
main_loop()