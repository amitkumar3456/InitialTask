/****************************************************************
* Class Name:  AddProductComponentController
* Test Class:  AddProductComponentController_Test
* Purpose   :  Test Class for AddProductComponentController
*****************************************************************/            
/*
* Revision History  :  Created : 26 June 2022 Amit Kumar
*/
@isTest
public class AddProductComponentController_Test {
    /*Test Method for the method getPriceBookEntryList(orderId)*/
    @isTest
    private static void testToCheckPriceBookEntryList(){       
        Order orderRec = TestDataFactory.createOrderRecord();
        List<PricebookEntry> pbeList = AddProductComponentController.getPriceBookEntryList(orderRec.Id);
        system.assertEquals(0, pbeList.size());
        
        List<PricebookEntry> pricebookEntryList = TestDataFactory.createPriceBookEntryRecords(5);
        Integer pbeCount = [Select count() from PricebookEntry];
        //Below assert statement proves that irrespective of OrderId we would display the available products.
        system.assertEquals(5, pbeCount);
        //Below two assert statements prove that the pricebookEntry records return values.
        system.assertEquals(100, pricebookEntryList[0].UnitPrice);
        system.assertEquals(101, pricebookEntryList[1].UnitPrice);        
    }
    
    
    @isTest
    private static void testToFetchOrderItems(){
        Order orderRec = TestDataFactory.createOrderRecord();
        List<OrderItem> itemList = AddProductComponentController.getOrderItems(orderRec.Id);
        system.assertEquals(0, itemList.size());
        
        List<OrderItem> orderItemList = TestDataFactory.createOrderItemsRecord(10);
        //Simple assert statement to check weather the fields are populating values or not.         
        system.assertEquals(100, orderItemList[0].UnitPrice);
        system.assertEquals(1, orderItemList[0].Quantity);
    }
    
    /*
     * Test Method would check if the same product is inserted, The quantity  would be increased by 1.
*/
    @isTest
    private static void testForSameProductInsert(){
        Id orderId;
        List<OrderItem> orderItemList = TestDataFactory.createOrderItemsRecord(10);
        
        Set<Id> entryIds = new Set<Id>();
        
        for(OrderItem ordItem : orderItemList){
            entryIds.add(ordItem.PricebookEntryId);
            orderId = ordItem.OrderId;
        }
        
        List<PricebookEntry> pricebookEntryList = [Select Id,Name,UnitPrice,Product2Id FROM PricebookEntry Where Id IN : entryIds];
        AddProductComponentController.addProductsToOrder(pricebookEntryList, orderId);
        
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
    
    
    @isTest
    private static void testForQuantityCheck(){
        Order orderRec = TestDataFactory.createOrderRecord();
        List<OrderItem> orderItemList = TestDataFactory.createOrderItemsRecord(10);
        
        List<PricebookEntry> pricebookEntryList = [Select Id,Name,UnitPrice,Product2Id FROM PricebookEntry];
        AddProductComponentController.addProductsToOrder(pricebookEntryList, orderRec.Id);
        
        List<OrderItem> itemList = [Select Id,OrderId,Product2.name,UnitPrice, Quantity, TotalPrice,Product2Id 
                                    FROM OrderItem];
        //Below assert statement proves that since we havents provided the Pricebookentry records 
        //we would have duplicate records created and the list size will be 20.
        system.assertEquals(1, itemList[0].Quantity);
        system.assertEquals(1, itemList[7].Quantity);
        system.assertEquals(20, itemList.size());
    }
}
