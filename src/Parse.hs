{-# LANGUAGE OverloadedStrings #-}

module Parse (ParsedMovieDB(..), parseMovieDetails, parseMovieTitles, convertToDBMovie) where

import Data.Aeson
import Data.Text (Text)
import Types
import Database as DB
import Data.String (fromString)

convertToDBMovie :: ParsedMovieDB -> DB.ParsedMovieDB
convertToDBMovie pMovie = DB.ParsedMovieDB
    { Types.id = Types.id pMovie,
      title = title pMovie,
      year = year pMovie,
      rating = rating pMovie,
      genre = genre pMovie,
      description = description pMovie,
      rank = rank pMovie
    }


instance FromJSON ParsedMovieDB where
    parseJSON = withObject "ParsedMovieDB" $ \v ->
        ParsedMovieDB
            <$> v .: "id"
            <*> v .: "title"
            <*> v .: "year"
            <*> v .: "rating"
            <*> v .: "genre"
            <*> v .: "description"
            <*> v .: "rank"

parseMovieDetails :: Value -> [ParsedMovieDB]
parseMovieDetails json =
    case fromJSON json of
        Success movies -> movies
        Error _ -> []

parseMovieTitles :: Value -> [Text]
parseMovieTitles json =
    case json of
        Array arr -> concatMap extractTitle arr
        _ -> []

extractTitle :: Value -> [Text]
extractTitle (Object obj) =
    case fromJSON (Object obj) of
        Success movie -> [title movie]
        Error _ -> []
extractTitle _ = []