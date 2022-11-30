/* @author: Alex Hoffman
 * @authorEmail: hoffman@amendllc.com
 * @Description: Send Case Email Test Class. Create test data and publish line item platform event. Assert that an email was created related to the test case.
 * @Created Date: 12/20/21
 * @Revision Notes: 
 */
@isTest
public class ConvertLeadTest {
    Static testMethod void MyTestFunction(){
        
        //Create Lead test data
        
        List<Lead> testLeads = New List<Lead>();
        for(Integer i=0; i<5; i++){
            Lead l = New Lead();
            l.FirstName = 'Alex';
            l.LastName  = 'Hoffman' + i;
            l.Email     = 'hoffman' + i + '@amendllc.com';
            l.Company   = 'AMEND LLC';
            testLeads.add(l);
        }
        insert testLeads;
        
        //Create Contact test data
        
        List<Contact> testContacts = New List<Contact>();
        for(Integer i=0; i<5; i++){
            Contact c  = New Contact();
            c.LastName = 'Hoffman' + i;
            c.Email    = 'hoffman' + i + '@amendllc.com';
            testContacts.add(c);
        }
        insert testContacts;
        
        //Check if all 5 leads converted to all 5 contacts
        
        List<Lead> convertedLeads = New List<Lead>([Select Id from Lead Where isconverted = TRUE]);
        system.assertEquals(5, convertedLeads.size());
    }

}