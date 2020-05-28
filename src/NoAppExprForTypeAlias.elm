module NoAppExprForTypeAlias exposing (..)

import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Declaration as Declaration exposing (Declaration)
import Elm.Syntax.Node as Node exposing (Node)
import Review.Rule as Rule exposing (Error, Rule, error, Direction)

type alias Context = List String

rule : Rule
rule =
    Rule.newModuleRuleSchema "NoAppExprForTypeAlias" []
        |> Rule.withDeclarationVisitor declarationVisitor
        |> Rule.withExpressionVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema

declarationVisitor : Node Declaration -> Direction -> Context -> ( List (Error {}), Context)
declarationVisitor node direction context = 
    case Node.value node of 
        Declaration.AliasDeclaration n-> 
            case direction of 
                Rule.OnEnter -> 
                    ([], Node.value (n.name) :: context)
                Rule.OnExit -> 
                    ([], context)
        _ -> 
            ([], context)


expressionVisitor : Node Expression -> Direction ->  Context -> (List (Error {}), Context)
expressionVisitor node direction context =
    case Node.value node of 
        Expression.Application n -> 
            case List.head n |> Maybe.map Node.value  of 
                Just (Expression.FunctionOrValue _ name) -> 
                    case (direction, List.member name context ) of
                        (Rule.OnEnter, True) -> 
                            ([ Rule.error 
                                { message =  "No Application Expression"
                                , details = ["For better readability, specify the field names when applying values" ]
                                }
                                (Node.range node)
                            ]
                            , context)
                        _ -> 
                            ([], context)
                _ -> 
                    ([], context)
        _ ->
            ([], context)