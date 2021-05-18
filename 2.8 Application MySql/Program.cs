using System;
using System.Collections.Generic;
using System.Data;
using MySql.Data.MySqlClient;

// Pour lancer le programme, effectuer la commande suivante depuis le dossier contenant le fichier program.cs 
// dotnet run Program.cs idduclient 
// Tout devrait fonctionner, si il manquait un package (je ne pense pas que ce soit le cas), la commande à utiliser est la suivante : 
// dotnet add package mysql.data 

namespace ApplicationMysql
{
    class Program
    {
        static void Main(string[] args)
        {
            // Variables de connexion
            string cs = "server=localhost;userid=root;password=;database=banque";
            using var connexion = new MySql.Data.MySqlClient.MySqlConnection(cs);
            string idClient = args.Length > 1 ? args[1] : "1"; // Il faut passer l'ID du client en argument à la fonction, sinon, la valeur 1 sera utilisée par défaut.

            if (args.Length == 1)
            {
                Console.WriteLine("\n!!! ATTENTION !!!\nVous n'avez pas passé de valeur pour l'id client ! La valeur 1 sera utilisée par défaut! \n");
            }

            List<string> liste_iban = new List<string>();

            connexion.Open();

            // valeurs de la table client
            var stm_table_client = $"SELECT * FROM client WHERE idclient = '{idClient}'";
            var cmd_table_client = new MySqlCommand(stm_table_client, connexion);

            using MySqlDataReader rdr_table_client = cmd_table_client.ExecuteReader();

            while (rdr_table_client.Read())
            {
                Console.WriteLine("\nINFORMATIONS DU CLIENT : \nidclient : {0}\nnom : {1}\nprenom : {2}\nadresse : {3}\nville : {4}\ncode postal : {5}\nregistre national : {6}\n", rdr_table_client.GetInt32(0), rdr_table_client.GetString(1), rdr_table_client.GetString(2), rdr_table_client.GetString(3), rdr_table_client.GetString(4), rdr_table_client.GetInt32(5), rdr_table_client.GetString(6));
            }

            rdr_table_client.Close();


            // on récupère les valeurs d'iban
            var stm_iban = $"SELECT iban FROM client_compte WHERE idclient = '{idClient}'";
            var cmd_iban = new MySqlCommand(stm_iban, connexion);
            
            MySqlDataReader rdr_iban = cmd_iban.ExecuteReader();
            while(rdr_iban.Read())
            {
                liste_iban.Add((string)rdr_iban["iban"]);
            }

            rdr_iban.Close();


            // On affiche les valeurs des comptes ainsi que les transactions pour chaque iban
            foreach (string iban in liste_iban)
            {

                // On affiche les valeurs d'iban et les soldes
                var stm_compte = $"SELECT iban, solde FROM compte WHERE iban = '{iban}'";
                var cmd_compte = new MySqlCommand(stm_compte, connexion);
                MySqlDataReader rdr_compte = cmd_compte.ExecuteReader();
                while(rdr_compte.Read())
                {
                    Console.WriteLine("iban : {0}\nsolde: {1}\n", rdr_compte.GetString(0), rdr_compte.GetDecimal(1));
                }
                rdr_compte.Close();

                // On affiche les 2 derniers transferts 
                var stm_transfert = $"SELECT * FROM transfert WHERE iban_debit = '{iban}' OR iban_credit = '{iban}' ORDER BY moment DESC LIMIT 2";
                var cmd_transfert = new MySqlCommand(stm_transfert, connexion);
                MySqlDataReader rdr_transfert = cmd_transfert.ExecuteReader();
                while(rdr_transfert.Read())
                {
                    Console.WriteLine("    id transfert : {0}\n        montant : {1}\n        iban débiteur : {2}\n        iban créditeur : {3}\n        moment : {4}\n        statut : {5}\n", rdr_transfert.GetInt32(0), rdr_transfert.GetDecimal(1), rdr_transfert.GetString(2), rdr_transfert.GetString(3), rdr_transfert.GetDateTime(4), rdr_transfert.GetString(5));
                }
                Console.WriteLine("\n");
                rdr_transfert.Close();
            }

            

            

            



        }
    }
}
