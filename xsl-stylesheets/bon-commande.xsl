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

<xsl:output method="xml"/>

<xsl:decimal-format grouping-separator=" " decimal-separator=","/>

<xsl:template match="/bdc">
	<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
	
	<fo:layout-master-set>
		<fo:simple-page-master master-name="first"
				page-height="29.7cm" 
				page-width="21cm"
				margin-top="1.0cm" 
				margin-bottom="1.0cm" 
				margin-left="1.0cm" 
				margin-right="1.0cm">
			<fo:region-body margin-top="3cm"/>
			<fo:region-before extent="3cm"/>
			<fo:region-after extent="1.5cm"/>
		</fo:simple-page-master>
	</fo:layout-master-set>

	<fo:page-sequence master-reference="first">
		<fo:static-content flow-name="xsl-region-before">
			<fo:table> 
				<fo:table-column border-style="solid" border-width="0.3mm"
					background-color="rgb(240,240,240)"/>
				<fo:table-column column-width="2cm"/>
				<fo:table-column border-style="solid" border-width="0.3mm"
					background-color="rgb(240,240,240)"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell padding="2mm">
							<xsl:call-template name="adresse"/>
						</fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell padding="2mm">
							<fo:block>Numéro de commande: <xsl:value-of select="/bdc/@id"/></fo:block>
							<fo:block font-size="11pt">
								<fo:block>Date: <xsl:value-of select="/bdc/date"/></fo:block>
								<fo:block>&#160;</fo:block>
								<fo:block>Votre interlocuteur: <xsl:value-of select="/bdc/username"/></fo:block>
								<fo:block><xsl:value-of select="/bdc/contact_email"/></fo:block>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:static-content> 

		<fo:static-content flow-name="xsl-region-after">
			<xsl:call-template name="footer"/>
		</fo:static-content> 

		<fo:flow flow-name="xsl-region-body" font-family="Liberation Sans">
			<fo:block-container height="1.5cm" overflow="hidden">
			<fo:block>
				<fo:external-graphic src="logo-long.png"
				height="1.5cm" content-height="scale-to-fit"/>
			</fo:block>
			</fo:block-container>
			<fo:block-container height="2cm" width="19cm" top="0.5cm" left="0cm" position="absolute">
			<fo:block font-weight="bold" font-size="24pt">
				Bon de commande
			</fo:block>
			<fo:block border-top-style="solid" border-width="1mm"/>
			</fo:block-container>
			
			<fo:block-container height="3.5cm" width="19cm" top="2.5cm" left="0cm" position="absolute">
			<fo:table>
				<fo:table-column background-color="rgb(240,240,240)"/>
				<fo:table-column column-width="2cm"/>
				<fo:table-column background-color="rgb(240,240,240)"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell padding="1mm"
						border-style="solid" border-width="0.3mm">
							<fo:block font-weight="bold">Adresse de livraison</fo:block>
						</fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell padding="1mm"
						border-style="solid" border-width="0.3mm">
							<fo:block font-weight="bold">Fournisseur</fo:block>
						</fo:table-cell>
					</fo:table-row>
					<fo:table-row>
						<fo:table-cell padding="2mm"
						border-style="solid" border-width="0.3mm">
							<fo:block font-size="11pt">
							<fo:block><xsl:value-of select="delivery/name"/></fo:block>
							<fo:block><xsl:value-of select="delivery/addr1"/></fo:block>
							<fo:block><xsl:value-of select="delivery/addr2"/></fo:block>
							<fo:block>
								<xsl:value-of select="delivery/postcode"/>
								<xsl:text> </xsl:text>
								<xsl:value-of select="delivery/city"/>
							</fo:block>
							<xsl:if test="delivery/phone">
							<fo:block>Tél: <xsl:value-of select="delivery/phone"/></fo:block>
							</xsl:if>
							<xsl:if test="delivery/country">
							<fo:block><xsl:value-of select="delivery/country"/></fo:block>
							</xsl:if>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell padding="2mm"
						border-style="solid" border-width="0.3mm">
							<fo:block font-size="11pt">
							<fo:block><xsl:value-of select="distributor/name"/></fo:block>
							<fo:block><xsl:value-of select="distributor/addr1"/></fo:block>
							<fo:block><xsl:value-of select="distributor/addr2"/></fo:block>
							<fo:block>
								<xsl:value-of select="distributor/postcode"/>
								<xsl:text> </xsl:text>
								<xsl:value-of select="distributor/city"/>
							</fo:block>
							<xsl:if test="distributor/phone">
							<fo:block>Tél: <xsl:value-of select="distributor/phone"/></fo:block>
							</xsl:if>
							<xsl:if test="distributor/country">
							<fo:block><xsl:value-of select="distributor/country"/></fo:block>
							</xsl:if>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
			</fo:block-container>

			<fo:block-container position="absolute" width="19cm" height="11.5cm" top="6.5cm"
			border-bottom-style="solid" border-width="0.3mm"
			overflow="hidden">
			<fo:table table-layout="fixed"
				border-style="solid" border-width="0.3mm"
				border-collapse="collapse"
				width="19cm" height="11.5cm"
			>
				<fo:table-column column-width="3cm" overflow="hidden"
					border-style="solid" border-width="0.3mm"
					background-color="rgb(240,240,240)"/>
				<fo:table-column column-width="9cm"/>
				<fo:table-column column-width="1cm"
					border-style="solid" border-width="0.3mm"
					background-color="rgb(240,240,240)"/>
				<fo:table-column column-width="3cm"/>
				<fo:table-column column-width="3cm"
					border-style="solid" border-width="0.3mm"
					background-color="rgb(240,240,240)"/>
				/>
				<fo:table-header>
					<fo:table-row font-weight="bold" font-size="11pt">
						<fo:table-cell border-bottom-style="solid" border-width="0.3mm">
							<fo:block padding-top="4pt" padding-bottom="2pt" text-align="center">
								Référence
							</fo:block>
						</fo:table-cell>
						<fo:table-cell border-bottom-style="solid" border-width="0.3mm">
							<fo:block padding-top="4pt" padding-bottom="2pt" text-align="center">
								Description
							</fo:block>
						</fo:table-cell>
						<fo:table-cell border-bottom-style="solid" border-width="0.3mm">
							<fo:block padding-top="4pt" padding-bottom="2pt" text-align="center">
								Qté.
							</fo:block>
						</fo:table-cell>
						<fo:table-cell border-bottom-style="solid" border-width="0.3mm">
							<fo:block padding-top="4pt" padding-bottom="2pt" text-align="center">
								Prix unitaire
							</fo:block>
						</fo:table-cell>
						<fo:table-cell border-bottom-style="solid" border-width="0.3mm">
							<fo:block padding-top="4pt" padding-bottom="2pt" text-align="center">
								Montant
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-header>
				<fo:table-body>
					<xsl:apply-templates/>
					<fo:table-row height="11.5cm">
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
			</fo:block-container>

			<fo:block-container position="absolute" width="19cm" height="3cm" top="19.5cm">
				<fo:table border-width="0.3mm" border-collapse="collapse">
					<fo:table-column column-width="8.5cm"/>
					<fo:table-column column-width="4.5cm"/>
					<fo:table-column/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell padding="2mm" border-style="solid" border-width="0.3mm"
						background-color="rgb(240,240,240)">
							<fo:block>
								<xsl:value-of select="/bdc/comment"/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell>

				<fo:table border-width="0.3mm" border-collapse="collapse">
				<fo:table-column column-width="3cm"/>
				<fo:table-column column-width="3cm"
					border-style="solid" border-width="0.3mm"
					background-color="rgb(240,240,240)"
				/>
				<xsl:variable name="total_ht">
					<xsl:apply-templates mode="total" select="/bdc/item[1]"/>
				</xsl:variable>
				<xsl:variable name="tva" select="sum(vat_subtotal/value)"/>

				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<fo:block margin-top="3pt" margin-bottom="2pt" text-align="center">
								Total HT
							</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block margin-top="3pt" margin-bottom="2pt"
							margin-right="4pt" text-align="end">
								<xsl:value-of select="format-number($total_ht, '0,00')"/> €
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
					<fo:table-row>
						<fo:table-cell>
							<fo:block margin-top="3pt" margin-bottom="2pt" text-align="center">
								<xsl:call-template name="vat-rates"/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block margin-top="3pt" margin-bottom="2pt"
							margin-right="4pt" text-align="end">
								<xsl:call-template name="vat-sums"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
					<fo:table-row>
						<fo:table-cell>
							<fo:block margin-top="3pt" margin-bottom="2pt" text-align="center">
								Total TTC
							</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block margin-top="3pt" margin-bottom="2pt"
							margin-right="4pt" text-align="end">
								<xsl:value-of select="format-number($total_ht + $tva, '0,00')"/> €
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>

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

</xsl:stylesheet>
