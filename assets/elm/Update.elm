module Update exposing (update)

import Api exposing (check, deleteEvent, getEvents, updateEvent)
import Browser.Navigation as Navigation
import DateUtil exposing (dateStr, dateTuple, parseStringDate, timeTuple, zeroPad)
import Msgs exposing (Msg(..))
import Route exposing (route)
import Time exposing (..)
import Types exposing (Event, Model, Page(..))
import Url.Parser exposing ((</>), Parser, int, map, oneOf, s, string, top)
import ViewMsgs exposing (..)


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
            ( model, check "in" model.contract.name model.hostUrl )

        ViewEvent CheckOut ->
            ( model, check "out" model.contract.name model.hostUrl )

        ViewEvent GoHome ->
            ( { model | page = Home }, Cmd.none )

        ViewEvent (CreateInvoice ( year, month ) total dayCount) ->
            ( { model | page = Invoice ( year, month ) total dayCount }, Cmd.none )

        ViewEvent (MinuteSelected event min) ->
            ( model, Cmd.none )

        ViewEvent (HourSelected event hour) ->
            ( model, Cmd.none )

        ViewEvent (TimeUpdated event time) ->
            ( model, Cmd.none )

        ViewEvent (DateUpdated event date) ->
            ( model, Cmd.none )

        SetRoute location ->
            ( model, Cmd.none )

        Tick t ->
            let
                min2Millsec min =
                    60
                        * 1000
                        * min
                        |> toFloat
            in
            ( { model | timeSinceLastCheckIn = Time.millisToPosix (Time.posixToMillis t - Time.posixToMillis model.checkInAt) }, Cmd.none )
