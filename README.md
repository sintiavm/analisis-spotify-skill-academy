# analisis-spotify-skill-academy
 "Análisis de señales tempranas del éxito de canciones en Spotify. Skill Academy 2026."
# 🎵 Análisis de Spotify: Señales Tempranas del Éxito Musical

Proyecto de análisis exploratorio de datos del top de canciones de Spotify para identificar qué factores actúan como señales tempranas del éxito musical, medido en cantidad de reproducciones.

## 🎯 Objetivo

Identificar qué variables disponibles al momento del lanzamiento de una canción correlacionan con el éxito posterior en reproducciones, distinguiendo señales predictivas de indicadores consecuentes del éxito.

## 📊 Dataset

- **838 canciones** del Top de Spotify
- **Periodo:** 1942-2023
- **Variables:** artista, género, país, fecha de lanzamiento, presencia en playlists de Spotify y plataformas competidoras (Apple Music, Deezer, Shazam), cantidad de reproducciones

## 🛠️ Stack tecnológico

- **BigQuery (Google Cloud)** — almacenamiento y procesamiento de datos
- **SQL** — limpieza, transformaciones y análisis
- **Power BI** — visualización y dashboard interactivo

## 🔍 Metodología

1. **Carga y limpieza** de datos en BigQuery (identificación y filtrado de filas corruptas)
2. **Creación de vistas** con tipos de datos correctos
3. **Análisis exploratorio** (EDA): distribuciones, valores nulos, outliers
4. **Evaluación de 8 hipótesis** sobre factores de éxito
5. **Visualización** en dashboard de Power BI

## 💡 Hallazgo principal

**Las canciones con alta presencia en Apple Music Playlists generan en promedio 8 veces más streams en Spotify que las de baja presencia.**

Apple Music funciona como señal temprana y predictiva del éxito en Spotify, ya que su decisión editorial es independiente del desempeño en Spotify.

## ⚠️ Limitaciones

- **Sesgo de supervivencia:** las canciones antiguas en el dataset son las que mantuvieron popularidad
- **Causalidad vs correlación:** indicadores como "presencia en Spotify playlists" son consecuencia del éxito, no señales tempranas

## 📁 Estructura del repositorio

- `/data` — Datasets originales en CSV
- `/sql` — Queries de BigQuery utilizadas
- `/dashboard` — Archivo Power BI y screenshots
- `/presentacion` — Slides finales en PDF

## 👤 Autora

**Sintia Mamani**  
Instructional Designer | Learning Experience Designer  
Laboratoria- Analisis de datos

---

*Proyecto desarrollado en el marco de Skill Academy, mayo 2026.*
