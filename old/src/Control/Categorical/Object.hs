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
-- 【中文】终对象与始对象（terminal / initial object），都是（余）极限的特例。
--
-- * 终对象 @T@：对每个对象 @a@，存在唯一箭头 @terminate : a → T@。
--   在 @Hask@ 里典型例子是 @()@。
-- * 始对象 @I@：对每个对象 @a@，存在唯一箭头 @initiate : I → a@。
--   在 @Hask@ 里典型例子是 @Void@ / 空类型。
--
-- 「唯一」是范畴论意义下的：任意两条这样的箭头必须相等；类接口只给出存在的那条。
--
-- 注意：模块名在目录 @Control/Categorical/@ 下，但文件头写的是
-- @Control.Category.Object@（历史命名）；导出模块名仍是 @Control.Categorical.Object@。
--
-- 本文件在 @old/@ 下，不在 @categories.cabal@ 的 @hs-source-dirs@ 里，当前库不会编译它。
-- 英文说明保留；这里只加阅读用的中文，不改定义。
-------------------------------------------------------------------------------------------

module Control.Categorical.Object
    ( HasTerminalObject(..)
    , HasInitialObject(..)
    ) where

import Control.Category

-- | The @Category (~>)@ has a terminal object @Terminal (~>)@ such that for all objects @a@ in @(~>)@,
-- there exists a unique morphism from @a@ to @Terminal (~>)@.
--
-- 【中文】终对象：关联类型 @Terminal k@ 给出对象，@terminate@ 给出「到终对象的唯一箭头」。
class Category k => HasTerminalObject k where
    -- | 【中文】终对象本身。
    type Terminal k :: *
    -- | 【中文】从任意对象到终对象的唯一态射。
    terminate :: a `k` Terminal k

-- | The @Category (~>)@ has an initial (coterminal) object @Initial (~>)@ such that for all objects
-- @a@ in @(~>)@, there exists a unique morphism from @Initial (~>) @ to @a@.
--
-- 【中文】始对象（余终对象）：@initiate@ 是从始对象出发的唯一态射。
class Category k => HasInitialObject k where
    -- | 【中文】始对象本身。
    type Initial k :: *
    -- | 【中文】从始对象到任意对象的唯一态射。
    initiate :: Initial k `k` a
