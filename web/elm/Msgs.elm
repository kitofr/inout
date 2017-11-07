module Msgs exposing (Msg(ApiEvent, Tick, ViewEvent))

import Time exposing (Time)
import ApiMsgs exposing (ApiMsg)
import ViewMsgs exposing (ViewMsg)


type Msg
    = ApiEvent ApiMsg
    | Tick Time
    | ViewEvent ViewMsg
