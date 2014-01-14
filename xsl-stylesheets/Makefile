FOP=fop
XSLTPROC=xsltproc

.SUFFIXES:	.xml .fo .pdf

default: facture.pdf

devis.pdf: devis.xml devis.xsl common.xsl
	$(FOP) -xml devis.xml -xsl devis.xsl -pdf $(.TARGET)

facture.pdf: facture.xml facture.xsl common.xsl
	$(FOP) -c fop.conf -xml facture.xml -xsl facture.xsl -pdf $(.TARGET)

facture.fo: facture.xml facture.xsl common.xsl
	$(XSLTPROC) -o $(.TARGET) facture.xsl facture.xml

bon-commande.pdf: bon-commande.xml bon-commande.xsl common.xsl
	$(FOP) -xml bon-commande.xml -xsl bon-commande.xsl -pdf "$(.TARGET)"

bon-commande.fo: bon-commande.xml bon-commande.xsl
	$(XSLTPROC) -o $(.TARGET) bon-commande.xsl bon-commande.xml

bon-livraison.pdf: bon-livraison.xml bon-livraison.xsl common.xsl
	$(FOP) -xml bon-livraison.xml -xsl bon-livraison.xsl -pdf "$(.TARGET)"

envelope.pdf: envelope.xml envelope.xsl
	$(FOP) -xml envelope.xml -xsl envelope.xsl -pdf "$(.TARGET)"

envelope.fo: envelope.xml envelope.xsl
	$(XSLTPROC) -o $(.TARGET) envelope.xsl envelope.xml

statement.pdf:	statement.xml statement.xsl
	$(FOP) -xml statement.xml -xsl statement.xsl -pdf "$(.TARGET)"

statement.fo:	statement.xml statement.xsl
	$(XSLTPROC) -o $(.TARGET) statement.xsl statement.xml

expense-report.pdf:	expense-report.xml expense-report.xsl
	$(FOP) -xml expense-report.xml -xsl expense-report.xsl -pdf $(.TARGET)

expense-report.fo:	expense-report.xml expense-report.xsl
	$(XSLTPROC) -o $(.TARGET) expense-report.xsl expense-report.xml
