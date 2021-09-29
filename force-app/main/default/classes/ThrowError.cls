/**
 * @description       : 
 * @author            : fpanara
 * @group             : 
 * @last modified on  : 09-26-2021
 * @last modified by  : fpanara
**/
public class ThrowError {
  @InvocableMethod
  public static void getAccountNames(List<Maintenance_Part__c> maintenanceParts) {
    for (Maintenance_Part__c objMaintenancePart : maintenanceParts) {
        objMaintenancePart.addError('Please refill the child parts.');
    }
  }
}