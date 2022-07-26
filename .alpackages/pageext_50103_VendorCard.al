pageextension 50103 VendCardExt extends "Vendor Card"
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