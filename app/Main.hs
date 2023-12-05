module Main where

import Database.SQLite.Simple (Connection)
import qualified Database as DB
import qualified Parse as P
import qualified Fetch as F
import Data.Text (Text, pack)

convertToDBMovie :: P.ParsedMovieDB -> DB.ParsedMovieDB
convertToDBMovie pMovie = DB.ParsedMovieDB
    { P.id = P.id pMovie,
      P.title = P.title pMovie,
      P.year = P.year pMovie,
      P.rating = P.rating pMovie,
      P.genre = P.genre pMovie,
      P.description = P.description pMovie,
      P.rank = P.rank pMovie
    }

main :: IO ()
main = do
    maybeResponse <- F.fetchData

    case maybeResponse of
        Nothing -> putStrLn "Failed to fetch data or movie not found."
        Just response -> do
            putStrLn "Data fetched!"
            let movieDetails = P.parseMovieDetails response
                moviesDB = zipWith (\details rank -> details { P.rank = rank }) movieDetails [1..]

            DB.withConn "movies3.db" $ \conn -> do
                DB.createTable conn
                putStrLn "created tab"

                -- Convert P.ParsedMovieDB to DB.ParsedMovieDB
                let dbMoviesDB = map convertToDBMovie moviesDB

                -- Insert converted movies into the database
                mapM_ (DB.insertMovie conn) dbMoviesDB
                putStrLn "Inserted"




                putStrLn "Enter a movie/series title to retrieve details:"
                searchTitle <- getLine
                retrievedMovies <- DB.getMoviesByTitle conn (pack searchTitle)
                print retrievedMovies
