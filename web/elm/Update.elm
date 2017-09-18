module Update exposing (update)

import Types exposing (..)
import Api exposing (..)
import DateUtil exposing (sortDates, parseStringDate, zeroPad, dateStr)
import Date.Extra.Compare as Compare exposing (is, Compare2(..))
import Date
import Msgs exposing (..)
import Date.Extra.Create exposing (getTimezoneOffset)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load ->
            ( model, getEvents model.hostUrl )

        Update event ->
            ( model, updateEvent event model.hostUrl )

        Delete event ->
            ( model, deleteEvent event model.hostUrl )

        EditItem dayItem ->
            ( { model | edit = Just dayItem }, Cmd.none )

        CheckIn ->
            ( model, (check "in" model.hostUrl) )

        CheckOut ->
            ( model, (check "out" model.hostUrl) )

        CheckEvent (Ok event) ->
            ( model, getEvents model.hostUrl )

        CheckEvent (Err _) ->
            ( model, Cmd.none )

        UpdateEvent (Ok event) ->
            let
                _ =
                    Debug.log "update event in update" event
            in
                ( { model | edit = Nothing }, getEvents model.hostUrl )

        UpdateEvent (Err _) ->
            ( model, Cmd.none )

        TimeUpdated event time ->
            let
                createDateFrom d str =
                    let
                        date_ =
                            d |> dateStr
                    in
                        date_ ++ " " ++ str

                time_ =
                    time
                        |> createDateFrom event.inserted_at
                        |> parseStringDate

                event_ =
                    { event | inserted_at = time_ }

                changeEvent lst e =
                    List.map
                        (\event ->
                            if event.id == e.id then
                                e
                            else
                                event
                        )
                        lst

                edit =
                    case model.edit of
                        Just dayitem ->
                            Just { dayitem | events = (changeEvent dayitem.events event_) }

                        _ ->
                            Nothing
            in
                ( { model | edit = edit }, Cmd.none )

        DateUpdated event date ->
            let
                createDateFrom d str =
                    let
                        h =
                            Date.hour d |> toString |> zeroPad

                        m =
                            Date.minute d |> toString |> zeroPad

                        s =
                            Date.second d |> toString |> zeroPad
                    in
                        str ++ " " ++ h ++ ":" ++ m ++ ":" ++ s

                date_ =
                    date
                        |> createDateFrom event.inserted_at
                        |> parseStringDate

                event_ =
                    { event | inserted_at = date_ }

                changeEvent lst e =
                    List.map
                        (\event ->
                            if event.id == e.id then
                                e
                            else
                                event
                        )
                        lst

                edit =
                    case model.edit of
                        Just dayitem ->
                            Just { dayitem | events = (changeEvent dayitem.events event_) }

                        _ ->
                            Nothing
            in
                ( { model | edit = edit }, Cmd.none )

        DeleteEvent (Ok event) ->
            let
                _ =
                    Debug.log "delete event in update" event
            in
                ( { model | edit = Nothing }, getEvents model.hostUrl )

        DeleteEvent (Err _) ->
            ( model, Cmd.none )

        LoadEvents (Ok events) ->
            let
                ev =
                    List.sortWith (\a b -> sortDates SameOrBefore a.inserted_at b.inserted_at) events

                first =
                    List.head ev

                checkedIn =
                    case first of
                        Just e ->
                            if e.status == "check-in" then
                                Date.toTime e.inserted_at
                            else
                                0

                        _ ->
                            0
            in
                ( { model | events = ev, checkInAt = checkedIn }, Cmd.none )

        LoadEvents (Err _) ->
            ( model, Cmd.none )

        Tick t ->
            let
                min2Millsec min =
                    60 * 1000 * min
                      |> toFloat

                withTimeZone =
                    getTimezoneOffset (Date.fromTime model.checkInAt)
                        |> \x -> x * -1
                        |> min2Millsec
            in
                ( { model | timeSinceLastCheckIn = t - model.checkInAt - withTimeZone }, Cmd.none )
