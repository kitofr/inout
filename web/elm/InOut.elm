module InOut exposing (main)

import Platform.Cmd as Cmd exposing (Cmd)
import Html exposing (..)
import Html.App as App exposing (..)
import Html.Attributes as A
import List exposing (..)

main : Program Never
main =
  App.program { init = init
               , view = view
               , update = update
               , subscriptions = \_ -> Sub.none
               }

type alias Event = { insertedAt: String
                   , event: String
                   }
type alias Model = { events: List Event }
type Msg =
  CheckIn
  | CheckOut
  | Load

init : (Model, Cmd Msg)
init = 
    ({ events = [{ insertedAt = "today", event = "check-in"}, { insertedAt = "today",  event = "check-out"}] }
      , Cmd.none)

eventsComponent events =
  [div []
    [text "Events: "]
    , ul []
      (List.map (\e -> li [] [text e.event]) events)
  ]

view : Model -> Html Msg
view model =
  div [] 
    [div []
    (eventsComponent model.events) 
    , button [] [text "check in"]
    , button [] [text "check out"]
    ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  (model, Cmd.none)
