OBJS=	Devis.class \
		Facture.class \
		BonLivraison.class \
		BonCommande.class \
		FopPDFServlet.class

.SUFFIXES: .java .class

.java.class:
	javac $(.IMPSRC)

build: $(OBJS)

clean:
	rm $(OBJS)
