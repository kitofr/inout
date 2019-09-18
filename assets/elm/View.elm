module View exposing (view)

import Charts exposing (barChart)
import DateUtil exposing (Compare2(..), DeltaRecord, TimeDuration, addTimeDurations, dateToMonthStr, emptyTimeDuration, monthOrder, periodToStr, sortDates, toMonthStr, toTimeDuration)
import Dict
import EditEvent exposing (edit)
import Html exposing (Html, a, button, div, h3, h5, li, p, text, ul)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Invoice exposing (invoiceView)
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
            , p [ class "list-group-item-text col-md-1 col-xs-3" ]
                [ button [ class "btn btn-sm btn-danger", onClick (ViewEvent (CreateInvoice dates total count)) ] [ text "Invoice" ] ]
            ]
        , div [ class "row" ]
            [ p [ class "list-group-item-text monthly-chart col-md-8" ] [ barChart monthlyDayCount ]
            ]
        ]


monthlySum : List { a | diff : DeltaRecord } -> TimeDuration
monthlySum month =
    List.foldl addTimeDurations emptyTimeDuration (List.map (\y -> toTimeDuration y.diff) month)


totalsRect :
    ( Int
    , List
        { a
            | date : Date.Date
            , diff :
                { day : Int
                , millisecond : Int
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
                    Date.year d.date

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
                    , millisecond : Int
                    , minute : Int
                    , month : Int
                    , second : Int
                    , year : Int
                    }
                , date : Date.Date
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
                    , dayNumber = Date.day date
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
        [ a [ class "nav-link", onClick (ViewEvent (TabClicked year)) ] [ text (String.fromInt year) ]
        ]


groupedByYear : List Event -> List ( Int, List Event )
groupedByYear events =
    groupBy (\x -> Date.year x.inserted_at) events
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
        [ last6 monthlySorted
        , yearTabs currentTab events
        ]


view : Model -> Html Msg
view model =
    let
        event =
            List.head model.events
                |> Maybe.withDefault emptyEvent

        eventText =
            String.fromInt (1000 * event.posix) ++ " " ++ String.fromInt event.inserted_at

        shouldEdit =
            case model.edit of
                Just dayItem ->
                    edit dayItem

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
                    , eventsComponent model.currentTab model.events
                    ]
                ]

        Invoice when duration count ->
            invoiceView when duration count
