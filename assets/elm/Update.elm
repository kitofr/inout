module Update exposing (update)

import Api exposing (check, deleteEvent, getEvents, updateEvent)
import Browser
import Browser.Navigation as Navigation
import DateUtil exposing (..)
import Msgs exposing (Msg(..))
import Route exposing (route)
import Time exposing (..)
import Types exposing (DayItem, Event, Model, Page(..))
import Url
import Url.Parser exposing ((</>), Parser, int, map, oneOf, s, string, top)
import ViewMsgs exposing (..)


changeEvent : List Event -> Event -> List Event
changeEvent events event =
    List.map
        (\ev ->
            if ev.id == event.id then
                event

            else
                ev
        )
        events


updateEdit : Model -> Event -> Posix -> Maybe DayItem
updateEdit model event inserted =
    let
        event_ =
            { event | inserted_at = inserted }
    in
    case model.edit of
        Just dayitem ->
            Just { dayitem | events = changeEvent dayitem.events event_ }

        _ ->
            Nothing


update : Msgs.Msg -> Model -> ( Model, Cmd Msgs.Msg )
update msg model =
    case msg of
        ApiEvent apiMsg ->
            Api.update apiMsg model

        ViewEvent (TabClicked year) ->
            let
                _ =
                    Debug.log "year " year
            in
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
            let
                minute =
                    String.toInt min
                        |> Maybe.withDefault 0

                inserted =
                    Debug.log "minute" (changeMinuteInPosix model.zone event.inserted_at minute)

                edit =
                    updateEdit model event inserted
            in
            ( { model | edit = edit }, Cmd.none )

        ViewEvent (HourSelected event h) ->
            let
                hour =
                    String.toInt h
                        |> Maybe.withDefault 0

                inserted =
                    Debug.log "hour" (changeHourInPosix model.zone event.inserted_at hour)

                edit =
                    updateEdit model event inserted
            in
            ( { model | edit = edit }, Cmd.none )

        ViewEvent (DateUpdated event date) ->
            let
                inserted =
                    Debug.log "date" (changeDateInPosix model.zone event.inserted_at date)

                edit =
                    updateEdit model event inserted
            in
            ( { model | edit = edit }, Cmd.none )

        Tick t ->
            let
                min2Millsec min =
                    60
                        * 1000
                        * min
                        |> toFloat

                newTime =
                    Time.posixToMillis t
                        - Time.posixToMillis model.checkInAt
            in
            ( { model | timeSinceLastCheckIn = Time.millisToPosix newTime }, Cmd.none )
