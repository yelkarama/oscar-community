/**
 * Copyright (c) 2001-2012. Department of Family Medicine, McMaster University. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */
package org.oscarehr.integration.pccds;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;

import org.apache.commons.codec.EncoderException;
import org.apache.commons.codec.language.RefinedSoundex;
import org.apache.commons.codec.language.Soundex;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.log4j.xml.DOMConfigurator;
import org.oscarehr.util.ConfigXmlUtils;
import org.oscarehr.util.CxfClientUtils.TrustAllManager;

public final class MiscUtils
{
	public static final String DEFAULT_UTF8_ENCODING = "UTF-8";

	/**
	 * This method should only really be called once per context in the context startup listener.	 
	 * @param contextPath
	 */
	public static void addLoggingOverrideConfiguration(String contextPath)
	{
		String configLocation = System.getProperty("log4j.override.configuration");
		if (configLocation != null)
		{
			if (contextPath != null)
			{
				if (contextPath.length() > 0 && contextPath.charAt(0) == '/') contextPath = contextPath.substring(1);
				if (contextPath.length() > 0 && contextPath.charAt(contextPath.length() - 1) == '/') contextPath = contextPath.substring(0, contextPath.length() - 2);
			}

			String resolvedLocation = configLocation.replace("${contextName}", contextPath);
			getLogger().info("loading additional override logging configuration from : " + resolvedLocation);
			DOMConfigurator.configureAndWatch(resolvedLocation);
		}
	}

	/**
	 * This method will return a logger instance which has the name based on the class that's calling this method.
	 */
	public static Logger getLogger()
	{
		StackTraceElement[] ste = Thread.currentThread().getStackTrace();
		String caller = ste[2].getClassName();
		return(Logger.getLogger(caller));
	}

	/**
	 * This requires a config.xml file with a category=misc and property=build_date_time, the value 
	 * should be populated by your build command.
	 */
	public static String getBuildDateTime()
	{
		return(ConfigXmlUtils.getPropertyString("misc", "build_date_time"));
	}

	/**
	 * This requires a config.xml file with a category=misc and property=build_version, the value 
	 * should be populated by your build command.

	 * A unique string per compile which is url safe. This value can be used 
	 * to tag css/js files for browser caching flushes.
	 */
	public static String getBuildVersion()
	{
		return (ConfigXmlUtils.getPropertyString("misc", "build_version"));
	}

	public static String trimToNullLowerCase(String s)
	{
		s = StringUtils.trimToNull(s);

		if (s != null) s = s.toLowerCase();

		return(s);
	}

	public static String trimToNullUpperCase(String s)
	{
		s = StringUtils.trimToNull(s);

		if (s != null) s = s.toUpperCase();

		return(s);
	}

	/**
	 * Null safe, will return null
	 */
	public static String getEmailAddressNoDomain(String s)
	{
		if (s == null) return(null);

		int indexOfAt = s.indexOf('@');
		if (indexOfAt != -1) s = s.substring(0, indexOfAt);
		return(s);
	}

	public static byte[] serialize(Serializable s) throws IOException
	{
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		ObjectOutputStream oos = new ObjectOutputStream(baos);
		oos.writeObject(s);
		return(baos.toByteArray());
	}

	public static Serializable deserialize(byte[] b) throws IOException, ClassNotFoundException
	{
		return((Serializable) (new ObjectInputStream(new ByteArrayInputStream(b))).readObject());
	}

	/**
	 * @param filename is on the filesystem only.
	 */
	public static void serializeToFile(Serializable s, String filename) throws IOException
	{
		FileOutputStream fos = new FileOutputStream(filename);ObjectOutputStream oos = new ObjectOutputStream(fos);
		try
		{
			oos.writeObject(s);
			oos.flush();
			fos.flush();
		}
		finally
		{
			if (fos!=null) fos.close();
		}		
	}

