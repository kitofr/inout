module InputExtra exposing (dateInput, timeInput)

import DateUtil exposing (zeroPad)
import Html exposing (Html, input, select, div, text, option)
import Html.Attributes as Attr exposing (type_, value, step)


dateInput : List (Html.Attribute msg) -> List (Html msg) -> Html msg
dateInput attr children =
    input (attr ++ [ type_ "date", step "1", Attr.min "2017-01-01" ]) children


timeOption : Int -> Html a
timeOption time =
    let
        val =
            time |> toString |> zeroPad
    in
        option [ value val ] [ text val ]


timeInput : List (Html.Attribute msg) -> List Int -> Html msg
timeInput attr range =
    select attr (List.map timeOption range)
