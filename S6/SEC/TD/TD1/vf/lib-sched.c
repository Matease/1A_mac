
#include <stdio.h>
#include <setjmp.h>
#include <signal.h>
#include <stdlib.h>
#include <ucontext.h>
#include <unistd.h>
#include "lib-sched.h"

#define STACK_SIZE 16384
#define TIME_SLICE 4


void (*scheduler)();

void handler(int sig) {
	alarm(TIME_SLICE);
	scheduler();
}

void generate_tick() {
	kill(getpid(), SIGALRM);
}

thread_state *create_thread_context(void (*thread)()) {
	thread_state *thread_save = malloc(sizeof(ucontext_t));
	if (thread_save == NULL) { perror("malloc"); exit(1); }
	if (getcontext(thread_save) == -1) { perror("getcontext"); exit(1); }
        thread_save->uc_stack.ss_sp = malloc(STACK_SIZE);
	thread_save->uc_stack.ss_size = STACK_SIZE;
        thread_save->uc_link = NULL;
        makecontext(thread_save, thread, 0);
	return thread_save;
}

void switch_thread(thread_state *old, thread_state *new) {
	if (swapcontext(old, new) == -1) { perror("swapcontext"); exit(0); }
}

void install_tick_handler(void (*schedule)()) {
	signal(SIGALRM, handler);
	alarm(TIME_SLICE);
	scheduler = schedule;
}
	




