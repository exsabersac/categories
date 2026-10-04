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
-- 【中文】离散范畴：仅有单位箭头 Refl，因此 Discrete a b 同时是 a 与 b 相同的证明。liftDiscrete 把证明抬到 f a 与 f b；cast 把证明降成任意范畴里的 id。
-- 本文件在 old/ 下，不在 categories.cabal 的 hs-source-dirs 里，当前库不会编译它。
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
data Discrete a b where
    Refl :: Discrete a a

instance Category Discrete where
    id = Refl
    Refl . Refl = Refl

-- instance Groupoid Discrete where
--  inv Refl = Refl

-- | Discrete a b acts as a proof that a = b, lift that proof into something of kind * -> *
liftDiscrete :: Discrete a b -> Discrete (f a) (f b)
liftDiscrete Refl = Refl

-- | Lower the proof that a ~ b to an arbitrary category.
cast :: Category k => Discrete a b -> k a b
cast Refl = id

-- |
inverse :: Discrete a b -> Discrete b a
inverse Refl = Refl
