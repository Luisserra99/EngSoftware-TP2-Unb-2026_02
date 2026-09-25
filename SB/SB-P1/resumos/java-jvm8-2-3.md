# JVM 8 — Parte 2 de 3: O Interpretador e o Conjunto de Instruções

> Resumo didático do arquivo `/home/luis/unb/SB/java-jvm8-2-3.pdf` (34 páginas, slides 33 a 65).
> Baseado em *The Java Virtual Machine Specification*, 2nd Edition — Tim Lindholm & Frank Yellin.
> Disciplina: Software Básico (CIC0104 / UnB).

> 🔎 **Revisão Java 8** — o PDF se chama `java-jvm8`, mas o texto vem da **2ª edição** da JVMS
> (Java 2). A prova cobre **Java SE 8 / JVMS 8**. O conjunto de instruções mudou pouco entre as duas
> edições — a exceção relevante é `invokedynamic`. Divergências marcadas com 🟦/🟪/🟥; apanhado em
> [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).

---

## ⚠️ Aviso importante sobre o escopo deste PDF

A parte 2 **não** trata de carregamento/ligação/iniciação de classes, `invokevirtual`/`invokespecial`,
tratamento de exceções ou encerramento da JVM. Esses assuntos estão distribuídos assim na série:

| Assunto | Onde está |
|---|---|
| Estrutura da JVM, frames, pilhas, área de métodos, `<init>`/`<clinit>`, ordem de execução de blocos estáticos e construtores | **Parte 1** (slides 1–32) |
| Interpretador, formato das instruções, `tableswitch`/`lookupswitch`, tipos, carga/armazenamento, aritmética (soma…negação) | **Parte 2 — este resumo** (slides 33–65) |
| Shift, lógicas bit a bit, `iinc`, conversões, criação de objetos, pilha, desvios, **invocação e retorno de métodos**, exceções, `synchronized` | **Parte 3** (slides 66 em diante) |

Mesmo assim, incluí ao final um apêndice com a **ordem de execução `<clinit>`/bloco de instância/construtor**
(slide 32 da parte 1), porque é a pegadinha clássica de prova e foi pedida explicitamente.

---

## Sumário

