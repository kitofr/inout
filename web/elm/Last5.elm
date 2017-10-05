module Last5 exposing (..)

import Html exposing (li, h5, text, p, Html, div, h3, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import List
import DateUtil exposing (periodToStr, toTimeDuration)
import Types exposing (DayItem)
import Msgs exposing (Msg(ViewEvent))
import ViewMsgs exposing (ViewMsg(EditItem))


dayItem : DayItem -> Html Msg
dayItem day =
    li [ class "list-group-item list-group-item-warning", onClick (ViewEvent (EditItem day)) ]
        [ h5 [ class "list-group-item-heading" ] [ text day.dateStr ]
        , p [ class "list-group-item-text" ] [ text (periodToStr (toTimeDuration day.diff)) ]
        ]


last5 : List DayItem -> Html Msg
last5 sorted =
    div []
        [ h3 [] [ text "Last 5: " ]
        , List.map dayItem (List.take 5 sorted)
            |> ul [ class "list-group" ]
        ]
