module Charts exposing (barChart)

import List
import Html exposing (Html)
import Svg exposing (svg, rect)
import Svg.Attributes exposing (viewBox, width, stroke, strokeWidth, fill, x, y, height, transform)
import Seq


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
            viewSize |> toString
    in
        svg [ viewBox ("0 0 " ++ viewSizeStr ++ " 110"), width (viewSizeStr ++ "px") ]
            (List.indexedMap
                (\i day ->
                    let
                        color =
                            Seq.nth (day.hour % List.length rainbowColors) rainbowColors "#442299"
                    in
                        rect
                            [ stroke "#333"
                            , strokeWidth "1"
                            , fill color
                            , x (toString ((i * barSize) + offSet))
                            , y "5"
                            , width (barSize - 2 |> toString)
                            , height (toString (1 + day.hour) ++ "0")
                            , transform "rotate(180) translate(-300 -100)"
                            ]
                            []
                )
                (List.reverse dayCount)
            )
