module Types exposing (..)

import Date exposing (Date)
import Http


type alias Event =
    { status : String
    , location : String
    , device : String
    , inserted_at : Date
    , updated_at : Date
    }


type alias Flags =
    { hostUrl : String }


type alias Model =
    { events : List Event
    , hostUrl : String
    }


type Msg
    = CheckIn
    | CheckOut
    | Load
    | FetchSucceed (List Event)
    | FetchFail Http.Error
    | HttpSuccess String
    | HttpFail Http.Error
