/* @author: Alex Hoffman
 * @authorEmail: hoffman@amendllc.com
 * @Description: Convert lead from Lead_Convert__c record collection variable from flow
 * @Created Date: 01/19/2022
 * @Revision Notes: 
 */
global class ConvertLead {
   @InvocableMethod(label='Convert Lead')
    global static void convertLeads (List<List<Lead_Convert__c>> leadConvertPassedRecords){
        List<database.LeadConvert> databaseLeadConverts = new List<database.LeadConvert>();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        for(List<Lead_Convert__c> ll : leadConvertPassedRecords){
            for(Lead_Convert__c l : ll){
                IF(l.setAccountId__c != NULL && l.setContactId__c != NULL && l.setLeadId__c != NULL){
                    database.LeadConvert loopDatabaseLeadConvert = new database.LeadConvert();
                    loopDatabaseLeadConvert.setAccountId(l.setAccountId__c);
                    loopDatabaseLeadConvert.setContactId(l.setContactId__c);
                    loopDatabaseLeadConvert.setLeadId(l.setLeadId__c);
                    loopDatabaseLeadConvert.donotcreateopportunity = TRUE;
                    loopDatabaseLeadConvert.setconvertedstatus(convertStatus.Masterlabel);
                    databaseLeadConverts.add(loopDatabaseLeadConvert);
            	}
            }
        }
        If(databaseLeadConverts.size()>0){
            Database.convertlead(databaseLeadConverts);
        }
    }
    
}