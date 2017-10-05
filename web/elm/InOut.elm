module InOut exposing (main)

import Platform.Cmd as Cmd exposing (Cmd)
import Time exposing (Time, second)
import Html exposing (..)
import Types exposing (..)
import Msgs exposing (..)
import Api exposing (..)
import View exposing (..)
import Update exposing (update)


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = Update.update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.checkInAt of
        0 ->
            Sub.none

        _ ->
            Time.every second Tick


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { events = []
      , hostUrl = flags.hostUrl
      , checkInAt = 0
      , timeSinceLastCheckIn = 0
      , edit = Nothing
      }
    , getEvents flags.hostUrl
    )
