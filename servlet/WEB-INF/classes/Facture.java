/*
 * Copyright (c) 2005-2013, François Tigeot
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
*/

import java.io.*;

import javax.servlet.*;
import javax.servlet.http.*;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.Source;
import javax.xml.transform.Result;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.sax.SAXResult;

import org.apache.fop.apps.FOUserAgent;
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.MimeConstants;

import java.net.URI;

public class Facture extends HttpServlet {
	private static String baseDir = "/usr/local/Corylus/xsl-stylesheets";
	private static String xslFileName = "facture.xsl";

	protected TransformerFactory transformerFactory;
	protected FopFactory fopFactory = null;

	public void init() throws ServletException {
		this.transformerFactory = TransformerFactory.newInstance();
		this.fopFactory = FopFactory.newInstance();
		try {
			this.fopFactory.setBaseURL( baseDir );
		} catch ( Exception ex ) {
			throw new ServletException(ex);
		}
		try {
			this.fopFactory.setUserConfig(new File(baseDir, "fop.conf"));
		} catch ( Exception ex ) {
			throw new ServletException(ex);
		}
	}
	
    public void doGet( HttpServletRequest request, HttpServletResponse response )
	throws ServletException, IOException {

		// id must be a number > 0
		String request_id;
		if (request.getParameter("id") != null) {
			request_id = request.getParameter("id");
		} else {
			PrintWriter out = response.getWriter();
			response.setContentType("text/plain");
			out.println("PDF Transformation error: request_id not set.");
			return;
		}

		String request_host;
		if (request.getParameter("host") != null) {
			request_host = request.getParameter("host");
		} else {
			PrintWriter out = response.getWriter();
			response.setContentType("text/plain");
			out.println("PDF Transformation error: request_host not set.");
			return;
		}

		String filename;
		if (request.getParameter("filename") != null) {
			filename = request.getParameter("filename");
		} else {
			return;
		}

		String xml_url  = "http://" + request_host + "/invoices/facture/" + request_id + ".xml";
		File xslFile = new File( baseDir, xslFileName );

		Source xmlSource = new StreamSource( xml_url );
		Source xslSource = new StreamSource(xslFile);

		try {
			Transformer trans = this.transformerFactory.newTransformer(xslSource);

			FOUserAgent foUserAgent = this.fopFactory.newFOUserAgent();

			//Setup a buffer to obtain the content length
			ByteArrayOutputStream out = new ByteArrayOutputStream();

			Fop fop = this.fopFactory.newFop(MimeConstants.MIME_PDF, foUserAgent, out);

			//Setup Transformer
			Transformer transformer = this.transformerFactory.newTransformer( xslSource );

			//Make sure the XSL transformation's result is piped through to FOP
			Result res = new SAXResult(fop.getDefaultHandler());

			//Start the transformation and rendering process
			transformer.transform( xmlSource, res);

			response.setContentType("application/pdf");
			if (filename != null) {
				response.setHeader("Content-Disposition",
					"attachment; filename=\"" + filename + "\"");
			}
			response.setContentLength(out.size());
    
			//Send content to Browser
			response.getOutputStream().write(out.toByteArray());
			response.getOutputStream().flush();
		} catch (Exception ex) {
			throw new ServletException(ex);
		}
	}

}
