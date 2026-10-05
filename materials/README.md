# materials/

离线阅读 Edward Kmett 公开材料时的存放约定。学习顺序见 [`docs/learning-path.md`](../docs/learning-path.md)。

## 目录

| 路径 | 是否提交到 git | 说明 |
| --- | --- | --- |
| `materials/<stage>/` | 是（若有文件） | 仅放入**明确允许再分发**的副本（例如带 BSD/MIT/CC 许可的文档，且附带许可全文） |
| `materials/local/<stage>/` | **否**（已在 `.gitignore`） | 由 `scripts/fetch-materials.sh` 拉取的博文 HTML、幻灯片/论文 PDF 等，供本地浏览 |

## 已提交的可再分发文件与许可

**无。**

审查结论（2026-10）：

- [The Comonad.Reader](https://comonad.com/reader/) 博文与演讲页：页面未声明 Creative Commons 或其他再分发许可；默认版权保留，**不得**提交进本公开 fork。
- 幻灯片 PDF（如 *Lenses, Folds and Traversals*、*Linear Optics*）：作者站点提供下载，但未附 CC/开源许可文本，**不得**提交。
- *Applicative Do* 会议论文 PDF：ACM 出版体系下的论文，**不得**再分发进本仓库。
- `ekmett/*` 等开源仓库本身多为 BSD-2/BSD-3：请直接 clone 上游，**不要**把整库嵌进 `materials/`；本路径只链到 GitHub。

因此 `materials/<stage>/` 下当前没有正文文件。若日后遇到明确 CC-BY / BSD / MIT 且适合摘录的文档，再按阶段目录提交，并在本文件登记：

| 相对路径 | 来源 URL | 许可 | 备注 |
| --- | --- | --- | --- |
| （暂无） | | | |

## 本地拉取

```bash
./scripts/fetch-materials.sh
```

脚本会跳过已存在的非空文件，单个 URL 失败不中断。YouTube 录像不下载。拉取结果仅供个人离线阅读，请勿 `git add materials/local`。
