-- types.hs

{-# LANGUAGE DeriveGeneric #-}

module Types where

import Data.Aeson
import Data.Text (Text)
import GHC.Generics (Generic)
import Database.SQLite.Simple

-- Movie related types
data Movie = Movie
    { title :: Text
    } deriving (Show)

-- Define your Movie data structure for DB

