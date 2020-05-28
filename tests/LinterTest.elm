module LinterTest exposing (..)

import NoAppExprForTypeAlias exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


tests : Test
tests =
    describe "Application Expressions"
        [ test "report when used with type alias" <|
            \() ->
                """
module TypeAliasApplication exposing (..)
type alias Foo = 
    { foo : String
    , bar : Bool
    , baz : Float
    }
init : Foo
init = 
    Foo "hello" True 0.2 """
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "No Application Expression"
                            , details = [ "For better readability, specify the field names when applying values" ]
                            , under = "Foo \"hello\" True 0.2"
                            }
                        ]
        , test "do not report when using Decode.map2" <|
            \() ->
                """
module TypeAliasApplication exposing (..)
import Json.Decode exposing (Decoder, map2, field, float)

type alias Point = { x : Float, y : Float }

point : Decoder Point
point =
  map2 Point
    (field "x" float)
    (field "y" float) """
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "do not report when assigned in record format" <|
            \() ->
                """
module TypeAliasRecordExpr exposing (..)
type alias Foo = 
    { foo : String
    , bar : Bool
    , baz : Float
    }
init : Foo
init = 
    { foo = "hello"
    , bar = True
    , baz = 0.2    
    } """
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "do not report when using on normal functions" <|
            \() ->
                """
module NonTypeAliasApplication exposing(..)
add : Int -> Int -> Int
add a b = 
    a + b
init : Int
init = add 1 2 """
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "do not report when using functions declared elsewhere" <|
            \() ->
                """
module NonTypeAliasImportedFunction exposing (..)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)

type Msg = Increment | Decrement

view : Int -> Html Msg
view count =
  div []
    [ button [ onClick Decrement ] [ text "-" ]
    , div [] [ text (String.fromInt count) ]
    , button [ onClick Increment ] [ text "+" ]
    ] """
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        ]
