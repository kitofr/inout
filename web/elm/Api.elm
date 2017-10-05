module Api exposing (..)

import Json.Encode as Encode
import Json.Decode as JD exposing (Decoder, succeed, field)
import Json.Decode.Extra exposing ((|:))
import Date exposing (Date)
import DateUtil exposing (sortDates)
import Date.Extra.Format exposing (utcIsoString)
import Date.Extra.Compare exposing (Compare2(SameOrBefore))
import Http
import Types exposing (Model, Event)
import Msgs exposing (Msg(ApiEvent))
import ApiMsgs exposing (ApiMsg(CheckEvent, UpdateEvent, DeleteEvent, LoadEvents))


update : ApiMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CheckEvent (Ok _) ->
            ( model, getEvents model.hostUrl )

        CheckEvent (Err _) ->
            ( model, Cmd.none )

        UpdateEvent (Ok event) ->
            let
                _ =
                    Debug.log "update event in update" event
            in
                ( { model | edit = Nothing }, getEvents model.hostUrl )

        UpdateEvent (Err _) ->
            ( model, Cmd.none )

        DeleteEvent (Ok event) ->
            let
                _ =
                    Debug.log "delete event in update" event
            in
                ( { model | edit = Nothing }, getEvents model.hostUrl )

        DeleteEvent (Err _) ->
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
                                Date.toTime e.inserted_at
                            else
                                0

                        _ ->
                            0
            in
                ( { model | events = ev, checkInAt = checkedIn }, Cmd.none )

        LoadEvents (Err _) ->
            ( model, Cmd.none )


post : Decoder String -> String -> Encode.Value -> Cmd Msg
post decoder url body =
    Http.send (ApiEvent << CheckEvent) <|
        Http.post url (Http.jsonBody body) decoder


check : String -> String -> Cmd Msg
check inOrOut hostUrl =
    let
        rec =
            createCheck { status = "check-" ++ inOrOut, location = "tv4play" }
    in
        (post (succeed "") (hostUrl ++ "/events") rec)


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
                , ( "inserted_at", Encode.string <| utcIsoString inserted_at )
                , ( "updated_at", Encode.string <| utcIsoString updated_at )
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
        updateRequest (hostUrl ++ "/events/" ++ toString event.id) event


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
        deleteRequest (hostUrl ++ "/events/" ++ toString event.id)


decodeEvents : JD.Decoder (List Event)
decodeEvents =
    JD.succeed identity
        |: field "events" (JD.list decodeEvent)


cetTime : String -> Decoder Date
cetTime str =
    let
        withTimeZone =
            str ++ "+02:00"
    in
        case Date.fromString withTimeZone of
            Ok d ->
                JD.succeed d

            Err e ->
                JD.fail e


decodeEvent : JD.Decoder Event
decodeEvent =
    JD.map Event
        (field "id" JD.int)
        |: field "status" JD.string
        |: field "location" JD.string
        |: field "device" JD.string
        |: (field "inserted_at" JD.string |> JD.andThen cetTime)
        |: (field "updated_at" JD.string |> JD.andThen cetTime)


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
