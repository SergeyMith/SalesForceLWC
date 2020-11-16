public with sharing class schedulableClass implements Schedulable {

    public void execute(SchedulableContext ctx) {
        
        creditLinePopulated x = new creditLinePopulated();
		Id BatchId = Database.executeBatch(x);
    }
}
