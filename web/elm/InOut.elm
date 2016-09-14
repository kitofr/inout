module InOut exposing (main)

import Platform.Cmd as Cmd exposing (Cmd)
import Html.App as App exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import List exposing (..)
import Http
import Json.Decode as Json
import Task

main : Program Never
main =
  App.program { init = init
               , view = view
               , update = update
               , subscriptions = \_ -> Sub.none
               }

type alias Event = { insertedAt: String
                   , event: String }
type alias Model =
  { events : List Event 
  , text : String }
  
type Msg =
  CheckIn
  | CheckOut
  | Load
  | FetchSucceed String
  | FetchFail Http.Error

init : (Model, Cmd Msg)
init = 
    ({ events = [{ insertedAt = "today", event = "check-in"}, { insertedAt = "today",  event = "check-out"}]
    , text = "nothing" }
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
    (eventsComponent model.events) 
    , text model.text
    , button [class ("button"), onClick Load] [text "load"]
    , button [class ("button is-primary")] [text "check in"]
    , button [class ("button is-primary")] [text "check out"]
    ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Load -> (model, getEvents)
    FetchSucceed json -> ({ model | text = json }, Cmd.none)
    FetchFail _ -> (model, Cmd.none)
    _ -> (model, Cmd.none)


-- HTTP

getEvents : Cmd Msg
getEvents =
  let url = "http://localhost:4000/events"
  in
      Task.perform FetchFail FetchSucceed (Http.get decodeEvents url)

decodeEvents : Json.Decoder String
decodeEvents =
  Json.at ["events"] Json.string
