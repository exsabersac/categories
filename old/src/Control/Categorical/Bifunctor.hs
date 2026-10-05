{-# LANGUAGE CPP #-}
#if defined(__GLASGOW_HASKELL__) && __GLASGOW_HASKELL__ >= 702
{-# LANGUAGE Trustworthy #-}
#endif
{-# LANGUAGE MultiParamTypeClasses, FunctionalDependencies, FlexibleContexts #-}
-------------------------------------------------------------------------------------------
-- |
-- Module   : Control.Categorical.Bifunctor
-- Copyright: 2008-2010 Edward Kmett
-- License  : BSD3
--
-- Maintainer : Edward Kmett <ekmett@gmail.com>
-- Stability  : experimental
-- Portability: non-portable (functional-dependencies)
--
-- A more categorical definition of 'Bifunctor'
--
-- 【中文】旧版二元函子（bifunctor），用多参数类 + 函数依赖，而不是关联类型。
--
-- 分层：
--
-- * 'PFunctor'：只动左变元（@first@）；
-- * 'QFunctor'：只动右变元（@second@）；
-- * 'Bifunctor'：两边一起动（@bimap@），且同时是 P/Q。
--
-- @dimap@ / @difirst@ 用于「第一变元反变」：把定义域箭头先包进 'Dual' 再交给 @bimap@/@first@。
-- 当前 @src/Math/Functor.hs@ 用「余定义域是自然变换范畴」重新编码了同一想法。
--
-- 本文件在 @old/@ 下，不在 @categories.cabal@ 的 @hs-source-dirs@ 里，当前库不会编译它。
-- 英文说明保留；这里只加阅读用的中文，不改定义。
-------------------------------------------------------------------------------------------
module Control.Categorical.Bifunctor
    ( PFunctor (first)
    , QFunctor (second)
    , Bifunctor (bimap)
    , dimap
    , difirst
    ) where

import Prelude hiding (id, (.))
import Control.Category
import Control.Category.Dual

-- | 【中文】左变元上的函子：@first f@ 把 @p a c@ 送到 @p b c@，右变元不动。
-- 函数依赖 @p r -> t@、@p t -> r@ 固定「张量 + 左箭头范畴」与「结果箭头范畴」的关系。
class (Category r, Category t) => PFunctor p r t | p r -> t, p t -> r where
    -- | 【中文】只映射左变元。
    first :: r a b -> t (p a c) (p b c)
--    default first :: Bifunctor p r s t => r a b -> t (p a c) (p b c)
--    first f = bimap f id

-- | 【中文】右变元上的函子：@second g@ 把 @q c a@ 送到 @q c b@。
class (Category s, Category t) => QFunctor q s t | q s -> t, q t -> s where
    -- | 【中文】只映射右变元。
    second :: s a b -> t (q c a) (q c b)
--    default second :: Bifunctor q r s t => s a b -> t (q c a) (q c b)
--    second = bimap id

-- | Minimal definition: @bimap@
-- or both @first@ and @second@
--
-- 【中文】二元函子：同时是 'PFunctor' 与 'QFunctor'。
-- 最少实现 @bimap@，或同时给出 @first@ 与 @second@（再令 @bimap f g = second g . first f@）。
-- 应满足 @bimap id id = id@、@bimap (f . g) (h . i) = bimap f h . bimap g i@。
class (PFunctor p r t, QFunctor p s t) => Bifunctor p r s t | p r -> s t, p s -> r t, p t -> r s where
    -- | 【中文】同时映射两个变元。
    bimap :: r a b -> s c d -> t (p a c) (p b d)
    -- bimap f g = second g . first f

-- | 【中文】元组作为 @Hask@ 上的二元函子。
instance PFunctor (,) (->) (->) where first f = bimap f id
instance QFunctor (,) (->) (->) where second = bimap id
instance Bifunctor (,) (->) (->) (->) where
    bimap f g (a,b)= (f a, g b)

-- | 【中文】@Either@ 作为 @Hask@ 上的二元函子。
instance PFunctor Either (->) (->) where first f = bimap f id
instance QFunctor Either (->) (->) where second = bimap id
instance Bifunctor Either (->) (->) (->) where
    bimap f _ (Left a) = Left (f a)
    bimap _ g (Right a) = Right (g a)

-- | 【中文】函数箭头的右变元函子：@second = (.)@（后复合 / 协变 hom）。
instance QFunctor (->) (->) (->) where
    second = (.)

-- | 【中文】第一变元反变时的 @first@：先把箭头包成 'Dual'。
difirst :: PFunctor f (Dual s) t => s b a -> t (f a c) (f b c)
difirst = first . Dual

-- | 【中文】profunctor 风格的 @dimap@：左反变、右协变。
-- @dimap f g = bimap (Dual f) g@。
dimap :: Bifunctor f (Dual s) t u => s b a -> t c d -> u (f a c) (f b d)
dimap = bimap . Dual
