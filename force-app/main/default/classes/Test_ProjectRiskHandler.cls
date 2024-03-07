@isTest
public with sharing class Test_ProjectRiskHandler {

    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='R资源销售'];

        User user = new User(Alias = '格日图', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test11011.com');
        insert user;

        Account account = new Account(Name='zhw',Region__c='东北大区');
        insert account;

        Id account_id = [SELECT Id FROM Account WHERE Name = 'zhw'].Id;
        //User的数据不需要自己生成
        Id user_id = [SELECT Id FROM User WHERE Name = 'admin'].Id;

        List<Account> accounts = [SELECT Region__c,Id,Name FROM Account];

        Project__c project = new Project__c(
            Name='Test', 
            Account__c=account_id, 
            ProjectManager__c=user_id, 
            InitialNumOfMachine__c = 1,
            RegionNew__c = '东北大区'
            );

        insert project;

        ProjectRisk__c proRisk = new ProjectRisk__c(
            Name='Test', 
            Project__c = project.Id,
            Owner__c=user.id,
            RelatedDepartment__c='采购部'
        );

        insert proRisk;
        
    }    

    static testMethod void testProjectIssueHandler(){

        ProjectRisk__c proRisk = [SELECT ID FROM ProjectRisk__c WHERE Name = 'Test' limit 1];

        Profile p = [SELECT Id FROM Profile WHERE Name='R资源销售'];
        User user = new User(Alias = '格日图2', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@test11011.com');
        insert user;

        proRisk.Owner__c = user.Id;

        update proRisk;
    }

}