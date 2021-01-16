package org.oscarehr.ws.rest;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.oscarehr.common.model.Document;
import org.oscarehr.managers.DocumentManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.ws.rest.conversion.DocumentConverter;
import org.oscarehr.ws.rest.to.model.DocumentTo1;
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
    public Response saveDocumentToDemographic(DocumentTo1 documentT) {
        Response response;

        if (StringUtils.isNotEmpty(documentT.getFileName()) && documentT.getFileContents().length > 0 && documentT.getDemographicNo() != null) {
            try {
                DocumentConverter documentConverter = new DocumentConverter();
                LoggedInInfo loggedInInfo = getLoggedInInfo();
                if (StringUtils.isEmpty(documentT.getSource())) {
                    documentT.setSource("REST API");
                }
                Document document = documentConverter.getAsDomainObject(loggedInInfo, documentT);
                document = documentManager.createDocument(loggedInInfo, document, documentT.getDemographicNo(), documentT.getProviderNo(), documentT.getFileContents());
                response = Response.ok(documentConverter.getAsTransferObject(loggedInInfo, document)).build();
            } catch (IOException e) {
                response = Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("The document could not be saved.").build();
            }
        } else {
            response = Response.status(Response.Status.BAD_REQUEST).entity("The request body must contain a title, encoded documentData, a fileType (png, jpg, pdf, etc.), and a demographicNo").build();
        }
        
        return response;
    }
}
