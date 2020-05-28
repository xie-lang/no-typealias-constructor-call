# NoAppExprForTypeAlias



A [elm-review](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) rule that disallows the use of Application Expression for Type Alias


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
    import NoAppExprForTypeAlias
    import Review.Rule exposing (Rule)

    config : List Rule
    config =
        [ NoAppExprForTypeAlias.rule ]
```

