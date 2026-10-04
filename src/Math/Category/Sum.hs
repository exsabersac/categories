{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}

-- really, GHC, really?
{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}

-- |
-- Module      : Math.Category.Sum
--
-- 两个范畴的不交并，也就是范畴的余积 (coproduct / sum)。
-- 对象是 'Either'：左边来自 @p@，右边来自 @q@。箭头不能从左边通到右边。
module Math.Category.Sum
  ( (+)(..)
  , sumOb
  ) where

import Prelude (Either(..))
import Data.Constraint
import Data.Proxy
import Math.Category
import Math.Groupoid

-- | 并范畴的对象约束。不能对类型变量做模式匹配，所以用一个继续传递的方法 'sumOb'：
-- 若对象是 @Left a@ 就走第一个分支（此时已知 @Ob p a@），是 @Right b@ 就走第二个。
-- 两个 @proxy@ 只是把 @p@、@q@、@o@ 传进类型检查，运行时没有值。
class SumOb (p :: i -> i -> *) (q :: j -> j -> *) (o :: Either i j) where
  sumOb :: proxy1 p -> proxy2 q -> proxy3 o ->
    (forall a. Ob p a => (o ~ Left a) => r) -> (forall b. Ob q b => (o ~ Right b) => r) -> r

instance Ob p a => SumOb p q (Left a) where
  sumOb _ _ _ l _ = l

instance Ob q b => SumOb p q (Right b) where
  sumOb _ _ _ _ r = r

-- | 并范畴的箭头，只有两种：'L' 包住 @p@ 的箭头，'R' 包住 @q@ 的箭头。
-- 源和靶必须在同一侧，因此不存在 @Left@ 到 @Right@ 的箭头。
data (+) :: (i -> i -> *) -> (j -> j -> *) -> Either i j -> Either i j -> * where
  L :: p a b -> (p + q) (Left a) (Left b)
  R :: q a b -> (p + q) (Right a) (Right b)

-- | 复合只定义了 @L@ 配 @L@、@R@ 配 @R@。交叉情形在类型上不可能出现，
-- 所以文件头关掉了「模式没写全」的警告，而不是去写一个会报错的分支。
-- 'id' 必须先用 'sumOb' 分辨对象在哪一侧，再放进对应的 'L id' 或 'R id'。
instance (Category p, Category q) => Category (p + q) where
  type Ob (p + q) = SumOb p q
  id = it where
    it :: forall o. SumOb p q o => (p + q) o o
    it = sumOb (Proxy :: Proxy p) (Proxy :: Proxy q) (Proxy :: Proxy o) (L id) (R id)

  L f . L g = L (f . g)
  R f . R g = R (f . g)

  source (L p) = case source p of Dict -> Dict
  source (R q) = case source q of Dict -> Dict

  target (L p) = case target p of Dict -> Dict
  target (R q) = case target q of Dict -> Dict

-- | 两边都是群胚时，逆箭头留在原来的那一侧。
instance (Groupoid p, Groupoid q) => Groupoid (p + q) where
  inv (L f) = L (inv f)
  inv (R g) = R (inv g)
