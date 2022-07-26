table 50145 "Car Brand"
{
    DataClassification = CustomerContent;
    Caption = 'Car Brand';

    fields
    {
        field(1; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(2; Description; text[100])
        {
            Caption = 'Description';
        }
        field(3; Country; Text[100])
        {
            Caption = 'Country';
        }
        field(4; FildID; code[1000])
        {
            Caption = 'FildID';
        }
        field(5; FildID2; code[1000])
        {
            Caption = 'FildID2';
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