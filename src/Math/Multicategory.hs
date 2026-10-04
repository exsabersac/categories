{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE FlexibleContexts #-}

{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}

-- |
-- Module      : Math.Multicategory
--
-- 多元范畴 (multicategory)：一条箭头可以有多个输入、一个输出。
-- 箭头种类是 @f :: [i] -> i -> *@，@f as b@ 表示输入列表为 @as@、输出为 @b@ 的箭头。
--
-- 本文件同时给出：
--
-- * 'Forest'：若干条多元箭头并排放（输出并成列表，输入列表用 @(++)@ 接起来），它自己构成范畴，也是 'PRO'。
-- * 'C'：忘掉多元结构，只保留恰好一个输入的箭头，得到普通 'Category'。
-- * 'compose'：把一片森林接到一条多元箭头的各个输入上（真正的多元复合）。
-- * 'Dat'：只含单位箭头、对象还要满足某个约束的小范畴。
-- * 'IM'：多元箭头配上一列输入值，试图做成 'Monad'。见下面的未完成处。
module Math.Multicategory 
  ( Forest(..)
  , C(..)
  , Multicategory(..)
  -- * Utilities 
  , inputs, outputs
  , splitForest
  ) where

import Data.Constraint
import Data.Proxy
import Data.Type.Equality
import Math.Category
import Math.Functor
import Math.Monad
import Math.Polycategory.PRO
import Math.Rec
import Prelude (($))
import qualified Prelude



--------------------------------------------------------------------------------
-- 【中文】森林：多元箭头的「并排」，还没有互相插入。
-- * Forests
--------------------------------------------------------------------------------

-- | @Nil@ 是空森林（没有输入也没有输出）。
-- @h :- hs@ 把一条多元箭头 @h@ 放在森林左边：它的输出 @o@ 接到输出列表头上，
-- 它的输入列表 @k@ 用 @(++)@ 接到其余输入的前面。
-- 因此输出列表的长度等于森林里箭头的条数，输入列表的长度是各条输入个数之和。
data Forest :: ([i] -> i -> *) -> [i] -> [i] -> * where
  Nil :: Forest f '[] '[]
  (:-) :: f k o -> Forest f m n -> Forest f (k ++ m) (o ': n)

-- | 收集整片森林的输入索引。参数是「从一条多元箭头取出它输入列表的记录」的函数，
-- 结果用 'appendRec' 按森林的顺序接成一条大记录。
inputs  :: forall f g is os. (forall as b. f as b -> Rec g as) -> Forest f is os -> Rec g is
inputs _ Nil = RNil 
inputs f (a :- as) = f a `appendRec` inputs f as

-- | 收集每条多元箭头的输出，得到一条与输出列表等长的 'Rec'。
outputs :: (forall as b. f as b -> p b) -> Forest f is os -> Rec p os
outputs _ Nil = RNil
outputs f (a :- as) = f a :& outputs f as

-- | 把一片「输出恰好是 @is ++ js@」的森林，按 @is@ 的长度切成前后两片。
--
-- @Rec f is@ 只提供长度和索引，@Forest g js os@ 是已经分开的后半段参考，
-- 第三个参数才是待切的森林。继续函数 @k@ 收到前缀（输出 @is@）和后缀（输出 @js@），
-- 并带上类型等式 @ds ~ (bs ++ cs)@。中间要用 'appendAssocAxiom'，因为拼接的结合律不是定义等式。
splitForest :: forall f g ds is js os r. Rec f is -> Forest g js os -> Forest g ds (is ++ js)
            -> (forall bs cs. (ds ~ (bs ++ cs)) => Forest g bs is -> Forest g cs js -> r) -> r
splitForest RNil _ as k = k Nil as
splitForest (_ :& is) bs ((j :: g as o) :- js) k = splitForest is bs js $
  \ (l :: Forest g bs as1) (r :: Forest g cs js) ->
    case appendAssocAxiom (Proxy :: Proxy as) (Proxy :: Proxy bs) (Proxy :: Proxy cs) of
      Dict -> k (j :- l) r

-- | 森林在「源列表」上反变：定义域是 'Op'（'Forest' @f@），@fmap@ 是前复合。
-- 和 'Nat'、@(->)@ 那些「左端反变」的实例是同一种写法。
instance Multicategory f => Functor (Forest f) where
  type Dom (Forest f) = Op (Forest f)
  type Cod (Forest f) = Nat (Forest f) (->)
  fmap (Op f) = Nat (. f)

-- | 固定输入列表后，森林对输出列表协变，@fmap@ 是后复合。
instance (Multicategory f) => Functor (Forest f is) where
  type Dom (Forest f is) = Forest f
  type Cod (Forest f is) = (->)
  fmap = (.)

--------------------------------------------------------------------------------
-- 【中文】从多元范畴忘记到普通范畴：只留下一元箭头。
-- * Forgetting the multicategory structure
--------------------------------------------------------------------------------

-- | @C f a b@ 是一条恰好有一个输入 @a@、输出为 @b@ 的多元箭头。'runC' 把 @'[a]@ 这层列表暴露出来。
data C (f :: [i] -> i -> *) (a :: i) (b :: i) where
  C :: { runC :: f '[a] b } -> C f a b

-- | 一元箭头组成范畴。'id' 用多元范畴的 'ident'；
-- 复合时把右边那条箭头装进只含一个元素的森林，再用 'compose' 插进左边箭头的唯一输入。
-- 'source' 从 'sources' 的单元素记录里取出对象证据。
instance Multicategory f => Category (C f) where
  type Ob (C f) = Mob f
  id = C ident
  C f . C g = C (compose f (g :- Nil))
  source (C f) = case sources f of Dict1 :& RNil -> Dict
  target (C f) = case mtarget f of Dict1 -> Dict

--------------------------------------------------------------------------------
-- 【中文】多元范畴类。复合不单独存储，而是要求 @f@ 是二元函子：
-- 输入森林那一侧反变（'Dom' 是森林的对偶），输出那一侧是普通范畴 'C' @f@。
-- * Multicategories
--------------------------------------------------------------------------------


-- | 多元范畴。
--
-- 超类约束规定了箭头如何作用在变元上：
--
-- * 'MDom' 是对象所在的底层范畴，'Mob' 是它的对象约束。
-- * @f@ 是 'Bifunctor'，'Dom' 必须是 @Op (Forest f)@（一片输入森林），
--   'Dom2' 必须是 @C f@（一个输出箭头），'Cod2' 是 @(->)@。
--
-- 方法：
--
-- * 'ident'：单个对象上的恒等多元箭头，只有一个输入。
-- * 'sources'：这条箭头每个输入都是对象，证据排成 'Rec'。
-- * 'mtarget'：输出是对象。名字加 @m@ 是为了避开 'Category' 的 'target'。
--
-- 多元复合见 'compose'：它用 'lmap' 把森林代进反变的输入槽，所以实例要能提供相应的 'Functor'。
-- 恒等与结合法则即 operad / multicategory 的通常法则，这里不由类型系统检查。
class
  ( Category (MDom f)
  , Bifunctor f
  , Dom f ~ Op (Forest f)
  , Dom2 f ~ C f
  , Cod2 f ~ (->)
  ) => Multicategory (f :: [i] -> i -> *) where
  type MDom f :: i -> i -> *
  ident   :: Mob f a => f '[a] a
  sources :: f as b -> Rec (Dict1 (Mob f)) as
  mtarget :: f as b -> Dict1 (Mob f) b

-- | @f@ 的对象约束，即底层范畴 'MDom' 的 @Ob@。
type Mob f = Ob (MDom f)

-- | 多元复合：把森林 @es@ 的每一条箭头分别插入 @f@ 的对应输入，输出仍是 @c@。
-- 先用 'mtarget' 确认 @c@ 是对象，再 'lmap'。能这么写是因为输入槽的定义域是森林的对偶，
-- 'lmap' 期望的正好是一片 'Forest'（对偶再对偶回到森林本身）。
compose :: Multicategory f => f bs c -> Forest f as bs -> f as c
compose f es = case mtarget f of
  Dict1 -> lmap es f

-- | 森林的复合是「插入」而不是简单拼接。
--
-- * 对象是「列表中每个索引都是 'Mob'」的约束 'All'。
-- * 'id' 是一排 'ident'，长度由 'proofs' 里的对象证据决定。
-- * @bs . as@：左边森林的每条箭头 @b@ 要用 'splitForest' 从 @as@ 里切出 feeding 它的那一段 @es@，
--   然后 'compose' @b es@，再递归复合剩余的森林。
-- * 'source' / 'target' 把 'sources'、'mtarget' 收成的记录用 'reproof' 变回 'All' 字典。
instance Multicategory f => Category (Forest f) where
  type Ob (Forest f) = All (Mob f)

  id = go proofs where
    go :: Rec (Dict1 (Mob f)) is -> Forest f is is
    go (Dict1 :& as) = ident :- go as
    go RNil          = Nil

  Nil . Nil = Nil
  (b :- bs) . as = splitForest (sources b) bs as $ \es fs -> compose b es :- (bs . fs)

  source = reproof . inputs sources
  target = reproof . outputs mtarget

-- | 森林可以并排，因此是 'PRO'。@pro@ 就是把两片森林首尾相接（@(:-)@ 到左边那片的最后）。
-- 输入列表拼接的结合律要用 'appendAssocAxiom' 补上，否则 @l :- pro ls rs@ 的输入类型对不齐。
instance Multicategory f => PRO (Forest f) where
  pro Nil rs = rs
  pro (l :- ls) rs = case appendAssocAxiom (sources l) (go (source ls)) (go (source rs)) of
      Dict -> l :- pro ls rs 
    where
     go :: Dict (All p as) -> Rec (Dict1 p) as
     go Dict = proofs

-- | Indexed multicategory 项：一条多元箭头 @f is o@，再加每个输入位置上的一个值 @Rec a is@。
-- 可以读成「一棵只展开了一层的运算树，叶子上挂着 @a@」。
data IM :: ([k] -> k -> *) -> (k -> *) -> k -> * where
  IM :: f is o -> Rec a is -> IM f a o

-- 英文注记保留在下一行：这是 @(:~:)@ 的一个子范畴，对象还要满足约束 @p@。
-- A subcategory of (:~:) satisfying a constraint `p`

-- | 只有单位箭头的范畴，而且两端必须是同一个索引，并且满足约束 @p@。
-- 构造子 'Dat' 把 @p i@ 收进字典。它比 'Vacuous' 的离散范畴更窄。
data Dat p i j where
  Dat :: p i => Dat p i i

-- | 把 'Dat' 看成一条命题相等 'Refl'。约束 @p@ 被丢掉，只留下两端相同。
dum :: Dat p i j -> i :~: j
dum Dat = Refl

-- | 'Dat' 的复合只能是单位接单位。对象约束就是 @p@ 本身，所以 'source' / 'target' 直接给 'Dict'。
instance Category (Dat p) where
  type Ob (Dat p) = p
  id = Dat
  Dat . Dat = Dat
  source Dat{} = Dict
  target Dat{} = Dict

-- | 草稿：'Dat' 应当在左端反变，成为自然变换范畴上的函子。这里没有给出 'fmap'，实例是空的。
instance Functor (Dat p) where
  type Dom (Dat p) = Op (Dat p)
  type Cod (Dat p) = Nat (Dat p) (->)

-- | 草稿：固定一端后 'Dat' 沿自身的箭头应当给出函数。同样没有方法体。
instance Functor (Dat p a) where
  type Dom (Dat p a) = Dat p
  type Cod (Dat p a) = (->)

--instance Functor IM where
--  type Dom IM = Nat (:~:) (Nat (:~:) (->))
--  type Cod IM = Nat (Nat (:~:) (->)) (Nat (:~:) (->))

-- | @IM f@ 沿「对象上的函数」（'Nat' 的定义域是 'Dat'，不是全部 @(:~:)@）映射叶子。
--
-- 'fmap' 里的 'go' 目前是 'Prelude.undefined'：记录 'Rec' 的函子实例只接受 @(:~:)@ 的自然变换，
-- 而这里手里只有 'Dat'（还要求 'Mob'）的自然变换，缺一个受限版本的 'Rec'。见源码中的 TODO。
-- 因此这个 'fmap' 不能真的运行。
instance Multicategory f => Functor (IM f) where
  type Dom (IM f) = Nat (Dat (Mob f)) (->)
  type Cod (IM f) = Nat (Dat (Mob f)) (->)
  fmap f = Nat $ \(IM s d) -> IM s (runNat (fmap (go f)) d) where
    go :: Nat (Dat (Mob f)) (->) i j -> Nat (:~:) (->) i j
    go = Prelude.undefined -- TODO
    -- what we really need is a restricted 'Rec' which can only be mapped with a Dat (Mob f) rather than (:~:)

-- | 固定叶子的类型构造子后，'Dat' 上只有单位箭头，'fmap' 不改 @IM@ 的值。
instance Multicategory f => Functor (IM f a) where
  type Dom (IM f a) = Dat (Mob f)
  type Cod (IM f a) = (->)
  fmap Dat a = a

-- | 把一层运算看成单子的 @return@：恒等多元箭头配上单元素记录。
-- 类的 MINIMAL 还要求 'join' 或 'bind'，这里都没有写，所以实例不完整，只表达了「叶子变一元运算」这一步。
instance Multicategory f => Monad (IM f) where
  return = Nat $ \a -> IM ident (a :& RNil)
