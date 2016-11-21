module Seq exposing (..)

import Dict exposing (get, empty)


nth : Int -> List a -> a -> a
nth n lst def =
    List.drop n lst |> List.head |> Maybe.withDefault def


groupBy : (a -> comparable) -> List a -> Dict.Dict comparable (List a)
groupBy fun coll =
    let
        reducer x acc =
            let
                key =
                    fun x

                list =
                    Maybe.withDefault [] (Dict.get key acc)
            in
                Dict.insert key (x :: list) acc
    in
        List.foldl reducer Dict.empty coll
