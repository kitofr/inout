module Api exposing (..)

import Json.Encode as Encode
import Json.Decode as JD exposing (Decoder, decodeValue, succeed, string, list, field)
import Json.Decode.Extra as Extra exposing ((|:))
import Http
import Task exposing (Task)
import Msgs exposing (..)
import Types exposing (..)


post : Decoder String -> String -> Encode.Value -> Cmd Msg
post decoder url body =
    Http.send CheckEvent <|
        Http.post url (Http.jsonBody body) decoder


check : String -> String -> Cmd Msg
check inOrOut hostUrl =
    let
        rec =
            Debug.log "encode" createCheck { status = "check-" ++ inOrOut, location = "tv4play" }
    in
        (post (succeed "") (hostUrl ++ "/events") rec)


getEvents : String -> Cmd Msg
getEvents hostUrl =
    Http.send LoadEvents <|
        Http.get (hostUrl ++ "/events.json") decodeEvents


updateEvent : Event -> String -> Cmd Msg
updateEvent event hostUrl =
    let
        _ =
            Debug.log "update" event
    in
        Cmd.none


delete : String -> Http.Request String
delete url =
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
    Http.send DeleteEvent <|
      delete (hostUrl ++ "/events/" ++ (toString event.id))


decodeEvents : JD.Decoder (List Event)
decodeEvents =
    JD.succeed identity
        |: (field "events" (JD.list decodeEvent))


decodeEvent : JD.Decoder Event
decodeEvent =
    JD.map Event
        (field "id" JD.int)
        |: (field "status" JD.string)
        |: (field "location" JD.string)
        |: (field "device" JD.string)
        |: (field "inserted_at" Extra.date)
        |: (field "updated_at" Extra.date)


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
