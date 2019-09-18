
- elm/core
  - [x] Replace uses of toString with String.fromInt, String.fromFloat, or Debug.toString as appropriate
- undefined
  - [ ] Read the new documentation here: https://package.elm-lang.org/packages/elm/time/latest/
  - [ ] Replace uses of Date and Time with Time.Posix
- elm/html
  - [ ] If you used Html.program*, install elm/browser and switch to Browser.element or Browser.document
  - [ ] If you used Html.beginnerProgram, install elm/browser and switch Browser.sandbox
- elm/browser
  - [x] Change code using Navigation.program* to use Browser.application
  - [ ] Use the Browser.Key passed to your init function in any calls to Browser.Navigation.pushUrl/replaceUrl/back/forward
- elm/url
  - [x] Changes uses of Navigation.Location to Url.Url
  - [x] Change code using UrlParser.* to use Url.Parser.*


$ npx elm make --output ../vendor/inout.js InOut.elm

