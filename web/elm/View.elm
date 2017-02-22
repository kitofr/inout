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
import Time exposing (..)


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


monthItem : { count : Int, year : Int, month : String, total : TimeDuration, monthlyDayCount : List { hour : Int, minute : Int } } -> Html Msg
monthItem month =
    li [ class ("list-group-item list-group-item-success row") ]
        [ h5 [ class "list-group-item-heading" ] [ text (month.month ++ " " ++ (toString month.year)) ]
        , p [ class "list-group-item-text monthly-hours col-md-6" ] [ text (periodToStr month.total) ]
        , p [ class "list-group-item-text monthly-count col-md-2" ] [ text (toString month.count) ]
        , p [ class "list-group-item-text monthly-chart col-md-6" ] [ barChart month.monthlyDayCount ]
        ]


monthlySum : List { a | diff : DeltaRecord } -> TimeDuration
monthlySum month =
    List.foldl addTimeDurations emptyTimeDuration (List.map (\y -> toTimeDuration y.diff) month)


totalsRect x =
    let
        data =
            (Tuple.second x)

        year =
            case (List.head data) of
                Just d ->
                    Date.year d.date

                _ ->
                    0
    in
        { year = year
        , month = toMonthStr (Tuple.first x)
        , total = monthlySum data
        , count =
            List.length data
        , monthlyDayCount =
            List.map (\x -> { hour = x.diff.hour, minute = x.diff.minute }) data
        }


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
                totalsRect
                (Dict.toList perMonth)

        sortedMonthTotals =
            monthTotals
                |> List.sortWith
                    (\a b ->
                        case a.year > b.year of
                            True ->
                                LT

                            _ ->
                                GT
                    )

        --|> Debug.log "per month total"
    in
        div [ class "container-fluid" ]
            [ h3 [] [ text "Last 5: " ]
            , List.map dayItem (List.take 5 sorted)
                |> ul [ class "list-group" ]
            , h3 [] [ text "Montly totals: " ]
            , List.map monthItem sortedMonthTotals
                |> ul [ class "list-group" ]
            ]


view : Model -> Html Msg
view model =
    let
        time =
            Debug.log "time" model.currentTime
    in
        div []
            [ div []
                [ button [ class ("btn"), onClick Load ] [ text "refresh" ]
                , button [ class ("btn btn-success"), onClick CheckIn ] [ text "check in" ]
                , button [ class ("btn btn-primary"), onClick CheckOut ] [ text "check out" ]
                  --, p [] [ text (toString time) ]
                , (eventsComponent model.events)
                ]
            ]
