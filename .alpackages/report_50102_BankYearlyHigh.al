report 50102 BankYearlyHigh
{
    Caption = 'Bank Account Balance Summary (Yearly)';
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
                ExcelBuffer.AddColumn('Bank Account Balance Summary (Yearly)', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('Asia Steel & Metals Limited', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('For the year of ' + Format(intYear), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                ExcelBuffer.NewRow();

            end;

            trigger OnAfterGetRecord()
            begin

                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn(BankAcc1.Name, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(BankAcc1."Bank Account No.", false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

                if BankAcc1."Currency Code" <> '' then
                    codCurr := BankAcc1."Currency Code"
                else
                    codCurr := recGLSetup."LCY Code";

                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('Highest Balance (' + codCurr + ')', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('Record Date', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('Ending Balance (' + codCurr + ')', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);


                /**********************/
                /***       JAN      ***/
                /**********************/

                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('JAN', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                FirstDayofMonth := DMY2DATE(1, 1, intYear);
                LastDayofMonth := CalcDate('CM', FirstDayofMonth);
                If Today >= FirstDayofMonth then begin
                    TempDate := FirstDayofMonth;
                    decHighestAmt := 0;

                    while TempDate <= LastDayofMonth do begin
                        decTempAmt := 0;
                        recBankAcc_2.Reset();
                        recBankAcc_2.SetRange("No.", BankAcc1."No.");
                        recBankAcc_2.SetRange("Date Filter", 0D, TempDate);
                        If recBankAcc_2.FindFirst() then recBankAcc_2.CalcFields("Balance at Date");
                        decTempAmt := recBankAcc_2."Balance at Date";
                        if decHighestAmt = 0 then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;
                        If decTempAmt > decHighestAmt then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;

                        //if BankAcc1."No." = 'B0012' then message(format(TempDate) + ' - ' + Format(decTempAmt) + ' - ' + Format(decHighestAmt));

                        TempDate := CALCDATE('1D', TempDate);
                    end;

                    recBankAcc_3.Reset();
                    recBankAcc_3.SetRange("No.", BankAcc1."No.");
                    recBankAcc_3.SetRange("Date Filter", 0D, LastDayofMonth);
                    If recBankAcc_3.FindFirst() then recBankAcc_3.CalcFields("Balance at Date");
                    decMonthEndAmt := recBankAcc_3."Balance at Date";

                    ExcelBuffer.AddColumn(Format(decHighestAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(HighestDate), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(decMonthEndAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;


                /**********************/
                /***       FEB      ***/
                /**********************/

                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('FEB', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                FirstDayofMonth := DMY2DATE(1, 2, intYear);
                LastDayofMonth := CalcDate('CM', FirstDayofMonth);
                If Today >= FirstDayofMonth then begin
                    TempDate := FirstDayofMonth;
                    decHighestAmt := 0;

                    while TempDate <= LastDayofMonth do begin
                        decTempAmt := 0;
                        recBankAcc_2.Reset();
                        recBankAcc_2.SetRange("No.", BankAcc1."No.");
                        recBankAcc_2.SetRange("Date Filter", 0D, TempDate);
                        If recBankAcc_2.FindFirst() then recBankAcc_2.CalcFields("Balance at Date");
                        decTempAmt := recBankAcc_2."Balance at Date";
                        if decHighestAmt = 0 then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;
                        If decTempAmt > decHighestAmt then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;

                        //if BankAcc1."No." = 'B0012' then message(format(TempDate) + ' - ' + Format(decTempAmt) + ' - ' + Format(decHighestAmt));

                        TempDate := CALCDATE('1D', TempDate);
                    end;

                    recBankAcc_3.Reset();
                    recBankAcc_3.SetRange("No.", BankAcc1."No.");
                    recBankAcc_3.SetRange("Date Filter", 0D, LastDayofMonth);
                    If recBankAcc_3.FindFirst() then recBankAcc_3.CalcFields("Balance at Date");
                    decMonthEndAmt := recBankAcc_3."Balance at Date";

                    ExcelBuffer.AddColumn(Format(decHighestAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(HighestDate), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(decMonthEndAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;


                /**********************/
                /***       MAR      ***/
                /**********************/

                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('MAR', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                FirstDayofMonth := DMY2DATE(1, 3, intYear);
                LastDayofMonth := CalcDate('CM', FirstDayofMonth);
                If Today >= FirstDayofMonth then begin
                    TempDate := FirstDayofMonth;
                    decHighestAmt := 0;

                    while TempDate <= LastDayofMonth do begin
                        decTempAmt := 0;
                        recBankAcc_2.Reset();
                        recBankAcc_2.SetRange("No.", BankAcc1."No.");
                        recBankAcc_2.SetRange("Date Filter", 0D, TempDate);
                        If recBankAcc_2.FindFirst() then recBankAcc_2.CalcFields("Balance at Date");
                        decTempAmt := recBankAcc_2."Balance at Date";
                        if decHighestAmt = 0 then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;
                        If decTempAmt > decHighestAmt then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;

                        //if BankAcc1."No." = 'B0012' then message(format(TempDate) + ' - ' + Format(decTempAmt) + ' - ' + Format(decHighestAmt));

                        TempDate := CALCDATE('1D', TempDate);
                    end;

                    recBankAcc_3.Reset();
                    recBankAcc_3.SetRange("No.", BankAcc1."No.");
                    recBankAcc_3.SetRange("Date Filter", 0D, LastDayofMonth);
                    If recBankAcc_3.FindFirst() then recBankAcc_3.CalcFields("Balance at Date");
                    decMonthEndAmt := recBankAcc_3."Balance at Date";

                    ExcelBuffer.AddColumn(Format(decHighestAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(HighestDate), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(decMonthEndAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;


                /**********************/
                /***       APR      ***/
                /**********************/


                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('APR', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                FirstDayofMonth := DMY2DATE(1, 4, intYear);
                LastDayofMonth := CalcDate('CM', FirstDayofMonth);
                If Today >= FirstDayofMonth then begin
                    TempDate := FirstDayofMonth;
                    decHighestAmt := 0;

                    while TempDate <= LastDayofMonth do begin
                        decTempAmt := 0;
                        recBankAcc_2.Reset();
                        recBankAcc_2.SetRange("No.", BankAcc1."No.");
                        recBankAcc_2.SetRange("Date Filter", 0D, TempDate);
                        If recBankAcc_2.FindFirst() then recBankAcc_2.CalcFields("Balance at Date");
                        decTempAmt := recBankAcc_2."Balance at Date";
                        if decHighestAmt = 0 then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;
                        If decTempAmt > decHighestAmt then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;

                        //if BankAcc1."No." = 'B0012' then message(format(TempDate) + ' - ' + Format(decTempAmt) + ' - ' + Format(decHighestAmt));

                        TempDate := CALCDATE('1D', TempDate);
                    end;

                    recBankAcc_3.Reset();
                    recBankAcc_3.SetRange("No.", BankAcc1."No.");
                    recBankAcc_3.SetRange("Date Filter", 0D, LastDayofMonth);
                    If recBankAcc_3.FindFirst() then recBankAcc_3.CalcFields("Balance at Date");
                    decMonthEndAmt := recBankAcc_3."Balance at Date";

                    ExcelBuffer.AddColumn(Format(decHighestAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(HighestDate), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(decMonthEndAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;



                /**********************/
                /***       MAY      ***/
                /**********************/

                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('MAY', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                FirstDayofMonth := DMY2DATE(1, 5, intYear);
                LastDayofMonth := CalcDate('CM', FirstDayofMonth);
                If Today >= FirstDayofMonth then begin
                    TempDate := FirstDayofMonth;
                    decHighestAmt := 0;

                    while TempDate <= LastDayofMonth do begin
                        decTempAmt := 0;
                        recBankAcc_2.Reset();
                        recBankAcc_2.SetRange("No.", BankAcc1."No.");
                        recBankAcc_2.SetRange("Date Filter", 0D, TempDate);
                        If recBankAcc_2.FindFirst() then recBankAcc_2.CalcFields("Balance at Date");
                        decTempAmt := recBankAcc_2."Balance at Date";
                        if decHighestAmt = 0 then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;
                        If decTempAmt > decHighestAmt then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;

                        //if BankAcc1."No." = 'B0012' then message(format(TempDate) + ' - ' + Format(decTempAmt) + ' - ' + Format(decHighestAmt));

                        TempDate := CALCDATE('1D', TempDate);
                    end;

                    recBankAcc_3.Reset();
                    recBankAcc_3.SetRange("No.", BankAcc1."No.");
                    recBankAcc_3.SetRange("Date Filter", 0D, LastDayofMonth);
                    If recBankAcc_3.FindFirst() then recBankAcc_3.CalcFields("Balance at Date");
                    decMonthEndAmt := recBankAcc_3."Balance at Date";

                    ExcelBuffer.AddColumn(Format(decHighestAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(HighestDate), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(decMonthEndAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;


                /**********************/
                /***       JUN      ***/
                /**********************/

                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('JUN', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                FirstDayofMonth := DMY2DATE(1, 6, intYear);
                LastDayofMonth := CalcDate('CM', FirstDayofMonth);
                If Today >= FirstDayofMonth then begin
                    TempDate := FirstDayofMonth;
                    decHighestAmt := 0;

                    while TempDate <= LastDayofMonth do begin
                        decTempAmt := 0;
                        recBankAcc_2.Reset();
                        recBankAcc_2.SetRange("No.", BankAcc1."No.");
                        recBankAcc_2.SetRange("Date Filter", 0D, TempDate);
                        If recBankAcc_2.FindFirst() then recBankAcc_2.CalcFields("Balance at Date");
                        decTempAmt := recBankAcc_2."Balance at Date";
                        if decHighestAmt = 0 then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;
                        If decTempAmt > decHighestAmt then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;

                        //if BankAcc1."No." = 'B0012' then message(format(TempDate) + ' - ' + Format(decTempAmt) + ' - ' + Format(decHighestAmt));

                        TempDate := CALCDATE('1D', TempDate);
                    end;

                    recBankAcc_3.Reset();
                    recBankAcc_3.SetRange("No.", BankAcc1."No.");
                    recBankAcc_3.SetRange("Date Filter", 0D, LastDayofMonth);
                    If recBankAcc_3.FindFirst() then recBankAcc_3.CalcFields("Balance at Date");
                    decMonthEndAmt := recBankAcc_3."Balance at Date";

                    ExcelBuffer.AddColumn(Format(decHighestAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(HighestDate), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(decMonthEndAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;


                /**********************/
                /***       JUL      ***/
                /**********************/

                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('JUL', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                FirstDayofMonth := DMY2DATE(1, 7, intYear);
                LastDayofMonth := CalcDate('CM', FirstDayofMonth);
                If Today >= FirstDayofMonth then begin
                    TempDate := FirstDayofMonth;
                    decHighestAmt := 0;

                    while TempDate <= LastDayofMonth do begin
                        decTempAmt := 0;
                        recBankAcc_2.Reset();
                        recBankAcc_2.SetRange("No.", BankAcc1."No.");
                        recBankAcc_2.SetRange("Date Filter", 0D, TempDate);
                        If recBankAcc_2.FindFirst() then recBankAcc_2.CalcFields("Balance at Date");
                        decTempAmt := recBankAcc_2."Balance at Date";
                        if decHighestAmt = 0 then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;
                        If decTempAmt > decHighestAmt then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;

                        //if BankAcc1."No." = 'B0012' then message(format(TempDate) + ' - ' + Format(decTempAmt) + ' - ' + Format(decHighestAmt));

                        TempDate := CALCDATE('1D', TempDate);
                    end;

                    recBankAcc_3.Reset();
                    recBankAcc_3.SetRange("No.", BankAcc1."No.");
                    recBankAcc_3.SetRange("Date Filter", 0D, LastDayofMonth);
                    If recBankAcc_3.FindFirst() then recBankAcc_3.CalcFields("Balance at Date");
                    decMonthEndAmt := recBankAcc_3."Balance at Date";

                    ExcelBuffer.AddColumn(Format(decHighestAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(HighestDate), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(decMonthEndAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;


                /**********************/
                /***       AUG      ***/
                /**********************/

                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('AUG', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                FirstDayofMonth := DMY2DATE(1, 8, intYear);
                LastDayofMonth := CalcDate('CM', FirstDayofMonth);
                If Today >= FirstDayofMonth then begin
                    TempDate := FirstDayofMonth;
                    decHighestAmt := 0;

                    while TempDate <= LastDayofMonth do begin
                        decTempAmt := 0;
                        recBankAcc_2.Reset();
                        recBankAcc_2.SetRange("No.", BankAcc1."No.");
                        recBankAcc_2.SetRange("Date Filter", 0D, TempDate);
                        If recBankAcc_2.FindFirst() then recBankAcc_2.CalcFields("Balance at Date");
                        decTempAmt := recBankAcc_2."Balance at Date";
                        if decHighestAmt = 0 then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;
                        If decTempAmt > decHighestAmt then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;

                        //if BankAcc1."No." = 'B0012' then message(format(TempDate) + ' - ' + Format(decTempAmt) + ' - ' + Format(decHighestAmt));

                        TempDate := CALCDATE('1D', TempDate);
                    end;

                    recBankAcc_3.Reset();
                    recBankAcc_3.SetRange("No.", BankAcc1."No.");
                    recBankAcc_3.SetRange("Date Filter", 0D, LastDayofMonth);
                    If recBankAcc_3.FindFirst() then recBankAcc_3.CalcFields("Balance at Date");
                    decMonthEndAmt := recBankAcc_3."Balance at Date";

                    ExcelBuffer.AddColumn(Format(decHighestAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(HighestDate), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(decMonthEndAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;


                /**********************/
                /***       SEP      ***/
                /**********************/

                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('SEP', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                FirstDayofMonth := DMY2DATE(1, 9, intYear);
                LastDayofMonth := CalcDate('CM', FirstDayofMonth);
                If Today >= FirstDayofMonth then begin
                    TempDate := FirstDayofMonth;
                    decHighestAmt := 0;

                    while TempDate <= LastDayofMonth do begin
                        decTempAmt := 0;
                        recBankAcc_2.Reset();
                        recBankAcc_2.SetRange("No.", BankAcc1."No.");
                        recBankAcc_2.SetRange("Date Filter", 0D, TempDate);
                        If recBankAcc_2.FindFirst() then recBankAcc_2.CalcFields("Balance at Date");
                        decTempAmt := recBankAcc_2."Balance at Date";
                        if decHighestAmt = 0 then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;
                        If decTempAmt > decHighestAmt then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;

                        //if BankAcc1."No." = 'B0012' then message(format(TempDate) + ' - ' + Format(decTempAmt) + ' - ' + Format(decHighestAmt));

                        TempDate := CALCDATE('1D', TempDate);
                    end;

                    recBankAcc_3.Reset();
                    recBankAcc_3.SetRange("No.", BankAcc1."No.");
                    recBankAcc_3.SetRange("Date Filter", 0D, LastDayofMonth);
                    If recBankAcc_3.FindFirst() then recBankAcc_3.CalcFields("Balance at Date");
                    decMonthEndAmt := recBankAcc_3."Balance at Date";

                    ExcelBuffer.AddColumn(Format(decHighestAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(HighestDate), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(decMonthEndAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;


                /**********************/
                /***       OCT      ***/
                /**********************/

                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('OCT', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                FirstDayofMonth := DMY2DATE(1, 10, intYear);
                LastDayofMonth := CalcDate('CM', FirstDayofMonth);
                If Today >= FirstDayofMonth then begin
                    TempDate := FirstDayofMonth;
                    decHighestAmt := 0;

                    while TempDate <= LastDayofMonth do begin
                        decTempAmt := 0;
                        recBankAcc_2.Reset();
                        recBankAcc_2.SetRange("No.", BankAcc1."No.");
                        recBankAcc_2.SetRange("Date Filter", 0D, TempDate);
                        If recBankAcc_2.FindFirst() then recBankAcc_2.CalcFields("Balance at Date");
                        decTempAmt := recBankAcc_2."Balance at Date";
                        if decHighestAmt = 0 then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;
                        If decTempAmt > decHighestAmt then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;

                        //if BankAcc1."No." = 'B0012' then message(format(TempDate) + ' - ' + Format(decTempAmt) + ' - ' + Format(decHighestAmt));

                        TempDate := CALCDATE('1D', TempDate);
                    end;

                    recBankAcc_3.Reset();
                    recBankAcc_3.SetRange("No.", BankAcc1."No.");
                    recBankAcc_3.SetRange("Date Filter", 0D, LastDayofMonth);
                    If recBankAcc_3.FindFirst() then recBankAcc_3.CalcFields("Balance at Date");
                    decMonthEndAmt := recBankAcc_3."Balance at Date";

                    ExcelBuffer.AddColumn(Format(decHighestAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(HighestDate), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(decMonthEndAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;



                /**********************/
                /***       NOV      ***/
                /**********************/

                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('NOV', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                FirstDayofMonth := DMY2DATE(1, 11, intYear);
                LastDayofMonth := CalcDate('CM', FirstDayofMonth);
                If Today >= FirstDayofMonth then begin
                    TempDate := FirstDayofMonth;
                    decHighestAmt := 0;

                    while TempDate <= LastDayofMonth do begin
                        decTempAmt := 0;
                        recBankAcc_2.Reset();
                        recBankAcc_2.SetRange("No.", BankAcc1."No.");
                        recBankAcc_2.SetRange("Date Filter", 0D, TempDate);
                        If recBankAcc_2.FindFirst() then recBankAcc_2.CalcFields("Balance at Date");
                        decTempAmt := recBankAcc_2."Balance at Date";
                        if decHighestAmt = 0 then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;
                        If decTempAmt > decHighestAmt then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;

                        //if BankAcc1."No." = 'B0012' then message(format(TempDate) + ' - ' + Format(decTempAmt) + ' - ' + Format(decHighestAmt));

                        TempDate := CALCDATE('1D', TempDate);
                    end;

                    recBankAcc_3.Reset();
                    recBankAcc_3.SetRange("No.", BankAcc1."No.");
                    recBankAcc_3.SetRange("Date Filter", 0D, LastDayofMonth);
                    If recBankAcc_3.FindFirst() then recBankAcc_3.CalcFields("Balance at Date");
                    decMonthEndAmt := recBankAcc_3."Balance at Date";

                    ExcelBuffer.AddColumn(Format(decHighestAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(HighestDate), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(decMonthEndAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;



                /**********************/
                /***       DEC      ***/
                /**********************/

                ExcelBuffer.NewRow();
                ExcelBuffer.AddColumn('DEC', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                FirstDayofMonth := DMY2DATE(1, 12, intYear);
                LastDayofMonth := CalcDate('CM', FirstDayofMonth);
                If Today >= FirstDayofMonth then begin
                    TempDate := FirstDayofMonth;
                    decHighestAmt := 0;

                    while TempDate <= LastDayofMonth do begin
                        decTempAmt := 0;
                        recBankAcc_2.Reset();
                        recBankAcc_2.SetRange("No.", BankAcc1."No.");
                        recBankAcc_2.SetRange("Date Filter", 0D, TempDate);
                        If recBankAcc_2.FindFirst() then recBankAcc_2.CalcFields("Balance at Date");
                        decTempAmt := recBankAcc_2."Balance at Date";
                        if decHighestAmt = 0 then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;
                        If decTempAmt > decHighestAmt then begin
                            decHighestAmt := decTempAmt;
                            HighestDate := TempDate;
                        end;

                        //if BankAcc1."No." = 'B0012' then message(format(TempDate) + ' - ' + Format(decTempAmt) + ' - ' + Format(decHighestAmt));

                        TempDate := CALCDATE('1D', TempDate);
                    end;

                    recBankAcc_3.Reset();
                    recBankAcc_3.SetRange("No.", BankAcc1."No.");
                    recBankAcc_3.SetRange("Date Filter", 0D, LastDayofMonth);
                    If recBankAcc_3.FindFirst() then recBankAcc_3.CalcFields("Balance at Date");
                    decMonthEndAmt := recBankAcc_3."Balance at Date";

                    ExcelBuffer.AddColumn(Format(decHighestAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(HighestDate), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(Format(decMonthEndAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;


                ExcelBuffer.NewRow();
                ExcelBuffer.NewRow();


                /*
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
                    decExRate := decHighestAmt / decHighestAmtLCY
                else
                    decExrate := 0;

                ExcelBuffer.AddColumn(format(decHighestAmt, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(format(decExRate, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(format(decHighestAmtLCY, 0), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                */
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
                        Caption = 'Select a date within required Year.';
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
            intYear := DATE2DMY(SelectDate, 3)

        end else begin
            Error('A date must be select to define the Year.')
        end;
    end;


    trigger OnPostReport()
    begin
        ExcelBuffer.CreateNewBook('Banks Monthly highest Amount');
        ExcelBuffer.WriteSheet('Banks Monthly highest Amount', CompanyName, UserId);
        ExcelBuffer.CloseBook();
        excelbuffer.OpenExcel();
    end;


    var
        recBankAcc: Record "Bank Account";
        recBankAcc_2: Record "Bank Account";
        recBankAcc_3: Record "Bank Account";
        ExcelBuffer: Record "Excel Buffer" temporary;
        recGLSetup: Record "General Ledger Setup";
        decHighestAmt: Decimal;

        decTempAmt: Decimal;
        SelectDate: date;
        FirstDayofMonth: date;
        LastDayofMonth: Date;
        TempDate: Date;
        HighestDate: Date;
        decExRate: Decimal;
        codCurr: code[3];
        intYear: Integer;

        decMonthEndAmt: Decimal;
}