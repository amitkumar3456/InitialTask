import { LightningElement, wire,api} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getPriceBookEntryList from '@salesforce/apex/AddProductComponentController.getPriceBookEntryList';
import addProductsToOrder from '@salesforce/apex/AddProductComponentController.addProductsToOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SAMPLEMC from "@salesforce/messageChannel/SampleMessageChannel__c"
import {MessageContext, publish} from 'lightning/messageService'
import { refreshApex } from '@salesforce/apex'; 
import STATUS_FIELD from '@salesforce/schema/Order.Status';

export default class ProductsCatalog extends LightningElement {
    loaded = false;
    columns =[
        { label: 'Product Name', fieldName: 'Name', type:'text',sortable: true}, 
        { label: 'List Price', fieldName: 'UnitPrice', type:'currency',sortable: true}      
    ];
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    selectedRows;
    @api recordId;
    products;

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD]})
    order
    @wire(MessageContext)
    context
    @wire(getPriceBookEntryList, { orderId: '$recordId' })
    wireProducts({ error, data }) {
        this.loaded = true;
        if (data) {
            this.products = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.products = undefined;
        }
    }
    addProductAction(e){
        let $this = this;
        $this.loaded = false;
        let selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        addProductsToOrder({ prodIds: selectedRecords, orderId: this.recordId})
        .then((result) => {
            $this.showToast('Success','Product added successfully.','success');
            $this.loaded = true;
            const message={
                lmsData:{
                    value:''
                }
            }
            $this.template.querySelector('lightning-datatable').selectedRows = [];
            publish($this.context, SAMPLEMC, message)
        })
        .catch((error) => {
            $this.loaded = true;
            console.log(JSON.stringify(error));
            $this.showToast('Error','Error creating record.','error');
        });
    }
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.products];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.products = cloneData;
        this.sortDirection = sortDirection==='asc'?'desc':'asc';
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
    get isActive() {
        return getFieldValue(this.order.data, STATUS_FIELD)=='Activated';
    }
    showToast(title,message,variant) {
        const event = new ShowToastEvent({title,message,variant});
        this.dispatchEvent(event);
    }
}