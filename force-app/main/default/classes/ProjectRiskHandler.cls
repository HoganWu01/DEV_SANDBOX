/*
 * @Descripttion: 项目风险处理类Handler
 * @Author: Hogan
 * @Date: ###### Fri Feb 2 14:14:19 CST 2024
 * @LastEditors: Please set LastEditors
 * @LastEditTime: ###### Fri Feb 2 14:14:22 CST 2024
 */
public without sharing class ProjectRiskHandler implements Triggers.Handler {

    public void handle() {

        if (Trigger.isAfter && Trigger.isInsert) {
            List<ProjectRisk__c> tempProList = new List<ProjectRisk__c>();
            for(ProjectRisk__c newProRisk : (List<ProjectRisk__c>)Trigger.new) {
                //新建督办问题，授权责任人
                if (newProRisk.Owner__c != null) {
                    authoriseFun(newProRisk);
                }
            }
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            List<ProjectRisk__c> tempProList = new List<ProjectRisk__c>();
            for(ProjectRisk__c newProRisk : (List<ProjectRisk__c>)Trigger.new) {
                ProjectRisk__c oldProRisk = (ProjectRisk__c)Trigger.oldMap.get(newProRisk.Id);
                //变更责任人，授权新责任人
                if (newProRisk.Owner__c != null && newProRisk.Owner__c != oldProRisk.Owner__c){
                    authoriseFun(newProRisk);
                }
            }
        }
    }

    public static void authoriseFun(ProjectRisk__c proRisk){
        Project__share share = new Project__share();
        share.ParentId = proRisk.Project__c;
        share.UserOrGroupId = proRisk.Owner__c;
        share.AccessLevel = 'Edit';
        Database.insert(share, false);
    }

}