1. [O que você precisa saber para a prova](#1-o-que-você-precisa-saber-para-a-prova)
2. [O interpretador da JVM: o laço de execução](#2-o-interpretador-da-jvm-o-laço-de-execução)
3. [Anatomia de uma instrução: opcode + operandos](#3-anatomia-de-uma-instrução-opcode--operandos)
4. [Alinhamento e as duas instruções especiais](#4-alinhamento-e-as-duas-instruções-especiais)
5. [`tableswitch` em detalhe](#5-tableswitch-em-detalhe)
6. [`lookupswitch` em detalhe](#6-lookupswitch-em-detalhe)
7. [`tableswitch` × `lookupswitch`: quando o compilador escolhe cada um](#7-tableswitch--lookupswitch-quando-o-compilador-escolhe-cada-um)
8. [Tipos e a JVM: a letra de prefixo](#8-tipos-e-a-jvm-a-letra-de-prefixo)
9. [O template `T` e a tabela-sumário do conjunto de instruções](#9-o-template-t-e-a-tabela-sumário-do-conjunto-de-instruções)
10. [Mapeamento dos tipos de Java nos tipos da JVM e as categorias 1 e 2](#10-mapeamento-dos-tipos-de-java-nos-tipos-da-jvm-e-as-categorias-1-e-2)
11. [Instruções que operam por categoria: `pop`, `pop2`, `swap`](#11-instruções-que-operam-por-categoria-pop-pop2-swap)
12. [Instruções de carga e armazenamento](#12-instruções-de-carga-e-armazenamento)
13. [A instrução `wide`](#13-a-instrução-wide)
14. [Carga de constantes na pilha de operandos](#14-carga-de-constantes-na-pilha-de-operandos)
15. [Instruções aritméticas](#15-instruções-aritméticas)
16. [Apêndice A — ordem de execução `<clinit>`, blocos e construtores](#apêndice-a--ordem-de-execução-clinit-blocos-e-construtores)
17. [Apêndice B — tabela de opcodes vistos na parte 2](#apêndice-b--tabela-de-opcodes-vistos-na-parte-2)
18. [Resumo em 10 pontos](#resumo-em-10-pontos)

---

## 1. O que você precisa saber para a prova

Esta é a lista mínima de itens que a parte 2 cobra. Se você souber responder a todos estes pontos,
está preparado:

1. **O laço do interpretador**: `busca opcode → busca operandos (se houver) → executa → repete`.
   Saber que ele é descrito *ignorando* o tratamento de exceções.
2. **Por que o opcode tem apenas 1 byte** e por que o conjunto de instruções **não é ortogonal**
   (o tipo está embutido no opcode, então há várias instruções para a "mesma" operação).
3. **Ordem dos bytes**: operandos maiores que 1 byte são armazenados em **big-endian**
   (byte mais significativo primeiro). Fórmulas: 16 bits = `(byte1 << 8) | byte2`;
   32 bits = `(byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4`.
4. **Alinhamento**: todas as instruções são alinhadas por **byte**, exceto `tableswitch` e
   `lookupswitch`, que usam **0 a 3 bytes de padding (nulos)** para alinhar o primeiro operando
   em fronteira de 4 bytes.
5. **Layout completo do `tableswitch`** (default, low, high, `high-low+1` offsets) e do
   **`lookupswitch`** (default, npairs, pares `<match><offset>` **ordenados por match crescente**).
6. **Como calcular o alvo (target)** de um switch: o offset é **relativo ao endereço da própria
   instrução** de switch (dentro do método), não ao início do método e não à próxima instrução.
7. **Letras de prefixo de tipo**: `i l s b c f d a` e o que cada uma significa (`a` = referência).
8. **Mapeamento Java → JVM**: `boolean`, `byte`, `char`, `short` viram **`int`** na JVM.
   Só existem operações aritméticas para `int`, `long`, `float`, `double`.
9. **Extensão de sinal × extensão de zero**: `byte` e `short` → `int` com **extensão de sinal**;
   `char` e `boolean` → `int` com **extensão de zero**.
10. **Categoria 1 × categoria 2**: `long` e `double` são categoria 2 (ocupam 2 posições);
    todo o resto, inclusive `reference` e `returnAddress`, é categoria 1.
11. **Famílias com `<n>` implícito** (`iload_0`…`iload_3`, `iconst_m1`…`iconst_5`, etc.) e por que
    elas existem (economia de espaço: 1 byte em vez de 2).
12. **`ldc` × `ldc_w` × `ldc2_w`**: índice de 8 bits, de 16 bits e de 16 bits para `long`/`double`.
    **Não existe `ldc2` com índice de 8 bits.**
13. **`wide`**: estende o índice de variável local para 2 bytes; lista de opcodes que ela aceita;
    forma especial para `iinc`.
14. **Por que `aload` não pode carregar um `returnAddress`** (pergunta explícita do slide 50).
15. **Aritmética**: nomes, efeito na pilha (`..., value1, value2 → ..., result`), fórmula do resto
    (`value1 - (value1 / value2) * value2`, com truncamento) e o fato de que **resto e negação
    também existem para ponto flutuante**.

---

## 2. O interpretador da JVM: o laço de execução

A JVM é, conceitualmente, uma máquina de pilha interpretada. O slide 33 descreve o ciclo interno:

```c
do {
    busque um opcode;
    if (operandos) busque operandos;
    execute a ação associada ao opcode;
} while (!fim);
```

Em português: o interpretador lê 1 byte (o **opcode**) apontado pelo **`pc` (program counter)** do
frame corrente, descobre quantos e quais operandos aquele opcode exige, lê esses operandos do
**bytecode** (não da pilha!), executa a ação e avança.

```
        +------------------ bytecode do método -------------------+
 pc --> | 1A | 1B | 60 | 3C | AA | 00 | 00 | 00 | 21 | ...         |
        +---------------------------------------------------------+
          ^    ^    ^
          |    |    +-- iadd   (0 operandos no bytecode)
          |    +------- iload_1
          +------------ iload_0
```

> ⚠️ **Pegadinha de prova**
> O laço acima é apresentado **"ignorando a execução de exceções"**. Ou seja, ele é uma
> *simplificação*. O tratamento de exceções acrescenta um passo: se a execução da ação lançar
> exceção, o interpretador procura um manipulador na tabela de exceções do método corrente e,
> **se não encontrar, o frame corrente é desempilhado e a busca continua no método chamador** —
> o programa **não** encerra imediatamente. A JVM só termina abruptamente quando a propagação
> chega ao topo da pilha da thread sem nenhum manipulador. (Esse mecanismo é detalhado na parte 3.)

> ⚠️ **Pegadinha de prova**
> Dois "apontadores" diferentes convivem: o **`pc`**, que percorre o bytecode e é de onde vêm os
> **operandos imediatos**, e o **topo da pilha de operandos**, de onde vêm os **valores**.
> Questão típica: "os operandos de `iadd` vêm do bytecode" → **FALSO** (vêm da pilha de operandos).
> "Os operandos de `bipush` vêm do bytecode" → **VERDADEIRO**.

---

## 3. Anatomia de uma instrução: opcode + operandos

Cada instrução da JVM é composta de (slide 34):

- **um byte de opcode** especificando a operação;
- **zero ou mais operandos** representando argumentos ou dados usados na operação.

Regras:

- **O número e o tamanho dos operandos são determinados pelo opcode.** Não há campo de "tamanho";
  o decodificador sabe, a partir do byte de opcode, quantos bytes seguem.
- Se um operando ocupa **mais de um byte**, é armazenado em ordem **big-endian**
  (byte mais significativo primeiro).
  - Operando de 16 bits: `(byte1 << 8) | byte2`
  - Operando de 32 bits: `(byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4`
    (os bytes são tratados como **sem sinal** nessa montagem; o resultado é que tem sinal)
- As instruções são **alinhadas por byte** — isto é, começam em qualquer endereço.

### Por que apenas 1 byte de opcode?

Pergunta do próprio slide 34: *"Qual a razão de apenas um byte para código de operação?
Como a JVM sabe quais os tipos dos operandos?"*

**Resposta:** compacidade. O bytecode foi projetado para ser transmitido em rede e ocupar pouco
espaço; 1 byte permite no máximo 256 opcodes, o que bastou. E a JVM sabe os tipos porque **o tipo
está codificado no próprio opcode** (`iadd` soma ints, `dadd` soma doubles). O preço disso é que o
conjunto de instruções **não é ortogonal**: em vez de uma instrução `add` genérica + um descritor de
tipo, existem quatro instruções de soma distintas.

> ⚠️ **Pegadinha de prova**
> O slide 41 provoca: *"O conjunto de instruções da JVM não é ortogonal. Se fosse, apenas um byte
> de opcode seria suficiente?"* — **Não**. Um conjunto totalmente ortogonal (toda operação para todo
> tipo) exigiria muito mais combinações e/ou um campo de tipo separado. A não-ortogonalidade é
> justamente o que permitiu caber em 1 byte. Afirmação "a JVM tem um conjunto de instruções
> ortogonal" → **FALSO**.

---

## 4. Alinhamento e as duas instruções especiais

> Todas as instruções são alinhadas por byte, **exceto `tableswitch` e `lookupswitch`**.

Essas duas acessam tabelas de saltos e precisam que seus operandos de 32 bits fiquem em fronteira de
4 bytes (para leitura eficiente de palavras). Por isso o compilador insere de **0 a 3 bytes NULOS de
preenchimento (padding)** logo após o opcode.

```
 ... | AA |  pad  |    default    |     low       |     high      | off[0] | off[1] | ...
      ^     0..3        4 bytes        4 bytes        4 bytes
      |     bytes
      +-- endereço do opcode; o padding faz o PRÓXIMO campo cair em múltiplo de 4
```

| Instrução | Opcode | Estratégia de busca | Padding |
|---|---|---|---|
| `tableswitch` | `0xAA` (170) | **índice direto** na tabela de offsets | 0–3 bytes nulos |
| `lookupswitch` | `0xAB` (171) | **batimento de chave** (busca por `match`) | 0–3 bytes nulos |

> ⚠️ **Pegadinha de prova**
> "Todas as instruções da JVM são alinhadas por byte" → **FALSO** (ou, no mínimo, incompleto):
> `tableswitch` e `lookupswitch` são as exceções. E o padding é de **0 a 3** bytes — pode ser zero,
> quando o opcode já cai numa posição conveniente.

> ⚠️ **Pegadinha de prova**
> A quantidade de padding **não é fixa**: depende do endereço em que a instrução caiu dentro do
> método. Portanto o **tamanho em bytes** de um `tableswitch` não é constante, nem entre métodos
> nem entre compilações. Isso implica que não dá para calcular o tamanho da instrução só pelo opcode.

---

## 5. `tableswitch` em detalhe

### Formato (slides 35 e 36)

```
0xAA                  /* opcode */
0 a 3 bytes           /* padding: alinha os bytes a seguir em múltiplo de 4 a partir daqui */
32 bits signed        /* default – usado para calcular o target default        */
32 bits signed        /* low     – índice inferior da tabela de offsets        */
32 bits signed        /* high    – índice superior da tabela de offsets        */
x offsets             /* x = high - low + 1 offsets de 32 bits com sinal       */
```

Byte a byte, como aparece no `.class`:

```
tableswitch opcode        (0xAA)
<0-3 byte pad>
defaultbyte1
defaultbyte2
defaultbyte3
defaultbyte4
lowbyte1
lowbyte2
lowbyte3
lowbyte4
highbyte1
highbyte2
highbyte3
highbyte4
jump offsets...           (high - low + 1 offsets, 4 bytes cada)
```

### Efeito na pilha de operandos

```
..., index  →  ...
```

Ou seja: **desempilha** o índice (um `int`) e não empilha nada. É uma instrução de desvio puro.

### Semântica

```
se (index < low) ou (index > high):
        target = default + endereço_do_opcode_tableswitch
senão:
        target = offset[index - low] + endereço_do_opcode_tableswitch
```

> ⚠️ **Pegadinha de prova**
> O `target` é um offset **em relação ao endereço da instrução `tableswitch`** dentro do método —
> **não** em relação ao início do método e **não** em relação à instrução seguinte.
> Os slides 36 e 39 formulam assim: *"Próxima instrução a ser executada tem endereço
> `target + endereço da instrução atual`"*.
> (Atenção à pegadinha dentro da pegadinha: o comentário do slide 36 diz "a partir do início do
> método" ao falar do **padding**; o alinhamento é medido a partir do início do código do método,
> mas o **cálculo do desvio** é relativo ao opcode do switch.)

> ⚠️ **Pegadinha de prova**
> `index` é **sempre do tipo `int`**. Não existe `tableswitch` para `long`, `float`, `double` ou
> `String` no nível de bytecode. Um `switch` sobre `String` em Java-fonte é compilado como
> `hashCode()` + `lookupswitch` + comparações `equals`; um `switch` sobre `enum` usa o
> `ordinal()` (int). Afirmação "a JVM tem instrução de switch para strings" → **FALSO**.
>
> 🟦 **Divergência Java 8 (nível da linguagem, não do bytecode)** — o `switch` sobre `enum` só existe
> desde o **Java 5** e sobre `String` desde o **Java 7**. Os slides da IBM (Java 1.4) dizem que
> `switch` só aceita `byte`, `short`, `char` e `int`; **no Java 8 ele também aceita `enum` e
> `String`** (e continua **não** aceitando `long`, `float`, `double` e `boolean`).
> No **bytecode**, porém, nada mudou: o índice de `tableswitch`/`lookupswitch` é **sempre `int`** —
> os dois casos novos são açúcar sintático que o `javac` desmonta em `int`.

### Exemplo concreto (slide 37)

```java
int chooseNear(int i) {
    switch (i) {
        case 0:  return 0;
        case 1:  return 1;
        case 2:  return 2;
        default: return -1;
    }
}
```

Bytecode:

```
Method int chooseNear(int)
 0 iload_1               // empilha a variável local 1 (o argumento i)
 1 tableswitch 0 to 2:   // índices válidos são 0 até 2
       0: 28             // se i == 0, continua em 28
       1: 30             // se i == 1, continua em 30
       2: 32             // se i == 2, continua em 32
       default: 34       // caso contrário, continua em 34
28 iconst_0              // i era 0; empilha a constante int 0...
29 ireturn               //   ...e retorna
30 iconst_1              // i era 1; empilha a constante int 1...
31 ireturn               //   ...e retorna
32 iconst_2              // i era 2; empilha a constante int 2...
33 ireturn               //   ...e retorna
34 iconst_m1             // caso contrário empilha a constante int -1...
35 ireturn               //   ...e retorna
```

### O que está gravado no arquivo `.class` (figura do slide 37, reproduzida)

O slide mostra um dump hexadecimal com os campos destacados em amarelo. Reconstruindo:

```
Deslocamento no método   Campo               Valor em hexa        Valor decimal
---------------------------------------------------------------------------------
  0                      iload_1             1A                   -
  1                      tableswitch         AA                   -
  2..                    padding             00 00                (para alinhar)
  -                      default             00 00 00 21          33
  -                      low                 00 00 00 00           0
  -                      high                00 00 00 02           2
  -                      offset do case 0    00 00 00 1B          27
  -                      offset do case 1    00 00 00 1D          29
  -                      offset do case 2    00 00 00 1F          31
```

Legenda do slide (lado direito, sobre fundo azul):

```
33 (21h) – default
00 – low
02 – high
0 ~ 27 (1Bh)
1 ~ 29 (1Dh)
2 ~ 31 (1Fh)
```

**Conferindo a aritmética** (o `tableswitch` está no endereço 1 do método):

| Caso | Offset gravado | + endereço do opcode | = alvo | Bate com o disassembly? |
|---|---|---|---|---|
| `case 0` | 27 (0x1B) | + 1 | **28** | sim (`28 iconst_0`) |
| `case 1` | 29 (0x1D) | + 1 | **30** | sim (`30 iconst_1`) |
| `case 2` | 31 (0x1F) | + 1 | **32** | sim (`32 iconst_2`) |
| `default` | 33 (0x21) | + 1 | **34** | sim (`34 iconst_m1`) |

> ⚠️ **Pegadinha de prova**
> Confundir o **valor mostrado pelo disassembler** (28, 30, 32, 34 — já são endereços absolutos
> dentro do método) com o **valor gravado no arquivo** (27, 29, 31, 33 — offsets relativos) é o
> erro mais comum nesses exercícios. A diferença é exatamente o endereço do opcode do switch (1).

> ⚠️ **Pegadinha de prova**
> A tabela de `tableswitch` tem **`high - low + 1`** entradas, e não `high - low`.
> No exemplo: `2 - 0 + 1 = 3` offsets. Se o `switch` tivesse `case 0, case 2` (sem o 1), o
> compilador ainda geraria **3** entradas, com a do índice 1 apontando para o `default` —
> a tabela do `tableswitch` **não pode ter buracos**.

---

## 6. `lookupswitch` em detalhe

### Formato (slides 38 e 39)

```
0xAB                /* opcode */
0 a 3 bytes         /* padding: alinha os bytes a seguir em múltiplo de 4 a partir daqui */
32 bits signed      /* default – usado para calcular o target default   */
32 bits signed      /* npairs  – número de pares da tabela de offsets   */
npairs pares        /* cada par tem a forma <match><offset>             */
```

Byte a byte:

```
lookupswitch opcode       (0xAB)
<0-3 byte pad>
defaultbyte1
defaultbyte2
defaultbyte3
defaultbyte4
npairs1
npairs2
npairs3
npairs4
pares match-offset        (pares de 4 + 4 bytes, ORDENADOS por match crescente)
```

### Efeito na pilha

```
..., key  →  ...
```

### Semântica

```
se nenhum match casa com key:
        target = default + endereço_do_opcode_lookupswitch
senão:
        target = offset_associado_ao_match_casado + endereço_do_opcode_lookupswitch
```

### Comentários do slide

- `npairs` é um inteiro **maior ou igual a zero** (pode haver um `lookupswitch` sem nenhum par!).
- `match` e `key` são do tipo **`int`**.
- A tabela de pares é **ordenada por `match` crescente**.

> ⚠️ **Pegadinha de prova**
> Por que a ordenação importa? Porque permite **busca binária** — O(log n) em vez de O(n).
> A ordenação é uma **exigência do formato** (o verificador a checa), não uma mera convenção.
> Afirmação "os pares do `lookupswitch` podem estar em qualquer ordem" → **FALSO**.

> ⚠️ **Pegadinha de prova**
> `npairs >= 0` significa que `lookupswitch` **pode ter zero pares** (um `switch` só com `default`).
> Já o `tableswitch` exige `low <= high`, ou seja, ao menos uma entrada.

### Exemplo concreto (slide 40)

```java
int chooseFar(int i) {
    switch (i) {
        case -100: return -1;
        case 0:    return 0;
        case 100:  return 1;
        default:   return -1;
    }
}
```

Bytecode:

```
Method int chooseFar(int i)
 0 iload_1                 // empilha a variável local 1 (argumento i)
 1 lookupswitch 3:         // índices válidos são -100, 0 e 100
       -100: 36            // se i == -100, continua em 36
          0: 38            // se i == 0,    continua em 38
        100: 40            // se i == 100,  continua em 40
     default: 42           // caso contrário, continua em 42
36 iconst_m1               // i era -100; empilha a constante int -1...
37 ireturn                 //   ...e retorna
38 iconst_0                // i era 0; empilha a constante int 0...
39 ireturn                 //   ...e retorna
40 iconst_1                // i era 100; empilha a constante int 1...
41 ireturn                 //   ...e retorna
42 iconst_m1               // caso contrário empilha a constante int -1...
43 ireturn                 //   ...e retorna
```

### O que está gravado no `.class` (figura do slide 40, reproduzida)

O dump hexadecimal mostra, a partir do endereço `0x182` do arquivo:

```
Campo                      Bytes em hexa        Valor
------------------------------------------------------------------
iload_1                    1A                   -
lookupswitch               AB                   -
padding                    00 00                (alinhamento)
default                    00 00 00 29          41
npairs                     00 00 00 03           3
match  #1                  FF FF FF 9C         -100
offset #1                  00 00 00 23           35
match  #2                  00 00 00 00            0
offset #2                  00 00 00 25           37
match  #3                  00 00 00 64          100
offset #3                  00 00 00 27           39
```

Legenda do slide (fundo azul):

```
41 (29h) – default
03 – npairs
-100 ~ 35 (FFFFFF9Ch é o match; 35 é o offset)
0 ~ 37 (0h)
100 ~ 39 (64h)
```

**Conferindo** (o `lookupswitch` está no endereço 1):

| Caso | Match gravado | Offset gravado | + 1 | = alvo | Disassembly |
|---|---|---|---|---|---|
| `case -100` | `FFFFFF9C` = -100 | 35 (0x23) | +1 | **36** | `36 iconst_m1` |
| `case 0` | `00000000` = 0 | 37 (0x25) | +1 | **38** | `38 iconst_0` |
| `case 100` | `00000064` = 100 | 39 (0x27) | +1 | **40** | `40 iconst_1` |
| `default` | — | 41 (0x29) | +1 | **42** | `42 iconst_m1` |

> ⚠️ **Pegadinha de prova**
> `FFFFFF9C` é o **match** (-100 em complemento de dois), **não** um offset negativo.
> Cada par tem 8 bytes: 4 de match + 4 de offset. Um erro típico é ler os 4 primeiros bytes de um
> par como offset. Note que os **matches podem ser negativos**; os **offsets também podem ser
> negativos** (desvio para trás, como num laço), já que são de 32 bits **com sinal**.

---

## 7. `tableswitch` × `lookupswitch`: quando o compilador escolhe cada um

Comparando os dois exemplos dos slides:

| | `tableswitch` | `lookupswitch` |
|---|---|---|
| Opcode | `0xAA` (170) | `0xAB` (171) |
| Campos | `default`, `low`, `high`, offsets | `default`, `npairs`, pares `<match><offset>` |
| Nº de entradas | `high - low + 1` (implícito) | `npairs` (explícito) |
| Como acha o alvo | **indexação direta**: `offset[key - low]` → **O(1)** | **batimento de chave**: procura `match == key` → **O(log n)** por busca binária |
| Ordenação exigida | não se aplica (é um vetor por índice) | **sim**, por `match` crescente |
| Bom para | cases **densos / próximos** (0,1,2,3…) | cases **esparsos** (-100, 0, 100) |
| Nome do exemplo | `chooseNear` ("perto") | `chooseFar` ("longe") |
| Tamanho na tabela | 4 bytes por índice do intervalo, **mesmo sem case** | 8 bytes por case **realmente existente** |

Comentário do slide 35: *"index é do tipo inteiro. Os cases podem ser representados como uma tabela
de forma eficiente, não esparsa."* — ou seja, o `tableswitch` só vale a pena quando a tabela é densa.

> ⚠️ **Pegadinha de prova**
> Um `switch (i) { case 0: ...; case 1000000: ...; }` compilado como `tableswitch` exigiria
> 1.000.001 offsets de 4 bytes ≈ **4 MB** de tabela. Por isso o compilador emite `lookupswitch`
> nesse caso. A escolha é feita pelo **compilador** (`javac`) com base em densidade/tamanho — a
> **JVM não escolhe nada em tempo de execução**. Afirmação "a JVM decide em runtime qual switch
> usar" → **FALSO**.

> ⚠️ **Pegadinha de prova**
> Ambos **desempilham** o valor testado e **não empilham** nada. E os dois calculam o `default`
> da mesma forma. O `default` existe **sempre** no bytecode, mesmo que o Java-fonte não tenha
> cláusula `default` — nesse caso ele aponta para a instrução seguinte ao `switch`.

---

## 8. Tipos e a JVM: a letra de prefixo

Em geral, **o tipo dos operandos é explicitado no mnemônico da instrução por uma letra de prefixo**
(slide 41):

| Letra | Tipo |
|---|---|
| `i` | `int` |
| `l` | `long` |
| `s` | `short` |
| `b` | `byte` |
| `c` | `char` |
| `f` | `float` |
| `d` | `double` |
| `a` | **referência** (*address*) |

Exemplos de leitura: `iadd` = "int add"; `dstore_2` = "double store na local 2";
`aaload` = "carrega uma **referência** de um array de **referências**";
`baload` = "carrega um **byte** de um array de bytes".

### Três categorias de instruções quanto ao tipo

1. **Com tipo explícito no mnemônico**: `iload`, `fadd`, `dstore`, `areturn`…
2. **Com tipo não ambíguo → sem prefixo**: por exemplo `arraylength`, que opera sobre um objeto do
   tipo array:
   ```
   ..., arrayref  →  ..., length
   ```
3. **Que não operam sobre operandos com tipo**: por exemplo `goto`:
   ```
   goto branchbyte1 branchbyte2
   ...  →  ...
   ```
   (não mexe na pilha; seus operandos são imediatos, no bytecode)

> ⚠️ **Pegadinha de prova**
> `a` de `aload`/`astore`/`areturn`/`aaload` significa **referência**, não "array" e não "all".
> `aaload` é "a-a-load": *array-de-referências* + *carrega referência*.

> ⚠️ **Pegadinha de prova**
> **Não** existe `iload` de `byte`, nem `bload`, nem `cload`. Só há `load`/`store` para
> `int`, `long`, `float`, `double` e `reference`. `byte`, `short`, `char` e `boolean` usam as
> instruções de `int` nas variáveis locais. Eles só ganham instruções próprias no acesso a
> **arrays** (`baload`/`bastore`, `saload`/`sastore`, `caload`/`castore`) e nas **conversões**
> (`i2b`, `i2s`), porque aí importa a largura real do armazenamento.

---

## 9. O template `T` e a tabela-sumário do conjunto de instruções

O slide 42 explica a notação usada nas tabelas: *"Uma instrução específica com informação de tipo é
construída substituindo o `T` no template pela letra na coluna de tipo."*

Regras de leitura:

- **Célula vazia** na interseção (template × tipo) ⇒ **não existe** instrução daquele tipo para
  aquela operação. Exemplo: existe `iload`, **não existe** `bload` ("load de byte").
- Para a **maioria** das instruções não existe forma para os tipos integrais **`byte`, `char` e
  `short`**.
- **Não existe nenhuma instrução com operando `boolean`.**
- Conversões implícitas na JVM:
  - `byte` e `short` → tratados como `int` com **extensão de sinal**
  - `char` e `boolean` → tratados como `int` com **extensão de zero**

### Sumário do conjunto de instruções (slides 43 e 44)

| opcode | byte | short | int | long | float | double | char | reference |
|---|---|---|---|---|---|---|---|---|
| `Tipush` | `bipush` | `sipush` | | | | | | |
| `Tconst` | | | `iconst` | `lconst` | `fconst` | `dconst` | | `aconst` |
| `Tload` | | | `iload` | `lload` | `fload` | `dload` | | `aload` |
| `Tstore` | | | `istore` | `lstore` | `fstore` | `dstore` | | `astore` |
| `Tinc` | | | `iinc` | | | | | |
| `Taload` | `baload` | `saload` | `iaload` | `laload` | `faload` | `daload` | `caload` | `aaload` |
| `Tastore` | `bastore` | `sastore` | `iastore` | `lastore` | `fastore` | `dastore` | `castore` | `aastore` |
| `Tadd` | | | `iadd` | `ladd` | `fadd` | `dadd` | | |
| `Tsub` | | | `isub` | `lsub` | `fsub` | `dsub` | | |
| `Tmul` | | | `imul` | `lmul` | `fmul` | `dmul` | | |
| `Tdiv` | | | `idiv` | `ldiv` | `fdiv` | `ddiv` | | |
| `Trem` | | | `irem` | `lrem` | `frem` | `drem` | | |
| `Tneg` | | | `ineg` | `lneg` | `fneg` | `dneg` | | |
| `Tshl` | | | `ishl` | `lshl` | | | | |
| `Tshr` | | | `ishr` | `lshr` | | | | |
| `Tushr` | | | `iushr` | `lushr` | | | | |
| `Tand` | | | `iand` | `land` | | | | |
| `Tor` | | | `ior` | `lor` | | | | |
| `Txor` | | | `ixor` | `lxor` | | | | |
| `i2T` | `i2b` | `i2s` | | `i2l` | `i2f` | `i2d` | | |
| `l2T` | | | `l2i` | | `l2f` | `l2d` | | |
| `f2T` | | | `f2i` | `f2l` | | `f2d` | | |
| `d2T` | | | `d2i` | `d2l` | `d2f` | | | |
| `Tcmp` | | | | `lcmp` | | | | |
| `Tcmpl` | | | | | `fcmpl` | `dcmpl` | | |
| `Tcmpg` | | | | | `fcmpg` | `dcmpg` | | |
| `if_TcmpOP` | | | `if_icmpOP` | | | | | `if_acmpOP` |
| `Treturn` | | | `ireturn` | `lreturn` | `freturn` | `dreturn` | | `areturn` |

Como **ler as lacunas** (isto é o que a prova cobra):

- Linha `Tadd`: **não existe** `badd`, `sadd`, `cadd` nem `aadd`. Somar dois `byte` em Java é
  `iadd` sobre dois ints (por isso `byte b = b1 + b2;` não compila sem cast em Java!).
- Linha `Taload`/`Tastore`: é a **única** família completa — cobre todos os 8 tipos. Faz sentido:
  arrays armazenam os valores na largura real do tipo.
- Linha `Tinc`: só `iinc`. Não há `linc`, `finc`, `dinc`.
- Linha `Tcmp`: `long` usa `lcmp`; `float`/`double` têm **duas** variantes (`l` e `g`) por causa do
  `NaN`; `int` e `reference` não têm `Tcmp` — usam `if_icmpOP` / `if_acmpOP` diretamente.
- Linha `Treturn`: existe `ireturn`, `lreturn`, `freturn`, `dreturn`, `areturn` — e, fora da tabela,
  `return` (void), que não tem tipo.
- Conversões: **toda** conversão passa por `i`, `l`, `f`, `d`. Não existe `b2i` (desnecessário:
  byte já *é* int nas locais) nem `i2c`… espere: `i2c` **existe** na JVM real, mas **não aparece
  nesta tabela do slide**, que lista só `i2b` e `i2s` na linha `i2T`. Para a prova, **responda pela
  tabela do slide**.

> ⚠️ **Pegadinha de prova**
> Não existe `Tconst` para `byte`/`short`/`char` — mas existe `Tipush` (`bipush`, `sipush`) só para
> eles. São coisas diferentes: `bipush`/`sipush` empilham uma constante **imediata do bytecode**
> estendida para `int`; `iconst_<i>` empilha uma constante **implícita no opcode**.

> ⚠️ **Pegadinha de prova**
> `f2i`, `d2i`, `l2i`, `i2b`, `i2s` são conversões **estreitantes** (podem perder informação e
> **nunca** lançam exceção — elas truncam). `i2l`, `i2f`, `i2d`, `l2f`, `l2d`, `f2d` são
> **alargantes**. "Conversão estreitante na JVM lança exceção" → **FALSO**.

---

## 10. Mapeamento dos tipos de Java nos tipos da JVM e as categorias 1 e 2

Slide 45:

| Java | JVM | Categoria |
|---|---|---|
| `boolean` | `int` | 1 |
| `byte` | `int` | 1 |
| `char` | `int` | 1 |
| `short` | `int` | 1 |
| `int` | `int` | 1 |
| `float` | `float` | 1 |
| `reference` | `reference` | 1 |
| — | `returnAddress` | 1 |
| `long` | `long` | **2** |
| `double` | `double` | **2** |

Em diagrama:

```
   Tipos de Java                   Tipos computacionais da JVM
   -------------                   ---------------------------
   boolean ---\
   byte    ----\
   char    -----+------------->  int            (categoria 1, 32 bits)
   short   ----/
   int     ---/
   float   -------------------->  float          (categoria 1)
   reference ------------------>  reference      (categoria 1)
   (nenhum tipo Java) --------->  returnAddress  (categoria 1)  <- usado por jsr/ret
   long    -------------------->  long           (categoria 2, ocupa 2 slots)
   double  -------------------->  double         (categoria 2, ocupa 2 slots)
```

O que significa **categoria 2**: o valor ocupa **duas** posições consecutivas no array de variáveis
locais e **duas** palavras na pilha de operandos.

```
Array de variáveis locais com  long v guardado no índice 2:

 índice:   0        1        2              3        4
         +--------+--------+--------------+--------+--------+
         | this   | int a  |   long v (parte alta) (baixa)  | ...
         +--------+--------+--------------+--------+--------+
                            \____ o índice 3 é "consumido" ____/
```

> ⚠️ **Pegadinha de prova**
> `returnAddress` é um tipo da **JVM** que **não tem correspondente em Java**. É o tipo do valor
> produzido por `jsr`/`jsr_w` e consumido por `ret` (usados historicamente para implementar
> `finally`). Afirmação "todo tipo da JVM corresponde a um tipo de Java" → **FALSO**.

> ⚠️ **Pegadinha de prova**
> `reference` é **categoria 1** (uma palavra), mesmo numa JVM de 64 bits, do ponto de vista do
> modelo de bytecode. E `boolean` é `int` na JVM — não existe tipo `boolean` computacional.

> ⚠️ **Pegadinha de prova**
> Se um `long` está no índice `n`, então `n+1` também pertence a ele. Uma instrução
> `iload n+1` sobre esse par é **inválida** e o **verificador de bytecode** rejeita a classe.
> Por isso `lload index` exige que `index+1` também seja índice válido do array de locais
> (dito explicitamente no slide 48, na descrição do `wide`).

---

## 11. Instruções que operam por categoria: `pop`, `pop2`, `swap`

Slide 46: *"Normalmente o opcode determina o tipo dos operandos"* — mas **algumas instruções operam
na pilha limitadas por categoria e não por tipo**.

```
pop
    ..., value  →  ...                       /* value deve ser da categoria 1 */

pop2
    ..., value2, value1  →  ...              /* value2 e value1 de categoria 1 */
    ..., value  →  ...                       /* OU: value de categoria 2       */

swap
    ..., value2, value1  →  ..., value1, value2   /* somente categoria 1 */
```

Visualmente:

```
   pop                       pop2 (forma 1)            pop2 (forma 2)
  +-------+                 +-------+                 +-----------+
  | value | <- topo         | value1|                 |  double   |  (2 palavras)
  +-------+                 +-------+                 |           |
  |  ...  |                 | value2|                 +-----------+
                            +-------+                 |   ...     |
                            |  ...  |
```

> ⚠️ **Pegadinha de prova**
> **`pop` não pode desempilhar um `long` ou um `double`.** Para descartar um valor de categoria 2
> usa-se `pop2`. Um `pop` aplicado a metade de um `double` é rejeitado pelo verificador.
> Afirmação "`pop` remove qualquer valor do topo da pilha" → **FALSO**.

> ⚠️ **Pegadinha de prova**
> **`swap` só funciona com valores de categoria 1.** Não existe instrução para trocar dois `long`
> no topo da pilha — o compilador tem que usar variáveis locais temporárias.
> Afirmação "existe `swap2`" → **FALSO** (não há `swap2` na JVM; existem sim `dup2`, `dup2_x1`,
> `dup2_x2`, mas essas são da família `dup`, vista na parte 3).

> ⚠️ **Pegadinha de prova**
> `pop2` tem **duas formas** com o mesmo opcode: remove **dois** valores de categoria 1 **ou
> um** valor de categoria 2. A escolha é feita pelo que está na pilha, não pelo opcode.

---

## 12. Instruções de carga e armazenamento

Definição (slide 47): **transferem valores entre o array de variáveis locais e a pilha de operandos
de um frame de um método**.

```
        FRAME DE UM MÉTODO
 +--------------------------------------------------+
 |  array de variáveis locais                        |
 |   [0] [1] [2] [3] [4] ...                         |
 +----------------+----------------------------------+
        |    ^
  Tload |    | Tstore
        v    |
 +--------------------------------------------------+
 |  pilha de operandos      <-- Tconst/Tipush/ldc    |  (constantes vêm do
 |   |___|___|___|  <- topo                          |   bytecode ou do
 +--------------------------------------------------+   pool de constantes)
 |  referência ao pool de constantes da classe       |
 +--------------------------------------------------+
```

### Os três grupos

**(a) Variável local → pilha de operandos (`load`)**

```
iload, iload_<n>, lload, lload_<n>, fload, fload_<n>,
dload, dload_<n>, aload, aload_<n>
```

**(b) Pilha de operandos → array de variáveis locais (`store`)**

```
istore, istore_<n>, lstore, lstore_<n>, fstore, fstore_<n>,
dstore, dstore_<n>, astore, astore_<n>
```

**(c) Constante → pilha de operandos**

```
bipush, sipush, ldc, ldc_w, ldc2_w, aconst_null,
iconst_m1, iconst_<i>, lconst_<l>, fconst_<f>, dconst_<d>
```

### A notação `<n>` e `<i>`: famílias de instruções

Comentário do slide 52: *"Instruções com letra entre bicudos denotam **famílias** e geram instruções
específicas com **operandos implícitos**"*, onde `<i>` = int, `<l>` = long, `<f>` = float,
`<d>` = double. E: *"Formas tipo int são usadas com valores tipo byte, char e short"*.

### `iload` e `iload_<n>` (slide 49)

| | `iload index` | `iload_<n>` |
|---|---|---|
| Opcode | `21 (0x15)` | `iload_0 = 26 (0x1a)`, `iload_1 = 27 (0x1b)`, `iload_2 = 28 (0x1c)`, `iload_3 = 29 (0x1d)` |
| Tamanho | 2 bytes (opcode + índice) | **1 byte** |
| Índice | *unsigned byte*, operando explícito | **implícito** no opcode (0 a 3) |
| Exigência | a local no índice deve conter um `int` | a local em `<n>` deve conter um `int` |
| Com `wide` | **sim** — índice de 2 bytes | não |

Descrição textual do slide: *"O `index` é um unsigned byte que deve ser um índice do array de
variáveis locais do frame corrente. A variável local no índice deve conter um `int`. O valor da
variável local no índice é empilhado na pilha de operandos."* E: *"Cada instrução `iload_<n>` é a
mesma que `iload` com um index de `<n>`, exceto que o operando `<n>` é implícito."*

### `aload` e `aload_<n>` (slide 50)

| | `aload index` | `aload_<n>` |
|---|---|---|
| Opcode | `25 (0x19)` | `aload_0 = 42 (0x2a)`, `aload_1 = 43 (0x2b)`, `aload_2 = 44 (0x2c)`, `aload_3 = 45 (0x2d)` |
| Exigência | a local no índice deve conter uma **referência** | idem |

Observação-chave do slide, em destaque: *"Essa instrução **não pode ser usada para carregar um tipo
`returnAddress`** de uma variável local na pilha de operandos. **Porque?**"*

**Resposta:** por **segurança**. Se `aload` pudesse carregar um `returnAddress`, um bytecode
malicioso poderia manipular esse valor como se fosse uma referência comum — armazená-lo, passá-lo
adiante, forjá-lo — e executar `ret` para um endereço arbitrário, **desviando o fluxo de controle
para qualquer ponto do método** e burlando o verificador. Um `returnAddress` só pode ser produzido
por `jsr`, guardado com `astore` e consumido por `ret`. Por isso `astore` **aceita** `returnAddress`
mas `aload` **não**.

> ⚠️ **Pegadinha de prova**
> Assimetria proposital: **`astore` pode armazenar um `returnAddress`; `aload` não pode carregá-lo.**
> É a pergunta literal do slide 50. Afirmação "`aload` e `astore` são simétricas quanto aos tipos
> aceitos" → **FALSO**.

> ⚠️ **Pegadinha de prova**
> `aload_0` é o opcode `0x2A` e, em **métodos de instância**, carrega o `this` — porque a variável
> local 0 de um método de instância é sempre a referência ao objeto. Em **métodos `static`** a
> local 0 é o **primeiro argumento**, não `this`. Você vai ver `2A` (=`aload_0`) no início de
> praticamente todo construtor, logo antes do `invokespecial` para `<init>` da superclasse — inclusive
> no dump do slide 40, onde aparece a sequência `2A B7 00 01` = `aload_0; invokespecial #1`.

### `istore` e `istore_<n>` (slide 51)

| | `istore index` | `istore_<n>` |
|---|---|---|
| Opcode | `54 (0x36)` | `istore_0 = 59 (0x3b)`, `istore_1 = 60 (0x3c)`, `istore_2 = 61 (0x3d)`, `istore_3 = 62 (0x3e)` |
| Efeito | **desempilha** o `int` do topo e grava na local `index` | idem, com índice implícito |
| Com `wide` | **sim** | não |

> ⚠️ **Pegadinha de prova**
> O slide 51 tem uma **errata**: na coluna direita, a descrição de `istore_<n>` repete o texto de
> `iload_<n>` ("O valor da variável local em `<n>` é **empilhado** na pilha de operandos" e "Cada
> instrução **`iload_<n>`** é a mesma que **`iload`**…"). O correto é o inverso: `istore_<n>`
> **desempilha** da pilha de operandos e **armazena** na variável local `<n>`, e é equivalente a
> `istore` com índice `<n>` implícito. Se a prova reproduzir o slide, atenção.

### Por que existem as formas `_<n>`?

Pura **compactação**. `iload_1` ocupa **1 byte**; `iload 1` ocupa **2 bytes**. Como as variáveis
locais 0–3 são de longe as mais usadas (`this`, primeiros argumentos, primeiras temporárias), o
projeto dedicou 4 opcodes a cada família e economizou muito espaço no `.class`.

---

## 13. A instrução `wide`

**Problema:** o índice de variável local em `iload index` é um *unsigned byte* → só chega a **255**.
E se um método tiver mais de 256 variáveis locais?

**Solução (slide 48):** o prefixo `wide` estende o índice para **2 bytes** (até 65535).

```
wide <opcode> indexbyte1 indexbyte2
wide iinc     indexbyte1 indexbyte2 constbyte1 constbyte2

wide = 196 (0xc4)
```

### Descrição completa do slide

- O `<opcode>` é **um dos seguintes**:
  `iload, fload, aload, lload, dload, istore, fstore, astore, lstore, dstore` **ou `ret`**.
- Os *unsigned bytes* `indexbyte1` e `indexbyte2` são montados como um índice de **16 bits** de uma
  variável local no **frame corrente**: `(indexbyte1 << 8) | indexbyte2`.
- Para as instruções `lload`, `dload`, `lstore` ou `dstore`, o índice seguinte (`index + 1`) também
  deve ser um índice válido para o array de variáveis locais. **Os dois apontam para um valor `long`
  ou `double`.**
- Na **segunda forma** (com `iinc`), os *unsigned bytes* `constbyte1` e `constbyte2` são montados
  como uma constante **com sinal de 16 bits**: `(constbyte1 << 8) | constbyte2`.
  Nesse caso, a variável local dada por `(indexbyte1 << 8) | indexbyte2` é incrementada pelo valor
  com sinal dado por `(constbyte1 << 8) | constbyte2`.

### Layout em bytes

```
 Forma 1 (5 instruções de load/store + ret):
 +------+---------+------------+------------+
 | C4   | opcode  | indexbyte1 | indexbyte2 |     = 4 bytes
 +------+---------+------------+------------+

 Forma 2 (iinc):
 +------+------+------------+------------+------------+------------+
 | C4   | 84   | indexbyte1 | indexbyte2 | constbyte1 | constbyte2 |  = 6 bytes
 +------+------+------------+------------+------------+------------+
   wide   iinc        índice de 16 bits        constante de 16 bits (com sinal)
```

> ⚠️ **Pegadinha de prova**
> `wide` **não** funciona com qualquer instrução. A lista é fechada:
> `iload, fload, aload, lload, dload, istore, fstore, astore, lstore, dstore, ret` e `iinc`.
> Não existe `wide iadd`, `wide ldc` (o "ldc largo" é `ldc_w`, uma instrução própria), nem
> `wide goto` (o "goto largo" é `goto_w`).

> ⚠️ **Pegadinha de prova**
> `wide` é **um opcode** (`0xC4`, 196), não um "modo" da instrução seguinte. E `ret` está na lista
> porque também recebe um índice de variável local (a que guarda o `returnAddress`).

> ⚠️ **Pegadinha de prova**
> Na forma com `iinc`, a constante de 16 bits é **com sinal** (permite decrementar), enquanto os
> bytes de índice são **sem sinal**. Misturar isso é erro comum. No `iinc` **sem** `wide`, o índice
> é 1 *unsigned byte* e a constante é 1 *signed byte* (–128 a 127).

---

## 14. Carga de constantes na pilha de operandos

Existem três "fontes" de constante:

```
 (1) embutida no OPCODE           -> iconst_<i>, lconst_<l>, fconst_<f>, dconst_<d>, aconst_null
 (2) imediata no BYTECODE         -> bipush (1 byte), sipush (2 bytes)
 (3) no POOL DE CONSTANTES        -> ldc, ldc_w, ldc2_w
```

### `bipush` e `sipush` (slide 53)

```
bipush byte            bipush = 16 (0x10)
```
O byte imediato é **estendido com sinal** para um valor `int` e empilhado.
Faixa: **-128 a 127**.

```
sipush byte1 byte2     sipush = 17 (0x11)
```
O valor imediato `short` `(byte1 << 8) | byte2` é **estendido com sinal** para um `int` e empilhado.
Faixa: **-32768 a 32767**.

> ⚠️ **Pegadinha de prova**
> Apesar dos nomes `bipush` ("byte") e `sipush` ("short"), **o que vai para a pilha é um `int`**,
> nos dois casos — com extensão de sinal. Não existe valor `byte` nem `short` na pilha de operandos.

### `ldc` (slide 54)

```
ldc index              ldc = 18 (0x12)
```

- `index` é um *unsigned byte* que deve ser um índice **válido para o pool de constantes da classe
  corrente** (portanto: só alcança as entradas **1 a 255**).
- O valor no pool deve ser:
  - uma constante do tipo **`int`** ou **`float`** → o valor numérico é empilhado como `int` ou `float`;
  - ou uma **referência simbólica para um literal `String`** → uma referência para a instância de
    `String` que representa aquele literal é empilhada.

### `ldc_w` (slide 55)

```
ldc_w indexbyte1 indexbyte2        ldc_w = 19 (0x13)
```

Idêntica a `ldc`, **exceto que o índice é de 16 bits**:
`índice = (indexbyte1 << 8) | indexbyte2` (unsigned, alcança 1 a 65535).
Mesmos tipos permitidos: `int`, `float`, literal `String`.

### `ldc2_w` (slide 56)

```
ldc2_w indexbyte1 indexbyte2       ldc2_w = 20 (0x14)
```

- Índice **unsigned de 16 bits**, montado da mesma forma.
- O valor no pool **deve ser do tipo `long` ou `double`** → é empilhado como `long` ou `double`
  (ocupando **duas** palavras da pilha).
- **"Não existe uma versão `ldc2` com um índice de 8 bits."**

Resumo comparativo:

| Instrução | Opcode | Tamanho do índice | Tipos que carrega | Palavras na pilha |
|---|---|---|---|---|
| `ldc` | `0x12` | 8 bits (1–255) | `int`, `float`, `String` | 1 |
| `ldc_w` | `0x13` | 16 bits | `int`, `float`, `String` | 1 |
| `ldc2_w` | `0x14` | 16 bits | **`long`, `double`** | **2** |

> ⚠️ **Pegadinha de prova**
> **Não existe `ldc2`** (com índice de 8 bits) — o slide 56 diz isso explicitamente. Só existe
> `ldc2_w`. Motivo: `long`/`double` são relativamente raros no código, não valeria um opcode extra.

> ⚠️ **Pegadinha de prova**
> `ldc` **não** carrega `long` nem `double`; `ldc2_w` **não** carrega `int`, `float` nem `String`.
> São conjuntos de tipos **disjuntos**. Trocar um pelo outro é erro clássico de V/F.

> ⚠️ **Pegadinha de prova**
> Um literal `String` no bytecode é uma **referência simbólica** no pool de constantes
> (`CONSTANT_String_info`), que é **resolvida** para uma referência a um objeto `String` real.
> Ou seja: `ldc` de uma `String` empilha uma **referência**, não os caracteres.

### `aconst_null` e as famílias de constantes (slides 57, 58, 59)

```
aconst_null            aconst_null = 1 (0x1)
```
Empilha uma **referência `null`** para um objeto.

```
iconst_<i>
    iconst_m1 = 2 (0x2)    iconst_0 = 3 (0x3)    iconst_1 = 4 (0x4)
    iconst_2  = 5 (0x5)    iconst_3 = 6 (0x6)    iconst_4 = 7 (0x7)
    iconst_5  = 8 (0x8)
```
Empilha a constante `int` **-1, 0, 1, 2, 3, 4 ou 5**.
Equivalente a `bipush <i>` para o respectivo valor, **exceto que o operando `<i>` é implícito**
(logo, ocupa 1 byte em vez de 2).

```
lconst_<l>
    lconst_0 = 9  (0x9)     -> empilha 0L
    lconst_1 = 10 (0xa)     -> empilha 1L
```

```
fconst_<f>
    fconst_0 = 11 (0xb)     -> empilha 0.0f
    fconst_1 = 12 (0xc)     -> empilha 1.0f
    fconst_2 = 13 (0xd)     -> empilha 2.0f
```

```
dconst_<d>
    dconst_0 = 14 (0xe)     -> empilha 0.0
    dconst_1 = 15 (0xf)     -> empilha 1.0
```

Mapa de opcodes contíguos (útil para ler dumps hexa):

```
0x01 aconst_null
0x02 iconst_m1   0x03 iconst_0  0x04 iconst_1  0x05 iconst_2
0x06 iconst_3    0x07 iconst_4  0x08 iconst_5
0x09 lconst_0    0x0A lconst_1
0x0B fconst_0    0x0C fconst_1  0x0D fconst_2
0x0E dconst_0    0x0F dconst_1
0x10 bipush      0x11 sipush
0x12 ldc         0x13 ldc_w     0x14 ldc2_w
0x15 iload  0x16 lload  0x17 fload  0x18 dload  0x19 aload
```

> ⚠️ **Pegadinha de prova**
> Assimetrias que caem em V/F:
> - `iconst` vai de **-1 a 5** (7 opcodes) — inclui o negativo `iconst_m1` ("minus one").
> - `lconst` tem só **0 e 1**. Não existe `lconst_2`.
> - `fconst` tem **0.0, 1.0 e 2.0** — é o **único** que chega a 2.
> - `dconst` tem só **0.0 e 1.0**. **Não existe `dconst_2`.**
> A pergunta favorita é "existe `dconst_2`?" → **NÃO**.

> ⚠️ **Pegadinha de prova**
> Como um compilador empilha o `int` 100? `bipush 100` (cabe em byte). E o 1000?
> `sipush 1000`. E o 100000? Não cabe em `short` → vai para o **pool de constantes** e usa
> `ldc`/`ldc_w`. E o 3? `iconst_3` (1 byte). Saber essa escada é cobrado.

> ⚠️ **Pegadinha de prova**
> `aconst_null` empilha `null` — o **único** valor de referência que pode ser produzido sem
> alocar nada. Não confundir com `iconst_0`: `null` **não é** o inteiro zero no modelo de tipos
> da JVM (embora possa ser representado como 0 na implementação).

---

## 15. Instruções aritméticas

### Visão geral (slide 60)

*"Computam um resultado que é tipicamente uma função de dois valores na pilha de operandos; o
resultado é empilhado na pilha de operandos."*

Pontos essenciais:

- Operam sobre **valores inteiros** e **valores de ponto flutuante**.
- **"Não há suporte direto para operações aritméticas em valores do tipo `byte`, `short` e `char`
  ou `boolean` — essas operações são manipuladas por instruções de tipos `int`."**

### Catálogo (slide 61)

| Operação | Instruções |
|---|---|
| Soma | `iadd, ladd, fadd, dadd` |
| Subtração | `isub, lsub, fsub, dsub` |
| Multiplicação | `imul, lmul, fmul, dmul` |
| Divisão | `idiv, ldiv, fdiv, ddiv` |
| Resto | `irem, lrem, frem, drem` |
| Negação | `ineg, lneg, fneg, dneg` |
| Shift | `ishl, ishr, iushr, lshl, lshr, lushr` |
| Bitwise AND | `iand, land` |
| Bitwise OR | `ior, lor` |
| Bitwise XOR | `ixor, lxor` |
| Incremento em variável local | `iinc` |
| Comparação | `dcmpg, dcmpl, fcmpg, fcmpl, lcmp` |

(Shift, bitwise, `iinc` e comparação são **detalhados na parte 3**; a parte 2 chega só até a negação.)

### Soma e multiplicação (slide 62)

```
Soma                                  Multiplicação
..., value1, value2  →  ..., result   ..., value1, value2  →  ..., result
   result = value1 + value2              result = value1 * value2

iadd = 96  (0x60)                     imul = 104 (0x68)
ladd = 97  (0x61)                     lmul = 105 (0x69)
fadd = 98  (0x62)                     fmul = 106 (0x6a)
dadd = 99  (0x63)                     dmul = 107 (0x6b)
```

### Subtração e divisão (slide 63)

```
Subtração                             Divisão
..., value1, value2  →  ..., result   ..., value1, value2  →  ..., result
   result = value1 - value2              result = value1 / value2

isub = 100 (0x64)                     idiv = 108 (0x6c)
lsub = 101 (0x65)                     ldiv = 109 (0x6d)
fsub = 102 (0x66)                     fdiv = 110 (0x6e)
dsub = 103 (0x67)                     ddiv = 111 (0x6f)
```

(O slide grafa "`sub = 100`", faltando o `i`; leia `isub = 100 (0x64)`.)

### Resto (slide 64)

*"Desempilha dois valores do topo da pilha, divide-os como inteiros e empilha o resto."*

```
..., value1, value2  →  ..., result

   result = value1 - (value1 / value2) * value2
   (ocorre TRUNCAMENTO na divisão value1 / value2)

irem = 112 (0x70)
lrem = 113 (0x71)
frem = 114 (0x72)
drem = 115 (0x73)
```

Nota do rodapé do slide: *"A função resto também pode ser aplicada a ponto flutuante."*

### Negação (slide 65)

*"Desempilha um valor do topo da pilha, nega-o e empilha o resultado."*

```
..., value  →  ..., result

   result é similar a  zero - value,  ou seja,  -value

ineg = 116 (0x74)
lneg = 117 (0x75)
fneg = 118 (0x76)
dneg = 119 (0x77)
```

### A ordem dos operandos na pilha

Esta é a fonte n.º 1 de erros:

```
Para calcular  a - b :

    empilha a        empilha b            isub
   +-------+        +-------+         +---------+
   |   a   |        |   b   | <-topo  | a - b   |
   +-------+        +-------+         +---------+
   |  ...  |        |   a   |         |   ...   |
                    +-------+
                    |  ...  |

   value1 = a  (mais FUNDO)        value2 = b  (topo)
   result = value1 - value2 = a - b
```

> ⚠️ **Pegadinha de prova**
> `value1` é o que está **mais fundo** na pilha e `value2` é o **topo**. Para operações não
> comutativas (`sub`, `div`, `rem`, shifts), inverter isso dá a resposta errada.
> Regra prática: os operandos são empilhados na **mesma ordem** em que aparecem na expressão Java.

Exemplo completo:

```java
int f(int a, int b) { return a - b * 2; }
```

```
0 iload_1      // a            pilha: [a]
1 iload_2      // b            pilha: [a, b]
2 iconst_2     // 2            pilha: [a, b, 2]
3 imul         // b * 2        pilha: [a, b*2]
4 isub         // a - (b*2)    pilha: [a-(b*2)]
5 ireturn
```

> ⚠️ **Pegadinha de prova**
> **Aritmética não é ortogonal quanto aos tipos pequenos.** `byte x = 1, y = 2; byte z = x + y;`
> **não compila** em Java — e o motivo é exatamente este slide: não existe `badd`; o compilador
> promove tudo a `int` (`iadd`) e o resultado `int` não cabe em `byte` sem cast explícito.

> ⚠️ **Pegadinha de prova**
> **Existe `frem` e `drem`** — o resto **funciona em ponto flutuante** na JVM (e em Java:
> `5.5 % 2.0` é válido). Afirmação "o operador de resto só existe para inteiros" → **FALSO**.

> ⚠️ **Pegadinha de prova**
> `irem`/`idiv` com divisor **zero** lançam `ArithmeticException`; `frem`/`fdiv` com divisor zero
> **não lançam** — produzem `Infinity` ou `NaN` (IEEE 754). Idem para `long`/`double`.

> ⚠️ **Pegadinha de prova**
> **Não existe `inc`/`iinc` na pilha de operandos.** `iinc` opera **diretamente sobre a variável
> local** e **não afeta a pilha de operandos** — é a única instrução aritmética que trabalha fora
> da pilha. (Detalhada no slide 68, parte 3.)

> ⚠️ **Pegadinha de prova**
> `ineg` não é implementado como "empilhar 0 e subtrair" no bytecode — é uma instrução própria.
> O slide diz que o resultado *"é similar a zero - value"*, o que descreve a **semântica**, não a
> implementação. Cuidado com `Integer.MIN_VALUE`: `-(-2147483648)` continua `-2147483648`
> (overflow silencioso, sem exceção).

---

## Apêndice A — ordem de execução `<clinit>`, blocos e construtores

*(Slides 30–32 da parte 1, incluídos aqui por serem a pegadinha mais cobrada da matéria.)*

### Os dois métodos especiais

| | `<clinit>` | `<init>` |
|---|---|---|
| Nome | *class initialization method* | *instance initialization method* |
| Inicializa | campos `static` e **blocos `static`** | campos de instância, **blocos de instância** e corpo do construtor |
| Quantidade por classe | **exatamente um** (no máximo) | **um por construtor declarado** |
| Argumentos | **nenhum** | os do construtor |
| Retorno | **nenhum** (`void`) | `void` |
| Pode ser chamado do código Java? | **NÃO** | só indiretamente, via `new` / `super()` / `this()` |
| Quando executa | na **iniciação da classe**, **uma única vez** | a cada `new` |
| Invocado por | pela própria JVM | `invokespecial` |

Do slide 30: *"Se existir, é o primeiro método a ser executado."*

### Exemplo canônico (slide 32)

```java
class Foo extends Goo {
    static { System.out.println("1"); }        // bloco estático de Foo
    { System.out.println("2"); }               // bloco de instância de Foo

    public Foo() { System.out.println("3"); }  // construtor de Foo

    public static void main(String[] args) {
        System.out.println("4");
        Foo f = new Foo();
    }
}

class Goo {
    static { System.out.println("5"); }        // bloco estático de Goo
    { System.out.println("6"); }               // bloco de instância de Goo

    Goo() { System.out.println("7"); }         // construtor de Goo
}
```

**Saída: `5 1 4 6 7 2 3`**

Explicação passo a passo:

| Ordem | Saída | O que acontece |
|---|---|---|
| 1.º | **5** | bloco `static` da **superclasse** `Goo` (`<clinit>` de `Goo`) |
| 2.º | **1** | bloco `static` da **classe** `Foo` (`<clinit>` de `Foo`) |
| 3.º | **4** | execução de `main` |
| 4.º | **6** | `new Foo()` → `<init>` de `Foo` chama `super()` → **bloco de instância de `Goo`** |
| 5.º | **7** | corpo do **construtor de `Goo`** |
| 6.º | **2** | de volta em `Foo`: **bloco de instância de `Foo`** |
| 7.º | **3** | corpo do **construtor de `Foo`** |

Diagrama do fluxo:

```
  CARGA + INICIAÇÃO DA CLASSE (uma única vez)
  ------------------------------------------
     <clinit> de Goo   ->  imprime 5        (superclasse PRIMEIRO)
     <clinit> de Foo   ->  imprime 1
  EXECUÇÃO
  --------
     main              ->  imprime 4
     new Foo()
        |
        +-> <init> de Foo
              |
              +-> invokespecial <init> de Goo  (super() implícito)
                      |
                      +-> bloco de instância de Goo  -> imprime 6
                      +-> corpo do construtor Goo    -> imprime 7
              |
              +-> bloco de instância de Foo          -> imprime 2
              +-> corpo do construtor Foo            -> imprime 3
```

> ⚠️ **Pegadinha de prova**
> **`<clinit>` roda UMA ÚNICA VEZ** por classe (é `EXECUTADO ÚNICA VEZ!`, como grita o slide).
> Criar mil objetos `Foo` imprime `5 1` só na primeira vez; `6 7 2 3` se repete a cada `new`.

> ⚠️ **Pegadinha de prova**
> A ordem é **superclasse antes de subclasse** nos dois níveis:
> `<clinit>` de `Goo` antes do de `Foo`, **e** `<init>` de `Goo` (com seu bloco de instância)
> antes do bloco de instância de `Foo`. **Todos** os `<clinit>` acontecem antes de **qualquer**
> `<init>`.

> ⚠️ **Pegadinha de prova**
> Dentro de **um mesmo** nível, o **bloco de instância vem ANTES do corpo do construtor** —
> mesmo que o bloco esteja escrito **depois** do construtor no código-fonte. O compilador copia os
> blocos de instância e os inicializadores de campo para dentro de cada `<init>`, logo após a
> chamada a `super()` e antes do corpo escrito do construtor.

> ⚠️ **Pegadinha de prova**
> `<clinit>` **não pode ser chamado por um programa Java** — o nome com `<` e `>` é
> propositalmente **inválido** como identificador Java, justamente para que só a JVM o invoque.
> O mesmo vale para `<init>`, que só é alcançado via `invokespecial`.

> ⚠️ **Pegadinha de prova**
> `<clinit>` **não tem argumentos e não retorna valor**, e só **um** pode existir por classe —
> mesmo que a classe tenha **vários** blocos `static`: o compilador **concatena todos** (na ordem
> textual, junto com os inicializadores de campos `static`) em um único `<clinit>`.

---

## Apêndice B — tabela de opcodes vistos na parte 2

| Opcode (hex) | Dec | Mnemônico | Efeito na pilha |
|---|---|---|---|
| `0x01` | 1 | `aconst_null` | `… → …, null` |
| `0x02`–`0x08` | 2–8 | `iconst_m1` … `iconst_5` | `… → …, int` |
| `0x09`–`0x0A` | 9–10 | `lconst_0`, `lconst_1` | `… → …, long` |
| `0x0B`–`0x0D` | 11–13 | `fconst_0`, `fconst_1`, `fconst_2` | `… → …, float` |
| `0x0E`–`0x0F` | 14–15 | `dconst_0`, `dconst_1` | `… → …, double` |
| `0x10` | 16 | `bipush byte` | `… → …, int` (sinal estendido) |
| `0x11` | 17 | `sipush b1 b2` | `… → …, int` (sinal estendido) |
| `0x12` | 18 | `ldc index` | `… → …, int` / `float` / ref-String |
| `0x13` | 19 | `ldc_w i1 i2` | idem, índice 16 bits |
| `0x14` | 20 | `ldc2_w i1 i2` | `… → …, long` / `double` |
| `0x15` | 21 | `iload index` | `… → …, int` |
| `0x19` | 25 | `aload index` | `… → …, ref` |
| `0x1A`–`0x1D` | 26–29 | `iload_0` … `iload_3` | `… → …, int` |
| `0x2A`–`0x2D` | 42–45 | `aload_0` … `aload_3` | `… → …, ref` |
| `0x36` | 54 | `istore index` | `…, int → …` |
| `0x3B`–`0x3E` | 59–62 | `istore_0` … `istore_3` | `…, int → …` |
| `0x60`–`0x63` | 96–99 | `iadd, ladd, fadd, dadd` | `…, v1, v2 → …, v1+v2` |
| `0x64`–`0x67` | 100–103 | `isub, lsub, fsub, dsub` | `…, v1, v2 → …, v1-v2` |
| `0x68`–`0x6B` | 104–107 | `imul, lmul, fmul, dmul` | `…, v1, v2 → …, v1*v2` |
| `0x6C`–`0x6F` | 108–111 | `idiv, ldiv, fdiv, ddiv` | `…, v1, v2 → …, v1/v2` |
| `0x70`–`0x73` | 112–115 | `irem, lrem, frem, drem` | `…, v1, v2 → …, v1%v2` |
| `0x74`–`0x77` | 116–119 | `ineg, lneg, fneg, dneg` | `…, v → …, -v` |
| `0x84` | 132 | `iinc index const` | **não afeta a pilha** |
| `0xAA` | 170 | `tableswitch` | `…, index → …` |
| `0xAB` | 171 | `lookupswitch` | `…, key → …` |
| `0xC4` | 196 | `wide` | (prefixo) |

Dica de leitura de dumps: blocos de opcodes aritméticos são **contíguos em grupos de 4**, sempre na
ordem **i, l, f, d**. Sabendo que `iadd = 0x60`, você deduz `dmul = 0x60 + 4*2 + 3 = 0x6B`.

---

## Resumo em 10 pontos

1. **O interpretador é um laço simples**: busca opcode → busca operandos (se houver) → executa →
   repete. Essa descrição **ignora exceções**; com exceções, um manipulador não encontrado no método
   corrente faz o **frame ser desempilhado** e a busca continuar **no chamador** — o programa não
   morre na hora.

2. **Instrução = 1 byte de opcode + 0 ou mais operandos**, cujo número e tamanho são determinados
   pelo opcode. Operandos multibyte são **big-endian**: 16 bits = `(b1<<8)|b2`;
   32 bits = `(b1<<24)|(b2<<16)|(b3<<8)|b4`.

3. **Todas as instruções são alinhadas por byte, exceto `tableswitch` (`0xAA`) e `lookupswitch`
   (`0xAB`)**, que inserem **0 a 3 bytes nulos** de padding para alinhar o primeiro operando em
   fronteira de 4 bytes.

4. **`tableswitch`** = `default`, `low`, `high` e **`high-low+1`** offsets, acessados por
   **indexação direta** (cases densos). **`lookupswitch`** = `default`, `npairs` e pares
   `<match><offset>` **ordenados por match crescente**, acessados por **batimento de chave**
   (cases esparsos). Nos dois, **`target = offset + endereço do próprio opcode do switch`**, e a
   chave testada é sempre um **`int`** e é **desempilhada**.

5. **O tipo está no mnemônico**: `i`(int) `l`(long) `s`(short) `b`(byte) `c`(char) `f`(float)
   `d`(double) `a`(**referência**). Por isso o conjunto **não é ortogonal** — é o preço de caber o
   opcode em 1 byte. Instruções de tipo não ambíguo (`arraylength`) ou sem tipo (`goto`) não têm
   prefixo.

6. **Java → JVM**: `boolean`, `byte`, `char` e `short` **viram `int`**. `byte`/`short` com
   **extensão de sinal**; `char`/`boolean` com **extensão de zero**. Não existe instrução com
   operando `boolean` e não há aritmética direta para tipos pequenos — só `int`, `long`, `float`,
   `double`.

7. **Categoria 1 × categoria 2**: `long` e `double` são **categoria 2** (2 slots / 2 palavras);
   `int`, `float`, `reference` e `returnAddress` são **categoria 1**. `pop` e `swap` só valem para
   categoria 1; `pop2` remove **dois** valores de categoria 1 **ou um** de categoria 2.
   `returnAddress` é um tipo da JVM **sem correspondente em Java**.

8. **Carga/armazenamento** movem valores entre o **array de variáveis locais** e a **pilha de
   operandos** do frame. As famílias `_<n>` (`iload_0`…`iload_3`, `aload_0`…`aload_3`) têm o
   **índice implícito no opcode** e ocupam 1 byte. **`aload` não pode carregar um `returnAddress`**
   (segurança: impediria forjar desvios via `ret`), embora `astore` possa armazená-lo.
   **`wide` (`0xC4`)** estende o índice para 16 bits e vale só para
   `iload, fload, aload, lload, dload, istore, fstore, astore, lstore, dstore, ret` e `iinc`
   (esta com constante de 16 bits **com sinal**).

9. **Constantes** vêm de três lugares: do **opcode** (`iconst_m1`…`iconst_5`, `lconst_0/1`,
   `fconst_0/1/2`, `dconst_0/1`, `aconst_null`), do **bytecode** (`bipush` 1 byte, `sipush` 2 bytes,
   ambos estendidos com sinal para `int`) ou do **pool de constantes** (`ldc` índice 8 bits e
   `ldc_w` índice 16 bits para `int`/`float`/`String`; **`ldc2_w`** índice 16 bits para
   `long`/`double`). **Não existe `ldc2`** de 8 bits, **nem `dconst_2`**, **nem `lconst_2`**.

10. **Aritmética** segue o padrão `..., value1, value2 → ..., result`, com **`value1` mais fundo e
    `value2` no topo** (crítico para `sub`, `div`, `rem`). Há 4 variantes (`i`,`l`,`f`,`d`) para
    soma, subtração, multiplicação, divisão, **resto** e **negação** — sim, **resto e negação também
    existem em ponto flutuante**. O resto é `value1 - (value1/value2)*value2`, com **truncamento**
    na divisão; e a negação equivale a `zero - value`.

---

### Bônus — ordem de execução (parte 1, sempre cai)

`<clinit>` da **superclasse** → `<clinit>` da **classe** → `main` → em cada `new`:
`<init>` chama `super()` → **bloco de instância da superclasse** → **construtor da superclasse** →
**bloco de instância da classe** → **construtor da classe**.
No exemplo `Foo extends Goo` do slide 32: **`5 1 4 6 7 2 3`**.
`<clinit>` roda **uma única vez**, **não tem argumentos nem retorno**, existe **no máximo um por
classe** e **não pode ser chamado pelo programa Java**.

---

## Apêndice — Este material e o Java SE 8

O conjunto de instruções descrito aqui é praticamente idêntico ao da **JVMS 8**. Pontos de atenção:

| Tema | 2ª edição (o slide) | **Java 8** |
|---|---|---|
| Invocações | 4 (`invokevirtual`, `invokespecial`, `invokestatic`, `invokeinterface`) | **5** — entrou **`invokedynamic`** (opcode 186 / `0xba`), com que **toda lambda** é compilada |
| `jsr` / `jsr_w` / `ret` | Uso normal (implementavam `finally`) | 🟦 **Proibidas** em `major_version ≥ 51`; um `.class` de Java 8 **não pode contê-las** |
| `switch` (linguagem) | `byte`, `short`, `char`, `int` | 🟦 \+ **`enum`** (Java 5) e **`String`** (Java 7). No bytecode, continua tudo `int` |
| Concatenação `a + b` | `StringBuilder` | ✅ Ainda `StringBuilder` **no Java 8**. 🟪 Só o Java 9 (JEP 280) passou a usar `invokedynamic` |
| Aritmética | `i*`/`l*`/`f*`/`d*`, sem instrução para `byte`/`char`/`short`/`boolean` | ✅ **Igual no Java 8** — esses tipos viram `int` |

🟥 **Independente de versão:** a errata do slide 51 (`istore_<n>` com pilha e variável invertidas — o
correto é **desempilhar** e gravar na variável local `n`); os slides 43/44, que omitem `i2c` da lista
de conversões de estreitamento; o "sub=100" do slide 63; e a confusão do slide 36 entre o
**alinhamento** do padding (medido do início do código do método) e o **cálculo do desvio** (relativo
ao opcode do switch).

Detalhamento completo em [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).
