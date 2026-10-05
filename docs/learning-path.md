# 通过 Haskell 学范畴论：Kmett 材料学习路径

按「从简单到复杂、可浏览」重排 [`kmett-reading.md`](kmett-reading.md) 里的公开材料，并标出本仓库 `src/Math` 该读哪些模块。条目与链接原则上只复用导读清单；School of Haskell 原文域名当前无法解析，一律改用博客镜像。

**本地副本约定**

| 标记 | 含义 |
| --- | --- |
| 仓库内 | 已提交到 `materials/<阶段>/`（仅明确允许再分发的许可） |
| 可拉取 | 运行 `scripts/fetch-materials.sh` 后出现在 `materials/local/<阶段>/`（默认 gitignore，勿提交） |
| 仅外链 | 仓库 / YouTube 等，脚本不下载 |

当前审查结果：博文、幻灯片 PDF、会议论文均无明确的 CC / 开源再分发许可，故 **`materials/<阶段>/` 未提交任何正文文件**。详见 [`materials/README.md`](../materials/README.md)。

拉取命令：

```bash
./scripts/fetch-materials.sh
```

---

## 总览

| 阶段 | 主题 | 条目数 | 本库模块焦点 |
| --- | --- | --- | --- |
| 0 | 预备：Hask 与地图 | 5 | 先读中文 README，暂不深挖源码 |
| 1 | 范畴 / 函子 / 自然变换 | 10 | `Category`、`Groupoid`、`Functor`、`Faithful`、积与并 |
| 2 | 单子 / 余单子 / 自由构造 | 14 | `Monad`、`Monad.Atkey` |
| 3 | 伴随、Yoneda、Kan 扩张 | 8 | 重读 `Yoneda`/`Op`、`FullyFaithful` |
| 4 | 递归模式 | 6 | （库内无组合子；可顺带看 `Rec`） |
| 5 | 光学 / profunctor | 10 | `Bifunctor` 的 `dimap` / `lmap` / `rmap` |
| 6 | 进阶：约束、多元范畴、本库 | 10 | `Rec`、`PRO`、`Multicategory`、`Free`、`Operad` |

建议顺序：0 → 1 → 2，然后可并行 3 与 4；5 依赖 1（最好有 3 的一点 Yoneda）；6 收束到本仓库。

---

## 阶段 0：预备——Hask 不是 Set，先有一张地图

**目标：** 建立「在 Haskell 里谈范畴」的直觉：类型类不等于定律，Hask 也不等于集合范畴；并知道 Kmett 生态里 `categories` / `lens` / `free` 各管什么。

**前置：** 会写基础 Haskell，见过 `Functor` / `Monad` 名字即可。不必先修过范畴论课。

### 阅读顺序

