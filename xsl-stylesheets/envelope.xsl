<?xml version="1.0" encoding="utf-8"?>

<!--
Copyright (c) 2005-2014 François Tigeot
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.
-->

<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	version="1.0">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="/envelope">
	<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">

	<fo:layout-master-set>
		<fo:simple-page-master master-name="first"
				page-height="29.7cm" 
				page-width="21.0cm"
				margin-top="0cm" 
				margin-bottom="0cm" 
				margin-left="0cm" 
				margin-right="0cm">
			<fo:region-body margin-top="0cm"/>
			<fo:region-before extent="0cm"/>
			<fo:region-after extent="0cm"/>
		</fo:simple-page-master>
	</fo:layout-master-set>

	<fo:page-sequence master-reference="first">

		<fo:flow flow-name="xsl-region-body">

			<fo:block-container height="1.2cm" width="1.2cm" top="1.5cm" left="0.5cm" position="absolute"
			border-style="solid" border-width="0.2mm" border-color="black">
				<fo:block line-height="0" font-size="0">
					<fo:external-graphic src="logo-court.png"
					width="1.2cm" content-width="scale-to-fit"
					height="1.2cm" content-height="scale-to-fit"
					alignment-baseline="middle" scaling="uniform"/>
				</fo:block>
			</fo:block-container>

			<fo:block-container height="1.3cm" width="6cm" top="1.5cm" left="1.9cm" position="absolute">
				<fo:block font-size="8pt">
					<fo:block><xsl:value-of select="orig/name"/></fo:block>
					<fo:block><xsl:value-of select="orig/addr1"/></fo:block>
					<fo:block><xsl:value-of select="orig/addr2"/></fo:block>
					<fo:block>
						<xsl:value-of select="orig/postcode"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="orig/city"/>
					</fo:block>
				</fo:block>
			</fo:block-container>

			<fo:block-container height="3cm" width="9cm" top="6cm" left="10.5cm" position="absolute">
				<fo:block font-size="12pt">
					<fo:block><xsl:value-of select="dest/name"/></fo:block>
					<fo:block><xsl:value-of select="dest/service"/></fo:block>
					<fo:block><xsl:value-of select="dest/addr1"/></fo:block>
					<fo:block><xsl:value-of select="dest/addr2"/></fo:block>
					<fo:block>
						<xsl:value-of select="dest/postcode"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="dest/city"/>
					</fo:block>
				</fo:block>
			</fo:block-container>

		</fo:flow>

	</fo:page-sequence>

	</fo:root>
</xsl:template>

<xsl:include href="common.xsl"/>

</xsl:stylesheet>
