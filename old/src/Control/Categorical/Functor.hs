{-# LANGUAGE CPP #-}
#if __GLASGOW_HASKELL__ >= 702
{-# LANGUAGE Trustworthy #-}
#endif
{-# LANGUAGE MultiParamTypeClasses, FunctionalDependencies, FlexibleContexts, UndecidableInstances, FlexibleInstances #-}
#if __GLASGOW_HASKELL__ >= 708
{-# LANGUAGE DeriveDataTypeable #-}
#endif
-------------------------------------------------------------------------------------------
-- |
-- Module      : Control.Categorical.Functor
-- Copyright   : 2008-2010 Edward Kmett
-- License     : BSD3
--
-- Maintainer  : Edward Kmett <ekmett@gmail.com>
-- Stability   : experimental
-- Portability : non-portable (functional-dependencies)
--
-- A more categorical definition of 'Functor'
--
-- 【中文】旧版函子：多参数类 @Functor f r t@，用函数依赖固定
-- 「对象映射 @f@ + 定义域箭头范畴 @r@」与「余定义域箭头范畴 @t@」的关系。
--
-- 对比当前 @src/Math/Functor.hs@：新版用关联类型 @Dom f@ / @Cod f@，
-- 旧版把定义域、余定义域写成类参数。
--
-- * 'fmap' 应满足 @fmap id = id@、@fmap (f . g) = fmap f . fmap g@；
-- * 'Endofunctor'：定义域与余定义域相同（自函子）；
-- * 'LiftedFunctor'：把 "Prelude" 函子抬进本层；
-- * 'LoweredFunctor'：把本层在 @(->)@ 上的函子降回 "Prelude"。
--
-- 本文件在 @old/@ 下，不在 @categories.cabal@ 的 @hs-source-dirs@ 里，当前库不会编译它。
-- 英文说明保留；这里只加阅读用的中文，不改定义。
-------------------------------------------------------------------------------------------
module Control.Categorical.Functor
    ( Functor(fmap)
    , Endofunctor
    , LiftedFunctor(..)
    , LoweredFunctor(..)
    ) where

#ifndef MIN_VERSION_base
#define MIN_VERSION_base(x,y,z) 1
#endif

import Control.Category
import Prelude hiding (id, (.), Functor(..))
import qualified Prelude
#ifdef __GLASGOW_HASKELL__
import Data.Data (Data(..), mkDataType, DataType, mkConstr, Constr, constrIndex, Fixity(..))
#if __GLASGOW_HASKELL__ < 708
#if MIN_VERSION_base(4,4,0)
import Data.Typeable (Typeable1(..), TyCon, mkTyCon3, mkTyConApp, gcast1)
#else
import Data.Typeable (Typeable1(..), TyCon, mkTyCon, mkTyConApp, gcast1)
#endif
#else
import Data.Typeable (Typeable, gcast1)
#endif
#endif

-- TODO Data, Typeable
-- | 【中文】包装器：把 "Prelude".'Functor' 实例抬进本模块的 'Functor' 类。
newtype LiftedFunctor f a = LiftedFunctor (f a) deriving
  ( Show
  , Read
#if __GLASGOW_HASKELL__ >= 708
  , Typeable
#endif
  )

#ifdef __GLASGOW_HASKELL__

liftedConstr :: Constr
liftedConstr = mkConstr liftedDataType "LiftedFunctor" [] Prefix
{-# NOINLINE liftedConstr #-}

liftedDataType :: DataType
liftedDataType = mkDataType "Control.Categorical.Fucntor.LiftedFunctor" [liftedConstr]
{-# NOINLINE liftedDataType #-}

#if __GLASGOW_HASKELL__ < 708
instance Typeable1 f => Typeable1 (LiftedFunctor f) where
  typeOf1 tfa = mkTyConApp liftedTyCon [typeOf1 (undefined `asArgsType` tfa)]
    where asArgsType :: f a -> t f a -> f a
          asArgsType = const

liftedTyCon :: TyCon
#if MIN_VERSION_base(4,4,0)
liftedTyCon = mkTyCon3 "categories" "Control.Categorical.Functor" "LiftedFunctor"
#else
liftedTyCon = mkTyCon "Control.Categorical.Functor.LiftedFunctor"
#endif
{-# NOINLINE liftedTyCon #-}

#else
#define Typeable1 Typeable
#endif

instance (Typeable1 f, Data (f a), Data a) => Data (LiftedFunctor f a) where
  gfoldl f z (LiftedFunctor a) = z LiftedFunctor `f` a
  toConstr _ = liftedConstr
  gunfold k z c = case constrIndex c of
    1 -> k (z LiftedFunctor)
    _ -> error "gunfold"
  dataTypeOf _ = liftedDataType
  dataCast1 f = gcast1 f
#endif

-- | 【中文】包装器：把本模块在 @(->)@ 上的 'Functor' 降成 "Prelude".'Functor'。
newtype LoweredFunctor f a = LoweredFunctor (f a) deriving
  ( Show
  , Read
#if __GLASGOW_HASKELL__ >= 708
  , Typeable
#endif
  )

#ifdef __GLASGOW_HASKELL__

loweredConstr :: Constr
loweredConstr = mkConstr loweredDataType "LoweredFunctor" [] Prefix
{-# NOINLINE loweredConstr #-}

loweredDataType :: DataType
loweredDataType = mkDataType "Control.Categorical.Fucntor.LoweredFunctor" [loweredConstr]
{-# NOINLINE loweredDataType #-}

#if __GLASGOW_HASKELL__ < 708
instance Typeable1 f => Typeable1 (LoweredFunctor f) where
  typeOf1 tfa = mkTyConApp loweredTyCon [typeOf1 (undefined `asArgsType` tfa)]
    where asArgsType :: f a -> t f a -> f a
          asArgsType = const

loweredTyCon :: TyCon
#if MIN_VERSION_base(4,4,0)
loweredTyCon = mkTyCon3 "categories" "Control.Categorical.Functor" "LoweredFunctor"
#else
loweredTyCon = mkTyCon "Control.Categorical.Functor.LoweredFunctor"
#endif
{-# NOINLINE loweredTyCon #-}

#endif

instance (Typeable1 f, Data (f a), Data a) => Data (LoweredFunctor f a) where
  gfoldl f z (LoweredFunctor a) = z LoweredFunctor `f` a
  toConstr _ = loweredConstr
  gunfold k z c = case constrIndex c of
    1 -> k (z LoweredFunctor)
    _ -> error "gunfold"
  dataTypeOf _ = loweredDataType
  dataCast1 f = gcast1 f

#endif

-- | 【中文】范畴论意义下的函子：把 @r@-箭头 @a → b@ 送到 @t@-箭头 @f a → f b@。
-- @r@ 是定义域范畴的箭头种类，@t@ 是余定义域的。
class (Category r, Category t) => Functor f r t | f r -> t, f t -> r where
  -- | 【中文】对象映射在箭头上的作用；须保持单位与复合。
  fmap :: r a b -> t (f a) (f b)
--  default fmap :: Prelude.Functor f => (a -> b) -> f a -> f b
--  fmap = Prelude.fmap

-- | 【中文】降下：本层 @(->)@ 函子 → Prelude 函子。
instance Functor f (->) (->) => Prelude.Functor (LoweredFunctor f) where
  fmap f (LoweredFunctor a) = LoweredFunctor (Control.Categorical.Functor.fmap f a)

-- | 【中文】抬升：Prelude 函子 → 本层 @(->)@ 函子。
instance Prelude.Functor f => Functor (LiftedFunctor f) (->) (->) where
  fmap f (LiftedFunctor a) = LiftedFunctor (Prelude.fmap f a)

-- | 【中文】固定左分量的 @(a,)@ 是函子（只映射元组右边）。
instance Functor ((,) a) (->) (->) where
  fmap f (a, b) = (a, f b)

-- | 【中文】固定左标签的 @Either a@ 是函子（只映射 @Right@）。
instance Functor (Either a) (->) (->) where
  fmap _ (Left a) = Left a
  fmap f (Right a) = Right (f a)

instance Functor Maybe (->) (->) where
  fmap = Prelude.fmap

instance Functor [] (->) (->) where
  fmap = Prelude.fmap

instance Functor IO (->) (->) where
  fmap = Prelude.fmap

-- | 【中文】自函子：定义域范畴与余定义域范畴相同。
class Functor f a a => Endofunctor f a
instance Functor f a a => Endofunctor f a
