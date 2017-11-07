module InOut exposing (main)

import Time exposing (second)
import Html
import Types exposing (Flags, Model)
import Msgs exposing (Msg(Tick))
import Api exposing (getEvents)
import View exposing (view)
import Update


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
      , currentTab = 2017 -- TODO this year
      }
    , getEvents flags.hostUrl
    )
