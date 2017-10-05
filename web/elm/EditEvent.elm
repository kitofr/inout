module EditEvent exposing (edit)

import Html exposing (li, div, span, text, button, ul, Html)
import Html.Attributes exposing (class, style, value)
import Html.Events exposing (onClick, onInput)
import Date exposing (Date)
import Msgs exposing (Msg(ViewEvent))
import ViewMsgs exposing (ViewMsg(DateUpdated, TimeUpdated, Update, Delete))
import Types exposing (DayItem)
import InputExtra exposing (dateInput, timeInput)
import DateUtil exposing (dateStr, timeStr)
import HtmlExtra exposing ((=>))


editEvent : { device : String, id : Int, inserted_at : Date, location : String, status : String, updated_at : Date } -> Html Msg
editEvent event =
    let
        marginLeft px =
            style [ "margin-left" => (toString px ++ "px") ]
    in
        li [ class "list-group-item" ]
            [ div []
                [ span [ style [ "width" => "100px", "display" => "inline-block" ] ] [ text (toString event.id ++ ". " ++ event.status ++ " ") ]
                , dateInput [ marginLeft 20, onInput (ViewEvent << DateUpdated event), value (dateStr event.inserted_at) ] []
                , timeInput [ marginLeft 20, onInput (ViewEvent << TimeUpdated event), value (timeStr event.inserted_at) ] []
                , button [ marginLeft 20, class "btn btn-success", onClick (ViewEvent (Update event)) ] [ text "Update" ]
                , button [ class "btn btn-danger", onClick (ViewEvent (Delete event)) ] [ text "Delete" ]
                ]
            ]


edit : DayItem -> Html Msg
edit dayItem =
    ul [ class "list-group" ]
        (List.map editEvent dayItem.events)
