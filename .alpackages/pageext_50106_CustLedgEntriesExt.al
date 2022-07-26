pageextension 50106 CustLedgEntriesExt extends "Customer Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter("F&unctions")
        {
            action(ExportToExcel)
            {
                Caption = 'Export to Excel';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Export;

                trigger OnAction()
                var
                begin
                    ExportCustLedgerEntries(Rec);
                end;
            }
        }
    }

    local procedure ExportCustLedgerEntries(var CustLedgEntriesRec: Record "Cust. Ledger Entry")
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        CustLedgerEntriesLbl: Label 'Customer Ledger Entries';
        ExcelFileName: Label 'CustomerLedgerEntries_%1_%2';
    begin
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();

        //Add Header
        TempExcelBuffer.NewRow();
        tempexcelbuffer.AddColumn(CustLedgEntriesRec.FieldCaption("Entry No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        tempexcelbuffer.AddColumn(CustLedgEntriesRec.FieldCaption("Posting Date"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        tempexcelbuffer.AddColumn(CustLedgEntriesRec.FieldCaption("Document Type"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        tempexcelbuffer.AddColumn(CustLedgEntriesRec.FieldCaption("Document No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        tempexcelbuffer.AddColumn(CustLedgEntriesRec.FieldCaption("Customer No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        tempexcelbuffer.AddColumn(CustLedgEntriesRec.FieldCaption("Customer Name"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        tempexcelbuffer.AddColumn(CustLedgEntriesRec.FieldCaption(Description), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        tempexcelbuffer.AddColumn(CustLedgEntriesRec.FieldCaption("Currency Code"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        tempexcelbuffer.AddColumn(CustLedgEntriesRec.FieldCaption("Original Amount"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        tempexcelbuffer.AddColumn(CustLedgEntriesRec.FieldCaption(Amount), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        tempexcelbuffer.AddColumn(CustLedgEntriesRec.FieldCaption("Amount (LCY)"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        tempexcelbuffer.AddColumn(CustLedgEntriesRec.FieldCaption("Remaining Amount"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        tempexcelbuffer.AddColumn(CustLedgEntriesRec.FieldCaption("Remaining Amt. (LCY)"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        tempexcelbuffer.AddColumn(CustLedgEntriesRec.FieldCaption(Open), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        //Add Excel Report Line
        if CustLedgEntriesRec.FindSet() then
            repeat
                TempExcelBuffer.NewRow();
                tempexcelbuffer.AddColumn(CustLedgEntriesRec."Entry No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                tempexcelbuffer.AddColumn(CustLedgEntriesRec."Posting Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                tempexcelbuffer.AddColumn(CustLedgEntriesRec."Document Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                tempexcelbuffer.AddColumn(CustLedgEntriesRec."Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                tempexcelbuffer.AddColumn(CustLedgEntriesRec."Customer No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                tempexcelbuffer.AddColumn(CustLedgEntriesRec."Customer Name", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                tempexcelbuffer.AddColumn(CustLedgEntriesRec.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                tempexcelbuffer.AddColumn(CustLedgEntriesRec."Currency Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                tempexcelbuffer.AddColumn(CustLedgEntriesRec."Original Amount", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                tempexcelbuffer.AddColumn(CustLedgEntriesRec.Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                tempexcelbuffer.AddColumn(CustLedgEntriesRec."Amount (LCY)", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                tempexcelbuffer.AddColumn(CustLedgEntriesRec."Remaining Amount", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                tempexcelbuffer.AddColumn(CustLedgEntriesRec."Remaining Amt. (LCY)", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                tempexcelbuffer.AddColumn(CustLedgEntriesRec.Open, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

            until CustLedgEntriesRec.next = 0;

        //Generate Excel Report
        TempExcelBuffer.CreateNewBook(CustLedgerEntriesLbl);
        TempExcelBuffer.WriteSheet(CustLedgerEntriesLbl, CompanyName, UserId);
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.SetFriendlyFilename(strSubstNo(ExcelFileName, CurrentDateTime, UserId));
        TempExcelBuffer.OpenExcel();

    end;

}