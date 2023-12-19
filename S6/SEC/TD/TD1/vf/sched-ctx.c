#include <stdio.h>
#include <setjmp.h>
#include <signal.h>
#include <stdlib.h>
#include <ucontext.h>
#include <unistd.h>
#include "lib-sched.h"


#define MAX_THREAD 3

// Tableau des contextes de processus (tels que définis par l'API de gestion de contextes)
// Chaque contexte comporte un pointeur vers la pile d'exécution du processus.
thread_state *th_state[MAX_THREAD]; 

/* Représentation simplifiée de la file des processus prêts :  
 * un processus est soit actif (1), soit terminé (0). 
 * L'ordonnanceur ne gère que les processus actifs.
 * Notez qu'il ne s'agit ici que d'une démonstration : le nombre processus initial est fixe
 * et l'arrivée de nouveaux processus prêts n'est pas traitée.
 */
int th_active[MAX_THREAD];

thread_state *idl_state;

int current;

// fin d'un processus
void thread_terminate() {
	printf("thread terminated\n");
	th_active[current] = 0;
	generate_tick();
	while (1); // juste pour montrer que le processus est préempté
}

/* code pour occuper le processeur s'il n'y a rien d'autre à faire
 * (c'est-à-dire s'il n'y a pas/plus de processus prêts).
 */
void idle() {
	while (1) {
		printf(".");
		fflush(stdout);
		sleep(1);
	}
}
//code des processus prêts
void thread0() {
	int i;
	for (i=0;i<10;i++) {
		printf("thread 0\n");
		sleep(1);
	}
	thread_terminate();
}
void thread1() {
	int i;
	for (i=0;i<10;i++) {
		printf("thread 1\n");
		sleep(1);
	}
	thread_terminate();
}
void thread2() {
	int i;
	for (i=0;i<10;i++) {
		printf("thread 2\n");
		sleep(1);
	}
	thread_terminate();
}

// ordonnanceur
void schedule() {
	thread_state *old, *new;
	int k, i_old, i_new;
	if (current == -1) {
		i_old = -1;
		old = idl_state;
	} else {
		i_old = current;
		old = th_state[current];
	}

	/* recherche du prochain processus prêt :
	 * on parcourt (jusqu'à tous) les indices en partant du processus courant 
	 */
	if (current == -1) current = 0;
	for (k=0;k<MAX_THREAD;k++) {
		current = (current + 1) % MAX_THREAD;
		if (th_active[current] == 1) break;
	}
	if (k==MAX_THREAD) {
		// un tour complet sans trouver de processus prêt
		printf("\nlast thread completed: go to idle\n");
		i_new = -1;
		current = -1;
		new = idl_state;
	} else {
		// le processus trouvé est le nouvel élu
		i_new = current;
		new = th_state[current];
	}
	printf("schedule: save(%d) restore (%d)\n",i_old, i_new);
	// commutation
	switch_thread(old, new);
}


int main() {

	//création d'un processus pour exécuter la fonction idle()
	idl_state = create_thread_context(idle);
	
	// création de 3 processus, exécutant respectivement les fonctions thread0,1,2
	th_state[0] = create_thread_context(thread0);
	th_state[1] = create_thread_context(thread1);
	th_state[2] = create_thread_context(thread2);
	th_active[0] = 1;
	th_active[1] = 1;
	th_active[2] = 1;
        
	/* la fonction schedule() est associée à la réception des interruptions horloge
	 * Les interruptions horloges (ticks) sont émises (dans cet exemple) toutes les
	 * 4 secondes (constante TIME_SLICE dans lib-sched.c). 
	 * La fonction schedule sera exécutée à chaque réception d'une interruption horloge.  
	 */
	install_tick_handler(schedule);

	current = -1;
	idle();
}