module NoAppExprForTypeAlias exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Declaration as Declaration exposing (Declaration)
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Review.Rule as Rule exposing (Direction, Error, Rule, error)



-- Use context to store the names of all type aliases in the module


type alias Context =
    List String


{-| `NoAppExprForTypeAlias` forces you to use Record Expression for any type aliases declared in the current module


## Configuration

    config : List Rule
    config =
        [ NoAppExprForTypeAlias.rule ]


## Example

The following code will report an error

    type alias Foo =
        { foo : String
        , bar : Bool
        , baz : Float
        }

    init : Foo
    init =
        Foo "hello" True 0.2

To get rid of the error, do this:

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
        }


## Caution

This rule does not apply to `map2` from `Json.Decode`, so the following code will NOT report an error

    type alias Point =
        { x : Float, y : Float }

    point : Decoder Point
    point =
        map2 Point
            (field "x" float)
            (field "y" float)

-}
rule : Rule
rule =
    Rule.newModuleRuleSchema "NoAppExprForTypeAlias" []
        -- visit all declarations and expressions in the current module
        |> Rule.withDeclarationVisitor declarationVisitor
        |> Rule.withExpressionVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


declarationVisitor : Node Declaration -> Direction -> Context -> ( List (Error {}), Context )
declarationVisitor node direction context =
    case Node.value node of
        -- check if the declaration has the type of [Type Alias]
        -- (https://package.elm-lang.org/packages/stil4m/elm-syntax/latest/Elm-Syntax-TypeAlias)
        Declaration.AliasDeclaration n ->
            case direction of
                -- if so, store the declaration name in the context
                Rule.OnEnter ->
                    ( [], Node.value n.name :: context )

                Rule.OnExit ->
                    ( [], context )

        _ ->
            ( [], context )


expressionVisitor : Node Expression -> Direction -> Context -> ( List (Error {}), Context )
expressionVisitor node direction context =
    case Node.value node of
        -- check if the expression uses Application Expression -}
        Expression.Application n ->
            -- if so, get the first value of the expression. if it has the type of `FunctionOrValue`, get the function name.
            case List.head n |> Maybe.map Node.value of
                Just (Expression.FunctionOrValue _ name) ->
                    -- check if the context contains this name. In other words, check if this is the name of a type alias
                    case ( direction, List.member name context ) of
                        ( Rule.OnEnter, True ) ->
                            ( [ Rule.error
                                    { message = "No Application Expression"
                                    , details = [ "For better readability, specify the field names when applying values" ]
                                    }
                                    (Node.range node)
                              ]
                            , context
                            )

                        _ ->
                            ( [], context )

                _ ->
                    ( [], context )

        _ ->
            ( [], context )
