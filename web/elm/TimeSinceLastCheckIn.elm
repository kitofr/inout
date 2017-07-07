module TimeSinceLastCheckIn exposing (viewTimeSinceLastCheckIn)

import Html exposing (..)
import Html.Attributes exposing (..)
import Time exposing (..)
import DateUtil exposing (..)


viewTimeSinceLastCheckIn : Time -> List (Html msg)
viewTimeSinceLastCheckIn t =
    List.map viewTimePeriod (timePeriods t)


viewTimePeriod : ( String, String ) -> Html msg
viewTimePeriod ( period, amount ) =
    div [ class "time-period" ]
        [ span [ class "amount" ] [ text amount ]
        , span [ class "period" ] [ text period ]
        ]
