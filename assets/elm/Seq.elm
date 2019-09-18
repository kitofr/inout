module Seq exposing (desc, groupBy, nth)

import Dict


{-| Retrieves the nth element from a list

    nth 0 [ 'e', 'l', 'm' ] '-' == 'e'

    nth 5 [ 'e', 'l', 'm' ] '-' == '-'

-}
nth : Int -> List a -> a -> a
nth n lst def =
    List.drop n lst |> List.head |> Maybe.withDefault def


{-| groups a list by comparable function and returns a dictionary
with comparer as key and the group as value

    groupBy (\x -> x.age) [ { age = 10, name = "Kalle" }, { age = 10, name = "John" }, { age = 8, name = "Kevin" }]
      == { "10" = [ { age = 10, name = "Kalle" }, { age = 10, name = "John" }]
         , "8" = [ { age = 8, name = "Kevin" } ]
         }

-}
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


{-| sorts in descending order
-}
desc : comparable -> comparable -> Order
desc a b =
    case compare a b of
        LT ->
            GT

        EQ ->
            EQ

        GT ->
            LT
