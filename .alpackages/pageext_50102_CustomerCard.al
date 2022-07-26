pageextension 50102 CustCardExt extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("Scanning GL Acc"; "Scanning GL Acc")
            {
                ToolTip = 'G/L Account for Scanning';
                ApplicationArea = All;
            }
        }
    }
}