/****************************************************************
* Class Name:  OrderProcessController
* Test Class:  OrderProcessController_Test
* Purpose   :  Orders make a callout and update the order.
*****************************************************************/            
/*
* Revision History  :  Created : 24 June 2022 Amit Kumar
*/
Public class OrderProcessController {
    /**
     * Method to make a callout and fetch the response. 
     */
    public static String postOrderDetails(String requestBody, Id orderId){
        Integer responseCode;
        String exceptionMessage = '';
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        //Fetching the endPoint Url from the Named Credential
        request.setEndpoint('callout:SalesforceCallout'); 
        request.setMethod('POST');
        request.setBody(requestBody);
        request.setHeader('Content-Type','application/json');
        
        try {
            response = http.send(request);
            responseCode = response.getStatusCode();
        } catch(System.CalloutException e) {
            exceptionMessage = e.getMessage();
        }
        //Once the response is received we update the order Accordingly.
        return updateOrderResult(orderId, responseCode, exceptionMessage); 
    }
    
    /**
     * Method to create the RequestBody and return the Serialized String.
	 */
    public static String createRequestBody(Map<Id, Order> orderDetailsMap, String orderId){
        
        Order orderRec = orderDetailsMap.get(orderId);
        
        OrderActivationPayload payload = new OrderActivationPayload();
        payload.accountNumber = orderRec.Account.AccountNumber;
        payload.orderNumber = orderRec.OrderNumber;
        payload.type = orderRec.Type;
        payload.status = orderRec.Status;
        
        List<OrderActivationPayload.OrderProducts> orderItemList = new List<OrderActivationPayload.OrderProducts>();
        //Looping around the order items and assigning the items values accordingly. 
        for(OrderItem item : orderRec.orderItems){
            OrderActivationPayload.OrderProducts orderItemRec = new OrderActivationPayload.OrderProducts();
            orderItemRec.name = item.Product2.Name;
            orderItemRec.code = item.Product2.ProductCode;
            orderItemRec.unitPrice = item.UnitPrice;
            orderItemRec.quantity = item.Quantity;
            orderItemList.add(orderItemRec);
        }        
        
        payload.orderProducts = orderItemList;
        //Serializing the order.
        String jsonStr = JSON.serialize(payload);
        return jsonStr;
    }
    
    
    /*
     * We would receive the orderId from the LWC component.
     */
    @AuraEnabled
    public static String fetchOrderDetails(Id orderId){
        Map<Id, Order> orderItemsMap = new Map<Id, Order>([Select Id, Account.AccountNumber, OrderNumber, Type, Status, 
                                                           (Select Product2.Name, Product2.ProductCode, UnitPrice, Quantity 
                                                            From OrderItems Where OrderId =: orderId) 
                                                           FROM Order Where Id =: orderId]);
        
        String requestBody = createRequestBody(orderItemsMap, orderId);
        return postOrderDetails(requestBody, orderId);
    }
    
    
    /*
     * Method to update the Order Record once the response is recieved.
     */
    public static String updateOrderResult(Id orderId, Integer responseCode, String exceptionMessage){
        
        try{

            Order order = [Select Id, Status FROM Order Where Id =: orderId];   
            if(responseCode == 200){       
                order.Status = 'Activated';
            }else if(responseCode == 202){
                //order.ErrorFeild = 'Error Message';
            }else if(responseCode ==  500){
                //order.Status = 'Unreachable';
            }
            Database.Update(order);
            return String.valueOf(responseCode);
        }catch(Exception e){
            exceptionMessage = e.getMessage();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, exceptionMessage);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
}
