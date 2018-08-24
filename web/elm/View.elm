module View exposing (view)

import Charts exposing (barChart)
import Date.Extra.Compare exposing (Compare2(SameOrBefore))
import Date.Extra.Duration exposing (DeltaRecord)
import DateUtil exposing (DateRecord, TimeDuration, addTimeDurations, dateToMonthStr, emptyTimeDuration, monthOrder, periodToStr, sortDates, toMonthStr, toTimeDuration)
import Dict
import EditEvent exposing (edit)
import Html exposing (Html, a, button, div, h5, li, p, text, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Last5 exposing (last5)
import Msgs exposing (Msg(ViewEvent))
import Seq exposing (desc, groupBy)
import TimeSinceLastCheckIn exposing (viewTimeSinceLastCheckIn)
import Types exposing (DayItem, Event, Model, emptyEvent, timeDifference)
import ViewMsgs exposing (ViewMsg(CheckIn, CheckOut, Load, TabClicked))


monthItem : { count : Int, year : Int, month : Int, total : TimeDuration, monthlyDayCount : List { hour : Int, minute : Int } } -> Html Msg
monthItem { count, year, month, total, monthlyDayCount } =
    li [ class "list-group-item list-group-item-success row" ]
        [ h5 [ class "list-group-item-heading" ] [ text (toMonthStr month ++ " " ++ toString year) ]
        , p [ class "list-group-item-text monthly-hours col-md-6" ] [ text (periodToStr total) ]
        , p [ class "list-group-item-text monthly-count col-md-2" ] [ text (toString count) ]
        , p [ class "list-group-item-text monthly-chart col-md-6" ] [ barChart monthlyDayCount ]
        ]


monthlySum : List { a | diff : DateRecord } -> TimeDuration
monthlySum month =
    List.foldl addTimeDurations emptyTimeDuration (List.map (\y -> toTimeDuration y.diff) month)


totalsRect :
    ( Int
    , List
        { a
            | date : DateRecord
            , diff :
                { day : Int
                , month : Int
                , second : Int
                , year : Int
                , hour : Int
                , minute : Int
                }
        }
    )
    ->
        { count : Int
        , month : Int
        , monthlyDayCount :
            List
                { hour : Int
                , minute : Int
                }
        , total : TimeDuration
        , year : Int
        }
totalsRect rec =
    let
        data =
            Tuple.second rec

        year =
            case List.head data of
                Just d ->
                    d.date.year

                _ ->
                    0
    in
    { year = year
    , month = Tuple.first rec
    , total = monthlySum data
    , count =
        List.length data
    , monthlyDayCount =
        List.map (\x -> { hour = x.diff.hour, minute = x.diff.minute }) data
    }


monthlyTotals :
    Bool
    ->
        List
            { a
                | diff :
                    { day : Int
                    , hour : Int
                    , minute : Int
                    , month : Int
                    , second : Int
                    , year : Int
                    }
                , date : DateRecord
            }
    -> Html Msg
monthlyTotals active sorted =
    let
        paneClass =
            if active then
                "tab-pane active"

            else
                "tab-pane"

        perMonth =
            groupBy (\x -> monthOrder x.date) sorted
                |> Dict.toList

        sortedMonthTotals =
            List.map totalsRect perMonth
                |> List.sortWith (\x y -> desc x.month y.month)
    in
    div [ class paneClass ]
        [ List.map monthItem sortedMonthTotals
            |> ul [ class "list-group" ]
        ]


sortedDayItems : List Event -> List DayItem
sortedDayItems events =
    let
        grouped =
            groupBy (\x -> dateToMonthStr x.inserted_at) events

        dayItems =
            List.map
                (\x ->
                    let
                        date =
                            (List.head (Tuple.second x) |> Maybe.withDefault emptyEvent).inserted_at
                    in
                    { dateStr = Tuple.first x
                    , diff = timeDifference (Tuple.second x)
                    , date = date
                    , dayNumber = date.day
                    , events = Tuple.second x
                    }
                )
                (Dict.toList grouped)
    in
    dayItems |> List.sortWith (\x y -> sortDates x.date y.date)


yearTab : Int -> ( Int, List Event ) -> Html Msg
yearTab currentTab ( year, _ ) =
    let
        active =
            if currentTab == year then
                " active"

            else
                ""
    in
    li [ "nav-item" ++ active |> class ]
        [ a [ class "nav-link", onClick (ViewEvent (TabClicked year)) ] [ text (toString year) ]
        ]


groupedByYear : List Event -> List ( Int, List Event )
groupedByYear events =
    groupBy (\x -> x.inserted_at.year) events
        |> Dict.toList
        |> List.sortWith (\( x, _ ) ( y, _ ) -> desc x y)


yearTabs : Int -> List Event -> Html Msg
yearTabs currentTab events =
    let
        list =
            groupedByYear events
    in
    div []
        [ ul [ class "nav nav-pills" ]
            (List.map (yearTab currentTab) list)
        , div [ class "tab-content" ]
            (List.map
                (\( y, es ) ->
                    let
                        sorted =
                            sortedDayItems es
                    in
                    monthlyTotals (y == currentTab) sorted
                )
                list
            )
        ]


eventsComponent : Int -> List Event -> Html Msg
eventsComponent currentTab events =
    let
        monthlySorted =
            sortedDayItems events
    in
    div [ class "container-fluid" ]
        [ last5 monthlySorted
        , yearTabs currentTab events
        ]


view : Model -> Html Msg
view model =
    let
        shouldEdit =
            case model.edit of
                Just dayItem ->
                    edit dayItem

                _ ->
                    div [] []
    in
    div []
        [ div [ class "container" ]
            [ div [ class "row" ]
                [ button [ class "btn", onClick (ViewEvent Load) ] [ text "refresh" ]
                , button [ class "btn btn-success", onClick (ViewEvent CheckIn) ] [ text "check in" ]
                , button [ class "btn btn-primary", onClick (ViewEvent CheckOut) ] [ text "check out" ]
                ]
            , div [ class "row check-timer" ] (viewTimeSinceLastCheckIn model.timeSinceLastCheckIn)
            , shouldEdit
            , eventsComponent model.currentTab model.events
            ]
        ]
