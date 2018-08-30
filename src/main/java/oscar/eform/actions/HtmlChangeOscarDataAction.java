package oscar.eform.actions;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.URLDecoder;
import java.util.Date;
import java.util.List;
import java.util.Random;

import javax.servlet.ServletInputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.common.dao.DocumentDao;
import org.oscarehr.common.dao.EFormDataDao;
import org.oscarehr.common.model.Document;
import org.oscarehr.common.model.EFormData;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import oscar.OscarProperties;
import oscar.eform.data.EForm;

public class HtmlChangeOscarDataAction extends DispatchAction{

	private static EFormDataDao eFormDataDao = (EFormDataDao) SpringUtils.getBean("EFormDataDao");
	
	public ActionForward saveHtmlValue(ActionMapping mapping, ActionForm form,HttpServletRequest request, HttpServletResponse response) {
		LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
		String providerNo=loggedInInfo.getLoggedInProviderNo();
		String fid = request.getParameter("fid");
		String fdid = request.getParameter("fdid");
		String demographic_no = request.getParameter("demographic_no");
		String js_data = request.getParameter("js_data");
		
		String home_dir = OscarProperties.getInstance().getProperty("eform_image");
		JSONObject ret = new JSONObject();
		String temp = "";
		String js_name = "";
		if(fid != null){
			EForm curForm = new EForm(fid, demographic_no, providerNo);
			String html = curForm.getFormHtml();
			
			if(html.indexOf("${oscar_image_path}") > -1){
				String sub_str = "${oscar_image_path}" + curForm.getFormName() + ".js";
				temp = html.substring(0, html.lastIndexOf(sub_str) + sub_str.length());
				js_name = temp.substring(temp.lastIndexOf("${oscar_image_path}") + "${oscar_image_path}".length() , temp.length());
			}
			
			if(js_name.length() > 0){
				ret.put("js_name_old", js_name);
				
				File file = null;
				File directory = new File(home_dir);
				js_name = getRandomStringByLength(6) + js_name;
				try{
		           if(!directory.exists()){
		              throw new Exception("Directory:  "+home_dir+ " does not exist");
		           }
		           home_dir = home_dir + curForm.getFormName();
		           directory = new File(home_dir);
		           if(!directory.exists()){
		        	   directory.mkdirs();
		           }
		           
		           file = new File(directory,js_name);
		           FileOutputStream fos=new FileOutputStream(file);
		           byte[] buffer = new byte[8192];
		           int bytesRead = 0;
		           ByteArrayInputStream stream = new ByteArrayInputStream(js_data.getBytes());
		           while ((bytesRead = stream.read(buffer, 0, 8192)) != -1) {
		        	   fos.write(buffer, 0, bytesRead);
	        	   }
		           
		           fos.close();
				}catch(Exception e){
					MiscUtils.getLogger().info(e.toString());
				}
				
				ret.put("js_name_new", js_name);
			}
		}else{
			EFormData eFormData = eFormDataDao.find(new Integer(fdid));
			String html = eFormData.getFormData();
			if(html.indexOf("${oscar_image_path}") > -1){
				String sub_str = eFormData.getFormName() + ".js";
				temp = html.substring(0, html.lastIndexOf(sub_str) + sub_str.length());
				js_name = temp.substring(temp.lastIndexOf("${oscar_image_path}") + "${oscar_image_path}".length() , temp.length());
			}

			if(js_name.length() > 0){
				ret.put("js_name_old", js_name);
				
				File file = null;
				File directory = new File(home_dir);
				js_name = getRandomStringByLength(6) + js_name;
				try{
		           if(!directory.exists()){
		              throw new Exception("Directory:  "+home_dir+ " does not exist");
		           }
		           home_dir = home_dir + eFormData.getFormName();
		           directory = new File(home_dir);
		           if(!directory.exists()){
		        	   directory.mkdirs();
		           }
		           
		           file = new File(directory,js_name);
		           byte bytes[]=new byte[512];
		           bytes = js_data.getBytes();   //新加的
		           int b = js_data.length();   //改
		           FileOutputStream fos=new FileOutputStream(file);
		           fos.write(bytes,0,b);
		           fos.close();
				}catch(Exception e){
					MiscUtils.getLogger().info(e.toString());
				}
				ret.put("js_name_new", js_name);
			}
		}
		
    	ret.put("saveFlag", "true");
    	try {
			PrintWriter out = response.getWriter();
			out.print(ret.toString());
			out.flush();
			out.close();
		} catch (Exception e) {
			MiscUtils.getLogger().info(e.toString());
		}
		return null;
	}
	
