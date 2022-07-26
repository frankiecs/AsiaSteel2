table 50103 "Stage Table"
{
    //DataClassification = CustomerContent;
    Caption = 'Header Buffer';

    fields
    {
        field(1; F001; Text[100])
        {
            Caption = 'F001';
        }
        field(2; F002; Text[100])
        {
            Caption = 'F002';
        }
        field(3; F003; Text[100])
        {
            Caption = 'F003';
        }
        field(4; F004; Text[100])
        {
            Caption = 'F004';
        }
        field(5; F005; Text[100])
        {
            Caption = 'F005';
        }
        field(6; F006; Text[100])
        {
            Caption = 'F006';
        }
        field(7; F007; Text[100])
        {
            Caption = 'F007';
        }
        field(8; F008; Text[100])
        {
            Caption = 'F008';
        }
        field(9; F009; Text[100])
        {
            Caption = 'F009';
        }
        field(10; F010; Text[100])
        {
            Caption = 'F010';
        }
        field(11; F011; Text[100])
        {
            Caption = 'F011';
        }
        field(12; F012; Text[100])
        {
            Caption = 'F012';
        }
        field(13; F013; Text[100])
        {
            Caption = 'F013';
        }
        field(14; F014; Text[100])
        {
            Caption = 'F014';
        }
        field(15; F015; Text[100])
        {
            Caption = 'F015';
        }
        field(16; F016; Text[100])
        {
            Caption = 'F016';
        }
        field(17; F017; Text[100])
        {
            Caption = 'F017';
        }
        field(18; F018; Text[100])
        {
            Caption = 'F018';
        }
        field(19; F019; Text[100])
        {
            Caption = 'F019';
        }
        field(20; F020; Text[100])
        {
            Caption = 'F020';
        }
        field(21; F021; Text[100])
        {
            Caption = 'F021';
        }
        field(22; F022; Text[100])
        {
            Caption = 'F022';
        }
        field(23; F023; Text[100])
        {
            Caption = 'F023';
        }
        field(24; F024; Text[100])
        {
            Caption = 'F024';
        }
        field(25; F025; Text[100])
        {
            Caption = 'F025';
        }
        field(26; F026; Text[100])
        {
            Caption = 'F026';
        }
        field(27; F027; Text[100])
        {
            Caption = 'F027';
        }
        field(28; F028; Text[100])
        {
            Caption = 'F028';
        }
        field(29; F029; Text[100])
        {
            Caption = 'F029';
        }
        field(30; F030; Text[100])
        {
            Caption = 'F030';
        }

        field(31; F031; Text[100])
        {
            Caption = 'F031';
        }

        field(32; F032; Text[100])
        {
            Caption = 'F032';
        }
        field(33; F033; Text[100])
        {
            Caption = 'F033';
        }

        field(34; F034; Text[100])
        {
            Caption = 'F034';
        }
        field(35; F035; Text[100])
        {
            Caption = 'F035';
        }

        field(900; F900; Text[500])
        {
            Caption = 'F900';
        }
        field(997; F997; Code[50])
        {
            Caption = 'F997';
        }
        field(998; F998; Code[20])
        {
            Caption = 'F998';
        }
        field(999; F999; Decimal)
        {
            Caption = 'F999';
        }
        field(1000; DocTypeCode; Code[3])
        {
            Caption = 'Doc type code';
        }
        field(1001; FileId; Code[1000])
        {
            Caption = 'File ID';
        }
        field(1002; Processed; Boolean)
        {
            Caption = 'Processed';
        }
        field(1003; KeyField; BigInteger)
        {
            Caption = 'KeyField';
            AutoIncrement = true;
        }
    }

    keys
    {
        key(PK; KeyField)
        {
            Clustered = true;
        }
    }
}