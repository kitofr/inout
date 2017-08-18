module EditEvent exposing (edit)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Date.Extra.Format exposing (utcIsoString)
import Msgs exposing (..)
import Types exposing (DayItem, Event)


dateInput attr html =
    let
        attr_ =
            List.append [ (type_ "datetime-local") ] attr
              |> Debug.log "dateInput attr_"
    in
        Html.node "input" attr html


editEvent event =
    let
        _ =
            Debug.log "edit event" event
    in
        li []
            [ span [] [ text ((toString event.id) ++ ". " ++ event.status ++ " ") ]
            , dateInput
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
