module Msgs exposing (..)

import Http
import Time exposing (Time, second)
import Types exposing (..)

type Msg
    = CheckIn
    | CheckEvent (Result Http.Error String)
    | CheckOut
    | Delete Event
    | DeleteEvent (Result Http.Error String)
    | EditItem DayItem
    | Load
    | LoadEvents (Result Http.Error (List Event))
    | Tick Time
    | Update Event
    | UpdateEvent (Result Http.Error String)
