/* @author: Alex Hoffman
* @authorEmail: hoffman@amendllc.com
* @Description: Send Case Email Class. Invocable variables used to send an email related to a Case record.
* @Created Date: 12/20/21
* @Revision Notes: 
*/
global class SendCaseEmail {
    @InvocableMethod(label='Send Case Email')
    //List caseEmailVariables contains Lists of emailInputs
    global static void caseEmail (List<caseEmailVariables> emailInputs){
        
        //Create new list of single email message sObject records
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
       
        //Loop through caseEmailVariables List
   
        for(caseEmailVariables singleCaseEmail : emailInputs){
            //Check if any required email values are Null
            if(singleCaseEmail.caseId != NULL && singleCaseEmail.emailBody != NULL && singleCaseEmail.emailSubject != NULL && singleCaseEmail.emailTo != NULL && singleCaseEmail.orgWideId != NULL){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if(singleCaseEmail.caseId <> Null) { 
                    mail.setWhatId(singleCaseEmail.caseId); }
                mail.setHtmlBody(singleCaseEmail.emailBody);
                mail.setSubject(singleCaseEmail.emailSubject);
                mail.setToAddresses(singleCaseEmail.emailTo);
                mail.setBccSender(false); 
                mail.setUseSignature(false); 
                if(singleCaseEmail.orgWideId <> Null){
                      mail.setOrgWideEmailAddressId(singleCaseEmail.orgWideId); 
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
       
        
    }
    
}