module ApiMsgs exposing
    ( ApiMsg
        ( CheckEvent
        , DeleteEvent
        , LoadContract
        , LoadEvents
        , UpdateEvent
        )
    )

import Http
import Types exposing (Contract, Event)


type alias HttpResult a =
    Result Http.Error a


type ApiMsg
    = CheckEvent (HttpResult String)
    | LoadEvents (HttpResult (List Event))
    | UpdateEvent (HttpResult String)
    | DeleteEvent (HttpResult String)
    | LoadContract (HttpResult (List Contract))
