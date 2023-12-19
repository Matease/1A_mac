#include "readcmd.h"
#include "annexes.h"
#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <string.h>   /* opérations sur les chaines */
#include "liste.h"
#include <signal.h>


pid_t fils;
List process_list;
int id;
int status_fils;

void handler_SIGINT() {
  kill(fils,SIGKILL);
  process_list = supp_elem(process_list, &fils);
}

void handler_SIGTSTP() {
  kill(fils,SIGSTOP);
  process_list = supp_elem(process_list, &fils);
}

int main() {

  int stay = 1; //variable gérant la sortie du minishell
  struct cmdline  *cmd;

  process_list = new_list();
  id = 1;

  signal(SIGINT, &handler_SIGINT);
  signal(SIGTSTP, &handler_SIGTSTP);

  while (stay) {
    while (cmd->seq[0] == NULL) {
      write(1, "$>", 4);
      cmd = readcmd();
    }
    exec_cmd_interne(process_list, cmd, &stay);
    if (stay == 2) {
	    stay = 1;
	    continue;
	   }

     fils = fork();
     if (fils < 0) {
       printf("Error: fork failed.\n");
	     exit(1);
     }
     else if (fils == 0) {
       if (cmd->seq[1] == NULL) {
         if (execvp(cmd->seq[0][0], cmd->seq[0]) < 0) {
		       printf("%s: command not found\n", cmd->seq[0][0]);
		       exit(1);
		     }
       }
     }
     exit(0);
  }
  return -1;
}
