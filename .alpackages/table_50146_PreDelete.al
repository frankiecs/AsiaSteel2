table 50146 "PreDelete"
{

    Caption = 'PreDelete';

    fields
    {
        field(1; Name; text[100])
        {
            Caption = 'Name';
        }
        field(2; FildID; code[50])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(PK; Name)
        {
            Clustered = true;
        }
    }
}