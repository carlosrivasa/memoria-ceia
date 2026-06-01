# Memoria CEIA – Presentación Reveal.js

## Proyecto

Sistema de IA para caracterización automática de 13 características musicales a partir de audio de canciones. Trabajo Final de Especialización en Inteligencia Artificial (CEIA, FIUBA). Desarrollado para **Plusyc Live SAS**, empresa que ambienta espacios comerciales con música personalizada.

**Título oficial del trabajo** (portada.tex):  
> *Asignación de características musicales para ambientación comercial*

**Autor**: Ing. Carlos Alberto Rivas Araque — estudiante de especialización en IA, músico amateur, colabora con Plusyc.  
**Director**: Esp. Ing. Martín Moreyra (GatekeeperX)  
**Jurados**: Esp. Ing. Natanael Emir Ferrán · Mg. Lic. Pablo Carlos Zizzutti · Esp. Ing. Ana Laura Diedrichs (FIUBA)  
**Fecha**: Ciudad de Buenos Aires, junio de 2026  
**Contexto personal**: el trabajo nació de una necesidad real de la empresa y del interés propio en música e IA.

---

## Contenido de los capítulos

### Chapter 1 — Introducción general
- **MIR (Music Information Retrieval)**: procesamiento digital de señales + ML para etiquetar canciones automáticamente.
- **Plusyc Live**: plataforma de ambientación musical para locales comerciales. Antes dependía de APIs de terceros (Spotify, Gracenote) para obtener características musicales → costos, límites de consultas, dependencia.
- **Objetivo general**: sistema IA que predice características musicales desde el audio del catálogo de Plusyc.
- **13 características objetivo** (3 grupos):
  - *Básicas*: key, mode, tempo, loudness
  - *Perceptibles*: acousticness, danceability, energy, instrumentalness, liveness, speechiness, valence
  - *Ánimo y género*: primary mood, secondary mood, suggested genres
- **Estado del arte**: Librosa/Essentia (DSP), PANNs/musicnn (modelos preentrenados), Spotify/Gracenote (SaaS), Tunebat (manual). Limitación: ninguno se adapta exactamente a las clases de Plusyc ni es operable a escala sin costo.

### Chapter 2 — Introducción específica
- **Datos**: catálogo privado de Plusyc, +60.000 canciones completas. Ventaja sobre datasets públicos (GTZAN, FMA) que solo ofrecen segmentos de 30s.
- **DSP — representaciones numéricas**: espectrograma, cromagrama, tonnetz (2D). Atributos escalares: MFCC, centroide espectral, ancho de banda, ZCR, rolloff.
- **Semántica — PANNs / CNN14**: red neuronal preentrenada en AudioSet (527 clases). Genera embeddings + probabilidades de eventos sonoros (aplausos, habla, instrumentos).
- **Modelos**: LightGBM (ensamble de árboles, Optuna para hiperparámetros) + MLP (perceptrón multicapa para variables continuas multi-salida).
- **Despliegue**: FastAPI + Docker + OCI (Oracle Cloud), integración asíncrona con Beethoven (herramienta interna de Plusyc).

### Chapter 3 — Diseño e implementación
- **Datasets públicos analizados**: GTZAN, FMA estándar, Million Song Dataset, AudioSet. Identificadas sus variables predictivas y limitaciones.
- **Pipeline de extracción** (dos ramas paralelas):
  1. Rama DSP: ventanas de ~64ms → estadísticos (7: media, std, asimetría, curtosis, P10, P50, P90) → vector estático.
  2. Rama PANNs: ventanas de 10s → CNN14 → embeddings + probabilidades → estadísticos (4: media, máximo, std, P90).
  - Ambas ramas se concatenan (Flatten) → vector por canción.
- **EDA y preprocesamiento**: corte del histórico en fecha específica (cambio de distribución), submuestreo para liveness/speechiness (clases desbalanceadas), limpieza con modelos preentrenados para eliminar falsas etiquetas.
- **Selección de variables**: análisis de importancia de features.
- **Modelos por grupo**:
  - MLP multisalida: acousticness, danceability, energy, instrumentalness, valence.
  - LightGBM individual: tempo, loudness, key, mode, liveness, speechiness, primary mood, secondary mood, suggested genres.

### Chapter 4 — Ensayos y resultados
- **MLP**: early stopping en iteración 74 (mínimo validación 0.0058 en iter 59). R² global 0.8152.
  - Acousticness R²=0.89, Danceability R²=0.74, Energy R²=0.86, Instrumentalness R²=0.83, Valence R²=0.75.
- **Liveness/Speechiness**: primer experimento fallido (R²≈0.15 y 0.28). Solución: limpieza con AudioSet preentrenado + separación del modelo.
- **Key/Mode**: clasificación con LightGBM.
- **Moods y géneros**: clasificación multiclase. Reto: ambigüedad humana en el etiquetado.
- Imágenes clave disponibles en `Presentacion/Img/`: scatter plots (acousticness_actual_vs_predicted.pdf, etc.), curvas de aprendizaje (curva_fivep.png), confusion matrices, feature importance.

### Chapter 5 — Conclusiones
- **Sistema en producción**: clasifica canciones entrantes en Plusyc.
- **Logros clave**: PANNs fue la clave para variables semánticas; técnicas clásicas de ML funcionan bien; reducción de dependencia de APIs.
- **Próximos pasos**: reentrenamiento periódico con Airflow + MLflow; clasificación jerárquica para moods; arquitecturas transformer cuando haya más datos; SaaS posible futuro.

