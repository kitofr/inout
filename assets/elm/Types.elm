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

--import Date.Extra.Compare exposing (Compare2(..))
--import Date.Extra.Duration exposing (DeltaRecord, diff)

import DateUtil exposing (Compare2(..), DeltaRecord, TimeDuration, sortDates)
import Time exposing (..)


type alias Flags =
    { hostUrl : String }


type alias Event =
    { id : Int
    , status : String
    , location : String
    , device : String
    , posix : Int
    , inserted_at : Posix
    , updated_at : Posix
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
    , checkInAt : Posix
    , page : Page
    , edit : Maybe DayItem
    , timeSinceLastCheckIn : Posix
    , currentTab : Int
    , contract : Contract
    }


type alias DayItem =
    { date : Posix
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
    { id = 0
    , status = "empty"
    , location = "elm"
    , device = "none"
    , posix = 0
    , inserted_at = Time.millisToPosix 0
    , updated_at = Time.millisToPosix 0
    }


diff a b =
    { year = 0
    , month = 0
    , day = 0
    , hour = 0
    , minute = 0
    , second = 0
    , millisecond = 0
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
