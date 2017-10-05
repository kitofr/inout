module ApiMsgs exposing (ApiMsg(..))
import Http
import Types exposing (Event)

type alias HttpResult a = (Result Http.Error a)

type ApiMsg 
  = CheckEvent (HttpResult String)
    | LoadEvents (HttpResult (List Event))
    | UpdateEvent (HttpResult String)
    | DeleteEvent (HttpResult String)

