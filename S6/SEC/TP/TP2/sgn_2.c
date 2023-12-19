#include <stdio.h>    /* entrées/sorties */
#include <unistd.h>   /* primitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <signal.h>

#define MAX_PAUSES 10     /* nombre d'attentes maximum */

/* Traitant du signal SIGINT */
void handler(int signal_num) {
    printf("\n     Processus de pid %d : J'ai reçu le signal %d\n", 
            getpid(),signal_num) ;
    return ;
}

int main(int argc, char *argv[]) {
	int nbPauses;
	
	nbPauses = 0;
	for (int i = 1 ; i < 31 ; i++) { //il y a 32 signaux au total
		signal(i, handler); //cf tutoriel
	}

	printf("Processus de pid %d\n", getpid());
	for (nbPauses = 0 ; nbPauses < MAX_PAUSES ; nbPauses++) {
		pause();		// Attente d'un signal
		printf("pid = %d - NbPauses = %d\n", getpid(), nbPauses);
    } ;
    return EXIT_SUCCESS;
}

