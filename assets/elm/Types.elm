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

import Browser.Navigation as Nav
import DateUtil exposing (Compare2(..), Date, TimeDuration, sortDates)
import Time exposing (..)
import Url


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
    , zone : Zone
    , page : Page
    , edit : Maybe DayItem
    , timeSinceLastCheckIn : Posix
    , currentTab : Int
    , contract : Contract

    --    , key : Nav.Key
    --    , url : Url.Url
    }


type alias DayItem =
    { date : Posix
    , dateStr : String
    , diff : Date
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


toDate : Time.Zone -> Time.Posix -> Date
toDate zone time =
    { year = Time.toYear zone time
    , month = Time.toMonth zone time
    , day = Time.toDay zone time
    , weekDay = Time.toWeekday zone time
    , hour = Time.toHour zone time
    , minute = Time.toMinute zone time
    , second = Time.toSecond zone time
    , millisecond = Time.toMillis zone time
    , posix = time
    , zone = zone
    }


diff : Posix -> Posix -> Date
diff a b =
    let
        d =
            Time.posixToMillis a
                - Time.posixToMillis b
    in
    toDate Time.utc (Time.millisToPosix d)


timeDifference : List Event -> Date
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
