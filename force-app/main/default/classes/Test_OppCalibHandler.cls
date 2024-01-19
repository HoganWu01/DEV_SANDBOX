/*
 * @Descripttion: 【商机】 定标 测试类
 * @Author: Hogan
 * @Date: ###### Wed Nov 22 14:14:02 CST 2023
 * @LastEditors: Please set LastEditors
 * @LastEditTime: ###### Wed Nov 22 14:14:04 CST 2023
 */
@isTest
public with sharing class Test_OppCalibHandler {
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

        //添加客户分部记录
        MarketBidDept__c mb1 = new MarketBidDept__c(Name = '客户一部', General_Manager_User__c = user1.Id, General_Manager_Emp__c = emp.Id, DeptPickList__c = '162092f16daa04f4de53a694724b93ac', DeptId__c = '162092f16daa04f4de53a694724b93ac');
        insert mb1;
        MarketBidDept__c mb2 = new MarketBidDept__c(Name = '客户二部', General_Manager_User__c = user2.Id, General_Manager_Emp__c = emp.Id, DeptPickList__c = '162092f16e0f16e08b24fb54940ac5c7', DeptId__c = '162092f16e0f16e08b24fb54940ac5c7');
        insert mb2;

        //添加大区、售前项目经理记录
        Integrated_Middle_Table__c mid1 = new Integrated_Middle_Table__c(Salesdepartment__c = '西南大区', RecordTypeId = '0122u0000008V2DAAU', OppChiefgeneralmanager__c = user1.Id, Pre_Sales_Project_Manager__c = user1.Id, General_Manager_Company__c = emp.Id);
        insert mid1;
        Integrated_Middle_Table__c mid2 = new Integrated_Middle_Table__c(Salesdepartment__c = '东北大区', RecordTypeId = '0122u0000008V2DAAU', OppChiefgeneralmanager__c = user2.Id, Pre_Sales_Project_Manager__c = user2.Id, General_Manager_Company__c = emp.Id);
        insert mid2;

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
        opp.Salesdepartment__c = '西南大区';
        opp.MarketBidDept__c = '162092f16daa04f4de53a694724b93ac';
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
    static testMethod void test_OppCalibHandler() {

        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
       
        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.CalibApproval__c = '1';
        opp.OpportunityApprovalStatus__c = '线索提报通过';
        update opp;

        opp.CalibApproval__c = '2';
        opp.CalibResults__c = '1';
        opp.CalibResultsTemp__c = '1';
        update opp;

        opp.CalibApproval__c = '1';
        update opp;

        opp.CalibApproval__c = '2';
        opp.CalibResults__c = '2';
        opp.CalibResultsTemp__c = '2';
        update opp;
    }

}