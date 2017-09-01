module EditEvent exposing (edit)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick, onInput)
import Date.Extra.Format exposing (utcIsoString)
import Msgs exposing (..)
import Types exposing (DayItem, Event)

dateInput : List (Html.Attribute msg) -> List (Html msg) -> Html msg
dateInput attr children =
      input (attr ++ [ type_ "date", step "1", Attr.min "2017-01-01" ]) children

timeInput : List (Html.Attribute msg) -> List (Html msg) -> Html msg
timeInput attr children =
  input (attr ++ [ type_ "time", step "5"]) children


editEvent event =
    let
        _ =
            Debug.log "edit event" event
    in
        li []
            [ span [] [ text ((toString event.id) ++ ". " ++ event.status ++ " ") ]
--            , dateInput [] []
--            , timeInput [] []
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
