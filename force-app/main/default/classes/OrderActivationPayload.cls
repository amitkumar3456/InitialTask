/****************************************************************
* Class Name:  OrderActivationPayload
* Test Class:  OrderActivationPayload_Test
* Purpose   :  Inner Class to initalize the variables
*****************************************************************/            
/*
* Revision History  :  Created : 26 June 2022 Amit Kumar
*/
public class OrderActivationPayload { 
    public String accountNumber;
    public String orderNumber;
	public String type;
    public String status;
    public List<OrderProducts> orderProducts;
   
    //OrderItems List
    public class OrderProducts {
        public String name;
        public String code;
        public Decimal unitPrice;
        public Decimal quantity;
    }
}