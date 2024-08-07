/*
 * @Descripttion: 商机触发器
 * @Author: Devin
 * @Date: 2021-10-09 11:08:00
 * @LastEditors: Hogan
 * @LastEditTime: 2022-11-18 14:48:48
 */
public without sharing class OpportunityHandler implements Triggers.Handler{

    List<String> oppListFindManagerBySWZ = new List<String>();//大区

    List<String> oppListFindManagerByMBD = new List<String>();//客户分部

    // List<String> capacityList = new List<String>();

    public void handle() {

        //2022-01-11  irving
        if (Trigger.isBefore && Trigger.isInsert) {

            for(Opportunity opp : (List<Opportunity>)Trigger.new) {
                //如果商机的项目名称已经在系统存在
                Integer records = [SELECT count() FROM Opportunity WHERE Name =: opp.Name  ];
                if (records > 0) {
                    opp.addError('商机名称已重复，无法新建！请检查【风场项目名】、【期数】、【区县】字段是否补充完整，补充完整后可降低重复概率。若补充完整依然提示重复，则系统已存在相同商机，请勿新建！');
                }
            }

        }

        //更新之前
        if (Trigger.isBefore && Trigger.isUpdate) {
            //【商机已关闭】 值发生改变时, 加锁/解锁
            Set<Opportunity> closeOpportunitySet = new Set<Opportunity>();

            for(Opportunity newOpp : (List<Opportunity>)Trigger.new) {
                Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(newOpp.Id);
            
                //2021-12-28 【商机已关闭】 值发生改变时, 商机关闭 锁住记录/ 商机重启 解锁记录
                if (newOpp.Close__c != oldOpp.Close__c) {
                    closeOpportunitySet.add(newOpp);
                }
            }
            
            if (closeOpportunitySet.size() > 0) {
                LockAndUnLockOpportunity(closeOpportunitySet);
            }
        }

        //更新之后
        if (Trigger.isAfter && Trigger.isUpdate) {
            
            List<String> opportunityIdList = new List<String>();

            List<String> oppOwnerIdList = new List<String>();

            // Set<Id> shareOppSet = new Set<Id>();

            // List<Opportunity> manualOppList = new List<Opportunity>();

            System.debug('触发器进来了');
            for(Opportunity newOpp : (List<Opportunity>)Trigger.new) {
                Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(newOpp.Id);

                //满足条件的话，初始化新建SAP项目
                if (newOpp.ProjectSubmission__c!='历史项目' 
                && String.isEmpty(newOpp.ProjectNumber__c)
                && newOpp.OpportunityApprovalStatus__c != oldOpp.OpportunityApprovalStatus__c
                && (newOpp.OpportunityApprovalStatus__c == '线索提报通过' || newOpp.OpportunityApprovalStatus__c == '商机提报通过')) {
                    Controller_SAP4Project.SAP4ProjectAdd(newOpp.Id);
                }

                //sap项目创建，成功回传项目编号写入商机，则下达系统状态A1节点
                // if(!String.isEmpty(newOpp.ProjectNumber__c) && newOpp.ProjectNumber__c != oldOpp.ProjectNumber__c){
                //     Interface_Log__c logInfo = new Interface_Log__c();
                //     logInfo.IsSuccess__c = false;
                // logInfo.ErrorMessage__c = '！！！' + newOpp.ProjectNumber__c; 
                // insert logInfo;
                //     Controller_SAP4Project.SAP4ProjectStatusUpdate(newOpp.Id);
                // }

                if ((newOpp.Name != oldOpp.Name || newOpp.Periods__c != oldOpp.Periods__c || newOpp.AccountId != oldOpp.AccountId 
                        || newOpp.Province__c != oldOpp.Province__c || newOpp.City__c != oldOpp.City__c || newOpp.County__c != oldOpp.County__c 
                        || newOpp.Wind_Farm_Project_Name__c != oldOpp.Wind_Farm_Project_Name__c || newOpp.capacity__c != oldOpp.capacity__c) 
                    && (newOpp.StageName != oldOpp.StageName || newOpp.Close__c != oldOpp.Close__c) 
                    && String.isNotBlank(newOpp.ProjectNumber__c)
                    && newOpp.ProjectSubmission__c!='历史项目') {
                        //更新商机下项目的项目名称
                        updatePrjName(newOpp.Id);
                        Controller_SAP4Project.SAP4ProjectNameUpdateAndUpStatus(newOpp.Id);
                }else {
                    //商机名称变更，更新SAP项目名称  add:更新客户类型、产品类型、交付市场 by hogan ###### Wed Jul 3 16:47:45 CST 2024
                    if(newOpp.Name != oldOpp.Name && newOpp.ProjectSubmission__c!='历史项目'){
                        //更新商机下项目的项目名称
                        updatePrjName(newOpp.Id);
                        List<Contractmanagement__c> listContract = [SELECT Objectname2__c,WBS__c FROM Contractmanagement__c WHERE ObjectName__c =: newOpp.Id];
                        if (listContract.size() > 0) {
                            //更新商机下所有合同的sap项目名称和商机名称
                            for(Contractmanagement__c newContract : listContract) {
                                Controller_SAP4Project.SAP4ProjectNameUpdate(newContract.Objectname2__c, newContract.WBS__c, newOpp.Name, newOpp.Id);
                            }
                        }else {
                            //还未生成主合同，根据商机wbs更新sap项目名称和商机名称
                            Controller_SAP4Project.SAP4ProjectNameUpdate(newOpp.Name, newOpp.ProjectNumber__c, newOpp.Name, newOpp.Id);
                        }
                    }
                    //商机阶段变更
                    if((newOpp.StageName != oldOpp.StageName || newOpp.Close__c != oldOpp.Close__c) && String.isNotBlank(newOpp.ProjectNumber__c)){
                        // //设置SAP项目系统状态
                        // Controller_SAP4Project.SAP4ProjectStatusUpdate(newOpp.Id);
                        // //设置SAP项目用户状态
                        // Controller_SAP4Project.SAP4ProjectStatusUpdate2(newOpp.Id);
                        //更新商机下项目的项目名称
                        updatePrjName(newOpp.Id);
                        Controller_SAP4Project.SAP4ProjectNameUpdateAndUpStatus(newOpp.Id);
                    }
                }

                //商机关闭
                if(newOpp.Close__c != oldOpp.Close__c && String.isNotBlank(newOpp.ProjectNumber__c)){
                    //设置SAP项目用户状态
                    Controller_SAP4Project.SAP4ProjectStatusUpdate2(newOpp.Id);
                }

                // if (newOpp.capacity__c!=oldOpp.capacity__c) {
                //     capacityList.add(newOpp.id);
                // }

                if (newOpp.ProjectArea__c!=oldOpp.ProjectArea__c) {
                    oppListFindManagerBySWZ.add(newOpp.Id);
                }

                if (newOpp.MarketBidDept__c!=oldOpp.MarketBidDept__c) {
                    oppListFindManagerByMBD.add(newOpp.Id);
                }

                //立项审批通过，初始化商机的合同商务
                if(newOpp.Approvalstatus__c == '30' && newOpp.Approvalstatus__c != oldOpp.Approvalstatus__c){
                    opportunityIdList.add(newOpp.Id);
                }

                //OwnerId 发生改变时
                if (newOpp.OwnerId != oldOpp.OwnerId) {
                    oppOwnerIdList.add(newOpp.Id);
                }

                // if (newOpp.OpportunityApprovalStatus__c=='审批中') {
                //     shareOppSet.add(newOpp.id);
                // }

                //2022-02-21 防止用户手工修改 商机 阶段
                // if (newOpp.Is_Manual_Modification__c == false && newOpp.Is_Manual_Modification__c != oldOpp.Is_Manual_Modification__c) {
                //     manualOppList.add(newOpp);
                // }

            }

            // if (shareOppSet.size()>0) {
            //     shareAuthority(shareOppSet);
            // }
    
            // if(opportunityIdList.size() >0 ){
            //     createContractmanagement(opportunityIdList);
            // }

            if (oppOwnerIdList.size() > 0) {
                shareToOpportunityDepend(oppOwnerIdList);
            }

            if (oppListFindManagerBySWZ.size()>0) {
                OppManagerHandler.FindManagerBySWZ(oppListFindManagerBySWZ);
            }

            if (oppListFindManagerByMBD.size()>0) {
                OppManagerHandler.FindManagerByMBD(oppListFindManagerByMBD);
            }

            // if (manualOppList.size() > 0) {

            //     List<Opportunity> updateManuaList = new List<Opportunity>();

            //     List<Id> lockOpportunityIdList = new List<Id>();

            //     for (Opportunity manua : manualOppList) {
            //         Opportunity updateManua = new Opportunity();
            //         updateManua.Id = manua.Id;
            //         if(Approval.isLocked(manua.Id)){
            //             Approval.unlock(manua.Id, false);
            //             lockOpportunityIdList.add(manua.Id);
            //         }
            //         updateManua.Is_Manual_Modification__c = true;//防止用户手工修改 商机阶段， 只能由系统逻辑自动修改
            //         updateManuaList.add(updateManua);
            //     }

            //     update updateManuaList;

            //     //重新给需要加锁的商机，加锁
            //     Approval.lock(lockOpportunityIdList, false);
            // }

        }

        //更新项目客户类型、项目产品类型、项目交付市场 TO SAP
        if (Trigger.isAfter && Trigger.isUpdate) {
            for(Opportunity newOpp : (List<Opportunity>)Trigger.new) {
                Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(newOpp.Id);
                if (newOpp.ProjectCustomerType__c != oldOpp.ProjectCustomerType__c 
                || newOpp.ProjectProductType__c != oldOpp.ProjectProductType__c 
                || newOpp.ProjectDeliveryMarket__c != oldOpp.ProjectDeliveryMarket__c) {

                    List<Contractmanagement__c> listContract = [SELECT Objectname2__c,WBS__c FROM Contractmanagement__c WHERE ObjectName__c =: newOpp.Id];

                    if (listContract.size() > 0) {
                        //更新商机下所有合同的sap项目名称和商机名称
                        for(Contractmanagement__c newContract : listContract) {
                            Controller_SAP4Project.SAP4ProjectFieldUpdate(newContract.WBS__c, newOpp.Id);
                        }
                    }else {
                        //还未生成主合同
                        Controller_SAP4Project.SAP4ProjectFieldUpdate(newOpp.ProjectNumber__c, newOpp.Id);
                    }

                }
            }
        }

        //插入之后
        if (Trigger.isAfter && Trigger.isInsert) {
            System.debug('进入到商机新增触发器');
            Map<Id,Opportunity> newMap = (Map<Id,Opportunity>)Trigger.newMap;

            // for (Opportunity opp :newMap.values()) {
            //   if (opp.capacity__c!=null) {
            //     capacityList.add(opp.id);
            //   }  
            // }
            
            //初始化新建合同商务
            // List<Contractmanagement__c> cmList = new List<Contractmanagement__c>();
            // for (String oppId : newMap.keySet()) {
            //     Contractmanagement__c cm = new Contractmanagement__c();
            //     cm.ObjectName__c = oppId;
            //     cmList.add(cm);
            // }
            // insert cmList;

            for (Opportunity opp : newMap.values()) {

                //商机阶段初始化，更新SAP项目状态
                // Controller_SAP4Project.SAP4ProjectStatusUpdate(newOpp.Id);

               if (opp.ProjectArea__c!=null) {
                oppListFindManagerBySWZ.add(opp.Id);
               }

               if (opp.MarketBidDept__c!=null) {
                oppListFindManagerByMBD.add(opp.Id);
               }
            }

            if (oppListFindManagerBySWZ.size()>0) {
                OppManagerHandler.FindManagerBySWZ(oppListFindManagerBySWZ);
            }

            if (oppListFindManagerByMBD.size()>0) {
                OppManagerHandler.FindManagerByMBD(oppListFindManagerByMBD);
            }
        }

        // if (capacityList.size()>0) {
        //     capacityMethod(capacityList);
        // }


        //插入之后
        // if (Trigger.isAfter && Trigger.isInsert) {
        //     for(Opportunity opp : (List<Opportunity>)Trigger.new) {
        //         //新增商机团队：大区/二级公司总经理
        //         if(opp.Chiefgeneralmanager__c != null){
        //             OpportunityTeamMember insertTeam1 = new OpportunityTeamMember();
        //             insertTeam1.OpportunityId = opp.Id;
        //             insertTeam1.OpportunityAccessLevel = 'read';
        //             insertTeam1.TeamMemberRole = '区域总经理';
        //             insertTeam1.UserId = opp.Chiefgeneralmanager__c;
        //             insert insertTeam1;
        //         }

        //         //新增商机团队：大客户总经理
        //         if(opp.Key_Account_General_Manager__c != null){
        //             OpportunityTeamMember insertTeam2 = new OpportunityTeamMember();
        //             insertTeam2.OpportunityId = opp.Id;
        //             insertTeam2.OpportunityAccessLevel = 'read';
        //             insertTeam2.TeamMemberRole = '大客户总经理';
        //             insertTeam2.UserId = opp.Key_Account_General_Manager__c;
        //             insert insertTeam2;
        //         }

        //         //新增商机团队：售前项目经理
        //         if(opp.Pre_Sales_Project_Manager__c != null){
        //             OpportunityTeamMember insertTeam3 = new OpportunityTeamMember();
        //             insertTeam3.OpportunityId = opp.Id;
        //             insertTeam3.OpportunityAccessLevel = 'read';
        //             insertTeam3.TeamMemberRole = '售前项目经理';
        //             insertTeam3.UserId = opp.Pre_Sales_Project_Manager__c;
        //             insert insertTeam3;
        //         }
        //     }
        // }
        //更新之后
        if (Trigger.isAfter && Trigger.isUpdate) {

            for(Opportunity newOpp : (List<Opportunity>)Trigger.new) {
                Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(newOpp.Id);

                //更新商机团队（总经理发生变更：大区/二级公司总经理）
                if(newOpp.Chiefgeneralmanager__c != oldOpp.Chiefgeneralmanager__c){
                    System.debug('>>>>>>>>>>>');
                    String chief = newOpp.Chiefgeneralmanager__c;
                    List<OpportunityTeamMember> oppTeam = [SELECT ID FROM OpportunityTeamMember 
                    WHERE OpportunityId =: newOpp.Id and UserId =: oldOpp.Chiefgeneralmanager__c LIMIT 1];
                    //存在旧的总经理，删除成员
                    if (oppTeam != null) {
                        delete oppTeam;
                    }
                    OpportunityTeamMember insertTeam = new OpportunityTeamMember();
                    insertTeam.OpportunityId = newOpp.Id;
                    insertTeam.OpportunityAccessLevel = 'read';
                    insertTeam.TeamMemberRole = '区域总经理';
                    insertTeam.UserId = newOpp.Chiefgeneralmanager__c;
                    insert insertTeam;
                }
                
                //更新商机团队（总经理发生变更：大客户总经理）
                if(newOpp.Key_Account_General_Manager__c != oldOpp.Key_Account_General_Manager__c){
                    List<OpportunityTeamMember> oppTeam = [SELECT ID FROM OpportunityTeamMember 
                    WHERE OpportunityId =: newOpp.Id and UserId =: oldOpp.Key_Account_General_Manager__c LIMIT 1];
                    //存在旧的总经理，删除成员
                    if (oppTeam != null) {
                        delete oppTeam;
                    }
                    OpportunityTeamMember insertTeam = new OpportunityTeamMember();
                    insertTeam.OpportunityId = newOpp.Id;
                    insertTeam.OpportunityAccessLevel = 'read';
                    insertTeam.TeamMemberRole = '大客户总经理';
                    insertTeam.UserId = newOpp.Key_Account_General_Manager__c;
                    insert insertTeam;
                }

                //更新商机团队（总经理发生变更：售前项目经理）
                if(newOpp.Pre_Sales_Project_Manager__c != oldOpp.Pre_Sales_Project_Manager__c){
                    List<OpportunityTeamMember> oppTeam = [SELECT ID FROM OpportunityTeamMember 
                    WHERE OpportunityId =: newOpp.Id and UserId =: oldOpp.Pre_Sales_Project_Manager__c LIMIT 1];
                    //存在旧的总经理，删除成员
                    if (oppTeam != null) {
                        delete oppTeam;
                    }
                    OpportunityTeamMember insertTeam = new OpportunityTeamMember();
                    insertTeam.OpportunityId = newOpp.Id;
                    insertTeam.OpportunityAccessLevel = 'read';
                    insertTeam.TeamMemberRole = '售前项目经理';
                    insertTeam.UserId = newOpp.Pre_Sales_Project_Manager__c;
                    insert insertTeam;
                }
            }
        }
        
    }

    /**
     * @Descripttion: 更新商机下项目的项目名称
     * @Author: irving
     * @param {*}
     * @return {*}
     */
    public void updatePrjName(String oppId){
        List<Contractmanagement__c> listContract = [SELECT Id,Objectname2__c FROM Contractmanagement__c WHERE ObjectName__c =: oppId];
        if (listContract.size() > 0) {
            //更新商机下所有合同的sap项目名称和商机名称
            for(Contractmanagement__c newContract : listContract) {
                //###### Wed Oct 11 14:37:18 CST 2023 补充更新商机下合同下项目的项目名称
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


    /**
     * @Descripttion: 文本容量把所有的中文去掉 取前段数字
     * @Author: irving
     * @param {*}
     * @return {*}
     */
    // public void capacityMethod(List<String> capacityList) {

    //     List<Opportunity>  oppList = [select id,name,capacity__c,TotalMW__c from Opportunity where id in:capacityList];

    //     for (Opportunity opp : oppList) {
    //         if (opp.capacity__c==null) {
    //             opp.TotalMW__c = null ; 
    //         }else{
    //         //    String s =  opp.capacity__c.replaceAll('([\u4E00-\u9FA5]+)|([a-zA-Z])', '_').substringBefore('_');

    //         //   if (s.isNumeric()) {
    //         //     Double d = Double.valueOf(s);
    //         //     Integer l  = (Integer)d.round();
    //         //     opp.TotalMW__c = l ; 
    //         //   }
    //             opp.TotalMW__c = opp.capacity__c;
    //         }
          
    //     }

    //     update oppList ; 
    // }

    /**
     * @Descripttion: 商机下的所有人发生改变时，共享：方案申请、项目立项、修改 Owner合同商务
     * @Author: Devin
     * @param {*}
     * @return {*}
     */
    public void shareToOpportunityDepend(List<String> projectIdSet) {

        List<Opportunity> opportunityList = new List<Opportunity>();

        opportunityList = [SELECT   Id,
                                    OwnerId,
                                    (SELECT Id,ownerId FROM Form_Opp__r),//营销项目方案申请单
                                    (SELECT Id,ownerId FROM Oppty__r)//营销项目立项申请
                                    // (SELECT Id,OwnerId FROM ContractApproval_Opp__r)//合同商务
                                FROM 
                                    Opportunity 
                                WHERE 
                                    Id IN: projectIdSet
                                ];

        //营销项目方案申请单
        List<Project_Scheme_Application_Form__Share> pasfShareList = new List<Project_Scheme_Application_Form__Share>();
        //营销项目立项申请
        List<Projectapplication__Share> applicationShareList = new List<Projectapplication__Share>();
        //合同商务
        // List<Contractmanagement__c> cgOwnerIdListList = new List<Contractmanagement__c>();

        for(Opportunity opp : opportunityList) {

            //营销项目方案申请单
            for (Project_Scheme_Application_Form__c psaf : opp.Form_Opp__r) {
                
                //所有人 和 业务机会的 所有人不一样
                //一样的话  会出现错误
                if (psaf.OwnerId != opp.OwnerId) {
                    Project_Scheme_Application_Form__Share pasfShare = new Project_Scheme_Application_Form__Share();
                    pasfShare.ParentId = psaf.Id;
                    pasfShare.UserOrGroupId = opp.OwnerId;//分配给商机所有人
                    pasfShare.AccessLevel = 'edit';
                    pasfShareList.add(pasfShare);
                }
            }

            //营销项目立项申请
            for (Projectapplication__c application : opp.Oppty__r) {
                
                //所有人 和 业务机会的 所有人不一样
                //一样的话  会出现错误
                if (application.OwnerId != opp.OwnerId) {
                    Projectapplication__Share applicationShare = new Projectapplication__Share();
                    applicationShare.ParentId = application.Id;
                    applicationShare.UserOrGroupId = opp.OwnerId;//分配给商机所有人
                    applicationShare.AccessLevel = 'edit';
                    applicationShareList.add(applicationShare);
                }
            }

            //合同商务
            // for (Contractmanagement__c cg :opp.ContractApproval_Opp__r) {
            //     Contractmanagement__c changeOwnerId = new Contractmanagement__c();
            //     changeOwnerId.Id = cg.Id;
            //     changeOwnerId.OwnerId = opp.OwnerId;//修改所有人
            //     cgOwnerIdListList.add(changeOwnerId);
            // }
        }

        System.debug('pasfShareList---'+pasfShareList);
        System.debug('applicationShareList---'+applicationShareList);
        // System.debug('cgOwnerIdListList---'+cgOwnerIdListList);

        Database.insert(pasfShareList,true);//营销项目方案申请单
        Database.insert(applicationShareList,true);//营销项目立项申请
        // Database.update(cgOwnerIdListList,false);//合同商务
    }


    /**
     * @Descripttion: 发起申报审批时,共享给大区/二级公司总经理  大客户总经理
     * @Author: irving
     * @param {*}
     * @return {*}
     */   
    // public void shareAuthority(Set<Id> shareOppSet) {

    //     List<Opportunity> oppList = new List<Opportunity>();

    //     oppList = [SELECT Id,
    //                         Key_Account_General_Manager__c,  //大客户总经理*
    //                         Chiefgeneralmanager__c  //大区/二级公司总经理*
    //                         FROM Opportunity WHERE Id IN: shareOppSet];

    //     List<OpportunityShare> insertList = new List<OpportunityShare>();

    //     for (Opportunity l : oppList) {
    //         OpportunityShare share = new OpportunityShare();
    //         share.OpportunityId = l.Id;
    //         share.UserOrGroupId = l.Key_Account_General_Manager__c;   //分配给---
    //         share.OpportunityAccessLevel = 'Read';
    //         insertList.add(share);
    //     }

    //     for (Opportunity l : oppList) {
    //         OpportunityShare share = new OpportunityShare();
    //         share.OpportunityId = l.Id;
    //         share.UserOrGroupId = l.Chiefgeneralmanager__c;   //分配给---
    //         share.OpportunityAccessLevel = 'Read';
    //         insertList.add(share);
    //     }

    //     System.debug('insertList---'+insertList);

    //     Database.insert(insertList,false);

    // }

    /**
     * @Descripttion: 【商机已关闭】 值发生改变时, 商机关闭 锁住记录/ 商机重启 解锁记录
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    public void LockAndUnLockOpportunity(Set<Opportunity> oppSet) {

        //加锁
        List<Opportunity> lockOpportunityList = new List<Opportunity>();
        //解锁
        List<Opportunity> unLockOpportunityList = new List<Opportunity>();

        for (Opportunity opp : oppSet) {
            //商机关闭  加锁
            if (opp.Close__c) {
                lockOpportunityList.add(opp);
            } else {
                //商机重启  解锁
                unLockOpportunityList.add(opp);
            }
            //修改SAP项目商机状态
            Controller_SAP4Project.SAP4ProjectStatusMaintain(opp.Id);
        }

        System.debug('lockOpportunityList-----'+lockOpportunityList);
        System.debug('unLockOpportunityList-----'+unLockOpportunityList);

        //加锁
        if (!lockOpportunityList.isEmpty()) {
            List<Approval.LockResult> lrList = Approval.lock(lockOpportunityList, false);
            // Iterate through each returned result
            for(Approval.LockResult lr : lrList) {
                if (lr.isSuccess()) {
                    //Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully locked account with ID: ' + lr.getId());
                }
                else {
                    //Operation failed, so get all errors                
                    for(Database.Error err : lr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }

        //解锁
        if (!unLockOpportunityList.isEmpty()) {
            //Unlock records
            List<Approval.UnlockResult> ulrList = Approval.unlock(unLockOpportunityList, false);
            
            // Iterate through each returned result
            for(Approval.UnlockResult  ulr : ulrList) {
                if (ulr.isSuccess()) {
                    //Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully unlocked account with ID: ' + ulr.getId());
                }
                else {
                    //Operation failed, so get all errors                
                    for(Database.Error err : ulr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }
}