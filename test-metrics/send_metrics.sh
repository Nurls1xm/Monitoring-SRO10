#!/bin/bash
# =============================================================
# Push Model Demo: test-metrics
# Этот контейнер сам ОТПРАВЛЯЕТ метрики в Graphite (push)
# Не ждёт, пока кто-то придёт — сам инициирует отправку
# =============================================================

GRAPHITE_HOST="graphite"
GRAPHITE_PORT="2003"

echo "Starting push metrics to Graphite at ${GRAPHITE_HOST}:${GRAPHITE_PORT}"

while true; do
  TIMESTAMP=$(date +%s)

  # Генерируем CPU-like метрику (случайное значение 10-90%)
  CPU=$(awk -v min=10 -v max=90 'BEGIN{srand(); print int(min+rand()*(max-min))}')

  # Генерируем memory-like метрику
  MEM=$(awk -v min=30 -v max=80 'BEGIN{srand(); print int(min+rand()*(max-min))}')

  # Генерируем request rate
  REQ=$(awk -v min=50 -v max=500 'BEGIN{srand(); print int(min+rand()*(max-min))}')

  # PUSH: отправляем метрики в Graphite по TCP (plaintext protocol)
  # Формат: <metric.path> <value> <timestamp>
  {
    echo "demo.app.cpu_usage ${CPU} ${TIMESTAMP}"
    echo "demo.app.memory_usage ${MEM} ${TIMESTAMP}"
    echo "demo.app.request_rate ${REQ} ${TIMESTAMP}"
  } | nc -w 1 "${GRAPHITE_HOST}" "${GRAPHITE_PORT}" 2>/dev/null

  echo "[$(date '+%H:%M:%S')] PUSH -> Graphite: cpu=${CPU}% mem=${MEM}% req=${REQ}/s"

  sleep 5
done
