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


invoiceContractDetails :
    { number : Int, date : String, paymentDue : String, reference : String }
    -> { customer : String, reference : String, adress : String, postNumber : String, county : String }
    -> Html Msg
invoiceContractDetails invoice contract =
    div [ id "invoice" ]
        [ div []
            [ div [ class "info-header" ]
                [ div [ class "invoice-info" ]
                    [ label [] [ text ("Fakturanummer" ++ toString invoice.number) ]
                    , label [] [ text ("Fakturadatum" ++ invoice.date) ]
                    , label [] [ text ("Bet.Villkor" ++ invoice.paymentDue ++ " dagar netto") ]
                    , label [] [ text ("Referens Agical" ++ invoice.reference) ]
                    ]
                , div []
                    [ label [] [ text ("Kund" ++ contract.customer) ]
                    , label [] [ text ("Referens" ++ contract.reference) ]
                    , p []
                        [ b [ class ".label" ] [ text "Adress: " ]
                        , div [ class "adress.tab" ]
                            [ p [] [ text contract.adress ]
                            , br [] []
                            , p [] [ text (contract.postNumber ++ " " ++ contract.county) ]
                            ]
                        ]
                    ]
                ]
            ]
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


type Reporting
    = DailyReporting ( String, Float, Int, String, Float )
    | HourlyReporting ( String, Float, Int, String, Float )


type alias Invoice =
    { rows : List Reporting }


invoiceRows invoice =
    div [ class "rows" ]
        (List.map
            (\row ->
                case row of
                    DailyReporting day ->
                        invoiceDayRow day

                    HourlyReporting hours ->
                        invoiceHourRow hours
            )
            invoice.rows
        )


invoiceDayRow : ( String, Float, Int, String, Float ) -> Html Msg
invoiceDayRow ( description, price, amount, fromMonths, addedSum ) =
    div [ class "row" ]
        [ label [] [ text ("Beskrivning " ++ description) ]
        , label [] [ text ("Dagspris " ++ toString price) ]
        , label [] [ text ("Antal dagar " ++ toString amount) ]
        , label [] [ text ("Dagarna avser: " ++ fromMonths) ]
        , label [] [ text ("Övrig summa " ++ toString addedSum) ]
        ]


invoiceHourRow : ( String, Float, Int, String, Float ) -> Html Msg
invoiceHourRow ( description, price, amount, fromMonths, addedSum ) =
    div [ class "row" ]
        [ label [] [ text ("Beskrivning " ++ description) ]
        , label [] [ text ("Timpris " ++ toString price) ]
        , label [] [ text ("Antal timmar " ++ toString amount) ]
        , label [] [ text ("Timmarna avser: " ++ fromMonths) ]
        , label [] [ text ("Övrig summa " ++ toString addedSum) ]
        ]


sumInvoice : Invoice -> Float
sumInvoice invoice =
    List.foldl
        (\row total ->
            case row of
                HourlyReporting ( _, price, amount, _, addedSum ) ->
                    total + price * toFloat amount + addedSum

                DailyReporting ( _, price, amount, _, addedSum ) ->
                    total + price * toFloat amount + addedSum
        )
        0
        invoice.rows


paymentInfoSection : Invoice -> Html msg
paymentInfoSection invoice =
    let
        total =
            sumInvoice invoice
    in
    div [ class "payment-info-section" ]
        [ div [ class "total" ]
            [ label [] [ text ("Totalsumma " ++ toString total) ]
            , label [] [ text ("Moms " ++ toString (0.25 * total)) ]
            , label [] [ text ("Totalt inkl moms " ++ toString (1.25 * total)) ]
            ]
        ]


invoiceView ( year, month ) duration count =
    let
        invoice =
            { number = 2008, date = "2018-11-12", paymentDue = "35 dagar", reference = "Kristoffer Roupé" }

        contract =
            { customer = "Tingent", reference = "Teodor Överli", adress = "Regeringsgatan 74", postNumber = "111 39", county = "Stockholm" }

        rows =
            [ HourlyReporting ( "Mjukvaruutveckling", 1030, 100, "November 2018", 0 ) ]
    in
    div []
        [ button [ class "btn btn-sm btn-danger", onClick (ViewEvent GoHome) ] [ text "Back" ]
        , invoiceHeader invoice.number
        , invoiceContractDetails invoice contract
        , invoiceRows (Invoice rows)
        , paymentInfoSection (Invoice rows)

        --, div [ class "rows" ]
        --    [ p [] [ text (toString year) ]
        --    , p [] [ text (toString month) ]
        --    , p [] [ text (toString duration) ]
        --    , p [] [ text (toString count) ]
        --    ]
        , paymentInfo
        , footer
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
