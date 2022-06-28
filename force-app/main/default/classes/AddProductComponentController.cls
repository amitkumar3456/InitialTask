/****************************************************************
* Class Name:  AddProductComponentController
* Test Class:  AddProductComponentController_Test
* Purpose   :  Class to retrieve the product details and Order Details
*****************************************************************/            
/*
* Revision History  :  Created : 24 June 2022 Amit Kumar
*/
Public class AddProductComponentController {
    /*
     * Method to return the list of PriceBookEntry with the product Details.
	*/
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getPriceBookEntryList(ID orderId){  //Change the name to getPriceBookEntryList
        List<PricebookEntry> pbProds = [Select Id,Name,UnitPrice,Product2Id 
                FROM PricebookEntry 
                WHERE Pricebook2Id 
                IN (Select Pricebook2Id FROM order WHERE Id=:orderId) AND IsActive=true];
        if(pbProds.isEmpty()){
            pbProds = [Select Id,name,UnitPrice,Product2Id 
                FROM PricebookEntry 
                WHERE Pricebook2Id 
                IN (SELECT Id FROM Pricebook2 where Name='Standard') AND IsActive=true];
        }
        return pbProds;
    }
    
    /*
     * Method to return the list of orderItems associated to an order.
	*/
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderItems(ID orderId){
        return [Select Id,OrderId,Product2.name,UnitPrice, Quantity, TotalPrice,Product2Id 
                FROM OrderItem 
                WHERE OrderId=:orderId];
    }
    
    /*
     * Method to add the selected product to an orderItem and upsert the records accordingly. //Move this to new class.
	*/
    @AuraEnabled
    public static void addProductsToOrder(List<PricebookEntry> prodIds, ID orderId){ 
        OrderServiceClass service = new OrderServiceClass();
        service.addSelectedProductsToOrder(prodIds, orderId);
    } 
}
