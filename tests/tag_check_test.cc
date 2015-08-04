// See LICENSE for license details.

#include "env/tag.h"
#include <stdio.h>
#include <stdlib.h>

#define VECT_SIZE 10 //1<<9

main() {

  long a[VECT_SIZE], i;

  //set the csr to define load tag behaviour
  int load_csr = 0;			// trap on 00,01,10,11
  int store_csr = 00;			// 0b1010 trap on tag 01, 11
  read_write_load_csr(load_csr);
  read_write_store_csr(store_csr);
  
  for(i=0; i<VECT_SIZE; i++) {
    //*(a+i) = rand() % (1 << TAG_WIDTH);
    *(a+i) = i % (1 << TAG_WIDTH);
    store_tag((a+i), a[i]);
  }
  
  for(i=0; i<VECT_SIZE; i++) {
    void *location = a+i;
    int tag = load_tag(location);
    printf("------------------Location 0x%x, tag %d\n", location, tag);
    if((load_csr >> tag) & 1) 
	printf("The next load should trap:\n");
    int payload = tag_check_and_load(location);
    //printf("tag at %d is %d\n", i, tag);

    //now try to store to it with tag checks:
    if((store_csr >> tag) & 1)
	printf("The next store should trap:\n");
    tag_check_and_store(location,a[i]);
  }
  printf("Tag load and store tests passed.\n");
}
