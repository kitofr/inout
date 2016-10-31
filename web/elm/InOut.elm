module InOut exposing (main)

import Platform.Cmd as Cmd exposing (Cmd)
import Html.App as App exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)
import Task exposing (Task)
import Date exposing (..)
import List.Extra exposing (..)
import Types exposing (..)
import DateUtil exposing (..)
import Api exposing (..)
import Seq exposing (groupBy)
import View exposing (..)


main =
    App.programWithFlags
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

        FetchSucceed eventList ->
            ( { model | events = eventList }, Cmd.none )

        FetchFail error ->
            ( model, Cmd.none )

        CheckIn ->
            ( model, (check "in" model.hostUrl) )

        CheckOut ->
            ( model, (check "out" model.hostUrl) )

        HttpFail error ->
            ( model, Cmd.none )

        HttpSuccess things ->
            ( model, getEvents model.hostUrl )
