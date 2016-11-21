module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Date exposing (..)
import Date.Extra.Compare as Compare exposing (is, Compare2(..))
import Dict exposing (get, empty)
import Date.Extra.Duration as Duration exposing (..)
import Charts exposing (barChart)
import DateUtil exposing (..)
import Types exposing (..)
import Seq exposing (..)


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


dayItem : { date : Date, dateStr : String, diff : DeltaRecord, dayNumber : Int } -> Html Msg
dayItem day =
    li [ class ("list-group-item list-group-item-warning") ]
        [ h5 [ class "list-group-item-heading" ] [ text day.dateStr ]
        , p [ class "list-group-item-text" ] [ text (periodToStr (toTimeDuration day.diff)) ]
        ]


monthItem : { count : Int, month : String, total : TimeDuration, monthlyDayCount : List { hour : Int, minute : Int } } -> Html Msg
monthItem month =
    li [ class ("list-group-item list-group-item-success row") ]
        [ h5 [ class "list-group-item-heading" ] [ text month.month ]
        , p [ class "list-group-item-text monthly-hours col-md-6" ] [ text (periodToStr month.total) ]
        , p [ class "list-group-item-text monthly-count col-md-2" ] [ text (toString month.count) ]
        , p [ class "list-group-item-text monthly-chart col-md-6" ] [ barChart month.monthlyDayCount ]
        ]


monthlySum : List { a | diff : DeltaRecord } -> TimeDuration
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
                    let
                        date =
                            (List.head (Tuple.second x) |> Maybe.withDefault emptyEvent).inserted_at
                    in
                        { dateStr = (Tuple.first x)
                        , diff = (timeDifference (Tuple.second x))
                        , date = date
                        , dayNumber = Date.day date
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
                    { month = toMonthStr (Tuple.first x)
                    , total = monthlySum (Tuple.second x)
                    , count = List.length (Tuple.second (Debug.log "x" x))
                    , monthlyDayCount =
                        List.map (\x -> { hour = x.diff.hour, minute = x.diff.minute }) (Tuple.second x)
                        --                      [
                        --                      { hour = 4, minute = 12 }
                        --                    , { hour = 5, minute = 5 }
                        --                    , { hour = 0, minute = 0 }
                        --                    , { hour = 5, minute = 5 }
                        --                    , { hour = 6, minute = 30 }
                        --                    , { hour = 8, minute = 50 }
                        --                    , { hour = 0, minute = 59 }
                        --                    , { hour = 0, minute = 30 }
                        --                    , { hour = 8, minute = 50 }
                        --                    , { hour = 6, minute = 59 }
                        --                    , { hour = 8, minute = 50 }
                        --                    , { hour = 6, minute = 30 }
                        --                    , { hour = 6, minute = 59 }
                        --                    , { hour = 0, minute = 30 }
                        --                    , { hour = 0, minute = 50 }
                        --                    , { hour = 8, minute = 50 }
                        --                    , { hour = 6, minute = 30 }
                        --                    , { hour = 8, minute = 50 }
                        --                    , { hour = 6, minute = 59 }
                        --                    , { hour = 6, minute = 59 }
                        --                    , { hour = 0, minute = 30 }
                        --                    , { hour = 0, minute = 50 }
                        --                    , { hour = 8, minute = 50 }
                        --                    , { hour = 6, minute = 30 }
                        --                    , { hour = 6, minute = 59 }
                        --                    , { hour = 8, minute = 50 }
                        --                    , { hour = 6, minute = 59 }
                        --                    , { hour = 0, minute = 30 }
                        --                    , { hour = 0, minute = 50 }
                        --                    , { hour = 10, minute = 59 }
                        --                    ]
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
