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
        
        Part_Inventory__c partInventory2 = new Part_Inventory__c(Name = 'Child Part 2', Qty_In_Stock__c = 2, Min_Qty_Reminder__c = 1, Parent__c = partInventory.Id, Child_Part_Qty__c = 1);
        insert partInventory2;
        
         Part_Inventory__c partInventory0 = new Part_Inventory__c(Name = 'Child Part', Qty_In_Stock__c = 2, Min_Qty_Reminder__c = 1);
        insert partInventory0;
        
        Part_Inventory__c partInventory3 = new Part_Inventory__c(Name = 'Child Part 3', Qty_In_Stock__c = 2, Min_Qty_Reminder__c = 1, Parent__c = partInventory0.Id, Child_Part_Qty__c = 1);
        insert partInventory3;

        Maintenance_Part__c maintenancePart = new Maintenance_Part__c(Maintenance_Request__c = maintenanceRequest.Id, Part_Inventory__c = partInventory.Id, Qty_Utilized__c = 5);
        Test.startTest();
        
        try{
                insert maintenancePart;
            }
            Catch(Exception e){
                System.debug('Problem sending notification: ' + e.getMessage());
                System.assert(e.getMessage().contains('refill'));
            }
        
        System.assertEquals(partInventory.Qty_In_Stock__c - maintenancePart.Qty_Utilized__c, 95);
        
        //Child part maintenance request
        Maintenance_Part__c maintenancePart2 = new Maintenance_Part__c(Maintenance_Request__c = maintenanceRequest.Id, Part_Inventory__c = partInventory.Id, Qty_Utilized__c = 20);

        maintenancePart2.Qty_Utilized__c = 2;
            try{
        		insert maintenancePart2;
            }
            Catch(Exception e){
                System.debug('Problem sending notification: ' + e.getMessage());
                System.assert(e.getMessage().contains('refill'));
            }
        
                maintenancePart2.Qty_Utilized__c = 1;
            try{
        		update maintenancePart2;
            }
            Catch(Exception e){
                System.debug('Problem sending notification: ' + e.getMessage());
                System.assert(e.getMessage().contains('refill'));
            }

        
        
          //Child part maintenance request
        Maintenance_Part__c maintenancePart3 = new Maintenance_Part__c(Maintenance_Request__c = maintenanceRequest.Id, Part_Inventory__c = partInventory0.Id, Qty_Utilized__c = 2);
		insert maintenancePart3;

        
        Test.stopTest();
        
    }
}