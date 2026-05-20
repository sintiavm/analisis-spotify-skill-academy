-- =====================================================
-- ANÁLISIS DE SPOTIFY - SEÑALES TEMPRANAS DEL ÉXITO
-- Proyecto: Skill Academy
-- Autora: Sintia Mamani
-- Plataforma: Google BigQuery
-- =====================================================


-- =====================================================
-- 1. CREACIÓN DE VISTAS LIMPIAS
-- Se aplican casts de tipos correctos y se filtra
-- 1 fila corrupta detectada en la carga inicial.
-- =====================================================

CREATE OR REPLACE VIEW `analisis-datos-spotify.spotify_data.v_tracks_spotify_clean` AS
SELECT 
  CAST(track_id AS STRING) AS track_id,
  track_name,
  artists_name,
  SAFE_CAST(artist_count AS INT64) AS artist_count,
  TRIM(main_music_genre) AS main_music_genre,
  TRIM(main_country) AS main_country,
  SAFE_CAST(released_year AS INT64) AS released_year,
  SAFE_CAST(released_month AS INT64) AS released_month,
  SAFE_CAST(released_day AS INT64) AS released_day,
  SAFE_CAST(in_spotify_playlists AS INT64) AS in_spotify_playlists,
  SAFE_CAST(in_spotify_charts AS INT64) AS in_spotify_charts,
  SAFE_CAST(streams AS INT64) AS streams
FROM `analisis-datos-spotify.spotify_data.tracks_spotify`
WHERE SAFE_CAST(streams AS INT64) IS NOT NULL;


CREATE OR REPLACE VIEW `analisis-datos-spotify.spotify_data.v_tracks_competition_clean` AS
SELECT 
  CAST(track_id AS STRING) AS track_id,
  SAFE_CAST(in_apple_playlists AS INT64) AS in_apple_playlists,
  SAFE_CAST(in_apple_charts AS INT64) AS in_apple_charts,
  SAFE_CAST(in_deezer_playlists AS INT64) AS in_deezer_playlists,
  SAFE_CAST(in_deezer_charts AS INT64) AS in_deezer_charts,
  SAFE_CAST(in_shazam_charts AS INT64) AS in_shazam_charts
FROM `analisis-datos-spotify.spotify_data.tracks_competition`;


-- =====================================================
-- 2. EDA - ANÁLISIS EXPLORATORIO INICIAL
-- =====================================================

-- 2.1 Volumen general del dataset
SELECT 
  COUNT(*) AS total_canciones,
  MIN(released_year) AS anio_mas_antiguo,
  MAX(released_year) AS anio_mas_reciente,
  COUNT(DISTINCT artists_name) AS artistas_unicos,
  COUNT(DISTINCT main_music_genre) AS generos_unicos,
  COUNT(DISTINCT main_country) AS paises_unicos
FROM `analisis-datos-spotify.spotify_data.v_tracks_spotify_clean`;


-- 2.2 Distribución de streams (detección de outliers)
SELECT 
  MIN(streams) AS min_streams,
  MAX(streams) AS max_streams,
  ROUND(AVG(streams), 0) AS promedio_streams,
  APPROX_QUANTILES(streams, 4) AS cuartiles
FROM `analisis-datos-spotify.spotify_data.v_tracks_spotify_clean`;


-- 2.3 Verificación de valores nulos
SELECT 
  COUNTIF(track_name IS NULL) AS nulos_track_name,
  COUNTIF(artists_name IS NULL) AS nulos_artists,
  COUNTIF(streams IS NULL) AS nulos_streams,
  COUNTIF(main_music_genre IS NULL) AS nulos_genero,
  COUNTIF(main_country IS NULL) AS nulos_pais,
  COUNTIF(released_year IS NULL) AS nulos_anio
FROM `analisis-datos-spotify.spotify_data.v_tracks_spotify_clean`;


-- =====================================================
-- 3. EVALUACIÓN DE HIPÓTESIS
-- =====================================================

-- H1: ¿Las canciones más recientes tienen más streams?
SELECT 
  released_year,
  COUNT(*) AS cantidad_canciones,
  ROUND(AVG(streams), 0) AS promedio_streams,
  APPROX_QUANTILES(streams, 2)[OFFSET(1)] AS mediana_streams
FROM `analisis-datos-spotify.spotify_data.v_tracks_spotify_clean`
GROUP BY released_year
ORDER BY released_year DESC;


-- H2: ¿Qué géneros generan más éxito?
SELECT 
  main_music_genre,
  COUNT(*) AS cantidad_canciones,
  ROUND(AVG(streams), 0) AS promedio_streams,
  APPROX_QUANTILES(streams, 2)[OFFSET(1)] AS mediana_streams
FROM `analisis-datos-spotify.spotify_data.v_tracks_spotify_clean`
GROUP BY main_music_genre
HAVING COUNT(*) >= 5
ORDER BY mediana_streams DESC
LIMIT 15;


-- H3: ¿Las colaboraciones (más artistas) tienen más éxito?
SELECT 
  artist_count,
  COUNT(*) AS cantidad_canciones,
  ROUND(AVG(streams), 0) AS promedio_streams,
  APPROX_QUANTILES(streams, 2)[OFFSET(1)] AS mediana_streams
FROM `analisis-datos-spotify.spotify_data.v_tracks_spotify_clean`
GROUP BY artist_count
ORDER BY artist_count;


