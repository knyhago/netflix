{-# LANGUAGE OverloadedStrings #-}

module Fetch (fetchData) where

import Network.HTTP.Simple
import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Lazy.Char8 as LBS
import Data.Aeson (Value, decode)

fetchData :: IO (Maybe Value)  -- Update the return type to return parsed JSON
fetchData = do
    request <- parseRequest "GET https://imdb-top-100-movies.p.rapidapi.com/series"
    let headers = [
            ("X-RapidAPI-Host", "imdb-top-100-movies.p.rapidapi.com"),
            ("X-RapidAPI-Key", "e74dadf792mshf170120712f4bf5p17b2dbjsn6a97ac581c70") -- Replace with your RapidAPI key
            ]
    let request' = setRequestHeaders headers request
    response <- httpLBS request'
    putStrLn "Response status code:"
    print (getResponseStatusCode response)
    putStrLn "Response body:"
    LBS.putStrLn (getResponseBody response)

    -- Decode the response body as JSON
    let responseBody = getResponseBody response
    case decode responseBody of
        Just jsonResponse -> return (Just jsonResponse)
        Nothing -> do
            putStrLn "Failed to decode JSON response"
            return Nothing
