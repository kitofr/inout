module Last5 exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List exposing (map)
import Time exposing (..)
import DateUtil exposing (periodToStr, toTimeDuration)
import Types exposing (..)


dayItem : DayItem -> Html Msg
dayItem day =
    li [ class ("list-group-item list-group-item-warning"), onClick (EditItem day) ]
        [ h5 [ class "list-group-item-heading" ] [ text day.dateStr ]
        , p [ class "list-group-item-text" ] [ text (periodToStr (toTimeDuration day.diff)) ]
        ]


last5 sorted =
    div []
        [ h3 [] [ text "Last 5: " ]
        , List.map dayItem (List.take 5 sorted)
            |> ul [ class "list-group" ]
        ]
