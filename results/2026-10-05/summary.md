# Benchmark summary

## Framework

| Executed hooks | pre-commit | prek | prek speedup |
| -- | --: | --: | --: |
| 1 no-op hook | 228 ms | 67 ms | 3.40x |
| 10 sequential no-op hooks | 533 ms | 299 ms | 1.78x |

## Runtime ladder

| Runner and configuration | Pooled median | Samples |
| -- | --: | --: |
| pre-commit | 1,942 ms | 30 |
| prek: no fast path | 1,534 ms | 30 |
| prek: fast path | 105 ms | 30 |
| prek: + priority | 94 ms | 30 |
| prek: + 2 projects | 80 ms | 30 |

## Clean git diff

Pooled median: 31 ms
