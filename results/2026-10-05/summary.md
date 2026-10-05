# Benchmark summary

## Framework

| Executed hooks | pre-commit | prek | prek speedup |
| -- | --: | --: | --: |
| 1 no-op hook | 231 ms | 70 ms | 3.30x |
| 10 sequential no-op hooks | 556 ms | 303 ms | 1.83x |

## Runtime ladder

| Runner and configuration | Pooled median | Samples |
| -- | --: | --: |
| pre-commit | 1,945 ms | 30 |
| prek: no fast path | 1,571 ms | 30 |
| prek: fast path | 115 ms | 30 |
| prek: + priority | 96 ms | 30 |
| prek: + 2 projects | 82 ms | 30 |

## Clean git diff

Pooled median: 31 ms
