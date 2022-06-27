/****************************************************************
* Class Name:  OrderServiceClass
* Test Class:  OrderServiceClass_Test
* Purpose   :  Class to retrieve the product details and Order Details
*****************************************************************/            
/*
* Revision History  :  Created : 26 June 2022 Amit Kumar
*/

Public without sharing class OrderServiceClass {
    //Method to add the selected Products to an Order as a OrderItem.
    public static void addSelectedProductsToOrder(List<PricebookEntry> prodIds, ID orderId){
        Map<Id, OrderItem> orderItemsMap = new Map<Id, OrderItem>();
        Map<Id, PricebookEntry> pricebookEntryMap = new Map<Id, PricebookEntry>();
        pricebookEntryMap.putAll(prodIds);
        
        //Check if the order contains a pricebook or not. If not updating it with the standard one. 
        Order ord = [select id,pricebook2Id from order where Id =: orderId];
        if(ord.pricebook2Id==null){
            ord.pricebook2Id = [SELECT Id FROM Pricebook2 where Name='Standard' limit 1]?.Id;
            update ord;
        }
        
        Map<Id, Id> prodPEMap = new Map<Id, Id>();
        List<OrderItem> upsertOIlist = new List<OrderItem>();
        
        for(PricebookEntry pe : prodIds){
            prodPEMap.put(pe.product2Id,pe.id);
        }
        
        for(OrderItem oItem : [Select Id,OrderId,Product2.name,UnitPrice, Quantity, TotalPrice,Product2Id 
                               FROM OrderItem 
                               WHERE Product2Id in :prodPEMap.keySet() and OrderId =: orderId]){
                                   orderItemsMap.put(oItem.Product2Id, oItem);
                               }
        
        for(Id prodId : prodPEMap.keySet()){
            OrderItem ordItem;
            if(orderItemsMap.containsKey(prodId)){
                ordItem = orderItemsMap.get(prodId);
                ordItem.Quantity = ordItem.Quantity!=null?ordItem.Quantity+1:1;
            }
            else {
                ordItem = new Orderitem();
                ordItem.OrderId = orderId;
                ordItem.PricebookEntryId = prodPEMap.get(prodId);
                ordItem.UnitPrice = pricebookEntryMap.get(prodPEMap.get(prodId)).UnitPrice;
                ordItem.Quantity = 1;
            }
            upsertOIlist.add(ordItem);
        }
        
        if(!upsertOIlist.isEmpty()){
            upsert upsertOIlist;
        }
    }
}