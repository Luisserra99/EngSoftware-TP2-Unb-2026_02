/*
 * teste_memoria.c -- programa de validacao do Dr. Memory
 * Contem 5 defeitos de memoria propositais, um por funcao.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* 1. Leitura de memoria nao inicializada */
static int leitura_nao_inicializada(void) {
    int *v = (int *)malloc(sizeof(int));
    int r = *v + 1;              /* le antes de atribuir */
    free(v);
    return r;
}

/* 2. Escrita fora dos limites do bloco (heap overflow) */
static void estouro_de_buffer(void) {
    char *buf = (char *)malloc(8);
    memset(buf, 'A', 8);
    buf[8] = '\0';               /* 1 byte alem do bloco de 8 */
    free(buf);
}

/* 3. Uso apos liberacao (use-after-free) */
static void uso_apos_free(void) {
    int *p = (int *)malloc(sizeof(int));
    *p = 42;
    free(p);
    printf("valor lido apos free: %d\n", *p);   /* acesso invalido */
}

/* 4. Liberacao dupla (double free) */
static void liberacao_dupla(void) {
    char *p = (char *)malloc(16);
    free(p);
    free(p);                     /* segunda liberacao */
}

/* 5. Vazamento de memoria (memory leak) */
static void vazamento(void) {
    char *p = (char *)malloc(64);
    strcpy(p, "bloco de 64 bytes nunca liberado");
    /* faltou free(p) */
}

int main(void) {
    printf("resultado: %d\n", leitura_nao_inicializada());
    estouro_de_buffer();
    uso_apos_free();
    liberacao_dupla();
    vazamento();
    printf("fim do programa\n");
    return 0;
}
