module EditEvent exposing (edit)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick, onInput)
import Date exposing (Date)
import Date.Extra.Format exposing (utcIsoString)
import Msgs exposing (..)
import Types exposing (DayItem, Event)
import InputExtra exposing (dateInput, timeInput)


zeroPad : String -> String
zeroPad day =
    case (String.toInt day) of
        Ok num ->
            if num < 10 then
                "0" ++ day
            else
                day

        _ ->
            "00"

dateStr : Date -> String
dateStr date =
    let
        year =
            Date.year date |> toString

        month =
            case Date.month date of
                Date.Jan ->
                    "01"

                Date.Feb ->
                    "02"

                Date.Aug ->
                    "08"

                _ ->
                    "12"

        day =
            Date.day date
                |> toString
                |> zeroPad
    in
        year ++ "-" ++ month ++ "-" ++ day


timeStr : Date -> String
timeStr date =
    let
        hour =
            Date.hour date |> toString |> zeroPad

        min =
            Date.minute date |> toString |> zeroPad

        sec =
            Date.second date |> toString |> zeroPad
    in
        hour ++ ":" ++ min ++ ":" ++ sec

editEvent event =
    let
        _ =
            Debug.log "edit event" event
    in
        li []
            [ span [] [ text ((toString event.id) ++ ". " ++ event.status ++ " ") ]
            , dateInput [ onInput (DateUpdated event), value (dateStr event.inserted_at) ] []
            , timeInput [ onInput (TimeUpdated event), value (timeStr event.inserted_at) ] []
            , input
                [ value (utcIsoString event.inserted_at)
                , onInput (NewCheckInTime event)
                ]
                []
            , button [ onClick (Update event) ] [ text "Update" ]
            , button [ onClick (Delete event) ] [ text "Delete" ]
            ]


edit : DayItem -> Html Msg
edit dayItem =
    ul [ class "row" ]
        (List.map editEvent dayItem.events)
