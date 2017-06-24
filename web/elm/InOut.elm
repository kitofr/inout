module InOut exposing (main)

import Platform.Cmd as Cmd exposing (Cmd)
import Time exposing (Time, second)
import Html exposing (..)
import Types exposing (..)
import Api exposing (..)
import View exposing (..)
import DateUtil exposing (sortDates)
import Date.Extra.Compare as Compare exposing (is, Compare2(..))
import Date


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.checkInAt of
        0 ->
            Sub.none

        _ ->
            Time.every second Tick


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( 
      { events = []
      , hostUrl = flags.hostUrl
      , checkInAt = 0
      , timeSinceLastCheckIn = 0 
      , edit = Nothing
      }, getEvents flags.hostUrl )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load ->
            ( model, getEvents model.hostUrl )

        Delete event ->
            (model, Cmd.none )

        EditItem dayItem ->
            ( { model | edit = Just dayItem }, Cmd.none )

        CheckIn ->
            ( model, (check "in" model.hostUrl) )

        CheckOut ->
            ( model, (check "out" model.hostUrl) )

        CreateEvent (Ok event) ->
            ( model, getEvents model.hostUrl )

        CreateEvent (Err _) ->
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
