module View exposing (view)

import Browser
import Charts exposing (barChart)
import DateUtil exposing (Compare2(..), Date, TimeDuration, addTimeDurations, dateToMonthStr, emptyTimeDuration, monthOrder, periodToStr, sortDates, toMonthStr, toTimeDuration)
import Dict
import EditEvent exposing (edit)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
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


monthItem : { count : Int, year : Int, month : Int, total : TimeDuration, monthlyDayCount : List { hour : Int, minute : Int } } -> Element Msg
monthItem { count, year, month, total, monthlyDayCount } =
    let
        totalStr =
            periodToStr total

        dayCount =
            String.fromInt count

        dates =
            ( year, month )
    in
    column [ width fill, padding 2, Border.rounded 4, Border.width 1 ]
        [ row [ width fill, padding 2 ]
            [ text (toMonthStr month ++ " " ++ String.fromInt year) ]
        , row [ width fill ]
            [ column (border (rgb 155 123 39)) [ text totalStr ]
            , column [ alignRight ] [ text (dayCount ++ " days") ]
            ]
        , row [ width fill, padding 2 ] [ el [ centerX ] (html (barChart monthlyDayCount)) ]
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


border color =
    [ Border.width 1
    , Border.rounded 3
    , Border.color <| color
    ]


monthlyTotals : Bool -> List DayItem -> Zone -> Element Msg
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
    column [ width fill ]
        [ List.map monthItem sortedMonthTotals
            |> column [ width fill, height fill, spacing 3 ]
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


yearTab : Int -> ( Int, List Event ) -> Element Msg
yearTab currentTab ( year, _ ) =
    let
        active =
            if currentTab == year then
                Background.color <| rgb255 199 244 199

            else
                Background.color <| rgb255 199 199 199
    in
    el [ active, padding 2 ]
        (Input.button [] { onPress = Just (ViewEvent (TabClicked year)), label = text (String.fromInt year) })


groupedByYear : List Event -> Zone -> List ( Int, List Event )
groupedByYear events zone =
    groupBy (\x -> Time.toYear zone x.inserted_at) events
        |> Dict.toList
        |> List.sortWith (\( x, _ ) ( y, _ ) -> desc x y)


yearTabs : Int -> List Event -> Zone -> Element Msg
yearTabs currentTab events zone =
    let
        list =
            groupedByYear events zone
    in
    column
        (width fill :: border (rgb255 199 212 17))
        [ row []
            (List.map (yearTab currentTab) list)
        , column [ width fill ]
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


eventsComponent : Int -> List Event -> Zone -> Element Msg
eventsComponent currentTab events zone =
    let
        monthlySorted =
            sortedDayItems events zone
    in
    row [ width fill ]
        [ -- last6 monthlySorted
          yearTabs currentTab events zone
        ]


view : Model -> Element Msg
view model =
    let
        event =
            List.head model.events
                |> Maybe.withDefault emptyEvent

        eventText =
            String.fromInt (1000 * event.posix) ++ " " ++ String.fromInt (Time.toMillis model.zone event.inserted_at)

        --shouldEdit =
        --    case model.edit of
        --        Just dayItem ->
        --            edit dayItem model.zone
        --        _ ->
        --            row [] []
        buttonStyle bgColor =
            [ padding 2
            , Border.width 1
            , Border.rounded 3
            , Border.color <| rgb255 200 200 200
            , Background.color <| bgColor
            ]
    in
    case model.page of
        Home ->
            column
                [ width fill ]
                [ column
                    [ width fill
                    , Border.color <| rgb255 200 200 200
                    , Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
                    ]
                    [ row [ width fill ]
                        [ el [] <|
                            row []
                                [ text "Current contract: "
                                , link [] { url = "./contracts", label = text model.contract.name }
                                ]
                        , el [ alignRight ] (link [] { url = "./events", label = text "Events" })
                        ]
                    , row [ spacing 4, height (px 55), centerX ]
                        [ Input.button (buttonStyle (rgb255 163 244 164)) { onPress = Just (ViewEvent CheckIn), label = text "check in" }
                        , Input.button (buttonStyle (rgb255 164 164 244)) { onPress = Just (ViewEvent CheckOut), label = text "check out" }
                        ]

                    --, row [] (viewTimeSinceLastCheckIn model.timeSinceLastCheckIn)
                    -- -- -- -- -- -- -- -- -- , row [ centerX ] [ text eventText ]
                    --, shouldEdit
                    ]
                , eventsComponent model.currentTab model.events model.zone
                ]

        Invoice when duration count ->
            row [] []



--            invoiceView when duration count
