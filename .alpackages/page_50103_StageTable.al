page 50102 "Stage Table"
{

    PageType = API;

    APIVersion = 'v1.0';
    APIPublisher = 'bctech';
    APIGroup = 'demo';

    EntityCaption = 'StageTable';
    EntitySetCaption = 'StageTable';
    EntityName = 'StageTable';
    EntitySetName = 'StageTable';

    ODataKeyFields = SystemId;
    SourceTable = "Stage Table";

    Extensible = false;
    DelayedInsert = true;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }

                field(F001; Rec.F001)
                {
                    Caption = 'F001';
                }
                field(F002; Rec.F002)
                {
                    Caption = 'F002';
                }
                field(F003; Rec.F003)
                {
                    Caption = 'F003';
                }
                field(F004; Rec.F004)
                {
                    Caption = 'F004';
                }
                field(F005; Rec.F005)
                {
                    Caption = 'F005';
                }
                field(F006; Rec.F006)
                {
                    Caption = 'F006';
                }
                field(F007; Rec.F007)
                {
                    Caption = 'F007';
                }
                field(F008; Rec.F008)
                {
                    Caption = 'F008';
                }
                field(F009; Rec.F009)
                {
                    Caption = 'F009';
                }
                field(F010; Rec.F010)
                {
                    Caption = 'F010';
                }
                field(F011; Rec.F011)
                {
                    Caption = 'F011';
                }
                field(F012; Rec.F012)
                {
                    Caption = 'F012';
                }


                field(F013; Rec.F013)
                {
                    Caption = 'F013';
                }
                field(F014; Rec.F014)
                {
                    Caption = 'F014';
                }
                field(F015; Rec.F015)
                {
                    Caption = 'F015';
                }
                field(F016; Rec.F016)
                {
                    Caption = 'F016';
                }
                field(F017; Rec.F017)
                {
                    Caption = 'F017';
                }
                field(F018; Rec.F018)
                {
                    Caption = 'F018';
                }
                field(F019; Rec.F019)
                {
                    Caption = 'F019';
                }
                field(F020; Rec.F020)
                {
                    Caption = 'F020';
                }
                field(F021; Rec.F021)
                {
                    Caption = 'F021';
                }
                field(F022; Rec.F022)
                {
                    Caption = 'F022';
                }
                field(F023; Rec.F023)
                {
                    Caption = 'F023';
                }
                field(F024; Rec.F024)
                {
                    Caption = 'F024';
                }
                field(F025; Rec.F025)
                {
                    Caption = 'F025';
                }
                field(F026; Rec.F026)
                {
                    Caption = 'F026';
                }
                field(F027; Rec.F027)
                {
                    Caption = 'F027';
                }
                field(F028; Rec.F028)
                {
                    Caption = 'F028';
                }
                field(F029; Rec.F029)
                {
                    Caption = 'F029';
                }
                field(F030; Rec.F030)
                {
                    Caption = 'F030';
                }

                field(F031; Rec.F031)
                {
                    Caption = 'F031';
                }

                field(F032; Rec.F032)
                {
                    Caption = 'F032';
                }

                field(F033; Rec.F033)
                {
                    Caption = 'F033';
                }


                field(F034; Rec.F034)
                {
                    Caption = 'F034';
                }

                field(F035; Rec.F035)
                {
                    Caption = 'F035';
                }

                field(F900; Rec.F900)
                {
                    Caption = 'F900';
                }
                field(F997; Rec.F997)
                {
                    Caption = 'F997';
                }
                field(F998; Rec.F998)
                {
                    Caption = 'F998';
                }
                field(F999; Rec.F999)
                {
                    Caption = 'F999';
                }
                field(DocTypeCode; rec.DocTypeCode)
                {
                    Caption = 'Doc type code';
                }
                field(FileId; rec.FileId)
                {
                    Caption = 'File ID';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        //rec.reset;
        //rec.DeleteAll();
    end;

}