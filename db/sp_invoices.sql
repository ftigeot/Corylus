-- Corylus - ERP software
-- Copyright (c) 2005-2014 François Tigeot
--
-- sp_invoices.sql: Stored procedures to handle invoices


-- VAT rate for shipping
CREATE FUNCTION iv_shipping_rate(invoice_id int) RETURNS decimal(6,2) AS $$
DECLARE
    result decimal(6,2);
BEGIN
    SELECT q.shipping_tr INTO STRICT result
    FROM  quotations q,orders o,invoices i
    WHERE q.id = o.quotation_id
    AND   o.id = i.order_id
    AND   i.id = invoice_id;
    RETURN result;
END;
$$ LANGUAGE plpgsql;


-- Shipping amount, without VAT
CREATE FUNCTION iv_shipping(invoice_id int) RETURNS decimal(6,2) AS $$
DECLARE
    result decimal(6,2);
BEGIN
    SELECT shipping INTO STRICT result
    FROM  invoices
    WHERE id = invoice_id;

    IF (result IS NULL) THEN
	RETURN 0;
    ELSE
	RETURN result;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Sum of an invoice, without VAT
CREATE FUNCTION iv_sum(invoice_id int) RETURNS decimal(6,2) AS $$
DECLARE
    delivery_slip integer;
    subtotal decimal(8,2);
BEGIN
    SELECT ds_id FROM invoices i INTO STRICT delivery_slip
    WHERE id = invoice_id;

    IF (delivery_slip IS NULL) THEN
	-- invoice on the whole order ?
	SELECT SUM (qty*price) FROM q_items INTO STRICT subtotal
	WHERE quotation_id = (
		SELECT o.quotation_id
		FROM orders o, invoices i
		WHERE o.id = i.order_id
		AND i.id = invoice_id
	);
    ELSE
	-- or only a partial delivery ?
	SELECT SUM(qi.price * dsi.qty) INTO STRICT subtotal
	FROM   q_items qi, ds_items dsi, invoices i
	WHERE  qi.id = dsi.q_item_id
	AND    dsi.delivery_slip_id = i.ds_id
	AND    i.id = invoice_id;
    END IF;

    RETURN subtotal + iv_shipping(invoice_id);
END;
$$ LANGUAGE plpgsql;


-- Total VAT amount
CREATE FUNCTION iv_vat(invoice_id int) RETURNS decimal(6,2) AS $$
DECLARE
    delivery_slip integer;
    subtotal decimal(8,2);
BEGIN
    SELECT ds_id FROM invoices i INTO STRICT delivery_slip
    WHERE id = invoice_id;

    IF (delivery_slip IS NULL) THEN
	-- invoice on the whole order ?
	SELECT SUM (qty*price*vat) FROM q_items INTO STRICT subtotal
	WHERE quotation_id = (
		SELECT o.quotation_id
		FROM orders o, invoices i
		WHERE o.id = i.order_id
		AND i.id = invoice_id
	);
    ELSE
	-- or only a partial delivery ?
	SELECT SUM(qi.price * dsi.qty * qi.vat) INTO STRICT subtotal
	FROM   q_items qi, ds_items dsi, invoices i
	WHERE  qi.id = dsi.q_item_id
	AND    dsi.delivery_slip_id = i.ds_id
	AND    i.id = invoice_id;
    END IF;

    subtotal = subtotal + iv_shipping(invoice_id) * iv_shipping_rate(invoice_id); 

    RETURN ROUND (subtotal / 100, 2);
END;
$$ LANGUAGE plpgsql;


-- Credit notes are taken into account
CREATE FUNCTION iv_turnover_dates(start_d date, end_d date)
RETURNS decimal(6,2) AS $$
DECLARE
    i RECORD;
    subtotal decimal(8,2);
BEGIN
    subtotal := 0;

    FOR i IN SELECT id,is_credit_note FROM invoices
	WHERE created_on >= start_d
	AND created_on <= end_d
    LOOP
	IF (i.is_credit_note) THEN
	    subtotal = subtotal - iv_sum(i.id);
	ELSE
	    subtotal = subtotal + iv_sum(i.id);
	END IF;
    END LOOP;

    RETURN subtotal;
END;
$$ LANGUAGE plpgsql;


-- Optimization possibilities are legion with stored procedures
-- It should possible to return a full set of values in one go,
-- suitable to be used as-is by a complete web page
