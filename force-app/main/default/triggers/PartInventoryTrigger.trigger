/**
 * @description       : 
 * @author            : fpanara
 * @group             : 
 * @last modified on  : 09-26-2021
 * @last modified by  : fpanara
**/

trigger PartInventoryTrigger on Part_Inventory__c (after insert, after update) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            PartInventoryTriggerHelper.afterInsertAfterUpdateHandler(trigger.new);
        }
        when AFTER_UPDATE {
            PartInventoryTriggerHelper.afterInsertAfterUpdateHandler(trigger.new);
        }
          
    }
}