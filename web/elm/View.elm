module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Date exposing (..)
import Dict exposing (get, empty)
import Date.Extra.Duration as Duration exposing (..)
import Date.Extra.Compare as Compare exposing (is, Compare2(..))
import DateUtil exposing (..)
import Types exposing (..)
import Date.Extra.Duration as Duration exposing (..)
import Seq exposing (..)

sortEvents: List Event -> Compare2 -> List Event
sortEvents events order =
    events
        |> List.sortWith (\a b -> sortDates order a.inserted_at b.inserted_at)


sortEventsDesc: List Event -> List Event
sortEventsDesc events =
    sortEvents events SameOrBefore


emptyEvent : Event
emptyEvent =
    let
        date =
            case Date.fromString ("2000-01-01") of
                Ok val ->
                    val

                Err err ->
                    Debug.crash "Can't create date"
    in
        { status = "empty"
        , location = "elm"
        , device = "none"
        , inserted_at = date
        , updated_at = date
        }


timeDifference : List Event -> DeltaRecord
timeDifference coll =
    let
        sorted =
            sortEvents coll SameOrBefore

        first =
            List.head sorted |> Maybe.withDefault emptyEvent

        last =
            List.reverse sorted |> List.head |> Maybe.withDefault emptyEvent
    in
        Duration.diff first.inserted_at last.inserted_at



eventItem : Event -> Html Msg
eventItem event =
    let
        color =
            if event.status == "check-in" then
                "success"
            else
                "info"
    in
        li [ class ("list-group-item list-group-item-" ++ color) ]
            [ h5 [ class "list-group-item-heading" ] [ text event.status ]
            , p [ class "list-group-item-text" ] [ text <| dateToMonthStr event.inserted_at ]
            , p [ class "list-group-item-text" ] [ text event.device ]
            , p [ class "list-group-item-text" ] [ text event.location ]
            ]


dayItem : { date : Date, dateStr : String, diff : DeltaRecord } -> Html Msg
dayItem day =
    li [ class ("list-group-item list-group-item-warning") ]
        [ h5 [ class "list-group-item-heading" ] [ text day.dateStr ]
        , p [ class "list-group-item-text" ] [ text (periodToStr (toTimeDuration day.diff)) ]
        ]


monthItem : { count : Int, month : String, total : TimeDuration } -> Html Msg
monthItem month =
    li [ class ("list-group-item list-group-item-success row") ]
        [ h5 [ class "list-group-item-heading" ] [ text month.month ]
        , p [ class "list-group-item-text monthly-hours col-md-6" ] [ text (periodToStr month.total) ]
        , p [ class "list-group-item-text monthly-count col-md-6" ] [ text (toString month.count) ]
        ]


monthlySum month =
    List.foldl addTimeDurations emptyTimeDuration (List.map (\y -> toTimeDuration y.diff) month)


eventsComponent : List Event -> Html Msg
eventsComponent events =
    let
        grouped =
            groupBy (\x -> dateToMonthStr x.inserted_at) events

        dayItems =
            (List.map
                (\x ->
                    { dateStr = (fst x)
                    , diff = (timeDifference (snd x))
                    , date = (List.head (snd x) |> Maybe.withDefault emptyEvent).inserted_at
                    }
                )
                (Dict.toList grouped)
            )

        sorted =
            dayItems |> List.sortWith (\a b -> sortDates SameOrBefore a.date b.date)

        perMonth =
            groupBy (\x -> monthOrder x.date) sorted
                |> Debug.log "perMonth"

        monthTotals =
            List.map
                (\x ->
                    { month = toMonthStr (fst x)
                    , total = monthlySum (snd x)
                    , count = List.length (snd x)
                    }
                )
                (Dict.toList perMonth)
                |> Debug.log "per month total"
    in
        div [ class "container-fluid" ]
            [ h3 [] [ text "Last 5: " ]
            , List.map dayItem (List.take 5 sorted)
                |> ul [ class "list-group" ]
            , h3 [] [ text "Montly totals: " ]
            , List.map monthItem (List.reverse monthTotals)
                |> ul [ class "list-group" ]
            ]


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ button [ class ("btn"), onClick Load ] [ text "refresh" ]
            , button [ class ("btn btn-success"), onClick CheckIn ] [ text "check in" ]
            , button [ class ("btn btn-primary"), onClick CheckOut ] [ text "check out" ]
            , (eventsComponent model.events)
            ]
        ]
