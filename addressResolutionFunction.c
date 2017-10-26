#include <stdio.h>
#include <stdlib.h>

const int levels = 4;
const int offsetSize = 8;
const int pteBitSize = 64;
const int pageSize = 2048;
long *rootTable;

long *resolve(long num) {
    // create masks
    char baseMaskChar = -1;
    long baseMask = (long) baseMaskChar;
    
    // extract offsets from num
    long offsets[levels+1] = {0};
    for(int i = 0; i < levels+1; i++) {
        offsets[i] = (num>>(offsetSize*i))&baseMask;
    }
    
    // follow the page tables and allocate a new table if necessary
    long *cur = rootTable;
    for (int i = levels; i >= 0; i--) {
        cur += offsets[i];
        if (i != 0) { // follow the entry if i != 0 (if the current page contains a table)
            if(*cur == 0) {
                *cur = (long) calloc(pageSize, sizeof(char));
            }
            cur = (long *) *cur;
        }
    }
    return cur;
}

int main() {
    rootTable = calloc(pageSize, sizeof(char));
    printf("Address for location 0: %p", resolve(0));
}
