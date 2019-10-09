module EditEvent exposing (edit)

import DateUtil exposing (dateStr, timeStr, timeTuple)
import Html exposing (Html, button, div, h3, li, span, text, ul)
import Html.Attributes exposing (class, style, type_, value)
import Html.Events exposing (on, onClick, onInput, targetValue)
import InputExtra exposing (dateInput, timeInput)
import Json.Decode exposing (map)
import Msgs exposing (Msg(..))
import Time exposing (..)
import Types exposing (DayItem, Event)
import ViewMsgs exposing (ViewMsg(..))


onChange : (String -> msg) -> Html.Attribute msg
onChange tagger =
    on "change" (Json.Decode.map tagger Html.Events.targetValue)


editEvent : Types.Event -> Zone -> Html Msg
editEvent event zone =
    let
        marginLeft px =
            style "margin-left" (String.fromInt px ++ "px")

        shortText text =
            case text of
                "check-in" ->
                    "glyphicon glyphicon-log-in"

                _ ->
                    "glyphicon glyphicon-log-out"

        ( hourPart, minutePart, _ ) =
            event.inserted_at
                |> (\posix -> timeTuple posix zone)
    in
    li [ class "list-group-item" ]
        [ div []
            [ span
                [ (\( a, b ) -> style a b) ( "width", "30px" ), (\( a, b ) -> style a b) ( "display", "inline-block" ), class (shortText event.status) ]
                []
            , dateInput
                [ marginLeft 10
                , onInput (ViewEvent << DateUpdated event)
                , value (dateStr event.inserted_at zone)
                ]
                []
            , timeInput
                [ marginLeft 10
                , onChange (ViewEvent << HourSelected event)
                , value hourPart
                ]
                hourPart
                (List.range 0 23)
            , timeInput
                [ marginLeft 10
                , onChange (ViewEvent << MinuteSelected event)
                , value minutePart
                ]
                minutePart
                (List.range 0 59)
            , button [ marginLeft 10, class "pure-button", onClick (ViewEvent (Update event)) ] [ text "Update" ]
            , button [ class "pure-button button-error", onClick (ViewEvent (Delete event)) ] [ text "Delete" ]
            ]
        ]


edit : DayItem -> Zone -> Html Msg
edit dayItem zone =
    div []
        [ h3 [ (\( a, b ) -> style a b) ( "display", "inline-block" ) ]
            [ text ("Edit: " ++ dayItem.dateStr) ]
        , button
            [ (\( a, b ) -> style a b) ( "display", "inline-block" )
            , (\( a, b ) -> style a b) ( "margin-left", "20px" )
            , type_ "button"
            , class "pure-button pure-button-warning"
            , onClick (ViewEvent CloseEdit)
            ]
            [ span [] [ text "close" ]
            ]
        , ul [ class "list-group" ]
            (List.map (\p -> editEvent p zone) dayItem.events)
        ]
