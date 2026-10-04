{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE DefaultSignatures #-}

-- |
-- Module      : Math.Functor
--
-- 函子 (functor)、自然变换 (natural transformation)，以及用「函子范畴里的函子」编码的二元函子。
-- 读的顺序建议：'Functor' → 'ob' → 'Nat' → 'Bifunctor' → 'dimap'。
module Math.Functor 
  ( Functor(..)
  , FunctorOf
  , ob
  , Nat(..)
  , Bifunctor, Dom2, Cod2
  , bimap, first, second
  , dimap, lmap, rmap
  , contramap
  ) where

import Data.Constraint as Constraint
import Data.Type.Equality as Equality
import Data.Type.Coercion as Coercion
import Math.Category
import qualified Prelude
import Prelude (($), Either(..), Maybe(..))

--------------------------------------------------------------------------------
-- 【中文】函子：把定义域范畴 'Dom' 的箭头送进余定义域 'Cod'。
-- 法则（不检查）：@fmap id = id@，@fmap (f . g) = fmap f . fmap g@。
-- * Functors
--------------------------------------------------------------------------------

-- | 函子 @f :: i -> j@。它自己不是箭头，而是把对象（kind @i@）变成对象（kind @j@）。
--
-- * 'Dom'：定义域范畴的箭头种类，类型是 @i -> i -> *@。
-- * 'Cod'：余定义域范畴的箭头种类。
-- * 'fmap'：箭头的像。@Dom f a b@ 变成 @Cod f (f a) (f b)@。
--
-- 与 "Prelude".'Prelude.Functor' 不同：这里的定义域、余定义域可以不是 @(->)@。
-- 下面不少实例把 @fmap@ 定义成 @(.)@，是因为「在一端固定以后，hom 本身就是函子」。
class (Category (Cod f), Category (Dom f)) => Functor (f :: i -> j) where
  type Dom f :: i -> i -> *
  type Cod f :: j -> j -> *
  fmap :: Dom f a b -> Cod f (f a) (f b)

-- | 若定义域箭头是对偶范畴里的箭头，用 'unop' 翻回原范畴再 'fmap'。
-- 直观上：定义域反变时，用原范畴的箭头 @b -> a@ 得到 @f a -> f b@。
contramap :: Functor f => Op (Dom f) b a -> Cod f (f a) (f b)
contramap = fmap . unop

-- | 固定左端的函数箭头 @(->) e@，也就是 hom 函子 @Hask(e, -)@。@fmap@ 是后复合。
instance Functor ((->) e) where
  type Dom ((->) e) = (->)
  type Cod ((->) e) = (->)
  fmap = (.)

-- | 固定左端的约束蕴含。定义域是 @(:-)@，余定义域是普通函数：
-- 一条蕴含可以用来把「需要更强前提的字典运算」改写成函数复合。
instance Functor ((:-) e) where
  type Dom ((:-) e) = (:-)
  type Cod ((:-) e) = (->)
  fmap = (.)

-- | @Dict@ 把约束蕴含实现成函数。@fmap p Dict@ 在 @p :: c :- d@ 时，
-- 从「@c@ 成立」的证据做出「@d@ 成立」的证据（剥开 'Sub'）。
instance Functor Dict where
  type Dom Dict = (:-)
  type Cod Dict = (->)
  fmap p Dict = case p of
    Sub q -> q

-- | 固定左端的命题相等 @((:~:) e)@ 是到 @Hask@ 的函子，@fmap@ 仍是复合。
instance Functor ((:~:) e) where
  type Dom ((:~:) e) = (:~:)
  type Cod ((:~:) e) = (->)
  fmap = (.)

-- | 固定左端的 'Coercion'，同样后复合。
instance Functor (Coercion e) where
  type Dom (Coercion e) = Coercion
  type Cod (Coercion e) = (->)
  fmap = (.)

-- | 积的右投影函子。@fmap f (a, b) = (a, f b)@，左边的 @e@ 原样保留。模式用了惰性 @~@，和 base 里元组的 'Prelude.Functor' 一样。
instance Functor ((,) e) where
  type Dom ((,) e) = (->)
  type Cod ((,) e) = (->)
  fmap f ~(a,b) = (a, f b)

-- | 'Either' 的右偏函子：'Left' 不动，'Right' 里套用函数。
instance Functor (Either a) where
  type Dom (Either a) = (->)
  type Cod (Either a) = (->)
  fmap _ (Left a) = Left a
  fmap f (Right b) = Right (f b)

-- | 列表函子，直接沿用 "Prelude" 的 @fmap@。
instance Functor [] where
  type Dom [] = (->)
  type Cod [] = (->)
  fmap = Prelude.fmap

-- | 'Maybe' 函子，同样沿用 "Prelude"。
instance Functor Maybe where
  type Dom Maybe = (->)
  type Cod Maybe = (->)
  fmap = Prelude.fmap

-- | 固定对象后的米田嵌入 @Yoneda p a@ 是从对偶范畴到 @Hask@ 的函子（反变 hom）。
-- @fmap@ 取复合，和「预复合」那一侧的自然性一致。
instance (Category p, Op p ~ Yoneda p) => Functor (Yoneda p a) where
  type Dom (Yoneda p a) = Yoneda p
  type Cod (Yoneda p a) = (->)
  fmap = (.)


-- | 把「@f@ 是从范畴 @c@ 到范畴 @d@ 的函子」收成一个约束。
-- 没有方法。'Nat' 的构造子会携带它，这样自然变换的两端都被钉在同一对范畴上。
class (Dom f ~ c, Cod f ~ d, Functor f) => FunctorOf (c :: i -> i -> *) (d :: j -> j -> *) (f :: i -> j)
instance (Dom f ~ c, Cod f ~ d, Functor f) => FunctorOf c d f 

-- | 函子把对象送到对象：由 @Ob (Dom f) a@ 推出 @Ob (Cod f) (f a)@。
--
-- 做法：在定义域里取 'id'，'fmap' 之后得到 @f a@ 上的一条箭头，再调用 'source'。
-- 结果是 @constraints@ 包里的蕴含 @(:-)@，后面可以用 @(\\)@ 把这个证据喂给需要对象约束的方法。
ob :: forall f a. Functor f => Ob (Dom f) a :- Ob (Cod f) (f a)
ob = Sub $ case source (fmap (id :: Dom f a a) :: Cod f (f a) (f a)) of
  Dict -> Dict

--------------------------------------------------------------------------------
-- 【中文】自然变换。垂直复合使 @Nat c d@ 自己成为一个范畴，对象是从 @c@ 到 @d@ 的函子。
-- * Natural Transformations
--------------------------------------------------------------------------------

-- | 自然变换 @f => g@。构造子里已经要求两端都是 @c@ 到 @d@ 的函子 ('FunctorOf')。
--
-- 'runNat' 是分量：对 @c@ 的每个对象 @a@，给一条 @d (f a) (g a)@。
-- 自然性方块没有写成单独的方法，要由实例的作者保证：
-- @fmap g . runNat n = runNat n . fmap f@（按两端范畴的复合来写）。
data Nat (c :: i -> i -> *) (d :: j -> j -> *) (f :: i -> j) (g :: i -> j) where
  Nat :: (FunctorOf c d f, FunctorOf c d g) => { runNat :: forall a. Ob c a => d (f a) (g a) }  -> Nat c d f g

-- | 自然变换的垂直复合，对象约束是 'FunctorOf'（两端必须是这对范畴之间的函子）。
--
-- 'id' 的分量是函子里的 'id'。写 @id@ 之前要知道 @f x@ 在余定义域里是对象，
-- 所以用 'ob' 推出这个约束，再用 @(\\)@ 消掉它。
-- 复合 @Nat f . Nat g = Nat (f . g)@ 是分量各自复合。
instance (Category c, Category d) => Category (Nat c d) where
  type Ob (Nat c d) = FunctorOf c d
  id = Nat id1 where
    id1 :: forall f x. (Functor f, Dom f ~ c, Cod f ~ d, Ob c x) => d (f x) (f x)
    id1 = id \\ (ob :: Ob c x :- Ob d (f x))
  Nat f . Nat g = Nat (f . g)
  source Nat{} = Dict
  target Nat{} = Dict

-- | 把自然变换范畴看成函子：定义域是它自己的对偶，所以在「源函子」那个变元上是反变的。
--
-- @fmap (Op n) = Nat (. n)@：一条从 @β@ 到 @α@ 的自然变换 @n@，诱导
-- 「从 @α@ 出发的自然变换」到「从 @β@ 出发的自然变换」，做法是先接上 @n@（前复合）。
-- 余定义域 @Nat (Nat c d) (->)@ 就是以自然变换为对象、以 Haskell 函数为箭头的函子范畴。
instance (Category c, Category d) => Functor (Nat c d) where
  type Dom (Nat c d) = Op (Nat c d)
  type Cod (Nat c d) = Nat (Nat c d) (->)
  fmap (Op f) = Nat (. f)
  
-- | 固定源函子后的 hom 函子 @Nat c d (f, -)@，在靶函子上协变。@fmap@ 是后复合。
instance (Category c, Category d) => Functor (Nat c d f) where
  type Dom (Nat c d f) = Nat c d
  type Cod (Nat c d f) = (->)
  fmap = (.)

-- | 'FunctorOf' 可以看成从 @Nat c d@ 到约束蕴含范畴的函子。
-- 自然变换的构造子已经同时携带两端的 'FunctorOf'，所以 @fmap@ 不必看分量，直接给 @Sub Dict@。
instance (Category c, Category d) => Functor (FunctorOf c d) where
  type Dom (FunctorOf c d) = Nat c d
  type Cod (FunctorOf c d) = (:-)
  fmap Nat{} = Sub Dict

-- | 函数箭头 @(->)@ 作为二元运算的「左变元反变」那一半：定义域是对偶范畴。
-- @fmap (Op f) = Nat (. f)@ 就是前复合，分量 @(. f) :: (a -> c) -> (b -> c)@（当 @f :: b -> a@）。
instance Functor (->) where
  type Dom (->) = Op (->)
  type Cod (->) = Nat (->) (->)
  fmap (Op f) = Nat (. f)

-- | 约束蕴含同样在左端反变，前复合得到一个以函数为分量的自然变换。
instance Functor (:-) where
  type Dom (:-) = Op (:-)
  type Cod (:-) = Nat (:-) (->)
  fmap (Op f) = Nat (. f)

-- | 命题相等在左端反变。分量仍是前复合。
instance Functor (:~:) where
  type Dom (:~:) = Op (:~:)
  type Cod (:~:) = Nat (:~:) (->)
  fmap (Op f) = Nat (. f)

-- | 'Coercion' 在左端反变，形式与 @(->)@ 相同。
instance Functor Coercion where
  type Dom Coercion = Op Coercion
  type Cod Coercion = Nat Coercion (->)
  fmap (Op f) = Nat (. f)

-- | 'Yoneda' @p@ 是从 @p@ 到 @Nat (Yoneda p) (->)@ 的函子，也就是米田嵌入本身：
-- 原范畴的箭头 @f@ 变成对偶 hom 之间的自然变换 @Nat (. Op f)@。
instance (Category p, Op p ~ Yoneda p) => Functor (Yoneda p) where
  type Dom (Yoneda p) = p
  type Cod (Yoneda p) = Nat (Yoneda p) (->)
  fmap f = Nat (. Op f)

-- | 元组构造子 @(,)@ 的左变元函子。'Nat' 的分量只改元组的左边：@(a, b)@ 变成 @(f a, b)@。
-- 和上面 @Functor ((,) e)@（只改右边）合在一起，才是积的二元函子。
instance Functor (,) where
  type Dom (,) = (->)
  type Cod (,) = Nat (->) (->)
  fmap f = Nat $ \(a,b) -> (f a, b)

-- | 'Either' 的左变元函子：'Left' 里套用函数，'Right' 保持不动。
instance Functor Either where
  type Dom Either = (->)
  type Cod Either = Nat (->) (->)
  fmap f0 = Nat (go f0) where
    go :: (a -> b) -> Either a c -> Either b c
    go f (Left a)  = Left (f a)
    go _ (Right b) = Right b

--------------------------------------------------------------------------------
-- 【中文】二元函子 (bifunctor) 不单独给 @bimap@ 当类方法，而是规定：
-- @p@ 是函子，并且 @Cod p@ 是一个自然变换范畴。于是 @p a@ 是「第二个变元」上的函子，
-- @fmap@ 在第一个变元上给出这个函子之间的自然变换。
-- * Bifunctors
--------------------------------------------------------------------------------

-- | 从一个 @Nat p q@ 形状的箭头种类里把两端范畴 @p@、@q@ 取出来。
-- 只为了写出下面的 'Dom2' / 'Cod2'。
type family NatDom (f :: (i -> j) -> (i -> j) -> *) :: (i -> i -> *) where NatDom (Nat p q) = p
type family NatCod (f :: (i -> j) -> (i -> j) -> *) :: (j -> j -> *) where NatCod (Nat p q) = q

-- | 二元函子第二个变元的定义域、余定义域。
-- 因为 @Cod p@ 应是 @Nat (Dom2 p) (Cod2 p)@，这里用类型族把 @Nat@ 的参数投影出来。
type Dom2 p = NatDom (Cod p)
type Cod2 p = NatCod (Cod p)

-- | @p :: i -> j -> k@ 是二元函子：作为「第一个变元」的函子，余定义域必须是
-- 从 'Dom2' 到 'Cod2' 的自然变换范畴。类本身没有方法，结构都在这个约束里。
class (Functor p, Cod p ~ Nat (Dom2 p) (Cod2 p), Category (Dom2 p), Category (Cod2 p)) => Bifunctor (p :: i -> j -> k)
instance (Functor p, Cod p ~ Nat (Dom2 p) (Cod2 p), Category (Dom2 p), Category (Cod2 p)) => Bifunctor (p :: i -> j -> k)

-- | 只改二元函子的第一个变元。@fmap@ 得到一条自然变换，'runNat' 在第二个对象 @c@ 处取分量。
-- 因此调用时要有 @Ob d c@：自然变换的分量只保证在对象上存在。
first :: (Functor f, Cod f ~ Nat d e, Ob d c) => Dom f a b -> e (f a c) (f b c)
first = runNat . fmap

-- | 只改第二个变元。先用 'ob' 知道 @p c@ 是函子（@c@ 必须是 'Dom' 的对象），
-- 再对这个偏应用做 'fmap'。
second :: forall p a b c. (Bifunctor p, Ob (Dom p) c) => Dom2 p a b -> Cod2 p (p c a) (p c b)
second f = case ob :: Ob (Dom p) c :- FunctorOf (Dom2 p) (Cod2 p) (p c) of
  Sub Dict -> fmap f

-- | 两个变元一起改：先 'second' @g@，再接上 'first' 对应的那条自然变换。
-- 'source' / 'target' 用来确认中间对象上约束够用。等式上就是 @bimap f g = first f . second g@。
bimap :: Bifunctor p => Dom p a b -> Dom2 p c d -> Cod2 p (p a c) (p b d)
bimap f g = case source f of
  Dict -> case target g of
    Dict -> runNat (fmap f) . second g

--------------------------------------------------------------------------------
-- 【中文】profunctor 的用法：第一个变元反变、第二个变元协变。
-- 这里不另立类，只要二元函子的第一个定义域是某个范畴的对偶，就可以用 'dimap'。
-- * Profunctors
--------------------------------------------------------------------------------

-- | @dimap f g@ 在左端用对偶里的箭头（经 'unop' 翻成反变），右端用普通箭头。
-- 特化到 @Hask@ 时就是熟悉的 @dimap :: (a' -> a) -> (b -> b') -> p a b -> p a' b'@。
dimap :: Bifunctor p => Op (Dom p) b a -> Dom2 p c d -> Cod2 p (p a c) (p b d)
dimap = bimap . unop

-- | 只改反变的那一端，是 'first' 配上 'unop'。
lmap :: (Functor f, Cod f ~ Nat d e, Ob d c) => Op (Dom f) b a -> e (f a c) (f b c)
lmap = runNat . fmap . unop

-- | 只改协变的那一端。定义就是 'second'，单独起名是为了和 'lmap' 成对阅读。
rmap :: forall p a b c. (Bifunctor p, Ob (Dom p) c) => Dom2 p a b -> Cod2 p (p c a) (p c b)
rmap = second
