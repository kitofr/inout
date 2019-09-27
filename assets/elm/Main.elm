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
    Browser.application
        { init = init
        , view = view
        , update = Update.update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    case Time.posixToMillis model.checkInAt of
        0 ->
            Sub.none

        _ ->
            Time.every 1000 Tick


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { events = []
      , hostUrl = flags.hostUrl
      , checkInAt = Time.millisToPosix 0
      , timeSinceLastCheckIn = Time.millisToPosix 0
      , edit = Nothing
      , page = Home
      , currentTab = 2019
      , contract = Contract "None"
      , zone = Time.utc
      , url = url
      , key = key
      }
    , Cmd.batch
        [ getEvents flags.hostUrl
        , loadContract flags.hostUrl
        ]
    )
