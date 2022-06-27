import { LightningElement, wire,api} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getOrderItems from '@salesforce/apex/AddProductComponentController.getOrderItems';
import fetchOrderDetails from '@salesforce/apex/OrderProcessCtrl.fetchOrderDetails';
import SAMPLEMC from "@salesforce/messageChannel/SampleMessageChannel__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {subscribe, MessageContext, APPLICATION_SCOPE, unsubscribe} from 'lightning/messageService';
import { refreshApex } from '@salesforce/apex';
import STATUS_FIELD from '@salesforce/schema/Order.Status';

export default class ProductsCatalog extends LightningElement {
    @api recordId;
    products = [];
    recievedMessage;
    subscription;
    columns =[
        { label: 'Product Name', fieldName: 'Name', type:'text',sortable: true}, 
        { label: 'List Price', fieldName: 'UnitPrice', type:'currency',sortable: true},
        { label: 'Quantity', fieldName: 'Quantity', type:'number',sortable: true},
        { label: 'Total Price', fieldName: 'TotalPrice', type:'currency',sortable: true}      
    ];
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    wireProductsData;
    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD]})
    order

    @wire(MessageContext)
    context
    
    @wire(getOrderItems, { orderId: '$recordId' })
    wireProducts(result) {
        this.wireProductsData = result;
        let { error, data } = result;
        if (data) {
            let temp = JSON.parse(JSON.stringify(data));
            temp = temp.map((item,i,arr)=>{
                item['Name'] = item.Product2.Name;
                return item;
            });
            this.products = temp;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.products = undefined;
        }
    }
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.products];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.products = cloneData;
        this.sortDirection = sortDirection==='asc'?'asc':'desc';
        this.sortedBy = sortedBy;
    }
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
    sendOrder() {
        let $this = this;
        if(this.wireProduct.length>0){
            fetchOrderDetails({ orderId: this.recordId })
            .then(result => {
                refreshApex($this.order);
                if(result=='200'){
                    $this.showToast('Success','Order submitted successfully.','success');
                }
                else{
                    $this.showToast('Error','Error order submission.','error');
                }
                
            })
            .catch(error => {
                $this.showToast('Error','Error order submission.','error');
            });
        }
        else{
            $this.showToast('Error','Please select products.','error');
        }
    }
    get isActive() {
        return getFieldValue(this.order.data, STATUS_FIELD)=='Activated';
    }
    connectedCallback(){
        this.subscribeMessage()
    }
    subscribeMessage(){
        //subscribe(messageContext, messageChannel, listener, subscriberOptions)
        this.subscription= subscribe(this.context, SAMPLEMC, (message)=>{refreshApex(this.wireProductsData);}, {scope:APPLICATION_SCOPE})
    }
    showToast(title,message,variant) {
        const event = new ShowToastEvent({title,message,variant});
        this.dispatchEvent(event);
    }
}