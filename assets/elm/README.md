```
 _______   ___       ___     ___    ___ ___  ________             ___ ________          _______   ___       _____ ______      
|\  ___ \ |\  \     |\  \   |\  \  /  /|\  \|\   __  \           /  /|\_____  \        |\  ___ \ |\  \     |\   _ \  _   \    
\ \   __/|\ \  \    \ \  \  \ \  \/  / | \  \ \  \|\  \         /  / ||____|\ /_       \ \   __/|\ \  \    \ \  \\\__\ \  \   
 \ \  \_|/_\ \  \    \ \  \  \ \    / / \ \  \ \   _  _\       /  / /      \|\  \       \ \  \_|/_\ \  \    \ \  \\|__| \  \  
  \ \  \_|\ \ \  \____\ \  \  /     \/   \ \  \ \  \\  \|     |\  \/      __\_\  \       \ \  \_|\ \ \  \____\ \  \    \ \  \ 
   \ \_______\ \_______\ \__\/  /\   \    \ \__\ \__\\ _\     \ \  \     |\_______\       \ \_______\ \_______\ \__\    \ \__\
    \|_______|\|_______|\|__/__/ /\ __\    \|__|\|__|\|__|     \ \__\    \|_______|        \|_______|\|_______|\|__|     \|__|
                            |__|/ \|__|                         \|__|                                                         
                                                                                                                              
          by: @kitofr / nov 2016
```

## Topics
- Tooling
- Configuration
- Making `HTTP Requests` and decoding `JSON`

### Tooling: `elm-brunch` with live-reloading etc
  ```
  // package.json
  "devDependencies": {
    "elm": "^0.17.0",
    "elm-brunch": "^0.7.0"
  }
  ```
  
  ```
  // brunch-config.js
  paths: {
    watched: [
      ...
      "web/elm/"
    ],
  },

  plugins: {
    elmBrunch: {
      executablePath: "../../node_modules/elm/binwrappers",
      elmFolder: "web/elm",
      mainModules: ["Main.elm"],
      outputFolder: "../static/vendor",
      makeParameters : ['--warn']
    }
  ```

### Configuration
  Initialize your app with `Flags`

  ``` 
  -- web/elm/Types.elm
  type alias Flags =
      { hostUrl : String }
  
  type alias Model =
    { events : List Event
    , hostUrl : String
    }
  ```
  ```
  -- web/elm/Main.elm
  module InOut exposing (main)
  ...
  
  init : Flags -> ( Model, Cmd Msg )
  init flags =
    ( { events = [], hostUrl = flags.hostUrl }, getEvents flags.hostUrl )
  ```
  ```
    <!-- web/templates/layout/app.html.eex !>
    <script type="application/javascript">
      hostUrl = "<%= System.get_env("HOST_URL") || "https://inout-backend.herokuapp.com" %>";
    </script>
    <script src="<%= static_path(@conn, "/js/app.js") %>"></script>
  ```
  
  ```
    // web/static/js/app.js
    const elmDiv = document.getElementById('elm-main')
    , elmApp = Elm.InOut.embed(elmDiv, {
          hostUrl: hostUrl 
        });
  ```

### Making `HTTP-requests`
  ```
  -- web/elm/Types.elm

  type alias Event =
      { status : String
      , location : String
      , device : String
      , inserted_at : Date
      , updated_at : Date
      }
  
  type alias Model =
      { events : List Event
      , hostUrl : String
      }

  type Msg
      = CheckIn
      | CheckOut
      | Load
      | FetchSucceed (List Event)
      | FetchFail Http.Error
      | HttpSuccess String
      | HttpFail Http.Error
  ```

  ```
  -- web/elm/Api.elm
  import Json.Encode as Encode
  import Json.Decode as JD exposing (Decoder, decodeValue, succeed, string, list, (:=))
  import Json.Decode.Extra as Extra exposing ((|:))
  ...

  getEvents : String -> Cmd Msg
  getEvents hostUrl =
      Task.perform FetchFail
          FetchSucceed
          (Http.get decodeEvents (hostUrl ++ "/events.json"))
  
  
  decodeEvents : JD.Decoder (List Event)
  decodeEvents =
      JD.succeed identity
          |: ("events" := JD.list decodeEvent)
  
  
  decodeEvent : JD.Decoder Event
  decodeEvent =
      -- Note that Event here is used as the function (Event { status : String , location : String , device : String , inserted_at : Date , updated_at : Date })
      JD.map Event ("status" := JD.string)
          |: ("location" := JD.string)
          |: ("device" := JD.string)
          |: ("inserted_at" := Extra.date)
          |: ("updated_at" := Extra.date)
  ```
  
  And then the POSTS

  ```
  -- web/elm/Api.elm

  post : Decoder value -> String -> Http.Body -> Task Http.Error value
  post decoder url body =
      let
          request =
              { verb = "POST"
              , headers = [ ( "Content-Type", "application/json" ) ]
              , url = url
              , body = body
              }
      in
          Http.fromJson decoder (Http.send Http.defaultSettings request)
  
  
  check : String -> String -> Cmd Msg
  check inOrOut hostUrl =
      let
          rec =
              encodeEvent { status = "check-" ++ inOrOut, location = "work-location" }
      in
          Task.perform HttpFail
              HttpSuccess
              (post (succeed "") (hostUrl ++ "/events") (Http.string rec))
  

  encodeEvent : { status : String, location : String } -> String
  encodeEvent record =
      Encode.encode 0
          (Encode.object
              [ ( "event"
                , Encode.object
                      [ ( "status", Encode.string <| record.status )
                      , ( "location", Encode.string <| record.location )
                      , ( "device", Encode.string <| "internetz" )
                      ]
                )
              ]
          )

  ```

### Extra?
- *Model* your problem ( with state machines )
- TDD in Elm
- Integration with f.e. **React**
