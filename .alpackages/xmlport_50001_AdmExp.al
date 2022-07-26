xmlport 50101 AdmExp
{
    //AdmExp.TextEncoding := TEXTENCODING::Windows;

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

                textelement(VendorName) { MinOccurs = Zero; }
                textelement(VendorRefNo) { MinOccurs = Zero; }
                textelement(IssueDate) { MinOccurs = Zero; }
                textelement(Subject) { MinOccurs = Zero; }
                textelement(TotalAmount) { MinOccurs = Zero; }
                textelement(Currency) { MinOccurs = Zero; }
                textelement(AcctNo) { MinOccurs = Zero; }
                textelement(DueDate) { MinOccurs = Zero; }
                textelement(ServiceAddr) { MinOccurs = Zero; }
                textelement(NoOfShipment) { MinOccurs = Zero; }

                textelement(LineItemNo) { MinOccurs = Zero; }
                textelement(LinePostDate) { MinOccurs = Zero; }
                textelement(LineSFNo) { MinOccurs = Zero; }
                textelement(LineAmount) { MinOccurs = Zero; }
                textelement(LineDesc) { MinOccurs = Zero; }
                textelement(LineQuantity) { MinOccurs = Zero; }
                textelement(LineUnitPrice) { MinOccurs = Zero; }
                textelement(LineAirwayBillNo) { MinOccurs = Zero; }
                textelement(LineShipmentDate) { MinOccurs = Zero; }
                textelement(LineOrign) { MinOccurs = Zero; }
                textelement(LineDestination) { MinOccurs = Zero; }
                textelement(LineChargeTotal) { MinOccurs = Zero; }



                trigger OnBeforeInsertRecord()
                begin

                    IntHeader += 1;
                    //Message(format(IntHeader) + '   ' + Format((VendorName) + '   ' + Format(IssueDate) + '  -Line-  ' + Format(LineItemNo) + '  -  ' + Format(LineAmount)));

                    //If IntHeader = 1 then begin

                    EVALUATE(VenName, VendorName);
                    EVALUATE(VenRefNo, VendorRefNo);
                    EVALUATE(IssDate, IssueDate);
                    EVALUATE(Subj, Subject);
                    EVALUATE(TotAmt, TotalAmount);
                    EVALUATE(CurCode, Currency);
                    EVALUATE(AccNo, AcctNo);
                    EVALUATE(Due, DueDate);
                    EVALUATE(ServAddr, ServiceAddr);
                    EVALUATE(NoOfShip, NoOfShipment);

                    EVALUATE(L_LineNO, LineItemNo);
                    EVALUATE(L_PostDate, LinePostDate);
                    EVALUATE(L_SFNo, LineSFNo);
                    EVALUATE(L_Amt, LineAmount);
                    EVALUATE(L_Desc, LineDesc);

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

                    EVALUATE(L_AirwayBillNo, LineAirwayBillNo);
                    EVALUATE(L_ShipmentDate, LineShipmentDate);
                    EVALUATE(L_Orign, LineOrign);
                    EVALUATE(L_Dest, LineDestination);
                    if strlen(LineChargeTotal.Trim()) = 0 then
                        L_ChargeTot := 0
                    else
                        EVALUATE(L_ChargeTot, LineChargeTotal);

                    if booNotFirstLine = false then begin

                        //Message('header');

                        tblVendor.Reset();
                        tblVendor.SetFilter(Name, VenName);
                        //if not tblVendor.FindFirst() then
                        //    Error('Vendor Name:' + Format(VenName) + ' not found.');

                        tblPurHdr.Reset();
                        tblPurHdr.Setrange("Document Type", tblPurHdr."Document Type"::Invoice);
                        //tblPurHdr.SetFilter("Buy-from Vendor No.", tblVendor."No.");
                        tblPurHdr.SetFilter("Buy-from Vendor No.", '20000');
                        tblPurHdr.SetFilter("Vendor Invoice No.", VenRefNo);
                        tblPurHdr.SetRange("Document Date", IssDate);
                        //if TblPurHdr.FindFirst() then
                        //    Error('Vendor Invoice: ' + Format(VenRefNo) + ' already exist.');

                        tblPurHdr.reset;
                        tblPurHdr.Init();
                        tblPurHdr."Document Type" := tblPurHdr."Document Type"::Invoice;

                        if PurchSetup.GET then;
                        DocNo := NoSeriesMgt.tryGetNextNo(PurchSetup."Invoice Nos.", IssDate);
                        tblPurHdr."No." := DocNo;
                        tblpurhdr."Posting Date" := Today;
                        tblPurHdr.Insert(true);

                        //tblPurHdr.Validate("Buy-from Vendor No.", tblVendor."No.");
                        tblPurHdr.Validate("Buy-from Vendor No.", '20000');
                        tblPurHdr.Validate("Vendor Invoice No.", VenRefNo);
                        tblPurHdr.Validate("Document Date", IssDate);
                        tblPurHdr.Validate("Currency Code", Currency);
                        tblpurhdr.Validate("Due Date", Due);
                        tblpurhdr.Modify(true);


                        Clear(intPurCommLineNo);
                        tblPurCommLine.Reset();
                        tblPurCommLine.SetRange("Document Type", tblPurHdr."Document Type"::Invoice);
                        tblPurCommLine.SetRange("No.", tblPurHdr."No.");
                        if tblPurCommLine.findset then
                            intPurCommLineNo := tblPurCommLine.GETRANGEMAX("Line No.");

                        if Subj.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'SUBJECT: ' + CopyStr(Subj, 1, 80 - StrLen('SUBJECT: ')));
                            tblPurCommLine.Insert();
                        end;

                        if ServAddr.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'PROPERTY ADDRESS: ' + CopyStr(ServAddr, 1, 80 - StrLen('PROPERTY ADDRESS: ')));
                            tblPurCommLine.Insert();
                        end;

                        if NoOfShip.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'NO. OF SHIPMENT: ' + CopyStr(FORMAT(NoOfShip), 1, 80 - StrLen('NO. OF SHIPMENT: ')));
                            tblPurCommLine.Insert();
                        end;

                        booNotFirstLine := true;

                    end;

                    //end;

                    //If IntHeader > 1 then begin

                    //Message('L_LineNO: ' + FORMAT(LineItemNo) + '     Description: ' + L_SFNo);

                    tblPurLine.Reset();
                    tblPurLine.Init();
                    tblPurLine."Document Type" := tblPurLine."Document Type"::Invoice;
                    tblPurLine."Document No." := DocNo;
                    tblPurLine."Line No." := L_LineNO * 10000;
                    tblPurLine.Insert(true);

                    tblPurLine.type := tblPurLine.type::"G/L Account";
                    //tblPurline."No." := '8450';
                    tblpurline.Validate("No.", '8450');


                    IF L_SFNo <> '' then
                        tblPurLine.validate(Description, FORMAT(L_PostDate) + ' - ' + FORMAT(L_SFNo))
                    else
                        tblPurLine.Validate(Description, L_Desc);

                    //tblPurLine.Validate("Line Amount", L_Amt);
                    tblPurLine.Validate(Quantity, L_Qty);
                    tblPurLine.Validate("Direct Unit Cost", L_UnitPrice);
                    tblPurLine.Modify(true);

                    //if tblPurLine."Line Amount" <> L_Amt then
                    //    Error('Imported line amount: ' + FORMAT(L_Amt) + 'not equal to calculated line acount: ' + Format(tblPurLine."Line Amount"));

                    if L_AirwayBillNo.Trim() <> '' then begin
                        tblPurCommLine.Reset();
                        tblPurCommLine.Init();
                        tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                        tblPurCommLine.Validate("No.", tblPurHdr."No.");
                        tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                        tblPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                        tblPurCommLine.Validate("Date", IssDate);
                        tblPurCommLine.Validate("Comment", 'Airway Bill No: ' + CopyStr(L_AirwayBillNo, 1, 80 - StrLen('Airway Bill No: ')));
                        tblPurCommLine.Insert();
                    end;

                    if L_ShipmentDate <> 0D then begin
                        tblPurCommLine.Reset();
                        tblPurCommLine.Init();
                        tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                        tblPurCommLine.Validate("No.", tblPurHdr."No.");
                        tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                        tblPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                        tblPurCommLine.Validate("Date", IssDate);
                        tblPurCommLine.Validate("Comment", 'Shipment Date: ' + CopyStr(FORMAT(L_ShipmentDate), 1, 80 - StrLen('Shipment Date: ')));
                        tblPurCommLine.Insert();
                    end;

                    if L_Orign.Trim() <> '' then begin
                        tblPurCommLine.Reset();
                        tblPurCommLine.Init();
                        tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                        tblPurCommLine.Validate("No.", tblPurHdr."No.");
                        tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                        tblPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                        tblPurCommLine.Validate("Date", IssDate);
                        tblPurCommLine.Validate("Comment", 'Origin: ' + CopyStr(FORMAT(L_Orign), 1, 80 - StrLen('Origin: ')));
                        tblPurCommLine.Insert();
                    end;


                    if L_Dest.Trim() <> '' then begin
                        tblPurCommLine.Reset();
                        tblPurCommLine.Init();
                        tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                        tblPurCommLine.Validate("No.", tblPurHdr."No.");
                        tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                        tblPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                        tblPurCommLine.Validate("Date", IssDate);
                        tblPurCommLine.Validate("Comment", 'Destination: ' + CopyStr(FORMAT(L_Dest), 1, 80 - StrLen('Destination: ')));
                        tblPurCommLine.Insert();
                    end;

                    if L_ChargeTot <> 0 then begin
                        tblPurCommLine.Reset();
                        tblPurCommLine.Init();
                        tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                        tblPurCommLine.Validate("No.", tblPurHdr."No.");
                        tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                        tblPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                        tblPurCommLine.Validate("Date", IssDate);
                        tblPurCommLine.Validate("Comment", 'Charge Total: ' + CopyStr(FORMAT(L_ChargeTot), 1, 80 - StrLen('Charge Total: ')));
                        tblPurCommLine.Insert();
                    end;
                end;

                //end;
            }
            /*    
            tableelement(PurLine; "Purchase Line")
            {
                textelement(LineItemNo) { }
                textelement(LinePostDate) { }
                textelement(LineSFNo) { }
                textelement(LineAmount) { }
                textelement(LineDesc) { }
                textelement(LineQuantity) { }
                textelement(LineUnitPrice) { }
                textelement(LineAirwayBillNo) { }
                textelement(LineShipmentDate) { }
                textelement(LineOrign) { }
                textelement(LineDestination) { }
                textelement(LineChargeTotal) { }




                trigger OnBeforeInsertRecord()
                begin

                    IntLine += 1;
                    //Message('inner Loop:' + Format(myInt));

                    EVALUATE(L_LineNO, LineItemNo);
                    EVALUATE(L_PostDate, LinePostDate);
                    EVALUATE(L_SFNo, LineSFNo);
                    EVALUATE(L_Amt, LineAmount);
                    EVALUATE(L_Desc, LineDesc);
                    EVALUATE(L_Qty, LineQuantity);
                    EVALUATE(L_UnitPrice, LineUnitPrice);
                    EVALUATE(L_AirwayBillNo, LineAirwayBillNo);
                    EVALUATE(L_ShipmentDate, LineShipmentDate);
                    EVALUATE(L_Orign, LineOrign);
                    EVALUATE(L_Dest, LineDestination);
                    EVALUATE(L_ChargeTot, LineChargeTotal);

                    //LastLineNo := IntLine * 10000;

                    //GenJnlLine.Init();


                    tblPurLine."Document Type" := tblPurLine."Document Type"::Invoice;
                    tblPurLine."Document No." := DocNo;
                    tblPurLine."Line No." := L_LineNO * 10000;
                    tblPurLine.Insert();

                    //123
                    tblPurLine.type := tblPurLine.type::"G/L Account";
                    tblPurline."No." := '8450';


                    IF L_SFNo <> '' then
                        tblPurLine.validate(Description, FORMAT(L_PostDate) + FORMAT(L_SFNo))
                    else
                        tblPurLine.Validate(Description, L_Desc);

                    //tblPurLine.Validate("Line Amount", L_Amt);
                    tblPurLine.Validate(Quantity, L_Qty);
                    tblPurLine.Validate("Unit Price (LCY)", L_UnitPrice);

                    //if tblPurLine."Line Amount" <> L_Amt then
                    //    Error('Imported line amount: ' + FORMAT(L_Amt) + 'not equal to calculated line acount: ' + Format(tblPurLine."Line Amount"));

                    if L_AirwayBillNo.Trim() <> '' then begin
                        tblPurCommLine.Reset();
                        tblPurCommLine.Init();
                        tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                        tblPurCommLine.Validate("No.", tblPurHdr."No.");
                        tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                        tblPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                        tblPurCommLine.Validate("Date", IssDate);
                        tblPurCommLine.Validate("Comment", 'Airway Bill No: ' + CopyStr(L_AirwayBillNo, 1, 80 - StrLen('Airway Bill No: ')));
                        tblPurCommLine.Insert();
                    end;

                    if L_ShipmentDate <> 0D then begin
                        tblPurCommLine.Reset();
                        tblPurCommLine.Init();
                        tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                        tblPurCommLine.Validate("No.", tblPurHdr."No.");
                        tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                        tblPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                        tblPurCommLine.Validate("Date", IssDate);
                        tblPurCommLine.Validate("Comment", 'Shipment Date: ' + CopyStr(FORMAT(L_ShipmentDate), 1, 80 - StrLen('Shipment Date: ')));
                        tblPurCommLine.Insert();
                    end;

                    if L_Orign.Trim() <> '' then begin
                        tblPurCommLine.Reset();
                        tblPurCommLine.Init();
                        tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                        tblPurCommLine.Validate("No.", tblPurHdr."No.");
                        tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                        tblPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                        tblPurCommLine.Validate("Date", IssDate);
                        tblPurCommLine.Validate("Comment", 'Origin: ' + CopyStr(FORMAT(L_Orign), 1, 80 - StrLen('Origin: ')));
                        tblPurCommLine.Insert();
                    end;


                    if L_Dest.Trim() <> '' then begin
                        tblPurCommLine.Reset();
                        tblPurCommLine.Init();
                        tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                        tblPurCommLine.Validate("No.", tblPurHdr."No.");
                        tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                        tblPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                        tblPurCommLine.Validate("Date", IssDate);
                        tblPurCommLine.Validate("Comment", 'Destination: ' + CopyStr(FORMAT(L_Dest), 1, 80 - StrLen('Destination: ')));
                        tblPurCommLine.Insert();
                    end;

                    if L_ChargeTot <> 0 then begin
                        tblPurCommLine.Reset();
                        tblPurCommLine.Init();
                        tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                        tblPurCommLine.Validate("No.", tblPurHdr."No.");
                        tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                        tblPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                        tblPurCommLine.Validate("Date", IssDate);
                        tblPurCommLine.Validate("Comment", 'Charge Total: ' + CopyStr(FORMAT(L_ChargeTot), 1, 80 - StrLen('Charge Total: ')));
                        tblPurCommLine.Insert();
                    end;
                end;
            }
            */

        }
    }
    trigger OnPreXmlPort()
    begin
        //Message('Start of AdmExp');
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
        VenRefNo: code[35];
        IssDate: Date;
        Subj: Text[80];
        TotAmt: Decimal;
        CurCode: Code[10];
        AccNo: Text[80];
        Due: Date;
        ServAddr: text[80];
        NoOfShip: text[80];
        L_LineNO: Integer;
        L_PostDate: Date;
        L_SFNo: Text[100];
        L_Amt: Decimal;
        L_Desc: Text[100];
        L_Qty: Decimal;
        L_UnitPrice: Decimal;
        L_AirwayBillNo: Text[80];
        L_ShipmentDate: Date;
        L_Orign: Text[80];
        L_Dest: Text[80];
        L_ChargeTot: Decimal;

        booNotFirstLine: Boolean;


    procedure GetlastCommentLineNo() PurCommLineNo: integer
    begin
        tblPurCommLine2.Reset();
        tblPurCommLine2.SetRange("Document Type", tblPurHdr."Document Type"::Invoice);
        tblPurCommLine2.SetRange("No.", tblPurHdr."No.");
        if tblPurCommLine2.findset then
            PurCommLineNo := tblPurCommLine2.GETRANGEMAX("Line No.");
    end;
}