/*
 * @Descripttion: 【商机】 模块 测试类
 * @Author: Devin
 * @Date: 2021-11-05 08:51:24
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2022-03-22 14:43:47
 */
@isTest
public with sharing class Test_LwcOppNameCheckWeight {
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
        opp.OpportunityApprovalStatus__c = '线索提报通过';
        insert opp;

        Opportunity opp2  = new Opportunity();
        opp2.Name = 'opp';
        opp2.ProjectSubmission__c = '正常提报线索';
        opp2.Projecttype__c = '陆上项目';
        opp2.AccountId = acc.Id;
        opp2.Wind_Farm_Project_Name__c = '风场项目名2';
        opp2.capacity__c = 12;
        opp2.StageName ='线索管理';
        opp2.Province__c = '广东';
        opp2.City__c = '中山';
        opp2.CloseDate = System.today();
        opp2.Periods__c = '一';
        opp2.Close__c = false;
        opp2.recordTypeId = '0122u0000008UxEAAU';
        opp2.Salesdepartment__c = '西南大区';
        opp2.MarketBidDept__c = '162092f16daa04f4de53a694724b93ac';
        opp2.OwnerId = user1.Id;
        opp2.OpportunityApprovalStatus__c = '线索提报通过';
        insert opp2;
    }

    static testMethod void test_Controller() {

        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;

        LwcOppNameCheckWeightsController.getRelatedOpps(oppId);
    }
    
}