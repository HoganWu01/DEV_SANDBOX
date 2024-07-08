/*
 * @Author: irving
 * @Date: 2021-09-27 16:13:00
 * @LastEditTime: 2022-01-24 11:06:54
 * @LastEditors: Please set LastEditors
 * @Description: 手动创合同商务，项目编号为空，触发SAP标段项目创建接口
 */
global without sharing class ProjectCreateHandler implements Triggers.Handler {

    public void handle(){

        if (Trigger.isBefore && Trigger.isInsert) {

            for(Contractmanagement__c contract : (List<Contractmanagement__c>)Trigger.new) {
                if (contract.ObjectName__c != null) {
                    Opportunity opp = [select StageName from Opportunity where id =: contract.ObjectName__c];
                    if ( 
                        opp.StageName != '招投标' 
                        && opp.StageName != '中标/赢单' 
                        && opp.StageName != '合同商务' 
                        && opp.StageName != 'Closed Won') {
                            contract.addError('商机进入“招投标”后才能新建标段合同！');
                        }
                }else {
                    contract.addError('请选择商机！');
                }
            }
        }

        if (Trigger.isAfter && Trigger.isInsert) {

            for(Contractmanagement__c newContract : (List<Contractmanagement__c>)Trigger.new) {
                //当前新增的{合同商务}，其商机【项目提报类型】=“历史项目”，且当前{合同商务}是该商机的唯一关联{合同商务}，则不创建SAP项目；
                // System.debug('>>>>>>'+newContract.ObjectName__r.ProjectSubmission__c);
                Opportunity opp = [select ProjectSubmission__c,Close__c from Opportunity where id =: newContract.ObjectName__c];
                // System.debug('>>>>>>'+opp.ProjectSubmission__c);
                if (opp.ProjectSubmission__c == '历史项目') {
                    List<Contractmanagement__c> conTemp = [select id from Contractmanagement__c WHERE ObjectName__c =: newContract.ObjectName__c];
                    if (conTemp.size() == 1) {
                        break;
                    }
                }
                //项目编号为空,商机未关闭，非历史项目，新建SAP标段项目
                if ((String.isBlank(newContract.WBS__c) || String.isEmpty(newContract.WBS__c))
                &&opp.ProjectSubmission__c!='历史项目'
                &&opp.Close__c==false) {
                    Controller_SAP4Project.SAP4SectionProjectAdd(newContract.ObjectName__c, newContract.Id);
                }
            }
        }

        //合同商务项目名称更新，同时更新SAP项目名称
        if (Trigger.isAfter && Trigger.isUpdate) {

            for(Contractmanagement__c newContract : (List<Contractmanagement__c>)Trigger.new) {
                Contractmanagement__c oldContract = (Contractmanagement__c)Trigger.oldMap.get(newContract.Id);
                Opportunity opp = [select ProjectSubmission__c from Opportunity where id =: newContract.ObjectName__c];
                if(newContract.Objectname2__c != oldContract.Objectname2__c 
                && String.isNotBlank(newContract.WBS__c)
                && opp.ProjectSubmission__c!='历史项目'){
                    //更新SAP项目名称
                    Controller_SAP4Project.SAP4ProjectNameUpdate(newContract.Objectname2__c, newContract.WBS__c, newContract.OpportunityName__c, newContract.ObjectName__c);
                }
            }
        }

        //合同商务项目名称更新，同时更新到项目对象
        if (Trigger.isAfter && Trigger.isUpdate) {

            for(Contractmanagement__c newContract : (List<Contractmanagement__c>)Trigger.new) {
                Contractmanagement__c oldContract = (Contractmanagement__c)Trigger.oldMap.get(newContract.Id);
                if(newContract.Objectname2__c != oldContract.Objectname2__c){
                    //更新项目的项目名称
                    List<Project__c> proList = [select id,name from Project__c where Contract__c =: newContract.Id];
                    if (proList.size()>0) {
                        Project__c upPro = new Project__c();
                        upPro.Id = proList[0].id;
                        upPro.Name = newContract.Objectname2__c;
                        update upPro;
                    }
                }
            }
        }
        
    }
}