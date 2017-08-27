module DateUtil exposing (..)

import Time exposing (..)
import Date exposing (..)
import Date.Extra.Compare as Compare exposing (is, Compare2(..))
import Date.Extra.Duration as Duration exposing (..)

parseStringDate : String -> Date
parseStringDate isoString =
  Date.fromString isoString |> Result.withDefault (Date.fromTime 0)

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
            "WFT month: " ++ toString num



-- TODO this also need to take year in consideration
-- or I have to group on year first and make a monthType


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
            case (Date.dayOfWeek date) of
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
        day ++ " " ++ (toString <| Date.day date) ++ " " ++ month


type alias TimeDuration =
    { hour : Int, minute : Int, second : Int, millisecond : Int }


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
    ( t % 60, t // 60 )


addTimeDurations : TimeDuration -> TimeDuration -> TimeDuration
addTimeDurations a b =
    let
        mil =
            addTime (a.millisecond + b.millisecond)

        sec =
            addTime (a.second + b.second + (Tuple.second mil))

        min =
            addTime (a.minute + b.minute + (Tuple.second sec))

        hour =
            a.hour + b.hour + (Tuple.second min)
    in
        { millisecond = Tuple.first mil
        , second = Tuple.first sec
        , minute = Tuple.first min
        , hour = hour
        }


periodToStr : TimeDuration -> String
periodToStr period =
    (toString period.hour) ++ "h " ++ (toString period.minute) ++ "min " ++ (toString period.second) ++ "sec"



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