	/**
	 * @param filename can be from filesystem or classpath.
	 */
	public static Serializable deserializeFromFile(String filename) throws IOException, ClassNotFoundException
	{
		InputStream is = MiscUtils.class.getResourceAsStream(filename);

		try
		{
			if (is == null) is = new FileInputStream(filename);
			ObjectInputStream ois=new ObjectInputStream(is);
			try 
			{
				return((Serializable) (ois).readObject());
			}
			finally
			{
				if (ois!=null) ois.close();
			}
		}
		finally
		{
			if (is!=null) is.close();
		}
	}

	/**
	 * This method is only really intended for reading from the local file system, it may not work so well over the network.
	 */
	public static byte[] readFileAsByteArray(String url) throws IOException
	{
		InputStream is = MiscUtils.class.getResourceAsStream(url);
		try 
		{
			
			if (is == null) return (null);

			int size = is.available();
			byte[] b = new byte[size];
			is.read(b);
			return (b);
		}
		finally
		{
			if (is!=null) is.close();
		}
	}

	/**
	 * This method is only really intended for reading from the local file system, it may not work so well over the network.
	 */
	public static String readFileAsString(String url) throws IOException
	{
		return(new String(readFileAsByteArray(url)));
	}

	/**
	 * get a random string of type-able characters alpha numeric and symbols but not escape or control characters, suitable for random password generation.
	 * characters 33 to 126 inclusive. Might remove some confusing or odd characters to prevent confusion like 1,l,I and o,0,O also commas and quotes are removed for easy csv-ing.
	 */
	public static String getRandomString(int length)
	{
		StringBuilder sb = new StringBuilder();

		Random random = new Random();
		while (sb.length() < length)
		{
			int ch = random.nextInt(89);
			ch = ch + 33;

			// quotes and commas removed for csv-ing
			// = removed for people importing into excel files (yeah wussy reason but meh...)
			// I/1/l and o/0/O are not always distinguishable depending on fonts. 
			if (ch != '\'' && ch != '`' && ch != '"' && ch != '1' && ch != 'I' && ch != 'l' && ch != '0' && ch != 'o' && ch != 'O' && ch != ',' && ch != '=') sb.append((char) ch);
		}

		return(sb.toString());
	}
	

	public static String escapeCsv(String s)
	{
		if (s == null) return(null);

		boolean requiresQuoting = false;

		if (s.contains("\""))
		{
			s = s.replaceAll("\"", "\"\"");
			requiresQuoting = true;
		}

		if (s.contains(",") || s.contains("\n"))
		{
			requiresQuoting = true;
		}

		if (requiresQuoting)
		{
			s = '"' + s + '"';
		}

		return(s);
	}

	/**
	 * Use this with care, it is meant to allow the use of self signed certificates everywhere.
	 * This means all authentication of communications is now invalid, the only thing you're getting
	 * is encryption of the communications.
	 */
	public static void setJvmDefaultSSLSocketFactoryAllowAllCertificates() throws NoSuchAlgorithmException, KeyManagementException
	{
		TrustAllManager[] tam = { new TrustAllManager() };

		SSLContext ctx = SSLContext.getInstance("TLS");
		ctx.init(null, tam, new SecureRandom());
		SSLSocketFactory sslSocketFactory = ctx.getSocketFactory();
		HttpsURLConnection.setDefaultSSLSocketFactory(sslSocketFactory);

		HostnameVerifier hostNameVerifier = new HostnameVerifier()
		{
			@Override
			public boolean verify(String host, SSLSession sslSession)
			{
				return(true);
			}
		};
		HttpsURLConnection.setDefaultHostnameVerifier(hostNameVerifier);
	}

	/**
	 * This method will trim and tolower case for you.
	 * @return true if the strings are not null / blank and sounds like each other
	 */
	public static boolean refinedSoundex(String s1, String s2) throws EncoderException
	{
		return(refinedSoundexScore(s1, s2) >= 4);
	}

