module DateUtil exposing
    ( TimeDuration
    , addTimeDurations
    , dateStr
    , dateToMonthStr
    , dateTuple
    , emptyTimeDuration
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

import Date
    exposing
        ( Date
        , Day(..)
        , Month(..)
        )
import Date.Extra.Compare exposing (Compare2, is)
import Date.Extra.Core exposing (monthToInt)
import Date.Extra.Duration exposing (DeltaRecord)
import Time exposing (Time)


dateTuple : Date -> ( String, String, String )
dateTuple date =
    let
        year =
            Date.year date |> String.fromInt

        month =
            Date.month date
                |> monthToInt
                |> String.fromInt
                |> zeroPad

        day =
            Date.day date
                |> String.fromInt
                |> zeroPad
    in
    ( year, month, day )


dateStr : Date -> String
dateStr date =
    let
        ( year, month, day ) =
            dateTuple date
    in
    year ++ "-" ++ month ++ "-" ++ day


timeTuple : Date -> ( String, String, String )
timeTuple date =
    let
        hour =
            Date.hour date |> String.fromInt |> zeroPad

        min =
            Date.minute date |> String.fromInt |> zeroPad

        sec =
            Date.second date |> String.fromInt |> zeroPad
    in
    ( hour, min, sec )


timeStr : Date -> String
timeStr date =
    let
        ( hour, min, sec ) =
            timeTuple date
    in
    hour ++ ":" ++ min ++ ":" ++ sec


zeroPad : String -> String
zeroPad str =
    case String.toInt str of
        Ok num ->
            if num < 10 then
                "0" ++ str

            else
                str

        _ ->
            "00"


parseStringDate : String -> Date
parseStringDate isoString =
    let
        _ =
            Debug.log "isoString" isoString
    in
    Date.fromString isoString
        |> Result.withDefault (Date.fromTime 0)
        |> Debug.log "result in"


sortDates : Compare2 -> Date -> Date -> Order
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


monthOrder : Date -> Int
monthOrder date =
    case Date.month date of
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


dateToMonthStr : Date -> String
dateToMonthStr date =
    let
        day =
            case Date.dayOfWeek date of
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
            case Date.month date of
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
    day ++ " " ++ (String.fromInt <| Date.day date) ++ " " ++ month


type alias TimeDuration =
    { hour : Int
    , minute : Int
    , second : Int
    , millisecond : Int
    }


toTimeDuration : DeltaRecord -> TimeDuration
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


timePeriods : Time -> List ( String, String )
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
