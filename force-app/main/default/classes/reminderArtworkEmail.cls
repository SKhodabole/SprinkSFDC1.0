global class reminderArtworkEmail implements Database.Batchable<sObject> {
     global Database.QueryLocator start( Database.BatchableContext context ) {
        // collect the batches of records or objects to be passed to execute
           String query = 'SELECT ID,WordPress_Order_ID__c,Storefront_Phone__c,Case__c,Customer_First_Name__c,Domain__c,Name,Customer_Name__c,Language__c,Storefront__c,Artwork_Bounced__c,Artwork_Resubmitted__c From Opportunity WHERE Artwork_Bounced__c <> NULL AND Artwork_Resubmitted__c = Null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> lstOpportunity){
         List<Messaging.SingleEmailMessage> lstEmail = new List<Messaging.SingleEmailMessage>();
        // process each batch of records
        if(!lstOpportunity.isempty()){
             EmailTemplate et = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName =: 'Artwork_Reminder_Email_english'];
            for(Opportunity objOppo :lstOpportunity){
                String templateId;
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(et.Id);
                  //  mail.setToAddresses(toAddress);
                  //  mail.setSubject(et.subject);
                   // mail.setHTMLBody(et.Body);
                    mail.setTargetObjectId(objOppo.Customer_Name__c);
                    mail.setWhatId(objOppo.Case__c);
                    mail.setSaveAsActivity(false);
                    mail.setUseSignature(false);
            lstEmail.add(mail);
        }
        if(!lstEmail.isempty() && !Test.isRunningTest()){ 
        Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmail);
        
 if (results[0].success)
 {
   System.debug('The email was sent successfully.');
 }
 else
 {
   System.debug('The email failed to send:'  +
   results[0].errors[0].message);
 }
    }    
        }}
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}