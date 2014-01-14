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

<xsl:template match="/invoice">
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

		<fo:flow flow-name="xsl-region-body" font-family="Liberation Sans">

			<xsl:call-template name="adresse"/>

			<fo:block margin-top="1cm" font-size="10pt">
				<fo:block>
					N° de facture <xsl:if test="credit_note = 'true'">d'avoir </xsl:if>: 
					<xsl:value-of select="/invoice/@id"/>
				</fo:block>
				<fo:block margin-bottom="4pt">
					Date de facture: <xsl:value-of select="/invoice/date"/>
				</fo:block>
				<xsl:if test="commande">
					<fo:block>
						Suivant la commande
						<xsl:if test="commande/num">
							n° <xsl:value-of select="commande/num"/>
						</xsl:if>
						du <xsl:value-of select="commande/date"/>
					</fo:block>
				</xsl:if>
				<xsl:if test="packing_slip">
					<fo:block>
						Suivant le bon de livraison n° <xsl:value-of select="packing_slip"/>
					</fo:block>
				</xsl:if>
			</fo:block>

			<fo:block-container height="2cm" width="19cm" top="1.3cm" left="0cm" position="absolute">
			<fo:block font-weight="bold" font-size="24pt" text-align="right" margin-right="2mm">
				<xsl:choose>
					<xsl:when test="credit_note = 'true'">Avoir</xsl:when>
					<xsl:otherwise>Facture</xsl:otherwise>
				</xsl:choose>
			</fo:block>
			<fo:block border-top-style="solid" border-width="1mm"/>
			</fo:block-container>
			
			<fo:block-container height="3cm" width="19cm" top="5.4cm" left="0cm" position="absolute">
			<fo:table>
				<fo:table-column background-color="rgb(240,240,240)"/>
				<fo:table-column column-width="2cm"/>
				<fo:table-column background-color="rgb(240,240,240)"/>
				<fo:table-body>
					<fo:table-row font-size="10pt">
						<fo:table-cell padding="2mm"
						border-style="solid" border-width="0.3mm">
						<fo:block>
							<xsl:if test="delivery">
								<fo:block font-style="italic" margin-bottom="4pt">
									Adresse de livraison:
								</fo:block>
							</xsl:if>
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
						</fo:block>
						</fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell padding="2mm"
						border-style="solid" border-width="0.3mm">
						<fo:block>
							<fo:block font-style="italic" margin-bottom="4pt">
								Adresse de facturation:
							</fo:block>
							<fo:block><xsl:value-of select="customer/name"/></fo:block>
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

			<xsl:variable name="total_ht">
				<xsl:apply-templates mode="total" select="/invoice/item[1]"/>
			</xsl:variable>
			<xsl:comment>Règles d'arrondi de l'euro</xsl:comment>
			<xsl:variable name="tva" select="sum(vat_subtotal/value)"/>
			<xsl:variable name="advance" select="/invoice/advance"/>

			<fo:block-container position="absolute" width="19cm" height="11.5cm" top="9cm"
			border-bottom-style="solid" border-width="0.3mm"
			overflow="hidden">
			<fo:table table-layout="fixed"
				border-style="solid" border-width="0.3mm"
				border-collapse="collapse"
				width="19cm" height="11.5cm"
			>
				<fo:table-column background-color="rgb(240,240,240)"/>
				<fo:table-column column-width="12cm"/>
				<fo:table-column
					column-width="1cm"
					border-style="solid" border-width="0.3mm"
					background-color="rgb(240,240,240)"/>
				<fo:table-column column-width="3cm"/>
				<fo:table-column column-width="3cm"
					border-style="solid" border-width="0.3mm"
					background-color="rgb(240,240,240)"/>
				/>
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

			<fo:block-container position="absolute" width="19cm" height="4.5cm" top="21cm">

				<fo:block font-size="9pt" text-align="justify" margin-bottom="5mm">
				<xsl:choose><xsl:when test="credit_note = 'false'">
					Les biens vendus demeurent la propriété de <xsl:value-of select="company/name"/>
					jusqu'au paiement intégral des sommes dues.
				</xsl:when>
				<xsl:otherwise>
					&#160;
				</xsl:otherwise></xsl:choose>
 				</fo:block>

				<fo:table border-width="0.3mm" border-collapse="collapse">
					<fo:table-column column-width="8.5cm"/>
					<fo:table-column/>
					<fo:table-column column-width="6cm"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell padding="2mm" border-style="solid" border-width="0.3mm"
						background-color="rgb(240,240,240)">
						<fo:block font-size="10pt">
						<xsl:choose><xsl:when test="credit_note = 'false'">
							<xsl:choose>
							<xsl:when test="due-date">
								<fo:block>Payable au plus tard le <xsl:value-of select="due-date"/></fo:block>
							</xsl:when>
							<xsl:otherwise>
								<fo:block>Paiement comptant</fo:block>
							</xsl:otherwise>
							</xsl:choose>
								<fo:block>par chèque ou virement, sans escompte.</fo:block>
								<fo:block font-size="4pt">&#160;</fo:block>
								<fo:block>IBAN: <xsl:value-of select="company/bic"/></fo:block>
								<fo:block>BIC: <xsl:value-of select="company/iban"/></fo:block>
						</xsl:when></xsl:choose>
						</fo:block>
						</fo:table-cell>
						<fo:table-cell><fo:block/></fo:table-cell>
						<fo:table-cell>

				<xsl:comment>Mise en page de la zone de total</xsl:comment>
				<xsl:variable name="fontsize">
					<xsl:choose>
						<xsl:when test="/invoice/advance">8pt</xsl:when>
						<xsl:otherwise>10pt</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="row-height">
					<xsl:choose>
						<xsl:when test="/invoice/advance">3.9mm</xsl:when>
						<xsl:otherwise>7.33mm</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<fo:table height="2.2cm" border-width="0.3mm" border-collapse="collapse" font-size="{$fontsize}">
				<fo:table-column column-width="3cm"/>
				<fo:table-column column-width="3cm"
					border-style="solid" border-width="0.3mm"
					background-color="rgb(240,240,240)"
				/>
				<fo:table-body>
					<fo:table-row height="{$row-height}" display-align="center">
						<fo:table-cell>
							<fo:block>Total HT</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block margin-right="4pt" text-align="end">
								<xsl:value-of select="format-number($total_ht, '0,00')"/> €
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
					<fo:table-row height="{$row-height}" display-align="center">
						<fo:table-cell>
							<xsl:call-template name="vat-rates"/>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block margin-right="4pt" text-align="end">
								<xsl:call-template name="vat-sums"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
					<fo:table-row height="{$row-height}" display-align="center">
						<fo:table-cell>
							<fo:block>Total TTC</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block margin-right="4pt" text-align="end">
								<xsl:value-of select="format-number($total_ht + $tva, '0,00')"/> €
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
<xsl:if test="advance">
					<fo:table-row height="{$row-height}" display-align="center">
						<fo:table-cell>
							<fo:block>Acompte reçu</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block margin-right="4pt" text-align="end">
				 				<xsl:value-of select="format-number($advance, '0,00')"/> €
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
					<fo:table-row height="{$row-height}" display-align="center">
						<fo:table-cell>
							<fo:block>Net à payer</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block margin-right="4pt" text-align="end" font-weight="bold">
								<xsl:value-of select="format-number($total_ht + $tva - $advance, '0,00')"/> €
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
</xsl:if>
				</fo:table-body>
			</fo:table>

			</fo:table-cell>
			</fo:table-row>
			</fo:table-body>
			</fo:table>

			<xsl:choose><xsl:when test="credit_note = 'false'">
			<fo:block font-size="9pt" text-align="justify" margin-top="5mm">
				Tout règlement postérieur à la date de paiement fixée pourrait
				donner lieu à la facturation de pénalités de retard au moins
				égales à 1,5 fois le taux légal sans qu'une mise en demeure
				préalable de l'acheteur soit nécessaire.
 			</fo:block>
			</xsl:when></xsl:choose>
			</fo:block-container>

			<xsl:apply-templates mode="folding-mark"/>

		</fo:flow>

	</fo:page-sequence>

	</fo:root>
</xsl:template>

<xsl:include href="common.xsl"/>

</xsl:stylesheet>
