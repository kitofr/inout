module InputExtra exposing (dateInput, timeInput)

import DateUtil exposing (zeroPad)
import Html exposing (Html, div, input, option, select, text)
import Html.Attributes as Attr exposing (selected, step, type_, value)


dateInput : List (Html.Attribute msg) -> List (Html msg) -> Html msg
dateInput attr children =
    input (attr ++ [ type_ "date", step "1", Attr.min "2017-01-01" ]) children


timeOption : String -> Int -> Html a
timeOption selectedValue time =
    let
        val =
            time |> String.fromInt |> zeroPad

        current =
            if val == selectedValue then
                True

            else
                False
    in
    option [ value val, selected current ] [ text val ]


timeInput : List (Html.Attribute msg) -> String -> List Int -> Html msg
timeInput attr val range =
    select attr (List.map (timeOption val) range)
