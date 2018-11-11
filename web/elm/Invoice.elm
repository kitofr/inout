module Invoice exposing (invoiceView)

import Html exposing (..)
import Html.Attributes exposing (class, id, src)
import Html.Events exposing (onClick)
import Msgs exposing (Msg(ViewEvent))
import ViewMsgs exposing (ViewMsg(GoHome))


invoiceHeader invoiceNumber =
    div [ id "faktura" ]
        [ div [ class "header" ]
            [ img [ src "images/agical_128x40.png" ] []
            , h1 [] [ text ("Faktura " ++ toString invoiceNumber) ]
            ]
        ]


paymentInfo =
    div [ class "payment-info" ]
        [ p [] [ b [] [ text "Betalningsinformation" ] ]
        , label [] [ text "Bankgiro 5345-5226" ]
        , label [] [ text "Organisationsnummer 556667-2597" ]
        , p [] [ text "Ange fakturanummer vid betalning." ]
        , p [] [ i [] [ text "Vid försenad betalning debiteras dröjsmålsränta med 15%" ] ]
        ]


footer =
    div [ class "footer" ]
        [ div [ class "contact" ]
            [ p [] [ b [] [ text "Kontakt" ] ]
            , p [] [ text "faktura@agical.se" ]
            , p [] [ text "https://www.agical.se" ]
            , p [] [ text "08-221580" ]
            ]
        , div [ class "agical" ]
            [ p [] [ b [] [ text "Agical AB" ] ]
            , p [] [ text "Västerlånggatan 79A" ]
            , p [] [ text "111 29 Stockholm" ]
            , p [] [ text "Innehar F-skattesedel" ]
            ]
        ]


invoiceView ( year, month ) duration count =
    div []
        [ button [ class "btn btn-sm btn-danger", onClick (ViewEvent GoHome) ] [ text "Back" ]
        , invoiceHeader 1989
        , p [] [ text (toString year) ]
        , p [] [ text (toString month) ]
        , p [] [ text (toString duration) ]
        , p [] [ text (toString count) ]
        ]



--[div []
--      invoiceHeader
--      [div [id "invoice"]
--       [div []
--        [div [ class "info-header" ]
--        [div [ class "invoice-info" ]
--         [label "Fakturanummer" (:invoice-number invoice)]
--         [label "Fakturadatum" (:date invoice)]
--         [label "Bet.Villkor" (str (:payment-due invoice) " dagar netto")]
--         [label "Referens Agical" (:reference-agical invoice)]]
--        [div []
--         [label "Kund" (:customer invoice)]
--         [label "Referens" (:reference-customer invoice)]
--         [:p [:b.label "Adress: "]]
--         [div [ class "adress.tab" ]
--          [:p (:customer-address invoice) [:br] (:customer-post-number invoice) " " (:customer-town invoice)]]]
--        ]
--
--        [div [ class "rows" ]
--         (for [row (:rows invoice)]
--           [div [ class "row {:key (:idx row)}" ]
--            [label "Beskrivning"  (:description row)]
--            (if (:price-hour row)
--                [label "Timpris" (:price-hour row) true]
--                [label "Dagspris" (:price-day row) true])
--            (if (:amount-hours row)
--              [label "Antal timmar" (:amount-hours row)]
--              [label "Antal dagar" (:amount-days row)])
--
--            (if (:hours-from-months row)
--              [label "Timmarna avser" (:hours-from-months row)]
--              [label "Dagarna avser" (:days-from-months row)])
--            [label "Övrig summa" (:added-sum row) true]])
--         ]
--
--        [div [ class "payment-info-section" ]
--          (let [total (sum-invoice invoice)]
--            [div [ class "total" ]
--             [label "Totalsumma" total true]
--             [label "Moms" (* 0.25 total) true]
--             [label "Totalt inkl moms" (* 1.25 total) true]])
--
--          paymentInfo
--      ]]]
--      footer
--      ]
