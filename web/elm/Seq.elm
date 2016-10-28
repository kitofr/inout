module Seq exposing (..)
import Dict exposing (get, empty)

groupBy fun coll =
  let reducer x acc =
    let key = fun x
        list = Maybe.withDefault [] (Dict.get key acc)
    in
      Dict.insert key (x :: list) acc
  in
    List.foldl reducer Dict.empty coll