	/**
     * 获取一定长度的随机字符串
     * @param length 指定字符串长度
     * @return 一定长度的字符串
     */
    public static String getRandomStringByLength(int length) {
        String base = "abcdefghijklmnopqrstuvwxyz0123456789zyxwvutsrqponmlkjihgfedcba9876543210";
        Random random = new Random();
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < length; i++) {
            int number = random.nextInt(base.length());
            sb.append(base.charAt(number));
        }
        return sb.toString();
    }
    
    public ActionForward getFreeDrawImageList(ActionMapping mapping, ActionForm form,HttpServletRequest request, HttpServletResponse response){
    	DocumentDao docDao = (DocumentDao)SpringUtils.getBean("documentDao");
    	OscarProperties prop = OscarProperties.getInstance();
    	List<Document> pics = docDao.findByDoctype(prop.getProperty("FREE_DRAW_IMG_TYPE_NAME"));
    	
    	String ctx = request.getContextPath();
    	JSONArray obj = new JSONArray();
    	if (pics != null) {
			for (Document doc : pics) {
				JSONObject ret = new JSONObject();
				ret.put("image_name", doc.getDocdesc() + "-" + doc.getDocfilename());
				ret.put("image_path", ctx + "/oscarEncounter/freeDrawing.do?method=displayFreebgImg&docNo=" + doc.getId());
				obj.add(ret);
			}
    	}
    	
    	try {
			PrintWriter out = response.getWriter();
			out.print(obj.toString());
			out.flush();
			out.close();
		} catch (Exception e) {
			MiscUtils.getLogger().info(e.toString());
		}
    	return null;
    }
    
    public ActionForward uploadOscarPdf(ActionMapping mapping, ActionForm form,HttpServletRequest request, HttpServletResponse response) throws Exception{   
    		String isLetterhead = request.getParameter("isLetterhead");
    		String tmpstr = ""; 
    		InputStream is = request.getInputStream(); 
    		InputStreamReader isr = new InputStreamReader(is);   
    		BufferedReader br = new BufferedReader(isr); 
    		String s = "" ; 
    		while((s=br.readLine())!=null){
    			tmpstr+= s;
    		}
    		String[] splitArray = tmpstr.split(",");
    		byte [] dataByte= new byte[splitArray.length];
    		for (int i = 0;i < splitArray.length;i ++) {
    				String num = splitArray[i];
    				if (Integer.valueOf(num)>=128) {
    					num = String.valueOf(Integer.valueOf(num) - 256);
				}
    				dataByte[i] = Byte.valueOf(num);
    		}        
	    	BufferedInputStream bin = null;  
	        FileOutputStream fout = null;  
	        BufferedOutputStream bout = null;
	        try{
	    			ByteArrayInputStream bais = new ByteArrayInputStream(dataByte);
	    			bin = new BufferedInputStream(bais);
	    			File tempFile = null;
	    			if(null != isLetterhead && isLetterhead.equals("1")){
	    				tempFile = File.createTempFile("Letterhead", ".pdf");	
	    			}else{
	    				tempFile = File.createTempFile("EFormFax", ".pdf");
	    			}
	    	        fout = new FileOutputStream(tempFile); 
	    	        bout = new BufferedOutputStream(fout);
	    	        byte[] buffers = new byte[1024];  
	            int len = bin.read(buffers);  
	            while(len != -1){  
	                bout.write(buffers, 0, len);  
	                len = bin.read(buffers);  
	            }
	            bout.flush();
	            JSONObject obj = new JSONObject();
	            obj.put("existfilename", tempFile.getName());
				
				PrintWriter out = response.getWriter();
				out.print(obj.toString());
				out.flush();
				out.close();
        }catch (IOException e) {  
        		MiscUtils.getLogger().info(e.toString()); 
        }finally{  
            try {  
                bin.close();  
                fout.close();  
                bout.close();  
            } catch (IOException e) {  
            		MiscUtils.getLogger().info(e.toString());
            }  
        }
    		
    		return null;
    }
    
    public ActionForward uploadFreeDrawImage(ActionMapping mapping, ActionForm form,HttpServletRequest request, HttpServletResponse response){
    	try {
	    	String rootPath = OscarProperties.getInstance().getProperty("eform_image");
	    	rootPath = (rootPath.endsWith("\\") || rootPath.endsWith("/") ? rootPath : rootPath + "/");
	    	File folder = new File(rootPath);
	        if (!folder.exists()) {
	        	folder.mkdirs();
	        }
	        String name = System.currentTimeMillis() +"";
	        String filename = folder + File.separator + name + ".png";
			FileOutputStream fos = new FileOutputStream(new File(filename));
			String imageString = request.getParameter("thumbnailImage");
			if(null == imageString){
				ServletInputStream in = request.getInputStream();
				BufferedReader is = new BufferedReader(new InputStreamReader(in));
				StringBuffer strBuffer = new StringBuffer();
				String line = "";
				while ((line = is.readLine()) != null){
					strBuffer.append(line);
				}
				imageString = strBuffer.toString();
				imageString =  URLDecoder.decode(imageString, "UTF-8");
			}
			imageString = imageString.substring(imageString.indexOf(",")+1);
			
			Base64 b64 = new Base64();
			byte[] imageByteData = imageString.getBytes();
			byte[] imageData = b64.decode(imageByteData);
			if (imageData != null) {
				fos.write(imageData);
			}
			
			fos.flush();
			fos.close();
			
			JSONObject obj = new JSONObject();
			obj.put("ip", "");
			obj.put("imagePath", "../eform/displayImage.do?imagefile=");
			obj.put("imageName", name + ".png");
			
			PrintWriter out = response.getWriter();
			out.print(obj.toString());
			out.flush();
			out.close();
		} catch (IOException e) {
			MiscUtils.getLogger().info(e.toString());
		}
		
    	return null;
    }
    
    public ActionForward configOscarPdf(ActionMapping mapping, ActionForm form,HttpServletRequest request, HttpServletResponse response) throws Exception{   
		String tmpstr = ""; 
		InputStream is = request.getInputStream(); 
		InputStreamReader isr = new InputStreamReader(is);   
		BufferedReader br = new BufferedReader(isr); 
		String s = "" ; 
		while((s=br.readLine())!=null){
			tmpstr+= s;
		}
		String[] splitArray = tmpstr.split(",");
		byte [] dataByte= new byte[splitArray.length];
		for (int i = 0;i < splitArray.length;i ++) {
				String num = splitArray[i];
				if (Integer.valueOf(num)>=128) {
					num = String.valueOf(Integer.valueOf(num) - 256);
			}
				dataByte[i] = Byte.valueOf(num);
		}
		
		BufferedInputStream bin = null;  
	    FileOutputStream fout = null;  
	    BufferedOutputStream bout = null;
	    try{
			ByteArrayInputStream bais = new ByteArrayInputStream(dataByte);
			bin = new BufferedInputStream(bais);
			File tempFile = null;
			long time = new Date().getTime();
			tempFile = File.createTempFile(String.valueOf(time), ".pdf");	
	        fout = new FileOutputStream(tempFile); 
	        bout = new BufferedOutputStream(fout);
	        byte[] buffers = new byte[1024];  
	        int len = bin.read(buffers);  
	        while(len != -1){  
	            bout.write(buffers, 0, len);  
	            len = bin.read(buffers);  
	        }
	        bout.flush();
	        JSONObject obj = new JSONObject();
	        obj.put("existfilename", tempFile.getName());
			
			PrintWriter out = response.getWriter();
			out.print(obj.toString());
			out.flush();
			out.close();
	    }catch (IOException e) {  
	    		MiscUtils.getLogger().info(e.toString()); 
	    }finally{  
	        try {  
	            bin.close();  
	            fout.close();  
	            bout.close();  
	        } catch (IOException e) {  
	        		MiscUtils.getLogger().info(e.toString());
	        }  
	    }
		
		return null;
    }
}
