# uHIL

uHIL 聚合仓库，通过 Git submodule 管理各组件。

## 组件

| 目录 | 仓库 |
|------|------|
| `flash` | [getgauge/Flash](https://github.com/getgauge/Flash) |
| `flash-plus` | [Linhanmic/flash-plus](https://github.com/Linhanmic/flash-plus) |
| `gauge` | [getgauge/gauge](https://github.com/getgauge/gauge) |
| `gauge-js-demo` | [Linhanmic/gauge-js-demo](https://github.com/Linhanmic/gauge-js-demo) |
| `gauge-proto` | [getgauge/gauge-proto](https://github.com/getgauge/gauge-proto) |
| `html-report` | [getgauge/html-report](https://github.com/getgauge/html-report) |

## 克隆

```bash
git clone --recurse-submodules https://github.com/Linhanmic/uHIL.git
```

若已克隆但未拉取子模块：

```bash
git submodule update --init --recursive
```
