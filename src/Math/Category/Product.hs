{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}

-- |
-- Module      : Math.Category.Product
--
-- 两个范畴的积 (product category)。对象是双方对象组成的类型级二元组，
-- 箭头是双方各一条箭头，复合和单位都逐分量进行。
module Math.Category.Product
  ( (*)(..)
  ) where

import Data.Constraint
import Math.Category
import Math.Groupoid

-- | 从类型级二元组里取出第一、第二分量。只对真正写成 @'(x, y)@ 的类型有方程，
-- 所以后面 'ProductOb' 要求 @r ~ '(Fst r, Snd r)@，避免碰到还没化简开的类型变量。
type family Fst (r :: (a,b)) :: a where Fst '(x,y) = x
type family Snd (r :: (a,b)) :: b where Snd '(x,y) = y

-- | 积范畴的对象约束：@r@ 必须是一对 @(a, c)@，并且 @a@ 是 @p@ 的对象、@c@ 是 @q@ 的对象。
class    (r ~ '(Fst r, Snd r), Ob p (Fst r), Ob q (Snd r)) => ProductOb p q r
instance (r ~ '(Fst r, Snd r), Ob p (Fst r), Ob q (Snd r)) => ProductOb p q r

-- | 积范畴的箭头。@Pair f g@ 的源是 @'(a, c)@、靶是 @'(b, d)@，
-- 其中 @f :: p a b@，@g :: q c d@。没有「只动一边」的箭头；要不动另一边就放上那边的 'id'。
data (*) :: (i -> i -> *) -> (j -> j -> *) -> (i,j) -> (i,j) -> * where
  Pair :: p a b -> q c d -> (p * q) '(a,c) '(b,d)

-- | 积还是范畴：'id' 是一对 'id'；复合各自复合。
-- 'source' / 'target' 把两边的 @Dict@ 拼起来。因为对象约束不是 'Vacuous'，必须手写这两个方法。
instance (Category p, Category q) => Category (p * q) where
  type Ob (p * q) = ProductOb p q
  id = Pair id id
  Pair f g . Pair h i = Pair (f . h) (g . i)
  source (Pair f g) = case source f of
    Dict -> case source g of
      Dict -> Dict
  target (Pair f g) = case target f of
    Dict -> case target g of
      Dict -> Dict

-- | 两边都是群胚时，积也是群胚：逆箭头逐分量取 'inv'。
instance (Groupoid p, Groupoid q) => Groupoid (p * q) where
  inv (Pair p q) = Pair (inv p) (inv q)
