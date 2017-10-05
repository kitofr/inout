module Msgs exposing (..)

import Time exposing (Time, second)
import Types exposing (..)
import ApiMsgs exposing (ApiMsg)

type Msg
    = CheckIn
    | CheckOut
    | EditItem DayItem
    | DateUpdated Event String
    | TimeUpdated Event String
    | Tick Time
    | Load
    | Update Event
    | Delete Event
    | ApiEvent ApiMsg

