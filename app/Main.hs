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
            print response  -- Print the fetched response
            let movieDetails = P.parseMovieDetails response
                moviesDB = zipWith (\details rank -> details { P.rank = rank }) movieDetails [1..]

            DB.withConn "movies4.db" $ \conn -> do
                DB.createTable conn
                putStrLn "created tab"

                let dbMoviesDB = map convertToDBMovie moviesDB
                mapM_ (DB.insertMovie conn) dbMoviesDB
                putStrLn "Inserted"

                putStrLn "Enter a movie/series title to retrieve details:"
                searchTitle <- getLine
                retrievedMovies <- DB.getMoviesByTitle conn (pack searchTitle)
                print retrievedMovies
                

