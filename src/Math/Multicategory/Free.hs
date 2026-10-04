{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}

-- |
-- Module      : Math.Multicategory.Free
--
-- 由一组「分次运算」自由生成的多元范畴。'Free' 的一层要么是恒等，要么是「一个生成元套上一片已经自由生成的森林」。
-- 反复展开就是运算树。对象约束被意图写成不限制任何对象。
module Math.Multicategory.Free
  ( Graded(..)
  , Free(..)
  ) where

import Data.Constraint
import Data.Proxy
import Math.Category
import Math.Multicategory
import Math.Rec
import Prelude (const)

-- | 能看出一条箭头有多少个输入（以及输入的索引）。'grade' 不看输出，只交回与输入列表等长的 'Proxy' 记录。
-- 自由实例用它来制造「每个输入都是对象」的证据：对象约束若是 'Vacuous'，证据里不需要额外信息。
class Graded f where
  grade :: f is o -> Rec Proxy is

-- | 自由多元箭头。
--
-- * 'Ident'：单个输入上的恒等。
-- * 'Apply'：生成元 @f bs c@ 的每个输入位置，再插进一片 @Forest (Free f)@。
--   最外面的输入列表是这片森林的输入列表 @as@，不一定等于 @bs@。
data Free :: ([i] -> i -> *) -> [i] -> i -> * where
  Ident :: Free f '[a] a
  Apply :: f bs c -> Forest (Free f) as bs -> Free f as c

-- | 自由箭头的次数：恒等是单元素列表；'Apply' 把森林里每棵子树的输入用 'inputs' 接起来。
instance Graded f => Graded (Free f) where
  grade Ident        = Proxy :& RNil
  grade (Apply _ as) = inputs grade as

-- | 自由多元范畴的复合。
--
-- * 'ident' 是 'Ident'。
-- * 恒等的复合直接剥掉外层，并用 'appendNilAxiom' 说明「一个输入列表再拼上空列表」还是它自己。
-- * @Apply f as@ 与一片森林复合，是把这片森林接进已经存在的子森林（子森林自己是范畴，用 @('.')@）。
-- * 'sources' 依 'grade' 的形状填 'Dict1'；'mtarget' 直接给 'Dict1'，因为不打算限制对象。
--
-- 源码把关联类型写成了 @type Mob (Free f) = Vacuous@。类里真正要定义的关联类型是 'MDom'，
-- 'Mob' 只是 @Ob (MDom f)@ 的同义词。按字面读，作者的意图是：自由多元范畴的对象约束用 'Vacuous'。
-- 本文件也没有给出 'Functor' / 'Bifunctor' 实例，而 'Multicategory' 的超类要求这些实例存在。
-- 注释只说明这一点，没有改实例头。
instance Graded f => Multicategory (Free f) where
  type Mob (Free f) = Vacuous
  ident = Ident
  compose Ident ((a :: Free f bs c) :- Nil) = case appendNilAxiom :: Dict (bs ~ (bs ++ '[])) of Dict -> a
  compose (Apply f as) bs = Apply f (as . bs)

  sources m = mapRec (const Dict1) (grade m)

  mtarget _ = Dict1
