module InOut exposing (main)

import Platform.Cmd as Cmd exposing (Cmd)
import Html exposing (..)
import Types exposing (..)
import Api exposing (..)
import View exposing (..)


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { events = [], hostUrl = flags.hostUrl }, getEvents flags.hostUrl )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load ->
            ( model, getEvents model.hostUrl )

        CheckIn ->
            ( model, (check "in" model.hostUrl) )

        CheckOut ->
            ( model, (check "out" model.hostUrl) )

        CreateEvent (Ok event) ->
            ( model, getEvents model.hostUrl )

        CreateEvent (Err _) ->
            ( model, Cmd.none )

        LoadEvents (Ok events) ->
            ( { model | events = events }, Cmd.none )

        LoadEvents (Err _) ->
            ( model, Cmd.none )
