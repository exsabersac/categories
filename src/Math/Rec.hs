{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE Trustworthy #-}

-- GHC warns about splitRec, but a "fix" yield unreachable code and won't compile.
{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}

-- |
-- Module      : Math.Rec
--
-- 类型级列表上的异构记录，给多元范畴当「一列对象 / 一列值」用。
-- @Rec f '[a, b, c]@ 里依次放着 @f a@、@f b@、@f c@，长度和元素种类都在类型里。
-- 列表拼接 @(++)@ 的右单位和结合律 GHC 推不出来，所以另有两个用 'Unsafe.Coerce.unsafeCoerce' 做的公理。
module Math.Rec
  ( Rec(..)
  , appendRec
  , mapRec
  , splitRec
  , takeRec
  , dropRec
  , foldrRec
  , traverseRec
  -- * Type Lists
  , type (++)
  , appendNilAxiom
  , appendAssocAxiom
  -- * Dict1
  , Dict1(..)
  -- * All
  , All(..)
  , reproof
  ) where

import Control.Applicative
import Data.Constraint
import Data.Type.Equality
import Math.Functor
import Prelude (($), fst, snd)
import Unsafe.Coerce

-- | 类型级列表拼接。@'[] ++ bs = bs@，@(a ': as) ++ bs = a ': (as ++ bs)@。
-- 和值层面的 @(++)@ 同方向：左边的列表在前。
type family (++) (a :: [k]) (b :: [k]) :: [k]
type instance '[] ++ bs = bs
type instance (a ': as) ++ bs = a ': (as ++ bs)

-- | Proof provided by every single class on theorem proving in the last 20 years.
-- 中文：右单位 @as ~ (as ++ '[])@。对具体列表可以归纳得到，但类型族不会自动在变量 @as@ 上做归纳，
-- 因此把已有的 @Dict (as ~ as)@ 强制转成目标等式。只在你确信 @(++)@ 的这个性质时使用。
appendNilAxiom :: forall as. Dict (as ~ (as ++ '[]))
appendNilAxiom = unsafeCoerce (Dict :: Dict (as ~ as))

-- | Proof provided by every single class on theorem proving in the last 20 years.
-- 中文：结合律 @(as ++ (bs ++ cs)) ~ ((as ++ bs) ++ cs)@。三个参数只用来把三段列表的类型传进来，值本身被丢掉。
-- 同样是 'Unsafe.Coerce.unsafeCoerce'，不是在运行时计算证明。
appendAssocAxiom :: forall p q r as bs cs. p as -> q bs -> r cs -> Dict ((as ++ (bs ++ cs)) ~ ((as ++ bs) ++ cs))
appendAssocAxiom _ _ _ = unsafeCoerce (Dict :: Dict (as ~ as))

-- | 一列 @f@。'RNil' 是空列；@x :& xs@ 在类型上把头部索引接到列表前面。
-- 两个字段都是严格的（@!@）。
data Rec f as where
  RNil :: Rec f '[]
  (:&) :: !(f i) -> !(Rec f is) -> Rec f (i ': is)

-- | 沿命题相等映射记录：定义域只有 'Refl'，所以记录原样返回。
-- 这使得 @Rec f@ 可以出现在要求 'Functor' 的地方（例如某些自然变换的分量）。
instance Functor (Rec f) where
  type Dom (Rec f) = (:~:)
  type Cod (Rec f) = (->)
  fmap Refl as = as

-- | @Rec@ 本身是函子：一个「对每种索引都适用」的自然变换可以 'mapRec' 进记录的每一项。
instance Functor Rec where
  type Dom Rec = Nat (:~:) (->)
  type Cod Rec = Nat (:~:) (->)
  fmap f = Nat $ mapRec (runNat f)

-- | Append two records
-- | 按类型级拼接把两段记录接成一段。左边空则结果就是右边。
appendRec :: Rec f as -> Rec f bs -> Rec f (as ++ bs)
appendRec RNil bs      = bs
appendRec (a :& as) bs = a :& appendRec as bs

-- | Map over a record
-- | 逐项映射。函数必须对所有索引都适用（@forall a. f a -> g a@），因为各项的索引不一定相同。
mapRec :: (forall a. f a -> g a) -> Rec f as -> Rec g as
mapRec _ RNil = RNil
mapRec f (a :& as) = f a :& mapRec f as

-- | Split a record
-- | 按左边那条记录的长度，把一条更长的记录切成前缀和后缀。
-- 前缀的索引列表与 @is@ 相同，后缀的索引列表是剩下的 @js@。
-- 文件头关掉了不完全模式警告：按 @(++)@ 的定义，左边非空时右边不应当是 'RNil'，那个分支写出来也到不了。
splitRec :: Rec f is -> Rec g (is ++ js) -> (Rec g is, Rec g js)
splitRec (_ :& is) (a :& as) = case splitRec is as of
  (l,r) -> (a :& l, r)
splitRec RNil    as    = (RNil, as)
-- splitRec (_ :& _) RNil = error "splitRec: the impossible happened"

-- | 只取 'splitRec' 的前半。多出来的两个 @Rec@ 参数用来把 @is@、@js@ 固定在类型里。
takeRec :: forall f g h is js. Rec f is -> Rec g js -> Rec h (is ++ js) -> Rec h is
takeRec is _ ijs = fst $ (splitRec is ijs :: (Rec h is, Rec h js))

-- | 只取 'splitRec' 的后半，丢掉长度为 @is@ 的前缀。
dropRec :: Rec f is -> Rec g (is ++ js) -> Rec g js
dropRec is ijs = snd $ splitRec is ijs

-- | 从右边折叠。合并函数要说明结果的索引列表如何变长：
-- 吃进 @f j@ 和「索引为 @js@ 的结果」后，得到索引为 @(j ': js)@ 的结果。
foldrRec :: (forall j js. f j -> r js -> r (j ': js)) -> r '[] -> Rec f is -> r is
foldrRec _ z RNil = z
foldrRec f z (a :& as) = f a (foldrRec f z as)

-- | 逐项做 'Applicative' 效果，再按原顺序装回记录。空记录得到 @pure 'RNil'@。
traverseRec :: Applicative m => (forall i. f i -> m (g i)) -> Rec f is -> m (Rec g is)
traverseRec f (a :& as) = (:&) <$> f a <*> traverseRec f as
traverseRec _ RNil = pure RNil

-- | @p a@ 成立的一个运行时证据，是 'Dict' 的「带一个类型参数」版本。
-- 多元范畴用 @Rec (Dict1 (Mob f))@ 表示「这一列索引全是对象」。
data Dict1 p a where
  Dict1 :: p a => Dict1 p a

-- | 列表里每一个索引都满足约束 @p@。'proofs' 把这些证据收成一条 'Rec'。
-- 空列表总是满足；非空则要头部 @p i@ 加上尾部的 'All'。
class All (p :: i -> Constraint) (is :: [i]) where
  proofs :: Rec (Dict1 p) is

instance All p '[] where
  proofs = RNil

instance (p i, All p is) => All p (i ': is) where
  proofs = Dict1 :& proofs

-- | 反方向：手里已经有一整条 @Dict1@ 记录时，重新装成一个 'All' 约束字典。
-- 归纳走完尾部后，'Dict' 把「头部约束 + 尾部 'All'」收成实例上下文。
reproof :: Rec (Dict1 p) is -> Dict (All p is)
reproof RNil = Dict
reproof (Dict1 :& as) = case reproof as of
  Dict -> Dict
