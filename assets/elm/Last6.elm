module Last6 exposing (last6)

import DateUtil exposing (periodToStr, toTimeDuration)
import Html exposing (Html, div, h3, h5, li, p, text, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import List
import Msgs exposing (Msg(..))
import Types exposing (DayItem)
import ViewMsgs exposing (ViewMsg(..))


dayItem : DayItem -> Html Msg
dayItem day =
    li [ class "list-group-item list-group-item-warning", onClick (ViewEvent (EditItem day)) ]
        [ h5 [ class "list-group-item-heading" ] [ text day.dateStr ]
        , p [ class "list-group-item-text" ] [ text (periodToStr (toTimeDuration day.diff)) ]
        ]


last6 : List DayItem -> Html Msg
last6 sorted =
    div []
        [ h3 [] [ text "Last 6: " ]
        , List.map dayItem (List.take 6 sorted)
            |> ul [ class "list-group" ]
        ]
