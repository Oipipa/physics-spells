{-# LANGUAGE Safe #-}


module Physics.Math.Vec3Util
  ( Vec3        -- re-export
  , vzero
  , vadd, (<+>)
  , vsub, (<->)
  , vscale
  , vdot
  , vnorm2
  , vnorm
  , vhat
  , approxEqVec
  ) where

import           Physics.LeapfrogNR (Vec3)

--------------------------------------------------------------------------------
--  Basic operations -----------------------------------------------------------

vzero :: Vec3
vzero = (0,0,0)

vadd, vsub :: Vec3 -> Vec3 -> Vec3
vadd (ax,ay,az) (bx,by,bz) = (ax+bx, ay+by, az+bz)
vsub (ax,ay,az) (bx,by,bz) = (ax-bx, ay-by, az-bz)

infixl 6 <+>, <->
(<+>) :: Vec3 -> Vec3 -> Vec3
(<+>) = vadd
(<->) :: Vec3 -> Vec3 -> Vec3
(<->) = vsub

vscale :: Double -> Vec3 -> Vec3
vscale k (x,y,z) = (k*x, k*y, k*z)

vdot :: Vec3 -> Vec3 -> Double
vdot (ax,ay,az) (bx,by,bz) = ax*bx + ay*by + az*bz

--------------------------------------------------------------------------------
--  Derived helpers ------------------------------------------------------------

vnorm2 :: Vec3 -> Double
vnorm2 v = vdot v v

vnorm :: Vec3 -> Double
vnorm = sqrt . vnorm2

-- | Unit vector (returns @vzero@ for the zero vector).
vhat :: Vec3 -> Vec3
vhat v =
  let n = vnorm v
  in if n < 1e-12 then vzero else vscale (1/n) v

-- | Approximate equality with absolute tolerance @ε@ = 1e-9 for each component.
approxEqVec :: Vec3 -> Vec3 -> Bool
approxEqVec (ax,ay,az) (bx,by,bz) =
  let ε = 1e-9
  in  abs (ax - bx) < ε
   && abs (ay - by) < ε
   && abs (az - bz) < ε
