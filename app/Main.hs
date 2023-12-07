{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Database as DB
import qualified Fetch as F
import qualified Parse as P
import Data.Text (Text)
import Data.String (fromString)
import Data.Text (unpack, pack)
import Data.List (intercalate)
import Control.Monad (unless)

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
    putStrLn("\nWELCOME TO JMBD\n")
    maybeResponse <- F.fetchData

    case maybeResponse of
        Nothing -> putStrLn "Failed to fetch data or movie not found."
        Just response -> do
            --putStrLn "Data fetched!"
            let movieDetails = P.parseMovieDetails response
                moviesDB = zipWith (\details rank -> details { P.rank = rank }) movieDetails [1..]

            DB.withConn "movies4.db" $ \conn -> do
                DB.createTable conn
                --putStrLn "Created table"
                let dbMoviesDB = map P.convertToDBMovie moviesDB
                mapM_ (DB.insertMovie conn) dbMoviesDB
                --putStrLn "Inserted"

                let loop = do
                        putStrLn "Enter Choices\n-----------------\n1.Search for a movie\n2.Exit:"
                        choice <- getLine
                        case choice of
                            "1" -> do
                                putStrLn "Enter a movie/series title to retrieve details (or type 'quit' to exit):"
                                searchTitle <- getLine
                                unless (searchTitle == "quit") $ do
                                    retrievedMovies <- DB.getMoviesByTitle conn (fromString searchTitle)
                                    if null retrievedMovies
                                        then putStrLn "Movie not found. Try another title."
                                        else mapM_ displayMovie retrievedMovies
                                    loop  -- Recursive call to continue the loop
                            "2" -> putStrLn "Exiting program. Goodbye!"
                            _   -> do
                                putStrLn "Invalid choice. Please enter 1 to search or 2 to exit."
                                loop  -- Retry loop for invalid input

                loop  -- Start the loop initially
