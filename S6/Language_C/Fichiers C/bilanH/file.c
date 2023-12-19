/**
 *  \author Mathis Sigier <mathis.sigier@etu.inp-toulouse.fr>
 *  \file file.c
 *
 *  Objectif :
 *	Implantation des opérations de la file
*/
# include <stdlib.h>
#include <assert.h>

#include "file.h"


void initialiser(File *f)
{
    f->tete=NULL;
    f->queue=NULL;
    assert(est_vide(*f));
}


void detruire(File *f)
{
    while (f->tete != NULL) {
        Cellule *cellule_a_supprimer = f->tete;
        f->tete = f->tete->suivante;
        free(cellule_a_supprimer);
    }
    f->queue = NULL;
}

bool est_vide(File f)
{
    return(f.tete == NULL);
}

char tete(File f)
{
    assert(! est_vide(f));
    return f.tete->valeur;;
}
/**
 * Obtenir une nouvelle cellule allou�e dynamiquement
 * initialis�e avec la valeur et la cellule suivante pr�cis� en param�tre.
 */
static Cellule * cellule(char valeur, Cellule *suivante)
{
    Cellule *c = (Cellule*) malloc(sizeof(Cellule));
    c->valeur = valeur;
    c->suivante = suivante;
    return c;
}


void inserer(File *f, char v)
{
    assert(f != NULL);
    Cellule *cell = cellule(v, NULL);
    if (est_vide(*f)) {
        f->tete = cell;
        f->queue = cell;
    } else {
        f->queue->suivante = cell;
        f->queue = cell;
    }
}

void extraire(File *f, char *v)
{
    assert(f != NULL);
    assert(! est_vide(*f));
    *v = f->tete->valeur;
    Cellule *tete_avant = f->tete;
    f->tete = f->tete->suivante;
    if (f->tete == NULL) {
        f->queue = NULL;
    }
    free(tete_avant);
}


int longueur(File f)
{
    int l = 0;
    Cellule *cell = f.tete;
    while (cell != NULL) {
        l++;
        cell = cell->suivante;
    }
    return l;
}
