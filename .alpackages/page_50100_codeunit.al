page 50100 PageCodeunit
{
    PageType = API;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Item;

    EntityCaption = 'PageCodeUnit';
    EntitySetCaption = 'PageCodeUnit';
    EntityName = 'PageCodeUnit';
    EntitySetName = 'PageCodeUnit';

    APIVersion = 'v1.0';
    APIPublisher = 'bctech';
    APIGroup = 'demo';

    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Name; CompanyName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;


}


