/**
 * @description       : Maintenance Part Trigger Helper. 
 * @author            : Falgun Panara
 * @group             : 
 * @last modified on  : 09-26-2021
 * @last modified by  : fpanara
**/
public class MaintenancePartTriggerHelper {

    //After Insert
    public static void afterInsert(List<Maintenance_Part__c> maintenanceParts) {
        List<Id> partInventoryIdList = new List<Id>();
        List<Id> maintenancePartIdList = new List<Id>();
        List<Part_Inventory__c> updatedPartInventoryList = new List<Part_Inventory__c>();

        //Searching for the correct data
        for (Maintenance_Part__c objMaintenancePart : maintenanceParts) {
            if(objMaintenancePart.Qty_Utilized__c > 0 && objMaintenancePart.Part_Inventory__c != null){
                partInventoryIdList.add(objMaintenancePart.Part_Inventory__c);
                maintenancePartIdList.add(objMaintenancePart.Id);
            }
        }

        //Checking whether the child item has sufficient stock
        if(partInventoryIdList.size() > 0){
            List<Part_Inventory__c> childPartInventoryList = [SELECT Id, Qty_In_Stock__c, Child_Part_Qty__c, Name, (SELECT ID, Qty_Utilized__c FROM Maintenance_Parts__r) FROM Part_Inventory__c WHERE Parent__c in :partInventoryIdList];
            
            for (Part_Inventory__c objChildPartInventory : childPartInventoryList) {
                for (Maintenance_Part__c objMaintenancePart : objChildPartInventory.Maintenance_Parts__r){
                    
                    If((objMaintenancePart.Qty_Utilized__c * objChildPartInventory.Child_Part_Qty__c) > objChildPartInventory.Qty_In_Stock__c){
                        throwError(maintenanceParts, objChildPartInventory.Name);
                    }
                }
            }
        }

        //Adjusting the stock after insert of maintenance part
        if(partInventoryIdList.size() > 0){
            List<Part_Inventory__c> partInventoryList = [SELECT Id, Qty_In_Stock__c, Min_Qty_Reminder__c, Name, (SELECT ID, Qty_Utilized__c FROM Maintenance_Parts__r) FROM Part_Inventory__c WHERE Id in :partInventoryIdList];
            
            for (Part_Inventory__c objPartInventory : partInventoryList) {
                for (Maintenance_Part__c objMaintenancePart : objPartInventory.Maintenance_Parts__r){
                    If(maintenancePartIdList.Contains(objMaintenancePart.Id)){
                        objPartInventory.Qty_In_Stock__c = objPartInventory.Qty_In_Stock__c - objMaintenancePart.Qty_Utilized__c;
                    }
                }
                updatedPartInventoryList.add(objPartInventory);
            }
        }

        
        if(updatedPartInventoryList.size() > 0){
            update updatedPartInventoryList;
            checkMinQtyReminder(updatedPartInventoryList);
        }
    }

    //After Update
    public static void afterUpdate(List<Maintenance_Part__c> newMaintenancePartsList, Map<Id, Maintenance_Part__c> oldMaintenancePartsMap) {

        List<Id> partInventoryIdList = new List<Id>();
        List<Id> maintenancePartIdListAdd = new List<Id>();
        List<Part_Inventory__c> updatedPartInventoryList = new List<Part_Inventory__c>();
        List<Id> maintenancePartIdListSub = new List<Id>();

        //Searching for the data
        for (Maintenance_Part__c objMaintenancePart : newMaintenancePartsList) {

            Maintenance_Part__c oldMaintenancePart = oldMaintenancePartsMap.get(objMaintenancePart.Id);

            if(objMaintenancePart.Qty_Utilized__c > 0 && objMaintenancePart.Part_Inventory__c != null && objMaintenancePart.Qty_Utilized__c > oldMaintenancePart.Qty_Utilized__c){
                
                maintenancePartIdListAdd.add(objMaintenancePart.Id);
            }
            else {
                maintenancePartIdListSub.add(objMaintenancePart.Id);
            }
            partInventoryIdList.add(objMaintenancePart.Part_Inventory__c);
        }

        //Adjusting the inventory count
        if(partInventoryIdList.size() > 0){
            List<Part_Inventory__c> partInventoryList = [SELECT Id, Qty_In_Stock__c, Min_Qty_Reminder__c, Name, (SELECT ID, Qty_Utilized__c FROM Maintenance_Parts__r) FROM Part_Inventory__c WHERE Id in :partInventoryIdList];
            
            for (Part_Inventory__c objPartInventory : partInventoryList) {
                for (Maintenance_Part__c objMaintenancePart : objPartInventory.Maintenance_Parts__r){
                    If(maintenancePartIdListAdd.Contains(objMaintenancePart.Id)){
                        Maintenance_Part__c oldMaintenancePart = oldMaintenancePartsMap.get(objMaintenancePart.Id);
                        if(oldMaintenancePart.Qty_Utilized__c < objMaintenancePart.Qty_Utilized__c){
                            objPartInventory.Qty_In_Stock__c = objPartInventory.Qty_In_Stock__c - (objMaintenancePart.Qty_Utilized__c - oldMaintenancePart.Qty_Utilized__c);
                        }
                    }
                    If(maintenancePartIdListSub.Contains(objMaintenancePart.Id)){
                        Maintenance_Part__c oldMaintenancePart = oldMaintenancePartsMap.get(objMaintenancePart.Id);
                        if(oldMaintenancePart.Qty_Utilized__c > objMaintenancePart.Qty_Utilized__c){
                            objPartInventory.Qty_In_Stock__c = objPartInventory.Qty_In_Stock__c + (oldMaintenancePart.Qty_Utilized__c - objMaintenancePart.Qty_Utilized__c);
                        }
                    }
                }
                updatedPartInventoryList.add(objPartInventory);
            }
        }
        if(updatedPartInventoryList.size() > 0){
            update updatedPartInventoryList;
            checkMinQtyReminder(updatedPartInventoryList);
        }
    }

    //Sending minimum Qty reminder
    private static void checkMinQtyReminder(List<Part_Inventory__c> pareInventoryList){
        List<FeedItem> feedItemList = new List<FeedItem>();
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        // Get the Id for our custom notification type
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Notifications'];

        for (Part_Inventory__c objPareInventory : pareInventoryList) {
            if(objPareInventory.Qty_In_Stock__c < objPareInventory.Min_Qty_Reminder__c){
                ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                input.subjectId = objPareInventory.id;
                ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
                body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = 'Please refill this part immediately.';
                body.messageSegments.add(textSegment);
                input.body = body;

                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                batchInputs.add(batchInput);
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);

                // Create a new custom notification
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                            
                // Set the contents for the notification
                notification.setTitle('LOW INVENTORY');
                notification.setBody('Please refill this part ' + objPareInventory.Name + '.');
                    
                // Set the notification type and target
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(objPareInventory.Id);
                            
                Set<String> addressee = new Set<String>();
                addressee.add('0055g00000Cn55TAAR');
                            
                // Actually send the notification
                try {
                    notification.send(addressee);
                }
                catch (Exception e) {
                    System.debug('Problem sending notification: ' + e.getMessage());
                }
            }
        }
    }

    //Throw error to refill the part
    private static void throwError(List<Maintenance_Part__c> maintenanceParts, String name){
        for (Maintenance_Part__c objMaintenancePart : maintenanceParts) {
            objMaintenancePart.addError('Please refill the part ' + Name);
        }
    }
}
