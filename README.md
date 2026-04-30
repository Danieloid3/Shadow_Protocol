<div align="center">

<!-- TODO: reemplazar por el logo definitivo de Gossip Garden (PNG/SVG, ~320px) -->
<img src="docs/assets/logo.png" alt="Gossip Garden" width="320" />

# Gossip Garden

### Tu jardín nunca había estado tan parlanchín

*Plantas que chismosean sobre cómo se sienten — para que nunca más vuelvas a regar a ojo.*

---

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-Backend-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](#licencia)
[![Platforms](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blueviolet)]()

<br />

<!-- TODO: reemplazar el href cuando la app esté publicada -->
<a href="https://play.google.com/store/apps/details?id=com.gossipgarden.app">
  <img alt="Disponible en Google Play"
       src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"
       height="80" />
</a>

</div>

---

## Sobre Gossip Garden

¿Y si tus plantas pudieran hablar?

**Gossip Garden** convierte la telemetría de tus plantas (humedad, temperatura, luz, nutrientes) en una conversación. Cada planta tiene su propia personalidad, su mood del día y su rango de confort — y te avisa cuando algo no va bien, en su propio tono. Nada de gráficos aburridos: chismes con datos detrás.

> *"Hoy el sol estuvo glorioso, pero la tierra está más seca que el chiste de tu tío. ¿Me echas un trago?"* — Albahaca de la cocina, hace 3 minutos.

---

## Capturas

<div align="center">

<!-- TODO: reemplazar por un collage real con las pantallas principales: Login, Dashboard de plantas, Detalle, Chat. Recomendado 1200x675. -->
<img src="docs/assets/screenshots-collage.png" alt="Capturas de Gossip Garden" width="100%" />

<sub>Login con Google · Dashboard de plantas · Detalle con telemetría en tiempo real · Chat por planta</sub>

</div>

---

## Lo que hace

| | |
|---|---|
| **Telemetría en tiempo real** | Humedad, temperatura, luz y nutrientes vía SSE — la pantalla se actualiza en cuanto cambia el sensor. |
| **Mood y salud por planta** | Calculados a partir del rango de confort de cada especie: tu monstera no quiere el mismo clima que tu cactus. |
| **Chat por planta** | Conversa con cada planta. Persistido en Firestore si activas Firebase, o en memoria si solo quieres probar. |
| **Login con Google** | Sesión persistente entre dispositivos vía Firebase Auth. |
| **Modo offline-friendly** | La app arranca sin Firebase con stubs locales — útil para demos rápidas o desarrollo. |
| **Multiplataforma** | Un solo código Flutter para Android, iOS y Web. |

---

## Cómo funciona

```
   ┌──────────────┐        ┌───────────────────┐        ┌──────────────────┐
   │  Sensores    │  MQTT  │   Backend         │  REST  │   App Flutter    │
   │  (humedad,   ├───────▶│   FastAPI +       ├───────▶│   Riverpod +     │
   │   temp, luz) │        │   Postgres        │  SSE   │   Firebase       │
   └──────────────┘        └───────────────────┘        └──────────────────┘
```

1. Los sensores publican lecturas por **MQTT** a un broker HiveMQ.
2. El backend **FastAPI** las normaliza, las guarda en **Postgres** (Railway) y expone REST + un stream SSE por planta.
3. La app Flutter consume `/plants`, `/plant_species`, `/sensor_data/{id}` y se suscribe al SSE para actualizaciones en vivo.

---

## Arquitectura

<div align="center">

<!-- TODO: reemplazar por un diagrama real (drawio, excalidraw, figma export). 1400x700 recomendado. -->
<img src="docs/assets/architecture.png" alt="Arquitectura del sistema" width="80%" />

</div>

El cliente sigue una arquitectura por capas (`data` / `domain` / `presentation`) por feature, con **Riverpod** como única fuente de estado y un único `Scaffold` raíz con `IndexedStack` + overlays — sin rutas de `Navigator`.

---

## Stack tecnológico

**Cliente**
- Flutter 3.x (Dart `>=3.0.0 <4.0.0`)
- Riverpod (`flutter_riverpod`)
- `firebase_core` · `firebase_auth` · `cloud_firestore` · `google_sign_in`
- `http` para REST y SSE

**Backend** (rama `main`)
- FastAPI + SQLAlchemy
- Postgres (Railway)
- HiveMQ (MQTT)
- Server-Sent Events para streaming en vivo

**Infra**
- Railway para hosting del backend
- Firebase para auth y Firestore

---

## Empezar

### Como usuario

<a href="https://play.google.com/store/apps/details?id=com.gossipgarden.app">
  <img alt="Disponible en Google Play"
       src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"
       height="60" />
</a>

### Como desarrollador

El frontend vive en la rama [`frontend`](../../tree/frontend) y el backend en `main`.

```bash
git clone https://github.com/<org>/Shadow_Protocol.git
cd Shadow_Protocol/gossip_garden
flutter pub get
flutter run
```

Setup completo, variables de compilación y modos de arranque (local / remoto / con Firebase) en [`gossip_garden/README.md`](gossip_garden/README.md). Configuración inicial de Android Studio en [`README_CONFIG.md`](README_CONFIG.md).

---

## Roadmap

- [x] Telemetría en tiempo real con SSE
- [x] Chat por planta persistido en Firestore
- [x] Auth con Google
- [ ] Notificaciones push cuando una planta entra en zona crítica
- [ ] Recomendaciones de cuidado generadas con IA por especie
- [ ] Soporte para múltiples jardines / espacios
- [ ] Dashboard web
- [ ] Compartir jardín con otros usuarios

---

## Equipo

<div align="center">

<!-- TODO: añadir foto/avatar y rol de cada integrante -->

| | | |
|:---:|:---:|:---:|
| <img src="docs/assets/team-1.png" width="100" /><br />**Nombre 1**<br /><sub>Rol</sub> | <img src="docs/assets/team-2.png" width="100" /><br />**Nombre 2**<br /><sub>Rol</sub> | <img src="docs/assets/team-3.png" width="100" /><br />**Nombre 3**<br /><sub>Rol</sub> |

</div>

---

## Contribuir

¿Encontraste un bug o tienes una idea? Abre un issue o un PR — toda contribución es bienvenida.

1. Haz fork del repo
2. Crea una rama (`git checkout -b feat/mi-mejora`)
3. Commit con mensajes claros
4. Abre un PR contra la rama correspondiente (`frontend` o `main`)

---

## Licencia

Distribuido bajo licencia **MIT**. Ver [`LICENSE`](LICENSE) para más detalles.

---

<div align="center">

Hecho con cariño (y un poco de chisme) por el equipo de Gossip Garden.

<sub>Si esta app te ahorró una planta, dale una estrella al repo.</sub>

</div>
