api_systeme/                                                                                        0000755 0053044 0074430 00000000000 14027613556 012561  5                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    api_systeme/pf_sigint_ign_dfl_exec.c                                                                0000600 0053044 0074430 00000005215 13622520661 017362  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Traitement du signal SIGINT : SIG_IGN et SIG_DFL avec exec */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <signal.h>   /* traitement des signaux */

#define NB_FILS 3     /* nombre de fils */

/* Traitant du signal SIGINT */
void handler_sigint(int signal_num) {
    printf("\n     Processus de pid %d : J'ai reçu le signal %d\n", 
            getpid(),signal_num);
    return;
}

/* dormir pendant nb_secondes secondes  */
/* à utiliser à la palce de sleep(duree), car sleep s'arrête */
/* dès qu'un signal non ignoré est reçu */
void dormir(int nb_secondes)
{
    int duree = 0;
    while (duree < nb_secondes) {
        sleep(1);
        duree++;
    }
}

int main()
{
    int fils, retour;
    int duree_sommeil = 300;

    char ref_exec[]="./dormir"; /* exécutable  */
    char arg0_exec[]="je dors";	/* argument0 du exec : nom donnée au processus */
    char arg1_exec[]="300";	    /* argument0 du exec : durée de sommeil */

    /* associer un traitant au signal SIGINT */
    signal(SIGINT, handler_sigint);

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            if (fils == 1) {
                signal(SIGINT, SIG_IGN);
            }
            else if (fils == 2) {
                signal(SIGINT, SIG_DFL);
            }
            printf("\n     Processus fils numero %d, de pid %d, de pere %d.\n", 
                    fils, getpid(), getppid());
            execl(ref_exec, arg0_exec, arg1_exec, NULL);
            /* on ne se retrouve ici que si exec échoue */
            printf("\n     Processus fils numero %d : ERREUR EXEC\n", fils);
            /* perror : affiche un message relatif à l'erreur du dernier appel systàme */
            perror("     exec ");
            exit(fils);   /* sortie avec le numéro di fils qui a échoué */ 
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }
    dormir(duree_sommeil+2);
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                                                                                                                                   api_systeme/pf_fichier_lec_ouv_uni.c                                                                0000600 0053044 0074430 00000005576 14023705000 017375  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Fichiers : lecture partagée entre père et fils avec ouverture unique */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <string.h>   /* opérations sur les chaines */
#include <fcntl.h>    /* opérations sur les fichiers */

#define NB_FILS 3     /* nombre de fils */

int main()
{
    int fils, retour, desc_fic, fils_termine, wstatus;
    int duree_sommeil = 3;

    char fichier[] = "fic_centaines.txt";
    char buffer[8];     /* buffer de lecture */

    /* Initialiser buffer avec 0 */
    bzero(buffer, sizeof(buffer));

    /* ouverture du fichier en lecture */
    desc_fic = open(fichier, O_RDONLY);
    /* traiter systématiquement les retours d'erreur des appels */
    if (desc_fic < 0) {
        printf("Erreur ouverture %s\n", fichier);
        exit(1);
    }

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            /* decaler les lectures des differents fils : fils 3, fils 2, fils 1 */
            sleep(NB_FILS - fils);
            /* lire le fichier par blocs de 4 octets */
            while (read(desc_fic, buffer, 4) > 0) {
                printf("     Processus fils numero %d a lu %s\n", fils, buffer);
                sleep(duree_sommeil);
                bzero(buffer, sizeof(buffer));
            }
            /* Important : terminer un processus par exit */
            exit(EXIT_SUCCESS);   /* Terminaison normale (0 = sans erreur) */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }

    /* attendre la fin des fils */
    for (fils = 1; fils <= NB_FILS; fils++) {
        /* attendre la fin d'un fils */
        fils_termine = wait(&wstatus);

        if WIFEXITED(wstatus) {   /* fils terminé avec exit */
            printf("\nMon fils de pid %d a termine avec exit %d\n", 
                    fils_termine, WEXITSTATUS(wstatus));
        }
        else if WIFSIGNALED(wstatus) {  /* fils tué par un signal */
            printf("\nMon fils de pid %d a ete tue par le signal %d\n", 
                    fils_termine, WTERMSIG(wstatus));
        }
    }
    close(desc_fic);
    printf("\nProcessus Principal termine\n");
    return EXIT_SUCCESS;
}
                                                                                                                                  api_systeme/pf_calmaxtab_fichier.c                                                                  0000600 0053044 0074430 00000007176 13637052561 017041  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Calcul distribué du maximum d'un tableau : communication par fichier */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <string.h>   /* opérations sur les chaines */
#include <fcntl.h>    /* opérations sur les fichiers */

#define NB_FILS 3     /* nombre de fils */
#define NB_FLEM_FILS 100000
#define NB_ELEM NB_FILS*NB_FLEM_FILS

/* calcul du max d'un sous-tableau */
int cal_max_tab(int tab[], int i1, int i2) {
    int i, max;

    max = tab[i1];

    for (i = i1 + 1; i < i2; i++) {
        if (tab[i]>max) {
            max = tab[i];
        }
    }
    return max;
}

int main()
{
    int fils, retour, desc_fic, fils_termine, wstatus, max, max_lu;

    int tab[NB_ELEM];

    char fichier[] = "fic_3f_maxtab";

    /* initialiser le tableau */
    for (int i=0; i < NB_ELEM; i++) {
        tab[i] = i+1;
    }

    /* ouvrir le fichier en écriture */
    desc_fic = open(fichier, O_WRONLY | O_CREAT | O_TRUNC, 0640);
    /* traiter systématiquement les retours d'erreur des appels */
    if (desc_fic < 0) {
        printf("Erreur ouverture %s\n", fichier);
        exit(1);
    }

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            /* calculer le max du sous-tableau */
            max = cal_max_tab(tab, (fils-1)*NB_FLEM_FILS, fils*NB_FLEM_FILS);
            /* enregistrer le max en binaire */
            write(desc_fic, &max, sizeof(int));
            /* Important : terminer un processus par exit */
            exit(EXIT_SUCCESS);   /* Terminaison normale (0 = sans erreur) */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }

    /* fermer le fichier ouvert en ecriture */
    close(desc_fic);

    /* ouvrir le fichier en lecture */
    desc_fic = open(fichier, O_RDONLY);
    /* traiter systématiquement les retours d'erreur des appels */
    if (desc_fic < 0) {
        printf("Erreur ouverture %s\n", fichier);
        exit(1);
    }

    max = 0;
    /* attendre la fin des fils */
    for (fils = 1; fils <= NB_FILS; fils++) {
        /* attendre la fin d'un fils */
        fils_termine = wait(&wstatus);

        if WIFEXITED(wstatus) {   /* fils terminé avec exit */
            printf("\nMon fils de pid %d a termine avec exit %d\n", 
                    fils_termine, WEXITSTATUS(wstatus));
        }
        else if WIFSIGNALED(wstatus) {  /* fils tué par un signal */
            printf("\nMon fils de pid %d a ete tue par le signal %d\n", 
                    fils_termine, WTERMSIG(wstatus));
        }
        /* lire les nouvelles valeurs communiquées par les fils */
        /* et calculer le max intermédiaire */
        while (read(desc_fic, &max_lu, sizeof(int))>0) {
            if (max_lu > max) {
                max = max_lu;
            }
        }
    }
    close(desc_fic);
    printf("\nProcessus Principal termine. Max = %d\n", max);
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                                                                                                                                                  api_systeme/dormir.c                                                                                0000600 0053044 0074430 00000000626 13634070777 014222  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    #include <stdio.h>
#include <stdlib.h>
#include <unistd.h>  

// dormir durant n secondes : n fournie en argument
// sinon n=5 par défault
int main(int argc, char* argv[])
{
    int delai = 5;
    if (argc > 1 ) {
        delai = atoi(argv[1]);
    }
    printf("\n      - Processus %d va dormir durant %d secondes\n", getpid(), delai);
    sleep(delai);
	fflush(stdout);
    return 0;
}
                                                                                                          api_systeme/pere_fils_exec.c                                                                        0000644 0053044 0074430 00000005064 13625303020 015667  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* execl */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */

#define NB_FILS 3     /* nombre de fils */

int main()
{
    int fils, retour, wstatus, fils_termine;

    char ref_exec[]="./dormir"; /* exécutable  */
    char arg0_exec[]="dodo";	/* argument0 du exec : nom donnée au processus */
    char arg1_exec[]="10";	    /* argument0 du exec : durée de sommeil */

    printf("Je suis le processus principal de pid %d\n", getpid());
    /* Vidange du tampon de sortie pour que le fils le récupère vide        */
    fflush(stdout);

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {

			/* mettre un executable inexistant pour le fils 2 */
            if (fils == 2) {
                ref_exec[3] = 'a';
            }

            execl(ref_exec, arg0_exec, arg1_exec, NULL);

            /* on ne se retrouve ici que si exec échoue */
            printf("\n     Processus fils numero %d : ERREUR EXEC\n", fils);
            /* perror : affiche un message relatif à l'erreur du dernier appel systàme */
            perror("     exec ");
            exit(fils);   /* sortie avec le numéro di fils qui a échoué */ 
        }
        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
            fflush(stdout);
        }
    }
    sleep(3);   /* pour les besoins de l'outil de validation automatique */

    /* attendre la fin des fils */
    for (fils = 1; fils <= NB_FILS; fils++) {
        /* attendre la fin d'un fils */
        fils_termine = wait(&wstatus);

        if WIFEXITED(wstatus) {   /* fils terminé avec exit */
            printf("\nMon fils de pid %d a termine avec exit %d\n", 
                    fils_termine, WEXITSTATUS(wstatus));
        }
        else if WIFSIGNALED(wstatus) {  /* fils tué par un signal */
            printf("\nMon fils de pid %d a ete tue par le signal %d\n", 
                    fils_termine, WTERMSIG(wstatus));
        }
    }
    printf("\nProcessus Principal termine\n");
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                            api_systeme/pere_fils_wait.c                                                                        0000600 0053044 0074430 00000004443 13622311676 015714  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* wait : le père attend la fin de ses fils */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */

#define NB_FILS 3     /* nombre de fils */

int main()
{
    int fils, retour, wstatus, fils_termine;
    int duree_sommeil = 300;

    printf("\nJe suis le processus principal de pid %d\n", getpid());
    /* Vidange du tampon de sortie pour que le fils le récupère vide        */
    fflush(stdout);

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            printf("\n     Processus fils numero %d, de pid %d, de pere %d.\n", 
                    fils, getpid(), getppid());
            /* Le fils 2 s'endort pendant une durée asse longue */
            if (fils == 2) {
                sleep(duree_sommeil);
            }
            exit(fils);  /* normalement exit(0), mais on veut illustrer WEXITSTATUS */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }

    sleep(3);	/* pour les besoins de l'outil de validation automatique */

    /* attendre la fin des fils */
    for (fils = 1; fils <= NB_FILS; fils++) {
        /* attendre la fin d'un fils */
        fils_termine = wait(&wstatus);

        if WIFEXITED(wstatus) {   /* fils terminé avec exit */
            printf("\nMon fils de pid %d a termine avec exit %d\n", 
                    fils_termine, WEXITSTATUS(wstatus));
        }
        else if WIFSIGNALED(wstatus) {  /* fils tué par un signal */
            printf("\nMon fils de pid %d a ete tue par le signal %d\n", 
                    fils_termine, WTERMSIG(wstatus));
        }
    }
    printf("\nProcessus Principal termine\n");
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                             api_systeme/pf_fichier_ecr_ouv_uni.c                                                                0000600 0053044 0074430 00000006243 13637051056 017412  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* 1 fichier : 1 seule ouverture en écriture partagée */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <string.h>   /* opérations sur les chaines */
#include <fcntl.h>    /* opérations sur les fichiers */

#define NB_FILS 3     /* nombre de fils */

int main()
{
    int fils, retour, desc_fic, fils_termine, wstatus, ifor;
    int duree_sommeil = 3;

    char fichier[] = "fic_res_ouv_uni.txt";
    char buffer[8];     /* buffer de lecture */

    bzero(buffer, sizeof(buffer));

    /* ouverture du fichier en ecriture, avec autorisations rw- -r- ---*/
    /* avec création si le fichier n'existe pas : O_CREAT */
    /* avec vidange (raz du contenu) si le fichier existe: O_TRUNC */
    desc_fic = open(fichier, O_WRONLY | O_CREAT | O_TRUNC, 0640);

    /* traiter systématiquement les retours d'erreur des appels */
    if (desc_fic < 0) {
        printf("Erreur ouverture %s\n", fichier);
        exit(1);
    }

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            /* decaler les écritures des differents fils : fils 3, fils 2, fils 1, ... */
            sleep(NB_FILS - fils);

            /* effectuer 4 ecritures dans le fichier */
            for (ifor = 1; ifor <= 4; ifor++) {
                bzero(buffer, sizeof(buffer));
                sprintf(buffer, "%d-%d\n", fils,ifor);
                write(desc_fic, buffer, strlen(buffer));
                printf("     Processus fils numero %d a ecrit %s\n", 
                        fils, buffer);
                sleep(duree_sommeil);
            }
            /* Important : terminer un processus par exit */
            exit(EXIT_SUCCESS);   /* Terminaison normale (0 = sans erreur) */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }
    /* attendre la fin des fils */
    for (fils = 1; fils <= NB_FILS; fils++) {
        /* attendre la fin d'un fils */
        fils_termine = wait(&wstatus);

        if WIFEXITED(wstatus) {   /* fils terminé avec exit */
            printf("\nMon fils de pid %d a termine avec exit %d\n", 
                    fils_termine, WEXITSTATUS(wstatus));
        }
        else if WIFSIGNALED(wstatus) {  /* fils tué par un signal */
            printf("\nMon fils de pid %d a ete tue par le signal %d\n", 
                    fils_termine, WTERMSIG(wstatus));
        }
    }
    close(desc_fic);
    printf("\nProcessus Principal termine\n");
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                                                                                                             api_systeme/pere_fils_heritage.c                                                                    0000600 0053044 0074430 00000003415 13625505360 016534  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Héritage et dupplication des données */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */

#define NB_FILS 4     /* nombre de fils */

int main()
{
    int fils, retour;
    int cagnotte, patrimoine_fils;
    int duree_sommeil = 4;
    cagnotte = 10000 * NB_FILS;
    patrimoine_fils = cagnotte / NB_FILS;

    printf("\nJe suis le processus principal de pid %d\n", getpid());
    printf("Je dispose de %d Euros, que je partage entre mes futurs fils\n", cagnotte);

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            printf("\n    Processus fils numero %d : mon pere m'a offert %d Euros\n", 
                    fils, patrimoine_fils);
            patrimoine_fils = patrimoine_fils * (fils + 1);   
            sleep(duree_sommeil);
            printf("\n    Processus fils numero %d - j'ai augmente mon patrimoine a %d Euros\n", 
                    fils, patrimoine_fils);
            exit(EXIT_SUCCESS);   /* Te:rminaison normale (0 = sans erreur) */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }
    sleep(duree_sommeil+1);

    printf("\nProcessus Principal - le patrimoine total de mes fils est de %d\n", patrimoine_fils*NB_FILS);
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                   api_systeme/sigaction_source_signal.c                                                               0000600 0053044 0074430 00000004442 14027613476 017617  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    #include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h> 

/* traitant sigaction, avec récupération du pid de l'émetteur du signal */
void sigaction_sig (int num_sig, siginfo_t *siginfo, void * notused) {
	int emetteur;
	
	// récupérer le numéro du porcessus qui a envoyé le signal
	emetteur = siginfo->si_pid;
	
	printf("Processus %d a recu le signal %d envoye par le processus %d \n", getpid(), num_sig, emetteur);
}

/* traitant qui peut être utilisé en modifiant l'initialisation de sigaction */
void handler_sig (int num_sig) {
	printf("Processus %d a recu le signal %d\n", getpid(), num_sig);
}

/* Programme principal 
 * un père crée un fils et s'endort pendant 120 secondes 
 * le fils se termine après 3 secondes environs ==> envoi de SIGCHLD au père 
 * le père traite (traitant sigaction dessus) SIGCHLD, SIGINT, SIGTSTP et SIGCONT : 
 * afficahge du numéro du signal reçu et du pid de l'émetterur 
 * A tester avec CtrlC, CtrlZ, et envoie des signaux depuis un autre terminal */

