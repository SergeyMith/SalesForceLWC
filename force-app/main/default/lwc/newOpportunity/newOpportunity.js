import { LightningElement, wire } from 'lwc';
import { NavigationMixin , CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getRoleName from '@salesforce/apex/newOppController.getRoleName';
import getRecordType from '@salesforce/apex/newOppController.getRecordType';
import getOwnerId from '@salesforce/apex/newOppController.getOwnerId';

import OPPORTUNITY from '@salesforce/schema/Opportunity';
import NAME from '@salesforce/schema/Opportunity.Name';
import STAGE from '@salesforce/schema/Opportunity.StageName';
import CLOSEDATE from '@salesforce/schema/Opportunity.CloseDate';
import OWNER from '@salesforce/schema/Opportunity.OwnerId';
import AMOUNT from '@salesforce/schema/Opportunity.Amount';
import DISCOUNT from '@salesforce/schema/Opportunity.Discount__c';
import ACCOUNT from '@salesforce/schema/Opportunity.AccountId';

export default class NewOpportunity extends NavigationMixin(LightningElement) {

    opportunity = OPPORTUNITY;

    name = NAME;
    stage = STAGE;
    closeDate = CLOSEDATE;
    owner = OWNER;
    amount = AMOUNT;
    discount = DISCOUNT;
    account = ACCOUNT;

    defaultStage;
    defaultDate;

    @wire(getRoleName, {}) 
    roleName;
    @wire(getRecordType, {})
    recordTypeId;
    @wire(getOwnerId, {}) 
    ownerId;

    value;
    value2;
    value3;
    value4;
    accountId;
    @wire(CurrentPageReference)
    getPageRef(currentPageReference){
        if(currentPageReference.state.additionalParams) {

            var str = currentPageReference.state.additionalParams;
            var start = str.indexOf('001');
            if(start != -1) {
                this.accountId = str.slice(start, start+15);
            }
        }
    }

    handleLoad() {

        Date.prototype.addDays = function(days) {
            var date = this;
            date.setDate(date.getDate() + days);
            return date;
        }
        Date.prototype.toString = function() {
            var x = this;
            return x.getFullYear() +'-'+ (x.getMonth()+1) +'-'+ x.getDate();
        }
        var currentDate = new Date();

        if (this.roleName.data === 'Starter_Rep') {

            this.defaultStage = 'Discover';
            this.defaultDate = currentDate.addDays(10).toString();

        } else if (this.roleName.data === 'Seller_Rep') {

            this.defaultStage = 'Account Setup';
            this.defaultDate = currentDate.addDays(30).toString();
        }        
    }

    handleSuccess(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.id,
                objectApiName: 'Opportunity',
                actionName: 'view'
            },
        });
        
        const toastEvent = new ShowToastEvent({
            title: "Opportunity was created",
            variant: "success"
        });
        this.dispatchEvent(toastEvent);
    }
}