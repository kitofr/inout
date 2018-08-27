module TimeSinceLastCheckIn exposing (viewTimeSinceLastCheckIn)

import DateUtil exposing (timePeriods)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
import Time exposing (Time)


viewTimeSinceLastCheckIn : Time -> List (Html msg)
viewTimeSinceLastCheckIn t =
    let
        _ =
            Debug.log "time" t

        periods =
            timePeriods t
    in
    List.map viewTimePeriod periods


viewTimePeriod : ( String, String ) -> Html msg
viewTimePeriod ( period, amount ) =
    div [ class "time-period" ]
        [ span [ class "amount" ] [ text amount ]
        , span [ class "period" ] [ text period ]
        ]
