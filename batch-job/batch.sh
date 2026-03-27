#!/bin/bash
# =============================================================
# Push Model Demo: batch-job
# Демонстрирует ключевое преимущество Push модели:
# короткоживущий процесс успевает отправить метрики
# до завершения работы.
#
# В Pull модели (Prometheus) такой job был бы невидим —
# он завершится раньше, чем Prometheus придёт за метриками.
# =============================================================

GRAPHITE_HOST="graphite"
GRAPHITE_PORT="2003"

echo "=== Batch Job Started ==="
echo "Simulating data processing..."

# Имитируем работу batch процесса
sleep 2

TIMESTAMP=$(date +%s)

# PUSH: отправляем итоговые метрики сразу по завершении работы
{
  echo "demo.batch.records_processed 15420 ${TIMESTAMP}"
  echo "demo.batch.errors 3 ${TIMESTAMP}"
  echo "demo.batch.duration_seconds 2 ${TIMESTAMP}"
  echo "demo.batch.success 1 ${TIMESTAMP}"
} | nc -w 1 "${GRAPHITE_HOST}" "${GRAPHITE_PORT}" 2>/dev/null

echo "PUSH -> Graphite: batch metrics sent"
echo "  records_processed=15420"
echo "  errors=3"
echo "  duration=2s"
echo "  success=1"
echo ""
echo "=== Batch Job Completed ==="
echo "NOTE: Pull model (Prometheus) would MISS these metrics"
echo "      because the job finished before scrape interval."
