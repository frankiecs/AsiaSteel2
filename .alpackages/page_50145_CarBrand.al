page 50145 "API Car Brand"
{

    PageType = API;

    APIVersion = 'v1.0';
    APIPublisher = 'bctech';
    APIGroup = 'demo';

    EntityCaption = 'CarBrand';
    EntitySetCaption = 'CarBrands';
    EntityName = 'carBrand';
    EntitySetName = 'carBrands';

    ODataKeyFields = SystemId;
    SourceTable = "Car Brand";

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
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(country; Rec.Country)
                {
                    Caption = 'Country';
                }
                field(FildID; Rec.FildID)
                {
                    Caption = 'FildID';
                }
                field(FildID2; Rec.FildID2)
                {
                    Caption = 'FildID2';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        rec.Reset();
        rec.DeleteAll();
    end;


    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        recStageTable: Record "Stage Table";
        recPreDelete2: Record PreDelete;
        GenBCDocs: Codeunit GenBCDoc;
        ScanDoc: Code[20];
    begin
        //rec.Reset();
        //rec.DeleteAll();

        recPreDelete2.Reset();
        if recPreDelete2.FindFirst() then;

        recStageTable.Reset();
        recStageTable.SetRange(FileId, rec.FildID);
        if recStageTable.FindFirst() then;
        ScanDoc := recStageTable.DocTypeCode;
        Clear(recStageTable);

        //Error('ScanDoc: ' + Format(ScanDoc) + ' FileID: ' + Format(rec.FildID));

        IF ScanDoc = 'ADM' then GenBCDocs.GenAdmExp(rec.FildID);

        IF ScanDoc = 'BCA' then GenBCDocs.GenBCRADV(rec.FildID);

        IF ScanDoc = 'BDA' then GenBCDocs.GenBDRADV(rec.FildID);

        IF ScanDoc = 'INS' then GenBCDocs.GenInsExp(rec.FildID);

        IF ScanDoc = 'FGT' then GenBCDocs.GenFgtExp(rec.FildID);

        IF ScanDoc = 'ISP' then GenBCDocs.GenIspFee(rec.FildID);

        IF ScanDoc = 'SUP' then GenBCDocs.GenSupInv(rec.FildID);

        if ScanDoc = 'CIV' then GenBCDocs.GenComInv(rec.FildID);

    end;






}