# Validação prática do Dr. Memory

Teste executado para confirmar que a ferramenta detecta, na prática, os tipos de erro
que a documentação oficial anuncia.

## Ambiente

| Item | Valor |
| --- | --- |
| Ferramenta | Dr. Memory 2.6.20434 (build oficial, dez/2025) |
| Instalação | `.tar.gz` do GitHub, extraído e executado — sem compilação, sem `sudo` |
| Sistema | Ubuntu 24.04.4 LTS, x86_64 |
| Compilador | GCC, com `-g -O0` (símbolos de depuração) |

## O que foi testado

Um programa C de 55 linhas (`teste_memoria.c`) com **cinco defeitos de memória propositais**,
um por função, cobrindo as categorias que o Dr. Memory afirma detectar:

1. Leitura de memória não inicializada
2. Escrita fora dos limites do bloco (heap overflow)
3. Uso após liberação (use-after-free)
4. Liberação dupla (double free)
5. Vazamento de memória (memory leak)

O binário foi executado duas vezes: nativamente e sob o Dr. Memory, para comparar o que
cada cenário revela.

### Comandos

```bash
gcc -g -O0 -o teste_memoria teste_memoria.c
./teste_memoria                                    # execução nativa
drmemory -batch -logdir ./drmemory_logs -- ./teste_memoria   # sob Dr. Memory
```

## Código testado

```c
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
```

## Resultado 1 — execução nativa (sem a ferramenta)

```
free(): double free detected in tcache 2
Aborted (core dumped)          # exit code 134
```

O programa **abortou** no 4º defeito. A glibc detectou apenas o *double free*, e ainda assim
sem indicar arquivo ou linha. Os outros quatro erros passaram silenciosamente e o programa
nem chegou ao fim.

## Resultado 2 — execução sob Dr. Memory

```
~~Dr.M~~ Dr. Memory version 2.6.20434
~~Dr.M~~ WARNING: Unable to write to the disk.  Ensure that you have enough space and permissions.
~~Dr.M~~ 
~~Dr.M~~ Error #1: UNINITIALIZED READ: reading register r12
~~Dr.M~~ # 0 libc.so.6!__printf_buffer         [./stdio-common/vfprintf-process-arg.c:58]
~~Dr.M~~ # 1 libc.so.6!__vfprintf_internal     [./stdio-common/vfprintf-internal.c:1544]
~~Dr.M~~ # 2 libc.so.6!__printf                [./stdio-common/printf.c:33]
~~Dr.M~~ # 3 main                              [teste_memoria.c:48]
~~Dr.M~~ Note: @0:00:00.871 in thread 34943
~~Dr.M~~ Note: instruction: test   %r12 %r12
~~Dr.M~~ 
~~Dr.M~~ Error #2: UNADDRESSABLE ACCESS beyond heap bounds: writing 0x000079201b2011f8-0x000079201b2011f9 1 byte(s)
~~Dr.M~~ # 0 estouro_de_buffer               [teste_memoria.c:21]
~~Dr.M~~ # 1 main                            [teste_memoria.c:49]
~~Dr.M~~ Note: @0:00:00.896 in thread 34943
~~Dr.M~~ Note: refers to 0 byte(s) beyond last valid byte in prior malloc
~~Dr.M~~ Note: prev lower malloc:  0x000079201b2011f0-0x000079201b2011f8
~~Dr.M~~ Note: instruction: mov    $0x00 -> (%rax)
~~Dr.M~~ 
~~Dr.M~~ Error #3: UNADDRESSABLE ACCESS of freed memory: reading 0x000079201b201220-0x000079201b201224 4 byte(s)
~~Dr.M~~ # 0 uso_apos_free               [teste_memoria.c:30]
~~Dr.M~~ # 1 main                        [teste_memoria.c:50]
~~Dr.M~~ Note: @0:00:00.897 in thread 34943
~~Dr.M~~ Note: 0x000079201b201220-0x000079201b201224 overlaps memory 0x000079201b201220-0x000079201b201224 that was freed here:
~~Dr.M~~ Note: # 0 replace_free                [/home/runner/work/drmemory/drmemory/common/alloc_replace.c:2712]
~~Dr.M~~ Note: # 1 uso_apos_free               [teste_memoria.c:29]
~~Dr.M~~ Note: # 2 main                        [teste_memoria.c:50]
~~Dr.M~~ Note: instruction: mov    (%rax) -> %eax
~~Dr.M~~ 
~~Dr.M~~ Error #4: INVALID HEAP ARGUMENT to free 0x000079201b201250
~~Dr.M~~ # 0 replace_free                  [/home/runner/work/drmemory/drmemory/common/alloc_replace.c:2712]
~~Dr.M~~ # 1 liberacao_dupla               [teste_memoria.c:37]
~~Dr.M~~ # 2 main                          [teste_memoria.c:51]
~~Dr.M~~ Note: @0:00:00.904 in thread 34943
~~Dr.M~~ Note: memory was previously freed here:
~~Dr.M~~ Note: # 0 replace_free                  [/home/runner/work/drmemory/drmemory/common/alloc_replace.c:2712]
~~Dr.M~~ Note: # 1 liberacao_dupla               [teste_memoria.c:36]
~~Dr.M~~ Note: # 2 main                          [teste_memoria.c:51]
resultado: 1
valor lido apos free: 0
fim do programa
~~Dr.M~~ 
~~Dr.M~~ Error #5: LEAK 64 direct bytes 0x000079201b201280-0x000079201b2012c0 + 0 indirect bytes
~~Dr.M~~ # 0 replace_malloc               [/home/runner/work/drmemory/drmemory/common/alloc_replace.c:2582]
~~Dr.M~~ # 1 vazamento                    [teste_memoria.c:42]
~~Dr.M~~ # 2 main                         [teste_memoria.c:52]
~~Dr.M~~ 
~~Dr.M~~ ERRORS FOUND:
~~Dr.M~~       2 unique,     2 total unaddressable access(es)
~~Dr.M~~       1 unique,     1 total uninitialized access(es)
~~Dr.M~~       1 unique,     1 total invalid heap argument(s)
~~Dr.M~~       0 unique,     0 total warning(s)
~~Dr.M~~       1 unique,     1 total,     64 byte(s) of leak(s)
~~Dr.M~~       0 unique,     0 total,      0 byte(s) of possible leak(s)
~~Dr.M~~ ERRORS IGNORED:
~~Dr.M~~       1 unique,     1 total,   4096 byte(s) of still-reachable allocation(s)
~~Dr.M~~          (re-run with "-show_reachable" for details)
~~Dr.M~~ Details: drmemory_logs/DrMemory-teste_memoria.34943.000/results.txt
```

