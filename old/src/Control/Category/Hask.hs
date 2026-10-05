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
-- 【中文】把函数箭头 @(->)@ 起名为 @Hask@，提醒读者此时：
--
-- * 对象是 Haskell 类型（kind @*@）；
-- * 态射是函数；
-- * 单位是 @id@，复合是 @(.)@（与 "Prelude" 同序：先右后左）。
--
-- 这是经典「Haskell 类型范畴」的记号习惯，本身不增加结构。
-- 当前库直接把 @(->)@ 写成 'Category' 的实例，不再单独要这个别名。
--
-- 本文件在 @old/@ 下，不在 @categories.cabal@ 的 @hs-source-dirs@ 里，当前库不会编译它。
-- 英文说明保留；这里只加阅读用的中文，不改定义。
-------------------------------------------------------------------------------------------
module Control.Category.Hask ( Hask ) where

-- | 【中文】Haskell 类型范畴的别名：@Hask = (->)@。
-- 读代码时看到 @Hask a b@ 就应想「类型 @a@ 到类型 @b@ 的函数」，而不是抽象的任意箭头。
type Hask = (->)
