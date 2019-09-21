module InOut exposing (main)

import Api exposing (getEvents, loadContract)
import Msgs exposing (Msg(..))
import Time exposing (..)
import Types exposing (Contract, Flags, Model, Page(..))
import Update exposing (..)
import Url exposing (Url)
import View exposing (view)


main : Program Flags Model Msg
main =
    Browser.application SetRoute
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
            Time.every 1000 Tick


init : Flags -> Url -> ( Model, Cmd Msg )
init flags url =
    ( { events = []
      , hostUrl = flags.hostUrl
      , checkInAt = 0
      , timeSinceLastCheckIn = 0
      , edit = Nothing
      , page = Home
      , currentTab = 2019
      , contract = Contract "None"
      , zone = Time.utc
      }
    , Cmd.batch
        [ getEvents flags.hostUrl
        , loadContract flags.hostUrl
        ]
    )
