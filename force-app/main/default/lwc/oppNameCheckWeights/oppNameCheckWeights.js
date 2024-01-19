import { LightningElement, wire, api, track } from 'lwc';
import getRelatedOpps from '@salesforce/apex/LwcOppNameCheckWeightsController.getRelatedOpps';

const columns = [
    { label: '项目编号', fieldName: 'projectNumber',initialWidth: 100 },
    { label: '商机名称', fieldName: 'oppUrl', type: 'url', initialWidth: 220, wrapText: true, typeAttributes: {label: { fieldName: 'oppName' }, target: '_blank' } },
    { label: '客户二级公司', fieldName: 'accName', initialWidth: 130, wrapText: true},
    { label: '商机所有人', fieldName: 'owner',initialWidth: 100 },
    { label: '商机已关闭', fieldName: 'close',initialWidth: 100, },
    { label: '重复率值', fieldName: 'weight',initialWidth: 90, type: 'percent', sortable: true,  cellAttributes: { alignment: 'left', class: 'slds-text-color_error slds-text-title_caps' } }
];
export default class OppNameCheckWeights extends LightningElement {

    @api recordId;

    error;
    columns = columns;
    defaultSortDirection = 'desc';
    sortDirection = 'desc';
    sortedBy;
    isLoadedUI = false;  
    opps;

    @wire(getRelatedOpps, { oppId: '$recordId' })
    opps;

    isLoadedUI = true; 

    // // Used to sort the 'weight' column
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

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        // const cloneData = [...this.opps];
        const cloneData = this.opps.data;
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'desc' ? 1 : -1));
        this.opps = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}