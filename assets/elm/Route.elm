module Route exposing (Route(..), route)

import Url.Parser exposing ((</>), Parser, int, map, oneOf, s, string, top)


type Route
    = Home
    | Invoice


route : Parser (Route -> Route) Route
route =
    oneOf
        [ map Home top
        , map Invoice (s "invoice")
        ]
