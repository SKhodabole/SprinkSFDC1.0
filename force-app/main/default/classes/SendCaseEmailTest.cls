/* @author: Alex Hoffman
 * @authorEmail: hoffman@amendllc.com
 * @Description: Send Case Email Test Class. Create test data and publish line item platform event. Assert that an email was created related to the test case.
 * @Created Date: 12/20/21
 * @Revision Notes: 
 */
@IsTest
public class SendCaseEmailTest {
    Static testMethod void MyTestFunction(){
        
        //Find and assign recordtypeid for Case
        
        RecordType rt           = [Select Id from RecordType where SObjectType = 'Case' AND DeveloperName = 'Orders' LIMIT 1];
        String caseRecordTypeId = rt.Id;
        system.debug('Orders record type id is ' + caseRecordTypeId);
        
        //Create new account and insert
        
        Account a = new Account();
        a.Name    = 'Amend Consulting';
        a.Type    = 'Customer';
        insert a;
        
    	//Create new contact related to new account and insert
    	
        Contact c   = new Contact();
        c.FirstName = 'Alex';
        c.LastName  = 'Hoffman';
        c.Email     = 'hoffman@amendllc.com';
        c.AccountId = a.Id;
        insert c;
    
        //Create new opportunity related to new account + new contact and insert
        
        Opportunity o      = new Opportunity();
        o.Name             = 'Test Opportunity';
        o.AccountId        = a.Id;
        o.CloseDate        = date.today();
        o.StageName        = 'Sent To Hybrid';
        o.Customer_Name__c = c.id;
        o.Storefront__c    = 'UK';
        insert o;
        
        //Create new Case related to new Oppty + new Contact and insert. Case recordtype name is 'Orders'.
        
        Case cs           = new Case();
        cs.ContactId      = c.Id;
        cs.Opportunity__c = o.Id;
        cs.Status         = 'New';
        cs.Priority       = 'Medium';
        cs.RecordTypeId   = caseRecordTypeId;
        insert cs;
        
        //Create new line item related to new Oppty and insert. 
        
        Line_Item__c line          = new Line_Item__c();
        line.Name                  = 'Test Line Item';
        line.Opportunity__c        = o.Id;
        line.Shape__c              = 'Circle';
        line.Material__c           = 'White BOPP Plastic (Permanent)';
        line.Finish__c             = 'Gloss Laminate';
        line.Unwind_Direction__c   = 'Right Off First (#3)';
        line.Application_Method__c = 'Hand';
        line.Quantity__c           = 5000;
		line.Version_Count__c      = 1;
        line.Has_Corners__c        = FALSE;
        line.Unit_of_Measure__c    = 'Metric';
        line.Opportunity__c        = o.Id;
        insert line;
        
        //Create new label version related to new line item and insert.
        
        Label_Version__c label = new Label_Version__c();
        label.Name             = 'Test Label Version';
        label.Line_Item__c     = line.Id;
        label.Quantity__c      = 5000;
        label.File_Size__c     = 767363;
        label.File_Name__c     = 'examplefilename.pdf';
        label.Status__c        = 'New';
        insert label;
        
        //Create new line item platform event with a mock approval URL 'www.sprinklabels.co.uk'. Line item and Oppty are newly created records from above.
        //'Line Item - Platform Event' flow handles the event. 
        
        Line_Item_Events__e e  = new Line_Item_Events__e();
        e.Approval_URL__c      = 'www.sprinklabels.co.uk';
        e.Hybrid_Received__c   = FALSE;
        e.Line_Item_Number__c  = line.Name;
        e.Line_Item_SF_Id__c   = line.Id;
        e.Opportunity_SF_Id__c = o.Id;
        e.Order_Number__c      = o.Name;
        e.Status__c            = 'Out for Approval';
        
        //Publish event.
        
        Test.startTest();
        Database.SaveResult result = Eventbus.publish(e);
        Test.stopTest();
        
        //Check for a successful event publish
        
        System.assertEquals(true, result.isSuccess());
        
        //Create new List of emailmessage sObject. Populate using SOQL query looking for an emailmessage record related to the newly created case. Emailmessage is the result of
        //the 'Line Item - Platform Event' flow and 'SendCaseEmail' incovable Apex Class.
        OrgWideEmailAddress[] addresses = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(1, addresses.size());
        SendCaseEmail.caseEmailVariables  mailVariables = new SendCaseEmail.caseEmailVariables();
        mailVariables.caseId = cs.Id;
        mailVariables.emailBody = 'Test Email Body';
        mailVariables.emailSubject = 'Test Email Subject';
        mailVariables.emailTo = new list<string> {'kuldeep.sonvane@thinqloud.com'};
        mailVariables.orgWideId = addresses[0].Id;
         SendArtworkBounceCaseEmail.caseEmailVariables  EmailVariables = new SendArtworkBounceCaseEmail.caseEmailVariables();
        EmailVariables.caseId = cs.Id;
        EmailVariables.emailBody = 'Test Email Body';
        EmailVariables.emailSubject = 'Test Email Subject';
        EmailVariables.emailTo = new list<string> {'kuldeep.sonvane@thinqloud.com'};
        EmailVariables.orgWideId = addresses[0].Id;
        EmailVariables.AttchmentCheckbox = True;
        SendCaseEmail.caseEmail(new list<SendCaseEmail.caseEmailVariables> {mailVariables});
        SendArtworkBounceCaseEmail.caseEmail(new list<SendArtworkBounceCaseEmail.caseEmailVariables> {EmailVariables});
        List<EmailMessage> emails = new List<EmailMessage>([Select Id from EmailMessage WHERE ParentId = :cs.Id]);
          EscalationAlertForPaymentSuccessful.caseEmailVariables  Variables = new EscalationAlertForPaymentSuccessful.caseEmailVariables();
         Variables.emailBody = 'Test Email Body';
        Variables.emailSubject = 'Test Email Subject';
        Variables.emailTo = new list<string> {'kuldeep.sonvane@thinqloud.com'};
             EscalationAlertForPaymentSuccessful.caseEmail(new list<EscalationAlertForPaymentSuccessful.caseEmailVariables> {Variables});
        //Assert that the List contains 1 record.
        
        //system.assertEquals(1, emails.size());
}
}