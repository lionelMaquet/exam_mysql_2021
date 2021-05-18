USE banque;
DROP FUNCTION IF EXISTS get_client_category;

DELIMITER |
CREATE FUNCTION get_client_category(in_idclient MEDIUMINT) RETURNS CHAR(2) DETERMINISTIC
BEGIN

    DECLARE num_rows INT DEFAULT 0;
	DECLARE category_operations CHAR(1);
    DECLARE category_solde CHAR(1);

	DECLARE iban_client CHAR(19);
    
	DECLARE total_operations_entrantes DECIMAL(12,2) DEFAULT 0.00;
    DECLARE total_operations_sortantes DECIMAL(12,2) DEFAULT 0.00;
    
    DECLARE temp_total_operations_entrantes DECIMAL(12,2) DEFAULT 0.00;
    DECLARE temp_total_operations_sortantes DECIMAL(12,2) DEFAULT 0.00;
    
    DECLARE total_operations DECIMAL(12,2) DEFAULT 0.00;
    
    DECLARE solde_courant DECIMAL(12,2) DEFAULT 0.00;
    DECLARE temp_solde DECIMAL(12,2) DEFAULT 0.00;
    
    -- FLAG POUR FIN DE BOUCLE
    DECLARE exit_loop BOOLEAN;
    
    -- Curseur ayant pour but de parcourir chaque iban associé à l'idclient fourni
    DECLARE iban_cursor CURSOR FOR 
	SELECT iban FROM client_compte WHERE idclient = in_idclient;
    
    -- Continue handler pour sortie de boucle
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET exit_loop = TRUE;
    
    -- Ouverture du curseur
    OPEN iban_cursor;
    iban_loop: LOOP
		FETCH iban_cursor into iban_client;
        
        SELECT COUNT(*) INTO num_rows FROM transfert WHERE iban_credit = iban_client AND statut = "DONE";
        
        -- Simple procédure servant à récolter le total des opérations entrantes et sortantes de chaque iban associé à l'idclient fourni 
        IF num_rows > 0 
        THEN
			SELECT SUM(montant) INTO temp_total_operations_entrantes FROM transfert WHERE iban_credit = iban_client AND statut = "DONE";
		END IF;
        
        SELECT COUNT(*) INTO num_rows FROM transfert WHERE iban_debit = iban_client AND statut = "DONE";
        IF num_rows > 0
        THEN
			SELECT SUM(montant) INTO temp_total_operations_sortantes FROM transfert WHERE iban_debit = iban_client AND statut = "DONE";
		END IF;
        
        SELECT temp_total_operations_entrantes + total_operations_entrantes INTO total_operations_entrantes;
        SELECT temp_total_operations_sortantes + total_operations_sortantes INTO total_operations_sortantes;
        
        SELECT solde into temp_solde FROM compte WHERE iban = iban_client;
        SELECT temp_solde + solde_courant into solde_courant FROM compte WHERE iban = iban_client;
    
		IF exit_loop THEN
			CLOSE iban_cursor;
            LEAVE iban_loop;
		END IF;
	END LOOP iban_loop;
    
    SELECT total_operations_entrantes - total_operations_sortantes INTO total_operations;
    
    IF total_operations >= 20000.00 
		THEN SET category_operations = 'D';
	ELSEIF total_operations >= 0.00
		THEN SET category_operations = 'C';
    ELSEIF total_operations >= -20000.00
		THEN SET category_operations = 'B';
    ELSE 
		SET category_operations = 'A';
    END IF;
    
    IF solde_courant >= 20000.00
		THEN SET category_solde = '3';
	ELSEIF solde_courant >= 15000.00
		THEN SET category_solde = '2';
	ELSEIF solde_courant >= 10000.00
		THEN SET category_solde = '1';
	ELSE 
		SET category_solde = '0';
	END IF;
    
    RETURN (CONCAT(category_operations, category_solde));
    
END |
DELIMITER ;

-- Tests
SELECT get_client_category(1);
SELECT get_client_category(2);
SELECT get_client_category(3);
SELECT get_client_category(4);



    


