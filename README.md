# NoTypeAliasConstructorCall



A [elm-review](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) rule that forbids using type alias record constructors to create a record. 

This rule does not apply to the `map` functions in `Json.Decode`. 

## Examples 

For example, in the following code

```elm
type alias Foo = 
    { foo : String
    , bar : Bool
    , baz : Float
    }

init : Foo
init = 
    Foo "hello" True 0.2
```

`Foo "hello" True 0.2` will be marked as error. 

To be rid of the error, simply do: 

```elm
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
```



## Usage



After adding [elm-review](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) to your project, import this rule from
your `ReviewConfig.elm` file and add it to the config. E.g.:

```elm
import NoTypeAliasConstructorCall
import Review.Rule exposing (Rule)

config : List Rule
config =
    [ NoTypeAliasConstructorCall.rule ]

```
The following code will not report an error

```elm
type alias Point =
    { x : Float, y : Float }

point : Decoder Point
point =
    map2 Point
        (field "x" float)
        (field "y" float)
```
