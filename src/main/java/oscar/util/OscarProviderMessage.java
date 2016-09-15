package oscar.util;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * A servlet that returns the proivder_message property contained
 * in the provider_messages.properties in the user.home directory
 * @author kai
 *
 */
public class OscarProviderMessage extends HttpServlet {
	private static final String PROVIDER_MESSAGE_NAME = "provider_messages.properties";
	
	private String providerMessage;

	public void init() throws ServletException
	{
	}
	
	public void doGet(HttpServletRequest request,
	                  HttpServletResponse response)
	          throws ServletException, IOException
	{
	    response.setContentType("text/html");
	
		Path providerMessagePath = Paths.get(System.getProperty("user.home"), PROVIDER_MESSAGE_NAME);
		Properties providerMessages = new Properties();
		if (Files.exists(providerMessagePath))
		{
			InputStream is = new FileInputStream(providerMessagePath.toString());
			providerMessages.load(is);
			providerMessage = providerMessages.getProperty("proivder_message");
			if (providerMessage!=null)
			{
			    PrintWriter out = response.getWriter();
			    out.println(providerMessage);
			}
		}
	}
	
	public void destroy()
	{
	    // do nothing.
	}
}