public class PartInventoryTriggerHelper {
    public static void afterInsertAfterUpdateHandler(List<Part_Inventory__c> partInventoryList){
        for(Part_Inventory__c objpartInventory: partInventoryList){
            if(objpartInventory.Qty_in_Stock__c < objpartInventory.Min_Qty_Reminder__c){
                checkMinQtyReminder(objpartInventory);
            }
        }
    }
    
    //Sending minimum Qty reminder
    private static void checkMinQtyReminder(Part_Inventory__c pareInventory){
        List<FeedItem> feedItemList = new List<FeedItem>();
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        // Get the Id for our custom notification type
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Notifications'];

        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                input.subjectId = pareInventory.id;
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
                notification.setBody('Please refill this part ' + pareInventory.Name + '.');
                    
                // Set the notification type and target
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(pareInventory.Id);
                            
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