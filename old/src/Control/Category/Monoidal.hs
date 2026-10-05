{-# LANGUAGE TypeFamilies, MultiParamTypeClasses #-}
-------------------------------------------------------------------------------------------
-- |
-- Module    : Control.Category.Monoidal
-- Copyright : 2008,2012 Edward Kmett
-- License   : BSD
--
-- Maintainer : Edward Kmett <ekmett@gmail.com>
-- Stability  : experimental
-- Portability: non-portable (class-associated types)
--
-- A 'Monoidal' category is a category with an associated biendofunctor that has an identity,
-- which satisfies Mac Lane''s pentagonal and triangular coherence conditions
-- Technically we usually say that category is 'Monoidal', but since
-- most interesting categories in our world have multiple candidate bifunctors that you can
-- use to enrich their structure, we choose here to think of the bifunctor as being
-- monoidal. This lets us reuse the same 'Bifunctor' over different categories without
-- painful newtype wrapping.

--
-- 【中文】幺半范畴结构（monoidal structure）：在已结合的二元函子 @p@ 上再配备单位对象
-- @Id k p@，以及左右单位子（传统记号 λ、ρ）及其逆：
--
-- @
-- idl   :  I ⊗ a  →  a          （λ）
-- idr   :  a ⊗ I  →  a          （ρ）
-- coidl :  a      →  I ⊗ a      （λ⁻¹）
-- coidr :  a      →  a ⊗ I      （ρ⁻¹）
-- @
--
-- 应满足三角形连贯条件（triangle）：单位子与结合子相容；且
-- @idl . coidl = id@、@idr . coidr = id@ 等（互为逆）。
--
-- 设计选择：类挂在「范畴 + 二元函子」上，而不是只挂在范畴上——
-- 同一范畴往往有多种候选张量（积、和……），这样可避免为每种张量包 newtype。
--
-- 本文件在 @old/@ 下，不在 @categories.cabal@ 的 @hs-source-dirs@ 里，当前库不会编译它。
-- 英文说明保留；这里只加阅读用的中文，不改定义。
-------------------------------------------------------------------------------------------

module Control.Category.Monoidal
  ( Monoidal(..)
  ) where

import Control.Category.Associative
import Data.Void

-- | Denotes that we have some reasonable notion of 'Identity' for a particular 'Bifunctor' in this 'Category'. This
-- notion is currently used by both 'Monoidal' and 'Comonoidal'

{- | A monoidal category. 'idl' and 'idr' are traditionally denoted lambda and rho
 the triangle identities hold:

> first idr = second idl . associate
> second idl = first idr . associate
> first idr = disassociate . second idl
> second idl = disassociate . first idr
> idr . coidr = id
> idl . coidl = id
> coidl . idl = id
> coidr . idr = id

【中文】幺半结构：超类 'Associative' 已给出结合子；这里补上单位对象与单位子。
三角形条件把「先结合再消单位」与「直接消另一侧单位」等同起来。
关联类型 @Id k p@ 是「相对这个张量 @p@」的单位，不是范畴的全局唯一数据。
-}

class Associative k p => Monoidal (k :: * -> * -> *) (p :: * -> * -> *) where
  -- | 【中文】张量 @p@ 在范畴 @k@ 中的单位对象（monoidal unit）。
  type Id (k :: * -> * -> *) (p :: * -> * -> *) :: *
  -- | 【中文】左单位子 λ：消去左边的单位。
  idl   :: k (p (Id k p) a) a
  -- | 【中文】右单位子 ρ：消去右边的单位。
  idr   :: k (p a (Id k p)) a
  -- | 【中文】左单位子的逆 λ⁻¹：在左边引入单位。
  coidl :: k a (p (Id k p) a)
  -- | 【中文】右单位子的逆 ρ⁻¹：在右边引入单位。
  coidr :: k a (p a (Id k p))

-- | 【中文】积幺半结构：单位是 @()@；@idl = snd@，@idr = fst@；
-- @coidl@ / @coidr@ 分别塞入左边或右边的 @()@。
instance Monoidal (->) (,) where
  type Id (->) (,) = ()
  idl = snd
  idr = fst
  coidl a = ((),a)
  coidr a = (a,())

-- | 【中文】余积幺半结构：单位是空类型 @Void@；
-- 从 @Either Void a@ 出来只能走 @Right@（@absurd@ 处理不可能的 @Left@）；
-- @coidl = Right@、@coidr = Left@ 把值注入非空那一侧。
instance Monoidal (->) Either where
  type Id (->) Either = Void
  idl = either absurd id
  idr = either id absurd
  coidl = Right
  coidr = Left

{-- RULES
-- "bimap id idl/associate"   second idl . associate = first idr
-- "bimap idr id/associate"   first idr . associate = second idl
-- "disassociate/bimap id idl"  disassociate . second idl = first idr
-- "disassociate/bimap idr id"  disassociate . first idr = second idl
"idr/coidr" idr . coidr = id
"idl/coidl"  idl . coidl = id
"coidl/idl"  coidl . idl = id
"coidr/idr"  coidr . idr = id
"idr/braid" idr . braid = idl
"idl/braid" idl . braid = idr
"braid/coidr" braid . coidr = coidl
"braid/coidl" braid . coidl = coidr
 --}
