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

import java.util.Map;

import com.zimbra.common.service.ServiceException;
import com.zimbra.common.soap.Element;
import com.zimbra.soap.DocumentHandler;
import com.zimbra.soap.ZimbraSoapContext;

import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.io.BufferedReader;
import java.io.InputStreamReader;

public class ZefaGetaccountSoapHandler extends DocumentHandler {
    public Element handle(Element request, Map<String, Object> context)
            throws ServiceException {
        try {

            ZimbraSoapContext zsc = getZimbraSoapContext(context);
            Element response = zsc.createElement(
                    "ZefaGetaccountResponse"
            );
            Element zefaGetaccountResult = response.addUniqueElement("zefaGetaccountResult");

            switch (request.getAttribute("action")) {
                case "getAccounts":
                    zefaGetaccountResult.setText(this.runCommand("/usr/local/sbin/zefa-acctalias", "", "", "", ""));
                    break;
                case "getAccount":
                    if (this.validate(request.getAttribute("accounta"))) {
                        String runCommandOutput = this.runCommandNormalOutput("/usr/local/sbin/zefa-getaccount", request.getAttribute("accounta"), "", "", "");
                        zefaGetaccountResult.setText("<pre>"+runCommandOutput+"</pre>");
                    } else {
                        zefaGetaccountResult.setText("Invalid email address specified.");
                    }
                    break;
            }
            return response;

        } catch (
                Exception e)

        {
            throw ServiceException.FAILURE("ZefaGetaccountSoapHandler ServiceException ", e);
        }

    }

    public static final Pattern VALID_EMAIL_ADDRESS_REGEX =
            Pattern.compile("^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", Pattern.CASE_INSENSITIVE);

    public static boolean validate(String emailStr) {
        Matcher matcher = VALID_EMAIL_ADDRESS_REGEX.matcher(emailStr);
        return matcher.find();
    }

    private String runCommandPayload(String cmd, String append_char, String arg1, String arg2, String arg3, String arg4) throws ServiceException {
        try {
            ProcessBuilder pb = new ProcessBuilder()
                    .command(cmd, arg1, arg2, arg3, arg4)
                    .redirectErrorStream(true);
            Process p = pb.start();

            BufferedReader cmdOutputBuffer = new BufferedReader(new InputStreamReader(p.getInputStream()));

            StringBuilder builder = new StringBuilder();
            String aux = "";
            while ((aux = cmdOutputBuffer.readLine()) != null) {
                builder.append(aux);
                builder.append(append_char);
            }
            String cmdResult = builder.toString();
            return cmdResult;

        } catch (
                Exception e)

        {
            throw ServiceException.FAILURE("ZefaGetaccountSoapHandler runCommand exception", e);
        }
    }

    private String runCommand(String cmd, String arg1, String arg2, String arg3, String arg4) throws ServiceException {
        return (runCommandPayload(cmd, ";", arg1, arg2, arg3, arg4));
    }
    private String runCommandNormalOutput(String cmd, String arg1, String arg2, String arg3, String arg4) throws ServiceException {
        return (runCommandPayload(cmd, "\n", arg1, arg2, arg3, arg4));
    }

}
