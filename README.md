# 🚀 Mi "PowerServer" — PersonDemo
**Porque las malas prácticas a veces molan 😎**

![PowerBuilder](https://img.shields.io/badge/PowerBuilder-2025-orange?style=flat-square&logo=appveyor&logoColor=white)
![Despliegue](https://img.shields.io/badge/PowerClient-2025.2.6430.9-success?style=flat-square)
![Frontend](https://img.shields.io/badge/Dashboard-Chart.js-FF6384?style=flat-square&logo=chartdotjs&logoColor=white)
![Blog](https://img.shields.io/badge/blog-rsrsystem-FF5722?style=flat-square&logo=blogger&logoColor=white)

> Mi caja de experimentos con **PowerBuilder 2025**: una app de mantenimiento de personas/facturas que se despliega como **PowerClient**, habla con una API, pinta dashboards con **Chart.js** y mezcla un poco de diversión web dentro del cliente clásico.

---

## 📋 ¿Qué es esto?

Esto nació como demo para una conferencia y se ha ido convirtiendo en mi banco de pruebas favorito. La idea: enseñar que PowerBuilder de hoy se lleva de maravilla con lo "moderno" aunque, a veces, para conseguirlo, haya que cometer alguna que otra **mala práctica con mucho cariño** 😏.

Dentro encontraréis un poco de todo:

- **CRUD clásico** de mantenimiento (personas, facturas, listados y reports).
- **Despliegue como PowerClient** (instalador/actualización automática del cliente; versión `2025.2.6430.9`).
- Conexión a una **API** (configurable en `CloudSetting.ini`: entorno local o servidor) al estilo PowerServer.
- **Dashboards HTML embebidos** con **Chart.js** dentro de la propia aplicación.
- Un pequeño **SQL Viewer** web (`sqlviewer/`) servido dentro del cliente.
- **Temas** (incluido *Flat Design Dark*), **ribbon menu** y una ventana **MDI con imagen de fondo**.

## ✨ Cómo funciona

El proyecto se reparte en varias librerías para mantener las piezas separadas:

- **`persondemo.pbl`** → la aplicación, ventanas de mantenimiento/consulta, login, frame MDI, reports…
- **`api.pbl`** → la capa que consume la **API** (peticiones, ejecución de SQL remoto vía `SqlExecutor`, etc.).
- **`dashboards.pbl`** → los **dashboards** que renderizan los gráficos con Chart.js.
- **`topwiz.pbl`** → objetos de utilidad reutilizables.

La gracia "moderna" está en mezclar el cliente nativo con piezas **web** (HTML + JS) embebidas para los dashboards y el visor SQL, y en apoyarse en una **API** en lugar de una conexión directa a base de datos. De ahí lo de *"mi PowerServer"*: el patrón es el de PowerServer, montado a mi manera.

## 🛠️ Requisitos

- **PowerBuilder 2025** (compilado con el Runtime `25.1.0.6430`).
- **Windows 10/11**.
- Una **API** accesible para la parte de datos (configurable en `CloudSetting.ini`, apartado `[Api]`: `UrlBaseLocal` / `UrlBaseServer`).
- Conexión a la base de datos correspondiente al backend.

## ▶️ Cómo probarlo

1. Clona el repositorio (viene **en modo solución**).
2. Abre el workspace `persondemo.pbw` / target `persondemo.pbt` desde el IDE de PowerBuilder.
3. Revisa `CloudSetting.ini` y ajusta el entorno de la API (`Local` o `Server`).
4. Compila y ejecuta, o prueba directamente el `persondemo.exe`. Como es **PowerClient**, también puedes desplegarlo y dejar que se actualice solo.

## 📌 Conferencias y artículos

### 🎤 Appeon PowerBuilder Regional Conference
**Madrid, 22 Abril 2025**
👉 [Artículo completo](https://rsrsystem.blogspot.com/2025/05/mi-power-server-porque-las-malas.html)

### 🖼️ Imagen de Fondo en Ventana MDI con TabbedView Control
**22-07-2025** — Añadimos logo de fondo a ventana MDI.
👉 [Leer artículo](https://rsrsystem.blogspot.com/2025/07/imagen-de-fondo-en-ventana-mdi-con.html)

### 📊 Dashboard HTML PowerBuilder con Chart.js
**25-09-2025** — Nueva ventana con Dashboard de Ventas.
👉 [Ver artículo](https://rsrsystem.blogspot.com/2025/09/dashboard-html-powerbuilder-con-chartjs.html)

## 🔗 Repo PowerBuilder

Tenéis el ejemplo publicado en modo solución aquí:
👉 <https://github.com/rasanfe/PersonDemo>

## 🙌 Créditos

**Ramón San Félix Ramón**

- 🌐 [LinkedIn](https://www.linkedin.com/in/rasanfe)
- 📝 [Blog](https://rsrsystem.blogspot.com)
- 💻 [GitHub](https://github.com/rasanfe)

⭐ *Si te gustan estos experimentos, dale una estrellita al repo y comparte.*

---

> ¡Nos vemos en el próximo artículo! Y recuerda: en PowerBuilder, los límites solo están en nuestra imaginación. 🚀

📨 **Blog:** <https://rsrsystem.blogspot.com/>
