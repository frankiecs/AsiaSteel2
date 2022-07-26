xmlport 50105 FreightImport
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

                textelement(VendorName) { MinOccurs = Zero; }
                textelement(VendorRefNo) { MinOccurs = Zero; }
                textelement(IssueDate) { MinOccurs = Zero; }
                textelement(Subject) { MinOccurs = Zero; }
                textelement(TotalAmount) { MinOccurs = Zero; }
                textelement(Currency) { MinOccurs = Zero; }
                textelement(Remark) { MinOccurs = Zero; }
                textelement(DueDate) { MinOccurs = Zero; }
                textelement(Vessel) { MinOccurs = Zero; }
                textelement(IMO_No) { MinOccurs = Zero; }



                trigger OnBeforeInsertRecord()
                begin

                    IF firstline then begin
                        firstline := false;
                        currxmlport.skip;
                    end;

                    IntHeader += 1;

                    EVALUATE(VenName, VendorName);
                    EVALUATE(VenRefNo, VendorRefNo);
                    EVALUATE(IssDate, IssueDate);
                    EVALUATE(Subj, Subject);
                    EVALUATE(TotAmt, TotalAmount);
                    EVALUATE(CurCode, Currency);
                    EVALUATE(Rmk, Remark);
                    EVALUATE(Due, DueDate);
                    Evaluate(Ves, Vessel);
                    Evaluate(Imo, IMO_No);


                    Clear(tblVendor);
                    tblVendor.SetRange(Name, VenName);
                    iF not tblVendor.FindFirst then
                        Error('Vendor: ' + VenName + ' not found in system.');

                    L_Qty := 1;

                    if booNotFirstLine = false then begin

                        //Message('header');

                        Clear(tblPurHdr);
                        tblPurHdr.Init();
                        tblPurHdr."Document Type" := tblPurHdr."Document Type"::Invoice;

                        //if PurchSetup.GET then;
                        //DocNo := NoSeriesMgt.tryGetNextNo(PurchSetup."Invoice Nos.", IssDate);
                        Message('DocNo: ' + format(DocNo));
                        tblPurHdr."No." := DocNo;
                        tblpurhdr."Posting Date" := Today;
                        tblPurHdr.Insert(true);


                        tblPurHdr.Validate("Buy-from Vendor No.", tblVendor."No.");
                        tblPurHdr.Validate("Vendor Invoice No.", VenRefNo);
                        tblPurHdr.Validate("Document Date", IssDate);
                        tblPurHdr.Validate("Currency Code", Currency);
                        tblpurhdr.Validate("Due Date", Due);
                        tblpurhdr.Modify(true);

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

                        if Rmk.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'REMARK: ' + CopyStr(Rmk, 1, 80 - StrLen('REMARK: ')));
                            tblPurCommLine.Insert();
                        end;

                        if Ves.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'VESSEL: ' + CopyStr(Ves, 1, 80 - StrLen('VESSEL: ')));
                            tblPurCommLine.Insert();
                        end;

                        if Imo.Trim() <> '' then begin
                            tblPurCommLine.Reset();
                            tblPurCommLine.Init();
                            tblPurCommLine.Validate("Document Type", tblPurHdr."Document Type"::Invoice);
                            tblPurCommLine.Validate("No.", tblPurHdr."No.");
                            tblPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                            tblPurCommLine.Validate("Document Line No.", 0);
                            tblPurCommLine.Validate("Date", IssDate);
                            tblPurCommLine.Validate("Comment", 'IMO NO: ' + CopyStr(Imo, 1, 80 - StrLen('IMO NO: ')));
                            tblPurCommLine.Insert();
                        end;

                        //booNotFirstLine := true;
                        L_LineNO := 1;

                        tblPurLine.Reset();
                        tblPurLine.Init();
                        tblPurLine."Document Type" := tblPurLine."Document Type"::Invoice;
                        tblPurLine."Document No." := DocNo;
                        tblPurLine."Line No." := L_LineNO * 10000;
                        tblPurLine.Insert(true);

                        tblPurLine.type := tblPurLine.type::"G/L Account";
                        tblpurline.Validate("No.", '8450');

                        if Rmk.Trim() <> '' then begin
                            tblPurLine.Validate(Description, Rmk);
                        end;

                        tblPurLine.Validate(Quantity, L_Qty);

                        tblPurLine.Validate("Direct Unit Cost", TotAmt);
                        tblPurLine.Modify(true);

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
        VenRefNo: code[35];
        IssDate: Date;
        Subj: Text[80];
        TotAmt: Decimal;
        CurCode: Code[10];
        Rmk: Text[80];
        Due: Date;
        Ves: Text[80];
        Imo: Text[80];


        L_Qty: Integer;
        L_LineNO: Integer;
        Firstline: Boolean;
        booNotFirstLine: Boolean;




    procedure GetlastCommentLineNo() PurCommLineNo: integer
    begin
        Clear(tblPurCommLine2);
        tblPurCommLine2.SetRange("Document Type", tblPurHdr."Document Type"::Invoice);
        tblPurCommLine2.SetRange("No.", tblPurHdr."No.");
        tblPurCommLine.SetCurrentKey("Line No.");
        if tblPurCommLine2.FindLast() then
            PurCommLineNo := tblPurCommLine2."Line No."
        else
            PurCommLineNo := 0;
    end;
}