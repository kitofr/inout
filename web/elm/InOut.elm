module InOut exposing (main)

import Navigation exposing (Location)
import Time exposing (second)
import Html
import Types exposing (Flags, Model, Page(..))
import Msgs exposing (Msg(Tick, SetRoute))
import Api exposing (getEvents)
import View exposing (view)
import Update exposing (setRoute)


main : Program Flags Model Msg
main =
    Navigation.programWithFlags SetRoute
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


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    ( setRoute location
        { events = []
        , hostUrl = flags.hostUrl
        , checkInAt = 0
        , timeSinceLastCheckIn = 0
        , edit = Nothing
        , page = Home
        , currentTab = 2018
        }
    , getEvents flags.hostUrl
    )
