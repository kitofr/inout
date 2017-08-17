module Msgs exposing (..)

import Http
import Time exposing (Time, second)
import Types exposing (..)

type Msg
    = CheckIn
    | CheckOut
    | Load
    | EditItem DayItem
    | Delete Event
    | Update Event
    | ApiEvent (Result Http.Error String)
    | LoadEvents (Result Http.Error (List Event))
    | Tick Time
