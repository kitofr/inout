module Msgs exposing (..)

import Http
import Time exposing (Time, second)
import Types exposing (..)

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

type alias HttpResult a = (Result Http.Error a)

type ApiMsg 
  = CheckEvent (HttpResult String)
    | LoadEvents (HttpResult (List Event))
    | UpdateEvent (HttpResult String)
    | DeleteEvent (HttpResult String)
