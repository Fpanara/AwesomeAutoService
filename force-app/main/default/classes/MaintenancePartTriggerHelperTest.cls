/**
 * @description       : Helper test class
 * @author            : fpanara
 * @group             : 
 * @last modified on  : 09-26-2021
 * @last modified by  : fpanara
**/
@isTest
public class MaintenancePartTriggerHelperTest {
    @testsetup static void dataSetup(){
    Account act = new Account(Name = 'Test Account');
    insert act;

    Contact con = new Contact(LastName = 'Test Contact', AccountId = act.Id);
    insert con;

    Vehicle__c vehicle = new Vehicle__c(Contact__c = con.Id, Name = 'Test Vehicle', Make__c = 'TATA', Model__c = 'Test MOdel');
    insert vehicle;

    Maintenance_Reuest__c maintenanceRequest = new Maintenance_Reuest__c(Vehicle__c = vehicle.Id);
    insert maintenanceRequest;

    List<Part_Inventory__c> objParentPartInventoryList = new List<Part_Inventory__c>();
    List<Part_Inventory__c> objChildPartInventoryList = new List<Part_Inventory__c>();
    
    for(integer i = 1; i<= 2; i++){
        Part_Inventory__c partInventory = new Part_Inventory__c(Name = 'Parent Part ' + i, Qty_In_Stock__c = 100);
        objParentPartInventoryList.add(partInventory);
    }
    insert objParentPartInventoryList;

    for (Part_Inventory__c objPartInventory : objParentPartInventoryList) {
        for (integer i =1; i <= 5; i++) {
            Part_Inventory__c partInventory = new Part_Inventory__c(Name = 'Child Part ' + i, Qty_In_Stock__c = 100, Min_Qty_Reminder__c = 5, Parent__c = objPartInventory.Id, Child_Part_Qty__c = 50);
            objChildPartInventoryList.add(partInventory);
        }
    }
    insert objChildPartInventoryList;
    }

    @istest static void afterInsertAfterUpdatePosisiveTest(){

        List<Maintenance_Reuest__c> maintenanceRequestList = [SELECT Id FROM Maintenance_Reuest__c];
        List<Part_Inventory__c>  parentPartInventoryList = [SELECT ID, Qty_In_Stock__c, Min_Qty_Reminder__c, Parent__c, Child_Part_Qty__c FROM Part_Inventory__c WHERE Parent__c = null];
        List<Part_Inventory__c>  childPartInventoryList = [SELECT ID, Qty_In_Stock__c, Min_Qty_Reminder__c, Parent__c, Child_Part_Qty__c FROM Part_Inventory__c WHERE Parent__c != null];
        
        Maintenance_Part__c maintenancePart = new Maintenance_Part__c(Maintenance_Request__c = maintenanceRequestList[0].Id, Part_Inventory__c = parentPartInventoryList[0].Id, Qty_Utilized__c = 5);
        Test.startTest();
        insert maintenancePart;        
        
        System.System.assertEquals(parentPartInventoryList[0].Qty_In_Stock__c - maintenancePart.Qty_Utilized__c, 95);

        maintenancePart.Qty_Utilized__c = 10;
        update maintenancePart;
        Test.stopTest();

        System.System.assertEquals(parentPartInventoryList[0].Qty_In_Stock__c - maintenancePart.Qty_Utilized__c, 90);
    }

        @istest static void afterInsertAfterUpdateNegativeTest(){

        List<Maintenance_Reuest__c> maintenanceRequestList = [SELECT Id FROM Maintenance_Reuest__c];
        List<Part_Inventory__c>  parentPartInventoryList = [SELECT ID, Qty_In_Stock__c, Min_Qty_Reminder__c, Parent__c, Child_Part_Qty__c FROM Part_Inventory__c WHERE Parent__c = null];
        List<Part_Inventory__c>  childPartInventoryList = [SELECT ID, Qty_In_Stock__c, Min_Qty_Reminder__c, Parent__c, Child_Part_Qty__c FROM Part_Inventory__c WHERE Parent__c != null];
        
        Maintenance_Part__c maintenancePart = new Maintenance_Part__c(Maintenance_Request__c = maintenanceRequestList[0].Id, Part_Inventory__c = parentPartInventoryList[0].Id, Qty_Utilized__c = 10);
        Test.startTest();
        insert maintenancePart;        
        
        System.System.assertEquals(parentPartInventoryList[0].Qty_In_Stock__c - maintenancePart.Qty_Utilized__c, 90);

        maintenancePart.Qty_Utilized__c = 5;
        update maintenancePart;
        
        System.System.assertEquals(parentPartInventoryList[0].Qty_In_Stock__c - maintenancePart.Qty_Utilized__c, 95);

        Test.stopTest();
    }
}