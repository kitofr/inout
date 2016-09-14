module InOut exposing (main)

import Platform.Cmd as Cmd exposing (Cmd)
import Html.App as App exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
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
type alias Model =
  List Event 
  
type Msg =
  CheckIn
  | CheckOut
  | Load

init : (Model, Cmd Msg)
init = 
    ([{ insertedAt = "today", event = "check-in"}, { insertedAt = "today",  event = "check-out"}]
      , Cmd.none)

eventItem event =
  li [ class "event" ] [ text event.event]

eventsComponent events =
  [div []
    [text "Events: "]
    , ul [ class "events" ]
      (List.map eventItem events)
  ]

view : Model -> Html Msg
view model =
  div [] 
    [div []
    (eventsComponent model) 
    , button [class ("button"), onClick Load] [text "load"]
    , button [class ("button is-primary")] [text "check in"]
    , button [class ("button is-primary")] [text "check out"]
    ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  (model, Cmd.none)
