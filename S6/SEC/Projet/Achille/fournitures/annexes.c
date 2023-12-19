#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>    /* Files operations */
#include "readcmd.h"
#include "liste.h"

extern List process_list;

/** Suspendre un processus. */
void stop(pid_t pid) {
    kill(pid, SIGSTOP);
    maj_status(process_list, &pid, SUSPENDED);
}

/** Reprendre un processus suspendu en arrière-plan. */
void bg(pid_t pid, List process_list) {
    kill(pid, SIGCONT);
    maj_status(process_list, &pid, ACTIVE);
}

/** Executer une commande interne */
void exec_cmd_interne (List liste, struct cmdline *cmd, int *stay) {
  if (strcmp(cmd->seq[0][0], "cd") == 0) {
  if (cmd->seq[0][1] == NULL) {
	chdir(getenv("HOME"));
    }
    else {
	if (chdir(cmd->seq[0][1]) == -1) {;
	    printf("bash: cd: %s: No such file or directory\n", cmd->seq[0][1]);
	}
}
	*stay = 2;
  }

  else if (strcmp(cmd->seq[0][0], "exit") == 0) {
	   exit(0);
  }

  else if (strcmp(cmd->seq[0][0], "lj") == 0) {
    traverser(liste);
    *stay = 2;
  }

  else if (strcmp(cmd->seq[0][0], "sj") == 0) {
    pid_t pid = atoi(cmd->seq[0][1]);
    stop(pid);
    *stay = 2;
  }

  else if (strcmp(cmd->seq[0][0], "bg") ==0) {
    pid_t pid = atoi(cmd->seq[0][1]);
    bg(pid, liste);
    *stay = 2;
  }

  else if (strcmp(cmd->seq[0][0], "fg") == 0) {
    pid_t pid = atoi(cmd->seq[0][1]);
    waitpid(pid,0,0);
    *stay = 2;
  }
  else if (strcmp(cmd->seq[0][0], "susp") == 0) {
    pid_t pid = atoi(cmd->seq[0][1]);
    stop(pid);
    *stay = 2;
  }
}
