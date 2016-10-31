module Charts exposing (..)

import List
import Html exposing (Html, div)
import Html.Attributes as A
import Svg exposing (..)
import Svg.Attributes exposing (..)


barChart dayCount =
    div []
        [ svg [ viewBox "0 0 410 110", width "300px" ]
            (List.indexedMap
                (\i day ->
                        rect
                            [ stroke "#777"
                            , fill ( "#75" ++ (toString (i % 10)))                            , strokeWidth "1"
                            , strokeLinejoin "round"
                            , x ((toString ( i + 1 )) ++ "0")
                            , y "5"
                            , width "9"
                            , height ((toString day.hour) ++ "0")
                            ]
                            []
                )
                dayCount
            )
        ]
