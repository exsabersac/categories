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
-- 【中文】分配范畴（distributive category）：积对余积可分配。
--
-- 只要同时有积与余积，就总有「正向」的因子化箭头：
--
-- @
-- factor :  (a×b) + (a×c)  →  a × (b+c)
-- @
--
-- （用 @second inl ||| second inr@ 拼出。）
-- 'Distributive' 要求反方向的 @distribute@ 也存在，使 @factor@ 成为同构：
--
-- @
-- distribute :  a × (b+c)  →  (a×b) + (a×c)
-- factor . distribute = id
-- distribute . factor = id
-- @
--
-- @Hask@ 满足分配律：元组里带着 @Either@，可以按标签拆成两个元组再注入。
--
-- 本文件在 @old/@ 下，不在 @categories.cabal@ 的 @hs-source-dirs@ 里，当前库不会编译它。
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
--
-- 【中文】标准的「和上面积 → 积上面和」箭头。
-- 左支给右边贴上 @inl@，右支贴上 @inr@，再经 @(|||)@ 合成。
factor :: (Cartesian k, CoCartesian k) => Sum k (Product k a b) (Product k a c) `k` Product k a (Sum k b c)
factor = second inl ||| second inr

-- | A category in which 'factor' is an isomorphism
--
-- 【中文】分配结构：要求 @distribute@ 作为 @factor@ 的逆。
class (Cartesian k, CoCartesian k) => Distributive k where
    -- | 【中文】分配律同构的一方向：把积里的余积拆到外面。
    distribute :: Product k a (Sum k b c) `k` Sum k (Product k a b) (Product k a c)

-- | 【中文】@Hask@ 上的分配：按 @Either@ 标签把共享的 @a@ 分别配到左右。
instance Distributive (->) where
    distribute (a, Left b) = Left (a,b)
    distribute (a, Right c) = Right (a,c)

{-- RULES
"factor . distribute" factor . distribute = id
"distribute . factor" distribute . factor = id
  --}
