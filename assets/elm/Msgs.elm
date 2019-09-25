module Msgs exposing (Msg(..))

import ApiMsgs exposing (ApiMsg)
import Browser
import Time exposing (Posix)
import Url exposing (Url)
import ViewMsgs exposing (ViewMsg)


type Msg
    = ApiEvent ApiMsg
    | Tick Posix
    | ViewEvent ViewMsg
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
