module Charts exposing (..)

import List
import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Seq


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
            20

        viewSize = barSize * 22 
        viewSizeStr = viewSize |> toString
    in
        svg [ viewBox ( "0 0 " ++ viewSizeStr ++ " 110" ), width (viewSizeStr ++ "px") ]
            (List.indexedMap
                (\i day ->
                    rect
                        [ stroke "#333"
                        , strokeWidth "1"
                        , fill (Seq.nth (day.hour % (List.length rainbowColors)) rainbowColors "#442299")
                        , x ((toString ( (i * barSize) - (viewSize // 2) )))
                        , y "5"
                        , width ((barSize - 2) |> toString)
                        , height ((toString (1 + day.hour)) ++ "0")
                        , transform "rotate(180) translate(-300 -100)"
                        ]
                        []
                )
                (List.reverse dayCount)
            )
