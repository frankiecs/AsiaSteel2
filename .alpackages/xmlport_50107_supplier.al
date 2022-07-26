xmlport 50107 SupplierImport
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
            tableelement(PurHdr; "Purchase Header")
            {
                //Header
                textelement(VendorName) { MinOccurs = Zero; }
                textelement(VendorRefNo) { MinOccurs = Zero; }
                textelement(IssueDate) { MinOccurs = Zero; }
                textelement(Your_Ref) { MinOccurs = Zero; }
                textelement(ShipmentNo) { MinOccurs = Zero; }
                textelement(VendAgreeNo) { MinOccurs = Zero; }
                textelement(VesselDetail) { MinOccurs = Zero; }
                textelement(AmountDue) { MinOccurs = Zero; }
                textelement(Currency) { MinOccurs = Zero; }
                textelement(GoodsDescription) { MinOccurs = Zero; }
                textelement(Grade) { MinOccurs = Zero; }
                textelement(UnitPrice) { MinOccurs = Zero; }
                textelement(MT) { MinOccurs = Zero; }
                textelement(InvAmt) { MinOccurs = Zero; }
                textelement(DueDate) { MinOccurs = Zero; }
                textelement(InvAmt100pct) { MinOccurs = Zero; }
                textelement(InvAmt95pct) { MinOccurs = Zero; }
                textelement(Amount) { MinOccurs = Zero; }
                textelement(VAT) { MinOccurs = Zero; }
                textelement(Quantity) { MinOccurs = Zero; }
                textelement(Subject) { MinOccurs = Zero; }

                //Line
                textelement(LineItemNo) { MinOccurs = Zero; }
                textelement(LineDesc) { MinOccurs = Zero; }
                textelement(LineTonnage) { MinOccurs = Zero; }
                textelement(LineUnitPrice) { MinOccurs = Zero; }
                textelement(LineAmount) { MinOccurs = Zero; }
                textelement(LineCurrency) { MinOccurs = Zero; }
                textelement(LineQuantity) { MinOccurs = Zero; }
                textelement(LineUM) { MinOccurs = Zero; }
                textelement(LineDiscount) { MinOccurs = Zero; }


                trigger OnBeforeInsertRecord()
                begin

                    IF firstline then begin
                        firstline := false;
                        currxmlport.skip;
                    end;

                    IntHeader += 1;

                    EVALUATE(VenName, VendorName);
                    EVALUATE(VenRefNo, VendorRefNo);
                    If IssueDate.Trim() = '' then
                        IssDate := Today
                    else
                        EVALUATE(IssDate, IssueDate);
                    Evaluate(YourRef, Your_Ref);
                    Evaluate(ShipNo, ShipmentNo);
                    Evaluate(VendAgNo, VendAgreeNo);
                    Evaluate(VesselDetail, VesselDtl);
                    Evaluate(AmtDue, AmountDue);
                    Evaluate(CurCode, Currency);
                    Evaluate(GoodsDesc, GoodsDescription);
                    Evaluate(Grades, Grade);
                    Evaluate(UnitPrices, UnitPrice);
                    Evaluate(MTs, MT);
                    if (InvAmt.Trim() = '') or (invamt.Trim() = '0') then
                        InvAmount := 0
                    else
                        Evaluate(InvAmount, InvAmt);

                    If DueDate.Trim() = '' then
                        Due := Today
                    else
                        EVALUATE(Due, DueDate);
                    Evaluate(InvAmt100p, InvAmt100pct);
                    Evaluate(InvAmt95p, InvAmt95pct);
                    //Evaluate(totamt, Amount);
                    Evaluate(VATs, VAT);
                    Evaluate(qty, Quantity);
                    Evaluate(Subj, Subject);

                    //Evaluate(L_LineNO, LineItemNo);
                    Evaluate(L_Desc, LineDesc);
                    Evaluate(L_Tonnage, LineTonnage);
                    Evaluate(L_UnitPrice, LineUnitPrice);
                    Evaluate(L_Amt, LineAmount);
                    Evaluate(L_cur, LineCurrency);
                    Evaluate(L_Qty, LineQuantity);
                    Evaluate(L_UM, LineUM);
                    Evaluate(L_discount, LineDiscount);

                    Clear(tblVendor);
                    tblVendor.SetRange(Name, VenName);
                    iF not tblVendor.FindFirst then
                        Error('Vendor: ' + VenName + ' not found in system.');

                    if strlen(LineQuantity.Trim()) = 0 then
                        L_Qty := 1
                    else
                        if LineQuantity.Trim() = '0' then
                            L_Qty := 1
                        else
                            EVALUATE(L_Qty, LineQuantity);


                    if (strlen(LineUnitPrice.Trim()) = 0) and (L_Amt <> 0) then
                        L_UnitPrice := L_Amt / L_Qty
                    else
                        EVALUATE(L_UnitPrice, LineUnitPrice);

                    if booNotFirstLine = false then begin

                        //Message('header');

                        Clear(tblPurHdr);
                        tblPurHdr.Setrange("Document Type", tblPurHdr."Document Type"::Invoice);
                        tblPurHdr.SetFilter("Buy-from Vendor No.", tblVendor."No.");
                        tblPurHdr.SetFilter("Vendor Invoice No.", VenRefNo);
                        if TblPurHdr.FindFirst() then
                            Error('Vendor Invoice: ' + Format(VenRefNo) + ' already exist.');

                        Clear(tblPurHdr);
                        tblPurHdr.Init();
                        tblPurHdr."Document Type" := tblPurHdr."Document Type"::Invoice;

                        if PurchSetup.GET then;
                        DocNo := NoSeriesMgt.tryGetNextNo(PurchSetup."Invoice Nos.", IssDate);
                        tblPurHdr."No." := DocNo;
                        tblpurhdr."Posting Date" := Today;
                        tblPurHdr.Insert(true);

                        tblPurHdr.Validate("Buy-from Vendor No.", tblVendor."No.");
                        tblPurHdr.Validate("Vendor Invoice No.", VenRefNo);
                        tblPurHdr.Validate("Document Date", IssDate);
                        tblPurHdr.Validate("Currency Code", CurCode);
                        tblpurhdr.Validate("Due Date", Due);
                        tblpurhdr.Modify(true);





                        if YourRef.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'YOUR REF: ' + CopyStr(FORMAT(YourRef), 1, 80 - StrLen('YOUR REF: ')));
                            tblPurCommLine.Insert();
                        end;

                        if ShipNo.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'SHIPMENT NO.: ' + CopyStr(FORMAT(ShipNo), 1, 80 - StrLen('SHIPMENT NO.: ')));
                            tblPurCommLine.Insert();
                        end;


                        if VendAgNo.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'VENDER AGREE No.: ' + CopyStr(FORMAT(VendAgNo), 1, 80 - StrLen('VENDER AGREE No.: ')));
                            tblPurCommLine.Insert();
                        end;

                        if VesselDetail.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'VESSEL DETAIL: ' + CopyStr(FORMAT(VesselDetail), 1, 80 - StrLen('VESSEL DETAIL: ')));
                            tblPurCommLine.Insert();
                        end;

                        if AmtDue <> 0 then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'AMOUNT DUE: ' + CopyStr(FORMAT(AmtDue), 1, 80 - StrLen('AMOUNT DUE: ')));
                            tblPurCommLine.Insert();
                        end;

                        if GoodsDesc.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'GOODS DESC: ' + CopyStr(FORMAT(GoodsDesc), 1, 80 - StrLen('GOODS DESC: ')));
                            tblPurCommLine.Insert();
                        end;

                        if Grades.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'GRADE: ' + CopyStr(FORMAT(Grades), 1, 80 - StrLen('GRADE: ')));
                            tblPurCommLine.Insert();
                        end;

                        if UnitPrices.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'UNIT PrICE: ' + CopyStr(FORMAT(UnitPrices), 1, 80 - StrLen('UNIT PrICE: ')));
                            tblPurCommLine.Insert();
                        end;

                        if MTs.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'MT: ' + CopyStr(FORMAT(MTs), 1, 80 - StrLen('MT: ')));
                            tblPurCommLine.Insert();
                        end;

                        if InvAmount <> 0 then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'INVOICE AMT: ' + CopyStr(FORMAT(InvAmount), 1, 80 - StrLen('INVOICE AMT: ')));
                            tblPurCommLine.Insert();
                        end;

                        if InvAmt100p.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", '100% INVOICE AMT: ' + CopyStr(FORMAT(InvAmt100p), 1, 80 - StrLen('100% INVOICE AMT: ')));
                            tblPurCommLine.Insert();
                        end;

                        if InvAmt95p.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", '95% INVOICE AMT: ' + CopyStr(FORMAT(InvAmt95p), 1, 80 - StrLen('95% INVOICE AMT: ')));
                            tblPurCommLine.Insert();
                        end;

                        /*
                        if totamt <> 0 then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'AMOUNT: ' + CopyStr(FORMAT(totamt), 1, 80 - StrLen('AMOUNT: ')));
                            tblPurCommLine.Insert();
                        end;     
                        */

                        if VATs.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'VAT: ' + CopyStr(FORMAT(VATs), 1, 80 - StrLen('VAT: ')));
                            tblPurCommLine.Insert();
                        end;

                        if qty.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'QUANTITY: ' + CopyStr(FORMAT(qty), 1, 80 - StrLen('QUANTITY: ')));
                            tblPurCommLine.Insert();
                        end;

                        if Subj.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'SUBJECT: ' + CopyStr(FORMAT(Subj), 1, 80 - StrLen('SUBJECT: ')));
                            tblPurCommLine.Insert();
                        end;

                        booNotFirstLine := true;

                    end;

                    if (AmtDue <> 0) and (InvAmount <> 0) then begin
                        // 2 LINE NECESSAARY
                        CLEAR(tblPurLine);
                        tblPurLine.Init();
                        tblPurLine."Document Type" := tblPurLine."Document Type"::Invoice;
                        tblPurLine."Document No." := DocNo;
                        tblpurline.Type := tblPurLine.type::" ";
                        tblPurLine."Line No." := 10000;
                        tblPurLine.Description := 'Invoice Total Amount: ' + Format(InvAmount);
                        tblPurLine.Insert(true);

                        CLEAR(tblPurLine);
                        tblPurLine.Init();
                        tblPurLine."Document Type" := tblPurLine."Document Type"::Invoice;
                        tblPurLine."Document No." := DocNo;
                        tblPurLine."Line No." := 20000;
                        tblPurLine.Insert(true);
                        tblPurLine.type := tblPurLine.type::"G/L Account";
                        tblpurline.Validate("No.", '8450');

                        if Subj.Trim() <> '' then FinalDesc := Subj;
                        if GoodsDesc.Trim() <> '' then FinalDesc := GoodsDesc;
                        if L_Desc.Trim() <> '' then FinalDesc := L_Desc;
                        If FinalDesc.Trim() = '' then FinalDesc := 'Invoice Amount Due: ';

                        tblPurLine.Validate(Description, FinalDesc);
                        tblPurLine.Validate("Currency Code", L_Cur);
                        tblPurLine.Validate(Quantity, 1);
                        tblPurLine.Validate("Direct Unit Cost", AmtDue);
                        //tblPurLine.Validate("Unit of Measure", L_UM);

                        tblPurLine.Modify(true);

                        //if tblPurLine."Line Amount" <> L_Amt then
                        //    Error('Imported line amount: ' + FORMAT(L_Amt) + 'not equal to calculated line acount: ' + Format(tblPurLine."Line Amount"));

                    end else
                        if (AmtDue <> 0) or (InvAmount <> 0) then begin
                            // 1 LINE NECESSAARY

                            CLEAR(tblPurLine);
                            tblPurLine.Init();
                            tblPurLine."Document Type" := tblPurLine."Document Type"::Invoice;
                            tblPurLine."Document No." := DocNo;
                            tblPurLine."Line No." := 10000;
                            tblPurLine.Insert(true);
                            tblPurLine.type := tblPurLine.type::"G/L Account";
                            tblpurline.Validate("No.", '8450');

                            if Subj.Trim() <> '' then FinalDesc := Subj;
                            if GoodsDesc.Trim() <> '' then FinalDesc := GoodsDesc;
                            if L_Desc.Trim() <> '' then FinalDesc := L_Desc;
                            If FinalDesc.Trim() = '' then FinalDesc := 'Invoice Amount Due: ';

                            tblPurLine.Validate(Description, FinalDesc);
                            tblPurLine.Validate("Currency Code", L_Cur);
                            tblPurLine.Validate(Quantity, 1);
                            if AmtDue <> 0 then
                                tblPurLine.Validate("Direct Unit Cost", AmtDue)
                            else
                                tblPurLine.Validate("Direct Unit Cost", InvAmount);
                            tblPurLine.Modify(true);
                        end;

                    if L_Tonnage.Trim() <> '' then begin
                        tblPurCommLine.Reset();
                        tblPurCommLine.Init();
                        tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                        tblPurCommLine.Validate("No.", tblPurHdr."No.");
                        tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                        tblPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                        tblPurCommLine.Validate("Date", IssDate);
                        tblPurCommLine.Validate("Comment", 'TONNAGE: ' + CopyStr(L_Tonnage, 1, 80 - StrLen('TONNAGE: ')));
                        tblPurCommLine.Insert();
                    end;

                    if L_discount <> 0 then begin
                        tblPurCommLine.Reset();
                        tblPurCommLine.Init();
                        tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                        tblPurCommLine.Validate("No.", tblPurHdr."No.");
                        tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                        tblPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                        tblPurCommLine.Validate("Date", IssDate);
                        tblPurCommLine.Validate("Comment", 'DISCOUNT: ' + CopyStr(FORMAT(L_discount), 1, 80 - StrLen('DISCOUNT: ')));
                        tblPurCommLine.Insert();
                    end;

                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        Firstline := true;
        if PurchSetup.GET then
            DocNo := NoSeriesMgt.GetNextNo(PurchSetup."Invoice Nos.", Today, true);
    end;

    var
        IntHeader: Integer;
        intLine: Integer;
        tblPurHdr: Record "Purchase Header";
        tblPurLine: Record "Purchase Line";
        tblPurCommLine: Record "Purch. Comment Line";
        tblPurCommLine2: Record "Purch. Comment Line";
        intPurCommLineNo: Integer;
        tblVendor: Record Vendor;
        tblCurrency: Record Currency;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PurchSetup: record "Purchases & Payables Setup";

        DocNo: code[20];
        VenName: Text[100];
        VenRefNo: Code[35];
        IssDate: Date;
        Subj: Text[80];
        YourRef: Text[80];
        TotAmt: Decimal;
        CurCode: Code[10];
        VendAgNo: Text[80];
        Due: Date;
        ServAddr: Text[80];
        ShipNo: Text[80];
        VesselDtl: Text[80];
        AmtDue: Decimal;
        GoodsDesc: Text[80];
        Grades: Text[80];
        UnitPrices: Text[80];
        MTs: Text[80];
        InvAmount: Decimal;
        VATs: Text[80];
        Qty: Text[80];
        Subjects: Text[80];
        InvAmt100p: Text[80];
        InvAmt95p: Text[80];


        L_LineNO: Integer;
        L_Desc: Text[100];
        L_Tonnage: Text[100];
        L_UnitPrice: Decimal;
        L_Amt: Decimal;
        L_Cur: Code[10];
        L_Qty: Decimal;
        L_UM: Code[10];
        L_discount: Decimal;
        booNotFirstLine: Boolean;
        Firstline: Boolean;

        FinalDesc: text[100];



    procedure GetlastCommentLineNo() PurCommLineNo: integer
    begin
        tblPurCommLine2.Reset();
        tblPurCommLine2.SetRange("Document Type", tblPurHdr."Document Type"::Invoice);
        tblPurCommLine2.SetRange("No.", tblPurHdr."No.");
        if tblPurCommLine2.findset then
            PurCommLineNo := tblPurCommLine2.GETRANGEMAX("Line No.");
    end;
}