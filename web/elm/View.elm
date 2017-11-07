module View exposing (view)

import Html exposing (text, a, p, h5, li, Html, div, ul, span, h3, button)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Date
import Date.Extra.Compare exposing (Compare2(SameOrBefore))
import Dict
import Date.Extra.Duration exposing (DeltaRecord)
import Charts exposing (barChart)
import DateUtil exposing (dateToMonthStr, periodToStr, TimeDuration, addTimeDurations, emptyTimeDuration, toTimeDuration, toMonthStr, monthOrder, sortDates)
import Types exposing (Event, emptyEvent, timeDifference, DayItem, Model)
import Msgs exposing (Msg(ViewEvent))
import Seq exposing (groupBy, desc)
import Last5 exposing (last5)
import EditEvent exposing (edit)
import TimeSinceLastCheckIn exposing (viewTimeSinceLastCheckIn)
import ViewMsgs exposing (ViewMsg(Load, CheckIn, CheckOut, TabClicked))


monthItem : { count : Int, year : Int, month : String, total : TimeDuration, monthlyDayCount : List { hour : Int, minute : Int } } -> Html Msg
monthItem month =
    li [ class "list-group-item list-group-item-success row" ]
        [ h5 [ class "list-group-item-heading" ] [ text (month.month ++ " " ++ toString month.year) ]
        , p [ class "list-group-item-text monthly-hours col-md-6" ] [ text (periodToStr month.total) ]
        , p [ class "list-group-item-text monthly-count col-md-2" ] [ text (toString month.count) ]
        , p [ class "list-group-item-text monthly-chart col-md-6" ] [ barChart month.monthlyDayCount ]
        ]


monthlySum : List { a | diff : DeltaRecord } -> TimeDuration
monthlySum month =
    List.foldl addTimeDurations emptyTimeDuration (List.map (\y -> toTimeDuration y.diff) month)


totalsRect : ( Int, List { a | date : Date.Date, diff : { day : Int, millisecond : Int, month : Int, second : Int, year : Int, hour : Int, minute : Int } } ) -> { count : Int, month : String, monthlyDayCount : List { hour : Int, minute : Int }, total : TimeDuration, year : Int }
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
        , month = toMonthStr (Tuple.first rec)
        , total = monthlySum data
        , count =
            List.length data
        , monthlyDayCount =
            List.map (\x -> { hour = x.diff.hour, minute = x.diff.minute }) data
        }


monthlyTotals :
    Bool
    -> List
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
                |> List.sortWith
                    (\a b ->
                        case a.year > b.year of
                            True ->
                                LT

                            _ ->
                                GT
                    )
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
        dayItems |> List.sortWith (\a b -> sortDates SameOrBefore a.date b.date)


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
    groupBy (\x -> Date.year x.inserted_at) events
        |> Dict.toList
        |> List.sortWith (\( a, _ ) ( b, _ ) -> desc a b)


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
            [ --last5 monthlySorted
              yearTabs currentTab events
            ]


view : Model -> Html Msg
view model =
    let
        shouldEdit =
            case model.edit of
                Just dayItem ->
                    (edit dayItem)

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
