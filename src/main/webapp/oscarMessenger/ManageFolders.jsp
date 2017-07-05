<%--
  KAI INNOVATIONS
--%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_msg" rights="w" reverse="<%=true%>">
    <%authed=false; %>
    <%response.sendRedirect("../securityError.jsp?type=_msg");%>
</security:oscarSec>
<%
    if(!authed) {
        return;
    }
%>


<logic:notPresent name="msgSessionBean" scope="session">
    <logic:redirect href="index.jsp" />
</logic:notPresent>
<logic:present name="msgSessionBean" scope="session">
    <bean:define id="bean"
                 type="oscar.oscarMessenger.pageUtil.MsgSessionBean"
                 name="msgSessionBean" scope="session" />
    <logic:equal name="bean" property="valid" value="false">
        <logic:redirect href="index.jsp" />
    </logic:equal>
</logic:present>
<%
    String providerNo = (String) session.getAttribute("user");
    String demographic_no = (String) request.getAttribute("demographic_no");

    MessageFolderDao messageFolderDao = SpringUtils.getBean(MessageFolderDao.class);
    List<MessageFolder> messageFolders = messageFolderDao.findAllFoldersByProvider(providerNo);

%>
<%@page import="org.oscarehr.util.MiscUtils"%>
<%@ page import="org.oscarehr.common.dao.MessageFolderDao" %>
<%@ page import="org.oscarehr.common.model.MessageFolder" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="java.util.List" %>
<%@ page import="net.sf.json.JSONSerializer" %>
<%@ page import="net.sf.json.JSONObject" %>
<%@ page import="net.sf.json.JSON" %>
<%@ page import="oscar.oscarLab.ca.bc.PathNet.HL7.Message" %>
<%@ page import="net.sf.json.JSONArray" %>
<html:html locale="true">
    <head>
        <script type="text/javascript" src="../js/jquery-1.7.1.min.js"></script>
        <script src="<%=request.getContextPath()%>/js/jquery-ui-1.8.18.custom.min.js"></script>
        <script src="<%=request.getContextPath()%>/js/fg.menu.js"></script>

        <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
        <script src="<%=request.getContextPath()%>/share/javascript/prototype.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery.dataTables.js"></script>

        <title>Manage Folders</title>

        <link rel="stylesheet" type="text/css" href="encounterStyles.css">
        <link rel="stylesheet" type="text/css" media="all" href="../share/css/extractedFromPages.css"  />

        <style>
            .TopStatusBar{
                width:100% !important;
                height:100% !important;
            }
            input[type="text"]:read-only.editable{
                background:transparent;
                border: none;
                color: inherit;
            }
            .reorder{
                padding-right: 5px;
                float: right;
            }
        </style>
        <script type="text/javascript">
            function BackToOscar()
            {
                if (opener.callRefreshTabAlerts) {
                    opener.callRefreshTabAlerts("oscar_new_msg");
                    setTimeout("window.close()", 100);
                } else {
                    window.close();
                }
            }
            function checkAll(formId){
                var f = document.getElementById(formId);
                var val = f.checkA.checked;
                for (var i =0; i < f.folderId.length; i++){
                    f.folderId[i].checked = val;
                }
            }

            function renameFolder(element){
                element.readOnly="true";
                var folderId = element.name;
                var newName = element.value;

                var data="submit=rename&folderId="+folderId+"&newName="+newName;
                var url="<%=request.getContextPath()%>/oscarMessenger/ManageFolder.do";

                new Ajax.Request(url,{method:'post',parameters:data, onSuccess:function(transport){
                },
                onFailure:function(){
                    element.readonly=true;
                    alert("Error updating folder name");
                }});
            }
            function order(direction, folderId) {
                var url="<%=request.getContextPath()%>/oscarMessenger/ManageFolder.do";
                var data="submit=reorder&folderId="+folderId+"&direction="+direction;

                new Ajax.Request(url,{method:'post',parameters:data, onSuccess:function(transport){
                    document.location.reload();
                },
                onFailure:function(){
                    element.readonly=true;
                    alert("Error reordering folders");
                }});
            }
        </script>
    </head>

    <body class="BodyStyle" vlink="#0000FF">

    <table class="MainTable" id="scrollNumber1" name="encounterTable">
        <tr class="MainTableTopRow">
            <td class="MainTableTopRowLeftColumn">
                <bean:message key="oscarMessenger.CreateMessage.msgMessenger" />
            </td>
            <td class="MainTableTopRowRightColumn">
                <table class="TopStatusBar">
                    <tr>
                        <td>
                            Manage Folders
                        </td>
                        <td>&nbsp;</td>
                        <td style="text-align: right">
                            <oscar:help keywords="message" key="app.top1"/> |
                            <a href="javascript:void(0)" onclick="javascript:popupPage(600,700,'../oscarEncounter/About.jsp')"><bean:message key="global.about" /></a>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="MainTableLeftColumn">&nbsp;</td>
            <td class="MainTableRightColumn">
                <form name="folderList" id="folderList" action="<%=request.getContextPath()%>/oscarMessenger/ManageFolder.do" method="post">
                <table>

                    <tr>
                        <td>
                            <table cellspacing=3>
                                <tr>
                                    <td>
                                        <table class=messButtonsA cellspacing=0 cellpadding=3>
                                            <tr>
                                                <td class="messengerButtonsA">
                                                 <html:link page="/oscarMessenger/DisplayMessages.jsp" styleClass="messengerButtons">
                                                    <bean:message key="oscarMessenger.ViewMessage.btnInbox" />
                                                </html:link></td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td>
                                        <table class=messButtonsA cellspacing=0 cellpadding=3>
                                            <tr>
                                                <td class="messengerButtonsA">
                                                    <a href="javascript:BackToOscar()" class="messengerButtons"><bean:message key="oscarMessenger.CreateMessage.btnExit" /></a>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <input name="submit" type="submit" value="Delete">
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    <tr>
                        <td>

                            <table id="folders">

                                    <tr>
                                        <th align="left" bgcolor="#DDDDFF" width="75">
                                            <input type="checkbox" name="checkAll2" onclick="checkAll('folderList')" id="checkA" />
                                        </th>
                                        <th align="left" bgcolor="#DDDDFF">
                                            Folder
                                        </th>
                                    </tr>

                                <tbody class="ui-sortable">
                                   <% for (MessageFolder folder : messageFolders){%>
                                    <tr>
                                        <td bgcolor="#EEEEFF" valign=top>
                                            <input type="checkbox" name="folderId" value="<%=folder.getId()%>" />

                                        </td>

                                        <td bgcolor="#EEEEFF" valign=top>
                                            <input class="editable" type="text" name="<%=folder.getId()%>" value="<%=folder.getName()%>" onblur="renameFolder(this);" ondblclick="this.readOnly=''" readonly="true">

                                            <% if (messageFolders.get(messageFolders.size()-1)!=folder){%>
                                            <a href="javascript:void(0);"  onclick="order('down',<%=folder.getId()%>)" class="reorder"><img border="0" src="/oscar/images/icon_down_sort_arrow.png"></a>
                                            <%}%>
                                            <% if (messageFolders.get(0)!=folder){%>
                                            <a href="javascript:void(0);" onclick="order('up',<%=folder.getId()%>)" class="reorder"><img border="0" src="/oscar/images/icon_up_sort_arrow.png"></a>
                                            <%}%>

                                        </td>
                                    </tr>
                                    <%}%>
                </form>


                                    <tr>
                                        <td bgcolor="#B8B8FF"></td>
                                        <td bgcolor="#B8B8FF"><font style="font-weight: bold">Add New</font></td>
                                    </tr>

                                    <tr>
                                        <td bgcolor="#EEEEFF"></td>
                                        <td bgcolor="#EEEEFF">
                                            <form name="AddFolder" action="<%=request.getContextPath()%>/oscarMessenger/ManageFolder.do" method="post">
                                                <input type="text" name="folderName" size="30" />
                                                <input type="submit" name="submit" class="ControlPushButton" value="Add" />
                                            </form>


                                        </td>

                                    </tr>
                                </tbody>
                            </table>

                        </td>
                    </tr>
                    <tr>
                        <td></td>
                    </tr>

                </table>
            </td>
        </tr>
        <tr>
            <td class="MainTableBottomRowLeftColumn">&nbsp;</td>
            <td class="MainTableBottomRowRightColumn">&nbsp;</td>
        </tr>
    </table>
    </body>
</html:html>