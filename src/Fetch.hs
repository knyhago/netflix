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
                  , ("X-RapidAPI-Key", "0d529c2252mshb7bbc5138195e9ap11ff14jsnb72b5a22ed07")
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