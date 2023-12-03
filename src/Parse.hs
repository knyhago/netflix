{-# LANGUAGE OverloadedStrings #-}

module Parse (parseMovieTitles, parseMovieDetails) where

import Data.Aeson
import Data.Text (Text)

data MovieDetails = MovieDetails { title :: Text } deriving Show

instance FromJSON MovieDetails where
    parseJSON = withObject "MovieDetails" $ \v -> MovieDetails
        <$> v .: "title" -- Adjust this to match the actual field name in the JSON

parseMovieDetails :: Value -> MovieDetails
parseMovieDetails json =
    case fromJSON json of
        Success movieDetails -> movieDetails
        Error err -> error $ "Failed to parse movie details: " ++ err

parseMovieTitles :: Value -> [Text]
parseMovieTitles json =
    case fromJSON json of
        Success movies -> map title movies
        Error err -> error $ "Failed to parse movies: " ++ err
