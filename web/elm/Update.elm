module Update exposing (update)

import Types exposing (Model, Event)
import Api exposing (getEvents, updateEvent, deleteEvent, check)
import DateUtil exposing (parseStringDate, zeroPad, dateStr)
import Date
import Msgs exposing (Msg(ApiEvent, ViewEvent, Tick))
import ViewMsgs exposing (..)
import Date.Extra.Create exposing (getTimezoneOffset)


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

        ViewEvent (TimeUpdated event time) ->
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

                edit =
                    case model.edit of
                        Just dayitem ->
                            Just { dayitem | events = changeEvent dayitem.events event_ }

                        _ ->
                            Nothing
            in
                ( { model | edit = edit }, Cmd.none )

        ViewEvent (DateUpdated event date) ->
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

                edit =
                    case model.edit of
                        Just dayitem ->
                            Just { dayitem | events = changeEvent dayitem.events event_ }

                        _ ->
                            Nothing
            in
                ( { model | edit = edit }, Cmd.none )

        Tick t ->
            let
                min2Millsec min =
                    60
                        * 1000
                        * min
                        |> toFloat

                withTimeZone =
                    getTimezoneOffset (Date.fromTime model.checkInAt)
                        |> \x ->
                            x
                                * -1
                                |> min2Millsec
            in
                ( { model | timeSinceLastCheckIn = t - model.checkInAt - withTimeZone }, Cmd.none )
