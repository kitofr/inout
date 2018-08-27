module Types exposing
    ( DayItem
    , Event
    , Flags
    , Model
    , Page(..)
    , diff
    , emptyEvent
    , timeDifference
    )

import Date.Extra.Compare exposing (Compare2(SameOrBefore))
import DateUtil exposing (DateRecord, sortDates)
import Time exposing (Time)


type alias Flags =
    { hostUrl : String }


type alias Event =
    { id : Int
    , status : String
    , location : String
    , device : String
    , inserted_at : DateRecord
    , updated_at : DateRecord
    }


type alias Month =
    String


type Page
    = Home
    | Invoice


type alias Model =
    { events : List Event
    , hostUrl : String
    , checkInAt : Time
    , page : Page
    , edit : Maybe DayItem
    , timeSinceLastCheckIn : Time
    , currentTab : Int
    }


type alias DayItem =
    { date : DateRecord
    , dateStr : String
    , diff : DateRecord
    , dayNumber : Int
    , events : List Event
    }



-- Util Functions


sortEvents : List Event -> List Event
sortEvents events =
    events
        |> List.sortWith (\a b -> sortDates a.inserted_at b.inserted_at)


emptyEvent : Event
emptyEvent =
    let
        date =
            { year = 2015
            , month = 1
            , day = 1
            , hour = 12
            , minute = 0
            , second = 0
            }
    in
    { id = 0
    , status = "empty"
    , location = "elm"
    , device = "none"
    , inserted_at = date
    , updated_at = date
    }


diff : DateRecord -> DateRecord -> DateRecord
diff start end =
    let
        removeOne rem e s =
            if rem < 0 then
                (e - 1) - s

            else
                e - s

        handle60 t =
            if t < 0 then
                60 + t

            else
                t

        seconds =
            end.second - start.second

        minutes =
            removeOne seconds end.minute start.minute

        hours =
            removeOne minutes end.hour start.hour
    in
    { year = end.year - start.year
    , month = end.month - start.month
    , day = end.day - start.day
    , hour = hours
    , minute = handle60 minutes
    , second = handle60 seconds
    }


timeDifference : List Event -> DateRecord
timeDifference coll =
    let
        sorted =
            sortEvents coll

        first =
            List.head sorted |> Maybe.withDefault emptyEvent

        last =
            List.reverse sorted |> List.head |> Maybe.withDefault emptyEvent
    in
    diff first.inserted_at last.inserted_at
