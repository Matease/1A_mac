#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h> /* wait */
#include <string.h>
#include <sys/types.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include "processus.h"
#include "commandes.h"
#include "readcmd.h"

typedef struct cmdline cmdline;

// variables globales
cmdline *cmd;
int pidFils;
int etatFils;
liste_p liste_process;
int in;
int avant_plan = 0;
int fichier_in,fichier_out;
struct sigaction action;;


void handler_SIGINT(int sig){
        if (avant_plan){
        kill(pidFils,SIGKILL);
        printf("\n");
        }
        else {}
}

void handler_SIGTSTP(int sig){
       if (avant_plan){
        kill(pidFils,SIGSTOP);
        printf("\n");
        }
        else {}
}


void handler_SIGCHLD(int sig)
{
    do
    {
        pidFils = waitpid(-1, &etatFils, WUNTRACED | WCONTINUED | WNOHANG);
        if (pidFils > 0)
        {
                processus *proc = processus_via_pid(pidFils, &liste_process);
                
                if (proc != NULL)
                {
                    if (WIFSTOPPED(etatFils))
                    {
                        if (pidFils == avant_plan)
                        {
                            avant_plan = 0;
                        };
                        proc->etat = "Suspendu";
                    }
                    else if (WIFCONTINUED(etatFils))
                    {
                        proc->etat = "Actif";
                    }
                    else if (WIFEXITED(etatFils) || WIFSIGNALED(etatFils))
                    {   
                        if (pidFils == avant_plan)
                        {
                            avant_plan = 0;
                        };
                        supprimer(proc->pid, &liste_process);
                    
                }
            }
        }
    } while (pidFils > 0);
}


/* Exécuter une commande contenant un ou plusieurs pipes 
parametres :
IN : cmdv = ligne de commande (cmdv[0] | cmdv[1] ... )
La commande peut etre sans pipe
*/
void exec_cmd_pipe(char **cmdv[]) {
    int ret, pid_sous_fils, pf2p[2];
    int nbCmd;

    /* Trouver s'il y a un pipe */
	  nbCmd = 0;
    while (cmdv[nbCmd] != NULL) { 
        nbCmd++; 
    }
   
    if (nbCmd > 1) { /* c'est une commande avec 1 pipe ou + : cmdv[0] | cmdv[1] ...*/
		
        ret = pipe(pf2p);
        if (ret == -1) {  
        printf("Erreur pipe\n");
        exit(1);
        }
        /* Creer un fils pour exécuter cmdv[0], le père executant cmdv[1] ... */
        pid_sous_fils = fork();
        switch (pid_sous_fils) {
            case -1 :
              printf("Erreur fork du sous fils\n"); 
				      exit(1);
  
            case 0 : /*fils execute cmdv[0] et doit transmettre le résultat au père */
              close(pf2p[0]);
              dup2(pf2p[1], 1);
              ret = execvp(cmdv[0][0], cmdv[0]);
              printf("Erreur execvp sous fils\n");  /* seulement si execvp echoue */
              exit(ret);

            default : /* pere execute cmdv[1] | ... en récupérant le flot de données 
						fourni par son fils, qui servira d'entrée pour cmdv[1]*/
            close(pf2p[1]);
            dup2(pf2p[0],0);
				    exec_cmd_pipe ( cmdv + 1 );
        }
    }
    else {  /* dernière commande : sans pipe */
        ret = execvp(cmdv[0][0], cmdv[0]);
        printf("Erreur execvp dernière commande\n");  /* seulement si execvp echoue */
        exit(ret);
    }
    return;
}

/**
 * @brief execute une commande soit en creant un fils soit directement par le père.
 * 
 * @param cmdv la commande à executer
 */
void executer(cmdline *cmdv){

      pidFils = fork();
      if (pidFils < 0)
      {
        printf("ERROR: fork a échoué\n");
        exit(EXIT_FAILURE);
      }
      if (pidFils == 0)
      {
        
        action.sa_handler = SIG_IGN;
        sigaction(SIGTSTP, &action, NULL); // on ignore SIGTSTP
        sigaction(SIGINT, &action, NULL);  // on ignore SIGINT
       
        if (cmdv->in)
          {
            fichier_in = open(cmd->in, O_RDONLY);
            dup2(fichier_in, 0);
          }
        if (cmdv->out)
          {
              fichier_out = open(cmdv->out, O_CREAT | O_TRUNC | O_WRONLY, 0640);
              dup2(fichier_out, 1);
          }
          exec_cmd_pipe(cmdv->seq); 
          exit(EXIT_FAILURE);

      }
      else if (pidFils > 0)
      {
        
        if (!cmdv->backgrounded)
        {    
          add(pidFils, &liste_process, *(cmdv->seq));
          avant_plan = pidFils;
          while (avant_plan)
          {
            pause();
          }
        }
        else
        {
          add(pidFils, &liste_process, *(cmdv->seq));
        }
      }
}



int main(int argc, char *argv[])
{
  // signaux
  signal(SIGCHLD, handler_SIGCHLD);
  sigemptyset(&action.sa_mask);
  action.sa_flags = SA_SIGINFO | SA_RESTART;
  action.sa_handler = handler_SIGCHLD;
  sigaction(SIGCHLD, &action, NULL);
  action.sa_handler = handler_SIGINT;
  sigaction(SIGINT, &action, NULL);
  action.sa_handler = handler_SIGTSTP;
  sigaction(SIGTSTP, &action, NULL);
  
  // initialiser la liste jobs
  initialiser(&liste_process);

  // récuperer le chemin initial
  char chemin[256];
  getcwd(chemin, sizeof(chemin));

  // boucle
  while (1)
  {
    printf(">>>");
    // lecture de la commande
    cmd = readcmd();
    // interne
    in = traitement_commande(cmd, liste_process, chemin);
    if (in == 0)
    {
      break;
    }
    else if (in == 1)
    {
      continue;
    }
    else
    {
    executer(cmd);
    }
  }
  liberer(&liste_process);
}
