# 🚀 Mi Cloud Framework — PersonDemo

**(antes "Mi PowerServer") · Porque las malas prácticas a veces molan 😎**

![PowerBuilder](https://img.shields.io/badge/PowerBuilder-2025-orange?style=flat-square&logo=appveyor&logoColor=white)
![Despliegue](https://img.shields.io/badge/PowerClient-2025.2.6430.9-success?style=flat-square)
![Backend](https://img.shields.io/badge/Backend-.NET%2010-512BD4?style=flat-square&logo=dotnet&logoColor=white)
![Dashboard](https://img.shields.io/badge/Dashboard-Chart.js-FF6384?style=flat-square&logo=chartdotjs&logoColor=white)
![Grid](https://img.shields.io/badge/Grid-AG--Grid%20%2F%20Tabulator-1A73E8?style=flat-square)
![Blog](https://img.shields.io/badge/blog-rsrsystem-FF5722?style=flat-square&logo=blogger&logoColor=white)

> Mi caja de experimentos con **PowerBuilder 2025**: una app de mantenimiento de personas/facturas que se despliega como **PowerClient**, habla con una **API genérica en .NET 10**, pinta dashboards con **Chart.js** y mezcla un buen puñado de diversión web (Chart.js, AG-Grid, Tabulator…) dentro del cliente clásico.

---

## 📋 ¿Qué es esto?

Esto nació como demo para una conferencia y se ha ido convirtiendo en mi banco de pruebas favorito. La idea original: enseñar que PowerBuilder de hoy se lleva de maravilla con lo "moderno" aunque, a veces, para conseguirlo, haya que cometer alguna que otra **mala práctica con mucho cariño** 😏.

El proyecto empezó como **"Mi PowerServer"** (conferencia de España, abril 2025): una alternativa casera al PowerServer de Appeon pensada para **desarrolladores independientes** y proyectos con pocos recursos. Para la presentación de **LATAM** (febrero 2026) lo rebauticé como **"Mi Cloud Framework"** y, de paso, fui metiéndole código de varios artículos del blog. Así que lo que tenéis aquí es la **demo completa acumulada**, no un ejemplo de un solo tema.

Dentro encontraréis un poco de todo:

- **CRUD clásico** de mantenimiento (personas, facturas, listados y reports).
- **Despliegue como PowerClient** (instalador/actualización automática del cliente; versión `2025.2.6430.9`).
- **Backend propio**: una **API genérica en .NET 10** (mi "Cloud Framework"), configurable en `CloudSetting.ini` (entorno local o servidor), al estilo PowerServer pero montado a mi manera.
- **Dashboards HTML embebidos** con **Chart.js** dentro de la propia aplicación.
- Una ventana de **Consulta SQL asistida** (`w_con_sql`) con **dos variantes** de grid web que conviven: **AG-Grid (React)** y la **2.0** en HTML/JS puro (**CodeMirror + Tabulator**). La misma ventana sirve las dos, así que ninguna está jubilada: elijo la que me convenga.
- **Temas** (incluido *Flat Design Dark*), **ribbon menu** y una ventana **MDI con imagen de fondo**.

## ✨ Cómo funciona

El proyecto se reparte en varias librerías para mantener las piezas separadas:

- **`persondemo.pbl`** → la aplicación: ventanas de mantenimiento/consulta, login, frame MDI, fondo de MDI, reports, la ventana de consulta SQL asistida (`w_con_sql`)…
- **`api.pbl`** → la capa que consume la **API** (peticiones, ejecución de SQL remoto vía `SqlExecutor`, carga de DataWindows por REST/JSON, etc.).
- **`dashboards.pbl`** → los **dashboards** que renderizan los gráficos con Chart.js (clase base `n_cst_dashboard` que genera el HTML/CSS y clases especializadas que heredan).
- **`topwiz.pbl`** → objetos de utilidad reutilizables.

La gracia "moderna" está en mezclar el cliente nativo con piezas **web** (HTML + JS) embebidas en un `WebBrowser`, y en apoyarse en una **API** en lugar de una conexión directa a base de datos. De ahí lo de *"mi PowerServer / Cloud Framework"*: el patrón es el de PowerServer, montado a mano.

### 🌐 Las piezas web embebidas

| Carpeta / fichero | Qué es | Stack |
|---|---|---|
| `dashboards.pbl` (genera HTML) | Dashboard de ventas con KPIs y gráfico comparativo año actual vs. anterior | Chart.js + Flexbox |
| `dist/index.html` | Build **single-file** de la Consulta SQL con **AG-Grid (React)** (~3 MB, sin servidor web) | React + AG-Grid Community + ExcelJS + jsPDF, empaquetado con `vite-plugin-singlefile` |
| `sqlviewer/` | **Consulta SQL asistida 2.0**: editor + grid en HTML/JS puro, sin frameworks ni npm | CodeMirror 5 + Tabulator + SheetJS (xlsx) |

> Las dos viven en el repo a propósito. **AG-Grid sigue en pie** (es una **bestia** y hace cosas que la 2.0 ni intenta); para la 2.0 simplemente me apeteció probar otra cosa más ligera —HTML/JS plano, **sin npm, sin build**— y, como **reutilicé la misma ventana** (`w_con_sql`), AG-Grid se quedó ahí como alternativa. Quedaos con la que más os cuadre.

## 🛠️ Requisitos

- **PowerBuilder 2025** (compilado con el Runtime `25.1.0.6430`).
- **Windows 10/11**.
- El **backend .NET 10** (mi Cloud Framework) accesible para la parte de datos, configurable en `CloudSetting.ini`, apartado `[Api]`: `UrlBaseLocal` / `UrlBaseServer`.
- Conexión a la base de datos correspondiente al backend.

## ▶️ Cómo probarlo

1. Clona el repositorio (viene **en modo solución**).
2. Abre el workspace `persondemo.pbw` / target `persondemo.pbt` desde el IDE de PowerBuilder.
3. Copia `CloudSetting_example.ini` a `CloudSetting.ini` y ajusta el entorno de la API (`Local` o `Server`) y tus credenciales.
4. Compila y ejecuta, o prueba directamente el `persondemo.exe`. Como es **PowerClient**, también puedes desplegarlo y dejar que se actualice solo.

## 📌 Conferencias y artículos

Este ejemplo ha ido creciendo artículo a artículo. Aquí tenéis el recorrido completo, en orden:

### 🎤 Mi "PowerServer" — Appeon PowerBuilder Regional Conference
**Madrid, 22 abril 2025** — La presentación original: PowerBuilder como frontend + API genérica en .NET (entonces .NET 8; hoy migrada a **.NET 10**), sin licencias extra.
👉 [Artículo completo](https://rsrsystem.blogspot.com/2025/05/mi-power-server-porque-las-malas.html)

### 🖼️ Imagen de Fondo en Ventana MDI con TabbedView Control
**22 julio 2025** — Logo de fondo en la ventana MDI (UserObject `u_web_background` con un `WebBrowser`) que aparece/desaparece según las hojas abiertas.
👉 [Leer artículo](https://rsrsystem.blogspot.com/2025/07/imagen-de-fondo-en-ventana-mdi-con.html)

### 📊 Dashboard HTML PowerBuilder con Chart.js
**25 septiembre 2025** — Nueva ventana con Dashboard de Ventas: tarjetas KPI y gráfico comparativo mensual generados desde PowerBuilder, con interactividad bidireccional HTML↔PB.
👉 [Ver artículo](https://rsrsystem.blogspot.com/2025/09/dashboard-html-powerbuilder-con-chartjs.html)

### 🌎 Mi Cloud Framework — PB Talks Online (LATAM)
**11 febrero 2026** — La presentación se actualiza y se rebautiza como **"Cloud Framework"** para el público de Latinoamérica, ya con los dashboards integrados.
👉 [Ver artículo actualizado](https://rsrsystem.blogspot.com/2026/02/mi-cloud-framework-cuando-las-malas.html)

### 🧮 AG-Grid React en PowerBuilder
**25 marzo 2026** — La ventana de Consulta SQL (`w_con_sql`) estrena grid web: **AG-Grid Community** dentro de un `WebBrowser`, alimentado con JSON vía `EvaluateJavascriptSync()`, en un build single-file de React (~3 MB, sin servidor). Filtros, orden multi-columna y export a Excel/PDF.
👉 [Ver artículo](https://rsrsystem.blogspot.com/2026/03/ag-grid-react-en-powerbuilder.html)

### 🪶 Consulta SQL Asistida 2.0
**12 junio 2026** — Otra vuelta de tuerca a la misma ventana, esta vez "sin frameworks, sin npm": **CodeMirror 5 + Tabulator** en HTML/JS puro (conviviendo con la variante AG-Grid). Paneles de tablas y campos con autocompletado, SELECT generado automáticamente, modo editable (INSERT/UPDATE/DELETE), export a `.xlsx` real y temas sincronizados con PowerBuilder.
👉 [Ver artículo](https://rsrsystem.blogspot.com/2026/06/consulta-sql-asistida-20-de-ag-grid-una.html)

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
