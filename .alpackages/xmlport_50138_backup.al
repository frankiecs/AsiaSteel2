xmlport 50138 CommInvoiceImport2
{

    Direction = Import;
    TextEncoding = UTF8;
    Format = VariableText;
    FieldDelimiter = '"';
    FieldSeparator = ',';

    schema
    {
        textelement(root)
        {
            tableelement(PurHdr; "Sales Header")
            {

                textelement(Documenttype) { MinOccurs = Zero; }
                textelement(DocumentDate) { MinOccurs = Zero; }
                textelement(PN_NO) { MinOccurs = Zero; }
                textelement(CustomerName) { MinOccurs = Zero; }
                textelement(CustomerAddress) { MinOccurs = Zero; }
                textelement(ContractNo) { MinOccurs = Zero; }
                textelement(VesselName) { MinOccurs = Zero; }
                textelement(Commodity) { MinOccurs = Zero; }
                textelement(Specification) { MinOccurs = Zero; }
                textelement(ActualWeight) { MinOccurs = Zero; }
                textelement(DryWright) { MinOccurs = Zero; }
                textelement(ProvisionalPrice) { MinOccurs = Zero; }
                textelement(Currency) { MinOccurs = Zero; }
                textelement(ShippedGoodValue100Pct) { MinOccurs = Zero; }
                textelement(ShippedGoodValue95Pct) { MinOccurs = Zero; }
                textelement(PriceTerm) { MinOccurs = Zero; }
                textelement(FInalAmountDue) { MinOccurs = Zero; }
                textelement(FinalCommInvValue100Pct) { MinOccurs = Zero; }


                trigger OnBeforeInsertRecord()
                begin

                    IF firstline then begin
                        firstline := false;
                        currxmlport.skip;
                    end;

                    IntHeader += 1;

                    EVALUATE(Doctype, Documenttype);
                    EVALUATE(DocDate, DocumentDate);
                    EVALUATE(PNNO, PN_NO);
                    EVALUATE(CustName, CustomerName);
                    EVALUATE(CustAddress, CustomerAddress);
                    EVALUATE(ContractNos, ContractNo);
                    Evaluate(Vessel, VesselName);
                    EVALUATE(Commodities, Commodity);
                    Evaluate(Spec, Specification);
                    EVALUATE(ActualWeights, ActualWeight);
                    EVALUATE(DryWrights, DryWright);
                    EVALUATE(ProvisPrice, ProvisionalPrice);
                    EVALUATE(curr, Currency);

                    if (ShippedGoodValue100Pct.Trim() = '') or (ShippedGoodValue100Pct.Trim() = '0') then
                        ShippedGoodValue100P := 0
                    else
                        EVALUATE(ShippedGoodValue100P, ShippedGoodValue100Pct);

                    if (ShippedGoodValue95Pct.Trim() = '') or (ShippedGoodValue95Pct.Trim() = '0') then
                        ShippedGoodValue95P := 0
                    else
                        EVALUATE(ShippedGoodValue95P, ShippedGoodValue95Pct);
                    Evaluate(PriceTerms, PriceTerm);

                    if (FInalAmountDue.Trim() = '') or (FInalAmountDue.Trim() = '0') then
                        FInalAmtDue := 0
                    else
                        Evaluate(FInalAmtDue, FInalAmountDue);

                    //if (FinalCommInvValue100Pct.Trim() = '') or (FinalCommInvValue100Pct.Trim() = '0') then
                    //    FinalCommInvValue100P := 0
                    //else
                    //    Evaluate(FinalCommInvValue100P, FinalCommInvValue100Pct);

                    Clear(tblCustomer);
                    tblCustomer.SetRange(Name, CustName);
                    iF not tblCustomer.FindFirst then
                        Error('Customer: ' + CustName + ' not found in system.');


                    Clear(tblSalesHdr);
                    tblSalesHdr.setrange("Document Type", tblSalesHdr."Document Type"::Invoice);
                    tblSalesHdr.setrange("Bill-to Customer No.", tblCustomer."No.");
                    tblsaleshdr.SetRange("External Document No.", ContractNos);
                    IF tblSalesHdr.findfirst then
                        Error('Sales Contract No. already exist: ' + ContractNos);


                    L_Qty := 1;

                    if booNotFirstLine = false then begin

                        //Message('header');

                        Clear(tblSalesHdr);
                        tblSalesHdr.Init();
                        tblSalesHdr."Document Type" := tblSalesHdr."Document Type"::Invoice;

                        tblSalesHdr."No." := DocNo;
                        tblSalesHdr."Posting Date" := Today;
                        tblSalesHdr.Insert(true);

                        tblSalesHdr.Validate("Sell-to Customer No.", tblCustomer."No.");
                        tblSalesHdr.Validate("External Document No.", ContractNos);
                        tblSalesHdr.Validate("Document Date", DocDate);
                        tblSalesHdr.Validate("Currency Code", Currency);
                        tblSalesHdr.Validate("Your Reference", PNNO);
                        tblsaleshdr.Validate("Sell-to Address", CustomerAddress);
                        tblSalesHdr.Modify(true);


                        if Doctype.Trim() <> '' then begin
                            tblSalesCommLine.Reset();
                            tblSalesCommLine.Init();
                            tblSalesCommLine.Validate("Document Type", tblSalesHdr."Document Type"::Invoice);
                            tblSalesCommLine.Validate("No.", tblSalesHdr."No.");
                            tblSalesCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblSalesCommLine.Validate("Document Line No.", 0);
                            tblSalesCommLine.Validate("Date", DocDate);
                            tblSalesCommLine.Validate("Comment", 'DOC TYPE: ' + CopyStr(Doctype, 1, 80 - StrLen('DOC TYPE: ')));
                            tblSalesCommLine.Insert();
                        end;

                        if Vessel.Trim() <> '' then begin
                            tblSalesCommLine.Reset();
                            tblSalesCommLine.Init();
                            tblSalesCommLine.Validate("Document Type", tblSalesHdr."Document Type"::Invoice);
                            tblSalesCommLine.Validate("No.", tblSalesHdr."No.");
                            tblSalesCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblSalesCommLine.Validate("Document Line No.", 0);
                            tblSalesCommLine.Validate("Date", DocDate);
                            tblSalesCommLine.Validate("Comment", 'VESSEL: ' + CopyStr(Vessel, 1, 80 - StrLen('VESSEL: ')));
                            tblSalesCommLine.Insert();
                        end;

                        if Commodities.Trim() <> '' then begin
                            tblSalesCommLine.Reset();
                            tblSalesCommLine.Init();
                            tblSalesCommLine.Validate("Document Type", tblSalesHdr."Document Type"::Invoice);
                            tblSalesCommLine.Validate("No.", tblSalesHdr."No.");
                            tblSalesCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblSalesCommLine.Validate("Document Line No.", 0);
                            tblSalesCommLine.Validate("Date", DocDate);
                            tblSalesCommLine.Validate("Comment", 'COMMODITY: ' + CopyStr(Commodities, 1, 80 - StrLen('COMMODITY: ')));
                            tblSalesCommLine.Insert();
                        end;

                        if Spec.Trim() <> '' then begin
                            tblSalesCommLine.Reset();
                            tblSalesCommLine.Init();
                            tblSalesCommLine.Validate("Document Type", tblSalesHdr."Document Type"::Invoice);
                            tblSalesCommLine.Validate("No.", tblSalesHdr."No.");
                            tblSalesCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblSalesCommLine.Validate("Document Line No.", 0);
                            tblSalesCommLine.Validate("Date", DocDate);
                            tblSalesCommLine.Validate("Comment", 'SPECIFICATION: ' + CopyStr(Spec, 1, 80 - StrLen('SPECIFICATION: ')));
                            tblSalesCommLine.Insert();
                        end;

                        if ActualWeights.Trim() <> '' then begin
                            tblSalesCommLine.Reset();
                            tblSalesCommLine.Init();
                            tblSalesCommLine.Validate("Document Type", tblSalesHdr."Document Type"::Invoice);
                            tblSalesCommLine.Validate("No.", tblSalesHdr."No.");
                            tblSalesCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblSalesCommLine.Validate("Document Line No.", 0);
                            tblSalesCommLine.Validate("Date", DocDate);
                            tblSalesCommLine.Validate("Comment", 'ACTUAL WEIGHT: ' + CopyStr(ActualWeights, 1, 80 - StrLen('ACTUAL WEIGHT: ')));
                            tblSalesCommLine.Insert();
                        end;

                        if ShippedGoodValue100P <> 0 then begin
                            tblSalesCommLine.Reset();
                            tblSalesCommLine.Init();
                            tblSalesCommLine.Validate("Document Type", tblSalesHdr."Document Type"::Invoice);
                            tblSalesCommLine.Validate("No.", tblSalesHdr."No.");
                            tblSalesCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblSalesCommLine.Validate("Document Line No.", 0);
                            tblSalesCommLine.Validate("Date", DocDate);
                            tblSalesCommLine.Validate("Comment", '100% SHIPPED GOODS VALUE: ' + CopyStr(FORMAT(ShippedGoodValue100P), 1, 80 - StrLen('100% SHIPPED GOODS VALUE: ')));
                            tblSalesCommLine.Insert();
                        end;

                        if ShippedGoodValue95P <> 0 then begin
                            tblSalesCommLine.Reset();
                            tblSalesCommLine.Init();
                            tblSalesCommLine.Validate("Document Type", tblSalesHdr."Document Type"::Invoice);
                            tblSalesCommLine.Validate("No.", tblSalesHdr."No.");
                            tblSalesCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblSalesCommLine.Validate("Document Line No.", 0);
                            tblSalesCommLine.Validate("Date", DocDate);
                            tblSalesCommLine.Validate("Comment", '95% SHIPPED GOODS VALUE: ' + CopyStr(FORMAT(ShippedGoodValue95P), 1, 80 - StrLen('95% SHIPPED GOODS VALUE: ')));
                            tblSalesCommLine.Insert();
                        end;

                        if PriceTerms.Trim() <> '' then begin
                            tblSalesCommLine.Reset();
                            tblSalesCommLine.Init();
                            tblSalesCommLine.Validate("Document Type", tblSalesHdr."Document Type"::Invoice);
                            tblSalesCommLine.Validate("No.", tblSalesHdr."No.");
                            tblSalesCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblSalesCommLine.Validate("Document Line No.", 0);
                            tblSalesCommLine.Validate("Date", DocDate);
                            tblSalesCommLine.Validate("Comment", 'Price Term: ' + CopyStr(FORMAT(PriceTerms), 1, 80 - StrLen('Price Term: ')));
                            tblSalesCommLine.Insert();
                        end;

                        if FInalAmtDue <> 0 then begin
                            tblSalesCommLine.Reset();
                            tblSalesCommLine.Init();
                            tblSalesCommLine.Validate("Document Type", tblSalesHdr."Document Type"::Invoice);
                            tblSalesCommLine.Validate("No.", tblSalesHdr."No.");
                            tblSalesCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblSalesCommLine.Validate("Document Line No.", 0);
                            tblSalesCommLine.Validate("Date", DocDate);
                            tblSalesCommLine.Validate("Comment", 'Price Term: ' + CopyStr(FORMAT(PriceTerms), 1, 80 - StrLen('Price Term: ')));
                            tblSalesCommLine.Insert();
                        end;

                        if FinalCommInvValue100P <> 0 then begin
                            tblSalesCommLine.Reset();
                            tblSalesCommLine.Init();
                            tblSalesCommLine.Validate("Document Type", tblSalesHdr."Document Type"::Invoice);
                            tblSalesCommLine.Validate("No.", tblSalesHdr."No.");
                            tblSalesCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblSalesCommLine.Validate("Document Line No.", 0);
                            tblSalesCommLine.Validate("Date", DocDate);
                            tblSalesCommLine.Validate("Comment", '100% FINAL COMM. INVOICE VALUE: ' + CopyStr(FORMAT(FinalCommInvValue100P), 1, 80 - StrLen('100% FINAL COMM. INVOICE VALUE: ')));
                            tblSalesCommLine.Insert();
                        end;

                        // Sales Line

                        Clear(Price95p);
                        Price95p := ShippedGoodValue95P / DryWrights;
                        //6110
                        /*
                                                EVALUATE(DryWrights, DryWright);
                                                //EVALUATE(ProvisPrice, ProvisionalPrice);
                                                L_Qty

                                                Line Description (95% value)
                        */


                        //booNotFirstLine := true;
                        //L_LineNO := 1;

                        CLEAR(tblSalesLine);
                        tblSalesLine.Init();
                        tblSalesLine."Document Type" := tblSalesLine."Document Type"::Invoice;
                        tblSalesLine."Document No." := DocNo;
                        tblSalesLine."Line No." := 10000;
                        tblSalesLine.Insert(true);
                        tblSalesLine.type := tblSalesLine.type::" ";
                        tblSalesLine.Description := Doctype;
                        tblSalesLine.Modify(true);

                        CLEAR(tblSalesLine);
                        tblSalesLine.Init();
                        tblSalesLine."Document Type" := tblSalesLine."Document Type"::Invoice;
                        tblSalesLine."Document No." := DocNo;
                        tblSalesLine."Line No." := 20000;
                        tblSalesLine.Insert(true);
                        tblSalesLine.type := tblSalesLine.type::" ";
                        tblSalesLine.Description := 'Dryweight: ' + Format(DryWrights) + ', Provis. Price: ' + Format(ProvisPrice) + ' , 100% Shipped Value: ' + Format(ShippedGoodValue100P);
                        tblSalesLine.Modify(true);

                        tblSalesLine.Init();
                        tblSalesLine."Document Type" := tblSalesLine."Document Type"::Invoice;
                        tblSalesLine."Document No." := DocNo;
                        tblSalesLine."Line No." := 30000;
                        tblSalesLine.Insert(true);
                        tblSalesLine.type := tblSalesLine.type::"G/L Account";
                        tblSalesLine.Validate("No.", '6110');
                        tblSalesLine.Validate(Description, '95% SHIPPED GOODS VALUE');
                        tblSalesLine.Validate(Quantity, DryWrights);  //123
                        tblSalesLine.Validate("Unit Price", Price95p);
                        tblSalesLine.Modify(true);
                    end;
                end;
            }
        }
    }
    trigger OnPreXmlPort()
    begin
        Firstline := true;
        if SalesSetup.GET then
            DocNo := NoSeriesMgt.GetNextNo(SalesSetup."Invoice Nos.", Today, true);
    end;

    var
        IntHeader: Integer;
        intLine: Integer;
        tblSalesHdr: Record "Sales Header";
        tblSalesLine: Record "Sales Line";
        tblSalesCommLine: Record "Sales Comment Line";
        tblSalesCommLine2: Record "Sales Comment Line";
        intSalesCommLineNo: Integer;
        tblCustomer: Record Customer;
        tblCurrency: Record Currency;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        SalesSetup: record "Sales & Receivables Setup";


        Doctype: Text[80];
        DocDate: Date;
        PNNO: Text[80];
        CustName: Text[100];
        CustAddress: Text[80];
        ContractNos: Text[80];
        Vessel: Text[80];
        Commodities: Text[80];
        Spec: Text[80];
        ActualWeights: Text[80];
        DryWrights: Decimal;
        ProvisPrice: Decimal;
        curr: Code[10];
        ShippedGoodValue100P: Decimal;
        ShippedGoodValue95P: Decimal;
        PriceTerms: Text[80];
        FInalAmtDue: Decimal;
        FinalCommInvValue100P: Decimal;
        Price95p: Decimal;


        L_Qty: Integer;
        L_LineNO: Integer;
        Firstline: Boolean;
        booNotFirstLine: Boolean;
        DocNo: code[20];



    procedure GetlastCommentLineNo() SalesCommLineNo: integer
    begin
        Clear(tblSalesCommLine2);
        tblSalesCommLine2.SetRange("Document Type", tblSalesHdr."Document Type"::Invoice);
        tblSalesCommLine2.SetRange("No.", tblSalesHdr."No.");
        tblSalesCommLine2.SetCurrentKey("Line No.");
        if tblSalesCommLine2.FindLast() then
            SalesCommLineNo := tblSalesCommLine2."Line No."
        else
            SalesCommLineNo := 0;
    end;
}