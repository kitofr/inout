module Update exposing (setRoute, update)

import Api exposing (check, deleteEvent, getEvents, updateEvent)
import Date exposing (Date)
import Date.Extra.Create exposing (getTimezoneOffset)
import DateUtil exposing (dateStr, dateTuple, parseStringDate, timeTuple, zeroPad)
import Msgs exposing (Msg(ApiEvent, SetRoute, Tick, ViewEvent))
import Navigation exposing (Location)
import Route exposing (route)
import Types exposing (Event, Model, Page(..))
import UrlParser exposing (parsePath)
import ViewMsgs exposing (..)


constructDate : String -> String -> String -> String -> String -> String -> Date
constructDate year month day hour min sec =
    (year ++ "-" ++ month ++ "-" ++ day ++ "T" ++ hour ++ ":" ++ min ++ ":" ++ sec)
        |> parseStringDate


updateMinute : Date -> String -> Date
updateMinute date min =
    let
        ( year, month, day ) =
            dateTuple date

        ( hour, _, sec ) =
            timeTuple date
    in
    constructDate year month day hour min sec


updateHour : Date -> String -> Date
updateHour date hour =
    let
        ( year, month, day ) =
            dateTuple date

        ( _, min, sec ) =
            timeTuple date
    in
    constructDate year month day hour min sec


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


createDateFromTime : Date -> String -> String
createDateFromTime d str =
    let
        date_ =
            d |> dateStr
    in
    date_ ++ "T" ++ str


createDateFromDate : Date -> String -> String
createDateFromDate d str =
    let
        h =
            Date.hour d |> toString |> zeroPad

        m =
            Date.minute d |> toString |> zeroPad

        s =
            Date.second d |> toString |> zeroPad
    in
    str
        ++ "T"
        ++ h
        ++ ":"
        ++ m
        ++ ":"
        ++ s


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
            { model | page = Home }


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
            let
                _ =
                    Debug.log ">>>>>>> model.edit" model.edit

                _ =
                    Debug.log ">>>>>>> event" event
            in
            ( model, updateEvent event model.hostUrl )

        ViewEvent (Delete event) ->
            ( model, deleteEvent event model.hostUrl )

        ViewEvent (EditItem dayItem) ->
            ( { model | edit = Just dayItem }, Cmd.none )

        ViewEvent CheckIn ->
            ( model, check "in" model.contract.name model.hostUrl )

        ViewEvent CheckOut ->
            ( model, check "out" model.contract.name model.hostUrl )

        ViewEvent GoHome ->
            ( { model | page = Home }, Cmd.none )

        ViewEvent (CreateInvoice ( year, month ) total dayCount) ->
            let
                _ =
                    Debug.log "INVOICE" ( year, month, total, dayCount )
            in
            ( { model | page = Invoice ( year, month ) total dayCount }, Cmd.none )

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
                _ =
                    Debug.log "selected hour" event.inserted_at

                dt =
                    updateHour event.inserted_at hour

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

        ViewEvent (TimeUpdated event time) ->
            let
                time_ =
                    time
                        |> createDateFromTime event.inserted_at
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
                date_ =
                    date
                        |> createDateFromDate event.inserted_at
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

        SetRoute location ->
            ( setRoute location model, Cmd.none )

        Tick t ->
            let
                min2Millsec min =
                    60
                        * 1000
                        * min
                        |> toFloat

                withTimeZone =
                    getTimezoneOffset (Date.fromTime model.checkInAt)
                        |> (\x ->
                                x
                                    * -1
                                    |> min2Millsec
                           )
            in
            ( { model | timeSinceLastCheckIn = t - model.checkInAt - withTimeZone }, Cmd.none )