-- H4: ¿Las playlists de Spotify predicen streams?
-- NOTA: Esta variable es consecuencia del éxito, no señal temprana
SELECT 
  CASE 
    WHEN in_spotify_playlists < 100 THEN '01_Menos_100'
    WHEN in_spotify_playlists < 500 THEN '02_100_a_500'
    WHEN in_spotify_playlists < 1000 THEN '03_500_a_1000'
    WHEN in_spotify_playlists < 5000 THEN '04_1000_a_5000'
    ELSE '05_Mas_5000'
  END AS rango_playlists,
  COUNT(*) AS cantidad_canciones,
  ROUND(AVG(streams), 0) AS promedio_streams,
  APPROX_QUANTILES(streams, 2)[OFFSET(1)] AS mediana_streams
FROM `analisis-datos-spotify.spotify_data.v_tracks_spotify_clean`
GROUP BY rango_playlists
ORDER BY rango_playlists;


-- H5: ¿El mes de lanzamiento influye en el éxito?
SELECT 
  released_month,
  COUNT(*) AS cantidad_canciones,
  ROUND(AVG(streams), 0) AS promedio_streams,
  APPROX_QUANTILES(streams, 2)[OFFSET(1)] AS mediana_streams
FROM `analisis-datos-spotify.spotify_data.v_tracks_spotify_clean`
GROUP BY released_month
ORDER BY released_month;


-- H6: ¿El país de origen influye?
SELECT 
  main_country,
  COUNT(*) AS cantidad_canciones,
  ROUND(AVG(streams), 0) AS promedio_streams,
  APPROX_QUANTILES(streams, 2)[OFFSET(1)] AS mediana_streams
FROM `analisis-datos-spotify.spotify_data.v_tracks_spotify_clean`
GROUP BY main_country
HAVING COUNT(*) >= 5
ORDER BY mediana_streams DESC
LIMIT 15;


-- H7: ¿La presencia en Apple Music es señal temprana de éxito en Spotify?
-- HALLAZGO CLAVE: Sí lo es, las canciones con alta presencia en Apple
-- generan 8x más streams en Spotify que las de baja presencia.
SELECT 
  CASE 
    WHEN c.in_apple_playlists IS NULL THEN '0_Sin_Apple'
    WHEN c.in_apple_playlists < 50 THEN '1_Apple_bajo'
    WHEN c.in_apple_playlists < 150 THEN '2_Apple_medio'
    ELSE '3_Apple_alto'
  END AS rango_apple_playlists,
  COUNT(*) AS cantidad_canciones,
  ROUND(AVG(s.streams), 0) AS promedio_streams_spotify,
  APPROX_QUANTILES(s.streams, 2)[OFFSET(1)] AS mediana_streams_spotify
FROM `analisis-datos-spotify.spotify_data.v_tracks_spotify_clean` AS s
LEFT JOIN `analisis-datos-spotify.spotify_data.v_tracks_competition_clean` AS c
  ON s.track_id = c.track_id
GROUP BY rango_apple_playlists
ORDER BY rango_apple_playlists;


-- H8: Top 20 canciones por reproducciones (análisis cualitativo)
SELECT 
  track_name,
  artists_name,
  main_music_genre,
  main_country,
  released_year,
  artist_count,
  in_spotify_playlists,
  in_spotify_charts,
  streams
FROM `analisis-datos-spotify.spotify_data.v_tracks_spotify_clean`
ORDER BY streams DESC
LIMIT 20;


-- =====================================================
-- 4. EXPORT - TABLA MAESTRA PARA POWER BI
-- =====================================================

SELECT 
  s.track_id,
  s.track_name,
  s.artists_name,
  s.artist_count,
  s.main_music_genre,
  s.main_country,
  s.released_year,
  s.released_month,
  s.released_day,
  s.in_spotify_playlists,
  s.in_spotify_charts,
  s.streams,
  c.in_apple_playlists,
  c.in_apple_charts,
  c.in_deezer_playlists,
  c.in_deezer_charts,
  c.in_shazam_charts,
  CASE 
    WHEN s.in_spotify_playlists < 100 THEN '01_Menos_100'
    WHEN s.in_spotify_playlists < 500 THEN '02_100_a_500'
    WHEN s.in_spotify_playlists < 1000 THEN '03_500_a_1000'
    WHEN s.in_spotify_playlists < 5000 THEN '04_1000_a_5000'
    ELSE '05_Mas_5000'
  END AS rango_playlists_spotify,
  CASE 
    WHEN c.in_apple_playlists IS NULL OR c.in_apple_playlists < 50 THEN '1_Apple_bajo'
    WHEN c.in_apple_playlists < 150 THEN '2_Apple_medio'
    ELSE '3_Apple_alto'
  END AS rango_apple,
  CASE
    WHEN s.released_year >= 2020 THEN '2020-2023'
    WHEN s.released_year >= 2010 THEN '2010-2019'
    WHEN s.released_year >= 2000 THEN '2000-2009'
    WHEN s.released_year >= 1990 THEN '1990-1999'
    ELSE 'Antes de 1990'
  END AS decada
FROM `analisis-datos-spotify.spotify_data.v_tracks_spotify_clean` AS s
LEFT JOIN `analisis-datos-spotify.spotify_data.v_tracks_competition_clean` AS c
  ON s.track_id = c.track_id;
