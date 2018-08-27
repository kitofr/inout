module DateUtil exposing
    ( DateRecord
    , TimeDuration
    , addTimeDurations
    , dateStr
    , dateToMonthStr
    , dateTuple
    , emptyTimeDuration
    , monthOrder
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
        ( Day(Fri, Mon, Sat, Sun, Thu, Tue, Wed)
        , Month(Apr, Aug, Dec, Feb, Jan, Jul, Jun, Mar, May, Nov, Oct, Sep)
        )
import Date.Extra.Compare exposing (Compare2, is)
import Date.Extra.Core exposing (monthToInt)
import Date.Extra.Duration exposing (DeltaRecord)
import Time exposing (Time)


type alias DateRecord =
    { year : Int
    , month : Int
    , day : Int
    , hour : Int
    , minute : Int
    , second : Int
    }


dateTuple : DateRecord -> ( Int, Int, Int )
dateTuple date =
    ( date.year, date.month, date.day )


dateStr : DateRecord -> String
dateStr date =
    toString date.year
        ++ "-"
        ++ toString date.month
        ++ "-"
        ++ toString date.day


timeTuple : DateRecord -> ( Int, Int, Int )
timeTuple date =
    ( date.hour, date.minute, date.second )


timeStr : DateRecord -> String
timeStr date =
    toString date.hour
        ++ ":"
        ++ toString date.minute
        ++ ":"
        ++ toString date.second


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


emptyDateRecord =
    { year = 1970
    , month = 1
    , day = 1
    , hour = 12
    , minute = 0
    , second = 0
    }



--parseStringDate : String -> DateRecord
--parseStringDate isoString =
--    Date.fromString isoString
--        |> Result.withDefault emptyDateRecord


sortDates : DateRecord -> DateRecord -> Order
sortDates a b =
    if
        (a.year > b.year)
            && (a.month > b.month)
            && (a.day > b.month)
            && (a.hour > b.hour)
            && (a.minute > b.minute)
            && (a.second > b.second)
    then
        GT

    else
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
            "WFT month: " ++ toString num


monthOrder : DateRecord -> Int
monthOrder date =
    date.month


dateToMonthStr : DateRecord -> String
dateToMonthStr date =
    toMonthStr date.month ++ " " ++ toString date.day


type alias TimeDuration =
    { hour : Int
    , minute : Int
    , second : Int
    }


toTimeDuration : DateRecord -> TimeDuration
toTimeDuration duration =
    { hour = duration.hour
    , minute = duration.minute
    , second = duration.second
    }


emptyTimeDuration : TimeDuration
emptyTimeDuration =
    { hour = 0, minute = 0, second = 0 }


addTime : Int -> ( Int, Int )
addTime t =
    ( t % 60, t // 60 )


addTimeDurations : TimeDuration -> TimeDuration -> TimeDuration
addTimeDurations a b =
    let
        sec =
            addTime (a.second + b.second)

        min =
            addTime (a.minute + b.minute + Tuple.second sec)

        hour =
            a.hour + b.hour + Tuple.second min
    in
    { second = Tuple.first sec
    , minute = Tuple.first min
    , hour = hour
    }


periodToStr : TimeDuration -> String
periodToStr period =
    -- List map toString |> String.join ?
    toString period.hour ++ "h " ++ toString period.minute ++ "min " ++ toString period.second ++ "sec"



-- The remaining time is represented in milliseconds. Here we
-- calculate the remaining number of days, hours, minutes, and seconds.
-- It returns a list of tuples that looks like this, for example:
-- [ ("days", "02"), ("hours", "06"), ("minutes", "15"), ("seconds", "03")]


timePeriods : Time -> List ( String, String )
timePeriods t =
    let
        seconds =
            floor (t / 1000) % 60

        minutes =
            floor (t / 1000 / 60) % 60

        hours =
            floor (t / (1000 * 60 * 60)) % 24

        days =
            floor (t / (1000 * 60 * 60 * 24))

        addLeadingZeros n =
            String.padLeft 2 '0' (toString n)
    in
    [ days, hours, minutes, seconds ]
        |> List.map addLeadingZeros
        |> List.map2 (,) [ "days", "hours", "minutes", "seconds" ]
