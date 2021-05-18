USE banque;

DROP TRIGGER IF EXISTS transfert_before_insert;
DELIMITER |
CREATE TRIGGER transfert_before_insert
BEFORE INSERT
ON banque.transfert FOR EACH ROW
BEGIN
	DECLARE solde_courant_debiteur DECIMAL(12,2);
    DECLARE solde_minimum_debiteur DECIMAL(12,2);
    
    SELECT solde INTO solde_courant_debiteur FROM compte WHERE compte.iban = NEW.iban_debit ;
    SELECT solde_min INTO solde_minimum_debiteur FROM compte WHERE compte.iban = NEW.iban_debit;
    
    -- Si le solde débiteur n'a pas assez d'argent pour ne pas finir sous sa limite, un SQLSTATE 45000 est provoqué, annulant l'insertion.
    IF ((solde_courant_debiteur - NEW.montant) < solde_minimum_debiteur )
    THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Transfert annulé. Le compte débiteur a un solde insuffisant.';
    END IF;
    
END |
DELIMITER ;

-- Exemple de test qui ne fonctionnera pas 
INSERT INTO transfert(montant, iban_debit, iban_credit, moment, statut) VALUES ('6000.00', 'BE74 5158 0839 9110', 'BE16 8150 8760 3792', '2015-02-28 04:06:58', 'TODO');

-- Exemple de test qui fonctionnera
INSERT INTO transfert(montant, iban_debit, iban_credit, moment, statut) VALUES ('1.00', 'BE74 5158 0839 9110', 'BE16 8150 8760 3792', '2015-02-28 04:06:58', 'TODO');
