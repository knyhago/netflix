module Main where

import Data.Text (Text, unpack)  -- Import Text and unpack function from Data.Text
import qualified Data.Text as T  -- Qualified import for Text

import Fetch (fetchData)
import Parse (parseMovieTitles)
import Database

main :: IO ()
main = do
    putStrLn "Fetching data from IMDb Top 100 Movies API..."
    maybeResponse <- fetchData
    case maybeResponse of
        Nothing -> putStrLn "Failed to fetch data."
        Just response -> do
            putStrLn "Data fetched!"
            
            putStrLn "Parsing movie titles..."
            let movieTitles = parseMovieTitles response
            putStrLn "Parsed Movie Titles:"
            mapM_ (putStrLn . unpackText) movieTitles
            
            putStrLn "Connecting to the database..."
            withConn "movies.db" $ \conn -> do
                putStrLn "Creating the 'movies' table..."
                createTable conn

                putStrLn "Inserting movies into the database..."
                let movies = [ MovieDB 1 (T.pack "Movie Title") 2023 ] -- Replace with actual movie data
                mapM_ (\movie -> insertMovie conn movie) movies

                putStrLn "Fetching movies from the database..."
                storedMovies <- getMovies conn
                print storedMovies

-- Function to convert Text to String
unpackText :: Text -> String
unpackText = T.unpack
