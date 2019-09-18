module Route exposing (Route(..), route)

import Url exposing (Parser)


type Route
    = Home
    | Invoice


route : Parser (Route -> Route) Route
route =
    oneOf
        [ map Home top
        , map Invoice (s "invoice")
        ]
