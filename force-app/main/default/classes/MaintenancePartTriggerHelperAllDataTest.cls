/**
 * @description       : MaintenancePartTriggerHelper Test Class with see all data.
 * @author            : fpanara
 * @group             : 
 * @last modified on  : 09-26-2021
 * @last modified by  : fpanara
**/
@isTest
private class MaintenancePartTriggerHelperAllDataTest {
    @IsTest(SeeAllData=true)
    static void afterInsertWithSeeAllData(){

        Account act = new Account(Name = 'Test Account');
        insert act;

        Contact con = new Contact(LastName = 'Test Contact', AccountId = act.Id);
        insert con;

        Vehicle__c vehicle = new Vehicle__c(Contact__c = con.Id, Name = 'Test Vehicle', Make__c = 'TATA', Model__c = 'Test MOdel');
        insert vehicle;

        Maintenance_Reuest__c maintenanceRequest = new Maintenance_Reuest__c(Vehicle__c = vehicle.Id);
        insert maintenanceRequest;

        Part_Inventory__c partInventory = new Part_Inventory__c(Name = 'Child Part', Qty_In_Stock__c = 100, Min_Qty_Reminder__c = 5);
        insert partInventory;

        Maintenance_Part__c maintenancePart = new Maintenance_Part__c(Maintenance_Request__c = maintenanceRequest.Id, Part_Inventory__c = partInventory.Id, Qty_Utilized__c = 98);
        Test.startTest();
        insert maintenancePart; 
        Test.stopTest();

        System.assertEquals(partInventory.Qty_In_Stock__c - maintenancePart.Qty_Utilized__c, 2);
    }
}