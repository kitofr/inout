module TimeSinceLastCheckIn exposing (viewTimeSinceLastCheckIn)

import DateUtil exposing (timePeriods)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
import Time exposing (Posix, Zone)


viewTimeSinceLastCheckIn : Posix -> List (Html msg)
viewTimeSinceLastCheckIn t =
    let
        tp =
            timePeriods (toFloat (Time.posixToMillis t))
    in
    List.map viewTimePeriod tp


viewTimePeriod : ( String, String ) -> Html msg
viewTimePeriod ( period, amount ) =
    div [ class "time-period" ]
        [ span [ class "amount" ] [ text amount ]
        , span [ class "period" ] [ text period ]
        ]
