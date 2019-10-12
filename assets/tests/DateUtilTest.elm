module DateUtilTest exposing (suite)

import DateUtil exposing (addHoursToPosix, addMinutesToPosix)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Time


suite : Test
suite =
    describe "DateUtil"
        [ describe "addMinuteToPosix"
            [ test "adds a minute to posix" <|
                \_ ->
                    let
                        minutes =
                            5

                        posix =
                            Time.millisToPosix 0
                    in
                    Expect.equal (Time.millisToPosix (5 * 60 * 1000)) (addMinutesToPosix posix minutes)
            ]
        , describe "addHourToPosix"
            [ test "adds a hour to a posix" <|
                \_ ->
                    let
                        hours =
                            5

                        posix =
                            Time.millisToPosix 0
                    in
                    Expect.equal (Time.millisToPosix (5 * 60 * 60 * 1000)) (addHoursToPosix posix hours)
            ]
        ]
