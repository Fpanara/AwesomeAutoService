/**
 * @description       : Maintenance Part Trigger Helper. 
 * @author            : Falgun Panara
 * @group             : 
 * @last modified on  : 09-28-2021
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
        checkingForSufficientStock(partInventoryIdList, maintenanceParts, null);

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

        
        //Checking whether the child item has sufficient stock
        checkingForSufficientStock(partInventoryIdList, newMaintenancePartsList, oldMaintenancePartsMap);

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
        }
    }


    //Throw error to refill the part
    private static void throwError(List<Maintenance_Part__c> maintenanceParts, String name){
        for (Maintenance_Part__c objMaintenancePart : maintenanceParts) {
            objMaintenancePart.addError('Please refill the part ' + Name);
        }
    }

    private static void checkingForSufficientStock(List<Id> partInventoryIdList, List<Maintenance_Part__c> maintenanceParts, Map<Id, Maintenance_Part__c> oldMaintenancePartsMap){
         //Checking whether the child item has sufficient stock
        if(partInventoryIdList.size() > 0){
            List<Part_Inventory__c> childPartInventoryList = [SELECT Id, Qty_In_Stock__c, Child_Part_Qty__c,Parent__c, Min_Qty_Reminder__c, Name FROM Part_Inventory__c WHERE Parent__c in :partInventoryIdList];
    
            for(Maintenance_Part__c objMaintenancePart : maintenanceParts){
                if(oldMaintenancePartsMap != null){
                    Maintenance_Part__c oldMaintenancePart = oldMaintenancePartsMap.get(objMaintenancePart.Id);
                    
                    if(objMaintenancePart.Qty_Utilized__c > oldMaintenancePart.Qty_Utilized__c) //Validating the stock if there's an addition in utilized qty
                        for(Id objId: partInventoryIdList){
                            if(objMaintenancePart.Part_Inventory__c == objId){
                                for (Part_Inventory__c objChildPartInventory : childPartInventoryList) {
                                    if(objChildPartInventory.Parent__c == objId){
                                        If(((objMaintenancePart.Qty_Utilized__c - oldMaintenancePart.Qty_Utilized__c) * objChildPartInventory.Child_Part_Qty__c) > objChildPartInventory.Qty_In_Stock__c){
                                            throwError(maintenanceParts, objChildPartInventory.Name);
                                        }
                                    } 
                                }
                            }  
                        }
                }
                else {
                   for(Id objId: partInventoryIdList){
                        if(objMaintenancePart.Part_Inventory__c == objId){
                            for (Part_Inventory__c objChildPartInventory : childPartInventoryList) {
                                if(objChildPartInventory.Parent__c == objId){
                                    If((objMaintenancePart.Qty_Utilized__c * objChildPartInventory.Child_Part_Qty__c) > objChildPartInventory.Qty_In_Stock__c){
                                        throwError(maintenanceParts, objChildPartInventory.Name);
                                    }
                                } 
                            }
                        }  
                    }         
                }
            }
        }
    }
}