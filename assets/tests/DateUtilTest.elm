module DateUtilTest exposing (suite)

import DateUtil exposing (changeDateInPosix, changeHourInPosix, changeMinuteInPosix)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Time exposing (Month(..))
import Time.Extra exposing (Parts, partsToPosix, posixToParts)


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
        , describe "changeDateInPosix"
            [ test "different date" <|
                \_ ->
                    let
                        zone =
                            Time.utc

                        dateAsString =
                            "2020-10-14"

                        posix =
                            partsToPosix zone (Parts 2020 Oct 1 12 0 0 0)
                    in
                    Expect.equal
                        (posixToParts zone (partsToPosix zone (Parts 2020 Oct 14 12 0 0 0)))
                        (posixToParts zone (changeDateInPosix zone posix dateAsString))
            ]
        ]
