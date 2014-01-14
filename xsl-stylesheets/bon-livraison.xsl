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

<xsl:template match="/bdl">
	<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
	
	<fo:layout-master-set>
		<fo:simple-page-master master-name="first"
				page-height="29.7cm" 
				page-width="21cm"
				margin-top="1.5cm" 
				margin-bottom="1.5cm" 
				margin-left="2.0cm" 
				margin-right="2.0cm">
			<fo:region-body margin-top="3cm"/>
			<fo:region-before extent="3cm"/>
			<fo:region-after extent="1.5cm"/>
		</fo:simple-page-master>
	</fo:layout-master-set>

	<fo:page-sequence master-reference="first">
		<fo:static-content flow-name="xsl-region-before">
			<fo:table> 
				<fo:table-column background-color="rgb(240,240,240)"/>
				<fo:table-column column-width="1cm"/>
				<fo:table-column background-color="rgb(240,240,240)"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell padding="2mm"
						border-style="solid" border-width="0.3mm">
							<xsl:call-template name="adresse"/>
						</fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell padding="2mm"
						border-style="solid" border-width="0.3mm">
							<fo:block>
								Bon de livraison n°<xsl:value-of select="/bdl/@id"/>
							</fo:block>
							<fo:block>Date: <xsl:value-of select="/bdl/date"/></fo:block>
							<fo:block>&#160;</fo:block>
							<xsl:if test="commande">
								<fo:block font-size="11pt">
									Suivant la commande
									<xsl:if test="commande/num">
										n°<xsl:value-of select="commande/num"/>
									</xsl:if>
								</fo:block>
								<fo:block font-size="11pt">
									du <xsl:value-of select="commande/date"/>
								</fo:block>
							</xsl:if>
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
			<fo:block-container height="2cm" width="17cm" top="0.5cm" left="0cm" position="absolute">
			<fo:block font-weight="bold" font-size="24pt">
				Bon de livraison
			</fo:block>
			<fo:block border-top-style="solid" border-width="1mm"/>
			</fo:block-container>
			
			<fo:block-container height="3cm" width="17cm" top="3cm" left="0cm" position="absolute">
			<fo:table>
				<fo:table-column background-color="rgb(240,240,240)"/>
				<fo:table-column column-width="1cm"/>
				<fo:table-column background-color="rgb(240,240,240)"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell padding="2mm"
						border-style="solid" border-width="0.3mm">
						<fo:block font-size="11pt">
						<xsl:if test="delivery">
							<fo:block>Livré à:</fo:block>
							<fo:block><xsl:value-of select="delivery/name"/></fo:block>
							<fo:block><xsl:value-of select="delivery/addr1"/></fo:block>
							<fo:block><xsl:value-of select="delivery/addr2"/></fo:block>
							<fo:block>
								<xsl:value-of select="delivery/postcode"/>
								<xsl:text> </xsl:text>
								<xsl:value-of select="delivery/city"/>
							</fo:block>
							<xsl:if test="delivery/country">
							<fo:block><xsl:value-of select="delivery/country"/></fo:block>
							</xsl:if>
						</xsl:if>
						</fo:block>
						</fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell padding="2mm"
						border-style="solid" border-width="0.3mm">
							<fo:block font-size="11pt">
							<xsl:if test="delivery">
							<fo:block>Facturé à:</fo:block>
							</xsl:if>
							<fo:block><xsl:value-of select="customer/name"/></fo:block>
							<fo:block><xsl:value-of select="customer/service"/></fo:block>
							<fo:block><xsl:value-of select="customer/addr1"/></fo:block>
							<fo:block><xsl:value-of select="customer/addr2"/></fo:block>
							<fo:block>
								<xsl:value-of select="customer/postcode"/>
								<xsl:text> </xsl:text>
								<xsl:value-of select="customer/city"/>
							</fo:block>
							<xsl:if test="customer/phone">
							<fo:block>Tél: <xsl:value-of select="customer/phone"/></fo:block>
							</xsl:if>
							<xsl:if test="customer/country">
							<fo:block><xsl:value-of select="customer/country"/></fo:block>
							</xsl:if>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
			</fo:block-container>

			<fo:block-container position="absolute" width="17cm" height="10cm" top="6.5cm"
			border-bottom-style="solid" border-width="0.3mm"
			overflow="hidden">
			<fo:table table-layout="fixed"
				border-style="solid" border-width="0.3mm"
				border-collapse="collapse"
				width="17cm" height="10cm"
			>
				<fo:table-column/>
				<fo:table-column column-width="14cm"/>
				<fo:table-column column-width="3cm"
					border-style="solid" border-width="0.3mm"
					background-color="rgb(240,240,240)"/>
				/>
				<fo:table-column/>
				<fo:table-column/>
				<fo:table-header>
					<fo:table-row font-weight="bold" font-size="12pt">
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell border-bottom-style="solid" border-width="0.3mm">
							<fo:block padding-top="4pt" padding-bottom="2pt" text-align="center">
								Description
							</fo:block>
						</fo:table-cell>
						<fo:table-cell border-bottom-style="solid" border-width="0.3mm">
							<fo:block padding-top="4pt" padding-bottom="2pt" text-align="center">
								Quantité
							</fo:block>
						</fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
					</fo:table-row>
				</fo:table-header>
				<fo:table-body>
					<xsl:apply-templates/>
					<fo:table-row height="10cm">
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
			</fo:block-container>

			<fo:block-container position="absolute" width="17cm" height="3cm" top="18cm">
			<fo:table border-width="0.3mm" border-collapse="collapse">
				<fo:table-column column-width="8cm"/>
				<fo:table-column column-width="1cm"/>
				<fo:table-column column-width="8cm"/>
			<fo:table-body>
				<fo:table-row height="2cm">
					<fo:table-cell padding="2mm" border-style="solid" border-width="0.3mm">
						<fo:block>Reçu le:</fo:block>
						<fo:block>Nom:</fo:block>
					</fo:table-cell>
					<fo:table-cell><fo:block/></fo:table-cell>
					<fo:table-cell padding="2mm" border-style="solid" border-width="0.3mm">
						<fo:block>Signature:</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
			</fo:table>
			</fo:block-container>

			<fo:block-container position="absolute" width="17cm" height="3cm" top="20.5cm">
			<fo:block font-size="9pt" text-align="justify">
				Les risques du transport sont à la charge de l'acheteur.
				Veuillez vérifier le bon état des colis lors de leur
				réception et le cas échéant émettre des réserves écrites
				auprès du transporteur.
 			</fo:block>
			<fo:block font-size="9pt" text-align="justify" font-weight="bold">
				Au delà de 3 jours ouvrés après la livraison, aucune réclamation
				concernant cette livraison ne sera recevable.
 			</fo:block>
			</fo:block-container>

		</fo:flow>

	</fo:page-sequence>

	</fo:root>
</xsl:template>

<xsl:include href="common.xsl"/>

</xsl:stylesheet>
