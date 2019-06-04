<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>

<%@ page import="java.sql.*, java.io.*, java.util.*, oscar.oscarDB.*" buffer="none"%>


<%@page import="org.apache.struts.upload.FormFile"%>
<%@page import="java.io.File"%>

			<%
				String providerNo = request.getParameter("provider_no");
				DBPreparedHandler dbObj = new DBPreparedHandler(); 
				String sql = "select signature from provider where provider_no=?";
				ResultSet rs = dbObj.queryResults(sql, providerNo);
				rs.first();
				byte[] bytearray = new byte[4096];
				int size=0;
				InputStream ips = rs.getBinaryStream("signature");
				response.reset();
				response.setContentType("image/jpeg");
				response.addHeader("Content-Disposition","filename=getimage.jpeg");
				while((size=ips.read(bytearray))!= -1 )
				{
					response.getOutputStream().write(bytearray,0,size) ;
				}
			    response.flushBuffer();
			    ips.close();
				rs.close();
			%>