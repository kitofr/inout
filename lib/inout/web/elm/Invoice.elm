module Invoice exposing (invoiceView)

import Html exposing (..)
import Html.Attributes exposing (class, id, src)
import Html.Events exposing (onClick)
import Msgs exposing (Msg(ViewEvent))
import ViewMsgs exposing (ViewMsg(GoHome))


ph : String -> Html Msg
ph txt =
    p [] [ text txt ]


pb : String -> Html Msg
pb txt =
    p []
        [ b [ class "lbl" ] [ text txt ] ]


pbsv : String -> String -> Html Msg
pbsv txt value =
    p []
        [ b [ class "lbl" ] [ text (txt ++ ": ") ]
        , text value
        ]


pbv : String -> a -> Html Msg
pbv txt value =
    p []
        [ b [ class "lbl" ] [ text (txt ++ ": ") ]
        , text (toString value)
        ]


invoiceHeader : Int -> Html Msg
invoiceHeader invoiceNumber =
    div [ id "faktura" ]
        [ div [ class "header" ]
            [ img [ src "images/agical_128x40.png" ] []
            , h1 [] [ text ("Faktura " ++ toString invoiceNumber) ]
            ]
        ]


paymentInfo : Html Msg
paymentInfo =
    div [ class "payment-info" ]
        [ pb "Betalningsinformation"
        , pb "Bankgiro 5345-5226"
        , pb "Organisationsnummer 556667-2597"
        , pb "Ange fakturanummer vid betalning."
        , p [] [ i [] [ text "Vid försenad betalning debiteras dröjsmålsränta med 15%" ] ]
        ]


invoiceContractDetails :
    { number : Int, date : String, paymentDue : String, reference : String }
    -> { customer : String, reference : String, adress : String, postNumber : String, county : String }
    -> Html Msg
invoiceContractDetails invoice contract =
    div []
        [ div [ class "info-header" ]
            [ div [ class "invoice-info" ]
                [ pbv "Fakturanummer" invoice.number
                , pbsv "Fakturadatum" invoice.date
                , pb ("Bet.Villkor " ++ invoice.paymentDue ++ " dagar netto")
                , pbsv "Referens Agical" invoice.reference
                ]
            , div []
                [ pbsv "Kund" contract.customer
                , pbsv "Referens" contract.reference
                , pb "Adress: "
                , div [ class "adress tab" ]
                    [ p [] [ text contract.adress ]
                    , br [] []
                    , p [] [ text (contract.postNumber ++ " " ++ contract.county) ]
                    ]
                ]
            ]
        ]


footer =
    div [ class "footer" ]
        [ div [ class "contact" ]
            [ pb "Kontakt"
            , ph "faktura@agical.se"
            , ph "https://www.agical.se"
            , ph "08-221580"
            ]
        , div [ class "agical" ]
            [ pb "Agical AB"
            , ph "Västerlånggatan 79A"
            , ph "111 29 Stockholm"
            , ph "Innehar F-skattesedel"
            ]
        ]


type Reporting
    = DailyReporting ( String, Float, Int, String, Float )
    | HourlyReporting ( String, Float, Int, String, Float )


type alias Invoice =
    { rows : List Reporting }


invoiceRows : Invoice -> Html Msg
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
    div [ class "invoice-row" ]
        [ pbsv "Beskrivning " description
        , pbv "Dagspris " price
        , pbv "Antal dagar " amount
        , pbsv "Dagarna avser: " fromMonths
        , pbv "Övrig summa " addedSum
        ]


invoiceHourRow : ( String, Float, Int, String, Float ) -> Html Msg
invoiceHourRow ( description, price, amount, fromMonths, addedSum ) =
    div [ class "row" ]
        [ pbsv "Beskrivning " description
        , pbv "Timpris " price
        , pbv "Antal timmar " amount
        , pbsv "Timmarna avser: " fromMonths
        , pbv "Övrig summa " addedSum
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


paymentInfoSection : Invoice -> Html Msg
paymentInfoSection invoice =
    let
        total =
            sumInvoice invoice
    in
    div [ class "payment-info-section" ]
        [ div [ class "total" ]
            [ pbv "Totalsumma" total
            , pbv "Moms" (25 * total)
            , pbv "Totalt inkl moms" (1.25 * total)
            ]
        ]


invoiceView : ( Int, Int ) -> a -> b -> Html Msg
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
        , div [ class "invoice" ]
            [ invoiceContractDetails invoice contract
            , invoiceRows (Invoice rows)
            , paymentInfoSection (Invoice rows)
            , paymentInfo
            ]
        , footer
        ]



--, div [ class "rows" ]
--    [ p [] [ text (toString year) ]
--    , p [] [ text (toString month) ]
--    , p [] [ text (toString duration) ]
--    , p [] [ text (toString count) ]
--    ]
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
