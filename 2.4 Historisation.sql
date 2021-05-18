USE banque;

-- Création de la database d'historisation
CREATE DATABASE histo;
USE histo;

-- Création de la table d'historisation
CREATE TABLE histo_comptes LIKE banque.compte;

-- Suppression de la primary key existante
ALTER TABLE histo_comptes DROP PRIMARY KEY;

-- Ajout d'une nouvelle primary key
ALTER TABLE histo_comptes ADD COLUMN idhistocomptes MEDIUMINT UNSIGNED NOT NULL FIRST;
ALTER TABLE histo_comptes ADD PRIMARY KEY (idhistocomptes);
ALTER TABLE histo_comptes MODIFY COLUMN idhistocomptes MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT;

-- Ajout de nouvelles colomnes, concernant le type de requête et la date à laquelle elle a été effectuée
ALTER TABLE histo_comptes ADD COLUMN requete VARCHAR(10);
ALTER TABLE histo_comptes ADD COLUMN created_at DATETIME;


USE banque;
DROP TRIGGER IF EXISTS comptes_after_insert;
DELIMITER |
CREATE TRIGGER comptes_after_insert
AFTER INSERT
ON compte FOR EACH ROW
BEGIN
	-- Lors d'une insertion dans la table compte, on ajoute également un enregistrement dans la table d'historisation
	INSERT INTO histo.histo_comptes (iban, solde_min, solde, requete, created_at)
	VALUES(
		NEW.iban,
        NEW.solde_min,
        NEW.solde,
        "INSERT",
        NOW()
	);
END |
DELIMITER ;

DROP TRIGGER IF EXISTS comptes_after_update;
DELIMITER |
CREATE TRIGGER comptes_after_update
AFTER UPDATE
ON compte FOR EACH ROW
BEGIN
	-- De la même façon, nous enregistrons aussi toutes les modifications apportées aux enregistrements de la table compte.
	INSERT INTO histo.histo_comptes (iban, solde_min, solde, requete, created_at)
	VALUES(
		NEW.iban,
        NEW.solde_min,
        NEW.solde,
        "UPDATE",
        NOW()
	);
END |
DELIMITER ;

-- test de mise à jour 
SELECT * FROM histo.histo_comptes;
UPDATE compte SET solde = 25.00 WHERE solde > 0.00 LIMIT 1 ;
SELECT * FROM histo.histo_comptes; -- Un nouvel enregistrement est créé

-- test d'insertion
SELECT * FROM histo.histo_comptes;
INSERT INTO compte VALUES ('BE99 9999 9999 9999', '1000', '2000');
SELECT * FROM histo.histo_comptes; -- Un nouvel enregistrement est créé

