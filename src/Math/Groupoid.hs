{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeFamilies #-}

-- |
-- Module      : Math.Groupoid
--
-- 群胚 (groupoid)：每条箭头都有逆的范畴。相等证明 @(:~:)@、'Coercion' 都应当是群胚
-- （逆还是 'Refl' / 同一条 coercion），不过本文件只写了与对偶范畴相关的实例。
module Math.Groupoid where

import Math.Category

-- | 在 'Category' 之上加逆箭头 'inv' :: @p a b -> p b a@。
--
-- 法则（不检查）：@inv (inv f) = f@，@inv id = id@，以及 @inv (f . g) = inv g . inv f@。
class Category p => Groupoid p where
  inv :: p a b -> p b a

-- | 对偶范畴的逆就是原范畴逆箭头再翻一次方向：两边各有一个 'Op'。
-- 前提同样是 @p@ 还没有被包进 'Yoneda'。
instance (Groupoid p, Op p ~ Yoneda p) => Groupoid (Yoneda p) where
  inv (Op f) = Op (inv f)
