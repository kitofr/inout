module EditEvent exposing (edit)

import Html exposing (li, div, span, text, button, ul, Html, h3)
import Html.Attributes exposing (type_, class, style, value)
import Html.Events exposing (targetValue, onClick, onInput, on)
import Date exposing (Date)
import Msgs exposing (Msg(ViewEvent))
import ViewMsgs exposing (ViewMsg(DateUpdated, TimeUpdated, Update, Delete, CloseEdit, HourSelected, MinuteSelected))
import Types exposing (DayItem)
import InputExtra exposing (dateInput, timeInput)
import DateUtil exposing (dateStr, timeStr, timeTuple)
import HtmlExtra exposing ((=>))
import Json.Decode exposing (map)


onChange : (String -> msg) -> Html.Attribute msg
onChange tagger =
    on "change" (Json.Decode.map tagger Html.Events.targetValue)


editEvent : { device : String, id : Int, inserted_at : Date, location : String, status : String, updated_at : Date } -> Html Msg
editEvent event =
    let
        marginLeft px =
            style [ "margin-left" => (toString px ++ "px") ]

        shortText text =
            case text of
                "check-in" ->
                    "glyphicon glyphicon-log-in"

                _ ->
                    "glyphicon glyphicon-log-out"

        ( hourPart, minutePart, _ ) =
            event.inserted_at
                |> timeTuple
    in
        li [ class "list-group-item" ]
            [ div []
                [ span
                    [ style [ "width" => "30px", "display" => "inline-block" ], class (shortText event.status) ]
                    []
                , dateInput [ marginLeft 10, onInput (ViewEvent << DateUpdated event), value (dateStr event.inserted_at) ] []
                , timeInput
                    [ marginLeft 10
                    , onChange (ViewEvent << HourSelected)
                    , value hourPart
                    ]
                    hourPart
                    (List.range 1 24)
                , timeInput
                    [ marginLeft 10
                    , onChange (ViewEvent << MinuteSelected)
                    , value minutePart
                    ]
                    minutePart
                    (List.range 1 59)
                , button [ marginLeft 10, class "btn btn-success", onClick (ViewEvent (Update event)) ] [ text "Update" ]
                , button [ class "btn btn-danger", onClick (ViewEvent (Delete event)) ] [ text "Delete" ]
                ]
            ]


edit : DayItem -> Html Msg
edit dayItem =
    div []
        [ h3 [ style [ "display" => "inline-block" ] ] [ text ("Edit: " ++ dayItem.dateStr) ]
        , button
            [ style
                [ "display" => "inline-block"
                , "margin-left" => "20px"
                ]
            , type_ "button"
            , class "btn btn-warning"
            , onClick (ViewEvent CloseEdit)
            ]
            [ span [] [ text "close" ]
            ]
        , ul [ class "list-group" ]
            (List.map editEvent dayItem.events)
        ]
