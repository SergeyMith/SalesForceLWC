@isTest
public with sharing class newOppControllerTest {

    @TestSetup
    static void makeData () {

        List <UserRole> roles = [
            Select Id, DeveloperName 
            From UserRole 
            Where DeveloperName = 'CEO' Or
                  DeveloperName = 'Seller_Rep' Or
                  DeveloperName = 'Starter_Rep'
        ];  
        Profile prof = [
            Select Id    
            From Profile 
            Where Name = 'System Administrator'
            Limit 1
        ];
        List <User> users = new List <User> ();
        for (integer i = 0; i < 3; i++) {

            users.add( new User ( 
                LastName = 'user', 
                Alias = 'user', 
                Email = 'laegmith@gmail.com',
                Username = 'newOppControllerTest_user_'+ i +'@mith.ct3',
                CommunityNickname = 'user_ct3_'+ i,
                UserRoleId = roles[i].Id,
                ProfileId = prof.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
     		    EmailEncodingKey = 'UTF-8',
     		    LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US' ) 
            );
        }
        insert users;
    }

    @isTest
    public static void testGetRoleName () {

        List <User> users = [
            Select Id, UserRoleId
            From User
            Where UserName Like 'newOppControllerTest%'
            Order by UserName Asc
        ];

        List <String> roleNames = new List <String> ();

        test.StartTest();
            for (integer i = 0; i < 3; i++) {
                System.runAs (users[i]) {           
                    roleNames.add( newOppController.getRoleName() );
                }
            }
        test.StopTest();
       
        Map <Id, UserRole> roles = new Map <Id, UserRole> ([
            Select Id, DeveloperName 
            From UserRole 
            Where DeveloperName = 'CEO' Or
                  DeveloperName = 'Seller_Rep' Or
                  DeveloperName = 'Starter_Rep'
        ]);                                     
        
        for (integer i = 0; i < 3; i++) {

            System.assertEquals(roles.get(users[i].UserRoleId).DeveloperName, roleNames[i]);
        }    
    }

    private static Id getRecordTypeId (String name, List <RecordType> rt) {

        Id result;
        for (RecordType item: rt) {
            if ( item.DeveloperName.equals(name) ) {
                result = item.Id;
            }         
        }
        return result;
    }

    @isTest
    public static void testGetRecordType () {

        List <User> users = [
            Select Id, UserRole.DeveloperName
            From User
            Where UserName Like 'newOppControllerTest%'
        ];
        Map <String, String> roleName_and_RecordType = new Map <String, String> {
            'CEO' => 'Starter_RT',
            'Seller_Rep' => 'Seller_RT',
            'Starter_Rep' => 'Starter_RT'
        };
            
        List <RecordType> recordTypes = [
            Select Id, DeveloperName 
            From RecordType 
            Where DeveloperName = 'Seller_RT' Or
                  DeveloperName = 'Starter_RT'
        ];

        List <Id> result = new List <Id> ();

        test.StartTest();
            for (integer i = 0; i < 3; i++)
                System.runAs (users[i]) {           
                    result.add( newOppController.getRecordType() );
            }
        test.StopTest();

        for (integer i = 0; i < 3; i++) {

            System.assertEquals(
                getRecordTypeId(roleName_and_RecordType.get(users[i].UserRole.DeveloperName), recordTypes), 
                result[i]
            );
        }    
    }

    @isTest
    public static void testGetOwnerId () {

        User techadmin = [
            Select Id                    
            From User 
            Where UserName = 'techadmin@mith.x' 
            Limit 1
        ];

        test.StartTest();
            Id result = newOppController.getOwnerId();          
        test.StopTest();

        System.assertEquals(techadmin.Id, result);
    }
}
