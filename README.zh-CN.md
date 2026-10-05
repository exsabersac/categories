# categories 中文导读

这是 [Edward Kmett](https://github.com/ekmett/categories) 的 `categories` 库的中文阅读说明，放在英文 [README.markdown](README.markdown) 旁边。英文原文保留。本次改动只有注释和文档：不改运行时行为，不改导出列表，不改公开 API，也不重写算法。

库的版本号是 `2`。更新日志写着这一版用 `multicategories` 和 `hask` 里的片段从头搭过。因此它和 Hackage 上早期、以 `Control.Category` 为中心的 1.x 不是同一套类层次。当前会编译进去的代码只在 `src/Math/`。

他关于范畴论、光学、自由单子和递归模式的公开讲稿、博文与代码库，收在 [Edward Kmett 阅读导引](docs/kmett-reading.md)。那是外部材料的导读，不是本库 API，也不改变任何 Haskell 代码。

若要按「从简单到复杂」学范畴论并落到本库 `src/Math`，用 [学习路径](docs/learning-path.md)。路径按阶段列出目标、练习与模块；外链材料可用脚本拉到本地（不提交进 git）：

```bash
./scripts/fetch-materials.sh
```

拉取结果在 `materials/local/`（已 gitignore）。许可说明见 [`materials/README.md`](materials/README.md)。

## 这个库在做什么

Haskell 自带的 `Control.Category` 把「有单位、能复合」收成一个类，最常见的例子是函数 `(->)`。本库把这件事做得更一般，并且用 kind 多态把箭头写成

```haskell
p :: i -> i -> *
```

`p a b` 是从 `a` 到 `b` 的一条箭头。两端的 kind 是 `i`，不一定是普通类型 `*`。所以同一套类可以套在：

| 箭头 `p` | 直观 |
| --- | --- |
| `(->)` | 类型与函数 |
| `(:-)`（`constraints` 包） | 约束蕴含：「`a` 成立就能推出 `b` 成立」 |
| `(:~:)` | 命题相等，只有 `Refl` |
| `Coercion` | 表象相同因而可以零成本转换 |
| `Yoneda p` | `p` 的对偶范畴，箭头反向 |
| `p * q` / `p + q` | 两个范畴的积 / 不交并 |
| `Nat c d` | 从 `c` 到 `d` 的自然变换 |
| `Forest f` | 多元箭头并排成的森林 |

对象不必自动是「kind 上的全部索引」。类里有关联约束 `Ob p :: i -> Constraint`。默认是什么都不要求的 `Vacuous`。积、并、自然变换、森林这些实例会换一套更紧的 `Ob`。

## 建议阅读顺序

1. [Math.Category](src/Math/Category.hs)：范畴、对象约束、对偶。
2. [Math.Groupoid](src/Math/Groupoid.hs)：每条箭头都有逆。
3. [Math.Functor](src/Math/Functor.hs)：函子、自然变换、二元函子。
4. [Math.Functor.Faithful](src/Math/Functor/Faithful.hs)：全忠实，`fmap` 可逆。
5. [Math.Category.Product](src/Math/Category/Product.hs) 与 [Sum](src/Math/Category/Sum.hs)：范畴的积与并。
6. [Math.Monad](src/Math/Monad.hs)：单子与余单子（自函子上的）。
7. [Math.Rec](src/Math/Rec.hs)：类型级列表上的记录。后面多元结构都靠它。
8. [Math.Polycategory.PRO](src/Math/Polycategory/PRO.hs)：列表对象上的「并排」。
9. [Math.Multicategory](src/Math/Multicategory.hs)：多输入、单输出。
10. [Math.Multicategory.Free](src/Math/Multicategory/Free.hs)：自由多元范畴。
11. [Math.Operad](src/Math/Operad.hs)：只有一个对象的多元范畴，以及相伴的单子 / 余单子。
12. [Math.Monad.Atkey](src/Math/Monad/Atkey.hs)：索引相等时才存在的值。可以和前面分开读。

## 类层次（新读者会先撞上的那几层）

```text
Category p
  Ob p :: i -> Constraint     哪些索引算对象（默认 Vacuous）
  id, (.)                     单位与复合
  source, target              从箭头取出「端点是对象」的 Dict
  op, unop                    进出对偶；对偶的载体是 Yoneda
       │
       ├── Groupoid p         加 inv
       │
       ├── Functor f
       │     Dom f, Cod f, fmap
       │     FunctorOf c d f  把 Dom/Cod 钉死，当作 Nat 的对象约束
       │     ob               函子把对象送到对象（一条约束蕴含）
       │         │
       │         ├── Nat c d f g     自然变换；Nat c d 自己也是范畴
       │         ├── Bifunctor p     余定义域必须是 Nat … 的函子
       │         │     first, second, bimap
       │         │     dimap, lmap, rmap   第一个变元反变时的写法
       │         └── FullyFaithful f  unfmap
       │
       ├── Monad f / Comonad f  要求 Cod f ~ Dom f（自函子）
       │
       ├── p * q                范畴积（一对箭头）
       └── p + q                范畴不交并（箭头不能跨边）

Rec、（++）、Dict1、All          类型级列表设备

PRO p                         对象是列表时，pro 把两条箭头并排

Multicategory f               f :: [i] -> i -> *（多输入、单输出）
  ident, sources, mtarget
  Forest f                    并排；自己是 Category，也是 PRO
  C f                         只留一元箭头，变回普通 Category
  compose                     把森林插进一条多元箭头的输入
  Free f                      由分次生成元自由生成
  Operad f                    对象只剩 '()
      M f                     相伴单子（运算 + 叶子）
      W f                     相伴余单子（对每个运算都能填叶子）

At / Coat，Atkey / Coatkey    用 (:~:) 或 i ~ j 做索引的值
```

箭头方向和 `Prelude` 一致：`f . g` 是先 `g` 后 `f`。`Category` 的法则是单位律和结合律。库不检查这些等式，它们写在各类旁边的中文注释里。

### 对偶与米田

`Yoneda p a b` 里装的是一条 `p b a`（构造子叫 `Op`）。类型族 `Op` 是对合：

- 已经是 `Yoneda` 的，剥掉一层；
- 否则包上一层 `Yoneda`。

所以对偶的对偶回到原来的箭头类型。`op` / `unop` 做值上的翻转。`Yoneda p` 的 `Category` 实例把复合顺序对调，并且把 `source` 和 `target` 对调。

固定对象之后，`Yoneda p a` 是从对偶范畴到 `(->)` 的函子，也就是反变 hom。`FullyFaithful (->)` 用「自然变换作用在 `id` 上」把这个 hom 函子还原成对偶里的一条箭头，这就是米田引理里好计算的那一半。

### 函子为什么长得不像 `Prelude.Functor`

这里的函子带有定义域和余定义域：

```haskell
class (Category (Cod f), Category (Dom f)) => Functor (f :: i -> j) where
  type Dom f :: i -> i -> *
  type Cod f :: j -> j -> *
  fmap :: Dom f a b -> Cod f (f a) (f b)
```

`fmap id = id`，`fmap (f . g) = fmap f . fmap g`。许多实例把 `fmap` 定义成 `(.)`，因为「固定 hom 的一端」本身就是函子：`(->) e`、`(:~:) e`、`Coercion e` 都是后复合。

`ob` 证明函子把对象送到对象。做法是对 `id` 做 `fmap`，再取 `source`。得到的是 `constraints` 里的蕴含 `(:-)`，之后用 `(\\)` 喂给需要对象约束的方法（`Nat` 的单位、`Monad` 的默认 `join` 都这么写）。

自然变换 `Nat c d f g` 的分量只要求在 `c` 的对象上给出 `d (f a) (g a)`。构造子同时记住两端都是 `FunctorOf c d`。垂直复合使 `Nat c d` 成为范畴，对象就是这些函子。自然性方块没有单独的方法，要实例自己保证。

二元函子没有把 `bimap` 写成类方法。约束是：`p` 是函子，且 `Cod p` 是自然变换范畴。于是 `p a` 是第二个变元上的函子，`fmap` 在第一个变元上给出自然变换。`first` 取这个自然变换的分量，`second` 对偏应用做 `fmap`，`bimap f g = first f . second g`。`dimap` 只是先把左边箭头用 `unop` 翻到对偶里，所以第一个变元反变、第二个变元协变（profunctor 的用法）不必再立一个类。

### 单子

`Monad` 要求 `Cod f ~ Dom f`。`return` 和 `join` 是这个范畴里的箭头，不一定是 Haskell 函数。最少实现是 `return` 再加 `join` 或 `bind` 之一。默认 `bind f = join . fmap f`。列表、`Maybe`、`Either`、读写器 `(->) e` 的实例直接调用 `Control.Monad`。

`Comonad` 箭头相反：`extract` 对偶于 `return`，`duplicate` 对偶于 `join`。文件里写了环境余单子 `(,) e`：环境留在元组左边，`extract` 只取出值。

### 积与并

- `(*)`：对象是类型级二元组，箭头是 `Pair` 两条箭头。复合各做各的。两边都是群胚时，逆也各做各的。
- `(+)`：对象是 `Either`，箭头是 `L` 或 `R`，不能从左通到右。对象在类型变量上时无法模式匹配，所以 `sumOb` 用两个继续分支告诉你它在哪一侧。`id` 先问 `sumOb`，再放 `L id` 或 `R id`。交叉复合在类型上不可能，因此只写了同侧的等式，并关掉了不完全模式警告。

### 多元范畴、PRO、operad

普通范畴是「一个输入、一个输出」。多元范畴一条箭头 `f as b` 有一列输入 `as` 和一个输出 `b`。

- `Forest` 把好几条这样的箭头并排。输出列表就是每条的输出排成一排；输入列表是各输入列表用 `(++)` 接起来。并排还没有「插入」。
- 真正的复合是 `compose`：森林代进一条箭头的各个输入。实现上 `f` 必须是二元函子，输入槽的定义域是 `Op (Forest f)`（反变），所以 `lmap` 正好吃进一片森林。
- `C f` 只保留恰好一个输入的箭头，`id` 用 `ident`，于是多元范畴忘掉一层就回到 `Category`。
- `PRO` 是另一件事：对象已经是列表时，`pro` 把两条箭头的定义域列表和余定义域列表同时拼起来（水平并排，不是插接）。`Forest` 是 `PRO`，`(:~:)` 也是（相等对拼接是同余）。
- `Operad` 把对象约束收成「必须等于 `'()`」。只剩一个对象，箭头只由输入个数区分。`M f a` 是「一个运算加上每个叶子一个 `a`」，`bind` 做替换，这就是 operad 对应的单子。`W` 是余单子：无论拿来哪个运算，都能把输入填满。

`Rec` 是这些结构共用的列表。`(++)` 的右单位和结合律对类型变量不是定义展开能得到的，所以 `appendNilAxiom` 和 `appendAssocAxiom` 用 `unsafeCoerce` 把 `Dict (a ~ a)` 转成所需等式。注释里把它们标成公理：等式对这个类型族成立，但证明绕过了类型检查器。

## 源码里未完成的部分（注释没有补实现）

这是实验性重写，有几处实例按字面是不完整的。中文注释只把它们标出来：

- `Math.Multicategory` 里 `Functor (Dat p)` 与 `Functor (Dat p a)` 没有 `fmap`。
- `IM` 的 `fmap` 调用了 `undefined`。记录只肯沿 `(:~:)` 做映射，这里却只有带对象约束的 `Dat`；源码里的 TODO 说需要一个受限的 `Rec`。
- `Monad (IM f)` 只写了 `return`，没有 `join` 或 `bind`。
- `Math.Multicategory.Free` 的实例把关联类型写成 `type Mob (Free f) = Vacuous`。类里要定义的关联类型是 `MDom`，`Mob` 只是 `Ob (MDom f)` 的同义词。按命名看，意图是对象不受约束。该文件也没有写出超类所要求的 `Functor` / `Bifunctor` 实例。

读的时候把这些当成草稿，不要指望原样能在新 GHC 上编过。

## 文档覆盖了哪里

| 范围 | 中文写到什么程度 |
| --- | --- |
| `src/Math/**` 全部 13 个暴露模块 | 模块头，以及范畴、函子、自然变换、单子、记录、多元范畴、自由构造、operad、索引值上的类、数据型和关键函数。每个暴露模块都有中文，不是只写了 `Category`。 |
| `old/src/Control/**` 全部 12 个归档模块 | 模块头 + 类 / 数据型 / 关键函数上的 Haddock 中文（定律、意图、与 `src/Math` 的对照）。英文原文保留；不改运行时与导出。 |

## 归档层次 `old/`（经典 Control.Category 风格）

`old/` 不在 `categories.cabal` 的 `hs-source-dirs` 里，当前包不会编译它。那是 1.x 风格、建立在 `Control.Category` 上的一层：对象、态射、单位、复合、积 / 余积、幺半与闭结构都按教科书名字铺开，方便和现在的实验性 `src/Math.*` 对照。

若要按「经典定义从里到外」读 `old/`，建议顺序：

1. [Discrete](old/src/Control/Category/Discrete.hs)：只有单位箭头；相等证明即态射。
2. [Dual](old/src/Control/Category/Dual.hs)：对偶范畴（箭头反向）；现由 `Yoneda` / `Op` 承担。
3. [Hask](old/src/Control/Category/Hask.hs)：`type Hask = (->)`，对象是类型、态射是函数。
4. [Object](old/src/Control/Categorical/Object.hs)：始对象、终对象（（余）极限特例）。
5. [Functor](old/src/Control/Categorical/Functor.hs) 与 [Bifunctor](old/src/Control/Categorical/Bifunctor.hs)：函子 / 二元函子（函数依赖版）。
6. [Associative](old/src/Control/Category/Associative.hs)：结合子与五边形。
7. [Monoidal](old/src/Control/Category/Monoidal.hs)：单位对象与单位子 λ、ρ，三角形。
8. [Braided](old/src/Control/Category/Braided.hs)：辫子、对称、六边形。
9. [Cartesian](old/src/Control/Category/Cartesian.hs)：有限积与余积（`fst`/`snd`/`&&&`，`inl`/`inr`/`|||`）。
10. [Cartesian.Closed](old/src/Control/Category/Cartesian/Closed.hs)：笛卡尔闭、指数、`curry`/`apply`。
11. [Distributive](old/src/Control/Category/Distributive.hs)：积对余积的分配。

| 旧模块 | 在说什么 |
| --- | --- |
| `Control.Category.Discrete` | 只有单位箭头的离散范畴 |
| `Control.Category.Dual` | 对偶 newtype（现由 `Yoneda` / `Op` 承担） |
| `Control.Category.Hask` | `type Hask = (->)` |
| `Control.Categorical.Object` | 始对象、终对象 |
| `Control.Categorical.Functor` | 用函数依赖写的函子、自函子、抬升/下降 |
| `Control.Categorical.Bifunctor` | `first` / `second` / `bimap` / `dimap` |
| `Control.Category.Associative` | 结合子与五边形 |
| `Control.Category.Monoidal` | 单位子 λ、ρ |
| `Control.Category.Braided` | 辫子与对称 |
| `Control.Category.Cartesian` | 有限积与余积 |
| `Control.Category.Cartesian.Closed` | 笛卡尔闭、指数 |
| `Control.Category.Distributive` | 积对和的分配 |

## 怎样构建

`categories.cabal` 声明的依赖是：

- `base >= 4.7 && < 5`
- `constraints >= 0.5.1 && < 1`
- `void >= 0.5.4.2 && < 1`（当前 `src/` 不直接 import 它；依赖是为旧代码和 cabal 声明留的）

`tested-with` 只写了 GHC 7.8.4 和 7.10.1。源码使用闭类型族、`PolyKinds`、`DataKinds`、`DefaultSignatures`。cabal 字段：

```cabal
library
  hs-source-dirs: src
  default-language: Haskell2010
  ghc-options: -Wall -funbox-strict-fields -O2
```

在依赖能解析的环境里：

```bash
cabal update
cabal build
```

若本地 cabal 是带 sandbox 的老版本，则是 `cabal sandbox init`、`cabal install --only-dependencies`、`cabal build`。只想看文档可以用 Haddock（同样要先能类型检查）：

```bash
cabal haddock
```

中文写在 `-- |` 注释里，会跟英文一起出现在 Haddock 页面中。

不保证当前 GHC 能把这个实验性版本编过：上面列的未完成实例会直接导致类型错误，部分写法也和很新的 GHC 不兼容。注释本身不改变任何等式，所以没有为文档单独跑完整编译。

## 术语对照

| 中文 | 代码里的名字 | 一句话 |
| --- | --- | --- |
| 范畴 | `Category` | 对象、单位箭头、可结合的复合 |
| 对象约束 | `Ob` | 哪些索引算对象 |
| 对偶范畴 | `Op`、`Yoneda` | 同样的对象，箭头反向 |
| 群胚 | `Groupoid` | 箭头可逆 |
| 函子 | `Functor`、`Dom`、`Cod`、`fmap` | 保持单位和复合的映射 |
| 自然变换 | `Nat`、`runNat` | 函子之间的一族箭头，对定义域箭头自然 |
| 二元函子 | `Bifunctor`、`bimap` | 两个变元都保持复合 |
| 全忠实 | `FullyFaithful`、`unfmap` | `fmap` 在 hom 上可逆 |
| 单子 / 余单子 | `Monad`、`Comonad` | 自函子上的单位与乘法，或其对偶 |
| 范畴的积 / 并 | `(*)`、`(+)` | 一对箭头 / 分居两侧的箭头 |
| 多元范畴 | `Multicategory` | 多输入、单输出 |
| 森林 | `Forest` | 多元箭头并排 |
| PRO | `PRO`、`pro` | 列表对象上的水平拼接 |
| 算子元 | `Operad` | 只有一个对象的多元范畴 |
| 记录 | `Rec` | 类型级列表上的异构序列 |

## 上游与许可

版权与许可仍是 Edward Kmett 的 BSD3，见 [LICENSE](LICENSE)。问题与贡献的联系方式以英文 README 为准。这份中文是阅读辅助，不代替原文注释里的文献指向（例如 nLab 上的 Yoneda embedding）。
