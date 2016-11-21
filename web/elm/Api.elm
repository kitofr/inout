module Api exposing (..)

import Json.Encode as Encode
import Json.Decode as JD exposing (Decoder, decodeValue, succeed, string, list, field)
import Json.Decode.Extra as Extra exposing ((|:))
import Http
import Task exposing (Task)
import Types exposing (..)


post : Decoder String -> String -> Encode.Value -> Cmd Msg
post decoder url body =
    Http.send CreateEvent <|
        Http.post url (Http.jsonBody body) decoder


check : String -> String -> Cmd Msg
check inOrOut hostUrl =
    let
        rec =
            Debug.log "encode" encodeEvent { status = "check-" ++ inOrOut, location = "tv4play" }
    in
        (post (succeed "") (hostUrl ++ "/events") rec)


getEvents : String -> Cmd Msg
getEvents hostUrl =
    Http.send LoadEvents <|
        Http.get (hostUrl ++ "/events.json") decodeEvents


decodeEvents : JD.Decoder (List Event)
decodeEvents =
    JD.succeed identity
        |: (field "events" (JD.list decodeEvent))


decodeEvent : JD.Decoder Event
decodeEvent =
    JD.map Event
        (field "status" JD.string)
        |: (field "location" JD.string)
        |: (field "device" JD.string)
        |: (field "inserted_at" Extra.date)
        |: (field "updated_at" Extra.date)


encodeEvent : { status : String, location : String } -> Encode.Value
encodeEvent record =
    Encode.object
        [ ( "event"
          , Encode.object
                [ ( "status", Encode.string <| record.status )
                , ( "location", Encode.string <| record.location )
                , ( "device", Encode.string <| "internetz" )
                ]
          )
        ]
