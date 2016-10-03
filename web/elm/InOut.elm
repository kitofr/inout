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
--getUrl = "http://localhost:4000/events"
getUrl = "https://inout-backend.herokuapp.com/events"

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

toMonthStr : Int -> String
toMonthStr num =
  case num of
    1 -> "Jan"
    2 -> "Feb"
    3 -> "Mar"
    4 -> "Apr"
    5 -> "May"
    6 -> "Jun"
    7 -> "Jul"
    8 -> "Aug"
    9 -> "Sep"
    10 -> "Oct"
    11 -> "Nov"
    12 -> "Dec"
    _ -> "wft month: " ++ toString num

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

dateToMonthStr : Date -> String
dateToMonthStr date =
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

sortDates order a b =
  case is order a b of
    True -> GT
    _ -> LT

sortEvents events order =
  events
    |> List.sortWith (\a b -> sortDates order a.inserted_at b.inserted_at)

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

timeDifference : List Event -> DeltaRecord
timeDifference coll  =
  let sorted = sortEvents coll SameOrBefore
      first = List.head sorted |> Maybe.withDefault emptyEvent
      last = List.reverse sorted |> List.head |> Maybe.withDefault emptyEvent
  in
      Duration.diff first.inserted_at last.inserted_at

periodToStr : TimeDuration -> String
periodToStr period =
      (toString period.hour) ++ "h " ++ (toString period.minute) ++ "min " ++ (toString period.second) ++ "sec" 

eventItem event =
  let color = if event.status == "check-in" then "success" else "info"
  in
    li [ class ("list-group-item list-group-item-" ++ color) ] 
        [h5 [class "list-group-item-heading"] [text event.status]
        ,p [class "list-group-item-text"] [text <| dateToMonthStr event.inserted_at]
        ,p [class "list-group-item-text"] [text event.device]
        ,p [class "list-group-item-text"] [text event.location]
        ]

dayItem day =
  li [ class ("list-group-item list-group-item-success") ] 
      [h5 [class "list-group-item-heading"] [text day.dateStr]
      ,p [class "list-group-item-text"] [text (periodToStr (toTimeDuration day.diff))]
      ]

monthItem month =
  li [ class ("list-group-item list-group-item-success") ] 
      [h5 [class "list-group-item-heading"] [text month.month]
      ,p [class "list-group-item-text"] [text (periodToStr month.total)]
      ]

type alias TimeDuration =
  { hour : Int, minute : Int, second : Int, millisecond : Int}

toTimeDuration : DeltaRecord -> TimeDuration
toTimeDuration duration =
  { hour = duration.hour
  , minute = duration.minute
  , second = duration.second
  , millisecond = duration.millisecond
  }

emptyTimeDuration : TimeDuration
emptyTimeDuration =
  { hour = 0 , minute = 0 , second = 0 , millisecond = 0}

addTime : Int -> (Int, Int)
addTime t =
  (t%60, t//60)

addTimeDurations : TimeDuration -> TimeDuration -> TimeDuration
addTimeDurations a b =
  let mil = addTime (a.millisecond + b.millisecond) 
      sec = addTime (a.second + b.second + (snd mil))
      min = addTime (a.minute + b.minute + (snd sec))
      hour = a.hour + b.hour + (snd min) 
  in
  { 
  millisecond = fst mil
  , second = fst sec
  , minute = fst min
  , hour = hour
  }

--monthlySum : List { diff : DeltaRecord } -> TimeDuration
monthlySum month =
  List.foldl addTimeDurations emptyTimeDuration (List.map (\y -> toTimeDuration y.diff) month)

eventsComponent events =
  let grouped = groupBy (\x -> dateToMonthStr x.inserted_at) events
      dayItems = (List.map 
            (\x -> 
              { dateStr = (fst x)
              , diff = (timeDifference (snd x))
              , date = (List.head (snd x) |> Maybe.withDefault emptyEvent).inserted_at
              } ) 
              (Dict.toList grouped))
      sorted = dayItems |> List.sortWith (\a b -> sortDates SameOrBefore a.date b.date)
      perMonth = Debug.log "perMonth" ( groupBy (\x -> monthOrder x.date ) sorted )

      monthTotals = Debug.log "per month total" (List.map
        (\x -> { month = toMonthStr (fst x)
               , total = monthlySum (snd x) 
               })
        (Dict.toList perMonth))
  in
  div []
    [h3 [] [text "Last 5: "]
     , ul [ class "list-group" ]
      --(List.map eventItem (sortEventsDesc events))
      (List.map dayItem (List.take 5 sorted))
    , 
    h3 [] [text "Montly totals: "]
    , ul [ class "list-group" ]
      (List.map monthItem (List.reverse monthTotals))
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
