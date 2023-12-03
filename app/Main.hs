import Data.Text (Text, unpack)
import qualified Data.Text as T
import Fetch (fetchData)
import Parse (parseMovieTitles)
import Database

import Data.Text (Text, unpack)
import qualified Data.Text as T
import Database
import Fetch (fetchData)
import Parse (parseMovieDetails)

main :: IO ()
main = do
    putStrLn "Enter a movie/series name:"
    userInput <- getLine

    maybeResponse <- fetchData userInput
    case maybeResponse of
        Nothing -> putStrLn "Failed to fetch data or movie not found."
        Just response -> do
            putStrLn "Data fetched!"
            let movieDetails = parseMovieDetails response
            putStrLn "Movie/series details:"
            print movieDetails

-- Function to convert Text to String
unpackText :: Text -> String
unpackText = T.unpack
