{-# LANGUAGE CPP #-}
#if defined(__GLASGOW_HASKELL__) && __GLASGOW_HASKELL__ >= 702
{-# LANGUAGE Trustworthy #-}
#endif
{-# LANGUAGE MultiParamTypeClasses #-}
-------------------------------------------------------------------------------------------
-- |
-- Module    : Control.Category.Associative
-- Copyright : 2008 Edward Kmett
-- License   : BSD
--
-- Maintainer  : Edward Kmett <ekmett@gmail.com>
-- Stability   : experimental
-- Portability : portable
--
-- NB: this contradicts another common meaning for an 'Associative' 'Category', which is one
-- where the pentagonal condition does not hold, but for which there is an identity.
--
--
-- 【中文】结合的二元函子（associator）：在范畴 @k@ 上的二元自函子 @p@ 配备
-- @associate@ / @disassociate@，用来「重新加括号」：
--
-- @
-- associate    ::  p (p a b) c  →  p a (p b c)
-- disassociate ::  p a (p b c)  →  p (p a b) c
-- @
--
-- 它们应互为逆，并满足 Mac Lane 五边形连贯条件（pentagon coherence）：
-- 用结合子把五重积的括号从一种全左结合搬到全右结合，两条路径必须相等。
--
-- 文件头英文提醒：另有一种「Associative」用法是「有单位但不要求五边形」——
-- 与本模块不是一回事。
--
-- 本文件在 @old/@ 下，不在 @categories.cabal@ 的 @hs-source-dirs@ 里，当前库不会编译它。
-- 英文说明保留；这里只加阅读用的中文，不改定义。
-------------------------------------------------------------------------------------------
module Control.Category.Associative
    ( Associative(..)
    ) where

import Control.Categorical.Bifunctor

{- | A category with an associative bifunctor satisfying Mac Lane\'s pentagonal coherence identity law:

> bimap id associate . associate . bimap associate id = associate . associate
> bimap disassociate id . disassociate . bimap id disassociate = disassociate . disassociate

【中文】结合结构：超类要求 @p@ 是 @k@ 上的 'Bifunctor'。
五边形的一条典型写法（与上面英文 RULE 同向）：

@
second associate . associate . first associate  =  associate . associate
@

意图：括号怎么加不该影响「可观察」的结果；Mac Lane 连贯性定理保证
更高元的括号重排也都由这对同构决定。
-}
class Bifunctor p k k k => Associative k p where
    -- | 【中文】结合子 α：把 @(a ⊗ b) ⊗ c@ 送到 @a ⊗ (b ⊗ c)@。
    associate :: k (p (p a b) c) (p a (p b c))
    -- | 【中文】结合子的逆 α⁻¹：把 @a ⊗ (b ⊗ c)@ 送回 @(a ⊗ b) ⊗ c@。
    disassociate :: k (p a (p b c)) (p (p a b) c)

{-- RULES
"copentagonal coherence" first disassociate . disassociate . second disassociate = disassociate . disassociate
"pentagonal coherence"   second associate . associate . first associate = associate . associate
 --}

-- | 【中文】笛卡尔积 @(,)@ 在 @Hask@ 上的结合：嵌套元组换括号。
instance Associative (->) (,) where
        associate ((a,b),c) = (a,(b,c))
        disassociate (a,(b,c)) = ((a,b),c)

-- | 【中文】余积 @Either@ 在 @Hask@ 上的结合：三层标签重新归类到右结合树。
instance Associative (->) Either where
        associate (Left (Left a)) = Left a
        associate (Left (Right b)) = Right (Left b)
        associate (Right c) = Right (Right c)
        disassociate (Left a) = Left (Left a)
        disassociate (Right (Left b)) = Left (Right b)
        disassociate (Right (Right c)) = Right c
