import network
import socket
import ujson
import utime
import machine
import os

CONFIG_FILE = "wifi_config.json"
AP_SSID = "GossipGarden_Setup"
AP_PASSWORD = ""  # Open by default

def log(msg):
    print("[WiFi] {}".format(msg))

def load_config():
    try:
        with open(CONFIG_FILE, "r") as f:
            return ujson.load(f)
    except Exception:
        return None

def save_config(ssid, password):
    try:
        with open(CONFIG_FILE, "w") as f:
            ujson.dump({"ssid": ssid, "password": password}, f)
        return True
    except Exception as e:
        log("Error saving config: {}".format(e))
        return False

def remove_config():
    try:
        os.remove(CONFIG_FILE)
    except Exception:
        pass

def connect_to_wifi(ssid, password, timeout=12000):
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    if wlan.isconnected() and wlan.config('essid') == ssid:
        return True

    log("Connecting to {}...".format(ssid))
    if wlan.isconnected():
        wlan.disconnect()
    wlan.connect(ssid, password)

    start = utime.ticks_ms()
    while not wlan.isconnected():
        if utime.ticks_diff(utime.ticks_ms(), start) > timeout:
            log("Connection timeout")
            wlan.disconnect()
            return False
        utime.sleep_ms(250)

    log("Connected! IP: {}".format(wlan.ifconfig()[0]))
    return True

def get_networks(wlan):
    networks = wlan.scan()
    sec_map = {0: "open", 1: "WEP", 2: "WPA-PSK", 3: "WPA2-PSK", 4: "WPA/WPA2-PSK"}
    res = []
    for n in networks:
        ssid, bssid, channel, rssi, authmode, hidden = n
        res.append({
            "ssid": ssid.decode('utf-8') if isinstance(ssid, bytes) else ssid,
            "bssid": "{:02x}:{:02x}:{:02x}:{:02x}:{:02x}:{:02x}".format(*bssid),
            "channel": channel,
            "rssi": rssi,
            "security": sec_map.get(authmode, "unknown"),
            "hidden": hidden
        })
    return res

def start_ap_and_server():
    log("Starting AP mode...")
    ap = network.WLAN(network.AP_IF)
    ap.active(True)
    ap.config(essid=AP_SSID, authmode=network.AUTH_OPEN)

    sta = network.WLAN(network.STA_IF)
    sta.active(True)

    log("AP IP: {}".format(ap.ifconfig()[0]))
    log("Starting HTTP server on port 80...")

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(('', 80))
    s.listen(1)

    while True:
        try:
            conn, addr = s.accept()
            req = conn.recv(1024).decode('utf-8')
            if not req:
                conn.close()
                continue

            lines = req.split('\r\n')
            req_line = lines[0]
            parts = req_line.split(' ')
            if len(parts) < 2:
                conn.close()
                continue

            method, path = parts[0], parts[1]
            body = req.split('\r\n\r\n')[1] if '\r\n\r\n' in req else ""

            response_body = "{}"
            status = "200 OK"

            if method == "GET" and path == "/wifi/networks":
                nets = get_networks(sta)
                response_body = ujson.dumps(nets)
            elif method == "GET" and path == "/wifi/status":
                status_dict = {
                    "connected": sta.isconnected(),
                    "ip": sta.ifconfig()[0] if sta.isconnected() else None,
                    "status_code": sta.status()
                }
                response_body = ujson.dumps(status_dict)
            elif method == "POST" and path == "/wifi/reset":
                remove_config()
                sta.disconnect()
                response_body = ujson.dumps({"status": "reset"})
            elif method == "POST" and path == "/wifi/connect":
                try:
                    data = ujson.loads(body)
                    ssid = data.get("ssid", "")
                    pw = data.get("password", "")
                    if connect_to_wifi(ssid, pw):
                        save_config(ssid, pw)
                        response_body = ujson.dumps({"success": True, "ip": sta.ifconfig()[0]})

                        resp = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n" + response_body
                        conn.send(resp)
                        conn.close()

                        utime.sleep(1)
                        s.close()
                        ap.active(False)
                        return True
                    else:
                        response_body = ujson.dumps({"success": False, "status_code": sta.status()})
                except Exception as e:
                    status = "400 Bad Request"
                    response_body = ujson.dumps({"error": str(e)})
            else:
                status = "404 Not Found"

            resp = "HTTP/1.1 {}\r\nContent-Type: application/json\r\n\r\n{}".format(status, response_body)
            conn.send(resp)
            conn.close()
        except Exception as e:
            log("Server error: {}".format(e))
            try:
                conn.close()
            except:
                pass

def ensure_wifi_ready():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    if wlan.isconnected():
        return True

    config = load_config()
    if config and config.get("ssid"):
        log("Found saved config, attempting connection...")
        if connect_to_wifi(config["ssid"], config.get("password", "")):
            return True
        else:
            log("Connection failed with saved config.")

    log("No valid config or connection failed. Entering setup mode.")
    return start_ap_and_server()
