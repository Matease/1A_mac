#ifndef __COMMANDES_H
#define __COMMANDES_H

typedef struct cmdline cmdline;

//traite les commandes internes 
int traitement_commande(cmdline *cmd, liste_p liste_process, char *chemin);

#endif