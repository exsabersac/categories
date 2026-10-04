{-# LANGUAGE CPP #-}
#if defined(__GLASGOW_HASKELL__) && __GLASGOW_HASKELL__ >= 702
{-# LANGUAGE Trustworthy #-}
#endif
{-# LANGUAGE TypeOperators #-}
-------------------------------------------------------------------------------------------
-- |
-- Module   : Control.Category.Distributive
-- Copyright: 2008 Edward Kmett
-- License  : BSD
--
-- Maintainer : Edward Kmett <ekmett@gmail.com>
-- Stability  : experimental
-- Portability: non-portable (class-associated types)
--
--
-- 【中文】分配范畴。factor 是「和上面的积」收成「积上面的和」的标准箭头；Distributive 要求反方向的 distribute，使积对余积可分配。
-- 本文件在 old/ 下，不在 categories.cabal 的 hs-source-dirs 里，当前库不会编译它。
-- 英文说明保留；这里只加阅读用的中文，不改定义。
-------------------------------------------------------------------------------------------
module Control.Category.Distributive
    (
    -- * Distributive Categories
      factor
    , Distributive(..)
    ) where

import Prelude hiding (Functor, map, (.), id, fst, snd, curry, uncurry)
import Control.Categorical.Bifunctor
import Control.Category.Cartesian

-- | The canonical factoring morphism.

factor :: (Cartesian k, CoCartesian k) => Sum k (Product k a b) (Product k a c) `k` Product k a (Sum k b c)
factor = second inl ||| second inr

-- | A category in which 'factor' is an isomorphism

class (Cartesian k, CoCartesian k) => Distributive k where
    distribute :: Product k a (Sum k b c) `k` Sum k (Product k a b) (Product k a c)

instance Distributive (->) where
    distribute (a, Left b) = Left (a,b)
    distribute (a, Right c) = Right (a,c)

{-- RULES
"factor . distribute" factor . distribute = id
"distribute . factor" distribute . factor = id
  --}
