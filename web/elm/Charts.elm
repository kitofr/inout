module Charts exposing (..)

import List
import Html exposing (Html, div)
import Html.Attributes as A
import Svg exposing (..)
import Svg.Attributes exposing (..)


barChart dayCount =
    svg [ viewBox "0 0 250 110", width "250px" ]
        (List.indexedMap
            (\i day ->
                rect
                    [ stroke "#777"
                    , fill ("#7a" ++ (toString (i % 10)))
                    , strokeWidth "1"
                    , strokeLinejoin "round"
                    , x ((toString (i + 1)) ++ "0")
                    , y "5"
                    , width "9"
                    , height ((toString (1 + day.hour)) ++ "0")
                    ]
                    []
            )
            dayCount
        )
