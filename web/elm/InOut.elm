module InOut exposing (main)

import Platform.Cmd as Cmd exposing (Cmd)
import Html exposing (..)
import Html.App as App exposing (..)
import Html.Attributes as A
import List exposing (..)

main : Program Never
main =
  App.program { init = init
               , view = view
               , update = update
               , subscriptions = \_ -> Sub.none
               }

type alias Model = String
type Msg =
  Foo

init : (Model, Cmd Msg)
init = 
    ("Foo", Cmd.none)


view : Model -> Html Msg
view model =
  div [] [text model] 

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  (model, Cmd.none)