## Análise

**Os 5 defeitos foram detectados**, cada um com o tipo do erro, o endereço, a pilha de
chamadas e o **número da linha exata** no código-fonte. O programa **não abortou**: o
Dr. Memory substitui o alocador da libc, então o *double free* foi reportado como
`INVALID HEAP ARGUMENT` e a execução seguiu até o fim — permitindo encontrar o vazamento
de memória, que na execução nativa nunca seria alcançado.

Mapeamento entre defeito e diagnóstico:

| # | Defeito plantado | Linha | Diagnóstico do Dr. Memory |
| --- | --- | --- | --- |
| 1 | Leitura não inicializada | 13 | `UNINITIALIZED READ` |
| 2 | Escrita 1 byte além do bloco | 21 | `UNADDRESSABLE ACCESS beyond heap bounds` |
| 3 | Leitura após `free()` | 30 | `UNADDRESSABLE ACCESS of freed memory` (+ pilha de onde foi liberado) |
| 4 | `free()` duplo | 37 | `INVALID HEAP ARGUMENT` (+ pilha da 1ª liberação) |
| 5 | 64 bytes nunca liberados | 42 | `LEAK 64 direct bytes` |

**Observação sobre o erro #1:** o Dr. Memory apontou a pilha dentro do `printf` da libc,
chegando ao `main` na linha 48, e não diretamente na linha 13. Isso é o comportamento
esperado da técnica: valores não inicializados são propagados e só reportados no ponto em
que afetam de fato o comportamento do programa (aqui, ao serem impressos). É um detalhe que
exige interpretação de quem lê o relatório — a linha apontada nem sempre é a origem do bug.

## Custo de desempenho medido

| Cenário | Nativo | Sob Dr. Memory | Overhead |
| --- | --- | --- | --- |
| Custo fixo de inicialização (`hello world`) | 0,001 s | 0,39 s | — (~0,4 s fixos) |
| Laço com cálculo, 200M iterações | 0,509 s | 6,99 s | **≈ 14×** |
| Laço com 3M pares `malloc`/`free` | 0,047 s | 99,4 s | **≈ 2 100×** |

Medições com 3 execuções por cenário, menor tempo considerado.

O overhead **depende fortemente do perfil do programa**. Para código com cálculo, ficou em
~14×, próximo da faixa de 5–10× citada na literatura. Já para código dominado por alocação
e liberação, o custo explodiu para ~2 100×, porque o Dr. Memory grava a pilha de chamadas
a cada `malloc`. É um dado relevante: em programas que alocam muito, o teste sob a
ferramenta pode se tornar inviável em tempo.

## Conclusão da validação

A ferramenta **funciona como anunciado** e é fácil de adotar:

- Instalação em menos de um minuto — baixar, extrair, executar. Sem `sudo`, sem compilar.
- Roda sobre o **binário já compilado**, sem qualquer alteração no código-fonte.
- Detectou 100% dos defeitos plantados, com linha e pilha de chamadas.
- Continua a execução após erros fatais, encontrando problemas que a execução nativa não alcança.

Confirma-se também a principal desvantagem: o **custo de desempenho é alto e imprevisível**,
variando de ~14× a mais de 2 000× conforme o padrão de alocação do programa.

## Arquivos gerados

| Arquivo | Conteúdo |
| --- | --- |
| `teste_memoria.c` | Programa C com os 5 defeitos |
| `saida_drmemory.txt` | Saída completa do Dr. Memory |
| `bench.c`, `cpu.c`, `hello.c` | Programas usados na medição de overhead |
| `drmemory_logs/` | Logs detalhados gerados pela ferramenta |
