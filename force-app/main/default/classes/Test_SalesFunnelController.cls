/*
 * @Descripttion: 【销售漏斗】 测试类
 * @Author: Hogan
 * @Date: ###### Tue Jul 11 08:56:48 CST 2023
 * @LastEditors: Please set LastEditors
 * @LastEditTime: ###### Tue Jul 11 08:56:50 CST 2023
 */
@isTest
public with sharing class Test_SalesFunnelController {
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

        //添加客户分部记录
        MarketBidDept__c mb1 = new MarketBidDept__c(Name = '客户一部', General_Manager_User__c = user1.Id, DeptPickList__c = '162092f16daa04f4de53a694724b93ac', DeptId__c = '162092f16daa04f4de53a694724b93ac');
        insert mb1;
        MarketBidDept__c mb2 = new MarketBidDept__c(Name = '客户二部', General_Manager_User__c = user2.Id, DeptPickList__c = '162092f16e0f16e08b24fb54940ac5c7', DeptId__c = '162092f16e0f16e08b24fb54940ac5c7');
        insert mb2;

        //添加大区、售前项目经理记录
        Integrated_Middle_Table__c mid1 = new Integrated_Middle_Table__c(Salesdepartment__c = '西南大区', RecordTypeId = '0122u0000008V2DAAU', OppChiefgeneralmanager__c = user1.Id, Pre_Sales_Project_Manager__c = user1.Id);
        insert mid1;
        Integrated_Middle_Table__c mid2 = new Integrated_Middle_Table__c(Salesdepartment__c = '东北大区', RecordTypeId = '0122u0000008V2DAAU', OppChiefgeneralmanager__c = user2.Id, Pre_Sales_Project_Manager__c = user2.Id);
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
        opp.OpportunityApprovalStatus__c = '商机提报通过';
        insert opp;

        Opportunity opp2  = new Opportunity();
        opp2.Name = 'opp';
        opp2.ProjectSubmission__c = '正常提报线索';
        opp2.Projecttype__c = '陆上项目';
        opp2.AccountId = acc.Id;
        opp2.Wind_Farm_Project_Name__c = '风场项目名';
        opp2.capacity__c = 12;
        opp2.StageName ='商机管理';
        opp2.Province__c = '北京';
        opp2.City__c = '中山';
        opp2.CloseDate = System.today();
        opp2.Periods__c = '一';
        opp2.Close__c = false;
        opp2.recordTypeId = '0122u0000008UxEAAU';
        opp2.Salesdepartment__c = '西南大区';
        opp2.MarketBidDept__c = '162092f16daa04f4de53a694724b93ac';
        opp2.OwnerId = user1.Id;
        opp2.OpportunityApprovalStatus__c = '商机提报通过';
        insert opp2;

        Opportunity opp3  = new Opportunity();
        opp3.Name = 'opp';
        opp3.ProjectSubmission__c = '正常提报线索';
        opp3.Projecttype__c = '陆上项目';
        opp3.AccountId = acc.Id;
        opp3.Wind_Farm_Project_Name__c = '风场项目名';
        opp3.capacity__c = 12;
        opp3.StageName ='项目立项';
        opp3.Province__c = '上海';
        opp3.City__c = '中山';
        opp3.CloseDate = System.today();
        opp3.Periods__c = '一';
        opp3.Close__c = false;
        opp3.recordTypeId = '0122u0000008UxEAAU';
        opp3.Salesdepartment__c = '西南大区';
        opp3.MarketBidDept__c = '162092f16daa04f4de53a694724b93ac';
        opp3.OwnerId = user1.Id;
        opp3.OpportunityApprovalStatus__c = '商机提报通过';
        insert opp3;

        Opportunity opp4  = new Opportunity();
        opp4.Name = 'opp';
        opp4.ProjectSubmission__c = '正常提报线索';
        opp4.Projecttype__c = '陆上项目';
        opp4.AccountId = acc.Id;
        opp4.Wind_Farm_Project_Name__c = '风场项目名';
        opp4.capacity__c = 12;
        opp4.StageName ='招投标';
        opp4.Province__c = '天津';
        opp4.City__c = '中山';
        opp4.CloseDate = System.today();
        opp4.Periods__c = '一';
        opp4.Close__c = false;
        opp4.recordTypeId = '0122u0000008UxEAAU';
        opp4.Salesdepartment__c = '西南大区';
        opp4.MarketBidDept__c = '162092f16daa04f4de53a694724b93ac';
        opp4.OwnerId = user1.Id;
        opp4.OpportunityApprovalStatus__c = '商机提报通过';
        insert opp4;

        Opportunity opp5  = new Opportunity();
        opp5.Name = 'opp';
        opp5.ProjectSubmission__c = '正常提报线索';
        opp5.Projecttype__c = '陆上项目';
        opp5.AccountId = acc.Id;
        opp5.Wind_Farm_Project_Name__c = '风场项目名';
        opp5.capacity__c = 12;
        opp5.StageName ='中标/赢单';
        opp5.Province__c = '河北';
        opp5.City__c = '中山';
        opp5.CloseDate = System.today();
        opp5.Periods__c = '一';
        opp5.Close__c = false;
        opp5.recordTypeId = '0122u0000008UxEAAU';
        opp5.Salesdepartment__c = '西南大区';
        opp5.MarketBidDept__c = '162092f16daa04f4de53a694724b93ac';
        opp5.OwnerId = user1.Id;
        opp5.OpportunityApprovalStatus__c = '商机提报通过';
        insert opp5;

        Opportunity opp6  = new Opportunity();
        opp6.Name = 'opp';
        opp6.ProjectSubmission__c = '正常提报线索';
        opp6.Projecttype__c = '陆上项目';
        opp6.AccountId = acc.Id;
        opp6.Wind_Farm_Project_Name__c = '风场项目名';
        opp6.capacity__c = 12;
        opp6.StageName ='合同商务';
        opp6.Province__c = '河南';
        opp6.City__c = '中山';
        opp6.CloseDate = System.today();
        opp6.Periods__c = '一';
        opp6.Close__c = false;
        opp6.recordTypeId = '0122u0000008UxEAAU';
        opp6.Salesdepartment__c = '西南大区';
        opp6.MarketBidDept__c = '162092f16daa04f4de53a694724b93ac';
        opp6.OwnerId = user1.Id;
        opp6.OpportunityApprovalStatus__c = '商机提报通过';
        insert opp6;
    }

    /**
     * @Descripttion: ControllerMattersSubmit 测试类
     * @Author: Hogan
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_getSalesFunnelData() {
        System.Test.startTest();
        List<SelectOption> list1 = SalesFunnelController.getDynamicPicklistOptions();
        List<SelectOption> list2 = SalesFunnelController.getDynamicPicklistOptions2();
        SalesFunnelController.getSalesFunnelData('ALL','ALL');
        SalesFunnelController.getSalesFunnelData('','');
        SalesFunnelController.getSalesFunnelData('','ALL');
        SalesFunnelController.getSalesFunnelData('ALL','');
        System.Test.stopTest();
    }

}