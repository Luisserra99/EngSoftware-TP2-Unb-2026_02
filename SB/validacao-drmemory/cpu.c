#include <stdio.h>
#include <stdlib.h>
int main(void) {
    int n = 200000000; double s = 0;
    double *a = malloc(sizeof(double) * 1000);
    for (int i = 0; i < 1000; i++) a[i] = i * 0.5;
    for (int i = 0; i < n; i++) s += a[i % 1000] * 1.000001;
    free(a);
    printf("%.2f\n", s); return 0;
}
