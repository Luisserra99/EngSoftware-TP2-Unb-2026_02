#include <stdlib.h>
int main(void) {
    long s = 0;
    for (int i = 0; i < 3000000; i++) { int *p = malloc(16); *p = i; s += *p; free(p); }
    return (int)(s & 1);
}
