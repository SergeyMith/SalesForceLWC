public with sharing class newOppController {
    @AuraEnabled(cacheable=true)
    public static String getRoleName() {
        Id userId = UserInfo.getUserId();
        List <User> roleName = [
            Select UserRole.DeveloperName 
            From User 
            Where Id = :userId 
            Limit 1
        ];
        String result;
        if ( roleName.size() > 0 ) {
            result = roleName[0].UserRole.DeveloperName;
        }
        return result;
    }
    @AuraEnabled(cacheable=true)
    public static Id getRecordType() {

        String roleName = getRoleName();
        Id result;
        if ( ! String.isBlank(roleName) ) {
            String recordTypeName;
            if ( roleName.equals('Seller_Rep') ) {
                recordTypeName = 'Seller_RT';
            } else if ( roleName.equals('Starter_Rep') ) {
                recordTypeName = 'Starter_RT';
            } else {
                Schema.DescribeSObjectResult describe = Opportunity.SObjectType.getDescribe();
                Schema.RecordTypeInfo defaultRecordType;
                for(Schema.RecordTypeInfo item : describe.getRecordTypeInfos()) {
                    if(item.isDefaultRecordTypeMapping()) {
                        defaultRecordType = item;
                    }
                }
                recordTypeName = defaultRecordType.getDeveloperName();
            }
            result = [
                Select Id 
                From RecordType 
                Where DeveloperName = :recordTypeName
                Limit 1
            ].Id; 
        }
        return result;
    }
    @AuraEnabled(cacheable=true)
    public static Id getOwnerId () {

        return [
            Select Id                    
            From User 
            Where UserName = 'techadmin@mith.x' 
            Limit 1
        ].Id;
    }  
}
