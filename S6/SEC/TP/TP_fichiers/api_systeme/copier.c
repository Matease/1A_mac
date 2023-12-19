/* Exemple d'illustration des primitives Unix : Un père et ses fils */
/* Fichiers : lecture partagée entre père et fils avec ouverture unique */

#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <string.h>   /* opérations sur les chaines */
#include <fcntl.h>    /* opérations sur les fichiers */

#define NB_FILS 3     /* nombre de fils */
#define BUFSIZE 8 

int main(int argc, char *argv[])
{
    int fils, retour, fic_source, fic_destination, fils_termine, wstatus ;
    int duree_sommeil = 3 ;
    char buffer[BUFSIZE] ;     /* buffer de lecture */

    if (argc!=3) {
        printf("Donnez 3 arguments");
        exit(1);
    }
 
     /* ouverture du fichier en lecture */
     fic_source = open(argv[1], O_RDONLY) ;
     /* traiter systématiquement les retours d'erreur des appels */
     if (fic_source < 0) {
         printf("Erreur d'ouverture %s\n", argv[1]) ;
         exit(1) ;
     }
 
     /* ouverture du fichier en lecture */
     fic_destination = open(argv[2], O_WRONLY|O_CREAT|O_TRUNC,0640) ;
     /* traiter systématiquement les retours d'erreur des appels */
     if (fic_destination < 0) {
         printf("Erreur d'ouverture %s\n", argv[2]) ;
         exit(1) ;
     }

    int lus;

    do {
        lus = read(fic_source, buffer, BUFSIZE);
        if (lus<0) {
            printf("lus");
            exit(1);
        }

        int ecr = write(fic_destination, buffer, lus);
        if (ecr<0) {
            printf("ecris");
            exit(1);
        }
    } while(lus>0);

    close(fic_source) ;
    close(fic_destination) ;
    printf("\nProcessus Principal termine\n") ;
    return EXIT_SUCCESS ;
}
