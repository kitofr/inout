module Main exposing (main)

import Api exposing (getEvents, loadContract)
import Browser
import Browser.Navigation as Nav
import Msgs exposing (Msg(..))
import Time exposing (..)
import Types exposing (Contract, Flags, Model, Page(..))
import Update exposing (..)
import Url exposing (Url)
import View exposing (view)


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = Update.update
        , subscriptions = subscriptions

        --        , onUrlChange = UrlChanged
        --        , onUrlRequest = LinkClicked
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    case Time.posixToMillis model.checkInAt of
        0 ->
            Sub.none

        _ ->
            --Time.every 1000 Tick
            Sub.none


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { events = []
      , hostUrl = flags.hostUrl
      , checkInAt = Time.millisToPosix 0
      , timeSinceLastCheckIn = Time.millisToPosix 0
      , edit = Nothing
      , page = Home
      , currentTab = 2020
      , contract = Contract "None"
      , zone = Time.utc

      --      , url = url
      --      , key = key
      }
    , Cmd.batch
        [ getEvents flags.hostUrl
        , loadContract flags.hostUrl
        ]
    )
