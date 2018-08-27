module PosixTest exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Posix exposing (getTimeStamp)
import Test exposing (..)


suite : Test
suite =
    describe "The Posix module"
        [ describe "getTimeStamp"
            [ test "it gives us a big int" <|
                \_ ->
                    let
                        posix =
                            getTimeStamp 1970 1 1 0 0 0 0
                    in
                    Expect.equal posix (Ok 621355968000000000)
            , test "that is increased by milliseconds" <|
                \_ ->
                    let
                        posix =
                            getTimeStamp 1970 1 1 0 0 0 1
                    in
                    Expect.equal posix (Ok 621355968000010000)
            , test "and seconds" <|
                \_ ->
                    let
                        posix =
                            getTimeStamp 1970 1 1 0 0 1 1
                    in
                    Expect.equal posix (Ok 621355968010010000)
            , test "and minutes" <|
                \_ ->
                    let
                        posix =
                            getTimeStamp 1970 1 1 0 1 1 1
                    in
                    Expect.equal posix (Ok 621355968610010000)
            , test "and hours" <|
                \_ ->
                    let
                        posix =
                            getTimeStamp 1970 1 1 1 1 1 1
                    in
                    Expect.equal posix (Ok 621356004610010000)
            ]
        ]
