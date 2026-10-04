{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DefaultSignatures #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

-- |
-- Module      : Math.Category
--
-- 范畴 (category)。一条箭头的类型是 @p a b@，其中 @p :: i -> i -> *@，
-- 两端 @a@、@b@ 的 kind 是 @i@，不一定是普通的 @*@（也可以是约束、类型相等的证明等）。
--
-- 法则（约定，编译器不检查）：
--
-- * 左、右单位：@id . f = f@ 且 @f . id = f@
-- * 结合：@(f . g) . h = f . (g . h)@
--
-- 参数顺序和 "Prelude" 一致：@f . g@ 表示先做 @g@ 再做 @f@。
-- @source@ / @target@ 把「端点是对象」收成 @Dict@；@op@ / @unop@ 进出对偶范畴，载体是 'Yoneda'。
module Math.Category 
  ( Category(..)
  , Yoneda(..)
  , Op
  , Vacuous
  ) where

import Data.Constraint    as Constraint
import Data.Type.Equality as Equality
import Data.Type.Coercion as Coercion
import qualified Prelude

-- | The <http://ncatlab.org/nlab/show/Yoneda+embedding Yoneda embedding>.
--
-- Yoneda_C :: C -> [ C^op, Set ]
--
-- 【中文】这个 newtype 同时干两件事：
--
-- * 作为米田嵌入的值：对象 @a@ 被看成反变 hom 函子，@Yoneda p a b@ 里存放的是 @p b a@（箭头反向）。
-- * 作为对偶范畴 @Op p@ 的箭头类型。构造子叫 'Op'，取出里面那条反向箭头用 'getOp'。
newtype Yoneda (p :: i -> i -> *) (a :: i) (b :: i) = Op { getOp :: p b a }

-- | 对偶范畴的箭头种类，并且取两次回到自身。
--
-- * 若 @p@ 已经是 @Yoneda q@，则 @Op p = q@（剥掉一层）；
-- * 否则 @Op p = Yoneda p@（包上一层）。
--
-- 因此「对偶的对偶」和原来的箭头类型相同。值层面的翻转交给类方法 'op' 与 'unop'。
type family Op (p :: i -> i -> *) :: i -> i -> * where
  Op (Yoneda p) = p
  Op p = Yoneda p

-- | 什么都不要求的对象约束。任何 @a@ 都有实例。
--
-- 'Category' 把 @Ob p@ 默认成 @Vacuous@：kind 上的每一个索引都算对象时，不必改写 @Ob@，
-- 'source' 和 'target' 也走默认实现，直接返回 @Dict@。
class Vacuous (a :: i)
instance Vacuous a

-- | 一个范畴，箭头种类为 @p@。
--
-- * @Ob p@：哪些索引算对象，结果是 'Constraint'。默认 'Vacuous'。
-- * 'id'：对象上的单位箭头。写出来之前要有 @Ob p a@。
-- * @('.')@：复合。@p b c@ 接在 @p a b@ 后面，得到 @p a c@。
-- * 'source' / 'target'：由箭头得到端点是对象的证据 @Dict (Ob p …)@。
--   对象约束不是 'Vacuous' 时必须自己写，因为类型检查器不会从箭头里自动变出约束。
-- * 'op' / 'unop'：@p@ 与 'Op' @p@ 之间的换向。默认情形 @Op p ~ Yoneda p@，
--   就是套上或剥掉 'Op' 构造子。已经在对偶里时（见 @Yoneda@ 的实例）要互换这两个方法。
class Category (p :: i -> i -> *) where
  type Ob p :: i -> Constraint
  type Ob p = Vacuous

  id :: Ob p a => p a a
  (.) :: p b c -> p a b -> p a c

  source :: p a b -> Dict (Ob p a)
  default source :: (Ob p ~ Vacuous) => p a b -> Dict (Ob p a)
  source _ = Dict

  target :: p a b -> Dict (Ob p b)
  default target :: (Ob p ~ Vacuous) => p a b -> Dict (Ob p b)
  target _ = Dict

  unop :: Op p b a -> p a b
  default unop :: Op p ~ Yoneda p => Op p b a -> p a b
  unop = getOp

  op :: p b a -> Op p a b
  default op :: Op p ~ Yoneda p => p b a -> Op p a b
  op = Op

-- | 普通函数范畴 @Hask@。对象是一切类型（默认 'Vacuous'），复合就是函数复合。
instance Category (->) where
  id = Prelude.id
  (.) = (Prelude..)

-- | 约束蕴含构成的范畴。@a :- b@ 表示「约束 @a@ 能推出约束 @b@」。
-- 'id' 是自反 @refl@，复合是传递 @trans@（见 @constraints@ 包）。
instance Category (:-) where
  id = Constraint.refl
  (.) = Constraint.trans

-- | 命题相等 @(:~:)@ 的范畴。只有单位箭头 'Refl'（两端必须是同一个类型）。
-- @Equality.trans@ 的参数顺序和 @('.')@ 相反，所以这里用了 'Prelude.flip'。
instance Category (:~:) where
  id = Equality.Refl
  (.) = Prelude.flip Equality.trans

-- | 表象相等 'Coercion' 的范畴（名义类型相同、运行时表示一样，因此可以零成本转换）。
-- 复合同样要把 'Coercion.trans' 翻个方向。
instance Category Coercion where
  id = Coercion
  (.) = Prelude.flip Coercion.trans

-- | @Yoneda p@ 是 @p@ 的对偶范畴：对象集合与 @p@ 相同，箭头全部反向。
--
-- 复合 @Op f . Op g = Op (g . f)@ 先把箭头翻出来，按相反顺序在原范畴里复合，再装回去。
-- 'source' 与 'target' 对调；'unop' / 'op' 也不再使用默认的「套一层 / 剥一层」，
-- 因为 @Op (Yoneda p) = p@，这两边已经是不同类型，方法体写成 'Op' 与 'getOp' 互换。
-- 前提 @Op p ~ Yoneda p@ 表示 @p@ 自己还不是一个 'Yoneda'，避免和类型族方程打架。
instance (Category p, Op p ~ Yoneda p) => Category (Yoneda p) where
  type Ob (Yoneda p) = Ob p
  id = Op id
  Op f . Op g = Op (g . f)
  source (Op f) = target f
  target (Op f) = source f
  unop = Op
  op = getOp
