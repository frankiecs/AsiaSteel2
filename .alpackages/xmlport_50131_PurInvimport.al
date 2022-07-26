xmlport 50131 PurInvImport
{
    Format = VariableText;
    schema
    {
        textelement(root)
        {
            tableelement(GenJnlLine; "Gen. Journal Line")
            {
                textelement(PostingDate) { }
                textelement(AccountType) { }
                textelement(AccountNo) { }
                textelement(DocNo) { }
                textelement(ExtDocNo) { }
                textelement(Description) { }
                textelement(Amount) { }
                textelement(Dim1) { }
                textelement(Dim2) { }

                trigger OnBeforeInsertRecord()
                begin

                    myInt += 1;
                    //Message('inner Loop:' + Format(myInt));

                    EVALUATE(PostDate, PostingDate);
                    EVALUATE(AccType, AccountType);
                    EVALUATE(AccNo, AccountNo);
                    EVALUATE(DNo, DocNo);
                    EVALUATE(ExDNo, ExtDocNo);
                    EVALUATE(Desc, Description);
                    EVALUATE(Amt, Amount);
                    EVALUATE(D1, Dim1);
                    EVALUATE(D2, Dim2);

                    //GenJnlLine.Reset();
                    //GenJnlLine.SetRange("Journal Template Name", JournalTemplate);
                    //GenJnlLine.SetRange("Journal Batch Name", JournalBarch);
                    //LastLineNo := 0;
                    //if GenJnlLine.FindLast() then
                    //    LastLineNo := GenJnlLine."Line No.";

                    LastLineNo += 10000;

                    //GenJnlLine.Init();

                    GenJnlLine."Journal Template Name" := JournalTemplate;
                    GenJnlLine."Journal Batch Name" := JournalBarch;
                    GenJnlLine."Line No." := LastLineNo;

                    GenJnlLine.Validate("Posting Date", PostDate);
                    GenJnlLine.VALIDATE("Account Type", AccType);
                    GenJnlLine.validate("Account No.", AccNo);
                    GenJnlLine.Validate("Document No.", DNo);
                    GenJnlLine.Validate("External Document No.", ExDNo);
                    GenJnlLine.Validate(Description, Desc);
                    GenJnlLine.Validate(Amount, Amt);
                    GenJnlLine.validate("Shortcut Dimension 1 Code", D1);
                    GenJnlLine.Validate("Shortcut Dimension 2 Code", D2);
                    //Message('Inner LastLineNo BEFORE Insert:' + Format(GenJnlLine."Line No."));
                    //GenJnlLine.insert();
                    //Message('Inner LastLineNo Insert:' + Format(LastLineNo));
                end;
            }
        }
    }
    trigger OnPreXmlPort()
    begin
        GenJnlLine2.Reset();
        GenJnlLine2.SetRange("Journal Template Name", JournalTemplate);
        GenJnlLine2.SetRange("Journal Batch Name", JournalBarch);
        LastLineNo := 0;
        if GenJnlLine2.FindLast() then
            LastLineNo := GenJnlLine2."Line No.";

        GenJnlLine2.Reset;

        Message('Start:' + Format(LastLineNo));

    end;

    var
        myInt: Integer;

        GenJnlLine2: Record "Gen. Journal Line";

        JournalTemplate: Code[20];
        JournalBarch: Code[20];
        LastLineNo: Integer;
        PostDate: Date;
        AccType: option "G/L Account";
        AccNo: Code[20];
        DNo: Code[20];
        ExDNo: Code[35];
        Desc: Code[100];
        Amt: Decimal;
        D2: Code[20];
        D1: Code[20];






    procedure SetJournalTempalteBatch(template: Code[20]; batch: Code[20])
    begin
        JournalTemplate := template;
        JournalBarch := batch;
    end;
}