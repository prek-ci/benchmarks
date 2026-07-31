# Benchmark summary

## Framework

| Executed hooks | pre-commit | prek | prek speedup |
| -- | --: | --: | --: |
| 1 no-op hook | 231 ms | 107 ms | 2.16x |
| 10 sequential no-op hooks | 546 ms | 431 ms | 1.27x |

## Runtime ladder

| Runner and configuration | Pooled median | Samples |
| -- | --: | --: |
| pre-commit | 2,028 ms | 30 |
| prek: no fast path | 1,860 ms | 30 |
| prek: fast path | 203 ms | 30 |
| prek: + priority | 161 ms | 30 |
| prek: + 2 projects | 139 ms | 30 |

## Clean git diff

Pooled median: 34 ms
