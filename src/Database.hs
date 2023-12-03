{-# LANGUAGE OverloadedStrings #-}

module Database
    ( MovieDB(..)
    , withConn
    , createTable
    , insertMovie
    , getAllMovies
    , getMoviesByTitle
    ) where

import Database.SQLite.Simple
import Database.SQLite.Simple.FromRow (FromRow(..))
import Data.Text (Text)

data MovieDB = MovieDB
    { movieId :: Int,
      title :: Text,
      rank :: Int
    } deriving (Show)

instance FromRow MovieDB where
    fromRow = MovieDB <$> field <*> field <*> field

withConn :: String -> (Connection -> IO a) -> IO a
withConn dbName action = do
    conn <- open dbName
    r <- action conn
    close conn
    pure r

createTable :: Connection -> IO ()
createTable conn = execute_ conn "CREATE TABLE IF NOT EXISTS movies3 (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT UNIQUE, rank INTEGER)"


insertMovie :: Connection -> MovieDB -> IO ()
insertMovie conn movie =
    execute conn insertQuery (title movie, rank movie)
  where
    insertQuery :: Query
    insertQuery = "INSERT OR IGNORE INTO movies3 (title, rank) VALUES (?, ?)"


getMoviesByTitle :: Connection -> Text -> IO [MovieDB]
getMoviesByTitle conn searchTitle =
    query conn selectQuery (Only searchTitle)
  where
    selectQuery :: Query
    selectQuery = "SELECT * FROM movies3 WHERE title = ?"

getAllMovies :: Connection -> IO [MovieDB]
getAllMovies conn  =
    query_ conn selectQuery
  where
    selectQuery :: Query
    selectQuery = "SELECT * FROM movies3"
