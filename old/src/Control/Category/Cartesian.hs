{-# LANGUAGE CPP #-}
#if defined(__GLASGOW_HASKELL__) && __GLASGOW_HASKELL__ >= 702
{-# LANGUAGE Trustworthy #-}
#endif
{-# LANGUAGE TypeFamilies, MultiParamTypeClasses, TypeOperators, FlexibleContexts, FlexibleInstances, UndecidableInstances #-}
-------------------------------------------------------------------------------------------
-- |
-- Module    : Control.Category.Cartesian
-- Copyright : 2008-2010 Edward Kmett
-- License   : BSD
--
-- Maintainer  : Edward Kmett <ekmett@gmail.com>
-- Stability   : experimental
-- Portability : non-portable (class-associated types)
--
--
-- 【中文】笛卡尔 / 余笛卡尔结构：有限积与有限余积。
--
-- * 'Cartesian'：积 @Product k@，投影 @fst@ / @snd@，对角 @diag@，配对 @(&&&)@。
--   超类要求积张量已是对称幺半（'Symmetric' + 'Monoidal'）。
-- * 'CoCartesian'：余积 @Sum k@，注入 @inl@ / @inr@，余对角 @codiag@，分情形 @(|||)@。
--
-- 经典积的通用性质：对任意 @f : a → b@、@g : a → c@，存在唯一
-- @f &&& g : a → b × c@ 使 @fst . (f &&& g) = f@、@snd . (f &&& g) = g@。
-- 余积对偶：@(f ||| g) . inl = f@、@(f ||| g) . inr = g@。
--
-- 下面的 @bimapProduct@ / @braidProduct@ / @associateProduct@ 等是「已知积的
-- 通用性质时，免费得到 Bifunctor / Braided / Associative 结构」的公式；
-- 余积侧同理。
--
-- 本文件在 @old/@ 下，不在 @categories.cabal@ 的 @hs-source-dirs@ 里，当前库不会编译它。
-- 英文说明保留；这里只加阅读用的中文，不改定义。
-------------------------------------------------------------------------------------------
module Control.Category.Cartesian
    (
    -- * (Co)Cartesian categories
      Cartesian(..)
    , bimapProduct, braidProduct, associateProduct, disassociateProduct
    , CoCartesian(..)
    , bimapSum, braidSum, associateSum, disassociateSum
    ) where

import Control.Category.Braided
import Control.Category.Monoidal
import Prelude hiding (Functor, map, (.), id, fst, snd, curry, uncurry)
import qualified Prelude (fst,snd)
import Control.Categorical.Bifunctor
import Control.Category

infixr 3 &&&
infixr 2 |||

{- |
Minimum definition:

> fst, snd, diag
> fst, snd, (&&&)

【中文】笛卡尔范畴（有限积）。最少实现二选一：
给出投影与对角，或给出投影与配对组合子 @(&&&)@。
默认实现互相推导：@diag = id &&& id@，@f &&& g = bimap f g . diag@。

积定律（约定）：

@
fst . diag = id
snd . diag = id
fst . (f &&& g) = f
snd . (f &&& g) = g
@
-}
class (Symmetric k (Product k), Monoidal k (Product k)) => Cartesian k where
    -- | 【中文】该范畴的积二元函子（通常写作 ×）。
    type Product k :: * -> * -> *
    -- | 【中文】左投影 π₁。
    fst :: Product k a b `k` a
    -- | 【中文】右投影 π₂。
    snd :: Product k a b `k` b
    -- | 【中文】对角 Δ : a → a × a。
    diag :: a `k` Product k a a
    -- | 【中文】配对 〈f,g〉：由两条同域箭头得到进入积的箭头。
    (&&&) :: (a `k` b) -> (a `k` c) -> a `k` Product k b c

    diag = id &&& id
    f &&& g = bimap f g . diag

{-- RULES
"fst . diag"      fst . diag = id
"snd . diag"    snd . diag = id
"fst . f &&& g" forall f g. fst . (f &&& g) = f
"snd . f &&& g" forall f g. snd . (f &&& g) = g
 --}

-- | 【中文】@Hask@ 的积是 @(,)@：投影即 "Prelude" 的 @fst@/@snd@，对角复制，配对并应用。
instance Cartesian (->) where
    type Product (->) = (,)
    fst = Prelude.fst
    snd = Prelude.snd
    diag a = (a,a)
    (f &&& g) a = (f a, g a)

-- | free construction of 'Bifunctor' for the product 'Bifunctor' @Product k@ if @(&&&)@ is known
--
-- 【中文】由配对免费得到积上的 @bimap@：@bimap f g = (f . fst) &&& (g . snd)@。
bimapProduct :: Cartesian k => k a c -> k b d -> Product k a b `k` Product k c d
bimapProduct f g = (f . fst) &&& (g . snd)

-- | free construction of 'Braided' for the product 'Bifunctor' @Product k@
--
-- 【中文】由配对免费得到积上的辫子：@snd &&& fst@。
braidProduct :: Cartesian k => k (Product k a b) (Product k b a)
braidProduct = snd &&& fst

-- | free construction of 'Associative' for the product 'Bifunctor' @Product k@
--
-- 【中文】由配对免费得到积的结合子。
associateProduct :: Cartesian k => Product k (Product k a b) c `k` Product k a (Product k b c)
associateProduct = (fst . fst) &&& first snd

-- | free construction of 'Disassociative' for the product 'Bifunctor' @Product k@
--
-- 【中文】积的逆结合子；这里用辫子与 @associateProduct@ 拼出（与直接写对称公式等价）。
disassociateProduct:: Cartesian k => Product k a (Product k b c) `k` Product k (Product k a b) c
disassociateProduct= braid . second braid . associateProduct . first braid . braid

-- * Co-Cartesian categories

-- a category that has finite coproducts, weakened the same way as PreCartesian above was weakened
--
-- 【中文】余笛卡尔范畴（有限余积）。对偶于积：
-- 注入 @inl@/@inr@、余对角、分情形组合子 @(|||)@。
-- 定律：@codiag . inl = id@、@(f ||| g) . inl = f@ 等。
class (Monoidal k (Sum k), Symmetric k (Sum k)) => CoCartesian k where
    -- | 【中文】该范畴的余积二元函子（通常写作 + 或 ⊔）。
    type Sum k :: * -> * -> *
    -- | 【中文】左注入 ι₁。
    inl :: a `k` Sum k a b
    -- | 【中文】右注入 ι₂。
    inr :: b `k` Sum k a b
    -- | 【中文】余对角 ∇ : a + a → a。
    codiag :: Sum k a a `k` a
    -- | 【中文】分情形 [f,g]：由两条同余域箭头得到离开余积的箭头。
    (|||) :: k a c -> k b c -> Sum k a b `k` c

    codiag = id ||| id
    f ||| g = codiag . bimap f g

{-- RULES
"codiag . inl"  codiag . inl = id
"codiag . inr"    codiag . inr = id
"(f ||| g) . inl" forall f g. (f ||| g) . inl = f
"(f ||| g) . inr" forall f g. (f ||| g) . inr = g
 --}

-- | 【中文】@Hask@ 的余积是 @Either@。
instance CoCartesian (->) where
    type Sum (->) = Either
    inl = Left
    inr = Right
    codiag (Left a) = a
    codiag (Right a) = a
    (f ||| _) (Left a) = f a
    (_ ||| g) (Right a) = g a

-- | free construction of 'Bifunctor' for the coproduct 'Bifunctor' @Sum k@ if @(|||)@ is known
--
-- 【中文】由分情形免费得到余积上的 @bimap@。
bimapSum :: CoCartesian k => k a c -> k b d -> Sum k a b `k` Sum k c d
bimapSum f g = (inl . f) ||| (inr . g)

-- | free construction of 'Braided' for the coproduct 'Bifunctor' @Sum k@
--
-- 【中文】余积上的辫子：@inr ||| inl@。
braidSum :: CoCartesian k => Sum k a b `k` Sum k b a
braidSum = inr ||| inl

-- | free construction of 'Associative' for the coproduct 'Bifunctor' @Sum k@
--
-- 【中文】余积的结合子（经辫子与 @disassociateSum@ 表达）。
associateSum :: CoCartesian k => Sum k (Sum k a b) c `k` Sum k a (Sum k b c)
associateSum = braid . first braid . disassociateSum . second braid . braid

-- | free construction of 'Disassociative' for the coproduct 'Bifunctor' @Sum k@
--
-- 【中文】余积的逆结合子。
disassociateSum :: CoCartesian k => Sum k a (Sum k b c) `k` Sum k (Sum k a b) c
disassociateSum = (inl . inl) ||| first inr
