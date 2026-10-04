{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

-- |
-- Module      : Math.Monad
--
-- 范畴里的单子 (monad) 与余单子 (comonad)。它们都是自函子：'Cod' 与 'Dom' 是同一个范畴，
-- 所以 @return@、@join@ 本身是这个范畴里的箭头，而不一定是 Haskell 函数。
-- 特化到 @(->)@ 时就回到 "Control.Monad" 里熟悉的列表、'Maybe'、'Either'、读写器。
module Math.Monad
  ( Monad(..)
  , Comonad(..)
  ) where

import Data.Constraint
import Math.Category
import Math.Functor
import qualified Control.Monad as Base
import qualified Prelude

-- | 自函子上的单子。最少要写 'return'，再加 'join' 或 'bind' 里的一个（见 MINIMAL）。
--
-- * 'return'：对象 @a@ 进到 @f a@，单位。
-- * 'join'：@f (f a)@ 压扁成 @f a@，乘法。
-- * 'bind'：Kleisli 复合的一层。默认 @bind f = join . fmap f@；
--   反过来默认的 'join' 是 @bind id@，但 @id@ 需要「@f a@ 是对象」的证据，所以用了 'ob' 和 @(\\)@。
--
-- 法则即通常的单子三元组：'join' 结合，'return' 是 'join' 的左右单位。
-- @bind@ 与 @return@ 的 Kleisli 写法等价，这里不重复展开。
class (Functor f, Cod f ~ Dom f) => Monad f where
  {-# MINIMAL return, (join | bind) #-}
  return :: Ob (Dom f) a => Dom f a (f a)
  join :: forall a. Ob (Dom f) a => Dom f (f (f a)) (f a)
  join = bind (id \\ (ob :: Ob (Dom f) a :- Ob (Cod f) (f a)))
  bind :: Ob (Dom f) b => Dom f a (f b) -> Dom f (f a) (f b)
  bind f = join . fmap f

-- | 列表单子，'return' / 'join' 用 base 里的实现。
instance Monad [] where
  return = Base.return
  join = Base.join

-- | 'Maybe' 单子。失败（'Nothing'）在 'join' 时被压扁，不会多包一层。
instance Monad Prelude.Maybe where
  return = Base.return
  join = Base.join

-- | 'Either' 的错误短路上的单子（右偏）。'Left' 里的错误在 'join' 时保持错误，不继续计算。
instance Monad (Prelude.Either a) where
  return = Base.return
  join = Base.join

-- | 读写器单子 @(->) e@，也叫环境单子：'return' 忽略环境，'join' 把环境 @e@ 复制给两层函数。
instance Monad ((->) e) where
  return = Base.return
  join = Base.join

-- | 余单子，箭头方向与 'Monad' 相反。最少要写 'extract'，再加 'duplicate' 或 'extend'。
--
-- * 'extract'：从 @f a@ 取出 @a@（单子 'return' 的对偶）。
-- * 'duplicate'：@f a@ 变成 @f (f a)@，把「上下文」复制一份。
-- * 'extend'：默认 @fmap f . duplicate@；'duplicate' 的默认是 @extend id@。
--
-- 法则是余单子三元组：'duplicate' 余结合，'extract' 是左右余单位。
class (Functor f, Cod f ~ Dom f) => Comonad f where
  {-# MINIMAL extract, (duplicate | extend) #-}
  extract :: Ob (Dom f) a => Dom f (f a) a
  duplicate :: forall a. Ob (Dom f) a => Dom f (f a) (f (f a))
  duplicate = extend (id \\ (ob :: Ob (Dom f) a :- Ob (Cod f) (f a)))
  extend :: Ob (Dom f) a => Dom f (f a) b -> Dom f (f a) (f b)
  extend f = fmap f . duplicate

-- | 环境余单子 @(,) e@：第一分量是环境。'extract' 丢掉环境只留值；
-- 'duplicate' 把同一份环境套到外层，内层仍是原来的一对；
-- 'extend' 用整对 @(e, a)@ 算出新值，环境原样留在外面。
instance Comonad ((,) e) where
  extract (_, a) = a
  duplicate ea@(e, _) = (e, ea)
  extend f ea@(e, _) = (e, f ea)
