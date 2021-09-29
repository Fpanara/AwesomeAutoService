/**
 * @description       : 
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
        
        List<Maintenance_Reuest__c> maintenanceRequestList = new List<Maintenance_Reuest__c>();
        for(integer i = 1; i<= 2; i++){
         Maintenance_Reuest__c maintenanceRequest = new Maintenance_Reuest__c(Vehicle__c = vehicle.Id);
        maintenanceRequestList.add(maintenanceRequest);
    }
    insert maintenanceRequestList;

    List<Part_Inventory__c> objParentPartInventoryList = new List<Part_Inventory__c>();
    //List<Part_Inventory__c> objChildPartInventoryList = new List<Part_Inventory__c>();
    
    for(integer i = 1; i<= 2; i++){
        Part_Inventory__c partInventory = new Part_Inventory__c(Name = 'Parent Part ' + i, Qty_In_Stock__c = 100, Min_Qty_Reminder__c = 5);
        objParentPartInventoryList.add(partInventory);
    }
    insert objParentPartInventoryList;

    
        Part_Inventory__c partInventory = new Part_Inventory__c(Name = 'Child Part', Qty_In_Stock__c = 400, Min_Qty_Reminder__c = 5, Parent__c = objParentPartInventoryList[1].Id, Child_Part_Qty__c = 5);
        insert partInventory;
    }

    @istest static void afterInsertAfterUpdatePosisiveTest(){

        List<Maintenance_Reuest__c> maintenanceRequestList = [SELECT Id FROM Maintenance_Reuest__c];
        List<Part_Inventory__c>  parentPartInventoryList = [SELECT ID, Qty_In_Stock__c, Min_Qty_Reminder__c, Parent__c, Child_Part_Qty__c FROM Part_Inventory__c WHERE Parent__c = null];
        List<Part_Inventory__c>  childPartInventoryList = [SELECT ID, Qty_In_Stock__c, Min_Qty_Reminder__c, Parent__c, Child_Part_Qty__c FROM Part_Inventory__c WHERE Parent__c != null];
        
        //Without depadent part
        Maintenance_Part__c maintenancePart = new Maintenance_Part__c(Maintenance_Request__c = maintenanceRequestList[0].Id, Part_Inventory__c = parentPartInventoryList[1].Id, Qty_Utilized__c = 10);
        Test.startTest();
        insert maintenancePart;        
        
        System.assertEquals(parentPartInventoryList[1].Qty_In_Stock__c - maintenancePart.Qty_Utilized__c, 90);

        maintenancePart.Qty_Utilized__c = 20;
        update maintenancePart;
        Test.stopTest();

        System.assertEquals(parentPartInventoryList[1].Qty_In_Stock__c - maintenancePart.Qty_Utilized__c, 80);
    }

        @istest static void afterInsertAfterUpdateNegativeTest(){

        List<Maintenance_Reuest__c> maintenanceRequestList = [SELECT Id FROM Maintenance_Reuest__c];
        List<Part_Inventory__c>  parentPartInventoryList = [SELECT ID, Qty_In_Stock__c, Min_Qty_Reminder__c, Parent__c, Child_Part_Qty__c FROM Part_Inventory__c WHERE Parent__c = null];
        List<Part_Inventory__c>  childPartInventoryList = [SELECT ID, Qty_In_Stock__c, Min_Qty_Reminder__c, Parent__c, Child_Part_Qty__c FROM Part_Inventory__c WHERE Parent__c != null];
        
        //Parent part maintenance request
        Maintenance_Part__c maintenancePart = new Maintenance_Part__c(Maintenance_Request__c = maintenanceRequestList[0].Id, Part_Inventory__c = parentPartInventoryList[0].Id, Qty_Utilized__c = 5);
        Test.startTest();
        insert maintenancePart;
        System.assertEquals(parentPartInventoryList[1].Qty_In_Stock__c - maintenancePart.Qty_Utilized__c, 95);
            
        //Adding 5
        maintenancePart.Qty_Utilized__c = 10;
        update maintenancePart;
        System.assertEquals(parentPartInventoryList[1].Qty_In_Stock__c - maintenancePart.Qty_Utilized__c, 90);

        //Removing 5
        maintenancePart.Qty_Utilized__c = 5;
        update maintenancePart;
        System.assertEquals(parentPartInventoryList[1].Qty_In_Stock__c - maintenancePart.Qty_Utilized__c, 95);
    
        //Checking minimum qty reminder on parent part
        maintenancePart.Qty_Utilized__c = 91;

                update maintenancePart;

                //System.assert(e.getMessage().contains('refill'));
            
        System.assertEquals(parentPartInventoryList[1].Qty_In_Stock__c - maintenancePart.Qty_Utilized__c, 9);
     
        //Low notification count excepation for parent part
        maintenancePart.Qty_Utilized__c = 100;
        try {
            update maintenancePart;
        }
        catch (Exception e) {
            //System.debug('Problem sending notification: ' + e.getMessage());
            System.assert(e.getMessage().contains('refill'));
        }
            
            //Child part maintenance request
        Maintenance_Part__c maintenancePart2 = new Maintenance_Part__c(Maintenance_Request__c = maintenanceRequestList[1].Id, Part_Inventory__c = parentPartInventoryList[1].Id, Qty_Utilized__c = 5);
        insert maintenancePart2;
            System.assertEquals(parentPartInventoryList[1].Qty_In_Stock__c - maintenancePart.Qty_Utilized__c, 0);
            
            
        //Checking minimum qty reminder on child part
        maintenancePart2.Qty_Utilized__c = 95;
            try{
                update maintenancePart;
            }
            Catch(Exception e){
                System.debug('Problem sending notification: ' + e.getMessage());
                System.assert(e.getMessage().contains('refill'));
            }
        
       
            
        
        
        Test.stopTest();
    }

    
}