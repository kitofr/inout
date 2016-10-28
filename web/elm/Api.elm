module Api exposing (..)

import Json.Encode as Encode
import Json.Decode as JD exposing (Decoder, decodeValue, succeed, string, list, (:=))
import Json.Decode.Extra as Extra exposing ((|:))
import Http
import Task exposing (Task)
import Types exposing (..)

post : Decoder value -> String -> Http.Body -> Task Http.Error value
post decoder url body =
  let request =
        { verb = "POST"
        , headers = [("Content-Type", "application/json")]
        , url = url
        , body = body
        }
  in
      Http.fromJson decoder (Http.send Http.defaultSettings request)

check : String -> String -> Cmd Msg
check inOrOut hostUrl=
  let rec = Debug.log "encode" encodeEvent { status = "check-" ++ inOrOut, location = "tv4play" }
  in
      Task.perform HttpFail HttpSuccess
        (post (succeed "") (hostUrl ++ "/events") (Debug.log "payload" (Http.string rec)))

getEvents : String -> Cmd Msg
getEvents hostUrl=
  Task.perform FetchFail FetchSucceed
    (Http.get decodeEvents (hostUrl ++ "/events.json"))

decodeEvents : JD.Decoder (List Event)
decodeEvents =
  JD.succeed identity
    |: ("events" := JD.list decodeEvent)

decodeEvent : JD.Decoder Event
decodeEvent =
    JD.map Event ("status" := JD.string)
        |: ("location" := JD.string)
        |: ("device" := JD.string)
        |: ("inserted_at" := Extra.date)
        |: ("updated_at" := Extra.date)

encodeEvent : { status: String, location: String } -> String
encodeEvent record =
    Encode.encode 0 (Encode.object
        [("event", Encode.object [
          ("status",  Encode.string <| record.status)
          , ("location",  Encode.string <| record.location)
          , ("device",  Encode.string <| "internetz")
          ])
        ])
