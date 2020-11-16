@isTest
public with sharing class creditLinePopulatedTest {

    @TestSetup
    static void makeData () { 
        
        List <UserRole> roles = [
            Select Id, DeveloperName 
            From UserRole 
            Where DeveloperName = 'Starter_Rep' Or
                  DeveloperName = 'Seller_Rep'
        ];                                  
        Map <String, Id> roleId = new Map <String, Id>();
        for(UserRole item: roles) {
            roleId.put(item.DeveloperName, item.Id);
        }
        Profile prof = [
            Select Id    
            From Profile 
            Where Name = 'System Administrator'
            Limit 1
        ];
        List <User> users = new List <User> ();
        for (integer i = 0; i < 2; i++) {
            users.add( new User ( 
                LastName = 'user', 
                Alias = 'user', 
                Email = 'laegmith@gmail.com',
                Username = 'creditLinePopulatedTest_user_'+ i +'@mith.ct3',
                CommunityNickname = 'user_ct3_a'+ i,
                ProfileId = prof.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
     		    EmailEncodingKey = 'UTF-8',
     		    LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US' ) 
            );
        }
        users[0].UserRoleId = roleId.get('Starter_Rep');
        users[1].UserRoleId = roleId.get('Seller_Rep');
        insert users;
    }

    @isTest
    public static void testBatch () {
     
        List <User> users = [
            Select Id, CommunityNickname
            From User
            Where UserName Like 'creditLinePopulatedTest%'
        ];
        if ( users[0].CommunityNickname.equals('user_ct3_a1') ) {

            User x   = users[0];
            users[0] = users[1];
            users[1] = x;
        }

        List <Account> accounts = new List <Account> ();
        System.runAs (users[0]) {
            accounts.add( new Account(Name = 'A0', Credit_Line__c = '123456781234') );
            accounts.add( new Account(Name = 'A1') );
            insert accounts;
            accounts.add( new Account(Name = 'A2', Credit_Line__c = '123456781234', ParentId = accounts[0].Id) );
            accounts.add( new Account(Name = 'A3', ParentId = accounts[1].Id) );
            upsert accounts;
        }

        List <Opportunity> opps = new List <Opportunity> ();
        Date close_date = Date.today();
        System.runAs (users[0]) {
            for (integer i = 0; i < 50; i++) {
                opps.add( new Opportunity(AccountId = accounts[2].Id, 
                                          Name = 'StarterPop'+ i, 
                                          CloseDate = close_date, 
                                          StageName = 'Prospecting') );
            }
            for (integer i = 0; i < 50; i++) {
                opps.add( new Opportunity(AccountId = accounts[3].Id, 
                                          Name = 'StarterNoPop'+ i, 
                                          CloseDate = close_date, 
                                          StageName = 'Prospecting') );
            }             
            for (integer i = 0; i < 50; i++) {
                opps.add( new Opportunity(Name = 'StarterNoAcc'+ i, 
                                          CloseDate = close_date, 
                                          StageName = 'Prospecting') );
            } 
            insert opps;
        }
        System.runAs (users[1]) {
            for (integer i = 0; i < 50; i++) {
                opps.add( new Opportunity(AccountId = accounts[0].Id, 
                                          Name = 'SellerPop'+ i, 
                                          CloseDate = close_date, 
                                          StageName = 'Prospecting') );
            }
            for (integer i = 0; i < 50; i++) {
                opps.add( new Opportunity(AccountId = accounts[1].Id, 
                                          Name = 'SellerNoPop'+ i, 
                                          CloseDate = close_date, 
                                          StageName = 'Prospecting') );
            }     
            for (integer i = 0; i < 50; i++) {
                opps.add( new Opportunity(Name = 'SellreNoAcc'+ i, 
                                          CloseDate = close_date, 
                                          StageName = 'Prospecting') );
            }
            upsert opps;
        }
        
        test.StartTest();
            creditLinePopulated testObj = new creditLinePopulated();
            Id BatchId = Database.executeBatch(testObj);
        test.StopTest();
        
        List <Opportunity> result = [
            Select Id, StageName
            From Opportunity
            Where StageName = 'Implementation'
        ];
        System.assertEquals(100, result.size());
    }
}
