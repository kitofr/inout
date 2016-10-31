module Charts exposing (..)

import List
import Html exposing (Html, div)
import Html.Attributes as A
import Svg exposing (..)
import Svg.Attributes exposing (..)


barChart dayCount =
    div []
        [ svg [ viewBox "0 0 110 110", width "300px" ]
            [ polygon
                [ stroke "#F0F"
                , fill "#F00"
                , strokeWidth "3"
                , strokeLinejoin "round"
                , points "45 30, 80 55, 45 80"
                ]
                []
            ]
        ]
