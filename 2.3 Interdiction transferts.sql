USE banque;

DROP TRIGGER IF EXISTS transfert_before_update;
DELIMITER |
CREATE TRIGGER transfert_before_update
BEFORE UPDATE
ON banque.transfert FOR EACH ROW
BEGIN
	-- Si le statut est déjà terminé, il ne sera plus possible d'updater le transfert.
    -- UN SQLSTATE 45000 est alors provoqué.
    IF (OLD.statut = "DONE") 
    THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Modification annulée. Le transfert est terminé.';
    END IF;
END |
DELIMITER ;

DROP TRIGGER IF EXISTS transfert_before_delete;
DELIMITER |
CREATE TRIGGER transfert_before_delete
BEFORE DELETE
ON banque.transfert FOR EACH ROW
BEGIN
	-- De la même manière, si le statut est déjà terminé, il ne sera plus non plus possible de supprimer l'enregistrement.
    -- UN SQLSTATE 45000 sera de nouveau provoqué.
    IF (OLD.statut = "DONE") 
    THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Suppression annulée. Le transfert est terminé.';
    END IF;
END |
DELIMITER ;


-- Exemple de suppression annulée
DELETE FROM transfert WHERE statut = "DONE" ORDER BY idtransfert DESC LIMIT 1 ;

-- Exemple de suppression réussie
DELETE FROM transfert WHERE statut = "TODO" ORDER BY idtransfert DESC LIMIT 1 ;