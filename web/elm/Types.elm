module Types exposing (..)

import Date exposing (Date)
import Date.Extra.Duration exposing (DeltaRecord, diff)
import Date.Extra.Compare exposing (Compare2(SameOrBefore))
import DateUtil exposing (sortDates)
import Time exposing (Time)


type alias Flags =
    { hostUrl : String }


type alias Event =
    { id : Int
    , status : String
    , location : String
    , device : String
    , inserted_at : Date
    , updated_at : Date
    }


type alias Model =
    { events : List Event
    , hostUrl : String
    , checkInAt : Time
    , edit : Maybe DayItem
    , timeSinceLastCheckIn : Time
    , currentTab : Int
    }


type alias DayItem =
    { date : Date
    , dateStr : String
    , diff : DeltaRecord
    , dayNumber : Int
    , events : List Event
    }



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
            case Date.fromString "2000-01-01" of
                Ok val ->
                    val

                Err _ ->
                    Debug.crash "Can't create date"
    in
        { id = 0
        , status = "empty"
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
        diff first.inserted_at last.inserted_at
