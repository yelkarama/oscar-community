package org.oscarehr.ws.rest;

import net.sf.json.JSONException;
import net.sf.json.JSONObject;
import org.apache.log4j.Logger;
import org.oscarehr.common.model.Document;
import org.oscarehr.managers.DocumentManager;
import org.oscarehr.util.MiscUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.io.IOException;
import java.util.Base64;

@Service
@Path("/document")
@Component("documentService")
public class DocumentService extends AbstractServiceImpl{
    @Autowired
    DocumentManager documentManager;
    
    Logger logger = MiscUtils.getLogger();

    
    @POST
    @Path("/saveDocumentToDemographic")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response saveDocumentToDemographic(JSONObject body) {
        Response response;

        try {
            String title = body.getString("title");
            String fileType = body.getString("fileType");
            String documentData = body.getString("documentData");
            Integer demographicNo = body.getInt("demographicNo");
            String providerNo = body.optString("providerNo", "");
            
            byte[] decodedDocument = Base64.getDecoder().decode(documentData);
            
            Document document = documentManager.createDocument(getLoggedInInfo(), title, demographicNo, providerNo, fileType, decodedDocument);
            response = Response.ok(document).build();
        } catch (IOException e) {
            response = Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("The document could not be saved.").build();
        } catch (JSONException e) {
            response = Response.status(Response.Status.BAD_REQUEST).entity("The request body must contain a title, encoded documentData, a fileType (png, jpg, pdf, etc.), and a demographicNo").build();
        }
        
        
        return response;
    }
}
