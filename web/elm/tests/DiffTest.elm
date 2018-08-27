module DiffTest exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Types exposing (diff)


dateRecord year month day hour minute second =
    { year = year
    , month = month
    , day = day
    , hour = hour
    , minute = minute
    , second = second
    }


suite : Test
suite =
    describe "The DateRecord"
        [ describe "diff"
            [ test "handles hours minutes and seconds" <|
                \_ ->
                    let
                        delta =
                            diff (dateRecord 1990 1 1 0 10 10)
                                (dateRecord 1990 1 1 12 0 0)
                    in
                    Expect.equal delta
                        { year = 0
                        , month = 0
                        , day = 0
                        , hour = 11
                        , minute = 49
                        , second = 50
                        }
            ]
        ]
