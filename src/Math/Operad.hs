{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}

-- |
-- Module      : Math.Operad
--
-- 算子元 (operad)：只有一个对象的多元范畴。对象被钉死为 @'()@，
-- 所以一条箭头 @f n '()@ 只由「有几个输入」决定（输入列表的长度，元素都是 @'()@）。
--
-- 'M' 是它对应的单子：值是「一个运算 + 每个输入位置上的一个元素」。
-- 'W' 是对偶的余单子：手里的是「给定任意运算，都能填好它的输入」。
module Math.Operad where

import Data.Constraint
import Math.Category
import Math.Functor
import Math.Monad
import Math.Monad.Atkey
import Math.Multicategory
import Math.Polycategory.PRO
import Math.Rec
import Prelude (($))

-- | @Mob f ~ ((~) '())@ 表示对象约束就是「必须等于 @'()@」。
-- 多元范畴因此只剩一个对象，这就是单色 operad。类没有新的方法。
class (Multicategory f, Mob f ~ (~) '()) => Operad f
instance (Multicategory f, Mob f ~ (~) '()) => Operad f

-- 英文：与 operad 相伴的单子。
-- 中文：@M f a@ 是运算 @f n '()@ 再加上 @n@ 个 @a@（每个都包在 'At' 里，索引只能是 @'()@）。
-- 读作一棵扁平的运算树：根是这个运算，叶子是 @a@ 的值。
-- the monad associated with an operad
data M (f :: [()] -> () -> *) (a :: *) where
  M :: f n '() -> Rec (At a '()) n -> M f a

--instance Functor M where
--  type Dom M = Nat (:~:) (Nat (:~:) (:~:))
--  type Cod M = Nat (->) (->)

-- | 函数推进每个叶子。'fmap' 两次 'runNat' 是因为 'At' 的最外层函子实例要穿过两层 @(:~:)@。
instance Functor (M f) where
  type Dom (M f) = (->)
  type Cod (M f) = (->)
  fmap f (M s d) = M s (mapRec (runNat (runNat (fmap f))) d)

-- | operad 单子。'return' 是恒等运算配一个叶子。
--
-- 'bind' 做替换：对根运算的每个叶子调用 @f@，各自得到一棵新的 @M@，
-- 再用 'compose' 把这些新运算插进原来的根，叶子记录用 'appendRec' 接成一条。
-- 局部函数 'go' 按叶子列表递归，先处理尾部，再把当前叶子展开接到森林左边。
instance Operad f => Monad (M f) where
  return a = M ident (At a :& RNil)
  bind (f :: a -> M f b) (M s0 d0) = go d0 $ \ as ds -> M (compose s0 as) ds where
    go :: Rec (At a '()) is -> (forall os. Forest f os is -> Rec (At b '()) os -> r) -> r
    go RNil k = k Nil RNil
    go (At a :& is) k = go is $ \fs as -> case f a of
      M s bs -> k (s :- fs) (appendRec bs as)

-- | 与 operad 相伴的余单子。@runW@ 的类型是：无论给出哪个运算 @f is '()@，
-- 都能交回填满其输入的一条记录。'Coat' 表示这些叶子只有在索引为 @'()@ 时才取得出值。
-- 直觉上，'W' 是「对一切运算都有填法」的环境，而不是某一棵具体的树。
-- | The comonad associated with an operad
newtype W (f :: [()] -> () -> *) (a :: *) = W { runW :: forall is. f is '() -> Rec (Coat a '()) is }

-- | 函数推进 'W' 能填出来的每一个叶子，不改变「哪个运算用哪种填法」的选择。
instance Functor (W f) where
  type Dom (W f) = (->)
  type Cod (W f) = (->)
  fmap f (W g) = W (mapRec (\(Coat a) -> Coat (f a)) . g)

-- | 'extract' 只问恒等运算（恰好一个输入）的填法，取出那唯一的叶子。
--
-- 'extend' 比较绕，对应余单子的 co-Kleisli 扩张：给定「怎样从一整份 'W' 算出一个 @b@」，
-- 要对任意运算 @s@ 的每个输入位置各算出一个 @b@。
-- 对第某个位置，先用恒等运算把它左右的输入补齐（'idents'），再把子运算插进 @s@（'compose' / 'pro'），
-- 用原来的 'W' 填这棵更大的树，最后 'prune' 只留下属于这个子运算的那一段叶子。
-- 'shift' 用列表拼接的结合律把「已经处理过的前缀」在类型上挪到位。
-- 这些辅助函数都关在 'extend' 里面，没有改动算法。
instance Operad f => Comonad (W f) where
  extract (W f) = case f ident of
    Coat a :& RNil -> a
  extend (f :: W f a -> b) (w :: W f a) = W $ \s -> go RNil (sources s) s where
    go :: forall (ls :: [()]) (rs :: [()]). Rec (Dict1 (Mob f)) ls -> Rec (Dict1 (Mob f)) rs -> f (ls ++ rs) '() -> Rec (Coat b '()) rs
    go _ RNil _ = RNil
    go ls0 (p :& rs0) s = g :& go (appendRec ls0 (p :& RNil)) rs0 (shift s)
      where
        g = Coat $ f $ W $ \s' ->
          prune ls0 (sources s') rs0 (runW w (compose s (pro (idents ls0) (s' :- idents rs0))))
        prune ls is rs = takeRec is rs . dropRec ls
        shift s' = case appendAssocAxiom ls0 (p :& RNil) rs0 of Dict -> s'
        idents :: Rec (Dict1 (Mob f)) as -> Forest f as as
        idents p' = case reproof p' of Dict -> id