int main() {
	struct sigaction s;
	
	int pid, retval, duree_sommeil = 120;
	
	/* Il est très important d'initialiser sa_flags, éventuellement avec 0 */
	s.sa_flags = SA_SIGINFO; // pour récupérer les infos dans siginfo
	s.sa_sigaction = sigaction_sig;

    /* On utilise soit sa_sigaction ou sa_handler */
	// s.sa_handler = handler_sig;
	
	retval = sigaction(SIGINT, &s, NULL);   // 3eme paramètre à NULL, car on ne
	retval = sigaction(SIGTSTP, &s, NULL);  // souhaite pas récupérer l'ancien
	retval = sigaction(SIGCONT, &s, NULL);  // sigaction
	retval = sigaction(SIGCHLD, &s, NULL);
	
	if(retval < 0) { 
		perror("sigaction failed"); 
	} 
	
	pid = fork();
	switch (pid) {
		case -1 :
			printf("Erreur fork\n"); exit(1);
		case 0 : //fils 
			sleep(3);
			exit(0); 	
				
		default : //pere 
			printf("Je suis le processus %d et j'ai cree un fils de numéro %d\n", getpid(), pid);
			printf("Je m'endors pendant %d secondes et je traite les signaux SIGINT, SIGTSTP,  SIGCONT et SIGCHLD\n", duree_sommeil);

			int duree=0;
			do {
				sleep(1);  	// sleep est arrêté par la réception d'un signal
							// on ne peut donc pas utiliser sleep(duree_sommeil)
				duree++;
			} while (duree < duree_sommeil);
	}
	return 0;
}
                                                                                                                                                                                                                              api_systeme/pf_fichier_lec_ouv_uni_lseek.c                                                          0000600 0053044 0074430 00000006170 13637050413 020562  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Fichiers : lecture partagée avec ouverture unique et lssek */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <sys/types.h>
#include <string.h>   /* opérations sur les chaines */
#include <fcntl.h>    /* opérations sur les fichiers */

#define NB_FILS 3     /* nombre de fils */

