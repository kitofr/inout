module Charts exposing (barChart)

import Html exposing (Html)
import List
import Seq
import Svg exposing (rect, svg)
import Svg.Attributes exposing (fill, height, stroke, strokeWidth, transform, viewBox, width, x, y)


rainbowColors : List String
rainbowColors =
    [ "#f80c12"
    , "#ee1100"
    , "#ff3311"

    --    , "#ff4422"
    --    , "#ff6644"
    --    , "#ff9933"
    --    , "#feae2d"
    --    , "#ccbb33"
    --    , "#d0c310"
    , "#aacc22"
    , "#69d025"
    , "#22ccaa"
    , "#12bdb9"
    , "#11aabb"
    , "#4444dd"
    , "#3311bb"
    , "#3b0cbd"
    , "#442299"
    ]


barChart : List { a | hour : Int } -> Html msg
barChart dayCount =
    let
        barSize =
            12

        offSet =
            3 * barSize

        viewSize =
            barSize * 26

        viewSizeStr =
            viewSize |> String.fromInt
    in
    svg [ viewBox ("0 0 " ++ viewSizeStr ++ " 110"), width (viewSizeStr ++ "px") ]
        (List.indexedMap
            (\i day ->
                let
                    color =
                        Seq.nth (modBy (List.length rainbowColors) day.hour) rainbowColors "#442299"
                in
                rect
                    [ stroke "#333"
                    , strokeWidth "1"
                    , fill color
                    , x (String.fromInt ((i * barSize) + offSet))
                    , y "5"
                    , width (barSize - 2 |> String.fromInt)
                    , height (String.fromInt (1 + day.hour) ++ "0")
                    , transform "rotate(180) translate(-300 -100)"
                    ]
                    []
            )
            (List.reverse dayCount)
        )
