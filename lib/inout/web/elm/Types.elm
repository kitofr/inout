module Types exposing
    ( Contract
    , DayItem
    , Event
    , Flags
    , Model
    , Page(..)
    , emptyEvent
    , timeDifference
    )

import Date exposing (Date)
import Date.Extra.Compare exposing (Compare2(SameOrBefore))
import Date.Extra.Duration exposing (DeltaRecord, diff)
import DateUtil exposing (TimeDuration, sortDates)
import Time exposing (Time)


type alias Flags =
    { hostUrl : String }


type alias Event =
    { id : Int
    , status : String
    , location : String
    , device : String
    , posix : Int
    , inserted_at : Date
    , updated_at : Date
    }


type alias Month =
    String


type Page
    = Home
    | Invoice ( Int, Int ) TimeDuration Int


type alias Contract =
    { name : String }


type alias Model =
    { events : List Event
    , hostUrl : String
    , checkInAt : Time
    , page : Page
    , edit : Maybe DayItem
    , timeSinceLastCheckIn : Time
    , currentTab : Int
    , contract : Contract
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
    , posix = 0
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
