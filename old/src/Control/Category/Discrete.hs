{-# LANGUAGE GADTs, TypeOperators #-}
-------------------------------------------------------------------------------------------
-- |
-- Module    : Control.Category.Discrete
-- Copyright : 2008-2010 Edward Kmett
-- License   : BSD
--
-- Maintainer  : Edward Kmett <ekmett@gmail.com>
-- Stability   : experimental
-- Portability : portable
--
--
-- 【中文】离散范畴（discrete category）：对象可以任意，但箭头「只有单位」。
-- 因此 @Discrete a b@ 同时是一条箭头，也是「@a@ 与 @b@ 相同」的证明。
--
-- 经典对照：
--
-- * 对象：任意类型 @a@；
-- * 态射：仅有 @Refl :: Discrete a a@（identity）；
-- * 复合：@Refl . Refl = Refl@；
-- * 单位律 / 结合律：由构造子唯一性自动成立。
--
-- @liftDiscrete@ 把相等证明抬到 @f a@ / @f b@；@cast@ 把证明降成任意范畴里的 @id@；
-- @inverse@ 说明离散范畴其实是群胚（每条箭头可逆）。
--
-- 本文件在 @old/@ 下，不在 @categories.cabal@ 的 @hs-source-dirs@ 里，当前库不会编译它。
-- 英文说明保留；这里只加阅读用的中文，不改定义。
-------------------------------------------------------------------------------------------
module Control.Category.Discrete
    ( Discrete(Refl)
    , liftDiscrete
    , cast
    , inverse
    ) where

import Prelude ()
import Control.Category

-- | Category of discrete objects. The only arrows are identity arrows.
--
-- 【中文】离散范畴的箭头类型。唯一构造子 @Refl@ 要求两端相同，
-- 所以有值的 @Discrete a b@ 就是 @a ~ b@ 的证据。
data Discrete a b where
    -- | 【中文】单位箭头，也是「两端类型相等」的证明。
    Refl :: Discrete a a

-- | 【中文】离散范畴是 'Category'：@id = Refl@；复合只有 @Refl . Refl@ 一种可能。
instance Category Discrete where
    id = Refl
    Refl . Refl = Refl

-- instance Groupoid Discrete where
--  inv Refl = Refl

-- | Discrete a b acts as a proof that a = b, lift that proof into something of kind * -> *
--
-- 【中文】把 @a ~ b@ 的证明沿任意 @f :: * -> *@ 抬升为 @f a ~ f b@。
-- 因为只有 @Refl@，模式匹配后直接再构造 @Refl@ 即可（Congruence / congruence of equality）。
liftDiscrete :: Discrete a b -> Discrete (f a) (f b)
liftDiscrete Refl = Refl

-- | Lower the proof that a ~ b to an arbitrary category.
--
-- 【中文】把相等证明「降」成任意范畴 @k@ 里的单位箭头：
-- 若 @a ~ b@，则 @id :: k a b@ 合法。这是离散范畴到任意范畴的唯一函子在箭头上的作用。
cast :: Category k => Discrete a b -> k a b
cast Refl = id

-- | 【中文】离散范畴里每条箭头可逆：@Refl@ 的逆仍是 @Refl@。
-- （若启用 'Groupoid'，这就是 @inv@。）
inverse :: Discrete a b -> Discrete b a
inverse Refl = Refl
