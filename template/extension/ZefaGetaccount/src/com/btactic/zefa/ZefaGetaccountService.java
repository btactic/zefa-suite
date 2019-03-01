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
package com.btactic.zefa;

import com.zimbra.soap.DocumentDispatcher;
import com.zimbra.soap.DocumentService;
import org.dom4j.Namespace;
import org.dom4j.QName;


public class ZefaGetaccountService implements DocumentService {
    public static final Namespace namespace = Namespace.get("urn:ZefaGetaccount");

    public void registerHandlers(DocumentDispatcher dispatcher) {
        dispatcher.registerHandler(QName.get("ZefaGetaccount",namespace), new ZefaGetaccountSoapHandler());
    }
}
