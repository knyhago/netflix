{-# LANGUAGE OverloadedStrings #-}

module Main where

import Database.SQLite.Simple (Connection, open, close)
import Database (MovieDB(..), withConn, createTable, insertMovie, getMoviesByTitle)
import Fetch (fetchData)
import Parse (parseMovieTitles)
import Data.Text (Text, pack)

main :: IO ()
main = do
    putStrLn "Enter a movie/series name:"
    userInput <- getLine

    maybeResponse <- fetchData userInput
    print maybeResponse -- Add this line to print the response
    case maybeResponse of
        Nothing -> putStrLn "Failed to fetch data or movie not found."
        Just response -> do
            putStrLn "Data fetched!"
            let movieTitles = parseMovieTitles response
            mapM_ print movieTitles

            -- Storing the data in the database
            withConn "movies2.db" $ \conn -> do
                createTable conn
                let movies2 = zipWith (\title rank -> MovieDB { movieId = 0, title = title, rank = rank }) movieTitles [1..]
                mapM_ (insertMovie conn) movies2

            -- Ask the user for a title to retrieve from the database
            putStrLn "Enter a movie/series title to retrieve details:"
            searchTitle <- getLine
            retrievedMovies <- withConn "movies2.db" $ \conn -> getMoviesByTitle conn (pack searchTitle)
            print retrievedMovies
