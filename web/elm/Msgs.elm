module Msgs exposing (..)

import Time exposing (Time, second)
import Types exposing (..)
import ApiMsgs exposing (ApiMsg)
import ViewMsgs exposing (ViewMsg)

type Msg
    = ApiEvent ApiMsg
    | Tick Time
    | ViewEvent ViewMsg

