global class SendArtworkBounceCaseEmail {
     @InvocableMethod(label='Send ArtworkBounce Case Email')
    //List caseEmailVariables contains Lists of emailInputs
    global static void caseEmail (List<caseEmailVariables> emailInputs){
        System.debug('Attchent Checkbox :: '+emailInputs[0].AttchmentCheckbox);
        //Create new list of single email message sObject records
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> emailFileAttachments = new List<Messaging.EmailFileAttachment>(); 
        //Loop through caseEmailVariables List
        
        
        // To attach file to email -- Ticket 372
        Set<String> contentDocumentIds = new Set<String>(); 
        if(emailInputs[0].AttchmentCheckbox == true){
        List<ContentDocumentLink> cdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :emailInputs[0].caseId order by SystemModstamp  desc limit 1];
      
        for (ContentDocumentLink doc : cdls) { 
            contentDocumentIds.add(doc.ContentDocumentId); 
        }
        List<ContentVersion> contentVersionFile = [SELECT VersionData, Title, FileType FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds AND IsLatest = true]; 
        
        system.debug('contentVersionFile'+contentVersionFile);
        for (ContentVersion cv : contentVersionFile) { 
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment(); 
            efa.setFileName(cv.Title + '.' + cv.FileType); 
            efa.setBody(cv.VersionData); 
            emailFileAttachments.add(efa); 
        }
        }
        system.debug('emailFileAttachments'+emailFileAttachments);
        
            for(caseEmailVariables singleCaseEmail : emailInputs){
            //Check if any required email values are Null
            if(singleCaseEmail.caseId != NULL && singleCaseEmail.emailBody != NULL && singleCaseEmail.emailSubject != NULL && singleCaseEmail.emailTo != NULL && singleCaseEmail.orgWideId != NULL){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setWhatId(singleCaseEmail.caseId);
                mail.setHtmlBody(singleCaseEmail.emailBody);
                mail.setSubject(singleCaseEmail.emailSubject);
                mail.setToAddresses(singleCaseEmail.emailTo);
                mail.setBccSender(false); 
                mail.setUseSignature(false); 
                mail.setOrgWideEmailAddressId(singleCaseEmail.orgWideId);
                if (!emailFileAttachments.isEmpty()) { 
                 mail.setFileAttachments(emailFileAttachments); 
                }
                //Add email to List
                lstMsgs.add(mail);
            }
        }
           
           
         
        
        
        system.debug('lstMsgs'+lstMsgs);
        //Check if List contains emails. If not empty, send all Emails.
        if(lstMsgs.size() > 0) {
            Messaging.sendEmail(lstMsgs);}
    }
    //Define invocable variables available to populate from Flow
    global class caseEmailVariables{
        @InvocableVariable(label = 'Email Body' required=true)
        global String emailBody;
        @InvocableVariable(label = 'Email Subject' required=true)
        global String emailSubject;
        @InvocableVariable(label = 'Email To Address Collection' required=true)
        global List<String> emailTo;
        @InvocableVariable(label = 'Case Id' required=true)
        global String caseId;
        @InvocableVariable(label = 'Org Wide Address Id' required=true)
        global String orgWideId;
         @InvocableVariable(label = 'Attachment Checkbox' required=true)
        global boolean AttchmentCheckbox;
        
    }

}