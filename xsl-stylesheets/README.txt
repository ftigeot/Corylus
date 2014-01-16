This directory contains xsl stylesheet necessary to generate PDF documents
ready for printing.


How this works:

- Important parts of the document are first written in XML format (content
  only, no style)

- This first XML description is then converted to a FO document with the
  help of an XSL stylesheet
  (this stage is not visible from the web interface)

- The XSL:FO document is then converted to PDF

The local Makefile and .xml files allow the generation of sample documents
and the examination of XSL:FO content from the command line.

These xsl stylesheet are ready to be used from Tomcat servlets in the
../servlet/ directory



Even though it is possible to use the XSL language to perform
calculations, this is not done here. The stylesheet only display verbatim
information present in the original XML documents.

There's a good reason for that: XSLT 1.0 only handles floating point
binary calculations and cannot maintain an acceptable level of precision
with decimal data.



Required software:

- A 1.4 or more recent jdk
- Apache Fop 0.20.5 or more recent
- JAI ou Jimi to handle .png images

Optional Dependencies:

- Liberation Sans font
  (If you want documents produced by the default style sheets to look good)

