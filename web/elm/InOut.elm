module InOut exposing (main)

import Platform.Cmd as Cmd exposing (Cmd)
import Html.App as App exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import List exposing (..)
import Http
import Json.Encode
import Json.Decode exposing (Decoder, decodeValue, succeed, string, list, (:=))
import Json.Decode.Extra exposing ((|:))
import Task

main : Program Never
main =
  App.program { init = init
               , view = view
               , update = update
               , subscriptions = \_ -> Sub.none
               }

type alias Event =
    { updated_at : String
    , status : String
    , location : String
    , inserted_at : String
    }

type alias Model =
  { events : List Event }
  
type Msg =
  CheckIn
  | CheckOut
  | Load 
  | FetchSucceed Model
  | FetchFail Http.Error

init : (Model, Cmd Msg)
init = 
    ({ events = [] },  Cmd.none)

eventItem event =
  li [ class "event" ] [ text event.status]

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
    , button [class ("button"), onClick Load ] [text "load"]
    , button [class ("button is-primary")] [text "check in"]
    , button [class ("button is-primary")] [text "check out"]
    ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Load -> 
      (model, getEvents)
    FetchSucceed newModel -> 
      (newModel, Cmd.none)
    FetchFail error -> 
      (model, Cmd.none)
    _ -> 
      (model, Cmd.none)


-- HTTP

getEvents : Cmd Msg
getEvents =
  let url = "http://localhost:4000/events"
      get = (Http.get decodeEvents url)
  in
      Task.perform FetchFail FetchSucceed get 

decodeEvents : Json.Decode.Decoder Model
decodeEvents =
      Json.Decode.succeed Model
              |: ("events" := Json.Decode.list decodeEvent)

decodeEvent : Json.Decode.Decoder Event
decodeEvent =
    Json.Decode.succeed Event
        |: ("updated_at" := Json.Decode.string)
        |: ("status" := Json.Decode.string)
        |: ("location" := Json.Decode.string)
        |: ("inserted_at" := Json.Decode.string)

encodeEvent : Event -> Json.Encode.Value
encodeEvent record =
    Json.Encode.object
        [ ("updated_at",  Json.Encode.string <| record.updated_at)
        , ("status",  Json.Encode.string <| record.status)
        , ("location",  Json.Encode.string <| record.location)
        , ("inserted_at",  Json.Encode.string <| record.inserted_at)
        ]
