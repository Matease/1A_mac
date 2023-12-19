 /**
 *  \author Xavier Cr�gut <nom@n7.fr>
 *  \file file.c
 *
 *  Objectif :
 *	Implantation des op�rations de la file
*/

#include <stdlib.h>
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


char tete(File f)
{
    assert(! est_vide(f));
    return f.tete->valeur;;
}


bool est_vide(File f)
{
    return(f.tete == NULL);
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
    Cellule *ancienne_tete = f->tete;
    f->tete = f->tete->suivante;
    if (f->tete == NULL) {
        f->queue = NULL;
    }
    free(ancienne_tete);
}


int longueur(File f)
{
    int length = 0;
    Cellule *c = f.tete;
    while (c != NULL) {
        length++;
        c = c->suivante;
    }
    return length;
}
