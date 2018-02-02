module EditEvent exposing (edit)

import Html exposing (li, div, span, text, button, ul, Html, h3)
import Html.Attributes exposing (type_, class, style, value)
import Html.Events exposing (onClick, onInput)
import Date exposing (Date)
import Msgs exposing (Msg(ViewEvent))
import ViewMsgs exposing (ViewMsg(DateUpdated, TimeUpdated, Update, Delete, CloseEdit))
import Types exposing (DayItem)
import InputExtra exposing (dateInput, timeInput)
import DateUtil exposing (dateStr, timeStr)
import HtmlExtra exposing ((=>))


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
    in
        li [ class "list-group-item" ]
            [ div []
                [ span
                    [ style [ "width" => "30px", "display" => "inline-block" ], class (shortText event.status) ]
                    []
                , dateInput [ marginLeft 10, onInput (ViewEvent << DateUpdated event), value (dateStr event.inserted_at) ] []
                , timeInput [ marginLeft 10, onInput (ViewEvent << TimeUpdated event), value (timeStr event.inserted_at) ] []
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
