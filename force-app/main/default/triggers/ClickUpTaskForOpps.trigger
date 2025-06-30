trigger ClickUpTaskForOpps on Opportunity (after update) {
    List<Opportunity> closedLostOpps = new List<Opportunity>();
    for (Opportunity newOpp : Trigger.new) {
        Opportunity oldOpp = Trigger.oldMap.get(newOpp.Id);
        if (newOpp.StageName == 'Closed Lost' && oldOpp.StageName != 'Closed Lost') {
            closedLostOpps.add(newOpp);
        }
    }
    if (!closedLostOpps.isEmpty()) {
        System.enqueueJob(new ClickUpTaskForOpportunity(closedLostOpps, null, null, null));
    }
}