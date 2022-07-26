page 50146 "PreDelete"
{

    PageType = API;

    APIVersion = 'v1.0';
    APIPublisher = 'bctech';
    APIGroup = 'demo';

    EntityCaption = 'PreDelete';
    EntitySetCaption = 'PreDelete';
    EntityName = 'PreDelete';
    EntitySetName = 'PreDelete';

    ODataKeyFields = SystemId;
    SourceTable = PreDelete;

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

                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(FildID; rec.FildID)
                {
                    Caption = 'File ID';
                }
            }
        }
    }


    trigger OnOpenPage()
    var
        recHeaderBuffer: Record "Header Buffer";
    begin
        recHeaderBuffer.Reset();
        //recHeaderBuffer.DeleteAll();
        //rec.DeleteAll();
    end;
}