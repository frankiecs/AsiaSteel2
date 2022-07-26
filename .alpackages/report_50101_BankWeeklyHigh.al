report 50101 BankWeeklyHigh
{
    Caption = 'Export Excel for Banks Weekly highest Amount';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = true;


    dataset
    {
        dataitem(BankAcc1; "Bank Account")
        {
            trigger OnPreDataItem()
            begin
                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('Bank Balance - Weekly', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('Report Date from ' + format(FirstDayofWeek) + ' to ' + format(LastDayofWeek), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.NewRow();

                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('BANK', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('Original Currency', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('Amount', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('A/C Ex Rate', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('USD Eqv.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
            end;

            trigger OnAfterGetRecord()
            begin
                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn(BankAcc1.Name, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                if BankAcc1."Currency Code" <> '' then
                    codCurr := BankAcc1."Currency Code"
                else
                    codCurr := recGLSetup."LCY Code";

                ExcelBuffer.AddColumn(codCurr, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                TempDate := FirstDayofWeek;
                decHighestAmtLCY := 0;

                while TempDate <= LastDayofWeek do begin
                    decTempAmt := 0;
                    recBankAcc_2.Reset();
                    recBankAcc_2.SetRange("No.", BankAcc1."No.");
                    recBankAcc_2.SetRange("Date Filter", 0D, TempDate);
                    If recBankAcc_2.FindFirst() then recBankAcc_2.CalcFields("Balance at Date (LCY)");
                    decTempAmt := recBankAcc_2."Balance at Date (LCY)";
                    if decHighestAmtLCY = 0 then begin
                        decHighestAmtLCY := decTempAmt;
                        HighestDate := TempDate;
                    end;
                    If decTempAmt > decHighestAmtLCY then begin
                        decHighestAmtLCY := decTempAmt;
                        HighestDate := TempDate;
                    end;
                    TempDate := CALCDATE('1D', TempDate);
                end;

                recBankAcc_2.Reset();
                recBankAcc_2.SetRange("No.", BankAcc1."No.");
                recBankAcc_2.SetRange("Date Filter", 0D, HighestDate);
                if recBankAcc_2.FindFirst() then recBankAcc_2.CalcFields("Balance at Date");
                decHighestAmt := recBankAcc_2."Balance at Date";

                if decHighestAmtLCY <> 0 then
                    decExRate := decHighestAmtLCY / decHighestAmt
                else
                    decExrate := 0;

                ExcelBuffer.AddColumn(format(decHighestAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(format(decExRate, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(format(decHighestAmtLCY, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(SelectDate; SelectDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Select a date within required week.';
                    }
                }
            }
        }
    }
    /*
        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;
                    
                }
            }
        }
    }
    */


    trigger OnInitReport()
    begin
        ExcelBuffer.reset;
        ExcelBuffer.DeleteAll();
        if recGLSetup.FindFirst() then;
    end;


    trigger OnPreReport()
    begin
        if SelectDate <> 0D then begin
            FirstDayofWeek := CalcDate('<-CW>', SelectDate);
            LastDayofWeek := CalcDate('<CW>', SelectDate);
        end else begin
            Error('A date must be select to define the week.')
        end;
    end;


    trigger OnPostReport()
    begin
        ExcelBuffer.CreateNewBook('Banks Weekly highest Amount');
        ExcelBuffer.WriteSheet('Banks Weekly highest Amount', CompanyName, UserId);
        ExcelBuffer.CloseBook();
        excelbuffer.OpenExcel();
    end;


    var
        recBankAcc: Record "Bank Account";
        recBankAcc_2: Record "Bank Account";
        ExcelBuffer: Record "Excel Buffer" temporary;
        recGLSetup: Record "General Ledger Setup";
        decHighestAmt: Decimal;
        decHighestAmtLCY: Decimal;
        decTempAmt: Decimal;
        SelectDate: date;
        FirstDayofWeek: date;
        LastDayofWeek: Date;
        TempDate: Date;
        HighestDate: Date;
        decExRate: Decimal;
        codCurr: code[3];
}