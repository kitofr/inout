module TimeSinceLastCheckIn exposing (viewTimeSinceLastCheckIn)

import Html exposing (div, span, Html, text)
import Html.Attributes exposing (class)
import Time exposing (Time)
import DateUtil exposing (timePeriods)


viewTimeSinceLastCheckIn : Time -> List (Html msg)
viewTimeSinceLastCheckIn t =
    List.map viewTimePeriod (timePeriods t)


viewTimePeriod : ( String, String ) -> Html msg
viewTimePeriod ( period, amount ) =
    div [ class "time-period" ]
        [ span [ class "amount" ] [ text amount ]
        , span [ class "period" ] [ text period ]
        ]
