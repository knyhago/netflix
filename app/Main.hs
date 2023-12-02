import Data.Text (Text, unpack)
import qualified Data.Text as T
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

            putStrLn "Choose an operation:"
            putStrLn "1. Insert movies into the database"
            putStrLn "2. Fetch movies from the database"
            putStrLn "3. Exit"

            choice <- getLine
            case choice of
                "1" -> do
                    putStrLn "Inserting movies into the database..."
                    -- Logic to insert movies into the database
                    putStrLn "Fetching movies from the database..."
                    putStrLn "Connecting to the database..."
                    withConn "movies.db" $ \conn -> do
                        putStrLn "Inserting movies into the database..."
                        let movies = [ MovieDB 1 (T.pack "Movie Title") 2023 ] -- Replace with actual movie data
                        mapM_ (\movie -> insertMovie conn movie) movies

                "2" -> do
                    putStrLn "Fetching movies from the database..."
                    putStrLn "Connecting to the database..."
                    withConn "movies.db" $ \conn -> do
                    
                    -- Logic to fetch movies from the database
                        putStrLn "Fetching movies from the database..."
                        storedMovies <- getMovies conn
                        print storedMovies
                "3" -> putStrLn "Exiting."
                _ -> putStrLn "Invalid choice. Please choose again."

-- Function to convert Text to String
unpackText :: Text -> String
unpackText = T.unpack
