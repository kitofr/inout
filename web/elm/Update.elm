module Update exposing (setRoute, update)

import Api exposing (check, deleteEvent, getEvents, updateEvent)
import Date exposing (Date)
import Date.Extra.Create exposing (getTimezoneOffset)
import DateUtil exposing (DateRecord, dateStr, dateTuple, timeTuple, zeroPad)
import Msgs exposing (Msg(ApiEvent, SetRoute, Tick, ViewEvent))
import Navigation exposing (Location)
import Result exposing (withDefault)
import Route exposing (route)
import Types exposing (Event, Model, Page(..))
import UrlParser exposing (parsePath)
import ViewMsgs exposing (..)


updateMinute : DateRecord -> String -> DateRecord
updateMinute date min =
    { date | minute = String.toInt min |> withDefault 0 }


updateHour : DateRecord -> String -> DateRecord
updateHour date hour =
    { date | hour = String.toInt hour |> withDefault 0 }


changeEvent : List Event -> Event -> List Event
changeEvent lst e =
    List.map
        (\ev ->
            if ev.id == e.id then
                e

            else
                ev
        )
        lst



--createDateFromTime : Date -> String -> String
--createDateFromTime d str =
--    let
--        date_ =
--            d |> dateStr
--    in
--    date_ ++ "T" ++ str


createDateFromDate : DateRecord -> DateRecord -> DateRecord
createDateFromDate d str =
    let
        h =
            d.hour

        m =
            d.minute

        s =
            d.second
    in
    { str
        | hour = h
        , minute = m
        , second = s
    }


setRoute : Location -> Types.Model -> Types.Model
setRoute location model =
    let
        route =
            UrlParser.parsePath Route.route location
                |> Maybe.withDefault Route.Home
    in
    case route of
        Route.Home ->
            { model | page = Home }

        Route.Invoice ->
            { model | page = Invoice }


update : Msgs.Msg -> Model -> ( Model, Cmd Msgs.Msg )
update msg model =
    case msg of
        ApiEvent apiMsg ->
            Api.update apiMsg model

        ViewEvent (TabClicked year) ->
            ( { model | currentTab = year }, Cmd.none )

        ViewEvent CloseEdit ->
            ( { model | edit = Nothing }, Cmd.none )

        ViewEvent Load ->
            ( model, getEvents model.hostUrl )

        ViewEvent (Update event) ->
            ( model, updateEvent event model.hostUrl )

        ViewEvent (Delete event) ->
            ( model, deleteEvent event model.hostUrl )

        ViewEvent (EditItem dayItem) ->
            ( { model | edit = Just dayItem }, Cmd.none )

        ViewEvent CheckIn ->
            ( model, check "in" model.hostUrl )

        ViewEvent CheckOut ->
            ( model, check "out" model.hostUrl )

        ViewEvent (MinuteSelected event min) ->
            let
                dt =
                    updateMinute event.inserted_at min
                        |> Debug.log "selected minute"

                event_ =
                    { event | inserted_at = dt }

                edit =
                    case model.edit of
                        Just dayitem ->
                            Just { dayitem | events = changeEvent dayitem.events event_ }

                        _ ->
                            Nothing
            in
            ( { model | edit = edit }, Cmd.none )

        ViewEvent (HourSelected event hour) ->
            let
                dt =
                    updateHour event.inserted_at hour
                        |> Debug.log "selected hour"

                event_ =
                    { event | inserted_at = dt }

                edit =
                    case model.edit of
                        Just dayitem ->
                            Just { dayitem | events = changeEvent dayitem.events event_ }

                        _ ->
                            Nothing
            in
            ( { model | edit = edit }, Cmd.none )

        ViewEvent (TimeUpdated event timeString) ->
            --let
            --    time_ =
            --        time
            --            |> createDateFromTime event.inserted_at
            --    event_ =
            --        { event | inserted_at = time_ }
            --    edit =
            --        case model.edit of
            --            Just dayitem ->
            --                Just { dayitem | events = changeEvent dayitem.events event_ }
            --            _ ->
            --                Nothing
            --in
            ( { model | edit = Nothing }, Cmd.none )

        ViewEvent (DateUpdated event dateString) ->
            --let
            --    date_ =
            --        date
            --            |> createDateFromDate event.inserted_at
            --    event_ =
            --        { event | inserted_at = date_ }
            --    edit =
            --        case model.edit of
            --            Just dayitem ->
            --                Just { dayitem | events = changeEvent dayitem.events event_ }
            --            _ ->
            --                Nothing
            --in
            ( { model | edit = Nothing }, Cmd.none )

        SetRoute location ->
            ( setRoute location model, Cmd.none )

        Tick t ->
            let
                posix0 =
                    toPosix
                        { year = 1970
                        , month = 1
                        , day = 1
                        , hour = 0
                        , minute = 0
                        , second = 0
                        }

                foo =
                    Debug.log "checkInAt" model.checkInAt

                diff =
                    (t - posix0) - foo
            in
            ( { model | timeSinceLastCheckIn = diff }, Cmd.none )
