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

eventItem event =
  let color = if event.status == "check-in" then "success" else "info"
  in
    li [ class ("list-group-item list-group-item-" ++ color) ] 
        [h5 [class "list-group-item-heading"] [text event.status]
        ,p [class "list-group-item-text"] [text <| dateToString event.inserted_at]
        ,p [class "list-group-item-text"] [text event.device]
        ,p [class "list-group-item-text"] [text event.location]
        ]
sortEventsDesc events = 
  let insertCompare a b =
      case is SameOrBefore a.inserted_at b.inserted_at of
        True -> GT
        _ -> LT
  in
  events
    |> List.sortWith insertCompare

-- (defn group-by 
--   "Returns a map of the elements of coll keyed by the result of
--   f on each element. The value at each key will be a vector of the
--   corresponding elements, in the order they appeared in coll."
--   {:added "1.2"
--    :static true}
--   [f coll]  
--   (persistent!
--    (reduce
--     (fn [ret x]
--       (let [k (f x)]
--         (assoc! ret k (conj (get ret k []) x))))
--     (transient {}) coll)))

groupBy toCompareable f coll =
  List.foldl (\ret x -> 
--    let k = f x
--        list = case Dict.get k ret of
--              Just v -> v
--              Nothing -> []
--             
--    in
--      Dict.insert k (x :: list)
      let update mv = 
          case mv of
            Nothing -> []
            Just v -> v 
      in
          Dict.insert (toCompareable x) update ret
    ) Dict.empty coll

eventsGroupedPerDay events =
  sortEventsDesc events
    --TODO PR on extra so that it is clear that it groups only adjacent
    |> List.Extra.groupWhile (\ x y -> (dateToString x.inserted_at) == (dateToString y.inserted_at))

eventsComponent events =
  let group = (List.map (\x -> List.map (\z -> z.inserted_at) x) (eventsGroupedPerDay events))
--      last = Debug.log "last" (timeDifference (List.Extra.last group))
  in
  div []
    [h3 [] [text "Events: "]
     , ul [ class "list-group" ]
      (List.map eventItem (List.reverse events))
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
