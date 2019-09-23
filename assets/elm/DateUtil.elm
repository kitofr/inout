module DateUtil exposing
    ( Compare2(..)
    , Date
    , TimeDuration
    , addTimeDurations
    , dateStr
    , dateToMonthStr
    , dateTuple
    , emptyTimeDuration
    , is
    , monthOrder
    , parseStringDate
    , periodToStr
    , sortDates
    , timePeriods
    , timeStr
    , timeTuple
    , toMonthStr
    , toTimeDuration
    , zeroPad
    )

import Iso8601
import String exposing (..)
import Time exposing (..)


type alias Date =
    { year : Int
    , month : Time.Month
    , day : Int
    , weekDay : Time.Weekday
    , hour : Int
    , minute : Int
    , second : Int
    , millisecond : Int
    , posix : Time.Posix
    , zone : Time.Zone
    }


is : Compare2 -> Posix -> Posix -> Bool
is comp first second =
    let
        a =
            Time.posixToMillis first

        b =
            Time.posixToMillis second
    in
    case comp of
        After ->
            a > b

        Before ->
            a < b

        SameOrAfter ->
            a >= b

        SameOrBefore ->
            a <= b

        Same ->
            a == b


type Compare2
    = After
    | Before
    | Same
    | SameOrAfter
    | SameOrBefore


dateTuple : Posix -> Zone -> ( String, String, String )
dateTuple posix zone =
    let
        year =
            Time.toYear zone posix |> String.fromInt

        month =
            Time.toMonth zone posix
                |> monthToInt
                |> String.fromInt
                |> zeroPad

        day =
            Time.toDay zone posix
                |> String.fromInt
                |> zeroPad
    in
    ( year, month, day )


dateStr : Posix -> Zone -> String
dateStr posix zone =
    let
        ( year, month, day ) =
            dateTuple posix zone
    in
    year ++ "-" ++ month ++ "-" ++ day


timeTuple : Posix -> Zone -> ( String, String, String )
timeTuple posix zone =
    let
        hour =
            Time.toHour zone posix |> String.fromInt |> zeroPad

        min =
            Time.toMinute zone posix |> String.fromInt |> zeroPad

        sec =
            Time.toSecond zone posix |> String.fromInt |> zeroPad
    in
    ( hour, min, sec )


timeStr : Posix -> Zone -> String
timeStr posix zone =
    let
        ( hour, min, sec ) =
            timeTuple posix zone
    in
    hour ++ ":" ++ min ++ ":" ++ sec


zeroPad : String -> String
zeroPad str =
    case String.toInt str of
        Just num ->
            if num < 10 then
                "0" ++ str

            else
                str

        _ ->
            "00"


parseStringDate : String -> Posix
parseStringDate isoString =
    Iso8601.toTime isoString
        |> Result.withDefault (Time.millisToPosix 0)


sortDates : Compare2 -> Posix -> Posix -> Order
sortDates order a b =
    case is order a b of
        True ->
            GT

        _ ->
            LT


toMonthStr : Int -> String
toMonthStr num =
    case num of
        1 ->
            "Jan"

        2 ->
            "Feb"

        3 ->
            "Mar"

        4 ->
            "Apr"

        5 ->
            "May"

        6 ->
            "Jun"

        7 ->
            "Jul"

        8 ->
            "Aug"

        9 ->
            "Sep"

        10 ->
            "Oct"

        11 ->
            "Nov"

        12 ->
            "Dec"

        _ ->
            "WFT month: " ++ String.fromInt num


monthOrder : Posix -> Zone -> Int
monthOrder posix zone =
    case Time.toMonth zone posix of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12


dateToMonthStr : Posix -> Zone -> String
dateToMonthStr posix zone =
    let
        day =
            case Time.toWeekday zone posix of
                Mon ->
                    "Mon"

                Tue ->
                    "Tue"

                Wed ->
                    "Wed"

                Thu ->
                    "Thu"

                Fri ->
                    "Fri"

                Sat ->
                    "Sat"

                Sun ->
                    "Sun"

        month =
            case Time.toMonth zone posix of
                Jan ->
                    "Jan"

                Feb ->
                    "Feb"

                Mar ->
                    "Mar"

                Apr ->
                    "Apr"

                May ->
                    "May"

                Jun ->
                    "Jun"

                Jul ->
                    "Jul"

                Aug ->
                    "Aug"

                Sep ->
                    "Sep"

                Oct ->
                    "Oct"

                Nov ->
                    "Nov"

                Dec ->
                    "Dec"
    in
    day ++ " " ++ (String.fromInt <| Time.toDay zone posix) ++ " " ++ month


type alias TimeDuration =
    { hour : Int
    , minute : Int
    , second : Int
    , millisecond : Int
    }


toTimeDuration : Date -> TimeDuration
toTimeDuration duration =
    { hour = duration.hour
    , minute = duration.minute
    , second = duration.second
    , millisecond = duration.millisecond
    }


emptyTimeDuration : TimeDuration
emptyTimeDuration =
    { hour = 0, minute = 0, second = 0, millisecond = 0 }


addTime : Int -> ( Int, Int )
addTime t =
    ( modBy 60 t, t // 60 )


addTimeDurations : TimeDuration -> TimeDuration -> TimeDuration
addTimeDurations a b =
    let
        mil =
            addTime (a.millisecond + b.millisecond)

        sec =
            addTime (a.second + b.second + Tuple.second mil)

        min =
            addTime (a.minute + b.minute + Tuple.second sec)

        hour =
            a.hour + b.hour + Tuple.second min
    in
    { millisecond = Tuple.first mil
    , second = Tuple.first sec
    , minute = Tuple.first min
    , hour = hour
    }


periodToStr : TimeDuration -> String
periodToStr period =
    -- List map String.fromInt |> String.join ?
    String.fromInt period.hour ++ "h " ++ String.fromInt period.minute ++ "min " ++ String.fromInt period.second ++ "sec"



-- The remaining time is represented in milliseconds. Here we
-- calculate the remaining number of days, hours, minutes, and seconds.
-- It returns a list of tuples that looks like this, for example:
-- [ ("days", "02"), ("hours", "06"), ("minutes", "15"), ("seconds", "03")]


timePeriods : Float -> List ( String, String )
timePeriods t =
    let
        seconds =
            modBy 60 (floor (t / 1000))

        minutes =
            modBy 60 (floor (t / 1000 / 60))

        hours =
            modBy 24 (floor (t / (1000 * 60 * 60)))

        days =
            floor (t / (1000 * 60 * 60 * 24))

        addLeadingZeros n =
            String.padLeft 2 '0' (String.fromInt n)
    in
    [ days, hours, minutes, seconds ]
        |> List.map addLeadingZeros
        |> List.map2 (\a b -> ( a, b )) [ "days", "hours", "minutes", "seconds" ]


monthToInt : Month -> Int
monthToInt month =
    case month of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12
