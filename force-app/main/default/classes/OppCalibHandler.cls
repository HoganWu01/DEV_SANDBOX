/*
 * @Descripttion: 商机定标触发器
 * @Author: Hogan
 * @Date: ###### Wed Nov 22 11:21:42 CST 2023
 * @LastEditors: Hogan
 * @LastEditTime: ###### Wed Nov 22 11:21:43 CST 2023
 */
public without sharing class OppCalibHandler implements Triggers.Handler{

    public void handle() {

        //更新之后
        if (Trigger.isAfter && Trigger.isUpdate) {
            
            List<Opportunity> upOppList = new List<Opportunity>();
            for(Opportunity newOpp : (List<Opportunity>)Trigger.new) {
                Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(newOpp.Id);
            
                //【定标审批】 从审批中变为审批结束，对定标结果进行赋值
                if (newOpp.CalibApproval__c != oldOpp.CalibApproval__c && oldOpp.CalibApproval__c == '1' && newOpp.CalibApproval__c == '2') {
                    Opportunity upOpp = new Opportunity();
                    upOpp.Id = newOpp.Id;
                    upOpp.CalibResults__c = newOpp.CalibResultsTemp__c;
                    upOpp.CalibrationDate__c = newOpp.CalibrationDateTemp__c;
                    if(upOpp.CalibResults__c == '1'){ //中标
                        upOpp.Wonreason__c = newOpp.WonreasonTemp__c;
                        upOpp.Listprice__c = newOpp.ListpriceTemp__c;
                        upOpp.WinCapacity__c = newOpp.WinCapacityTemp__c;
                        upOpp.StageName = '中标/赢单';
                        upOppList.add(upOpp);
                    }else if (upOpp.CalibResults__c == '2') { //丢标
                        upOpp.Winningopponent__c = newOpp.WinningopponentTemp__c;
                        upOpp.Competitor__c = newOpp.CompetitorTemp__c;
                        upOpp.Lostreason__c = newOpp.LostreasonTemp__c;
                        upOpp.Other__c = newOpp.OtherTemp__c;
                        upOpp.Close__c = true;
                        upOpp.CloseType__c = '丢标/输单';
                        upOppList.add(upOpp);
                    }else{
                        break;
                    }
                }
            }
            
            if (upOppList.size() > 0) {
                update upOppList;
            }
        }
    }
}