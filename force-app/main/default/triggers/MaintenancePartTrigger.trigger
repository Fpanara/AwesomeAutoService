/**
 * @description       : MaintenancePartTrigger
 * @author            : fpanara
 * @group             : 
 * @last modified on  : 09-26-2021
 * @last modified by  : fpanara
**/
trigger MaintenancePartTrigger on Maintenance_Part__c (before insert, after insert, before update, after update) {
    switch on Trigger.operationType {  
        when AFTER_INSERT {
            MaintenancePartTriggerHelper.afterInsert(trigger.new);
        }
        when AFTER_UPDATE {
            MaintenancePartTriggerHelper.afterUpdate(trigger.new, trigger.oldMap);
        }      
    }
}