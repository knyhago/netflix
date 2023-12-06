-- types.hs

{-# LANGUAGE DeriveGeneric #-}

module Types where

import Data.Aeson
import Data.Text (Text)
import GHC.Generics (Generic)
import Database.SQLite.Simple

data ParsedMovieDB = ParsedMovieDB
    { id :: Text,
      title :: Text,
      year :: Int,
      rating :: Text,
      genre :: [Text],
      description :: Text,
      rank :: Int
    } deriving Show

-- Movie related types
--data Movie = Movie
  --  { title :: Text
    --} deriving (Show)
