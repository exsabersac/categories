{-# LANGUAGE CPP #-}
#if defined(__GLASGOW_HASKELL__) && __GLASGOW_HASKELL__ >= 702
{-# LANGUAGE Trustworthy #-}
#endif
{-# LANGUAGE TypeFamilies, MultiParamTypeClasses, TypeOperators, FlexibleContexts #-}
-------------------------------------------------------------------------------------------
-- |
-- Module     : Control.Category.Cartesian.Closed
-- Copyright  : 2008 Edward Kmett
-- License    : BSD
--
-- Maintainer : Edward Kmett <ekmett@gmail.com>
-- Stability  : experimental
-- Portability: non-portable (class-associated types)
--
--
-- 【中文】笛卡尔闭范畴（CCC）与余笛卡尔闭（CoCCC）。
--
-- 在有限积之上增加指数对象 @Exp k a b@（直觉上是「从 @a@ 到 @b@ 的内部齐均」），
-- 以及求值 @apply@、柯里化 @curry@ / @uncurry@：
--
-- @
-- apply  :  Exp(a,b) × a  →  b
-- curry  :  (a × b → c) → (a → Exp(b,c))
-- uncurry:  (a → Exp(b,c)) → (a × b → c)
-- @
--
-- @curry@ / @uncurry@ 应互为逆；@curry apply = id@。
-- @unitCCC@ / @counitCCC@ 是积函子与指数函子形成的伴随（adjunction）的单位 / 余单位。
--
-- 'CoCCC' 把箭头全部反过来：余指数、@coapply@、@cocurry@。
--
-- 本文件在 @old/@ 下，不在 @categories.cabal@ 的 @hs-source-dirs@ 里，当前库不会编译它。
-- 英文说明保留；这里只加阅读用的中文，不改定义。
-------------------------------------------------------------------------------------------
module Control.Category.Cartesian.Closed
    (
    -- * Cartesian Closed Category
      CCC(..)
    , unitCCC, counitCCC
    -- * Co-(Cartesian Closed Category)
    , CoCCC(..)
    , unitCoCCC, counitCoCCC
    ) where

import Prelude ()
import qualified Prelude

import Control.Category
import Control.Category.Braided
import Control.Category.Cartesian

-- * Closed Cartesian Category

-- | A 'CCC' has full-fledged monoidal finite products and exponentials
--
-- Ideally you also want an instance for @'Bifunctor' ('Exp' hom) ('Dual' hom) hom hom@.
-- or at least @'Functor' ('Exp' hom a) hom hom@, which cannot be expressed in the constraints here.
--
-- 【中文】笛卡尔闭：有积，且每个 @(-) × b@ 有右伴随 @Exp k b@。
-- 理想情况下指数还应是反变/协变的二元函子（第一变元走 'Dual'），
-- 但该类的约束写不下，留给实例自行补充。
class Cartesian k => CCC k where
    -- | 【中文】指数对象 bifunctor（内部齐均）；在 @Hask@ 里就是 @(->)@ 本身。
    type Exp k :: * -> * -> *
    -- | 【中文】求值（ counit of (−×b) ⊣ Exp(b,−) ）：把「函数 × 参数」送到结果。
    apply :: Product k (Exp k a b) a `k` b
    -- | 【中文】柯里化：把二元箭头变成「返回指数」的一元箭头。
    curry :: Product k a b `k` c -> a `k` Exp k b c
    -- | 【中文】反柯里化。
    uncurry :: a `k` Exp k b c -> Product k a b `k` c

-- | 【中文】@Hask@ 是 CCC：指数即函数类型，@apply (f,a) = f a@。
instance CCC (->) where
  type Exp (->) = (->)
  apply (f,a) = f a
  curry = Prelude.curry
  uncurry = Prelude.uncurry

{-# RULES
"curry apply"         curry apply = id
-- "curry . uncurry"     curry . uncurry = id
-- "uncurry . curry"     uncurry . curry = id
 #-}

-- * Free @'Adjunction' (Product (<=) a) (Exp (<=) a) (<=) (<=)@
-- | 【中文】伴随的单位：@a → Exp b (b × a)@，由 @curry braid@ 得到。
unitCCC :: CCC k => a `k` Exp k b (Product k b a)
unitCCC = curry braid

-- | 【中文】伴随的余单位：@b × Exp b a → a@，由 @apply . braid@ 得到。
counitCCC :: CCC k => Product k b (Exp k b a) `k` a
counitCCC = apply . braid

-- * A Co-(Closed Cartesian Category)

-- | A Co-CCC has full-fledged comonoidal finite coproducts and coexponentials
--
-- You probably also want an instance for @'Bifunctor' ('coexp' hom) ('Dual' hom) hom hom@.
--
-- 【中文】余笛卡尔闭：有余积与余指数。箭头方向相对 CCC 全部反过来。
-- @Hask@ 本身一般不写成 CoCCC 实例（函数类型不是余指数的自然选择）。
class CoCartesian k => CoCCC k where
    -- | 【中文】余指数对象。
    type Coexp k :: * -> * -> *
    -- | 【中文】余求值（coapply）。
    coapply :: b `k` Sum k (Coexp k a b) a
    -- | 【中文】余柯里化。
    cocurry :: c `k` Sum k a b -> Coexp k b c `k` a
    -- | 【中文】反余柯里化。
    uncocurry :: Coexp k b c `k` a -> c `k` Sum k a b

{-# RULES
"cocurry coapply" cocurry coapply = id
-- "cocurry . uncocurry"   cocurry . uncocurry = id
-- "uncocurry . cocurry"   uncocurry . cocurry = id
 #-}

-- * Free @'Adjunction' ('Coexp' (<=) a) ('Sum' (<=) a) (<=) (<=)@
-- | 【中文】CoCCC 伴随的单位。
unitCoCCC :: CoCCC k => a `k` Sum k b (Coexp k b a)
unitCoCCC = swap . coapply

-- | 【中文】CoCCC 伴随的余单位。
counitCoCCC :: CoCCC k => Coexp k b (Sum k b a) `k` a
counitCoCCC = cocurry swap
