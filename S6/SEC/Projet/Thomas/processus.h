#ifndef __PROCESSUS_H
#define __PROCESSUS_H


typedef struct processus
{
    int id;              // identifiant propre au shell
    int pid;             // pid
    char *etat;          // actif(A) ou suspendu(S)
    char *cmd;           // la commande lancée
    struct processus *suivant; // pointeur sur le processus suivant
} processus;

typedef struct processus processus;
typedef processus *liste_p;

void initialiser(liste_p *liste_processus);


void liberer(liste_p *liste_processus);


void add(int pid, processus **liste_processus, char **seq);


void supprimer(int id, processus **liste_processus);


void afficher(processus **liste_processus);


processus *processus_via_id(int id, liste_p *liste_processus); // chercher le processus associé à un id


processus *processus_via_pid(int pid, liste_p *liste_processus); // chercher le processus associé à un pid

#endif
