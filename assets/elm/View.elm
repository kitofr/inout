module View exposing (view)

import Browser
import Charts exposing (barChart)
import DateUtil exposing (Compare2(..), Date, TimeDuration, addTimeDurations, dateToMonthStr, emptyTimeDuration, monthOrder, periodToStr, sortDates, toMonthStr, toTimeDuration)
import Dict
import EditEvent exposing (edit)
import Html exposing (Html, a, button, div, h3, h5, li, p, text, ul)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Last6 exposing (last6)
import Msgs exposing (Msg(..))
import Seq exposing (desc, groupBy)
import Time exposing (..)
import TimeSinceLastCheckIn exposing (viewTimeSinceLastCheckIn)
import Types exposing (DayItem, Event, Model, Page(..), emptyEvent, timeDifference)
import ViewMsgs exposing (ViewMsg(..))


monthItem : { count : Int, year : Int, month : Int, total : TimeDuration, monthlyDayCount : List { hour : Int, minute : Int } } -> Html Msg
monthItem { count, year, month, total, monthlyDayCount } =
    let
        totalStr =
            periodToStr total

        dayCount =
            String.fromInt count

        dates =
            ( year, month )
    in
    li [ class "list-group-item list-group-item-success row" ]
        [ h5 [ class "list-group-item-heading" ]
            [ text (toMonthStr month ++ " " ++ String.fromInt year) ]
        , div
            [ class "row" ]
            [ p [ class "list-group-item-text monthly-hours col-md-6 col-xs-6" ] [ text totalStr ]
            , p [ class "list-group-item-text monthly-count col-md-1 col-xs-2" ] [ text dayCount ]
            ]
        , div [ class "row" ]
            [ p [ class "list-group-item-text monthly-chart col-md-8" ] [ barChart monthlyDayCount ]
            ]
        ]


monthlySum : List { a | diff : Date } -> TimeDuration
monthlySum month =
    List.foldl addTimeDurations emptyTimeDuration (List.map (\y -> toTimeDuration y.diff) month)


totalsRect :
    ( Int
    , List
        { a
            | date : Posix
            , diff : Date
        }
    )
    -> Zone
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
totalsRect rec zone =
    let
        data =
            Tuple.second rec

        year =
            case List.head data of
                Just d ->
                    Time.toYear zone d.date

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


monthlyTotals : Bool -> List DayItem -> Zone -> Html Msg
monthlyTotals active sorted zone =
    let
        paneClass =
            if active then
                "tab-pane active"

            else
                "tab-pane"

        perMonth =
            groupBy (\x -> monthOrder x.date zone) sorted
                |> Dict.toList

        sortedMonthTotals =
            List.map (\p -> totalsRect p zone) perMonth
                |> List.sortWith (\x y -> desc x.month y.month)
    in
    div [ class paneClass ]
        [ List.map monthItem sortedMonthTotals
            |> ul [ class "list-group" ]
        ]


sortedDayItems : List Event -> Zone -> List DayItem
sortedDayItems events zone =
    let
        grouped =
            groupBy (\x -> dateToMonthStr x.inserted_at zone) events

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
                    , dayNumber = Time.toDay zone date
                    , events = Tuple.second x
                    }
                )
                (Dict.toList grouped)
    in
    dayItems |> List.sortWith (\x y -> sortDates SameOrBefore x.date y.date)


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
        [ div [ class "nav-link", onClick (ViewEvent (TabClicked year)) ] [ text (String.fromInt year) ]
        ]


groupedByYear : List Event -> Zone -> List ( Int, List Event )
groupedByYear events zone =
    groupBy (\x -> Time.toYear zone x.inserted_at) events
        |> Dict.toList
        |> List.sortWith (\( x, _ ) ( y, _ ) -> desc x y)


yearTabs : Int -> List Event -> Zone -> Html Msg
yearTabs currentTab events zone =
    let
        list =
            groupedByYear events zone
    in
    div []
        [ ul [ class "nav nav-pills" ]
            (List.map (yearTab currentTab) list)
        , div [ class "tab-content" ]
            (List.map
                (\( y, es ) ->
                    let
                        sorted =
                            sortedDayItems es zone
                    in
                    monthlyTotals (y == currentTab) sorted zone
                )
                list
            )
        ]


eventsComponent : Int -> List Event -> Zone -> Html Msg
eventsComponent currentTab events zone =
    let
        monthlySorted =
            sortedDayItems events zone
    in
    div [ class "container" ]
        [ last6 monthlySorted
        , yearTabs currentTab events zone
        ]


view : Model -> Html.Html Msg
view model =
    let
        event =
            List.head model.events
                |> Maybe.withDefault emptyEvent

        eventText =
            String.fromInt (1000 * event.posix) ++ " " ++ String.fromInt (Time.toMillis model.zone event.inserted_at)

        shouldEdit =
            case model.edit of
                Just dayItem ->
                    edit dayItem model.zone

                _ ->
                    div [] []
    in
    case model.page of
        Home ->
            div []
                [ div [ class "container" ]
                    [ div [ class "row" ]
                        [ h5 [ class "contract-header" ] [ text ("Current contract: " ++ model.contract.name) ]
                        , h5 [ class "contract-header" ] [ a [ href "./events" ] [ text "Events" ] ]
                        ]
                    , div [ class "row" ]
                        [ button [ class "btn btn-success", onClick (ViewEvent CheckIn) ] [ text "check in" ]
                        , button [ class "btn btn-primary", onClick (ViewEvent CheckOut) ] [ text "check out" ]
                        ]
                    , div [ class "row check-timer" ] (viewTimeSinceLastCheckIn model.timeSinceLastCheckIn)
                    , div [ class "row check-timer" ] [ text eventText ]
                    , shouldEdit
                    , eventsComponent model.currentTab model.events model.zone
                    ]
                ]

        Invoice when duration count ->
            div [] []



--            invoiceView when duration count
