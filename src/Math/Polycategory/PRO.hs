{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}

-- |
-- Module      : Math.Polycategory.PRO
--
-- PRO：对象是类型级列表、并且带有「并排」运算的范畴。
-- 名字来自代数理论里的 PRO（只有一个生成对象的严格幺半范畴；这里列表的元素可以不止一种，所以更接近 colored / 多色的情形）。
-- 'pro' 同时拼接定义域列表和余定义域列表，也就是水平复合，不是把一条箭头的输出接进下一条的输入。
module Math.Polycategory.PRO where

import Math.Category
import Math.Rec
import Data.Type.Equality

-- | @pro f g@ 把两条箭头并排放。@f@ 的两端列表在左边，@g@ 的在右边。
--
-- 应满足的性质（不检查）：对单位箭头尊重拼接，并且与复合可交换
-- （并排再复合 = 各自复合再并排），另外对 @(++)@ 结合。
class Category p => PRO p where
  pro :: p as bs -> p cs ds -> p (as ++ cs) (bs ++ ds)

-- | 对偶范畴仍是 PRO：把 'Op' 剥掉，在原范畴里 'pro'，再包回去。
-- 列表拼接的方向不变，变的只是箭头朝向。前提 @Yoneda p ~ Op p@ 表示 @p@ 还不是对偶载体。
instance (PRO p, Yoneda p ~ Op p) => PRO (Yoneda p) where
  pro (Op p) (Op q) = Op (pro p q)

-- | 命题相等对拼接是同余：两边都是 'Refl' 时，拼出来的列表仍然相等。
instance PRO (:~:) where
  pro Refl Refl = Refl
