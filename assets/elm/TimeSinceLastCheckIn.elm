module TimeSinceLastCheckIn exposing (viewTimeSinceLastCheckIn)

import DateUtil exposing (timePeriods)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
import Time exposing (Posix, Zone)


viewTimeSinceLastCheckIn : Posix -> Zone -> List (Html msg)
viewTimeSinceLastCheckIn t zone =
    List.map viewTimePeriod (timePeriods (toFloat (Time.toMillis zone t)))


viewTimePeriod : ( String, String ) -> Html msg
viewTimePeriod ( period, amount ) =
    div [ class "time-period" ]
        [ span [ class "amount" ] [ text amount ]
        , span [ class "period" ] [ text period ]
        ]
