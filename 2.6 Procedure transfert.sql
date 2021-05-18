USE banque;

DROP PROCEDURE IF EXISTS execute_transfert;

-- Je considère ici que cette procédure est à exécuter lorsqu'un enregistrement avec le statut "TODO" est déjà présent dans la table de transferts. 
-- Nous fournissons donc l'id du transfert à effectuer à cette procédure.
DELIMITER |
CREATE PROCEDURE execute_transfert(IN in_idtransfert MEDIUMINT)
BEGIN
	
    DECLARE statut_transfert CHAR(4);
    DECLARE montant_transfert DECIMAL(12,2);
    DECLARE solde_debiteur DECIMAL(12,2);
    DECLARE solde_crediteur DECIMAL(12,2);
    DECLARE iban_debiteur CHAR(19);
    DECLARE iban_crediteur CHAR(19);
    
    SELECT statut, montant INTO statut_transfert, montant_transfert FROM transfert WHERE idtransfert = in_idtransfert;
    SELECT solde, iban INTO solde_debiteur, iban_debiteur FROM compte INNER JOIN transfert ON compte.iban = transfert.iban_debit WHERE idtransfert = in_idtransfert;
    SELECT solde, iban INTO solde_crediteur, iban_crediteur FROM compte INNER JOIN transfert ON compte.iban = transfert.iban_credit WHERE idtransfert = in_idtransfert;
    
    IF statut_transfert = "TODO" 
    THEN

		START TRANSACTION; -- Utilisation d'une transaction pour garder les données intactes en cas de problème
        
        -- On passe le statut en OPEN, effectuons la transactions, passons le statut en DONE
        UPDATE transfert SET moment = NOW(), statut = "OPEN" WHERE idtransfert = in_idtransfert; 
		UPDATE compte SET solde = solde_debiteur - montant_transfert WHERE iban = iban_debiteur;
        UPDATE compte SET solde = solde_crediteur + montant_transfert WHERE iban = iban_crediteur;
		UPDATE transfert SET moment = NOW(), statut = "DONE" WHERE idtransfert = in_idtransfert;
    
		COMMIT;
	ELSE 
		-- Dans le cas où le transfert n'a pas un statut TODO, un SQLSTATE sera déclenché.
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "Le statut de la commande n'est pas valide.";
	END IF;
END |
DELIMITER ;

-- Statut non valide => Il est open.
CALL execute_transfert(3);

-- Statut non valide => Il est done.
CALL execute_transfert(1);

-- Statut valide => Il est todo
SELECT solde FROM compte WHERE iban = 'BE52 2722 4167 4556'; -- Etat du compte débiteur avant l'opération (3628.26)
SELECT solde FROM compte WHERE iban = 'BE90 8445 6985 4226'; -- Etat du compte créditeur avant l'opération (1672.66)
CALL execute_transfert(10); -- Montant : 1118.06
SELECT solde FROM compte WHERE iban = 'BE52 2722 4167 4556'; -- Etat du compte débiteur après l'opération (2510.20)
SELECT solde FROM compte WHERE iban = 'BE90 8445 6985 4226'; -- Etat du compte créditeur après l'opération (2790.72)






