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

<xsl:decimal-format grouping-separator=" " decimal-separator=","/>

<xsl:template match="/expense_report">
	<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
	
	<fo:layout-master-set>
		<fo:simple-page-master master-name="first"
				page-height="29.7cm"
				page-width="21cm"
				margin-top="1.0cm"
				margin-bottom="1.0cm"
				margin-left="1.0cm"
				margin-right="1.0cm">
			<fo:region-body/>
			<fo:region-after extent="1.5cm"/>
		</fo:simple-page-master>
	</fo:layout-master-set>

	<fo:page-sequence master-reference="first">

	<fo:static-content flow-name="xsl-region-after">
		<xsl:call-template name="footer"/>
	</fo:static-content>

	<fo:flow flow-name="xsl-region-body">
		<xsl:call-template name="adresse"/>
	
		<fo:block-container height="2cm" width="19cm" top="3cm" left="0cm" position="absolute">
		<fo:block font-weight="bold" font-size="24pt">
			Expense Report
		</fo:block>
		<fo:block border-top-style="solid" border-width="1mm" border-color="rgb(153,0,0)"/>
		<fo:block font-size="10pt" margin-top="6pt">
			Date: <xsl:value-of select="/expense_report/date"/>
		</fo:block>
		<fo:block font-size="10pt" margin-top="6pt">
			Name: <xsl:value-of select="/expense_report/user"/>
		</fo:block>
		</fo:block-container>

	<fo:block-container position="absolute" width="19cm" height="11cm" top="9cm"
	font-size="10pt">
		<fo:table border-style="solid" border-width="0.2mm" border-collapse="collapse" width="19cm">
		<fo:table-column border-style="solid" border-width="0.2mm" column-width="2cm"/>
		<fo:table-column border-style="solid" border-width="0.2mm"/>
		<fo:table-column border-style="solid" border-width="0.2mm"/>
		<fo:table-column border-style="solid" border-width="0.2mm" column-width="3cm"/>
		<fo:table-column border-style="solid" border-width="0.2mm" column-width="2cm"/>
		<fo:table-header>
			<fo:table-row font-weight="bold" font-size="10pt">
				<fo:table-cell border-bottom-style="solid" border-width="0.2mm">
					<fo:block margin-top="4pt" margin-bottom="2pt" text-align="center">
						Date
					</fo:block>
				</fo:table-cell>
				<fo:table-cell border-bottom-style="solid" border-width="0.2mm">
					<fo:block margin-top="4pt" margin-bottom="2pt" text-align="center">
						Description
					</fo:block>
				</fo:table-cell>
				<fo:table-cell border-bottom-style="solid" border-width="0.2mm">
					<fo:block margin-top="4pt" margin-bottom="2pt" text-align="center">
						Merchant
					</fo:block>
				</fo:table-cell>
				<fo:table-cell border-bottom-style="solid" border-width="0.2mm">
					<fo:block margin-top="4pt" margin-bottom="2pt" text-align="center">
						Type of payment
					</fo:block>
				</fo:table-cell>
				<fo:table-cell border-bottom-style="solid" border-width="0.2mm">
					<fo:block margin-top="4pt" margin-bottom="2pt" text-align="center">
						Amount
					</fo:block>
				</fo:table-cell>
			</fo:table-row>
		</fo:table-header>

		<fo:table-body>
				<xsl:apply-templates/>
		</fo:table-body>
		</fo:table>

		<fo:block height="1cm">&#160;</fo:block>

		<fo:table border-collapse="collapse" width="19cm">
			<fo:table-column border-style="none"/>
			<fo:table-column column-width="3cm" border-style="solid" border-width="0.2mm"/>
			<fo:table-column column-width="2cm" border-style="solid" border-width="0.2mm"/>
		<fo:table-body>
			<fo:table-row font-size="10pt" font-family="Liberation Sans">
				<fo:table-cell><fo:block/></fo:table-cell>
				<fo:table-cell>
					<fo:block margin-top="4pt" margin-bottom="2pt" text-align="center">
						Total cost
					</fo:block>
				</fo:table-cell>
				<fo:table-cell font-weight="bold">
					<fo:block margin-top="4pt" margin-bottom="2pt"
					margin-right="4pt" text-align="end">
						<xsl:value-of select="format-number(total_cost, '0,00')"/> €
					</fo:block>
				</fo:table-cell>
			</fo:table-row>
		</fo:table-body>
		</fo:table>

	</fo:block-container>

	</fo:flow>
	</fo:page-sequence>
	</fo:root>
</xsl:template>

<xsl:include href="common.xsl"/>

<xsl:template match="item">
	<fo:table-row border-style="solid" border-width="0.2mm"
	font-size="9pt" font-family="Liberation Sans">

		<fo:table-cell><fo:block margin-top="4pt" margin-bottom="2pt" text-align="center">
			<xsl:value-of select="date"/>
		</fo:block></fo:table-cell>

		<fo:table-cell><fo:block margin-top="4pt" margin-bottom="2pt" text-align="left"
		margin-left="4pt">
			<xsl:value-of select="description"/>
		</fo:block></fo:table-cell>

		<fo:table-cell><fo:block margin-top="4pt" margin-bottom="2pt" text-align="left"
		margin-left="4pt">
			<xsl:value-of select="merchant"/>
		</fo:block></fo:table-cell>

		<fo:table-cell><fo:block margin-top="4pt" margin-bottom="2pt" text-align="center">
			<xsl:value-of select="payment"/>
		</fo:block></fo:table-cell>

		<fo:table-cell><fo:block margin-top="4pt" text-align="end" margin-right="4pt">
			<xsl:value-of select="format-number(amount,'0,00')"/> €
		</fo:block></fo:table-cell>


	</fo:table-row>
</xsl:template>

</xsl:stylesheet>
