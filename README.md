# Pull vs Push Monitoring Demo

Demonstrates two monitoring models side by side:
- Pull — Prometheus scrapes metrics from services on its own schedule
- Push — services send metrics to Graphite themselves

## Requirements

- [Docker](https://docs.docker.com/get-docker/) 20.10+
- [Docker Compose](https://docs.docker.com/compose/install/) v2.0+
- Ports 80, 2003, 8125, 9090, 9100 must be free

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     PULL MODEL                          │
│                                                         │
│  Prometheus ──GET /metrics──> Node Exporter             │
│  (polls every 5s)              (passively waits)        │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                     PUSH MODEL                          │
│                                                         │
│  test-metrics ──TCP push──> Graphite                    │
│  batch-job    ──TCP push──> Graphite                    │
│  (initiate sending themselves)  (passively receives)    │
└─────────────────────────────────────────────────────────┘
```

## Quick Start

```bash
git clone <repo-url>
cd monitoring-sro10
docker compose up -d
```

Wait ~15 seconds for Graphite to initialize, then open the URLs below.

## URLs

| Service | URL | Description |
|---------|-----|-------------|
| Prometheus UI | http://localhost:9090 | Pull model |
| Prometheus Targets | http://localhost:9090/targets | Target status |
| Node Exporter raw metrics | http://localhost:9100/metrics | What Prometheus scrapes |
| Graphite Web UI | http://localhost:80 | Push model |

---

## Step 1 — Demonstrate Pull Model (Prometheus)

Open http://localhost:9090/targets

You will see:
- `node-exporter` — State: UP
- `prometheus` — State: UP

This shows Prometheus actively polling these addresses every 5 seconds. The targets do nothing — they just wait.

To see raw metrics that Prometheus pulls, open http://localhost:9100/metrics in the browser.

Build a CPU graph at http://localhost:9090/graph using this query:

```
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)
```

Click Execute, then switch to the Graph tab.

---

## Step 2 — Demonstrate Push Model (Graphite)

Open http://localhost:80

In the left panel expand the metrics tree:
```
Metrics → demo → app → cpu_usage
                      → memory_usage
                      → request_rate
```

Click any metric to see the graph. The `test-metrics` container pushes these every 5 seconds.

To send a metric manually:

```bash
echo "demo.manual.test 42 $(date +%s)" | nc -w 1 localhost 2003
```

After a few seconds it will appear in Graphite UI under `demo → manual → test`.

---

## Step 3 — Demonstrate Batch Job (key Push advantage)

```bash
docker compose run --rm batch-job
```

Expected output:

```
=== Batch Job Started ===
Simulating data processing...
PUSH -> Graphite: batch metrics sent
  records_processed=15420
  errors=3
  duration=2s
  success=1
=== Batch Job Completed ===
NOTE: Pull model (Prometheus) would MISS these metrics
      because the job finished before scrape interval.
```

Find the metrics in Graphite UI: `Metrics → demo → batch → records_processed`

Why Pull fails here: Prometheus scrapes every 5 seconds. The batch job finishes in 2 seconds and exits — Prometheus never gets a chance to scrape it. Push solves this because the job sends metrics itself before exiting.

---

## Pull vs Push Comparison

| | Pull (Prometheus) | Push (Graphite) |
|---|---|---|
| Initiator | Monitoring system | Application |
| Batch jobs | Not suitable | Works perfectly |
| Firewall | Needs access to service | Needs access to server |
| Service discovery | Built-in | Manual |
| Scaling | Centralized | Distributed |

---

## Useful Commands

```bash
# Start everything
docker compose up -d

# Watch push metrics in real time
docker compose logs -f test-metrics

# Run batch job manually
docker compose run --rm batch-job

# Stop everything
docker compose down

# Rebuild containers
docker compose build
```
