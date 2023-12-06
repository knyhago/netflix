{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Database as DB
import qualified Fetch as F
import qualified Parse as P
import Data.Text (Text)
import Data.String (fromString)
import Data.Text (unpack, pack)
import Data.List (intercalate)


displayMovie :: DB.ParsedMovieDB -> IO ()
displayMovie movie = do
    putStrLn "--------------------------------------"
    putStrLn $ "Title: " ++ unpack (DB.title movie)
    putStrLn $ "Year: " ++ show (DB.year movie)
    putStrLn $ "Rating: " ++ unpack (DB.rating movie)
    putStrLn $ "Genres: " ++ unpackGenres (DB.genre movie)
    putStrLn $ "Description: " ++ unpack (DB.description movie)
    putStrLn $ "Rank: " ++ show (DB.rank movie)
    putStrLn "--------------------------------------"

-- Helper function to unpack a list of Text into a comma-separated String
unpackGenres :: [Text] -> String
unpackGenres = intercalate ", " . map unpack

main :: IO ()
main = do
    maybeResponse <- F.fetchData

    case maybeResponse of
        Nothing -> putStrLn "Failed to fetch data or movie not found."
        Just response -> do
            putStrLn "Data fetched!"
            --print response  -- Print the fetched response
            let movieDetails = P.parseMovieDetails response
                moviesDB = zipWith (\details rank -> details { P.rank = rank }) movieDetails [1..]

            DB.withConn "movies4.db" $ \conn -> do
                DB.createTable conn
                putStrLn "created tab"

                let dbMoviesDB = map P.convertToDBMovie moviesDB
                mapM_ (DB.insertMovie conn) dbMoviesDB
                putStrLn "Inserted"

                putStrLn "Enter a movie/series title to retrieve details:"
                searchTitle <- getLine
                retrievedMovies <- DB.getMoviesByTitle conn (fromString searchTitle)
                mapM_ displayMovie retrievedMovies
