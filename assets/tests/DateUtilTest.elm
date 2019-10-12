module DateUtilTest exposing (suite)

import DateUtil exposing (changeHourInPosix, changeMinuteInPosix)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Time


suite : Test
suite =
    describe "DateUtil"
        [ describe "changeMinuteInPosix"
            [ test "same minute is still same posix" <|
                \_ ->
                    let
                        zone =
                            Time.utc

                        minutes =
                            5

                        posix =
                            Time.millisToPosix (5 * 60 * 1000)
                    in
                    Expect.equal (Time.millisToPosix (5 * 60 * 1000)) (changeMinuteInPosix zone posix minutes)
            ]
        , describe "changeHourInPosix"
            [ test "same hour is still same posix" <|
                \_ ->
                    let
                        zone =
                            Time.utc

                        hours =
                            5

                        posix =
                            Time.millisToPosix (5 * 60 * 60 * 1000)
                    in
                    Expect.equal (Time.millisToPosix (5 * 60 * 60 * 1000)) (changeHourInPosix zone posix hours)
            ]
        ]
