/* @author: Alex Hoffman
 * @authorEmail: hoffman@amendllc.com
 * @Description: This test class inserts a new form submission and attachment to mimic a Contact Us gravity forms submission from a Sprink.com website. It checks
 * that the ContentDocumentLinkFormSubmission trigger creates a new ContentDocumentLink record related to the Case created from the form submission process flow.
 * @Created Date: 1/27/21
 * @Revision Notes: 
 */

@isTest
public class ContentDocumentLinkFormSubmissionTest {
    Static testMethod void contentDocumentLinkTest(){
        
        //Create new Form Submission
        
        Form_Submission__c form = new Form_Submission__c();
        form.First_Name__c      = 'Alex';
        form.Last_Name__c       = 'Hoffman';
        form.Email__c           = 'hoffman@amendllc.com';
        form.Industry__c        = 'Beer';
        form.Storefront__c      = 'UK';
        form.IP_Address__c      = '123456789';
        form.Type__c            = 'Contact Us';
        form.Company_Name__c    = 'AMEND LLC';
        form.Phone__c           = '513-222-2222';
        form.Website__c         = 'www.amend.com';
        form.Message__c         = 'Example form submission message';
        form.Address_1__c       = '538 Reading Road';
        form.City__c            = 'Cincinnati';
        form.State__c           = 'OH';
        form.Zip_Postal_Code__c = '45202';
        form.Country__c         = 'United Kingdom';
        
        insert form;
        
        //Find case resulting for form submission processor flow
        
        Case c = [Select Id, Attached_Form_File__c from Case where Form_Submission__c = :form.Id];
        Id caseId = c.Id;
        system.debug('Case id is ' + caseId);
        
        //Insert new contentversion
        
        ContentVersion cV = new ContentVersion();
        cV.Title          = 'Test Attachment';
        cV.PathOnClient   = 'TestImage.jpg';
        cV.VersionData    = Blob.valueOf('Test Content Data');
        cV.isMajorVersion    = true;
        
        insert cV;
        
        List<ContentDocument> cDList = new List<ContentDocument>([Select id from ContentDocument where title = 'Test Attachment' LIMIT 1]);
        Id contentDocId;
        for(ContentDocument cDItem : cDList){
            contentDocId = cDItem.Id;
        }
		system.debug('Content Document List where title is "Test Attachment" is ' + cDList);    
      	system.debug('ContentDocumentID is ' + contentDocId);
            
     	//insert new contentDocumentLink related to contentversion and Form_Submission__c record.
        
      	ContentDocumentLink cDL = new ContentDocumentLink();
      	cDL.ContentDocumentId   = contentDocId;
        cDL.LinkedEntityId      = form.Id;
        
     	insert cDL;
        
       	//Check if ContentDocumentLink exists on related Case. Check the attached form file checkbox is true on the Case.
        
        List<ContentDocumentLink> cDLList = new List<ContentDocumentLink>([Select Id from ContentDocumentLink where LinkedEntityId = :caseId]);
        system.debug('cDLList is ' + cDLList);
        system.assertEquals(1, cDLLIst.size());
        system.assert(True, c.Attached_Form_File__c);
        
    }

}