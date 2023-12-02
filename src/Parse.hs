{-# LANGUAGE OverloadedStrings #-}

module Parse (parseMovieTitles) where

import Data.Aeson
import Data.Text (Text)
import Types



instance FromJSON Movie where
    parseJSON = withObject "Movie" $ \v -> Movie
        <$> v .: "title" -- Adjust this to match the actual field name in the JSON

-- Function to parse the response body into a list of movie titles
parseMovieTitles :: Value -> [Text]
parseMovieTitles json =
    case fromJSON json of
        Success movies -> map title movies
        Error err -> error $ "Failed to parse movies: " ++ err
