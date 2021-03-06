module Api exposing (check, deleteEvent, getEvents, loadContract, update, updateEvent)

import ApiMsgs
    exposing
        ( ApiMsg(..)
        )
import DateUtil exposing (Compare2(..), sortDates)
import Http
import Iso8601 exposing (decoder)
import Json.Decode as JD exposing (Decoder, field, succeed)
import Json.Decode.Extra exposing (andMap)
import Json.Encode as Encode
import Msgs exposing (Msg(..))
import Time
import Types exposing (Contract, Event, Model)


update : ApiMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CheckEvent (Ok _) ->
            ( model, getEvents model.hostUrl )

        CheckEvent (Err _) ->
            ( model, Cmd.none )

        UpdateEvent (Ok _) ->
            ( { model | edit = Nothing }, getEvents model.hostUrl )

        UpdateEvent (Err _) ->
            ( model, Cmd.none )

        DeleteEvent (Ok _) ->
            ( { model | edit = Nothing }, getEvents model.hostUrl )

        DeleteEvent (Err _) ->
            ( model, Cmd.none )

        LoadContract (Ok contracts) ->
            let
                contract =
                    case contracts of
                        h :: _ ->
                            h

                        _ ->
                            Contract "None"
            in
            ( { model | contract = contract }, Cmd.none )

        LoadContract (Err err) ->
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
                                e.inserted_at

                            else
                                Time.millisToPosix 0

                        _ ->
                            Time.millisToPosix 0
            in
            ( { model | events = ev, checkInAt = checkedIn }, Cmd.none )

        LoadEvents (Err _) ->
            ( model, Cmd.none )


post : Decoder String -> String -> Encode.Value -> Cmd Msg
post decoder url body =
    Http.send (ApiEvent << CheckEvent) <|
        Http.post url (Http.jsonBody body) decoder


check : String -> String -> String -> Cmd Msg
check inOrOut contract hostUrl =
    let
        rec =
            createCheck { status = "check-" ++ inOrOut, location = contract }
    in
    post (succeed "") (hostUrl ++ "/events") rec


loadContract : String -> Cmd Msg
loadContract hostUrl =
    Http.send (ApiEvent << LoadContract) <|
        Http.get (hostUrl ++ "/contracts.json") decodeContracts


getEvents : String -> Cmd Msg
getEvents hostUrl =
    Http.send (ApiEvent << LoadEvents) <|
        Http.get (hostUrl ++ "/events.json") decodeEvents


encodeEvent : Event -> Encode.Value
encodeEvent { id, status, location, inserted_at, updated_at } =
    Encode.object
        [ ( "event"
          , Encode.object
                [ ( "id", Encode.int <| id )
                , ( "status", Encode.string <| status )
                , ( "location", Encode.string <| location )
                , ( "inserted_at", Encode.string <| Iso8601.fromTime inserted_at )
                , ( "updated_at", Encode.string <| Iso8601.fromTime updated_at )
                ]
          )
        ]


updateRequest : String -> Event -> Http.Request String
updateRequest url event =
    Http.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = Http.jsonBody <| encodeEvent event
        , expect = Http.expectStringResponse (\_ -> Ok "UPDATED")
        , timeout = Nothing
        , withCredentials = False
        }


updateEvent : Event -> String -> Cmd Msg
updateEvent event hostUrl =
    Http.send (ApiEvent << UpdateEvent) <|
        updateRequest (hostUrl ++ "/events/" ++ String.fromInt event.id) event


deleteRequest : String -> Http.Request String
deleteRequest url =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectStringResponse (\_ -> Ok "DELETED")
        , timeout = Nothing
        , withCredentials = False
        }


deleteEvent : Event -> String -> Cmd Msg
deleteEvent event hostUrl =
    Http.send (ApiEvent << DeleteEvent) <|
        deleteRequest (hostUrl ++ "/events/" ++ String.fromInt event.id)


decodeContracts : JD.Decoder (List Contract)
decodeContracts =
    JD.succeed identity
        |> andMap
            (field "contracts" (JD.list decodeContract))


decodeContract : JD.Decoder Contract
decodeContract =
    JD.map Contract
        (field "client" JD.string)


decodeEvents : JD.Decoder (List Event)
decodeEvents =
    JD.succeed identity
        |> andMap (field "events" (JD.list decodeEvent))


decodeEvent : JD.Decoder Event
decodeEvent =
    JD.succeed Event
        |> andMap (field "id" JD.int)
        |> andMap (field "status" JD.string)
        |> andMap (field "location" JD.string)
        |> andMap (field "device" JD.string)
        |> andMap (field "posix" JD.int)
        |> andMap (field "inserted_at" decoder)
        |> andMap (field "updated_at" decoder)


createCheck : { status : String, location : String } -> Encode.Value
createCheck record =
    Encode.object
        [ ( "event"
          , Encode.object
                [ ( "status", Encode.string <| record.status )
                , ( "location", Encode.string <| record.location )
                , ( "device", Encode.string <| "internetz" )
                ]
          )
        ]
