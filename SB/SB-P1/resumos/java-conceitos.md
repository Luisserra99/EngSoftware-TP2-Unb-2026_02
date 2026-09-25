# Conceitos sobre a Linguagem Java e a JVM
### Resumo de estudo — Software Básico (CIC0104 / UnB)

> Material baseado no PDF `java-conceitos.pdf` (21 slides), que por sua vez se baseia no livro
> **"The Java™ Virtual Machine Specification", Second Edition — Tim Lindholm & Frank Yellin**.

> 🔎 **Revisão Java 8** — atenção à base deste PDF: ele segue a **2ª edição** da JVMS (Java 2, ~1999),
> mas a prova cobre **Java SE 8 / JVMS 8** (`major_version = 52`). Entre uma edição e outra entraram
> `invokedynamic`, as tags 15/16/18 do pool, `StackMapTable`, a proibição de `jsr`/`ret` e os métodos
> `default` em interfaces. Os pontos afetados estão marcados com 🟦 (**Divergência Java 8**),
> 🟪 (**Posterior ao Java 8**) e 🟥 (**Divergência com a especificação**). Apanhado completo em
> [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).

---

## Sumário

1. [O que você precisa saber para a prova](#1-o-que-você-precisa-saber-para-a-prova)
2. [Introdução: Java vs. C](#2-introdução-java-vs-c)
3. [A Máquina Virtual Java (JVM)](#3-a-máquina-virtual-java-jvm)
   - 3.1 [O que a JVM provê](#31-o-que-a-jvm-provê)
   - 3.2 [Máquina de pilha, não de registradores](#32-máquina-de-pilha-não-de-registradores)
   - 3.3 [Threads, pilha JVM e frames](#33-threads-pilha-jvm-e-frames)
   - 3.4 [Vetor de variáveis locais](#34-vetor-tabela-de-variáveis-locais)
   - 3.5 [Pilha de operandos](#35-pilha-de-operandos-32-bits)
   - 3.6 [Pool de constantes](#36-pool-de-constantes-constant-pool)
4. [Tipos e valores](#4-tipos-e-valores)
   - 4.1 [Tipos primitivos](#41-tipos-primitivos)
   - 4.2 [Ponto flutuante e valores especiais](#42-ponto-flutuante-e-valores-especiais)
5. [Tipos de variáveis (as 7 categorias)](#5-tipos-de-variáveis-as-7-categorias)
6. [Nomes e Pacotes](#6-nomes-e-pacotes)
7. [Classes fundamentais: Object e String](#7-classes-fundamentais-object-e-string)
8. [Classes abstratas](#8-classes-abstratas)
9. [Interfaces](#9-interfaces)
10. [Arquitetura de uma JVM (o diagrama)](#10-arquitetura-de-uma-jvm-o-diagrama)
11. [Execução de um .class: iniciação da JVM](#11-execução-de-um-class-iniciação-da-jvm)
    - 11.1 [Carga (Loading)](#111-carga-loading)
    - 11.2 [Ligação (Linking): verificação, preparação, resolução](#112-ligação-linking)
    - 11.3 [Iniciação (Initialization)](#113-iniciação-initialization)
12. [Possíveis erros na inicialização](#12-possíveis-erros-na-inicialização)
13. [Resumo em 10 pontos](#13-resumo-em-10-pontos)

---

## 1. O que você precisa saber para a prova

Se o tempo for curto, memorize **estes** pontos — são os que o material enfatiza (inclusive nos rodapés
em destaque de cada slide, que costumam virar questão):

| # | Ponto-chave | Onde cai |
|---|---|---|
| 1 | A JVM **não possui registradores de propósito geral**: é uma **máquina de pilha**. | V/F clássico |
| 2 | A **pilha de operandos é de 32 bits**; tipos menores são convertidos/alinhados a 32 bits; `long` e `double` ocupam **dois** slots de 32 bits. | V/F e cálculo |
| 3 | **Cada thread tem sua própria pilha JVM**; cada invocação de método cria um **frame**. | V/F |
| 4 | Um frame tem 3 partes: **pilha de operandos**, **vetor de variáveis locais** e **referência ao pool de constantes em runtime**. | Descritiva |
| 5 | Em método **de instância/construtor**, o índice **0** das variáveis locais guarda o **`this`**; em método **static**, o índice 0 guarda o **primeiro parâmetro formal**. | V/F favorito |
| 6 | Tamanho do vetor de locais e da pilha de operandos é determinado em **tempo de compilação**. | V/F |
| 7 | **Opcode** = 1 byte com o código de "máquina" de uma instrução Java no `.class`. O **índice do pool de constantes** é operando de **1 byte (1–255)** ou **2 bytes (1–65535)**. | Numérico |
| 8 | Java: coletor de lixo, **tempo não determinístico**, **não indicado para tempo real**; C: heap manual, **mais eficiente**, permite **referência pendente** (dangling). | Comparativa |
| 9 | Java usa **referências tipadas**, **não ponteiros**. C usa **ponteiros tipados**. | V/F |
| 10 | `char` em Java tem **2 bytes sem sinal** (Unicode) — não 1 byte como em C. | V/F |
| 11 | `boolean` existe em Java e **não existe** em C (C "não tem tipos lógicos", segundo o slide). | V/F |
| 12 | Um arquivo `.java` pode ter **no máximo UMA classe pública**, com o mesmo nome do arquivo. | V/F |
| 13 | Tipos públicos de **`java.lang` são importados automaticamente** em todo programa Java. | V/F |
| 14 | `Object` é a superclasse de **todas** as classes; **arrays também herdam** os métodos de `Object`. | V/F |
| 15 | `String` é **imutável** e de valor constante; literais String são **referências** a instâncias de `String`. | V/F |
| 16 | Classe abstrata: **não pode ser instanciada**, pode ter métodos concretos. Interface: **só métodos abstratos e atributos constantes**, tudo **público**, serve para simular **herança múltipla**. | V/F garantido |
| 17 | `main` deve ser declarado **`public static void`** e recebe um **array de Strings**. | V/F |
| 18 | Ordem da iniciação da JVM: **Carga → Ligação (Verificação → Preparação → Resolução) → Iniciação**. | Ordenação |
| 19 | Superclasses são iniciadas **antes** da subclasse, recursivamente, começando por `Object`. | V/F |
| 20 | Saber **qual erro** é lançado em cada situação (tabela da seção 12): `ClassFormatError`, `NoClassDefFoundError`, `VerifyError`, `IllegalAccessError`, `InstantiationError`, etc. | Associação |
| 21 | **Resolução estática** (o mais cedo possível) **vs. resolução preguiçosa/lazy** (o mais tarde possível). | Conceitual |

---

## 2. Introdução: Java vs. C

O material abre comparando as duas linguagens. A sintaxe de Java é **similar à de C**, mas as
semelhanças param na gerência de memória.

| Aspecto | **Java** | **C** |
|---|---|---|
| Sintaxe | Similar à de C | — |
| Tipagem | "Fortemente tipada" | "Fortemente tipada" |
| Tipo lógico | Possui `boolean` | **Sem tipos lógicos** (usa `int`: 0 = falso, ≠0 = verdadeiro) |
| Gerência do heap | **Automática** — coletor de lixo (*garbage collector*) | **A cargo do programador** (`malloc`/`free`) |
| Consequência | Facilidade de uso | Maior **eficiência** |
| Referência pendente (*dangling*) | **Não permite** | **Permite** (usar ponteiro após `free`) |
| Acesso indireto à memória | **Referências tipadas** | **Ponteiros tipados** (aritmética de ponteiros) |
| Determinismo temporal | **Não determinístico** (o GC roda quando quer) | **Determinístico** |
| Tempo real | **Não indicado** para tempo real | **Indicado** para tempo real |

### Por que o GC torna o tempo "não determinístico"?

Em C, `free(p)` devolve a memória num tempo previsível. Em Java, você apenas "solta" a referência:

```java
// Java — gerência automática
Pessoa p = new Pessoa("Ana");  // aloca no heap
p = null;                      // perdi a ÚNICA referência ao objeto
// O objeto virou "lixo". Mas QUANDO ele será coletado?
// Resposta: não se sabe! O GC decide. Por isso: tempo NÃO determinístico.
// System.gc() é apenas uma SUGESTÃO à JVM, não uma ordem.
```

```c
/* C — gerência manual */
Pessoa *p = malloc(sizeof(Pessoa));
free(p);        /* liberação em tempo previsível => bom p/ tempo real */
printf("%d", p->idade);  /* REFERÊNCIA PENDENTE (dangling pointer)!
                            Compila, mas o comportamento é indefinido.
                            Em Java isso é impossível. */
```

> ⚠️ **Pegadinha de prova**
> - "Java é mais eficiente que C na gerência de heap" → **FALSO**. O slide atribui **maior eficiência** ao C, justamente por ser manual.
> - "Java possui ponteiros" → **FALSO** no vocabulário do material: Java usa **referências** (tipadas), não ponteiros. Não há aritmética de ponteiros.
> - "Java é indicada para sistemas de tempo real por ser portável" → **FALSO**. É **não indicada**, por causa do tempo não determinístico do coletor de lixo.
> - "C possui tipo booleano nativo" → **FALSO** segundo o slide ("sem tipos lógicos"). *(Obs.: o C99 introduziu `_Bool`/`<stdbool.h>`, mas para efeito desta prova vale o que o slide diz.)*
> - "Ambas são fortemente tipadas" → **VERDADEIRO** conforme o slide (note as aspas no material: é uma afirmação com ressalvas).

---

## 3. A Máquina Virtual Java (JVM)

### 3.1 O que a JVM provê

A JVM é a peça que dá a Java suas propriedades características. Ela é **responsável por prover**:

1. **Independência do hardware e do sistema operacional** — o famoso *write once, run anywhere*.
2. **Código compilado compacto** — o bytecode é muito menor que código nativo equivalente.
3. **Proteção ao cliente contra programas maliciosos** — o verificador de bytecode e o modelo de
   segurança impedem que um `.class` baixado faça coisas arbitrárias.

A JVM é uma **máquina abstrata** (uma especificação, não necessariamente um programa):

- **Entrada**: bytecode no formato **`.class`**.
- **Código de saída**: pode ser **interpretado** ou **compilado para código da máquina hospedeira**
  (JIT — *Just In Time*). Pode até ser implementada em **micro-código ou silício** (ou seja,
  em hardware — existiram processadores Java, como o picoJava).
- **Manipula várias áreas de memória em tempo de execução**.

```
   Fonte.java  --[ javac ]-->  Fonte.class  --[ JVM ]-->  execução
   (texto)                     (bytecode)                 interpretado OU
                                                          compilado (JIT) p/
                                                          código nativo
```

> ⚠️ **Pegadinha de prova**
> - "A JVM só interpreta bytecode" → **FALSO**. Ela pode interpretar **ou** compilar para o código da máquina hospedeira (JIT), e pode ainda ser implementada em micro-código/silício.
> - "A entrada da JVM é o arquivo `.java`" → **FALSO**. É o **`.class`** (bytecode). Quem lê `.java` é o compilador `javac`.

### 3.2 Máquina de pilha, não de registradores

Ponto mais importante da arquitetura:

> **A JVM não possui registradores. É uma máquina de pilha.**

Isso significa que as instruções de bytecode **não nomeiam registradores** como `add r1, r2, r3`.
Elas operam implicitamente sobre o **topo da pilha de operandos**.

```java
int c = a + b;   // código Java
```

Bytecode correspondente (método de instância, `a` no índice 1 e `b` no índice 2):

```
iload_1   ; empilha o valor da variável local 1 (a)  -> pilha: [a]
iload_2   ; empilha o valor da variável local 2 (b)  -> pilha: [a, b]
iadd      ; desempilha 2, soma, empilha resultado    -> pilha: [a+b]
istore_3  ; desempilha e guarda na variável local 3 (c) -> pilha: []
```

Compare com uma máquina de registradores (estilo MIPS/ARM):

```
add r3, r1, r2   ; operandos EXPLÍCITOS em registradores
```

**Vantagem da máquina de pilha**: instruções curtíssimas (muitas têm **1 byte só**, sem operandos),
o que gera **código compacto** e independente do número de registradores da máquina real.

> ⚠️ **Pegadinha de prova**
> - "A JVM possui um banco de registradores de propósito geral" → **FALSO**.
> - Cuidado: existe o **PC Register** (contador de programa), **um por thread**, que aponta a instrução corrente. Ele **não é** um registrador de propósito geral para operandos. A frase "a JVM não possui registradores" refere-se a registradores de dados/operandos.

### 3.3 Threads, pilha JVM e frames

> **Cada thread tem uma pilha JVM, que armazena frames.**

- Um **frame** é criado **quando um método é invocado** (e destruído quando o método retorna).
- Cada frame contém:
  1. Uma **pilha de operandos** de bytecodes;
  2. Um **vetor de variáveis locais** do método;
  3. Um **ponteiro (referência) para o pool de constantes em runtime** da classe do método corrente.

```
  Thread A                         Thread B
  ┌──────────────────┐             ┌──────────────────┐
  │ frame: calcula() │ <- topo     │ frame: run()     │ <- topo
  ├──────────────────┤             ├──────────────────┤
  │ frame: main()    │             │ ...              │
  └──────────────────┘             └──────────────────┘
      pilha JVM da A                   pilha JVM da B

  Cada frame:
  ┌───────────────────────────────────────────────────┐
  │ [0][1][2][3] ...   vetor de variáveis locais      │
  │ ▓▓▓▓            pilha de operandos (32 bits)      │
  │ ──► ref. ao Pool de Constantes em runtime         │
  └───────────────────────────────────────────────────┘
```

> ⚠️ **Pegadinha de prova**
> - "Todas as threads compartilham a mesma pilha JVM" → **FALSO**. Pilha e PC são **por thread**. O que é **compartilhado** entre threads é o **heap** e a **method area**.
> - "Um frame é criado quando a classe é carregada" → **FALSO**. É criado **quando um método é invocado**.
> - "Cada método tem um frame" → cuidado: cada **invocação** de método tem um frame. Recursão de 10 níveis = 10 frames do mesmo método.

### 3.4 Vetor (tabela) de variáveis locais

Contém os **parâmetros do método** e os **valores das variáveis locais**.

**Regra de ordenação (cai muito!):** os **parâmetros são armazenados primeiro, iniciando no índice 0**.

| Tipo de método | Índice 0 | Índices seguintes |
|---|---|---|
| **Método de instância** ou **construtor** | o **ponteiro `this`** (referência ao objeto) | 1º parâmetro formal, 2º, ... , depois as locais |
| **Método `static`** | o **1º parâmetro formal** | 2º parâmetro, 3º, ... , depois as locais |

**Tamanho**: determinado em **tempo de compilação**, em função do **número e tamanho** das variáveis
locais e dos parâmetros formais.

```java
public class Exemplo {

    // MÉTODO DE INSTÂNCIA
    public int soma(int a, int b) {
        int r = a + b;
        return r;
    }
    // Vetor de variáveis locais:
    //   [0] = this   (referência ao objeto — SEMPRE no índice 0 em método de instância)
    //   [1] = a
    //   [2] = b
    //   [3] = r
    //   => tamanho 4, calculado pelo compilador (javac), não em runtime

    // MÉTODO ESTÁTICO
    public static int somaS(int a, int b) {
        int r = a + b;
        return r;
    }
    // Vetor de variáveis locais:
    //   [0] = a      (NÃO existe "this" em método estático!)
    //   [1] = b
    //   [2] = r
    //   => tamanho 3

    // COM long (ocupa 2 slots de 32 bits)
    public static void comLong(long x, int y) { }
    // [0] e [1] = x  (long ocupa DOIS slots)
    // [2]       = y
}
```

> ⚠️ **Pegadinha de prova**
> - "Em um método estático, `this` fica no índice 0" → **FALSO**. Método estático **não tem** `this`; o índice 0 é o primeiro parâmetro formal.
> - "O tamanho do vetor de variáveis locais é decidido em tempo de execução" → **FALSO**. É em **tempo de compilação**.
> - "As variáveis locais vêm antes dos parâmetros no vetor" → **FALSO**. Os **parâmetros vêm primeiro**.
> - Um `long` ou `double` consome **dois** índices consecutivos do vetor (coerente com a largura de 32 bits dos slots).

### 3.5 Pilha de operandos (32 bits)

- Usada para **empilhar e desempilhar valores operandos de opcode**.
- **Tamanho determinado em tempo de compilação** (o `.class` guarda o `max_stack`).
- Funcionamento:
  - algumas instruções **empilham** valores na pilha;
  - outras **retiram** operandos da pilha, **manipulam-nos** e **empilham o resultado**;
  - **valores retornados pelos métodos são recebidos via pilha de operandos**.

```java
int x = mult(2, 3) + 1;
```

```
iconst_2     ; pilha: [2]
iconst_3     ; pilha: [2, 3]
invokestatic mult   ; desempilha 2 args, executa mult; o RETORNO volta na pilha -> [6]
iconst_1     ; pilha: [6, 1]
iadd         ; pilha: [7]
istore_1     ; x = 7 ; pilha: []
```

> **Definição que o slide destaca:** *"Um opcode é um byte com o código de 'máquina' de uma instrução
> Java no formato .class."* — ou seja, o opcode tem **exatamente 1 byte** (daí o limite de 256
> instruções possíveis). Os **operandos** vêm **depois** do opcode no fluxo de bytes.

> ⚠️ **Pegadinha de prova**
> - "A pilha de operandos é de 64 bits" → **FALSO**. É de **32 bits**; valores maiores (long/double) usam **dois** slots.
> - "O tamanho da pilha de operandos cresce dinamicamente conforme a necessidade" → **FALSO**. É fixado em **tempo de compilação**.
> - "O valor de retorno de um método é devolvido pelo vetor de variáveis locais" → **FALSO**. É devolvido pela **pilha de operandos**.
> - "Opcode tem 2 bytes" → **FALSO**. Opcode = **1 byte**. Quem pode ter 1 ou 2 bytes é o **índice do pool de constantes** (operando).

### 3.6 Pool de constantes (constant pool)

- **Armazena todas as constantes associadas com a classe**, incluindo os **valores das variáveis
  declaradas como `final`**.
- **Vantagem**: contribui para **tornar menores os requisitos de memória**, pois **evita a duplicação
  de constantes em cada instância (objeto)** de uma classe — a constante existe **uma vez por classe**,
  não uma vez por objeto.
- Os opcodes que empilham constantes a partir do pool usam um **"índice de pool de constante"**:
  - operando de **1 byte** → faixa **1 a 255**;
  - ou de **2 bytes** → faixa **1 a 65535**;
  - esse operando **segue o código de operação (opcode)** no fluxo de bytes.

```java
public class Circulo {
    static final double PI = 3.14159;   // vai para o POOL DE CONSTANTES da classe
    String nome = "circulo";            // o literal "circulo" também está no pool
    double raio;                        // variável de INSTÂNCIA: fica no objeto (heap)
}
// Se eu criar 1.000 objetos Circulo:
//   - PI e "circulo" existem UMA vez (no pool da classe)
//   - raio existe 1.000 vezes (um por objeto)
```

Bytecode típico (formato: `opcode` + `índice`):

```
ldc  #7        ; ldc  = opcode (1 byte), #7 = índice de 1 byte no pool  (1..255)
ldc_w #300     ; ldc_w usa índice de 2 bytes                            (1..65535)
```

> ⚠️ **Pegadinha de prova**
> - "O pool de constantes fica dentro de cada objeto" → **FALSO**. É **por classe**; é justamente isso que evita duplicação e economiza memória.
> - "O índice do pool de constantes começa em 0" → cuidado: as faixas citadas pelo slide são **1 a 255** e **1 a 65535** (o índice 0 é inválido/reservado no `.class`).
> - "Variáveis `final` não aparecem no pool" → **FALSO**: o slide diz explicitamente que os valores das variáveis `final` estão lá.

---

## 4. Tipos e Valores

### 4.1 Tipos primitivos

| Tipo | Definição (como o slide define) | Bits | Sinal | Slots na pilha (32 bits) |
|---|---|---|---|---|
| `byte` | 1 byte com sinal, **convertido em inteiro de 32 bits** | 8 | com sinal | 1 |
| `short` | 2 bytes com sinal, **convertidos em inteiro de 32 bits** | 16 | com sinal | 1 |
| `int` | 4 bytes com sinal (**inteiro de 32 bits**) | 32 | com sinal | 1 |
| `long` | 8 bytes com sinal, **convertido em 2 inteiros de 32 bits** | 64 | com sinal | **2** |
| `float` | 4 bytes **IEEE 754**, ponto flutuante de **precisão simples** | 32 | IEEE 754 | 1 |
| `double` | 8 bytes **IEEE 754**, ponto flutuante de **precisão dupla** | 64 | IEEE 754 | **2** |
| `char` | 2 bytes **sem sinal**, representando um caractere **Unicode** | 16 | **sem sinal** | 1 |

> **Nota do slide (em destaque):** *"Lembre-se que a pilha de operandos é de 32 bits! Os valores são
> compatíveis com a largura de bits original."* — é por isso que `byte`, `short` e `char` são
> promovidos a 32 bits na pilha, e `long`/`double` ocupam dois slots.

```java
byte  b = 100;       // na memória: 8 bits; na pilha de operandos: 32 bits
short s = 30000;     // 16 bits -> promovido a 32 na pilha
char  c = 'á';       // 16 bits SEM SINAL (Unicode): faixa 0 .. 65535
int   i = b + s;     // aritmética inteira em Java é feita em, no mínimo, 32 bits
long  l = 10L;       // ocupa 2 slots de 32 bits
float f = 1.5f;      // IEEE 754 simples
double d = 1.5;      // IEEE 754 dupla, 2 slots

// byte b2 = b + s;  // ERRO de compilação: o resultado de b+s é int (32 bits)
```

> ⚠️ **Pegadinha de prova**
> - "`char` em Java tem 1 byte" → **FALSO**. Tem **2 bytes**, sem sinal, Unicode.
> - "`char` tem sinal" → **FALSO**. É o **único tipo inteiro sem sinal** de Java.
> - "`long` ocupa um slot de 32 bits na pilha" → **FALSO**. Ocupa **dois**.
> - "Em Java os tamanhos dos tipos dependem da plataforma (como em C)" → **FALSO**. São **fixos pela especificação** — é parte da independência de plataforma.
> - `boolean` **não aparece** nesta tabela do slide (a JVM o representa internamente como inteiro), mas Java **tem** o tipo `boolean` na linguagem — foi o que a comparação com C afirmou.

### 4.2 Ponto flutuante e valores especiais

Os tipos de ponto flutuante seguem **IEEE 754** e possuem **valores especiais** definidos como
constantes nas classes *wrapper* `Float` e `Double`:

| Constante | Significado |
|---|---|
| `Float.NaN` / `Double.NaN` | *Not a Number* — resultado inválido (ex.: `0.0/0.0`) |
| `Float.NEGATIVE_INFINITY` / `Double.NEGATIVE_INFINITY` | −∞ (ex.: `-1.0/0.0`) |
| `Float.POSITIVE_INFINITY` / `Double.POSITIVE_INFINITY` | +∞ (ex.: `1.0/0.0`) |

```java
double a = 1.0 / 0.0;    // +Infinity  (NÃO lança exceção!)
double b = -1.0 / 0.0;   // -Infinity
double c = 0.0 / 0.0;    // NaN
int    d = 1 / 0;        // ArithmeticException: / by zero  (inteiro É diferente!)

System.out.println(c == c);            // false! NaN != NaN, por definição IEEE 754
System.out.println(Double.isNaN(c));   // true  <- forma CORRETA de testar NaN
```

> ⚠️ **Pegadinha de prova**
> - "Dividir por zero em Java sempre lança exceção" → **FALSO**. Em **ponto flutuante** produz `Infinity` ou `NaN`; só na **divisão inteira** lança `ArithmeticException`.
> - "`NaN == NaN` é verdadeiro" → **FALSO**. NaN não é igual a nada, nem a si mesmo. Use `isNaN()`.

---

## 5. Tipos de variáveis (as 7 categorias)

O material lista **sete** categorias de variáveis, cada uma com seu momento de **criação**,
**iniciação** e **destruição**. Esta é a seção mais "decoreba" do PDF.

| Categoria | O que é | Quando é criada | Valor inicial | Quando deixa de existir |
|---|---|---|---|---|
| **Variável de classe** (global às instâncias) | *field* declarado `static` em uma classe, ou com/sem `static` em uma **interface** | quando a **classe/interface é carregada** | **valores default** | quando a classe/interface é **removida** (descarregada) |
| **Variável de instância** (local à instância) | *field* declarado em uma classe **sem** `static` | quando um **objeto** (ou objeto de subclasse) é criado | **valores default** | quando **não existir mais referência** ao objeto que a contém |
| **Componentes de array** | variáveis **anônimas** dentro do array | quando um **novo objeto array** é criado | **valores default** | quando o array **não for mais referenciado** |
| **Parâmetros de métodos** (locais ao método) | nomes dos valores dos argumentos passados a um método | na invocação do método | valor do argumento | ao fim do método |
| **Parâmetros de construtores** (locais ao construtor) | nomes dos valores dos argumentos passados ao construtor | na invocação do construtor | valor do argumento | ao fim do construtor |
| **Parâmetro de manipulador de exceção** (local ao *handler*) | a variável do `catch (Tipo e)` | **cada vez que uma exceção é capturada** por um `catch` de um `try` | o **objeto atual associado à exceção** | quando o **bloco do `catch` termina** |
| **Variáveis locais** (locais a blocos ou ao `for`) | declaradas por comandos de declaração em blocos ou no `for` | uma nova variável **para cada variável local declarada** | **NÃO é iniciada** até que o comando de declaração seja executado | quando a execução do **bloco ou do `for`** termina |

> **Nota em destaque do slide:** *"Todos possuem alocação dinâmica baseada em registro de ativação."*

```java
public class Demo {

    static int contador;          // (1) VARIÁVEL DE CLASSE: criada ao carregar a classe,
                                  //     default = 0. Uma só, compartilhada por todos os objetos.

    int id;                       // (2) VARIÁVEL DE INSTÂNCIA: criada com "new Demo()",
                                  //     default = 0. Uma por objeto.

    int[] v = new int[3];         // (3) COMPONENTES DE ARRAY: v[0], v[1], v[2] são variáveis
                                  //     ANÔNIMAS, criadas com default 0 na criação do array.

    Demo(int id) {                // (5) PARÂMETRO DE CONSTRUTOR: "id" é local ao construtor
        this.id = id;
    }

    void processa(String nome) {  // (4) PARÂMETRO DE MÉTODO: "nome" é local ao método
        int total;                // (7) VARIÁVEL LOCAL: existe, mas NÃO está iniciada ainda!
        // System.out.println(total); // ERRO: variable total might not have been initialized
        total = 0;                //     só agora ela passa a ter valor

        for (int i = 0; i < 3; i++) {   // (7) "i" é local ao comando for;
            total += v[i];              //     deixa de existir ao fim do for
        }
        // System.out.println(i);  // ERRO: "i" não existe mais fora do for

        try {
            Object o = null;
            o.toString();
        } catch (NullPointerException e) {  // (6) PARÂMETRO DE MANIPULADOR DE EXCEÇÃO:
            System.out.println(e);          //     "e" é criada ao capturar e iniciada com
        }                                   //     o objeto da exceção; morre ao fim do catch.
    }
}
```

**Valores default** (aplicam-se a variáveis de classe, de instância e a componentes de array —
**nunca** a variáveis locais):

| Tipo | Default |
|---|---|
| `byte`, `short`, `int`, `long` | `0` |
| `float`, `double` | `0.0` |
| `char` | `'\u0000'` |
| `boolean` | `false` |
| referência (qualquer objeto/array) | `null` |

> ⚠️ **Pegadinha de prova**
> - "Toda variável em Java é iniciada automaticamente com valor default" → **FALSO**. **Variáveis locais NÃO são iniciadas automaticamente** — o compilador exige atribuição antes do uso. Fields, componentes de array e variáveis de classe **são**.
> - "Em uma interface, um *field* só é variável de classe se for declarado `static`" → **FALSO**. Em **interface**, o *field* é variável de classe **com ou sem** `static` (é implicitamente `public static final`).
> - "A variável de instância é desalocada quando o método termina" → **FALSO**. Ela morre quando **não há mais referência ao objeto** (e o GC recolhe).
> - "A variável do `catch` continua acessível depois do bloco" → **FALSO**. Deixa de existir ao fim do bloco `catch`.
> - "A variável do `for` sobrevive após o laço" → **FALSO** (quando declarada no próprio `for`).

---

## 6. Nomes e Pacotes

### Nomes

- **Nomes** são usados para **referir as entidades declaradas no programa**: pacote, tipo,
  **membros** (atributos ou métodos) de um tipo, parâmetros ou variáveis locais.
- **Programas são conjuntos de pacotes organizados.**
- Dois tipos de nome:

| Tipo | Definição | Exemplo |
|---|---|---|
| **Nome simples** | é **um identificador** (um único nome) | `String`, `x`, `calcula` |
| **Nome qualificado** | permite **acesso aos membros de pacotes** e aos **membros de tipos de referência** (usa pontos) | `java.util.ArrayList`, `obj.campo`, `System.out.println` |

### Pacotes

- Um **pacote** consiste de um número de **unidades de compilação** e tem um **nome hierárquico**
  (`br.unb.cic.sb`).
- **O escopo dos nomes definidos no pacote é o próprio pacote.**
- **Unidade de compilação** = um **código fonte em Java**:
  - o arquivo deve ter extensão **`.java`**;
  - deve conter **no máximo UMA classe pública**, cujo **nome é o mesmo do arquivo sem a extensão**.
- No **topo do arquivo fonte** podem aparecer, nesta ordem:
  1. declaração de pacote — palavra reservada **`package`**;
  2. declaração de importação — palavra reservada **`import`**;
  3. definição de classe — palavra reservada **`class`**.
- **`import` permite que os tipos declarados em um pacote sejam conhecidos em outro pelo nome
  SIMPLES e não pelo qualificado.**

> **Nota em destaque do slide:** *"Os nomes de tipos declarados públicos no pacote `java.lang` são
> importados automaticamente em todo programa Java."*

```java
package br.unb.cic.sb;        // 1) declaração de pacote — no máximo UMA, e vem primeiro

import java.util.ArrayList;   // 2) importações
import java.util.List;

public class Agenda {         // 3) definição de classe
                              //    ARQUIVO obrigatoriamente chamado Agenda.java

    // Graças ao import, uso o NOME SIMPLES:
    List<String> nomes = new ArrayList<>();

    // Sem o import, teria que usar o NOME QUALIFICADO:
    java.util.HashMap<String,Integer> mapa = new java.util.HashMap<>();

    // String e System vêm de java.lang => importados AUTOMATICAMENTE, sem escrever import
    String s = "ok";
}

class Auxiliar { }   // OK: classe NÃO pública pode conviver no mesmo arquivo

// public class Outra { }  // ERRO: já existe uma classe pública neste arquivo
```

> ⚠️ **Pegadinha de prova**
> - "Um arquivo `.java` pode ter várias classes públicas" → **FALSO**. **No máximo uma**, e com o nome do arquivo.
> - "Um arquivo `.java` só pode ter uma classe" → **FALSO**. Pode ter várias classes; só **uma pública**.
> - "É preciso escrever `import java.lang.String;`" → **FALSO**. `java.lang` é importado **automaticamente**.
> - "`import` copia o código do outro pacote para o arquivo" → **FALSO**. `import` apenas permite usar o **nome simples** em vez do **qualificado**; nada é copiado.
> - "O escopo dos nomes de um pacote é global ao programa" → **FALSO**. O escopo é **o próprio pacote**.

---

## 7. Classes fundamentais: Object e String

### Classe `Object`

- É a **superclasse de todas as outras classes**.
- Uma variável do tipo `Object` **pode manipular uma referência para qualquer objeto** —
  seja de uma **classe** ou de um **array**.
- **Os tipos classe E os tipos array herdam os métodos de `Object`.**

```java
Object o;
o = new String("oi");      // OK: classe
o = new int[10];           // OK: ARRAY também é objeto e herda de Object!
o = new Object();          // OK
// o = 5;                  // em Java antigo seria erro; hoje há autoboxing (vira Integer)

int[] v = new int[3];
System.out.println(v.getClass());  // método herdado de Object => [I
System.out.println(v.hashCode());  // método herdado de Object
```

Métodos herdados de `Object` (os mais cobrados): `equals()`, `hashCode()`, `toString()`,
`getClass()`, `clone()`, `finalize()`, `notify()`, `notifyAll()`, `wait()`.

### Classe `String`

- Instâncias dessa classe representam **sequências de caracteres Unicode**.
- Um objeto `String` tem um **valor constante e imutável** (*immutable*).
- **Literais String são referências a instâncias dessa classe.**

```java
String a = "SB";          // literal: é uma REFERÊNCIA a uma instância de String
String b = a.concat("!"); // NÃO altera "a"! Cria um NOVO objeto String.
System.out.println(a);    // SB     <- prova da imutabilidade
System.out.println(b);    // SB!

a = a + "!";              // isto NÃO mudou o objeto; fez "a" apontar para OUTRO objeto
System.out.println(a);    // SB!

a.toUpperCase();          // valor descartado: o retorno é um novo objeto
System.out.println(a);    // SB!   (continua igual — erro clássico de iniciante)
```

> ⚠️ **Pegadinha de prova**
> - "Arrays não herdam de `Object`" → **FALSO**. Arrays **são** objetos e herdam os métodos de `Object`.
> - "Métodos de `String` como `toUpperCase()` modificam a string original" → **FALSO**. `String` é **imutável**; esses métodos retornam **novos** objetos.
> - "`Object` é uma interface" → **FALSO**. É uma **classe** (concreta), a raiz da hierarquia.
> - "Tipos primitivos herdam de `Object`" → **FALSO**. Primitivos **não** são objetos; só classes e arrays.

---

## 8. Classes abstratas

- Uma classe **deve ser declarada abstrata se ela não está completamente implementada**, isto é,
  **se contém métodos abstratos**.
- Uma **classe abstrata NÃO pode ser instanciada**.
- Ela **pode ser estendida por uma subclasse**, que **deve implementar todos os seus métodos
  abstratos** — **ou se tornar abstrata também**.
- **Para que servem**: para **reunir classes em torno de métodos comuns** — por exemplo, métodos
  matemáticos.

> **Definição em destaque:** *"Método abstrato é um método que tem a **assinatura declarada** mas
> **não tem implementação**."*

```java
// Classe abstrata: reúne subclasses em torno de métodos comuns
public abstract class Figura {

    protected String nome;                 // classe abstrata PODE ter atributos normais

    public Figura(String nome) {           // PODE ter construtor (usado pelas subclasses)
        this.nome = nome;
    }

    // MÉTODO ABSTRATO: assinatura declarada, SEM implementação (termina em ';')
    public abstract double area();

    // MÉTODO CONCRETO: classe abstrata PODE ter implementação
    public void imprime() {
        System.out.println(nome + " tem area " + area());
    }
}

public class Quadrado extends Figura {
    private double lado;

    public Quadrado(double lado) {
        super("Quadrado");
        this.lado = lado;
    }

    @Override
    public double area() {            // OBRIGATÓRIO implementar o método abstrato
        return lado * lado;
    }
}

// Uso:
// Figura f = new Figura("x");     // ERRO DE COMPILAÇÃO: Figura is abstract; cannot be instantiated
Figura f = new Quadrado(2.0);       // OK: referência do tipo abstrato, objeto da subclasse
f.imprime();                        // Quadrado tem area 4.0  (polimorfismo)
```

Se a subclasse **não** implementar tudo, ela também precisa ser abstrata:

```java
public abstract class FiguraParcial extends Figura {   // OK porque é abstract
    public FiguraParcial() { super("parcial"); }
    // não implementa area() -> por isso PRECISA ser abstract
}
```

> ⚠️ **Pegadinha de prova**
> - "Classe abstrata não pode ter métodos concretos" → **FALSO**. Pode ter métodos implementados, atributos e construtores. (Quem **não pode** ter métodos concretos é a **interface**, segundo o slide.)
> - "Toda classe com um método abstrato deve ser abstrata" → **VERDADEIRO**.
> - "Toda classe abstrata tem pelo menos um método abstrato" → **FALSO** em Java na prática (pode-se marcar `abstract` uma classe totalmente implementada, só para impedir instanciação). O slide diz que ela **deve** ser abstrata **se** contiver métodos abstratos — a implicação é nessa direção.
> - "Classe abstrata não pode ter construtor" → **FALSO**. Pode, e ele é chamado via `super(...)` pela subclasse.
> - "Método abstrato tem corpo vazio `{ }`" → **FALSO**. Corpo vazio é **implementação vazia**; método abstrato **não tem corpo**, termina em `;`.

---

## 9. Interfaces

> 🟦 **Divergência Java 8** — a regra "interface não pode ter métodos concretos" é da 2ª edição da
> JVMS (Java 2). **No Java 8** a interface pode ter métodos **`default`** e **`static`**, ambos com
> corpo. Mantém-se, porém, o que a prova de fato cobra: **só atributos constantes**
> (`public static final`), **sem estado de instância** e **sem construtor**.
> Ver [DIVERGENCIAS-JAVA8.md §2.1](DIVERGENCIAS-JAVA8.md#21--interface-só-tem-métodos-abstratos).

- **Conceituação semelhante à da classe abstrata**, mas:
  - a interface **não pode ter métodos concretos**;
  - **só pode ter atributos constantes**;
  - **pode ser usada para simular herança múltipla**.
- **Representam ideias**:
  - **não é considerada uma classe**;
  - as classes que **implementam** uma interface **dão suporte a essa ideia**.
- Os **métodos abstratos** de uma interface **podem ser utilizados se são definidos em uma classe que
  implementa a interface**.
- **Todos os seus métodos e atributos são considerados públicos.**

### Classe abstrata × Interface

| Critério | **Classe abstrata** | **Interface** |
|---|---|---|
| É uma classe? | **Sim** | **Não** ("não é considerada uma classe") |
| Métodos concretos (com implementação) | **Pode** ter | **Não pode** ter (conforme o slide) |
| Métodos abstratos | Pode ter | **Só** tem métodos abstratos |
| Atributos | Pode ter atributos de instância comuns | **Só atributos constantes** (`public static final`) |
| Visibilidade dos membros | `public`, `protected`, `private`, default | **Todos públicos**, implicitamente |
| Construtor | **Pode** ter | **Não** tem |
| Instanciação direta | **Não** pode | **Não** pode |
| Herança múltipla | Java **não permite** estender 2 classes | **Permite** implementar **várias** interfaces → **simula herança múltipla** |
| Palavra-chave de uso | `extends` | `implements` |

```java
// Interfaces representam IDEIAS / capacidades
public interface Desenhavel {
    int MAX = 100;                    // implicitamente public static final (CONSTANTE)
    void desenha();                   // implicitamente public abstract (sem corpo)
}

public interface Serializavel {
    String paraTexto();               // público e abstrato, implicitamente
}

// SIMULAÇÃO DE HERANÇA MÚLTIPLA: uma classe pode implementar VÁRIAS interfaces,
// mas só pode estender UMA classe.
public class Ponto extends Figura implements Desenhavel, Serializavel {
    private int x, y;

    public Ponto(int x, int y) { super("Ponto"); this.x = x; this.y = y; }

    @Override public double area()      { return 0; }            // da classe abstrata
    @Override public void   desenha()   { System.out.println("."); }  // de Desenhavel
    @Override public String paraTexto() { return x + "," + y; }       // de Serializavel
    // Os métodos implementados TÊM que ser públicos: a interface os declara públicos,
    // e não se pode reduzir a visibilidade ao sobrescrever.
}

// Polimorfismo por interface: a referência representa a IDEIA
Desenhavel d = new Ponto(1, 2);
d.desenha();
// d.area();  // ERRO: o tipo Desenhavel não conhece area()
```

> ⚠️ **Pegadinha de prova**
> - "Interface é um tipo especial de classe" → **FALSO** segundo o slide: *"não é considerada uma classe"*.
> - "Uma interface pode ter atributos de instância" → **FALSO**. **Só atributos constantes**.
> - "Métodos de interface podem ser `private` ou `protected`" → **FALSO** neste material: **todos são públicos**.
> - "Java permite herança múltipla de classes" → **FALSO**. Permite **implementar várias interfaces**, o que **simula** herança múltipla.
> - "Uma classe pode implementar apenas uma interface" → **FALSO**. Pode implementar quantas quiser.
> - 🟦 **Divergência Java 8:** "todos os métodos são públicos" e "não há métodos concretos" valem
>   até o Java 7. **No Java 8** existem métodos **`default`** e **`static`** com corpo (ainda
>   obrigatoriamente `public`); métodos **`private`** em interface só no **Java 9** (🟪 fora desta prova).
>   **Para esta prova, vale a regra do slide** — mas escreva a ressalva do Java 8 na justificativa.
> - 🟥 "Uma interface pode ter atributos de instância" → **FALSO em qualquer versão**, inclusive no
>   Java 8. Essa é a parte da regra que **nunca** mudou, e é exatamente o que caiu na Q17 da prova.

---

## 10. Arquitetura de uma JVM (o diagrama)

O slide 16 traz o diagrama clássico da arquitetura da JVM, com uma legenda indicando as partes que
**"não implemente"** (ou seja, partes fora do escopo do trabalho prático de implementação de JVM da
disciplina) e a observação **"apenas uma thread"**.

```
                 .class
                    │
                    ▼
 ┌──────────────────────────────────────────────────────────────┐
 │                  CLASS LOADER SUBSYSTEM                      │
 │  Loading              Linking              Initialization    │
 │  ┌────────────────┐   ┌──────────┐        ┌───────────────┐  │
 │  │ Bootstrap CL   │   │ Verify   │        │ Initialization│  │
 │  │ Extension CL * │ → │ Prepare  │   →    │               │  │
 │  │ Application CL │   │ Resolve  │        │               │  │
 │  └────────────────┘   └──────────┘        └───────────────┘  │
 └──────────────────────────────┬───────────────────────────────┘
                                ▲ ▼
 ┌──────────────────────────────────────────────────────────────┐
 │                      RUNTIME DATA AREA                       │
 │ ┌───────────┐ ┌────────┐ ┌─────────┐ ┌────────────┐ ┌──────┐ │
 │ │  Method   │ │ Heap * │ │  Stack  │ │ PC Register│ │Native│ │
 │ │   Area    │ │        │ │ Thread1 │ │ Thread1 PC │ │Method│ │
 │ │           │ │        │ │ Thread2 │ │ Thread2 PC │ │Stack*│ │
 │ │           │ │        │ │ Thread n│ │ Thread n PC│ │      │ │
 │ └───────────┘ └────────┘ └─────────┘ └────────────┘ └──────┘ │
 │                        ("apenas uma thread" no trabalho)     │
 └──────────────────────────────┬───────────────────────────────┘
                                ▲ ▼
 ┌────────────────────────────────┐   ┌─────────────┐   ┌──────────────┐
 │       EXECUTION ENGINE         │ ↔ │ Native      │ ↔ │ Native       │
 │ ┌──────────┐┌─────┐┌─────────┐ │   │ Method      │   │ Method       │
 │ │Interpreter││JIT *││  GC *  │ │   │ Interface * │   │ Library *    │
 │ └──────────┘└─────┘└─────────┘ │   │ (JNI)       │   │              │
 └────────────────────────────────┘   └─────────────┘   └──────────────┘

 (*) marcado com "não implemente" na legenda do slide
```

### As três grandes partes

| Bloco | Subcomponentes | Função |
|---|---|---|
| **Class Loader Subsystem** | **Loading** (Bootstrap, Extension*, Application Class Loader), **Linking** (Verify → Prepare → Resolve), **Initialization** | Carrega o `.class`, liga e inicia a classe |
| **Runtime Data Area** | **Method Area**, **Heap***, **Stack** (uma por thread), **PC Register** (um por thread), **Native Method Stack*** | Todas as áreas de memória em tempo de execução |
| **Execution Engine** | **Interpreter**, **JIT Compiler***, **Garbage Collector*** | Executa o bytecode; interage com a **JNI** e a **Native Method Library*** |

#### Os três class loaders (ordem de delegação)

| Class Loader | Carrega |
|---|---|
| **Bootstrap Class Loader** | classes fundamentais da plataforma (`java.lang.*`, `rt.jar`) |
| **Extension Class Loader** | classes de extensão (`jre/lib/ext`) |
| **Application Class Loader** | classes da aplicação (o **classpath** do usuário) |

#### Áreas de memória: compartilhadas × por thread

| Área | Escopo | Conteúdo |
|---|---|---|
| **Method Area** | **compartilhada** entre todas as threads | estrutura da classe, pool de constantes em runtime, código dos métodos, variáveis de classe |
| **Heap** | **compartilhado** | todos os **objetos** e **arrays**; é a área que o **GC** gerencia |
| **Stack (pilha JVM)** | **uma por thread** | os **frames** (locais + pilha de operandos + ref. ao pool) |
| **PC Register** | **um por thread** | endereço da instrução corrente da thread |
| **Native Method Stack** | **uma por thread** | pilha para métodos nativos (via JNI) |

> **Nota do slide 17 (em destaque):** *"O leitor exibidor faz o papel de ClassLoader"* — referência ao
> programa do trabalho prático da disciplina, que lê e exibe o `.class` e, portanto, desempenha o
> papel do carregador de classes.

> ⚠️ **Pegadinha de prova**
> - "O heap é privativo de cada thread" → **FALSO**. **Heap e Method Area são compartilhados**; **Stack, PC Register e Native Method Stack são por thread**.
> - "O Garbage Collector faz parte do Class Loader Subsystem" → **FALSO**. Faz parte do **Execution Engine**.
> - "O JIT substitui o Interpreter" → parcialmente falso: ambos convivem no Execution Engine; o JIT compila trechos "quentes" para código nativo.
> - "A JNI serve para carregar classes" → **FALSO**. A JNI (*Native Method Interface*) é a ponte para a **Native Method Library** (código nativo, tipicamente C/C++).

---

## 11. Execução de um `.class`: iniciação da JVM

> Cenário do slide: executar `java.exe` (o comando `java`).

A **iniciação da máquina virtual** começa com a **chamada do método `main` de uma classe**, passando
um **array de Strings** (os parâmetros da linha de comandos).

- **`main` deve ser declarado `public static void`.**

```java
public class Terminator {
    // Assinatura EXIGIDA pela JVM:
    //   public  -> a JVM (fora da classe) precisa chamá-lo
    //   static  -> não existe objeto ainda; não se pode instanciar para chamar
    //   void    -> não devolve valor à JVM
    //   String[] args -> parâmetros da linha de comandos
    public static void main(String[] args) {
        for (String s : args) System.out.println(s);
    }
}
```

Exemplo do slide:

```
java Terminator Hasta la vista Baby!
```

- Isso passa `args = {"Hasta", "la", "vista", "Baby!"}` (`args.length == 4`).
- **A execução de `main` pela JVM falha**, porque a classe `Terminator` **não está carregada na
  memória**.
- Então o **ClassLoader é executado para carregar a classe `Terminator`**. Ela **é carregada se não
  houver erro**.

Depois da carga, a classe precisa ser **ligada** e **iniciada**:

### 11.1 Carga (Loading)

Leitura do arquivo `.class` (código binário) e criação da representação interna da classe.
Erros possíveis aqui: `ClassFormatError`, `UnsupportedClassVersionError`, `ClassCircularityError`,
`NoClassDefFoundError` (ver seção 12).

### 11.2 Ligação (Linking)

> "Terminator deve ser **ligada**". A ligação tem **três etapas**, nesta ordem:

**1) Verificação (Verify)**
- **Verifica se o código é bem formado**, **possui tabela de símbolos** e **segue os requisitos
  semânticos da JVM**.
- **Pode lançar um erro** (`VerifyError`).

**2) Preparação (Prepare)**
- **O código estático da classe** e **as estruturas de dados internas da JVM**, tais como as
  **tabelas de métodos**, **são alocadas**.

**3) Resolução (Resolve)**
- **A resolução de referências simbólicas** é o processo de **resolver as referências de `Terminator`
  para as outras classes e interfaces**.
- **As outras classes e interfaces mencionadas são carregadas e as referências são checadas.**
- Há **duas estratégias**:

| Estratégia | Quando resolve | Característica |
|---|---|---|
| **Resolução estática** | **o mais cedo possível** | Essa verificação é "estática"; detecta erros antecipadamente, mas carrega tudo de uma vez (mais lento no início, mais memória) |
| **Resolução preguiçosa** (*lazy*) | **o mais tarde possível**, **somente quando as referências externas forem resolvidas** | Inicia mais rápido, mas erros só aparecem em tempo de execução |

> **Nota em destaque do slide:** *"Resolução estática versus resolução preguiçosa."*

### 11.3 Iniciação (Initialization)

> "Terminator deve ser **iniciado**".

- Consiste na **execução dos procedimentos para iniciar as variáveis de classe e as iniciações
  estáticas** da classe, **na ordem em que aparecem** no código.
- **Todas as superclasses devem ser iniciadas ANTES, começando pelas diretas, recursivamente.**
- No **caso mais simples**, a única superclasse direta é **`Object`**, que **deve ser iniciada antes**
  da classe `Terminator`.
- **Esse processo recursivo envolve carga, verificação e resolução de todas as superclasses na
  hierarquia.**
- **Erros podem ser lançados durante esse processo.**
- **Só então o método `main` de `Terminator` pode ser executado.**

```java
class Base {
    static int a = f("Base: variavel de classe");
    static { f("Base: bloco estatico"); }              // iniciação estática
    static int f(String s) { System.out.println(s); return 1; }
}

public class Terminator extends Base {
    static int b = Base.f("Terminator: variavel de classe");
    static { Base.f("Terminator: bloco estatico"); }

    public static void main(String[] args) {
        Base.f("main executando");
    }
}
```

Saída — repare que a **superclasse é totalmente iniciada primeiro**, e dentro de cada classe a ordem
é a **ordem de aparecimento no código**:

```
Base: variavel de classe
Base: bloco estatico
Terminator: variavel de classe
Terminator: bloco estatico
main executando
```

### Fluxo completo em uma figura

```
 java Terminator Hasta la vista Baby!
        │
        ▼
 JVM tenta executar main  →  FALHA: classe não está na memória
        │
        ▼
 ┌─ CARGA (ClassLoader) ─────────────────────────────────────┐
 │  lê o .class      ClassFormatError / UnsupportedClass-    │
 │                   VersionError / ClassCircularityError /  │
 │                   NoClassDefFoundError                    │
 └───────────────────────────────────────────────────────────┘
        ▼
 ┌─ LIGAÇÃO ─────────────────────────────────────────────────┐
 │  1. VERIFICAÇÃO  -> bem formado? tabela de símbolos?      │
 │                     semântica da JVM?     [VerifyError]   │
 │  2. PREPARAÇÃO   -> aloca código estático e estruturas    │
 │                     internas (tabelas de métodos)         │
 │  3. RESOLUÇÃO    -> resolve referências simbólicas        │
 │                     (estática OU preguiçosa)              │
 │                     [IllegalAccessError, InstantiationError,│
 │                      NoSuchFieldError, NoSuchMethodError] │
 └───────────────────────────────────────────────────────────┘
        ▼
 ┌─ INICIAÇÃO ───────────────────────────────────────────────┐
 │  superclasses primeiro (recursivo, até Object)            │
 │  variáveis de classe + blocos estáticos, na ordem do código│
 └───────────────────────────────────────────────────────────┘
        ▼
   main() executa
```

> ⚠️ **Pegadinha de prova**
> - "A ordem é Verificação → Resolução → Preparação" → **FALSO**. É **Verificação → Preparação → Resolução**.
> - "A classe é carregada antes de a JVM tentar executar `main`" → segundo o slide, a JVM **tenta** executar `main`, **falha** porque a classe não está carregada, e **aí** aciona o ClassLoader.
> - "`main` pode ser declarado `private static void`" → **FALSO**. Deve ser **`public static void`**.
> - "`main` recebe os argumentos já convertidos em tipos" → **FALSO**. Recebe sempre um **array de Strings**.
> - "A subclasse é iniciada antes da superclasse" → **FALSO**. **Superclasses primeiro**, recursivamente, até `Object`.
> - "A resolução preguiçosa é feita o mais cedo possível" → **FALSO**. Preguiçosa = **o mais tarde possível**; quem é "o mais cedo possível" é a **estática**.
> - "Na preparação é que as referências a outras classes são checadas" → **FALSO**. Isso é a **resolução**. Na **preparação** alocam-se o código estático e as estruturas internas (tabelas de métodos).

---

## 12. Possíveis erros na inicialização

O PDF separa os erros em **dois grupos**: os lançados pelo **ClassLoader** (durante a **carga**) e os
lançados durante a **ligação** (verificação e resolução). **Saber associar cada erro à sua causa é
questão quase certa.**

### 12.1 Exceções que podem ser lançadas pelo ClassLoader (carga)

| Erro | Causa exata (texto do slide) |
|---|---|
| **`ClassFormatError`** | **Código binário** da classe ou interface **compilada é malformado**. |
| **`UnsupportedClassVersionError`** | O formato do código binário **não pode ser carregado porque usa uma versão antiga do formato `.class`**. |
| **`ClassCircularityError`** | A classe ou interface **não pode ser carregada porque é uma das suas próprias superclasses ou superinterfaces** (ciclo na hierarquia). |
| **`NoClassDefFoundError`** | **Não foi encontrada definição** para uma classe ou interface requerida. |

> **Nota em destaque do slide:** *"Consistências a serem testadas pela JVM do grupo"* — ou seja, no
> trabalho prático, a JVM implementada pelo grupo deve detectar essas situações.

```java
// ClassCircularityError — conceitualmente:
class A extends B { }
class B extends A { }   // A é superclasse de B e B é superclasse de A => CICLO

// NoClassDefFoundError — situação típica:
//   compilei Main.java junto com Util.java, mas na hora de rodar
//   apaguei/movi Util.class  =>  a definição não é encontrada em runtime.

// UnsupportedClassVersionError — situação típica:
//   compilei com uma versão do javac e rodo com uma JVM incompatível
//   (major version do .class fora do suportado).
//   ATENÇÃO (ver nota abaixo): é lançado quando o .class é MAIS NOVO que a JVM,
//   nunca quando é mais antigo — a JVM 8 roda .class de major 45 a 52.
```

> 🟥 **Divergência com a especificação** — alguns slides descrevem o
> `UnsupportedClassVersionError` como "versão **antiga** do formato `.class`". É o contrário: ele é
> lançado quando o `major_version` é **maior** do que a JVM suporta. Uma JVM do **Java 8** aceita
> `major_version` de **45 a 52** e rejeita 53+ (Java 9 em diante). Compatibilidade para trás é total;
> para frente, nenhuma.

### 12.2 Exceções que podem ser lançadas na ligação da classe

**Na Verificação:**

| Erro | Causa |
|---|---|
| **`VerifyError`** | **Código binário apresenta erro**: *opcode inválido*, *desvio para o meio de uma instrução*, *método com assinatura incorreta*, ... |

**Na Resolução:**

| Erro | Causa exata (texto do slide) |
|---|---|
| **`IllegalAccessError`** | Referência a um símbolo **não pode ser resolvida** porque o **atributo ou método foi declarado `private`, `protected` ou com acesso default (não público)**, **ou a classe não é pública**. |
| **`InstantiationError`** | Uma referência a uma **classe ou interface ABSTRATA** foi encontrada em uma **expressão de criação de instância de classe** (`new`). |
| **`NoSuchFieldError`** | Uma referência a um **atributo inexistente** de uma classe ou interface foi encontrada. |
| **`NoSuchMethodError`** | Uma referência a um **método inexistente** de uma classe ou interface foi encontrada. |

```java
// InstantiationError — conceitualmente:
abstract class Figura { }
// new Figura();     // o compilador normalmente barra; se o bytecode for gerado
                     // à mão ou a classe virar abstrata DEPOIS da compilação,
                     // a JVM lança InstantiationError na RESOLUÇÃO.

// NoSuchMethodError / NoSuchFieldError — situação típica:
//   compilei Main contra a versão 1 de Lib (que tinha metodo()),
//   e rodo contra a versão 2 de Lib (onde metodo() foi removido).
//   Compila, mas a RESOLUÇÃO falha em runtime.

// IllegalAccessError — situação típica:
//   Lib.campo era public quando compilei; depois virou private e Lib foi recompilada.
```

### Tabela-resumo: qual erro em qual fase

| Fase | Erros |
|---|---|
| **Carga** | `ClassFormatError`, `UnsupportedClassVersionError`, `ClassCircularityError`, `NoClassDefFoundError` |
| **Ligação → Verificação** | `VerifyError` |
| **Ligação → Preparação** | *(o slide não lista erros específicos)* |
| **Ligação → Resolução** | `IllegalAccessError`, `InstantiationError`, `NoSuchFieldError`, `NoSuchMethodError` |
| **Iniciação** | "Erros podem ser lançados durante esse processo" (ex.: `ExceptionInInitializerError`) |

> ⚠️ **Pegadinha de prova**
> - "`ClassNotFoundException` e `NoClassDefFoundError` são a mesma coisa" → **FALSO**. O slide lista **`NoClassDefFoundError`** (um **Error**, lançado quando a **definição** não é encontrada em runtime); `ClassNotFoundException` é uma **exceção verificada**, de busca explícita (`Class.forName`).
> - "Todos esses são `Exception`" → **FALSO**. Todos terminam em **`Error`** — são erros graves da JVM, **não devem ser tratados** pelo programa.
> - "`NoSuchMethodError` acontece em tempo de compilação" → **FALSO**. Em compilação o erro seria "cannot find symbol". O `NoSuchMethodError` é de **runtime**, na **resolução**.
> - "`InstantiationError` é lançado ao chamar `new` em qualquer classe" → **FALSO**. Só quando a referência é a uma **classe ou interface abstrata**.
> - "`UnsupportedClassVersionError` ocorre quando o `.class` é novo demais para a JVM" → cuidado com a redação: **o slide diz "versão antiga do formato `.class`"**. Na prática moderna, o caso mais comum é o contrário (classe compilada por um javac mais novo que a JVM). **Na prova, responda conforme o slide.**
> - "`VerifyError` é lançado na resolução" → **FALSO**. É na **verificação**.

---

## 13. Resumo em 10 pontos

1. **Java × C**: mesma sintaxe de base, mas Java tem `boolean`, **referências tipadas** e **coletor de
   lixo** (fácil, seguro, **não determinístico**, **ruim para tempo real**); C tem **heap manual**
   (**mais eficiente**, **determinístico**, **permite referência pendente**) e **ponteiros tipados**.

2. **A JVM provê** independência de hardware/SO, **código compacto** e **proteção contra programas
   maliciosos**. É uma **máquina abstrata** que recebe **`.class`** e **interpreta ou compila (JIT)**
   para a máquina hospedeira — podendo até ser implementada em **micro-código/silício**.

3. **A JVM não tem registradores: é máquina de pilha.** Cada **thread** tem sua **pilha JVM**; cada
   **invocação de método** cria um **frame** com (i) **pilha de operandos**, (ii) **vetor de variáveis
   locais** e (iii) **referência ao pool de constantes em runtime**.

4. **Vetor de variáveis locais**: **parâmetros primeiro**, a partir do índice 0. Em **método de
   instância/construtor**, o **índice 0 é o `this`**; em **método estático**, é o **1º parâmetro
   formal**. **Tamanho definido em tempo de compilação** — assim como o da **pilha de operandos (32
   bits)**, por onde também **voltam os valores de retorno** dos métodos.

5. **Pool de constantes**: guarda as constantes da **classe** (inclusive valores `final`), **evitando
   duplicação em cada instância** e economizando memória. É acessado por **índice de 1 byte (1–255)**
   ou **2 bytes (1–65535)** que **segue o opcode** — sendo o **opcode** exatamente **1 byte**.

6. **Tipos primitivos** têm tamanhos **fixos**: `byte` 1, `short` 2, `int` 4, `long` 8, `float` 4
   (IEEE 754 simples), `double` 8 (IEEE 754 dupla), `char` **2 bytes SEM SINAL** (Unicode). `long` e
   `double` ocupam **2 slots** de 32 bits. Ponto flutuante tem os especiais **`NaN`**,
   **`POSITIVE_INFINITY`** e **`NEGATIVE_INFINITY`** em `Float`/`Double`.

7. **Sete categorias de variáveis**: de classe, de instância, componentes de array, parâmetros de
   método, parâmetros de construtor, parâmetro de manipulador de exceção e locais. Todas têm
   **alocação dinâmica baseada em registro de ativação**. **Só as variáveis locais NÃO recebem valor
   default** — têm que ser iniciadas explicitamente.

8. **Nomes e pacotes**: **nome simples** (um identificador) × **nome qualificado** (acesso a membros
   de pacotes e de tipos de referência). Um arquivo **`.java`** é uma **unidade de compilação** com
   **no máximo uma classe pública** de mesmo nome; no topo vêm **`package`**, **`import`** e
   **`class`**. `import` permite usar o **nome simples**; os tipos públicos de **`java.lang` são
   importados automaticamente**.

9. **Object / String / abstrata / interface**: `Object` é superclasse de **tudo** (classes **e
   arrays**); `String` é **imutável** e seus literais são **referências** a instâncias. **Classe
   abstrata** não pode ser instanciada, pode ter métodos concretos, e reúne classes em torno de
   métodos comuns. **Interface** não é classe, **só tem métodos abstratos e atributos constantes**,
   **tudo público**, e **simula herança múltipla**.

10. **Iniciação da JVM**: `java Classe args...` chama **`main`** (obrigatoriamente **`public static
    void`**, recebendo **`String[]`**); como a classe não está na memória, roda o **ClassLoader** →
    **CARGA** (erros: `ClassFormatError`, `UnsupportedClassVersionError`, `ClassCircularityError`,
    `NoClassDefFoundError`) → **LIGAÇÃO**: **Verificação** (`VerifyError`) → **Preparação** (aloca
    código estático e tabelas de métodos) → **Resolução** de referências simbólicas, **estática (o
    mais cedo possível)** ou **preguiçosa (o mais tarde possível)** (`IllegalAccessError`,
    `InstantiationError`, `NoSuchFieldError`, `NoSuchMethodError`) → **INICIAÇÃO** (variáveis de
    classe e blocos estáticos **na ordem do código**, com **todas as superclasses iniciadas antes,
    recursivamente, até `Object`**) → e só então **`main` executa**.

---

## Apêndice — Divergências deste PDF com o Java SE 8

Este PDF segue a **2ª edição da JVMS**. O que mudou até o **Java 8** e afeta o que está escrito aqui:

| Tema | 2ª edição (o slide) | **JVMS 8** |
|---|---|---|
| Interfaces | Só métodos abstratos, todos públicos | \+ métodos **`default`** e **`static`** com corpo (ainda públicos) |
| Iniciação de classe (§5.5) | Iniciar uma classe inicia só as **superclasses** | \+ as **superinterfaces que declaram métodos `default`** |
| Invocação | 4 instruções `invoke*` | **5** — entrou **`invokedynamic`** (opcode 186 / `0xba`), base das lambdas |
| Pool de constantes | 11 tags (1 e 3–12) | **14** tags — entraram **15** (`MethodHandle`), **16** (`MethodType`) e **18** (`InvokeDynamic`) |
| `jsr` / `ret` | Uso normal (implementavam `finally`) | **Proibidas** em `major_version ≥ 51`. O tipo `returnAddress` continua na especificação |
| Verificação | Inferência de tipos | **`StackMapTable`** obrigatório (*type checking*) desde o `major` 50/51 |
| Área de métodos | — | Implementação: PermGen até o Java 7, **Metaspace** no Java 8 (a especificação não cita nenhuma das duas) |
| `strictfp` | Distinção FP-strict × non-FP-strict | **Ainda vale no Java 8**; só o Java 17 tornou tudo estrito (🟪) |

🟥 **Independente de versão:** o slide descreve `UnsupportedClassVersionError` como "versão antiga"
(é o contrário — versão **nova** demais); trata o frame como se **contivesse** o pool de constantes
(ele contém uma **referência**); e fala em slots de **32 bits** (a JVMS não define o tamanho do slot —
define que `long`/`double` ocupam **2**).

Detalhamento completo em [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).

---

*Bons estudos! Revise especialmente as tabelas das seções 5 (tipos de variáveis), 9 (abstrata ×
interface) e 12 (erros por fase) — são as que mais viram questão objetiva.*
