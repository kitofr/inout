module EditEvent exposing (edit)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick, onInput)
import Date exposing (Date)
import Date.Extra.Format exposing (utcIsoString)
import Msgs exposing (..)
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
                span [] [ text ((toString event.id) ++ ". " ++ event.status ++ " ") ]
              , dateInput [ onInput (DateUpdated event), value (dateStr event.inserted_at) ] []
              , timeInput [ onInput (TimeUpdated event), value (timeStr event.inserted_at) ] []
              , button [ onClick (Update event) ] [ text "Update" ]
              , button [ onClick (Delete event) ] [ text "Delete" ]
              ]
            ]


edit : DayItem -> Html Msg
edit dayItem =
    ul [ class "list-group" ]
        (List.map editEvent dayItem.events)