---

## Presentación — especificaciones

### Archivo principal
```
Presentacion/
├── Slides/
│   └── index.html        ← HTML principal de la presentación
├── theme/
│   ├── variables.css     ← Variables CSS (colores, tipografías, espaciados)
│   ├── custom.css        ← Estilos base de Reveal.js
│   └── components.css    ← Componentes reutilizables (pipeline, cards, etc.)
└── Img/                  ← Todas las imágenes disponibles
```

### Restricciones de diseño
- **Máximo 25 diapositivas**, 25 minutos de exposición.
- Demo en video al final (slide aparte).
- **Una sola tipografía**: Inter (ya configurada).
- **Máximo 3 colores principales** (ver paleta abajo).
- Texto grande, pocas palabras por slide.
- Márgenes y alineaciones consistentes.
- No tablas enormes sin explicación.
- No capturas mal recortadas.
- **Numeración de slides obligatoria**: número legible en cada slide (esquina inferior derecha o footer). Formato sugerido: `N / Total` en color `--text-muted` (#8892b0). La slide de portada puede omitir el número.

### Tema elegido: A — Dark Navy + Teal

Seleccionado por su legibilidad y contraste. No cambiar sin confirmación explícita.

```css
--bg-primary: #1a1a2e      /* fondo principal - navy oscuro */
--bg-secondary: #16213e    /* fondo de cards */
--bg-code: #0f0f1a         /* fondo de código/datos */
--text-primary: #e0e0e0    /* texto principal */
--text-heading: #ffffff    /* títulos */
--text-muted: #8892b0      /* texto secundario/apagado */
--accent: #64ffda          /* acento teal — bullets, highlights, barras */
--accent-secondary: #82aaff /* acento azul-lila — subtítulos, valores secundarios */
```

### Reveal.js — cargado desde CDN
```html
<link rel="stylesheet" href="https://unpkg.com/reveal.js/dist/reveal.css">
<script src="https://unpkg.com/reveal.js/dist/reveal.js"></script>
```

### Imágenes disponibles en Presentacion/Img/
Rutas relativas desde `Slides/index.html` → `../Img/<nombre>`

| Imagen | Descripción |
|--------|-------------|
| `espectro_croma_tonnetz.pdf` | Espectrograma + cromagrama + tonnetz de "Weird Fishes" |
| `mapa_top_clases.pdf` | Mapa de calor PANNs/CNN14 (probabilidades semánticas) |
| `curva_fivep.png` | Curvas de aprendizaje MLP (Huber loss + MAE) |
| `acousticness_actual_vs_predicted.pdf` | Scatter real vs predicho |
| `danceability_actual_vs_predicted.pdf` | Scatter real vs predicho |
| `energy_actual_vs_predicted.pdf` | Scatter real vs predicho |
| `instrumentalness_actual_vs_predicted.pdf` | Scatter real vs predicho |
| `valence_actual_vs_predicted.pdf` | Scatter real vs predicho |
| `liveness_antes_rvp.png` / `liveness_despues_rvp.png` | Antes/después de limpiar liveness |
| `speechiness_antes_rvp.png` / `speechiness_despues_rvp.png` | Antes/después de limpiar speechiness |
| `primary_mood_ncm.png` | Confusion matrix primary mood |
| `secondary_mood_ncm.png` | Confusion matrix secondary mood |
| `genre_ncm.png` | Confusion matrix géneros |
| `primary_mood_roc.png` | Curva ROC primary mood |
| `infra.png` / `infra0.png` / `infra2.png` / `infra3.png` | Diagramas de infraestructura |
| `lgbm_block.png` | Diagrama bloque LightGBM |
| `mlp_block.png` | Diagrama bloque MLP |
| `ui_overview.png` / `ui_features.png` / `ui_genres.png` / `ui_mood.png` | Capturas de la UI de Plusyc |
| `distribucion_de_*.png` | Distribuciones EDA por variable |
| `fi_genre.png` / `fi_livenes.png` / `fi_speechiness_top15.png` | Feature importance |
| `paleta_de_colores.png` | Paleta de colores de la app |

---

## Flujo de trabajo para generar la presentación

1. **Spine** → propuesta de estructura slide a slide (título + punto clave + imagen sugerida). Carlos aprueba.
2. **HTML completo** → `Presentacion/Slides/index.html` con todas las slides.
3. No modificar los archivos en `Presentacion/theme/` a menos que se requiera un cambio de estilo explícito.
4. Usar componentes de `components.css` cuando aplique (`.pipeline-box`, `.stage-box`, `.comparison-2col`).
5. Las imágenes `.pdf` no se renderizan en HTML — usar siempre las versiones `.png` equivalentes cuando existan; para las que solo existen en `.pdf`, crear versión SVG/HTML alternativa o indicarlo.

---

## Notas importantes

- Carlos es músico amateur además de ingeniero de IA — el tono puede ser personal en la slide de presentación.
- El jurado ya leyó la memoria — no repetir todo el texto, ir a los puntos clave y los aportes propios.
- Aportes propios: pipeline de extracción propio sobre audio completo, uso de PANNs para semántica, limpieza con AudioSet, sistema en producción en Plusyc.
- El trabajo está **en producción** — esto es un logro concreto para destacar.
- Demo en video al final (slide de transición a demo).
