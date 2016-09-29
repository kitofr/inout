module InOut exposing (main)

import Platform.Cmd as Cmd exposing (Cmd)
import Html.App as App exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import List exposing (..)
import Dict exposing (get, empty)
import Http
import Json.Encode as Encode
import Json.Decode as JD exposing (Decoder, decodeValue, succeed, string, list, (:=))
import Json.Decode.Extra as Extra exposing ((|:))
import Task exposing (Task)
import Date exposing (..)
import Date.Extra.Duration as Duration exposing (..)
import Date.Extra.Compare as Compare exposing (is, Compare2 (..))
import List.Extra exposing (..)

getUrl : String
getUrl = "http://localhost:4000/events"
--getUrl = "https://inout-backend.herokuapp.com/events"

main : Program Never
main =
  App.program { init = init
               , view = view
               , update = update
               , subscriptions = \_ -> Sub.none
               }

type alias Event =
    { status : String
    , location : String
    , device : String
    , inserted_at : Date
    , updated_at : Date
    }

type alias Model =
  { events : List Event }
  
type Msg =
  CheckIn
  | CheckOut
  | Load 
  | FetchSucceed Model
  | FetchFail Http.Error
  | HttpSuccess String
  | HttpFail Http.Error
    

init : (Model, Cmd Msg)
init = 
    ({ events = [] },  Cmd.none)

monthOrder : Date -> Int
monthOrder date =
  case Date.month date of
    Jan -> 1
    Feb -> 2
    Mar -> 3
    Apr -> 4
    May -> 5
    Jun -> 6
    Jul -> 7
    Aug -> 8
    Sep -> 9
    Oct -> 10
    Nov -> 11
    Dec -> 12

dateToString : Date -> String
dateToString date =
  let month = 
      case Date.month date of
        Jan -> "Jan"
        Feb -> "Feb"
        Mar -> "Mar"
        Apr -> "Apr"
        May -> "May"
        Jun -> "Jun"
        Jul -> "Jul"
        Aug -> "Aug"
        Sep -> "Sep"
        Oct -> "Oct"
        Nov -> "Nov"
        Dec -> "Dec"
  in
    month ++ " " ++ (toString <| Date.day date)

sortEvents events order =
  let insertCompare a b =
      case is order a.inserted_at b.inserted_at of
        True -> GT
        _ -> LT
  in
  events
    |> List.sortWith insertCompare

sortEventsDesc events = 
  sortEvents events SameOrBefore 

groupBy fun coll =
  let reducer x acc =
    let key = fun x
        list = Maybe.withDefault [] (Dict.get key acc)
    in
      Dict.insert key (x :: list) acc
  in 
    List.foldl reducer Dict.empty coll

eventsGroupedPerDay events =
  sortEventsDesc events
    --TODO PR on extra so that it is clear that it groups only adjacent
    |> List.Extra.groupWhile (\ x y -> (dateToString x.inserted_at) == (dateToString y.inserted_at))

emptyEvent : Event
emptyEvent =
  let date = case Date.fromString("2000-01-01") of
                    Ok val -> val
                    Err err -> Debug.crash "Can't create date"
  in
  { status = "empty"
  , location = "elm"
  , device = "none"
  , inserted_at = date  
  , updated_at = date
  }

timeDifference coll  =
  let sorted = sortEvents coll SameOrBefore
      first = List.head sorted |> Maybe.withDefault emptyEvent |> Debug.log "first" 
      last = List.reverse sorted |> List.head |> Maybe.withDefault emptyEvent |> Debug.log "last"
      _ = Debug.log "coll" sorted
  in
      Duration.diff first.inserted_at last.inserted_at

periodToStr : DeltaRecord -> String
periodToStr period =
      (toString period.hour) ++ "h " ++ (toString period.minute) ++ "min " ++ (toString period.second) ++ "sec" 

eventItem event =
  let color = if event.status == "check-in" then "success" else "info"
  in
    li [ class ("list-group-item list-group-item-" ++ color) ] 
        [h5 [class "list-group-item-heading"] [text event.status]
        ,p [class "list-group-item-text"] [text <| dateToString event.inserted_at]
        ,p [class "list-group-item-text"] [text event.device]
        ,p [class "list-group-item-text"] [text event.location]
        ]

dayItem day =
  li [ class ("list-group-item list-group-item-success") ] 
      [h5 [class "list-group-item-heading"] [text day.date]
      ,p [class "list-group-item-text"] [text day.diff]
      ]

eventsComponent events =
  let group = (List.map (\x -> List.map (\z -> z.inserted_at) x) (eventsGroupedPerDay events))
      by = Debug.log "groupBy: " (groupBy (\x -> dateToString x.inserted_at) events)
      es = Debug.log "by to list" 
          (List.map 
            (\x -> { date = (fst x), diff = (timeDifference (snd x) |> periodToStr) } ) 
              (Dict.toList by))
  in
  div []
    [h3 [] [text "Events: "]
     , ul [ class "list-group" ]
      --(List.map eventItem (sortEventsDesc events))
      (List.map dayItem es)
    ]
  

view : Model -> Html Msg
view model =
  div [] 
    [div []
      [ button [class ("btn"), onClick Load ] [text "load"]
      , button [class ("btn btn-success"), onClick CheckIn] [text "check in"]
      , button [class ("btn btn-primary"), onClick CheckOut] [text "check out"]
      , (eventsComponent model.events)
      ]
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
    CheckIn ->
      (model, (check "in"))
    CheckOut ->
      (model, (check "out"))
    HttpFail error ->
      let _ = Debug.log "error" error
      in
      (model, Cmd.none)
    HttpSuccess things ->
      let _ = Debug.log "success" things
      in
      (model, getEvents)

-- HTTP
post : Decoder value -> String -> Http.Body -> Task Http.Error value
post decoder url body =
  let request =
        { verb = "POST"
        , headers = [("Content-Type", "application/json")]
        , url = url
        , body = body
        }
  in
      Http.fromJson decoder (Http.send Http.defaultSettings request)


check : String -> Cmd Msg
check inOrOut=
  let rec = Debug.log "encode" encodeEvent { status = "check-" ++ inOrOut, location = "tv4play" }
  in
      Task.perform HttpFail HttpSuccess 
        (post (succeed "") getUrl (Debug.log "payload" (Http.string rec)))

getEvents : Cmd Msg
getEvents =
  Task.perform FetchFail FetchSucceed 
    (Http.get decodeEvents getUrl)

decodeEvents : JD.Decoder Model
decodeEvents =
  JD.succeed Model
    |: ("events" := JD.list decodeEvent)

decodeEvent : JD.Decoder Event
decodeEvent =
    JD.map Event ("status" := JD.string)
        |: ("location" := JD.string)
        |: ("device" := JD.string)
        |: ("inserted_at" := Extra.date)
        |: ("updated_at" := Extra.date)

encodeEvent : { status: String, location: String } -> String
encodeEvent record =
    Encode.encode 0 (Encode.object
        [("event", Encode.object [
          ("status",  Encode.string <| record.status)
          , ("location",  Encode.string <| record.location)
          , ("device",  Encode.string <| "internetz")
          ])
        ])
