#ifndef _LISTE_H_
#define _LISTE_H_

/** type des statuts des processus. */
typedef enum {ACTIVE, SUSPENDED} Status;

/** type des listes de processus. */
typedef struct list *List;

/** Constructeur d'une liste vide. */
List new_list(void);

int get_id(List list);

pid_t get_pid(List list);

Status get_status(List list);

char* get_cmd(List list);

List get_next(List list);

void set_id(List list, int *id);

void set_pid(List list, pid_t *pid);

void set_status(List list, Status status);

void set_next(List list, List next);

void maj_status(List liste, pid_t *pid, Status status);

void traverser(List liste);

/** Supprimer un élement d'une liste. */
List supp_elem(List liste, pid_t *pid);

/** Obtenir un processus dans une liste. */
List get_elem(List liste, pid_t *pid);

/** Ajouter un processus à la fin d'une liste. */
List add_elem(List liste, List elem);

#endif
