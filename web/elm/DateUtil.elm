module DateUtil exposing (..)

import Date exposing (..)
import Date.Extra.Compare as Compare exposing (is, Compare2 (..))

sortDates order a b =
  case is order a b of
    True -> GT
    _ -> LT

toMonthStr : Int -> String
toMonthStr num =
  case num of
    1 -> "Jan"
    2 -> "Feb"
    3 -> "Mar"
    4 -> "Apr"
    5 -> "May"
    6 -> "Jun"
    7 -> "Jul"
    8 -> "Aug"
    9 -> "Sep"
    10 -> "Oct"
    11 -> "Nov"
    12 -> "Dec"
    _ -> "wft month: " ++ toString num

monthOrder : Date -> Int
monthOrder date =
  case Date.month date of
    Jan -> 1
    Feb -> 2
    Mar -> 3
    Apr -> 4
    May -> 5
    Jun -> 6
    Jul -> 7
    Aug -> 8
    Sep -> 9
    Oct -> 10
    Nov -> 11
    Dec -> 12

dateToMonthStr : Date -> String
dateToMonthStr date =
  let month =
    case Date.month date of
      Jan -> "Jan"
      Feb -> "Feb"
      Mar -> "Mar"
      Apr -> "Apr"
      May -> "May"
      Jun -> "Jun"
      Jul -> "Jul"
      Aug -> "Aug"
      Sep -> "Sep"
      Oct -> "Oct"
      Nov -> "Nov"
      Dec -> "Dec"
  in
    month ++ " " ++ (toString <| Date.day date)

