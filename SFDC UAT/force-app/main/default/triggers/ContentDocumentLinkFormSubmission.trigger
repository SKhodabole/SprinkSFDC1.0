/* @author: Alex Hoffman
 * @authorEmail: hoffman@amendllc.com
 * @Description: Contact Us Gravity Forms integration on sprink.com websites send customer file attachments to Form_Submission__c record. This trigger creates a new
 * contentdocumentlink for the resulting Case.
 * @Created Date: 1/27/22
 * @Revision Notes: 1/28/22 Check Attached Form File checkbox on Case
 */

trigger ContentDocumentLinkFormSubmission on ContentDocumentLink (after insert) {
    //Create new list of contentdocumentlinks and cases
    List<ContentDocumentLink> newFormSubmissionDocs = new List<ContentDocumentLink>();
    List<Case> casesToUpdate = new List<Case>();
    //Loop over contentdocumentlinks in trigger.new.
    for(ContentDocumentLink newFile : trigger.new){
        Id sId             = newFile.LinkedEntityId;
        //Get sObject Name of the linkedEntity. Check if the object type is form submission. Only want to create new contentdocumentlinks for form
        //submissions.
        String sobjectType = sId.getSObjectType().getDescribe().getName();
        system.debug('Object type is '+sobjectType+' for id '+sId);
        
        If(sobjectType == 'Form_Submission__c'){
            //Find Case resulting from Form Submission Processor flow
            Case matchingCase;
            matchingCase = [Select Id from Case where Form_Submission__c = :sId LIMIT 1];
            system.debug('Related Case Id is ' + matchingCase.Id);
            
            //Create new contentdocumentlink that is related to the Case. Assign checkbox value as true on case.
            If(matchingCase != NULL){
                matchingCase.Attached_Form_File__c = True;
                ContentDocumentLink newFormFile    = new ContentDocumentLink();
            	newFormFile.LinkedEntityId         = matchingCase.Id;
                newFormFile.ContentDocumentId      = newFile.ContentDocumentId;
                newFormSubmissionDocs.add(newFormFile);
                casesToUpdate.add(matchingCase);
                system.debug('ContentDocumentLinks to create are '+ newFormSubmissionDocs);
            }
            
        }
    }
    //Update Cases
    If(casesToUpdate.size() > 0){
        update casesToUpdate;
    }
    //Insert new contentdocumentlinks.
    If(newFormSubmissionDocs.size() > 0){
        insert newFormSubmissionDocs;
    }

}