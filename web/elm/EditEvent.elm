module EditEvent exposing (edit)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick, onInput)
import Date exposing (Date)
import Date.Extra.Format exposing (utcIsoString)
import Msgs exposing (Msg(ViewEvent))
import ViewMsgs exposing (ViewMsg(DateUpdated, TimeUpdated, Update, Delete))
import Types exposing (DayItem, Event)
import InputExtra exposing (dateInput, timeInput)
import DateUtil exposing (..)


editEvent event =
    let
        _ =
            Debug.log "edit event" event
    in
        li [ class "list-group-item" ]
            [ 
              div [ ] [
                span [style [("width", "100px"), ("display","inline-block")]] [ text ((toString event.id) ++ ". " ++ event.status ++ " ") ]
              , dateInput [ style [("margin-left", "20px")], onInput (ViewEvent << (DateUpdated event)), value (dateStr event.inserted_at) ] []
              , timeInput [ style [("margin-left", "20px")], onInput (ViewEvent << (TimeUpdated event)), value (timeStr event.inserted_at) ] []
              , button [ style [("margin-left", "20px")], class "btn btn-success", onClick (ViewEvent (Update event)) ] [ text "Update" ]
              , button [ class "btn btn-danger", onClick (ViewEvent (Delete event)) ] [ text "Delete" ]
              ]
            ]


edit : DayItem -> Html Msg
edit dayItem =
    ul [ class "list-group" ]
        (List.map editEvent dayItem.events)
