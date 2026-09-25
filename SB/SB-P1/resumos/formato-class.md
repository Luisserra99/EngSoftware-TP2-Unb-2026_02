# Formato do Arquivo `.class` — Resumo de Estudo (SB / CIC0104 — UnB)

> Baseado no material da disciplina `formato-class.pdf` (76 slides), que por sua vez segue
> **"The Java Virtual Machine Specification, Java SE 8 Edition"** — Tim Lindholm, Frank Yellin,
> Gilad Bracha & Alex Buckley.

> 🔎 **Revisão Java 8** — este é o arquivo **mais alinhado à prova**: a JVMS 8 é exatamente a
> especificação cobrada (`major_version = 52`). As anotações 🟦/🟪/🟥 abaixo marcam os poucos pontos
> em que os slides usam exemplos de versões antigas ou omitem estruturas que **só existem a partir do
> Java 7/8**. Apanhado completo em [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).

---

## Sumário

1. [O que você precisa saber para a prova](#1-o-que-você-precisa-saber-para-a-prova)
2. [Conceitos introdutórios: o arquivo como stream de bytes](#2-conceitos-introdutórios-o-arquivo-como-stream-de-bytes)
   - 2.1 [Tipos de dados u1, u2, u4, u8](#21-tipos-de-dados-u1-u2-u4-u8)
   - 2.2 [Big-endian, ausência de padding, tabelas vs. arrays](#22-big-endian-ausência-de-padding-tabelas-vs-arrays)
   - 2.3 [Nomes internos de classes e interfaces](#23-nomes-internos-de-classes-e-interfaces)
3. [Descritores de tipo (a "linguagem de tipos" da JVM)](#3-descritores-de-tipo-a-linguagem-de-tipos-da-jvm)
   - 3.1 [Gramática dos descritores](#31-gramática-dos-descritores)
   - 3.2 [Descritores de campo (field descriptors)](#32-descritores-de-campo-field-descriptors)
   - 3.3 [Descritores de método (method descriptors)](#33-descritores-de-método-method-descriptors)
   - 3.4 [Exercícios resolvidos de descritores](#34-exercícios-resolvidos-de-descritores)
4. [A estrutura ClassFile](#4-a-estrutura-classfile)
   - 4.1 [Tabela completa da estrutura](#41-tabela-completa-da-estrutura)
   - 4.2 [magic, minor_version, major_version](#42-magic-minor_version-major_version)
   - 4.3 [constant_pool_count e constant_pool](#43-constant_pool_count-e-constant_pool)
   - 4.4 [access_flags da classe](#44-access_flags-da-classe)
   - 4.5 [this_class e super_class](#45-this_class-e-super_class)
   - 4.6 [interfaces_count e interfaces[]](#46-interfaces_count-e-interfaces)
   - 4.7 [fields, methods e attributes](#47-fields-methods-e-attributes)
5. [O pool de constantes (constant_pool)](#5-o-pool-de-constantes-constant_pool)
   - 5.1 [cp_info e a tabela de tags](#51-cp_info-e-a-tabela-de-tags)
   - 5.2 [Constantes de referência simbólica](#52-constantes-de-referência-simbólica-class-fieldref-methodref-interfacemethodref-nameandtype)
   - 5.3 [CONSTANT_Utf8_info e o Modified UTF-8](#53-constant_utf8_info-e-o-modified-utf-8)
   - 5.4 [Constantes literais: String, Integer, Float, Long, Double](#54-constantes-literais-string-integer-float-long-double)
   - 5.5 [Reconstrução dos valores float e double a partir dos bits](#55-reconstrução-dos-valores-float-e-double-a-partir-dos-bits)
6. [A tabela fields (field_info)](#6-a-tabela-fields-field_info)
7. [A tabela methods (method_info)](#7-a-tabela-methods-method_info)
8. [Atributos (attribute_info)](#8-atributos-attribute_info)
   - 8.1 [Estrutura genérica e regra do "ignorar em silêncio"](#81-estrutura-genérica-e-regra-do-ignorar-em-silêncio)
   - 8.2 [ConstantValue](#82-atributo-constantvalue)
   - 8.3 [Code](#83-atributo-code)
   - 8.4 [Tratamento de exceções pela JVM](#84-como-a-jvm-localiza-o-manipulador-de-exceções)
   - 8.5 [Exceptions](#85-atributo-exceptions)
   - 8.6 [Deprecated e Synthetic](#86-atributos-deprecated-e-synthetic)
   - 8.7 [InnerClasses](#87-atributo-innerclasses)
   - 8.8 [LineNumberTable](#88-atributo-linenumbertable)
   - 8.9 [LocalVariableTable](#89-atributo-localvariabletable)
   - 8.10 [SourceFile](#810-atributo-sourcefile)
   - 8.11 [Tabela-resumo: onde cada atributo pode aparecer](#811-tabela-resumo-onde-cada-atributo-pode-aparecer)
9. [Exemplos completos: do Java ao .class](#9-exemplos-completos-do-java-ao-class)
   - 9.1 [HelloWorld: fonte, dump hexadecimal e javap -c -verbose](#91-helloworld-fonte-dump-hexadecimal-e-javap--c--verbose)
   - 9.2 [Classe Teste: soma, float, double e laço for](#92-classe-teste-soma-float-double-e-laço-for)
   - 9.3 [Ferramenta jclasslib Bytecode Viewer](#93-ferramenta-jclasslib-bytecode-viewer)
10. [Implementando um leitor de .class em C](#10-implementando-um-leitor-de-class-em-c)
    - 10.1 [fopen e modos de abertura](#101-fopen-e-modos-de-abertura)
    - 10.2 [Leitura big-endian: u1Read, u2Read, u4Read](#102-leitura-big-endian-u1read-u2read-u4read)
    - 10.3 [Lendo o ClassFile e o constant_pool](#103-lendo-o-classfile-e-o-constant_pool)
11. [Erros e imprecisões dos slides (cuidado!)](#11-erros-e-imprecisões-dos-slides-cuidado)
12. [Resumo em 10 pontos](#12-resumo-em-10-pontos)

---

## 1. O que você precisa saber para a prova

Se o tempo for curto, estes são os pontos que caem com mais frequência:

| # | Ponto | O essencial |
|---|-------|-------------|
| 1 | **Magic number** | `0xCAFEBABE`, campo `u4 magic`, primeiros 4 bytes do arquivo. |
| 2 | **Ordem dos bytes** | **Big-endian** (byte mais significativo primeiro). Nunca little-endian. |
| 3 | **Sem alinhamento** | Itens são gravados **sequencialmente, sem bytes de preenchimento (padding) nem alinhamento**. |
| 4 | **Tabela ≠ array** | *Tabela*: itens de **tamanho variável** → índice **não** vira offset diretamente. *Array*: itens de **tamanho fixo** → indexável como em C. |
| 5 | **constant_pool_count** | É o número de entradas **+ 1**. Índices válidos: `1 ≤ i < constant_pool_count`. O índice **0 é inválido/reservado**. |
| 6 | **Long e Double no CP** | Ocupam **dois índices**; se `n` é o índice de um `CONSTANT_Long`/`CONSTANT_Double`, então `n+1` é **inválido**. |
| 7 | **Nome da classe** | Nome totalmente qualificado com **`/` no lugar do `.`**: `java/lang/Thread`. |
| 8 | **super_class = 0** | Só a classe `java.lang.Object` tem `super_class` igual a 0 (o slide diz: "se for 0 essa classe estende Object" / não é derivada). Caso contrário é índice para um `CONSTANT_Class_info`. |
| 9 | **ConstantValue** | `attribute_length` é **sempre 2**; serve para **variáveis estáticas**. Em campo **não estático** a JVM **ignora em silêncio**. |
| 10 | **Code** | Só em `method_info`; **no máximo um por método**; métodos **nativos e abstratos NÃO têm** atributo `Code`. `code_length` deve ser **> 0**. |
| 11 | **attribute_length** | Conta os bytes **restantes** do atributo, **sem** incluir os 6 bytes de `attribute_name_index` (2) + `attribute_length` (4). |
| 12 | **Tags do CP** | Decorar: Utf8=1, Integer=3, Float=4, Long=5, Double=6, Class=7, String=8, Fieldref=9, Methodref=10, InterfaceMethodref=11, NameAndType=12, MethodHandle=15, MethodType=16, InvokeDynamic=18. (**Não existem as tags 2, 13, 14 e 17**.) |
| 13 | **Utf8 não é ASCIIZ** | `length` é o número de **bytes**, não de caracteres, e a string **não termina em `\0`**. |
| 14 | **Modified UTF-8** | Usa **1, 2 ou 3 bytes** — **nunca 4**. O caractere `\u0000` (null) é codificado em **2 bytes** (`0xC0 0x80`). |
| 15 | **Herança não aparece** | As tabelas `fields` e `methods` contêm **apenas** os membros **declarados** na própria classe/interface — **nada herdado**. |
| 16 | **Descritores** | `(IDLjava/lang/Thread;)Ljava/lang/Object;`. `V` = void, só aparece como **retorno**. `J` = long, `Z` = boolean, `[` = uma dimensão de array. |
| 17 | **Atributos obrigatórios** | A JVM **deve** reconhecer `ConstantValue`, `Code` e `Exceptions` (e, a partir do Java 2, `InnerClasses` e `Synthetic`). Atributos desconhecidos → **ignorar em silêncio**. |
| 18 | **Métodos especiais** | `<init>` = construtor de instância (chamado por `invokespecial`); `<clinit>` = inicialização de classe/interface. |
| 19 | **catch_type = 0** | Significa cláusula **`finally`** (captura qualquer exceção). Diferente de zero → índice para `CONSTANT_Class_info`. |
| 20 | **Nomes exatos dos campos** | `magic`, `minor_version`, `major_version`, `constant_pool_count`, `constant_pool`, `access_flags`, `this_class`, `super_class`, `interfaces_count`, `interfaces`, `fields_count`, `fields`, `methods_count`, `methods`, `attributes_count`, `attributes` — **nesta ordem**. |

---

## 2. Conceitos introdutórios: o arquivo como stream de bytes

### O que é um arquivo `.class`?

Um arquivo `.class` é o **formato binário de saída do compilador Java** (`javac`). Ele contém
a definição de **uma única classe ou interface** — nunca duas. Se o seu `Foo.java` define
`Foo` e uma classe auxiliar `Bar`, o compilador gera **dois** arquivos: `Foo.class` e `Bar.class`.

Do ponto de vista físico, o arquivo é um **stream (fluxo) de bytes de 8 bits**. A especificação
descreve seu conteúdo usando uma **notação com sintaxe semelhante à da linguagem C**
(structs, arrays, campos) — mas isso é só notação: o arquivo em disco não tem structs, só bytes.

### 2.1 Tipos de dados u1, u2, u4, u8

A especificação define quatro tipos inteiros **sem sinal**:

| Tipo | Tamanho | Equivalente em C | Faixa |
|------|---------|------------------|-------|
| `u1` | 1 byte  | `typedef unsigned char u1;`  | 0 … 255 |
| `u2` | 2 bytes | `typedef unsigned short u2;` | 0 … 65.535 |
| `u4` | 4 bytes | `typedef unsigned int u4;`   | 0 … 4.294.967.295 |
| `u8` | 8 bytes | `typedef unsigned long u8;`  | 0 … 2⁶⁴−1 |

> Observação do slide: os tipos de largura garantida (`uint8_t`, `uint16_t`, …) vêm de
> `stdint.h`, que é do **C99**. Em um trabalho de implementação, usar `stdint.h` é mais
> seguro do que confiar que `short` tem 2 bytes e `int` tem 4.

Em C, a forma robusta seria:

```c
#include <stdint.h>
typedef uint8_t  u1;
typedef uint16_t u2;
typedef uint32_t u4;
typedef uint64_t u8;
```

### 2.2 Big-endian, ausência de padding, tabelas vs. arrays

**Big-endian.** Todo item multi-byte é armazenado com o **byte mais significativo primeiro**.
O número `0xCAFEBABE` aparece no arquivo, na ordem de leitura, como:

```
CA FE BA BE
```

e não como `BE BA FE CA` (que seria little-endian, a ordem nativa do x86). Por isso, um leitor
escrito em C rodando num PC **não pode** simplesmente fazer `fread(&x, 4, 1, fd)`: precisa
montar o valor byte a byte (ver seção 10.2).

**Itens sucessivos, sem preenchimento.** Os itens são armazenados **sequencialmente, sem
caracteres de preenchimento (padding) e sem alinhamento**. Isso significa, por exemplo, que um
`u4` pode começar num offset ímpar do arquivo. É uma diferença importante em relação a
`struct`s de C compiladas, que normalmente são alinhadas pelo compilador.

**Tabelas vs. arrays** — distinção que cai em prova:

| | Tabela | Array |
|---|---|---|
| Conteúdo | zero ou mais itens de **tamanho variável** | zero ou mais itens de **tamanho fixo** |
| Indexação | o índice **não** pode ser traduzido diretamente em um offset (deslocamento) | pode ser indexado como um array de C |
| Exemplos | `constant_pool`, `fields`, `methods`, `attributes` | `interfaces[]`, `code[]`, `bytes[]` |

Ou seja: para chegar à entrada 10 do `constant_pool` você **tem de percorrer** as 9 anteriores,
porque cada uma pode ter um tamanho diferente (uma `CONSTANT_Utf8_info` de 50 bytes ao lado de
uma `CONSTANT_Class_info` de 3 bytes).

> ⚠️ **Pegadinha de prova**
> - "Os itens do arquivo `.class` são alinhados em fronteiras de 4 bytes." → **FALSO**. Não há
>   alinhamento nem padding.
> - "O índice de uma tabela pode ser convertido diretamente em um deslocamento no arquivo."
>   → **FALSO** para *tabelas* (itens variáveis); **VERDADEIRO** apenas para *arrays*
>   (itens fixos).
> - "Itens multi-byte são armazenados em little-endian." → **FALSO**: big-endian.

### 2.3 Nomes internos de classes e interfaces

Dentro do `.class`, nomes de classes e interfaces aparecem sempre na forma **totalmente
qualificada (fully qualified)**, armazenados como constantes **UTF-8**, com o **ponto
qualificador substituído por barra `/`**:

| No código-fonte Java | No arquivo `.class` (internal name) |
|---|---|
| `java.lang.Thread` | `java/lang/Thread` |
| `java.lang.Object` | `java/lang/Object` |
| `java.io.PrintStream` | `java/io/PrintStream` |
| `HelloWorld` (pacote default) | `HelloWorld` |

> ⚠️ **Pegadinha de prova**: a `CONSTANT_Class_info` de uma classe guarda `java/lang/Thread`
> — **sem** o `L` inicial e **sem** o `;` final. O formato `Ljava/lang/Thread;` é o **descritor
> de campo**, usado em `CONSTANT_Utf8_info` apontada por um `descriptor_index`, não no
> `name_index` de uma `CONSTANT_Class_info`. (O slide 20 do PDF traz esse exemplo de forma
> imprecisa — veja a seção 11.)

---

## 3. Descritores de tipo (a "linguagem de tipos" da JVM)

### O problema que o descritor resolve

A JVM precisa saber, para cada campo e cada método, **qual é o seu tipo**. Mas o `.class` não
guarda "int" ou "double" por extenso: guarda uma **string compacta** chamada **descritor**,
armazenada como uma `CONSTANT_Utf8_info` no pool de constantes. Descritor é, portanto,
**uma string que representa o tipo de um field ou de um método**.

### 3.1 Gramática dos descritores

A especificação define a gramática (em notação BNF):

```
FieldDescriptor:
    FieldType

FieldType:
    BaseType
    ObjectType
    ArrayType

BaseType:
    B  C  D  F  I  J  S  Z

ObjectType:
    L <classname> ;

ArrayType:
    [ ComponentType

ComponentType:
    FieldType

MethodDescriptor:
    ( ParameterDescriptor* ) ReturnDescriptor

ParameterDescriptor:
    FieldType

ReturnDescriptor:
    FieldType
    V
```

Note que a gramática é **recursiva**: `ArrayType` é `[` seguido de um `ComponentType`, que é um
`FieldType`, que pode ser outro `ArrayType`. É assim que `[[[D` significa "array de 3 dimensões
de `double`".

### 3.2 Descritores de campo (field descriptors)

| Caractere | Tipo base | Tipo Java | Interpretação |
|---|---|---|---|
| `B` | byte | `byte` | Byte com sinal (8 bits) |
| `C` | char | `char` | Caractere Unicode codificado em UTF-16 |
| `D` | double | `double` | Ponto flutuante de **dupla** precisão |
| `F` | float | `float` | Ponto flutuante de precisão **simples** |
| `I` | int | `int` | Inteiro (32 bits) |
| `J` | long | `long` | Inteiro **longo** (64 bits) |
| `L<nome_classe>;` | referência | objeto | Instância da classe `<nome_classe>` |
| `S` | short | `short` | Inteiro **curto** com sinal |
| `Z` | boolean | `boolean` | `true` ou `false` |
| `[` | referência | array | **Uma dimensão** de array |

Exemplo dado no material:

```
I                     <->  variável de instância do tipo int
Ljava/lang/Object;    <->  variável de instância do tipo Object
[[[D                  <->  array multidimensional (3 dimensões) de doubles
```

> ⚠️ **Pegadinha de prova**
> - **`J` é `long`**, não `L`; **`L` inicia um tipo objeto** e exige o `;` no fim.
> - **`Z` é `boolean`**, não `B`; **`B` é `byte`**.
> - **`S` é `short`**, e `C` é `char` (16 bits, UTF-16).
> - Cada `[` vale **uma** dimensão: `[[I` é `int[][]`, e não "array de 2 ints".
> - Não existe o caractere `V` em descritor de **campo** — só em retorno de método.

### 3.3 Descritores de método (method descriptors)

Um descritor de método representa, ao mesmo tempo, **os tipos dos parâmetros** e **o tipo de
retorno**:

```
( ParameterDescriptor* ) ReturnDescriptor
```

- Os parâmetros ficam entre parênteses, **um colado no outro, sem vírgulas**, na ordem da
  declaração.
- O retorno vem **depois** do parêntese que fecha.
- `V` representa o tipo **void**, isto é, método que **não retorna nenhum valor**. `V` só é
  válido como **ReturnDescriptor**.

Exemplo do material — para o método cujo protótipo é:

```java
Object mymethod(int i, double d, Thread t)
```

o descritor é:

```
(IDLjava/lang/Thread;)Ljava/lang/Object;
```

Leitura passo a passo: `(` abre a lista → `I` (int) → `D` (double) → `Ljava/lang/Thread;`
(referência a Thread) → `)` fecha → `Ljava/lang/Object;` (retorno).

### 3.4 Exercícios resolvidos de descritores

| Assinatura Java | Descritor |
|---|---|
| `void main(String[] args)` | `([Ljava/lang/String;)V` |
| `int soma(int a, int b)` | `(II)I` |
| `HelloWorld()` (construtor) | `()V` — nome do método: `<init>` |
| `static {}` (bloco estático) | `()V` — nome do método: `<clinit>` |
| `long calc(long x, float y)` | `(JF)J` |
| `boolean eq(Object o)` | `(Ljava/lang/Object;)Z` |
| `void p(int[][] m, char c)` | `([[IC)V` |
| `String[] nomes()` | `()[Ljava/lang/String;` |
| `void nada()` | `()V` |
| `double[] v(double d)` | `(D)[D` |
| campo `private static final int MAX` | `I` |
| campo `String nome` | `Ljava/lang/String;` |
| campo `float[] pesos` | `[F` |

> ⚠️ **Pegadinha de prova**: no descritor **não existe** separador entre parâmetros. `(II)I`
> tem **dois** parâmetros int. E `(Ljava/lang/String;I)V` tem um `String` e um `int` — o `;`
> é terminador do tipo objeto, **não** separador de parâmetros.

---

## 4. A estrutura ClassFile

### 4.1 Tabela completa da estrutura

Esta é **a** estrutura da prova. Vale decorar a ordem.

```c
ClassFile {
    u4             magic;
    u2             minor_version;
    u2             major_version;
    u2             constant_pool_count;
    cp_info        constant_pool[constant_pool_count-1];
    u2             access_flags;
    u2             this_class;
    u2             super_class;
    u2             interfaces_count;
    u2             interfaces[interfaces_count];
    u2             fields_count;
    field_info     fields[fields_count];
    u2             methods_count;
    method_info    methods[methods_count];
    u2             attributes_count;
    attribute_info attributes[attributes_count];
}
```

Em formato de tabela:

| Ordem | Tipo | Campo | Significado |
|---|---|---|---|
| 1 | `u4` | `magic` | Assinatura `0xCAFEBABE` |
| 2 | `u2` | `minor_version` | Versão menor (m) |
| 3 | `u2` | `major_version` | Versão maior (M) |
| 4 | `u2` | `constant_pool_count` | nº de entradas do pool **+ 1** |
| 5 | `cp_info` | `constant_pool[count-1]` | Tabela de constantes (tamanho variável) |
| 6 | `u2` | `access_flags` | Máscara de bits da classe/interface |
| 7 | `u2` | `this_class` | Índice p/ `CONSTANT_Class_info` desta classe |
| 8 | `u2` | `super_class` | Índice p/ `CONSTANT_Class_info` da superclasse, ou **0** |
| 9 | `u2` | `interfaces_count` | nº de superinterfaces **diretas** |
| 10 | `u2[]` | `interfaces[]` | Índices p/ `CONSTANT_Class_info` |
| 11 | `u2` | `fields_count` | nº de estruturas `field_info` |
| 12 | `field_info[]` | `fields[]` | Campos **declarados** na classe |
| 13 | `u2` | `methods_count` | nº de estruturas `method_info` |
| 14 | `method_info[]` | `methods[]` | Métodos **declarados** na classe |
| 15 | `u2` | `attributes_count` | nº de estruturas `attribute_info` |
| 16 | `attribute_info[]` | `attributes[]` | Atributos da classe (ex.: `SourceFile`) |

> ⚠️ **Pegadinha de prova**
> - O array declarado é `constant_pool[constant_pool_count-1]` — **menos 1**. Todos os demais
>   arrays usam o `count` cheio (`interfaces[interfaces_count]`, `fields[fields_count]`, …).
> - A ordem é **fields antes de methods**, e **methods antes de attributes**.
> - Os nomes são exatamente `super_class` (não `superclass`, nem `parent_class`) e
>   `this_class` (não `class_name`).
> - Não existe campo "`package`", nem "`filename`" no `ClassFile`: o nome do fonte vem do
>   **atributo** `SourceFile`.

### 4.2 magic, minor_version, major_version

**`u4 magic`** — assinatura do arquivo `.class`, valor fixo **`0xCAFEBABE`**. É a primeira coisa
que a JVM lê; se não bater, o arquivo é rejeitado (`ClassFormatError`). No dump hexadecimal, os
quatro primeiros bytes são sempre `CA FE BA BE`.

**`u2 minor_version` (m)** e **`u2 major_version` (M)** — juntos indicam a versão do formato na
forma **M.m**. Características:

- As versões podem ser **ordenadas lexicograficamente**: por exemplo, `1.5 < 2.0 < 2.1`.
- São **definidas pela Oracle** (antes, Sun).
- Uma JVM só carrega arquivos cuja versão ela suporta.

Tabela útil de correspondência (`major_version` ↔ versão da plataforma):

| major_version | hex | Plataforma |
|---|---|---|
| 45 | 0x2D | JDK 1.1 |
| 46 | 0x2E | JDK 1.2 |
| 47 | 0x2F | JDK 1.3 |
| 48 | 0x30 | JDK 1.4 |
| 49 | 0x31 | Java SE 5 |
| 50 | 0x32 | Java SE 6 |
| 51 | 0x33 | Java SE 7 |
| 52 | 0x34 | Java SE 8 |

(No exemplo do jclasslib mostrado no material, `major_version = 46` e `minor_version = 0`.)

> 🟦 **Divergência Java 8** — esse `46` é **JDK 1.2**: a captura de tela do slide é de um `.class`
> antigo. Um `.class` compilado com o **JDK 8** tem `major_version = 52` (`0x34`), que é a versão
> cobrada nesta prova — e é a que aparece no `javap` da seção 9 deste resumo.
>
> A tabela acima **para no 52 de propósito**: é o último da série que interessa aqui. 🟪 Depois vêm
> 53 (Java 9), 55 (Java 11), 61 (Java 17) — fora do escopo.
>
> Consequência prática: uma JVM do **Java 8** aceita `major_version` de **45 a 52** e lança
> `UnsupportedClassVersionError` para 53+. E, como `major_version ≥ 51`, um `.class` de Java 8
> **não pode conter `jsr`/`ret`** (ver seção sobre o tipo `returnAddress`).

> ⚠️ **Pegadinha de prova**: no arquivo, a ordem física é **minor antes de major** (minor vem
> primeiro!), embora a versão se **escreva** M.m. Isso é contraintuitivo e é uma pergunta
> clássica de verdadeiro/falso.

### 4.3 constant_pool_count e constant_pool

**`u2 constant_pool_count`** — é o **número de entradas na tabela `constant_pool` + 1**.
Consequência: os índices válidos satisfazem

```
1 ≤ índice do constant_pool < constant_pool_count
```

O **índice 0 não é usado** (é reservado para significar "nenhuma entrada", como em
`super_class = 0` ou `catch_type = 0`).

Regra adicional: **se `n` é um índice válido para uma constante do tipo `long` ou `double`,
então o índice `n+1` é inválido** — porque essas constantes ocupam **duas** posições do pool
(uma herança histórica do design original da JVM).

**`cp_info constant_pool[]`** — é a **tabela de estruturas** que representa:

- strings literais,
- nomes de classes e interfaces,
- nomes de campos e métodos,
- descritores de tipo,
- constantes numéricas,

todos **referidos por índice** dentro da `ClassFile` e de suas subestruturas
(`field_info`, `method_info`, `attribute_info`, `Code_attribute`, …). O **formato de cada
entrada é indicado pelo byte de `tag`** que a inicia.

> ⚠️ **Pegadinha de prova**
> - "Se o `constant_pool_count` vale 34, há 34 entradas no pool." → **FALSO**: há **33**.
> - "Todos os índices de 1 a `constant_pool_count-1` são sempre válidos." → **FALSO**: o índice
>   seguinte a um `Long`/`Double` é inválido.
> - "O índice 0 do pool aponta para a primeira constante." → **FALSO**: o índice 0 é inválido.

### 4.4 access_flags da classe

**`u2 access_flags`** — **máscara de bits** que especifica as permissões de acesso e as
propriedades da classe ou interface. Como é máscara, valores se **combinam por OR bit a bit**.

| Nome do flag | Valor | Interpretação |
|---|---|---|
| `ACC_PUBLIC` | `0x0001` | Declarada pública: pode ser acessada de fora do pacote |
| `ACC_FINAL` | `0x0010` | Declarada final: **não pode ter subclasses** |
| `ACC_SUPER` | `0x0020` | Chama métodos de superclasse via a instrução `invokespecial` |
| `ACC_INTERFACE` | `0x0200` | **É uma interface**, não uma classe |
| `ACC_ABSTRACT` | `0x0400` | Declarada abstrata: **não pode ser instanciada** |
| `ACC_SYNTHETIC` | `0x1000` | Declarada *synthetic*: **não presente no código-fonte** |
| `ACC_ANNOTATION` | `0x2000` | Declarada como tipo *annotation* |
| `ACC_ENUM` | `0x4000` | Declarada como tipo *enum* |

**Todos os demais bits são reservados para uso futuro e devem ser definidos como zero.**

Exemplos de combinação:

| Declaração Java | access_flags | Decomposição |
|---|---|---|
| `public class HelloWorld` | `0x0021` | `ACC_PUBLIC (0x0001) \| ACC_SUPER (0x0020)` |
| `class Teste` (pacote default) | `0x0020` | `ACC_SUPER` |
| `public final class X` | `0x0031` | `0x0001 \| 0x0010 \| 0x0020` |
| `public abstract class Y` | `0x0421` | `0x0001 \| 0x0400 \| 0x0020` |
| `public interface I` | `0x0601` | `ACC_PUBLIC \| ACC_INTERFACE \| ACC_ABSTRACT` |

> ⚠️ **Pegadinha de prova**
> - **Não existe `ACC_PRIVATE` nem `ACC_PROTECTED` no `access_flags` da classe** (eles só
>   existem em `field_info`, `method_info` e no `InnerClasses`). Uma classe de topo é pública
>   ou "package-private" (flags sem `ACC_PUBLIC`).
> - **Não existe `ACC_STATIC` no `access_flags` da classe** (só em campos, métodos e em
>   `InnerClasses`).
> - Toda **interface** tem obrigatoriamente `ACC_INTERFACE` **e** `ACC_ABSTRACT` ligados.
> - `ACC_SUPER` (0x0020) **na classe** e `ACC_SYNCHRONIZED` (0x0020) **no método** têm o mesmo
>   valor numérico, mas significados totalmente diferentes. Cai muito.
> - `ACC_FINAL` é `0x0010`, e não `0x0008` (0x0008 é `ACC_STATIC`, que não se aplica à classe).

### 4.5 this_class e super_class

**`u2 this_class`** — deve ser um **índice válido da tabela `constant_pool`**, apontando para
uma estrutura **`CONSTANT_Class_info`**, que representa **a classe ou interface definida por
este arquivo**:

```c
CONSTANT_Class_info {
    u1 tag;          // 7
    u2 name_index;   // -> CONSTANT_Utf8_info com o nome, ex.: "HelloWorld"
}
```

**`u2 super_class`** — também índice válido para `constant_pool` apontando para uma
`CONSTANT_Class_info`, que representa a **superclasse direta (classe mãe)** da classe definida
neste arquivo. Regra especial:

- vale **0 (zero)** se a classe **não for derivada**;
- segundo o material, **se for 0 essa classe estende `Object`** — na prática, apenas
  `java.lang.Object` tem `super_class = 0`, pois todas as outras classes têm como superclasse
  explícita pelo menos `java/lang/Object`.

Na prática, se você compilar `public class HelloWorld { }`, o `javac` coloca em `super_class`
um índice apontando para `CONSTANT_Class_info` → `java/lang/Object`, e **não** zero.

> ⚠️ **Pegadinha de prova**
> - `this_class` e `super_class` **não** apontam diretamente para a string do nome: apontam para
>   uma `CONSTANT_Class_info`, que por sua vez aponta (via `name_index`) para a
>   `CONSTANT_Utf8_info` com o nome. É uma **indireção dupla**.
> - "`super_class` só pode ser zero em uma interface." → **FALSO**: interfaces têm
>   `super_class` apontando para `java/lang/Object`.

### 4.6 interfaces_count e interfaces[]

**`u2 interfaces_count`** — número de entradas no array `interfaces[]`, isto é, o número de
**superinterfaces diretas** dessa classe ou interface. Índices válidos:

```
0 ≤ índice de interfaces < interfaces_count
```

**`u2 interfaces[]`** — cada valor deve ser um **índice válido na `constant_pool`** cuja entrada
seja uma estrutura **`CONSTANT_Class_info`**, representando **uma interface que é
superinterface direta** da classe/interface representada neste arquivo.

Exemplo: para `class A extends B implements C, D`, temos `interfaces_count = 2` e
`interfaces[0]`, `interfaces[1]` apontando para `CONSTANT_Class_info` de `C` e `D`.

> ⚠️ **Pegadinha de prova**: `interfaces[]` é um **array** (itens de tamanho fixo `u2`) e é
> indexado **a partir de 0** — diferente do `constant_pool`, que é uma **tabela** indexada a
> partir de **1**. Além disso, só entram as superinterfaces **diretas**, não as herdadas
> transitivamente.

### 4.7 fields, methods e attributes

**`u2 fields_count` / `field_info fields[]`**

- `fields_count` é o número de **variáveis de classe (static) ou variáveis de instância**
  declaradas nesta classe ou interface, e também o número de estruturas `field_info` na tabela.
- Cada entrada é uma `field_info` com a **descrição completa de um campo**.
- A tabela inclui **apenas os campos declarados** na classe/interface: **não inclui campos
  herdados** de superclasses ou superinterfaces.

**`u2 methods_count` / `method_info methods[]`**

- Número de estruturas `method_info` na tabela `methods[]`.
- Cada entrada descreve **completamente um método** da classe/interface. Se o método **não é
  nativo nem abstrato**, também são fornecidas as **instruções da JVM** que o implementam
  (dentro do atributo `Code`).
- Entram **todos os tipos de métodos**: declarados pela classe ou interface, de instância,
  estáticos, de **iniciação de instância** (`<init>`) e qualquer método de **iniciação de
  classe ou interface** (`<clinit>`).
- **Não inclui métodos herdados** de superclasses ou superinterfaces.

**`u2 attributes_count` / `attribute_info attributes[]`**

- Número de estruturas `attribute_info` na tabela `attributes[]` da classe.
- A **implementação da JVM deve ignorar em silêncio qualquer atributo que não reconheça** —
  é assim que o formato permanece extensível.

> ⚠️ **Pegadinha de prova**: "A tabela `methods` de `Teste` contém `toString()` herdado de
> `Object`." → **FALSO**. Herança **não** é materializada no `.class`; é resolvida em tempo de
> execução pela JVM, subindo a cadeia de superclasses.

---

## 5. O pool de constantes (constant_pool)

### 5.1 cp_info e a tabela de tags

Todas as **informações simbólicas** do arquivo estão armazenadas na tabela `constant_pool`.
Cada entrada tem a forma genérica:

```c
cp_info {
    u1 tag;
    u1 info[];
}
```

O **byte de `tag` define o tipo da informação** contida em `info[]` — e, portanto, quantos bytes
aquela entrada ocupa. É exatamente por isso que o `constant_pool` é uma **tabela** e não um
array: entradas diferentes têm tamanhos diferentes.

**Tipos válidos de tags:**

| Tipo de constante | Valor (tag) | Tamanho total da entrada |
|---|---|---|
| `CONSTANT_Utf8` | **1** | 3 + length bytes |
| `CONSTANT_Integer` | **3** | 5 bytes |
| `CONSTANT_Float` | **4** | 5 bytes |
| `CONSTANT_Long` | **5** | 9 bytes (ocupa 2 índices) |
| `CONSTANT_Double` | **6** | 9 bytes (ocupa 2 índices) |
| `CONSTANT_Class` | **7** | 3 bytes |
| `CONSTANT_String` | **8** | 3 bytes |
| `CONSTANT_Fieldref` | **9** | 5 bytes |
| `CONSTANT_Methodref` | **10** | 5 bytes |
| `CONSTANT_InterfaceMethodref` | **11** | 5 bytes |
| `CONSTANT_NameAndType` | **12** | 5 bytes |
| `CONSTANT_MethodHandle` | **15** | 4 bytes |
| `CONSTANT_MethodType` | **16** | 3 bytes |
| `CONSTANT_InvokeDynamic` | **18** | 5 bytes |

> ⚠️ **Pegadinha de prova**
> - **Não existem as tags 2, 13, 14 e 17.** São valores reservados/não usados.
> - As tags **não** estão em ordem "lógica": `Utf8` é **1**, mas `Class` é **7** e `String` é
>   **8** (String vem **depois** de Class!). Um erro clássico é trocar `String` (8) com
>   `Fieldref` (9).
> - `MethodHandle`(15), `MethodType`(16) e `InvokeDynamic`(18) foram introduzidos no **Java 7**
>   para suportar `invokedynamic`/linguagens dinâmicas. O material de leitura em C (slide 73)
>   lista **apenas as 11 primeiras tags** (1 a 12) — pode ser o escopo cobrado no trabalho.
> - 🟦 Materiais baseados na **2ª edição** da JVMS (como o `java-conceitos.pdf`) listam só **11**
>   tags, porque 15/16/18 ainda não existiam. Na **JVMS 8** são **14** tags. Se um slide mostrar
>   11, ele é pré-Java-7.
> - 🟪 A tag **17** está vaga **no Java 8**, mas foi ocupada por `CONSTANT_Dynamic` no **Java 11**;
>   as tags **19** (`Module`) e **20** (`Package`) vieram no **Java 9**. Para esta prova, valem as
>   14 tags do Java 8 e as **inexistentes são 2, 13, 14 e 17**.

### 5.2 Constantes de referência simbólica (Class, Fieldref, Methodref, InterfaceMethodref, NameAndType)

#### CONSTANT_Class_info — representa uma **classe ou interface**

```c
CONSTANT_Class_info {
    u1 tag;          // valor 7
    u2 name_index;
}
```

- `name_index` é **índice válido para a `constant_pool`**, e a entrada nesse índice deve ser uma
  **`CONSTANT_Utf8_info`** representando o **nome completo qualificado** da classe ou interface.
- Exemplo (nome interno correto): `java/lang/Thread`.

#### CONSTANT_Fieldref_info — representa um **field**

```c
CONSTANT_Fieldref_info {
    u1 tag;                    // valor 9
    u2 class_index;
    u2 name_and_type_index;
}
```

- `class_index` é índice válido para `constant_pool` → estrutura **`CONSTANT_Class_info`**
  representando a classe ou interface que contém a declaração desse field.
- `name_and_type_index` é índice válido para `constant_pool` → estrutura
  **`CONSTANT_NameAndType_info`** indicando o **nome e o descritor** do field.

#### CONSTANT_Methodref_info — representa um **método (de classe)**

```c
CONSTANT_Methodref_info {
    u1 tag;                    // valor 10
    u2 class_index;
    u2 name_and_type_index;
}
```

- `class_index` → `CONSTANT_Class_info` da **classe** (não interface) que declara o método.
- `name_and_type_index` → `CONSTANT_NameAndType_info` com nome e descritor do método.
- **Regra importante**: se o nome do método **iniciar com `<`**, então ele **deve ser `<init>`**,
  representando um método de **iniciação (construtor) de instância**, e o descritor deve retornar
  `V`.

#### CONSTANT_InterfaceMethodref_info — método declarado em uma **interface**

```c
CONSTANT_InterfaceMethodref_info {
    u1 tag;                    // valor 11
    u2 class_index;
    u2 name_and_type_index;
}
```

- Idêntica à `Methodref`, mas `class_index` aponta para uma **interface**.

#### CONSTANT_NameAndType_info — nome + descritor, **sem** dizer a que classe pertence

```c
CONSTANT_NameAndType_info {
    u1 tag;                // valor 12
    u2 name_index;
    u2 descriptor_index;
}
```

- Representa **um field ou método sem indicar a classe ou interface a que pertence**.
- `name_index` → `CONSTANT_Utf8_info` com o **nome simples** do field/método, ou ainda o nome do
  método especial **`<init>`**.
- `descriptor_index` → `CONSTANT_Utf8_info` com um **descritor válido de campo ou de método**.

> Nota do material: **`<init>` (*instance initialization method*)** é derivado do método
> construtor da classe e é chamado via a instrução especial **`invokespecial`** para iniciar uma
> instância da classe em questão.

**Diagrama da cadeia de indireções** (muito cobrado):

```
CONSTANT_Methodref_info
   ├── class_index ─────────────► CONSTANT_Class_info
   │                                  └── name_index ──► CONSTANT_Utf8_info  "java/io/PrintStream"
   └── name_and_type_index ─────► CONSTANT_NameAndType_info
                                      ├── name_index ───────► CONSTANT_Utf8_info  "println"
                                      └── descriptor_index ─► CONSTANT_Utf8_info  "(Ljava/lang/String;)V"
```

Ou seja: para resolver `System.out.println("Hello")`, a JVM percorre **até 5 entradas** do pool.
Tudo é **simbólico** (por nome), e a resolução para endereços reais acontece em tempo de
execução — é isso que permite ligação dinâmica e carregamento tardio de classes.

> ⚠️ **Pegadinha de prova**
> - `Fieldref`/`Methodref` **não contêm o nome em texto**; contêm **dois índices**.
> - `NameAndType` **não** diz a que classe o membro pertence — essa informação está no
>   `class_index` do `Fieldref`/`Methodref`.
> - `CONSTANT_Class_info` tem **um só** índice (`name_index`); quem tem dois é
>   `Fieldref`/`Methodref`/`InterfaceMethodref`/`NameAndType`.

### 5.3 CONSTANT_Utf8_info e o Modified UTF-8

```c
CONSTANT_Utf8_info {
    u1 tag;              // valor 1
    u2 length;
    u1 bytes[length];
}
```

- Representa **valores string constantes, inclusive Unicode**.
- **`length` indica o número de BYTES no array `bytes`** — **não** o número de caracteres da
  string (um caractere pode ocupar 1, 2 ou 3 bytes). E a string **não termina com o caractere
  nulo** (não é ASCIIZ como em C).
- `bytes` contém os bytes da string. Restrição: **nenhum byte pode ter valor zero nem estar no
  intervalo `0xF0` a `0xFF`**, isto é, `[240, 255]`.

**Modified UTF-8.** Java usa uma **versão modificada do padrão UTF-8**, chamada *Modified UTF-8*.
Usa códigos de **1, 2 ou 3 bytes** e **não utiliza códigos de 4 bytes** do formato UTF-8 padrão.

**1 byte** — caracteres no intervalo `'\u0001'` a `'\u007F'`, isto é `[1, 127]`:

| bit 7 | bits 6–0 |
|---|---|
| `0` | bits 6-0 do caractere |

**2 bytes** — **o zero (null)** e caracteres no intervalo `'\u0080'` a `'߿'`, isto é
`[128, 2047]`, formados pelo par `x`, `y`:

| byte | bits |
|---|---|
| `x` | `1 1 0` + bits 10-6 |
| `y` | `1 0` + bits 5-0 |

O caractere é reconstruído por:

```c
((x & 0x1f) << 6) + (y & 0x3f)
```

**3 bytes** — caracteres no intervalo `'ࠀ'` a `'￿'`, isto é `[2048, 65535]`, formados
por `x`, `y`, `z`:

| byte | bits |
|---|---|
| `x` | `1 1 1 0` + bits 15-12 |
| `y` | `1 0` + bits 11-6 |
| `z` | `1 0` + bits 5-0 |

O caractere é reconstruído por:

```c
((x & 0xf) << 12) + ((y & 0x3f) << 6) + (z & 0x3f)
```

> Nota do material: **caracteres suplementares (maiores que `0xFFFF`) em Java são representados
> por dois blocos de 3 bytes** (o par surrogate UTF-16, cada metade codificada em 3 bytes), **ao
> invés da representação padrão de UTF-8 de 4 bytes**. Logo, um caractere suplementar ocupa
> **6 bytes** no `.class`.

**Exemplo prático de decodificação.** A string `"Oi"` seria:

```
01 00 02 4F 69
│  │     │  └── 'i' = 0x69
│  │     └───── 'O' = 0x4F
│  └─────────── length = 2
└────────────── tag = 1 (CONSTANT_Utf8)
```

E o caractere `'é'` (`é`, 233 decimal, na faixa [128, 2047]) ocupa **2 bytes**:
`x = 0xC3`, `y = 0xA9`. Conferindo: `((0xC3 & 0x1F) << 6) + (0xA9 & 0x3F) = (3 << 6) + 41 =
192 + 41 = 233` ✔.

> ⚠️ **Pegadinha de prova**
> - "`length` é o número de caracteres da string." → **FALSO**: é o número de **bytes**.
> - "As strings do pool terminam em `\0`, como em C." → **FALSO**.
> - "O caractere nulo é codificado com 1 byte igual a 0." → **FALSO**: em Modified UTF-8 o
>   `\u0000` é codificado em **2 bytes** (`0xC0 0x80`), justamente para que **nenhum byte zero**
>   apareça no meio da string.
> - "Java usa UTF-8 padrão no `.class`." → **FALSO**: usa **Modified UTF-8**, sem sequências de
>   4 bytes.

### 5.4 Constantes literais: String, Integer, Float, Long, Double

#### CONSTANT_String_info

```c
CONSTANT_String_info {
    u1 tag;            // valor 8
    u2 string_index;
}
```

- Representa **objetos constantes do tipo `String`**.
- `string_index` é índice válido para `constant_pool` → **`CONSTANT_Utf8_info`** com a sequência
  de caracteres com a qual o objeto `String` será iniciado.

> ⚠️ Ou seja: `CONSTANT_String_info` **não guarda os caracteres**; ela **aponta** para uma
> `CONSTANT_Utf8_info`. A distinção entre "a string como objeto Java" (`String`) e "a sequência
> de bytes" (`Utf8`) é exatamente essa.

#### CONSTANT_Integer_info

```c
CONSTANT_Integer_info {
    u1 tag;      // valor 3
    u4 bytes;
}
```

- Representa uma **constante inteira de 4 bytes**; `bytes` contém o valor da constante `int`
  em **big-endian**.

#### CONSTANT_Float_info

```c
CONSTANT_Float_info {
    u1 tag;      // valor 4
    u4 bytes;
}
```

- Representa uma **constante de ponto flutuante de 4 bytes**; `bytes` contém o valor `float` em
  **big-endian**, no formato de **precisão simples do padrão IEEE 754**.

#### CONSTANT_Long_info

```c
CONSTANT_Long_info {
    u1 tag;            // valor 5
    u4 high_bytes;     // unsigned
    u4 low_bytes;      // unsigned
}
```

- Representa uma **constante inteira de 8 bytes**, armazenada em ordem **big-endian**.
- **Ocupa dois índices na tabela `constant_pool`.**
- O valor `long` armazenado é dado pela expressão:

```c
((long) high_bytes << 32) + low_bytes
```

#### CONSTANT_Double_info

```c
CONSTANT_Double_info {
    u1 tag;            // valor 6
    u4 high_bytes;     // unsigned
    u4 low_bytes;      // unsigned
}
```

- Representa uma **constante de ponto flutuante de 8 bytes**, em **big-endian**, no formato de
  **dupla precisão IEEE 754**.
- **Ocupa dois índices na `constant_pool`.**
- O valor é inicialmente convertido em uma constante inteira `long` pela expressão:

```c
long bits = ((long) high_bytes << 32) + low_bytes;
```

> ⚠️ **Pegadinha de prova**
> - Apenas **`Long` e `Double`** ocupam dois índices. `String`, `Integer` e `Float` ocupam **um**.
> - `Integer` e `Float` têm **a mesma forma** (`tag` + `u4 bytes`) — o que muda é **a
>   interpretação** dos 4 bytes (complemento de 2 vs. IEEE 754).
> - `Long` e `Double` são gravados como **dois `u4`** (`high_bytes`, `low_bytes`), **não** como
>   um `u8`.

### 5.5 Reconstrução dos valores float e double a partir dos bits

#### Float (precisão simples, 32 bits)

O valor representado é inicialmente convertido em uma **constante inteira `bits`**. Então:

- se `bits == 0x7f800000` → o valor float é **+∞** (infinito positivo);
- se `bits == 0xff800000` → o valor float é **−∞** (infinito negativo);
- se `bits` está na faixa `0x7f800001`…`0x7fffffff` **ou** `0xff800001`…`0xffffffff` → o valor é
  **NaN**;
- caso contrário, sejam `s`, `e`, `m` computados como:

```c
int s = ((bits >> 31) == 0) ? 1 : -1;            // sinal
int e = ((bits >> 23) & 0xff);                   // expoente (8 bits)
int m = (e == 0) ?
        (bits & 0x7fffff) << 1 :                 // subnormal
        (bits & 0x7fffff) | 0x800000;            // normal: recoloca o bit implícito
```

e o valor float é o resultado da expressão:

```
valor = s · m · 2^(e − 150)
```

> Observação do material: **o expoente apresentado na especificação é excedente a 150, mas o
> valor definido pelo IEEE é excedente a 127**. A razão: o IEEE define
> `valor = s · 1,mantissa · 2^(e−127)`, com mantissa fracionária de 23 bits. Como a fórmula da
> JVM usa `m` como **inteiro** de 24 bits (já multiplicado por 2²³), é preciso compensar:
> `127 + 23 = 150`.

#### Double (dupla precisão, 64 bits)

Primeiro monta-se `bits = ((long) high_bytes << 32) + low_bytes`. Então:

- se `bits == 0x7ff0000000000000L` → **+∞**;
- se `bits == 0xfff0000000000000L` → **−∞**;
- se `bits` está na faixa `0x7ff0000000000001L`…`0x7fffffffffffffffL` **ou**
  `0xfff0000000000001L`…`0xffffffffffffffffL` → **NaN**;
- caso contrário:

```c
int  s = ((bits >> 63) == 0) ? 1 : -1;               // sinal
int  e = (int)((bits >> 52) & 0x7ffL);               // expoente (11 bits)
long m = (e == 0) ?
         (bits & 0xfffffffffffffL) << 1 :            // subnormal
         (bits & 0xfffffffffffffL) | 0x10000000000000L;  // normal
```

e o valor double é:

```
valor = s · m · 2^(e − 1075)
```

> Observação do material: **o expoente apresentado na especificação é excedente a 1075, mas o
> valor definido pelo IEEE é excedente a 1023**. Novamente: `1023 + 52 = 1075`.

**Tabela-resumo dos dois formatos IEEE 754:**

| | float (32 bits) | double (64 bits) |
|---|---|---|
| Sinal | 1 bit (bit 31) | 1 bit (bit 63) |
| Expoente | 8 bits (30–23) | 11 bits (62–52) |
| Mantissa | 23 bits (22–0) | 52 bits (51–0) |
| Bias IEEE | 127 | 1023 |
| Bias na fórmula da JVM | **150** | **1075** |
| +∞ | `0x7F800000` | `0x7FF0000000000000` |
| −∞ | `0xFF800000` | `0xFFF0000000000000` |

**Exemplo concreto**: `100.0f` em IEEE 754 é `0x42C80000`.
`s = +1`; `e = (0x42C80000 >> 23) & 0xFF = 0x85 = 133`; `m = (0x480000) | 0x800000 = 0xC80000 =
13.107.200`. Então `valor = 13.107.200 × 2^(133−150) = 13.107.200 / 131.072 = 100,0` ✔

> ⚠️ **Pegadinha de prova**
> - **Existem muitos padrões de bits que representam NaN**, não apenas um.
> - O expoente **zero** indica número **subnormal** (sem bit implícito 1) — por isso o
>   `<< 1` no lugar do `| 0x800000`.
> - Os bias usados na fórmula da JVM (**150** e **1075**) são diferentes dos bias do IEEE
>   (**127** e **1023**), e essa diferença é **intencional** (mantissa tratada como inteiro).

---

## 6. A tabela fields (field_info)

Cada campo (variável de classe ou de instância) é descrito por uma estrutura `field_info`.
**Dois campos na mesma classe não podem ter o mesmo nome** (mesmo que tenham tipos diferentes).

```c
field_info {
    u2             access_flags;
    u2             name_index;
    u2             descriptor_index;
    u2             attributes_count;
    attribute_info attributes[attributes_count];
}
```

| Campo | Tipo | Significado |
|---|---|---|
| `access_flags` | `u2` | Máscara de permissões/propriedades do campo |
| `name_index` | `u2` | → `CONSTANT_Utf8_info` com o **nome simples** do campo (identificador Java) |
| `descriptor_index` | `u2` | → `CONSTANT_Utf8_info` com o **descritor de campo** válido |
| `attributes_count` | `u2` | Número de atributos do campo |
| `attributes[]` | `attribute_info` | Atributos (ex.: `ConstantValue`, `Deprecated`, `Synthetic`) |

### Flags de acesso de campo

| Nome do flag | Valor | Interpretação |
|---|---|---|
| `ACC_PUBLIC` | `0x0001` | Declarado público: pode ser acessado de fora do pacote |
| `ACC_PRIVATE` | `0x0002` | Declarado privado: contexto restrito à definição da classe |
| `ACC_PROTECTED` | `0x0004` | Declarado protegido: pode ser usado na classe e nas subclasses |
| `ACC_STATIC` | `0x0008` | Declarado estático: **variável de classe**, não de instância |
| `ACC_FINAL` | `0x0010` | Declarado final: não pode ter seu valor alterado após a iniciação |
| `ACC_VOLATILE` | `0x0040` | Declarado volátil: **não pode ser colocado em cache**; a thread que o usa deve conciliar sua cópia com a mestra toda vez |
| `ACC_TRANSIENT` | `0x0080` | Declarado transiente: **não pode ser lido ou gravado por um gerente de objetos persistente** (serialização) |
| `ACC_SYNTHETIC` | `0x1000` | Declarado sintético: **não presente no código-fonte** (código gerado) |
| `ACC_ENUM` | `0x4000` | Declarado como um **elemento de uma enum** |

**Todos os demais bits são reservados para uso futuro e devem ser definidos como zero.**

Exemplos:

| Declaração Java | access_flags |
|---|---|
| `int x;` | `0x0000` |
| `public int x;` | `0x0001` |
| `private static int c;` | `0x000A` (`0x0002 \| 0x0008`) |
| `public static final int MAX = 10;` | `0x0019` (`0x0001 \| 0x0008 \| 0x0010`) |
| `private volatile boolean flag;` | `0x0042` |
| `private transient String senha;` | `0x0082` |

### Atributos do campo

```c
attribute_info {
    u2 attribute_name_index;
    u4 attribute_length;
    u1 info[attribute_length];
}
```

- A implementação da JVM **deve ignorar em silêncio qualquer atributo que não reconheça**.
- **Toda implementação deve reconhecer e ler corretamente o atributo `ConstantValue`.**

> ⚠️ **Pegadinha de prova**
> - `field_info` **não tem** o flag `ACC_ABSTRACT` nem `ACC_SYNCHRONIZED` nem `ACC_NATIVE` —
>   esses são só de método.
> - `ACC_VOLATILE` (0x0040) em campo tem o mesmo valor de `ACC_BRIDGE` (0x0040) em método;
>   `ACC_TRANSIENT` (0x0080) tem o mesmo valor de `ACC_VARARGS` (0x0080).
> - "Dois campos com o mesmo nome e tipos diferentes são permitidos na mesma classe." →
>   **FALSO** (para **métodos**, sim: nome igual com descritores diferentes é sobrecarga; para
>   **campos**, não).

---

## 7. A tabela methods (method_info)

**Cada método** — inclusive o método de iniciação de **instância** (`<init>`), de **classe** ou
de **interface** (`<clinit>`) — é descrito por uma estrutura `method_info`.
Regra: **métodos na mesma classe não podem ter o mesmo nome E o mesmo descritor** (podem ter o
mesmo nome com descritores diferentes → **sobrecarga**).

```c
u2          methods_count;
method_info methods[methods_count];

method_info {
    u2             access_flags;
    u2             name_index;
    u2             descriptor_index;
    u2             attributes_count;
    attribute_info attributes[attributes_count];
}
```

Repare: **`method_info` tem exatamente os mesmos quatro campos de `field_info`** — o que muda é
a interpretação das flags e dos atributos possíveis.

### Flags de acesso de método

| Nome do flag | Valor | Interpretação |
|---|---|---|
| `ACC_PUBLIC` | `0x0001` | Público: pode ser acessado de fora do pacote |
| `ACC_PRIVATE` | `0x0002` | Privado: acesso restrito à definição da classe |
| `ACC_PROTECTED` | `0x0004` | Protegido: pode ser chamado na classe e subclasses |
| `ACC_STATIC` | `0x0008` | Estático: **método de classe** (chamado sem referir um objeto) |
| `ACC_FINAL` | `0x0010` | Final: **não pode ser sobrescrito** em subclasses |
| `ACC_SYNCHRONIZED` | `0x0020` | Sincronizado: **requer um monitor** antes de ser executado (thread) |
| `ACC_BRIDGE` | `0x0040` | Método **bridge**, gerado por um compilador (genéricos) |
| `ACC_VARARGS` | `0x0080` | Declarado com um **número variável de argumentos** |
| `ACC_NATIVE` | `0x0100` | Nativo: **implementado em linguagem não Java** (C, C++, Assembly) |
| `ACC_ABSTRACT` | `0x0400` | Abstrato: **sem definição**, deve ser sobrescrito em uma subclasse |
| `ACC_STRICT` | `0x0800` | `strictfp`: utiliza modo de ponto flutuante **FP-strict** (não normalizado) |
| `ACC_SYNTHETIC` | `0x1000` | Sintético: **não presente no código-fonte** |

**Todos os demais bits são reservados para uso futuro e devem ser definidos como zero.**

Exemplos:

| Declaração Java | access_flags |
|---|---|
| `public static void main(String[] a)` | `0x0009` (`PUBLIC \| STATIC`) |
| `public static int soma(int a,int b)` | `0x0009` |
| `public HelloWorld()` (construtor) | `0x0001` |
| `private synchronized void f()` | `0x0022` |
| `public abstract void g();` | `0x0401` |
| `public native void h();` | `0x0101` |
| `public void v(int... x)` | `0x0081` |

> ⚠️ **Pegadinha de prova**
> - **Não existe `ACC_VOLATILE` nem `ACC_TRANSIENT` em método**, e **não existe `ACC_NATIVE`,
>   `ACC_ABSTRACT`, `ACC_SYNCHRONIZED`, `ACC_STRICT` nem `ACC_BRIDGE` em campo.**
> - Note que **não existe `0x0200` (`ACC_INTERFACE`) em método** — esse é da classe.
> - `ACC_ABSTRACT` (0x0400) e `ACC_NATIVE` (0x0100) **implicam ausência do atributo `Code`**.

### Nome e descritor do método

- **`u2 name_index`** → `CONSTANT_Utf8_info` representando um **nome especial de método
  (`<init>` ou `<clinit>`)** ou um **nome simples** válido como nome de método.
- **`u2 descriptor_index`** → `CONSTANT_Utf8_info` representando um **descritor de método
  válido**.

| Nome especial | Significado | Como é chamado |
|---|---|---|
| `<init>` | Método de **iniciação de instância** (construtor) | `invokespecial`, ao criar o objeto |
| `<clinit>` | Método de **iniciação de classe/interface** (blocos `static { }` e inicializadores de campos estáticos) | Invocado **pela própria JVM**, nunca por bytecode explícito |

### Atributos do método

Mesma estrutura genérica `attribute_info`. Regras do material:

- A implementação da JVM **deve ignorar em silêncio qualquer atributo que não reconheça**.
- **Toda implementação deve reconhecer e ler corretamente os atributos `Code`, `Exceptions` e
  `SourceFile`.**

---

## 8. Atributos (attribute_info)

### 8.1 Estrutura genérica e regra do "ignorar em silêncio"

Atributos são **usados nas estruturas `ClassFile`, `field_info`, `method_info` e
`Code_attribute`**. Eles podem ser **predefinidos na especificação da JVM** ou **definidos por
um compilador Java** (atributos proprietários).

```c
attribute_info {
    u2 attribute_name_index;
    u4 attribute_length;
    u1 info[attribute_length];
}
```

- **`u2 attribute_name_index`** — índice válido para `constant_pool` → `CONSTANT_Utf8_info`
  representando **o nome do atributo** (é assim que se sabe se é `Code`, `SourceFile`, etc.).
- **`u4 attribute_length`** — indica o **tamanho, em bytes, do restante do atributo**. Ele **NÃO
  inclui os 6 bytes** que contêm o índice do nome (2 bytes) e o comprimento do atributo
  (4 bytes).

> ⚠️ **Pegadinha de prova**: `attribute_length` é `u4` (**4 bytes**), enquanto quase todos os
> outros "counts" do formato são `u2`. E ele **exclui** os 6 bytes do cabeçalho. Assim, um
> atributo ocupa `6 + attribute_length` bytes no total.

**Por que a regra "ignorar em silêncio" importa?** Ela é o mecanismo de **extensibilidade e
compatibilidade retroativa** do formato: como cada atributo declara o próprio comprimento, uma
JVM antiga consegue **pular** (`fseek` de `attribute_length` bytes) um atributo que não conhece,
sem quebrar a leitura do resto do arquivo. **Atributos proprietários não podem afetar a
semântica do arquivo `.class`** — apenas fornecem informação adicional de descrição.

### Atributos predefinidos na especificação `.class`

Lista do material:

| Atributo | Obrigatoriedade |
|---|---|
| `ConstantValue` | **A JVM deve implementar** |
| `Code` | **A JVM deve implementar** |
| `Exceptions` | **A JVM deve implementar** |
| `InnerClasses` | Obrigatório a partir da **JVM Java 2** e superior |
| `Synthetic` | Obrigatório a partir da **JVM Java 2** e superior |
| `Deprecated` | **Opcional** |
| `SourceFile` | **Opcional** |
| `LineNumberTable` | **Opcional** |
| `LocalVariableTable` | **Opcional** |

Regra geral para os opcionais: **a JVM pode ler esses atributos ou ignorá-los.**

> ⚠️ **Pegadinha de prova**: `SourceFile`, `LineNumberTable`, `LocalVariableTable` e
> `Deprecated` são **opcionais** e existem essencialmente para **depuração/documentação** — o
> programa roda perfeitamente sem eles (é o que faz `javac -g:none`). Já `Code`,
> `ConstantValue` e `Exceptions` são **obrigatórios**. Atenção ao slide 43, que afirma que
> toda implementação deve reconhecer **`Code`, `Exceptions` e `SourceFile`** — para a prova,
> siga o que o professor listou no slide 45: obrigatórios = `Code`, `ConstantValue`,
> `Exceptions` (+ `InnerClasses` e `Synthetic` a partir do Java 2).

### 8.2 Atributo ConstantValue

**Onde aparece:** na tabela `attributes` de uma estrutura **`field_info`**.

**Para que serve:** **inicializa variáveis (implícitas ou explícitas) estáticas**.

Regras:

- **Somente um valor é possível por variável** (no máximo um `ConstantValue` por campo).
- É utilizado para **iniciar a variável antes da chamada do método de iniciação de classe ou
  interface** (`<clinit>`) que contém a variável.
- A estrutura aponta para uma `CONSTANT_<tipo>_info` que contém a constante a ser utilizada na
  iniciação.
- **Se `field_info` contém um atributo `ConstantValue` associado a uma variável NÃO ESTÁTICA, a
  JVM deve ignorá-lo em silêncio.**
- **Toda JVM deve reconhecer atributos `ConstantValue`.**

**Formato:**

```c
ConstantValue_attribute {
    u2 attribute_name_index;   // -> CONSTANT_Utf8_info com a string "ConstantValue"
    u4 attribute_length;       // SEMPRE o valor 2
    u2 constantvalue_index;    // -> CONSTANT_<tipo>_info com o valor
}
```

| Campo | Regra |
|---|---|
| `attribute_name_index` | índice para `constant_pool` → `CONSTANT_Utf8_info` com a string **"ConstantValue"** |
| `attribute_length` | **assume sempre o valor 2** |
| `constantvalue_index` | índice para `constant_pool` com uma `CONSTANT_<tipo>_info` representando o valor constante associado ao atributo |

**Tipo do campo × tipo da estrutura apontada:**

| Tipo do campo | Tipo da estrutura no pool |
|---|---|
| `long` | `CONSTANT_Long` |
| `float` | `CONSTANT_Float` |
| `double` | `CONSTANT_Double` |
| `int`, `short`, `char`, `byte`, `boolean` | **`CONSTANT_Integer`** |
| `String` | `CONSTANT_String` |

**Exemplo:**

```java
public class Config {
    public static final int MAX = 100;       // tem ConstantValue -> CONSTANT_Integer 100
    public static final String NOME = "SB";  // tem ConstantValue -> CONSTANT_String "SB"
    public static int contador = 5;          // NÃO tem ConstantValue (não é final):
                                             // é inicializado dentro de <clinit>
    public final int inst = 7;               // não estático: se houvesse ConstantValue,
                                             // seria IGNORADO em silêncio
}
```

Saída típica de `javap -v Config.class` para o primeiro campo:

```
  public static final int MAX;
    descriptor: I
    flags: ACC_PUBLIC, ACC_STATIC, ACC_FINAL
    ConstantValue: int 100
```

> ⚠️ **Pegadinha de prova**
> - `ConstantValue` com `attribute_length` diferente de **2** é inválido — o valor é **sempre 2**
>   (o tamanho de `constantvalue_index`).
> - `boolean`, `byte`, `short` e `char` usam **`CONSTANT_Integer`** — **não existem**
>   `CONSTANT_Boolean`, `CONSTANT_Byte`, `CONSTANT_Short` nem `CONSTANT_Char` no pool.
> - Em campo **não estático**, o `ConstantValue` é **ignorado em silêncio** (não gera erro!).
> - `ConstantValue` é atributo **de `field_info`**, nunca de `method_info` nem do `ClassFile`.

### 8.3 Atributo Code

**Onde aparece:** na tabela `attributes` de uma estrutura **`method_info`**.

Características:

- **Atributo de tamanho variável.**
- **Somente um atributo `Code` é possível por método.**
- **Método não nativo e não abstrato:** contém **o código da JVM (bytecodes)** e informações
  auxiliares para o método, método de iniciação de instância, de classe ou de interface.
- **Método nativo ou abstrato: NÃO possui esse atributo de código.**
- **Toda JVM deve reconhecer o atributo `Code`.**

**Formato completo:**

```c
Code_attribute {
    u2 attribute_name_index;
    u4 attribute_length;
    u2 max_stack;
    u2 max_locals;
    u4 code_length;
    u1 code[code_length];
    u2 exception_table_length;
    {   u2 start_pc;
        u2 end_pc;
        u2 handler_pc;
        u2 catch_type;
    } exception_table[exception_table_length];
    u2 attributes_count;
    attribute_info attributes[attributes_count];
}
```

| Campo | Tipo | Significado |
|---|---|---|
| `attribute_name_index` | `u2` | → `CONSTANT_Utf8_info` com a string **"Code"** |
| `attribute_length` | `u4` | Número de bytes do atributo, **exceto os 6 bytes iniciais** |
| `max_stack` | `u2` | **Profundidade máxima da pilha de operandos** durante a execução do método |
| `max_locals` | `u2` | **Número de variáveis locais (incluindo os parâmetros)** no vetor de variáveis locais |
| `code_length` | `u4` | Número de bytes no array `code` — **deve ser maior que zero** |
| `code[]` | `u1[]` | Os **bytecodes da JVM** que implementam o método |
| `exception_table_length` | `u2` | Número de entradas na `exception_table` |
| `exception_table[]` | struct | Manipuladores de exceção |
| `attributes_count` | `u2` | Número de atributos **do atributo Code** |
| `attributes[]` | `attribute_info` | Tipicamente `LineNumberTable` e `LocalVariableTable` |

#### A exception_table

Cada entrada descreve **um manipulador das exceções** que podem ocorrer no código JVM contido no
array `code`:

| Campo | Significado |
|---|---|
| `u2 start_pc` | início da região protegida |
| `u2 end_pc` | fim (exclusivo) da região protegida — o manipulador está **ativo para os índices `[start_pc, end_pc)`** de `code` |
| `u2 handler_pc` | índice para `code` indicando o **bytecode inicial do manipulador** |
| `u2 catch_type` | classe da exceção capturada, ou **0** |

Sobre `catch_type`:

- **Se não nulo** (cláusula `catch` de um comando `try`): é um **índice válido para
  `constant_pool`** → `CONSTANT_Class_info` representando a **classe de exceções a ser capturada**
  pelo manipulador (`Throwable` ou uma de suas subclasses).
- **Se nulo (zero)** (cláusula **`finally`** de um comando `try`): o manipulador é chamado
  **para todo tipo de exceção** que pode ser lançado no `try` em questão.

Repare no intervalo: **`[start_pc, end_pc)`** — fechado no início, **aberto no fim**. `start_pc`
está protegido; `end_pc` **não** está.

#### Atributos do atributo Code

- Pode existir um **número qualquer de atributos opcionais (de depuração)** associados ao
  atributo `Code`; **a JVM pode ignorá-los em silêncio**.
- **`LineNumberTable`** — associa posições no array `code` com **linhas do arquivo fonte**.
- **`LocalVariableTable`** — utilizado por **debuggers** para determinar o valor de uma variável
  local durante a execução.
- **Atributos proprietários** — **não podem afetar a semântica** do arquivo `.class`; apenas
  fornecem informação adicional de descrição do arquivo.

> ⚠️ **Pegadinha de prova**
> - `Code` é **atributo aninhado**: um `attribute_info` que, dentro de si, contém **outra**
>   tabela de `attribute_info`. `LineNumberTable` e `LocalVariableTable` ficam dentro de `Code`,
>   **não** diretamente em `method_info`.
> - `code_length` é **`u4`**, mas `max_stack`, `max_locals` e os campos da `exception_table` são
>   **`u2`**.
> - "Um método abstrato tem `Code` com `code_length` = 0." → **FALSO**: ele simplesmente **não
>   tem** o atributo `Code`. E `code_length` **deve ser > 0** quando `Code` existe.
> - `max_locals` **inclui os parâmetros** e, em método de instância, também o `this` (slot 0).
> - `catch_type = 0` significa **`finally`** (captura tudo), não "nenhum manipulador".

### 8.4 Como a JVM localiza o manipulador de exceções

Algoritmo descrito no material:

1. A JVM **busca no método corrente** um manipulador aplicável (percorrendo a `exception_table`
   do `Code` desse método).
2. **Se localizado**, **desvia a execução para `handler_pc`**.
3. **Senão**, o **método corrente é terminado abruptamente**:
   - a **pilha de operandos e o vetor de variáveis locais são descartados**;
   - o **frame é desempilhado** e o controle é passado para **o método chamador** do método
     corrente.
4. A **exceção é relançada para o método chamador**, que se torna o corrente.
5. Esse processo continua até **encontrar um manipulador** ou chegar ao **final da cadeia de
   métodos chamadores**.
6. **Se nenhum manipulador adequado for encontrado, a execução da thread onde a exceção foi
   lançada é terminada.**

```
   try { ... }  ← região [start_pc, end_pc)
   catch (E e) { ... }  ← handler_pc, catch_type = índice de E

   exceção lançada
        │
        ▼
   método corrente tem handler? ──sim──► goto handler_pc
        │ não
        ▼
   descarta pilha de operandos + variáveis locais
   desempilha o frame  →  método chamador vira o corrente
        │
        └──► repete ... até o fim da cadeia → thread é terminada
```

> ⚠️ **Pegadinha de prova**: quando nenhum manipulador é encontrado, **é a thread que termina**,
> não necessariamente a JVM inteira (a JVM só encerra quando não sobram threads não-daemon).

### 8.5 Atributo Exceptions

**Onde aparece:** em estrutura **`method_info`**.

- **Atributo de tamanho variável.**
- **No máximo, um atributo `Exceptions` por método.**
- **Indica quais exceções verificadas (checked) o método pode lançar** — ou seja, é a
  representação da cláusula `throws` do Java.

```c
Exceptions_attribute {
    u2 attribute_name_index;
    u4 attribute_length;
    u2 number_of_exceptions;
    u2 exception_index_table[number_of_exceptions];
}
```

| Campo | Significado |
|---|---|
| `attribute_name_index` | → `CONSTANT_Utf8_info` com a string **"Exceptions"** |
| `attribute_length` | número de bytes do atributo, **exceto os 6 bytes iniciais** |
| `number_of_exceptions` | número de entradas na `exception_index_table` |
| `exception_index_table[]` | cada entrada é índice válido para `constant_pool` → **`CONSTANT_Class_info`** representando um **tipo de classe de exceção que o método pode lançar** (por exemplo, classe ou subclasse de `RuntimeException`, `Error` ou `Throwable`) |

Exemplo:

```java
public void ler(String f) throws java.io.IOException, InterruptedException { ... }
```

gera um `Exceptions_attribute` com `number_of_exceptions = 2` e dois índices apontando para
`CONSTANT_Class_info` de `java/io/IOException` e `java/lang/InterruptedException`.
Nesse caso, `attribute_length = 2 + 2*2 = 6`.

> ⚠️ **Pegadinha de prova**
> - **`Exceptions` ≠ `exception_table`!** `Exceptions` é um **atributo de `method_info`** e
>   representa o **`throws`**. A `exception_table` fica **dentro do atributo `Code`** e
>   representa os blocos **`try/catch/finally`**. Essa é a confusão mais cobrada do tema.
> - `exception_index_table[]` aponta para `CONSTANT_Class_info`, **não** para `Utf8` direto.

### 8.6 Atributos Deprecated e Synthetic

#### Deprecated

- **Opcional, de tamanho fixo.**
- Pode aparecer na tabela `attributes` de **`ClassFile`, `field_info` ou `method_info`**.
- **Informa ao usuário que a classe, interface, campo ou método está superado (obsoleto)**.
- **Não altera a semântica** da classe ou interface — serve para o compilador emitir avisos.

```c
Deprecated_attribute {
    u2 attribute_name_index;   // -> CONSTANT_Utf8_info com a string "Deprecated"
    u4 attribute_length;       // valor fixo em ZERO
}
```

> ⚠️ **Pegadinha de prova**: `Deprecated` tem **`attribute_length = 0`** (o atributo inteiro
> ocupa apenas 6 bytes). Compare: `ConstantValue` e `SourceFile` têm `attribute_length = 2`.

#### Synthetic

- Marca um membro **gerado pelo compilador**, que **não aparece no código-fonte** (exceto
  `<init>` e `<clinit>`). Mesmo formato de tamanho fixo do `Deprecated`
  (`attribute_length = 0`).
- Conforme o material, é **obrigatório na JVM Java 2 e superior** (junto com `InnerClasses`).
- Alternativa moderna ao atributo: o flag **`ACC_SYNTHETIC` (0x1000)**.

### 8.7 Atributo InnerClasses

**Onde aparece:** na tabela `attributes` de **`ClassFile`**. **Atributo de tamanho variável.**

Regra: se o **pool de constantes** de uma classe ou interface **refere uma classe ou interface
`C` que não é membro de um pacote** (isto é, `C` é uma classe aninhada/interna), então a
estrutura `ClassFile` **deve conter exatamente um atributo `InnerClasses`** em sua tabela
`attributes`.

```c
InnerClasses_attribute {
    u2 attribute_name_index;
    u4 attribute_length;
    u2 number_of_classes;
    {   u2 inner_class_info_index;
        u2 outer_class_info_index;
        u2 inner_name_index;
        u2 inner_class_access_flags;
    } classes[number_of_classes];
}
```

| Campo | Significado |
|---|---|
| `attribute_name_index` | → `CONSTANT_Utf8_info` com a string **"InnerClasses"** |
| `attribute_length` | número de bytes, **exceto os 6 bytes iniciais** |
| `number_of_classes` | número de entradas na tabela `classes` |
| `classes[]` | uma entrada por classe/interface aninhada referenciada |

Um **membro de uma classe ou interface aninhada terá o atributo `InnerClasses` para toda classe
envolvente e para cada membro imediato**.

Itens do array `classes`:

| Item | Significado |
|---|---|
| `u2 inner_class_info_index` | índice válido para `constant_pool` → `CONSTANT_Class_info` representando **a classe `C`**. Os outros itens dão informação sobre `C`. |
| `u2 outer_class_info_index` | **Zero** (se `C` **não é um membro**, por exemplo classe local ou anônima) ou índice válido → `CONSTANT_Class_info` representando a classe/interface **da qual `C` é membro** |
| `u2 inner_name_index` | **Zero** (se `C` é **anônima**) ou índice válido → `CONSTANT_Utf8_info` representando o **nome simples original de `C`**, como no fonte a partir do qual este arquivo foi compilado |
| `u2 inner_class_access_flags` | Máscara de bits especificando permissões de acesso e propriedades de `C` **conforme declaradas no fonte** |

**Flags de `inner_class_access_flags`:**

| Nome do flag | Valor | Interpretação |
|---|---|---|
| `ACC_PUBLIC` | `0x0001` | Marcada ou implicitamente `public` no fonte |
| `ACC_PRIVATE` | `0x0002` | Marcada `private` no fonte |
| `ACC_PROTECTED` | `0x0004` | Marcada `protected` no fonte |
| `ACC_STATIC` | `0x0008` | Marcada ou implicitamente `static` no fonte |
| `ACC_FINAL` | `0x0010` | Marcada `final` no fonte. **Não pode ser estendida** |
| `ACC_INTERFACE` | `0x0200` | É uma **interface** no fonte |
| `ACC_ABSTRACT` | `0x0400` | Marcada `abstract` no fonte. Possui apenas métodos abstratos. **Não pode ser instanciada** |

**Todos os demais bits são reservados para uso futuro e devem ser definidos como zero.**

> ⚠️ **Pegadinha de prova**
> - `InnerClasses` é atributo **do `ClassFile`**, nunca de `method_info`/`field_info`.
> - **`inner_name_index = 0` ⇒ classe ANÔNIMA**; **`outer_class_info_index = 0` ⇒ `C` não é
>   membro** (classe local ou anônima). São duas condições **diferentes**.
> - Diferentemente do `access_flags` da classe, **aqui existem** `ACC_PRIVATE`, `ACC_PROTECTED`
>   e `ACC_STATIC` — porque uma classe **aninhada** pode ser privada ou estática. E **não
>   existe** `ACC_SUPER` aqui.
> - Classes aninhadas geram arquivos `.class` separados, com nomes como `Externa$Interna.class`
>   e `Externa$1.class` (anônimas).

### 8.8 Atributo LineNumberTable

**Onde aparece:** na tabela `attributes` **do atributo `Code`**. **Opcional, tamanho variável.**

- Permite a um **debugger determinar que posições no array `code` correspondem a uma dada linha
  do arquivo fonte**.
- **Relação 1-para-1 entre um atributo `LineNumberTable` e uma linha no fonte original NÃO é
  requerida**: **múltiplos atributos `LineNumberTable` juntos podem representar uma linha**.

```c
LineNumberTable_attribute {
    u2 attribute_name_index;
    u4 attribute_length;
    u2 line_number_table_length;
    {   u2 start_pc;
        u2 line_number;
    } line_number_table[line_number_table_length];
}
```

| Campo | Significado |
|---|---|
| `attribute_name_index` | → `CONSTANT_Utf8_info` com a string **"LineNumberTable"** |
| `attribute_length` | bytes do atributo, **exceto os 6 iniciais** |
| `line_number_table_length` | número de entradas no array `line_number_table` |
| `start_pc` | índice para o array `code` correspondendo ao código que **inicia uma nova linha** no arquivo fonte original |
| `line_number` | **número dessa linha** no arquivo fonte |

É graças a esse atributo que um *stack trace* mostra `at HelloWorld.main(HelloWorld.java:5)`.
Compilando com `javac -g:none`, ele desaparece e o *stack trace* perde os números de linha.

### 8.9 Atributo LocalVariableTable

**Onde aparece:** na tabela `attributes` **do atributo `Code`**. **Opcional, tamanho variável.**

- Permite a um **debugger determinar o valor de uma dada variável local durante a execução de um
  método**.
- **No máximo, um atributo `LocalVariableTable` por variável local em `Code`.**

```c
LocalVariableTable_attribute {
    u2 attribute_name_index;
    u4 attribute_length;
    u2 local_variable_table_length;
    {   u2 start_pc;
        u2 length;
        u2 name_index;
        u2 descriptor_index;
        u2 index;
    } local_variable_table[local_variable_table_length];
}
```

Cada entrada em `local_variable_table` indica:

- uma **faixa de índices no array `code`** na qual uma dada variável local **mantém o mesmo
  valor** (isto é, está "viva");
- o **índice dessa variável local no array de variáveis locais** do frame corrente no qual ela
  pode ser encontrada.

Itens do array:

| Item | Significado |
|---|---|
| `u2 start_pc` e `u2 length` | a variável local possui o mesmo valor no intervalo **`[start_pc, start_pc+length]`** de offsets de `code`; esses offsets correspondem a **índices válidos em `code` que apontam para opcodes** da JVM |
| `u2 name_index` | → `CONSTANT_Utf8_info` com um **nome válido de variável local**, armazenado como **nome simples** |
| `u2 descriptor_index` | → `CONSTANT_Utf8_info` com um **descritor de campo válido** com o **tipo da variável local** no programa fonte |
| `u2 index` | **índice no array de variáveis locais** do frame corrente correspondente a essa variável; **se do tipo `double` ou `long`, a variável ocupa as posições `index` e `index+1`** |

> ⚠️ **Pegadinha de prova**
> - `long` e `double` ocupam **DOIS slots** no vetor de variáveis locais (`index` e `index+1`) —
>   exatamente como ocupam **dois índices** no `constant_pool`. É a mesma regra de "valores de
>   categoria 2".
> - Em um **método de instância**, o slot **0** é sempre **`this`**; em um método **estático**,
>   o slot 0 já é o **primeiro parâmetro**.
> - `LocalVariableTable` usa `descriptor_index` (descritor de **campo**), mesmo descrevendo
>   variável local.
> - `LineNumberTable` e `LocalVariableTable` ficam dentro de **`Code`**, não de `method_info`.

### 8.10 Atributo SourceFile

**Onde aparece:** na tabela `attributes` da estrutura **`ClassFile`**. **Opcional, tamanho
fixo.**

- Guarda o **nome (relativo) do fonte a partir do qual a classe foi compilada**.
- **Apenas um atributo `SourceFile` pode aparecer por `ClassFile`.**

```c
SourceFile_attribute {
    u2 attribute_name_index;   // -> CONSTANT_Utf8_info com a string "SourceFile"
    u4 attribute_length;       // assume SEMPRE o valor 2
    u2 sourcefile_index;       // -> CONSTANT_Utf8_info com o nome do fonte
}
```

| Campo | Regra |
|---|---|
| `attribute_name_index` | → `CONSTANT_Utf8_info` com a string **"SourceFile"** |
| `attribute_length` | **assume sempre o valor 2** |
| `sourcefile_index` | → `CONSTANT_Utf8_info` representando uma string com o **nome do fonte** |

> ⚠️ **Pegadinha de prova**
> - `sourcefile_index` guarda **apenas o nome do arquivo** (ex.: `"HelloWorld.java"`), **sem
>   caminho de diretório** — é um nome **relativo**.
> - `SourceFile` é atributo **do `ClassFile`**, e tem `attribute_length` **sempre 2** — igual ao
>   `ConstantValue` (que, porém, é de `field_info`).

### 8.11 Tabela-resumo: onde cada atributo pode aparecer

| Atributo | ClassFile | field_info | method_info | Code | attribute_length | Obrigatório? |
|---|:---:|:---:|:---:|:---:|---|---|
| `ConstantValue` | | ✔ | | | **2** (fixo) | **Sim** |
| `Code` | | | ✔ | | variável | **Sim** |
| `Exceptions` | | | ✔ | | variável | **Sim** |
| `InnerClasses` | ✔ | | | | variável | Sim (Java 2+) |
| `Synthetic` | ✔ | ✔ | ✔ | | **0** (fixo) | Sim (Java 2+) |
| `Deprecated` | ✔ | ✔ | ✔ | | **0** (fixo) | Opcional |
| `SourceFile` | ✔ | | | | **2** (fixo) | Opcional |
| `LineNumberTable` | | | | ✔ | variável | Opcional |
| `LocalVariableTable` | | | | ✔ | variável | Opcional |

> 🟦 **Divergência Java 8 — atributos que a tabela acima não lista**
>
> A tabela cobre os atributos da **1ª/2ª edição** da JVMS. Um `.class` real de **Java 8**
> (`major_version = 52`) carrega ainda:
>
> | Atributo | Onde | Desde | Para quê |
> |---|---|:---:|---|
> | `StackMapTable` | `Code` | Java 6 | Verificação por *type checking*. **Obrigatório** na prática em `major ≥ 50` |
> | `BootstrapMethods` | `ClassFile` | Java 7 | **Obrigatório** se a classe usar `invokedynamic` (toda classe com lambda) |
> | `Signature` | classe/campo/método | Java 5 | Guarda a assinatura **genérica** (apagada pelo *erasure*) |
> | `RuntimeVisibleAnnotations` / `RuntimeInvisibleAnnotations` | classe/campo/método | Java 5 | Anotações |
> | `RuntimeVisibleTypeAnnotations` / `RuntimeInvisibleTypeAnnotations` | vários | **Java 8** | Anotações **de tipo** (JSR 308) |
> | `MethodParameters` | `method_info` | **Java 8** | Nomes dos parâmetros (`javac -parameters`) |
> | `EnclosingMethod` | `ClassFile` | Java 5 | Classe local/anônima |
>
> Também é do **Java 8** a flag `ACC_MANDATED` (`0x8000`), usada em `MethodParameters`.
>
> **Por que isso não quebra nada:** pela regra da §8.1, a JVM **ignora em silêncio** atributos que
> não reconhece. É exatamente por isso que esses atributos puderam ser acrescentados sem invalidar
> JVMs antigas — e é isso que uma questão de prova sobre "atributos desconhecidos" está cobrando.
>
> 🟥 Uma correção à própria tabela: os slides 43 e 45 se contradizem sobre obrigatoriedade.
> `ConstantValue` é **opcional** (só é obrigatório *interpretá-lo* se estiver presente num campo
> `static`); `Code` é obrigatório **exceto** em métodos `abstract` e `native`; `Exceptions` é
> **opcional**; `SourceFile` é **opcional**.

---

## 9. Exemplos completos: do Java ao `.class`

### 9.1 HelloWorld: fonte, dump hexadecimal e javap -c -verbose

#### Código-fonte (do material)

```java
/*
   The HelloWorld class is an application that displays
   "Hello World!" to the standard output.
*/
public class HelloWorld {

    // Display "Hello World!"
    public static void main(String args[]) {
        System.out.println("Hello World!");
    }
}
```

#### Início do dump hexadecimal (`xxd HelloWorld.class | head`)

```
00000000: cafe babe 0000 0034 001d 0a00 0600 0f09  .......4........
00000010: 0010 0011 0800 120a 0013 0014 0700 1507  ................
00000020: 0016 0100 063c 696e 6974 3e01 0003 2829  .....<init>...()
00000030: 5601 0004 436f 6465 0100 0f4c 696e 654e  V...Code...LineN
00000040: 756d 6265 7254 6162 6c65 0100 046d 6169  umberTable...mai
00000050: 6e01 0016 285b 4c6a 6176 612f 6c61 6e67  n...([Ljava/lang
00000060: 2f53 7472 696e 673b 2956 0100 0a53 6f75  /String;)V...Sou
00000070: 7263 6546 696c 6501 000f 4865 6c6c 6f57  rceFile...HelloW
00000080: 6f72 6c64 2e6a 6176 61                   orld.java
```

**Leitura byte a byte do cabeçalho** (este é o tipo de questão que cai):

| Bytes | Campo | Valor | Interpretação |
|---|---|---|---|
| `CA FE BA BE` | `magic` | `0xCAFEBABE` | assinatura válida |
| `00 00` | `minor_version` | 0 | |
| `00 34` | `major_version` | 52 | **Java SE 8** |
| `00 1D` | `constant_pool_count` | 29 | logo há **28 entradas** no pool |
| `0A` | tag da entrada #1 | 10 | `CONSTANT_Methodref` |
| `00 06` | `class_index` | 6 | → `CONSTANT_Class_info` #6 |
| `00 0F` | `name_and_type_index` | 15 | → `CONSTANT_NameAndType_info` #15 |
| `09` | tag da entrada #2 | 9 | `CONSTANT_Fieldref` |
| `00 10 00 11` | | 16, 17 | → `#16.#17` |
| `08` | tag da entrada #3 | 8 | `CONSTANT_String` |
| `00 12` | `string_index` | 18 | → `CONSTANT_Utf8_info` #18 |
| `0A 00 13 00 14` | entrada #4 | Methodref `#19.#20` | `println` |
| `07 00 15` | entrada #5 | `CONSTANT_Class` → #21 | `HelloWorld` |
| `07 00 16` | entrada #6 | `CONSTANT_Class` → #22 | `java/lang/Object` |
| `01 00 06 3C 69 6E 69 74 3E` | entrada #7 | `Utf8`, length=6, `<init>` | `3C='<'`, `3E='>'` |
| `01 00 03 28 29 56` | entrada #8 | `Utf8`, length=3, `()V` | descritor do construtor |
| `01 00 04 43 6F 64 65` | entrada #9 | `Utf8`, length=4, `Code` | nome de atributo |

#### Saída de `javap -c -verbose HelloWorld.class`

```
Classfile /home/aluno/HelloWorld.class
  Last modified ...; size 425 bytes
  MD5 checksum ...
  Compiled from "HelloWorld.java"
public class HelloWorld
  minor version: 0
  major version: 52
  flags: ACC_PUBLIC, ACC_SUPER
Constant pool:
   #1 = Methodref          #6.#15         // java/lang/Object."<init>":()V
   #2 = Fieldref           #16.#17        // java/lang/System.out:Ljava/io/PrintStream;
   #3 = String             #18            // Hello World!
   #4 = Methodref          #19.#20        // java/io/PrintStream.println:(Ljava/lang/String;)V
   #5 = Class              #21            // HelloWorld
   #6 = Class              #22            // java/lang/Object
   #7 = Utf8               <init>
   #8 = Utf8               ()V
   #9 = Utf8               Code
  #10 = Utf8               LineNumberTable
  #11 = Utf8               main
  #12 = Utf8               ([Ljava/lang/String;)V
  #13 = Utf8               SourceFile
  #14 = Utf8               HelloWorld.java
  #15 = NameAndType        #7:#8          // "<init>":()V
  #16 = Class              #23            // java/lang/System
  #17 = NameAndType        #24:#25        // out:Ljava/io/PrintStream;
  #18 = Utf8               Hello World!
  #19 = Class              #26            // java/io/PrintStream
  #20 = NameAndType        #27:#28        // println:(Ljava/lang/String;)V
  #21 = Utf8               HelloWorld
  #22 = Utf8               java/lang/Object
  #23 = Utf8               java/lang/System
  #24 = Utf8               out
  #25 = Utf8               Ljava/io/PrintStream;
  #26 = Utf8               java/io/PrintStream
  #27 = Utf8               println
  #28 = Utf8               (Ljava/lang/String;)V
{
  public HelloWorld();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #1     // Method java/lang/Object."<init>":()V
         4: return
      LineNumberTable:
        line 6: 0

  public static void main(java.lang.String[]);
    descriptor: ([Ljava/lang/String;)V
    flags: ACC_PUBLIC, ACC_STATIC
    Code:
      stack=2, locals=1, args_size=1
         0: getstatic     #2     // Field java/lang/System.out:Ljava/io/PrintStream;
         3: ldc           #3     // String Hello World!
         5: invokevirtual #4     // Method java/io/PrintStream.println:(Ljava/lang/String;)V
         8: return
      LineNumberTable:
        line 9: 0
        line 10: 8
}
SourceFile: "HelloWorld.java"
```

**Coisas para notar neste exemplo:**

1. **O construtor `HelloWorld()` aparece na tabela `methods` mesmo não tendo sido escrito no
   fonte** — o `javac` gera o construtor padrão, com nome **`<init>`** e descritor `()V`.
   Portanto `methods_count = 2` (`<init>` e `main`).
2. `fields_count = 0` (a classe não declara campos) e `interfaces_count = 0`.
3. `attributes_count = 1` no `ClassFile`: apenas o `SourceFile`.
4. `this_class` → `#5` (`HelloWorld`); `super_class` → `#6` (`java/lang/Object`) — **não é zero**.
5. `flags: ACC_PUBLIC, ACC_SUPER` = `0x0021`.
6. Os `//` na saída do `javap` são **comentários resolvidos pelo próprio javap**, seguindo as
   indireções do pool; no arquivo binário existem **apenas os números**.

#### Visão do jclasslib para o mesmo exemplo (slide 35, compilado com JDK 1.2)

| Campo | Valor mostrado |
|---|---|
| Minor version | 0 |
| Major version | **46** |
| Constant pool count | **34** (⇒ 33 entradas) |
| Access flags | **0x0021 [public]** |
| This class | `cp_info #2` → `<HelloWorld>` |
| Super class | `cp_info #4` → `<java/lang/Object>` |
| Interfaces count | 0 |
| Fields count | 0 |
| Methods count | **2** (`<init>` e `main`) |
| Attributes count | **1** (`SourceFile`) |

Na árvore lateral aparecem: `Constant Pool`, `Interfaces`, `Fields`, `Methods` → `[0] <init>` →
`[0] Code` → `[0] LineNumberTable`, `[1] LocalVariableTable`; `[1] main` → `[0] Code`; e
`Attributes` → `[0] SourceFile`. **Isso ilustra perfeitamente o aninhamento**
`ClassFile → method_info → Code → LineNumberTable/LocalVariableTable`.

### 9.2 Classe Teste: soma, float, double e laço for

#### Código-fonte (do material)

```java
class Teste {
    public static int soma(int a, int b) {
        return a + b;
    }

    public static void main(String[] s) {
        int i;
        float x = 100.f;
        double y = 1000.;
        int j = 20;
        for (i = 0; i < 10; i++) {
            j = soma(j, 10);
        }
        System.out.print(j);
    }
}
```

#### O que esperar no `.class`

| Item | Valor esperado |
|---|---|
| `access_flags` da classe | `0x0020` (`ACC_SUPER` apenas — a classe **não** é `public`) |
| `this_class` | → `CONSTANT_Class_info` → `Teste` |
| `super_class` | → `CONSTANT_Class_info` → `java/lang/Object` |
| `fields_count` | **0** (todas as variáveis são **locais**, não campos!) |
| `methods_count` | **3**: `<init>`, `soma`, `main` |
| Constantes numéricas no pool | `CONSTANT_Float` (100.0f) e `CONSTANT_Double` (1000.0) — o `20` e o `10` **não** entram no pool: viram operandos `bipush` |

> ⚠️ **Pegadinha de prova**: variáveis **locais** (`i`, `x`, `y`, `j`) **não** geram `field_info`.
> Elas aparecem apenas em `max_locals` e, se houver depuração, na `LocalVariableTable` dentro do
> `Code`. Já constantes **pequenas** (que cabem em `byte`/`short`) usam `bipush`/`sipush` e
> **não ocupam** o pool; constantes `float`, `double`, `long` e `String` **sempre** vão ao pool.

#### `javap -c Teste.class` (bytecode comentado)

```
  static int soma(int, int);
    descriptor: (II)I
    flags: ACC_PUBLIC, ACC_STATIC
    Code:
      stack=2, locals=2, args_size=2
         0: iload_0            // empilha o parâmetro a (slot 0)
         1: iload_1            // empilha o parâmetro b (slot 1)
         2: iadd               // desempilha 2, soma, empilha o resultado
         3: ireturn            // retorna o int do topo da pilha

  public static void main(java.lang.String[]);
    descriptor: ([Ljava/lang/String;)V
    flags: ACC_PUBLIC, ACC_STATIC
    Code:
      stack=2, locals=6, args_size=1
         0: ldc           #2   // float 100.0f   <- CONSTANT_Float do pool
         2: fstore_2           // x  -> slot 2
         3: ldc2_w        #3   // double 1000.0d <- CONSTANT_Double (ocupa 2 índices!)
         6: dstore_3           // y  -> slots 3 E 4  (double = 2 slots)
         7: bipush        20   // constante imediata, NÃO vai ao pool
         9: istore        5    // j  -> slot 5
        11: iconst_0
        12: istore_1           // i  -> slot 1
        13: goto          28   // salta para o teste da condição
        16: iload         5    // corpo do laço: empilha j
        18: bipush        10
        20: invokestatic  #5   // Method soma:(II)I
        23: istore        5    // j = soma(j,10)
        25: iinc          1, 1 // i++
        28: iload_1           // teste: i
        29: bipush        10
        31: if_icmplt     16   // se i < 10, volta ao corpo
        34: getstatic     #6   // Field java/lang/System.out:Ljava/io/PrintStream;
        37: iload         5
        39: invokevirtual #7   // Method java/io/PrintStream.print:(I)V
        42: return
```

**Mapa das variáveis locais de `main`** (`max_locals = 6`):

| slot | variável | descritor |
|---|---|---|
| 0 | `s` (parâmetro) | `[Ljava/lang/String;` |
| 1 | `i` | `I` |
| 2 | `x` | `F` |
| 3 **e 4** | `y` | `D` (**ocupa dois slots**) |
| 5 | `j` | `I` |

Note que `main` é **estático** — por isso o slot 0 já é o **primeiro parâmetro**, e não `this`.
Em `<init>` (método de instância), o slot 0 seria `this`.

**Instruções de invocação que aparecem (vale saber a diferença):**

| Instrução | Usada para | Constante do pool |
|---|---|---|
| `invokespecial` | construtores (`<init>`), métodos `private`, chamadas a `super` | `CONSTANT_Methodref` |
| `invokestatic` | métodos **estáticos** (`soma`) | `CONSTANT_Methodref` |
| `invokevirtual` | métodos de instância com despacho dinâmico (`println`) | `CONSTANT_Methodref` |
| `invokeinterface` | métodos declarados em interface | `CONSTANT_InterfaceMethodref` |
| `invokedynamic` | lambdas / linguagens dinâmicas (Java 7+) | `CONSTANT_InvokeDynamic` |

**Instruções que consultam o pool de constantes:** `ldc` (1 byte de índice, categoria 1),
`ldc_w` (2 bytes de índice), `ldc2_w` (**`long`/`double`**, 2 bytes de índice),
`getstatic`/`putstatic`/`getfield`/`putfield` (`CONSTANT_Fieldref`), `new`/`checkcast`/
`instanceof`/`anewarray` (`CONSTANT_Class`).

> ⚠️ **Pegadinha de prova**: `ldc` **não** carrega `long`/`double` — para esses usa-se
> **`ldc2_w`**, exatamente porque ocupam duas posições. É o mesmo padrão "categoria 2" que já
> apareceu no `constant_pool` e no vetor de variáveis locais.

### 9.3 Ferramenta jclasslib Bytecode Viewer

O material apresenta o **jclasslib Bytecode Viewer**, um visualizador gráfico de `.class`. Ele
mostra a árvore completa do arquivo: *General Information* (versões, `constant_pool_count`,
`access_flags`, `this class`, `super class`, contadores), *Constant Pool*, *Interfaces*,
*Fields*, *Methods* (com o `Code` e seus sub-atributos) e *Attributes*.

Alternativas em linha de comando, úteis para o estudo e para o trabalho:

| Comando | O que faz |
|---|---|
| `javap -c Classe.class` | desmonta os bytecodes |
| `javap -v Classe.class` | verbose: mostra **todo** o pool de constantes, flags, atributos |
| `javap -p -v Classe.class` | inclui também membros `private` |
| `javap -s Classe.class` | mostra os **descritores** (assinaturas internas) |
| `xxd Classe.class \| head` | dump hexadecimal bruto (conferir `CAFEBABE`) |
| `od -A d -t x1 Classe.class` | outro dump, com offsets decimais |

---

## 10. Implementando um leitor de `.class` em C

Esta parte do material é a ponte para o **trabalho da disciplina**: escrever um leitor/exibidor
(e depois um interpretador) de arquivos `.class` em C.

### 10.1 fopen e modos de abertura

```c
FILE* fopen(const char* filename, const char* mode);
```

| Modo | Significado |
|---|---|
| `"r"` | leitura de texto (*text reading*) |
| `"w"` | escrita de texto (*text writing*) — **descarta** conteúdo anterior |
| `"a"` | *append* de texto (escreve no fim) |
| `"r+"` | atualização de texto: **leitura e escrita** |
| `"w+"` | atualização de texto, **descartando o conteúdo anterior** (se houver) |
| `"a+"` | *append*, leitura e escrita no fim |
| `"b"` | acrescentado **após o primeiro caractere** para **arquivos binários** |

> ⚠️ **Pegadinha de prova / do trabalho**: um `.class` é **binário**, então o modo correto é
> **`"rb"`** — e não `"r"`. Em Windows, abrir em modo texto faria a conversão de `0x0D 0x0A`,
> **corrompendo** a leitura; o `b` vai **depois** do primeiro caractere (`"rb"`, `"wb"`,
> `"r+b"`).

### 10.2 Leitura big-endian: u1Read, u2Read, u4Read

Como o arquivo é **big-endian** e o hospedeiro geralmente é little-endian, a leitura precisa
**montar o valor byte a byte**, deslocando 8 bits a cada byte lido. O material dá a função para
`u2`:

```c
static u2 u2Read(FILE *fd) {
    u2 toReturn = getc(fd);
    toReturn = (toReturn << 8) | (getc(fd));
    return toReturn;
}
```

Por analogia, as demais:

```c
static u1 u1Read(FILE *fd) {
    return (u1) getc(fd);
}

static u4 u4Read(FILE *fd) {
    u4 toReturn = getc(fd);
    toReturn = (toReturn << 8) | (getc(fd));
    toReturn = (toReturn << 8) | (getc(fd));
    toReturn = (toReturn << 8) | (getc(fd));
    return toReturn;
}
```

O primeiro byte lido é o **mais significativo** e vai sendo "empurrado" para a esquerda a cada
novo byte — é exatamente isso que converte big-endian para a representação nativa.

> ⚠️ **Pegadinha de prova**: `fread(&valor, sizeof(u4), 1, fd)` **não funciona** num PC x86 para
> ler `magic`: o valor sairia invertido (`0xBEBAFECA`). É preciso usar a leitura byte a byte
> (ou aplicar um *byte swap*).

### 10.3 Lendo o ClassFile e o constant_pool

Leitura do cabeçalho:

```c
ClassFile *cf = (ClassFile *) malloc(sizeof(ClassFile));
cf->magic               = u4Read(fd);
cf->minor_version       = u2Read(fd);
cf->major_version       = u2Read(fd);
cf->constant_pool_count = u2Read(fd);
```

**Representando `cp_info` em C.** Como cada tag tem um layout diferente, a técnica é uma
**`struct` com `union`** (uma "*tagged union*"):

```c
typedef struct {
    u1 tag;
    union {
        struct {
            u2 name_index;
        } Class;
        struct {
            u2 class_index;
            u2 name_and_type_index;
        } Fieldref;
        struct {
            u2 class_index;
            u2 name_and_type_index;
        } Methodref;
        struct {
            u2 name_index;
            u2 descriptor_index;
        } NameAndType;
        struct {
            u2 length;
            u1 *bytes;
        } Utf8;
        struct {
            u4 bytes;
        } Integer;
        struct {
            u4 high_bytes;
            u4 low_bytes;
        } Long;
        /* ... demais tipos ... */
    } u;
} Constant;
```

**Laço de leitura do pool** (note o `count - 1`):

```c
Constant *constantPool = (Constant *) malloc(sizeof(Constant) * (count - 1));
Constant *cp;

for (cp = constantPool; cp < constantPool + count - 1; cp++) {
    cp->tag = u1Read(fd);
    switch (cp->tag) {
        case CONSTANT_Class:
            cp->u.Class.name_index = u2Read(fd);
            break;
        case CONSTANT_Fieldref:
            cp->u.Fieldref.class_index          = u2Read(fd);
            cp->u.Fieldref.name_and_type_index  = u2Read(fd);
            break;
        /* ... demais casos ... */
    }
}
```

**Pontos de atenção ao implementar** (todos derivados de regras já vistas):

1. O laço vai até `count - 1`, porque `constant_pool_count` é o número de entradas **+ 1**.
2. O pool é **1-based**: a entrada lógica `#1` fica em `constantPool[0]`. Indexe com
   `constantPool[i-1]`.
3. Ao ler um `CONSTANT_Long` ou `CONSTANT_Double`, é preciso **avançar o contador em 2**, porque
   a entrada seguinte é um "buraco" inválido.
4. Para `CONSTANT_Utf8`, é preciso ler `length` e então **alocar dinamicamente** `length` bytes
   (`malloc(length + 1)` se quiser terminar com `\0` para imprimir com `printf("%s")`).
5. Um `default:` no `switch` deve tratar **tag inválida** como erro de formato.
6. Depois do pool, a leitura continua na ordem exata da `ClassFile`: `access_flags`,
   `this_class`, `super_class`, `interfaces_count`, `interfaces[]`, `fields_count`, `fields[]`,
   `methods_count`, `methods[]`, `attributes_count`, `attributes[]`.
7. Para exibir um atributo desconhecido, basta ler `attribute_length` bytes e descartá-los —
   é a regra do **"ignorar em silêncio"** implementada na prática.

---

## 11. Erros e imprecisões dos slides (cuidado!)

Vale conhecê-los: se cair em prova, é provável que a resposta esperada siga o slide, mas é bom
saber a verdade da especificação.

| Slide | O que está escrito | O correto pela JVMS |
|---|---|---|
| 20 (`CONSTANT_Class_info`) | Exemplo de `name_index`: `Ljava/lang/Thread;` | O `name_index` guarda o **nome interno** `java/lang/Thread` (sem `L` e sem `;`). `Ljava/lang/Thread;` é um **descritor de campo**. |
| 21/22/23 (`Fieldref`, `Methodref`, `InterfaceMethodref`) | "`class_index` … `CONSTANT_Utf8_info` representando nome completo da classe" | `class_index` aponta para uma **`CONSTANT_Class_info`** (que, por sua vez, aponta para a `Utf8`). |
| 25 (`Utf8`) | "`length` … não indica o número de bytes da string" | A frase é confusa: `length` **é** o número de **bytes** do array; o que ele **não** indica é o número de **caracteres**, e a string **não** é terminada em `\0`. |
| 13 (`super_class`) | "0 (zero) se a classe não for derivada. Se for 0 essa classe estende Object" | Na prática, **apenas `java.lang.Object`** tem `super_class = 0`. Toda outra classe tem índice explícito, mesmo que estenda `Object`. |
| 43 vs. 45 (atributos obrigatórios) | 43: "Code, Exceptions e SourceFile"; 45: "Code, ConstantValue, Exceptions" | O conjunto obrigatório da JVMS é **`ConstantValue`, `Code`, `Exceptions`** (+ `InnerClasses` e `Synthetic` a partir do Java 2). `SourceFile` é **opcional**. |
| 33 (`Double`) | faixas de NaN escritas como `0x7ffffffffffffL` | O correto é `0x7fffffffffffffffL` (o slide perdeu dígitos). |
| 66 (`LocalVariableTable`) | intervalo `[start_pc, start_pc+length]` | A JVMS define o intervalo como **`[start_pc, start_pc+length)`**, com o fim exclusivo. |
| 2 | `typedef unsined long` | Erro de digitação de `unsigned long`. |

---

## 12. Resumo em 10 pontos

1. **Um `.class` = uma classe ou interface.** É um **stream de bytes de 8 bits**, descrito em
   notação estilo C, com os tipos sem sinal **`u1`, `u2`, `u4`, `u8`**, itens **big-endian** e
   **sem padding/alinhamento**. **Tabelas** têm itens de tamanho variável (índice ≠ offset);
   **arrays** têm itens de tamanho fixo.

2. **A `ClassFile` tem 16 campos, nesta ordem:** `magic` (`0xCAFEBABE`), `minor_version`,
   `major_version`, `constant_pool_count`, `constant_pool[count-1]`, `access_flags`,
   `this_class`, `super_class`, `interfaces_count`, `interfaces[]`, `fields_count`, `fields[]`,
   `methods_count`, `methods[]`, `attributes_count`, `attributes[]`.

3. **O `constant_pool` é o coração do arquivo:** tudo é **simbólico** e referenciado por
   **índice**. `constant_pool_count` é o número de entradas **+ 1**; índices vão de **1** a
   `count-1`; **`Long` e `Double` ocupam dois índices** (o seguinte é inválido). Cada entrada
   começa por um byte de **tag**.

4. **Decore as tags:** Utf8=1, Integer=3, Float=4, Long=5, Double=6, Class=7, String=8,
   Fieldref=9, Methodref=10, InterfaceMethodref=11, NameAndType=12, MethodHandle=15,
   MethodType=16, InvokeDynamic=18. Não existem 2, 13, 14 e 17.

5. **Descritores são a linguagem de tipos da JVM:** `B C D F I J S Z` para primitivos,
   `L<classe>;` para objetos, `[` para cada dimensão de array, e `(params)retorno` para métodos,
   com `V` só no retorno. Exemplo canônico:
   `(IDLjava/lang/Thread;)Ljava/lang/Object;`. Nomes de classe usam **`/`** no lugar do `.`.

6. **`field_info` e `method_info` têm a mesma forma** (`access_flags`, `name_index`,
   `descriptor_index`, `attributes_count`, `attributes[]`) e contêm **apenas os membros
   declarados** na classe — **nada herdado**. Métodos especiais: **`<init>`** (construtor,
   via `invokespecial`) e **`<clinit>`** (iniciação de classe, chamado pela JVM).

7. **Flags de acesso são máscaras de bits combinadas por OR.** Classe: `PUBLIC 0x0001`,
   `FINAL 0x0010`, `SUPER 0x0020`, `INTERFACE 0x0200`, `ABSTRACT 0x0400`, `SYNTHETIC 0x1000`,
   `ANNOTATION 0x2000`, `ENUM 0x4000` (sem `PRIVATE`/`PROTECTED`/`STATIC`). Campo tem
   `VOLATILE 0x0040` e `TRANSIENT 0x0080`; método tem `SYNCHRONIZED 0x0020`, `BRIDGE 0x0040`,
   `VARARGS 0x0080`, `NATIVE 0x0100`, `ABSTRACT 0x0400`, `STRICT 0x0800`.

8. **Todo atributo tem o mesmo cabeçalho** (`attribute_name_index` + `attribute_length`), e
   **`attribute_length` NÃO conta os 6 bytes do cabeçalho**. Atributos **desconhecidos devem ser
   ignorados em silêncio** — é o que torna o formato extensível.

9. **Atributos-chave:** `ConstantValue` (em `field_info`, `length` **sempre 2**, só para
   **estáticas**; em não estática é **ignorado**), `Code` (em `method_info`, **um por método**,
   **ausente** em nativos e abstratos, com `max_stack`, `max_locals`, `code[]`,
   `exception_table` e sub-atributos), `Exceptions` (o **`throws`**, ≠ `exception_table`),
   `InnerClasses` e `SourceFile` (em `ClassFile`), `LineNumberTable` e `LocalVariableTable`
   (dentro de `Code`, para **depuração**), `Deprecated`/`Synthetic` (`length` **0**).

10. **Para ler um `.class` em C:** abrir com **`fopen(arquivo, "rb")`**, ler byte a byte com
    funções tipo `u2Read`/`u4Read` que **montam o valor em big-endian**, representar `cp_info`
    como **`struct` com `union` discriminada pela tag**, percorrer o pool com `count - 1`
    iterações lembrando dos **dois índices** de `Long`/`Double`, e depois seguir **exatamente a
    ordem dos campos da `ClassFile`**.

---

## Apêndice — Este material e o Java SE 8

Os slides seguem a **JVMS 8**, então há pouca divergência. Os pontos de atenção:

| Ponto | Situação |
|---|---|
| Captura do jclasslib com `major_version = 46` | 🟦 É um `.class` de **JDK 1.2**. Java 8 = **52** |
| Tabela de atributos da seção 8.11 | 🟦 Lista só os atributos das edições antigas. Faltam `StackMapTable` (6), `Signature` e anotações (5), `BootstrapMethods` (7), `MethodParameters` e anotações de tipo (**8**) |
| Slide 73 (leitor em C) com 11 tags | 🟦 Escopo pré-Java-7. A JVMS 8 tem **14** tags |
| Tag 17 "não existe" | ✅ Correto **no Java 8**. 🟪 Virou `CONSTANT_Dynamic` no Java 11 |
| `jsr` / `ret` | 🟦 **Não podem aparecer** num `.class` de Java 8 (`major ≥ 51` as proíbe), embora o tipo `returnAddress` siga na especificação |
| `invokedynamic` | ✅ Existe e é essencial no Java 8 — **toda lambda** vira um `invokedynamic` + `BootstrapMethods` |

🟥 **Erros dos slides, independentes de versão** (já detalhados na seção 11): `name_index` de
`CONSTANT_Class_info` mostrado como `Ljava/lang/Thread;` (o correto é o nome interno
`java/lang/Thread`); `class_index` descrito como apontando para `CONSTANT_Utf8_info` (aponta para
`CONSTANT_Class_info`); contradição entre os slides 43 e 45 sobre atributos obrigatórios; e dígitos
faltando na faixa de NaN do `double`.

Detalhamento completo em [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).

---

*Bons estudos! Se puder, abra um `.class` real com `javap -v` e com `xxd` lado a lado: meia hora
fazendo isso vale mais do que reler o resumo três vezes.*
