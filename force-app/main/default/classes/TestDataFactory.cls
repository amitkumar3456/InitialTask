public class TestDataFactory {
    //public ID standardPBID = Test.getStandardPricebookId();
    
    //First Create Product2 Records.
    public static List<Product2> createProductRecords(Integer count){ //100
        List<Product2> productList = new List<Product2>();
        for(Integer i = 0; i< count; i++){
            Product2 prod = new Product2(Name = 'TesProduct' + i, ProductCode = 'TsSt' + i);
            productList.add(prod);
        }
        insert productList;
        return productList;
    }
    
    @testVisible
    private static List<PriceBookEntry> createPriceBookEntryRecords(Integer count){
        List<Product2> productList = createProductRecords(count);
        List<PriceBookEntry> pricebookEntryList = new List<PriceBookEntry>();
        Integer tempCount = 0;
        
        if(!productList.isEmpty()){
            for(Product2 prod : productList){
                //For each product we would be creating a pricebookEntryList
                PriceBookEntry pricebookEntry = new PriceBookEntry();
                pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
                pricebookEntry.Product2Id = prod.Id;
                pricebookEntry.UnitPrice = 100 + tempCount;
                pricebookEntry.isActive = True;
                tempCount++;
                pricebookEntryList.add(pricebookEntry);
            }
        }
                
        insert pricebookEntryList;
        return pricebookEntryList;
    }
    
    public static List<Account> createAccountRecord(Integer count){
        List<Account> accountList = new List<Account>();
        for(Integer i = 0; i < count; i++){
            Account accRec = new Account(Name = 'Account' + i);
            accountList.add(accRec);
        }
        insert accountList;
        return accountList;
    }
    
    public static List<Contract> createContractRecord(Integer count){
        List<Contract> contractList = new List<Contract>();
        List<Account> accountList = createAccountRecord(count);
        for(Integer i = 0; i < count; i++){
            Contract contractRec = new Contract();
            contractRec.Name = 'CntractRec' + i;
            contractRec.AccountId = accountList[i].Id;
            contractRec.ContractTerm = 12;
            contractRec.StartDate = System.Today();
            contractList.add(contractRec);
        }
        insert contractList;
        
        return contractList;
    }
    
    public static Order createOrderRecord(){
        List<Contract> contractList = createContractRecord(1);
        Contract contractRec = [Select Id, AccountId From Contract LIMIT 1];
        
            Order orderRec = new Order();
            orderRec.Name = 'TestOrder' ;
            orderRec.AccountId = contractRec.AccountId;
            orderRec.Status = 'Draft';
            orderRec.Pricebook2Id = Test.getStandardPricebookId();
            orderRec.EffectiveDate = System.Today();
        
        insert orderRec;
        
        return orderRec;
    }
    
     
    public static List<OrderItem> createOrderItemsRecord(Integer count){
        Order orderRec = createOrderRecord();
        List<PriceBookEntry> pbeList = createPriceBookEntryRecords(count);
        List<OrderItem> orderItemList = new List<OrderItem>();
        
            for(PriceBookEntry pbe : pbeList){
                OrderItem itemRec = new OrderItem();
                itemRec.Product2Id = pbe.Product2Id;
                itemRec.PricebookEntryId = pbe.Id;
                itemRec.Quantity = 1;
                itemRec.UnitPrice = pbe.UnitPrice;
                itemRec.OrderId = orderRec.Id;
                orderItemList.add(itemRec);
            }
        
        insert orderItemList;
       
        return orderItemList;
    }
}