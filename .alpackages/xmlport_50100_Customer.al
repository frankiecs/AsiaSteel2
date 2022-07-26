xmlport 50100 "Import Customer"
{

    Caption = 'Create Customer';


    UseDefaultNamespace = true;
    Direction = Both;
    Format = Xml;


    /*
    UseRequestPage = false;
    DefaultFieldsValidation = true;
    UseDefaultNamespace = true;
    FormatEvaluate = Xml;
    Direction = Both;
    DefaultNamespace = 'urn:microsoft-dynamics/Customer';
    */
    /*
    Direction = Import;
    TextEncoding = UTF8;
    Format = VariableText;
    */
    schema
    {
        textelement(CreateCustomer)
        {
            tableelement(Cust; Customer)
            {
                //MaxOccurs = Once;
                //MinOccurs = Zero;
                //XmlName = 'RatingData';         
                fieldattribute(CustNo; Cust."No.") { }
                fieldattribute(CustName; Cust.Name) { }

                //trigger OnBeforeInsertRecord()
                //begin
                //end;

            }

        }
    }
}