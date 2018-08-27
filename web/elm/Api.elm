module Api exposing (check, deleteEvent, getEvents, update, updateEvent)

import ApiMsgs exposing (ApiMsg(CheckEvent, DeleteEvent, LoadEvents, UpdateEvent))
import Date.Extra.Compare exposing (Compare2(SameOrBefore))
import DateUtil exposing (DateRecord, sortDates)
import Http
import Json.Decode as JD exposing (Decoder, field, succeed)
import Json.Decode.Extra exposing ((|:))
import Json.Encode as Encode
import Msgs exposing (Msg(ApiEvent))
import Regex exposing (HowMany(All), find, regex)
import Seq exposing (nth)
import Types exposing (Event, Model)



--TODO Ok, this is shady as fuck


toPosix d =
    (31556926 * (d.year - 1970))
        + (2629743 * d.month)
        + (86400 * d.day)
        + (3600 * d.hour)
        + (60 * d.minute)
        + d.second
        |> toFloat


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

        LoadEvents (Ok events) ->
            let
                ev =
                    events
                        |> List.sortWith (\a b -> sortDates a.inserted_at b.inserted_at)

                first =
                    List.head ev

                checkedIn =
                    case first of
                        Just e ->
                            if e.status == "check-in" then
                                toPosix e.inserted_at

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
    post (succeed "") (hostUrl ++ "/events") rec


getEvents : String -> Cmd Msg
getEvents hostUrl =
    Http.send (ApiEvent << LoadEvents) <|
        Http.get (hostUrl ++ "/events.json") decodeEvents


utcIsoString : DateRecord -> String
utcIsoString { year, month, day, hour, minute, second } =
    toString year
        ++ "-"
        ++ toString month
        ++ "-"
        ++ toString day
        ++ "T"
        ++ toString hour
        ++ ":"
        ++ toString minute
        ++ ":"
        ++ toString second


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


fromString : String -> DateRecord
fromString d =
    let
        date =
            List.filterMap identity
                (nth
                    0
                    (find All (regex "(\\d{4})-([01]\\d)-([0-3]\\d)T([0-2]\\d):([0-5]\\d):([0-5]\\d)") d
                        |> List.map .submatches
                    )
                    []
                )
                |> List.map (\a -> String.toInt a |> Result.withDefault 0)
    in
    { year = nth 0 date 0
    , month = nth 1 date 0
    , day = nth 2 date 0
    , hour = nth 3 date 0
    , minute = nth 4 date 0
    , second = nth 5 date 0
    }


cetTime : String -> Decoder DateRecord
cetTime str =
    JD.succeed (fromString str)


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
