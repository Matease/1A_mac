#include "readcmd.h"
#include "annexes.h"
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <string.h>
#include "liste.h"
#include <signal.h>

pid_t pid_fils;
List processus_list;
int id_processus;
int statut_fils;

void SIGINT_handler() {
  kill (pid_fils, SIGKILL);
 processus_list = supp_elem ( processus_list,  &pid_fils);
}

void SIGTSTP_handler() {
  kill (pid_fils, SIGSTOP);
 processus_list = supp_elem ( processus_list,  &pid_fils);
}

int main() {
  int running = 1; // Variable gérant la sortie du minishell
  struct cmdline *cmd = NULL; // Initialize cmd pointer to avoid segmentation fault

 processus_list = new_list();
 id_processus = 1;

  signal(SIGINT, SIGINT_handler);
  signal(SIGTSTP, SIGTSTP_handler);

  while (running) {
    while (cmd == NULL || cmd->seq[0] == NULL) {
      write(1, "$>", 4);
      cmd = readcmd();
    }

    exec_cmd_interne (processus_list, cmd, &running);

    if (running == 2) {
      running = 1;
      continue;
    }

    pid_fils = fork();
    if (pid_fils < 0) {
      printf("Erreur: le fork a échoué.\n");
      exit(1);
    } else if (pid_fils == 0) {
      if (cmd->seq[1] == NULL) {
        if (execvp(cmd->seq[0][0], cmd->seq[0]) < 0) {
          printf("%s: commande non trouvée\n", cmd->seq[0][0]);
          exit(1);
        }
      }
    }
    exit(0);
  }

  return -1;
}
