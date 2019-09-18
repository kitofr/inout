module Route exposing (Route(..), route)

import UrlParser exposing ((</>), Parser, map, oneOf, s, string, top)


type Route
    = Home
    | Invoice


route : Parser (Route -> Route) Route
route =
    oneOf
        [ map Home top
        , map Invoice (s "invoice")
        ]
