{-# LANGUAGE TypeFamilies, TypeOperators #-}
-------------------------------------------------------------------------------------------
-- |
-- Module   : Control.Category.Object
-- Copyright: 2010-2012 Edward Kmett
-- License  : BSD
--
-- Maintainer : Edward Kmett <ekmett@gmail.com>
-- Stability  : experimental
-- Portability: non-portable (either class-associated types or MPTCs with fundeps)
--
-- This module declares the 'HasTerminalObject' and 'HasInitialObject' classes.
--
-- These are both special cases of the idea of a (co)limit.
--
-- 【中文】终对象与始对象。terminate 是到终对象的唯一箭头，initiate 是从始对象出发的唯一箭头，二者都是（余）极限的特例。
-- 本文件在 old/ 下，不在 categories.cabal 的 hs-source-dirs 里，当前库不会编译它。
-- 英文说明保留；这里只加阅读用的中文，不改定义。
-------------------------------------------------------------------------------------------

module Control.Categorical.Object
    ( HasTerminalObject(..)
    , HasInitialObject(..)
    ) where

import Control.Category

-- | The @Category (~>)@ has a terminal object @Terminal (~>)@ such that for all objects @a@ in @(~>)@,
-- there exists a unique morphism from @a@ to @Terminal (~>)@.
class Category k => HasTerminalObject k where
    type Terminal k :: *
    terminate :: a `k` Terminal k

-- | The @Category (~>)@ has an initial (coterminal) object @Initial (~>)@ such that for all objects
-- @a@ in @(~>)@, there exists a unique morphism from @Initial (~>) @ to @a@.

class Category k => HasInitialObject k where
    type Initial k :: *
    initiate :: Initial k `k` a
