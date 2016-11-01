module Types exposing (..)

import Date exposing (Date)
import Date.Extra.Duration as Duration exposing (..)
import Date.Extra.Compare as Compare exposing (is, Compare2(..))
import DateUtil exposing (..)
import Http


type alias Flags =
    { hostUrl : String }


type alias Event =
    { status : String
    , location : String
    , device : String
    , inserted_at : Date
    , updated_at : Date
    }


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



-- Util Functions


sortEvents : List Event -> Compare2 -> List Event
sortEvents events order =
    events
        |> List.sortWith (\a b -> sortDates order a.inserted_at b.inserted_at)


sortEventsDesc : List Event -> List Event
sortEventsDesc events =
    sortEvents events SameOrBefore


emptyEvent : Event
emptyEvent =
    let
        date =
            case Date.fromString ("2000-01-01") of
                Ok val ->
                    val

                Err err ->
                    Debug.crash "Can't create date"
    in
        { status = "empty"
        , location = "elm"
        , device = "none"
        , inserted_at = date
        , updated_at = date
        }


timeDifference : List Event -> DeltaRecord
timeDifference coll =
    let
        sorted =
            sortEvents coll SameOrBefore

        first =
            List.head sorted |> Maybe.withDefault emptyEvent

        last =
            List.reverse sorted |> List.head |> Maybe.withDefault emptyEvent
    in
        Duration.diff first.inserted_at last.inserted_at
