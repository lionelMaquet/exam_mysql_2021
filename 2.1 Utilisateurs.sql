USE banque;

-- Guichetier : Aucune modification, insertion ou suppression possible. Uniquement un select possible.
CREATE USER 'guichetier'@'localhost'
IDENTIFIED BY 'guichetier';
GRANT SELECT ON *.*
TO 'guichetier'@'localhost';


-- Manager : Uniquement du select possible.
CREATE USER 'manager'@'localhost'
IDENTIFIED BY 'manager';
GRANT SELECT ON banque.*
TO 'manager'@'localhost';


-- Directeur : Je considère que le directeur a les droits pour sélectionner et modifier les tables client, mais rien d'autre.
CREATE USER 'directeur'@'localhost'
IDENTIFIED BY 'directeur';
GRANT SELECT, UPDATE
ON banque.client
TO 'directeur'@'localhost';

-- DBA : C'est à lui que pourront revenir toutes les tâches plus sensibles. Il a donc le droit de tout faire sur la base de données.
CREATE USER 'dba'@'localhost'
IDENTIFIED BY 'dba';
GRANT ALL
ON *.*
TO 'dba'@'localhost';



