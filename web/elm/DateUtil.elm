module DateUtil exposing
    ( TimeDuration
    , addTimeDurations
    , emptyTimeDuration
    , periodToStr
    , timePeriods
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
import DateRecord exposing (DateRecord)
import Posix exposing (getTimeStamp)
import Time exposing (Time)


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
