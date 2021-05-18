USE banque;
SET GLOBAL event_scheduler:=ON;

-- Création de la table de sauvegarde
CREATE TABLE saved_soldes(
	save_date DATETIME NOT NULL,
    iban CHAR(19) NOT NULL,
    solde DECIMAL(12,2) NOT NULL
)
ENGINE=InnoDB CHARSET=utf8;

-- Création de la primary key
ALTER TABLE saved_soldes
ADD PRIMARY KEY (save_date, iban);

-- Création de l'event
DROP EVENT IF EXISTS save_soldes_25_du_mois;
DELIMITER |
CREATE EVENT IF NOT EXISTS save_soldes_25_du_mois
ON SCHEDULE
	EVERY 1 MONTH
    STARTS "2021-05-25 04:00:00" -- La sauvegarde se fera à partir du 25 mai 2021 à 4h du matin tous les mois, valeur complètement arbitraire.
DO 
	BEGIN
			-- Pour plus de clarté, je prefère appeler une procédure depuis l'event
			CALL save_soldes();
    END |
DELIMITER ;

-- Création de la procédure de sauvegarde des soldes
DROP PROCEDURE IF EXISTS save_soldes;

DELIMITER |
CREATE PROCEDURE save_soldes()
BEGIN
	DECLARE current_iban CHAR(19);
    DECLARE current_solde DECIMAL(12,2);
    
    -- FLAG POUR FIN DE BOUCLE
    DECLARE exit_loop BOOLEAN;
    
    -- Curseur pour ibans
    DECLARE iban_cursor CURSOR FOR 
	SELECT iban, solde FROM compte;
    
    -- Continue handler de fin de boucle
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET exit_loop = TRUE;
    
    -- Ouverture du curseur
    OPEN iban_cursor;
    
    -- Début du loop 
    iban_loop: LOOP
		FETCH iban_cursor INTO current_iban, current_solde;
        INSERT INTO saved_soldes VALUES (NOW(), current_iban, current_solde);
		IF exit_loop THEN
			CLOSE iban_cursor;
            LEAVE iban_loop;
		END IF;
	END LOOP iban_loop;
END |
DELIMITER ;