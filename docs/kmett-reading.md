# Edward Kmett：范畴、光学与 Haskell 导读

这份清单只收公开材料：标题、作者、年份（能确定时）和原链接，每条加一句中文，说明它和阅读本仓库有什么关系。不抄讲稿，也不搬论文正文。

本仓库是 Edward Kmett 的 [`categories`](https://github.com/ekmett/categories) 的实验性重写，不是 [`lens`](https://github.com/ekmett/lens)。`categories.cabal` 写着 `stability: experimental`、版本 `2`；会编译的代码在 `src/Math/`，类层次是范畴、群胚、函子、自然变换、单子与余单子、多元范畴和自由多元范畴。下面的材料是这套类的背景：他如何把范畴论写进 Haskell，以及光学、自由单子、递归模式这些相邻工作。它们解释动机和词汇，不提供本库没有的实例。

他的博客是 [The Comonad.Reader](https://comonad.com/reader/)（[ekmett.github.io/reader](https://ekmett.github.io/reader/) 是镜像）。School of Haskell 上的原文在 [`schoolofhaskell.com/user/edwardk`](https://www.schoolofhaskell.com/user/edwardk)，站点后来只读，文还在。客座文章单独标明作者。

## 范畴论进 Haskell

- [Generalizing `(.)`](https://comonad.com/reader/2006/generalizing-dot/)（Edward Kmett，2006）。把函数复合看成范畴里的复合。本库的 `Category` 就是这条路的终点：`id` 与 `(.)`，箭头不必是 `(->)`。
- [Parameterized Monads in Haskell](https://comonad.com/reader/2007/parameterized-monads-in-haskell/)（Edward Kmett，2007）。单子的返回类型可以带着会变的索引。用来读 `Math.Monad.Atkey`：值只在两端索引相等时才存在。
- [Kan Extensions 系列](https://comonad.com/reader/series/kan-extensions/)（Edward Kmett，2008）。三篇：定义、伴随与提升、end 与 coend。本库没有 `Ran`/`Lan` 类型；读函子、自然变换和对偶时，词汇在这里。
- [Representing Adjunctions](https://comonad.com/reader/2008/representing-adjunctions/)（Edward Kmett，2008）。伴随如何写成 Haskell 里的一对方向。对照 `FullyFaithful`：`fmap` 可逆时，函子在 hom 上是同构。
- [Unnatural Transformations and Quantifiers](https://comonad.com/reader/2012/unnatural-transformations-and-quantifiers/)（Edward Kmett，2012）。量词会破坏自然性。`Math.Functor` 里的 `Nat` 要求变换对定义域的箭头自然，这篇说明这个要求在防什么。
- [Natural Deduction, Sequent Calculus and Type Classes](https://comonad.com/reader/2012/natural-deduction-sequent-calculus-and-type-classes/)（Edward Kmett，2012）。把类型类当证明、把实例当推导。本库用 `Ob` 和 `Dict` 见证「这个索引是对象」，是同一习惯。
- [What Constraints Entail 系列](https://comonad.com/reader/series/what-constraints-entail/)（Edward Kmett，2011）。约束蕴含 `( :- )` 自己构成一个范畴。中文导读里拿 `constraints` 当箭头的例子，来自这里，不是来自 `lens`。
- [On Hask](https://www.youtube.com/watch?v=Klwkt9oJwg0)（Edward Kmett，2014，Boston Haskell；[演讲页](https://comonad.com/reader/talks/kmett-2014-on-hask/)）。Haskell 的类型和函数并不是集合范畴。不要把本库里 `(->)` 的实例当成全部范畴等式都已经在 Hask 里成立。
- [The free theorem for fmap](https://www.schoolofhaskell.com/user/edwardk/snippets/fmap)（Edward Kmett，2015，School of Haskell；[博客镜像](https://comonad.com/reader/2015/snippets-fmap/)）。参数化多态迫使 `fmap` 自然。这是本库把自然变换收成 `Nat` 的理由，而不只是多一个类。
- [Type Classes vs. the World](https://www.youtube.com/watch?v=hIZxTQP1ifo)（Edward Kmett，2015，Boston Haskell；[演讲页](https://comonad.com/reader/talks/youtube-hIZxTQP1ifo/)）。定律写不进 Haskell 的类型，就靠类型类和惯例。本库的类也是这样：结合律不在类型里。
- [Procrustean Mathematics](https://comonad.com/reader/2013/editorial-procrustean-mathematics/)（Edward Kmett，2013）。把数学结构削进 Haskell 会砍掉什么。本库标成 experimental，不少实例没写完，这篇是他承认这种削法的代价。
- [Adjoint Triples](https://comonad.com/reader/2016/adjoint-triples/)（Edward Kmett，2016）。自由、遗忘、余自由组成三连伴随。`Math.Multicategory.Free` 是「自由」这一侧的一个实例，不是这篇里的那份代码。
- [Categories of Structures in Haskell](https://comonad.com/reader/2015/categories-of-structures-in-haskell/)（Dan Doel，2015；发在 Kmett 的博客，不是 Kmett 写的）。用约束切出带结构的范畴，再把自由和余自由写成 Kan 扩张。和本库的 `Ob p :: i -> Constraint` 最接近的一篇散文。
- [`ekmett/categories`](https://github.com/ekmett/categories)。上游。简介仍是 “categories from category-extras”。本 fork 的 `src/Math` 是后来的实验性重写，和 Hackage 上早期以 `Control.Category` 为中心的 1.x 不是同一套类。
- [`ekmett/hask`](https://github.com/ekmett/hask)。仓库自述是给 Haskell 用的、带 lens 味道的范畴论，而且要很老的 GHC。版本 2 的更新日志写过：这一版用 `multicategories` 和这里的片段重搭过。
- [`ekmett/kan-extensions`](https://github.com/ekmett/kan-extensions)。`Ran`、`Lan`、Yoneda、Codensity 的库。2008 年那三篇博客的可运行对应物；本仓库没有这些类型。
- [`ekmett/adjunctions`](https://github.com/ekmett/adjunctions)。伴随函子的类。本库的 `Monad` / `Comonad` 只要求自函子，没有把伴随做成类。
- [`ekmett/constraints`](https://github.com/ekmett/constraints)。在 `ConstraintKinds` 下编程的工具，包括约束蕴含。本库把 `( :- )` 当作范畴时依赖这个包。
- [`ekmett/semigroupoids`](https://github.com/ekmett/semigroupoids)。可以复合、但不强制单位箭头的结构。本库的 `Category` 把 `id` 和 `(.)` 放在一起，是这条谱系上要求更全的一端。

## 光学（lenses / optics）

本库没有 lens。下面这些说明他如何把「能复合的函数式引用」收成范畴里的箭头；和本库共享的是复合，不是 API。

- [Lenses: A Functional Imperative](https://comonad.com/reader/talks/kmett-2011-lenses-functional-imperative/)（Edward Kmett，2011-05-24，Boston Area Scala Enthusiasts）。函数式引用为什么值得做成可复合的镜头。演讲页里嵌了五段录像，顺序以该页为准。
- [Mirrored Lenses](https://comonad.com/reader/2012/mirrored-lenses/)（Edward Kmett，2012）。van Laarhoven 镜头族：多态更新、只读或只写，并且用 Prelude 的 `(.)` 复合。后来的 `lens` 从这里长出来。
- [Lenses, Folds and Traversals](https://www.youtube.com/watch?v=cefnmjtAolY)（Edward Kmett，2012-12-12，New York Haskell；[幻灯片 PDF](https://ekmett.github.io/haskell/Lenses-Folds-and-Traversals-NYC.pdf)，[演讲页](https://comonad.com/reader/talks/kmett-2012-lenses-nyc/)）。Setter、遍历、折叠、镜头、Getter 排成一条越来越强的谱系。本库的 `(.)` 是同一句「力量在点号里」，只是对象是范畴箭头而不是光学。
- [Haskell Cast，第 1 集：On Lenses](https://www.haskellcast.com/episode/001-edward-kmett-on-lenses)（Edward Kmett，2013；[YouTube](https://www.youtube.com/watch?v=6GNDzrgFhGM)）。口头讲 `lens` 为什么长成那样。比幻灯片好读，仍然不是本库的教程。
- [Monad Transformer Lenses](https://www.youtube.com/watch?v=Bxcz23GOJqc)（Edward Kmett，2016-07-25，Monadic Warsaw；[演讲页](https://comonad.com/reader/talks/monad-transformer-lenses-warsaw-2016/)）。在更一般的范畴里做镜头，包括单子变换子组成的幺半范畴。和本库「箭头的 kind 不必是 `* -> * -> *` 里的函数」是同一个方向。
- [A Taste of Linear Optics](https://comonad.com/reader/talks/linear-optics-bx-2021/)（Edward Kmett，2021-06-21，Bx 2021；[幻灯片 PDF](https://comonad.com/assets/documents/linear-optics-2021.pdf)）。线性逻辑里的光学。本库没有线性类型；只说明光学后来被放进资源敏感的范畴。
- [`ekmett/lens`](https://github.com/ekmett/lens)。镜头、折叠、遍历的实现。读光学去这里，不要在 `src/Math` 里找 `Lens'`。
- [`ekmett/profunctors`](https://github.com/ekmett/profunctors)。profunctor 以及 `Strong`、`Choice`。2016 年那场镜头演讲用的词汇在这个库里。本库 `Bifunctor` 上的 `dimap` / `lmap` / `rmap` 是更瘦的一层，没有光学类。
- [`ekmett/linear-logic`](https://github.com/ekmett/linear-logic)。上面那份 2021 幻灯片指向的实验仓库。[`ekmett/linear`](https://github.com/ekmett/linear) 是低维线性代数，不是线性类型，不要看错。

## 单子、自由构造与递归模式

- [Monads for Free](https://comonad.com/reader/2008/monads-for-free/)（Edward Kmett，2008）。一个函子的自由单子是什么，以及怎样折叠它。读 `Math.Multicategory.Free` 之前，先分清「自由单子」和「自由多元范畴」不是同一个构造。
- [The Cofree Comonad and the Expression Problem](https://comonad.com/reader/2008/the-cofree-comonad-and-the-expression-problem/)（Edward Kmett，2008）。余自由余单子与自由单子对偶，并用来拆开可扩展的表达式。本库的 `Comonad` 只是自函子上的类，不是这个数据类型。
- [广义 hylomorphism 与 chronomorphism](https://comonad.com/reader/series/chronomorphisms/)（Edward Kmett，2008）。三篇：广义 hylomorphism、chronomorphism、dynamorphism 如何看成 chronomorphism。折叠可以回头看，展开可以一次种下多层种子；承载它们的是自由单子和余自由余单子。
- [Recursion Schemes: A Field Guide (Redux)](https://comonad.com/reader/2009/recursion-schemes/)（Edward Kmett，2009）。一张表，给 cata、ana、hylo、histo、futu、chrono 等各起一个名字。当索引用；本库没有这些组合子。
- [Catamorphisms](https://www.schoolofhaskell.com/user/edwardk/recursion-schemes/catamorphisms)（Edward Kmett，2014，School of Haskell；[博客镜像](https://comonad.com/reader/2014/recursion-schemes-catamorphisms/)）。可运行的折叠笔记，比 2009 年那张表更具体。
- [Catamorphism Knol](https://comonad.com/reader/2012/catamorphism-knol/)（Edward Kmett，2012）。更早的折叠笔记，原是 Google Knol，后来迁到博客。和上一篇重叠，留着看他当时的说法。
- [Free Monads for Less 系列](https://comonad.com/reader/series/free-monads-for-less/)（Edward Kmett，2011）。三篇：Codensity、Yoneda、把 IO 让出去。解释自由单子为什么常换成别的表示，而不是死守一层 `Free`。
- [Monads from Comonads 系列](https://comonad.com/reader/series/monads-from-comonads/)（Edward Kmett，2011）。四篇：从余单子做出单子，再做成单子变换子。本库把 `Monad` 和 `Comonad` 并排放，这篇说明它们不是两套无关的名字。
- [The State Comonad](https://comonad.com/reader/2018/the-state-comonad/)（Edward Kmett，2018）。State 也有余单子形式。用来记住「余」不是把单子的名字加个 co。
- [PHOAS For Free](https://www.schoolofhaskell.com/user/edwardk/phoas)（Edward Kmett，2013，School of Haskell；[博客镜像](https://comonad.com/reader/2013/phoas/)）。用参数化高阶抽象语法少写绑定样板。和自由单子一样是「由结构生成」，本库的自由多元范畴不处理名字绑定。
- [Bound](https://www.schoolofhaskell.com/user/edwardk/bound)（Edward Kmett，2015，School of Haskell；[博客镜像](https://comonad.com/reader/2015/bound/)）。`bound` 库怎么表示局部作用域。自由单子偏效应，这个库偏名字。
- [Desugaring Haskell’s do-Notation into Applicative Operations](https://comonad.com/assets/documents/applicative-do.pdf)（Simon Marlow、Simon Peyton Jones、Edward Kmett、Andrey Mokhov，Haskell Symposium，2016 年 9 月；[他的论文页](https://comonad.com/reader/papers/applicative-do/)，出版页 [doi:10.1145/2976002.2976007](https://dl.acm.org/doi/10.1145/2976002.2976007)）。能看成 applicative 的 `do` 就不要留成单子。本库的 `Monad` 比 `(>>=)` 更抽象；这篇说明在 Haskell 里单子也常常比需要的更强。
- [`ekmett/free`](https://github.com/ekmett/free)。自由单子、余自由余单子以及几种更省的表示。对应 2008 和 2011 年那两组博客，不是 `Math.Multicategory.Free`。
- [`recursion-schemes/recursion-schemes`](https://github.com/recursion-schemes/recursion-schemes)。递归模式库。`ekmett/recursion-schemes` 会跳到这里；简介引用 Meijer、Fokkinga、Paterson 的 “Functional Programming with Bananas, Lenses, Envelopes and Barbed Wire”，那篇不是 Kmett 的论文。
- [`ekmett/comonad`](https://github.com/ekmett/comonad)。余单子的类和常见实例。本库有自己的 `Comonad`，定义更瘦，而且要求 `Cod f ~ Dom f`。
- [`ekmett/machines`](https://github.com/ekmett/machines)。可复合的流传感器网络。余单子的一个应用；类不在本仓库。

## 其他

- [Across the Kmettverse](https://www.youtube.com/watch?v=jZrCVp5ekbA)（Edward Kmett，2022，Functional Futures / Serokell；[演讲页](https://comonad.com/reader/talks/kmett-2022-functional-futures/)）。他自己画的库地图。先看这场，再决定往 `lens`、`free` 还是本仓库走。
- [Getting a Quick Fix of Comonads](https://www.youtube.com/watch?v=8r1lji4Pzsg)（Edward Kmett，2014-09-17，Boston Haskell；[演讲页](https://comonad.com/reader/talks/youtube-8r1lji4Pzsg/)）。余单子的短介绍。比 2008 年的长文更容易入口，随后再回博客。
- [Monad Homomorphisms](https://www.youtube.com/watch?v=YTaNkWjd-ac)（Edward Kmett，2016-07-23，ZuriHac；[演讲页](https://comonad.com/reader/talks/monad-homomorphisms-zurihac-2016/)）。单子之间保持结构的箭头。本库的 `Monad` 只给了单位和乘法，没有把同态做成类。
- [There and Back Again: Regular and Inverse Semigroups](https://www.youtube.com/watch?v=HGi5AxmQUwU)（Edward Kmett，2018，Lambda World；[演讲页](https://comonad.com/reader/talks/there-and-back-again-lambda-world-2018/)）。正则半群和逆半群：比群胚弱的「几乎可逆」。本库的 `Groupoid` 要求每条箭头都有 `inv`，是更强的那一端。
- [Combinators Revisited](https://www.youtube.com/watch?v=GirDSC6BnCo)（Edward Kmett，2018，YOW! Lambda Jam，悉尼；[演讲页](https://comonad.com/reader/talks/combinators-yow-2018/)）。用组合子而不是命名函数搭程序。和本库用复合搭范畴是同一口味。会议幻灯片的直链这次没有稳定下来，以演讲页和录像为准。
- [Live Coding 系列](https://comonad.com/reader/series/live-coding/)（Edward Kmett，2018–2023）。很长。和范畴直接有关的主要是 Session 1（交换性）和 Session 4（正则半群与逆半群）。其余是 succinct 结构、关系编程等，不拿来读 `src/Math`。

## 没有收进来的

- 没有找到 Kmett 单独或共同署名的、专门讲 profunctor optics 或镜头定律的同行评审论文。Pickering、Gibbons、Wu 以及 Riley 等人的光学论文不是他的，这里不列。
- Kan 扩张、自由单子、递归模式没有找到他挂在 arXiv 上的论文。材料就是上面的博客、School of Haskell 和库。
- 博客上大量 Boston Haskell 录像是别人的报告，只是收在他的站点里，没有算作他的作品。Gershom Bazerman、Dan Doel 的客座长文同样只保留了和本库 `Ob` 直接相关的那一篇，并写明作者。
