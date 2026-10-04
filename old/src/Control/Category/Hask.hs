-------------------------------------------------------------------------------------------
-- |
-- Module    : Control.Category.Hask
-- Copyright : 2008-2010 Edward Kmett
-- License   : BSD
--
-- Maintainer  : Edward Kmett <ekmett@gmail.com>
-- Stability   : experimental
-- Portability : portable
--
-- Make it clearer when we are dealing with the category (->) that we mean the category
-- of haskell types via its Hom bifunctor (->)
--
-- 【中文】把函数箭头 (->) 起名为 Hask，提醒读者这时对象是 Haskell 类型、箭头是函数。当前库直接把 (->) 写成 Category 的实例，不再单独要这个别名。
-- 本文件在 old/ 下，不在 categories.cabal 的 hs-source-dirs 里，当前库不会编译它。
-- 英文说明保留；这里只加阅读用的中文，不改定义。
-------------------------------------------------------------------------------------------
module Control.Category.Hask ( Hask ) where

type Hask = (->)
