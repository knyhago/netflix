{-# LANGUAGE OverloadedStrings #-}

module Fetch (fetchData) where

import Network.HTTP.Simple
import Network.HTTP.Simple (setRequestHeader)
import qualified Data.ByteString.Char8 as BS
import qualified Data.Aeson as Aeson

fetchData :: IO (Maybe Aeson.Value)
fetchData = do
    let url = "https://imdb-top-100-movies.p.rapidapi.com/" 
    request <- parseRequest $ "GET " ++ url
    let headers = [ ("X-RapidAPI-Host", "imdb-top-100-movies.p.rapidapi.com")
                  , ("X-RapidAPI-Key", "e74dadf792mshf170120712f4bf5p17b2dbjsn6a97ac581c70")
                  ]

    let request' = setRequestHeaders headers request

    response <- httpLBS request'
    putStrLn "Response status code:"
    print (getResponseStatusCode response)

    -- Decode the response body as JSON
    let responseBody = getResponseBody response
    case Aeson.decode responseBody of
        Just jsonResponse -> return (Just jsonResponse)
        Nothing -> do
            putStrLn "Failed to decode JSON response"
            return Nothing