	/**
	 * This method will trim and tolower case for you.
	 * @return the soundex difference, -1 will be returned if null or empty strings are passed in.
	 * @throws EncoderException 
	 */
	public static int refinedSoundexScore(String s1, String s2) throws EncoderException
	{
		s1 = StringUtils.trimToNull(s1);
		s2 = StringUtils.trimToNull(s2);
		if (s1 == null || s2 == null) return(-1);

		s1 = s1.toLowerCase();
		s2 = s2.toLowerCase();

		RefinedSoundex soundex = new RefinedSoundex();
		int difference = soundex.difference(s1, s2);

		return(difference);
	}

	/**
	 * This method will trim and tolower case for you.
	 * @return true if the strings are not null / blank and sounds like each other
	 */
	public static boolean soundex(String s1, String s2) throws EncoderException
	{
		return(soundexScore(s1, s2) >= 4);
	}

	/**
	 * This method will trim and tolower case for you.
	 * @return the soundex difference, -1 will be returned if null or empty strings are passed in.
	 * @throws EncoderException 
	 */
	public static int soundexScore(String s1, String s2) throws EncoderException
	{
		s1 = StringUtils.trimToNull(s1);
		s2 = StringUtils.trimToNull(s2);
		if (s1 == null || s2 == null) return(-1);

		s1 = s1.toLowerCase();
		s2 = s2.toLowerCase();

		Soundex soundex = new Soundex();
		int difference = soundex.difference(s1, s2);

		return(difference);
	}
	
	/**
	 * This checks the thrown chain of causes to see if there's an exact match for a given exception.
	 * Note this will not be a super/sub class match on causes.
	 */
	public static boolean containsCause(Throwable thrown, Class<? extends Throwable> checkForThisThrowableClass)
	{
		if (thrown==null) return(false);
		
		if (thrown.getClass().equals(checkForThisThrowableClass)) return(true);
		
		return(containsCause(thrown.getCause(), checkForThisThrowableClass));
	}
	
	/**
	 * Will return null for null csv,
	 * will silently discard values not representing longs,
	 * will trim white space.
	 */
	public static List<Long> getCsvAsLongList(String csv)
	{
		if (csv==null) return(null);
		
		ArrayList<Long> results=new ArrayList<Long>();
		
		String[] split=csv.split(",");
		for (String s : split)
		{
			s=StringUtils.trimToNull(s);
			if (s!=null)
			{
				try
				{
					results.add(new Long(s));
				}
				catch (NumberFormatException e)
				{
					// as per specification, we will silently discard non-numbers
				}
			}
		}
		
		return(results);
	}
	
	public static String getLongListAsCsv(List<Long> list)
	{
		if (list==null) return(null);
		
		StringBuilder sb=new StringBuilder();
		
		for (Long l : list)
		{
			if (sb.length()!=0) sb.append(',');
			sb.append(l);
		}
		
		return(sb.toString());
	}
	
	public static String getLongArrayAsCsv(Long[] list)
	{
		if (list==null) return(null);
		
		StringBuilder sb = new StringBuilder();

		for (Long l : list)
		{
			if (sb.length() != 0) sb.append(',');
			sb.append(l);
		}

		return (sb.toString());
	}
	
	/**
	 * This is an efficient way to add the byte arrays together.
	 * @return an array with all the bytes concatenated or null if null was passed in.
	 */
	public static byte[] addArrays(byte[]... byteArrays)
	{
		if (byteArrays==null) return(null);
		
		int totalSize=0;
		
		for (byte[] temp : byteArrays)
		{
			totalSize=totalSize+temp.length;
		}
		
		byte[] result=new byte[totalSize];
		int startPointer=0;
		
		for (byte[] temp : byteArrays)
		{
			System.arraycopy(temp, 0, result, startPointer, temp.length);
			startPointer=startPointer+temp.length;
		}
		
		return(result);
	}

	public static byte[] toBytes(long val)
	{
		byte[] b = new byte[8];
		for (int i = 7; i > 0; i--)
		{
			b[i] = (byte) val;
			val >>>= 8;
		}
		b[0] = (byte) val;
		return b;
	}
}
