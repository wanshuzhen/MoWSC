module Heuristic.Cheap (cheap) where

import Problem
import Heuristic

import Data.Vector (Vector, (//))
import qualified Data.Vector as Vec
import Data.List (sortBy)
import Data.Ord (comparing)


data CPartial pl = CPar { _pool::pl --Pool
                          -- State information
                        , _lastFT::Double -- A metric for decision
                        , _lastC::Double
                        , _finishTimes::Vector Time
                        , _locations::Vector Ins}

instance PartialSchedule CPartial where
  locations = _locations
  finishTimes = _finishTimes
  pool = _pool

  sortSchedule _ ss = sortBy (comparing $ \x->(_lastC x, _lastFT x)) $ ss

  putTask p s t i = s { _pool = pl'
                      , _lastFT = ft
                      , _lastC = cost pl' i - cost pl i
                      , _finishTimes = _finishTimes s // [(t, ft)]
                      , _locations = _locations s // [(t, i)]}
          where (_, ft, pl, pl') = allocIns p s t i


empty::Pool pl=>Problem->CPartial pl
empty p = CPar (prepare p) 0 0
          (Vec.replicate (nTask p) 0) (Vec.replicate (nTask p) 0)

cheap::Problem->Schedule
cheap p = head . schedule p 1 $ (empty p ::CPartial InfinityPool)