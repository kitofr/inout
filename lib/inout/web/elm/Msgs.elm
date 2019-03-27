module Msgs exposing (Msg(ApiEvent, Tick, ViewEvent, SetRoute))

import Navigation exposing (Location)
import Time exposing (Time)
import ApiMsgs exposing (ApiMsg)
import ViewMsgs exposing (ViewMsg)


type Msg
    = ApiEvent ApiMsg
    | Tick Time
    | ViewEvent ViewMsg
    | SetRoute Location
