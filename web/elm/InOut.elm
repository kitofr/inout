module InOut exposing (main)

import Platform.Cmd as Cmd exposing (Cmd)
import Html.App as App exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Dict exposing (get, empty)
import Task exposing (Task)
import Date exposing (..)
import Date.Extra.Duration as Duration exposing (..)
import Date.Extra.Compare as Compare exposing (is, Compare2 (..))
import List.Extra exposing (..)
import Types exposing (..)
import DateUtil exposing (..)
import Api exposing (..)
import Seq exposing (groupBy)

main =
  App.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }

init: Flags -> (Model, Cmd Msg)
init flags =
    ({ events = [], hostUrl = flags.hostUrl }, getEvents flags.hostUrl )

sortEvents events order =
  events
    |> List.sortWith (\a b -> sortDates order a.inserted_at b.inserted_at)

sortEventsDesc events =
  sortEvents events SameOrBefore

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
  li [ class ("list-group-item list-group-item-warning") ]
      [h5 [class "list-group-item-heading"] [text day.dateStr]
      ,p [class "list-group-item-text"] [text (periodToStr (toTimeDuration day.diff))]
      ]

monthItem month =
  li [ class ("list-group-item list-group-item-success row") ]
      [h5 [class "list-group-item-heading"] [text month.month]
      ,p [class "list-group-item-text monthly-hours col-md-6"] [text (periodToStr month.total)]
      ,p [class "list-group-item-text monthly-count col-md-6"] [text (toString month.count)]
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
               , count = List.length (snd x)
               })
        (Dict.toList perMonth))
  in
  div [ class "container-fluid" ]
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
      (model, getEvents model.hostUrl)
    FetchSucceed eventList ->
      let _ = Debug.log "events" eventList
      in
      ({ model | events = eventList }, Cmd.none)
    FetchFail error ->
      let _ = Debug.log "error#events" error
      in
      (model, Cmd.none)
    CheckIn ->
      (model, (check "in" model.hostUrl))
    CheckOut ->
      (model, (check "out" model.hostUrl))
    HttpFail error ->
      let _ = Debug.log "error" error
      in
      (model, Cmd.none)
    HttpSuccess things ->
      let _ = Debug.log "success" things
      in
      (model, getEvents model.hostUrl)
