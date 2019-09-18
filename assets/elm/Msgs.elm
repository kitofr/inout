module Msgs exposing (Msg(..))

import ApiMsgs exposing (ApiMsg)
import Navigation exposing (Location)
import Time exposing (Time)
import ViewMsgs exposing (ViewMsg)


type Msg
    = ApiEvent ApiMsg
    | Tick Time
    | ViewEvent ViewMsg
    | SetRoute Location
