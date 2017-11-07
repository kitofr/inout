module InputExtra exposing (dateInput, timeInput)

import Html exposing (Html, input)
import Html.Attributes as Attr exposing (type_, step)


dateInput : List (Html.Attribute msg) -> List (Html msg) -> Html msg
dateInput attr children =
    input (attr ++ [ type_ "date", step "1", Attr.min "2017-01-01" ]) children


timeInput : List (Html.Attribute msg) -> List (Html msg) -> Html msg
timeInput attr children =
    input (attr ++ [ type_ "time", step "5" ]) children
