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

<xsl:template name="adresse">
	<fo:block font-size="11pt">
		<fo:block><xsl:value-of select="company/name"/></fo:block>
		<fo:block><xsl:value-of select="company/addr1"/></fo:block>
		<fo:block><xsl:value-of select="company/addr2"/></fo:block>
		<fo:block>
			<xsl:value-of select="company/postcode"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="company/city"/>
		</fo:block>
		<xsl:if test="company/country">
			<fo:block><xsl:value-of select="company/country"/></fo:block>
		</xsl:if>
	</fo:block>
</xsl:template>

<xsl:template match="item">
	<fo:table-row font-size="9pt">

	<fo:table-cell>
		<fo:block-container overflow="hidden">
		<fo:block margin-left="2pt" padding-top="3pt">
			<xsl:if test="ref">
				<xsl:value-of select="ref"/>
			</xsl:if>
		</fo:block>
		</fo:block-container>
	</fo:table-cell>

	<fo:table-cell>
		<fo:block margin-left="4pt" margin-right="4pt" padding-top="3pt">
			<xsl:if test="name">
				<xsl:value-of select="name"/>
			</xsl:if>
		</fo:block>
	</fo:table-cell>

	<fo:table-cell>
		<fo:block text-align="end" margin-right="4pt" padding-top="3pt">
			<xsl:if test="qty">
				<xsl:value-of select="qty"/>
			</xsl:if>
		</fo:block>
	</fo:table-cell>

	<fo:table-cell>
		<fo:block text-align="end" margin-right="4pt" padding-top="3pt">
			<xsl:if test="price">
				<xsl:value-of select="format-number(price, '0,00')"/> €
			</xsl:if>
		</fo:block>
	</fo:table-cell>

	<fo:table-cell>
		<fo:block text-align="end" margin-right="4pt" padding-top="3pt">
			<xsl:if test="price">
				<xsl:value-of select="format-number((qty * price), '0,00')"/> €
			</xsl:if>
		</fo:block>
	</fo:table-cell>

	</fo:table-row>
</xsl:template>

<xsl:template mode="total" match="*">
	<xsl:param name="t" select="0"/>

	<xsl:choose>
	<xsl:when test="price">
		<xsl:apply-templates mode="total" select="following-sibling::item[1]">
			<xsl:with-param name="t" select="$t + (qty * price)"/>
		</xsl:apply-templates>
	</xsl:when>
	<xsl:otherwise>
		<xsl:apply-templates mode="total" select="following-sibling::item[1]">
			<xsl:with-param name="t" select="$t + 0"/>
		</xsl:apply-templates>
	</xsl:otherwise>
	</xsl:choose>

	<xsl:if test="not(following-sibling::item[1])">
		<xsl:choose>
		<xsl:when test="price">
			<xsl:value-of select="$t + (qty * price)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$t + 0"/>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:template name="footer">
	<fo:block
		font-size="10pt" font-family="Liberation Sans" line-height="1em + 4pt"
		border-style="solid" border-width="0.3mm"
		text-align="center" padding="1mm">
		<fo:block>
			Pâtisserie Dupont - EURL au capital de 8 000 € - 
			RCS Orléans 456 789 012 - TVA FR26 456 789 012
		</fo:block>
		<fo:block>
			Tel: +33 (0) 123 456 006 -
			Fax: +33 (0) 123 456 007 -
			Web: www.example.com
		</fo:block>
	</fo:block>
</xsl:template>

<xsl:template mode="folding-mark" match="*">
	<fo:block-container height="0.3mm" width="0.3mm" top="198mm" left="1cm" absolute-position="fixed">
		<fo:block border-style="solid" border-width="0.3mm" border-color="white"/>
	</fo:block-container>
</xsl:template>

<xsl:template name="vat-rates">
	<xsl:for-each select="vat_subtotal">
		<fo:block>TVA <xsl:value-of select="format-number(rate, '0,00')"/> %</fo:block>
	</xsl:for-each>
</xsl:template>

<xsl:template name="vat-sums">
	<xsl:for-each select="vat_subtotal">
		<fo:block>
			<xsl:value-of select="format-number(value, '0,00')"/> €
		</fo:block>
	</xsl:for-each>
</xsl:template>

</xsl:stylesheet>
