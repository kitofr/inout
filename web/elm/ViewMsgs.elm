module ViewMsgs exposing (ViewMsg(..))

import Types exposing (Event, DayItem)


type ViewMsg
    = CheckIn
    | CheckOut
    | DateUpdated Event String
    | Delete Event
    | EditItem DayItem
    | Load
    | TimeUpdated Event String
    | Update Event
    | TabClicked Int
