{-# LANGUAGE OverloadedStrings #-}

module Database
    ( ParsedMovieDB(..)
    , withConn
    , createTable
    , insertMovie
    , getAllMovies
    , getMoviesByTitle
    , toTextListField
    ) where

import Database.SQLite.Simple
import Database.SQLite.Simple.FromRow
import Data.Text (Text, intercalate, strip, splitOn)
import Types
import Data.String (fromString)

instance FromRow ParsedMovieDB where
    fromRow = ParsedMovieDB <$> field <*> field <*> field <*> field <*> (splitGenre <$> field) <*> field <*> field
      where
        splitGenre = map strip . splitOn ","
        
toTextListField :: [Text] -> SQLData
toTextListField texts = SQLText $ stripQuotes $ intercalate ", " texts
  where
    stripQuotes = strip . Data.Text.strip


withConn :: String -> (Connection -> IO a) -> IO a
withConn dbName action = do
    conn <- open dbName
    r <- action conn
    close conn
    pure r

createTable :: Connection -> IO ()
createTable conn =
    execute_ conn "CREATE TABLE IF NOT EXISTS movies3 ( title TEXT UNIQUE, year INTEGER, rating TEXT, genre TEXT, description TEXT, rank INTEGER)"

insertMovie :: Connection -> ParsedMovieDB -> IO ()
insertMovie conn movie =
    execute conn insertQuery (title movie, year movie, rating movie, toTextListField (genre movie), description movie, rank movie)
  where
    insertQuery :: Query
    insertQuery = "INSERT OR IGNORE INTO movies3 (id,title, year, rating, genre, description, rank) VALUES (?, ?, ?, ?, ?, ?,?)"

getMoviesByTitle :: Connection -> Text -> IO [ParsedMovieDB]
getMoviesByTitle conn searchTitle = do
    let wildcardedSearch = "%" <> searchTitle <> "%"
    query conn selectQuery (Only wildcardedSearch)
  where
    selectQuery :: Query
    selectQuery = "SELECT * FROM movies3 WHERE title LIKE ?"

getAllMovies :: Connection -> IO [ParsedMovieDB]
getAllMovies conn =
    query_ conn "SELECT * FROM movies3"
