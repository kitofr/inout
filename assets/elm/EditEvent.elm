module EditEvent exposing (edit)

import DateUtil exposing (dateStr, timeStr, timeTuple)
import Html exposing (Html, button, div, h3, li, span, text, ul)
import Html.Attributes exposing (class, style, type_, value)
import Html.Events exposing (on, onClick, onInput, targetValue)
import HtmlExtra exposing ((=>))
import InputExtra exposing (dateInput, timeInput)
import Json.Decode exposing (map)
import Msgs exposing (Msg(ViewEvent))
import Types exposing (DayItem, Event)
import ViewMsgs exposing (ViewMsg(CloseEdit, DateUpdated, Delete, HourSelected, MinuteSelected, TimeUpdated, Update))


onChange : (String -> msg) -> Html.Attribute msg
onChange tagger =
    on "change" (Json.Decode.map tagger Html.Events.targetValue)


editEvent : Types.Event -> Html Msg
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
                , onChange (ViewEvent << HourSelected event)
                , value hourPart
                ]
                hourPart
                (List.range 0 23)
            , timeInput
                [ marginLeft 10
                , onChange (ViewEvent << MinuteSelected event)
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
