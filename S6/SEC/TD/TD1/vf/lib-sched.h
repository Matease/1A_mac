

typedef ucontext_t thread_state;

thread_state *create_thread_context(void (*thread)());

void switch_thread(thread_state *old, thread_state *new);

void install_tick_handler(void (*schedule)());

void generate_tick();



