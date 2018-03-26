// Copyright (c) 2013-2016 Bluespec, Inc. All Rights Reserved

extern uint64_t  c_malloc_and_init (uint64_t n_bytes, uint64_t init_from_file);

extern uint64_t c_get_start_pc (void);

extern uint64_t c_get_min_addr (void);
extern uint64_t c_get_max_addr (void);

extern uint64_t c_get_min_text_addr (void);
extern uint64_t c_get_max_text_addr (void);

extern uint64_t  c_read (uint64_t addr, uint64_t n_bytes);

extern void c_write (uint64_t addr, uint64_t x, uint64_t n_bytes);

extern void c_get_console_command (uint64_t *cmd_vec);
