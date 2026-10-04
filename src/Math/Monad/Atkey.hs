{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE PolyKinds #-}

-- |
-- Module      : Math.Monad.Atkey
--
-- Atkey 风格的索引值：一份数据只在两个索引相等时存在。
-- 'At' 用 GADT 把相等写进构造子，'Coat' 用约束 @i ~ j@ 写在字段上，两者对偶。
-- 'Atkey' / 'Coatkey' 是把它们套进另一个构造子 @m@ 之后的简写，方便写索引单子。
module Math.Monad.Atkey 
  ( At(..)
  , Atkey
  , Coat(..)
  , Coatkey
  ) where

import Data.Type.Equality
import Math.Category
import Math.Functor
import Prelude (($))

-- | @At a i j@ 只有在 @i@ 与 @j@ 是同一个索引时才能造出来（构造子 @At :: a -> At a i i@）。
-- 可以把它读成「标了索引 @i@ 的一个 @a@」，类型上不存在索引对不上的值。
data At a i j where
  At :: a -> At a i i

-- | 固定外层索引后，@At a i@ 是 @(:~:)@ 到 @(->)@ 的函子。
-- 定义域里只有 'Refl'，所以 @fmap@ 只能是恒等，值完全不动。
instance Functor (At a i) where
  type Dom (At a i) = (:~:)
  type Cod (At a i) = (->)
  fmap Refl a = a

-- | 再放开一个索引：@At a@ 把相等证明送到「以相等为对象、函数为箭头」的自然变换。
-- 'Refl' 对应的自然变换分量是 'id'。
instance Functor (At a) where
  type Dom (At a) = (:~:)
  type Cod (At a) = Nat (:~:) (->)
  fmap Refl = Nat id

-- | 最外层：普通函数作用在 'At' 里面的值上，两层 'Nat' 对应两层索引范畴 @(:~:)@。
instance Functor At where
  type Dom At = (->)
  type Cod At = Nat (:~:) (Nat (:~:) (->))
  fmap f = Nat $ Nat $ \(At a) -> At (f a)

-- | 索引单子里常见的简写：@m@ 的「在索引 @i@ 处、键为 @j@ 的 @a@」。
-- @At a j@ 先把值钉在键 @j@ 上，再交给 @m@ 的外层索引 @i@。本模块不再给 @m@ 写单子实例。
type Atkey m i j a = m (At a j) i

-- | 'At' 的余变体。字段的类型是 @(i ~ j) => a@：构造时可以先不给相等证明，
-- 但 'runCoat' 取出来的时候，调用点必须已经知道 @i@ 与 @j@ 相等。
newtype Coat a i j = Coat { runCoat :: (i ~ j) => a }

-- | 与 @At a i@ 相同的角色：沿 'Refl' 映射时值不变。
instance Functor (Coat a i) where
  type Dom (Coat a i) = (:~:)
  type Cod (Coat a i) = (->)
  fmap Refl a = a

-- | 固定载荷 @a@ 后，'Coat' 沿相等证明仍然是恒等自然变换。
instance Functor (Coat a) where
  type Dom (Coat a) = (:~:)
  type Cod (Coat a) = Nat (:~:) (->)
  fmap Refl = Nat id

-- | 函数推进 'Coat' 里的值。取出时要用 'runCoat'，因此这一步要求索引已经相等。
instance Functor Coat where
  type Dom Coat = (->)
  type Cod Coat = Nat (:~:) (Nat (:~:) (->))
  fmap f = Nat $ Nat $ \ g -> Coat (f (runCoat g))

-- | 'Atkey' 的余版本：@m (Coat a j) i@。适合「上下文在索引上、取值时才对索引」的写法。
type Coatkey m i j a = m (Coat a j) i
