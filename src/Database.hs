{-# LANGUAGE OverloadedStrings #-}

module Database
    ( MovieDB(..)
    , withConn
    , createTable
    , insertMovie
    , getMovies
    ) where

import Database.SQLite.Simple
import Data.Text (Text)
--import Types

data MovieDB = MovieDB
    { movieId :: Int,
      title :: Text,
      rank :: Int
    } deriving (Show)    



instance FromRow MovieDB where
    fromRow = MovieDB <$> field <*> field <*> field

instance ToRow MovieDB where
    toRow (MovieDB movieId' title' rank') = toRow (movieId', title', rank')

-- Function to connect to the database
withConn :: String -> (Connection -> IO a) -> IO a
withConn dbName action = do
    conn <- open dbName
    r <- action conn
    close conn
    pure r

-- Function to create a table
createTable :: Connection -> IO ()
createTable conn =
    execute_ conn "CREATE TABLE IF NOT EXISTS movies (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, rank INTEGER)"

-- Function to insert a movie into the database
insertMovie :: Connection -> MovieDB -> IO ()
insertMovie conn movie =
    execute conn "INSERT INTO movies (title, rank) VALUES (?, ?)" (title movie, rank movie)

-- Function to retrieve all movies from the database
getMovies :: Connection -> IO [MovieDB]
getMovies conn =
    query_ conn "SELECT * FROM movies"
