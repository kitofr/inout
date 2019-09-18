module Update exposing (setRoute, update)

import Api exposing (check, deleteEvent, getEvents, updateEvent)
import DateUtil exposing (dateStr, dateTuple, parseStringDate, timeTuple, zeroPad)
import Msgs exposing (Msg(..))
import Route exposing (route)
import Time exposing (..)
import Types exposing (Event, Model, Page(..))
import Url exposing (Parser(..), Url)
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


setRoute : Location -> Types.Model -> Types.Model
setRoute location model =
    let
        route =
            Url.Parser.parsePath Route.route location
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
            ( model, Cmd.none )

        ViewEvent (HourSelected event hour) ->
            ( model, Cmd.none )

        ViewEvent (TimeUpdated event time) ->
            ( model, Cmd.none )

        ViewEvent (DateUpdated event date) ->
            ( model, Cmd.none )

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
                    Date.fromTime model.checkInAt
                        |> (\x ->
                                x
                                    * -1
                                    |> min2Millsec
                           )
            in
            ( { model | timeSinceLastCheckIn = t - model.checkInAt - withTimeZone }, Cmd.none )
