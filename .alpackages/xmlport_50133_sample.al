xmlport 50133 ImportOrderCOPY
{/*
    UseDefaultNamespace = true;
    UseRequestPage = false;
    Encoding = UTF8;

    //Format = VariableText;
    Direction = Import;
    //FileName = 'SO.csv';
    //TableSeparator = '<NewLine>';
    schema
    {
        textelement(NodeName1)
        {
            tableelement(SalesHeader; "Sales Header")
            {
                MinOccurs = Once;
                //SourceTableView = WHERE("Document Type" = FILTER(Quote));
                UseTemporary = true;


                fieldattribute(DocType; SalesHeader."Document Type")
                {

                }
                fieldattribute(CustomerNo; SalesHeader."Sell-to Customer No.")
                {

                }
                fieldattribute(OrderType; SalesHeader.Order_Type)
                {
                    Occurrence = Optional;
                }

                fieldattribute(PostingDate; SalesHeader."Posting Date")
                {
                    Occurrence = Optional;
                }
                fieldattribute(ShipmentDate; SalesHeader."Shipment Date")
                {
                    Occurrence = Optional;
                }
                fieldattribute(OrderDate; SalesHeader."Order Date")
                {
                    Occurrence = Optional;
                }
                fieldattribute(MarketingCode; SalesHeader."Marketing Code")
                {

                }
                fieldattribute(ShiptoName; SalesHeader."Ship-to Name")
                {
                    Occurrence = Optional;
                }
                fieldattribute(OrderStatus; SalesHeader."Order Status")
                {
                    Occurrence = Optional;
                }
                fieldattribute(ShiptoName2; SalesHeader."Ship-to Name 2")
                {
                    Occurrence = Optional;
                }
                fieldattribute(ShiptoAddress; SalesHeader."Ship-to Address")
                {
                    Occurrence = Optional;
                }
                fieldattribute(ShiptoAddress2; SalesHeader."Ship-to Address 2")
                {
                    Occurrence = Optional;
                }
                fieldattribute(ShiptoCity; SalesHeader."Ship-to City")
                {
                    Occurrence = Optional;
                }
                fieldattribute(ShiptoCountryReasonCode; SalesHeader."Ship-to Country/Region Code")
                {
                    Occurrence = Optional;
                }
                fieldattribute(ShiptoCounty; SalesHeader."Ship-to County")
                {
                    Occurrence = Optional;
                }
                fieldattribute(ShiptoPostCode; SalesHeader."Ship-to Post Code")
                {
                    Occurrence = Optional;
                }
                fieldattribute(ShiptoContact; SalesHeader."Ship-to Contact")
                {
                    Occurrence = Optional;
                }
                fieldattribute(ShippingAgentCode; SalesHeader."Shipping Agent Code")
                {
                    Occurrence = Optional;
                }
                fieldattribute(ShippingAgentService; SalesHeader."Shipping Agent Service Code")
                {
                    Occurrence = Optional;
                }
                fieldattribute(LocationCode; SalesHeader."Location Code")
                {
                    Occurrence = Optional;
                }
                fieldattribute(Amount; SalesHeader.Amount)
                {
                    Occurrence = Optional;
                }
                fieldattribute(TaxAreaCode; SalesHeader."Tax Area Code")
                {
                    Occurrence = Optional;
                }
                fieldattribute(TaxLiable; SalesHeader."Tax Liable")
                {
                    Occurrence = Optional;
                }
                fieldattribute(VATCountryRegionCode; SalesHeader."VAT Country/Region Code")
                {
                    Occurrence = Optional;
                }
                fieldattribute(WebOrder; SalesHeader."Web Order")
                {
                    Occurrence = Optional;
                }
                fieldattribute(CartrID; SalesHeader.CartID)
                {
                    Occurrence = Optional;
                }
                fieldattribute(SalesPersonCode; SalesHeader."Salesperson Code")
                {
                    Occurrence = Optional;
                }
                fieldattribute(ExternalDocNo; SalesHeader."External Document No.")
                {
                    Occurrence = Optional;
                }
                fieldattribute(SellToContact; SalesHeader."Sell-to Contact")
                {
                    Occurrence = Optional;
                }
                fieldattribute(SellToContactNo; SalesHeader."Sell-to Contact No.")
                {
                    Occurrence = Optional;
                }
                fieldattribute(InHandDate; SalesHeader."In-Hand Date")
                {
                    Occurrence = Optional;

                }
                fieldattribute(OwnShipping; SalesHeader."Own Shipping")
                {
                    Occurrence = Optional;
                }
                fieldattribute(ShippingAccountNo; SalesHeader."Shipping Account No.")
                {
                    Occurrence = Optional;
                }
                fieldattribute(PromoCode; SalesHeader."Promo Code")
                {
                    Occurrence = Optional;
                }

                //Sales Header
                trigger OnAfterInitRecord()
                BEGIN
                    DocNo := NoSeriesMgmt.GetNextNo(SalesSetup."Order Nos.", TODAY, TRUE);
                    SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                    SalesHeader."No." := DocNo;
                    SalesHeader."Posting Date" := WORKDATE;
                END;

                trigger OnAfterInsertRecord()
                BEGIN
                    IF NOT SalesHedRec.GET(SalesHeader."Document Type", SalesHeader."No.") THEN BEGIN
                        SalesHedRec.INIT;
                        SalesHedRec.TRANSFERFIELDS(SalesHeader);
                        SalesHedRec."Document Type" := SalesHeader."Document Type";
                        SalesHedRec.Validate(SalesHedRec."No.", SalesHeader."No.");
                        SalesHedRec.Validate(SalesHedRec."Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                        SalesHedRec."Web Order" := True;
                        SalesHedRec.INSERT(TRUE);
                    END;
                    LineNo := 0;
                END;

            }
        }
    }

    requestpage
    {
        layout
        {

        }


    }

    var
        SalesHedRec: Record 36;
        NoSeriesMgmt: Codeunit 396;
        DocNo: Text;
        SalesSetup: Record 311;
        SalesLineRec: Record 37;
        ImprintDetailRec: Record "Imprint Details";
        ImprintColorDetailRec: Record "Imprint Color Detail";
        LineNo: Integer;
        InSessionId: Text;
        OrderNosText: Text;
        FirstLine: Boolean;
        NoSeries: Codeunit 396;

        CustProvidedImage1: Text[50];
        CustProvidedImage2: Text[50];
        CustProvidedImage3: Text[50];
        CustProvidedImage4: Text[50];
        CustProvidedImage5: Text[50];
        CustProvidedImage6: Text[50];
        CartDetailRec: Record "Item Cart Detail";



    trigger OnPreXmlPort()
    BEGIN
        SalesSetup.GET;
        //FirstLine := true;
    END;
   
*/
}