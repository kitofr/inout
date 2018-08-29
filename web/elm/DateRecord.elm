module DateRecord exposing (DateRecord, diff, sortDates)

import Posix exposing (getTimeStamp)


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


monthOrder : DateRecord -> Int
monthOrder date =
    date.month


dateToMonthStr : DateRecord -> String
dateToMonthStr date =
    toMonthStr date.month ++ " " ++ toString date.day


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


sortDates : DateRecord -> DateRecord -> Order
sortDates a b =
    let
        posixA =
            getTimeStamp a.year a.month a.day a.hour a.minute a.second 0

        posixB =
            getTimeStamp b.year b.month b.day b.hour b.minute b.second 0
    in
    case ( posixA, posixB ) of
        ( Ok aValue, Ok bValue ) ->
            if aValue > bValue then
                GT

            else if aValue == bValue then
                EQ

            else
                LT

        ( _, _ ) ->
            --TODO we encountered an error...
            let
                _ =
                    Debug.log "posixA or posixB is errornus" ( posixA, posixB )
            in
            GT


emptyDateRecord =
    { year = 1970
    , month = 1
    , day = 1
    , hour = 12
    , minute = 0
    , second = 0
    }


diff : DateRecord -> DateRecord -> DateRecord
diff start end =
    let
        removeOne rem e s =
            if rem < 0 then
                (e - 1) - s

            else
                e - s

        handle60 t =
            if t < 0 then
                60 + t

            else
                t

        seconds =
            end.second - start.second

        minutes =
            removeOne seconds end.minute start.minute

        hours =
            removeOne minutes end.hour start.hour
    in
    { year = end.year - start.year
    , month = end.month - start.month
    , day = end.day - start.day
    , hour = hours
    , minute = handle60 minutes
    , second = handle60 seconds
    }
