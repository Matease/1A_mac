#ifndef _COMMAND_PROCESS_H_
#define _COMMAND_PROCESS_H_
#include "readcmd.h"
#include <sys/types.h>
#include "liste.h"

/** Suspendre un processus. */
void stop(pid_t pid);

/** Reprendre un processus suspendu en arrière-plan. */
void bg(pid_t pid);

/** Executer une commande interne */
void exec_cmd_interne (List liste, struct cmdline *cmd, int *stay);

#endif
