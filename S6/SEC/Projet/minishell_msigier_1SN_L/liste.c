#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "liste.h"
#include "readcmd.h"

/** type liste des processus. */
struct list {
    int id;
    pid_t pid;
    Status status;
    char* cmd;
    List next;
};

/** Constructeur d'une liste vide. */
List new_list(void) {
    return NULL;
}

int get_id(List list) {
  return list->id;
}

pid_t get_pid(List list) {
  return list->pid;
}

Status get_status(List list) {
  return list->status;
}

char* get_cmd(List list) {
  return list->cmd;
}

List get_next(List list) {
  return list->next;
}

void set_id(List list, int *id) {
    list->id = *id;
}

void set_pid(List list, pid_t *pid) {
    list->pid = *pid;
}

void set_status(List list, Status status) {
    list->status = status;
}

void set_next(List list, List next) {
    list->next = next;
}

void maj_status(List liste, pid_t *pid, Status status) {
  List curseur = liste;
  while (curseur != NULL) {
    if (curseur->pid == *pid) {
      set_status(curseur, status);
      return;
    }
    curseur = get_next(curseur);
  }
}

void traverser(List liste) {
  List curseur = liste;
  char* etat;
  printf("ID\t\tPID\t\tSTATUS\t\t\tCMD\n");
  while (curseur != NULL) {
    if (curseur->status == ACTIVE) {
      etat = "ACTIVE\t";
    }
    else {
      etat = "SUSPENDED";
    }
	   printf("%d\t\t%d\t\t%s\t\t%s\n", curseur->id, curseur->pid, etat, curseur->cmd);
	   curseur = get_next(curseur);
  }
}

/** Supprimer un élement d'une liste. */
List supp_elem(List liste, pid_t *pid) {
    List copie = liste;
    List suite;
    if (copie != NULL && copie->pid == *pid) {
	free(copie);
	copie = NULL;
	return NULL;
    }
    while (copie != NULL && copie->pid != *pid) {
	suite = copie;
	copie = get_next(copie);
    }
    if (copie == NULL) {
	return liste;
    }
    set_next(suite, get_next(copie));
    free(copie);
    copie = NULL;
    return liste;
}

/** Obtenir un processus dans une liste. */
List get_elem(List liste, pid_t *pid) {
    List copie = liste;
    while (copie != NULL) {
	if (copie->pid == *pid) {
	    return copie;
	}
	copie = get_next(copie);
    }
    return NULL;
}

/** Ajouter un processus à la fin d'une liste. */
List add_elem(List liste, List elem) {
    List copie;
    if (liste == NULL){
	liste = elem;
    }
    else{
	copie  = liste;
	while(get_next(copie) != NULL){
	    copie = get_next(copie);
	}
	set_next(copie, elem);
    }
    return liste;
}
