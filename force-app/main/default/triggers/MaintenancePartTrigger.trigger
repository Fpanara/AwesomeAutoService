/**
 * @description       : Maintenance Part Trigger.
 * @author            : Falgun Panara
 * @group             : 
 * @last modified on  : 09-26-2021
 * @last modified by  : fpanara
**/
trigger MaintenancePartTrigger on Maintenance_Part__c (after insert, after update) {
    switch on Trigger.operationType {
    
        when AFTER_INSERT {
            //calling helper calss for bulk update record type (department)
            MaintenancePartTriggerHelper.afterInsert(trigger.new);
        }
        when AFTER_UPDATE {
            MaintenancePartTriggerHelper.afterUpdate(trigger.new, trigger.oldMap);
        }      
    }
}