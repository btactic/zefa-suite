/*
Copyright (C) 2019 BTACTIC,SCCL

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see http://www.gnu.org/licenses/.
 */
ZaZefaGetaccountTab = function(parent, entry) {
    if (arguments.length == 0) return;
    ZaTabView.call(this, parent,"ZaZefaGetaccountTab");
    ZaTabView.call(this, {
        parent:parent,
        iKeyName:"ZaZefaGetaccountTab",
        contextId:"ZEFA_GETACCOUNT"
    });
    this.setScrollStyle(Dwt.SCROLL);

    var soapDoc = AjxSoapDoc.create("ZefaGetaccount", "urn:ZefaGetaccount", null);
    soapDoc.getMethod().setAttribute("action", "getAccounts");
    var csfeParams = new Object();
    csfeParams.soapDoc = soapDoc;
    csfeParams.asyncMode = true;
    csfeParams.callback = new AjxCallback(ZaZefaGetaccountTab.prototype.getAccountsCallback);
    var reqMgrParams = {} ;
    resp = ZaRequestMgr.invoke(csfeParams, reqMgrParams);

    document.getElementById('ztab__ZEFA_GETACCOUNT').innerHTML = 
    '<div style="padding-left:10px">'
    +
    '<h1>ZEFA\'s Getaccount extension</h1>'
    +
    '<datalist id="ZefaGetaccount-datalist"></datalist>'
    +

    '<h2>Getaccount</h2>This option allows you to output the equivalent of \'zmprov getAccount\' from the Zimbra UI.\
    <br><br><input type="text" id="ZefaGetaccount-account-c" list="ZefaGetaccount-datalist" placeholder="user@domain.com">&nbsp;&nbsp;<button id="ZefaGetaccount-btnGetaccount">OK</button>' +
    '<br><br><hr>'

    +
    '<h2>Status</h2><div id="ZefaGetaccount-status" style="color:#aaaaaa; font-style: italic;"></div></div>';   

    ZaZefaGetaccountTab.prototype.status('Loading auto completion...');


    var btnGetaccount = document.getElementById('ZefaGetaccount-btnGetaccount');
    btnGetaccount.onclick = AjxCallback.simpleClosure(this.btnGetaccount);
}


ZaZefaGetaccountTab.prototype = new ZaTabView();
ZaZefaGetaccountTab.prototype.constructor = ZaZefaGetaccountTab;

ZaZefaGetaccountTab.prototype.getTabIcon =
    function () {
        return "ClientUpload" ;
    }

ZaZefaGetaccountTab.prototype.getTabTitle =
    function () {
        return "ZEFA Getaccount";
    }

ZaZefaGetaccountTab.prototype.getAccountsCallback = function (result) {
   var dataList = document.getElementById('ZefaGetaccount-datalist');
   var users = result._data.Body.ZefaGetaccountResponse.zefaGetaccountResult._content.split(";");
   
   users.sort();
   users.forEach(function(item) 
   {
      // Create a new <option> element.
      var option = document.createElement('option');
      // Set the value using the item in the JSON array.
      option.value = item;
      // Add the <option> element to the <datalist>.
      dataList.appendChild(option);
   });
   ZaZefaGetaccountTab.prototype.status('Ready.');
   return;
}

ZaZefaGetaccountTab.prototype.btnGetaccount = function () {
    ZaZefaGetaccountTab.prototype.status('Running zmprov getAccount...');

    var accountA = document.getElementById('ZefaGetaccount-account-c').value;
  
    if(accountA)
    {
       var soapDoc = AjxSoapDoc.create("ZefaGetaccount", "urn:ZefaGetaccount", null);
       soapDoc.getMethod().setAttribute("action", "getAccount");
       soapDoc.getMethod().setAttribute("accounta", accountA);
       var csfeParams = new Object();
       csfeParams.soapDoc = soapDoc;
       csfeParams.asyncMode = true;
       csfeParams.callback = new AjxCallback(ZaZefaGetaccountTab.prototype.zefaGetaccountDefaultCallback);
       var reqMgrParams = {} ;
       resp = ZaRequestMgr.invoke(csfeParams, reqMgrParams);
    }   
    else
    {
       ZaZefaGetaccountTab.prototype.status('Select or type email address.');
    }
}   
  
   
ZaZefaGetaccountTab.prototype.zefaGetaccountDefaultCallback = function (result) {
   ZaZefaGetaccountTab.prototype.status('Ready. '+result._data.Body.ZefaGetaccountResponse.zefaGetaccountResult._content);
}  

ZaZefaGetaccountTab.prototype.status = function (statusText) {
   document.getElementById('ZefaGetaccount-status').innerHTML = statusText;
}


