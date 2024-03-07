trigger ProjectRiskTrigger on ProjectRisk__c (after insert, after update) {
    Trigger__mdt mc = Trigger__mdt.getInstance('ProjectRiskTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.AfterInsert,new ProjectRiskHandler())
        .Bind(Triggers.Evt.AfterUpdate,new ProjectRiskHandler())
        .Execute();
    }
}