/*
 * @Descripttion: 督办问题处理类Handler
 * @Author: Hogan
 * @Date: ###### Fri Feb 2 14:14:19 CST 2024
 * @LastEditors: Please set LastEditors
 * @LastEditTime: ###### Fri Feb 2 14:14:22 CST 2024
 */
public without sharing class ProjectIssueHandler implements Triggers.Handler {

    public void handle() {

        if (Trigger.isAfter && Trigger.isInsert) {
            List<ProjectIssue__c> tempProList = new List<ProjectIssue__c>();
            for(ProjectIssue__c newProIssue : (List<ProjectIssue__c>)Trigger.new) {
                //新建督办问题，授权责任人
                if (newProIssue.IssueOwner__c != null) {
                    authoriseFun(newProIssue);
                }
            }
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            List<ProjectIssue__c> tempProList = new List<ProjectIssue__c>();
            for(ProjectIssue__c newProIssue : (List<ProjectIssue__c>)Trigger.new) {
                ProjectIssue__c oldProIssue = (ProjectIssue__c)Trigger.oldMap.get(newProIssue.Id);
                //变更责任人，授权新责任人
                if (newProIssue.IssueOwner__c != null && newProIssue.IssueOwner__c != oldProIssue.IssueOwner__c){
                    authoriseFun(newProIssue);
                }
            }
        }
    }

    public static void authoriseFun(ProjectIssue__c proIssue){
        Project__share share = new Project__share();
        share.ParentId = proIssue.Project__c;
        share.UserOrGroupId = proIssue.IssueOwner__c;
        share.AccessLevel = 'Edit';
        Database.insert(share, false);
    }

}