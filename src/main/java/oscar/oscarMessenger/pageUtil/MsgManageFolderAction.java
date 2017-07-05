/**
 * KAI INNOVATIONS
 */

package oscar.oscarMessenger.pageUtil;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.common.dao.MessageFolderDao;
import org.oscarehr.common.dao.MessageListDao;
import org.oscarehr.common.model.MessageFolder;
import org.oscarehr.common.model.MessageList;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class MsgManageFolderAction extends Action {
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
    MessageFolderDao messageFolderDao = SpringUtils.getBean(MessageFolderDao.class);

    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_msg", "w", null)) {
            throw new SecurityException("missing required security object (_msg)");
        }
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        String action = request.getParameter("submit")!=null?request.getParameter("submit"):"";

        if (action.equalsIgnoreCase("add")){
            add(mapping, request, loggedInInfo);
        } else if (action.equalsIgnoreCase("rename")){
            rename(mapping, request,loggedInInfo);
        } else if (action.equalsIgnoreCase("reorder")){
            reorder(mapping, request,loggedInInfo);
        } else if (action.equalsIgnoreCase("delete")) {
            delete(mapping, request, loggedInInfo);
        }

        return new ActionForward("/oscarMessenger/ManageFolders.jsp");
    }

    public ActionForward add(ActionMapping mapping, HttpServletRequest request, LoggedInInfo loggedInInfo) {
        if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_msg", "w", null)) {
            throw new SecurityException("missing required security object (_msg)");
        }

        String providerNo = loggedInInfo.getLoggedInProviderNo();
        String folderName = request.getParameter("folderName");
        int messageCount = messageFolderDao.findAllFoldersByProvider(providerNo)!=null?messageFolderDao.findAllFoldersByProvider(providerNo).size():0;


        if (folderName!=null && !folderName.trim().equals("")){
            MessageFolder messageFolder = new MessageFolder();
            messageFolder.setName(folderName.trim());
            messageFolder.setProviderNo(providerNo);
            messageFolder.setDisplayOrder(messageCount+1);
            messageFolderDao.saveEntity(messageFolder);
        }

        return new ActionForward("/oscarMessenger/ManageFolders.jsp");
    }

    public ActionForward rename(ActionMapping mapping, HttpServletRequest request, LoggedInInfo loggedInInfo) {
        String providerNo = loggedInInfo.getLoggedInProviderNo();
        String id = request.getParameter("folderId");
        String name = request.getParameter("newName");

        MessageFolder folder = messageFolderDao.findByProvider(providerNo,Integer.valueOf(id));
        if (folder!=null && name!=null && !name.trim().equals("")){
            folder.setName(name);

            messageFolderDao.merge(folder);
        }

        return new ActionForward("/oscarMessenger/ManageFolders.jsp");
    }

    public ActionForward reorder(ActionMapping mapping, HttpServletRequest request, LoggedInInfo loggedInInfo) {
        String providerNo = loggedInInfo.getLoggedInProviderNo();
        String id = request.getParameter("folderId");
        String direction = request.getParameter("direction");

        MessageFolder folder = messageFolderDao.findByProvider(providerNo,Integer.valueOf(id));
        if (folder!=null){

            if (direction.equalsIgnoreCase("up")){
                MessageFolder previousFolder = messageFolderDao.findByDisplayOrder(providerNo, (folder.getDisplayOrder()-1));
                if(previousFolder!=null){
                    previousFolder.setDisplayOrder(previousFolder.getDisplayOrder()+1);
                    messageFolderDao.merge(previousFolder);
                }
                folder.setDisplayOrder(folder.getDisplayOrder()-1);
            } else if (direction.equalsIgnoreCase("down")){
                MessageFolder nextFolder = messageFolderDao.findByDisplayOrder(providerNo, (folder.getDisplayOrder()+1));
                if(nextFolder!=null){
                    nextFolder.setDisplayOrder(nextFolder.getDisplayOrder()-1);
                    messageFolderDao.merge(nextFolder);
                }
                folder.setDisplayOrder(folder.getDisplayOrder()+1);
            }
            messageFolderDao.merge(folder);
        }

        return new ActionForward("/oscarMessenger/ManageFolders.jsp");
    }

    public ActionForward delete(ActionMapping mapping, HttpServletRequest request, LoggedInInfo loggedInInfo) {
        String providerNo = loggedInInfo.getLoggedInProviderNo();
        List<String> folderId = new ArrayList<String>();
        if(request.getParameterValues("folderId")!=null){
            folderId = Arrays.asList(request.getParameterValues("folderId"));
        }
        MessageListDao messageListDao = SpringUtils.getBean(MessageListDao.class);

        if (folderId!=null && !folderId.isEmpty()) {
            for (String id : folderId) {
                MessageFolder folder = messageFolderDao.findByProvider(providerNo, Integer.valueOf(id));
                if (folder != null) {
                    folder.setDeleted(true);
                    folder.setDisplayOrder(-1);

                    // Move any messages back to the inbox
                    List<MessageList> messageList = messageListDao.findByProviderAndFolder(providerNo, Integer.valueOf(id));
                    for (MessageList message : messageList) {
                        message.setFolderId(0);
                        messageListDao.merge(message);
                    }
                    messageFolderDao.merge(folder);
                }
            }
        }

        return new ActionForward("/oscarMessenger/ManageFolders.jsp");
    }


}
