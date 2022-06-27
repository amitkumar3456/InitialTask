/****************************************************************
* Class Name:  OrderServiceClass_Test
* Main Class:  OrderServiceClass
* Purpose   :  Class to retrieve the product details and Order Details
*****************************************************************/            
/*
* Revision History  :  Created : 26 June 2022 Amit Kumar
*/
@isTest
public without sharing class OrderServiceClass_Test {
    /*
     * Method to prove if same records are inserted the quantity gets doubled. 
     * Provided the matched pricebookentry Ids are specified.
	*/
    @isTest
    private static void testMethod1(){
        Id orderId;
        List<OrderItem> orderItemList = TestDataFactory.createOrderItemsRecord(10);
        
        Set<Id> entryIds = new Set<Id>();
        
        for(OrderItem ordItem : orderItemList){
            entryIds.add(ordItem.PricebookEntryId);
            orderId = ordItem.OrderId;
        }
        
        List<PricebookEntry> pricebookEntryList = [Select Id,Name,UnitPrice,Product2Id FROM PricebookEntry Where Id IN : entryIds];
        OrderServiceClass.addSelectedProductsToOrder(pricebookEntryList, orderId);
        
        List<OrderItem> orderItemsList = [Select Id,OrderId,Product2.name,UnitPrice, Quantity, TotalPrice,Product2Id 
                                          FROM OrderItem];
        //assert statement to prove that only 10 products are created with quantity as 2 and total Price will be doubled. 
        system.assertEquals(2, orderItemsList[0].Quantity);
        system.assertEquals(200, orderItemsList[0].TotalPrice);        
        system.assertEquals(2, orderItemsList[1].Quantity);
        system.assertEquals(202, orderItemsList[1].TotalPrice);
        system.assertEquals(2, orderItemsList[2].Quantity);
        system.assertEquals(204, orderItemsList[2].TotalPrice);
    }
    
    
    /*
     * Method to prove if same records are inserted the quantity does not change as the . 
     * matched pricebookentry Ids are not specified.
	*/
    @isTest
    private static void testMethod2(){
        Order orderRec = TestDataFactory.createOrderRecord();
        List<OrderItem> orderItemList = TestDataFactory.createOrderItemsRecord(10);
        
        List<PricebookEntry> pricebookEntryList = [Select Id,Name,UnitPrice,Product2Id FROM PricebookEntry];
        OrderServiceClass.addSelectedProductsToOrder(pricebookEntryList, orderRec.Id);
        
        List<OrderItem> itemList = [Select Id,OrderId,Product2.name,UnitPrice, Quantity, TotalPrice,Product2Id 
                                    FROM OrderItem];
        //Below assert statement proves that since we havents provided the Pricebookentry records 
        //we would have duplicate records created and the list size will be 20.
        system.assertEquals(1, itemList[0].Quantity);
        system.assertEquals(1, itemList[7].Quantity);
        system.assertEquals(20, itemList.size());
    }
}