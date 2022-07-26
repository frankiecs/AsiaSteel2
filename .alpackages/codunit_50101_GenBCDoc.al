codeunit 50101 "GenBCDoc"
{
    /***********************************************/
    /***********************************************/
    /*** Admin Expense generate Purchase Invoice ***/
    /***********************************************/
    /***********************************************/
    procedure GenAdmExp(FileID: code[1000])
    var
        intNo: Integer;
        recPurHdr: record "Purchase Header";
        recPurline: Record "Purchase Line";
        PurSetup: Record "Purchases & Payables Setup";
        recPurCommLine: Record "Purch. Comment Line";
        recPreDelete: Record PreDelete;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        recVendor: Record Vendor;
        GLSetup: Record "General Ledger Setup";
        recGLAcc: Record "G/L Account";

        myDate: Date;
        myCost: Decimal;
        myVendName: Text[100];
        recStageTable: Record "Stage Table";
        recStageTable_2: Record "Stage Table";
        intCount: Integer;
        intPurCommLineNo: Integer;
        IntHdr: Integer;
        IntBufferCount: Integer;
        txtVenName: text[80];
        txtVenRefNo: text[80];

        DocNo: code[20];
        VenName: Text[100];
        VenName2: Text[102];
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

        L_SumAmt: Decimal;
        L_LineSumAmt: Decimal;
        L_SumUnitPrice: Decimal;
        booFlag: Boolean;
        VendFlag: Boolean;

    begin

        intCount := 0;
        IntHdr := 0;
        IntBufferCount := 0;

        recPreDelete.Reset();
        If recPreDelete.FindFirst() then;

        recStageTable.Reset();
        recStageTable.SetRange(FileId, FileID);
        recStageTable.SetFilter(F001, '<>%1', '');
        IntBufferCount := recStageTable.Count;

        If recStageTable.FindSet() then begin
            IntBufferCount := recStageTable.Count;
            repeat
                intCount := intCount + 1;

                EVALUATE(VenName, CheckString(recStageTable.F001).Trim());
                EVALUATE(VenRefNo, CheckString(recStageTable.F002).Trim());
                txtVenName := recStageTable.F001.Trim();
                txtVenRefNo := recStageTable.F002.Trim();

                EVALUATE(IssDate, CheckString(recStageTable.F003).Trim());
                EVALUATE(Subj, CheckString(recStageTable.F004).Trim());

                if CheckString(recStageTable.F005) = '' then
                    TotAmt := 0
                else
                    EVALUATE(TotAmt, CheckString(recStageTable.F005).Trim());

                EVALUATE(CurCode, CheckString(recStageTable.F006).Trim().Trim());
                EVALUATE(AccNo, CheckString(recStageTable.F007).Trim().Trim());
                EVALUATE(Due, CheckString(recStageTable.F008).Trim().Trim());
                EVALUATE(ServAddr, CheckString(recStageTable.F009).trim);

                EVALUATE(NoOfShip, CheckString(recStageTable.F010).trim);

                if CheckString(recStageTable.F010) = '' then
                    L_LineNO := 0
                else
                    EVALUATE(L_LineNO, CheckString(recStageTable.F010).Trim());

                EVALUATE(L_PostDate, CheckString(recStageTable.F012).Trim());
                EVALUATE(L_SFNo, CheckString(recStageTable.F013).Trim());

                if CheckString(recStageTable.F014) = '' then
                    L_Amt := 0
                else
                    EVALUATE(L_Amt, CheckString(recStageTable.F014).Trim());

                EVALUATE(L_Desc, CheckString(recStageTable.F015).Trim());
                if L_Desc = '' then EVALUATE(L_Desc, CheckString(recStageTable.F004).Trim());

                if CheckString(recStageTable.F016) = '' then
                    L_Qty := 0
                else
                    EVALUATE(L_Qty, CheckString(recStageTable.F016).Trim());

                if CheckString(recStageTable.F017) = '' then
                    L_UnitPrice := 0
                else
                    EVALUATE(L_UnitPrice, CheckString(recStageTable.F017).Trim());
                EVALUATE(L_AirwayBillNo, CheckString(recStageTable.F018).Trim());
                EVALUATE(L_ShipmentDate, CheckString(recStageTable.F019).Trim());
                EVALUATE(L_Orign, CheckString(recStageTable.F020).Trim());
                EVALUATE(L_Dest, CheckString(recStageTable.F021).Trim());

                //***********************************************
                //Purchase Invoice Header Section (Admin Expense)
                //************************************************

                //Generate Header one time
                If inthdr = 0 then begin

                    VendFlag := false;
                    VenName2 := '';
                    VenName2 := '''' + VenName.Trim() + '''';

                    //Error('***' + VenName2);

                    Clear(recVendor);
                    recVendor.SetFilter(Name, VenName2);
                    iF recVendor.FindFirst then
                        VendFlag := true
                    else begin
                        Clear(recVendor);
                        recVendor.SetFilter("Name 2", VenName2);
                        iF recVendor.FindFirst then VendFlag := true;
                    end;

                    if VendFlag = false then Error('Vendor: ' + VenName + ' not found in system.');

                    recPurHdr.Reset();
                    recPurHdr.Setrange("Document Type", recPurHdr."Document Type"::Invoice);
                    recPurHdr.SetFilter("Buy-from Vendor No.", recVendor."No.");
                    recPurHdr.SetFilter("Vendor Invoice No.", VenRefNo);
                    //if recPurHdr.FindFirst() then
                    //    Error('Vendor Invoice: ' + Format(VenRefNo) + ' already exist.');

                    recPurHdr.reset;
                    recPurHdr.Init();
                    recPurHdr."Document Type" := recPurHdr."Document Type"::Invoice;

                    if PurSetup.GET then;
                    recPurHdr.Validate("No.", DocNo);
                    recPurHdr.Validate("Posting Date", Today);
                    recPurHdr.Validate("Buy-from Vendor No.", recVendor."No.");
                    recPurHdr.Insert(true);

                    recPurHdr.Validate("Buy-from Vendor No.", recVendor."No.");
                    recPurHdr.Validate("Vendor Invoice No.", VenRefNo);
                    recPurHdr.Validate("Document Date", IssDate);
                    if GLSetup.get then;
                    If (CurCode <> '') and (CurCode <> GLSetup."LCY Code") then recPurHdr.Validate("Currency Code", CurCode);
                    recpurhdr.Validate("Due Date", Due);
                    recpurhdr.Modify(true);

                    if Subj.Trim() <> '' then begin
                        recPurCommLine.Reset();
                        recPurCommLine.Init();
                        recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                        recPurCommLine.Validate("No.", recPurHdr."No.");
                        recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                        recPurCommLine.Validate("Document Line No.", 0);
                        recPurCommLine.Validate("Date", IssDate);
                        recPurCommLine.Validate("Comment", 'SUBJECT: ' + CopyStr(Subj, 1, 80 - StrLen('SUBJECT: ')));
                        recPurCommLine.Insert();
                    end;

                    if ServAddr.Trim() <> '' then begin
                        recPurCommLine.Reset();
                        recPurCommLine.Init();
                        recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                        recPurCommLine.Validate("No.", recPurHdr."No.");
                        recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                        recPurCommLine.Validate("Document Line No.", 0);
                        recPurCommLine.Validate("Date", IssDate);
                        recPurCommLine.Validate("Comment", 'PROPERTY ADDRESS: ' + CopyStr(ServAddr, 1, 80 - StrLen('PROPERTY ADDRESS: ')));
                        recPurCommLine.Insert();
                    end;

                    if NoOfShip.Trim() <> '' then begin
                        recPurCommLine.Reset();
                        recPurCommLine.Init();
                        recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                        recPurCommLine.Validate("No.", recPurHdr."No.");
                        recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                        recPurCommLine.Validate("Document Line No.", 0);
                        recPurCommLine.Validate("Date", IssDate);
                        recPurCommLine.Validate("Comment", 'NO. OF SHIPMENT: ' + CopyStr(FORMAT(NoOfShip), 1, 80 - StrLen('NO. OF SHIPMENT: ')));
                        recPurCommLine.Insert();
                    end;

                    inthdr := IntHdr + 1;
                end;

                //*********************************************
                //Purchase Invoice Line Section (Admin Expense)
                //*********************************************

                recPurLine.Reset();
                recPurLine.Init();
                recPurLine."Document Type" := recPurLine."Document Type"::Invoice;
                recPurLine."Document No." := recPurHdr."No.";
                recPurLine."Line No." := intCount * 10000;
                recPurLine.Insert(true);

                recPurLine.type := recPurLine.type::"G/L Account";
                //tblPurline."No." := '8450';

                if recVendor."Scanning GL Acc" = '' then Error('Vendor ' + recVendor.Name + ' missing value in Scanning G/L Accoount.');

                recGLAcc.Reset();
                recGLAcc.SetRange("No.", recVendor."Scanning GL Acc");
                If recGLAcc.FindFirst() then begin
                    if recGLAcc."Gen. Posting Type" = recGLAcc."Gen. Posting Type"::" " then Error('G/L Account ' + Format(recVendor."Scanning GL Acc") + ' missing value in Gen. Posting Type.');
                    if recGLAcc."Gen. Prod. Posting Group" = '' then Error('G/L Account' + Format(recVendor."Scanning GL Acc") + ' missing value in Gen. Prod. Posting Group..');
                    recpurline.Validate("No.", recVendor."Scanning GL Acc")
                end else
                    Error('Vendor ' + recVendor.Name + ' with Scanning G/L Account no. ' + recVendor."Scanning GL Acc" + ' not found in Chart of Account.');



                IF L_SFNo <> '' then
                    recPurLine.validate(Description, FORMAT(L_PostDate) + ' - ' + FORMAT(L_SFNo))
                else
                    recPurLine.Validate(Description, L_Desc);

                if (IntBufferCount = 1) then begin
                    if TotAmt = 0 then
                        Error('Total Amount = 0')
                    else
                        if (L_Amt <> 0) and (L_Amt <> TotAmt) then
                            Error('Line Amount not equal to Total Amount')
                        else
                            if (L_Amt <> 0) and (L_Qty <> 0) and (L_UnitPrice <> 0) then
                                Error('Line Amount not equal to Qty X Unit Price')
                            else
                                if (L_Amt <> 0) and ((L_Qty = 0) or (L_Qty = 1)) then begin
                                    L_Qty := 1;
                                    L_UnitPrice := L_Amt;
                                end else
                                    L_Qty := 1;
                    L_UnitPrice := TotAmt
                end;

                if (IntBufferCount > 1) then begin
                    /*** Calc sum of line amount ***/
                    L_LineSumAmt := 0;
                    recStageTable_2.reset;
                    recStageTable_2.SetRange(FileId, FileID);
                    //recHeaderBuffer_2.SetRange(F001, txtVenName);
                    //recHeaderBuffer_2.SetRange(F002, txtVenRefNo);
                    If recStageTable_2.FindSet() then begin
                        repeat
                            if CheckString(recStageTable_2.F014) = '' then
                                L_SumAmt := 0
                            else
                                EVALUATE(L_SumAmt, CheckString(recStageTable_2.F014).Trim());
                            L_LineSumAmt := L_LineSumAmt + L_SumAmt;
                        until recStageTable_2.next <= 0;
                    end;
                    if TotAmt <> L_LineSumAmt then begin
                        Error('Total Amount: ' + Format(TotAmt) + ' not equal to sum of line amount: ' + Format(L_LineSumAmt));
                    end;


                    /*** Check all qty and unit price ready***/
                    /*
                    booFlag := false;
                    recHeaderBuffer_2.reset;
                    recHeaderBuffer_2.SetRange(F001, txtVenName);
                    recHeaderBuffer_2.SetRange(F002, txtVenRefNo);
                    If recHeaderBuffer_2.FindSet() then begin
                        repeat
                            if CheckString(recHeaderBuffer_2.F016) = '' then booFlag := true;
                            if CheckString(recHeaderBuffer_2.F017) = '' then booFlag := true;
                        until recHeaderBuffer_2.next <= 0;
                    end;
                    */
                end;

                if L_Qty = 0 then L_Qty := 1;
                if IntBufferCount = 1 then
                    L_UnitPrice := TotAmt / L_Qty
                else
                    L_UnitPrice := L_Amt / L_Qty;

                //recPurLine.Validate("Line Amount", L_Amt);
                //L_Qty := 1;

                recPurLine.Validate(Quantity, L_Qty);
                recPurLine.Validate("Direct Unit Cost", L_UnitPrice);
                recPurLine.Modify(true);

                //if recPurLine."Line Amount" <> L_Amt then
                //    Error('Imported line amount: ' + FORMAT(L_Amt) + 'not equal to calculated line acount: ' + Format(recPurLine."Line Amount"));

                if L_AirwayBillNo.Trim() <> '' then begin
                    recPurCommLine.Reset();
                    recPurCommLine.Init();
                    recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                    recPurCommLine.Validate("No.", recPurHdr."No.");
                    recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                    recPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                    recPurCommLine.Validate("Date", IssDate);
                    recPurCommLine.Validate("Comment", 'Airway Bill No: ' + CopyStr(L_AirwayBillNo, 1, 80 - StrLen('Airway Bill No: ')));
                    recPurCommLine.Insert();
                end;

                if L_ShipmentDate <> 0D then begin
                    recPurCommLine.Reset();
                    recPurCommLine.Init();
                    recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                    recPurCommLine.Validate("No.", recPurHdr."No.");
                    recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                    recPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                    recPurCommLine.Validate("Date", IssDate);
                    recPurCommLine.Validate("Comment", 'Shipment Date: ' + CopyStr(FORMAT(L_ShipmentDate), 1, 80 - StrLen('Shipment Date: ')));
                    recPurCommLine.Insert();
                end;

                if L_Orign.Trim() <> '' then begin
                    recPurCommLine.Reset();
                    recPurCommLine.Init();
                    recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                    recPurCommLine.Validate("No.", recPurHdr."No.");
                    recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                    recPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                    recPurCommLine.Validate("Date", IssDate);
                    recPurCommLine.Validate("Comment", 'Origin: ' + CopyStr(FORMAT(L_Orign), 1, 80 - StrLen('Origin: ')));
                    recPurCommLine.Insert();
                end;


                if L_Dest.Trim() <> '' then begin
                    recPurCommLine.Reset();
                    recPurCommLine.Init();
                    recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                    recPurCommLine.Validate("No.", recPurHdr."No.");
                    recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                    recPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                    recPurCommLine.Validate("Date", IssDate);
                    recPurCommLine.Validate("Comment", 'Destination: ' + CopyStr(FORMAT(L_Dest), 1, 80 - StrLen('Destination: ')));
                    recPurCommLine.Insert();
                end;

                if L_ChargeTot <> 0 then begin
                    recPurCommLine.Reset();
                    recPurCommLine.Init();
                    recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                    recPurCommLine.Validate("No.", recPurHdr."No.");
                    recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                    recPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
                    recPurCommLine.Validate("Date", IssDate);
                    recPurCommLine.Validate("Comment", 'Charge Total: ' + CopyStr(FORMAT(L_ChargeTot), 1, 80 - StrLen('Charge Total: ')));
                    recPurCommLine.Insert();
                end;

            until recStageTable.NEXT <= 0;
        end;
    end;


    /**************************/
    /**************************/
    /*** Bank Credit Advice ***/
    /**************************/
    /**************************/
    procedure GenBCRADV(FileID: code[1000])
    var
        GLSetup: Record "General Ledger Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        recStageTable: Record "Stage Table";
        recStageTable_2: Record "Stage Table";
        recGJL: Record "Gen. Journal Line";
        recGJL2: Record "Gen. Journal Line";
        recBankAcc: Record "Bank Account";
        recCustomer: Record Customer;

        intCount: Integer;
        IntHdr: Integer;
        IntBufferCount: Integer;

        Bankname: Text[100];    //F001
        BankRef: Text[80];      //F002  
        issueDate: Date;        //F003
        DocType: Text[80];     //F004
        Currency: Code[3];      //F005
        CreditAmt: Decimal;    //F006
        YourRef: Text[80];      //F007
        Applicant: Text[80];    //F008
        BillAmt: Decimal;       //F009
        LCNo: text[80];         //F012
        DraweeAppl: Text[80];   //F013
        BankAccNo: Text[30];    //F019
        ByOrderOf: Text[80];    //F020
        RemittAmt: Decimal;     //F021


        ReimbFee: Decimal;      //F010
        BankCharge: Decimal;    //F011
        Commission: Decimal;    //F014
        CommInLieu: Decimal;    //F015
        Postage: Decimal;       //F016
        CableCharge: Decimal;   //F017
        ServiceCharge: Decimal; //F018
        TotalCharge: Decimal;   //F022
        CreditAccNo: Code[20];  //F023
        Chile: Decimal;         //F024

        SumOfBankCharge: Decimal;
        Docno: code[20];
        LastLineNo: Integer;
        tempDesc: text[300];
        tempComment: text[2000];
        BankNo: code[20];

    begin

        intCount := 0;
        IntHdr := 0;
        IntBufferCount := 0;

        recStageTable.Reset();
        recStageTable.SetRange(FileId, FileID);
        recStageTable.SetFilter(F001, '<>%1', '');

        If recStageTable.FindSet() then begin
            IntBufferCount := recStageTable.Count;

            // For Cash Receipt Journal
            EVALUATE(Bankname, CheckString(recStageTable.F001).Trim());
            EVALUATE(BankRef, CheckString(recStageTable.F002).Trim());
            EVALUATE(issueDate, CheckString(recStageTable.F003).Trim());
            EVALUATE(DocType, CheckString(recStageTable.F004).Trim());
            EVALUATE(Currency, CheckString(recStageTable.F005).Trim());

            if (CheckString(recStageTable.F006).Trim() = '') OR (CheckString(recStageTable.F006).Trim() = '0') then
                CreditAmt := 0
            else
                EVALUATE(CreditAmt, CheckString(recStageTable.F006).Trim());

            EVALUATE(YourRef, CheckString(recStageTable.F007).Trim());
            EVALUATE(Applicant, CheckString(recStageTable.F008).Trim());

            if (CheckString(recStageTable.F009).Trim() = '') OR (CheckString(recStageTable.F009).Trim() = '0') then
                BillAmt := 0
            else
                EVALUATE(BillAmt, CheckString(recStageTable.F009).Trim());

            EVALUATE(LCNo, CheckString(recStageTable.F010).Trim());
            EVALUATE(DraweeAppl, CheckString(recStageTable.F011).Trim());
            EVALUATE(BankAccNo, CheckString(recStageTable.F019).Trim());
            EVALUATE(ByOrderOf, CheckString(recStageTable.F020).Trim());

            if (CheckString(recStageTable.F021).Trim() = '') OR (CheckString(recStageTable.F021).Trim() = '0') then
                RemittAmt := 0
            else
                EVALUATE(RemittAmt, CheckString(recStageTable.F021).Trim());


            // For General Jouranl (Bank Charge)

            if (CheckString(recStageTable.F010).Trim() = '') OR (CheckString(recStageTable.F010).Trim() = '0') then
                ReimbFee := 0
            else
                EVALUATE(ReimbFee, CheckString(recStageTable.F010).Trim());

            if (CheckString(recStageTable.F011).Trim() = '') OR (CheckString(recStageTable.F011).Trim() = '0') then
                BankCharge := 0
            else
                EVALUATE(BankCharge, CheckString(recStageTable.F011).Trim());

            if (CheckString(recStageTable.F014).Trim() = '') OR (CheckString(recStageTable.F014).Trim() = '0') then
                Commission := 0
            else
                EVALUATE(Commission, CheckString(recStageTable.F014).Trim());

            if (CheckString(recStageTable.F015).Trim() = '') OR (CheckString(recStageTable.F015).Trim() = '0') then
                CommInLieu := 0
            else
                EVALUATE(CommInLieu, CheckString(recStageTable.F015).Trim());

            if (CheckString(recStageTable.F016).Trim() = '') OR (CheckString(recStageTable.F016).Trim() = '0') then
                Postage := 0
            else
                EVALUATE(Postage, CheckString(recStageTable.F016).Trim());

            if (CheckString(recStageTable.F017).Trim() = '') OR (CheckString(recStageTable.F017).Trim() = '0') then
                CableCharge := 0
            else
                EVALUATE(CableCharge, CheckString(recStageTable.F017).Trim());

            if (CheckString(recStageTable.F018).Trim() = '') OR (CheckString(recStageTable.F018).Trim() = '0') then
                ServiceCharge := 0
            else
                EVALUATE(ServiceCharge, CheckString(recStageTable.F018).Trim());

            if (CheckString(recStageTable.F022).Trim() = '') OR (CheckString(recStageTable.F022).Trim() = '0') then
                TotalCharge := 0
            else
                EVALUATE(TotalCharge, CheckString(recStageTable.F022).Trim());

            EVALUATE(CreditAccNo, CheckString(recStageTable.F023).Trim());

            if (CheckString(recStageTable.F024).Trim() = '') OR (CheckString(recStageTable.F024).Trim() = '0') then
                Chile := 0
            else
                EVALUATE(Chile, CheckString(recStageTable.F024).Trim());


            If (BillAmt = 0) and (RemittAmt = 0) then Error('Bill Amount and Remitted Amount cannot both in zero or no value.');

            If (BillAmt <> 0) and (RemittAmt <> 0) then Error('Bill Amount and Remitted Amount cannot both have value.');

            if CreditAmt = 0 then Error('Credit Amount cannot be zero or no value');


            /**********************************************************/
            /*** Generate Cash Receipt Journal (Bank Credit Advice) ***/
            /**********************************************************/

            //*** Cash Receipt Journal Line 1 ***
            recGJL.Reset();
            recGJL.Init();
            recGJL."Journal Template Name" := 'CASH RECE';
            recGJL."Journal Batch Name" := 'SCANNING';

            DocNo := NoSeriesMgt.GetNextNo('GJNL-RCPT', Today, true);
            recGJL.Validate("Document No.", DocNo);
            recGJL.Validate("Posting Date", Today);

            recGJL2.Reset();
            recGJL2.SetRange("Journal Template Name", 'CASH RECE');
            recGJL2.SetRange("Journal Batch Name", 'SCANNING');
            if recGJL2.FindLast() then
                LastLineNo := recGJL2."Line No." + 10000
            else
                LastLineNo := 10000;

            recGJL.Validate("Line No.", LastLineNo);
            recGJL.Validate("Account Type", recGJL."Account Type"::Customer);

            GLSetup.Reset();
            if GLSetup.get then;
            if Currency <> GLSetup."LCY Code" then
                recGJL.Validate("Currency Code", Currency);

            recGJL.Validate(Amount, -CreditAmt);
            recGJL.Insert();

            //*** Cash Receipt Journal Line 2 ***
            recGJL.Reset();
            recGJL.Init();
            recGJL."Journal Template Name" := 'CASH RECE';
            recGJL."Journal Batch Name" := 'SCANNING';

            recGJL.Validate("Document No.", DocNo);
            recGJL.Validate("Posting Date", Today);

            recGJL2.Reset();
            recGJL2.SetRange("Journal Template Name", 'CASH RECE');
            recGJL2.SetRange("Journal Batch Name", 'SCANNING');
            if recGJL2.FindLast() then
                LastLineNo := recGJL2."Line No." + 10000
            else
                LastLineNo := 10000;

            recGJL.Validate("Line No.", LastLineNo);
            recGJL.Validate("Account Type", recGJL."Account Type"::"Bank Account");


            if BankAccNo = '' then Error('Bank Account No. cannot be empty.');
            //recGJL.Validate("Account No.", '808-508774-274');
            //Code to get correct Bank Account    

            recBankAcc.Reset();
            recBankAcc.SetRange("Bank Account No.", BankAccNo.Trim());
            if recBankAcc.FindFirst() then
                BankNo := recBankAcc."No."
            else
                Error('Bank Account No.: ' + Format(BankAccNo.Trim()) + ' not found in bank account.');

            recGJL.Validate("Account No.", BankNo);

            if YourRef.Trim() <> '' then
                tempDesc := recGJL.Description + ' | YourRef: ' + YourRef;
            tempDesc := CopyStr(tempDesc, 1, 100);
            recGJL.Description := tempDesc;

            GLSetup.Reset();
            if GLSetup.get then;
            if Currency <> GLSetup."LCY Code" then
                recGJL.Validate("Currency Code", Currency);
            recGJL.Validate(Amount, CreditAmt);

            //Write to comment fields
            tempComment := '';
            if YourRef.Trim() <> '' then tempComment := tempComment + ' Your Ref: ' + YourRef.Trim() + ' | ';
            if Bankname.Trim() <> '' then tempComment := tempComment + ' Bank Name: ' + Bankname.Trim() + ' | ';
            if BankRef.Trim() <> '' then tempComment := tempComment + ' Bank Ref: ' + BankRef.Trim() + ' | ';
            tempComment := tempComment + ' Credit Amt: ' + Format(CreditAmt) + ' | ';
            tempComment := tempComment + ' Remitt Amt: ' + Format(RemittAmt) + ' | ';
            tempComment := tempComment + ' Bill Amt: ' + Format(BillAmt) + ' | ';
            if issueDate <> 0D then tempComment := tempComment + ' Issue Date: ' + format(issueDate).Trim() + ' | ';
            if DocType.Trim() <> '' then tempComment := tempComment + ' Doc. Type: ' + DocType.Trim() + ' | ';
            if Applicant.Trim() <> '' then tempComment := tempComment + ' Applicant: ' + Applicant.Trim() + ' | ';
            if LCNo.Trim() <> '' then tempComment := tempComment + ' LC No: ' + LCNo.Trim() + ' | ';
            if DraweeAppl.Trim() <> '' then tempComment := tempComment + ' Drawee Appl: ' + DraweeAppl.Trim() + ' | ';
            if ByOrderOf.Trim() <> '' then tempComment := tempComment + ' By Order Of: ' + ByOrderOf.Trim() + ' | ';

            If StrLen(tempComment) > 2 then tempComment := Copystr(tempComment, 1, StrLen(tempComment) - 2);

            if Strlen(tempcomment.Trim()) <= 250 then
                recGJL.Validate(Comment, tempComment)
            else begin
                recGJL.Validate(Comment, Copystr(tempComment, 1, 250));
                recGJL.Validate("Contact Graph Id", Copystr(tempComment, 251, 500));
            end;

            recGJL.Insert(true);


            SumOfBankCharge := 0;
            //SumOfBankCharge := ReimbFee + BankCharge + Commission + CommInLieu + Postage + CableCharge + ServiceCharge + TotalCharge + Chile;

            if BillAmt <> 0 then SumOfBankCharge := BillAmt - CreditAmt;
            if RemittAmt <> 0 then SumOfBankCharge := RemittAmt - CreditAmt;

            if SumOfBankCharge > 0 then begin

                //*** General Journal Line 1 (Bank Charge) ***  

                recGJL.Reset();
                recGJL.Init();
                recGJL."Journal Template Name" := 'GENERAL';
                recGJL."Journal Batch Name" := 'SCANNING';

                //??? Need rewrite to get from General Journal Batch
                DocNo := NoSeriesMgt.GetNextNo('GJNL-GEN', Today, true);
                recGJL.Validate("Document No.", DocNo);
                recGJL.Validate("Posting Date", Today);

                recGJL2.Reset();
                recGJL2.SetRange("Journal Template Name", 'GENERAL');
                recGJL2.SetRange("Journal Batch Name", 'SCANNING');
                if recGJL2.FindLast() then
                    LastLineNo := recGJL2."Line No." + 10000
                else
                    LastLineNo := 10000;

                recGJL.Validate("Line No.", LastLineNo);
                recGJL.Validate("Account Type", recGJL."Account Type"::"Bank Account");

                if (CreditAccNo = '') and (BankAccNo.Trim() = '') then Error('Missing value in Credit Account No. and Bank Account No.');

                if CreditAccNo <> '' then begin
                    recBankAcc.Reset();
                    recBankAcc.SetRange("Bank Account No.", CreditAccNo);
                    if recBankAcc.FindFirst() then
                        BankNo := recBankAcc."No."
                    else
                        Error('Bank Account No.: ' + Format(CreditAccNo) + ' not found in bank account.');
                    recGJL.Validate("Account No.", BankNo);
                end else begin
                    recBankAcc.Reset();
                    recBankAcc.SetRange("Bank Account No.", BankAccNo.Trim());
                    if recBankAcc.FindFirst() then
                        BankNo := recBankAcc."No."
                    else
                        Error('Bank Account No.: ' + Format(BankAccNo) + ' not found in bank account.');
                    recGJL.Validate("Account No.", BankNo);
                end;

                GLSetup.Reset();
                if GLSetup.get then;
                if Currency <> GLSetup."LCY Code" then
                    recGJL.Validate("Currency Code", Currency);

                recGJL.Validate(Amount, -SumOfBankCharge);
                recGJL.Insert(true);

                tempComment := '';
                if ReimbFee <> 0 then tempComment := tempComment + ' Reimb Fee: ' + Format(ReimbFee, 0) + ' | ';
                if BankCharge <> 0 then tempComment := tempComment + ' Bank Charge: ' + Format(BankCharge, 0) + ' | ';
                if Commission <> 0 then tempComment := tempComment + ' Commission: ' + Format(Commission, 0) + ' | ';
                if CommInLieu <> 0 then tempComment := tempComment + ' Comm In Lieu: ' + Format(CommInLieu, 0) + ' | ';
                if Postage <> 0 then tempComment := tempComment + ' Postage: ' + Format(Postage, 0) + ' | ';
                if CableCharge <> 0 then tempComment := tempComment + ' Cable Charge: ' + Format(CableCharge, 0) + ' | ';
                if ServiceCharge <> 0 then tempComment := tempComment + ' Service Charge: ' + Format(ServiceCharge, 0) + ' | ';
                if TotalCharge <> 0 then tempComment := tempComment + ' Total Charge: ' + Format(TotalCharge, 0) + ' | ';
                if Chile <> 0 then tempComment := tempComment + ' Chile: ' + Format(Chile, 0) + ' | ';

                If StrLen(tempComment) > 2 then tempComment := Copystr(tempComment, 1, StrLen(tempComment) - 2);

                if Strlen(tempcomment.Trim()) <= 250 then
                    recGJL.Validate(Comment, tempComment)
                else
                    recGJL.Validate(Comment, Copystr(tempComment, 1, 250));

                recGJL.Modify(true);

                //*** General Journal Line 2 (Bank Charge) ***  

                recGJL.Reset();
                recGJL.Init();
                recGJL."Journal Template Name" := 'GENERAL';
                recGJL."Journal Batch Name" := 'SCANNING';

                recGJL.Validate("Document No.", DocNo);
                recGJL.Validate("Posting Date", Today);

                recGJL2.Reset();
                recGJL2.SetRange("Journal Template Name", 'GENERAL');
                recGJL2.SetRange("Journal Batch Name", 'SCANNING');
                if recGJL2.FindLast() then
                    LastLineNo := recGJL2."Line No." + 10000
                else
                    LastLineNo := 10000;

                recGJL.Validate("Line No.", LastLineNo);
                recGJL.Validate("Account Type", recGJL."Account Type"::"G/L Account");

                //??? Need allow to set by user in future
                recGJL.Validate("Account No.", '80105');  //Other Operating Expene                     

                GLSetup.Reset();
                if GLSetup.get then;
                if Currency <> GLSetup."LCY Code" then
                    recGJL.Validate("Currency Code", Currency);

                recGJL.Validate(Amount, SumOfBankCharge);

                if Strlen(tempcomment.Trim()) <= 250 then
                    recGJL.Validate(Comment, tempComment)
                else
                    recGJL.Validate(Comment, Copystr(tempComment, 1, 250));

                recGJL.Insert(true);

            end;
        end;

    end;





    /*************************/
    /*************************/
    /*** Bank Debit Advice ***/
    /*************************/
    /*************************/

    procedure GenBDRADV(FileID: code[1000])
    var
        GLSetup: Record "General Ledger Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        recStageTable: Record "Stage Table";
        recStageTable_2: Record "Stage Table";
        recGJL: Record "Gen. Journal Line";
        recGJL2: Record "Gen. Journal Line";
        recBankAcc: Record "Bank Account";
        recCustomer: Record Customer;

        intCount: Integer;
        IntHdr: Integer;
        IntBufferCount: Integer;

        Docno: code[20];
        LastLineNo: Integer;
        tempDesc: text[300];
        tempComment: text[2000];

        BankName: Text[100];
        BankRef: Text[80];
        Issdate: Date;
        DocType: Text[80];
        Currency: Code[3];
        DebitAmt: Decimal;
        Loantype: Text[80];
        InvNo: Code[35];        //Ext. Doc. No.
        AmtOfLoan: Decimal;
        TermOfLoan: Text[80];
        MaturityDate: Date;
        InterestRate: Text[80];
        AccountNo: Text[30];     //Bank Account No.
        InvFinComm: Decimal;
        BankCharge: Decimal;
        YourRef: Text[80];
        LCNo: Text[80];
        ApplDrawee: Text[80];
        Commission: Decimal;
        CheckingFee: Decimal;
        Postage: Decimal;
        TelexCharge: Decimal;
        ServiceCharge: Decimal;
        Beneficiary: Text[80];
        CableCharges: Decimal;
        LCIssAmendCom: Decimal;
        DocName: Text[80];
        RemittAmt: Decimal;
        InterestAmt: Decimal;
        AmtRepaid: Decimal;
        BillAmt: Decimal;
        InterestDue: Decimal;
        BankNo: Code[20];

    begin

        intCount := 0;
        IntHdr := 0;
        IntBufferCount := 0;

        recStageTable.Reset();
        recStageTable.SetRange(FileId, FileID);
        recStageTable.SetFilter(F001, '<>%1', '');

        If recStageTable.FindSet() then begin
            IntBufferCount := recStageTable.Count;

            // For Cash Receipt Journal
            EVALUATE(Bankname, CheckString(recStageTable.F001).Trim());
            EVALUATE(BankRef, CheckString(recStageTable.F002).Trim());
            EVALUATE(Issdate, CheckString(recStageTable.F003).Trim());
            EVALUATE(DocType, CheckString(recStageTable.F004).Trim());
            EVALUATE(Currency, CheckString(recStageTable.F005).Trim());

            if (CheckString(recStageTable.F006).Trim() = '') OR (CheckString(recStageTable.F006).Trim() = '0') then
                DebitAmt := 0
            else
                EVALUATE(DebitAmt, CheckString(recStageTable.F006).Trim());

            EVALUATE(Loantype, CheckString(recStageTable.F007).Trim());
            EVALUATE(InvNo, CheckString(recStageTable.F008).Trim());

            if (CheckString(recStageTable.F009).Trim() = '') OR (CheckString(recStageTable.F009).Trim() = '0') then
                AmtOfLoan := 0
            else
                EVALUATE(AmtOfLoan, CheckString(recStageTable.F009).Trim());

            EVALUATE(TermOfLoan, CheckString(recStageTable.F010).Trim());
            EVALUATE(MaturityDate, CheckString(recStageTable.F011).Trim());
            EVALUATE(InterestRate, CheckString(recStageTable.F012).Trim());
            EVALUATE(AccountNo, CheckString(recStageTable.F013).Trim());

            if (CheckString(recStageTable.F014).Trim() = '') OR (CheckString(recStageTable.F014).Trim() = '0') then
                InvFinComm := 0
            else
                EVALUATE(InvFinComm, CheckString(recStageTable.F014).Trim());

            if (CheckString(recStageTable.F015).Trim() = '') OR (CheckString(recStageTable.F015).Trim() = '0') then
                BankCharge := 0
            else
                EVALUATE(BankCharge, CheckString(recStageTable.F015).Trim());

            EVALUATE(YourRef, CheckString(recStageTable.F016).Trim());
            EVALUATE(LCNo, CheckString(recStageTable.F017).Trim());
            EVALUATE(ApplDrawee, CheckString(recStageTable.F018).Trim());

            if (CheckString(recStageTable.F019).Trim() = '') OR (CheckString(recStageTable.F019).Trim() = '0') then
                Commission := 0
            else
                EVALUATE(Commission, CheckString(recStageTable.F019).Trim());

            if (CheckString(recStageTable.F020).Trim() = '') OR (CheckString(recStageTable.F020).Trim() = '0') then
                CheckingFee := 0
            else
                EVALUATE(CheckingFee, CheckString(recStageTable.F020).Trim());

            if (CheckString(recStageTable.F021).Trim() = '') OR (CheckString(recStageTable.F021).Trim() = '0') then
                Postage := 0
            else
                EVALUATE(Postage, CheckString(recStageTable.F021).Trim());

            if (CheckString(recStageTable.F022).Trim() = '') OR (CheckString(recStageTable.F022).Trim() = '0') then
                TelexCharge := 0
            else
                EVALUATE(TelexCharge, CheckString(recStageTable.F022).Trim());

            if (CheckString(recStageTable.F023).Trim() = '') OR (CheckString(recStageTable.F023).Trim() = '0') then
                ServiceCharge := 0
            else
                EVALUATE(ServiceCharge, CheckString(recStageTable.F023).Trim());

            EVALUATE(Beneficiary, CheckString(recStageTable.F024).Trim());

            if (CheckString(recStageTable.F025).Trim() = '') OR (CheckString(recStageTable.F025).Trim() = '0') then
                CableCharges := 0
            else
                EVALUATE(CableCharges, CheckString(recStageTable.F025).Trim());

            if (CheckString(recStageTable.F026).Trim() = '') OR (CheckString(recStageTable.F026).Trim() = '0') then
                LCIssAmendCom := 0
            else
                EVALUATE(LCIssAmendCom, CheckString(recStageTable.F026).Trim());

            EVALUATE(DocName, CheckString(recStageTable.F027).Trim());

            if (CheckString(recStageTable.F028).Trim() = '') OR (CheckString(recStageTable.F028).Trim() = '0') then
                RemittAmt := 0
            else
                EVALUATE(RemittAmt, CheckString(recStageTable.F028).Trim());

            if (CheckString(recStageTable.F029).Trim() = '') OR (CheckString(recStageTable.F029).Trim() = '0') then
                InterestAmt := 0
            else
                EVALUATE(InterestAmt, CheckString(recStageTable.F029).Trim());

            if (CheckString(recStageTable.F030).Trim() = '') OR (CheckString(recStageTable.F030).Trim() = '0') then
                AmtRepaid := 0
            else
                EVALUATE(AmtRepaid, CheckString(recStageTable.F030).Trim());

            if (CheckString(recStageTable.F031).Trim() = '') OR (CheckString(recStageTable.F031).Trim() = '0') then
                BillAmt := 0
            else
                EVALUATE(BillAmt, CheckString(recStageTable.F031).Trim());

            if (CheckString(recStageTable.F032).Trim() = '') OR (CheckString(recStageTable.F032).Trim() = '0') then
                InterestDue := 0
            else
                EVALUATE(InterestDue, CheckString(recStageTable.F032).Trim());

            /*
                        If (BillAmt = 0) and (RemittAmt = 0) then Error('Bill Amount and Remitted Amount cannot both in zero or no value.');

                        If (BillAmt <> 0) and (RemittAmt <> 0) then Error('Bill Amount and Remitted Amount cannot both have value.');

                        if CreditAmt = 0 then Error('Credit Amount cannot be zero or no value');
            */

            if DebitAmt = 0 then Error('Debit Amount cannot be zero.');

            if AccountNo.Trim() = '' then Error('Bank Account No. cannot be empty.');


            /****************************************************/
            /*** Generate Payment Journal (Bank Debit Advice) ***/
            /****************************************************/

            //*** Payment Journal Line 1 ***
            recGJL.Reset();
            recGJL.Init();
            recGJL."Journal Template Name" := 'PAYMENTS';
            recGJL."Journal Batch Name" := 'SCANNING';

            DocNo := NoSeriesMgt.GetNextNo('GJNL-PMT', Today, true);
            recGJL.Validate("Document No.", DocNo);
            recGJL.Validate("Posting Date", Today);

            recGJL2.Reset();
            recGJL2.SetRange("Journal Template Name", 'PAYMENTS');
            recGJL2.SetRange("Journal Batch Name", 'SCANNING');
            if recGJL2.FindLast() then
                LastLineNo := recGJL2."Line No." + 10000
            else
                LastLineNo := 10000;

            recGJL.Validate("Line No.", LastLineNo);
            recGJL.Validate("Document Type", recGJL."Document Type"::Payment);
            recGJL.Validate("Account Type", recGJL."Account Type"::Vendor);
            recGJL.Validate("Payment Method Code", 'BANK');
            recGJL.Validate("External Document No.", InvNo);

            GLSetup.Reset();
            if GLSetup.get then;
            if Currency <> GLSetup."LCY Code" then
                recGJL.Validate("Currency Code", Currency);

            recGJL.Validate(Amount, DebitAmt);
            recGJL.Insert(true);

            //*** Payment Journal Line 2 ***
            recGJL.Reset();
            recGJL.Init();
            recGJL."Journal Template Name" := 'PAYMENTS';
            recGJL."Journal Batch Name" := 'SCANNING';

            recGJL.Validate("Document No.", DocNo);
            recGJL.Validate("Posting Date", Today);

            recGJL2.Reset();
            recGJL2.SetRange("Journal Template Name", 'PAYMENTS');
            recGJL2.SetRange("Journal Batch Name", 'SCANNING');
            if recGJL2.FindLast() then
                LastLineNo := recGJL2."Line No." + 10000
            else
                LastLineNo := 10000;

            recGJL.Validate("Line No.", LastLineNo);
            recGJL.Validate("Document Type", recGJL."Document Type"::Payment);
            recGJL.Validate("Account Type", recGJL."Account Type"::"Bank Account");
            recGJL.Validate("Payment Method Code", 'BANK');
            recGJL.Validate("External Document No.", InvNo);


            if AccountNo.Trim() = '' then Error('Bank Account No. cannot be empty.');

            recBankAcc.Reset();
            recBankAcc.SetRange("Bank Account No.", AccountNo.Trim());
            if recBankAcc.FindFirst() then
                BankNo := recBankAcc."No."
            else
                Error('Bank Account No.: ' + Format(AccountNo.Trim()) + ' not found in bank account.');

            recGJL.Validate("Account No.", BankNo);

            if YourRef.Trim() <> '' then
                tempDesc := recGJL.Description + ' | YourRef: ' + YourRef + ' | Doc Type: ' + DocType;
            tempDesc := CopyStr(tempDesc, 1, 100);
            recGJL.Description := tempDesc;

            GLSetup.Reset();
            if GLSetup.get then;
            if Currency <> GLSetup."LCY Code" then
                recGJL.Validate("Currency Code", Currency);
            recGJL.Validate(Amount, -DebitAmt);

            //Write to comment fields
            tempComment := '';
            if YourRef.Trim() <> '' then tempComment := tempComment + ' Your Ref: ' + YourRef.Trim() + ' | ';
            if BankName.Trim() <> '' then tempComment := tempComment + ' Bank Name: ' + BankName.Trim() + ' | ';
            if BankRef.Trim() <> '' then tempComment := tempComment + ' Bank Ref: ' + BankRef.Trim() + ' | ';
            if Issdate <> 0D then tempComment := tempComment + ' Issue Date: ' + Format(Issdate) + ' | ';
            if Loantype.Trim() <> '' then tempComment := tempComment + ' Loan Type: ' + Loantype.Trim() + ' | ';
            if AmtOfLoan <> 0 then tempComment := tempComment + ' Amt of Loan: ' + Format(AmtOfLoan, 0) + ' | ';
            if TermOfLoan.Trim() <> '' then tempComment := tempComment + ' Term of Loan: ' + TermOfLoan.Trim() + ' | ';
            if MaturityDate <> 0D then tempComment := tempComment + ' Maturity Date: ' + Format(MaturityDate) + ' | ';
            if InterestRate.Trim() <> '' then tempComment := tempComment + ' Interest Rate: ' + InterestRate.Trim() + ' | ';
            if InvFinComm <> 0 then tempComment := tempComment + ' Inv Fin Comm: ' + Format(InvFinComm, 0) + ' | ';
            if BankCharge <> 0 then tempComment := tempComment + ' Bank Charge: ' + Format(BankCharge, 0) + ' | ';
            if LCNo.Trim() <> '' then tempComment := tempComment + ' LC No: ' + LCNo.Trim() + ' | ';
            if ApplDrawee.Trim() <> '' then tempComment := tempComment + ' Appl Drawee: ' + ApplDrawee.Trim() + ' | ';
            if Commission <> 0 then tempComment := tempComment + ' Commission: ' + Format(Commission, 0) + ' | ';
            if CheckingFee <> 0 then tempComment := tempComment + ' Checking Fee: ' + Format(CheckingFee, 0) + ' | ';
            if Postage <> 0 then tempComment := tempComment + ' Postage: ' + Format(Postage, 0) + ' | ';
            if TelexCharge <> 0 then tempComment := tempComment + ' Telex Charge: ' + Format(TelexCharge, 0) + ' | ';
            if ServiceCharge <> 0 then tempComment := tempComment + ' Service Charge: ' + Format(ServiceCharge, 0) + ' | ';
            if Beneficiary.Trim() <> '' then tempComment := tempComment + ' Beneficiary: ' + Beneficiary.Trim() + ' | ';
            if CableCharges <> 0 then tempComment := tempComment + ' Cable Charge: ' + Format(CableCharges, 0) + ' | ';
            if LCIssAmendCom <> 0 then tempComment := tempComment + ' LC Iss/Amend Com: ' + Format(LCIssAmendCom, 0) + ' | ';
            if DocName.Trim() <> '' then tempComment := tempComment + ' Doc Name: ' + DocName.Trim() + ' | ';
            if RemittAmt <> 0 then tempComment := tempComment + ' Remitt Amt: ' + Format(RemittAmt, 0) + ' | ';
            if InterestAmt <> 0 then tempComment := tempComment + ' Interest Amt: ' + Format(InterestAmt, 0) + ' | ';
            if AmtRepaid <> 0 then tempComment := tempComment + ' Amt Repaid: ' + Format(AmtRepaid, 0) + ' | ';
            if BillAmt <> 0 then tempComment := tempComment + ' Bill Amt: ' + Format(BillAmt, 0) + ' | ';
            if InterestDue <> 0 then tempComment := tempComment + ' Interest Due: ' + Format(InterestDue, 0) + ' | ';

            If StrLen(tempComment) > 2 then tempComment := Copystr(tempComment, 1, StrLen(tempComment) - 2);

            if Strlen(tempcomment.Trim()) <= 250 then
                recGJL.Validate(Comment, tempComment)
            else begin
                recGJL.Validate(Comment, Copystr(tempComment, 1, 250));
                recGJL.Validate("Contact Graph Id", Copystr(tempComment, 251, 500));
            end;

            recGJL.Insert(true);

        end;

    end;


    /*******************************************/
    /*******************************************/
    /*** Insurance generate Purchase Invoice ***/
    /*******************************************/
    /*******************************************/
    procedure GenInsExp(FileID: code[1000])
    var
        intNo: Integer;
        recPurHdr: record "Purchase Header";
        recPurline: Record "Purchase Line";
        PurSetup: Record "Purchases & Payables Setup";
        recPurCommLine: Record "Purch. Comment Line";
        recPreDelete: Record PreDelete;
        GLSetup: Record "General Ledger Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        recStageTable: Record "Stage Table";
        recStageTable_2: Record "Stage Table";
        recVendor: Record Vendor;
        recVendor2: Record Vendor;
        recGLAcc: Record "G/L Account";
        intCount: Integer;
        IntHdr: Integer;
        IntBufferCount: Integer;
        txtVenName: text[80];
        txtVenRefNo: text[80];
        myCost: Decimal;

        DocNo: code[20];
        VenName: Text[100];
        VenName2: Text[102];
        VenRefNo: code[35];
        IssDate: Date;
        Subj: Text[80];
        TotAmt: Decimal;
        CurCode: Code[10];
        AccNo: Text[80];
        Due: Date;
        Rmk: text[80];
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
        VendFlag: Boolean;

    begin

        intCount := 0;
        IntHdr := 0;
        IntBufferCount := 0;
        if recPreDelete.FindFirst() then;

        recStageTable.Reset();
        recStageTable.SetRange(FileId, FileID);
        recStageTable.SetFilter(F001, '<>%1', '');

        If recStageTable.FindSet() then begin
            IntBufferCount := recStageTable.Count;

            EVALUATE(VenName, CheckString(recStageTable.F001).Trim());
            EVALUATE(VenRefNo, CheckString(recStageTable.F002).Trim());
            txtVenName := recStageTable.F001.Trim();
            txtVenRefNo := recStageTable.F002.Trim();

            EVALUATE(IssDate, CheckString(recStageTable.F003).Trim());
            EVALUATE(Subj, CheckString(recStageTable.F004).Trim());
            EVALUATE(CurCode, CheckString(recStageTable.F005).Trim());
            EVALUATE(Due, CheckString(recStageTable.F006).Trim());




            if CheckString(recStageTable.F007).Trim() = '' then
                TotAmt := 0
            else
                EVALUATE(TotAmt, CheckString(recStageTable.F007).Trim());

            if TotAmt = 0 then Error('Total Amount = 0');

            Evaluate(Rmk, CheckString(recStageTable.F900).Trim());

            /***************************************************/
            /*** Purchase Invoice Header Section (Insurance) ***/
            /***************************************************/

            VendFlag := false;
            VenName2 := '';
            VenName2 := '''' + VenName.Trim() + '''';

            //Error('***' + VenName2);

            Clear(recVendor);
            recVendor.SetFilter(Name, VenName2);
            iF recVendor.FindFirst then
                VendFlag := true
            else begin
                Clear(recVendor);
                recVendor.SetFilter("Name 2", VenName2);
                iF recVendor.FindFirst then VendFlag := true;
            end;

            recPurHdr.Reset();
            recPurHdr.Setrange("Document Type", recPurHdr."Document Type"::Invoice);
            recPurHdr.SetFilter("Buy-from Vendor No.", recVendor."No.");
            recPurHdr.SetFilter("Vendor Invoice No.", VenRefNo);
            //if recPurHdr.FindFirst() then
            //    Error('Vendor Invoice: ' + Format(VenRefNo) + ' already exist.');

            if PurSetup.GET then
                DocNo := NoSeriesMgt.GetNextNo(PurSetup."Invoice Nos.", Today, true);

            recPurHdr.reset;
            recPurHdr.Init();
            recPurHdr."Document Type" := recPurHdr."Document Type"::Invoice;

            if PurSetup.GET then;
            recPurHdr.Validate("No.", DocNo);
            recPurHdr.Validate("Posting Date", Today);
            recPurHdr.Insert(true);

            if GLSetup.get then;
            If (CurCode <> '') AND (CurCode <> GLSetup."LCY Code") then recPurHdr.Validate("Currency Code", CurCode);

            recPurHdr.Validate("Buy-from Vendor No.", recVendor."No.");
            recPurHdr.Validate("Vendor Invoice No.", VenRefNo);
            if IssDate <> 0D then recPurHdr.Validate("Document Date", IssDate);

            if Due <> 0D then recpurhdr.Validate("Due Date", Due);
            recpurhdr.Modify(true);

            if Subj.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", Today);
                recPurCommLine.Validate("Comment", 'SUBJECT: ' + CopyStr(Subj.Trim(), 1, 80 - StrLen('SUBJECT: ')));
                recPurCommLine.Insert();
            end;

            if Rmk.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 20000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", Today);
                recPurCommLine.Validate(Comment, 'REMARK: ' + copystr(Rmk, 1, 80 - StrLen('REMARK: ')));
                recPurCommLine.Insert();
            end;

            /***************************************************/
            /*** Purchase Invoice Line Section (Insurance) ***/
            /***************************************************/
            intNo := 1;
            recPurLine.Reset();
            recPurLine.Init();
            recPurLine."Document Type" := recPurLine."Document Type"::Invoice;
            recPurLine."Document No." := DocNo;
            recPurLine."Line No." := intNo * 10000;
            recPurLine.Insert(true);

            recPurLine.type := recPurLine.type::"G/L Account";
            //recPurLine.Validate("No.", '8450');

            if recVendor."Scanning GL Acc" = '' then Error('Vendor ' + recVendor.Name + ' missing value in Scanning G/L Accoount.');

            recGLAcc.Reset();
            recGLAcc.SetRange("No.", recVendor."Scanning GL Acc");
            If recGLAcc.FindFirst() then begin
                if recGLAcc."Gen. Posting Type" = recGLAcc."Gen. Posting Type"::" " then Error('G/L Account ' + Format(recVendor."Scanning GL Acc") + ' missing value in Gen. Posting Type.');
                if recGLAcc."Gen. Prod. Posting Group" = '' then Error('G/L Account' + Format(recVendor."Scanning GL Acc") + ' missing value in Gen. Prod. Posting Group..');
                recpurline.Validate("No.", recVendor."Scanning GL Acc")
            end else
                Error('Vendor ' + recVendor.Name + ' with Scanning G/L Account no. ' + recVendor."Scanning GL Acc" + ' not found in Chart of Account.');



            if Rmk.Trim() <> '' then
                recPurLine.Validate(Description, Rmk.Trim())
            else
                if Subj.Trim() <> '' then
                    recPurLine.Validate(Description, Subj.Trim())
                else
                    recPurLine.Validate(Description, 'Insurance');

            recPurLine.Validate(Quantity, 1);
            recPurLine.Validate("Unit of Measure", 'SERVICE');
            recPurLine.Validate("Direct Unit Cost", TotAmt);
            recPurLine.Modify(true);

        end;
    end;

    /******************************************/
    /******************************************/
    /*** Freight Fee generate Sales Invoice ***/
    /******************************************/
    /******************************************/
    procedure GenFgtExp(FileID: code[1000])
    var
        intNo: Integer;
        recPurHdr: record "Purchase Header";
        recPurline: Record "Purchase Line";
        PurSetup: Record "Purchases & Payables Setup";
        recPurCommLine: Record "Purch. Comment Line";
        recPreDelete: Record PreDelete;
        GLSetup: Record "General Ledger Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        recStageTable: Record "Stage Table";
        recStageTable_2: Record "Stage Table";
        recVendor: Record Vendor;
        recGLAcc: Record "G/L Account";
        intCount: Integer;
        IntHdr: Integer;
        IntBufferCount: Integer;
        txtVenName: text[80];
        txtVenRefNo: text[80];
        myCost: Decimal;

        DocNo: code[20];
        VenName: Text[100];
        VenName2: Text[102];
        VenRefNo: code[35];
        IssDate: Date;
        Subj: Text[80];
        TotAmt: Decimal;
        CurCode: Code[10];
        Rmk: Text[80];
        Due: Date;
        Ves: Text[80];
        Imo: Text[80];

        IntHeader: Integer;
        VendFlag: Boolean;
        L_Qty: Integer;

    begin

        intCount := 0;
        IntHdr := 0;
        IntBufferCount := 0;
        if recPreDelete.FindFirst() then;

        recStageTable.Reset();
        recStageTable.SetRange(FileId, FileID);
        recStageTable.SetFilter(F001, '<>%1', '');

        If recStageTable.FindSet() then begin
            IntBufferCount := recStageTable.Count;

            IntHeader += 1;

            EVALUATE(VenName, CheckString(recStageTable.F001).Trim());
            EVALUATE(VenRefNo, CheckString(recStageTable.F002).Trim());
            EVALUATE(IssDate, CheckString(recStageTable.F003).Trim());
            EVALUATE(Subj, CheckString(recStageTable.F004).Trim());

            if CheckString(recStageTable.F005) = '' then
                TotAmt := 0
            else
                EVALUATE(TotAmt, CheckString(recStageTable.F005).Trim());

            if TotAmt = 0 then Error('Total Amount = 0');

            EVALUATE(CurCode, CheckString(recStageTable.F006).Trim());
            EVALUATE(Rmk, CheckString(recStageTable.F007).Trim());
            EVALUATE(Due, CheckString(recStageTable.F008).Trim());
            Evaluate(Ves, CheckString(recStageTable.F009).Trim());
            Evaluate(Imo, CheckString(recStageTable.F010).Trim());

            VendFlag := false;
            VenName2 := '';
            VenName2 := '''' + VenName.Trim() + '''';

            //Error('***' + VenName2);

            Clear(recVendor);
            recVendor.SetFilter(Name, VenName2);
            iF recVendor.FindFirst then
                VendFlag := true
            else begin
                Clear(recVendor);
                recVendor.SetFilter("Name 2", VenName2);
                iF recVendor.FindFirst then VendFlag := true;
            end;

            If VendFlag = false then Error('Vendor: ' + VenName + ' not found.');


            L_Qty := 1;

            /*****************************************/
            /*** Freight Fee generate Sales Header ***/
            /*****************************************/

            recPurHdr.Reset();
            recPurHdr.Setrange("Document Type", recPurHdr."Document Type"::Invoice);
            recPurHdr.SetFilter("Buy-from Vendor No.", recVendor."No.");
            recPurHdr.SetFilter("Vendor Invoice No.", VenRefNo);
            //if recPurHdr.FindFirst() then
            //    Error('Vendor Invoice: ' + Format(VenRefNo) + ' already exist.');

            if PurSetup.GET then
                DocNo := NoSeriesMgt.GetNextNo(PurSetup."Invoice Nos.", Today, true);

            recPurHdr.reset;
            recPurHdr.Init();
            recPurHdr."Document Type" := recPurHdr."Document Type"::Invoice;

            if PurSetup.GET then;
            recPurHdr.Validate("No.", DocNo);
            recPurHdr.Validate("Posting Date", Today);
            recPurHdr.Insert(true);

            recPurHdr.Validate("Buy-from Vendor No.", recVendor."No.");
            recPurHdr.Validate("Vendor Invoice No.", VenRefNo);
            if IssDate <> 0D then recPurHdr.Validate("Document Date", IssDate);
            if GLSetup.get then;
            If (CurCode <> '') and (CurCode <> GLSetup."LCY Code") then recPurHdr.Validate("Currency Code", CurCode);

            if Due <> 0D then recpurhdr.Validate("Due Date", Due);
            recpurhdr.Modify(true);

            if Subj.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'SUBJECT: ' + CopyStr(Subj, 1, 80 - StrLen('SUBJECT: ')));
                recPurCommLine.Insert();
            end;

            if Rmk.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'REMARK: ' + CopyStr(Rmk, 1, 80 - StrLen('REMARK: ')));
                recPurCommLine.Insert();
            end;

            if Ves.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'VESSEL: ' + CopyStr(Ves, 1, 80 - StrLen('VESSEL: ')));
                recPurCommLine.Insert();
            end;

            if Imo.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'IMO NO: ' + CopyStr(Imo, 1, 80 - StrLen('IMO NO: ')));
                recPurCommLine.Insert();
            end;

            /****************************************/
            /*** Freight  Fee generate Sales Line ***/
            /****************************************/

            recPurLine.Reset();
            recPurLine.Init();
            recPurLine."Document Type" := recPurLine."Document Type"::Invoice;
            recPurLine."Document No." := DocNo;
            recPurLine."Line No." := 10000;
            recPurLine.Insert(true);

            recPurLine.type := recPurLine.type::"G/L Account";
            //recPurline.Validate("No.", '8450');

            if recVendor."Scanning GL Acc" = '' then Error('Vendor ' + recVendor.Name + ' missing value in Scanning G/L Accoount.');

            recGLAcc.Reset();
            recGLAcc.SetRange("No.", recVendor."Scanning GL Acc");
            If recGLAcc.FindFirst() then begin
                if recGLAcc."Gen. Posting Type" = recGLAcc."Gen. Posting Type"::" " then Error('G/L Account ' + Format(recVendor."Scanning GL Acc") + ' missing value in Gen. Posting Type.');
                if recGLAcc."Gen. Prod. Posting Group" = '' then Error('G/L Account' + Format(recVendor."Scanning GL Acc") + ' missing value in Gen. Prod. Posting Group..');
                recpurline.Validate("No.", recVendor."Scanning GL Acc")
            end else
                Error('Vendor ' + recVendor.Name + ' with Scanning G/L Account no. ' + recVendor."Scanning GL Acc" + ' not found in Chart of Account.');

            if Rmk.Trim() <> '' then begin
                recPurLine.Validate(Description, Rmk);
            end;

            recPurLine.Validate(Quantity, L_Qty);

            recPurLine.Validate("Direct Unit Cost", TotAmt);
            recPurLine.Modify(true);

        end;
    end;


    /************************************************/
    /************************************************/
    /*** Inspection Fee generate Purchase Invoice ***/
    /************************************************/
    /************************************************/

    procedure GenIspFee(FileID: code[1000])
    var
        intNo: Integer;
        recPurHdr: record "Purchase Header";
        recPurline: Record "Purchase Line";
        PurSetup: Record "Purchases & Payables Setup";
        recPurCommLine: Record "Purch. Comment Line";
        recPreDelete: Record PreDelete;
        GLSetup: Record "General Ledger Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        recStageTable: Record "Stage Table";
        recStageTable_2: Record "Stage Table";
        recVendor: Record Vendor;
        recGLAcc: Record "G/L Account";
        intCount: Integer;
        IntHdr: Integer;
        IntBufferCount: Integer;
        txtVenName: text[80];
        txtVenRefNo: text[80];
        myCost: Decimal;

        DocNo: code[20];
        VenName: Text[100];
        VenName2: Text[102];
        VenRefNo: code[35];
        IssDate: Date;
        Subj: Text[80];
        TotAmt: Decimal;
        CurCode: Code[10];
        Rmk: Text[80];
        YouRef: Text[80];
        Ves: Text[80];


        IntHeader: Integer;
        VendFlag: Boolean;
        L_Qty: Integer;

    begin

        intCount := 0;
        IntHdr := 0;
        IntBufferCount := 0;
        if recPreDelete.FindFirst() then;

        recStageTable.Reset();
        recStageTable.SetRange(FileId, FileID);
        recStageTable.SetFilter(F001, '<>%1', '');

        If recStageTable.FindSet() then begin
            IntBufferCount := recStageTable.Count;

            IntHeader += 1;

            EVALUATE(VenName, CheckString(recStageTable.F001).Trim());
            EVALUATE(VenRefNo, CheckString(recStageTable.F002).Trim());
            EVALUATE(IssDate, CheckString(recStageTable.F003).Trim());
            EVALUATE(Subj, CheckString(recStageTable.F004).Trim());

            if CheckString(recStageTable.F005) = '' then
                TotAmt := 0
            else
                EVALUATE(TotAmt, CheckString(recStageTable.F005).Trim());

            if TotAmt = 0 then Error('Invoice Amount = 0');

            EVALUATE(CurCode, CheckString(recStageTable.F006).Trim());
            EVALUATE(YouRef, CheckString(recStageTable.F007).Trim());
            EVALUATE(Rmk, CheckString(recStageTable.F008).Trim());
            Evaluate(Ves, CheckString(recStageTable.F009).Trim());

            VendFlag := false;
            VenName2 := '';
            VenName2 := '''' + VenName.Trim() + '''';

            //Error('***' + VenName2);

            Clear(recVendor);
            recVendor.SetFilter(Name, VenName2);
            iF recVendor.FindFirst then
                VendFlag := true
            else begin
                Clear(recVendor);
                recVendor.SetFilter("Name 2", VenName2);
                iF recVendor.FindFirst then VendFlag := true;
            end;

            if VendFlag = false then Error('Vendor: ' + VenName + ' not found in system.');

            L_Qty := 1;

            /********************************************/
            /*** Inspection Fee generate Sales Header ***/
            /********************************************/

            recPurHdr.Reset();
            recPurHdr.Setrange("Document Type", recPurHdr."Document Type"::Invoice);
            recPurHdr.SetFilter("Buy-from Vendor No.", recVendor."No.");
            recPurHdr.SetFilter("Vendor Invoice No.", VenRefNo);
            //if recPurHdr.FindFirst() then
            //    Error('Vendor Invoice: ' + Format(VenRefNo) + ' already exist.');

            if PurSetup.GET then
                DocNo := NoSeriesMgt.GetNextNo(PurSetup."Invoice Nos.", Today, true);

            recPurHdr.reset;
            recPurHdr.Init();
            recPurHdr."Document Type" := recPurHdr."Document Type"::Invoice;

            if PurSetup.GET then;
            recPurHdr.Validate("No.", DocNo);
            recPurHdr.Validate("Posting Date", Today);
            recPurHdr.Insert(true);

            recPurHdr.Validate("Buy-from Vendor No.", recVendor."No.");
            recPurHdr.Validate("Vendor Invoice No.", VenRefNo);
            if IssDate <> 0D then recPurHdr.Validate("Document Date", IssDate);
            if GLSetup.get then;
            If (CurCode <> '') and (CurCode <> GLSetup."LCY Code") then recPurHdr.Validate("Currency Code", CurCode);

            //if Due <> 0D then recpurhdr.Validate("Due Date", Due);
            recpurhdr.Modify(true);

            if Subj.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'SUBJECT: ' + CopyStr(Subj, 1, 80 - StrLen('SUBJECT: ')));
                recPurCommLine.Insert();
            end;

            if Rmk.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'REMARK: ' + CopyStr(Rmk, 1, 80 - StrLen('REMARK: ')));
                recPurCommLine.Insert();
            end;

            if Ves.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'VESSEL: ' + CopyStr(Ves, 1, 80 - StrLen('VESSEL: ')));
                recPurCommLine.Insert();
            end;

            if YouRef.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'Your Ref.: ' + CopyStr(YouRef, 1, 80 - StrLen('Your Ref.: ')));
                recPurCommLine.Insert();
            end;

            /******************************************/
            /*** Inspection Fee generate Sales Line ***/
            /******************************************/

            recPurLine.Reset();
            recPurLine.Init();
            recPurLine."Document Type" := recPurLine."Document Type"::Invoice;
            recPurLine."Document No." := DocNo;
            recPurLine."Line No." := 10000;
            recPurLine.Insert(true);

            recPurLine.type := recPurLine.type::"G/L Account";
            //recPurline.Validate("No.", '8450');

            if recVendor."Scanning GL Acc" = '' then Error('Vendor ' + recVendor.Name + ' missing value in Scanning G/L Accoount.');

            recGLAcc.Reset();
            recGLAcc.SetRange("No.", recVendor."Scanning GL Acc");
            If recGLAcc.FindFirst() then begin
                if recGLAcc."Gen. Posting Type" = recGLAcc."Gen. Posting Type"::" " then Error('G/L Account ' + Format(recVendor."Scanning GL Acc") + ' missing value in Gen. Posting Type.');
                if recGLAcc."Gen. Prod. Posting Group" = '' then Error('G/L Account' + Format(recVendor."Scanning GL Acc") + ' missing value in Gen. Prod. Posting Group..');
                recpurline.Validate("No.", recVendor."Scanning GL Acc")
            end else
                Error('Vendor ' + recVendor.Name + ' with Scanning G/L Account no. ' + recVendor."Scanning GL Acc" + ' not found in Chart of Account.');

            if Rmk.Trim() <> '' then begin
                recPurLine.Validate(Description, Rmk);
            end;

            recPurLine.Validate(Quantity, L_Qty);

            recPurLine.Validate("Direct Unit Cost", TotAmt);
            recPurLine.Modify(true);

        end;
    end;


    /***********************************************/
    /***********************************************/
    /*** Supplier Invoice generate Sales Invoice ***/
    /***********************************************/
    /***********************************************/
    procedure GenSupInv(FildID: code[1000])
    var
        intCount: Integer;
        IntHdr: Integer;
        IntBufferCount: Integer;

        recStageTable: Record "Stage Table";
        recPurHdr: Record "Purchase Header";
        recPurLine: Record "Purchase Line";
        recVendor: Record Vendor;
        PurchSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        recPurCommLine: Record "Purch. Comment Line";
        GLSetup: Record "General Ledger Setup";
        recGLAcc: Record "G/L Account";

        DocNo: code[20];
        VenName: Text[100];
        VenName2: Text[102];
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
        FinalDesc: text[100];


        L_LineNO: Integer;
        L_Desc: Text[100];
        L_Tonnage: Text[100];
        L_UnitPrice: Decimal;
        L_Amt: Decimal;
        L_Cur: Code[10];
        L_Qty: Decimal;
        L_UM: Code[10];
        L_discount: Decimal;

        VendFlag: Boolean;
        NotFirstLine: Boolean;

    begin
        intCount := 0;
        IntHdr := 0;
        IntBufferCount := 0;

        recStageTable.Reset();
        recStageTable.SetRange(FileId, FildID);
        recStageTable.SetFilter(F001, '<>%1', '');

        If recStageTable.FindSet() then begin
            IntBufferCount := recStageTable.Count;
        end;


        EVALUATE(VenName, CheckString(recStageTable.F001).Trim());
        EVALUATE(VenRefNo, CheckString(recStageTable.F002));
        If CheckString(recStageTable.F003).Trim() = '' then
            IssDate := Today
        else
            EVALUATE(IssDate, CheckString(recStageTable.F003));
        Evaluate(YourRef, CheckString(recStageTable.F004));
        Evaluate(ShipNo, CheckString(recStageTable.F005));
        Evaluate(VendAgNo, CheckString(recStageTable.F006));
        Evaluate(VesselDtl, CheckString(recStageTable.F007));

        if (CheckString(recStageTable.F008).Trim() = '') or (CheckString(recStageTable.F008).Trim() = '0') then
            AmtDue := 0
        else
            Evaluate(AmtDue, CheckString(recStageTable.F008));

        Evaluate(CurCode, CheckString(recStageTable.F009));
        Evaluate(GoodsDesc, CheckString(recStageTable.F010));
        Evaluate(Grades, CheckString(recStageTable.F011));

        Evaluate(UnitPrices, CheckString(recStageTable.F012));

        Evaluate(MTs, CheckString(recStageTable.F013));

        if (CheckString(recStageTable.F014).Trim() = '') or (CheckString(recStageTable.F014).Trim() = '0') then
            InvAmount := 0
        else
            Evaluate(InvAmount, CheckString(recStageTable.F014));

        If CheckString(recStageTable.F015).Trim() = '' then
            Due := Today
        else
            EVALUATE(Due, CheckString(recStageTable.F015));
        Evaluate(InvAmt100p, CheckString(recStageTable.F016));

        Evaluate(InvAmt95p, CheckString(recStageTable.F017));

        //Evaluate(totamt, Amount);
        Evaluate(VATs, CheckString(recStageTable.F019));
        Evaluate(qty, CheckString(recStageTable.F020));
        Evaluate(Subj, CheckString(recStageTable.F021));

        //Evaluate(L_LineNO, LineItemNo);
        Evaluate(L_Desc, CheckString(recStageTable.F023));
        Evaluate(L_Tonnage, CheckString(recStageTable.F024));

        if (CheckString(recStageTable.F025).Trim() = '') or (CheckString(recStageTable.F025).Trim() = '0') then
            L_UnitPrice := 0
        else
            Evaluate(L_UnitPrice, CheckString(recStageTable.F025));

        if (CheckString(recStageTable.F026).Trim() = '') or (CheckString(recStageTable.F014).Trim() = '0') then
            L_Amt := 0
        else
            Evaluate(L_Amt, CheckString(recStageTable.F026));


        Evaluate(L_cur, CheckString(recStageTable.F027));

        if (CheckString(recStageTable.F028).Trim() = '') or (CheckString(recStageTable.F028).Trim() = '0') then
            L_Qty := 0
        else
            Evaluate(L_Qty, CheckString(recStageTable.F028));

        if L_Qty = 0 then L_Qty := 1;
        if (L_UnitPrice = 0) and (L_Amt <> 0) then L_UnitPrice := L_Amt / L_Qty;
        Evaluate(L_UM, CheckString(recStageTable.F029));

        if (CheckString(recStageTable.F030).Trim() = '') or (CheckString(recStageTable.F030).Trim() = '0') then
            L_discount := 0
        else
            Evaluate(L_discount, CheckString(recStageTable.F030));

        VendFlag := false;
        VenName2 := '';
        VenName2 := '''' + VenName.Trim() + '''';

        //Error('***' + VenName2);

        Clear(recVendor);
        recVendor.SetFilter(Name, VenName2);
        iF recVendor.FindFirst then
            VendFlag := true
        else begin
            Clear(recVendor);
            recVendor.SetFilter("Name 2", VenName2);
            iF recVendor.FindFirst then VendFlag := true;
        end;

        if VendFlag = false then Error('Vendor: ' + VenName + ' not found in system.');


        /*
                Clear(recSalesHdr);
                recSalesHdr.setrange("Document Type", recSalesHdr."Document Type"::Invoice);
                recSalesHdr.setrange("Sell-to Customer No.", recCustomer."No.");
                recSaleshdr.SetRange("External Document No.", ContractNos);
                recSaleshdr.SetRange("Package Tracking No.", doctype);
                IF recSalesHdr.findfirst then
                    Error('Sales Contract No. already exist: ' + ContractNos);
        */


        L_Qty := 1;

        /***************************************/
        /*** Supplier Invoice Header Section ***/
        /***************************************/

        if NotFirstLine = false then begin

            //Message('header');

            //Clear(recPurHdr);
            //recPurHdr.Setrange("Document Type", recPurHdr."Document Type"::Invoice);
            //recPurHdr.SetFilter("Buy-from Vendor No.", recVendor."No.");
            //recPurHdr.SetFilter("Vendor Invoice No.", VenRefNo);
            //if recPurHdr.FindFirst() then
            //    Error('Vendor Invoice: ' + Format(VenRefNo) + ' already exist.');
            recPurHdr.Reset();
            recPurHdr.Init();
            recPurHdr."Document Type" := recPurHdr."Document Type"::Invoice;

            if PurchSetup.GET then
                DocNo := NoSeriesMgt.GetNextNo(PurchSetup."Invoice Nos.", Today, true);

            recPurHdr.reset;
            recPurHdr.Init();
            recPurHdr."Document Type" := recPurHdr."Document Type"::Invoice;

            if PurchSetup.GET then;
            recPurHdr.Validate("No.", DocNo);
            recPurHdr.Validate("Posting Date", Today);
            recPurHdr.Insert(true);

            recPurHdr.Validate("Buy-from Vendor No.", recVendor."No.");
            recPurHdr.Validate("Vendor Invoice No.", VenRefNo);
            if IssDate <> 0D then recPurHdr.Validate("Document Date", IssDate);
            if GLSetup.get then;
            If (CurCode <> '') and (CurCode <> GLSetup."LCY Code") then recPurHdr.Validate("Currency Code", CurCode);

            //if Due <> 0D then recpurhdr.Validate("Due Date", Due);
            recpurhdr.Modify(true);





            if YourRef.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'YOUR REF: ' + CopyStr(FORMAT(YourRef), 1, 80 - StrLen('YOUR REF: ')));
                recPurCommLine.Insert();
            end;




            if ShipNo.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'SHIPMENT NO.: ' + CopyStr(FORMAT(ShipNo), 1, 80 - StrLen('SHIPMENT NO.: ')));
                recPurCommLine.Insert();
            end;


            if VendAgNo.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'VENDER AGREE No.: ' + CopyStr(FORMAT(VendAgNo), 1, 80 - StrLen('VENDER AGREE No.: ')));
                recPurCommLine.Insert();
            end;

            if VesselDtl.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'VESSEL DETAIL: ' + CopyStr(FORMAT(VesselDtl), 1, 80 - StrLen('VESSEL DETAIL: ')));
                recPurCommLine.Insert();
            end;

            if AmtDue <> 0 then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'AMOUNT DUE: ' + CopyStr(FORMAT(AmtDue), 1, 80 - StrLen('AMOUNT DUE: ')));
                recPurCommLine.Insert();
            end;

            if GoodsDesc.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'GOODS DESC: ' + CopyStr(FORMAT(GoodsDesc), 1, 80 - StrLen('GOODS DESC: ')));
                recPurCommLine.Insert();
            end;

            if Grades.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'GRADE: ' + CopyStr(FORMAT(Grades), 1, 80 - StrLen('GRADE: ')));
                recPurCommLine.Insert();
            end;

            if UnitPrices.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'UNIT PrICE: ' + CopyStr(FORMAT(UnitPrices), 1, 80 - StrLen('UNIT PrICE: ')));
                recPurCommLine.Insert();
            end;

            if MTs.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'MT: ' + CopyStr(FORMAT(MTs), 1, 80 - StrLen('MT: ')));
                recPurCommLine.Insert();
            end;

            if InvAmount <> 0 then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'INVOICE AMT: ' + CopyStr(FORMAT(InvAmount), 1, 80 - StrLen('INVOICE AMT: ')));
                recPurCommLine.Insert();
            end;

            if InvAmt100p.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", '100% INVOICE AMT: ' + CopyStr(FORMAT(InvAmt100p), 1, 80 - StrLen('100% INVOICE AMT: ')));
                recPurCommLine.Insert();
            end;

            if InvAmt95p.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", '95% INVOICE AMT: ' + CopyStr(FORMAT(InvAmt95p), 1, 80 - StrLen('95% INVOICE AMT: ')));
                recPurCommLine.Insert();
            end;

            /*
            if totamt <> 0 then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastCommentLineNo() + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'AMOUNT: ' + CopyStr(FORMAT(totamt), 1, 80 - StrLen('AMOUNT: ')));
                recPurCommLine.Insert();
            end;     
            */

            if VATs.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'VAT: ' + CopyStr(FORMAT(VATs), 1, 80 - StrLen('VAT: ')));
                recPurCommLine.Insert();
            end;

            if qty.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'QUANTITY: ' + CopyStr(FORMAT(qty), 1, 80 - StrLen('QUANTITY: ')));
                recPurCommLine.Insert();
            end;

            if Subj.Trim() <> '' then begin
                recPurCommLine.Reset();
                recPurCommLine.Init();
                recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
                recPurCommLine.Validate("No.", recPurHdr."No.");
                recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
                recPurCommLine.Validate("Document Line No.", 0);
                recPurCommLine.Validate("Date", IssDate);
                recPurCommLine.Validate("Comment", 'SUBJECT: ' + CopyStr(FORMAT(Subj), 1, 80 - StrLen('SUBJECT: ')));
                recPurCommLine.Insert();
            end;

            NotFirstLine := true;

        end;


        if (AmtDue <> 0) and (InvAmount <> 0) then begin
            // 2 LINE NECESSAARY
            CLEAR(recPurLine);
            recPurLine.Init();
            recPurLine."Document Type" := recPurLine."Document Type"::Invoice;
            recPurLine."Document No." := DocNo;
            recPurLine.Type := recPurLine.type::" ";
            recPurLine."Line No." := 10000;
            recPurLine.Description := 'Invoice Total Amount: ' + Format(InvAmount);
            recPurLine.Insert(true);

            CLEAR(recPurLine);
            recPurLine.Init();
            recPurLine."Document Type" := recPurLine."Document Type"::Invoice;
            recPurLine."Document No." := DocNo;
            recPurLine."Line No." := 20000;
            recPurLine.Insert(true);
            recPurLine.type := recPurLine.type::"G/L Account";
            //recPurLine.Validate("No.", '8450');

            if recVendor."Scanning GL Acc" = '' then Error('Vendor ' + recVendor.Name + ' missing value in Scanning G/L Accoount.');

            recGLAcc.Reset();
            recGLAcc.SetRange("No.", recVendor."Scanning GL Acc");
            If recGLAcc.FindFirst() then begin
                if recGLAcc."Gen. Posting Type" = recGLAcc."Gen. Posting Type"::" " then Error('G/L Account ' + Format(recVendor."Scanning GL Acc") + ' missing value in Gen. Posting Type.');
                if recGLAcc."Gen. Prod. Posting Group" = '' then Error('G/L Account' + Format(recVendor."Scanning GL Acc") + ' missing value in Gen. Prod. Posting Group..');
                recpurline.Validate("No.", recVendor."Scanning GL Acc")
            end else
                Error('Vendor ' + recVendor.Name + ' with Scanning G/L Account no. ' + recVendor."Scanning GL Acc" + ' not found in Chart of Account.');

            if Subj.Trim() <> '' then FinalDesc := Subj;
            if GoodsDesc.Trim() <> '' then FinalDesc := GoodsDesc;
            if L_Desc.Trim() <> '' then FinalDesc := L_Desc;
            If FinalDesc.Trim() = '' then FinalDesc := 'Invoice Amount Due: ';

            recPurLine.Validate(Description, FinalDesc);

            if GLSetup.get then;
            If (L_Cur <> '') and (L_Cur <> GLSetup."LCY Code") then recPurLine.Validate("Currency Code", L_Cur);

            recPurLine.Validate(Quantity, 1);
            recPurLine.Validate("Direct Unit Cost", AmtDue);
            //recPurLine.Validate("Unit of Measure", L_UM);

            recPurLine.Modify(true);

            //if recPurLine."Line Amount" <> L_Amt then
            //    Error('Imported line amount: ' + FORMAT(L_Amt) + 'not equal to calculated line acount: ' + Format(recPurLine."Line Amount"));

        end else
            if (AmtDue <> 0) or (InvAmount <> 0) then begin
                // 1 LINE NECESSAARY

                CLEAR(recPurLine);
                recPurLine.Init();
                recPurLine."Document Type" := recPurLine."Document Type"::Invoice;
                recPurLine."Document No." := DocNo;
                recPurLine."Line No." := 10000;
                recPurLine.Insert(true);
                recPurLine.type := recPurLine.type::"G/L Account";
                //recPurLine.Validate("No.", '8450');

                if recVendor."Scanning GL Acc" = '' then Error('Vendor ' + recVendor.Name + ' missing value in Scanning G/L Accoount.');

                recGLAcc.Reset();
                recGLAcc.SetRange("No.", recVendor."Scanning GL Acc");
                If recGLAcc.FindFirst() then begin
                    if recGLAcc."Gen. Posting Type" = recGLAcc."Gen. Posting Type"::" " then Error('G/L Account ' + Format(recVendor."Scanning GL Acc") + ' missing value in Gen. Posting Type.');
                    if recGLAcc."Gen. Prod. Posting Group" = '' then Error('G/L Account' + Format(recVendor."Scanning GL Acc") + ' missing value in Gen. Prod. Posting Group..');
                    recpurline.Validate("No.", recVendor."Scanning GL Acc")
                end else
                    Error('Vendor ' + recVendor.Name + ' with Scanning G/L Account no. ' + recVendor."Scanning GL Acc" + ' not found in Chart of Account.');

                if Subj.Trim() <> '' then FinalDesc := Subj;
                if GoodsDesc.Trim() <> '' then FinalDesc := GoodsDesc;
                if L_Desc.Trim() <> '' then FinalDesc := L_Desc;
                If FinalDesc.Trim() = '' then FinalDesc := 'Invoice Amount Due: ';

                recPurLine.Validate(Description, FinalDesc);

                if GLSetup.get then;
                If (L_Cur <> '') and (L_Cur <> GLSetup."LCY Code") then recPurLine.Validate("Currency Code", L_Cur);

                recPurLine.Validate(Quantity, 1);
                if AmtDue <> 0 then
                    recPurLine.Validate("Direct Unit Cost", AmtDue)
                else
                    recPurLine.Validate("Direct Unit Cost", InvAmount);
                recPurLine.Modify(true);
            end;

        if L_Tonnage.Trim() <> '' then begin
            recPurCommLine.Reset();
            recPurCommLine.Init();
            recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
            recPurCommLine.Validate("No.", recPurHdr."No.");
            recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
            recPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
            recPurCommLine.Validate("Date", IssDate);
            recPurCommLine.Validate("Comment", 'TONNAGE: ' + CopyStr(L_Tonnage, 1, 80 - StrLen('TONNAGE: ')));
            recPurCommLine.Insert();
        end;

        if L_discount <> 0 then begin
            recPurCommLine.Reset();
            recPurCommLine.Init();
            recPurCommLine.Validate("Document Type", recPurHdr."Document Type"::Invoice);
            recPurCommLine.Validate("No.", recPurHdr."No.");
            recPurCommLine.Validate("Line No.", GetlastPurCommentLineNo(recPurHdr) + 10000);
            recPurCommLine.Validate("Document Line No.", L_LineNO * 10000);
            recPurCommLine.Validate("Date", IssDate);
            recPurCommLine.Validate("Comment", 'DISCOUNT: ' + CopyStr(FORMAT(L_discount), 1, 80 - StrLen('DISCOUNT: ')));
            recPurCommLine.Insert();
        end;

    end;




    /*************************************************/
    /*************************************************/
    /*** Commerical Invoice generate Sales Invoice ***/
    /*************************************************/
    /*************************************************/
    procedure GenComInv(FildID: code[1000])
    var
        IntHeader: Integer;
        intLine: Integer;
        recSalesHdr: Record "Sales Header";
        recSalesLine: Record "Sales Line";
        recSalesCommLine: Record "Sales Comment Line";
        recSalesCommLine2: Record "Sales Comment Line";
        recDimVal: Record "Dimension Value";


        recStageTable: Record "Stage Table";
        recStageTable_2: Record "Stage Table";

        recPreDelete: Record PreDelete;
        recSalesCommLineNo: Integer;
        recCustomer: Record Customer;
        recCurrency: Record Currency;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        SalesSetup: record "Sales & Receivables Setup";
        recGLAcc: Record "G/L Account";

        Doctype: Text[80];
        DocDate: Date;
        PNNO: code[20];
        CustName: Text[100];
        CustName2: Text[102];
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
        FInalAmt: Decimal;
        FinalCommInvValue100P: Decimal;
        Price95p: Decimal;


        L_Qty: Integer;
        L_LineNO: Integer;
        Firstline: Boolean;
        booNotFirstLine: Boolean;
        DocNo: code[20];
        intcount: Integer;
        IntHdr: Integer;
        IntBufferCount: Integer;
        CustFlag: Boolean;
        intNewDimID: Integer;
        GLSetup: Record "General Ledger Setup";
        Position: Integer;

    begin

        intCount := 0;
        IntHdr := 0;
        IntBufferCount := 0;
        if recPreDelete.FindFirst() then;

        recStageTable.Reset();
        recStageTable.SetRange(FileId, FildID);
        recStageTable.SetFilter(F001, '<>%1', '');

        If recStageTable.FindSet() then begin
            IntBufferCount := recStageTable.Count;
        end;

        EVALUATE(Doctype, CheckString(recStageTable.F001).Trim());
        EVALUATE(DocDate, CheckString(recStageTable.F002).Trim());

        If CheckString(recStageTable.F003).Trim() = '' then Error('PN No. is empty.');

        Position := STRPOS(CheckString(recStageTable.F003).Trim(), '/');
        if Position = 0 then Error('PN No. not found.');

        PNNO := CopyStr(CheckString(recStageTable.F003).Trim(), 1, Position - 1);
        If copystr(PNNO, 1, 2) <> 'PN' then Error('PN No. not found.');
        //EVALUATE(PNNO, CheckString(recStageTable.F003).Trim());

        EVALUATE(CustName, CheckString(recStageTable.F004).Trim());
        EVALUATE(CustAddress, CheckString(recStageTable.F005).Trim());
        EVALUATE(ContractNos, CheckString(recStageTable.F006).Trim());
        Evaluate(Vessel, CheckString(recStageTable.F007).Trim());
        EVALUATE(Commodities, CheckString(recStageTable.F008).Trim());
        Evaluate(Spec, CheckString(recStageTable.F009).Trim());
        EVALUATE(ActualWeights, CheckString(recStageTable.F010).Trim());
        EVALUATE(DryWrights, CheckString(recStageTable.F011).Trim());
        EVALUATE(ProvisPrice, CheckString(recStageTable.F012).Trim());
        EVALUATE(curr, CheckString(recStageTable.F013).Trim());

        if (CheckString(recStageTable.F014).Trim() = '') or (CheckString(recStageTable.F014).Trim() = '0') then
            ShippedGoodValue100P := 0
        else
            EVALUATE(ShippedGoodValue100P, CheckString(recStageTable.F014).Trim());

        if (CheckString(recStageTable.F015).Trim() = '') or (CheckString(recStageTable.F015).Trim() = '0') then
            ShippedGoodValue95P := 0
        else
            EVALUATE(ShippedGoodValue95P, CheckString(recStageTable.F015).Trim());

        Evaluate(PriceTerms, CheckString(recStageTable.F016));

        if (CheckString(recStageTable.F017).Trim() = '') or (CheckString(recStageTable.F017).Trim() = '0') then
            FInalAmt := 0
        else
            Evaluate(FInalAmt, CheckString(recStageTable.F017).Trim());

        if (CheckString(recStageTable.F019).Trim() = '') or (CheckString(recStageTable.F019).Trim() = '0') then
            FinalCommInvValue100P := 0
        else
            Evaluate(FinalCommInvValue100P, CheckString(recStageTable.F019).Trim());

        CustFlag := false;
        CustName2 := '';
        CustName2 := '''' + CustName.Trim() + '''';

        Clear(recCustomer);
        recCustomer.SetFilter(Name, CustName2);
        iF recCustomer.FindFirst then
            CustFlag := true
        else begin
            Clear(recCustomer);
            recCustomer.SetFilter("Name 2", CustName2);
            iF recCustomer.FindFirst then CustFlag := true;
        end;

        if CustFlag = false then Error('Customer: ' + CustName + ' not found in system.');




        /*
                Clear(recSalesHdr);
                recSalesHdr.setrange("Document Type", recSalesHdr."Document Type"::Invoice);
                recSalesHdr.setrange("Sell-to Customer No.", recCustomer."No.");
                recSaleshdr.SetRange("External Document No.", ContractNos);
                recSaleshdr.SetRange("Package Tracking No.", doctype);
                IF recSalesHdr.findfirst then
                    Error('Sales Contract No. already exist: ' + ContractNos);
        */


        L_Qty := 1;

        /******************************************************/
        /*** Commerical Invoice Header Section (Commerical) ***/
        /******************************************************/


        if booNotFirstLine = false then begin

            //Message('header');

            if SalesSetup.GET then
                DocNo := NoSeriesMgt.GetNextNo(SalesSetup."Invoice Nos.", Today, true);

            Clear(recSalesHdr);
            recSalesHdr.Init();
            recSalesHdr."Document Type" := recSalesHdr."Document Type"::Invoice;

            recSalesHdr."No." := DocNo;
            recSalesHdr."Posting Date" := Today;
            recSalesHdr.Insert(true);

            recSalesHdr.Validate("Sell-to Customer No.", recCustomer."No.");
            recSalesHdr.Validate("External Document No.", ContractNos);
            recSalesHdr.Validate("Document Date", DocDate);

            if GLSetup.get then;
            If (curr <> '') and (curr <> GLSetup."LCY Code") then recSalesHdr.Validate("Currency Code", curr);

            recSalesHdr.Validate("Your Reference", PNNO);
            recSalesHdr.Validate("Sell-to Address", CustAddress);
            //recSalesHdr.Validate("Package Tracking No.", );

            if PNNO = '' then ERROR('PN No. is empty');


            //if StrPos(PNNO, '/') <> 0 then begin


            //end;
            recDimVal.Reset();
            if not recDimVal.Get('PNNO', PNNO) then begin
                recDimVal.Reset();
                recDimVal.Init();
                recDimVal."Dimension Code" := 'PNNO';
                recDimVal.Validate(code, PNNO);
                recDimVal.Insert();
            end;

            intNewDimID := 0;
            intNewDimID := CreateDimensions4('PNNO', PNNO, 0);

            If intNewDimID <> 0 then begin
                recSalesHdr.Validate("Dimension Set ID", intNewDimID);
            end;

            recSalesHdr.Modify(true);


            if Doctype.Trim() <> '' then begin
                recSalesCommLine.Reset();
                recSalesCommLine.Init();
                recSalesCommLine.Validate("Document Type", recSalesHdr."Document Type"::Invoice);
                recSalesCommLine.Validate("No.", recSalesHdr."No.");
                recSalesCommLine.Validate("Line No.", GetlastSalesCommentLineNo(recSalesHdr) + 10000);
                recSalesCommLine.Validate("Document Line No.", 0);
                recSalesCommLine.Validate("Date", DocDate);
                recSalesCommLine.Validate("Comment", 'DOC TYPE: ' + CopyStr(Doctype, 1, 80 - StrLen('DOC TYPE: ')));
                recSalesCommLine.Insert();
            end;

            if Vessel.Trim() <> '' then begin
                recSalesCommLine.Reset();
                recSalesCommLine.Init();
                recSalesCommLine.Validate("Document Type", recSalesHdr."Document Type"::Invoice);
                recSalesCommLine.Validate("No.", recSalesHdr."No.");
                recSalesCommLine.Validate("Line No.", GetlastSalesCommentLineNo(recSalesHdr) + 10000);
                recSalesCommLine.Validate("Document Line No.", 0);
                recSalesCommLine.Validate("Date", DocDate);
                recSalesCommLine.Validate("Comment", 'VESSEL: ' + CopyStr(Vessel, 1, 80 - StrLen('VESSEL: ')));
                recSalesCommLine.Insert();
            end;

            if Commodities.Trim() <> '' then begin
                recSalesCommLine.Reset();
                recSalesCommLine.Init();
                recSalesCommLine.Validate("Document Type", recSalesHdr."Document Type"::Invoice);
                recSalesCommLine.Validate("No.", recSalesHdr."No.");
                recSalesCommLine.Validate("Line No.", GetlastSalesCommentLineNo(recSalesHdr) + 10000);
                recSalesCommLine.Validate("Document Line No.", 0);
                recSalesCommLine.Validate("Date", DocDate);
                recSalesCommLine.Validate("Comment", 'COMMODITY: ' + CopyStr(Commodities, 1, 80 - StrLen('COMMODITY: ')));
                recSalesCommLine.Insert();
            end;

            if Spec.Trim() <> '' then begin
                recSalesCommLine.Reset();
                recSalesCommLine.Init();
                recSalesCommLine.Validate("Document Type", recSalesHdr."Document Type"::Invoice);
                recSalesCommLine.Validate("No.", recSalesHdr."No.");
                recSalesCommLine.Validate("Line No.", GetlastSalesCommentLineNo(recSalesHdr) + 10000);
                recSalesCommLine.Validate("Document Line No.", 0);
                recSalesCommLine.Validate("Date", DocDate);
                recSalesCommLine.Validate("Comment", 'SPECIFICATION: ' + CopyStr(Spec, 1, 80 - StrLen('SPECIFICATION: ')));
                recSalesCommLine.Insert();
            end;

            if ActualWeights.Trim() <> '' then begin
                recSalesCommLine.Reset();
                recSalesCommLine.Init();
                recSalesCommLine.Validate("Document Type", recSalesHdr."Document Type"::Invoice);
                recSalesCommLine.Validate("No.", recSalesHdr."No.");
                recSalesCommLine.Validate("Line No.", GetlastSalesCommentLineNo(recSalesHdr) + 10000);
                recSalesCommLine.Validate("Document Line No.", 0);
                recSalesCommLine.Validate("Date", DocDate);
                recSalesCommLine.Validate("Comment", 'ACTUAL WEIGHT: ' + CopyStr(ActualWeights, 1, 80 - StrLen('ACTUAL WEIGHT: ')));
                recSalesCommLine.Insert();
            end;

            if ShippedGoodValue100P <> 0 then begin
                recSalesCommLine.Reset();
                recSalesCommLine.Init();
                recSalesCommLine.Validate("Document Type", recSalesHdr."Document Type"::Invoice);
                recSalesCommLine.Validate("No.", recSalesHdr."No.");
                recSalesCommLine.Validate("Line No.", GetlastSalesCommentLineNo(recSalesHdr) + 10000);
                recSalesCommLine.Validate("Document Line No.", 0);
                recSalesCommLine.Validate("Date", DocDate);
                recSalesCommLine.Validate("Comment", '100% SHIPPED GOODS VALUE: ' + CopyStr(FORMAT(ShippedGoodValue100P), 1, 80 - StrLen('100% SHIPPED GOODS VALUE: ')));
                recSalesCommLine.Insert();
            end;

            if ShippedGoodValue95P <> 0 then begin
                recSalesCommLine.Reset();
                recSalesCommLine.Init();
                recSalesCommLine.Validate("Document Type", recSalesHdr."Document Type"::Invoice);
                recSalesCommLine.Validate("No.", recSalesHdr."No.");
                recSalesCommLine.Validate("Line No.", GetlastSalesCommentLineNo(recSalesHdr) + 10000);
                recSalesCommLine.Validate("Document Line No.", 0);
                recSalesCommLine.Validate("Date", DocDate);
                recSalesCommLine.Validate("Comment", '95% SHIPPED GOODS VALUE: ' + CopyStr(FORMAT(ShippedGoodValue95P), 1, 80 - StrLen('95% SHIPPED GOODS VALUE: ')));
                recSalesCommLine.Insert();
            end;

            if PriceTerms.Trim() <> '' then begin
                recSalesCommLine.Reset();
                recSalesCommLine.Init();
                recSalesCommLine.Validate("Document Type", recSalesHdr."Document Type"::Invoice);
                recSalesCommLine.Validate("No.", recSalesHdr."No.");
                recSalesCommLine.Validate("Line No.", GetlastSalesCommentLineNo(recSalesHdr) + 10000);
                recSalesCommLine.Validate("Document Line No.", 0);
                recSalesCommLine.Validate("Date", DocDate);
                recSalesCommLine.Validate("Comment", 'Price Term: ' + CopyStr(FORMAT(PriceTerms), 1, 80 - StrLen('Price Term: ')));
                recSalesCommLine.Insert();
            end;

            if FInalAmt <> 0 then begin
                recSalesCommLine.Reset();
                recSalesCommLine.Init();
                recSalesCommLine.Validate("Document Type", recSalesHdr."Document Type"::Invoice);
                recSalesCommLine.Validate("No.", recSalesHdr."No.");
                recSalesCommLine.Validate("Line No.", GetlastSalesCommentLineNo(recSalesHdr) + 10000);
                recSalesCommLine.Validate("Document Line No.", 0);
                recSalesCommLine.Validate("Date", DocDate);
                recSalesCommLine.Validate("Comment", 'Price Term: ' + CopyStr(FORMAT(PriceTerms), 1, 80 - StrLen('Price Term: ')));
                recSalesCommLine.Insert();
            end;

            if FinalCommInvValue100P <> 0 then begin
                recSalesCommLine.Reset();
                recSalesCommLine.Init();
                recSalesCommLine.Validate("Document Type", recSalesHdr."Document Type"::Invoice);
                recSalesCommLine.Validate("No.", recSalesHdr."No.");
                recSalesCommLine.Validate("Line No.", GetlastSalesCommentLineNo(recSalesHdr) + 10000);
                recSalesCommLine.Validate("Document Line No.", 0);
                recSalesCommLine.Validate("Date", DocDate);
                recSalesCommLine.Validate("Comment", '100% FINAL COMM. INVOICE VALUE: ' + CopyStr(FORMAT(FinalCommInvValue100P), 1, 80 - StrLen('100% FINAL COMM. INVOICE VALUE: ')));
                recSalesCommLine.Insert();
            end;

            booNotFirstLine := true;

        end;

        /****************************************************/
        /*** Commerical Invoice Line Section (Commerical) ***/
        /****************************************************/

        if CheckString(Doctype).Trim() = 'Provisional Commercial Invoice' then begin

            Clear(Price95p);
            Price95p := ShippedGoodValue95P / DryWrights;

            CLEAR(recSalesLine);
            recSalesLine.Init();
            recSalesLine."Document Type" := recSalesLine."Document Type"::Invoice;
            recSalesLine."Document No." := DocNo;
            recSalesLine."Line No." := 10000;
            recSalesLine.Insert(true);
            recSalesLine.type := recSalesLine.type::" ";
            recSalesLine.Description := Doctype;
            recSalesLine.Modify(true);

            CLEAR(recSalesLine);
            recSalesLine.Init();
            recSalesLine."Document Type" := recSalesLine."Document Type"::Invoice;
            recSalesLine."Document No." := DocNo;
            recSalesLine."Line No." := 20000;
            recSalesLine.Insert(true);
            recSalesLine.type := recSalesLine.type::" ";
            recSalesLine.Description := 'Dryweight: ' + Format(DryWrights) + ', Provis. Price: ' + Format(ProvisPrice) + ' , 100% Shipped Value: ' + Format(ShippedGoodValue100P);
            recSalesLine.Modify(true);

            recSalesLine.Init();
            recSalesLine."Document Type" := recSalesLine."Document Type"::Invoice;
            recSalesLine."Document No." := DocNo;
            recSalesLine."Line No." := 30000;
            recSalesLine.Insert(true);
            recSalesLine.type := recSalesLine.type::"G/L Account";

            if recCustomer."Scanning GL Acc" = '' then Error('Customer ' + recCustomer.Name + ' missing value in Scanning G/L Accoount.');

            recGLAcc.Reset();
            recGLAcc.SetRange("No.", recCustomer."Scanning GL Acc");
            If recGLAcc.FindFirst() then begin
                if recGLAcc."Gen. Posting Type" = recGLAcc."Gen. Posting Type"::" " then Error('G/L Account ' + Format(recCustomer."Scanning GL Acc") + ' missing value in Gen. Posting Type.');
                if recGLAcc."Gen. Prod. Posting Group" = '' then Error('G/L Account' + Format(recCustomer."Scanning GL Acc") + ' missing value in Gen. Prod. Posting Group..');
                recSalesLine.Validate("No.", recCustomer."Scanning GL Acc");
            end else
                Error('Customer ' + recCustomer.Name + ' with Scanning G/L Account no. ' + recCustomer."Scanning GL Acc" + ' not found in Chart of Account.');

            recSalesLine.Validate(Description, '95% SHIPPED GOODS VALUE');
            recSalesLine.Validate(Quantity, DryWrights);
            recSalesLine.Validate("Unit Price", Price95p);
            recSalesLine.Modify(true);
        end else
            if CheckString(Doctype).Trim() = 'Final Commercial Invoice' then begin

                Clear(Price95p);
                Price95p := ShippedGoodValue95P / DryWrights;

                CLEAR(recSalesLine);
                recSalesLine.Init();
                recSalesLine."Document Type" := recSalesLine."Document Type"::Invoice;
                recSalesLine."Document No." := DocNo;
                recSalesLine."Line No." := 10000;
                recSalesLine.Insert(true);
                recSalesLine.type := recSalesLine.type::" ";
                recSalesLine.Description := Doctype;
                recSalesLine.Modify(true);

                CLEAR(recSalesLine);
                recSalesLine.Init();
                recSalesLine."Document Type" := recSalesLine."Document Type"::Invoice;
                recSalesLine."Document No." := DocNo;
                recSalesLine."Line No." := 20000;
                recSalesLine.Insert(true);
                recSalesLine.type := recSalesLine.type::" ";
                recSalesLine.Description := '100 PCT OF FINAL COMMERCIAL INVOICE VALUE: ' + Format(FinalCommInvValue100P);
                recSalesLine.Modify(true);

                CLEAR(recSalesLine);
                recSalesLine.Init();
                recSalesLine."Document Type" := recSalesLine."Document Type"::Invoice;
                recSalesLine."Document No." := DocNo;
                recSalesLine."Line No." := 30000;
                recSalesLine.Insert(true);
                recSalesLine.type := recSalesLine.type::" ";
                recSalesLine.Description := '95 PCT OF THE SHIPPED GOODS VALUE: ' + Format(ShippedGoodValue95P);
                recSalesLine.Modify(true);

                recSalesLine.Init();
                recSalesLine."Document Type" := recSalesLine."Document Type"::Invoice;
                recSalesLine."Document No." := DocNo;
                recSalesLine."Line No." := 40000;
                recSalesLine.Insert(true);
                recSalesLine.type := recSalesLine.type::"G/L Account";

                if recCustomer."Scanning GL Acc" = '' then Error('Customer ' + recCustomer.Name + ' missing value in Scanning G/L Accoount.');

                recGLAcc.Reset();
                recGLAcc.SetRange("No.", recCustomer."Scanning GL Acc");
                If recGLAcc.FindFirst() then begin
                    if recGLAcc."Gen. Posting Type" = recGLAcc."Gen. Posting Type"::" " then Error('G/L Account ' + Format(recCustomer."Scanning GL Acc") + ' missing value in Gen. Posting Type.');
                    if recGLAcc."Gen. Prod. Posting Group" = '' then Error('G/L Account' + Format(recCustomer."Scanning GL Acc") + ' missing value in Gen. Prod. Posting Group..');
                    recSalesLine.Validate("No.", recCustomer."Scanning GL Acc");
                end else
                    Error('Customer ' + recCustomer.Name + ' with Scanning G/L Account no. ' + recCustomer."Scanning GL Acc" + ' not found in Chart of Account.');

                recSalesLine.Validate(Description, 'FINAL AMOUNT DUE');
                recSalesLine.Validate(Quantity, DryWrights);
                recSalesLine.Validate("Unit Price", FInalAmt / DryWrights);
                recSalesLine.Modify(true);
            end;


    end;


    procedure GetlastPurCommentLineNo(recPurHdr: Record "Purchase Header") PurCommLineNo: integer
    var
        recPurCommLine2: Record "Purch. Comment Line";
    begin
        Clear(recPurCommLine2);
        recPurCommLine2.SetRange("Document Type", recPurHdr."Document Type"::Invoice);
        recPurCommLine2.SetRange("No.", recPurHdr."No.");
        recPurCommLine2.SetCurrentKey("Line No.");
        if recPurCommLine2.FindLast() then
            PurCommLineNo := recPurCommLine2."Line No."
        else
            PurCommLineNo := 0;
    end;


    procedure GetlastSalesCommentLineNo(recSalesHdr: Record "Sales Header") SalesCommLineNo: integer
    var
        recSalesCommLine2: Record "Sales Comment Line";
    begin
        Clear(recSalesCommLine2);
        recSalesCommLine2.SetRange("Document Type", recSalesHdr."Document Type"::Invoice);
        recSalesCommLine2.SetRange("No.", recSalesHdr."No.");
        recSalesCommLine2.SetCurrentKey("Line No.");
        if recSalesCommLine2.FindLast() then
            SalesCommLineNo := recSalesCommLine2."Line No."
        else
            SalesCommLineNo := 0;
    end;

    procedure CheckString(InStr: Text[500]) NewString: Text[500]
    var
        tempStr: text[500];
        tempLen: Integer;
    begin
        tempStr := InStr.Trim();
        tempLen := StrLen(tempStr);
        if instr = '""' then
            NewString := ''
        else
            if tempLen <= 2 then
                NewString := ''
            else
                if (CopyStr(InStr, 1, 1) = '"') and (CopyStr(InStr, tempLen, 1) = '"') then
                    NewString := CopyStr(InStr, 2, templen - 2)
                else
                    NewString := InStr;
    end;


    local procedure CreateDimensions4(DimensionCode: Code[20]; DimensionSetValue: Code[20]; DimensionSetID: Integer): Integer
    var
        DimSetEntry1: Record "Dimension Set Entry";
        recDimSet: Record "Dimension Set Entry" temporary;
        DimSetEntry: Record "Dimension Set Entry";
        DM: Codeunit DimensionManagement;
        dimSetID: Integer;
        dimSetIDn: Integer;
        TryV: Integer;
    begin
        dimSetID := 0;
        recDimSet.RESET();
        IF recDimSet.FINDSET() THEN
            recDimSet.DELETEALL();
        recDimSet.RESET();
        recDimSet.INIT();
        recDimSet.VALIDATE(recDimSet."Dimension Code", DimensionCode);
        recDimSet.VALIDATE(recDimSet."Dimension Value Code", DimensionSetValue);
        recDimSet.INSERT();
        if DimensionSetID = 0 then begin
            dimSetIDn := 0;
            dimSetIDn := DM.GetDimensionSetID(recDimSet);
            exit(dimSetIDn);
        end
    end;
}