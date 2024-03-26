@isTest
public with sharing class Test_OppManagerHandler {
    @TestSetup 
    static void setData() {

        //客户数据
        Account acc = new Account();
        acc.Name = '广州风机';
        acc.BeenGroup__c = true;
        insert acc;

        //简档数据
        Profile manageprofile = [SELECT Id FROM Profile WHERE Name='O项目经理'];

        //用户数据
        User user1 = new User(Alias = '格日图', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = manageprofile.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test1110.com');
        insert user1;

        User user2 = new User(Alias = '格日图222', Email='standarduser222@testorg.com',EmailEncodingKey='UTF-8', LastName='Test120', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = manageprofile.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test120.com');
        insert user2;

        //员工数据
        Employee__c emp = new Employee__c(Job_Number__c = '123456', name = 'aaa', Duty__c = '顾问', Department__c = '小卖部', Department_Number__c = '111', Status__c = '在职');
        insert emp ; 

        String recTypeId1 =Schema.SObjectType.BasicData__c.getRecordTypeInfosByDeveloperName().get('RecordType_BasicData_Sales').getRecordTypeId();
        BasicData__c bd = new BasicData__c(RecordTypeId = recTypeId1, name = 'aaa', ProjectDeliveryMarket__c = '01', ProjectArea__c = 'SR101', BasicNo__c = 'A001');
        insert bd;

        String recTypeId2 =Schema.SObjectType.BasicData__c.getRecordTypeInfosByDeveloperName().get('RecordType_BasicData_Customer').getRecordTypeId();
        BasicData__c bd2 = new BasicData__c(RecordTypeId = recTypeId2, name = 'bbb', ProjectDeliveryMarket__c = '01', MarketBidDept__c = 'KA101', BasicNo__c = 'B001');
        insert bd2;

        Opportunity opp  = new Opportunity();
        opp.Name = 'opp';
        opp.ProjectSubmission__c = '正常提报线索';
        opp.Projecttype__c = '陆上项目';
        opp.AccountId = acc.Id;
        opp.Wind_Farm_Project_Name__c = '风场项目名';
        opp.capacity__c = 12;
        opp.StageName ='线索管理';
        opp.Province__c = '广东';
        opp.City__c = '中山';
        opp.CloseDate = System.today();
        opp.Periods__c = '一';
        opp.Close__c = false;
        opp.recordTypeId = '0122u0000008UxEAAU';
        opp.MarketBidDept__c = 'KA101';
        opp.ProjectArea__c = 'SR101';
        opp.ProjectDeliveryMarket__c = '01';
        opp.OwnerId = user1.Id;
        opp.OpportunityApprovalStatus__c = '草稿';
        insert opp;

    }

    /**
     * @Descripttion: OpportunityHandler 测试类 81%
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_OppManagerHandler() {
        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
        List<Id> oppListIds = new List<Id>();
        oppListIds.add(oppId);
        OppManagerHandler.syncOppManager(oppListIds);
    }
}