{-# LANGUAGE NamedFieldPuns #-}
module Physics.ForceNR
  ( forceNR        -- :: Force -> [(Component,Double)] -> NumericRule
  ) where

import Physics.Force    (Force(..))
import NState           (NState, lookupPos, lookupMom, insertMom)
import NumericRule      (NumericRule(..))
import Components       (Component)
import qualified Data.Set        as S
import qualified Data.Map.Strict as M

-- | Build a NumericRule that applies a 1-D force to each body,
--   updating pᵢ ← pᵢ + dt·Fᵢ, where Fᵢ is the x-component of the net force.
forceNR
  :: Force                -- ^ force field
  -> [(Component,Double)] -- ^ list of (body, mass in kg)
  -> NumericRule
forceNR f masses =
  let domain = S.fromList (map fst masses)
      mMap   = M.fromList masses

      step dt st0 = foldr update st0 masses
        where
          update (c,m) acc =
            let p0 = lookupMom c acc
                fx = case f of
                  Custom ff ->
                    let (fx',_,_) = ff acc c
                    in fx'

                  Drag γ    ->
                    let v = p0 / m
                    in - γ * v

                  Spring i j k rest ->
                    let xi   = lookupPos i acc
                        xj   = lookupPos j acc
                        dx   = xj - xi
                        disp = dx - signum dx * rest
                    in if c == i then  k * disp
                       else if c == j then -k * disp
                       else 0

                  Gravity g ->
                    let mi   = mMap M.! c
                        qi   = lookupPos c acc
                        fsum = sum
                          [ let mj = mMap M.! cj
                                qj = lookupPos cj acc
                                d  = qj - qi
                            in g * mi * mj * signum d / (abs d ** 2)
                          | (cj,_) <- masses, cj /= c
                          ]
                    in fsum

                p' = p0 + dt * fx
            in insertMom c p' acc

  in NumericRule { nrDomain = domain, nrStep = step }
