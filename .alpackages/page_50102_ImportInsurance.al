page 50103 ImportInsurance
{


    PageType = API;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Item;

    EntityCaption = 'ImportInsurance';
    EntitySetCaption = 'ImportInsurance';
    EntityName = 'ImportInsurance';
    EntitySetName = 'ImportInsurance';

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
                //field(Name; NameSource)
                //{
                //    ApplicationArea = All;
                //}
            }
        }
    }


    var
        myInt: Integer;
}