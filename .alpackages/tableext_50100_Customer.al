tableextension 50100 CustTblExt extends Customer
{
    fields
    {
        field(50100; "Scanning GL Acc"; code[20])
        {
            TableRelation = "G/L Account"."No.";
            Caption = 'Scanning G/L Account No.';
        }
    }

    var
        myInt: Integer;
}