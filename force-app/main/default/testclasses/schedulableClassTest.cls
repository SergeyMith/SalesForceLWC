@isTest
public with sharing class schedulableClassTest {
      
    @isTest
    public static void testSchedule () {

        Date today = Date.today();
        String timeExp = '0 0 22 '+ today.day() +' '+ today.month() +' ?';
        String jobId = System.schedule('ScheduledTest', timeExp, new schedulableClass());
    }
}
