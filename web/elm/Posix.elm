module Posix exposing (getTimeStamp)

import Seq exposing (nth)


daysToMonth365 =
    [ 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365 ]


daysToMonth366 =
    [ 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366 ]


ticksInMillisecond =
    10000


ticksInSecond =
    ticksInMillisecond * 1000


getTimeStamp year month day hour minute second milliseconds =
    let
        timestamp =
            Result.map2 (+) (dateToTicks year month day) (timeToTicks hour minute second)
    in
    Result.map2 (+) timestamp (Ok (milliseconds * ticksInMillisecond))


isLeapYear year =
    if not ((year % 4) == 0) then
        False

    else if (year % 100) == 0 then
        (year % 400) == 0

    else
        True


dateToTicks : Int -> Int -> Int -> Result String Int
dateToTicks year month day =
    if ((year >= 1) && (year <= 9999)) && ((month >= 1) && (month <= 12)) then
        let
            daysToMonth month =
                if isLeapYear year then
                    nth month daysToMonth366 0

                else
                    nth month daysToMonth365 0
        in
        if (day >= 1) && (day <= (daysToMonth month - daysToMonth (month - 1))) then
            let
                previousYear =
                    year - 1

                daysInPreviousYears =
                    (((previousYear * 365) + (previousYear // 4)) - (previousYear // 100)) + (previousYear // 400)

                totalDays =
                    ((daysInPreviousYears + daysToMonth (month - 1)) + day) - 1
            in
            Ok (totalDays * 0x000000C92A69C000)

        else
            Err "Out of range"

    else
        Err "Out of range"


timeToTicks : Int -> Int -> Int -> Result String Int
timeToTicks hour minute second =
    let
        totalSeconds =
            ((hour * 3600) + (minute * 60)) + second
    in
    if (totalSeconds > 0x000000D6BF94D5E5) || (totalSeconds < -922337203685) then
        Err "Out of range"

    else
        Ok (totalSeconds * ticksInSecond)
