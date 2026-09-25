# JVM 8 — Parte 1 de 3: Estruturação da Máquina Virtual Java

> Resumo didático completo do arquivo `java-jvm8-1-3.pdf` (32 slides).
> Baseado em *The Java Virtual Machine Specification*, 2nd Edition — Tim Lindholm & Frank Yellin.
> Disciplina: Software Básico (CIC0104 — UnB).

> 🔎 **Revisão Java 8** — note a tensão na linha acima: o PDF se chama **`java-jvm8`**, mas cita a
> **2ª edição** da JVMS (Java 2, ~1999). A prova cobre **Java SE 8 / JVMS 8**. Onde as duas edições
> divergem, há uma anotação 🟦 (**Divergência Java 8**), 🟪 (**Posterior ao Java 8**) ou
> 🟥 (**Divergência com a especificação**). Apanhado completo em
> [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).

---

## Sumário

1. [O que você precisa saber para a prova](#1-o-que-você-precisa-saber-para-a-prova)
2. [Introdução: o que é a JVM](#2-introdução-o-que-é-a-jvm)
3. [Tipos de dados da JVM](#3-tipos-de-dados-da-jvm)
   - 3.1 [Visão geral: primitivos × referência](#31-visão-geral-primitivos--referência)
   - 3.2 [A JVM não faz checagem de tipo](#32-a-jvm-não-faz-checagem-de-tipo)
   - 3.3 [Tipos primitivos e valores](#33-tipos-primitivos-e-valores)
   - 3.4 [O tipo `returnAddress`](#34-o-tipo-returnaddress)
   - 3.5 [Tipos de referência e `null`](#35-tipos-de-referência-e-null)
4. [Áreas de dados em tempo de execução](#4-áreas-de-dados-em-tempo-de-execução)
   - 4.1 [Visão geral e diagrama](#41-visão-geral-e-diagrama)
   - 4.2 [Registrador PC](#42-registrador-pc)
   - 4.3 [Pilha da JVM](#43-pilha-da-jvm)
   - 4.4 [Heap](#44-heap)
   - 4.5 [Área de métodos](#45-área-de-métodos)
   - 4.6 [Pool de constantes em runtime](#46-pool-de-constantes-em-runtime)
   - 4.7 [Pilha de métodos nativos](#47-pilha-de-métodos-nativos)
   - 4.8 [Tabela-resumo das áreas e exceções](#48-tabela-resumo-das-áreas-e-exceções)
5. [Frames (pilha de frames)](#5-frames-pilha-de-frames)
   - 5.1 [O que é um frame](#51-o-que-é-um-frame)
   - 5.2 [Diagrama do frame](#52-diagrama-do-frame)
   - 5.3 [Frame, método e classe correntes](#53-frame-método-e-classe-correntes)
   - 5.4 [Vetor de variáveis locais](#54-vetor-de-variáveis-locais)
   - 5.5 [Pilha de operandos](#55-pilha-de-operandos)
   - 5.6 [Ligação dinâmica (referência ao pool de constantes)](#56-ligação-dinâmica-referência-ao-pool-de-constantes)
   - 5.7 [Término normal de método](#57-término-normal-de-método)
   - 5.8 [Término abrupto de método](#58-término-abrupto-de-método)
   - 5.9 [Informação adicional](#59-informação-adicional)
6. [Representação de objetos](#6-representação-de-objetos)
7. [Ponto flutuante e o padrão IEEE 754 em Java](#7-ponto-flutuante-e-o-padrão-ieee-754-em-java)
8. [Palavras-chave da linguagem Java](#8-palavras-chave-da-linguagem-java)
9. [Métodos especiais: `<init>` e `<clinit>`](#9-métodos-especiais-init-e-clinit)
   - 9.1 [`<init>` — iniciação de instância](#91-init--iniciação-de-instância)
   - 9.2 [`<clinit>` — iniciação de classe](#92-clinit--iniciação-de-classe)
   - 9.3 [Ordem de execução de blocos e construtores](#93-ordem-de-execução-de-blocos-e-construtores)
10. [Instruções da JVM citadas nesta parte](#10-instruções-da-jvm-citadas-nesta-parte)
11. [Resumo em 10 pontos](#11-resumo-em-10-pontos)

---

## 1. O que você precisa saber para a prova

Esta é a lista curta do que cai com mais frequência em questões de verdadeiro/falso e de
múltipla escolha sobre esta parte da matéria. Cada item está detalhado adiante.

| # | Ponto essencial |
|---|-----------------|
| 1 | **Os tipos de dados da JVM não são idênticos aos da linguagem Java.** A JVM tem o tipo `returnAddress`, que não existe em Java; e **não** tem instruções dedicadas ao tipo `boolean`. |
| 2 | A JVM **não realiza checagem de tipo em tempo de execução**; quem é fortemente tipada, com checagem **estática**, é a linguagem Java. A distinção de tipos na JVM vem do **opcode** (`iadd`, `ladd`, `fadd`, `dadd`). |
| 3 | Valores primitivos **não têm tags** de tipo na memória. |
| 4 | Áreas criadas na **iniciação da JVM** e **compartilhadas por todas as threads**: **heap**, **área de métodos** (e, dentro dela, o **pool de constantes**). |
| 5 | Áreas criadas por **thread** (privadas): **registrador PC**, **pilha da JVM** (frames) e **pilha de métodos nativos**. |
| 6 | O **frame contém uma *referência* ao pool de constantes** da classe do método corrente — o frame **não contém o pool de constantes**. |
| 7 | No frame de **método de instância ou construtor**, o índice **0** do vetor de variáveis locais guarda a referência `this`; em **método estático**, o índice 0 guarda o **primeiro parâmetro**. |
| 8 | **Slots** (tanto do vetor de variáveis locais quanto da pilha de operandos) têm **32 bits**; `long` e `double` ocupam **dois slots acoplados**, em **big-endian**. |
| 9 | Tamanhos de `max_locals` e `max_stack` são determinados em **tempo de compilação** e guardados junto com o código do método. |
| 10 | **Nem todo bytecode usa a pilha de operandos** — por exemplo, `ret index` e `goto` operam sem empilhar/desempilhar; `iinc` incrementa direto na variável local. |
| 11 | Um método que termina **abruptamente** (exceção não tratada) **não retorna valor** ao chamador. |
| 12 | A pilha de operandos de um frame **nasce vazia**; o valor de retorno de um método é entregue **empilhado na pilha de operandos do frame do chamador**. |
| 13 | `<init>` (construtor) e `<clinit>` (iniciação de classe) **não podem ser chamados** a partir de código Java; `<init>` é invocado pela instrução `invokespecial`. |
| 14 | Só pode existir **um** `<clinit>` por classe, **sem argumentos e sem retorno**; se existir, é o **primeiro** método executado. |
| 15 | `true`, `false` e `null` **são literais, não palavras-chave**. `const` e `goto` são palavras-chave **reservadas mas não implementadas**. |
| 16 | Exceções por área: `StackOverflowError` (pilha da JVM e pilha nativa), `OutOfMemoryError` (heap, área de métodos, pool de constantes, criação/expansão de pilhas). |
| 17 | Opções da JVM: `-Xss<size>` (tamanho da pilha), `-Xms<size>` (heap inicial), `-Xmx<size>` (heap máximo). |

---

## 2. Introdução: o que é a JVM

A **Java Virtual Machine (JVM)** é uma **máquina abstrata**: uma especificação de um
computador imaginário, definido por um conjunto de instruções (os *bytecodes*), um
conjunto de tipos de dados e um conjunto de áreas de memória em tempo de execução.

O fluxo básico é:

```
   Foo.java  ──[ javac ]──►  Foo.class  ──[ carregado pela JVM ]──►  execução
   (fonte)     compilador     (bytecode)      class loader           interpretação/JIT
```

Ideia central: o compilador Java **não** gera código de máquina de um processador real;
gera bytecode para a JVM. Quem traduz para a máquina real é a implementação da JVM
(interpretador e/ou compilador JIT). Daí o "*write once, run anywhere*".

O sumário original do material cobre, nesta parte 1 de 3:

- Estruturação da JVM (introdução);
- Tipos de dados (primitivos e de referência);
- Estruturas de dados em tempo de execução;
- Frames;
- Representação de objetos;
- Instruções da JVM (introduzidas ao longo dos exemplos; detalhadas nas partes 2 e 3).

> ⚠️ **Pegadinha de prova**
> A JVM é definida como uma **especificação**, não como um programa específico. "JVM"
> (a máquina abstrata), "implementação da JVM" (HotSpot, OpenJ9, …) e "instância da JVM"
> (o processo em execução) são coisas distintas. A especificação **não obriga** uma
> implementação concreta para vários detalhes (ex.: como representar `null`, como
> representar objetos internamente).

---

## 3. Tipos de dados da JVM

### 3.1 Visão geral: primitivos × referência

A JVM opera sobre duas grandes famílias de tipos:

```
                        Tipos de dados da JVM
                                 │
            ┌────────────────────┴────────────────────┐
            ▼                                         ▼
       PRIMITIVOS                               DE REFERÊNCIA
   (assumem apenas                       (ponteiros para objetos;
    valores primitivos)                assumem apenas valores de referência)
            │                                         │
   ┌────────┼─────────┬──────────────┐      ┌─────────┼──────────┬──────────┐
   ▼        ▼         ▼              ▼      ▼         ▼          ▼          ▼
numéricos boolean  returnAddress          classe    array   interface     null
   │                (só da JVM!)                                       (valor especial)
   ├── integrais: byte, short, int, long, char
   └── ponto flutuante: float, double  (IEEE 754)
```

Ambas as famílias de valores podem ser:
- armazenadas em **variáveis** (locais ou fields);
- passadas como **argumentos** de métodos;
- **retornadas** por métodos;
- usadas em **operações específicas** (instruções próprias para cada tipo).

### 3.2 A JVM não faz checagem de tipo

Este é um dos pontos mais cobrados.

- **Java é fortemente tipada e usa checagem de tipo estática** — ou seja, quem verifica
  os tipos é o **compilador** (`javac`), em tempo de compilação.
- **A JVM não realiza checagem de tipo** (dinâmica) para distinguir valores.
- Valores de tipos primitivos **não possuem tags** e **não requerem checagem dinâmica**
  para serem distinguidos de valores de tipos de referência. Um slot de 32 bits contendo
  `0x0000002A` pode ser o `int` 42 ou uma referência — a JVM não guarda essa informação
  junto do valor.

Então, como a JVM sabe o tipo? **Pela instrução (opcode) usada**. Existe um bytecode
diferente por tipo de operando:

| Instrução | Tipo dos operandos | Efeito na pilha |
|-----------|--------------------|-----------------|
| `iadd` | `int` | `(..., value1, value2) → (..., result)` |
| `ladd` | `long` | `(..., value1, value2) → (..., result)` |
| `fadd` | `float` | `(..., value1, value2) → (..., result)` |
| `dadd` | `double` | `(..., value1, value2) → (..., result)` |

Todas somam dois valores numéricos e produzem um resultado numérico; cada uma é
**específica de um tipo**. O mesmo padrão (prefixo `i`, `l`, `f`, `d`, `a` para
referência, `b`, `s`, `c` para byte/short/char) aparece em quase todo o conjunto de
instruções: `iload`/`aload`, `istore`/`astore`, `imul`/`dmul`, `ireturn`/`areturn`, etc.

> ⚠️ **Pegadinha de prova**
> "A JVM verifica os tipos em tempo de execução" → **FALSO**.
> "Valores primitivos carregam tags de tipo na memória" → **FALSO**.
> "A distinção de tipos é feita pelas instruções" → **VERDADEIRO**.
> Observação: o *verificador de bytecode* (bytecode verifier), executado na **carga** da
> classe, faz uma análise de tipos — mas isso é verificação estática do `.class`, não
> checagem dinâmica de valores durante a execução.

#### Objetos e referências

- Um **objeto** é uma **instância de uma classe** *ou* um **array**.
- Uma **referência** para um objeto é um dado do **tipo de referência**; valores de tipo
  de referência podem ser vistos como **ponteiros** para objetos.
- **Mais de uma referência pode existir para um mesmo objeto** (aliasing).
- Objetos são **sempre** operados, passados ou testados **via valores de tipo de
  referência** — nunca por cópia da estrutura.
- **Não existem ponteiros em Java** na forma da linguagem C: não há aritmética de
  ponteiros, nem operadores `*`/`&`, nem como obter o endereço bruto.

**Pergunta do slide:** *"Se existir mais de uma referência para um objeto, como o coletor
de lixo sabe quando desalocá-lo?"*
**Resposta:** o coletor de lixo trabalha por **alcançabilidade (reachability)**, e não
por contagem simples de referências: partindo das *GC roots* (variáveis locais nos frames
das threads vivas, fields estáticos, referências da JNI, etc.), ele percorre o grafo de
objetos; tudo que **não é alcançável por nenhum caminho** é candidato à coleta — mesmo que
haja várias referências entre si (ex.: ciclos isolados). É exatamente isso que o material
expressa ao dizer que "objetos **sem caminhos de acesso** são coletados".

### 3.3 Tipos primitivos e valores

#### Tipos integrais

| Tipo | Faixa (notação do slide) | Faixa decimal | Tamanho |
|------|--------------------------|---------------|---------|
| `byte` | −2⁷ a 2⁷−1 | −128 a 127 | 8 bits |
| `short` | −2¹⁵ a 2¹⁵−1 | −32.768 a 32.767 | 16 bits |
| `int` | −2³¹ a 2³¹−1 | −2.147.483.648 a 2.147.483.647 | 32 bits |
| `long` | −2⁶³ a 2⁶³−1 | −9.223.372.036.854.775.808 a 9.223.372.036.854.775.807 | 64 bits |
| `char` | 0 a 2¹⁶−1 | 0 a 65.535 | 16 bits (**sem sinal**) |

> ⚠️ **Pegadinha de prova**
> `char` é o **único tipo integral sem sinal** de Java (0 a 65535). Todos os demais são
> **com sinal, em complemento de dois**. Não existe `unsigned` em Java.

#### Tipos de ponto flutuante (IEEE 754)

- `float`: valores do conjunto de valores *float* (32 bits);
- `double`: valores do conjunto de valores *double* (64 bits).

#### Tipo booleano

- Valores verdade: `true` (**1**) e `false` (**0**).
- **Não há instruções da JVM específicas para o tipo booleano.**
  - Expressões booleanas em Java são mapeadas como **expressões `int`** na pilha de
    operandos (usa-se `iload`, `istore`, `ifeq`, `ifne`, …).
  - **Arrays de `boolean`** são mapeados em **bytes** (8 bits por elemento) na JVM,
    manipulados pelas instruções `baload`/`bastore`.

Exemplo concreto:

```java
boolean flag = true;     //  iconst_1 ; istore_1   → tratado como int
if (flag) { ... }        //  iload_1  ; ifeq  <desvio>
boolean[] v = new boolean[10];   // newarray boolean → 10 bytes
```

> ⚠️ **Pegadinha de prova**
> "A JVM possui instruções aritméticas próprias para `boolean`" → **FALSO**.
> `boolean` é manipulado como `int` na pilha, e como `byte` quando está em array.
> Consequência: o tipo `boolean` **existe** na JVM (é primitivo), mas **não tem suporte
> direto** no conjunto de instruções.

### 3.4 O tipo `returnAddress`

- É o **único tipo da JVM não associado a nenhum tipo de dado da linguagem Java**.
- Usado pelas instruções de **sub-rotina** dentro de um método:
  - `jsr` — *jump subroutine*;
  - `jsr_w` — *jump subroutine – wide index*;
  - `ret` — *return from subroutine*.
- Seus valores são **ponteiros para o código de operação** (opcode) que indica um
  **desvio incondicional** no método em execução. Na prática, o `returnAddress`
  empilhado é o **endereço da instrução seguinte** ao `jsr` (o *offset de retorno*).

| Instrução | Formato | Efeito na pilha |
|-----------|---------|-----------------|
| `jsr branchbyte1 branchbyte2` | offset de 2 bytes | `(...) → (..., address)` |
| `jsr_w branchbyte1..branchbyte4` | offset de 4 bytes | `(...) → (..., address)` |
| `ret index` | `index` de 1 byte | `(...) → (...)` — **não mexe na pilha** |

- Em `ret index`, o `index` é um **offset de um byte usado como índice para o vetor de
  variáveis locais** do frame; esse slot contém o **offset de retorno**. A execução
  continua nesse offset.

Uso histórico: `jsr`/`ret` implementavam os blocos `finally` (a sub-rotina do `finally`
era chamada de vários pontos do método e retornava ao ponto de chamada). Compiladores
modernos duplicam o código do `finally` em vez de usar `jsr`.

```
   ... instrução A
   jsr  L          ; empilha o endereço da instrução B (returnAddress)
   ... instrução B ◄──────────┐
   ...                        │
L: astore_3        ; guarda o returnAddress na variável local 3
   ...corpo da sub-rotina...  │
   ret  3          ; salta de volta para o endereço guardado no slot 3
```

> ⚠️ **Pegadinha de prova**
> "Todo tipo da JVM corresponde a um tipo da linguagem Java" → **FALSO**: `returnAddress`
> não tem correspondente em Java.
> Note também que `ret index` **não usa a pilha de operandos** — ele lê o endereço
> diretamente de uma variável local. É o contraexemplo clássico para "toda instrução da
> JVM opera sobre a pilha de operandos" → **FALSO**.
>
> 🟦 **Divergência Java 8** — `jsr`, `jsr_w` e `ret` estão **proibidas** em arquivos `.class` com
> `major_version ≥ 51` (Java 7). Como o Java 8 usa `major_version = 52`, **nenhuma classe compilada
> para Java 8 pode conter essas instruções** — os compiladores passaram a **duplicar o código do
> `finally`** em vez de chamá-lo como sub-rotina. O **tipo `returnAddress` continua na especificação**
> (JVMS 8 §2.3.3), e continua sendo o argumento certo para "os tipos da JVM não são os de Java".
>
> **Na prova:** `returnAddress` como *tipo* → ainda vale, use-o. `jsr`/`ret` como *instruções em uso*
> → é descrição histórica; se a questão perguntar se podem aparecer num `.class` atual, a resposta é
> **não**.

### 3.5 Tipos de referência e `null`

Existem **três** tipos de referência:

| Tipo de referência | Os valores são referências a… |
|--------------------|-------------------------------|
| **Tipo de classe** | instâncias de classes criadas **dinamicamente** |
| **Tipo de array** | arrays criados **dinamicamente** |
| **Tipo de interface** | instâncias de classes que **implementam** a interface, ou arrays |

E o valor de referência especial **`null`**:

- é a **referência vazia** — indica que não aponta para nenhum objeto;
- **não tem tipo em tempo de execução**, mas **pode ser moldado (cast) para qualquer
  tipo de referência**;
- **a especificação da JVM não define um valor concreto para codificar `null`** (não
  precisa ser 0, embora quase todas as implementações usem 0).

```java
String s = null;          // ok
Object o = (Object) null; // cast válido
int[] v = (int[]) null;   // cast válido
```

> ⚠️ **Pegadinha de prova**
> "`null` é do tipo `Object`" → **FALSO**: `null` não tem tipo em runtime.
> "`null` é obrigatoriamente representado pelo valor 0" → **FALSO**: a especificação não
> define a codificação concreta.
> "`null` é uma palavra-chave de Java" → **FALSO**: é um **literal** (ver seção 8).

---

## 4. Áreas de dados em tempo de execução

### 4.1 Visão geral e diagrama

A JVM define áreas de dados com **dois tempos de vida distintos**:

| Alocadas na **iniciação da JVM** (compartilhadas por todas as threads) | Alocadas na **criação de cada thread** (privadas da thread) |
|---|---|
| **Heap** | **Registrador PC** |
| **Área de métodos** (que contém o **pool de constantes** de cada classe) | **Pilha da JVM** (frames) |
| | **Pilha de métodos nativos** |

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        INSTÂNCIA DA JVM (processo)                        │
│                                                                           │
│   COMPARTILHADO ENTRE TODAS AS THREADS                                    │
│  ┌─────────────────────────────┐   ┌──────────────────────────────────┐   │
│  │           HEAP              │   │        ÁREA DE MÉTODOS           │   │
│  │  objetos (instâncias de     │   │  por classe/interface:           │   │
│  │  classes) e arrays          │   │   • pool de constantes (runtime) │   │
│  │  coletado pelo GC           │   │   • fields (atributos)           │   │
│  │  -Xms / -Xmx                │   │   • dados dos métodos            │   │
│  │                             │   │   • código dos métodos           │   │
│  │                             │   │   • código dos construtores      │   │
│  └─────────────────────────────┘   └──────────────────────────────────┘   │
│                                                                           │
│   POR THREAD (privado)                                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                     │
│  │  Thread 1    │  │  Thread 2    │  │  Thread N    │                     │
│  │ ┌──────────┐ │  │ ┌──────────┐ │  │ ┌──────────┐ │                     │
│  │ │ reg. PC  │ │  │ │ reg. PC  │ │  │ │ reg. PC  │ │                     │
│  │ ├──────────┤ │  │ ├──────────┤ │  │ ├──────────┤ │                     │
│  │ │ pilha da │ │  │ │ pilha da │ │  │ │ pilha da │ │                     │
│  │ │   JVM    │ │  │ │   JVM    │ │  │ │   JVM    │ │                     │
│  │ │ (frames) │ │  │ │ (frames) │ │  │ │ (frames) │ │                     │
│  │ ├──────────┤ │  │ ├──────────┤ │  │ ├──────────┤ │                     │
│  │ │  pilha   │ │  │ │  pilha   │ │  │ │  pilha   │ │                     │
│  │ │ de mét.  │ │  │ │ de mét.  │ │  │ │ de mét.  │ │                     │
│  │ │ nativos  │ │  │ │ nativos  │ │  │ │ nativos  │ │                     │
│  │ └──────────┘ │  │ └──────────┘ │  │ └──────────┘ │                     │
│  └──────────────┘  └──────────────┘  └──────────────┘                     │
└──────────────────────────────────────────────────────────────────────────┘
```

> ⚠️ **Pegadinha de prova**
> Classificar cada área como **compartilhada** ou **por thread** é questão clássica.
> Decore: **heap e área de métodos são compartilhados**; **PC, pilha da JVM e pilha
> nativa são por thread**. O pool de constantes fica **dentro da área de métodos**, logo
> é compartilhado — mas o **frame** guarda só uma **referência** para ele.

### 4.2 Registrador PC

- **Cada thread da JVM possui seu próprio registrador PC** (*program counter*, contador
  de programa).
- Em um dado instante, **cada thread executa o código de um único método**, chamado
  **método corrente**.
- O conteúdo do PC depende da natureza do método corrente:

| Método corrente | Conteúdo do registrador PC |
|-----------------|----------------------------|
| **Não nativo** (método Java) | o **endereço da instrução da JVM sendo executada** |
| **Nativo** (não Java, ex.: JNI/C) | **indefinido**; pode conter um `returnAddress` ou um ponteiro nativo da plataforma em que a JVM foi implementada |

> ⚠️ **Pegadinha de prova**
> "O registrador PC é único e compartilhado pela JVM" → **FALSO**: é **um por thread**.
> "Quando o método corrente é nativo, o PC aponta para a próxima instrução Java" →
> **FALSO**: o valor é **indefinido**.

### 4.3 Pilha da JVM

- Armazena **frames**, um para **cada chamada de método** em uma thread.
- Permite manipular **variáveis locais**, **resultados parciais** e participa da
  **chamada e retorno** de métodos.
- A implementação da JVM **deve permitir** pilhas de **tamanho fixo** ou com
  **expansão e contração dinâmica** conforme a computação exigir.
- Exceções possíveis:
  - **`StackOverflowError`** — a computação em uma thread requer uma pilha **maior do que
    a permitida** (caso típico: recursão infinita);
  - **`OutOfMemoryError`** — não há memória suficiente para **expandir dinamicamente** uma
    pilha ou para **criar a pilha de uma nova thread**.
- O **tamanho máximo** de uma pilha é definido pela opção **não padronizada**
  **`-Xss<size>`** da JVM (programa `java`). Ex.: `java -Xss512k MinhaClasse`.

```java
static int f(int n) { return f(n + 1); }  // sem caso base → StackOverflowError
```

> ⚠️ **Pegadinha de prova**
> `StackOverflowError` e `OutOfMemoryError` são **`Error`**, não `Exception` — não se
> espera que sejam tratados pelo programa. Cuidado também: uma pilha que **não consegue
> crescer por falta de memória** gera `OutOfMemoryError`, enquanto uma pilha que
> **atingiu o limite configurado** gera `StackOverflowError`.

### 4.4 Heap

- É **criado na iniciação da JVM** e **compartilhado por todas as threads**.
- É usado para **alocar memória para os objetos**: **todas as instâncias de classes e
  arrays**.
- Objetos **não são explicitamente desalocados** (não existe `free`/`delete` em Java):
  objetos **sem caminhos de acesso** são coletados pelo **coletor de lixo**.
- A implementação deve permitir controlar: **tamanho inicial**, se pode ser
  **dinamicamente expandido ou contraído**, e seus **tamanhos máximo e mínimo**.
- Exceção: **`OutOfMemoryError`**, se a computação requer mais memória do heap do que
  pode ser disponibilizada.
- Opções: **`-Xms<size>`** (valor **inicial**) e **`-Xmx<size>`** (valor **máximo**).
  Ex.: `java -Xms256m -Xmx2g MinhaClasse`.

> ⚠️ **Pegadinha de prova**
> **Tudo que é objeto (incluindo arrays, inclusive arrays de primitivos) vive no heap.**
> As **variáveis locais** ficam no **frame** (pilha), mas se a variável local for de tipo
> de referência, **o objeto apontado está no heap**. "Arrays de `int` ficam na pilha" →
> **FALSO**.

### 4.5 Área de métodos

- **Criada na iniciação da JVM** e **compartilhada por todas as threads** (inclusive no
  caso de computador multi-core).
- É **similar à área de armazenamento de código compilado** de uma linguagem compilada
  (o "segmento de texto").
- Armazena **estruturas de dados por classe**:
  - **pool de constantes**;
  - **atributos (fields)**;
  - **dados de métodos**;
  - **código dos métodos**;
  - **código dos construtores**.
- Exceção: **`OutOfMemoryError`**, se o requisito de memória para a área de métodos não
  puder ser atendido.

```
ÁREA DE MÉTODOS
├── classe Point
│   ├── pool de constantes (runtime)
│   ├── fields: x, y (descritores) + fields estáticos (valores)
│   ├── dados dos métodos: nome, descritor, max_stack, max_locals
│   └── código: <init>, getX(), ...
├── classe ColoredPoint
│   └── ...
└── interface Comparable
    └── ...
```

> ⚠️ **Pegadinha de prova**
> A área de métodos guarda o **código** dos métodos, e **não** os frames nem as variáveis
> locais. O **corpo do método está na área de métodos; a execução desse método acontece
> em um frame na pilha da thread**.
>
> 🟦 **Divergência Java 8 — PermGen × Metaspace.** A área de métodos era implementada na
> *permanent generation* (**PermGen**) até o Java 7. O **Java 8 removeu a PermGen** (JEP 122): os
> metadados de classe passaram para a **Metaspace**, alocada em **memória nativa**, fora do heap.
> Efeitos colaterais que valem citar numa discursiva:
> - a flag `-XX:MaxPermSize` **deixou de existir**; a equivalente é `-XX:MaxMetaspaceSize`;
> - `OutOfMemoryError: PermGen space` virou `OutOfMemoryError: Metaspace`;
> - o **pool de strings internadas** já havia saído da PermGen para o **heap** no **Java 7**.
>
> 🟥 Cuidado com a última frase: PermGen e Metaspace são **detalhes da HotSpot**. A **especificação**
> nunca cita nenhuma das duas — ela só diz que a área de métodos é **logicamente parte do heap** e é
> **compartilhada entre todas as threads**. Numa questão conceitual, responda pela especificação.

### 4.6 Pool de constantes em runtime

- É **construído na área de métodos** quando a **classe/interface é criada** pela JVM.
- Armazena estrutura de dados **por classe ou interface**: é a **representação em tempo
  de execução da tabela `constant_pool` do arquivo `.class`**.
- Contém **constantes**, desde **literais numéricos conhecidos em tempo de compilação**
  até **referências a métodos e atributos que devem ser resolvidos em tempo de
  execução** (referências simbólicas).
- Desempenha função **similar à de uma tabela de símbolos** de uma linguagem compilada.
- Exceção: **`OutOfMemoryError`**, se a construção do pool de constantes para uma classe
  ou interface exigir mais memória do que a disponível na área de métodos.

#### Detalhes importantes

- Armazena **todas as constantes associadas à classe ou interface**, **inclusive os
  valores das variáveis declaradas como `final`**.
- **Evita duplicar as constantes em cada instância da classe** — a constante existe uma
  única vez, na classe, e não em cada objeto.
- As instruções que **empilham constantes na pilha de operandos a partir do CP** usam um
  **índice do pool de constantes como argumento (operando)**, com **1 byte (1 a 255)** ou
  **2 bytes (1 a 65535)** logo após o bytecode:

| Instrução | Tamanho do índice | Faixa | O que empilha |
|-----------|-------------------|-------|---------------|
| `ldc index` | 1 byte | 1 a 255 | um `int`, `float` ou **referência a uma string literal** |
| `ldc_w indexbyte1 indexbyte2` | 2 bytes | 1 a 65535 | idem `ldc`, com índice largo |
| `ldc2_w indexbyte1 indexbyte2` | 2 bytes | 1 a 65535 | um **`long`** ou **`double`** |

Efeito na pilha das três: `(...) → (..., value)`.

```
        bytecode           pool de constantes (classe corrente)
      ┌───────────┐        ┌────┬──────────────────────────────┐
      │ ldc  #7   │───────►│ #1 │ ...                          │
      └───────────┘        │ ...│                              │
                           │ #7 │ Float  3.14159               │
                           │ #8 │ String "Olá"                 │
                           └────┴──────────────────────────────┘
                                          │
                                          ▼
                              pilha de operandos: [..., 3.14159]
```

> ⚠️ **Pegadinha de prova**
> - O **índice do pool de constantes começa em 1**, não em 0 (a entrada 0 é inválida/
>   reservada). Já o **vetor de variáveis locais começa em 0**. Não confunda!
> - `ldc` usa índice de **1 byte**; para `long` e `double` usa-se **`ldc2_w`** (2 bytes).
>   Não existe `ldc2` de 1 byte.
> - O pool de constantes fica na **área de métodos**, **por classe** — não no heap junto
>   com cada objeto, e não dentro do frame.

### 4.7 Pilha de métodos nativos

- É utilizada como **suporte a métodos nativos** (não Java, tipicamente C/C++ via JNI).
- É uma **pilha convencional**, conhecida coloquialmente como **"pilha C"**.
- É **alocada tipicamente por thread, quando a thread é criada**.
- Exceções possíveis:
  - **`StackOverflowError`** — a computação em uma thread requer uma pilha de método
    nativo maior do que a permitida;
  - **`OutOfMemoryError`** — a pilha nativa pode ser dinamicamente expandida mas não há
    memória suficiente, **ou** não há memória suficiente para criar a pilha de método
    nativo de uma nova thread.

> ⚠️ **Pegadinha de prova**
> A pilha de métodos nativos **não é obrigatória**: uma implementação que não suporte
> métodos nativos pode não fornecê-la. E quando um método **nativo** é o método corrente,
> o **registrador PC fica indefinido** (seção 4.2) — os dois fatos costumam aparecer
> juntos.

### 4.8 Tabela-resumo das áreas e exceções

| Área | Criada quando | Escopo | Conteúdo | Exceções | Opção JVM |
|------|---------------|--------|----------|----------|-----------|
| **Heap** | iniciação da JVM | compartilhada | instâncias de classes e arrays | `OutOfMemoryError` | `-Xms`, `-Xmx` |
| **Área de métodos** | iniciação da JVM | compartilhada | estruturas por classe: CP, fields, dados e código de métodos e construtores | `OutOfMemoryError` | — |
| **Pool de constantes** | criação da classe/interface (dentro da área de métodos) | compartilhada, **por classe** | literais e referências simbólicas | `OutOfMemoryError` | — |
| **Registrador PC** | criação da thread | **por thread** | endereço da instrução corrente (indefinido se método nativo) | — | — |
| **Pilha da JVM** | criação da thread | **por thread** | frames | `StackOverflowError`, `OutOfMemoryError` | `-Xss` |
| **Pilha de métodos nativos** | criação da thread | **por thread** | frames nativos ("pilha C") | `StackOverflowError`, `OutOfMemoryError` | — |

---

## 5. Frames (pilha de frames)

### 5.1 O que é um frame

> **Frame é usado para armazenar dados e resultados parciais, executar ligação dinâmica,
> retornar valores para métodos e disparar exceções.**

- Um **novo frame é criado cada vez que um método é chamado**.
- O frame é **destruído quando o método que o criou encerra**, seja **normalmente**, seja
  **lançando exceção**.
- É **alocado na pilha da JVM da thread que o criou**.
- **Cada frame possui**:
  1. seu próprio **array (vetor) de variáveis locais**;
  2. sua própria **pilha de operandos**;
  3. uma **referência para o pool de constantes** da classe do **método corrente**.
- **Slots** do array de variáveis locais e da pilha de operandos são de **32 bits**.

### 5.2 Diagrama do frame

Reprodução em ASCII do diagrama do slide 17:

```
                         Frame
        ┌────────────────────────────────────────┐
        │  0 1 2 3 4 5 ...                       │
        │ ┌──┬──┬──┬──┬──┬──┬───────────────┐    │
        │ │  │  │  │  │  │  │               │    │   ← Array of local variables
        │ └──┴──┴──┴──┴──┴──┴───────────────┘    │     (vetor de variáveis locais)
        │                                        │
        │        ┌─────────────────┐             │
        │        │                 │             │
        │        ├─────────────────┤             │
        │        │                 │             │
        │        ├─────────────────┤             │
        │        │                 │      ▲      │
        │        ├─────────────────┤      │      │
        │        │                 │   growth    │   ← Operand Stack
        │        ├─────────────────┤   (cresce)  │     (pilha de operandos)
        │        │                 │             │
        │        └─────────────────┘             │
        │                                        │           ┌───────────┐
        │   ┌────┐                               │           │ Constant  │
        │   │ ●──┼───────────────────────────────┼──────────►│   Pool    │
        │   └────┘  referência (ponteiro)        │           └───────────┘
        └────────────────────────────────────────┘        (na ÁREA DE MÉTODOS,
              reference to constant pool                    fora do frame!)
```

E a pilha de frames de uma thread:

```
    PILHA DA JVM (thread)
    ┌───────────────────────────┐
    │ frame de c()  ◄── FRAME CORRENTE (método corrente = c)
    ├───────────────────────────┤
    │ frame de b()              │   (chamador de c)
    ├───────────────────────────┤
    │ frame de a()              │
    ├───────────────────────────┤
    │ frame de main()           │
    └───────────────────────────┘
```

> ⚠️ **Pegadinha de prova**
> **O frame contém uma REFERÊNCIA ao pool de constantes, não o pool de constantes.**
> O pool vive na **área de métodos**, é **único por classe** e **compartilhado** por
> todos os frames de métodos daquela classe. Afirmações do tipo "cada frame possui seu
> próprio pool de constantes" → **FALSO**.
> Já o **vetor de variáveis locais** e a **pilha de operandos** são, sim, **próprios de
> cada frame**.

### 5.3 Frame, método e classe correntes

- Os **tamanhos** do array de variáveis locais e da pilha de operandos são determinados
  em **tempo de compilação** (`max_locals` e `max_stack`).
  - São **armazenados junto com o código do método** associado ao frame (no atributo
    `Code` do `.class`).
  - Assim, a memória para as estruturas de dados do frame pode ser **alocada de uma só
    vez, simultaneamente com a chamada do método**.
- **Frame corrente**: o frame do método em execução (**método corrente**).
  - É **o único ativo em uma thread**.
  - A classe que define esse método é a **classe corrente**.
  - **Todas as operações sobre variáveis locais e pilha de operandos referem-se ao frame
    corrente.**
- Um frame **deixa de ser o corrente** se seu método **chamar outro método** ou se
  **finalizar**:
  - quando um método é chamado, **um novo frame é criado**; esse frame **torna-se o
    corrente quando o controle é transferido** para o novo método;
  - no **retorno**, o frame corrente **passa o valor resultante da chamada** (se existir)
    para o **frame prévio**; o frame corrente é **descartado** e o **frame prévio torna-se
    o novo frame corrente**.
- Um frame criado por uma thread é **local à thread** e **não pode ser referenciado por
  nenhuma outra thread**.

> ⚠️ **Pegadinha de prova**
> - "Existe mais de um frame ativo por thread" → **FALSO**: só **um** é o corrente (os
>   outros estão na pilha, suspensos).
> - "Os tamanhos do vetor de locais e da pilha de operandos são definidos em tempo de
>   execução" → **FALSO**: em **tempo de compilação** (`max_locals`, `max_stack`).
> - "Uma thread pode acessar o frame de outra thread" → **FALSO**.
> - Frames de threads **diferentes** são isolados; mas objetos no **heap** são
>   compartilhados — é por isso que existem problemas de concorrência.

### 5.4 Vetor de variáveis locais

- Contém os **parâmetros do método** e os **valores das variáveis locais** associadas à
  classe ou interface que gerou o frame.
- Seu **comprimento é determinado em tempo de compilação** e armazenado junto com o
  código do método associado ao frame (`max_locals`).
- **Os parâmetros são armazenados primeiro, começando no índice 0:**
  - **frame de método construtor ou de método de instância**: a **referência (`this`) é
    armazenada no índice 0**, seguida pelos parâmetros;
  - **método estático**: o **primeiro parâmetro é armazenado no índice 0**, e assim por
    diante.
- Uma variável local pode armazenar um valor dos tipos: **`boolean`, `byte`, `char`,
  `short`, `int`, `float`, de referência ou `returnAddress`**.
- **Slots são de 32 bits**; **`long` e `double` utilizam dois slots (acoplados)**, em
  **ordem big-endian**.
- Um inteiro usado como **índice do vetor de variáveis locais** assume um valor entre
  **0 e (tamanho do array − 1)**.

#### Exemplo 1 — método de instância

```java
class Conta {
    double saldo;
    int deposita(int valor, long ref, Object quem) {
        int novo = 0;
        ...
    }
}
```

| Índice | Conteúdo | Observação |
|--------|----------|------------|
| 0 | `this` (referência) | **método de instância → `this` no índice 0** |
| 1 | `valor` (`int`) | |
| 2 | `ref` (`long`) — parte alta | `long` ocupa **2 slots** |
| 3 | `ref` (`long`) — parte baixa | slot acoplado, **não é indexável sozinho** |
| 4 | `quem` (referência) | |
| 5 | `novo` (`int`) | variável local declarada no corpo |

```
 índice:   0        1       2        3       4       5
         ┌──────┬───────┬────────┬───────┬───────┬───────┐
         │ this │ valor │  ref (long, 2) │ quem  │ novo  │
         └──────┴───────┴────────┴───────┴───────┴───────┘
                        └── big-endian ──┘
```

#### Exemplo 2 — método estático

```java
static int soma(int a, int b) { int r = a + b; return r; }
```

| Índice | Conteúdo |
|--------|----------|
| 0 | `a` (**primeiro parâmetro**, pois é `static`) |
| 1 | `b` |
| 2 | `r` |

E no caso clássico de `public static void main(String[] args)`: o índice **0** contém a
referência para o array `args`.

> ⚠️ **Pegadinha de prova**
> - "O índice 0 do vetor de variáveis locais sempre contém `this`" → **FALSO**: só em
>   **métodos de instância e construtores**. Em métodos **estáticos** o índice 0 é o
>   primeiro parâmetro.
> - "`long` e `double` ocupam um slot" → **FALSO**: **dois slots acoplados**, em
>   **big-endian**. Você indexa pelo **primeiro** dos dois; o segundo não pode ser usado
>   isoladamente.
> - "`returnAddress` não pode ser guardado em variável local" → **FALSO**: pode (é
>   exatamente o que `jsr`/`ret` fazem, via `astore`).
> - Repare que a lista de tipos de uma variável local **não inclui `long` e `double`
>   explicitamente** no slide — porque eles não cabem em **um** slot; ocupam **um par**.

### 5.5 Pilha de operandos

- É usada para **armazenar valores que são operandos das instruções da JVM** — é a área
  de trabalho da máquina (a JVM é uma **máquina de pilha**, não de registradores).
- Seu **tamanho é determinado em tempo de compilação** (`max_stack`).
- A pilha é **criada vazia** quando o frame é criado.
- Dinâmica de uso:
  - algumas instruções **empilham** valores na pilha (`iconst_1`, `iload_0`, `ldc`, …);
  - outras **retiram operandos da pilha, manipulam-nos e empilham o resultado**
    (`iadd`, `imul`, `ifeq`, …).
  - Exemplo: **`iadd`** retira os **dois inteiros no topo** da pilha, **soma-os** e
    **empilha o resultado**: `(..., value1, value2) → (..., result)`.
- **Valores retornados pelos métodos são recebidos via pilha de operandos** (do frame do
  chamador).
- **Slots são de 32 bits**; **`long` e `double` utilizam dois slots acoplados**, em
  **big-endian**.

#### Traço de execução: `int c = a + b;` com `a = 3`, `b = 4`

Suponha `a` no slot 1 e `b` no slot 2, `c` no slot 3, dentro de um método estático.

```
 Bytecode      Vetor de locais            Pilha de operandos
 ─────────────────────────────────────────────────────────────
 (início)      [_, 3, 4, _]               [ ]            (vazia)
 iload_1       [_, 3, 4, _]               [ 3 ]
 iload_2       [_, 3, 4, _]               [ 3, 4 ]       ← topo à direita
 iadd          [_, 3, 4, _]               [ 7 ]          desempilha 4 e 3, empilha 7
 istore_3      [_, 3, 4, 7]               [ ]            desempilha e guarda no slot 3
```

> ⚠️ **Pegadinha de prova**
> - "A pilha de operandos é criada já contendo os parâmetros do método" → **FALSO**: ela
>   **nasce vazia**; os parâmetros vão para o **vetor de variáveis locais**.
> - "Toda instrução da JVM usa a pilha de operandos" → **FALSO**. Contraexemplos:
>   `ret index` (lê de variável local e desvia), `goto`/`goto_w`, `iinc index const`
>   (incrementa uma variável local **diretamente**, sem passar pela pilha), `nop`.
> - "A pilha de operandos e a pilha da JVM são a mesma coisa" → **FALSO**: a **pilha da
>   JVM** é a pilha de **frames** da thread; a **pilha de operandos** existe **dentro de
>   cada frame**.
> - O valor de retorno de um método vai para a pilha de operandos **do chamador**, não
>   para uma variável local automaticamente.

#### Comparação rápida: vetor de variáveis locais × pilha de operandos

| Característica | Vetor de variáveis locais | Pilha de operandos |
|---|---|---|
| Acesso | **por índice** (aleatório), a partir de 0 | **LIFO** (só o topo) |
| Tamanho definido em | compilação (`max_locals`) | compilação (`max_stack`) |
| Estado inicial do frame | contém `this` (se houver) + parâmetros | **vazia** |
| Slot | 32 bits (`long`/`double` = 2 slots) | 32 bits (`long`/`double` = 2 slots) |
| Papel | armazenamento nomeado/indexado | área de trabalho das instruções |
| Onde fica | dentro do frame | dentro do frame |

### 5.6 Ligação dinâmica (referência ao pool de constantes)

A **referência ao pool de constantes (CP)** existente no frame é o que **permite
suportar a ligação dinâmica** do código do método.

- O código no formato `.class` de um método usa **referências simbólicas** para os
  métodos que serão chamados e para as variáveis a serem acessadas.
  (Exemplo de referência simbólica: `java/io/PrintStream.println:(Ljava/lang/String;)V`.)
- A **ligação dinâmica traduz as referências simbólicas** em:
  - **referências concretas a métodos** — se necessário, **classes são carregadas** para
    resolver os símbolos ainda não resolvidos;
  - **offsets apropriados** em estruturas de armazenamento, com a **localização em tempo
    de execução das variáveis** (locais e dos *fields*).
- A **ligação tardia (late binding)** de métodos e variáveis torna **alterações em outras
  classes** que um método usa **menos prováveis de quebrar o código desse método** — é
  possível recompilar uma classe usada sem recompilar todas as que a usam.

```
   frame corrente                  pool de constantes da classe corrente
   ┌───────────────┐               ┌─────────────────────────────────────────┐
   │ ...           │               │ #12 → Methodref:                        │
   │ ref. ao CP ●──┼──────────────►│        Conta.deposita:(I)V   (SIMBÓLICO)│
   └───────────────┘               └─────────────────────────────────────────┘
                                                    │
                            resolução (1ª vez)      ▼
                              carrega/liga     endereço concreto do código
                                               do método na área de métodos
```

> ⚠️ **Pegadinha de prova**
> "A ligação de métodos em Java é feita totalmente em tempo de compilação" → **FALSO**:
> o `.class` guarda **referências simbólicas**, resolvidas **em tempo de execução**
> (tipicamente na **primeira utilização**). É por isso que existe a
> `NoSuchMethodError`/`NoClassDefFoundError` **em runtime**.

### 5.7 Término normal de método

**Término normal** ocorre se a execução do método **não provocar o lançamento de
exceção**.

- O método chamado executa **uma das instruções `return`** com **o tipo apropriado** ao
  valor a retornar:

| Instrução | Tipo retornado |
|-----------|----------------|
| `ireturn` | `int` (e também `boolean`, `byte`, `char`, `short`) |
| `lreturn` | `long` |
| `freturn` | `float` |
| `dreturn` | `double` |
| `areturn` | referência |
| `return` | **nada** (método `void`) |

- Se **nenhum valor for retornado** (método `void`), executa-se **apenas `return`**.
- O **frame do método chamador torna-se o corrente**, restaurando o contexto do chamador:
  suas **variáveis locais**, sua **pilha de operandos**, e o **PC é atualizado para
  apontar para a instrução seguinte à invocação** do método chamado.
- A execução **continua no frame do método chamador**, com o **valor retornado (se
  existente) empilhado na pilha de operandos desse frame**.

```
 ANTES do ireturn                      DEPOIS do ireturn
 ┌──────────────────────┐              ┌──────────────────────┐
 │ frame de soma()      │ ◄ corrente   │ (descartado)         │
 │  op.stack: [ 7 ]     │              └──────────────────────┘
 ├──────────────────────┤              ┌──────────────────────┐
 │ frame de main()      │              │ frame de main()      │ ◄ corrente
 │  op.stack: [ ]       │              │  op.stack: [ 7 ]     │
 │  PC → invokestatic   │              │  PC → próxima instr. │
 └──────────────────────┘              └──────────────────────┘
```

### 5.8 Término abrupto de método

**Término abrupto** ocorre se a execução do método provocar o **lançamento de uma
exceção que não é manipulada dentro do próprio método**.

- Um método que termina abruptamente **não pode retornar um valor** para o método
  chamador.
- **O processamento é encerrado** (o frame é descartado e a exceção é propagada para o
  frame do chamador, que por sua vez pode tratá-la ou propagá-la — se ninguém tratar, a
  thread termina).

> ⚠️ **Pegadinha de prova**
> "Um método que lança exceção retorna `null` ao chamador" → **FALSO**: ele **não retorna
> valor algum**. O que o chamador recebe é a **exceção**, não um valor na pilha de
> operandos. Note ainda: a pilha de operandos do frame que trata a exceção é
> **esvaziada** e recebe apenas a referência ao objeto da exceção.

### 5.9 Informação adicional

- Um frame **pode ser estendido com informação adicional específica** da implementação,
  tal como **informação de depuração (debug)** — por exemplo, tabelas de número de linha
  (`LineNumberTable`) e de variáveis locais (`LocalVariableTable`), usadas para produzir
  *stack traces* legíveis e para depuradores.

---

## 6. Representação de objetos

- **A especificação da Oracle não determina nenhuma estrutura interna particular para
  representar objetos.** Cada implementação é livre.
- Na **implementação da Sun** para a JVM (modelo *handle*):
  - uma **referência para uma instância de classe é um ponteiro para um *handler*
    (handle)**, que é um **par de ponteiros**:
    1. um ponteiro para uma **tabela contendo os métodos do objeto**, e, junto,
       um ponteiro para a **classe que representa o tipo do objeto**;
    2. o outro ponteiro é para a **memória alocada para os dados do objeto** (os fields
       da instância).

```
  variável de referência          HANDLE (par de ponteiros)
  ┌───────────┐                  ┌───────────────────────┐
  │  obj  ●───┼─────────────────►│ ptr → tabela de       │──┐
  └───────────┘                  │       métodos         │  │
                                 ├───────────────────────┤  │
                                 │ ptr → dados do objeto │──┼──┐
                                 └───────────────────────┘  │  │
                                                            │  │
        ┌───────────────────────────────────────────────────┘  │
        ▼                                                      ▼
  TABELA DE MÉTODOS (área de métodos)               DADOS DO OBJETO (heap)
  ┌────────────────────────────┐                    ┌──────────────────┐
  │ ● → código de metodoA()    │                    │ field x = 10     │
  │ ● → código de metodoB()    │                    │ field y = 20     │
  │ ● → ponteiro para a CLASSE │───► objeto Class   │ field color = 1  │
  └────────────────────────────┘     (tipo do obj.) └──────────────────┘
```

**Vantagem** do handle: o coletor de lixo pode **mover os dados do objeto** no heap
atualizando apenas **um** ponteiro (o do handle), sem varrer todas as referências.
**Desvantagem**: **dupla indireção** a cada acesso a um field — por isso as JVMs modernas
(HotSpot) **não** usam handles: a referência aponta **diretamente** para o objeto, que
carrega em seu cabeçalho (*mark word* + *klass pointer*) a informação de tipo.

> ⚠️ **Pegadinha de prova**
> "A especificação da JVM define como os objetos devem ser representados na memória" →
> **FALSO**. O modelo de *handle* descrito é **uma escolha de implementação da Sun**, não
> uma exigência da especificação.

---

## 7. Ponto flutuante e o padrão IEEE 754 em Java

Java implementa um **subconjunto do padrão IEEE 754-1985**.

- **Ponto flutuante em Java não lança exceções, não gera traps e não sinaliza erros**
  para as condições clássicas do 754:
  - **operador inválido**, **divisão por zero**, **overflow**, **underflow**;
  - **não sinaliza a ocorrência de `NaN`**.
  - Em vez disso, produz valores especiais: `Infinity`, `-Infinity`, `NaN`.

```java
double a = 1.0 / 0.0;    // Infinity  (NÃO lança exceção!)
double b = 0.0 / 0.0;    // NaN       (NÃO lança exceção!)
int    c = 1 / 0;        // ArithmeticException (aritmética INTEIRA lança!)
System.out.println(Double.NaN == Double.NaN);  // false
```

#### Modos de ponto flutuante

| Modo | Como funciona | Consequência |
|------|---------------|--------------|
| **FP-strict** (`strictfp`) | Usa a norma **IEEE 754** para `float` (32 bits) e `double` (64 bits) | **Garante o mesmo resultado independentemente do processador** (portabilidade total) |
| **non FP-strict** | Usa **float-extended-exponent** e **double-extended-exponent** (faixa de expoente estendida, ex.: registradores x87 de 80 bits) | **Sem arredondamento intermediário** se usar 80 bits; o **valor pode ser diferente** do obtido com IEEE 754 estrito |

**Tendência:** usar **FP-strict**, para garantir o mesmo resultado em qualquer máquina,
com uso da norma IEEE 754.

> 🟪 **Posterior ao Java 8** — a partir do **Java 17** (JEP 306), **todo** ponto flutuante voltou a
> ser estrito por padrão e `strictfp` tornou-se redundante. **No Java 8, que é o que cai nesta prova,
> a distinção FP-strict × non-FP-strict ainda vale**: sem `strictfp`, a JVM pode usar registradores
> de expoente estendido (x87 de 80 bits) e produzir resultado diferente do IEEE 754 puro.

> ⚠️ **Pegadinha de prova**
> - "Divisão por zero em ponto flutuante lança `ArithmeticException`" → **FALSO** (produz
>   `Infinity`/`NaN`). Em **inteiros**, sim, lança `ArithmeticException`.
> - "`NaN == NaN` é verdadeiro" → **FALSO**.
> - "Java sinaliza overflow/underflow de ponto flutuante" → **FALSO**.
> - O modo **non FP-strict** pode dar resultados **mais precisos**, mas **não
>   reprodutíveis** entre plataformas — é exatamente por isso que se prefere FP-strict.

---

## 8. Palavras-chave da linguagem Java

**Palavra-chave = não pode ser usada como identificador** (nome de variável, classe,
método…).

| | | | | |
|---|---|---|---|---|
| `abstract` | `continue` | `for` | `new` | `switch` |
| `assert` | `default` | `if` | `package` | `synchronized` |
| `boolean` | `do` | `goto` | `private` | `this` |
| `break` | `double` | `implements` | `protected` | `throw` |
| `byte` | `else` | `import` | `public` | `throws` |
| `case` | `enum` | `instanceof` | `return` | `transient` |
| `catch` | `extends` | `int` | `short` | `try` |
| `char` | `final` | `interface` | `static` | `void` |
| `class` | `finally` | `long` | `strictfp` | `volatile` |
| `const` | `float` | `native` | `super` | `while` |

Observações do material:

- **`const` e `goto` são palavras-chave reservadas, mas não estão implementadas
  atualmente.** Existem apenas para dar mensagens de erro melhores a quem vem de C/C++.
- **`true`, `false` e `null` são literais (constantes), NÃO são palavras-chave** — mas
  ainda assim **não podem** ser usados como identificadores.
- `assert`:
  ```java
  assert exprBooleana : <mensagem>;
  ```
  Se a expressão booleana for **falsa**, o processamento é encerrado (lança
  `AssertionError` com a mensagem). Asserções precisam ser habilitadas com `-ea`.

> ⚠️ **Pegadinha de prova**
> A pergunta "quantas/quais destas são palavras-chave?" costuma incluir `true`, `false`,
> `null` (literais) e `main`, `String`, `System`, `length`, `args` (identificadores
> comuns, **não** reservados). Também vale lembrar que `goto` e `const` **são**
> reservadas apesar de não fazerem nada.

---

## 9. Métodos especiais: `<init>` e `<clinit>`

Dois métodos existem apenas no nível da JVM, com nomes **impronunciáveis** em Java
(contêm `<` e `>` justamente para não colidirem com identificadores válidos).

| | `<init>` | `<clinit>` |
|---|---|---|
| Nome completo | *instance initialization method* | *class or interface initialization method* |
| Origem em Java | **construtores** + blocos de inicialização de instância + inicializadores de fields de instância | blocos `static { }` + inicializadores de fields `static` |
| Quantos por classe | **vários** (um por construtor, distinguidos pela **assinatura**) | **no máximo um** |
| Argumentos | os do construtor | **nenhum** |
| Retorno | **nenhum** (void) | **nenhum** (void) |
| Quem chama | a JVM, via **`invokespecial`** | a **JVM**, na iniciação da classe |
| Pode ser chamado por código Java? | **NÃO** | **NÃO** |
| Quando executa | ao **instanciar** um objeto (`new`) | **antes de tudo**, uma **única vez**, na iniciação da classe |

### 9.1 `<init>` — iniciação de instância

- O **método construtor**, que tem o **mesmo nome da classe** em Java, é **mapeado no
  arquivo `.class` para `<init>`**.
- É **executado quando um objeto dessa classe é instanciado**.
- **Não pode ser chamado em um programa Java** (você não escreve `obj.<init>()`; escreve
  `new Classe(...)`).
- **Se houver mais de um construtor**, ao executar um deles, ele **deve chamar outro**
  construtor (`this(...)`) ou o da superclasse (`super(...)`).
  - Os construtores são **identificados por possuírem assinaturas diferentes**
    (sobrecarga) — no `.class` todos se chamam `<init>`, diferindo pelo **descritor**.
- **Não pode retornar um valor.**
- **Não pode ter o modificador `static` nem `strictfp`.**
- É chamado **via a instrução `invokespecial`** durante a execução na JVM.

#### Exemplo do slide 29

```java
class Point {
    int x, y;
    Point(int x, int y) { this.x = x; this.y = y; }
}

class ColoredPoint extends Point {
    static final int WHITE = 0, BLACK = 1;
    int color;

    ColoredPoint(int x, int y) {
        this(x, y, WHITE);          // chama OUTRO construtor da MESMA classe
    }

    ColoredPoint(int x, int y, int color) {
        super(x, y);                // chama o construtor da SUPERCLASSE
        this.color = color;
    }
}
```

O que isso vira no `.class`:

| Em Java | No `.class` | Descritor |
|---------|-------------|-----------|
| `Point(int, int)` | `<init>` | `(II)V` |
| `ColoredPoint(int, int)` | `<init>` | `(II)V` |
| `ColoredPoint(int, int, int)` | `<init>` | `(III)V` |

Sequência ao executar `new ColoredPoint(3, 4)`:

```
 new ColoredPoint(3,4)
      │
      ├─ new          → aloca o objeto no HEAP (fields zerados), empilha a referência
      ├─ dup          → duplica a referência (uma para <init>, outra para o resultado)
      ├─ invokespecial ColoredPoint.<init>:(II)V
      │      └─ invokespecial ColoredPoint.<init>:(III)V   ← this(x, y, WHITE)
      │             └─ invokespecial Point.<init>:(II)V    ← super(x, y)
      │                    └─ invokespecial Object.<init>:()V
      │                    └─ this.x = x; this.y = y;
      │             └─ this.color = color;
      └─ astore  → guarda a referência na variável local
```

Repare: `WHITE` é `static final int` → é uma **constante de compilação**, resolvida a
partir do **pool de constantes** (o compilador normalmente embute o valor `0` com
`iconst_0`).

> ⚠️ **Pegadinha de prova**
> - "`<init>` pode ser `static`" → **FALSO** (ele precisa do `this`, que fica no índice 0
>   das variáveis locais!).
> - "`<init>` é invocado por `invokevirtual`" → **FALSO**: é **`invokespecial`**
>   (justamente porque **não** há despacho polimórfico em construtores).
> - "Construtores são herdados" → **FALSO**. Cada classe tem os seus; a cadeia é
>   percorrida via `super()`.
> - Se você não escrever nenhum construtor, o compilador gera um `<init>` **padrão sem
>   argumentos** que chama `super()`.

### 9.2 `<clinit>` — iniciação de classe

- O "método construtor de classe" é mapeado no arquivo `.class` para **`<clinit>`**.
- É utilizado para **inicializar fields `static` e blocos declarados `static`**.
- **Não pode ser chamado em um programa Java.**
- **Só pode existir um `<clinit>` por classe.**
- **Não tem argumentos e não retorna nenhum valor.**
- **Se existir, é o primeiro método a ser executado** (antes de `main`, antes de qualquer
  construtor, antes de qualquer acesso a membro estático da classe).
- A JVM garante que `<clinit>` executa **uma única vez** e de forma **thread-safe**.

#### Exemplo do slide 31

```java
class static_test {
    static int    a = -1;
    static double b = -2.0;

    public static void main(String argv[]) {
        System.out.println(a);   // -1
        System.out.println(b);   // -2.0
        a = 3;
        System.out.println(a);   // 3
    }
}
```

As atribuições `a = -1` e `b = -2.0` **não estão em nenhum método escrito por você** —
o compilador as coloca no **`<clinit>`** gerado:

```
 static_test.<clinit>()V
    iconst_m1
    putstatic  static_test.a : I
    ldc2_w     -2.0d            ← double vem do pool com ldc2_w (2 slots!)
    putstatic  static_test.b : D
    return
```

Saída do programa: `-1`, `-2.0`, `3`.

> ⚠️ **Pegadinha de prova**
> - "Uma classe pode ter dois blocos `static { }`" → **VERDADEIRO** em Java, mas eles são
>   **concatenados, na ordem textual, em um único `<clinit>`**.
> - "`<clinit>` recebe argumentos" → **FALSO**.
> - "`main` é o primeiro método executado" → **FALSO**, se houver `<clinit>`: a iniciação
>   da classe vem antes.
> - Fields `static final` de tipo primitivo/String com valor constante podem ser
>   resolvidos **em tempo de compilação** (ficam como `ConstantValue` no pool) e **nem
>   aparecem** no `<clinit>`.

### 9.3 Ordem de execução de blocos e construtores

Exemplo do slide 32 — **bloco estático é executado uma única vez!**

```java
class Foo extends Goo {
    static { System.out.println("1"); }   // bloco static de Foo
    { System.out.println("2"); }          // bloco de instância de Foo

    public Foo() { System.out.println("3"); }

    public static void main(String[] args) {
        System.out.println("4");
        Foo f = new Foo();
    }
}

class Goo {
    static { System.out.println("5"); }   // bloco static de Goo
    { System.out.println("6"); }          // bloco de instância de Goo
    Goo() { System.out.println("7"); }
}
```

**Saída: `5 1 4 6 7 2 3`**

| Ordem | Saída | Por quê |
|-------|-------|---------|
| 1º | **5** | bloco `static` da **superclasse** (`Goo`) — `<clinit>` de `Goo` |
| 2º | **1** | bloco `static` da **classe** (`Foo`) — `<clinit>` de `Foo` |
| 3º | **4** | execução de `main` |
| 4º | **6** | `new Foo()` → cadeia até `Goo`: **bloco de instância de `Goo`** |
| 5º | **7** | **construtor de `Goo`** |
| 6º | **2** | **bloco de instância de `Foo`** |
| 7º | **3** | **construtor de `Foo`** |

Regras que esse exemplo destila:

```
  1. INICIAÇÃO DE CLASSE (<clinit>) — uma única vez, de cima para baixo na hierarquia:
        super.<clinit>  →  sub.<clinit>
        (dentro de cada uma: fields static + blocos static, na ordem textual)

  2. main() (ou o que for disparar a instanciação)

  3. INICIAÇÃO DE INSTÂNCIA (<init>) — a cada `new`, também de cima para baixo:
        para cada classe, da superclasse para a subclasse:
            blocos de instância + inicializadores de fields de instância
            corpo do construtor
```

> ⚠️ **Pegadinha de prova**
> - Blocos **`static`** rodam **uma única vez**, na **iniciação da classe**; blocos de
>   **instância** rodam **a cada `new`**.
> - Dentro de um `<init>`, os **blocos de instância e inicializadores de fields rodam
>   ANTES do corpo do construtor** (mas **depois** do `super(...)`).
> - Se `new Foo()` fosse chamado duas vezes, a saída seria `5 1 4 6 7 2 3 6 7 2 3` — os
>   `static` **não repetem**.
> - A superclasse é sempre iniciada **antes** da subclasse, tanto em `<clinit>` quanto em
>   `<init>`.

---

## 10. Instruções da JVM citadas nesta parte

Tabela consolidada de todos os bytecodes que aparecem nos slides, com o efeito na pilha
na notação `(antes → depois)`:

| Instrução | Operandos (bytes após o opcode) | Efeito na pilha | Descrição |
|-----------|--------------------------------|-----------------|-----------|
| `iadd` | — | `..., v1, v2 → ..., result` | soma dois `int` |
| `ladd` | — | `..., v1, v2 → ..., result` | soma dois `long` |
| `fadd` | — | `..., v1, v2 → ..., result` | soma dois `float` |
| `dadd` | — | `..., v1, v2 → ..., result` | soma dois `double` |
| `jsr` | `branchbyte1..2` | `... → ..., address` | salta para sub-rotina, empilha `returnAddress` |
| `jsr_w` | `branchbyte1..4` | `... → ..., address` | idem, com índice largo |
| `ret` | `index` (1 byte) | `... → ...` | retorna da sub-rotina usando a variável local `index` |
| `ldc` | `index` (1 byte, 1–255) | `... → ..., value` | empilha `int`, `float` ou ref. a string literal do CP |
| `ldc_w` | `indexbyte1..2` (1–65535) | `... → ..., value` | idem, índice de 2 bytes |
| `ldc2_w` | `indexbyte1..2` | `... → ..., value` | empilha `long` ou `double` do CP (2 slots) |
| `invokespecial` | `indexbyte1..2` | `..., objectref, args → ...` | invoca `<init>`, métodos privados e `super.m()` |
| `ireturn` | — | `..., value → [vazia]` | retorna `int` ao chamador |
| `lreturn` | — | `..., value → [vazia]` | retorna `long` |
| `freturn` | — | `..., value → [vazia]` | retorna `float` |
| `dreturn` | — | `..., value → [vazia]` | retorna `double` |
| `areturn` | — | `..., objectref → [vazia]` | retorna uma referência |
| `return` | — | `... → [vazia]` | retorna de método `void` |

Padrão de prefixos que vale memorizar:

| Prefixo | Tipo |
|---------|------|
| `i` | `int` |
| `l` | `long` |
| `f` | `float` |
| `d` | `double` |
| `a` | referência (*address*) |
| `b` | `byte`/`boolean` |
| `c` | `char` |
| `s` | `short` |

---

## 11. Resumo em 10 pontos

1. **A JVM é uma máquina abstrata especificada**, não um programa: define tipos, conjunto
   de instruções (bytecodes) e áreas de memória em tempo de execução. Muita coisa
   (representação de `null`, layout de objetos) é deixada a cargo da implementação.

2. **Os tipos da JVM não coincidem com os de Java**: a JVM possui o tipo `returnAddress`
   (usado por `jsr`/`jsr_w`/`ret`), que **não existe** na linguagem; e **não possui
   instruções próprias para `boolean`**, que é tratado como `int` na pilha e como `byte`
   em arrays.

3. **A JVM não faz checagem de tipo dinâmica**; quem é fortemente tipada com checagem
   **estática** é a linguagem Java. Valores primitivos **não têm tags**; o tipo é
   determinado pelo **opcode** (`iadd` × `ladd` × `fadd` × `dadd`).

4. **Áreas compartilhadas por todas as threads** (criadas na iniciação da JVM):
   **heap** (todos os objetos e arrays, coletados pelo GC, `-Xms`/`-Xmx`) e **área de
   métodos** (código, fields, dados de métodos e o **pool de constantes** por classe).

5. **Áreas privadas de cada thread** (criadas na criação da thread): **registrador PC**
   (endereço da instrução corrente; **indefinido** se o método corrente for nativo),
   **pilha da JVM** (frames, `-Xss`) e **pilha de métodos nativos** ("pilha C").

6. **Pool de constantes em runtime** = representação em memória da `constant_pool` do
   `.class`, construído na área de métodos por classe/interface; funciona como uma
   **tabela de símbolos**, guarda literais (inclusive valores `final`) e **referências
   simbólicas** a métodos e fields, resolvidas em tempo de execução. Acessado por índice
   (`ldc` 1 byte, `ldc_w`/`ldc2_w` 2 bytes; **índices começam em 1**).

7. **Um frame é criado a cada chamada de método** e destruído no término (normal ou
   abrupto). Cada frame tem: **vetor de variáveis locais**, **pilha de operandos** e uma
   **REFERÊNCIA ao pool de constantes** da classe do método corrente. **Só um frame é o
   corrente por thread**, e frames não são visíveis a outras threads.

8. **Vetor de variáveis locais**: acesso por **índice a partir de 0**; em métodos de
   instância e construtores o **índice 0 é `this`**, seguido dos parâmetros; em métodos
   **estáticos** o índice 0 é o **primeiro parâmetro**. **Slots de 32 bits**; `long` e
   `double` ocupam **2 slots acoplados** em **big-endian**. Tamanho (`max_locals`)
   definido em **tempo de compilação**.

9. **Pilha de operandos**: área de trabalho das instruções, **nasce vazia**, tamanho
   (`max_stack`) definido em **tempo de compilação**, slots de 32 bits. O valor de
   retorno de um método é entregue **empilhado na pilha de operandos do frame do
   chamador**; no **término abrupto** (exceção não tratada) **nenhum valor é retornado**.
   **Nem toda instrução usa a pilha** (`ret`, `goto`, `iinc`).

10. **Métodos especiais**: `<init>` (construtores, invocado por **`invokespecial`**, vários
    por classe, não pode ser `static`/`strictfp`, sem retorno) e `<clinit>` (fields e
    blocos `static`, **único**, sem argumentos nem retorno, **primeiro a executar**).
    Ordem de execução: `<clinit>` da superclasse → `<clinit>` da classe → `main` →
    (a cada `new`) blocos de instância e construtor da superclasse → blocos de instância e
    construtor da classe. No exemplo clássico: **5 1 4 6 7 2 3**.

---

## Apêndice — Este material e o Java SE 8

O PDF se chama `java-jvm8`, mas o texto dos slides vem da **2ª edição** da JVMS. O que mudou até o
**Java 8**:

| Tema | 2ª edição (o slide) | **JVMS 8 / Java 8** |
|---|---|---|
| Área de métodos | — | Implementação: PermGen até o 7, **Metaspace** no 8. A especificação não cita nenhuma das duas |
| Pool de strings | Na PermGen | No **heap**, desde o Java 7 |
| `jsr` / `jsr_w` / `ret` | Instruções normais (implementavam `finally`) | **Proibidas** em `major ≥ 51`. O **tipo `returnAddress` permanece** |
| Instruções de invocação | 4 | **5** — entrou `invokedynamic`, base das **lambdas** |
| Iniciação de classe (§5.5) | Inicia só as superclasses | \+ superinterfaces que declaram métodos **`default`** |
| Verificação | Inferência de tipos | **`StackMapTable`** (*type checking*) desde o `major` 50/51 |
| `strictfp` | Distinção FP-strict × non-FP-strict | **Continua valendo no Java 8** (só o Java 17 unificou — 🟪) |

**O que não mudou nada** — e é 90% do que a prova cobra: as áreas de dados em runtime e o que é por
thread × compartilhado, a anatomia do frame, `this` no índice 0, `long`/`double` em 2 slots, a
pilha de operandos, `<init>` × `<clinit>` e a ordem de iniciação.

🟥 **Independente de versão:** o slide trata o frame como se **contivesse** o pool de constantes (ele
contém uma **referência**, e o pool vive na área de métodos) e fala em slots de **32 bits** (a JVMS
não define o tamanho do slot; define que `long`/`double` ocupam **2**).

Detalhamento completo em [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).

---

*Bons estudos! Nas partes 2 e 3 da série: formato do arquivo `.class`, carregamento,
ligação e iniciação de classes, e o conjunto de instruções da JVM em detalhe.*
