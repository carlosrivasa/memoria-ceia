#!/bin/bash
# Exporta la presentación Reveal.js a PDF usando decktape
# Uso: ./export_pdf.sh [nombre_salida.pdf]

OUTPUT="${1:-presentacion.pdf}"
PORT=3737
PRESENTACION_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "→ Iniciando servidor local en puerto $PORT..."
npx --yes serve "$PRESENTACION_DIR" -l $PORT &
SERVER_PID=$!

# Esperar que el servidor esté listo
sleep 2

echo "→ Exportando a $OUTPUT ..."
npx --yes decktape reveal \
  "http://localhost:$PORT/Slides/index.html" \
  "$OUTPUT" \
  --size 1280x720 \
  --pause 1500

EXIT_CODE=$?

echo "→ Deteniendo servidor..."
kill $SERVER_PID 2>/dev/null
wait $SERVER_PID 2>/dev/null

if [ $EXIT_CODE -eq 0 ]; then
  echo "✓ PDF generado: $OUTPUT"
else
  echo "✗ Error al generar el PDF (código $EXIT_CODE)"
fi
