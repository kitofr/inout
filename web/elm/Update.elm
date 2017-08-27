module Update exposing (update)

import Types exposing (..)
import Api exposing (..)
import DateUtil exposing (sortDates, parseStringDate)
import Date.Extra.Compare as Compare exposing (is, Compare2(..))
import Date
import Msgs exposing (..)


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
          let _ = Debug.log "update event in update" event
          in
          ( { model | edit = Nothing }, getEvents model.hostUrl )

        UpdateEvent (Err _) ->
          ( model, Cmd.none )

        NewCheckInTime event time ->
          let event_ = { event | inserted_at = parseStringDate time }
                  |> Debug.log "new event"

              changeEvent lst e =
                List.map (\event ->
                  if event.id == e.id then
                    e
                  else
                    event) lst

              edit = case model.edit of
                      Just dayitem ->
                        Just { dayitem | events = (changeEvent dayitem.events event_) }
                      _ -> Nothing
          in
            ( { model | edit = edit } , Cmd.none )


        DeleteEvent (Ok event) ->
          let _ = Debug.log "delete event in update" event
          in
          ( { model | edit = Nothing }, getEvents model.hostUrl )

        DeleteEvent (Err _) ->
          ( model, Cmd.none )

        LoadEvents (Ok events) ->
            let
                ev =
                    List.sortWith (\a b -> sortDates SameOrBefore a.inserted_at b.inserted_at) events

                --|> Debug.log "events"
                first =
                    List.head ev

                checkedIn =
                    case first of
                        Just e ->
                            let
                                _ =
                                    Debug.log "e" e
                            in
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
            ( { model | timeSinceLastCheckIn = t - model.checkInAt }, Cmd.none )
