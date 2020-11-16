public with sharing class creditLinePopulated implements 
        Database.Batchable<sObject> {

    public Database.QueryLocator start (Database.BatchableContext bc) {
        
        return Database.getQueryLocator (
            'Select Id, StageName, Name '+
            'From Opportunity '+
            'Where (CreatedBy.UserRole.DeveloperName = \'Starter_Rep\' And '+ 
                  ' Account.Parent.Credit_Line__c <> Null)              Or '+
                  '(CreatedBy.UserRole.DeveloperName = \'Seller_Rep\'  And '+
                  ' Account.Credit_Line__c <> Null)'
        );
    }
    
    public void execute (Database.BatchableContext bc, List <Opportunity> scope) {
        
        for (Opportunity x: scope) {
            
            x.StageName = 'Implementation';
        } 
        try {        
            update scope;            
        } catch (DmlException e) {             
            System.debug('ERROR! ' + e.getMessage());
        }
    }
    
    public void finish (Database.BatchableContext bc) {
               
    }
}
