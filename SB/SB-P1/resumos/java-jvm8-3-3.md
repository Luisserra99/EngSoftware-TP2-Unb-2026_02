# JVM 8 — Parte 3 de 3: Conjunto de Instruções (Bytecodes)

> Resumo didático do arquivo `java-jvm8-3-3.pdf` (slides 66 a 92), da disciplina **Software Básico (CIC0104 — UnB)**.
> Baseado em *"The Java Virtual Machine Specification", 2nd Edition* — Tim Lindholm & Frank Yellin.

> 🔎 **Revisão Java 8** — o PDF se chama `java-jvm8`, mas cita a **2ª edição** da JVMS. A prova cobre
> **Java SE 8 / JVMS 8**. A diferença que mais aparece aqui é a **tabela de opcodes**: a da 2ª edição
> mostra `0xba` vazio, enquanto na JVMS 8 esse opcode é **`invokedynamic`**. Divergências marcadas
> com 🟦/🟪/🟥; apanhado em [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).

---

## Sumário

1. [O que você precisa saber para a prova](#1-o-que-você-precisa-saber-para-a-prova)
2. [Revisão rápida: o modelo de execução da JVM](#2-revisão-rápida-o-modelo-de-execução-da-jvm)
3. [O formato das mnemônicas e os prefixos de tipo (i, l, f, d, a, b, c, s)](#3-o-formato-das-mnemônicas-e-os-prefixos-de-tipo-i-l-f-d-a-b-c-s)
4. [Panorama dos grupos de instruções](#4-panorama-dos-grupos-de-instruções)
5. [Instruções de deslocamento (shift)](#5-instruções-de-deslocamento-shift)
6. [Instruções lógicas bit a bit](#6-instruções-lógicas-bit-a-bit)
7. [Incremento em variável local: `iinc`](#7-incremento-em-variável-local-iinc)
8. [Instruções de comparação](#8-instruções-de-comparação)
   - 8.1 [Comparação de `float` e `double` (`fcmpl`, `fcmpg`, `dcmpl`, `dcmpg`)](#81-comparação-de-float-e-double)
   - 8.2 [Comparação de `long` (`lcmp`)](#82-comparação-de-long-lcmp)
   - 8.3 [Comparação de `int` com zero (`if<cond>`)](#83-comparação-de-int-com-zero-ifcond)
   - 8.4 [Comparação de dois `int` (`if_icmp<cond>`)](#84-comparação-de-dois-int-if_icmpcond)
   - 8.5 [Comparação de duas referências (`if_acmp<cond>`)](#85-comparação-de-duas-referências-if_acmpcond)
9. [Instruções de conversão de tipo](#9-instruções-de-conversão-de-tipo)
   - 9.1 [Promoção (widening)](#91-promoção-widening--sem-perda)
   - 9.2 [Estreitamento (narrowing)](#92-estreitamento-narrowing--com-perda)
10. [Criação e manipulação de objetos e arrays](#10-criação-e-manipulação-de-objetos-e-arrays)
    - 10.1 [`new` — instanciar uma classe](#101-new--instanciar-uma-classe)
    - 10.2 [`newarray` — array de tipo primitivo](#102-newarray--array-de-tipo-primitivo)
    - 10.3 [`anewarray` e `multianewarray`](#103-anewarray-e-multianewarray)
    - 10.4 [Acesso a fields: `getstatic`, `putstatic`, `getfield`, `putfield`](#104-acesso-a-fields-getstatic-putstatic-getfield-putfield)
    - 10.5 [Carga de elemento de array: `?aload`](#105-carga-de-elemento-de-array-aload)
    - 10.6 [Armazenamento em array: `?astore`, `arraylength`, `instanceof`, `checkcast`](#106-armazenamento-em-array-astore-arraylength-instanceof-checkcast)
11. [Gerenciamento da pilha de operandos](#11-gerenciamento-da-pilha-de-operandos)
12. [Transferência de controle (desvios)](#12-transferência-de-controle-desvios)
13. [Invocação de métodos e retorno](#13-invocação-de-métodos-e-retorno)
14. [Exceções e sincronização (complemento)](#14-exceções-e-sincronização-complemento)
15. [Sumário das instruções da JVM — tabela de opcodes](#15-sumário-das-instruções-da-jvm--tabela-de-opcodes)
16. [Exemplos completos: Java ⇄ bytecode passo a passo](#16-exemplos-completos-java--bytecode-passo-a-passo)
17. [Pegadinhas de prova — lista consolidada](#17-pegadinhas-de-prova--lista-consolidada)
18. [Resumo em 10 pontos](#18-resumo-em-10-pontos)

---

## 1. O que você precisa saber para a prova

Se o tempo for curto, memorize **este bloco**. Ele concentra o que mais cai em questões objetivas e verdadeiro/falso.

| # | Ponto essencial |
|---|-----------------|
| 1 | O **opcode** da JVM tem **1 byte** → no máximo **256 instruções** possíveis. Por isso o conjunto é enxuto e não há instrução para todo tipo. |
| 2 | **Não existem instruções dedicadas para `boolean`, `byte`, `char` e `short`** na aritmética/lógica. Esses tipos são **convertidos (promovidos) para `int`** e operados com as instruções `i...`. |
| 3 | **`long` e `double` ocupam 2 slots** (duas posições) no vetor de variáveis locais e na pilha de operandos — são de **categoria 2**. Todos os demais (`int`, `float`, `reference`, `returnAddress`) são de **categoria 1** (1 slot). |
| 4 | O prefixo da mnemônica indica o tipo: **`i`**=int, **`l`**=long, **`f`**=float, **`d`**=double, **`a`**=reference, **`b`**=byte, **`c`**=char, **`s`**=short. |
| 5 | A JVM é uma **máquina de pilha**: quase toda instrução **desempilha operandos e empilha o resultado**. As exceções notáveis são `iinc` (opera direto na variável local, **não mexe na pilha**) e `nop`. |
| 6 | Em `ishl`/`ishr`/`iushr` a quantidade de deslocamento vem dos **5 bits menos significativos** de `value2` (máscara `& 0x1F`); em `lshl`/`lshr`/`lushr`, dos **6 bits menos significativos** (`& 0x3F`). |
| 7 | `ushr` (`iushr`, `lushr`) é o deslocamento **sem sinal**: insere **zeros à esquerda**. `shr` (`ishr`, `lshr`) é aritmético: **preserva o sinal**. **Não existe `ushl`** — deslocar à esquerda com e sem sinal é a mesma coisa. |
| 8 | Comparações de `long`, `float` e `double` **não desviam**: elas empilham um `int` igual a **1, 0 ou -1**. Quem desvia é uma instrução `if<cond>` posterior. Já para `int` existe desvio direto (`if_icmp<cond>`). |
| 9 | `fcmpg`/`dcmpg` empilham **1** quando há **NaN**; `fcmpl`/`dcmpl` empilham **-1** quando há NaN. (O sufixo indica o resultado "greater" ou "less" no caso NaN.) |
| 10 | Conversões de **promoção** (`i2l`, `i2f`, `i2d`, `l2f`, `l2d`, `f2d`) nunca perdem magnitude; as de **estreitamento** (`l2i`, `f2i`, `d2i`, `i2b`, `i2c`, `i2s`, ...) **descartam bits superiores e podem mudar o sinal**. |
| 11 | `i2c` estende para inteiro **sem sinal** (char não tem sinal); `i2b` e `i2s` estendem **com sinal**. |
| 12 | Instruções que referenciam classes, fields, métodos ou arrays de referência usam um **índice de 16 bits para o Constant Pool** (`indexbyte1 indexbyte2`, montado como `(indexbyte1 << 8) | indexbyte2`, bytes **sem sinal**). |
| 13 | `new` só **aloca** e inicializa fields com valor default — o **construtor é chamado à parte** por `invokespecial`. |
| 14 | `newarray` cria arrays de **primitivos** (operando `atype`: T_BOOLEAN=4 ... T_LONG=11); `anewarray` cria array de **referências**; `multianewarray` cria arrays **multidimensionais** (operando `dimensions`). |
| 15 | As 5 instruções de invocação: `invokevirtual` (despacho dinâmico normal), `invokespecial` (construtor `<init>`, privado, `super`), `invokestatic` (método de classe), `invokeinterface` (método de interface) e `invokedynamic`. |
| 16 | A instrução `wide` amplia o índice da variável local de 8 para **16 bits** (e, com `iinc`, também a constante para 16 bits com sinal). |
| 17 | Os três opcodes **reservados pela Sun/Oracle**: `breakpoint` (0xca), `impdep1` (0xfe) e `impdep2` (0xff). Não podem aparecer num `.class` válido. |
| 18 | Em `putstatic`/`putfield`, se o descritor do field for `boolean`, `byte`, `char`, `short` **ou** `int`, o valor na pilha é um **`int`**. |

---

## 2. Revisão rápida: o modelo de execução da JVM

Antes de estudar as instruções, é preciso ter clara a **máquina** onde elas rodam. A JVM não tem registradores de uso geral como um x86: ela é uma **máquina de pilha** (*stack machine*).

Cada vez que um método é chamado, a JVM cria um **frame** (quadro), que contém:

```
            FRAME de um método
 +---------------------------------------------+
 |  Vetor de Variáveis Locais                  |
 |  [0] [1] [2] [3] [4] ...                    |   <- indexado por número
 |   ^ em métodos de instância, [0] = this     |
 +---------------------------------------------+
 |  Pilha de Operandos                         |
 |                                             |
 |        +--------+                           |
 |        | topo   |  <- as instruções         |
 |        +--------+     empilham/desempilham  |
 |        | ...    |     aqui                  |
 |        +--------+                           |
 +---------------------------------------------+
 |  Referência ao Constant Pool da classe      |
 +---------------------------------------------+
```

Regras fundamentais:

- Uma instrução aritmética **não** recebe "endereços" de operandos: ela sempre **desempilha** o que precisa do topo da pilha e **empilha** o resultado.
- Para levar um valor da variável local para a pilha usa-se `?load`; para o caminho inverso, `?store`.
- `long` e `double` ocupam **duas** posições consecutivas; os demais tipos, **uma**.

Notação usada nos slides (e neste resumo) para descrever o efeito na pilha:

```
..., value1, value2   →   ..., result
```

onde `...` é o resto da pilha (intocado), o **elemento mais à direita é o topo**, à esquerda da seta está o estado *antes* e à direita o estado *depois*.

> ⚠️ **Pegadinha de prova**
> O elemento **mais à direita** na notação é o **topo** da pilha. Como `value2` está mais à direita, `value2` é desempilhado **primeiro**. Em subtrações e divisões isso importa: `isub` calcula `value1 - value2`, e não `value2 - value1`. Da mesma forma, `idiv` calcula `value1 / value2`.

---

## 3. O formato das mnemônicas e os prefixos de tipo (i, l, f, d, a, b, c, s)

As mnemônicas da JVM seguem o padrão:

```
<prefixo de tipo> <operação> [ _ <variação/constante embutida> ]
       i             add
       i            load                _0
       d             cmp                  g
```

### Tabela de prefixos

| Prefixo | Tipo Java | Categoria | Slots | Exemplos |
|---------|-----------|-----------|-------|----------|
| `i` | `int` (e também `boolean`, `byte`, `char`, `short` promovidos) | 1 | 1 | `iload`, `iadd`, `istore`, `iaload`, `ireturn` |
| `l` | `long` | 2 | **2** | `lload`, `ladd`, `lcmp`, `lastore`, `lreturn` |
| `f` | `float` | 1 | 1 | `fload`, `fmul`, `fcmpg`, `freturn` |
| `d` | `double` | 2 | **2** | `dload`, `ddiv`, `dcmpl`, `dreturn` |
| `a` | `reference` (objeto, array, `null`, `String`) | 1 | 1 | `aload`, `astore`, `aaload`, `areturn`, `aconst_null` |
| `b` | `byte` (e `boolean` em arrays) | 1 | 1 | `baload`, `bastore`, `bipush`, `i2b` |
| `c` | `char` | 1 | 1 | `caload`, `castore`, `i2c` |
| `s` | `short` | 1 | 1 | `saload`, `sastore`, `sipush`, `i2s` |

### Por que `b`, `c` e `s` quase não aparecem?

Porque o opcode tem **apenas 1 byte** (256 valores possíveis). Se a JVM tivesse `badd`, `cadd`, `sadd`, `bsub`, `csub`... o espaço de opcodes estouraria. A decisão de projeto foi:

- **Aritmética/lógica**: existe só para `int`, `long`, `float` e `double`.
- `boolean`, `byte`, `char` e `short` são **promovidos a `int`** no momento da carga e manipulados com instruções `i...`.
- Os prefixos `b`, `c` e `s` sobrevivem **apenas** onde a largura em memória realmente importa:
  - acesso a arrays (`baload`/`bastore`, `caload`/`castore`, `saload`/`sastore`), porque o array tem elementos de 1 ou 2 bytes;
  - conversões de estreitamento (`i2b`, `i2c`, `i2s`);
  - empilhamento de constantes (`bipush`, `sipush`).

> ⚠️ **Pegadinha de prova**
> "A JVM possui instruções aritméticas dedicadas para `byte`, `char`, `short` e `boolean`." → **FALSO**. Não há `badd`, `cadd`, `ssub`, `bmul` etc. Esses tipos são convertidos para `int`.

> ⚠️ **Pegadinha de prova**
> **Não existe prefixo `z` para `boolean`** nas instruções, embora o descritor de tipo no arquivo `.class` seja `Z`. Em array de `boolean`, usam-se `baload`/`bastore` (as mesmas de `byte`). Já em `newarray`, `boolean` tem código próprio: `T_BOOLEAN = 4`.

### Sufixos `_<n>` e formas especiais

Muitas instruções têm **variantes com o operando embutido no opcode**, para economizar espaço:

| Forma geral | Forma compacta | Efeito |
|-------------|----------------|--------|
| `iload 0` (2 bytes) | `iload_0` (1 byte) | carrega a variável local 0 |
| `istore 3` | `istore_3` | armazena na variável local 3 |
| `ldc #k` (constante int 1) | `iconst_1` | empilha a constante 1 |
| `aload 0` | `aload_0` | carrega `this` em método de instância |

E os sufixos de variação semântica: `fcmp**l**` / `fcmp**g**` (comportamento com NaN), `goto_w` / `jsr_w` (offset de 32 bits), `dup_x1` / `dup2_x2` (posição de inserção da cópia).

---

## 4. Panorama dos grupos de instruções

O conjunto de instruções da JVM se divide nos seguintes grupos:

| Grupo | O que faz | Instruções típicas |
|-------|-----------|--------------------|
| **Carga e armazenamento** | move valores entre variáveis locais e pilha de operandos | `iload`, `lload`, `fload`, `dload`, `aload`, `istore`..., `bipush`, `sipush`, `ldc`, `ldc_w`, `ldc2_w`, `iconst_<n>`, `aconst_null`, `wide` |
| **Aritméticas** | somar, subtrair, multiplicar, dividir, resto, negar | `iadd`, `ladd`, `fadd`, `dadd`, `isub`, `imul`, `idiv`, `irem`, `ineg`, ... |
| **Deslocamento e lógicas** | shifts e operações bit a bit | `ishl`, `ishr`, `iushr`, `iand`, `ior`, `ixor` (+ versões `l`) |
| **Incremento** | incrementa variável local direto | `iinc` |
| **Comparação** | comparar valores e/ou desviar | `lcmp`, `fcmpl/g`, `dcmpl/g`, `if<cond>`, `if_icmp<cond>`, `if_acmp<cond>` |
| **Conversão de tipos** | promoção e estreitamento | `i2l`, `i2f`, `i2d`, `l2f`, `l2d`, `f2d`, `l2i`, `f2i`, `d2i`, `i2b`, `i2c`, `i2s`, ... |
| **Criação e manipulação de objetos** | instanciar, criar arrays, acessar fields, ler/escrever elementos, testar tipo | `new`, `newarray`, `anewarray`, `multianewarray`, `getstatic`, `putstatic`, `getfield`, `putfield`, `?aload`, `?astore`, `arraylength`, `instanceof`, `checkcast` |
| **Gerenciamento da pilha de operandos** | duplicar, descartar, trocar | `pop`, `pop2`, `dup`, `dup_x1`, `dup_x2`, `dup2`, `dup2_x1`, `dup2_x2`, `swap` |
| **Transferência de controle** | desvios condicionais, compostos e incondicionais | `if*`, `tableswitch`, `lookupswitch`, `goto`, `goto_w`, `jsr`, `jsr_w`, `ret` |
| **Invocação e retorno** | chamar métodos e retornar | `invokevirtual`, `invokespecial`, `invokestatic`, `invokeinterface`, `invokedynamic`, `ireturn`, `lreturn`, `freturn`, `dreturn`, `areturn`, `return` |
| **Exceções** | lançar exceção | `athrow` |
| **Sincronização** | entrar/sair de monitor | `monitorenter`, `monitorexit` |

---

## 5. Instruções de deslocamento (shift)

### Semântica

```
..., value1, value2   →   ..., result
```

`value1` é o valor a deslocar; `value2` diz **quantos bits**. A instrução desempilha os dois, calcula e empilha o `result`.

**Quantidade efetiva de deslocamento (`s`)**:
- para `int`: `s` = os **5 bits de ordem mais baixa** de `value2` (ou seja, `value2 & 0x1F`, valores de 0 a 31);
- para `long`: `s` = os **6 bits de ordem mais baixa** de `value2` (`value2 & 0x3F`, valores de 0 a 63).

### Tabela das instruções de shift

| Mnemônica | Opcode | Tipo | Direção | Sinal |
|-----------|--------|------|---------|-------|
| `ishl` | 120 (0x78) | int | esquerda | — |
| `lshl` | 121 (0x79) | long | esquerda | — |
| `ishr` | 122 (0x7a) | int | direita | **aritmético** (preserva o sinal) |
| `lshr` | 123 (0x7b) | long | direita | **aritmético** |
| `iushr` | 124 (0x7c) | int | direita | **lógico** (insere zeros à esquerda) |
| `lushr` | 125 (0x7d) | long | direita | **lógico** (insere zeros à esquerda) |

### Exemplo numérico

```
int a = -8;          // 1111 1111 1111 1111 1111 1111 1111 1000
int b = a >> 2;      // ishr  -> 1111 ... 1110  = -2   (replica o bit de sinal)
int c = a >>> 2;     // iushr -> 0011 1111 ... 1110 = 1073741822 (zeros à esquerda)
int d = a << 2;      // ishl  -> -32
```

### Java ⇄ bytecode

```java
int x = 5;
int y = x << 3;
```

```
0: iconst_5          // pilha: [] -> [5]
1: istore_1          // locais: var1 = 5        pilha: [5] -> []
2: iload_1           // pilha: [] -> [5]
3: iconst_3          // pilha: [5] -> [5, 3]
4: ishl              // desempilha 3 e 5, empilha 5<<3 = 40   pilha: [40]
5: istore_2          // locais: var2 = 40       pilha: []
```

Rastreio passo a passo:

| PC | Instrução | Pilha (topo à direita) | Variáveis locais |
|----|-----------|------------------------|------------------|
| 0 | `iconst_5` | `5` | var1=?, var2=? |
| 1 | `istore_1` | *(vazia)* | var1=**5** |
| 2 | `iload_1` | `5` | var1=5 |
| 3 | `iconst_3` | `5, 3` | var1=5 |
| 4 | `ishl` | `40` | var1=5 |
| 5 | `istore_2` | *(vazia)* | var1=5, var2=**40** |

> ⚠️ **Pegadinha de prova**
> "Deslocar um `int` 32 bits à esquerda resulta em 0." → **FALSO**. Como só os 5 bits menos significativos de `value2` contam, `32 & 0x1F = 0`, logo `x << 32 == x` (nenhum deslocamento). Idem para `long` com 64 (`64 & 0x3F = 0`).

> ⚠️ **Pegadinha de prova**
> **Não existe `iushl`/`lushl`**. Só há versão "unsigned" para o deslocamento à **direita**.

---

## 6. Instruções lógicas bit a bit

Desempilham **dois** valores do topo, aplicam o operador bit a bit e empilham o resultado. Operam apenas com `int` e `long`.

```
..., value1, value2   →   ..., result
```

| Operação | int | opcode | long | opcode |
|----------|-----|--------|------|--------|
| AND bit a bit | `iand` | 126 (0x7e) | `land` | 127 (0x7f) |
| OR bit a bit | `ior` | 128 (0x80) | `lor` | 129 (0x81) |
| XOR bit a bit | `ixor` | 130 (0x82) | `lxor` | 131 (0x83) |

### Exemplo

```java
int m = 0b1100;   // 12
int n = 0b1010;   // 10
int a = m & n;    // 8
int o = m | n;    // 14
int x = m ^ n;    // 6
```

```
bipush 12        // [12]
istore_1
bipush 10        // [10]
istore_2
iload_1          // [12]
iload_2          // [12, 10]
iand             // [8]
istore_3
```

### Truques usados pelo compilador

- **Negação lógica de boolean**: `!b` vira `ixor` com 1 (`b ^ 1`), pois `boolean` é um `int` 0/1.
- **Complemento `~x`**: não existe instrução! O compilador gera `x ^ -1` → `iconst_m1` + `ixor`.
- `x % 2` com potências de 2 pode ser otimizado com `iand`.

> ⚠️ **Pegadinha de prova**
> "Existe uma instrução `inot` para o complemento de bits." → **FALSO**. `~x` é compilado como `ixor` com `-1` (`iconst_m1`). Da mesma forma, `x != y` para booleanos costuma virar `ixor`.

> ⚠️ **Pegadinha de prova**
> Não existem `fand`, `dor`, `fxor`. Operações bit a bit só existem para **inteiros** (`i` e `l`).

---

## 7. Incremento em variável local: `iinc`

```
iinc  index  const
```

- **Opcode**: 132 (0x84)
- **Operando 1**: `unsigned byte` — índice no vetor de variáveis locais
- **Operando 2**: `signed byte` — constante a somar (−128 a +127)

**Efeito**: `locals[index] = locals[index] + const`.

**Efeito na pilha de operandos: NENHUM.** Esta é a grande particularidade da instrução.

Comentários da especificação:
- A variável local em `index` **deve ser do tipo `int`**.
- Pode ser combinada com `wide` para índice de **16 bits** e constante de **16 bits com sinal**.

### Por que ela existe?

Porque `i++` é extremamente comum. Sem `iinc` seriam necessárias 4 instruções:

```
iload_1
iconst_1
iadd
istore_1
```

Com `iinc`, uma só (3 bytes): `iinc 1, 1`.

### Java ⇄ bytecode

```java
for (int i = 0; i < 10; i++) {
    soma += i;
}
```

```
 0: iconst_0
 1: istore_1          // i = 0            (var1 = i)
 2: iload_1           // [i]
 3: bipush 10         // [i, 10]
 5: if_icmpge 17      // se i >= 10 -> sai do laço
 8: iload_2           // [soma]
 9: iload_1           // [soma, i]
10: iadd              // [soma+i]
11: istore_2          // soma = soma+i
12: iinc 1, 1         // i++   <-- NÃO toca na pilha!
15: goto 2
17: ...
```

> ⚠️ **Pegadinha de prova**
> "`iinc` desempilha o valor da variável, soma a constante e empilha o resultado." → **FALSO**. `iinc` **não altera a pilha de operandos**: ela opera diretamente sobre o vetor de variáveis locais.

> ⚠️ **Pegadinha de prova**
> Não existem `linc`, `finc` ou `dinc`. `iinc` só funciona com variável local do tipo **`int`**. Um `long x; x++;` vira `lload` + `lconst_1` + `ladd` + `lstore`.

> ⚠️ **Pegadinha de prova**
> `iinc` aceita constante **com sinal**, então `i--` também é `iinc 1, -1`.

---

## 8. Instruções de comparação

A JVM separa dois estilos de comparação:

1. **Comparar e empilhar um `int` (1, 0 ou -1)** — usado para `long`, `float` e `double`. Depois é preciso uma instrução `if<cond>` para de fato desviar.
2. **Comparar e desviar diretamente** — usado para `int` (`if_icmp<cond>`), para `int` contra zero (`if<cond>`) e para referências (`if_acmp<cond>`, `ifnull`, `ifnonnull`).

> ⚠️ **Pegadinha de prova**
> "Existe uma instrução `if_lcmplt` para desviar comparando dois `long`." → **FALSO**. Para `long`/`float`/`double` é sempre **duas etapas**: `lcmp`/`fcmpX`/`dcmpX` e depois `iflt`, `ifge`, etc. Desvio direto de comparação só existe para `int` e para referências.

### 8.1 Comparação de `float` e `double`

```
..., value1, value2   →   ..., result
```

Desempilha `value2` e `value1`, compara e empilha um **`int`**:

- **1** se `value1 > value2`
- **0** se `value1 == value2`
- **-1** se `value1 < value2`

| Mnemônica | Opcode | Tipo | Resultado se houver NaN |
|-----------|--------|------|--------------------------|
| `fcmpl` | 149 (0x95) | float | **-1** |
| `fcmpg` | 150 (0x96) | float | **+1** |
| `dcmpl` | 151 (0x97) | double | **-1** |
| `dcmpg` | 152 (0x98) | double | **+1** |

**Por que duas versões?** Porque NaN não é maior, nem menor, nem igual a nada — nem a si mesmo. Qualquer comparação envolvendo NaN deve resultar em `false`. O compilador escolhe `l` ou `g` conforme o operador, de modo que o desvio subsequente dê `false`:

```java
if (a < b)  { ... }   // fcmpg + ifge   -> com NaN, fcmpg dá 1, ifge desvia (pula o if): false. OK
if (a > b)  { ... }   // fcmpl + ifle   -> com NaN, fcmpl dá -1, ifle desvia: false. OK
```

### Java ⇄ bytecode

```java
double a = 1.5, b = 2.5;
boolean r = (a < b);
```

```
 0: dconst_1          // [1.0]  (na prática ldc2_w 1.5)
 ...
 5: dload_1           // [a]        (a ocupa var1 e var2!)
 6: dload_3           // [a, b]     (b ocupa var3 e var4!)
 7: dcmpg             // [-1]   (1.5 < 2.5 -> -1)
 8: ifge 15           // -1 >= 0? não -> não desvia
11: iconst_1          // [1]  (true)
12: goto 16
15: iconst_0          // [0]  (false)
16: istore 5          // r = true
```

| PC | Instrução | Pilha | Locais |
|----|-----------|-------|--------|
| 5 | `dload_1` | `1.5` (2 slots) | a@1-2, b@3-4 |
| 6 | `dload_3` | `1.5, 2.5` (4 slots) | — |
| 7 | `dcmpg` | `-1` (1 slot int) | — |
| 8 | `ifge 15` | *(vazia)* | não desvia |
| 11 | `iconst_1` | `1` | — |
| 16 | `istore 5` | *(vazia)* | r@5 = 1 |

> ⚠️ **Pegadinha de prova**
> O resultado de `fcmp`/`dcmp`/`lcmp` é sempre um **`int` de 1 slot**, mesmo comparando `double` (que ocupa 2 slots). A pilha "encolhe" de 4 slots para 1.

> ⚠️ **Pegadinha de prova**
> `fcmp**g**` = "**g**reater" no caso NaN (empilha **1**). `fcmp**l**` = "**l**ess" no caso NaN (empilha **-1**). Confundir as duas é erro clássico.

### 8.2 Comparação de `long` (`lcmp`)

```
lcmp = 148 (0x94)
..., value1, value2   →   ..., result
```

Desempilha `value2` e `value1` (ambos `long`, 2 slots cada) e empilha um `int`:
- **1** se `value1 > value2`
- **0** se `value1 == value2`
- **-1** se `value1 < value2`

**Não há variantes `l`/`g`** porque `long` não tem NaN — só existe `lcmp`, um único opcode.

```java
long x = 10L, y = 20L;
if (x == y) { ... }
```

```
lload_1     // [x]     (2 slots)
lload_3     // [x, y]  (4 slots)
lcmp        // [-1]    (1 slot)
ifne  L     // != 0 -> desvia (não são iguais)
```

> ⚠️ **Pegadinha de prova**
> Para comparação de **`int`** existe a instrução direta `if_icmp<cond>` — a especificação faz questão de destacar isso ao lado de `lcmp`. Ou seja: **não existe `icmp`**.

### 8.3 Comparação de `int` com zero (`if<cond>`)

```
if<cond>  branchbyte1  branchbyte2
..., value1   →   ...
```

Desempilha `value1` (do tipo `int`), compara **com zero** e desvia se o resultado for `true`.

| Mnemônica | Opcode | Condição (value1 ? 0) |
|-----------|--------|------------------------|
| `ifeq` | 153 (0x99) | `== 0` |
| `ifne` | 154 (0x9a) | `!= 0` |
| `iflt` | 155 (0x9b) | `< 0` |
| `ifge` | 156 (0x9c) | `>= 0` |
| `ifgt` | 157 (0x9d) | `> 0` |
| `ifle` | 158 (0x9e) | `<= 0` |

Comentários:
- O offset (16 bits com sinal, montado a partir de `branchbyte1`/`branchbyte2`) é **relativo ao endereço da própria instrução** e deve apontar para dentro do **mesmo método**.
- Se a condição for `false`, a execução **continua na próxima instrução**.

```java
if (x != 0) { y = 1; }
```

```
iload_1      // [x]
ifeq  L      // se x == 0, desvia (pula o corpo do if)
iconst_1
istore_2
L: ...
```

> ⚠️ **Pegadinha de prova**
> O compilador **inverte a condição**: `if (x != 0)` gera `ifeq` (desvia quando a condição do `if` é falsa, pulando o corpo). Não estranhe ver `ifge` para um `<` no código-fonte.

> ⚠️ **Pegadinha de prova**
> `ifeq`/`ifne` também são usadas para testar `boolean` (que é um `int` 0/1) — não existe `ifbool`.

### 8.4 Comparação de dois `int` (`if_icmp<cond>`)

```
if_icmp<cond>  branchbyte1  branchbyte2
..., value1, value2   →   ...
```

Desempilha os dois inteiros, compara `value1 <cond> value2` e desvia se `true`.

| Mnemônica | Opcode | Condição |
|-----------|--------|----------|
| `if_icmpeq` | 159 (0x9f) | `value1 == value2` |
| `if_icmpne` | 160 (0xa0) | `value1 != value2` |
| `if_icmplt` | 161 (0xa1) | `value1 < value2` |
| `if_icmpge` | 162 (0xa2) | `value1 >= value2` |
| `if_icmpgt` | 163 (0xa3) | `value1 > value2` |
| `if_icmple` | 164 (0xa4) | `value1 <= value2` |

Mesmos comentários: offset dentro do método; se `false`, segue adiante.

```java
if (a >= b) { c = 1; }
```

```
iload_1        // [a]
iload_2        // [a, b]
if_icmplt L    // se a < b, pula (condição invertida)
iconst_1
istore_3
L: ...
```

### 8.5 Comparação de duas referências (`if_acmp<cond>`)

```
if_acmp<cond>  branchbyte1  branchbyte2
..., value1, value2   →   ...
```

`value1` e `value2` são **referências**. Desempilha, compara e desvia se `true`.

| Mnemônica | Opcode | Condição |
|-----------|--------|----------|
| `if_acmpeq` | 165 (0xa5) | mesma referência |
| `if_acmpne` | 166 (0xa6) | referências diferentes |

> ⚠️ **Pegadinha de prova**
> `if_acmpeq` compara **identidade de referência** (o endereço), não conteúdo. É exatamente o motivo de `s1 == s2` para Strings não comparar texto — para isso é preciso `invokevirtual` de `String.equals`, que retorna um `int` e vira `ifeq`/`ifne`.

> ⚠️ **Pegadinha de prova**
> **Não existem** `if_acmplt`, `if_acmpgt`, etc. Só igualdade e desigualdade fazem sentido para referências.

E, complementando o grupo de referências (aparecem no sumário de desvios do slide 88):

| Mnemônica | Opcode | Efeito |
|-----------|--------|--------|
| `ifnull` | 198 (0xc6) | desvia se a referência do topo for `null` |
| `ifnonnull` | 199 (0xc7) | desvia se a referência do topo **não** for `null` |

---

## 9. Instruções de conversão de tipo

```
..., value   →   ..., result
```

Todas desempilham **um** valor, convertem e empilham o resultado. Dividem-se em **promoção** (widening) e **estreitamento** (narrowing).

### 9.1 Promoção (widening) — sem perda

Conversão para um tipo "maior": **nunca perde magnitude nem sinal** (pode haver perda de precisão em `l2f`/`l2d`/`i2f`, mas não de magnitude).

| Mnemônica | Opcode | De → Para |
|-----------|--------|-----------|
| `i2l` | 133 (0x85) | int → long |
| `i2f` | 134 (0x86) | int → float |
| `i2d` | 135 (0x87) | int → double |
| `l2f` | 137 (0x89) | long → float |
| `l2d` | 138 (0x8a) | long → double |
| `f2d` | 141 (0x8d) | float → double |

Ordem de promoção: `int → long → float → double`.

### 9.2 Estreitamento (narrowing) — com perda

**Despreza os bits superiores e pode mudar o sinal.**

| Mnemônica | Opcode | De → Para | Observação |
|-----------|--------|-----------|------------|
| `i2b` | 145 (0x91) | int → byte | e **estende para inteiro com sinal** |
| `i2c` | 146 (0x92) | int → char | e **estende para inteiro sem sinal** |
| `i2s` | 147 (0x93) | int → short | e **estende para inteiro com sinal** |
| `l2i` | 136 (0x88) | long → int | |
| `f2i` | 139 (0x8b) | float → int | |
| `f2l` | 140 (0x8c) | float → long | |
| `d2i` | 142 (0x8e) | double → int | |
| `d2l` | 143 (0x8f) | double → long | |
| `d2f` | 144 (0x90) | double → float | |

### Exemplo do estreitamento mudando o sinal

```java
int i = 200;
byte b = (byte) i;   // b == -56 !
```

```
bipush 200      -> na verdade sipush 200   // [200]
istore_1
iload_1         // [200]
i2b             // 200 = 0000 0000 1100 1000
                // fica  1100 1000 (byte) -> estende COM sinal -> 1111...1100 1000 = -56
istore_2
```

```java
int i = -1;
char c = (char) i;   // c == 65535 (0xFFFF)
```

```
iconst_m1
i2c            // pega os 16 bits baixos = 0xFFFF, estende SEM sinal -> 65535
```

### Cadeia de conversões (o compilador insere automaticamente)

```java
int a = 3;
double d = a / 2 + 0.5;
```

```
iconst_3
istore_1
iload_1        // [3]
iconst_2       // [3, 2]
idiv           // [1]        <-- divisão INTEIRA! 3/2 = 1
i2d            // [1.0]      <-- só AGORA converte
ldc2_w 0.5     // [1.0, 0.5]
dadd           // [1.5]
dstore_2
```

> ⚠️ **Pegadinha de prova**
> "Não existe `b2i` / `c2i` / `s2i`." → **VERDADEIRO**. A conversão de `byte`/`char`/`short` para `int` é **implícita**: esses tipos já são carregados como `int` na pilha, então não é preciso instrução nenhuma.

> ⚠️ **Pegadinha de prova**
> "Não existe conversão direta `f2b`, `d2s`, `l2c`." → **VERDADEIRO**. Para ir de `double` para `byte` é preciso **duas** instruções: `d2i` e depois `i2b`.

> ⚠️ **Pegadinha de prova**
> `i2c` estende **sem sinal**; `i2b` e `i2s` estendem **com sinal**. `char` é o único tipo inteiro sem sinal em Java.

> ⚠️ **Pegadinha de prova**
> `f2i`/`d2i` **truncam em direção a zero** (não arredondam). `(int) -2.9` é `-2`, não `-3`.

---

## 10. Criação e manipulação de objetos e arrays

O grupo, conforme o slide 76, cobre:

| Tarefa | Instruções |
|--------|------------|
| Criar uma nova instância de classe | `new` |
| Criar um novo array | `newarray`, `anewarray`, `multianewarray` |
| Acessar fields de classes ou de instâncias | `getstatic`, `putstatic`, `getfield`, `putfield` |
| Carregar um componente de array na pilha | `baload`, `caload`, `saload`, `iaload`, `laload`, `faload`, `daload`, `aaload` |
| Armazenar valor da pilha como componente de array | `bastore`, `castore`, `sastore`, `iastore`, `lastore`, `fastore`, `dastore`, `aastore` |
| Obter o comprimento de um array | `arraylength` |
| Verificar propriedades de instâncias/arrays | `instanceof`, `checkcast` |

### 10.1 `new` — instanciar uma classe

```
new  indexbyte1  indexbyte2
```

- **Opcode**: 187 (0xbb)
- **Operando**: 16 bits **unsigned** — índice para o **Constant Pool**

Comentários da especificação:
- Use `(indexbyte1 << 8) | indexbyte2` para construir o valor de 16 bits. Os bytes são considerados **sem sinal**.
- `index` aponta para um **nome (referência simbólica)**.
- O tipo desse nome **deve ser classe**.
- Memória para a nova instância é alocada a partir do **coletor de lixo** (heap).
- As **variáveis de instância são iniciadas com o valor default** (0, 0.0, `false`, `null`).
- A referência `objectref` para a instância é armazenada (empilhada) na pilha.

**Pilha**:
```
...   →   ..., objectref
```

### O padrão `new` + `dup` + `invokespecial`

```java
Ponto p = new Ponto(3, 4);
```

```
 0: new #2            // classe Ponto        pilha: [ref]
 3: dup               // pilha: [ref, ref]   <-- copia porque invokespecial CONSOME uma
 4: iconst_3          // [ref, ref, 3]
 5: iconst_4          // [ref, ref, 3, 4]
 6: invokespecial #3  // <init>(II)V  consome ref, 3, 4 -> pilha: [ref]
 9: astore_1          // p = ref             pilha: []
```

| PC | Instrução | Pilha | Comentário |
|----|-----------|-------|------------|
| 0 | `new #2` | `ref` | objeto alocado, fields = default |
| 3 | `dup` | `ref, ref` | duplica a referência |
| 4 | `iconst_3` | `ref, ref, 3` | argumento 1 |
| 5 | `iconst_4` | `ref, ref, 3, 4` | argumento 2 |
| 6 | `invokespecial` | `ref` | construtor executado sobre uma das cópias |
| 9 | `astore_1` | *(vazia)* | `p` recebe a referência |

> ⚠️ **Pegadinha de prova**
> "A instrução `new` chama o construtor." → **FALSO**. `new` apenas **aloca** e zera os fields. O construtor (`<init>`) é chamado separadamente por **`invokespecial`**. Por isso o `dup`: o `invokespecial` consome a referência, e sem a cópia não sobraria nada para atribuir à variável.

> ⚠️ **Pegadinha de prova**
> `new` **não serve para arrays**. Arrays usam `newarray`, `anewarray` ou `multianewarray`.

### 10.2 `newarray` — array de tipo primitivo

```
newarray  atype
```

- **Opcode**: 188 (0xbc)
- **Operando**: 1 `byte` — `atype`, o tipo do array a ser criado

#### Codificação do tipo (`atype`)

| Tipo | Código | Tipo | Código |
|------|--------|------|--------|
| `T_BOOLEAN` | **4** | `T_CHAR` | **5** |
| `T_FLOAT` | **6** | `T_DOUBLE` | **7** |
| `T_BYTE` | **8** | `T_SHORT` | **9** |
| `T_INT` | **10** | `T_LONG` | **11** |

Comentários:
- Memória para um array do tipo `atype` com `count` elementos é alocada. `count` deve ser um **`int` positivo**.
- Os elementos são iniciados com seus **valores padrão** (0 / 0.0 / `false`).
- A referência `arrayref` é armazenada na pilha.

**Pilha**:
```
..., count   →   ..., arrayref
```

```java
int[] v = new int[5];
```

```
iconst_5          // [5]
newarray int      // atype=10   -> [arrayref]
astore_1          // v = arrayref
```

> ⚠️ **Pegadinha de prova**
> A numeração do `atype` **começa em 4**, não em 0 nem em 1. A sequência é: `boolean`(4), `char`(5), `float`(6), `double`(7), `byte`(8), `short`(9), `int`(10), `long`(11). Memorize a ordem — ela **não** segue a ordem alfabética nem a de tamanho.

> ⚠️ **Pegadinha de prova**
> `newarray` cria apenas arrays **unidimensionais de primitivos**. Seu operando é **1 byte literal**, **não** um índice para o Constant Pool (diferente de `new`, `anewarray` e `multianewarray`).

### 10.3 `anewarray` e `multianewarray`

**`anewarray indexbyte1 indexbyte2`** — opcode 189 (0xbd). Cria array **unidimensional de referências** (objetos). O índice de 16 bits aponta para uma classe/interface/array no Constant Pool.

```
..., count   →   ..., arrayref
```

```java
String[] s = new String[3];
```

```
iconst_3
anewarray #2       // class java/lang/String
astore_1
```

**`multianewarray indexbyte1 indexbyte2 dimensions`**

- **Opcode**: 197 (0xc5)
- **Operando 1-2**: 16 bits unsigned — índice para o Constant Pool
- **Operando 3**: `unsigned byte` — **número de dimensões**

Comentários:
- Use `(indexbyte1 << 8) | indexbyte2`; os bytes são **sem sinal**.
- `index` aponta para um **nome (referência simbólica)**; o tipo desse nome deve ser **classe, array ou interface**.
- Memória para um array desse tipo com `count_i` elementos na i-ésima dimensão é alocada; **todos os `count` devem ser `int` positivos maiores ou iguais a um**.
- Os elementos são iniciados com **`null`**.
- A referência `arrayref` é armazenada na pilha.

**Pilha**:
```
..., count1, [count2, ...]   →   ..., arrayref
```

```java
int[][] m = new int[2][3];
```

```
iconst_2                    // [2]
iconst_3                    // [2, 3]
multianewarray #2, 2        // class "[[I", dimensions=2  -> [arrayref]
astore_1
```

Visualmente:

```
 arrayref ──► [ ref0 , ref1 ]           (array de 2 refs)
                 │       │
                 ▼       ▼
            [0,0,0]  [0,0,0]            (cada um: array de 3 ints)
```

> ⚠️ **Pegadinha de prova**
> `multianewarray` consome **`dimensions` valores da pilha**, um para cada dimensão — a pilha "encolhe" `dimensions` slots e cresce 1.

> ⚠️ **Pegadinha de prova**
> `int[][] m = new int[2][];` (só a primeira dimensão) **não** usa `multianewarray` — usa `anewarray` com o tipo `[I`, porque só uma dimensão é alocada.

> ⚠️ **Pegadinha de prova**
> Quadro comparativo das três instruções de array:

| Instrução | Opcode | Operando | Cria | Valor inicial |
|-----------|--------|----------|------|---------------|
| `newarray` | 188 (0xbc) | 1 byte `atype` | array 1-D de primitivo | valor default (0/false) |
| `anewarray` | 189 (0xbd) | índice 16 bits CP | array 1-D de referências | `null` |
| `multianewarray` | 197 (0xc5) | índice 16 bits CP + `dimensions` | array multidimensional | `null` |

### 10.4 Acesso a fields: `getstatic`, `putstatic`, `getfield`, `putfield`

Todas as quatro têm o mesmo formato: opcode + **índice de 16 bits para o Constant Pool**. O índice aponta para uma **referência simbólica a um field**, que dá:
- o **nome** do field,
- o **descritor** (tipo) do field,
- a referência simbólica para a **classe ou interface** que o contém.

| Instrução | Opcode | Field | Pilha antes → depois |
|-----------|--------|-------|----------------------|
| `getstatic` | 178 (0xb2) | de classe (`static`) | `...` → `..., value` |
| `putstatic` | 179 (0xb3) | de classe (`static`) | `..., value` → `...` |
| `getfield` | 180 (0xb4) | de instância | `..., objectref` → `..., value` |
| `putfield` | 181 (0xb5) | de instância | `..., objectref, value` → `...` |

#### `getstatic` (slide 80)
- A classe ou interface é **iniciada (se ainda não o foi)** — ou seja, dispara a inicialização estática — e o valor do field é obtido e **inserido na pilha**.

#### `putstatic` (slide 81)
- A classe ou interface é iniciada (se ainda não o foi) e o field recebe o `value` retirado da pilha.
- **Se o descritor do field for `boolean`, `byte`, `char`, `short` ou `int`, então `value` deve ser um `int`.**
- Se o descritor for `float`, `long` ou `double`, então `value` deve ser `float`, `long` ou `double`, respectivamente.

#### `getfield` (slide 82)
- `objectref`, a **referência para o objeto que contém o field**, é retirada da pilha.
- O valor do field é obtido e inserido na pilha.
- Se o field for `protected`, `objectref` deve ser da **classe atual ou de uma de suas subclasses**.

#### `putfield` (slide 83)
- `value` **e** `objectref` são retirados da pilha (nessa ordem: `value` está no topo).
- Mesmas regras de tipo do `putstatic`.
- Mesma regra de `protected`.

### Exemplo completo

```java
class Conta {
    static int total;      // field estático
    int saldo;             // field de instância

    void deposita(int v) {
        saldo = saldo + v;
        total = total + v;
    }
}
```

Bytecode de `deposita(int v)` (var0 = `this`, var1 = `v`):

```
 0: aload_0             // [this]
 1: aload_0             // [this, this]
 2: getfield #2         // Conta.saldo:I  consome this -> [this, saldo]
 5: iload_1             // [this, saldo, v]
 6: iadd                // [this, saldo+v]
 7: putfield #2         // consome this e o valor -> []
10: getstatic #3        // Conta.total:I  -> [total]
13: iload_1             // [total, v]
14: iadd                // [total+v]
15: putstatic #3        // -> []
18: return
```

Rastreio de `saldo = saldo + v` (supondo `saldo=100`, `v=50`):

| PC | Instrução | Pilha |
|----|-----------|-------|
| 0 | `aload_0` | `this` |
| 1 | `aload_0` | `this, this` |
| 2 | `getfield` | `this, 100` |
| 5 | `iload_1` | `this, 100, 50` |
| 6 | `iadd` | `this, 150` |
| 7 | `putfield` | *(vazia)* — `this.saldo = 150` |

> ⚠️ **Pegadinha de prova**
> Note a **ordem** em `putfield`: a pilha é `..., objectref, value` — ou seja, o `objectref` deve ser empilhado **antes** do valor. É por isso que o compilador emite `aload_0` **duas vezes** no exemplo acima: uma cópia é consumida pelo `getfield` e outra pelo `putfield`.

> ⚠️ **Pegadinha de prova**
> `getstatic`/`putstatic` **não** consomem `objectref` — o field pertence à classe, não a um objeto. Se a prova mostrar `..., objectref → ..., value` associado a `getstatic`, está **errado**.

> ⚠️ **Pegadinha de prova**
> Tanto `getstatic` quanto `putstatic` podem **disparar a inicialização da classe** (`<clinit>`), se ela ainda não tiver ocorrido.

> ⚠️ **Pegadinha de prova**
> Um field `boolean` na pilha é um **`int`**. Não existe "valor booleano" na pilha de operandos.

### 10.5 Carga de elemento de array: `?aload`

Acessa um elemento de um array **no heap** e o **copia para a pilha de operandos**. Essas instruções **não possuem operandos** (tudo vem da pilha).

**Pilha**:
```
..., arrayref, index   →   ..., value
```

**Ação**: `value = arrayref[index]`

| Instrução | Opcode | Tipo do elemento |
|-----------|--------|------------------|
| `aaload` | 0x32 (50) | `reference` |
| `baload` | 0x33 (51) | `byte` (e `boolean`) |
| `caload` | 0x34 (52) | `char` |
| `saload` | 0x35 (53) | `short` |
| `iaload` | 0x36 (54) | `int` |
| `laload` | 0x37 (55) | `long` |
| `faload` | 0x38 (56) | `float` |
| `daload` | 0x39 (57) | `double` |

Perceba que os opcodes são **consecutivos, de 0x32 a 0x39**, na ordem `a, b, c, s, i, l, f, d`.

```java
int[] v = ...;
int x = v[2];
```

```
aload_1        // [arrayref]
iconst_2       // [arrayref, 2]
iaload         // [v[2]]
istore_2       // x = v[2]
```

> ⚠️ **Pegadinha de prova**
> **Cuidado para não confundir `aload` com `aaload`!**
> - `aload_1` = carrega a **variável local 1** (que contém uma referência) para a pilha.
> - `aaload` = carrega **um elemento de um array de referências** para a pilha.
> O `a` duplicado significa "**a**rray + tipo **a** (reference)". O mesmo padrão vale em `astore` (variável local) vs `aastore` (elemento de array).

> ⚠️ **Pegadinha de prova**
> O `index` empilhado é sempre um **`int`** — não existe `laload` com índice `long`. Arrays em Java são limitados a `Integer.MAX_VALUE` elementos por isso.

> ⚠️ **Pegadinha de prova**
> `baload` é usada tanto para arrays de `byte` **quanto** de `boolean`. E o valor que vai para a pilha é sempre promovido a **`int`** (1 slot), mesmo sendo um `byte` de 1 byte na memória.

### 10.6 Armazenamento em array: `?astore`, `arraylength`, `instanceof`, `checkcast`

#### Armazenamento em array

**Pilha**:
```
..., arrayref, index, value   →   ...
```

**Ação**: `arrayref[index] = value`

| Instrução | Opcode | Tipo |
|-----------|--------|------|
| `iastore` | 0x4f (79) | int |
| `lastore` | 0x50 (80) | long |
| `fastore` | 0x51 (81) | float |
| `dastore` | 0x52 (82) | double |
| `aastore` | 0x53 (83) | reference |
| `bastore` | 0x54 (84) | byte / boolean |
| `castore` | 0x55 (85) | char |
| `sastore` | 0x56 (86) | short |

```java
int[] v = new int[3];
v[0] = 7;
```

```
iconst_3
newarray int     // [arrayref]
astore_1         // v = arrayref
aload_1          // [arrayref]
iconst_0         // [arrayref, 0]
bipush 7         // [arrayref, 0, 7]
iastore          // []   -> v[0] = 7
```

| Passo | Instrução | Pilha | Heap |
|-------|-----------|-------|------|
| 1 | `iconst_3` | `3` | — |
| 2 | `newarray int` | `ref` | `[0,0,0]` |
| 3 | `astore_1` | *(vazia)* | var1 = ref |
| 4 | `aload_1` | `ref` | — |
| 5 | `iconst_0` | `ref, 0` | — |
| 6 | `bipush 7` | `ref, 0, 7` | — |
| 7 | `iastore` | *(vazia)* | `[7,0,0]` |

#### `arraylength`

- **Opcode**: 190 (0xbe). Sem operandos.
- **Pilha**: `..., arrayref → ..., length`
- Empilha o comprimento (um `int`) do array.

```java
int n = v.length;
```
```
aload_1
arraylength     // [3]
istore_2
```

> ⚠️ **Pegadinha de prova**
> `length` de um array **não é um field** — não se usa `getfield`, e sim a instrução dedicada `arraylength`. (Já `String.length()` é um **método**, chamado com `invokevirtual`.)

#### `instanceof` e `checkcast`

| Instrução | Opcode | Formato | Pilha | Efeito |
|-----------|--------|---------|-------|--------|
| `instanceof` | 193 (0xc1) | + índice 16 bits CP | `..., objectref → ..., result` | empilha `int` 1 se é instância do tipo, 0 caso contrário (0 também se `objectref` for `null`) |
| `checkcast` | 192 (0xc0) | + índice 16 bits CP | `..., objectref → ..., objectref` | **não altera a pilha**; lança `ClassCastException` se a conversão for inválida |

```java
if (o instanceof String) { String s = (String) o; }
```

```
aload_1
instanceof #2      // [0 ou 1]
ifeq L             // se 0, pula
aload_1
checkcast #2       // valida o cast (pilha inalterada)
astore_2
L: ...
```

> ⚠️ **Pegadinha de prova**
> `checkcast` **deixa a referência na pilha** (não empilha nem desempilha nada de líquido) e **lança exceção** se falhar. `instanceof` **substitui** a referência por um `int` (0 ou 1) e **nunca lança exceção**. `null instanceof X` é sempre `0`/`false`; já `checkcast` com `null` **passa** sem erro.

---

## 11. Gerenciamento da pilha de operandos

Estas instruções não olham para o *tipo* dos valores, só para a **categoria** (quantos slots ocupam):

- **Categoria 1** (1 slot): `int`, `float`, `reference`, `returnAddress`
- **Categoria 2** (2 slots): `long`, `double`

| Instrução | Opcode | Efeito |
|-----------|--------|--------|
| `pop` | 0x57 (87) | descarta o topo (cat 1) |
| `pop2` | 0x58 (88) | descarta 2 slots (um cat 2, ou dois cat 1) |
| `dup` | 0x59 (89) | duplica o topo (cat 1) |
| `dup_x1` | 0x5a (90) | duplica o topo e insere 2 slots abaixo |
| `dup_x2` | 0x5b (91) | duplica o topo e insere 2 ou 3 slots abaixo |
| `dup2` | 0x5c (92) | duplica os 2 slots do topo |
| `dup2_x1` | 0x5d (93) | duplica 2 slots e insere 2 ou 3 slots abaixo |
| `dup2_x2` | 0x5e (94) | duplica 2 slots e insere 2, 3 ou 4 slots abaixo |
| `swap` | 0x5f (95) | troca os dois elementos do topo (**cat 1 apenas**) |

### Detalhamento (slides 86 e 87)

**`pop`** — desempilha o topo (cat 1):
```
..., value   →   ...
```

**`pop2`** — desempilha 2 slots:
```
..., value       →   ...          (se value for cat 2)
..., value1, value2  →   ...      (se os topos forem cat 1)
```

**`dup`** — duplica o topo (cat 1):
```
..., value   →   ..., value, value
```

**`dup2`** — duplica 2 slots:
```
..., value   →   ..., value, value                                 (value cat 2)
..., value2, value1   →   ..., value2, value1, value2, value1      (ambos cat 1)
```

**`dup_x1`** — duplica o topo e insere **dois slots abaixo** (ambos cat 1):
```
..., value2, value1   →   ..., value1, value2, value1
```

**`dup_x2`** — duplica o topo e insere **dois ou três slots abaixo**:
```
..., value3, value2, value1   →   ..., value1, value3, value2, value1   (todos cat 1)
..., cat2, cat1               →   ..., cat1, cat2, cat1
```

**`dup2_x1`** — duplica o(s) topo(s) e insere dois ou três slots abaixo:
```
..., cat1, cat2       →   ..., cat2, cat1, cat2
..., value3, value2, value1   →   ..., value2, value1, value3, value2, value1
                                  (value3, value2, value1 são cat 1)
```

**`dup2_x2`** — duplica o(s) topo(s) e insere dois, três ou **quatro** slots abaixo:
```
..., value4, value3, value2, value1  →  ..., value2, value1, value4, value3, value2, value1
                                        (todos cat 1)
..., value3, value2, cat2   →   ..., cat2, value3, value2, cat2
                                (value3 e value2 são cat 1)
..., cat2, value2, value1   →   ..., value2, value1, cat2, value2, value1
                                (value2, value1 são cat 1)
..., value2, value1         →   ..., value1, value2, value1
                                (value2 e value1 são cat 2)
```

**`swap`** — troca os elementos do topo (**cat 1 apenas**):
```
..., value2, value1   →   ..., value1, value2
```

### Como ler o nome da instrução

```
dup2_x1
 │  │  └── x<n>: quantos SLOTS abaixo a cópia é inserida
 │  └───── 2: duplica 2 SLOTS (sem o 2, duplica 1 slot)
 └──────── duplicar
```

### Aplicações práticas

- `dup` após `new`: para o `invokespecial` consumir uma cópia. (Visto na seção 10.1.)
- `dup_x1` / `dup_x2`: em expressões como `a[i] = x = 5;` ou `this.f = valor` com uso do valor da atribuição.
- `dup` com `putfield`: numa atribuição encadeada `x = obj.f = 5`, o valor precisa sobrar na pilha.

Exemplo de `dup_x2` em `v[i] = x` retornando o valor:

```
..., arrayref, index, value
dup_x2
..., value, arrayref, index, value      <- iastore consome os 3; sobra 'value'
```

> ⚠️ **Pegadinha de prova**
> **`swap` não funciona com `long` e `double`** (categoria 2). Não existe `swap2` na JVM.

> ⚠️ **Pegadinha de prova**
> `dup2` **não** é "duplicar os dois elementos do topo" em todos os casos — é "duplicar os **dois slots** do topo". Se o topo for um `double`, `dup2` duplica **um único valor**.

> ⚠️ **Pegadinha de prova**
> `pop` **não pode** desempilhar um `long` ou `double` (seria deixar meio valor na pilha). Para isso existe `pop2`.

---

## 12. Transferência de controle (desvios)

Conforme o slide 88, o grupo se divide em três:

### Desvio condicional

`ifeq`, `iflt`, `ifle`, `ifne`, `ifgt`, `ifge`, `ifnull`, `ifnonnull`, `if_icmpeq`, `if_icmpne`, `if_icmplt`, `if_icmpgt`, `if_icmple`, `if_icmpge`, `if_acmpeq`, `if_acmpne`.

(Detalhadas na seção 8.)

### Desvio condicional composto

| Instrução | Opcode | Uso |
|-----------|--------|-----|
| `tableswitch` | 170 (0xaa) | `switch` com **cases densos/contíguos** — usa uma **tabela de saltos** indexada diretamente: O(1) |
| `lookupswitch` | 171 (0xab) | `switch` com **cases esparsos** — pares (chave, offset) **ordenados**, busca binária: O(log n) |

```java
switch (x) { case 1: ...; case 2: ...; case 3: ...; }   // -> tableswitch
switch (x) { case 1: ...; case 100: ...; case 5000: ...; } // -> lookupswitch
```

Ambas desempilham um **`int`** (`..., index → ...`) e possuem um destino `default`.

### Desvio incondicional

| Instrução | Opcode | Efeito |
|-----------|--------|--------|
| `goto` | 167 (0xa7) | salto com offset de **16 bits** com sinal |
| `goto_w` | 200 (0xc8) | salto com offset de **32 bits** (métodos muito grandes) |
| `jsr` | 168 (0xa8) | *jump to subroutine*: empilha um `returnAddress` e salta (offset 16 bits) |
| `jsr_w` | 201 (0xc9) | idem, offset 32 bits |
| `ret` | 169 (0xa9) | retorna de sub-rotina: salta para o `returnAddress` **guardado numa variável local** |

`jsr`/`ret` eram usadas para implementar o bloco **`finally`** (a sub-rotina do `finally` era chamada de vários pontos). A partir do Java 6/7 os compiladores passaram a **duplicar o código do `finally`** em vez de usar `jsr`/`ret`, que ficaram **obsoletas** (proibidas em classes com versão ≥ 51.0).

> 🟦 **Divergência Java 8** — reforçando, porque é fácil errar: como o Java 8 gera
> `major_version = 52` e a proibição vale a partir de **51**, **nenhum `.class` de Java 8 pode conter
> `jsr`, `jsr_w` ou `ret`**. Elas aparecem na tabela de opcodes apenas por compatibilidade com
> classes antigas. O **tipo `returnAddress` continua existindo** na JVMS 8 — não confunda a
> instrução obsoleta com o tipo, que segue sendo a melhor resposta para "há tipo na JVM que não
> existe em Java?".

> ⚠️ **Pegadinha de prova**
> `ret` **não** é uma instrução de retorno de método! Retorno de método é `return`/`ireturn`/`areturn`/etc. `ret` retorna de uma **sub-rotina** (`jsr`) e seu operando é um **índice de variável local**, não um offset.

> ⚠️ **Pegadinha de prova**
> `tableswitch` é usada para cases **contíguos** (acesso direto por índice) e `lookupswitch` para cases **esparsos** (busca em pares chave/offset ordenados). Trocar as duas é erro comum.

> ⚠️ **Pegadinha de prova**
> Os offsets de desvio são **relativos** ao endereço da instrução de desvio e devem apontar para **dentro do mesmo método** — a especificação enfatiza isso em todos os slides de comparação.

---

## 13. Invocação de métodos e retorno

### As cinco instruções de invocação (slide 89)

| Instrução | Opcode | Quando é usada |
|-----------|--------|----------------|
| `invokevirtual` | 182 (0xb6) | Chama um **método de um objeto**. É a forma normal de chamar um método da mesma classe do objeto. Despacho **dinâmico** (polimorfismo). |
| `invokespecial` | 183 (0xb7) | Chama um método de instância que **requer tratamento especial**: método de **iniciação** (construtor `<init>`), método **privado** ou método de **superclasse** (`super.m()`). |
| `invokestatic` | 184 (0xb8) | Chama um **método de classe** (`static`). |
| `invokeinterface` | 185 (0xb9) | Chama um método **implementado por uma interface**. |
| `invokedynamic` | 186 (0xba) | Chama um **método dinâmico** (requer um objeto). Usada por lambdas e linguagens dinâmicas na JVM. |

### Detalhe de `invokevirtual` (slide 90)

**Formato**:
```
invokevirtual  indexbyte1  indexbyte2
```

**Operação na pilha**:
```
..., objectref, [arg1, [arg2 ...]]   →   ...
```

**Descrição** (texto da especificação):
- O índice formado pelos dois bytes aponta para uma entrada no **Constant Pool** que dá o **nome e o descritor** do método sendo chamado — o que define **o número de argumentos** que possui.
- O método **não pode ser um método construtor**.
- O método deve ser da **classe do objeto `objectref` ou de uma superclasse**.
- Os argumentos são **retirados da pilha** e um **frame é construído** para executar esse método com os argumentos passados.

```
 Antes da chamada (no frame do chamador)     Depois (novo frame do chamado)
  Pilha de operandos                          Variáveis locais do novo frame
  +---------+                                 +--------------------+
  | arg2    | <- topo                         | [0] objectref (this)|
  | arg1    |                                 | [1] arg1            |
  | objectref|                                | [2] arg2            |
  +---------+                                 +--------------------+
```

### Instruções de retorno

| Instrução | Opcode | Retorna |
|-----------|--------|---------|
| `ireturn` | 172 (0xac) | `int` (e `boolean`, `byte`, `char`, `short`) |
| `lreturn` | 173 (0xad) | `long` |
| `freturn` | 174 (0xae) | `float` |
| `dreturn` | 175 (0xaf) | `double` |
| `areturn` | 176 (0xb0) | `reference` |
| `return` | 177 (0xb1) | **`void`** (sem prefixo!) |

Ao executar uma instrução de retorno, o valor (se houver) é desempilhado do frame atual, o frame é **destruído** e o valor é empilhado na **pilha de operandos do frame do chamador**.

### Exemplo completo

```java
class A {
    int dobro(int x) { return x * 2; }

    void teste() {
        int r = dobro(21);
        System.out.println(r);
    }
}
```

Bytecode de `dobro(int x)` — var0 = `this`, var1 = `x`:
```
0: iload_1        // [21]
1: iconst_2       // [21, 2]
2: imul           // [42]
3: ireturn        // devolve 42 ao chamador
```

Bytecode de `teste()`:
```
 0: aload_0               // [this]
 1: bipush 21             // [this, 21]
 3: invokevirtual #2      // dobro(I)I -> consome this e 21, empilha 42: [42]
 6: istore_1              // r = 42
 7: getstatic #3          // System.out -> [PrintStream]
10: iload_1               // [PrintStream, 42]
11: invokevirtual #4      // println(I)V -> consome os dois: []
14: return
```

| PC | Instrução | Pilha | Locais |
|----|-----------|-------|--------|
| 0 | `aload_0` | `this` | var0=this |
| 1 | `bipush 21` | `this, 21` | — |
| 3 | `invokevirtual` | `42` | (frame de `dobro` criado e destruído) |
| 6 | `istore_1` | *(vazia)* | var1 = **42** |
| 7 | `getstatic` | `out` | — |
| 10 | `iload_1` | `out, 42` | — |
| 11 | `invokevirtual` | *(vazia)* | imprime 42 |
| 14 | `return` | — | frame destruído |

> ⚠️ **Pegadinha de prova**
> `invokestatic` **não consome `objectref`** — a pilha é só `..., [arg1, arg2...]`. Todas as outras invocações consomem a referência do objeto **por baixo dos argumentos**.

> ⚠️ **Pegadinha de prova**
> Construtores (`<init>`) são chamados por **`invokespecial`**, **nunca** por `invokevirtual`. A especificação diz explicitamente que o método de `invokevirtual` "não pode ser um método construtor".

> ⚠️ **Pegadinha de prova**
> `return` (void) **não tem prefixo de tipo**. Não existe "`vreturn`". E métodos que retornam `boolean`, `byte`, `char` ou `short` usam **`ireturn`** — mais uma consequência da promoção a `int`.

> ⚠️ **Pegadinha de prova**
> `super.metodo()` usa `invokespecial`, não `invokevirtual` — senão o despacho dinâmico faria a chamada voltar para o método sobrescrito, causando recursão infinita.

---

## 14. Exceções e sincronização (complemento)

Estes grupos aparecem apenas na **tabela-sumário de opcodes** (slide 92) desta parte do material, mas são cobrados:

### Exceções

| Instrução | Opcode | Pilha | Efeito |
|-----------|--------|-------|--------|
| `athrow` | 191 (0xbf) | `..., objectref → objectref` | lança a exceção referenciada |

`athrow` **limpa toda a pilha de operandos** do frame e deixa apenas a referência da exceção. Em seguida a JVM procura na **tabela de exceções** do método (atributo `Code` → `exception_table`) um *handler* cujo intervalo `[start_pc, end_pc)` contenha o PC atual e cujo tipo seja compatível. Se não achar, o frame é **desempilhado** e a busca continua no chamador.

Pontos importantes:
- O bloco **`try`** não gera instrução alguma — ele é apenas um **intervalo de PCs** registrado na tabela de exceções.
- O **`catch`** é o código no `handler_pc`.
- O **`finally`** é implementado duplicando o código (antigamente, com `jsr`/`ret`).
- Se `objectref` for `null`, `athrow` lança `NullPointerException`.

### Sincronização

| Instrução | Opcode | Pilha | Efeito |
|-----------|--------|-------|--------|
| `monitorenter` | 194 (0xc2) | `..., objectref → ...` | adquire o monitor (lock) do objeto |
| `monitorexit` | 195 (0xc3) | `..., objectref → ...` | libera o monitor do objeto |

```java
synchronized (obj) { ... }
```
gera `monitorenter` no início e `monitorexit` no fim — **e mais um `monitorexit`** num handler de exceção, para garantir que o lock seja liberado mesmo se o bloco lançar exceção.

> ⚠️ **Pegadinha de prova**
> Um **método** `synchronized` **não gera `monitorenter`/`monitorexit`**! Ele é marcado com a flag `ACC_SYNCHRONIZED` no `access_flags` do método, e a JVM adquire/libera o monitor implicitamente. As instruções só aparecem em **blocos** `synchronized(obj){}`.

---

## 15. Sumário das instruções da JVM — tabela de opcodes

Os slides 91 e 92 trazem a tabela completa de opcodes, indexada por **linha = nibble alto** e **coluna = nibble baixo** do byte. Reproduzida abaixo:

### Opcodes 0x00 – 0x7f

|  | **0** | **1** | **2** | **3** | **4** | **5** | **6** | **7** | **8** | **9** | **a** | **b** | **c** | **d** | **e** | **f** |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **0** | nop | aconst_null | iconst_m1 | iconst_0 | iconst_1 | iconst_2 | iconst_3 | iconst_4 | iconst_5 | lconst_0 | lconst_1 | fconst_0 | fconst_1 | fconst_2 | dconst_0 | dconst_1 |
| **1** | bipush | sipush | ldc | ldc_w | ldc2_w | iload | lload | fload | dload | aload | iload_0 | iload_1 | iload_2 | iload_3 | lload_0 | lload_1 |
| **2** | lload_2 | lload_3 | fload_0 | fload_1 | fload_2 | fload_3 | dload_0 | dload_1 | dload_2 | dload_3 | aload_0 | aload_1 | aload_2 | aload_3 | iaload | laload |
| **3** | faload | daload | aaload | baload | caload | saload | istore | lstore | fstore | dstore | astore | istore_0 | istore_1 | istore_2 | istore_3 | lstore_0 |
| **4** | lstore_1 | lstore_2 | lstore_3 | fstore_0 | fstore_1 | fstore_2 | fstore_3 | dstore_0 | dstore_1 | dstore_2 | dstore_3 | astore_0 | astore_1 | astore_2 | astore_3 | iastore |
| **5** | lastore | fastore | dastore | aastore | bastore | castore | sastore | **pop** | **pop2** | **dup** | **dup_x1** | **dup_x2** | **dup2** | **dup2_x1** | **dup2_x2** | **swap** |
| **6** | iadd | ladd | fadd | dadd | isub | lsub | fsub | dsub | imul | lmul | fmul | dmul | idiv | ldiv | fdiv | ddiv |
| **7** | irem | lrem | frem | drem | ineg | lneg | fneg | dneg | ishl | lshl | ishr | lshr | iushr | lushr | iand | land |

### Opcodes 0x80 – 0xff

|  | **0** | **1** | **2** | **3** | **4** | **5** | **6** | **7** | **8** | **9** | **a** | **b** | **c** | **d** | **e** | **f** |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **8** | ior | lor | ixor | lxor | iinc | i2l | i2f | i2d | l2i | l2f | l2d | f2i | f2l | f2d | d2i | d2l |
| **9** | d2f | i2b | i2c | i2s | lcmp | fcmpl | fcmpg | dcmpl | dcmpg | ifeq | ifne | iflt | ifge | ifgt | ifle | if_icmpeq |
| **a** | if_icmpne | if_icmplt | if_icmpge | if_icmpgt | if_icmple | if_acmpeq | if_acmpne | goto | jsr | ret | tableswitch | lookupswitch | ireturn | lreturn | freturn | dreturn |
| **b** | areturn | return | getstatic | putstatic | getfield | putfield | invokevirtual | invokespecial | invokestatic | invokeinterface | *(invokedynamic)* | new | newarray | anewarray | arraylength | **athrow** |
| **c** | checkcast | instanceof | monitorenter | monitorexit | wide | multianewarray | ifnull | ifnonnull | goto_w | jsr_w | **breakpoint** ⛔ | — | — | — | — | — |
| **d** | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| **e** | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| **f** | — | — | — | — | — | — | — | — | — | — | — | — | — | — | **impdep1** ⛔ | **impdep2** ⛔ |

**Nota do slide 92**: "Os três opcode em destaque são reservados pela Sun" — são `breakpoint` (0xca), `impdep1` (0xfe) e `impdep2` (0xff).

*(Observação: a posição 0xba está vazia no material original da 2ª edição da especificação, pois `invokedynamic` só foi introduzida no Java 7; a parte textual do slide 89 já a menciona.)*

### Como ler a tabela

Para descobrir a instrução do byte `0x60`: linha **6**, coluna **0** → `iadd`.
Para descobrir o opcode de `dcmpg`: procure na tabela → linha **9**, coluna **8** → `0x98` = 152.

### Padrões visíveis na tabela (ótimos para memorizar)

1. **Aritmética em blocos de 4** na ordem `i, l, f, d`:
   `0x60-63` add, `0x64-67` sub, `0x68-6b` mul, `0x6c-6f` div, `0x70-73` rem, `0x74-77` neg.
   Ou seja: **`opcode = base + 0` para int, `+1` para long, `+2` para float, `+3` para double**.
2. **Loads e stores** também seguem `i, l, f, d, a`.
3. **`?aload` de arrays**: 0x2e–0x35 na ordem `i, l, f, d, a, b, c, s`. **`?astore`**: 0x4f–0x56 na mesma ordem.
4. **Retornos**: 0xac–0xb1 na ordem `i, l, f, d, a, (void)`.
5. **`if<cond>`** (0x99–0x9e) na ordem `eq, ne, lt, ge, gt, le`; **`if_icmp<cond>`** (0x9f–0xa4) na mesma ordem.

> ⚠️ **Pegadinha de prova**
> A ordem canônica dos sufixos de condição é **eq, ne, lt, ge, gt, le** (e não eq, ne, lt, gt, le, ge). Note que `lt` vem antes de `ge` e `gt` antes de `le` — cada condição é seguida da sua negação.

> ⚠️ **Pegadinha de prova**
> As linhas **d** e **e** da tabela estão **inteiramente vazias** — há muitos opcodes não atribuídos. A JVM usa cerca de 200 dos 256 valores possíveis.

---

## 16. Exemplos completos: Java ⇄ bytecode passo a passo

### Exemplo A — Expressão aritmética simples

```java
public int calcula() {
    int a = 10;
    int b = 3;
    return (a + b) * 2 - a / b;
}
```

```
 0: bipush 10
 2: istore_1          // a = 10
 3: iconst_3
 4: istore_2          // b = 3
 5: iload_1           // [10]
 6: iload_2           // [10, 3]
 7: iadd              // [13]
 8: iconst_2          // [13, 2]
 9: imul              // [26]
10: iload_1           // [26, 10]
11: iload_2           // [26, 10, 3]
12: idiv              // [26, 3]      <-- divisão inteira: 10/3 = 3
13: isub              // [23]
14: ireturn           // retorna 23
```

Rastreio completo:

| PC | Instrução | Pilha (topo à direita) | Locais |
|----|-----------|------------------------|--------|
| 0 | `bipush 10` | `10` | var0=this |
| 2 | `istore_1` | *(vazia)* | a=10 |
| 3 | `iconst_3` | `3` | a=10 |
| 4 | `istore_2` | *(vazia)* | a=10, b=3 |
| 5 | `iload_1` | `10` | — |
| 6 | `iload_2` | `10, 3` | — |
| 7 | `iadd` | `13` | — |
| 8 | `iconst_2` | `13, 2` | — |
| 9 | `imul` | `26` | — |
| 10 | `iload_1` | `26, 10` | — |
| 11 | `iload_2` | `26, 10, 3` | — |
| 12 | `idiv` | `26, 3` | — |
| 13 | `isub` | `23` | — |
| 14 | `ireturn` | *(retorna)* | — |

**Profundidade máxima da pilha**: 3. **Variáveis locais**: 3 (this, a, b).

### Exemplo B — Tipos de 2 slots (`long` e `double`)

```java
public double media(long soma, int n) {
    return (double) soma / n;
}
```

Alocação de variáveis locais (método de instância):

```
var0 = this      (1 slot)
var1 = soma      (2 slots: var1 e var2!)
var3 = n         (1 slot)
```

```
0: lload_1         // [soma]   ocupa 2 slots da pilha
1: l2d             // [soma como double]  (ainda 2 slots)
2: iload_3         // [soma_d, n]         (3 slots)
3: i2d             // [soma_d, n_d]       (4 slots)
4: ddiv            // [resultado]         (2 slots)
5: dreturn
```

| PC | Instrução | Pilha (slots) | Comentário |
|----|-----------|----------------|------------|
| 0 | `lload_1` | `soma` (2) | carrega da dupla var1/var2 |
| 1 | `l2d` | `somaD` (2) | long → double |
| 2 | `iload_3` | `somaD, n` (3) | `n` está em var3, **não** var2 |
| 3 | `i2d` | `somaD, nD` (4) | int → double |
| 4 | `ddiv` | `res` (2) | divisão em ponto flutuante |
| 5 | `dreturn` | — | devolve 2 slots ao chamador |

> ⚠️ **Pegadinha de prova**
> Com um `long` no parâmetro 1, o parâmetro seguinte está em **var3**, não em var2 — o `long` consumiu var1 **e** var2. Questões que perguntam "qual o índice da variável local X" exploram exatamente isso.

### Exemplo C — `if / else`

```java
int max(int a, int b) {
    if (a > b) return a;
    else       return b;
}
```

```
0: iload_1          // [a]
1: iload_2          // [a, b]
2: if_icmple 7      // se a <= b, desvia para 7  (condição INVERTIDA)
5: iload_1          // [a]
6: ireturn
7: iload_2          // [b]
8: ireturn
```

### Exemplo D — Laço `while` com array

```java
int soma(int[] v) {
    int s = 0;
    int i = 0;
    while (i < v.length) {
        s += v[i];
        i++;
    }
    return s;
}
```

Locais: var0=`this`, var1=`v`, var2=`s`, var3=`i`.

```
 0: iconst_0
 1: istore_2          // s = 0
 2: iconst_0
 3: istore_3          // i = 0
 4: iload_3           // [i]
 5: aload_1           // [i, v]
 6: arraylength       // [i, len]
 7: if_icmpge 22      // se i >= len -> sai
10: iload_2           // [s]
11: aload_1           // [s, v]
12: iload_3           // [s, v, i]
13: iaload            // [s, v[i]]
14: iadd              // [s + v[i]]
15: istore_2          // s = s + v[i]
16: iinc 3, 1         // i++        <-- pilha intocada
19: goto 4
22: iload_2           // [s]
23: ireturn
```

Rastreio de uma iteração (com `v = {5, 7}`, `s=0`, `i=0`):

| PC | Instrução | Pilha | Locais |
|----|-----------|-------|--------|
| 4 | `iload_3` | `0` | s=0, i=0 |
| 5 | `aload_1` | `0, ref` | — |
| 6 | `arraylength` | `0, 2` | — |
| 7 | `if_icmpge 22` | *(vazia)* | 0 >= 2? não → continua |
| 10 | `iload_2` | `0` | — |
| 11 | `aload_1` | `0, ref` | — |
| 12 | `iload_3` | `0, ref, 0` | — |
| 13 | `iaload` | `0, 5` | `v[0] = 5` |
| 14 | `iadd` | `5` | — |
| 15 | `istore_2` | *(vazia)* | **s=5** |
| 16 | `iinc 3, 1` | *(vazia)* | **i=1** |
| 19 | `goto 4` | *(vazia)* | volta ao teste |

### Exemplo E — Criação de objeto e chamada de método

```java
class Ponto {
    int x, y;
    Ponto(int x, int y) { this.x = x; this.y = y; }
    int soma() { return x + y; }
}

// no main:
Ponto p = new Ponto(3, 4);
int s = p.soma();
```

Construtor `<init>(int,int)` (var0=this, var1=x, var2=y):
```
 0: aload_0
 1: invokespecial #1    // Object.<init>()V   <-- chamada implícita a super()
 4: aload_0             // [this]
 5: iload_1             // [this, 3]
 6: putfield #2         // this.x = 3    -> []
 9: aload_0             // [this]
10: iload_2             // [this, 4]
11: putfield #3         // this.y = 4    -> []
14: return
```

Método `soma()`:
```
0: aload_0          // [this]
1: getfield #2      // [x]
4: aload_0          // [x, this]
5: getfield #3      // [x, y]
8: iadd             // [x+y]
9: ireturn
```

No `main`:
```
 0: new #4              // [ref]
 3: dup                 // [ref, ref]
 4: iconst_3            // [ref, ref, 3]
 5: iconst_4            // [ref, ref, 3, 4]
 6: invokespecial #5    // <init>(II)V -> [ref]
 9: astore_1            // p = ref     -> []
10: aload_1             // [ref]
11: invokevirtual #6    // soma()I     -> [7]
14: istore_2            // s = 7
```

### Exemplo F — Campo estático e `switch`

```java
static int contador;

static String dia(int d) {
    contador++;
    switch (d) {
        case 1: return "Seg";
        case 2: return "Ter";
        default: return "?";
    }
}
```

```
 0: getstatic #2        // [contador]
 3: iconst_1            // [contador, 1]
 4: iadd                // [contador+1]
 5: putstatic #2        // []
 8: iload_0             // [d]     (método static: parâmetro em var0!)
 9: tableswitch { 1: 32; 2: 37; default: 42 }
32: ldc #3              // "Seg"
34: areturn
37: ldc #4              // "Ter"
39: areturn
42: ldc #5              // "?"
44: areturn
```

> ⚠️ **Pegadinha de prova**
> Em um método **`static`**, **não existe `this`** — o primeiro parâmetro fica em **var0** (por isso `iload_0`). Em métodos de instância, var0 é sempre `this` e o primeiro parâmetro fica em var1.

> ⚠️ **Pegadinha de prova**
> `contador++` num field estático **não** usa `iinc`! `iinc` só funciona com **variáveis locais**. Para fields, é `getstatic` + `iconst_1` + `iadd` + `putstatic`.

---

## 17. Pegadinhas de prova — lista consolidada

Checklist final de verdadeiro/falso.

| Afirmação | V/F | Por quê |
|-----------|-----|---------|
| Existem instruções aritméticas dedicadas para `byte`, `char`, `short` e `boolean`. | **F** | São promovidos a `int`; usam-se as instruções `i...`. |
| `long` e `double` ocupam 2 slots na pilha e nas variáveis locais. | **V** | São de categoria 2. |
| `reference` ocupa 2 slots numa JVM de 64 bits. | **F** | Uma `reference` é sempre **categoria 1** = 1 slot, independentemente da arquitetura. |
| O opcode da JVM tem 1 byte. | **V** | Daí o limite de 256 instruções. |
| `iinc` altera a pilha de operandos. | **F** | Opera direto na variável local. |
| Existe `linc` para incrementar `long`. | **F** | Só `iinc`, e só para `int`. |
| `ishl` desloca por `value2 & 0x1F`. | **V** | 5 bits menos significativos. |
| `lshl` desloca por `value2 & 0x3F`. | **V** | 6 bits menos significativos. |
| Existe `iushl`. | **F** | Só há versões unsigned do shift à **direita**. |
| `fcmpg` empilha 1 quando há NaN. | **V** | O `g` indica "greater". |
| `dcmpl` empilha -1 quando há NaN. | **V** | O `l` indica "less". |
| `lcmp` possui variantes `lcmpl` e `lcmpg`. | **F** | `long` não tem NaN; só existe `lcmp` (0x94). |
| Existe `icmp` para comparar dois int e empilhar -1/0/1. | **F** | Para `int` há desvio direto: `if_icmp<cond>`. |
| `if_icmplt` desvia se `value1 < value2`. | **V** | `value1` é o de baixo, `value2` o do topo. |
| Existe `if_acmplt`. | **F** | Referências só admitem `eq` e `ne`. |
| `i2c` estende com sinal. | **F** | `i2c` estende **sem** sinal; `i2b` e `i2s` estendem com sinal. |
| Existe `b2i`. | **F** | `byte` já é carregado como `int`; conversão implícita. |
| Existe `d2b`. | **F** | Precisa de duas instruções: `d2i` + `i2b`. |
| `new` executa o construtor. | **F** | Só aloca; o construtor é `invokespecial`. |
| `newarray` usa índice do Constant Pool. | **F** | Usa 1 byte literal (`atype`). Quem usa CP é `anewarray`/`multianewarray`. |
| `T_INT` vale 10 e `T_LONG` vale 11. | **V** | A codificação começa em `T_BOOLEAN=4`. |
| Elementos criados por `multianewarray` são iniciados com `null`. | **V** | Conforme o slide 79. |
| `getstatic` desempilha um `objectref`. | **F** | Não há objeto: `... → ..., value`. |
| Em `putfield`, o `value` está no topo e o `objectref` abaixo dele. | **V** | `..., objectref, value → ...`. |
| `getstatic` pode disparar a inicialização da classe. | **V** | "a classe ou interface é iniciada (se não já o foi)". |
| `aload` e `aaload` fazem a mesma coisa. | **F** | `aload` = variável local; `aaload` = elemento de array de referências. |
| `v.length` é compilado com `getfield`. | **F** | Usa a instrução dedicada `arraylength`. |
| `checkcast` empilha 0 ou 1. | **F** | Isso é `instanceof`. `checkcast` deixa a referência e lança `ClassCastException` se falhar. |
| `null instanceof X` resulta em 0. | **V** | `instanceof` nunca lança exceção. |
| `swap` funciona com `double`. | **F** | Só categoria 1. Não existe `swap2`. |
| `pop` pode desempilhar um `long`. | **F** | Precisa de `pop2`. |
| `dup2` sempre duplica dois valores. | **F** | Duplica dois **slots** — pode ser um único `double`. |
| `ret` é a instrução de retorno de método. | **F** | Retorna de sub-rotina (`jsr`); seu operando é um índice de variável local. |
| `tableswitch` é usada para cases esparsos. | **F** | Cases esparsos → `lookupswitch`. |
| Construtores são chamados com `invokevirtual`. | **F** | `invokespecial`. |
| Um método que retorna `boolean` usa `ireturn`. | **V** | `boolean` é `int` na pilha. |
| Existe `vreturn` para métodos `void`. | **F** | É simplesmente `return` (0xb1). |
| `invokestatic` consome `objectref`. | **F** | Método de classe não tem `this`. |
| Método `synchronized` gera `monitorenter`/`monitorexit`. | **F** | Usa a flag `ACC_SYNCHRONIZED`; as instruções aparecem em **blocos** `synchronized`. |
| `breakpoint`, `impdep1` e `impdep2` são reservados. | **V** | Destacados no slide 92. |
| `wide` amplia índices de variável local para 16 bits. | **V** | E, com `iinc`, também a constante (16 bits com sinal). |
| Em método de instância, var0 é `this`. | **V** | Em método `static`, var0 é o primeiro parâmetro. |
| Offsets de desvio são absolutos no arquivo `.class`. | **F** | São **relativos** à instrução e devem ficar dentro do mesmo método. |

---

## 18. Resumo em 10 pontos

1. **A JVM é uma máquina de pilha com opcode de 1 byte.** Cada instrução desempilha operandos e empilha resultados; no máximo 256 instruções existem, o que força um conjunto enxuto e tipado por prefixo.

2. **Os prefixos codificam o tipo**: `i` (int), `l` (long), `f` (float), `d` (double), `a` (reference), `b` (byte), `c` (char), `s` (short). **Não há aritmética para `boolean`, `byte`, `char` e `short`** — esses tipos são **promovidos a `int`** e os prefixos `b`, `c`, `s` sobrevivem só em acesso a arrays, conversões de estreitamento e `bipush`/`sipush`.

3. **Categoria 1 × categoria 2**: `long` e `double` ocupam **2 slots**; `int`, `float`, `reference` e `returnAddress` ocupam **1**. Isso define quais variáveis locais são consumidas, como `pop`/`pop2`/`dup`/`dup2` se comportam e por que `swap` não funciona com `long`/`double`.

4. **Shifts e lógicas** existem só para `int` e `long`. A contagem de deslocamento vem dos **5 bits baixos** (int) ou **6 bits baixos** (long) de `value2`; `ushr` insere **zeros** à esquerda e `shr` preserva o sinal; não existe `ushl` nem `not` (o complemento é `ixor` com −1).

5. **`iinc` é a exceção que confirma a regra**: incrementa uma variável local `int` diretamente, **sem tocar na pilha de operandos**, usando índice `unsigned byte` e constante `signed byte` (ampliáveis para 16 bits com `wide`). É o coração dos laços `for`.

6. **Comparação tem dois estilos**: `lcmp`, `fcmpl/g` e `dcmpl/g` **empilham um `int` −1/0/1** e exigem um `if<cond>` posterior (com `g` → 1 e `l` → −1 no caso **NaN**); já `int` e referências desviam diretamente com `if<cond>`, `if_icmp<cond>`, `if_acmp<cond>`, `ifnull`/`ifnonnull`. Os offsets são relativos e confinados ao método.

7. **Conversões** dividem-se em **promoção** (`i2l`, `i2f`, `i2d`, `l2f`, `l2d`, `f2d` — sem perda de magnitude) e **estreitamento** (`l2i`, `f2i`, `f2l`, `d2i`, `d2l`, `d2f`, `i2b`, `i2c`, `i2s` — **descartam bits superiores e podem mudar o sinal**). `i2c` estende **sem sinal**; `i2b`/`i2s`, **com sinal**.

8. **Criação de objetos é um padrão de três passos**: `new` (aloca no heap e zera os fields) → `dup` → `invokespecial <init>` (construtor). Arrays têm instruções próprias: `newarray` (primitivos, operando `atype` de 4 a 11), `anewarray` (referências) e `multianewarray` (multidimensional, elementos iniciados com `null`).

9. **Fields e arrays**: `getstatic`/`putstatic` (sem `objectref`, podem inicializar a classe) e `getfield`/`putfield` (com `objectref`; em `putfield` a pilha é `..., objectref, value`). Elementos de array usam `?aload` (`..., arrayref, index → ..., value`, opcodes 0x32–0x39) e `?astore` (`..., arrayref, index, value → ...`), mais `arraylength`, `instanceof` (empilha 0/1) e `checkcast` (mantém a pilha e lança `ClassCastException`).

10. **Controle e invocação**: desvios condicionais (`if*`), compostos (`tableswitch` para cases densos, `lookupswitch` para esparsos) e incondicionais (`goto`, `goto_w`, `jsr`/`jsr_w`/`ret` — obsoletas, ligadas ao `finally`); e as cinco invocações — `invokevirtual` (objeto, despacho dinâmico), `invokespecial` (construtor/privado/`super`), `invokestatic` (classe), `invokeinterface` (interface) e `invokedynamic` — com retornos `ireturn`, `lreturn`, `freturn`, `dreturn`, `areturn` e `return` (void). Fecham o conjunto `athrow` (exceções) e `monitorenter`/`monitorexit` (sincronização em blocos), lembrando que `breakpoint`, `impdep1` e `impdep2` são **opcodes reservados**.

---

## Apêndice — Este material e o Java SE 8

| Tema | 2ª edição (o slide) | **JVMS 8** |
|---|---|---|
| Opcode `0xba` (186) | 🟦 Aparece **vazio / não usado** na tabela | É **`invokedynamic`** desde o Java 7, e é com ele que **toda lambda e todo *method reference*** são compilados |
| Instruções de invocação | 4 | **5** (com `invokedynamic`) — o resumo já lista as 5 |
| `jsr` / `jsr_w` / `ret` | Uso normal | 🟦 **Proibidas** em `major ≥ 51`; não podem aparecer num `.class` de Java 8 |
| `invokespecial` | `<init>`, `private`, `super` | \+ **`Interface.super.metodo()`** (Java 8, métodos `default`) |
| `invokevirtual` / `invokeinterface` | Resolvem para métodos de classe / de interface abstratos | \+ podem resolver para métodos **`default`**, que têm corpo na própria interface |
| Aritmética de `byte`/`char`/`short`/`boolean` | Não existe; viram `int` | ✅ **Igual no Java 8** |
| `breakpoint` (0xca), `impdep1` (0xfe), `impdep2` (0xff) | Reservados | ✅ **Igual no Java 8** |

**Como uma lambda vira bytecode no Java 8** — vale saber, porque é o que explica o `0xba`:

```java
Runnable r = () -> System.out.println("oi");
```
```
invokedynamic #2, 0    // run()Ljava/lang/Runnable;
```
O `#2` aponta para um `CONSTANT_InvokeDynamic` (tag **18**), que remete ao atributo
`BootstrapMethods` da classe. Na **primeira** execução, a JVM chama
`LambdaMetafactory.metafactory` (um `CONSTANT_MethodHandle`, tag **15**), que fabrica e guarda em
cache uma instância de `Runnable`. Nas execuções seguintes, o *call site* já está ligado. Ou seja:
lambda **não** é classe anônima, e o corpo dela vira um método sintético `lambda$main$0`.

🟥 **Independente de versão:** a tabela de opcodes dos slides tem `0xba` vazio (erro herdado da 2ª
edição) e `jsr`/`ret` listadas sem a ressalva de obsolescência.

Detalhamento completo em [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).

---

*Bons estudos! Se puder, gere seu próprio bytecode com `javac Exemplo.java && javap -c -verbose Exemplo` — é o melhor exercício para fixar a relação Java ⇄ bytecode.*
