# Benchmark summary

## Framework

| Executed hooks | pre-commit | prek | prek speedup |
| -- | -: | -: | -: |
| 1 no-op hook | 224 ms | 68 ms | 3.30x |
| 10 sequential no-op hooks | 458 ms | 255 ms | 1.80x |

## Runtime ladder

| Runner and configuration | Pooled median | Samples |
| -- | -: | -: |
| pre-commit | 1,737 ms | 30 |
| prek: no fast path | 1,438 ms | 30 |
| prek: fast path | 213 ms | 30 |
| prek: + priority | 172 ms | 30 |
| prek: + 2 projects | 135 ms | 30 |

## Clean git diff

Pooled median: 18 ms
