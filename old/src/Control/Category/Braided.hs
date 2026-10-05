{-# LANGUAGE CPP #-}
#if defined(__GLASGOW_HASKELL__) && __GLASGOW_HASKELL__ >= 702
{-# LANGUAGE Trustworthy #-}
#endif
{-# LANGUAGE MultiParamTypeClasses #-}
-------------------------------------------------------------------------------------------
-- |
-- Module     : Control.Category.Braided
-- Copyright  : 2008-2012 Edward Kmett
-- License    : BSD
--
-- Maintainer : Edward Kmett <ekmett@gmail.com>
-- Stability  : experimental
-- Portability: portable
--
--
-- 【中文】辫子 / 对称结构（braiding / symmetry）。
--
-- @braid :: k (p a b) (p b a)@ 交换张量的两个变元。应满足六边形连贯条件
-- （hexagon）：辫子与结合子相容。若还满足 @braid . braid = id@，则称为对称
-- （'Symmetric'），此时 @swap@ 只是 @braid@ 的别名。
--
-- 与单位子配合时还有：
--
-- @
-- idr . braid = idl
-- idl . braid = idr
-- @
--
-- （余幺半侧则是 @braid . coidr = coidl@ 等。）
--
-- 本文件在 @old/@ 下，不在 @categories.cabal@ 的 @hs-source-dirs@ 里，当前库不会编译它。
-- 英文说明保留；这里只加阅读用的中文，不改定义。
-------------------------------------------------------------------------------------------
module Control.Category.Braided
  ( Braided(..)
  , Symmetric
  , swap
  ) where

-- import Control.Categorical.Bifunctor
import Control.Category.Associative

{- | A braided (co)(monoidal or associative) category can commute the arguments of its bi-endofunctor. Obeys the laws:

> associate . braid . associate = second braid . associate . first braid
> disassociate . braid . disassociate = first braid . disassociate . second braid

If the category is Monoidal the following laws should be satisfied

> idr . braid = idl
> idl . braid = idr

If the category is Comonoidal the following laws should be satisfied

> braid . coidr = coidl
> braid . coidl = coidr

【中文】辫子：在结合结构上增加「交换两个因子」的自然同构。
六边形保证三次结合 + 辫子的两条路径一致；与单位子的三角形把左右单位子联系起来。
注意：一般辫子不必是对合（@braid . braid@ 不必等于 @id@），那是 'Symmetric' 的额外要求。
-}

class Associative k p => Braided k p where
    -- | 【中文】辫子 β：@a ⊗ b → b ⊗ a@。
    braid :: k (p a b) (p b a)

-- | 【中文】@Either@ 的辫子：互换 @Left@ / @Right@。
instance Braided (->) Either where
    braid (Left a) = Right a
    braid (Right b) = Left b

-- | 【中文】元组的辫子：@(a,b) ↦ (b,a)@（惰性匹配 @~@ 保持与积的其他组合子相容）。
instance Braided (->) (,) where
    braid ~(a,b) = (b,a)

{-- RULES
"braid/associate/braid"         second braid . associate . first braid    = associate . braid . associate
"braid/disassociate/braid"      first braid . disassociate . second braid = disassociate . braid . disassociate
  --}

{- |
If we have a symmetric (co)'Monoidal' category, you get the additional law:

> swap . swap = id

【中文】对称结构：辫子是对合。此时交换两次回到原处，@swap@ 可作为更口头的名字。
-}
class Braided k p => Symmetric k p

-- | 【中文】对称情形下交换的入口，定义成 @braid@。
swap :: Symmetric k p => k (p a b) (p b a)
swap = braid

{-- RULES
"swap/swap" swap . swap = id
  --}

instance Symmetric (->) Either
instance Symmetric (->) (,)
