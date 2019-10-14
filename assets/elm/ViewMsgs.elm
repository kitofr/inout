module ViewMsgs exposing (ViewMsg(..))

import DateUtil exposing (TimeDuration)
import Types exposing (DayItem, Event)


type ViewMsg
    = CheckIn
    | CheckOut
    | CloseEdit
    | CreateInvoice ( Int, Int ) TimeDuration Int
    | DateUpdated Event String
    | Delete Event
    | EditItem DayItem
    | GoHome
    | HourSelected Event String
    | Load
    | MinuteSelected Event String
    | TabClicked Int
    | Update Event
