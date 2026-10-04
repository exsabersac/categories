{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeFamilies #-}

-- |
-- Module      : Math.Functor.Faithful
--
-- 全忠实函子 (fully faithful functor)：'fmap' 在每对对象的 hom 集合之间都有反方向的 'unfmap'。
-- 模块名写 Faithful，类名是 'FullyFaithful'。忠实通常只要求 'fmap' 是单射；
-- 这里直接给出逆，所以比「单射」更强，是全忠实，而且逆是可计算的。
module Math.Functor.Faithful where

import Data.Constraint
import Math.Category
import Math.Functor
import Prelude (($))

-- | @unfmap . fmap = id@ 且 @fmap . unfmap = id@ 是应有的法则，编译器不检查。
-- 能写出 'unfmap' 就说明箭头可以被对象上的像完全还原。
class Functor f => FullyFaithful f where
  unfmap :: Cod f (f a) (f b) -> Dom f a b

-- | @Dict@ 是全忠实的：一条函数 @Dict c -> Dict d@ 由它在唯一元素 'Dict' 上的值决定，
-- 再包回 @c :- d@（构造子 'Sub'）。这就是「约束蕴含」和「字典之间的函数」的对应。
instance FullyFaithful Dict where
  unfmap f = Sub $ f Dict

-- | 米田引理的一个方向。@(->)@ 作为「左端反变」的函子时，
-- 自然变换 @Nat (->) (->) ((->) a) ((->) b)@ 由它在 'id' 上的分量 @b -> a@ 唯一决定，
-- 再放进对偶范畴（'Op'）变回一条箭头。
instance FullyFaithful (->) where
  unfmap (Nat f) = Op (f id)

-- | 约束蕴含 @(:-)@ 与 @(->)@ 同样的米田还原：看自然变换作用在 'id' 上得到的那一条蕴含。
instance FullyFaithful (:-) where
  unfmap (Nat f) = Op (f id)
