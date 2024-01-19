public with sharing class LwcOppNameCheckWeightsController {
    /**
     * 获取商机列表
     */
    @AuraEnabled(cacheable=true)
    public static List<OppEntity> getRelatedOpps(String oppId) {

        List<OppEntity> oppEntityList = new List<OppEntity>();

        Opportunity currOpp = [SELECT Id, Name, ProjectNumber__c, Account.Name, Owner.Name, 
        Account.Shortname__c, City__c, County__c, Province__c, Wind_Farm_Project_Name__c, capacity__c, Close__c 
                FROM Opportunity WHERE Id =: oppId];

        List<Opportunity> oppList = [SELECT Id, Name, ProjectNumber__c, Account.Name, Owner.Name, 
        Account.Shortname__c, City__c, County__c, Province__c, Wind_Farm_Project_Name__c, capacity__c, Close__c
                FROM Opportunity WHERE Id != :oppId and OpportunityApprovalStatus__c not in ('草稿','线索提报审批中','商机提报审批中') 
                and Wind_Farm_Project_Name__c != null and Wind_Farm_Project_Name__c != ''];

        for (Opportunity o : oppList) {
            Decimal weight = 0;
            if (o.Account.Shortname__c == currOpp.Account.Shortname__c &&
                o.Province__c == currOpp.Province__c &&
                o.City__c.replaceAll('市','') == currOpp.City__c.replaceAll('市','')) { //客户简称、省份、城市 重复

                weight += 49;

                if (o.capacity__c == currOpp.capacity__c) { //容量 重复
                    weight += 10;
                }

                if (String.isNotBlank(o.County__c)&&String.isNotEmpty(o.County__c)
                    &&String.isNotBlank(currOpp.County__c)&&String.isNotEmpty(currOpp.County__c)) {
                        if (o.County__c.replaceAll('县','').replaceAll('区','') == currOpp.County__c.replaceAll('县','').replaceAll('区','')) { //县区 重复
                            weight += 10;
                        }
                }
            }
            
            if (String.isNotBlank(currOpp.Wind_Farm_Project_Name__c) && String.isNotEmpty(currOpp.Wind_Farm_Project_Name__c)) {

                List<CheckWeightSetting__mdt> mdtList = [select Sn__c,MasterLabel from CheckWeightSetting__mdt ORDER BY Sn__c asc];
                if (mdtList.size()>0) {
                    String currWindTemp = currOpp.Wind_Farm_Project_Name__c;
                    String targetWindTemp = o.Wind_Farm_Project_Name__c;
                    for (CheckWeightSetting__mdt mdt : mdtList) {
                        currWindTemp = currWindTemp.replaceAll(mdt.MasterLabel, '');
                        targetWindTemp = targetWindTemp.replaceAll(mdt.MasterLabel, '');
                    }
                    if (windFarmFun(currWindTemp, targetWindTemp)) { //大于两个字符重复
                        weight += 30;
                    }
                }

                // String windFarmCurr = currOpp.Wind_Farm_Project_Name__c.replaceAll('风电场','').replaceAll('风电','').replaceAll('项目','')
                //     .replaceAll('分散式','').replaceAll('一体化','').replaceAll('源网荷储','').replaceAll('风力发电','');

                // String windFarmStr = o.Wind_Farm_Project_Name__c.replaceAll('风电场','').replaceAll('风电','').replaceAll('项目','')
                //     .replaceAll('分散式','').replaceAll('一体化','').replaceAll('源网荷储','').replaceAll('风力发电','');

            }

            if (weight >= Decimal.valueOf('30') ) {
                OppEntity oEnt = new OppEntity();
                oEnt.Id = o.Id;
                oEnt.projectNumber = o.ProjectNumber__c;
                oEnt.oppName = o.Name;
                oEnt.accName = o.Account.Name;
                oEnt.owner = o.Owner.Name;
                oEnt.weight = weight / 100;
                oEnt.close = o.Close__c;
                oEnt.oppUrl = '/lightning/r/Opportunity/' + o.Id + '/view';
                oppEntityList.add(oEnt);
            }
        }

        System.debug('>>>>>>>>>>>>>' + oppEntityList);

        //权重值排序
        Map<Integer,OppEntity> mapOpps = new Map<Integer,OppEntity>();
        Integer i = 0;
        for (OppEntity oe : oppEntityList) {
            mapOpps.put(i++, oe);
        }
        for (Integer ii : mapOpps.keySet()) {
            for (Integer jj : mapOpps.keySet()) {
                if (mapOpps.get(ii).weight > mapOpps.get(jj).weight) {
                    OppEntity oppTemp = new OppEntity();
                    oppTemp = mapOpps.get(ii);
                    mapOpps.put(ii, mapOpps.get(jj));
                    mapOpps.put(jj, oppTemp);
                }  
            }
        }
        List<OppEntity> oppEntityListSort = new List<OppEntity>();
        for (Integer zz : mapOpps.keySet()) {
            oppEntityListSort.add(mapOpps.get(zz));
        }

        return oppEntityListSort;
    }

    public static Boolean windFarmFun(String currStr, String oppStr){
        Integer dupCount = 0; //重复次数

        String[] stringCharacters = currStr.replaceAll(' ','').split('');

        for (String c : stringCharacters) {

            Integer count = 0;

            Integer origialLength = oppStr.length();
            oppStr = oppStr.replace(c, '');
            Integer newLength = oppStr.length();

            count = origialLength - newLength;
            if (count > 0) { //说明循环该字符有重复，记1
                dupCount++;
                if (dupCount>=2) { //大于两个字符重复，不再循环
                    return true;
                }
            }
        }
        return false;
    }

    public class OppEntity {
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String projectNumber{get;set;}
        @AuraEnabled
        public String oppName{get;set;}
        @AuraEnabled
        public String accName{get;set;}
        @AuraEnabled
        public String owner{get;set;}
        @AuraEnabled
        public Decimal weight{get;set;}
        @AuraEnabled
        public String oppUrl{get;set;}
        @AuraEnabled
        public Boolean close{get;set;}
    } 
}