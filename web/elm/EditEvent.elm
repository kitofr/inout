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
  div []
  [ h3 [ style ["display" => "inline-block"]] [text ("Edit: " ++ dayItem.dateStr)]
  , button [
    style ["display" => "inline-block"
          ,"margin-left" => "20px"]
    , type_ "button"
    , class "btn btn-warning"
    , onClick (ViewEvent CloseEdit)] [
    span [] [text "close" ]
    ]
  , ul [ class "list-group" ]
        (List.map editEvent dayItem.events)
  ]