int main()
{
    int fils, retour, desc_fic, fils_termine, wstatus;
    int duree_sommeil = 3;

    char fichier[] = "fic_centaines.txt";
    char buffer[8];     /* buffer de lecture */

    /* Initialiser buffer avec 0 */
    bzero(buffer, sizeof(buffer));

    /* ouverture du fichier en lecture */
    desc_fic = open(fichier, O_RDONLY);
    /* traiter systématiquement les retours d'erreur des appels */
    if (desc_fic < 0) {
        printf("Erreur ouverture %s\n", fichier);
        exit(1);
    }

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            /* decaler les lectures des differents fils : fils 3, fils 2, fils 1, ... */
            sleep(NB_FILS - fils);

            if (fils == NB_FILS) {
                lseek(desc_fic, 4, SEEK_SET);
            }
            /* lire le fichier par blocs de 4 octets */
            while (read(desc_fic, buffer, 4) > 0) {

                printf("     Processus fils numero %d a lu %s\n", 
                        fils, buffer);
                if (fils == 1) {
                    lseek(desc_fic, 4, SEEK_CUR);
                }
                sleep(duree_sommeil);
                bzero(buffer, sizeof(buffer));
            }
            /* Important : terminer un processus par exit */
            exit(EXIT_SUCCESS);   /* Terminaison normale (0 = sans erreur) */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }

    /* attendre la fin des fils */
    for (fils = 1; fils <= NB_FILS; fils++) {
        /* attendre la fin d'un fils */
        fils_termine = wait(&wstatus);

        if WIFEXITED(wstatus) {   /* fils terminé avec exit */
            printf("\nMon fils de pid %d a termine avec exit %d\n", 
                    fils_termine, WEXITSTATUS(wstatus));
        }
        else if WIFSIGNALED(wstatus) {  /* fils tué par un signal */
            printf("\nMon fils de pid %d a ete tue par le signal %d\n", 
                    fils_termine, WTERMSIG(wstatus));
        }
    }
    close(desc_fic);
    printf("\nProcessus Principal termine\n");
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                                                                                                                                                        api_systeme/apisys                                                                                  0000755 0053044 0074430 00000213300 14027604530 014006  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    ELF          >           @       �         @ 8 	 @         @       @       @       �      �                   8      8      8                                                         h�      h�                    ��      ��      ��            �`                    ��      ��      ��      �      �                   T      T      T      D       D              P�td   0�      0�      0�                         Q�td                                                  R�td   ��      ��      ��      H      H             /lib64/ld-linux-x86-64.so.2          GNU                        GNU �F��*фG;��i�������   '             � '   (   )�gUa                        r                      :                                            W                      �                      �                      �                      �                      a                                            �                      �                                           �                                           �                      P                      V                      �                      �                      �                                            1                      �                      '                      &                      �                      A                      �                                                                  �                      e                      �                      �                      ,                      �   "                   \                      �     ��             z     ��              libc.so.6 fflush strcpy exit sprintf fopen wait __isoc99_sscanf __isoc99_scanf signal puts fork __stack_chk_fail putchar stdin kill fgetc execlp fgets strlen getchar getlogin_r ctime stdout fclose strcat umask bzero alarm fwrite fread sleep __cxa_finalize strcmp __libc_start_main GLIBC_2.7 GLIBC_2.4 GLIBC_2.2.5 _ITM_deregisterTMCloneTable __gmon_start__ _ITM_registerTMCloneTable                                                                 ii        ii   $     ui	   .      ��                    ��             �      �             �      ��                    ��                    ��                    ��         !           ��         %           ��         '           ��         (           ��                    ��                    ��                    ��                    ��                    ��                     �                    �         	           �         
           �                     �                    (�                    0�                    8�                    @�                    H�                    P�                    X�                    `�                    h�                    p�                    x�                    ��                    ��                    ��                    ��                    ��                    ��                    ��                     ��         "           ��         #           ��         $           ��         &           H��H�%�  H��t��H��� �5��  �%��  @ �%��  h    ������%��  h   ������%��  h   ������%��  h   �����%��  h   �����%��  h   �����%��  h   �����%��  h   �p����%��  h   �`����%��  h	   �P����%��  h
   �@����%��  h   �0����%��  h   � ����%��  h   �����%z�  h   � ����%r�  h   ������%j�  h   ������%b�  h   ������%Z�  h   ������%R�  h   �����%J�  h   �����%B�  h   �����%:�  h   �����%2�  h   �p����%*�  h   �`����%"�  h   �P����%�  h   �@����%�  h   �0����%
�  h   � ����%�  h   �����%��  h   � ����%��  h   ������%��  h    ������%�  f�        1�I��^H��H���PTL�
�  H���  H�=�  ���  �D  H�=��  UH���  H9�H��tH���  H��t]��f.�     ]�@ f.�     H�=Q�  H�5J�  UH)�H��H��H��H��?H�H��tH�Q�  H��t]��f�     ]�@ f.�     �=1�   u/H�='�   UH��tH�=*�  �����H����	�  ]��    ��fD  UH��]�f���UH��H���}�H�=�  ��������UH��H���}��O4! ���F4! H���  H�������14! =�  ~)H���  H�5��  H�=�  �    ������    �����   ��������UH��H���E� ������E��}�
t�}��u���UH��    ������]�UH��H��0H�}�H�u�dH�%(   H�E�1�H�U�H�E�H��H�=��  �    �_���H�E�H��H�=}�  �    �G����E�}�t6H�5��  H�=`�  �    �&����q����E���g����E�}�
t�}��u�}�u��M����E���C����E�}�
t�}��u�E�H�M�dH3%(   t������UH����E��}�`~�}�z	�E��� ��E�]�UH��H���   H��H�����D���dH�%(   H�E�1�ǅT���    H�5˚  H�=��  �C���H��`���H��`��� u
ǅT���   H��p�����   H���$���H��p���H�~�  H�5~�  H�Ǹ    �2���H��p���H�������H��H��`���H��p���H��H��   H������H��`���H�������K�����X�����X����u
ǅT���   ��X��� u.�    H���  H�5�  H�=��  �    ������   ������X�����  �   ����H��P���H���������P���������   ��P�����%�   ��T�����T��� ��   H�5��  H�=n�  �����H��h���H��h��� uǅT���   ���D���Hc�H��H���H��H���������D���Hc�H��h���H��H����   H���e�����\�����\���ǅT���   �%��\���H�H�P�H��H���H��  �
ǅT���   ��T���H�M�dH3%(   t�K�����UH��H���   H��H���dH�%(   H�E�1�H�5��  H�=r�  ����H��`���H��`��� uǅT���������  H��p�����   H�������H��H���H��p���H�4�  H�5M�  H�Ǹ    �����H��p���H������H��H��`���H��p���H��H��   H�������H��`���H���F���������X�����X����u
ǅT���������X��� u.�    H���  H�5��  H�=��  �    ����������a����   �G���H��P���H��������P���������   ��P�����%�   ��\�����\��� ��   H�5��  H�=0�  ����H��h���H��h��� uǅT��������   H��p�����   H������ǅT���    H��h���H��p�����   H������H��t"H��T���H��p���H�5�  H�Ǹ    ����H��h���H�������ǅT��������
ǅT���������T���H�M�dH3%(   t������UH��H��  dH�%(   H�E�1���
!     �
.!     ǅP���    �C��P���H�H��    H��! �    ��P���H�H��    H��! �    ��P�����P���~��,�     �    ����H��`����    H�=�! �N���H��`���H������H��H�=e! ������i!  H��p���H�5k-! H������H��p���H�5��  H������H��p���H������H�¸    H���H��H��H�P�H��p���H�� .csv�@ H��p���H�58�  H������H��h���H��h��� ��  H��h���H������H�Ѻ   �   H���6�����\�����\��� �T  ǅP���    ���P�����P���;�\���}��P���H�������<;u׃�P�����P���;�\���}EH��������P���H�H�H�	! H�5��  H�Ǹ    ������! ����! ���P�����P���;�\���}��P���H�������<;u׃�P�����P���;�\���}-H��������P���H�H�H�@�  H�54�  H�Ǹ    �0����&�  ����  ���P�����P���;�\���}��P���H�������<;u׃�P���ǅT���    �    H�=I! �����1��P���H���������T���Hc�H�"! ���T�����P�����P���;�\���}��P���H�������<;u���P���ǅT���    �1��P���H���������T���Hc�H�\3! ���T�����P�����P���;�\���}��P���H�������<;u���P���ǅX���    �  ��P���;�\���}I��X���H�H��    H�! H�H��������P���H�H�H�5��  H�Ǹ    �������P�����P���;�\���}��P���H�������<;u׃�P�����P���;�\���}@��X���H�H��    H��! H�H��������P���H�H�H�59�  H�Ǹ    �5�����P������P�����P���;�\���}��P���H�������<;u׃�P�����X�����P���;�\���}��P���H�������<;�����H��h���H���������H�E�dH3%(   t�������UH��H��  dH�%(   H�E�1�H��p���H�5)! H���X���H��p���H�5z�  H�������H��p���H������H�¸    H���H��H��H�P�H��p���H�� .csv�@ �I   �����H��p���H�5��  H���9���H��`����?   ����H��`��� ��   H�=�  �����H�=�  �    ����H���  H��������   H�=�! �����H�5�! H�=5�  �    �������! �����	�����'! ��'! ���  8��  �   �����H�������   H������H������H�5L�  H������H������H������H�¸    H���H��H��H�P�H������H�f� ; H��h����   H���,����6! �PH��h���H�5̏  H�Ǹ    �8���H��h���H������H��H������H������H������H�¸    H���H��H��H�P�H������H�f� ; H��h����   H�������]�  H��h���H�5J�  H�Ǹ    ����H��h���H������H��H������H������H������H�¸    H���H��H��H�P�H������H�f� ; H������H�5[! H���C���H������H������H�¸    H���H��H��H�P�H������H�f� ; �    ����H��X����    H�=�.! �����H��X���H������H��H�=�.! �O�����.!  H������H�5j.! H������H������H������H�¸    H���H��H��H�P�H������H�f� ; ǅT���    �3  H��h����   H���;�����T���H�H��    H�! �H��h���H�5ʍ  H�Ǹ    �6���H��h���H������H��H������H������H������H�¸    H���H��H��H�P�H������H�f� ; H��h����   H��������T���H�H��    H��	! �H��h���H�54�  H�Ǹ    ����H��h���H������H��H���w���H������H������H�¸    H���H��H��H�P�H������H�f� ; ��T�����	! 9�T��������H������H������H�¸    H���H��H��H�P�H������H�f� 
 H������H������H��H��`���H������H��H��   H�������H��`���H���d����    H�u�dH34%(   t�{�����UH��SH��H  H������H������������H������D������dH�%(   H�E�1�ǅ����    H������H�5ً  H������H������H������ u(��������H�=\�  �    ����ǅ����   �  H�������   H�������H�������     �   H������� H�H��H��H������H�H������� H�H��H��H������H�H���l���H��� H������� �PH�������������H�H�������Hc�H��H��H������H�H��H���/���H������� ��/=H������� H�H��H��H������H�H��������������H���-���H���'���H������H������������H�]�dH3%(   t����H��H  []�UH��H��   dH�%(   H�E�1�ǅ����    H�������   H���y���H������H�5�!! H������H������H������H�¸    H���H��H��H�P�H������H�H�.mafatihH�f�@3 H������H�5ȉ  H�������H������H������ u%�   H�=N�  �    �����ǅ����   ��   H�������   H���������!     �q�! H�H��H��H���  H��e! H�H��H��H�U!! H�H������H�5�  H�Ǹ    �'���H�������   H���S����! ���! �! ��$H������H�������   H���^���H���`���H������H�������������H�u�dH34%(   t�������UH��H��pdH�%(   H�E�1�H�Validee H�E��E�    H�Non valiH�E��E�dee H�E��@   H���������  H�H��    H�q! ���u/H�U�H�E�L�O�  H��H�!�  H�5�  H�Ǹ    �}����-H�U�H�E�L� �  H��H���  H�5  H�Ǹ    �N����
   ������  H�H��H��H��! H���  �PH�E�I��H��H�5��  H�=w�  �    �����H�=�  �s������  H�H��H��H�}! H�H��H�5p�  H�=J�  �    �������  H�H��H��H���  H�L�S�  H��H�1�  H�5��  H�=�  �    �]����E�   �"�E�H�H��H��H��  H�H��������E���! 9E�|�H�=Շ  �    ����H���  H�������H�E�dH3%(   t�������UH��H��   dH�%(   H�E�1�H�5��  H�=��  �    ����ǅ`���    �c  ��`���H�H��H��H���  H�H���n�����l���ǅd���   ǅh���   ��`���H�H��H��H�^�  ���p�����   ��d���H���`���Hc�H��H�H�0�  H����h���H���p�����h�����d�����d���;�l���})��d���H���`���Hc�H��H�H���  H�� <[u���h���H�Ƅp��� H��p���H��H�=��  �    ������d���H���`���Hc�H��H�H���  H�� ��p�����d���ǅh���   ��d���;�l����P����
   �������`������  9�`��������H�=+�  �    �)���H���  H������H�5�! H�=R�  �    �����H�E�dH3%(   t�������UH��H��H���  H�5��  H�=��  �    ������E�    �"�E�H�H��H��H�(! H�H���=����E��;�  9E�|Ӑ��UH��H��@  H������H������H������dH�%(   H�E�1�ǅ����    H������H�5��  H������H������H������ u*H������H��H�=��  �    ����ǅ����   �  H�������   H�������H������H������H�5h�  H�Ǹ    �����H������H������H��H������H������H��H��   H�������H������H�dcmd=$1/H��@$cmdf�@
 H������H���H���H��H������H������H��H��   H������H������H������H��H���  H�5��  H�Ǹ    �8���H������H�������H��H������H������H��H��   H���%���H������H�if [ -x H�$dcmd -aH�0H�xH� -r $dcmH�d ] && [H�pH�xH� -w $1 ]H�; then
 H�P H�H(H������H���\���H��H������H������H��H��   H������H������H������H�5�  H�Ǹ    �V���H������H������H��H������H������H��H��   H���C���H������H�echo faiH�t > $1/$H�0H�xH�ficerr
 H�HH������H������H��H������H������H��H��   H�������H������H�exit $?
H��@ H������H���Y���H��H������H������H��H��   H������H������� elsef�@
 H������H������H��H������H������H��H��   H���O���H������H�echo '--H�- RessouH�H�HH�rces disH�tantes iH�pH�xH�naccessiH�H �@(blesf�@,'
�@. H������H������H��H������H������H��H��   H������H������H�exit 1
 H�H������H���<���H��H������H������H��H��   H���x���H������f� fi�@ H������H�������H��H������H������H��H��   H���5���H������H������������H�M�dH3%(   t������UH��H���   dH�%(   H�E�1�H�./.tempsH��[���fǅc���h H�./.temprH��e���fǅm���esƅo��� ǅD���    ǅ@���    �������H�����H������t	��t��   H�=�  ������   �\���H�./.tempsH��[���fǅc���h ��  H�H��H��H��! H�4���  H�H��H��H��  H�H��[���H��H���A�����D�����D��� uCH��e���H��[���A�    I��H��! H��H�5~  H�=�}  �    �������������������������H�����  �   �z���H��8���H��������8��������U  ��8�����%�   ��D�����D��� �  ��  Hc�H��    H�A�  ��JH�H��    H�*�  �H��e���H�5K}  H������H��P���H��P��� ��  H��P���H��p�����   H�������H���c  H��<���H��p���H�5*}  H�Ǹ    �&����p�  H�H��    H���  ��V�  H�H��    H���  ����ȺVUUU���������)���<�����<�����������k�d��L�����  H�H��    H�1�  ���~*�! ���  H�H��    H���  �)Љ�! ���  H�H��    H�H! ����  +�L�����Hc�H��    H�e�  ��|�  H�H��    H�K�  ���! Љ�! ��L�����H�=#~  �    �A����    �?����qH��e���H��H�=$~  �    ����H�=C~  �����H��D�����H�=]~  �    �������D�����@����!��8�����������~��8�������@�����@��� ~��@�����������H�E�dH3%(   t������UH��H��0H�}�dH�%(   H�E�1�H�5�z  H�=��  �I���H�E�H�}� u$H�5��  H�=�}  �    �F����E������   H�E�H������H��H�U�H�E�H��H��   H���P���H�E�H������������E�}� u.�    H�2�  H�5Rz  H�=Kz  �    �"����   �����H�E�H���,����E����u�E���%�   �E���E������E�H�M�dH3%(   t�t�����UH��H�� H�}�u�U��E�    �E��E�H�E�H�5,�  H�������E��}� u	�E�	   �6�E�;E�t'�m��E��E���H�5޼  H�=�|  �    ������E�    �}� ~�}� ~�}�~��E���UH��H�� H�}�u�U��E�    �E��E�H�E�H�5��  H���%����E��}� u	�E�	   �D�E��9E��E��9E�|	�E�    �%�m��E��E���H�56�  H�=+|  �    �i����}� ~�}� ~�}�~��E���UH��H��0H�}�u�U��M��E�    �E܉E�H�E�H�5��  H�������E��}� u	�E�	   �>�E�;E�t/�E�;E�t'�m��E��E���H�5��  H�=�{  �    �������E�    �}� ~�}� ~�}�~��E���UH��H��0H�}؉��UЈE�dH�%(   H�E�1��E�    �EЉE�H�E�H��H�5L�  H�=X{  �    �g���H�E�H��H�=�x  �    �O����E������v���8E�t*�m��E������E��H�5�  H�=�z  �    ������E�    �}� ~
�}� �u����E�H�M�dH3%(   t�������UH��H��@H�}�H�uЉU�dH�%(   H�E�1��E�    �ẺE�H�E�H��H�5y�  H�=�z  �    ����H�E�H��H�=�w  �    �|���H�U�H�E�H��H��������t*�m��E������E��H�5
�  H�=�y  �    �=�����E�    �}� ~
�}� �q����E�H�M�dH3%(   t�������UH��H��P  H������H������������dH�%(   H�E�1�ǅ����    H�5qv  H�=�  ����H������H������ uH�5p�  H�=�y  �    �����   H�������   H���n����l������H�H��    H������H�<������H�H��    H������H�4H������H������H������I��I��H�5Dy  H�Ǹ    �����������������;�����}$H������H�������   H������H���b���H������H������������H�M�dH3%(   t������UH��H��   dH�%(   H�E�1�ǅ����    H�5-u  H�=ٸ  �\���H������H������ uH�5,�  H�=Mx  �    �S����VH�������   H���-���H������H�������   H���R���H��t"H������H������H�5�t  H�Ǹ    ����H������H������������H�M�dH3%(   t�������UH��H��0  H������dH�%(   H�E�1�ǅ����   H��p�����   H������H������H��p���H�Է  H�5�w  H�Ǹ    ����H��p���H�������������H��0���H������H��H���/��������������� ~H���  H�5ٶ  H�=nw  �    ����ǅ����    �"������H���������	   ���e���������������;�����|АH�E�dH3%(   t������UH��H��   dH�%(   H�E�1�ǅ����   H��p�����   H���q���H��p���H�˶  H���  H�5�v  H�Ǹ    �x���H��p���H������������H��0���H������H��H������������ǅ����    �5������H����������t������H���������	   ���j���������������;�����|��H�E�dH3%(   t������UH��H��@  H������dH�%(   H�E�1�ǅ����   ǅ����   �   �����ǅ����    H��p�����   H���Q���H������H��p���H���  H�5uu  H�Ǹ    �X���H��p���H������������H��0���H������H��H�������������ǅ����   ��0���������������;�������   ǅ����   �H������H����0�����������H����0���9�u������������H����0���������������������;�����|���������9�����tvH�5�  H�=�t  �    �Q���H�5�  H�=u  �    �9���ǅ���������:H�5�  H�=u  �    ����H�5ʳ  H�=�t  �    �����ǅ�������������� u�������   ��H�=�t  �O��������������� u�������   ��H�=u  �'���������ǅ����    �"������H���������	   �������������������;�����|Ћ�����H�M�dH3%(   t�=�����UH��H���  H��H���dH�%(   H�E�1�ǅ|���   ǅ����   �   �l���ǅ\���    H��p�����   H�������H��H���H��p���H�1�  H�5s  H�Ǹ    �����H��p���H��������|���H������H������H��H������������������;�������  ǅP���    �~��P���H�Ǆ�0���    ǅT���    �J��T���H����������P���H��������9�u!��P���H����0����P��P���H����0�����T�����T���;�����|���P�����P���;������p���ǅP���    ���P�����P���;�����}��P���H����0�����~׋�P���;�����|?H�5U�  H�=s  �    ����H�5=�  H�=:r  �    �p���ǅ\��������  ��P���H��������������ǅT���    ǅX���    ��T���H��������9�����u%��T���H����������X���H����������X�����T�����T���;�����}	��X���~�ǅ`���    ǅd���    ǅh���    ǅP���    �k��P���H��������������9�u	��`����B��P���H��������������9�u	��d���� ��P���H��������������9�u��h�����P�����P���;�����|���`�����d����h���Ѓ�t?H�5կ  H�=�q  �    ����H�5��  H�=�p  �    �����ǅ\��������   ��`�����   ��d���t��h���tvH�5w�  H�=�q  �    ����H�5_�  H�=\p  �    ����ǅ\��������:H�5;�  H�=hp  �    �n���H�5#�  H�= p  �    �V���ǅ\���������\��� ��  ǅT���    ���T���H�Ǆ�����    ��T�����T���;�X���|�ǅT���    �   ǅP���    �J��P���H����������T���H��������9�u!��T���H���������P��T���H����������P�����P���;�����|���T���H����������u��T���H����������l�����T���H����������u��T���H����������p�����T�����T���;�X����2���ǅP���    �   ��P���H��������9�p���ub��P���H��������������ǅT���    �3��T���H��������9�����u��T���H����������t�����T�����T���;�����|���P�����P���;������n���H�5Z�  H�=�o  �    �u����   �   H�=�o  �������\�����\��� u�   �   H�=�o  ������\�����\��� u�   �   H�=�o  ������\�����\��� u��l����   ��H�=�o  �k�����\�����\��� u��t����   ��H�=�o  �C�����\���ǅx���    �"��x���H���������	   ��������x�����x���;�����|Ћ�\���H�M�dH3%(   t�Y�����UH��H��P  H������dH�%(   H�E�1�ǅ����   ǅ����   �   ����H��p�����   H������H������H��p���H�W�  H�5(l  H�Ǹ    ����H��p���H���E���������H��0���H������H��H�������������   ����ǅ����    ǅ����   ������;�������   ǅ����   �3������H����0�����������H����0���9�u������������������;�����|���������9�����tvH�5ު  H�=sn  �    ����H�5ƪ  H�=�k  �    �����ǅ���������:H�5��  H�=�k  �    �����H�5��  H�=�k  �    ����ǅ�������������� unǅ����    �"������H���������   ������������������;�����|п   ������   �'  H�=�m  �����������H�=�  ����������� ubǅ����   �"������H���������   ������������������;�����|п   �M����   � N  H�=�m  �U��������������� u(�   �P�  H�=�m  �0���������H�=s�  �@��������� u8�������   �������   ������   �@�  H�=�m  �����������ǅ����    �"������H���������	   ������������������;�����|Ћ�����H�M�dH3%(   t�������UH��H��p  H������������H������dH�%(   H�E�1�H�Je suis H��[���H�ProcessuH��c���ǅk���s deƅo��� ǅ����   �   �����H��p�����   H���n���H������H��p���H���  H�5�h  H�Ǹ    �u���H��p���H������������H�����H������H��H������������ǅ����    ǅ����   ��������   ǅ����   �3������H���������������H�������9�u������������������;�����|�������tvH�5_�  H�=�j  �    ����H�5G�  H�=Dh  �    �z���ǅ���������:H�5#�  H�=Ph  �    �V���H�5�  H�=h  �    �>���ǅ�������������� �  H�5�  H�=�k  �    �����   �e���H��p�����   H�������H������H��[���H��p���L�-�  H�5ik  H�Ǹ    �����H��p���H�������������   �����    �����������H��p�����   H���n���H������H��[���H��p���H�5k  H�Ǹ    �u���������H��p����   ��H������������������ u�   �   H�=!k  ���������������� ��   H��p�����   H�������H������H��c���H��p���L�)�  H�5ej  H�Ǹ    �����H��p���H�������������   ������    �����������H��p�����   H���j���H������H��c���H��p���H�5j  H�Ǹ    �q���������H��p����   ��H������������������ u�   �   H�=ej  ����������ǅ����    �"������H���������	   ���c���������������;�����|Ћ�����H�M�dH3%(   t������UH��H��`  H������������H������dH�%(   H�E�1�ǅ����   ǅ����   �   �����H�53�  H�=�i  �    �N���H������H��H�5�  H�=j  �    �,���H��p�����   H������H������H��p���H�[�  H�5,d  H�Ǹ    ����H��p���H���I����   �6���������H��0���H������H��H������������ǅ����   ��0���������������;�������   ǅ����   �H������H����0�����������H����0���9�u������������H����0���������������������;�����|���������9�����tvH�5ˢ  H�=`f  �    �����H�5��  H�=�c  �    ����ǅ���������:H�5��  H�=�c  �    �¿��H�5w�  H�=tc  �    調��ǅ�������������� uXH��p�����   H���s���H������H��p���H�5~h  H�Ǹ    ����������H��p����   ��H������������������� ��  �������	   ��蠿��������H��  ��H�5ء  H�=Gh  �    ������   �O���H��p�����   H���˿��H������H��p���H��  H�5�a  H�Ǹ    �ҿ��H��p���H�������   �����������H��0���H������H��H���o���������ǅ����    ǅ����   ��0�����������������   ǅ����   �H������H����0�����������H����0���9�u������������H����0���������������������;�����|�������<H�5��  H�=&d  �    �Ľ��H�5y�  H�=va  �    謽��ǅ���������g������t^H�5L�  H�=�f  �    ����ǅ���������:H�5(�  H�=Ua  �    �[���H�5�  H�=a  �    �C���ǅ�������������� ��   H�5��  H�=�e  �    ����H������H��H�5ן  H�=�f  �    ����H��p�����   H���ν��H������H��p���H�5�f  H�Ǹ    �ܽ��H��p����   �   H���!���������ǅ����    �"������H���������	   �������������������;�����|Ћ�����H�M�dH3%(   t�7�����UH��H��P  H������������H������dH�%(   H�E�1�ǅ����   �   �c���H��p�����   H���߼��H������H��p���H�2�  H�5_  H�Ǹ    ����H��p���H��� ���������H��0���H������H��H������������������ ��  ������������H��p�����   H���U���������H��p���H���  H�5Ze  H�Ǹ    �]���H��p���H������������H��0���H������H��H������������ǅ����    ǅ����   ��������   ǅ����   �3������H����0�����������H����0���9�u������������������;�����|�������tvH�5G�  H�=�`  �    �z���H�5/�  H�=,^  �    �b���ǅ���������:H�5�  H�=8^  �    �>���H�5�  H�=�]  �    �&���ǅ�������������� uLH�5��  H�=�b  �    �����H�5Ȝ  H�=%d  �    �����   �S   H�=Rd  ���������������� uTH��p�����   H��蚺��������H��p���H�5Nd  H�Ǹ    詺��H��p����   �S   H������������������ ��  �������	   ���˹��������H��  ��H�5�  H�=d  �    �$����   �z���H��p�����   H�������������H��p���H�J�  H�5�b  H�Ǹ    �����H��p���H���8���������H��0���H������H��H������������ǅ����    ǅ����   ��������   ǅ����   �3������H����0�����������H����0���9�u������������������;�����|�������tvH�5�  H�=}^  �    ����H�5К  H�=�[  �    ����ǅ���������:H�5��  H�=�[  �    �߷��H�5��  H�=�[  �    �Ƿ��ǅ�������������� ��   H�5}�  H�=�b  �    蘷��H�5e�  H�=�a  �    耷��H��p�����   H���\���������H��p���H�5b  H�Ǹ    �k���H��p����   �Z   H���|���������ǅ����    �"������H���������	   ��腷��������������;�����|��:H�5��  H�=�Z  �    �ֶ��H�5��  H�=�Z  �    辶��ǅ��������������H�M�dH3%(   t芶����UH��H��@  H������������H������dH�%(   H�E�1�ǅ����   �   趷��H��p�����   H���2���H������H��p���H���  H�5VY  H�Ǹ    �9���H��p���H���s����   �`���������H��0���H������H��H��������������������9  �������   ���<���������������H�5}�  H�=:^  �    蘵��H�5e�  H�=�`  �    耵���������   ��H�=�`  ����������������� ��   ��������H�5�  H�=a  �    �4���H���  H�5��  H�=/a  �    ����H���  H�������������   ���t����   �J����   �   H�=)a  �R��������������� u�   �	   H�=<a  �-����������������	   �������:H�5J�  H�=wX  �    �}���H�52�  H�=/X  �    �e���ǅ��������������H�M�dH3%(   t�1�����UH��H���  H��8�����4���H��(���dH�%(   H�E�1�ǅ`���   H�5Ζ  H�=�`  �    �����   �E���H��p�����   H�������H��8���H��p���H��  H�5�V  H�Ǹ    �ȴ��H��p���H�������   ������`���H������H��p���H��H���e�����d���ǅT���    ��d���~?H�5�  H�=9W  �    �?���H�5��  H�=�V  �    �'���ǅT��������  ��d����  ��p����   ���y�����p�����h���H��p�����   H���ɳ����h���H��p���H��  H�5�\  H�Ǹ    �ѳ��H��p���H�������   �������`���H������H��p���H��H���n�����d�����d���t?H�5�  H�=LV  �    �R���H�5�  H�=V  �    �:���ǅT��������I  H��p�����   H������H��p���H�a�  H��^  H�5+U  H�Ǹ    ����H��p���H���H����   �5�����`���H��0���H������H��H��������l���ǅX���    ���X�����X���H����p�����0���9�t���X���H����p���������9�tǋ�X���H����p���������9�t���X���H����p�����P�����l���tRH�5�  H�=U  �    ����H�5ѓ  H�=�T  �    ����H�5��  H�=�]  �    ����ǅT���������T��� u�   �   H�=�]  �A�����T�����T��� u%�������������   ��H�=�]  �C�����T�����T��� u��P����   ��H�=�]  �������T�����T��� uZ��h����   ���̰��H�5�  H�=^  �    �4���H��L���H��蕱���   �   H�=�]  ������T����   ��h����	   ���r����vH�5��  H�=�S  �    �د��H�5��  H�=�S  �    �����ǅ\���    �"��\���H����p����	   ��������\�����\���;�d���|�ǅT���������T���H�M�dH3%(   t�P�����UH��H���  H��8�����4���H��(���dH�%(   H�E�1�ǅ\���   H�5�  H�=�[  �    �����   �d���H��p�����   H������H��8���H��p���H�3�  H�5R  H�Ǹ    ����H��p���H���!����   ������\���H������H��p���H��H��������`���ǅP���    ��`���~?H�5+�  H�=XR  �    �^���H�5�  H�=R  �    �F���ǅP���������  ��`����m  ��p����   ��蘮����p�����d���H��p�����   H��������d���H��p���H�<�  H�5�W  H�Ǹ    ����H��p���H���*����   ������\���H������H��p���H��H��������`�����`���t?H�5>�  H�=kQ  �    �q���H�5&�  H�=#Q  �    �Y���ǅP��������  H��p�����   H���&���H��p���H���  H��Y  H�5JP  H�Ǹ    �-���H��p���H���g����   �T�����\���H��0���H������H��H���������h���ǅT���    ���T�����T���H����p�����0���9�t���T���H����p���������9�tǋ�T���H����p���������9�t���h���t:H�5�  H�=JP  �    �P���H�5�  H�=P  �    �8���ǅP���������P��� u�   �   H�=LZ  ������P�����P��� u�   �   H�=wZ  �h�����P�����P��� �  ��d����   ���E���H�5��  H�=Y  �    譫��H��L���H������H��p�����   H���z���H��(���H��p���L�͎  H��H�<Z  H�5=Z  H�Ǹ    �w���H��p���H�������   螬���    ������l���H��p�����   H���
���H��(���H��p���H�5�Y  H�Ǹ    ������l���H��p����   ��H���Z�����P����   ��d����	   ���?����vH�5r�  H�=�N  �    襪��H�5Z�  H�=WN  �    荪��ǅX���    �"��X���H����p����	   ��������X�����X���;�`���|�ǅP���������P���H�M�dH3%(   t������UH����  �P���  9�~��  ����  �H�5��  H�=5Y  �    �����]�UH��H���}��}� ��   H�5��  H�=-Y  �    軩�����  H�H��    H���  ���u2���  Hc�H��    H���  ��JH�H��    H���  ��e�  H�H��    H�4�  �   �    �K����    �����   �.�  H�H��    H���  ���~H�5ˋ  H�=�X  �    ������TH�5��  H�=�X  �    �����޼  Hc�H��    H��  ��JH�H��    H���  ��    谶�����UH��H��@  H������dH�%(   H�E�1�ǅ����   ǅ����   �   �Ʃ��ǅ����    H��p�����   H���8���H������H��p���H���  H�5\K  H�Ǹ    �?���H��p���H���y���������H��0���H������H��H�������������ǅ����   ������;�������   ǅ����   �3������H����0�����������H����0���9�u������������������;�����|���������9�������   H�4�  H�5�  H�=PW  �    �N���H��  H�5��  H�=iW  �    �/���ǅ���������HH��  H�5щ  H�=nW  �    ����H�ˉ  H�5��  H�=W  �    ����ǅ�������������� ��   ������H���  ��H�5��  H�=IW  �    触��H�n�  H�5m�  H�=rW  �    舦���    �ө��H��p���H�>�  H�=�  H�5jW  H�Ǹ    �u���H��p����   �   H������������������ ��   H���  H�5�  H�=LW  �    �
���H�ш  H�5Ј  H�=�V  �    �����    �6���H��p���H���  H���  H�5UW  H�Ǹ    �ئ��H��p����   �   H������������������ uHH��p���H�P�  H�O�  H�5DW  H�Ǹ    臦��H��p����   �   H�������������ǅ����    �"������H���������	   ��补��������������;�����|Ћ�����H�M�dH3%(   t������UH��H��@  H������dH�%(   H�E�1�ǅ����   ǅ����   �   ����ǅ����    H��p�����   H��胥��H������H��p���H�և  H�5�G  H�Ǹ    芥��H��p���H�������������H��0���H������H��H���1���������ǅ����   ������;�������   ǅ����   �3������H����0�����������H����0���9�u������������������;�����|���������9�������   H��  H�5f�  H�=�S  �    虣��H�`�  H�5G�  H�=�S  �    �z���ǅ���������HH�5�  H�5�  H�=�S  �    �O���H��  H�5��  H�=jS  �    �0���ǅ�������������� ��   ������H�څ  ��H�5ׅ  H�=U  �    ����H���  H�5��  H�=�S  �    �Ӣ���    ����H��p���H���  H���  H�5U  H�Ǹ    �����H��p����   �   H������������������ ��   ������H�5�  ��H�52�  H�=�T  �    �M���H��  H�5�  H�=S  �    �.����    �y���H��p���H��  H��  H�5�T  H�Ǹ    ����H��p����   �   H���`��������������� ��   H���  H�5��  H�=�T  �    谡��H�w�  H�5v�  H�={R  �    葡���    �ܤ��H��p���H�G�  H�F�  H�5�T  H�Ǹ    �~���H��p����   �   H������������������� uHH��p���H���  H���  H�5�T  H�Ǹ    �-���H��p����   �   H���r���������ǅ����    �"������H���������	   ���G���������������;�����|Ћ�����H�M�dH3%(   t舠����UH��H���  H��H���dH�%(   H�E�1�ǅd���   ǅh���   �   跡��ǅX���    H�������   H���)���H��H���H������H�|�  H�5MC  H�Ǹ    �0���H������H���j�����d���H������H��p���H��H���������l���ǅT���   ��l���;�h�����   ǅ\���   �3��\���H����������\�����H��������9�u��T�����\�����\���;�l���|���h�����9�T�����   H�%�  H�5�  H�=AO  �    �?���H��  H�5�  H�=ZO  �    � ���ǅX��������HH�ہ  H�5  H�=_O  �    �����H���  H�5��  H�=O  �    �֞��ǅX���������X��� ��   H���  H�5��  H�=�R  �    蠞��H�g�  H�5f�  H�=kO  �    聞���    �̡��H������H�7�  H�6�  H�5�R  H�Ǹ    �n���H�������   �   H��������X�����X��� ��   H��  H�5�  H�=S  �    ����H�ʀ  H�5ɀ  H�=�N  �    �����    �/���H������H���  H���  H�5�Q  H�Ǹ    �ў��H�������   �   H��������X�����X��� ��   H�L�  H�5K�  H�=�R  �    �f���H�-�  H�5,�  H�=1N  �    �G����    蒠��H������H��  H��  H�5YQ  H�Ǹ    �4���H�������   �   H���y�����X�����X��� ��   H��  H�5�  H�=sR  �    �ɜ��H��  H�5�  H�=�M  �    誜���    �����H������H�`  H�_  H�5�P  H�Ǹ    藝��H�������   �   H���������X���ǅ`���    �"��`���H����p����	   ��豜����`�����`���;�l���|Ћ�X���H�M�dH3%(   t������UH��H��  H��X���dH�%(   H�E�1�ǅh���   �   �+���ǅ`���    ǅ`���    H�������   H��蓜��H��X���H������H��~  H�5�>  H�Ǹ    蚜��H������H���Կ����h���H������H��p���H��H���A�����l�����l��� uTH��X���H��}  H��H�5�}  H�=Q  �    ����H��}  H�5�}  H�=/K  �    �����ǅ`��������[��l���~RH��X���H��}  H��H�5�}  H�=�P  �    跚��H�~}  H�5e}  H�=�P  �    蘚��ǅ`���������`��� ��   H�H}  H�5G}  H�=TN  �    �b���H�)}  H�5(}  H�=-K  �    �C����    莝��H������H��|  H��|  H�5UN  H�Ǹ    �0���H�������   �   H���u�����`�����`��� ��   H��|  H�5�|  H�=�N  �    �ř��H��|  H�5�|  H�=�J  �    覙���    ����H������H�\|  H�[|  H�5�M  H�Ǹ    蓚��H�������   �   H���ؾ����`�����`��� ��   H�|  H�5|  H�=�N  �    �(���H��{  H�5�{  H�=�I  �    �	����    �T���H������H��{  H��{  H�5M  H�Ǹ    �����H�������   �   H���;�����`�����`��� ��   H�q{  H�5p{  H�=5N  �    苘��H�R{  H�5Q{  H�=VI  �    �l����    跛��H������H�"{  H�!{  H�5~L  H�Ǹ    �Y���H�������   �   H��螽����`���ǅd���    �"��d���H����p����	   ���s�����d�����d���;�l���|Ћ�`���H�M�dH3%(   t贗����UH��H���  H��H���dH�%(   H�E�1�ǅd���   ǅh���   �   ����ǅX���    H�������   H���U���H��H���H������H��z  H�5y:  H�Ǹ    �\���H������H��薻����d���H������H��p���H��H��������l���ǅT���   ��l���;�h�����   ǅ\���   �3��\���H����������\�����H��������9�u��T�����\�����\���;�l���|���h�����9�T�����   H�Qy  H�58y  H�=mF  �    �k���H�2y  H�5y  H�=�F  �    �L���ǅX��������HH�y  H�5�x  H�=�F  �    �!���H��x  H�5�x  H�=<F  �    ����ǅX��������   �N�����X��� uKH������H��x  H��x  H�5AL  H�Ǹ    �ܖ����t���H�������   ��H��������X�����X��� uHH������H�Qx  H�Px  H�55L  H�Ǹ    舖��H�������   �   H���ͺ����X�����X��� ��   H�x  H�5x  H�=_L  �    ����H��w  H�5�w  H�=�E  �    ������    �I���H������H��w  H��w  H�5`L  H�Ǹ    ����H�������   �   H���0�����X�����X��� uHH������H�cw  H�bw  H�5�L  H�Ǹ    蚕��H�������   �   H���߹����X�����X��� ��   H�w  H�5w  H�=�L  �    �/���H��v  H�5�v  H�=�D  �    �����    �[���H������H��v  H��v  H�5�L  H�Ǹ    �����H�������   �	   H���B�����X���ǅ`���    �"��`���H����p����	   ��������`�����`���;�l���|Ћ�X���H�M�dH3%(   t�X�����UH��H���  H��H���dH�%(   H�E�1�ǅd���   ǅh���   �   臔��ǅX���    H�������   H�������H��H���H������H�Lv  H�56  H�Ǹ    � ���H������H���:�����d���H������H��p���H��H��觻����l���ǅT���   ��l���;�h�����   ǅ\���   �3��\���H����������\�����H��������9�u��T�����\�����\���;�l���|���h�����9�T�����   H��t  H�5�t  H�=B  �    ����H��t  H�5�t  H�=*B  �    ����ǅX��������HH��t  H�5�t  H�=/B  �    �ő��H��t  H�5st  H�=�A  �    覑��ǅX���������X��� uqH�Zt  H�5Yt  H�=^J  �    �t����   �ʒ��H������H�*t  H�)t  H�5VJ  H�Ǹ    �a���H�������   �   H��覶����X�����X��� uHH������H��s  H��s  H�5EJ  H�Ǹ    ����H�������   �   H���U�����X�����X��� uHH������H��s  H��s  H�5DJ  H�Ǹ    近��H�������   �   H��������X�����X��� uHH������H�7s  H�6s  H�5�J  H�Ǹ    �n���H�������   �   H��賵����X�����X��� uHH������H��r  H��r  H�5�J  H�Ǹ    ����H�������   �   H���b�����X���ǅ`���    �"��`���H����p����	   ���7�����`�����`���;�l���|Ћ�X���H�M�dH3%(   t�x�����UH��H���  H��H���dH�%(   H�E�1�ǅd���   ǅh���   �   觐��ǅX���    H�������   H������H��H���H������H�lr  H�5=2  H�Ǹ    � ���H������H���Z�����d���H������H��p���H��H���Ƿ����l���ǅT���   ��l���;�h�����   ǅ\���   �3��\���H����������\�����H��������9�u��T�����\�����\���;�l���|���h�����9�T�����   H�q  H�5�p  H�=1>  �    �/���H��p  H�5�p  H�=J>  �    ����ǅX��������HH��p  H�5�p  H�=O>  �    ����H��p  H�5�p  H�= >  �    �ƍ��ǅX���������X��� uqH�zp  H�5yp  H�=�I  �    蔍���   ����H������H�Jp  H�Ip  H�5vF  H�Ǹ    聎��H�������   �   H���Ʋ����X�����X��� uHH������H��o  H��o  H�5eF  H�Ǹ    �0���H�������   �   H���u�����X�����X��� uHH������H��o  H��o  H�5�H  H�Ǹ    �ߍ��H�������   �   H���$�����X�����X��� ��   H�Zo  H�5Yo  H�=�H  �    �t���H�;o  H�5:o  H�=I  �    �U����    蠏��H�o  H�5o  H�=&I  �    �,���H��n  H�5�n  H�=�H  �    �����    �X���ǅ`���    �"��`���H����p����	   ���\�����`�����`���;�l���|Ћ�X���H�M�dH3%(   t蝋����UH��H���  H��H���dH�%(   H�E�1�ǅd���   ǅh���   �   �̌��ǅX���    H�������   H���>���H��H���H������H��n  H�5b.  H�Ǹ    �E���H������H��������d���H������H��p���H��H��������l���ǅT���   ��l���;�h���t��h�����9�l���uOǅ\���   �3��\���H����������\�����H��������9�u��T�����\�����\���;�l���|��HH�@m  H�5'm  H�=�:  �    �Z���H�!m  H�5m  H�=u:  �    �;���ǅX���������X��� ��   H��l  H�5�l  H�=OG  �    �����   �[���H��l  H�5�l  H�=�G  �    �܉��H������H��l  H��l  H�5�G  H�Ǹ    �ӊ��H�������   �   H��詯����X�����X��� uHH������H�Kl  H�Jl  H�5�G  H�Ǹ    肊��H�������   �   H���Ǯ����X�����X��� uHH������H��k  H��k  H�5�G  H�Ǹ    �1���H�������   �   H���v�����X���ǅ`���    �"��`���H����p����	   ���K�����`�����`���;�l���|Ћ�X���H�M�dH3%(   t茈����UH��H���  H��H���dH�%(   H�E�1�ǅd���   ǅh���   �   軉��ǅX���    H�������   H���-���H��H���H������H��k  H�5Q+  H�Ǹ    �4���H������H���n�����d���H������H��p���H��H���۰����l���ǅT���   ��l���;�h���t��h�����9�l���uOǅ\���   �3��\���H����������\�����H��������9�u��T�����\�����\���;�l���|��HH�/j  H�5j  H�=�7  �    �I���H�j  H�5�i  H�=d7  �    �*���ǅX���������X��� ��   H��i  H�5�i  H�=>D  �    �����   �J���H��i  H�5�i  H�=}D  �    �ˆ��H������H��i  H��i  H�5�D  H�Ǹ    ���H�������   �   H��蘬����X�����X��� uHH������H�:i  H�9i  H�5�D  H�Ǹ    �q���H�������   �   H��趫����X�����X��� uHH������H��h  H��h  H�5ME  H�Ǹ    � ���H�������   �
   H���������X���ǅ`���    �"��`���H����p����	   ���:�����`�����`���;�l���|Ћ�X���H�M�dH3%(   t�{�����UH��H���  H��H���dH�%(   H�E�1�ǅd���   ǅh���   �   誆��ǅX���    H�������   H������H��H���H������H�oh  H�5@(  H�Ǹ    �#���H������H���]�����d���H������H��p���H��H���ʭ����l���ǅT���   ��l���;�h���t��h�����9�l���uOǅ\���   �3��\���H����������\�����H��������9�u��T�����\�����\���;�l���|��HH�g  H�5g  H�=�4  �    �8���H��f  H�5�f  H�=S4  �    ����ǅX���������X��� uR�   �\���H������H��f  H��f  H�5�C  H�Ǹ    ����H�������   �   H���8�����X�����X��� uHH������H�kf  H�jf  H�5'D  H�Ǹ    袄��H�������   �   H��������X�����X��� uHH������H�f  H�f  H�5E  H�Ǹ    �Q���H�������   �   H��薨����X���ǅ`���    �"��`���H����p����	   ���k�����`�����`���;�l���|Ћ�X���H�M�dH3%(   t謂����UH��H���  H��H���dH�%(   H�E�1�ǅd���   ǅh���   �   �ۃ��ǅX���    H�������   H���M���H��H���H������H��e  H�5q%  H�Ǹ    �T���H������H��莦����d���H������H��p���H��H���������l���ǅT���   ��l���;�h���t��h�����9�l���uOǅ\���   �3��\���H����������\�����H��������9�u��T�����\�����\���;�l���|��HH�Od  H�56d  H�=�1  �    �i���H�0d  H�5d  H�=�1  �    �J���ǅX���������X��� uR�	   荂��H������H��c  H��c  H�5yC  H�Ǹ    �$���H�������   �   H���i�����X�����X��� uHH������H��c  H��c  H�5`C  H�Ǹ    �Ӂ��H�������   �   H��������X�����X��� uHH������H�Kc  H�Jc  H�5�C  H�Ǹ    肁��H�������   �   H���ǥ����X�����X��� uHH������H��b  H��b  H�5�C  H�Ǹ    �1���H�������   �   H���v�����X���ǅ`���    �"��`���H����p����	   ���K�����`�����`���;�l���|Ћ�X���H�M�dH3%(   t�����UH��H���  H��H���dH�%(   H�E�1�ǅd���   ǅh���   �   軀��ǅX���    H�������   H���-���H��H���H������H��b  H�5Q"  H�Ǹ    �4���H������H���n�����d���H������H��p���H��H���ۧ����l���ǅT���   ��l���;�h���t��h�����9�l���uOǅ\���   �3��\���H����������\�����H��������9�u��T�����\�����\���;�l���|��HH�/a  H�5a  H�=�.  �    �I~��H�a  H�5�`  H�=d.  �    �*~��ǅX���������X��� uR�$   �m��H������H��`  H��`  H�5�A  H�Ǹ    ���H�������   �   H���I�����X�����X��� uHH������H�|`  H�{`  H�5�A  H�Ǹ    �~��H�������   �   H���������X�����X��� uHH������H�+`  H�*`  H�5�A  H�Ǹ    �b~��H�������   �   H��觢����X���ǅ`���    �"��`���H����p����	   ���|}����`�����`���;�l���|Ћ�X���H�M�dH3%(   t�|����UH��H���  H��H���dH�%(   H�E�1�ǅd���   ǅh���   �   ��}��ǅX���    H�������   H���^}��H��H���H������H��_  H�5�  H�Ǹ    �e}��H������H��蟠����d���H������H��p���H��H��������l���ǅT���   ��l���;�h���t��h�����9�l���uOǅ\���   �3��\���H����������\�����H��������9�u��T�����\�����\���;�l���|��HH�`^  H�5G^  H�=�+  �    �z{��H�A^  H�5(^  H�=�+  �    �[{��ǅX���������X��� uR�   �|��H������H��]  H��]  H�5�@  H�Ǹ    �5|��H�������   �   H���z�����X�����X��� ugH��]  H�5�]  H�=p@  �    ��z��H������H��]  H��]  H�5�@  H�Ǹ    ��{��H�������   �   H���
�����X�����X��� uHH������H�=]  H�<]  H�5�@  H�Ǹ    �t{��H�������   �   H��蹟����X���ǅ`���    �"��`���H����p����	   ���z����`�����`���;�l���|Ћ�X���H�M�dH3%(   t��y����UH��H���  H��H���dH�%(   H�E�1�ǅd���   ǅh���   �   ��z��ǅX���    H�������   H���pz��H��H���H������H��\  H�5�  H�Ǹ    �wz��H������H��豝����d���H������H��p���H��H��������l���ǅT���   ��l���;�h���t��h�����9�l���uOǅ\���   �3��\���H����������\�����H��������9�u��T�����\�����\���;�l���|��HH�r[  H�5Y[  H�=�(  �    �x��H�S[  H�5:[  H�=�(  �    �mx��ǅX���������X��� uR�   �y��H������H�[  H�[  H�5�=  H�Ǹ    �Gy��H�������   �   H��茝����X�����X��� ugH��Z  H�5�Z  H�=�>  �    ��w��H������H��Z  H��Z  H�5D?  H�Ǹ    ��x��H�������   �   H��������X�����X��� uHH������H�OZ  H�NZ  H�5K?  H�Ǹ    �x��H�������   �   H���˜����X�����X��� uHH������H��Y  H��Y  H�52?  H�Ǹ    �5x��H�������   �   H���z�����X�����X��� uHH������H��Y  H��Y  H�5!?  H�Ǹ    ��w��H�������   �   H���)�����X�����X��� uHH������H�\Y  H�[Y  H�5?  H�Ǹ    �w��H�������   �   H���؛����X�����X��� uHH�Y  H�5Y  H�=?  �    �,v���    �Ry��H��X  H�5�X  H�==?  �    �v��ǅ`���    �"��`���H����p����	   ���\v����`�����`���;�l���|Ћ�X���H�M�dH3%(   t�u����UH��H���  H��H���dH�%(   H�E�1�ǅd���   ǅh���   �   ��v��ǅX���    H�������   H���>v��H��H���H������H��X  H�5b  H�Ǹ    �Ev��H������H��������d���H������H��p���H��H��������l���ǅT���   ��l���;�h���t��h�����9�l���uOǅ\���   �3��\���H����������\�����H��������9�u��T�����\�����\���;�l���|��HH�@W  H�5'W  H�=�$  �    �Zt��H�!W  H�5W  H�=u$  �    �;t��ǅX���������X��� uR�   �~u��H������H��V  H��V  H�5�=  H�Ǹ    �u��H�������   �   H���Z�����X�����X��� ugH��V  H�5�V  H�=P9  �    �s��H������H�nV  H�mV  H�5b=  H�Ǹ    �t��H�������   �   H��������X�����X��� uHH������H�V  H�V  H�5i=  H�Ǹ    �Tt��H�������   �   H��虘����X�����X��� uHH������H��U  H��U  H�5h=  H�Ǹ    �t��H�������   �   H���H�����X�����X��� uHH������H�{U  H�zU  H�5�=  H�Ǹ    �s��H�������   �   H���������X�����X��� ugH������H�*U  H�)U  H�5�=  H�Ǹ    �as��H�������   �   H��覗����X���H��T  H�5�T  H�=�=  �    �r��ǅ`���    �"��`���H����p����	   ���\r����`�����`���;�l���|Ћ�X���H�M�dH3%(   t�q����UH��H��0H�}�u�H�U؋��  ��uH�E�H���Ğ���E��E��������&  �j�  ��uH�E�H�������E��E����d�����  �A�  ��uH�E�H���ɧ���E��E����;�����  ��  ��u'H�U؋M�H�E��H��������E��E����	����  ��  ��u'H�U؋M�H�E��H���Ū���E��E���������p  ���  ��u'H�U؋M�H�E��H�������E��E��������>  ���  ��u'H�U؋M�H�E��H���#����E��E����s����  �P�  ��u'H�U؋M�H�E��H��螹���E��E����A�����  ��  ��u'H�U؋M�H�E��H���Ż���E��E��������  ��  ��	u'H�U؋M�H�E��H���t����E��E���������v  ���  ��
uH�E�H�������E��E��������M  ���  ��uH�E�H�������E��E��������$  �h�  ��uH�E�H��������E��E����b�����  �?�  ��uH�E�H���.����E��E����9�����  ��  ��uH�E�H���C����E��E��������  ��  ��uH�E�H���v����E��E���������  �Ă  ��uH�E�H���-����E��E��������W  ���  ��uH�E�H��������E��E��������.  �r�  ��uH�E�H��������E��E����l����  �I�  ��uH�E�H�������E��E����C�����   � �  ��uH�E�H���U����E��E��������   ���  ��uH�E�H���L����E��E���������   �΁  ��uH�E�H��������E��E���������d���  ��uH�E�H�������E��E��������>���  ��uH�E�H��������E��E����|����H�5P  H�=c9  �    �Jm����  �	   ���m��H�=P  ��l�����UH��H��0H�}�H�u�H�U�H�M��E�   �E�    �E�    ��E�H�E�� 9E�}�E�Hc�H�E�H�� <>u�H�E�� 9E�|kH�E��     ���  ��t���  ��t���  ��	��  H�5RO  H�=�8  �    �l��H�5:O  H�=�8  �    �ml���E������  H�E��    �E�H�H�PH�E�H�� < u�E�H�E�� +E�9E�|<�E�����H�5�N  H�=�8  �    �l��H�5�N  H�=k8  �    ��k���)  �E�H�H�PH�E�H�� < t_H�E�� ���E��'�E�Hc�H�E�HЋU�Hc�H�JH�U�H�� ��m��E�;E�ыE�H�H�PH�E�H��  H�E�� �PH�E���E����E��*�E�Hc�H�E�H��E�+E�H�H�P�H�E�H����E�H�E�� 9E�|ˋE�H�H�P�H�E�H�� < t\H�E�� ���E��'�E�Hc�H�E�HЋU�Hc�H�JH�U�H�� ��m��E�;E�}ыE�Hc�H�E�H��  H�E�� �PH�E���E���UH��H�ĀH�}��u��U�H�M�dH�%(   H�E�1�H�U�H�E�H�5�
  H�Ǹ    �3k��H�E�H��觕��H�5�	  H�=�M  �Dk��H�E�H�}� uH�5�M  H�=�  �    �Aj����   �E�Hc�H�M�H�E��   H���ak��H�E�H����i���k���E��}� ugH�=�L  �i���    �   �Lj���    �   �=j���    �   �.j���    H�
M  H�5*	  H�=#	  �    ��j���   ��j���E��[�  H�=dL  �+i��H�U��M�H�E���H�������H�E�H����j���H�E�dH3%(   t�Ei����UH��H��pH�}��u�dH�%(   H�E�1���     �E�����  �E����/  H�E�� �����8m���E���K  8E�u�    ��v���    �j����K  8E�u�    �߃���  ��K  8E�uC��|  ��~��|  ����|  �    �v���Y  H�=R5  �%h���[�      �>  �oK  8E�uj�$�  �P��[|  9�~)�Q|  ���F|  ���=|  �    �;v����   H��J  H�5�J  H�=5  �    �h����      ��   H�=15  �g���ʧ      �   H�E�� <.uH�E�H��� </t!H��J  H�5yJ  H�=5  �    �g���q�E���!H�oJ  H�5PJ  H�=�4  �    �g���IH�E��@   H���`h��H�M�H�U�H�u�H�E�H���/����E��}� u�U��u�H�M�H�E�H���u�����H�E�dH3%(   t�g����UH��H���   ��L���H��@���dH�%(   H�E�1��   �   �Kg���   �   �<g�����      H��`����   H���g��H��@���H�H��`���H��H���2f��H��`���H���:m����T�����T�����  H�5=i���   ��f���@   H�=#b  �Ng����L���~@H��@���H��H� H�5�3  H���xf����uH��@���H��H� H��H�=�a  �e����@   H�=�a  ��f����T�����T��� uH�=�a  ��e��H��wM�@   H�=�a  �+j����T�����T��� t-H��@���H���T�����H�=Z3  �    �e���   ��f����   H�=ʜ  �uf�����  /homf���  e/���   H�5lH  H�=��  �hf��H�5iH  H�=��  �Uf��H�5fH  H�=w�  �Bf��H�5cH  H�=d�  �/f��H��p�����   H����e��H��p���H�5=�  H���d��H��p���H������H�¸    H���H��H��H�P�H��p���H�H�presentaH�tion.txtH�H�H�@ H��p���A�   H�;H  ��   H�5�  H����w����T�����T��� tH�=@2  �d���  H��p�����   H���;e��H��p���H�5}�  H����c��H��p���H������H�¸    H���H��H��H�P�H��p���H�H�menu.txtH��@ H��p���A�   H�a�  ��   H�5�G  H���Dw����T�����T��� tH�=�1  �Rc���   ��d����  �A   H�=�1  �    �]d����  �    �x����T�����T��� t
�   �d���    �Jl����T��� t
�   �wd��H��X���H����c��H��^  H�5�E  H�=71  �    �c���    �$~���   �%c����   H�=�E  �b���    ��y����   H�=�  ��c��H�bF  H�¾�   H�=�  ��b��H����   �ϙ      H�=�  �b����P�����P��� ~L��P�����Hc�H�]  �<
u��P�����P���Hc�H�>  � ��P�����H�=+  ������.H�=e0  ��a����      �H�=d0  ��a�����      �4�  =�  ����H�=V0  �a���H��@���H� H��H�=s0  �    ��a���    H�M�dH3%(   t�a����f.�     @ AWAVI��AUATL�%�@  UH�-�@  SA��I��L)�H��H����`��H��t 1��     L��L��D��A��H��H9�u�H��[]A\A]A^A_Ðf.�     ��  H��H���         
--- Retour au menu     %s---- Arret de sécurité : relancer l'application%s
 %s%s %i  %s   --- Erreur : Il faut entrer un entier
 wb echo $USER > %s sh rb    ps -fu | grep -v grep | grep %s | wc -l > %s r %d       
--- Erreur de sauvegarde des résultats. Vous pouvez poursuivre, mais  --- vos ésultats ne seront pas sauvegardés. Tapez v ou V pour poursuivre :  %s        --- Erreur d'accès aux ressources distantes %d
 %s %s %s%s%s %s %d  - %s  - %s
 %s %s
 %s %s %s %s
 >>> Entrez votre commande :  
%sStructures de contrôle
 %s       [0m
=== Entrez un caractère pour afficher le menu :   
%sPrésentation de l'outil d'apprentissage système :
%s
      --- Erreur : Fichier script %s
 cmd=%s
 ficerr=%s_%s.err
 $dcmd %s $1 $2 2> $1/$ficerr
 Erreur fork     
=== Nouveau score de l'étape : %d 
   --- Erreur ouverture fichier résultats %s
     --- Je ne peux pas calculer le nouveau score    
--- Erreur script de validation %d
    --- Erreur : je n'arrive pas à ouvrir %s
      %s   === Réponse fausse : encore %d essai(s)
 
%s%s    %s--- Erreur d'ouverture du fichier résultats
 %d %d %d %d     ps l | grep -v grep | grep %s > %s      
%s--- Processus de meme nom trouves et tues%s
 
%s=== Je ne trouve pas le bon nombre de freres
        %s??? Avez-vous lance le bon executable ???
    
%s=== Je ne trouve pas le bon nombre de processus 
    <<< Entrer le nombre total de processus :       <<< Entrer le pid du processus pere :   
%s=== Je ne trouve pas le bon nombre de fils 
 
%s=== Je ne trouve pas le bon nombre de petits-fils 
  
%s=== La eépartition des petits-fils n'est pas correcte
      
%s=== Construire l'arborescence des processus 
        <<< Entrer le nombre de fils du processus principal :   <<< Entrer le nombre de petits-fils :   <<< Entrer le nombre d'arrieres petits-fils :   <<< Entrer le pid du fils qui n'a pas de fils :         <<< Entrer le pid de l'arriere petit fils :     
%s=== Je ne trouve pas le bon nombre de freres 
       
<<< Quel est le montant herite par chaque fils ?       
<<< Quel est le patrimoine le moins eleve parmi les fils ?     
<<< Quel est le patrimoine le plus eleve parmi les fils ?      
<<< Quel patrimoine total des 4 fils voit le pere ?  
%s=== Patientez 4 secondes
 grep '%s' %s |wc -l > %s     <<< Quel est le nombre de lignes commencant par '%s' dans le fichier %s :       <<< Combien de ces lignes doivent-elles etre reellement affichees ? ?   <<< Combien de ces lignes doivent-elles etre reellement affichees ?     %s=== Executer la commande 'ps l' dans un autre terminal
       %s    et noter le pid du père de chaque processus %s
  <<< Quel est le pid du pere des 3 fils de nom %s :  %s
 Pere de pid %d est tue%s
       %s=== Je ne trouve pas des fils orphelins 
     %s    et noter le pid du pere de chaque processus de nom %s
    <<< Entrer le pid du pere des processus de nom %s :     ps l | grep -v grep | grep %d > %s      %s    et noter l'etat du processus pere et de ses fils (colonne STAT)
  <<< Entrez la premiere lettre de l'etat du père :      <<< Entrez la premiere lettre de l'etat du fils %d :  %s
 Fils de pid %d est tue%s
     
%s=== Executer la commande 'ps l' dans un autre terminal
      %s    et noter l'etat des processus fils (colonne STAT)
        <<< Quel est le PID du fils qui n'est pas zombie ?      
%s=== Executer la commande 'kill -KILL %d' dans un autre terminal
     %s<<< puis Taper Return ICI et observer ce qui se passe%s
      <<< Quelle est la valeur de terminaison du fils 1       <<< Quel est le numero du signal qui a tue le fils 2  
%s... Patientez ...
 dodo        %s??? Avez-vous bien compilé le programme dormir ???
  <<< Combien de processus fils ont reussi à s'endormir ?        <<< Quel est le pid du premier d'entre eux ?    <<< Quel est le pid du fils qui n'a pas reussi à s'endormir ?  %s... Patientez ...
    <<< Quelle est la valeur de terminaison du fils qui n'a pas reussi à s'endormir ?      <<< Ou est affiche le message produit par 'perror' (1 : fichier, 2 terminal) ?  <<< Sur quel descripteur 'perror' ecrit-il (1 : stdout ou 2 : stderr) ?  "[a-z]" grep %s %s | wc -l > %s        <<< Quel est le nombre de messages inscrits dans le fichier %s ? :      
%s=== Derniere etape pour l'instant
   
%s>>> Bravo : Exercice validé.
       
%s>>> Tentative avortee, mais exercice deja valide
    
%s>>> Exercice non validé. Recommencez. 
     
%s=== Je ne trouve pas le bon nombre de freres%s
      %s??? Avez-vous lance le bon executable ???%s
  
%s=== Je ne trouve pas le bon nombre de processus %s
  
%s=== Dans un autre terminal, exécutez la commande "kill -INT %d"%s
  
%s=== Puis, tapez <return> ICI%s
      %s<<< Entrer le numéro du signal INT : %s      
%s=== Dans ce terminal (ICI), tapez en même temps les touches 'ctrl' et 'c'%s
        %s<<< Entrer le numéro du signal provoqué par 'ctrl'+'c' :%s  %s<<< Entrer le nombre de processus ayant reçu le signal SIGINT : %s   
%s=== Dans un autre terminal, exécutez la commande "kill -TSTP %d"%s
 %s<<< Entrer le numéro du signal TSTP : %s     
%s=== Dans un autre terminal, exécutez la commande "kill -CONT %d"%s
 %s<<< Entrer le numéro du signal CONT : %s     
%s=== Dans ce terminal (ICI), tapez en même temps les touches 'ctrl' et 'z'%s
        %s<<< Entrer le numéro du signal provoqué par 'ctrl'+'z' : %s %s<<< Entrer le nombre de processus ayant reçu le signal SIGTSTP : %s  
%s=== Dans un autre terminal, exécutez la commande "kill -INT pid_fils_1"%s
  %s<<< Que s'est-il passé ? :
    - le processus a été tué : tapez 1
    - le processus a affiché le signal reçu : tapez 2
    - le signal n'a eu aucun effet sur le processus : tapez 3 : %s      
%s=== Dans un autre terminal, exécutez la commande "kill -INT pid_fils_2"%s
  
%s=== Dans un autre terminal, exécutez la commande "kill -INT pid_fils_3"%s
  
%s=== Dans un autre terminal, exécutez la commande "kill -INT pid_pere"%s
    
%s=== Je ne trouve pas le processus %s%s
      
%s=== Il y a plus de 1 processus %s%s
 
%s=== Il faut les tuer et recommencer%s
       %s<<< Quel est le pid du processus qui vient de se terminer ? : %s      %s<<< Comment s'est-il terminé ? :
    - normalement avec exit : tapez 1
    - tué par un signal : tapez 2 : %s       
%s=== Dans un autre terminal, exécutez la commande "kill -QUIT pid_fils_2"%s
 %s<<< Comment s'est terminé le fils numéro 2 ? :
    - normalement avec exit : tapez 1
    - tué par un signal : tapez 2 : %s        %s<<< Quel est le numéro du signal qui a tué le fils numéro 2 ? : %s 
%s=== Dans un autre terminal, exécutez la commande "kill -KILL pid_fils_3"%s
 %s<<< Quel est le numéro du signal SIGKILL ? : %s      
%s=== Patientez qielques secondes%s 
  %s<<< Combien de processus fils se sont-ils arrêtés ? : %s    %s<<< De combien de fils terminés le père a-t-il pris connaissance ? : %s     %s<<< Quel est l'état du processus non traité par le wait ? : 
    - actif : tapez 1
    - zombie : tapez 2
    - orphelin : tapez 3 : %s     %s<<< Le processus père reste bloqué: 
    - dans la primitive wait : tapez 1
    - parce qu'un signal SIGCHLD a été perdu : tapez 2 : %s   %s<<< Pour quelle raison un signal SIGCHLD a-t-il été perdu ? : 
    - à cause d'une erreur système : tapez 1
    - car il n'a pas été émis : tapez 2
    - car une seule case par signal est prévue pour mémoriser le signal en attente, et si un second signal est émis il est ignoré  : tapez 3 : %s      
%s=== Patientez quelques secondes%s 
  %s<<< Combien de signaux SIGCHLD le père a-t-il reçu ? : %s   
%s=== Dans un autre terminal, exécutez la commande "kill -TSTP pid_fils_4"%s
 
%s=== Puis, observez ce qu'il se passe ici et tapez <return>%s
        
%s=== Dans un autre terminal, exécutez la commande "kill -CONT pid_fils_4"%s
 
%s=== Notez le délai entre l'instant d'arrêt du fils 1 et sa prise en compte par le père%s 
        
%s=== Si vous n'avez pas eu le temps, répondez 0 et recommencez%s
    %s<<< Quel est le délai entre l'instant d'arrêt du fils 1 et sa prise en compte par le père ? : %s   %s<<< D'après le code, quel est le délai entre l'arrêt du fils 1 et celui du fils 3 ? : %s   %s<<< A l'exécution, ce délai est-il respecté lors de la prise en compte par le père de ces deux arrêts ? (oui : 1, non : 2) : %s  %s<<< Quelle est la durée durant laquelle le père est resté protégé du signal SIGCHLD : %s %s<<< Dans quel ordre les 3 fils lisent-ils le fichier :
    - fils1, fils2, fils3, fils1, fils2, fils3, ... : tapez 1
    - fils3, fils2, fils1, fils3, fils2, fils1, ... : tapez 2
    - fils1, fils3, fils2, fils1, fils3, fils2, ... : tapez 3 : %s %s<<< Pourquoi chaque valeur n'est lue ou affichée que par un seul fils :
    - parce que la valeur est supprimée dès qu'elle est lue : tapez 1
    - parce qu'on n'affiche pas toutes les valeurs lues : tapez 2
    - parce que la tête de lecture avance automatiquement à chaque lecture : tapez 3 : %s        %s<<< Les trois fils utilisent-ils :
    - une tête de lecture unique (partagée)  : tapez 1
    - une tête de lecture individuelle : tapez 2 : %s    %s<<< Combien de valeurs n'ont pas été lues ? : %s    %s=== Il faut lire le code C pour répondre aux questions suivantes; 
<<< Quel fils est responsable de la non lecture de la valeur 100 ? : %s   %s<<< Quel fils est responsable de la non lecture de la valeur 104 ? : %s       %s<<< Quel fils est responsable de la non lecture de la valeur 108 ? : %s       %s<<< Combien de valeurs à lu chaque fils : %s %s<<< Au total, combien de têtes de lecture ont été utilisées pour réaliser ces lectures ? : %s    %s<<< Que se passerait-il, si le fils 3 déplaçait sa tête de lecture de +4 avant d'effectuer sa première lecture :
    - il ne lirait pas la première valeur : tapez 1 : 
    - tous les fils ne liraient pas la première valeur : tapez 2 : %s   %s<<< Combien de mots à écrit chaque fils ? : %s      %s=== Dans un autre terminal, afficher le contenu du fichier rempli par les fils%s
     %s<<< Au total, combien de mots ont été écrits dans le fichier ? : %s        %s<<< Au total, combien de têtes d'écriture ont été utilisées pour ce fichier ? : %s       %s=== Dans un autre terminal, afficher le contenu hexadécimal du fichier résultat avec la commande hd
    - 31 est le code de '1', 33 le code de '3', 
    - 2d est le code du '-', 0a est le code de passage à la ligne%s   
%s<<< Parmi les mots écrits par les fils, combien se trouvent dans le fichier ? : %s  %s<<< A quel fils appartient les mots disparus ? : %s   %s<<< Quel fils est responsable de ces disparitions ? : %s      %s<<< Combien d'octets contenant 0 sont apparus dans le fichier ? : %s  %s<<< Quel fils est responsable de ces ajouts ? : %s    %s<<< Pourtant le fils 1 a réalisé 4 lseek de +4 ! : tapez return pour l'explication%s        
%s=== Le dernier lseek n'est suivi d'aucune écriture, et est donc sans effet.%s       %s<<< Quel est le nombre total de mots à écrits par les 3 fils ? : %s 
%s<<< Parmi les mots écrits par les fils, combien se trouvent dans ce fichier ? : %s  %s<<< A quel fils appartiennet les mots présents dans le fichier ? : %s        %s<<< Si la tête d'écriture est à l'index 1 lorsqu'on ouvre le fichier,
    à quel index le fils3 écrit son premeir mot ? : %s     %s<<< A quel index se trouve la tête du fils2 lorsqu'il écrit son premier mot ? : %s  %s<<< A quel index se trouve la tête du fils1 lorsqu'il écrit son premier mot ? : %s  
%s=== J'espère que vous avez compris pourquoi les mots du fils3 et du fils2 sont écrasés%s %s>>>Etape non implantée.
      
%s=== Je ne trouve pas de caractere de redirection '>' 
 %s=== Recommencez.
   
%s=== Redirection trouvée : nom de fichier doit >= 4 caracteres
      --- Vous ne pouvez pas aller plus bas que l'étape 1    
%s--- Il n'y a pas d'étape suivante pour l'instant%s
 
--- Commande inconnue! 
%s--- Il faut que l'exécutable commence par ./ suivis par au moins deux caractères%s
 -u     %d UTILISEZ LA COMMANDE : %s -u $USER
 
 Présentation inacessible  
 Menu inacessible  .messcaches %sBonjour %s, [0m
 ---- Commande inconnue ---- Echec de la lecture ---- Arret de sécurité : relancer l'application       
Une autre exécution de %s est en cours. Il faut l'arrêter.
  ;  ?   �0��P  �2��x  �2��   �3���  �3���  `4���  �4���  �4��  e5��0  �5��P  �7��p   :���  8?���  �D���  oF���  6H��  @J��4  EL��T  �L��t  fQ���  �U���  �V���  ?W���  �W��  zX��4  NY��T  %Z��t  }[���  `\���  w]���  r^���  �`��  �g��4  )k��T  ~o��t  �t���  �z���  �|���  ҁ���  ���  H���4  ����T  @���t  �����  0����  n����  ʝ���  ����  ����4  ����T  ����t  v����  �����  e����  S����  ����	  ����4	  ���T	  l���t	  �����	  ����	  �����	  ���� 
             zR x�      �0��+                  zR x�  $      H.��    FJw� ?;*3$"       D   @0��              \   B1��    A�CU      |   <1��l    A�Cg     �   �1��%    A�C`      �   �1��    A�CL      �   ~1���    A�C�     �   -2��$    A�C_        12��N   A�CI    <  _4��I   A�CD    \  �6��   A�C    |  �;��o   A�Cj     �  �@���   A�CH��     �  sB���   A�C�    �  D��
   A�C       F��   A�C        �G��`    A�C[     @  )H���   A�C�    `  �L��3   A�C.    �  �P��   A�C    �  �Q���    A�C�     �  CR���    A�C�     �  �R���    A�C�        >S���    A�C�        �S���    A�C�     @  �T��X   A�CS    `  �U���    A�C�     �  �V��   A�C    �  �W���    A�C�     �  vX��s   A�Cn    �  �Z���   A�C�       �a��`   A�C[       �d��U   A�CP    @  i��m   A�Ch    `  On���   A�C�    �  �s��Y   A�CT    �  v���   A�C�    �  �z��3   A�C.    �  ���C    A�C~         ���C   A�C>       /����   A�C�    @  Ą��Z   A�CU    `  �����   A�C�    �  t���>   A�C9    �  ����\   A�CW    �  Ε���   A�C�    �  �����   A�C�       I���   A�C       :���   A�C    @  +����   A�C�    `  ڥ��    A�C    �  ڨ���   A�C�    �  �����   A�C�    �  W���2   A�C-    �  i���    A�C�       I����   A�C}       ����e   A�C`    @  ���q   A�Cl    `  A���2   A�C-     �  S���c   A�C^     D   �  ����e    B�B�E �B(�H0�H8�M@r8A0A(B BBB    �  ����                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  �                           �             $�             ��                           ��                    ���o    �             �             �      
                                                 ��                                        �	             �             �       	                            ���o          ���o    p      ���o           ���o          ���o                                                                                           ��                      �      �                  &      6      F      V      f      v      �      �      �      �      �      �      �      �                  &      6      F      V      f      v      �      �      �      �      �      �      �                                                      �      [31m [32m [33m [34m [35m [36m [0m [41m [42m [43m [44m [45m [46m QVPSIR     hamrouni/       .mkhabi/        .SEC_2020/      .mahloul/       .tempsh197350   .tempres197350 GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0                               8                    T                    t                    �                    �                    �                                        p                   	 �                   
 �	                    �                    �                    �                                         $�                    0�                    0�                    8�                    ��                    ��                    ��                    ��                     �                    ��                                        ��                     0                   p              !     �              7     ��             F     ��              m                    y     ��              �    ��                    ��                �     d�                   ��                �      ��              �     ��              �      ��              �      0�              �     ��                  �"      �           �             !    ��             '                     <    E�             C    ��             a    $      l       n    u(      `       x                      �    ��             �      �              �                     �    ƍ      �      �    7�      e      r    a�             �                     �    h      o          �      2          o3      �       "    xc      C      /    ��      q      <    Q�             B                     U    ��             h     �             q    �             z    h�      
       �    ��             �    �C      `      �    �l      �      �    �             �    Q      �      �    ��              �    �             �    =      �          �(      �                           $                     7     �             @    �             N    �-      3          $�              ]                     q    YG      U      �                     V     	!     @       �    `	!            �    �u      \      �    Ƅ            �    `!!            �                     �    ��            �    ~5      �           ^�                 "�                 �!!            &    �)!             .    �)!     �       8                     K                     ^    `�             f    W�             m    �9      �       y     *!            �    $*!            �    �       �      �                     �                     �    P            �    ?�             �    @*!     �       �    ��             �    5c      C       �    �      %       �    �*!     �       �     �                                                        *                     >    �:      s      R    �      N      \    �4      �       n          I      �    ph      Z      �                      �                     �   �              �    @+!     �       �    K�             �    0�             �    �             �    p&            �                         `q      >      -    �+!            %                     7    �1            ?    �+!            H    �             O    .�             V    
             a    f$      
      j    ��      e       z    �             �    ]�             �                     �    �C!            �    �y      �      �    �C!            �                     �    �K      m      �     HM!             	    9�             �           +           x�      	           ��      
            ��      �      .    ��             R    U6      X      ^     D!     �       e    ��              q    ^      3      �                     �    �D!            �    ?�      c      �    �D!            �    �      $       �    _�             �    ��      �      �                     �                     �    �D!            �    b�                 ׇ      �      "                     5    4      �       G    ��      2      k                     �                     �    (�             �    �D!     �       �     E!            �                     �                     �    �7      �       �                     �   ��              	     M!             	    !Y      �      !	                      ;	    4�             B	                     V	    �V      Y      j	                     }	    @M!            �	                     �	  "                   t    �              �	                     �	    �      �       �	    �2      �       �	    �8            �	    �d      �      
    �}      �       crtstuff.c deregister_tm_clones __do_global_dtors_aux completed.7698 __do_global_dtors_aux_fini_array_entry frame_dummy __frame_dummy_init_array_entry appsec.c __FRAME_END__ __init_array_end _DYNAMIC __init_array_start __GNU_EH_FRAME_HDR _GLOBAL_OFFSET_TABLE_ lec_mafatih __libc_csu_fini ficsh putchar@@GLIBC_2.2.5 fjaune verifier_4p3f_fic_ecr_ouv_sep handler_alrm aff_intro _ITM_deregisterTMCloneTable stdout@@GLIBC_2.2.5 strcpy@@GLIBC_2.2.5 verifier_4p3f_fic_lec_ouv_sep verifier_cmd puts@@GLIBC_2.2.5 maj_csv traiter_cmd verifier_reponse_p_m aff_resultat executer_cmd frose fread@@GLIBC_2.2.5 stdin@@GLIBC_2.2.5 filscour nbl_synt repdis1 repdis3 verifier_5p_4f_heritage verifier_4p3f_sigint_ign_dfl nbl_pres verifier_4p_3f_zombie _edata nbcon verifier_8p_3f_3pf_1ppf const_script fclose@@GLIBC_2.2.5 ctime@@GLIBC_2.2.5 mes_menu lire_nimporte valider_etape0 strlen@@GLIBC_2.2.5 verifier_4p_3f_redir __stack_chk_fail@@GLIBC_2.4 mes_synt verifier_4p3f_sigchld_wait verifier_4p3f_sigchld_mask verifier_4p3f_alarm_waitpid verifier_rep_str valider tbleu execetape premcon nb_essais fgetc@@GLIBC_2.2.5 alarm@@GLIBC_2.2.5 suivant fbleuc nettoyer_sh nb_etapes pidcmd lec_fic_mes __libc_start_main@@GLIBC_2.2.5 fgets@@GLIBC_2.2.5 lec_csv fvert maj_etape viderBuffer passage __data_start strcmp@@GLIBC_2.2.5 getchar@@GLIBC_2.2.5 signal@@GLIBC_2.2.5 verifier_4p_3freres obt_login verifier_rep_char verifier_proc_abs verifier_4p3f_sigint_tstp_cont __gmon_start__ umask@@GLIBC_2.2.5 __dso_handle score fbleu _IO_stdin_used tvert aff_scoul kill@@GLIBC_2.2.5 verifier_4p3f_sigint_ign_dfl_exec sv_stdout exec_sc mes_pres trouge tbleuc handlerint aff_menu __libc_csu_init tjaune sortie fflush@@GLIBC_2.2.5 nbl_menu verifier_4p3f_sigchld_wait_sig_perdu fmesscached __isoc99_sscanf@@GLIBC_2.7 verifier_4p_3f_orphelin frouge repdis2 repdis4 valider_etape verifier_4p3f_fic_lec_ouv_uni_lseek lire_procid credit __bss_start verifier_4p_3f_exec_redir getlogin_r@@GLIBC_2.2.5 cc main t_ecoule upper precedent verifier_4p3f_fic_ecr_ouv_uni fopen@@GLIBC_2.2.5 score_g regles verifier_4p3f_fic_lec_ouv_uni bzero@@GLIBC_2.2.5 verifier_reponse2 verifier_4p3f_fic_ecr_ouv_uni_lseek __isoc99_scanf@@GLIBC_2.7 strcat@@GLIBC_2.2.5 trose repdis srcetape sprintf@@GLIBC_2.2.5 exit@@GLIBC_2.2.5 lire_ent_ficres fwrite@@GLIBC_2.2.5 __TMC_END__ dercon verifier_4p_3f_exec _ITM_registerTMCloneTable tblanc execlp@@GLIBC_2.2.5 verifier_4p_3f_wait sleep@@GLIBC_2.2.5 reaff wait@@GLIBC_2.2.5 __cxa_finalize@@GLIBC_2.2.5 fork@@GLIBC_2.2.5 saisie_ent verifier_reponse nettoyer_procs verifier_4p3f_sigint verifier_4p3f_sigchld_waitpid_while  .symtab .strtab .shstrtab .interp .note.ABI-tag .note.gnu.build-id .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt .init .plt.got .text .fini .rodata .eh_frame_hdr .eh_frame .init_array .fini_array .dynamic .data .bss .comment                                                                                 8      8                                    #             T      T                                     1             t      t      $                              D   ���o       �      �      (                             N             �      �      �                          V             �      �                                   ^   ���o                   R                            k   ���o       p      p      @                            z             �      �      �                            �      B       �	      �	                                �             �      �                                    �             �      �                                   �             �      �                                   �                           "�                             �             $�      $�      	                              �             0�      0�      �/                             �             0�      0�                                   �             8�      8�      0                             �             ��      ��                                   �             ��      ��                                   �             ��      ��      �                           �             ��      ��      H                            �              �       �      �                              �             ��      ��      h\                              �      0               ��      )                                                   ��      h         +                 	                      X     '
                                                        �                                                                                                                                                                                                                                                                                                                                                              api_systeme/fic_centaines.txt                                                                       0000644 0053044 0074430 00000000054 13636623406 016113  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    100
101
102
103
104
105
106
107
108
109
110
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    api_systeme/pf_sigint_tstp_cont.c                                                                   0000600 0053044 0074430 00000004117 13635367501 016777  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Traitement du signal SIGINT */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <signal.h>   /* traitement des signaux */

#define NB_FILS 3     /* nombre de fils */

/* Traitant du signal SIGINT */
void handler(int signal_num) {
    printf("\n     Processus de pid %d : J'ai reçu le signal %d\n", 
            getpid(),signal_num);
    return;
}

/* dormir pendant nb_secondes secondes  */
/* à utiliser à la palce de sleep(duree), car sleep s'arrête */
/* dès qu'un signal non ignoré est reçu */
void dormir(int nb_secondes)
{
    int duree = 0;
    while (duree < nb_secondes) {
        sleep(1);
        duree++;
    }
}

int main()
{
    int fils, retour;
    int duree_sommeil = 120;

    /* associer un traitant au signal SIGINT */
    signal(SIGINT, handler);
    signal(SIGTSTP, handler);
    signal(SIGCONT, handler);
    signal(SIGQUIT, handler);

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            printf("\n     Processus fils numero %d, de pid %d, de pere %d.\n", 
                    fils, getpid(), getppid());
            dormir(duree_sommeil);
            /* Important : terminer un processus par exit */
            exit(EXIT_SUCCESS);   /* Terminaison normale (0 = sans erreur) */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }
    dormir(duree_sommeil+2);
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                 api_systeme/pf_sigchld_mask.c                                                                       0000600 0053044 0074430 00000007240 13636057243 016035  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* masquage et démasquage de SIGCHLD  */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <signal.h>   /* opérations sur les signaux */

#define NB_FILS 3     /* nombre de fils */
#define DELAI 10

int nb_fils_termines; /* variable globale car modifiée par le traitant */

/* Traitant du signal SIGCHLD */
void handler_sigchld(int signal_num) {
    int fils_termine, wstatus;

    if (signal_num == SIGCHLD) {
        while ((fils_termine = (int) waitpid(-1, &wstatus, WNOHANG | WUNTRACED | WCONTINUED)) > 0) {
            if WIFEXITED(wstatus) {
                printf("\nMon fils de pid %d s'est arrete avec exit %d\n",  fils_termine, WEXITSTATUS(wstatus));
                nb_fils_termines++;
            }
            else if WIFSIGNALED(wstatus) {
                printf("\nMon fils de pid %d a recu le signal %d\n",  fils_termine, WTERMSIG(wstatus));
                nb_fils_termines++;
            }
            else if (WIFCONTINUED(wstatus)) {
                printf("\nMon fils de pid %d a ete relance \n",  fils_termine);
            }
            else if (WIFSTOPPED(wstatus)) {
                printf("\nMon fils de pid %d a ete suspendu \n", fils_termine);
            }
        }
    }
    return;
}

int main()
{
    int fils, retour;
    int duree_sommeil = 2;

    sigset_t ens_signaux;

    sigemptyset(&ens_signaux);

    /* ajouter SIGCHLD à ens_signaux */
    sigaddset(&ens_signaux, SIGCHLD);

    nb_fils_termines = 0;
    /* associer traitant sigchld à SIGCHLD */
    signal(SIGCHLD, handler_sigchld);

    printf("\nJe suis le processus principal de pid %d\n", getpid());
    /* Vidange du tampon de sortie pour que le fils le récupère vide        */
    fflush(stdout);

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            printf("\n     Processus fils numero %d, de pid %d, de pere %d.\n", 
                    fils, getpid(), getppid());
            sleep(duree_sommeil * fils);
			printf("\n     Processus fils numero %d : je m\'arrête.\n", fils);
            exit(fils);  /* normalement exit(0), mais on veut illustrer WEXITSTATUS */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }

    /* faire ce qu'on veut jusqu'à la terminaison de tous les fils */
    do {
        /* période durant laquelle on ne veut pas être embêté par SIGCHLD */
        printf("\nProcessus de pid %d : Je masque SIGCHLD durant %d secondes\n", getpid(), DELAI);
        /* masquer les signaux définis dans ens_signaux : SIGCHLD */
        sigprocmask(SIG_BLOCK, &ens_signaux, NULL);
        sleep(DELAI);

        /* période durant laquelle on peut traiter le signal SIGCHLD */
        printf("\nProcessus de pid %d : Je démasque SIGCHLD\n", getpid());
        /* démasquer les signaux définis dans ens_signaux : SIGCHLD */
        sigprocmask(SIG_UNBLOCK, &ens_signaux, NULL);
        sleep(2);

    } while (nb_fils_termines < NB_FILS);
    printf("\nProcessus Principal termine\n");
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                                                                                                                api_systeme/pf_sigint.c                                                                             0000600 0053044 0074430 00000004000 13635632556 014676  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Traitement du signal SIGINT */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <signal.h>   /* traitement des signaux */

#define NB_FILS 3     /* nombre de fils */

/* Traitant du signal SIGINT */
void handler_sigint(int signal_num) {
    printf("\n     Processus de pid %d : J'ai reçu le signal %d\n", 
            getpid(),signal_num);
    return;
}

/* dormir pendant nb_secondes secondes  */
/* à utiliser à la palce de sleep(duree), car sleep s'arrête */
/* dès qu'un signal non ignoré est reçu */
void dormir(int nb_secondes)
{
    int duree = 0;
    while (duree < nb_secondes) {
        sleep(1);
        duree++;
    }
}

int main()
{
    int fils, retour;
    int duree_sommeil = 600;

    /* associer un traitant au signal SIGINT */
    signal(SIGINT, handler_sigint);

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            printf("\n     Processus fils numero %d, de pid %d, de pere %d.\n", 
                    fils, getpid(), getppid());
            dormir(duree_sommeil);
            /* Important : terminer un processus par exit */
            exit(EXIT_SUCCESS);   /* Terminaison normale (0 = sans erreur) */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }
    dormir(duree_sommeil+2);
    return EXIT_SUCCESS;
}
api_systeme/pf_sigchld_wait.c                                                                       0000600 0053044 0074430 00000004771 13636052600 016044  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* utilisation de SIGCHLD pour prendre connaissance de la fin des fils */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <signal.h>   /* opérations sur les signaux */

#define NB_FILS 3     /* nombre de fils */

int nb_fils_termines; /* variable globale car modifiée par le traitant */

/* Traitant du signal SIGCHLD */
void handler_sigchld(int signal_num) {
    int wstatus, fils_termine;

    fils_termine = wait(&wstatus);
    nb_fils_termines++;
    if WIFEXITED(wstatus) {   /* fils terminé avec exit */
        printf("\nMon fils de pid %d a termine avec exit %d\n", 
                fils_termine, WEXITSTATUS(wstatus));
    }
    else if WIFSIGNALED(wstatus) {  /* fils tué par un signal */
        printf("\nMon fils de pid %d a ete tue par le signal %d\n", 
                fils_termine, WTERMSIG(wstatus));
    }
    return;
}

int main()
{
    int fils, retour;
    int duree_sommeil = 300;

    nb_fils_termines = 0;
    /* associer traitant sigchld à SIGCHLD */
    signal(SIGCHLD, handler_sigchld);

    printf("\nJe suis le processus principal de pid %d\n", getpid());
    /* Vidange du tampon de sortie pour que le fils le récupère vide        */
    fflush(stdout);

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            printf("\n     Processus fils numero %d, de pid %d, de pere %d.\n", 
                    fils, getpid(), getppid());
            sleep(2 + duree_sommeil * (fils -1));
            exit(fils);  /* normalement exit(0), mais on veut illustrer WEXITSTATUS */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }

    /* faire ce qu'on jusqu'à la terminaison de tous les fils */
    do {
        /* faire ce qu'on veut */

    } while (nb_fils_termines < NB_FILS);
    printf("\nProcessus Principal termine\n");
    return EXIT_SUCCESS;
}
       api_systeme/pf_fichier_ecr_ouv_sep.c                                                                0000600 0053044 0074430 00000006104 13637051434 017402  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* 1 fichier : plusieurs ouvertures, écritures concurrentes */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <string.h>   /* opérations sur les chaines */
#include <fcntl.h>    /* opérations sur les fichiers */

#define NB_FILS 3     /* nombre de fils */

int main()
{
    int fils, retour, desc_fic, fils_termine, wstatus, ifor;
    int duree_sommeil = 3;

    char fichier[] = "fic_res_ouv_sep.txt";
    char buffer[8];     /* buffer de lecture */

    bzero(buffer, sizeof(buffer));

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            /* ouverture du fichier en lecture */
            desc_fic = open(fichier, O_WRONLY | O_CREAT | O_TRUNC, 0640);
            /* traiter systématiquement les retours d'erreur des appels */
            if (desc_fic < 0) {
                printf("Erreur ouverture %s\n", fichier);
                exit(1);
            }

            /* decaler les écritures des differents fils : fils 3, fils 2, fils 1, ... */
            sleep(NB_FILS - fils);

            /* effectuer 4 ecritures dans le fichier */
            for (ifor = 1; ifor <= 4; ifor++) {
                bzero(buffer, sizeof(buffer));
                sprintf(buffer, "%d-%d\n", fils,ifor);
                write(desc_fic, buffer, strlen(buffer));
                printf("     Processus fils numero %d a ecrit %s\n", 
                        fils, buffer);
                sleep(duree_sommeil);
            }

            close(desc_fic);
            /* Important : terminer un processus par exit */
            exit(EXIT_SUCCESS);   /* Terminaison normale (0 = sans erreur) */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }
    /* attendre la fin des fils */
    for (fils = 1; fils <= NB_FILS; fils++) {
        /* attendre la fin d'un fils */
        fils_termine = wait(&wstatus);

        if WIFEXITED(wstatus) {   /* fils terminé avec exit */
            printf("\nMon fils de pid %d a termine avec exit %d\n", 
                    fils_termine, WEXITSTATUS(wstatus));
        }
        else if WIFSIGNALED(wstatus) {  /* fils tué par un signal */
            printf("\nMon fils de pid %d a ete tue par le signal %d\n", 
                    fils_termine, WTERMSIG(wstatus));
        }
    }

    printf("\nProcessus Principal termine\n");
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                            api_systeme/dormir                                                                                  0000755 0053044 0074430 00000020510 14027604423 013772  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    ELF          >    �      @                 @ 8 	 @         @       @       @       �      �                   8      8      8                                                          
       
                    �      �      �      x      �                    �      �      �      �      �                   T      T      T      D       D              P�td   �      �      �      <       <              Q�td                                                  R�td   �      �      �      h      h             /lib64/ld-linux-x86-64.so.2          GNU                        GNU ��1A���,wЙ�0ʒQ)��V                         )�                            _                                                                   A                      {                                             '                      �                       ,                      2   "                                       libc.so.6 fflush getpid printf stdout atoi sleep __cxa_finalize __libc_start_main GLIBC_2.2.5 _ITM_deregisterTMCloneTable __gmon_start__ _ITM_registerTMCloneTable                                 ui	   S       �             �      �             `                         �                    �                    �                    �                    �         
                               �                    �                    �                    �                    �         	           H��H��	  H��t��H���         �5j	  �%l	  @ �%j	  h    ������%b	  h   ������%Z	  h   ������%R	  h   �����%J	  h   �����%b	  f�        1�I��^H��H���PTL��  H�c  H�=�   �	  �D  H�=9	  UH�1	  H9�H��tH��  H��t]��f.�     ]�@ f.�     H�=�  H�5�  UH)�H��H��H��H��?H�H��tH��  H��t]��f�     ]�@ f.�     �=�   u/H�=�   UH��tH�=�  �����H�����  ]��    ��fD  UH��]�f���UH��H�� �}�H�u��E�   �}�~H�E�H��H� H�������E��_������E���H�=�   �    �U����E����{���H�  H���L����    ��D  AWAVI��AUATL�%f  UH�-f  SA��I��L)�H��H������H��t 1��     L��L��D��A��H��H9�u�H��[]A\A]A^A_Ðf.�     ��  H��H���         
      - Processus %d va dormir durant %d secondes
 ;8      T����   �����   ����T   �����   D����   ����,         zR x�      h���+                  zR x�  $      ����`    FJw� ?;*3$"       D    ���              \   ���q    A�Cl  D   |   X���e    B�B�E �B(�H0�H8�M@r8A0A(B BBB    �   ����                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   �      `                                        �             �                           �                    ���o    �             �             �      
       �                                           �             x                            �             �             �       	                            ���o          ���o    �      ���o           ���o    �      ���o                                                                                           �                      F      V      f      v      �                                                            GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0                                      8                    T                    t                    �                    �                    �                    �                    �                   	 �                   
 �                                        0                    �                    �                    �                    �                    �                    	                    �                    �                    �                    �                                                                                 ��                     �                                 !     `              7                  F     �              m     �              y     �              �    ��                    ��                �     
                   ��                �      �              �     �              �      �              �      �              �     �                  �                                   1                 �                    E                     Y                      �              `                     t                     �                   �                      �                 �    �             �           e       �                     �                    �    �      +       �                  �    �      q                                                                    8                     K  "                   �                   crtstuff.c deregister_tm_clones __do_global_dtors_aux completed.7698 __do_global_dtors_aux_fini_array_entry frame_dummy __frame_dummy_init_array_entry dormir.c __FRAME_END__ __init_array_end _DYNAMIC __init_array_start __GNU_EH_FRAME_HDR _GLOBAL_OFFSET_TABLE_ __libc_csu_fini _ITM_deregisterTMCloneTable stdout@@GLIBC_2.2.5 getpid@@GLIBC_2.2.5 _edata printf@@GLIBC_2.2.5 __libc_start_main@@GLIBC_2.2.5 __data_start __gmon_start__ __dso_handle _IO_stdin_used __libc_csu_init fflush@@GLIBC_2.2.5 __bss_start main atoi@@GLIBC_2.2.5 __TMC_END__ _ITM_registerTMCloneTable sleep@@GLIBC_2.2.5 __cxa_finalize@@GLIBC_2.2.5  .symtab .strtab .shstrtab .interp .note.ABI-tag .note.gnu.build-id .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt .init .plt.got .text .fini .rodata .eh_frame_hdr .eh_frame .init_array .fini_array .dynamic .data .bss .comment                                                                                 8      8                                    #             T      T                                     1             t      t      $                              D   ���o       �      �      $                             N             �      �                                 V             �      �      �                              ^   ���o       �      �                                  k   ���o       �      �                                   z             �      �      �                            �      B       �      �      x                           �                                                       �             0      0      `                             �             �      �                                   �             �      �      �                             �             �      �      	                              �             �      �      <                              �             �      �      <                              �             	      	                                   �             �      �                                   �             �      �                                   �             �      �      �                           �             �      �      h                             �                                                         �                                                       �      0                     )                                                   @      `         +                 	                      �      g                                                         �                                                                                                                                                                                                                      api_systeme/pf_fichier_ecr_ouv_uni_lseek.c                                                          0000600 0053044 0074430 00000007007 13637051264 020575  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* 1 fichier : 1 seule ouverture en écriture partagée et lseek */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <sys/types.h>
#include <string.h>   /* opérations sur les chaines */
#include <fcntl.h>    /* opérations sur les fichiers */

#define NB_FILS 3     /* nombre de fils */

int main()
{
    int fils, retour, desc_fic, fils_termine, wstatus, ifor;
    int duree_sommeil = 3;

    char fichier[] = "fic_res_ouv_uni_lseek.txt";
    char buffer[8];     /* buffer de lecture */

    bzero(buffer, sizeof(buffer));

    /* ouverture du fichier en ecriture, avec autorisations rw- -r- ---*/
    /* avec création si le fichier n'existe pas : O_CREAT */
    /* avec vidange (raz du contenu) si le fichier existe: O_TRUNC */
    desc_fic = open(fichier, O_WRONLY | O_CREAT | O_TRUNC, 0640);

    /* traiter systématiquement les retours d'erreur des appels */
    if (desc_fic < 0) {
        printf("Erreur ouverture %s\n", fichier);
        exit(1);
    }

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            /* decaler les écritures des differents fils : fils 3, fils 2, fils 1, ... */
            sleep(NB_FILS - fils);

            /* effectuer 4 ecritures dans le fichier */
            for (ifor = 1; ifor <= 4; ifor++) {
                // fils 2 recule la tete de 4 octets
                if (fils == 2) {
                    lseek(desc_fic, -4, SEEK_CUR);
                }
                bzero(buffer, sizeof(buffer));
                sprintf(buffer, "%d-%d\n", fils,ifor);
                write(desc_fic, buffer, strlen(buffer));
                printf("     Processus fils numero %d a ecrit %s\n", 
                        fils, buffer);
                // fils 1 avance la tete de 4 octets
                if (fils == 1) {
                    lseek(desc_fic, 4, SEEK_CUR);
                }
                sleep(duree_sommeil);
            }
            /* Important : terminer un processus par exit */
            exit(EXIT_SUCCESS);   /* Terminaison normale (0 = sans erreur) */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }
    /* attendre la fin des fils */
    for (fils = 1; fils <= NB_FILS; fils++) {
        /* attendre la fin d'un fils */
        fils_termine = wait(&wstatus);

        if WIFEXITED(wstatus) {   /* fils terminé avec exit */
            printf("\nMon fils de pid %d a termine avec exit %d\n", 
                    fils_termine, WEXITSTATUS(wstatus));
        }
        else if WIFSIGNALED(wstatus) {  /* fils tué par un signal */
            printf("\nMon fils de pid %d a ete tue par le signal %d\n", 
                    fils_termine, WTERMSIG(wstatus));
        }
    }
    close(desc_fic);
    printf("\nProcessus Principal termine\n");
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         api_systeme/pf_alarm_waitpid.c                                                                      0000600 0053044 0074430 00000006140 13636056206 016216  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* SIGALRM et waitpid pour prendre connaissance de la fin des fils  */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <signal.h>   /* opérations sur les signaux */

#define NB_FILS 3     /* nombre de fils */
#define D_ALARM 10     /* durée pour alarm */

int nb_fils_termines; /* variable globale car modifiée par le traitant */

/* Traitant du signal SIGCHLD */
void handler_sigalrm(int signal_num) {
    int fils_termine, wstatus;

    if (signal_num == SIGALRM) {
        while ((fils_termine = (int) waitpid(-1, &wstatus, WNOHANG | WUNTRACED | WCONTINUED)) > 0) {
            if WIFEXITED(wstatus) {
                printf("\nMon fils de pid %d s'est arrete avec exit %d\n",  fils_termine, WEXITSTATUS(wstatus));
                nb_fils_termines++;
            }
            else if WIFSIGNALED(wstatus) {
                printf("\nMon fils de pid %d a recu le signal %d\n",  fils_termine, WTERMSIG(wstatus));
                nb_fils_termines++;
            }
            else if (WIFCONTINUED(wstatus)) {
                printf("\nMon fils de pid %d a ete relance \n",  fils_termine);
            }
            else if (WIFSTOPPED(wstatus)) {
                printf("\nMon fils de pid %d a ete suspendu \n", fils_termine);
            }
        }
    }
    /* relancer alarm a cela n'est pas fait automatiquement */
    alarm(D_ALARM);
    return;
}

int main()
{
    int fils, retour;
    int duree_sommeil = 3;

    nb_fils_termines = 0;
    /* associer traitant sigchld à SIGCHLD */
    signal(SIGALRM, handler_sigalrm);

    printf("\nJe suis le processus principal de pid %d\n", getpid());
    /* Vidange du tampon de sortie pour que le fils le récupère vide        */
    fflush(stdout);

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            printf("\n     Processus fils numero %d, de pid %d, de pere %d.\n", 
                    fils, getpid(), getppid());
            sleep(duree_sommeil * fils);
			printf("\n     Processus fils numero %d : je m\'arrête.\n", fils);
            exit(fils);  /* normalement exit(0), mais on veut illustrer WEXITSTATUS */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }

    alarm(D_ALARM);
    /* faire ce qu'on veut jusqu'à la terminaison de tous les fils */
    do {
        /* faire ce qu'on veut */

    } while (nb_fils_termines < NB_FILS);
    printf("\nProcessus Principal termine\n");
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                                                                                                                                                                                api_systeme/pere_fils_zombie.c                                                                      0000600 0053044 0074430 00000002325 13625250421 016223  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Fils Zombie */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */

#define NB_FILS 3     /* nombre de fils */

int main()
{
    int fils, retour;
    int duree_sommeil = 120;

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            printf("\n     Processus fils numero %d, de pid %d, de pere %d.\n", 
                    fils, getpid(), getppid());
            sleep(duree_sommeil);
            exit(EXIT_SUCCESS);   /* Terminaison normale */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }
    sleep(duree_sommeil);
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                                                           api_systeme/pf_sigchld_wait_sig_perdu.c                                                             0000600 0053044 0074430 00000005362 13635702601 020104  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* utilisation de SIGCHLD pour prendre connaissance de la fin des fils */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <signal.h>   /* opérations sur les signaux */

#define NB_FILS 3     /* nombre de fils */

int nb_fils_termines; /* variable globale car modifiée par le traitant */

/* Traitant du signal SIGCHLD */
void handler_sigchld(int signal_num) {
    int wstatus, fils_termine;

	printf("\nJ'ai reçu le signal %d\n",  signal_num);
    fils_termine = wait(&wstatus);
    nb_fils_termines++;
    if WIFEXITED(wstatus) {   /* fils terminé avec exit */
        printf("\nMon fils de pid %d a termine avec exit %d\n", 
                fils_termine, WEXITSTATUS(wstatus));
    }
    else if WIFSIGNALED(wstatus) {  /* fils tué par un signal */
        printf("\nMon fils de pid %d a ete tue par le signal %d\n", 
                fils_termine, WTERMSIG(wstatus));
    }
	sleep(3);
    return;
}

int main()
{
    int fils, retour;
    int duree_sommeil = 2;

    nb_fils_termines = 0;
    /* associer traitant sigchld à SIGCHLD */
    signal(SIGCHLD, handler_sigchld);

    printf("\nJe suis le processus principal de pid %d\n", getpid());
    /* Vidange du tampon de sortie pour que le fils le récupère vide        */
    fflush(stdout);

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            printf("\n     Processus fils numero %d, de pid %d, de pere %d.\n", 
                    fils, getpid(), getppid());
			//if (fils==3) duree_sommeil++;
            sleep(duree_sommeil);
			printf("\n     Processus fils numero %d s'arrete\n", 
                    fils);
            exit(fils);  /* normalement exit(0), mais on veut illustrer WEXITSTATUS */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }

    //sleep(2);	/* pour les besoins de l'outil de validation automatique */

    /* faire ce qu'on jusqu'à la terminaison de tous les fils */
    do {
        /* faire ce qu'on veut */

    } while (nb_fils_termines < NB_FILS);
    printf("\nProcessus Principal termine\n");
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                              api_systeme/pf_sigchld_waitpid_while.c                                                              0000600 0053044 0074430 00000004663 13636055636 017745  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* SIGCHLD et waitpid pour prendre connaissance de la fin des fils  */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <signal.h>   /* opérations sur les signaux */
#include <string.h> 

#define NB_FILS 4     /* nombre de fils */

int nb_fils_termines; /* variable globale car modifiée par le traitant */

/* Traitant du signal SIGCHLD */
void handler_chld(int signal_num) {
	int fils_termine, wstatus;
	printf("\nJ'ai reçu le signal %d\n",  signal_num);
	if (signal_num == SIGCHLD) {
		while ((fils_termine = (int) waitpid(-1, &wstatus, WNOHANG | WUNTRACED | WCONTINUED)) > 0) {
			if WIFEXITED(wstatus) {
				printf("\nMon fils de pid %d s'est arrete avec exit %d\n",  fils_termine, WEXITSTATUS(wstatus));
				nb_fils_termines++;
			}
			else if WIFSIGNALED(wstatus) {
				printf("\nMon fils de pid %d a recu le signal %d\n",  fils_termine, WTERMSIG(wstatus));
				nb_fils_termines++;
			}
			else if (WIFCONTINUED(wstatus)) {
				printf("\nMon fils de pid %d a ete relance \n",  fils_termine);
			}
			else if (WIFSTOPPED(wstatus)) {
				printf("\nMon fils de pid %d a ete suspendu \n", fils_termine);
			}
			sleep(1);
		}
	}
	
}

/* Programme principal : Un pere qui cree 3 fils */

int main()
{
	int fils, pid;
	int duree_sommeil = 2;
	
	signal(SIGCHLD, handler_chld);

	printf("Je suis le processus principal %d, de pere %d\n", getpid(), getppid());
	nb_fils_termines = 0;
		
	for (fils=1; fils<=NB_FILS; fils++) {
		pid = fork();
		if (pid<0) { // erreur fork
				printf("Erreur fork\n");
				exit(1);
		}
		else if (pid==0) { //fils
				printf("\n     Processus fils num %d, de pid %d, de pere %d.\n", fils, getpid(), getppid());
				if (fils == 4) {
					duree_sommeil = 300;
				}
				sleep(duree_sommeil);
				printf("\n     Processus fils num %d termine\n", fils);
				exit(fils);  /* normalement 0, mais on veut illustrer WEXITSTATUS */
		}
		else {//pere
				printf("\nProcessus pere de pid %d a cree un fils numero %d, de pid %d \n", getpid(), fils, pid);
		}
	}
	
	/* faire ce qu'on jusqu'à la terminaison de tous les fils */
    do {
        /* faire ce qu'on veut */

    } while (nb_fils_termines < NB_FILS);
	printf("\nProcessus Principal termine\n");
	return EXIT_SUCCESS;
}
                                                                             api_systeme/pf_sigint_ign_dfl.c                                                                     0000600 0053044 0074430 00000004310 13635754525 016365  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Traitement du signal SIGINT : SIG_IGN et SIG_DFL */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <signal.h>   /* traitement des signaux */

#define NB_FILS 3     /* nombre de fils */

/* Traitant du signal SIGINT */
void handler_sigint(int signal_num) {
    printf("\n     Processus de pid %d : J'ai reçu le signal %d\n", 
            getpid(),signal_num);
    return;
}

/* dormir pendant nb_secondes secondes  */
/* à utiliser à la palce de sleep(duree), car sleep s'arrête */
/* dès qu'un signal non ignoré est reçu */
void dormir(int nb_secondes)
{
    int duree = 0;
    while (duree < nb_secondes) {
        sleep(1);
        duree++;
    }
}

int main()
{
    int fils, retour;
    int duree_sommeil = 600;

    /* associer un traitant au signal SIGINT */
    signal(SIGINT, handler_sigint);

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            if (fils == 1) {
                signal(SIGINT, SIG_IGN);
            }
            else if (fils == 2) {
                signal(SIGINT, SIG_DFL);
            }
            printf("\n     Processus fils numero %d, de pid %d, de pere %d.\n", 
                    fils, getpid(), getppid());
            dormir(duree_sommeil);
            /* Important : terminer un processus par exit */
            exit(EXIT_SUCCESS);   /* Terminaison normale (0 = sans erreur) */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }
    dormir(duree_sommeil+2);
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                                                                        api_systeme/pere_fils_fflush.c                                                                      0000600 0053044 0074430 00000003711 13625231320 016222  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Redirection et fflush */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */

#define NB_FILS 3     /* nombre de fils */

int main()
{
    int fils, retour;
    int duree_sommeil = 2;

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    /* Vidange du tampon de sortie pour que le fils le récupère vide        */
    /* D'après le standard ISO le comportement du printf présente 2 cas :   */
    /* - sortie interactive (terminal) : flot géré par ligne et \n provoque */
    /*   la vidange du tampon langage */
    /* - sortie dans un fichier : flot géré par bloc et \n est traité comme */
    /*   un caractère ordinaire. fflush(stdout) force la vidange du tampon. */

    fflush(stdout);

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            printf("\n     Processus fils numero %d, de pid %d, de pere %d.\n", 
                    fils, getpid(), getppid());
            sleep(duree_sommeil);
            /* Important : terminer un processus par exit */
            exit(EXIT_SUCCESS);   /* Terminaison normale (0 = sans erreur) */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
            /* vidange du tampon de sortie pour que le fils le récupère vide */
            fflush(stdout);
        }
    }
    sleep(duree_sommeil);
    return EXIT_SUCCESS;
}
                                                       api_systeme/pere_fils_sans_exit.c                                                                   0000600 0053044 0074430 00000002376 13622220153 016735  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Absence du exit dans le fils, et conséquences */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */

#define NB_FILS 3     /* nombre de fils */

int main()
{
    int fils, retour;
    int duree_sommeil = 3;

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) { 
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            printf("\n     Processus fils numero %d, de pid %d, de pere %d.\n", 
                    fils, getpid(), getppid());
            /* Le fils ne s'arrete pas ici */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }
    sleep(duree_sommeil);
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                  api_systeme/pere_fils_orphelin.c                                                                    0000600 0053044 0074430 00000002453 13625232626 016567  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Fils orphelins */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */

#define NB_FILS 3     /* nombre de fils */

int main()
{
    int fils, retour;
    int duree_sommeil = 120;

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            printf("\n     Processus fils numero %d, de pid %d, de pere %d.\n", 
                    fils, getpid(), getppid());
            sleep(duree_sommeil);
            exit(EXIT_SUCCESS);       /* Terminaison normale */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }
    sleep(duree_sommeil);
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                     api_systeme/pf_fichier_lec_ouv_sep.c                                                                0000600 0053044 0074430 00000005525 13637050561 017402  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Fichiers : lecture partagée avec ouvertures séparées */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <string.h>   /* opérations sur les chaines */
#include <fcntl.h>    /* opérations sur les fichiers */

#define NB_FILS 3     /* nombre de fils */

int main()
{
    int fils, retour, desc_fic, fils_termine, wstatus;
    int duree_sommeil = 3;

    char fichier[] = "fic_centaines.txt";
    char buffer[8];     /* buffer de lecture */

    bzero(buffer, sizeof(buffer));

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            /* ouverture du fichier en lecture */
            desc_fic = open(fichier, O_RDONLY);
            /* traiter systématiquement les retours d'erreur des appels */
            if (desc_fic < 0) {
                printf("Erreur ouverture %s\n", fichier);
                exit(1);
            }

            sleep(NB_FILS - fils);

            /* lire le fichier par blocs de 4 octets */
            while (read(desc_fic, buffer, 4)>0) {

                printf("     Processus fils numero %d a lu %s\n", 
                        fils, buffer);
                sleep(duree_sommeil);
                bzero(buffer, sizeof(buffer));
            }

            close(desc_fic);

            /* Important : terminer un processus par exit */
            exit(EXIT_SUCCESS);   /* Terminaison normale (0 = sans erreur) */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }
    /* attendre la fin des fils */
    for (fils = 1; fils <= NB_FILS; fils++) {
        /* attendre la fin d'un fils */
        fils_termine = wait(&wstatus);

        if WIFEXITED(wstatus) {   /* fils terminé avec exit */
            printf("\nMon fils de pid %d a termine avec exit %d\n", 
                    fils_termine, WEXITSTATUS(wstatus));
        }
        else if WIFSIGNALED(wstatus) {  /* fils tué par un signal */
            printf("\nMon fils de pid %d a ete tue par le signal %d\n", 
                    fils_termine, WTERMSIG(wstatus));
        }
    }

    printf("\nProcessus Principal termine\n");
    return EXIT_SUCCESS;
}
                                                                                                                                                                           api_systeme/pere_fils.c                                                                             0000600 0053044 0074430 00000003123 13625516422 014661  0                                                                                                    ustar   hamrouni                        gea                                                                                                                                                                                                                    /* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Création de fils : fork et exit */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <string.h>   /* manipulation des chaines */

#define NB_FILS 3     /* nombre de fils */

int main(int argc, char *argv[])
{
    int fils, retour;
    int duree_sommeil = 3;
    char progname[]="pere_fils.c";

    if (argc > 1) {
        write(atoi(argv[1]), progname, strlen(progname));
    }

    printf("\nJe suis le processus principal de pid %d\n", getpid());

    for (fils = 1; fils <= NB_FILS; fils++) {
        retour = fork();

        /* Bonne pratique : tester systématiquement le retour des appels système */
        if (retour < 0) {   /* échec du fork */
            printf("Erreur fork\n");
            /* Convention : s'arrêter avec une valeur > 0 en cas d'erreur */
            exit(1);
        }

        /* fils */
        if (retour == 0) {
            printf("\n     Processus fils numero %d, de pid %d, de pere %d\n", 
                    fils, getpid(), getppid());
            sleep(duree_sommeil);
            /* Important : terminer un processus par exit */
            exit(EXIT_SUCCESS);   /* Terminaison normale (0 = sans erreur) */
        }

        /* pere */
        else {
            printf("\nProcessus de pid %d a cree un fils numero %d, de pid %d \n", 
                    getpid(), fils, retour);
        }
    }
    sleep(duree_sommeil + 1);
    return EXIT_SUCCESS;
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             