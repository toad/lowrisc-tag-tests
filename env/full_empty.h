/**
 * Library with helper functions for the full - empty usecase
 */

#include"tag.h"

inline long load_when_full(void *addr) {
        long result = tag_check_and_load(addr);
        store_tag(addr, 0);
	return result;
}

inline void store_and_set_full(void *addr, long value) {
	tag_check_and_store(addr, value);
	store_tag(addr, 1);
}

inline void setup_exceptions() {
	read_write_load_csr(1);		// trap on tag 00
					// atm trap means busy lock
	read_write_store_csr(0); 	// don't trap for now
}
