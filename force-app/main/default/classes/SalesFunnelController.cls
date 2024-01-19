/**
 * 销售漏斗controller
 */
public without sharing class SalesFunnelController {
      
    public String salesDepartment { get; set; }
    public String marketBidDept { get; set; }

    public String selectedOption { get; set; }
    public String selectedOption2 { get; set; }

    public static List<SelectOption> getDynamicPicklistOptions() {
        List<SelectOption> picklistOptions = new List<SelectOption>();
        // 在这里获取动态数据，并将其添加到picklistOptions中
        // 以下示例只是演示，实际上你需要根据你的业务逻辑来获取动态数据
        List<Utils.PickListValue> listPick = Utils.getPickListValue('Opportunity', 'Salesdepartment__c'); //所属大区/二级公司
        picklistOptions.add(new SelectOption('ALL', 'ALL'));
        for (Utils.PickListValue pickV : listPick) {
            picklistOptions.add(new SelectOption(pickV.FieldValue, pickV.FieldLabel));
        }
        return picklistOptions;
    }

    public static List<SelectOption> getDynamicPicklistOptions2() {
        List<SelectOption> picklistOptions = new List<SelectOption>();
        // 在这里获取动态数据，并将其添加到picklistOptions中
        // 以下示例只是演示，实际上你需要根据你的业务逻辑来获取动态数据
        List<Utils.PickListValue> listPick = Utils.getPickListValue('Opportunity', 'MarketBidDept__c'); //客户分部
        picklistOptions.add(new SelectOption('ALL', 'ALL'));
        for (Utils.PickListValue pickV : listPick) {
            picklistOptions.add(new SelectOption(pickV.FieldValue, pickV.FieldLabel));
        }
        return picklistOptions;
    }

    public void submitForm(){

    }

    @RemoteAction
    public static List<SalesFunnelEntity> getSalesFunnelData(String salesDepartment, String marketBidDept) {
        List<AggregateResult> query_results = null;
        if (salesDepartment=='ALL'&&marketBidDept=='ALL') {
            query_results = [SELECT   count(Id) coun,
                                            StageName
                                        FROM 
                                            Opportunity
                                        WHERE 
                                            OpportunityApprovalStatus__c not in ('草稿','线索提报审批中','线索驳回','商机提报审批中','商机驳回') 
                                            group by StageName order by StageName
                                        ];
        }else if(salesDepartment!='ALL'&&marketBidDept!='ALL'){
            query_results = [SELECT   count(Id) coun,
                                            StageName
                                        FROM 
                                            Opportunity
                                        WHERE 
                                            OpportunityApprovalStatus__c not in ('草稿','线索提报审批中','线索驳回','商机提报审批中','商机驳回') 
                                            and Salesdepartment__c =: salesDepartment and MarketBidDept__c =: marketBidDept
                                            group by StageName order by StageName
                                        ];
        }else if(salesDepartment=='ALL'&&marketBidDept!='ALL'){
            query_results = [SELECT   count(Id) coun,
                                            StageName
                                        FROM 
                                            Opportunity
                                        WHERE 
                                            OpportunityApprovalStatus__c not in ('草稿','线索提报审批中','线索驳回','商机提报审批中','商机驳回') 
                                            and MarketBidDept__c =: marketBidDept
                                            group by StageName order by StageName
                                        ];
        }else if(salesDepartment!='ALL'&&marketBidDept=='ALL'){
            query_results = [SELECT   count(Id) coun,
                                            StageName
                                        FROM 
                                            Opportunity
                                        WHERE 
                                            OpportunityApprovalStatus__c not in ('草稿','线索提报审批中','线索驳回','商机提报审批中','商机驳回') 
                                            and Salesdepartment__c =: salesDepartment
                                            group by StageName order by StageName
                                        ];
        }

        Decimal counSum = 0;
        List<SalesFunnelEntity> sfeList = new List<SalesFunnelEntity>();
        Map<String,Decimal> map_opp = new Map<String,Decimal>();

        for(AggregateResult result : query_results){
            counSum += Integer.valueOf(result.get('coun'));
            map_opp.put(String.valueOf(result.get('StageName')), Decimal.valueOf(Integer.valueOf(result.get('coun'))));
        }

        Map<String,Decimal> map_oppCounts = new Map<String,Decimal>();
        for(AggregateResult result : query_results){
            SalesFunnelEntity sfe = new SalesFunnelEntity();
            Decimal coun =  Decimal.valueOf(Integer.valueOf(result.get('coun')));
            String StageName = String.valueOf(result.get('StageName'));
            sfe.stageName = StageName;
            sfe.oppCounts = coun;
            // sfe.percentage = Decimal.valueOf(coun).divide(counSum, 2)*100;
            sfe.percentage = coun.divide(counSum,4) * 100;
            System.debug(sfe.percentage);
            if (StageName=='线索管理') {
                sfe.countsSum = (map_opp.containsKey('线索管理')?map_opp.get('线索管理'):0) + (map_opp.containsKey('商机管理')?map_opp.get('商机管理'):0) + (map_opp.containsKey('项目立项')?map_opp.get('项目立项'):0) + (map_opp.containsKey('招投标')?map_opp.get('招投标'):0) + (map_opp.containsKey('中标/赢单')?map_opp.get('中标/赢单'):0) + (map_opp.containsKey('合同商务')?map_opp.get('合同商务'):0) + (map_opp.containsKey('Closed Won')?map_opp.get('Closed Won'):0);
                sfe.conversionRate = 0;
            }else if (StageName=='商机管理') {
                sfe.countsSum = (map_opp.containsKey('商机管理')?map_opp.get('商机管理'):0) + (map_opp.containsKey('项目立项')?map_opp.get('项目立项'):0) + (map_opp.containsKey('招投标')?map_opp.get('招投标'):0) + (map_opp.containsKey('中标/赢单')?map_opp.get('中标/赢单'):0) + (map_opp.containsKey('合同商务')?map_opp.get('合同商务'):0) + (map_opp.containsKey('Closed Won')?map_opp.get('Closed Won'):0);
                // sfe.conversionRate = (map_opp.containsKey('项目立项')?map_opp.get('项目立项'):0).divide(((map_opp.containsKey('商机管理')?map_opp.get('商机管理'):0) + (map_opp.containsKey('项目立项')?map_opp.get('项目立项'):0)),4) * 100;
                sfe.conversionRate = (map_oppCounts.containsKey('线索管理')?sfe.countsSum.divide(map_oppCounts.get('线索管理'),4) * 100:0);
            }else if (StageName=='项目立项') {
                sfe.countsSum = (map_opp.containsKey('项目立项')?map_opp.get('项目立项'):0) + (map_opp.containsKey('招投标')?map_opp.get('招投标'):0) + (map_opp.containsKey('中标/赢单')?map_opp.get('中标/赢单'):0) + (map_opp.containsKey('合同商务')?map_opp.get('合同商务'):0) + (map_opp.containsKey('Closed Won')?map_opp.get('Closed Won'):0);
                // sfe.conversionRate = (map_opp.containsKey('招投标')?map_opp.get('招投标'):0).divide(((map_opp.containsKey('项目立项')?map_opp.get('项目立项'):0) + (map_opp.containsKey('招投标')?map_opp.get('招投标'):0)),4) * 100;
                sfe.conversionRate = (map_oppCounts.containsKey('商机管理')?sfe.countsSum.divide(map_oppCounts.get('商机管理'),4) * 100:0);
            }else if (StageName=='招投标') {
                sfe.countsSum = (map_opp.containsKey('招投标')?map_opp.get('招投标'):0) + (map_opp.containsKey('中标/赢单')?map_opp.get('中标/赢单'):0) + (map_opp.containsKey('合同商务')?map_opp.get('合同商务'):0) + (map_opp.containsKey('Closed Won')?map_opp.get('Closed Won'):0);
                // sfe.conversionRate = (map_opp.containsKey('中标/赢单')?map_opp.get('中标/赢单'):0).divide(((map_opp.containsKey('招投标')?map_opp.get('招投标'):0) + (map_opp.containsKey('中标/赢单')?map_opp.get('中标/赢单'):0)),4) * 100;
                sfe.conversionRate = (map_oppCounts.containsKey('项目立项')?sfe.countsSum.divide(map_oppCounts.get('项目立项'),4) * 100:0);
            }else if (StageName=='中标/赢单') {
                sfe.countsSum = (map_opp.containsKey('中标/赢单')?map_opp.get('中标/赢单'):0) + (map_opp.containsKey('合同商务')?map_opp.get('合同商务'):0) + (map_opp.containsKey('Closed Won')?map_opp.get('Closed Won'):0);
                // sfe.conversionRate = (map_opp.containsKey('合同商务')?map_opp.get('合同商务'):0).divide(((map_opp.containsKey('中标/赢单')?map_opp.get('中标/赢单'):0) + (map_opp.containsKey('合同商务')?map_opp.get('合同商务'):0)),4) * 100;
                sfe.conversionRate = (map_oppCounts.containsKey('招投标')?sfe.countsSum.divide(map_oppCounts.get('招投标'),4) * 100:0);
            }else if (StageName=='合同商务') {
                sfe.countsSum = (map_opp.containsKey('合同商务')?map_opp.get('合同商务'):0) + (map_opp.containsKey('Closed Won')?map_opp.get('Closed Won'):0);
                // sfe.conversionRate = (map_opp.containsKey('Closed Won')?map_opp.get('Closed Won'):0).divide(((map_opp.containsKey('合同商务')?map_opp.get('合同商务'):0) + (map_opp.containsKey('Closed Won')?map_opp.get('Closed Won'):0)),4) * 100;
                sfe.conversionRate = (map_oppCounts.containsKey('中标/赢单')?sfe.countsSum.divide(map_oppCounts.get('中标/赢单'),4) * 100:0);
            }else if (StageName=='Closed Won') {
                sfe.countsSum = (map_opp.containsKey('Closed Won')?map_opp.get('Closed Won'):0);
                sfe.conversionRate = (map_oppCounts.containsKey('合同商务')?sfe.countsSum.divide(map_oppCounts.get('合同商务'),4) * 100:0);
            }else {
                sfe.countsSum = 0;
                sfe.conversionRate = 0;
            }
            map_oppCounts.put(StageName, sfe.countsSum);
            sfeList.add(sfe);
        }

        return sfeList;

    }

    public class SalesFunnelEntity {
		public String stageName{get;set;} //阶段
        public Decimal oppCounts {get;set;} //数量
        public Decimal percentage {get;set;} //占比
        public Decimal countsSum {get;set;} //数量汇总
        public Decimal conversionRate  {get;set;} //转化率
	}

}