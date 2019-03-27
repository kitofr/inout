module InOut exposing (main)

import Api exposing (getEvents, loadContract)
import Msgs exposing (Msg(SetRoute, Tick))
import Navigation exposing (Location)
import Time exposing (second)
import Types exposing (Contract, Flags, Model, Page(..))
import Update exposing (setRoute)
import View exposing (view)


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
        , currentTab = 2019
        , contract = Contract "None"
        }
    , Cmd.batch
        [ getEvents flags.hostUrl
        , loadContract flags.hostUrl
        ]
    )
