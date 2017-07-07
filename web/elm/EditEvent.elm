module EditEvent exposing (edit)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Date.Extra.Format exposing (format)
import Date.Extra.Config.Config_en_us exposing (config)
import Msgs exposing (..)
import Types exposing (DayItem, Event)


editEvent : Event -> Html Msg
editEvent event =
    let
        _ =
            Debug.log "edit event" event
    in
        li []
            [ span [] [ text ((toString event.id) ++ ". " ++ event.status ++ " ") ]
            , input [ placeholder (format config "%a %-d %b %Y at  %-H:%M:%S" event.inserted_at) ] []
            , button [ onClick (Update event) ] [ text "Update" ]
            , button [ onClick (Delete event) ] [ text "Delete" ]
            ]


edit : DayItem -> Html Msg
edit dayItem =
    ul [ class "row" ]
        (List.map editEvent dayItem.events)
