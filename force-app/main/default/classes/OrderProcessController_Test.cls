/****************************************************************
* Class Name:  OrderProcessController_Test
* Main Class:  OrderProcessController
* Purpose   :  Test Class for OrderProcessController
*****************************************************************/            
/*
* Revision History  :  Created : 26 June 2022 Amit Kumar
*/
@isTest
Public class OrderProcessController_Test {
    @isTest
    private static void testForMockClassResponse(){
        Order orderRec = TestDataFactory.createOrderRecord();
        System.assert(orderRec.Id != null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OrderHttpMockResponse());  
        String strResp = OrderProcessController.fetchOrderDetails(orderRec.Id);
        Test.stopTest();
    }
    
    
    //@isTest
    private static void testToCheckRequestBody(){
        //Order orderRec = TestDataFactory.createOrderRecord();
        List<OrderItem> itemsList = TestDataFactory.createOrderItemsRecord(1);
        Id orderId = itemsList[0].OrderId;
        Map<Id, Order> orderItemsMap = new Map<Id, Order>([Select Id, Account.AccountNumber, OrderNumber, Type, Status, 
                                                           (Select Product2.Name, Product2.ProductCode, UnitPrice, Quantity 
                                                            From OrderItems WHERE OrderId =: orderId) 
                                                           FROM Order WHERE Id =: orderId]);
        
        String jsonStr = OrderProcessController.createRequestBody(orderItemsMap, orderId);
        
        system.assert(jsonStr != Null);
    }
    
    
    //@isTest
    private static void testToCheckOrderStatusValue(){
        List<OrderItem> itemsList = TestDataFactory.createOrderItemsRecord(5);
        String beforeOrderUpdate = [Select Id, Status FROM Order].Status;
        Test.startTest();
        OrderProcessController.updateOrderResult(itemsList[0].OrderId, 200, '');
        Test.stopTest();
        String afterOrderUpdate = [Select Id, Status FROM Order].Status;
        
        //assert statement to prove that once the update is done the status value is changed.
        System.assertNotEquals(beforeOrderUpdate, afterOrderUpdate);
    }
}
