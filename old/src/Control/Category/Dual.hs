{-# LANGUAGE CPP #-}
{-# LANGUAGE TypeOperators, FlexibleContexts #-}
#if __GLASGOW_HASKELL__ >= 702
{-# LANGUAGE Trustworthy #-}
#endif
#if __GLASGOW_HASKELL__ >= 708
{-# LANGUAGE DeriveDataTypeable #-}
#endif
-------------------------------------------------------------------------------------------
-- |
-- Module   : Control.Category.Dual
-- Copyright: 2008-2010 Edward Kmett
-- License  : BSD
--
-- Maintainer : Edward Kmett <ekmett@gmail.com>
-- Stability  : experimental
-- Portability: portable
--
--
-- 【中文】对偶范畴（dual / opposite category）的载体：@Dual k a b@ 里装的是 @k b a@，
-- 也就是把原范畴的箭头全部反向。
--
-- 经典对照：
--
-- * 对象集合与 @k@ 相同；
-- * 态射 @a → b@ 在对偶里变成 @b → a@；
-- * 单位：@id_Dual = Dual id@；
-- * 复合：@Dual f . Dual g = Dual (g . f)@（顺序对调，才能与原复合衔接）。
--
-- 当前库（@src/Math/Category.hs@）用 'Yoneda' 与类型族 'Op' 扮演同一角色；
-- 本文件是 1.x / @Control.Category@ 风格的写法。
--
-- 本文件在 @old/@ 下，不在 @categories.cabal@ 的 @hs-source-dirs@ 里，当前库不会编译它。
-- 英文说明保留；这里只加阅读用的中文，不改定义。
-------------------------------------------------------------------------------------------
module Control.Category.Dual
  ( Dual(..)
  ) where

#ifndef MIN_VERSION_base
#define MIN_VERSION_base(x,y,z) 1
#endif

import Control.Category

#ifdef __GLASGOW_HASKELL__
import Data.Data (Data(..), mkDataType, DataType, mkConstr, Constr, constrIndex, Fixity(..))
#if __GLASGOW_HASKELL__ < 708
#if MIN_VERSION_base(4,4,0)
import Data.Typeable (Typeable2(..), TyCon, mkTyCon3, mkTyConApp, gcast1)
#else
import Data.Typeable (Typeable2(..), TyCon, mkTyCon, mkTyConApp, gcast1)
#endif
import Prelude (undefined,const,error)
#else
import Prelude (error)
import Data.Typeable (Typeable, gcast1)
#endif
#endif

-- | 【中文】对偶箭头的 newtype。字段 @runDual@ 取出「方向相反」的那条原箭头。
-- 类型参数顺序是 @Dual k a b@，内部却是 @k b a@：外层从 @a@ 到 @b@，里层从 @b@ 到 @a@。
data Dual k a b = Dual { runDual :: k b a }
#if __GLASGOW_HASKELL__ >= 708
  deriving Typeable

#define Typeable2 Typeable
#endif

-- | 【中文】对偶范畴的 'Category' 实例：单位套一层 @Dual@；复合先剥开、反序复合、再包回去。
instance Category k => Category (Dual k) where
  id = Dual id
  Dual f . Dual g = Dual (g . f)

#ifdef __GLASGOW_HASKELL__

#if __GLASGOW_HASKELL__ < 707
instance Typeable2 k => Typeable2 (Dual k) where
  typeOf2 tfab = mkTyConApp dataTyCon [typeOf2 (undefined `asDualArgsType` tfab)]
    where asDualArgsType :: f b a -> t f a b -> f b a
          asDualArgsType = const

dataTyCon :: TyCon
#if MIN_VERSION_base(4,4,0)
dataTyCon = mkTyCon3 "categories" "Control.Category.Dual" "Dual"
#else
dataTyCon = mkTyCon "Control.Category.Dual.Dual"
#endif
{-# NOINLINE dataTyCon #-}
#endif

dualConstr :: Constr
dualConstr = mkConstr dataDataType "Dual" [] Prefix
{-# NOINLINE dualConstr #-}

dataDataType :: DataType
dataDataType = mkDataType "Control.Category.Dual.Dual" [dualConstr]
{-# NOINLINE dataDataType #-}

instance (Typeable2 k, Data a, Data b, Data (k b a)) => Data (Dual k a b) where
  gfoldl f z (Dual a) = z Dual `f` a
  toConstr _ = dualConstr
  gunfold k z c = case constrIndex c of
    1 -> k (z Dual)
    _ -> error "gunfold"
  dataTypeOf _ = dataDataType
  dataCast1 f = gcast1 f
#endif
