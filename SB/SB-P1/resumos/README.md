# Software Básico (CIC0104 — UnB) — Resumo Geral Integrado: JVM e Java

> **Este é o documento da véspera.** Ele costura os sete resumos detalhados em um só fio,
> destaca o que precisa estar decorado, lista as pegadinhas mais prováveis e diz **o que
> responder** nos pontos em que o material do professor diverge da especificação oficial.
> Quando precisar de profundidade, siga os links — cada bloco aponta para o arquivo-fonte.
>
> 🔎 **Baseline de toda a revisão: Java SE 8** — JLS 8, JVMS 8, `.class` com `major_version = 52`.
> Os oito arquivos foram auditados contra essa versão e anotados com 🟦 (**divergência Java 8**),
> 🟪 (**posterior ao Java 8**, não cai) e 🟥 (**divergência com a especificação**, em qualquer versão).
> O apanhado está em [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).

---

## Sumário

1. [Índice do material](#1-índice-do-material)
2. [Mapa mental da matéria](#2-mapa-mental-da-matéria)
3. [O núcleo da matéria em 15 blocos](#3-o-núcleo-da-matéria-em-15-blocos)
4. [Folha de cola — todas as tabelas em um lugar](#4-folha-de-cola--todas-as-tabelas-em-um-lugar)
5. [As 25 pegadinhas mais prováveis](#5-as-25-pegadinhas-mais-prováveis)
6. [Divergências e pontos ambíguos](#6-divergências-e-pontos-ambíguos) — e o documento dedicado [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md)
7. [Plano de estudo de 3 dias](#7-plano-de-estudo-de-3-dias)

---

## 1. Índice do material

| Ordem | Arquivo | PDF de origem | Temas cobertos |
|:--:|---|---|---|
| **1º** | [java-conceitos.md](java-conceitos.md) | `java-conceitos.pdf` (21 slides) | Java × C; o que a JVM provê; máquina de pilha; threads/pilha/frames; vetor de locais; pilha de operandos; pool de constantes; tipos primitivos e IEEE 754; **as 7 categorias de variáveis**; nomes e pacotes; `Object`/`String`; classe abstrata × interface; diagrama da arquitetura da JVM; **carga → ligação → iniciação**; erros por fase |
| **2º** | [java-jvm8-1-3.md](java-jvm8-1-3.md) | `java-jvm8-1-3.pdf` (slides 1–32) | Tipos da JVM (incl. `returnAddress`); a JVM **não** faz checagem dinâmica de tipos; **áreas de dados em runtime** (por thread × compartilhadas) e suas exceções; **anatomia do frame**; ligação dinâmica; término normal × abrupto; representação de objetos; ponto flutuante/`strictfp`; palavras-chave; **`<init>` e `<clinit>`** e a ordem `5 1 4 6 7 2 3` |
| **3º** | [java-jvm8-2-3.md](java-jvm8-2-3.md) | `java-jvm8-2-3.pdf` (slides 33–65) | Laço do interpretador; opcode + operandos e **big-endian**; alinhamento e **`tableswitch`/`lookupswitch`**; prefixos de tipo; tabela-sumário `T`; mapeamento Java→JVM e **categorias 1 e 2**; `pop`/`pop2`/`swap`; carga e armazenamento; `wide`; constantes (`iconst`/`bipush`/`sipush`/`ldc`/`ldc2_w`); **aritmética** |
| **4º** | [java-jvm8-3-3.md](java-jvm8-3-3.md) | `java-jvm8-3-3.pdf` (slides 66–92) | Shift e lógicas bit a bit; `iinc`; **comparações** (`lcmp`, `fcmpl/g`, `if*`); **conversões** (`i2b`/`i2c`/`i2s`…); `new`/`newarray`/`anewarray`/`multianewarray`; `get/put` `static/field`; `?aload`/`?astore`/`arraylength`/`instanceof`/`checkcast`; `dup*`; desvios; **as 5 invocações e os retornos**; `athrow`, `monitorenter/exit`; **tabela completa de opcodes** |
| **5º** | [formato-class.md](formato-class.md) | `formato-class.pdf` (76 slides) | `.class` como stream de bytes; `u1/u2/u4/u8`; tabela × array; **descritores**; **estrutura `ClassFile`**; **pool de constantes e tags**; Modified UTF-8; `field_info`/`method_info`; **`access_flags`**; atributos (`ConstantValue`, `Code`, `exception_table`, `Exceptions`, `InnerClasses`, `LineNumberTable`, `LocalVariableTable`, `SourceFile`); HelloWorld em hexa; leitor em C |
| **6º** | [IBM-JavaBasico.md](IBM-JavaBasico.md) | `IBM-JavaBasico.pdf` (149 slides) | Linguagem Java: OO, pacotes/imports, construtores, tipos primitivos, casting, wrappers, `String`, **modificadores de acesso**, `Object`, `this`, operadores, arrays, **tabela "Todos os Modificadores"**, GC, `==` × `equals`, passagem de parâmetros, herança, override × overload, **abstratas e interfaces**, polimorfismo, `Collection`, exceções, threads |
| **7º** | [SB_Prova_Java.md](SB_Prova_Java.md) | `SB_Prova_Java.docx.pdf` | **Gabarito corrigido da prova anterior**: 22 objetivas comentadas + 4 discursivas (descritor `pandemia`, retorno de `long`, sequência `5146723`, `B[2] = (short)(B[2]-128)`), com o que o aluno errou e por quê |
| **8º** | [00-SIMULADO.md](00-SIMULADO.md) | — (gerado) | **44 objetivas + 8 discursivas** com gabarito comentado. É o fechamento do estudo |
| **★** | [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md) | — (gerado) | **Divergências com o Java SE 8.** Linha do tempo das versões; as 5 divergências que podem valer ponto; o que muda por ser o `IBM-JavaBasico.pdf` de **Java 1.4**; conteúdo posterior ao Java 8 a descartar; divergências com a especificação. **Leia junto com a seção 6 deste arquivo** |

**Ordem recomendada:** 1 → 2 → 5 → 3 → 4 → 6 → 7 → 8.
Racional: conceitos gerais primeiro, depois a estrutura de runtime, depois o **formato do arquivo**
(que dá nome a tudo: `max_stack`, `Code`, descritores), só então o conjunto de instruções em detalhe,
a linguagem Java, e por fim prova anterior + simulado. Se o tempo for curto, leia as seções
"O que você precisa saber para a prova" de cada arquivo e venha direto para as seções 4, 5 e 6 daqui.

**Regras da prova** (de [SB_Prova_Java.md](SB_Prova_Java.md) §1): respostas **V / F / NS**;
**duas erradas anulam uma certa**; **em branco conta como errada**; **toda resposta F exige
justificativa** (sem ela, não pontua). Consequência prática: **NS é melhor que chute**, e só responda
F se souber dizer **qual palavra** do enunciado o torna falso.

---

## 2. Mapa mental da matéria

Tudo nesta disciplina é **um único pipeline**. Saber em que caixa do desenho cada conceito mora
resolve metade das questões.

```
  Pessoa.java                      ┌──────────────────────────────────────────┐
  (texto, unidade de compilação)   │  o javac decide AQUI:                    │
        │                          │   • max_stack / max_locals               │
        │  javac                   │   • tableswitch × lookupswitch           │
        ▼                          │   • promoção de byte/short/char a int    │
  Pessoa.class ────────────────────┤   • <init> e <clinit> sintetizados       │
  (stream de bytes, big-endian,    │   • descritores e pool de constantes     │
   sem padding, 0xCAFEBABE)        └──────────────────────────────────────────┘
        │
        │   ClassFile{ magic, minor, major, constant_pool, access_flags,
        │              this_class, super_class, interfaces, fields,
        │              methods, attributes }
        ▼
 ┌─────────────────────────────── CLASS LOADER SUBSYSTEM ──────────────────────────────┐
 │  CARGA                LIGAÇÃO                                   INICIAÇÃO           │
 │  (Bootstrap,          Verificação → Preparação → Resolução      executa <clinit>    │
 │   Extension,          [VerifyError]  (defaults)  (símbolos)     super PRIMEIRO      │
 │   Application)                                    estática ×                        │
 │  [ClassFormatError,                               preguiçosa    [ExceptionIn-       │
 │   NoClassDefFoundError,                          [IllegalAccess- InitializerError]  │
 │   ClassCircularityError,                          Error, NoSuch-                    │
 │   UnsupportedClassVersionError]                   Method/FieldError,                │
 │                                                   InstantiationError]               │
 └───────────────────────────────────────┬─────────────────────────────────────────────┘
                                         ▼
 ┌─────────────────────────────── RUNTIME DATA AREAS ──────────────────────────────────┐
 │  COMPARTILHADO entre threads                │  POR THREAD (privado)                 │
 │  ┌───────────────────┐ ┌─────────────────┐  │  ┌──────────┐┌──────────┐┌─────────┐  │
 │  │       HEAP        │ │ ÁREA DE MÉTODOS │  │  │ reg. PC  ││ pilha da ││ pilha   │  │
 │  │ objetos + arrays  │ │ código, fields  │  │  │          ││   JVM    ││ nativa  │  │
 │  │ (GC; -Xms/-Xmx)   │ │ estáticos,      │  │  │ (indef.  ││ (frames; ││ ("C")   │  │
 │  │ [OutOfMemoryError]│ │ POOL DE CONST.  │  │  │ se nativo││  -Xss)   ││         │  │
 │  └───────────────────┘ └─────────────────┘  │  └──────────┘└────┬─────┘└─────────┘  │
 └───────────────────────────────────────────────────────────────┬─┴───────────────────┘
                                                                 ▼
                             FRAME (um por INVOCAÇÃO de método)
                    ┌───────────────────────────────────────────────────┐
                    │ vetor de variáveis locais [0][1][2]…  (max_locals) │
                    │    [0] = this (instância) | 1º param (static)      │
                    │ pilha de operandos (max_stack) — nasce VAZIA       │
                    │ ►► REFERÊNCIA ao pool de constantes (não o pool!)  │
                    └───────────────────────────────────────────────────┘
                                         │
                                         ▼
 ┌─────────────────────────────── EXECUTION ENGINE ────────────────────────────────────┐
 │  do { busca opcode (1 byte); busca operandos; executa; } while (!fim)               │
 │  carga/store · aritmética · shift/lógicas · conversão · objetos/arrays ·            │
 │  pilha (dup/pop/swap) · desvios · invocação/retorno · athrow · monitorenter/exit    │
 │                                                                                     │
 │  exceção → exception_table do Code do método corrente?                              │
 │      sim → PC = handler_pc (pilha esvaziada, só a exceção nela)                     │
 │      não → frame DESCARTADO, exceção repropagada ao CHAMADOR → … → thread morre     │
 └─────────────────────────────────────────────────────────────────────────────────────┘
```

**Três eixos que atravessam o desenho inteiro** (e que a prova adora cruzar):

```
 (a) COMPILAÇÃO × EXECUÇÃO   max_stack, max_locals, escolha do switch, promoção a int,
                             descritores  →  COMPILAÇÃO
                             resolução de símbolos, alocação de objetos, despacho
                             virtual, <clinit>  →  EXECUÇÃO

 (b) SÍMBOLO × ENDEREÇO      .class guarda REFERÊNCIAS SIMBÓLICAS (nome+descritor);
                             a ligação dinâmica as converte em referências concretas

 (c) CATEGORIA 1 × 2         long/double = 2 slots — repete-se em 3 lugares diferentes:
                             pool de constantes (2 índices), vetor de locais (2 slots)
                             e pilha de operandos (2 posições)
```

---

## 3. O núcleo da matéria em 15 blocos

### Bloco 1 — Formato `.class` e pool de constantes
→ [formato-class.md](formato-class.md) §2, §4, §5

Um `.class` contém **uma única classe ou interface** (não precisa ser pública), gravada como
**stream de bytes de 8 bits**, **big-endian**, **sem padding nem alinhamento**. Tudo é simbólico:
o arquivo referencia nomes e descritores **por índice** no `constant_pool`, que funciona como
**tabela de símbolos**. `constant_pool` é **tabela** (itens de tamanho variável ⇒ índice ≠ offset);
`interfaces[]`, `code[]` e `bytes[]` são **arrays** (tamanho fixo).

| Decore | Valor |
|---|---|
| `magic` | `0xCAFEBABE` (`u4`, primeiros 4 bytes) |
| Ordem física das versões | **`minor_version` ANTES de `major_version`** (mas escreve-se M.m) |
| `major_version` 52 | Java SE 8 (45=JDK1.1 … 49=SE5, 50=SE6, 51=SE7, 52=SE8) |
| `constant_pool_count` | nº de entradas **+ 1**; índices válidos `1 ≤ i < count`; **índice 0 inválido** |
| `Long`/`Double` no pool | ocupam **2 índices** (o `n+1` é inválido) |
| `super_class = 0` | só em `java.lang.Object` |
| Nome interno | `java/lang/Thread` (com `/`, **sem** `L` e **sem** `;`) |
| `attribute_length` | **não** conta os 6 bytes do cabeçalho; atributo ocupa `6 + length` |

```
00000000: cafe babe 0000 0034 001d 0a00 0600 0f09
          └magic──┘ └min┘ └maj┘ └cp_count=29→28 entradas┘
                          52=SE8   0A = tag 10 = Methodref #6.#15
```

---

### Bloco 2 — Descritores de tipo
→ [formato-class.md](formato-class.md) §3 · [SB_Prova_Java.md](SB_Prova_Java.md) Discursiva 1

Descritor é **a linguagem de tipos da JVM**: uma `CONSTANT_Utf8_info` que codifica o tipo de um
field ou a assinatura de um método. Lê-se **da esquerda para a direita, token a token, sem
separadores**: cada `[` consome o descritor seguinte e cada `L…;` só termina no `;`. **`V` só
aparece como retorno.** O descritor **não** guarda nomes de parâmetros nem modificadores
(`public`/`static` vivem em `access_flags`).

| `B` byte | `C` char | `D` double | `F` float | `I` int | `J` **long** | `S` short | `Z` **boolean** | `L<classe>;` ref | `[` 1 dimensão | `V` void (só retorno) |
|---|---|---|---|---|---|---|---|---|---|---|

Memotécnica: **`J` é long porque `L` já era referência; `Z` é boolean porque `B` já era byte.**

```java
Object mymethod(int i, double d, Thread t)  →  (IDLjava/lang/Thread;)Ljava/lang/Object;
void main(String[] args)                    →  ([Ljava/lang/String;)V
static double[] calcula(String, char[][], long) → (Ljava/lang/String;[[CJ)[D
construtor HelloWorld()                     →  ()V   (nome do método: <init>)
```

---

### Bloco 3 — Áreas de dados em runtime: por thread × compartilhadas
→ [java-jvm8-1-3.md](java-jvm8-1-3.md) §4 · [java-conceitos.md](java-conceitos.md) §10

A JVM tem áreas de **dois tempos de vida**: as criadas na **iniciação da JVM** e
**compartilhadas por todas as threads** (heap e área de métodos, com o pool de constantes dentro
dela), e as criadas **na criação de cada thread** e privadas dela (registrador PC, pilha da JVM,
pilha de métodos nativos). Classificar cada área é questão quase certa — e o erro clássico é
achar que objetos ficam na área de métodos ou que arrays ficam na pilha.

| Área | Escopo | Conteúdo | Exceções | Opção |
|---|---|---|---|---|
| **Heap** | compartilhado | **todos os objetos e arrays**; alvo do GC | `OutOfMemoryError` | `-Xms`/`-Xmx` |
| **Área de métodos** | compartilhada | por classe: **pool de constantes**, fields, **variáveis estáticas**, dados e **código** de métodos e construtores | `OutOfMemoryError` | — |
| **Registrador PC** | **por thread** | endereço da instrução corrente; **indefinido** se o método corrente for nativo | — | — |
| **Pilha da JVM** | **por thread** | os **frames** | `StackOverflowError`, `OutOfMemoryError` | `-Xss` |
| **Pilha de métodos nativos** | **por thread** | "pilha C"; **opcional**, formato da plataforma | `StackOverflowError`, `OutOfMemoryError` | — |

```
código de soma()      → área de métodos        objeto de new Pessoa() → heap
static int contador   → área de métodos        int idade (instância)  → heap (no objeto)
int[] v = new int[3]  → heap (a REFERÊNCIA v fica no frame)
```

---

### Bloco 4 — Anatomia do frame
→ [java-jvm8-1-3.md](java-jvm8-1-3.md) §5 · [java-conceitos.md](java-conceitos.md) §3.3–3.5

Um frame é criado **a cada invocação de método** (não por método, não na carga da classe) e
destruído no término, normal ou abrupto. Contém **três** coisas: vetor de variáveis locais,
pilha de operandos e uma **referência** ao pool de constantes da classe corrente — o pool **não**
está dentro do frame. Só **um** frame é o corrente por thread, e frames são **invisíveis a outras
threads**. Os tamanhos vêm do `.class` (`max_locals`, `max_stack`), fixados em **compilação**.

| | Vetor de variáveis locais | Pilha de operandos |
|---|---|---|
| Acesso | **por índice**, a partir de 0 | **LIFO**, só o topo |
| Tamanho | `max_locals` (compilação) | `max_stack` (compilação) |
| Estado inicial | `this` (se houver) + parâmetros | **vazia** |
| Slot | 32 bits (`long`/`double` = 2) | 32 bits (`long`/`double` = 2) |
| Papel | armazenamento indexado | área de trabalho + **passagem de retorno** |

```java
int deposita(int valor, long ref, Object quem) { int novo = 0; … }
// [0]=this  [1]=valor  [2..3]=ref (long!)  [4]=quem  [5]=novo
static int soma(int a, int b) { int r; … }     // [0]=a  [1]=b  [2]=r  (sem this!)
```

---

### Bloco 5 — Ciclo de vida da classe: carga, ligação, iniciação
→ [java-conceitos.md](java-conceitos.md) §11–12

`java Terminator args…` faz a JVM **tentar** executar `main`, **falhar** porque a classe não está
em memória, e então acionar o ClassLoader. A sequência é **Carga → Ligação (Verificação →
Preparação → Resolução) → Iniciação**, e só depois `main` roda. Na **preparação** os campos
estáticos recebem os **valores default**; os valores do código-fonte só chegam na **iniciação**
(`<clinit>`). A resolução pode ser **estática** (o mais cedo possível) ou **preguiçosa** (o mais
tarde possível).

| Fase | O que faz | Erros típicos |
|---|---|---|
| **Carga** | lê o binário, cria a representação interna | `ClassFormatError`, `UnsupportedClassVersionError`, `ClassCircularityError`, `NoClassDefFoundError` |
| **Ligação → Verificação** | código bem formado, tabela de símbolos, semântica da JVM | `VerifyError` |
| **Ligação → Preparação** | aloca código estático, tabelas de métodos, **defaults** das estáticas | — |
| **Ligação → Resolução** | referências simbólicas → concretas; carrega outras classes | `IllegalAccessError`, `InstantiationError`, `NoSuchFieldError`, `NoSuchMethodError` |
| **Iniciação** | executa `<clinit>`, **superclasses primeiro** | `ExceptionInInitializerError` |

Os três class loaders, em ordem de delegação: **Bootstrap** (`java.lang.*`, `rt.jar`) →
**Extension** (`jre/lib/ext`) → **Application** (classpath do usuário).
Todos os nomes acima terminam em **`Error`**, não em `Exception`.

---

### Bloco 6 — `<init>` × `<clinit>` e a ordem de iniciação
→ [java-jvm8-1-3.md](java-jvm8-1-3.md) §9 · [SB_Prova_Java.md](SB_Prova_Java.md) Discursiva 3

Dois métodos existem só no nível da JVM, com nomes **impronunciáveis em Java** (por isso nenhum
programa pode chamá-los). `<init>` é o construtor, invocado por **`invokespecial`**, um por
construtor declarado, distinguidos pelo **descritor**. `<clinit>` reúne **todos** os blocos
`static { }` e as iniciações de campos estáticos em **um único** método, sem argumentos e sem
retorno, executado **uma única vez** e **antes de tudo** naquela classe.

| | `<init>` | `<clinit>` |
|---|---|---|
| Origem | construtores + blocos `{ }` de instância + inicializadores de campos de instância | blocos `static { }` + inicializadores de campos `static` |
| Quantos | **vários** (um por construtor) | **no máximo um** |
| Argumentos / retorno | os do construtor / nenhum | **nenhum** / nenhum |
| Quem chama | `invokespecial` | **a própria JVM** |
| Quando | a cada `new` | na iniciação da classe, **uma vez** |

```java
class Foo extends Goo { static{print 1} {print 2} Foo(){print 3}
    main(){ print 4; new Foo(); } }
class Goo { static{print 5} {print 6} Goo(){print 7} }
// Saída: 5 1 4 6 7 2 3       (na prova de 21/2 veio como 5146723)
// Regra 1: <clinit> super → <clinit> sub → main   (uma única vez!)
// Regra 2: em cada <init>: super() → blocos de instância → corpo do construtor
// Um segundo new Foo() acrescenta só "6 7 2 3".
```

---

### Bloco 7 — Invocação e retorno de métodos
→ [java-jvm8-3-3.md](java-jvm8-3-3.md) §13 · [SB_Prova_Java.md](SB_Prova_Java.md) Discursiva 2

Na **chamada**, os argumentos saem da **pilha de operandos do chamador** e entram no **vetor de
variáveis locais do novo frame**; a `objectref` (o `this`) vai **por baixo** dos argumentos e
ocupa o índice 0 — exceto em `invokestatic`, que não tem `this`. No **retorno**, o valor sai da
**pilha de operandos do chamado**, o frame é descartado, o PC do chamador é restaurado para a
instrução **seguinte** ao `invoke*`, e o valor é **empilhado na pilha de operandos do chamador**.
**De pilha de operandos para pilha de operandos** — nunca pelo vetor de locais.

| Invocação | Opcode | Uso | | Retorno | Opcode |
|---|---|---|---|---|---|
| `invokevirtual` | 182 | método de instância, **despacho dinâmico** | | `ireturn` | 172 (`int`, **e boolean/byte/char/short**) |
| `invokespecial` | 183 | **`<init>`**, `private`, `super.m()` | | `lreturn` | 173 |
| `invokestatic` | 184 | método de classe (**sem `objectref`**) | | `freturn` | 174 |
| `invokeinterface` | 185 | método de interface | | `dreturn` | 175 |
| `invokedynamic` | 186 | lambdas / linguagens dinâmicas | | `areturn` / `return` | 176 / 177 (**sem prefixo**) |

```
 // retorno de um long:
 lreturn → desempilha o long (2 slots) do frame chamado
         → libera monitor se synchronized; descarta o frame inteiro
         → PC do chamador volta para depois do invoke*
         → empilha o long (2 slots) na pilha do CHAMADOR
         → só então um lstore_n move para variável local (ou pop2 se ignorado)
```

---

### Bloco 8 — Exceções e a `exception_table`
→ [formato-class.md](formato-class.md) §8.3–8.4 · [java-jvm8-3-3.md](java-jvm8-3-3.md) §14

O bloco `try` **não gera instrução nenhuma**: ele é apenas um **intervalo de PCs** registrado na
`exception_table`, que vive **dentro do atributo `Code`**. Ao lançar, `athrow` **esvazia a pilha de
operandos** do frame e deixa só a referência da exceção; a JVM procura um handler cujo intervalo
`[start_pc, end_pc)` contenha o PC atual e cujo tipo seja compatível. **Se não achar, o frame é
descartado e a exceção é repropagada ao chamador** — o programa **não** termina ali. Só quando a
pilha da thread se esgota é que **a thread** morre (e a JVM só encerra sem threads não-daemon).

| `exception_table[]` | Significado |
|---|---|
| `start_pc`, `end_pc` | região protegida, **`[start_pc, end_pc)`** — fim **exclusivo** |
| `handler_pc` | onde começa o `catch` |
| `catch_type` | índice p/ `CONSTANT_Class_info`, **ou 0 = `finally`** (pega tudo) |

**Não confundir:** `Exceptions` é um **atributo de `method_info`** e representa o **`throws`**;
a `exception_table` fica **dentro do `Code`** e representa `try/catch/finally`.

---

### Bloco 9 — Conjunto de instruções e prefixos de tipo
→ [java-jvm8-2-3.md](java-jvm8-2-3.md) §2–§9 · [java-jvm8-3-3.md](java-jvm8-3-3.md) §3–§4

O interpretador é o laço `busca opcode → busca operandos → executa` (descrito **ignorando
exceções**). O **opcode tem 1 byte** (≤ 256 instruções), e é por isso que o conjunto **não é
ortogonal**: o tipo está codificado no próprio mnemônico. Operandos multibyte são **big-endian**:
16 bits = `(b1<<8)|b2`. Todas as instruções são **alinhadas por byte, exceto `tableswitch` (0xAA) e
`lookupswitch` (0xAB)**, que inserem **0 a 3 bytes nulos** de padding.

| `i` int | `l` long | `f` float | `d` double | `a` **referência** | `b` byte | `c` char | `s` short |
|---|---|---|---|---|---|---|---|

| | `tableswitch` | `lookupswitch` |
|---|---|---|
| Campos | `default`, `low`, `high`, offsets | `default`, `npairs`, pares `<match><offset>` |
| Nº de entradas | **`high − low + 1`** (sem buracos) | `npairs` (pode ser **0**) |
| Busca | índice direto, O(1) | **ordenada por match**, busca binária O(log n) |
| Bom para | cases **densos** (`chooseNear`) | cases **esparsos** (`chooseFar`) |

**`target = offset + endereço do PRÓPRIO opcode do switch`.** A chave é sempre `int` e é
**desempilhada**. Quem escolhe entre os dois é o **compilador**, não a JVM.

```
Ordem dos operandos (fonte nº1 de erro):  ..., value1, value2 → ..., result
value1 é o mais FUNDO, value2 é o TOPO.   isub = value1 − value2 ;  idiv = value1 / value2
```

---

### Bloco 10 — `byte`, `char`, `short`, `boolean`: o tratamento especial
→ [java-jvm8-2-3.md](java-jvm8-2-3.md) §9–§10 · [java-jvm8-3-3.md](java-jvm8-3-3.md) §3, §9 · **ver também a seção 6 (divergências)**

Estes quatro tipos **existem** na JVM, mas têm **suporte limitado**: são **promovidos a `int`** ao
serem carregados e operados pelo conjunto `int`. `byte` e `short` promovem com **extensão de
sinal**; `char` e `boolean`, com **extensão de zero**. Não existe `badd`, `sadd`, `cadd`, nem
`bload`/`cload`, nem prefixo `z`. Os prefixos `b`, `c`, `s` sobrevivem **exatamente em três
lugares**, onde a largura real importa.

| Onde eles têm instrução própria | Instruções |
|---|---|
| **Acesso a arrays** | `baload`/`bastore` (byte **e boolean**), `caload`/`castore`, `saload`/`sastore` |
| **Conversões de estreitamento** | `i2b` e `i2s` (**com sinal**), `i2c` (**sem sinal**) |
| **Constantes imediatas** | `bipush` (−128…127), `sipush` (−32768…32767) — mas **empilham um `int`** |
| (+) criação de array | `newarray` com `atype`: `T_BOOLEAN`=4, `T_CHAR`=5, `T_BYTE`=8, `T_SHORT`=9 |

```java
byte b1=10, b2=20;  short c = b1 + b2;   // NÃO COMPILA: b1+b2 é int (não existe "badd")
short c2 = (short)(b1 + b2);             // OK → iadd + i2s
int i = 200;  byte b = (byte) i;         // i2b → −56 (trunca e estende COM sinal)
int j = -1;   char ch = (char) j;        // i2c → 65535 (estende SEM sinal)
```

---

### Bloco 11 — `long`/`double` e os 2 slots (categoria 2)
→ [java-jvm8-2-3.md](java-jvm8-2-3.md) §10–§11 · [formato-class.md](formato-class.md) §4.3

Os slots são de **32 bits**. `long` e `double` são de **categoria 2**: ocupam **dois slots
acoplados, em big-endian**, indexados pelo **primeiro** (o segundo não é endereçável sozinho — o
verificador rejeita `iload n+1`). Todo o resto — incl. `reference` e `returnAddress`, mesmo numa
JVM de 64 bits — é **categoria 1**. A mesma regra reaparece no **pool de constantes** (`Long`/
`Double` ocupam 2 índices) e na `LocalVariableTable` (`index` e `index+1`).

| Consequência | Detalhe |
|---|---|
| Carga de constante | `ldc`/`ldc_w` → `int`, `float`, `String`; **`ldc2_w` → `long`, `double`**. **Não existe `ldc2`** |
| Pilha | `pop` e `swap` só valem para **categoria 1**; `pop2` remove um cat-2 **ou** dois cat-1; **não existe `swap2`** |
| `dup2` | duplica **dois SLOTS** — se o topo for `double`, duplica **um único valor** |
| Comparação | `lcmp`/`fcmpl/g`/`dcmpl/g` consomem 4 slots e empilham **1 slot** (um `int` −1/0/1) |

```java
public double media(long soma, int n) { … }
// var0 = this ; var1+var2 = soma ; var3 = n    ← o int foi para var3, não var2!
```

---

### Bloco 12 — Objetos e arrays no heap
→ [java-jvm8-3-3.md](java-jvm8-3-3.md) §10 · [SB_Prova_Java.md](SB_Prova_Java.md) Q22

**Arrays são objetos** e vivem no **heap**, criados **em tempo de execução**; o que fica no frame é
sempre uma **referência**. `new` apenas **aloca e zera os fields** — o construtor é chamado à
parte, por `invokespecial`; daí o padrão **`new` + `dup` + `invokespecial`**. Para arrays existem
três instruções distintas, e `new` **não** serve para nenhuma delas.

| Instrução | Opcode | Operando | Cria | Valor inicial |
|---|---|---|---|---|
| `new` | 187 | índice 16 bits CP | instância de **classe** | defaults |
| `newarray` | 188 | **1 byte `atype`** (4…11) | array 1-D de **primitivo** | 0 / `false` |
| `anewarray` | 189 | índice 16 bits CP | array 1-D de **referências** | `null` |
| `multianewarray` | 197 | índice CP + `dimensions` | array **multidimensional** | `null` |

| Acesso | Pilha |
|---|---|
| `?aload` (0x32–0x39: `a,b,c,s,i,l,f,d`) | `…, arrayref, index → …, value` |
| `?astore` (0x4f–0x56: `i,l,f,d,a,b,c,s`) | `…, arrayref, index, value → …` |
| `arraylength` (190) | `…, arrayref → …, length` — **`length` não é field!** |
| `getfield`/`putfield` | `…, objectref → …, value` / `…, objectref, value → …` |
| `getstatic`/`putstatic` | **sem `objectref`**; podem **disparar o `<clinit>`** |

```java
Ponto p = new Ponto(3,4);
// new #2 ; dup ; iconst_3 ; iconst_4 ; invokespecial #3 <init>(II)V ; astore_1
```
`instanceof` empilha 0/1 e **nunca lança**; `checkcast` **deixa a referência** e lança
`ClassCastException`. `null instanceof X` = 0; `checkcast` com `null` **passa**.

---

### Bloco 13 — OO em Java: abstract, interface, static, final, herança
→ [IBM-JavaBasico.md](IBM-JavaBasico.md) §19, §23–§26 · [java-conceitos.md](java-conceitos.md) §8–§9

Java tem **herança simples de classes** (`extends`, uma só) e **múltipla de interfaces**
(`implements`, várias) — é assim que se **simula herança múltipla**, mas **nunca de estado**:
campos de interface são implicitamente `public static final`. Toda classe herda de `Object`, que
**tem** construtor. Classe abstrata **não pode ser instanciada**, mas **pode** ter métodos
concretos, atributos e construtor; **pode até não ter nenhum método abstrato** (veja a seção 6).

| | **Interface** | **Classe abstrata** |
|---|---|---|
| É classe? | **Não** ("representa uma ideia") | Sim |
| Métodos | só **abstratos** (no escopo do material) | abstratos **e** concretos |
| Atributos | só **constantes** `public static final` | quaisquer |
| Construtor | **não tem** | **tem** (via `super()`) |
| Instanciação | não | não |
| Quantidade | **várias** por classe | **uma** (`extends`) |

**Tabela "Todos os Modificadores" (slide 88 — mina de V/F):**

| Modificador | Classe | Atributo | Método | Construtor | Bloco livre |
|---|:--:|:--:|:--:|:--:|:--:|
| `public` | sim | sim | sim | sim | não |
| `protected` / `private` | **não** | sim | sim | sim | não |
| *(default)* | sim | sim | sim | sim | **sim** |
| `final` | sim | sim | sim | **não** | não |
| `abstract` | sim | **não** | sim | **não** | não |
| `static` | **não** | sim | sim | **não** | **sim** |
| `native` | não | não | **sim** | não | não |
| `transient` / `volatile` | não | **sim** | não | não | não |
| `synchronized` | não | não | **sim** | não | **sim** |

Ainda: construtor **não é herdado**; `super(...)`/`this(...)` são o **primeiro comando** e não
coexistem; métodos `static` sofrem **hiding**, não override; `private` **não é sobrescrito**;
atributos **não são polimórficos**; `abstract` e `final` são mutuamente exclusivos.

---

### Bloco 14 — Modificadores de acesso
→ [IBM-JavaBasico.md](IBM-JavaBasico.md) §12 · [formato-class.md](formato-class.md) §4.4, §6, §7

Quatro níveis, do mais restrito ao mais amplo: **`private` < default (pacote) < `protected`
(pacote + subclasses) < `public`**. `protected` é **mais permissivo** que default, não menos.
Uma **classe de topo** só aceita `public` ou default. No `.class`, tudo isso vira a **máscara de
bits `access_flags`**, combinada por OR — e a máscara da **classe** não tem `ACC_PRIVATE`,
`ACC_PROTECTED` nem `ACC_STATIC`.

| Acesso a partir de… | `private` | default | `protected` | `public` |
|---|:--:|:--:|:--:|:--:|
| Mesma classe | ✅ | ✅ | ✅ | ✅ |
| Mesmo pacote | ❌ | ✅ | ✅ | ✅ |
| Subclasse, outro pacote | ❌ | ❌ | ✅ | ✅ |
| Qualquer classe, outro pacote | ❌ | ❌ | ❌ | ✅ |

**Colisões de valor que caem em prova:** `ACC_SUPER` (classe) e `ACC_SYNCHRONIZED` (método) valem
os dois `0x0020`; `ACC_VOLATILE` (campo) e `ACC_BRIDGE` (método) valem `0x0040`; `ACC_TRANSIENT` e
`ACC_VARARGS` valem `0x0080`.
`public class HelloWorld` → `0x0021` (`ACC_PUBLIC|ACC_SUPER`); `public interface I` → `0x0601`
(`PUBLIC|INTERFACE|ABSTRACT` — toda interface é obrigatoriamente abstrata).

---

### Bloco 15 — Java × C e tempo real
→ [java-conceitos.md](java-conceitos.md) §2 · [SB_Prova_Java.md](SB_Prova_Java.md) Q15

A sintaxe de Java vem de C, mas a gerência de memória separa as duas. Java tem **coletor de lixo**
(fácil e seguro, mas com **tempo não determinístico**) e **referências tipadas**; C tem heap
manual (**mais eficiente**, **determinístico**, mas permite **referência pendente**) e **ponteiros
tipados**. Conclusão do slide, que é a resposta esperada: **Java NÃO é indicada para tempo real**;
C é. Existência de portes (JavaCard, Java ME) **não** implica determinismo.

| Aspecto | **Java** | **C** |
|---|---|---|
| Tipo lógico | tem `boolean` | "sem tipos lógicos" (usa `int`) |
| Heap | **automático (GC)** | **a cargo do programador** |
| Eficiência | menor | **maior** |
| Referência pendente | **não permite** | **permite** |
| Acesso indireto | **referências tipadas** | **ponteiros tipados** |
| Determinismo / tempo real | **não determinístico / não indicada** | **determinístico / indicada** |

Fontes de não determinismo em Java: **pausas do GC**, **compilação JIT**, **carga preguiçosa de
classes** e o **escalonamento de threads**. Para tempo real duro existe a **RTSJ (JSR-1)**, que
**não** é o Java padrão. Também: `char` em Java tem **2 bytes sem sinal** (Unicode), não 1 como em C;
tamanhos de tipos são **fixos pela especificação**, não dependem da plataforma.

---

## 4. Folha de cola — todas as tabelas em um lugar

### 4.1 Estrutura `ClassFile` (16 campos, nesta ordem)

```c
ClassFile {
    u4 magic;                  // 0xCAFEBABE
    u2 minor_version;          // MINOR VEM ANTES
    u2 major_version;          // 52 = Java SE 8
    u2 constant_pool_count;    // nº de entradas + 1
    cp_info constant_pool[constant_pool_count-1];   // ← o ÚNICO com "-1"
    u2 access_flags;
    u2 this_class;             // → CONSTANT_Class_info
    u2 super_class;            // → CONSTANT_Class_info, ou 0 (só em Object)
    u2 interfaces_count;  u2 interfaces[interfaces_count];   // só as DIRETAS
    u2 fields_count;      field_info  fields[fields_count];  // só os DECLARADOS
    u2 methods_count;     method_info methods[methods_count];// só os DECLARADOS
    u2 attributes_count;  attribute_info attributes[attributes_count];
}
field_info / method_info { access_flags; name_index; descriptor_index;
                           attributes_count; attributes[]; }   // MESMA forma!
attribute_info { u2 attribute_name_index; u4 attribute_length; u1 info[]; }
```

### 4.2 Tags do pool de constantes

| Utf8 | Integer | Float | Long | Double | Class | String | Fieldref | Methodref | InterfaceMethodref | NameAndType | MethodHandle | MethodType | InvokeDynamic |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **1** | **3** | **4** | **5** | **6** | **7** | **8** | **9** | **10** | **11** | **12** | **15** | **16** | **18** |

**Não existem as tags 2, 13, 14 e 17.** `Long`(5) e `Double`(6) ocupam **2 índices**.
`Class` tem **um** índice (`name_index`); `Fieldref`/`Methodref`/`InterfaceMethodref`/`NameAndType`
têm **dois**. `Utf8`: `length` é em **bytes**, **sem `\0`**, em **Modified UTF-8** (1, 2 ou 3 bytes;
**nunca 4**; `\u0000` vira `0xC0 0x80`; suplementares = 6 bytes).

### 4.3 Códigos de descritor

`B`=byte · `C`=char · `D`=double · `F`=float · `I`=int · **`J`=long** · `S`=short · **`Z`=boolean**
· `L<classe>;`=referência · `[`=uma dimensão · **`V`=void (só retorno)**
Forma: `( params sem separadores ) retorno`.

### 4.4 `access_flags`

| Flag | Valor | Classe | Campo | Método |
|---|:--:|:--:|:--:|:--:|
| `ACC_PUBLIC` | 0x0001 | ✔ | ✔ | ✔ |
| `ACC_PRIVATE` | 0x0002 | — | ✔ | ✔ |
| `ACC_PROTECTED` | 0x0004 | — | ✔ | ✔ |
| `ACC_STATIC` | 0x0008 | — | ✔ | ✔ |
| `ACC_FINAL` | 0x0010 | ✔ | ✔ | ✔ |
| `ACC_SUPER` / `ACC_SYNCHRONIZED` | 0x0020 | ✔ (SUPER) | — | ✔ (SYNCHRONIZED) |
| `ACC_VOLATILE` / `ACC_BRIDGE` | 0x0040 | — | ✔ (VOLATILE) | ✔ (BRIDGE) |
| `ACC_TRANSIENT` / `ACC_VARARGS` | 0x0080 | — | ✔ (TRANSIENT) | ✔ (VARARGS) |
| `ACC_NATIVE` | 0x0100 | — | — | ✔ |
| `ACC_INTERFACE` | 0x0200 | ✔ | — | — |
| `ACC_ABSTRACT` | 0x0400 | ✔ | — | ✔ |
| `ACC_STRICT` | 0x0800 | — | — | ✔ |
| `ACC_SYNTHETIC` | 0x1000 | ✔ | ✔ | ✔ |
| `ACC_ANNOTATION` / `ACC_ENUM` | 0x2000 / 0x4000 | ✔ | ✔ (ENUM) | — |

### 4.5 Atributos: onde aparecem e obrigatoriedade

| Atributo | ClassFile | field_info | method_info | Code | `attribute_length` | Obrigatório |
|---|:--:|:--:|:--:|:--:|---|---|
| `ConstantValue` | | ✔ | | | **2** | **sim** |
| `Code` | | | ✔ | | variável | **sim** |
| `Exceptions` (= `throws`) | | | ✔ | | variável | **sim** |
| `InnerClasses` | ✔ | | | | variável | sim (Java 2+) |
| `Synthetic` | ✔ | ✔ | ✔ | | **0** | sim (Java 2+) |
| `Deprecated` | ✔ | ✔ | ✔ | | **0** | opcional |
| `SourceFile` | ✔ | | | | **2** | opcional |
| `LineNumberTable` / `LocalVariableTable` | | | | ✔ | variável | opcional |

`Code_attribute { …, max_stack(u2), max_locals(u2), code_length(u4), code[],
exception_table_length(u2), {start_pc,end_pc,handler_pc,catch_type}[], attributes[] }`.
**Métodos `native` e `abstract` NÃO têm `Code`**; quando existe, `code_length > 0`.
`ConstantValue` só vale para campo **`static`**; em campo **não estático é ignorado em silêncio**.

### 4.6 Áreas de runtime

| Compartilhadas (criadas na iniciação da JVM) | Por thread (criadas com a thread) |
|---|---|
| **Heap** (objetos e arrays) | **Registrador PC** |
| **Área de métodos** (código, estáticos, **pool de constantes**) | **Pilha da JVM** (frames) |
| | **Pilha de métodos nativos** |

### 4.7 Prefixos e famílias de instruções

| Template | byte | short | int | long | float | double | char | reference |
|---|---|---|---|---|---|---|---|---|
| `Tipush` | `bipush` | `sipush` | | | | | | |
| `Tconst` | | | `iconst` | `lconst` | `fconst` | `dconst` | | `aconst_null` |
| `Tload` / `Tstore` | | | `iload`/`istore` | `l…` | `f…` | `d…` | | `a…` |
| `Taload`/`Tastore` | `baload` | `saload` | `iaload` | `laload` | `faload` | `daload` | `caload` | `aaload` |
| `Tadd`…`Tneg` | — | — | `iadd`… | `ladd`… | `fadd`… | `dadd`… | — | — |
| `Tshl/shr/ushr`, `Tand/or/xor` | | | ✔ | ✔ | | | | |
| `Tinc` | | | **só `iinc`** | | | | | |
| `i2T` | `i2b` | `i2s` | | `i2l` | `i2f` | `i2d` | (`i2c`) | |
| `Tcmp` | | | — | `lcmp` | `fcmpl/g` | `dcmpl/g` | | — |
| `if_TcmpOP` | | | `if_icmpOP` | | | | | `if_acmpOP` |
| `Treturn` | | | `ireturn` | `lreturn` | `freturn` | `dreturn` | | `areturn` |

**Célula vazia = a instrução não existe.** Não existe `dconst_2`, `lconst_2`, `ldc2`, `iushl`,
`inot`, `linc`, `icmp`, `if_acmplt`, `b2i`, `d2b`, `swap2`, `vreturn`.

**Opcodes que vale reconhecer:** `iadd`=0x60 (blocos de 4, ordem **i, l, f, d**: `sub` 0x64,
`mul` 0x68, `div` 0x6c, `rem` 0x70, `neg` 0x74) · `iinc`=0x84 · `lcmp`=0x94 · `ifeq`…`ifle`=0x99–0x9e
(ordem **eq, ne, lt, ge, gt, le**) · `if_icmp*`=0x9f–0xa4 · `goto`=0xa7 · `tableswitch`=0xaa ·
`lookupswitch`=0xab · retornos 0xac–0xb1 · `getstatic`…`invokedynamic`=0xb2–0xba · `new`=0xbb ·
`newarray`=0xbc · `anewarray`=0xbd · `arraylength`=0xbe · `athrow`=0xbf · `checkcast`=0xc0 ·
`instanceof`=0xc1 · `monitorenter/exit`=0xc2/0xc3 · `wide`=0xc4 · `multianewarray`=0xc5.
**Reservados pela Sun/Oracle:** `breakpoint` (0xca), `impdep1` (0xfe), `impdep2` (0xff).

### 4.8 Mapeamento Java → JVM e categorias

`boolean`, `byte`, `char`, `short`, `int` → **`int`** (cat. 1) · `float` → `float` (1) ·
`reference` → `reference` (1) · **`returnAddress`** → (1, **sem correspondente em Java**) ·
`long` → `long` (**2**) · `double` → `double` (**2**).

### 4.9 Valores default (nunca para variáveis locais!)

`byte/short/int/long` → `0` · `float/double` → `0.0` · `char` → `'\u0000'` · `boolean` → `false`
· referência → `null`.

---

## 5. As 25 pegadinhas mais prováveis

| # | Afirmação | V/F | Justificativa em uma linha |
|:--:|---|:--:|---|
| 1 | O `.class` contém a definição de uma única classe **pública** ou interface | **F** | Uma classe ou interface **qualquer** — package-private, aninhada ou anônima também gera `.class`. *(Caiu: Q1)* |
| 2 | O campo `super_class` **sempre** contém índice válido para a superclasse | **F** | Vale **0** em `java.lang.Object`, a única classe sem superclasse. *(Caiu: Q4)* |
| 3 | Cada `method_info` inclui **as instruções** que implementam o método | **F** | Métodos **`native`** e **`abstract`** não têm atributo `Code`. *(Caiu: Q3)* |
| 4 | `ConstantValue` em campo **estático** deve ser ignorado em silêncio | **F** | É o contrário: em campo **não estático** é que se ignora; no estático o valor é usado na **preparação**. *(Caiu: Q11)* |
| 5 | Os tipos da JVM são os definidos na linguagem Java | **F** | A JVM tem **`returnAddress`**, que não existe em Java; e `boolean/byte/char/short` têm suporte limitado. *(Caiu: Q5)* |
| 6 | O frame contém a pilha de operandos, o vetor de locais e **o pool de constantes** | **F** | Contém uma **referência** ao pool; o pool mora na **área de métodos**, compartilhado. *(Caiu: Q6, com redação dos slides como V)* |
| 7 | No vetor de locais, o **primeiro parâmetro** está no índice 0 | **F** | Em método de instância/`<init>`, o índice 0 é **`this`**; só em `static` é o 1º parâmetro. *(Caiu: Q7)* |
| 8 | **Todo** bytecode executado usa a pilha de operandos | **F** | `iinc`, `goto`, `nop`, `ret`, `wide` não tocam a pilha. *(Caiu: Q8)* |
| 9 | A área de métodos armazena o pool, **objetos** e **atributos de instância** | **F** | Objetos e campos de instância ficam no **heap**; a área de métodos guarda estruturas **por classe**. *(Caiu: Q10)* |
| 10 | Sem manipulador no método corrente, **o programa é encerrado** | **F** | A exceção é **repropagada ao chamador**; só ao esgotar a pilha a **thread** morre. *(Caiu: Q14)* |
| 11 | A pilha de métodos nativos tem a **mesma estrutura** da pilha de frames | **F** | É uma **"pilha C"** da plataforma, dependente de implementação e **opcional**. *(Caiu: Q12)* |
| 12 | Arrays são alocados em **memória estática**, em compilação, via `new` | **F** | `new`/`newarray` alocam **no heap, em execução**; arrays são objetos. *(Caiu: Q22)* |
| 13 | Interfaces simulam herança múltipla herdando **atributos de instância** | **F** | Campos de interface são implicitamente `public static final` — **não há estado de instância**. *(Caiu: Q17)* |
| 14 | Classe abstrata é aquela em que **todos** os métodos são abstratos | **F** | O que a torna abstrata é o **modificador**; pode ter métodos concretos, construtor e **zero** abstratos. *(Caiu: Q16)* |
| 15 | Toda classe tem construtor, **exceto `Object`** | **F** | `Object` **tem** `public Object()`; o que ele não tem é **superclasse**. *(Caiu: Q18)* |
| 16 | `public final int tamanhoMaximo = 15;` define **atributo de classe** | **F** | Falta `static` — é **atributo de instância**, uma cópia por objeto. *(Caiu: Q20)* |
| 17 | Java é adequada a tempo real com resposta **determinística** | **F** | GC, JIT, carga preguiçosa e escalonamento tornam o tempo **não determinístico**. *(Caiu: Q15)* |
| 18 | `long` e `double` ocupam **dois** slots (locais, pilha) e **dois índices** no pool | **V** | São de **categoria 2** — a regra se repete nos três lugares. |
| 19 | Heap e área de métodos são **compartilhados**; PC, pilha da JVM e pilha nativa são **por thread** | **V** | É a classificação canônica das áreas de runtime. |
| 20 | O índice do pool começa em **1**; o do vetor de variáveis locais começa em **0** | **V** | `constant_pool_count` = entradas + 1 e o índice 0 é reservado a "nenhuma entrada". |
| 21 | `new` **executa o construtor** | **F** | `new` só aloca e zera; o `<init>` vem depois, por **`invokespecial`** (daí o `dup`). |
| 22 | `v.length` é compilado com `getfield` | **F** | Usa a instrução dedicada **`arraylength`**; `String.length()` é método (`invokevirtual`). |
| 23 | `tableswitch` serve para cases **esparsos** | **F** | Denso → `tableswitch` (índice direto); esparso → `lookupswitch` (pares ordenados). |
| 24 | Um método `synchronized` gera `monitorenter`/`monitorexit` | **F** | Usa a flag **`ACC_SYNCHRONIZED`**; as instruções só aparecem em **blocos** `synchronized(obj){}`. |
| 25 | `<clinit>` é executado **uma única vez**, sem argumentos e sem retorno, e o da **superclasse vem antes** | **V** | Vários blocos `static` são concatenados em um só `<clinit>`; nenhum código Java pode chamá-lo. |

> **Regra de ouro derivada da prova anterior:** desconfie de **"sempre"**, **"todo"**, **"nunca"**,
> **"apenas"** e **"não há"**. Na prova de 21/2, as questões 1, 3, 4, 8, 9 e 14 eram exatamente isso.
> E lembre: **basta uma parte falsa para a proposição inteira ser falsa** (foi assim na Q17).

---

## 6. Divergências e pontos ambíguos

Esta seção existe porque o material do professor às vezes **diverge da especificação** — e, pior,
às vezes **diverge de si mesmo** (prova anterior × simulado). Saber onde isso acontece vale pontos.

### 6.1 "Não há instruções JVM específicas para boolean, byte, char e short" — o caso crítico

**Esta questão já caiu (Q9 da prova de 21/2) e o aluno errou.** Existem duas leituras legítimas:

| Leitura | Resposta | Argumento |
|---|:--:|---|
| **Literal / ampla** ("instruções *específicas*") | **FALSO** | Existem, sim, instruções dedicadas: `baload`/`bastore`, `caload`/`castore`, `saload`/`sastore`, `i2b`/`i2c`/`i2s`, `bipush`/`sipush`, `newarray T_BOOLEAN/T_CHAR/T_BYTE/T_SHORT`. E os descritores `B`, `C`, `S`, `Z` existem no `.class`. |
| **Restrita** ("instruções *aritméticas*") | **VERDADEIRO** | Não existe `badd`, `sadd`, `cadd`, `zadd`, `bmul`, `csub`… Esses valores são **promovidos a `int`** na carga e operados por `iadd`, `isub`, `imul`…, sendo truncados de volta por `i2b`/`i2c`/`i2s` ou pela instrução de `astore` do array. |

**O que diz a JVMS §2.11.1:** a especificação fala em **"suporte limitado"** (*limited support*) para
os tipos integrais menores. Ela afirma que **não há instruções dedicadas para `boolean`** e que as
operações sobre `byte`, `short`, `char` e `boolean` **são realizadas pelas instruções de `int`**
após extensão (de sinal para `byte`/`short`; de zero para `char`/`boolean`) — **mas ela própria
define** `baload`, `caload`, `saload`, `i2b`, `i2c`, `i2s`, `newarray` com `atype` etc. Ou seja, a
JVMS sustenta a leitura restrita **no plano aritmético** e desmente a leitura ampla **no plano do
conjunto de instruções como um todo**.

**Como os nossos materiais se posicionam — e eles conflitam:**

- [SB_Prova_Java.md](SB_Prova_Java.md) Q9 (gabarito corrigido da prova real): **F**, com a tabela de
  instruções específicas por tipo. Argumento decisivo: **a própria prova se contradiz**, porque a
  **Discursiva 4** exige descrever `B[2] = (short)(B[2] − 128)`, que usa **`saload`/`sastore`/`i2s`**
  — instruções específicas de `short`.
- [00-SIMULADO.md](00-SIMULADO.md) Q36: **V**, mas com o enunciado **reescrito** para
  *"…específicas para os tipos `boolean`, `byte`, `char` e `short` **nas operações aritméticas** —
  esses valores são tratados como `int`"*.
- [java-jvm8-2-3.md](java-jvm8-2-3.md) §15 e [java-jvm8-3-3.md](java-jvm8-3-3.md) §3 reproduzem o
  slide: *"não há suporte direto para operações aritméticas em valores do tipo `byte`, `short`,
  `char` ou `boolean`"* — repare no **"aritméticas"**.

> **✅ O que responder na prova.** Leia o enunciado palavra por palavra:
> - Se ele disser **"não há instruções aritméticas / não há suporte direto para operações"** →
>   responda **V**.
> - Se ele disser **"não há instruções específicas"** (sem qualificar), como na prova de 21/2 →
>   responda **F** e justifique assim: *"Existem instruções específicas para esses tipos —
>   `baload`/`bastore`, `caload`/`castore`, `saload`/`sastore`, `i2b`/`i2c`/`i2s`, `bipush`/`sipush`
>   e `newarray` com `atype` T_BOOLEAN/T_CHAR/T_BYTE/T_SHORT. O que não existe é **aritmética
>   dedicada**: esses valores são estendidos para `int` (com sinal em `byte`/`short`, com zero em
>   `char`/`boolean`) e operados pelas instruções `i…`."*
> Essa justificativa cobre as duas leituras e mostra que você entendeu a distinção — que é
> exatamente o que a JVMS §2.11.1 quer dizer com "suporte limitado".

### 6.2 "Classe abstrata tem ao menos um método abstrato" — slide 121 × JLS

O **slide 121 do IBM-JavaBasico** afirma que classes abstratas *"podem possuir métodos
implementados, mas possuem ao menos um método abstrato"*. **Pela Java Language Specification isso é
falso.** O que torna uma classe abstrata é o **modificador `abstract`** na declaração (flag
`ACC_ABSTRACT` no `.class`), não a natureza dos seus métodos.

| Direção | Verdade |
|---|---|
| Classe tem método `abstract` ⟹ classe **deve** ser `abstract` | **VERDADEIRO** |
| Classe é `abstract` ⟹ tem ao menos um método `abstract` | **FALSO** (`abstract class X { }` é legal) |

Os demais materiais já corrigem o slide: [IBM-JavaBasico.md](IBM-JavaBasico.md) §25.8 e §1.3,
[java-conceitos.md](java-conceitos.md) §8, [SB_Prova_Java.md](SB_Prova_Java.md) Q16 e
[00-SIMULADO.md](00-SIMULADO.md) Q37 — todos dizem **falso**. E a prova anterior confirma: a Q16
(*"classe abstrata é aquela em que os seus métodos são abstratos"*) tem gabarito **F**.

> **✅ O que responder.** Responda **FALSO** e justifique: *"O que torna a classe abstrata é o
> modificador `abstract` (flag `ACC_ABSTRACT`); ela pode ter nenhum, alguns ou todos os métodos
> abstratos, e pode ter métodos concretos, atributos e construtores. Declarar `abstract class X { }`
> sem nenhum método abstrato é legal e serve para impedir a instanciação. A implicação válida é a
> inversa: se houver ao menos um método `abstract`, a classe **deve** ser declarada `abstract`."*
> Cuidado com o erro do aluno na prova: ele respondeu F, mas justificou com *"só um dos métodos
> precisa ser abstrato"* — trocou "todos" por "pelo menos um", quando **zero já basta**. A
> justificativa errada anula o ponto.

### 6.3 Outras divergências entre a prova anterior e o simulado (leia com atenção)

| Tema | [SB_Prova_Java.md](SB_Prova_Java.md) | [00-SIMULADO.md](00-SIMULADO.md) | Como decidir |
|---|---|---|---|
| **"Se existir, o primeiro código executado é sempre o do `<clinit>`"** | Q2 = **V** (a JVM carrega, liga e **inicializa** antes de `main`) | Q28 = **F** (carga e ligação vêm antes; o `<clinit>` da **super** vem antes do da classe; "sempre" é forte demais) | O gabarito da **prova real é V**. Se o enunciado for idêntico ao da prova (*"o primeiro **código** a ser executado"*), responda **V** — bytecode do usuário nenhum roda antes. Só marque F se o enunciado disser "a primeira coisa que a JVM faz". |
| **"`static` pode ser aplicado a classe, variável e método"** | Q21 = **V** (classes **aninhadas** aceitam `static`) | Q41 = **F** (classe **de topo** não aceita) | O gabarito da prova real é **V**, e a tabela do slide 88 diz **"não"** para classe. Decisão segura: responda **V** e justifique com *classes aninhadas estáticas*; se responder F, justifique com *classe de topo*. Em ambos os casos **mencione a distinção topo × aninhada** — é ela que a correção procura. |
| **`ConstantValue`** | Q11: em campo **estático** ⇒ ignorar = **F** | Q9: em campo **não estático** ⇒ ignorar = **V** | Não é contradição: são os **dois lados da mesma regra**. Leia qual dos dois casos o enunciado traz. |

### 6.4 Erros dos próprios slides, sinalizados nos resumos

**Em [formato-class.md](formato-class.md) §11:**

| Slide | O que está escrito | O correto pela JVMS |
|---|---|---|
| 20 | `CONSTANT_Class_info.name_index` = `Ljava/lang/Thread;` | Guarda o **nome interno** `java/lang/Thread` (sem `L`, sem `;`); `L…;` é **descritor de campo** |
| 21/22/23 | `class_index` aponta para uma `CONSTANT_Utf8_info` | Aponta para uma **`CONSTANT_Class_info`** (indireção dupla) |
| 25 | *"`length` não indica o número de bytes da string"* | `length` **é** o número de **bytes**; o que ele não indica é o número de **caracteres** |
| 13 | *"0 se a classe não for derivada; se for 0, estende `Object`"* | Na prática **só `java.lang.Object`** tem `super_class = 0` |
| 43 × 45 | 43: obrigatórios = `Code`, `Exceptions`, **`SourceFile`**; 45: `Code`, `ConstantValue`, `Exceptions` | O conjunto correto é **`ConstantValue`, `Code`, `Exceptions`** (+ `InnerClasses` e `Synthetic` no Java 2+); **`SourceFile` é opcional**. Na prova, siga o **slide 45** |
| 33 | Faixas de NaN de `double` como `0x7ffffffffffffL` | O correto é `0x7fffffffffffffffL` (dígitos perdidos) |
| 66 | `LocalVariableTable`: intervalo `[start_pc, start_pc+length]` | A JVMS define `[start_pc, start_pc+length)`, fim **exclusivo** |
| 2 | `typedef unsined long` | Erro de digitação de `unsigned long` |

**Em [java-jvm8-2-3.md](java-jvm8-2-3.md):**

- **Slide 51 (errata real):** a descrição de `istore_<n>` repete o texto de `iload_<n>`
  ("o valor … é **empilhado**"). O correto é o inverso: `istore_<n>` **desempilha** e grava na
  variável local `<n>`. Se a prova reproduzir o slide, saiba que está invertido.
- **Slides 43/44:** a tabela-sumário lista só `i2b` e `i2s` na linha `i2T`; **`i2c` existe** na JVM
  real (opcode 0x92) e aparece no material da parte 3. Para uma questão sobre *a tabela*, responda
  pela tabela; para uma questão sobre *a JVM*, `i2c` existe.
- **Slide 63:** grafa "`sub = 100`", faltando o `i` — leia `isub = 100 (0x64)`.
- **Slide 36:** o comentário fala em alinhamento "a partir do início do método"; o **alinhamento**
  se mede do início do código, mas o **desvio** é relativo ao **opcode do switch**.

**Em [java-conceitos.md](java-conceitos.md):**

- **`UnsupportedClassVersionError`:** o slide diz *"usa uma versão **antiga** do formato `.class`"*.
  Na prática moderna, o caso comum é o **oposto** (classe compilada por um `javac` mais novo que a
  JVM). **Na prova, responda conforme o slide.**
- **"C não tem tipos lógicos":** verdadeiro no vocabulário do slide; o **C99** introduziu
  `_Bool`/`<stdbool.h>`. **Vale o slide.**
- **Interface "não pode ter métodos concretos":** regra do slide (e do Java 1.4). Desde o **Java 8**
  existem métodos `default` e `static` em interfaces, e desde o 9, `private`. **Para esta prova,
  vale a regra do slide.**
- **Frame "contém o pool de constantes":** a redação do slide diz isso, e a Q6 da prova foi
  gabaritada **V** com essa redação — embora, rigorosamente, o frame guarde uma **referência** ao
  pool ([00-SIMULADO.md](00-SIMULADO.md) Q16 = **F**). Se o enunciado usar a redação dos slides,
  responda **V**; se disser explicitamente "o pool em si, copiado para dentro do frame", é **F**.

**Em [IBM-JavaBasico.md](IBM-JavaBasico.md):**

- **Slide 52 / Exemplo 1 do slide 50:** a "correção" proposta `short c = (short) b1 + b2;`
  **continua não compilando** — o cast liga-se só a `b1`. O correto é `(short)(b1 + b2)`.
- **Slide 53:** grafa o wrapper de `char` como **"Char"**; o nome correto é **`Character`**.
- **Slide 48:** lista `boolean` com **8 bits**; a JVMS **não define** o tamanho real (na prática usa
  uma palavra). **Para a prova, use a tabela do PDF.**
- **Slide 88 × prova Q21:** a tabela diz que `static` **não** se aplica a classe; o gabarito da prova
  diz que a afirmação "`static` pode ser aplicado a classe, variável e método" é **V** (por causa das
  aninhadas). Ver §6.3.
- **Slide 121:** a afirmação sobre classe abstrata — ver §6.2.

**Em [java-jvm8-3-3.md](java-jvm8-3-3.md):**

- **Slide 92 / tabela de opcodes:** a posição `0xba` aparece vazia (a tabela vem da **2ª edição** da
  JVMS); `invokedynamic` só entrou no **Java 7** e já é citada no texto do slide 89.
- **`jsr`/`jsr_w`/`ret`:** ainda são ensinadas (implementavam o `finally`), mas estão **obsoletas** e
  são **proibidas** em classes com `major_version ≥ 51.0`. Na prova, responda pelo material.

---

### 6.5 Divergências de **versão**: o material é anterior ao Java 8

Além dos conflitos acima, há uma camada inteira de divergência que vem da **idade dos materiais**.
Ela está tratada em detalhe em [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md); aqui fica o essencial.

| Material | Base real | Distância até o Java 8 |
|---|---|---|
| `formato-class.pdf` | **JVMS 8** | ✅ Alinhado. Só falta listar os atributos novos (`StackMapTable`, `BootstrapMethods`, `MethodParameters`, anotações de tipo) |
| `java-jvm8-1-3/2-3/3-3.pdf` | **JVMS 2ª edição** (apesar do nome "jvm8") | 🟦 Falta `invokedynamic` (opcode `0xba` vazio na tabela), as tags 15/16/18 do pool, e a proibição de `jsr`/`ret` |
| `java-conceitos.pdf` | **JVMS 2ª edição** | 🟦 Interfaces sem métodos concretos; 11 tags no pool em vez de 14 |
| `IBM-JavaBasico.pdf` | **Java 1.4** (2002) | 🟦 **A maior distância**: sem generics, autoboxing, `for` estendido, varargs, `enum`, `switch` com `String`, *try-with-resources*, métodos `default` |

**As três que podem virar questão:**

1. **Interface só tem métodos abstratos** → verdade até o Java 7. No **Java 8** existem métodos
   **`default`** e **`static`** com corpo. **Mas** interface continua **sem atributos de instância** —
   e é *isso* que torna a Q17 da prova falsa, em qualquer versão.
2. **Área de métodos = PermGen** → o **Java 8 removeu a PermGen** (JEP 122) em favor da
   **Metaspace**, em memória nativa. Detalhe de implementação da HotSpot; a especificação não cita
   nenhuma das duas.
3. **`invokedynamic` não é usada** → é a instrução com que **toda lambda do Java 8** é compilada.
   Se a tabela do slide mostrar `0xba` vazio, ela é da 2ª edição.

**Posterior ao Java 8 — 🟪 descarte se aparecer:** métodos `private` em interface e módulos (9),
`CONSTANT_Dynamic` na tag 17 e *nestmates* (11), *records* (16), *sealed* e ponto flutuante sempre
estrito (17), concatenação de `String` via `invokedynamic` (9). No Java 8, `a + b` ainda vira
`StringBuilder` e a tag 17 **não existe**.

---

## 7. Plano de estudo de 3 dias

### Dia 1 — Fundamentos e estrutura (o "onde as coisas moram")

**Ler:** [java-conceitos.md](java-conceitos.md) inteiro · [java-jvm8-1-3.md](java-jvm8-1-3.md) §3 a §5
e §9 · deste README, os **blocos 3, 4, 5, 6, 15**.

**Exercitar:**
1. Desenhe **de cabeça** o diagrama da seção 2 (loader → runtime areas → frame → engine) e depois
   confira. Repita até sair sem consultar.
2. Faça a tabela "compartilhado × por thread" em papel e classifique 10 itens:
   objeto, array de `int`, variável local, `static int`, código de método, pool de constantes,
   PC, frame, referência ao pool, parâmetro de método.
3. Para 5 assinaturas de método (uma estática, uma de instância, uma com `long`, uma com `double`,
   uma com array), escreva o **mapa do vetor de variáveis locais** com os índices corretos.
4. Refaça o exemplo `Foo extends Goo` até acertar **`5 1 4 6 7 2 3`** explicando cada número.
5. Liste os erros por fase (carga / verificação / resolução) sem olhar.

### Dia 2 — Formato `.class` e conjunto de instruções (o "como está escrito")

**Ler:** [formato-class.md](formato-class.md) §2 a §8 · [java-jvm8-2-3.md](java-jvm8-2-3.md) §3 a §15 ·
[java-jvm8-3-3.md](java-jvm8-3-3.md) §5 a §13 · deste README, os **blocos 1, 2, 7, 8, 9, 10, 11, 12**
e a **folha de cola inteira**.

**Exercitar:**
1. Escreva a `ClassFile` com os 16 campos **na ordem**, de memória. Depois as **14 tags** do pool.
2. Converta 8 assinaturas Java em descritores e 8 descritores em assinaturas. Inclua
   `([FIZZ[[[BIS[CIDZLupa_tem_covid_19;Ljava/lang/String;)V` (é a D1 da prova) e
   `(Ljava/lang/String;[[CJ)[D`.
3. Traduza à mão para bytecode, com o estado da pilha a cada passo:
   `return (a+b)*2 - a/b;` · `for (i=0;i<10;i++) s+=v[i];` · `B[2] = (short)(B[2]-128);` ·
   `Ponto p = new Ponto(3,4); int s = p.soma();`
4. Se tiver Java instalado: `javac Exemplo.java && javap -c -verbose Exemplo` e
   `xxd Exemplo.class | head` lado a lado. **Meia hora disso vale três releituras.**
5. Decore os blocos de opcode aritmético (`0x60`+ i,l,f,d) e a ordem `eq, ne, lt, ge, gt, le`.

### Dia 3 — Linguagem Java, revisão de armadilhas e simulado

**Manhã — ler:** [IBM-JavaBasico.md](IBM-JavaBasico.md) §12, §19, §23 a §26, §29 (exceções) ·
deste README, os **blocos 13 e 14**.

**Exercitar (manhã):**
1. Reproduza a tabela "Todos os Modificadores" (slide 88) e a tabela de visibilidade cruzada.
2. Responda de memória: construtor pode ser `final`/`static`/`abstract`? classe de topo pode ser
   `static`/`private`? interface tem construtor? classe abstrata tem construtor? `Object` tem
   construtor? `Map` é uma `Collection`?

**Tarde — revisão dirigida:**
3. Leia a **seção 5** (as 25 pegadinhas) cobrindo a coluna V/F e tentando responder.
4. Leia a **seção 6 inteira** — em especial §6.1 e §6.2 — e escreva, de memória, as **duas
   justificativas prontas** (instruções para `boolean/byte/char/short`; classe abstrata).
5. Releia [SB_Prova_Java.md](SB_Prova_Java.md): as 22 objetivas e, com atenção, as **4 discursivas**.
   Foque nas questões que o aluno **acertou com justificativa errada** (1, 3, 4, 5, 7, 16) — é aí
   que se perde ponto sem perceber.

**Noite — fechamento:**
6. Faça [00-SIMULADO.md](00-SIMULADO.md) **cronometrado e sem consultar**: Partes I e II inteiras,
   escrevendo **a justificativa de todo F**. Só depois abra a Parte III.
7. Para cada erro, anote **em uma linha** o porquê e volte ao bloco correspondente deste README.
8. Antes de dormir, releia só: a **folha de cola** (§4), a lista **"Erros mais caros"** ao final do
   simulado e as **duas justificativas prontas** da §6.

---

*Boa prova. Se, na hora, um enunciado tiver "sempre", "todo", "nunca" ou "não há", pare e procure a
exceção — ela quase sempre existe, e é ela que vale a justificativa.*