1. [Across the Kmettverse](https://comonad.com/reader/talks/kmett-2022-functional-futures/)（Edward Kmett，2022；[YouTube](https://www.youtube.com/watch?v=jZrCVp5ekbA)）——他自己画的库地图。先看这场，再决定往哪走。**仅外链**（YouTube 不下载）；演讲页 HTML：**可拉取** → `materials/local/0-prep/across-the-kmettverse-talk.html`
2. [On Hask](https://comonad.com/reader/talks/kmett-2014-on-hask/)（Edward Kmett，2014；[YouTube](https://www.youtube.com/watch?v=Klwkt9oJwg0)）——不要把 `(->)` 实例当成全部范畴等式都在 Hask 里成立。**仅外链** + 演讲页 **可拉取** → `materials/local/0-prep/on-hask-talk.html`
3. [Type Classes vs. the World](https://comonad.com/reader/talks/youtube-hIZxTQP1ifo/)（Edward Kmett，2015；[YouTube](https://www.youtube.com/watch?v=hIZxTQP1ifo)）——定律写不进类型，就靠类型类和惯例。**仅外链** + 演讲页 **可拉取** → `materials/local/0-prep/type-classes-vs-the-world-talk.html`
4. [Procrustean Mathematics](https://comonad.com/reader/2013/editorial-procrustean-mathematics/)（Edward Kmett，2013）——把数学削进 Haskell 会砍掉什么；本库标 experimental 的背景。**可拉取** → `materials/local/0-prep/procrustean-mathematics.html`
5. [Getting a Quick Fix of Comonads](https://comonad.com/reader/talks/youtube-8r1lji4Pzsg/)（Edward Kmett，2014；[YouTube](https://www.youtube.com/watch?v=8r1lji4Pzsg)）——余单子短介绍，为阶段 2 铺垫。**仅外链** + 演讲页 **可拉取** → `materials/local/0-prep/quick-fix-of-comonads-talk.html`

### 练习

- 浏览 [README.zh-CN.md](../README.zh-CN.md) 的「建议阅读顺序」与类层次图，只求认出门牌。
- 用一句话区分：本仓库、`lens`、`free` 各自解决什么问题。

### 本库模块

本阶段不要求读源码；有兴趣可打开 `src/Math/Category.hs` 模块头注释，对照「箭头 kind 不必是 `* -> * -> *` 里的函数」。

---

## 阶段 1：范畴、函子、自然变换

**目标：** 把 `(.)` / `id` 看成一般范畴的复合；理解带 `Dom`/`Cod` 的函子、以及 `Nat` 为何要求自然性。

**前置：** 阶段 0；能读懂带关联类型的简单类型类。

### 阅读顺序

1. [Generalizing `(.)`](https://comonad.com/reader/2006/generalizing-dot/)（Edward Kmett，2006）——本库 `Category` 的直觉源头。**可拉取** → `materials/local/1-category-functor-nat/generalizing-dot.html`
2. [Natural Deduction, Sequent Calculus and Type Classes](https://comonad.com/reader/2012/natural-deduction-sequent-calculus-and-type-classes/)（Edward Kmett，2012）——类型类当证明；对照本库 `Ob` / `Dict`。**可拉取** → `materials/local/1-category-functor-nat/natural-deduction-type-classes.html`
3. [The free theorem for fmap](https://comonad.com/reader/2015/snippets-fmap/)（Edward Kmett，2015；School of Haskell 原文域名当前不可达，用博客镜像）——参数化多态迫使 `fmap` 自然。**可拉取** → `materials/local/1-category-functor-nat/free-theorem-fmap.html`
4. [Unnatural Transformations and Quantifiers](https://comonad.com/reader/2012/unnatural-transformations-and-quantifiers/)（Edward Kmett，2012）——量词如何破坏自然性。**可拉取** → `materials/local/1-category-functor-nat/unnatural-transformations.html`
5. [`ekmett/categories`](https://github.com/ekmett/categories)——上游；本 fork 的 `src/Math` 是实验性重写。**仅外链**
6. [`ekmett/constraints`](https://github.com/ekmett/constraints)——约束蕴含 `( :- )`；本库把约束当箭头时依赖它。**仅外链**
7. [`ekmett/semigroupoids`](https://github.com/ekmett/semigroupoids)——可复合但不强制单位；对照本库更完整的 `Category`。**仅外链**
8. （可选回顾）[On Hask](https://comonad.com/reader/talks/kmett-2014-on-hask/)——读完 `Category` 实例后再听一遍。**仅外链**
9. （对照）[The Comonad.Reader](https://comonad.com/reader/) 首页 / [镜像](https://ekmett.github.io/reader/)——找文入口。**可拉取** 首页 → `materials/local/1-category-functor-nat/comonad-reader-home.html`
10. （客座，可后读）见阶段 3 的 *Categories of Structures*；阶段 1 只需知道「用约束切范畴」与 `Ob` 有关。

### 练习

- 对照 `Math.Category`：说出 `Ob`、`source`/`target`、`op`/`unop` 各解决什么。
- 在纸上写「自然性方块」：为何 `Nat` 只在对象上给分量还不够（结合上一篇量词文）。

### 本库模块

- [`Math.Category`](../src/Math/Category.hs)——`Category`、`Yoneda`、`Op`
- [`Math.Groupoid`](../src/Math/Groupoid.hs)——`inv`
- [`Math.Functor`](../src/Math/Functor.hs)——`Functor`、`Nat`、`Bifunctor`
- [`Math.Functor.Faithful`](../src/Math/Functor/Faithful.hs)——`unfmap`（为阶段 3 铺垫）
- [`Math.Category.Product`](../src/Math/Category/Product.hs)、[`Math.Category.Sum`](../src/Math/Category/Sum.hs)

---

## 阶段 2：单子、余单子与自由构造

**目标：** 把 `Monad` / `Comonad` 看成自函子上的单位与乘法（及对偶）；分清「自由单子」与本库「自由多元范畴」。

**前置：** 阶段 1；熟悉 Haskell 的 `>>=` / `return` 直觉。

### 阅读顺序

1. [Monads for Free](https://comonad.com/reader/2008/monads-for-free/)（Edward Kmett，2008）。**可拉取** → `materials/local/2-monad-comonad-free/monads-for-free.html`
2. [The Cofree Comonad and the Expression Problem](https://comonad.com/reader/2008/the-cofree-comonad-and-the-expression-problem/)（Edward Kmett，2008）。**可拉取** → `materials/local/2-monad-comonad-free/cofree-comonad.html`
3. [Free Monads for Less 系列](https://comonad.com/reader/series/free-monads-for-less/)（Edward Kmett，2011）——系列索引；正文三篇一并拉取。**可拉取** → `materials/local/2-monad-comonad-free/free-monads-for-less-{1,2,3,series}.html`
4. [Monads from Comonads 系列](https://comonad.com/reader/series/monads-from-comonads/)（Edward Kmett，2011）。**可拉取** → `materials/local/2-monad-comonad-free/monads-from-comonads-{1..4,series}.html`
5. [The State Comonad](https://comonad.com/reader/2018/the-state-comonad/)（Edward Kmett，2018）。**可拉取** → `materials/local/2-monad-comonad-free/state-comonad.html`
6. [Parameterized Monads in Haskell](https://comonad.com/reader/2007/parameterized-monads-in-haskell/)（Edward Kmett，2007）——对照 `Math.Monad.Atkey`。**可拉取** → `materials/local/2-monad-comonad-free/parameterized-monads.html`
7. [Monad Homomorphisms](https://comonad.com/reader/talks/monad-homomorphisms-zurihac-2016/)（Edward Kmett，2016；[YouTube](https://www.youtube.com/watch?v=YTaNkWjd-ac)）。**仅外链** + 演讲页 **可拉取** → `materials/local/2-monad-comonad-free/monad-homomorphisms-talk.html`
8. [Desugaring Haskell’s do-Notation into Applicative Operations](https://comonad.com/assets/documents/applicative-do.pdf)（Marlow、Peyton Jones、Kmett、Mokhov，2016；[论文页](https://comonad.com/reader/papers/applicative-do/)）——单子常常比需要的更强。PDF **可拉取** → `materials/local/2-monad-comonad-free/applicative-do.pdf`；论文页 **可拉取** → `.../applicative-do-paper.html`
9. [PHOAS For Free](https://comonad.com/reader/2013/phoas/)（Edward Kmett，2013；SoH 原文不可达）。**可拉取** → `materials/local/2-monad-comonad-free/phoas.html`
10. [Bound](https://comonad.com/reader/2015/bound/)（Edward Kmett，2015；SoH 原文不可达）。**可拉取** → `materials/local/2-monad-comonad-free/bound.html`
11. [`ekmett/free`](https://github.com/ekmett/free)。**仅外链**
12. [`ekmett/comonad`](https://github.com/ekmett/comonad)。**仅外链**
13. [`ekmett/machines`](https://github.com/ekmett/machines)——余单子应用；可选。**仅外链**
14. （回顾）[Getting a Quick Fix of Comonads](https://comonad.com/reader/talks/youtube-8r1lji4Pzsg/)——阶段 0 已列。

### 练习

- 对照本库 `Monad`：`return`/`join` 是范畴里的箭头，不一定是 Haskell 函数。
- 用一句话区分 `ekmett/free` 的自由单子与 `Math.Multicategory.Free`。

### 本库模块

- [`Math.Monad`](../src/Math/Monad.hs)
- [`Math.Monad.Atkey`](../src/Math/Monad/Atkey.hs)

---

## 阶段 3：伴随、Yoneda、Kan 扩张

**目标：** 会把伴随、米田嵌入、左/右 Kan 扩张对应到 Haskell 词汇（及 `kan-extensions` / `adjunctions` 库）；读懂本库 `Yoneda`/`FullyFaithful` 在说米田的哪一半。

**前置：** 阶段 1；阶段 2 读完更顺。

### 阅读顺序

1. [Representing Adjunctions](https://comonad.com/reader/2008/representing-adjunctions/)（Edward Kmett，2008）。**可拉取** → `materials/local/3-adjunction-yoneda-kan/representing-adjunctions.html`
2. [Kan Extensions 系列](https://comonad.com/reader/series/kan-extensions/)（Edward Kmett，2008）——三篇。**可拉取** → `materials/local/3-adjunction-yoneda-kan/kan-extensions-{1,2,3,series}.html`
3. [Adjoint Triples](https://comonad.com/reader/2016/adjoint-triples/)（Edward Kmett，2016）——自由 / 遗忘 / 余自由。**可拉取** → `materials/local/3-adjunction-yoneda-kan/adjoint-triples.html`
4. [Categories of Structures in Haskell](https://comonad.com/reader/2015/categories-of-structures-in-haskell/)（Dan Doel，2015；发在 Kmett 博客）——用约束切结构范畴；与 `Ob p` 最接近的散文。**可拉取** → `materials/local/3-adjunction-yoneda-kan/categories-of-structures.html`
5. [`ekmett/kan-extensions`](https://github.com/ekmett/kan-extensions)——`Ran`/`Lan`/Yoneda/Codensity。**仅外链**
6. [`ekmett/adjunctions`](https://github.com/ekmett/adjunctions)。**仅外链**
7. [`ekmett/hask`](https://github.com/ekmett/hask)——带 lens 味道的范畴论实验；与本库版本 2 有渊源。**仅外链**
8. （对照本库）重读 README「对偶与米田」一节。

### 练习

- 在 `FullyFaithful (->)` 上指出：哪一步对应「hom 函子可逆」。
- 打开 `kan-extensions` 的 Haddock，认出 `Yoneda` / `Codensity` 与阶段 2 自由单子文的关系。

### 本库模块

- 重读 [`Math.Category`](../src/Math/Category.hs) 中 `Yoneda` / `Op`
- 重读 [`Math.Functor.Faithful`](../src/Math/Functor/Faithful.hs)

---

## 阶段 4：递归模式

**目标：** 能按名字认出 cata / ana / hylo / histo / futu / chrono，并知道它们与自由单子、余自由余单子的关系；本库没有这些组合子。

**前置：** 阶段 2。

### 阅读顺序

1. [Recursion Schemes: A Field Guide (Redux)](https://comonad.com/reader/2009/recursion-schemes/)（Edward Kmett，2009）——当索引表。**可拉取** → `materials/local/4-recursion-schemes/recursion-schemes-field-guide.html`
2. [Catamorphisms](https://comonad.com/reader/2014/recursion-schemes-catamorphisms/)（Edward Kmett，2014；SoH 原文不可达）。**可拉取** → `materials/local/4-recursion-schemes/catamorphisms.html`
3. [Catamorphism Knol](https://comonad.com/reader/2012/catamorphism-knol/)（Edward Kmett，2012）。**可拉取** → `materials/local/4-recursion-schemes/catamorphism-knol.html`
4. [广义 hylomorphism 与 chronomorphism 系列](https://comonad.com/reader/series/chronomorphisms/)（Edward Kmett，2008）。**可拉取** → `materials/local/4-recursion-schemes/chronomorphisms-{1,2,3,series}.html`
5. [`recursion-schemes/recursion-schemes`](https://github.com/recursion-schemes/recursion-schemes)（原 `ekmett/recursion-schemes` 指向此处）。**仅外链**
6. （可选）阶段 2 的自由 / 余自由文——折叠与展开的载体。

### 练习

- 对 `data ListF a r = Nil | Cons a r` 手写一个 `cata` 求和。
- 在 Field Guide 表里标出你用过的三个名字。

### 本库模块

无递归模式组合子。可顺带浏览 [`Math.Rec`](../src/Math/Rec.hs)（类型级列表上的记录），为阶段 6 多元结构做准备。

---

## 阶段 5：光学与 profunctor

**目标：** 理解「可复合的函数式引用」如何排成 Setter → Traversal → Fold → Lens → Getter 谱系；与本库共享的是复合（`.`），不是 API。本库没有 `Lens'`。

**前置：** 阶段 1；最好已接触阶段 3 的 Yoneda / `dimap`。

### 阅读顺序

1. [Mirrored Lenses](https://comonad.com/reader/2012/mirrored-lenses/)（Edward Kmett，2012）——van Laarhoven 镜头族。**可拉取** → `materials/local/5-optics-profunctor/mirrored-lenses.html`
2. [Lenses: A Functional Imperative](https://comonad.com/reader/talks/kmett-2011-lenses-functional-imperative/)（Edward Kmett，2011）。**可拉取** → `materials/local/5-optics-profunctor/lenses-functional-imperative-talk.html`
3. [Lenses, Folds and Traversals](https://comonad.com/reader/talks/kmett-2012-lenses-nyc/)（Edward Kmett，2012；[YouTube](https://www.youtube.com/watch?v=cefnmjtAolY)；[幻灯片 PDF](https://ekmett.github.io/haskell/Lenses-Folds-and-Traversals-NYC.pdf)）。PDF **可拉取** → `materials/local/5-optics-profunctor/lenses-folds-traversals-nyc.pdf`；演讲页 **可拉取** → `.../lenses-folds-traversals-talk.html`
4. [Haskell Cast，第 1 集：On Lenses](https://www.haskellcast.com/episode/001-edward-kmett-on-lenses)（Edward Kmett，2013；[YouTube](https://www.youtube.com/watch?v=6GNDzrgFhGM)）。播客页 **可拉取** → `materials/local/5-optics-profunctor/haskellcast-on-lenses.html`（YouTube 不下载）
5. [Monad Transformer Lenses](https://comonad.com/reader/talks/monad-transformer-lenses-warsaw-2016/)（Edward Kmett，2016；[YouTube](https://www.youtube.com/watch?v=Bxcz23GOJqc)）。**可拉取** → `materials/local/5-optics-profunctor/monad-transformer-lenses-talk.html`
6. [A Taste of Linear Optics](https://comonad.com/reader/talks/linear-optics-bx-2021/)（Edward Kmett，2021；[幻灯片 PDF](https://comonad.com/assets/documents/linear-optics-2021.pdf)）。PDF **可拉取** → `materials/local/5-optics-profunctor/linear-optics-2021.pdf`；演讲页 **可拉取** → `.../linear-optics-talk.html`
7. [`ekmett/lens`](https://github.com/ekmett/lens)。**仅外链**
8. [`ekmett/profunctors`](https://github.com/ekmett/profunctors)。**仅外链**
9. [`ekmett/linear-logic`](https://github.com/ekmett/linear-logic)——线性光学实验仓库；勿与 [`ekmett/linear`](https://github.com/ekmett/linear)（线性代数）混淆。**仅外链**
10. （对照）本库 `Bifunctor` 上的 `dimap`——更瘦的一层，没有光学类。

### 练习

- 手写 van Laarhoven `Lens s t a b` 类型，实现 `view` / `set` 各一例。
- 指出本库 `dimap` 与 profunctor 光学共用的「左反变、右协变」形状。

### 本库模块

- [`Math.Functor`](../src/Math/Functor.hs) 中 `Bifunctor`、`dimap` / `lmap` / `rmap`

---

## 阶段 6：进阶——约束范畴、多元范畴与本库 `src/Math`

**目标：** 把前面词汇落到本仓库完整类层次：约束蕴含范畴、`Rec`/`PRO`/`Multicategory`/`Operad`/`Free`；能按 [README.zh-CN.md](../README.zh-CN.md) 顺序通读源码并认出未完成实例。

**前置：** 阶段 1–3；阶段 2 的自由构造直觉；阶段 5 可选。

### 阅读顺序

1. [What Constraints Entail 系列](https://comonad.com/reader/series/what-constraints-entail/)（Edward Kmett，2011）——`( :- )` 自己是范畴。**可拉取** → `materials/local/6-advanced-multicategory/what-constraints-entail-{1,2,series}.html`
2. [There and Back Again: Regular and Inverse Semigroups](https://comonad.com/reader/talks/there-and-back-again-lambda-world-2018/)（Edward Kmett，2018；[YouTube](https://www.youtube.com/watch?v=HGi5AxmQUwU)）——比群胚弱的「几乎可逆」；对照 `Groupoid`。**可拉取** → `materials/local/6-advanced-multicategory/there-and-back-again-talk.html`
3. [Combinators Revisited](https://comonad.com/reader/talks/combinators-yow-2018/)（Edward Kmett，2018；[YouTube](https://www.youtube.com/watch?v=GirDSC6BnCo)）。**可拉取** → `materials/local/6-advanced-multicategory/combinators-revisited-talk.html`
4. [Live Coding 系列](https://comonad.com/reader/series/live-coding/)（Edward Kmett，2018–2023）——与范畴直接相关的主要是 Session 1（交换性）与 Session 4（正则/逆半群）；其余可略。**可拉取** 系列索引 → `materials/local/6-advanced-multicategory/live-coding-series.html`
5. [Categories of Structures in Haskell](https://comonad.com/reader/2015/categories-of-structures-in-haskell/)——阶段 3 已列；读 `Ob` / 自由构造时再读一遍。
6. [Adjoint Triples](https://comonad.com/reader/2016/adjoint-triples/)——对照 `Math.Multicategory.Free` 的「自由」侧（不是同一份代码）。
7. [`ekmett/categories`](https://github.com/ekmett/categories) / [`ekmett/hask`](https://github.com/ekmett/hask) / [`ekmett/constraints`](https://github.com/ekmett/constraints)——外链对照。
8. [Across the Kmettverse](https://comonad.com/reader/talks/kmett-2022-functional-futures/)——通读本库后再看一遍地图。
9. 本仓库 [README.zh-CN.md](../README.zh-CN.md)——类层次、未完成实例、术语表。
10. [`docs/kmett-reading.md`](kmett-reading.md)——按主题的完整清单（本路径的超集索引）。

### 练习

- 按 README「建议阅读顺序」1–11 通读 `src/Math`，每模块用一句话记「它在层次里的位置」。
- 画出 `Forest` → `compose` → `C f` 回到普通 `Category` 的关系。
- 标出源码里 `undefined` / 缺 `fmap` 的草稿点（见 README「未完成的部分」）。

### 本库模块（本阶段主战场）

- [`Math.Rec`](../src/Math/Rec.hs)
- [`Math.Polycategory.PRO`](../src/Math/Polycategory/PRO.hs)
- [`Math.Multicategory`](../src/Math/Multicategory.hs)
- [`Math.Multicategory.Free`](../src/Math/Multicategory/Free.hs)
- [`Math.Operad`](../src/Math/Operad.hs)
- 并回顾阶段 1–2 全部模块；可选浏览 `old/src/Control/**`（不参与当前 cabal 构建）对照 1.x 层次

---

## 死链与镜像说明

| URL | 状态 | 处理 |
| --- | --- | --- |
| `https://www.schoolofhaskell.com/user/edwardk/snippets/fmap` | 域名无法解析（2026-10 检测） | 改用 `https://comonad.com/reader/2015/snippets-fmap/` |
| `https://www.schoolofhaskell.com/user/edwardk/recursion-schemes/catamorphisms` | 同上 | 改用 `https://comonad.com/reader/2014/recursion-schemes-catamorphisms/` |
| `https://www.schoolofhaskell.com/user/edwardk/phoas` | 同上 | 改用 `https://comonad.com/reader/2013/phoas/` |
| `https://www.schoolofhaskell.com/user/edwardk/bound` | 同上 | 改用 `https://comonad.com/reader/2015/bound/` |

YouTube 录像一律不下载；请用浏览器打开导读中的视频链接。GitHub 仓库请直接 clone 上游，不写入本 fork 的 `materials/`。

---

## 与 `kmett-reading.md` 的关系

- [`kmett-reading.md`](kmett-reading.md)：按主题归档的完整书目（范畴进 Haskell / 光学 / 单子与递归 / 其他）。
- 本文：同一批材料的**学习顺序** + 本库模块对照 + 本地拉取路径。

两份文档应一起用：路径负责「先读什么」，导读负责「还有哪些同主题条目」。
