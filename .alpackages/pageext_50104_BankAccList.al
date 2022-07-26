pageextension 50104 BankAccListExt extends "Bank Account List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter("Receivables-Payables")
        {
            action(ExportToExcel)
            {
                Caption = 'Bank Weekly Highest Amount Report';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Image = Excel;

                trigger OnAction()
                var
                    ExportData: Report BankWeeklyHigh;
                begin
                    if rec.findset then
                        ExportData.Run();
                end;
            }

            action(ExportToExcels)
            {
                Caption = 'Bank Account Balance Summary';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Image = Excel;

                trigger OnAction()
                var
                    ExportData: Report BankYearlyHigh;
                begin
                    if rec.findset then
                        ExportData.Run();
                end;
            }




        }
        // Add changes to page actions here
    }

    var
        myInt: Integer;

        BalAtDateLcy: Decimal;
        EndDay: date;

        TempDate: date;
        InputDate: date;

    trigger OnOpenPage();
    begin
        /*
                recBankAcc.Reset();
                recBankAcc.SetRange("No.", 'B0001');

                recBankAcc.SetRange("Date Filter", 0D, 20220101D);
                if recBankAcc.FindFirst() then begin
                    recBankAcc.CalcFields("Balance at Date (LCY)");
                    message('a: ' + format(recBankAcc."Balance at Date (LCY)"));
                end;

                InputDate := Today;

                TempDate := CALCDATE('<-CW>', InputDate);

                While TempDate <= CALCDATE('<CW>', InputDate) do begin
                    Message(format(TempDate));
                    TempDate := CALCDATE('1D', TempDate);
                end;

                //Message(format(CALCDATE('<-CW>', Today)));      //First day of week (Monday)

                //Message(format(CALCDATE('<-CW> + 1D', Today)));      //First day of week (Monday)

                //Message(format(CALCDATE('<CW>', Today)));       //Last day of week (Sunday)

                //recBankAcc.SetRange("Date Filter", 0D, Today);
                //if recBankAcc.CalcFields("Balance at Date (LCY)") then Message(format(recBankAcc."Balance at Date (LCY)"));
        */
    end;

    /*
        local procedure ExportExcelBankWeeklyHigh(var BankAccRec: Record "Bank Account")
        var
            TempExcelBuffer: Record "Excel Buffer" temporary;
            CustLedgerEntriesLbl: Label 'Customer Ledger Entries';
            ExcelFileName: Label 'CustomerLedgerEntries_%1_%2';

            recBankAcc: Record "Bank Account";
            recBankAcc_2: Record "Bank Account";

        begin
            BankAccRec.Reset();
            BankAccRec.SetCurrentKey(Name);
            If BankAccRec.FindSet() then begin
                repeat

                until BankAccRec.next = 0;
            end;
        end;
    */
}