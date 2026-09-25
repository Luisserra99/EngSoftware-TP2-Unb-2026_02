# Java Básico (IBM — "Programando em Java") — Resumo Completo de Estudo

> Material de estudo para a prova de **Software Básico (CIC0104 — UnB)**.
> Base: `IBM-JavaBasico.pdf` (149 slides), com alterações de Marcelo Ladeira e Thelmo Enoque.
> Todos os tópicos do PDF estão cobertos aqui, com exemplos, tabelas e pegadinhas de prova.

> 🔎 **Revisão Java 8** — este PDF foi escrito para o **Java 1.4** (2002), mas a prova cobre
> **Java SE 8 / JVMS 8**. Ao longo do arquivo, os pontos em que o slide diverge do Java 8 estão
> marcados com 🟦 (**Divergência Java 8**), 🟪 (**Posterior ao Java 8**) e 🟥 (**Divergência com a
> especificação**, válida em qualquer versão). O apanhado completo está em 
> [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).

---

## Sumário

1. [O que você precisa saber para a prova](#1-o-que-você-precisa-saber-para-a-prova)
2. [Características da linguagem Java](#2-características-da-linguagem-java)
3. [Como o Java funciona: bytecode, compilador, JVM, classpath](#3-como-o-java-funciona-bytecode-compilador-jvm-classpath)
4. [Orientação a Objetos: conceitos fundamentais](#4-orientação-a-objetos-conceitos-fundamentais)
5. [Estrutura de um arquivo-fonte, pacotes e imports](#5-estrutura-de-um-arquivo-fonte-pacotes-e-imports)
6. [Declarando classes, atributos e métodos](#6-declarando-classes-atributos-e-métodos)
7. [Construtores](#7-construtores)
8. [Tipos primitivos](#8-tipos-primitivos)
9. [Conversão e casting de tipos primitivos](#9-conversão-e-casting-de-tipos-primitivos)
10. [Classes Wrappers](#10-classes-wrappers)
11. [A classe String](#11-a-classe-string)
12. [Modificadores de acesso](#12-modificadores-de-acesso)
13. [A classe Object](#13-a-classe-object)
14. [A referência this](#14-a-referência-this)
15. [Sintaxe básica, comentários, Javadoc, identificadores e palavras reservadas](#15-sintaxe-básica-comentários-javadoc-identificadores-e-palavras-reservadas)
16. [Operadores e precedência](#16-operadores-e-precedência)
17. [Estruturas de controle](#17-estruturas-de-controle)
18. [Arrays](#18-arrays)
19. [Modificadores final, static, synchronized, abstract e outros](#19-modificadores-final-static-synchronized-abstract-e-outros)
20. [Modelo de memória, referências e garbage collection](#20-modelo-de-memória-referências-e-garbage-collection)
21. [Igualdade entre objetos: == vs equals()](#21-igualdade-entre-objetos--vs-equals)
22. [Passagem de parâmetros](#22-passagem-de-parâmetros)
23. [Herança em Java](#23-herança-em-java)
24. [Sobrescrita (override) vs Sobrecarga (overload)](#24-sobrescrita-override-vs-sobrecarga-overload)
25. [Abstração: classes abstratas, métodos abstratos e interfaces](#25-abstração-classes-abstratas-métodos-abstratos-e-interfaces)
26. [Polimorfismo](#26-polimorfismo)
27. [API Collection](#27-api-collection)
28. [Conversão e casting de referências a objetos + instanceof](#28-conversão-e-casting-de-referências-a-objetos--instanceof)
29. [Exceções](#29-exceções)
30. [Threads e concorrência](#30-threads-e-concorrência)
31. [Resumo em 10 pontos](#31-resumo-em-10-pontos)

---

## 1. O que você precisa saber para a prova

Esta seção é o "mapa de calor" do conteúdo — o que historicamente cai em questões de verdadeiro/falso e múltipla escolha.

### 1.1. Tabelas que você deve saber de cor

- **Tipos primitivos**: são **8** (`boolean`, `char`, `byte`, `short`, `int`, `long`, `float`, `double`), seus tamanhos em bits e valores default.
- **Modificadores de acesso × visibilidade**: `public`, `protected`, *default* (package-private), `private`.
- **Tabela "Todos os Modificadores"** (slide 88): qual modificador pode ser aplicado a classe, atributo, método, construtor e bloco livre. É a fonte clássica de V/F.
- **Precedência de operadores** (13 níveis) e associatividade.

### 1.2. Conceitos que sempre caem

| Tema | Ponto crítico |
|---|---|
| Bytecode / JVM | `.java` → (compilador `javac`) → `.class` (bytecode) → (JVM) → execução |
| Herança | Java **não** tem herança múltipla de classes; tem herança múltipla de **interfaces** |
| `Object` | Toda classe herda de `Object`, mesmo sem `extends`. `Object` **tem** construtor público sem argumentos |
| Construtor padrão | Só é criado se **nenhum** outro construtor for declarado |
| `super()` / `this()` | Devem ser o **primeiro** comando do construtor |
| Classe abstrata | **Não pode ser instanciada**; pode ter métodos concretos; pode até não ter nenhum método abstrato |
| Interface | Só métodos abstratos e constantes (`public static final`) — **sem atributos de instância** |
| `static` | Aplica-se a atributo, método e bloco iniciador — **não** a classe de topo nem a construtor |
| `final` | Classe (não estendível), método (não sobrescrevível), variável (não reatribuível) |
| Passagem de parâmetros | Java é **sempre por valor** (para referências, passa-se uma **cópia da referência**) |
| `==` vs `equals()` | `==` compara valor (primitivos) ou referência (objetos); `equals()` compara conteúdo se sobrescrito |
| String | É **classe**, não primitivo; é **imutável**; literais vão para o *pool* |
| Exceções | Hierarquia `Throwable` → `Exception` / `Error`; `RuntimeException` e `Error` são **unchecked** |
| Override + exceções | O método sobrescrito **não pode** lançar checked exceptions novas ou mais amplas |
| Sobrecarga | Diferenciada pela **lista de parâmetros**; o tipo de retorno **não** diferencia |
| Arrays | Tamanho fixo definido na **construção**; índice de `0` a `length - 1`; `length` é **atributo**, não método |
| Garbage Collector | Thread da JVM; não se sabe **quando** roda; usa `finalize()` |
| Threads | `start()` põe na fila do escalonador; `synchronized`, `wait()`, monitor |

> 🟦 **Divergência Java 8 (linhas "Interface" e "Classe abstrata" da tabela acima)**
> - **Interface:** "só métodos abstratos" vale até o Java 7. **No Java 8** uma interface pode ter
>   métodos **`default`** (com corpo, herdados por quem implementa) e métodos **`static`**.
>   O que **continua verdade em qualquer versão**: interface **não tem atributos de instância**
>   (todo campo é `public static final`) e **não tem construtor**.
> - **`static`:** a linha está correta — `static` não se aplica a classe **de topo**, mas
>   **se aplica a classe aninhada** (`static class Interna { }`). Esse detalhe já caiu (Q21 da prova).
>
> Ver [DIVERGENCIAS-JAVA8.md §2.1](DIVERGENCIAS-JAVA8.md#21--interface-só-tem-métodos-abstratos).

### 1.3. Checklist de pegadinhas (as mais repetidas)

- [ ] "Uma classe abstrata precisa ter pelo menos um método abstrato?" → **Não obrigatoriamente** (ver §25).
- [ ] "Interfaces podem ter atributos?" → Apenas **constantes** (`static final`), nunca atributos de instância.
- [ ] "A classe `Object` tem construtor?" → **Sim**, `public Object()`.
- [ ] "Posso declarar uma classe de topo como `static`?" → **Não** (só classes internas).
- [ ] "Construtor pode ser `final`, `static` ou `abstract`?" → **Não**, nenhum dos três.
- [ ] "Construtor é herdado?" → **Não**.
- [ ] "`goto` existe em Java?" → É palavra **reservada**, mas **não implementada**.
- [ ] "`String` é tipo primitivo?" → **Não**, é classe.
- [ ] "`byte b1, b2; short c = b1 + b2;` compila?" → **Não**, o resultado é `int`.
- [ ] "Em `catch`, a ordem importa?" → **Sim**, do mais específico para o mais genérico.

---

## 2. Características da linguagem Java

O PDF abre listando as características de marketing/design do Java:

| Característica | Significado |
|---|---|
| **Simples** | Sintaxe derivada de C/C++, mas sem ponteiros explícitos, sem `struct`, sem herança múltipla de classes, sem sobrecarga de operadores |
| **Orientada a Objetos** | Tudo (exceto primitivos) é objeto; classes são a unidade de organização |
| **Distribuída** | Bibliotecas nativas de rede (sockets, RMI, URL) |
| **Suporte a Concorrência** | `Thread`, `synchronized`, `wait/notify` fazem parte da própria linguagem |
| **Dinâmica** | Classes são carregadas sob demanda em tempo de execução (class loading), reflexão |
| **Independente de Plataforma** | O bytecode roda em qualquer JVM: *"write once, run anywhere"* |
| **Portável** | Tamanhos dos tipos primitivos são **fixos** pela especificação (um `int` tem 32 bits em qualquer máquina) |
| **Alta Performance** | JIT (*Just-In-Time compiler*) traduz bytecode para código nativo em tempo de execução |
| **Robusta** | Checagem forte de tipos, ausência de aritmética de ponteiros, gerência automática de memória, exceções |
| **Segura** | Verificador de bytecode, *sandbox*, gerenciador de segurança |

> ⚠️ **Pegadinha de prova**
> **Portabilidade** e **independência de plataforma** não são a mesma coisa no vocabulário do slide. Independência de plataforma vem da JVM (o mesmo `.class` roda em todo lugar); portabilidade vem da especificação ter fixado o tamanho e o comportamento dos tipos primitivos — diferente de C, onde `int` pode ter 16, 32 ou 64 bits.

---

## 3. Como o Java funciona: bytecode, compilador, JVM, classpath

### 3.1. O pipeline

```
   Arquivo.java            Arquivo.class                  Execução
  (código-fonte)   ---->   (bytecode)        ---->      (código de máquina)
                   javac                      JVM
```

### 3.2. Conceitos básicos (slide 5)

| Conceito | Definição |
|---|---|
| **ByteCode** | Código **intermediário** (`*.class`), entre o código-fonte (`*.java`) e o código de máquina |
| **Compilador** | Responsável pela geração do bytecode (`*.class`) através da tradução do código-fonte |
| **JVM** | Máquina virtual do Java, responsável pela leitura do bytecode, tradução para linguagem de máquina e execução do programa |
| **Classpath** | Conjunto de caminhos especificado para a JVM **encontrar as classes** necessárias para a execução do programa |

### 3.3. Exemplo prático de compilação e execução

```java
// Arquivo: Ola.java
public class Ola {
    public static void main(String[] args) {
        System.out.println("Olá, Software Básico!");
    }
}
```

```bash
$ javac Ola.java      # gera Ola.class (bytecode)
$ java Ola            # a JVM carrega Ola.class e executa main()
Olá, Software Básico!

$ javap -c Ola        # desmonta o bytecode (útil para a parte de JVM da matéria)
```

Saída esperada:
```
Olá, Software Básico!
```

> ⚠️ **Pegadinha de prova**
> - Na linha `java Ola` você passa o **nome da classe**, não o nome do arquivo: `java Ola.class` está **errado**.
> - O `main` deve ter exatamente a assinatura `public static void main(String[] args)`. Se faltar `static`, a JVM não consegue chamá-lo sem instanciar a classe e o programa falha em tempo de execução (não de compilação!).
> - O **classpath** não é onde ficam os fontes, é onde a JVM **procura os `.class`**.

---

## 4. Orientação a Objetos: conceitos fundamentais

### 4.1. As gerações de linguagens (slide 7)

| Geração | Tipo |
|---|---|
| 1ª | Linguagem de máquina |
| 2ª | Linguagem de montagem (assembly) |
| 3ª | Linguagem de alto nível (C, Pascal, Fortran) |
| 4ª | Linguagens para geração de aplicações (SQL, geradores de relatório) |
| "5ª" / Geração OO | Linguagens voltadas para **reuso** e **manutenção** |

> O desafio da geração OO, segundo o slide, é efetuar a **manutenção** e o **reuso** das milhares de aplicações desenvolvidas pelas gerações anteriores.

### 4.2. Paradigmas (slide 8)

- **Procedural**: o programador fornece um **algoritmo** para solucionar o problema.
- **Declarativa**: o programador **descreve uma solução** e a VM/máquina provê o suporte para transformá-la em comandos executáveis.
- **POO**: o programador descreve o problema **em termos do próprio problema**, e não em termos de um algoritmo que o computador vai rodar.

### 4.3. Princípios de POO no slide

1. **Todas as coisas são objetos.** Um objeto é como uma variável que, além de armazenar dados, realiza operações com esses dados e tem comportamento definido.
2. **Programas são conjuntos de objetos** dizendo uns aos outros o que fazer **através de mensagens**. Mensagem = invocação de método.
3. **Objetos podem ser derivados de outros objetos** (especialização), podem **conter** outros objetos (composição) e podem **substituir métodos** de outros objetos (sobrescrita).
4. **Todo objeto tem um tipo**: todo objeto é instância de uma classe. Todos os objetos de uma classe podem receber as mesmas mensagens.
   - *"Todo objeto que é um círculo também é uma figura geométrica. Logo o círculo pode receber todas as mensagens destinadas a uma figura geométrica."* → Isso é **polimorfismo**.

### 4.4. Exemplo canônico do PDF: Interruptor e Lâmpada

```java
class Interruptor {
    Lampada lp = new Lampada();       // COMPOSIÇÃO: o interruptor "tem uma" lâmpada

    public void liga() {
        lp.acender();                 // envia a MENSAGEM acender() ao objeto lp
    }

    public void desliga() {
        lp.apagar();
    }
}

class Lampada {
    int potencia = 60;                // ATRIBUTO: propriedade comum a todas as lâmpadas

    public void acender() { /* ... */ }   // MÉTODO: ação que a classe pode fazer
    public void apagar()  { /* ... */ }
}
```

- **Atributos** representam uma propriedade **comum a todas as instâncias** da classe ("toda lâmpada tem uma potência").
- **Métodos** são as ações que uma classe pode fazer e são os **agentes das mensagens** ("um interruptor pode ligar e desligar").

### 4.5. Mensagens e visibilidade (encapsulamento)

O slide 16 mostra um diagrama: o "resto do mundo" deve conversar com o objeto **apenas através dos métodos**. Acessar diretamente os atributos é marcado com **"EVITAR!"**.

```java
public class ContaBancaria {
    private double saldo;             // ESCONDIDO do mundo externo

    public double getSaldo() {        // interface pública
        return saldo;
    }

    public void depositar(double valor) {
        if (valor > 0) {              // a classe protege sua própria consistência
            saldo += valor;
        }
    }
}
```

### 4.6. Relacionamentos entre classes (slide 22)

| Relacionamento | Descrição |
|---|---|
| **Herança** | Classes "filhas" herdam o comportamento e atributos da classe "pai" |
| **Composição** | Formação do **todo pelas partes** (um carro *tem* rodas, motor...) |
| **Generalização** | Comportamento e características **generalizados** (subir na hierarquia) |
| **Especialização** | **Particularização** do comportamento das subclasses (descer na hierarquia) |

### 4.7. Vantagens da OO (slides 36 e 102)

- **Reuso** → via **Herança** e **Composição**
- **Abstração** → via **Interfaces**, **Classes Abstratas** e **Encapsulamento**

> ⚠️ **Pegadinha de prova**
> Não confunda: **herança** é "é-um" (*is-a*); **composição** é "tem-um" (*has-a*).
> `Cachorro extends Animal` (herança) vs. `Carro { Motor m; }` (composição).
> Generalização e especialização são **duas leituras da mesma relação de herança**, não relacionamentos distintos de herança.

---

## 5. Estrutura de um arquivo-fonte, pacotes e imports

### 5.1. Ordem obrigatória (slide 38)

Um arquivo-fonte deve **obrigatoriamente** seguir esta estrutura e **esta ordem**:

1. Definição do **pacote** (`package`) — no máximo uma, e sempre a primeira instrução
2. Lista de **imports**
3. Declaração de **classe(s)**

Regras adicionais:
- É permitida **uma única classe pública por arquivo-fonte**.
- A classe pública deve ter **o mesmo nome do arquivo-fonte**.
  - Se a classe é `Bicicleta`, o arquivo deve ser `Bicicleta.java`.

```java
// 1) Declaração de pacote — obrigatoriamente a PRIMEIRA linha de código
package pessoal.meuPacote;

// 2) Declaração de imports
import java.util.Random;   // Importação de UMA classe
import java.sql.*;         // Importação de um PACOTE inteiro

// 3) Definições de classes
public class MinhaClasse {
    // ...
}
```

### 5.2. Pacote (`package`)

- Forma de **organizar grupos de classes** em unidades.
- Pode conter qualquer número de classes que se relacionam, seja pelo mesmo objetivo ou escopo.
- **Reduz problemas de conflito de nomes**: o nome de uma classe não é apenas aquele usado na declaração, mas o conjunto **nome do pacote + nome da classe** (nome *totalmente qualificado*).
  - Ex.: `java.util.Date` é diferente de `java.sql.Date`.
- Permite a **proteção** de classes, variáveis e métodos através dos modificadores (`protected` e *default* são baseados em pacote).

### 5.3. Import

Usa-se `import` para declarar classes que são referenciadas no arquivo-fonte mas **não pertencem ao pacote** onde o arquivo se encontra.

Imports podem referenciar:
- Outras classes no mesmo projeto
- Classes da API Java, como `java.util.List`
- Classes contidas em bibliotecas (`*.jar`) referenciadas no **classpath** do projeto

```java
import java.util.Date;     // importa só a classe Date
import java.util.*;        // importa todas as classes do pacote java.util
```

> ⚠️ **Pegadinha de prova**
> - `import java.util.*;` **não** importa subpacotes. `java.util.concurrent.Lock` continua não acessível.
> - `import` **não** copia código nem aumenta o tamanho do `.class`; é apenas um atalho para não escrever o nome totalmente qualificado.
> - Classes de `java.lang` (como `String`, `Object`, `Math`, `System`, `Integer`) são importadas **automaticamente**.
> - Um arquivo pode ter **várias** classes, desde que **no máximo uma** seja `public`.
> - Se a ordem `package` → `import` → `class` for invertida, é **erro de compilação**.

---

## 6. Declarando classes, atributos e métodos

### 6.1. Declaração de classe

```
[modificadores] class NomeDaClasse
{
    ....
}
```

```java
public class Curso { }
public class Turma { }
public class Aluno { }
```

### 6.2. Declaração de atributo

```
[modificadores] tipo nomeDoAtributo [ = iniciação ];
```

```java
private static int numero;                     // atributo de classe (static)
public final int tamanhoMaximo = 15;           // constante de instância
private String nome = "Maria da Silva";        // atributo de instância inicializado
double raio = 6.5;                             // visibilidade default (pacote)
Object o = new Object();                       // atributo referência
```

### 6.3. Declaração de método

```
[modificadores] retorno nomeDoMetodo ( [Argumentos] ) [ throws Exceções ]
{
    ...
    [ return varRetorno; ]
}
```

```java
private void obtemNumeroAlunosTurma(long codigoTurma) { ... }
public String getNomeAluno(int codigoAluno) { ... }
public void insereAluno(String nomeAluno) throws Exception { ... }
public static long getNumeroInstancias() { ... }
```

### 6.4. Exemplo completo de classe (slide 45) — padrão JavaBean

```java
public class Aluno {
    String nomeAluno;          // atributos (aqui com visibilidade default)
    int codigoAluno;

    public String getNomeAluno() {
        return nomeAluno;
    }

    public void setNomeAluno(String param) {
        nomeAluno = param;
    }

    public int getCodigoAluno() {
        return codigoAluno;
    }

    public void setCodigoAluno(int param) {
        codigoAluno = param;
    }
}
```

Uso:
```java
Aluno a = new Aluno();
a.setNomeAluno("Carolina");
a.setCodigoAluno(2023001);
System.out.println(a.getNomeAluno() + " - " + a.getCodigoAluno());
```
Saída:
```
Carolina - 2023001
```

> ⚠️ **Pegadinha de prova**
> - Um método `void` **não pode** ter `return expressao;` — só `return;` (que apenas encerra o método).
> - Um método com retorno declarado **deve** retornar em todos os caminhos possíveis, senão é erro de compilação (*missing return statement*).
> - Atributos **não inicializados** recebem valor default automaticamente (`0`, `false`, `null`). **Variáveis locais NÃO**: usar uma variável local não inicializada é **erro de compilação**.

```java
public class Teste {
    int x;                       // OK: vale 0 automaticamente
    public void m() {
        int y;
        System.out.println(y);   // ERRO DE COMPILAÇÃO: variable y might not have been initialized
    }
}
```

---

## 7. Construtores

### 7.1. O que é (slides 27 e 46)

- Método especial utilizado para **criar instâncias (objetos)** de uma classe e **iniciar seus atributos**.
- Para que um objeto exista é necessário **construí-lo**, isto é, dizer à JVM que é necessário espaço de memória.

```java
Lampada lp = new Lampada();
Aluno o1   = new Aluno();
Object o2  = new Object();
Button botao = new Button("cachorro");
```

### 7.2. Sintaxe

```
[modificador] nomeDaClasse ( [Argumentos] ) [ throws Exceções ]
{
    ...
}
```

```java
public Turma() { ... }
public Turma(long codigoTurma) { ... }
public Curso(int codigoCurso) throws Exception { ... }
public Curso(String nomeCurso, int codigoCurso) { ... }
```

Características que o diferenciam de um método comum:
- Tem **exatamente o mesmo nome da classe**.
- **Não tem tipo de retorno** (nem mesmo `void`).

### 7.3. Construtor padrão (default)

- Toda classe possui, por default, um **construtor padrão: público e sem argumentos**.
- O construtor default **somente é criado quando nenhum outro construtor for definido** pelo programador.
- Uma classe pode ter **quantos construtores desejar** (sobrecarga de construtores).

```java
public class A {
    // Nenhum construtor declarado → o compilador cria: public A() { super(); }
}

public class B {
    public B(int x) { }          // Declarei um construtor com argumento...
}

// Uso:
A a = new A();       // OK
B b = new B();       // ERRO DE COMPILAÇÃO! O construtor sem argumentos NÃO existe mais
B b2 = new B(10);    // OK
```

### 7.4. Encadeamento de construtores

- Implicitamente, ou mesmo explicitamente, o construtor **sempre chama o construtor da sua superclasse**.
- **Java executa os construtores do topo da hierarquia de classes até a classe atual.**

```java
class Base {
    public Base(String s) {
        System.out.println("Construtor Base(String)");
    }
    public Base(int i) {
        System.out.println("Construtor Base(int)");
    }
}

class Derived extends Base {
    public Derived(String s) {
        super(s);          // chama Base(String) — DEVE ser o primeiro comando
        System.out.println("Construtor Derived(String)");
    }
    public Derived(int i) {
        super(i);          // chama Base(int)
        System.out.println("Construtor Derived(int)");
    }
}
```

```java
new Derived("oi");
```
Saída:
```
Construtor Base(String)
Construtor Derived(String)
```

### 7.5. `this(...)` — encadeando construtores da mesma classe

```java
public class Ponto {
    private int x, y;

    public Ponto() {
        this(0, 0);            // chama o outro construtor DESTA classe
    }

    public Ponto(int x, int y) {
        this.x = x;
        this.y = y;
    }
}
```

### 7.6. Ordem de execução: blocos static, blocos de instância e construtores

Esta é a pegadinha clássica. A ordem completa é:

1. **Blocos estáticos** (`static { }`) da superclasse — uma única vez, quando a classe é **carregada**
2. **Blocos estáticos** da subclasse — uma única vez
3. A cada `new`:
   - `super(...)` → sobe até `Object`
   - **Inicializadores de atributos de instância** e **blocos de instância** `{ }`, na ordem textual
   - **Corpo do construtor**

```java
class Pai {
    static { System.out.println("1 - static Pai"); }
           { System.out.println("3 - bloco instancia Pai"); }
    Pai()  { System.out.println("4 - construtor Pai"); }
}

class Filho extends Pai {
    static { System.out.println("2 - static Filho"); }
           { System.out.println("5 - bloco instancia Filho"); }
    Filho() { System.out.println("6 - construtor Filho"); }

    public static void main(String[] args) {
        new Filho();
        System.out.println("---");
        new Filho();
    }
}
```

Saída:
```
1 - static Pai
2 - static Filho
3 - bloco instancia Pai
4 - construtor Pai
5 - bloco instancia Filho
6 - construtor Filho
---
3 - bloco instancia Pai
4 - construtor Pai
5 - bloco instancia Filho
6 - construtor Filho
```

> ⚠️ **Pegadinha de prova**
> - Blocos `static` executam **uma única vez** (no carregamento da classe), **antes** de qualquer construtor e **antes** do `main`.
> - O `super()` implícito só é inserido se você **não** escrever `super(...)` nem `this(...)`. Se a superclasse **não tiver** construtor sem argumentos, isso é **erro de compilação**.
> - `super(...)` e `this(...)` devem ser o **primeiro comando** do construtor, e **não podem coexistir** no mesmo construtor.
> - Construtores **não são herdados**. Devem ser definidos em cada classe.
> - Construtor **não pode** ser `final`, `static`, `abstract`, `native` nem `synchronized` — só aceita modificadores de acesso.
> - Se você escrever `public void Aluno() { }`, isso **não é um construtor**, é um método comum chamado `Aluno`! E a classe continua ganhando o construtor default.

---

## 8. Tipos primitivos

### 8.1. A tabela (slide 48) — decore!

| Tipo | Conteúdo | Default | Tamanho (bits) | Mínimo | Máximo |
|---|---|---|---|---|---|
| `boolean` | Valor lógico | `false` | 8 | — | — |
| `char` | Caractere Unicode | `\u0000` | 16 | `\u0000` | `￿` |
| `byte` | Inteiro com sinal | `0` | 8 | -2⁷ (-128) | 2⁷-1 (127) |
| `short` | Inteiro com sinal | `0` | 16 | -2¹⁵ (-32.768) | 2¹⁵-1 (32.767) |
| `int` | Inteiro com sinal | `0` | 32 | -2³¹ | 2³¹-1 |
| `long` | Inteiro com sinal | `0` | 64 | -2⁶³ | 2⁶³-1 |
| `float` | Ponto flutuante | `0.0` | 32 | IEEE 754 | IEEE 754 |
| `double` | Ponto flutuante | `0.0` | 64 | IEEE 754 | IEEE 754 |

### 8.2. Expressões e literais (slide 52)

- Um **literal inteiro** é, por default, do tipo primitivo **`int`**.
- Um **literal ponto flutuante** é, por default, do tipo primitivo **`double`**.
- Durante a avaliação de expressões, os operandos são convertidos para o mesmo tipo primitivo do operando de **maior precisão**.
- Tipos `short` e `byte` são **promovidos para `int`** em qualquer operação aritmética.

```java
long  x = 10;          // 10 é int, promovido para long — OK
float f = 3.14;        // ERRO! 3.14 é double, não cabe em float sem cast
float f2 = 3.14f;      // OK — sufixo f
float f3 = (float) 3.14;   // OK — cast explícito
long  y = 10000000000;     // ERRO! literal int estoura
long  y2 = 10000000000L;   // OK — sufixo L
```

### 8.3. O erro clássico do slide 52

```java
byte b1 = 10;
byte b2 = 20;
short c = b1 + b2;     // → ERRO DE COMPILAÇÃO!
```

Motivo: `b1 + b2` é promovido a **`int`**, e `int` não cabe em `short` implicitamente.

> ⚠️ **Pegadinha de prova (erro no próprio slide!)**
> O PDF sugere corrigir com:
> ```java
> short c = (short) b1 + b2;     // AINDA ESTÁ ERRADO!
> ```
> O cast tem precedência **maior** que a soma, então ele se aplica só a `b1`. Resultado: `(short)b1 + b2` → `short + byte` → promove a `int` → não cabe em `short`. O correto é:
> ```java
> short c = (short) (b1 + b2);   // CORRETO: parênteses envolvendo a expressão
> ```
> O mesmo vale para o "Exemplo 1" do slide 50 (`short d = (short) b1 + b2;`), que **não compila** como está escrito.

> ⚠️ **Pegadinha de prova**
> - 🟥 `boolean` ocupa 8 bits na tabela do slide, mas a especificação da JVM **não define** o tamanho real; na prática a JVM usa uma palavra inteira. O que a JVMS 8 define é que `boolean` **é** um tipo da JVM (§2.3.4), sem representação própria em runtime: vira `int`, e **arrays** de `boolean` usam `baload`/`bastore`, iguais aos de `byte`. Para a prova, use a tabela do PDF.
> - `char` é **sem sinal** (0 a 65535); `byte`, `short`, `int` e `long` são **com sinal**.
> - **Não existe** tipo primitivo sem sinal em Java (diferente de C).
> - `boolean` **não** é convertido para/de número. `if (1)` é **erro de compilação** em Java.
> - Tipos primitivos **não são objetos**: não têm métodos e não podem ser `null`.

---

## 9. Conversão e casting de tipos primitivos

### 9.1. Definições (slides 49 e 50)

- **Conversão (*widening*)**: acontece quando existe uma modificação do tipo de uma variável de forma **implícita** (automática, sem perda de informação).
- **Casting (*narrowing*)**: acontece quando há uma modificação do tipo de uma variável de forma **explícita** (o programador escreve `(tipo)`, podendo haver perda).

### 9.2. Diagrama de conversão (slide 51)

```
          char ──┐
                 ├──> int ──> long ──> float ──> double      (setas = CONVERSÃO implícita)
 byte ──> short ─┘

          Qualquer caminho CONTRA as setas exige CASTING explícito.
```

### 9.3. Onde ocorre conversão implícita

**a) Atribuições**
```java
int i;
double d;
i = 100;
d = i;        // int → double: conversão implícita. d vale 100.0
```

**b) Chamadas de métodos**
```java
java.util.Vector v = new java.util.Vector();
String s = "Eita!!";
v.add(s);     // a assinatura é add(Object o): String → Object, conversão implícita
```

**c) Operações aritméticas**
```java
byte  b = 2;
int   i = 5;
float f = 11.1f;
double d = b * i - f;   // b*i vira int; int - float vira float;
                        // o float é implicitamente convertido para double na atribuição
System.out.println(d);  // 11.100000381469727  (imprecisão do float!)
```

### 9.4. Casting explícito

```java
// Exemplo 3 do slide (correto)
long l = 1200;
int i = (int) l;             // i = 1200

// Exemplo 2 do slide: truncamento de bits
int i2 = 16777473;           // 0x01000101
byte b2 = (byte) i2;         // pega só os 8 bits menos significativos: 0x01 = 1
System.out.println(b2);      // 1

// Perda de parte fracionária (truncamento, NÃO arredondamento)
double d = 9.99;
int n = (int) d;
System.out.println(n);       // 9

// char e int
char c = 'A';
int codigo = c;              // conversão implícita: 65
char c2 = (char) 66;         // casting: 'B'
System.out.println(codigo + " " + c2);   // 65 B
```

> ⚠️ **Pegadinha de prova**
> - Conversão `int` → `float` e `long` → `float`/`double` é **implícita**, embora possa **perder precisão**! Java permite porque não perde *magnitude*.
> - `char` → `short` e `short` → `char` exigem **casting** nos dois sentidos (têm 16 bits, mas faixas diferentes).
> - `boolean` **não participa** de nenhuma conversão ou casting com outros tipos.
> - O casting de `int` para `byte` **trunca bits**, não satura. `(byte) 200` dá `-56`, não `127`.
> - Casting de ponto flutuante para inteiro **trunca** em direção a zero: `(int) -9.99` = `-9`.

---

> 🟦 **Divergência Java 8 — wrappers e coleções**
> Todo este capítulo assume **Java 1.4, sem generics e sem autoboxing**. No Java 8:
>
> ```java
> // Como o PDF escreve (Java 1.4)            // Como se escreve no Java 8
> List lista = new ArrayList();               List<Integer> lista = new ArrayList<>();
> lista.add(new Integer(5));                  lista.add(5);            // autoboxing (Java 5)
> Integer i = (Integer) lista.get(0);         int i = lista.get(0);    // sem cast, unboxing
> int v = i.intValue();
> ```
>
> `new Integer(5)` ainda **compila** no Java 8 (só foi marcado como *deprecated* no Java 9), mas o
> recomendado é `Integer.valueOf(5)`, que reaproveita o cache de −128 a 127 — o que explica o
> clássico `Integer a = 127, b = 127; a == b` → `true`, mas com `128` → `false`.
>
> **Na prova:** a semântica de wrapper (objeto que embrulha um primitivo) não mudou; só a sintaxe.

## 10. Classes Wrappers

### 10.1. Definição (slide 53)

- São classes que **encapsulam um único e imutável valor**.
- Cada tipo primitivo possui uma **classe wrapper correspondente**.
- Permitem **armazenar valores primitivos em estruturas da API Collection** (que só aceitam objetos).

| Tipo Primitivo | Classe Wrapper |
|---|---|
| `boolean` | `Boolean` |
| `byte` | `Byte` |
| `char` | `Character` *(o slide escreve "Char" — está incorreto)* |
| `short` | `Short` |
| `int` | `Integer` |
| `long` | `Long` |
| `float` | `Float` |
| `double` | `Double` |

### 10.2. Criando wrappers (slide 54)

```java
// A partir do valor primitivo
Integer intObj1    = new Integer(1);
Double  doubleObj1 = new Double(5.5);

// A partir de uma representação em String
Integer intObj2    = new Integer("1");
Double  doubleObj2 = new Double("5.5");
```

### 10.3. Uso típico

```java
import java.util.ArrayList;
import java.util.List;

public class ExemploWrapper {
    public static void main(String[] args) {
        List lista = new ArrayList();
        // lista.add(5);   // na versão do PDF (Java 1.4) isso NÃO compila!
        lista.add(new Integer(5));               // precisa do wrapper
        Integer i = (Integer) lista.get(0);
        int valor = i.intValue();                // desembrulhando
        System.out.println(valor);               // 5

        // Conversão String -> primitivo (muito usada)
        int n = Integer.parseInt("42");
        double d = Double.parseDouble("3.14");
        System.out.println(n + d);               // 45.14

        // Constantes úteis
        System.out.println(Integer.MAX_VALUE);   // 2147483647
        System.out.println(Integer.MIN_VALUE);   // -2147483648
    }
}
```

> ⚠️ **Pegadinha de prova**
> - O wrapper de `char` é **`Character`**, e o de `int` é **`Integer`** — não `Char` nem `Int`.
> - Wrappers são **imutáveis**: `new Integer(5)` nunca muda de valor.
> - `Integer.parseInt("x")` retorna um **primitivo `int`**; `Integer.valueOf("x")` retorna um **objeto `Integer`**.
> - `Character` **não** tem construtor a partir de `String`.
> - Comparar wrappers com `==` compara **referências**, não valores:
>   ```java
>   Integer a = new Integer(127);
>   Integer b = new Integer(127);
>   System.out.println(a == b);        // false!
>   System.out.println(a.equals(b));   // true
>   ```

---

## 11. A classe String

### 11.1. Fatos essenciais (slides 55 e 99)

- `String` é uma **classe** da linguagem Java, **não** um tipo primitivo.
- Java utiliza esta classe para **encapsular strings de caracteres**.
- Cada instância representa uma string **imutável**: depois de criada, a string representada **não pode ser alterada**.
- Quando uma **literal** é compilada, ela é adicionada a um **pool de literais**. Caso o compilador encontre essa literal já no pool, a literal existente é **reutilizada**.

```
   s1 ──┐
   s2 ──┼──> "minha string"     (uma única instância no Pool de literais)
   s3 ──┘
```

### 11.2. Métodos utilitários citados

| Método | Descrição |
|---|---|
| `boolean equals(Object o)` | Compara o **conteúdo** de duas strings |
| `boolean equalsIgnoreCase(String s)` | Compara ignorando maiúsculas/minúsculas |
| `int length()` | Retorna o número de caracteres |
| `String substring(int ini [, int fim])` | Extrai um pedaço |
| `String toLowerCase()` | Converte para minúsculas |
| `String toUpperCase()` | Converte para maiúsculas |

### 11.3. Exemplo comentado

```java
public class ExemploString {
    public static void main(String[] args) {
        String nome      = "Carolina";
        String sobreNome = "Buarque";

        System.out.println(nome.length());              // 8
        System.out.println(nome.toUpperCase());         // CAROLINA
        System.out.println(nome);                       // Carolina  <- IMUTÁVEL! não mudou
        System.out.println(nome.substring(0, 4));       // Caro
        System.out.println(nome + " " + sobreNome);     // Carolina Buarque

        // Pool de literais
        String a = "java";
        String b = "java";
        String c = new String("java");

        System.out.println(a == b);          // true  -> mesma instância no pool
        System.out.println(a == c);          // false -> new SEMPRE cria novo objeto
        System.out.println(a.equals(c));     // true  -> mesmo conteúdo
        System.out.println(a.equalsIgnoreCase("JAVA"));  // true
    }
}
```

Saída:
```
8
CAROLINA
Carolina
Caro
Carolina Buarque
true
false
true
true
```

### 11.4. `String` vs `StringBuffer`

Como `String` é imutável, concatenar em laço cria muitos objetos descartáveis. `StringBuffer` (usado no exemplo do slide 94) é **mutável**:

```java
StringBuffer sb = new StringBuffer("TESTE");
sb.append("-realizado append");
System.out.println(sb);        // TESTE-realizado append  (o MESMO objeto mudou)
```

> ⚠️ **Pegadinha de prova**
> - `String` **não** é tipo primitivo. É a pegadinha número um.
> - `String` é `final`: **não pode ser estendida**.
> - `length` em **array** é atributo (`arr.length`); em **String** é método (`s.length()`).
> - `s.toUpperCase()` **não altera** `s`, **retorna uma nova String**. Se você não atribuir, perde o resultado.
> - `==` entre Strings compara referências. Sempre use `equals()`.

---

## 12. Modificadores de acesso

### 12.1. Definição (slide 56)

Definem o acesso que outras classes terão à classe, a seus métodos e seus atributos.

| Modificador | Visibilidade | Pode ser usado por |
|---|---|---|
| **`public`** | Visível para **qualquer classe**, sem restrições | Classes, atributos e métodos |
| **`protected`** | Visível para todas as classes do **mesmo pacote** e para as **subclasses** (mesmo em outro pacote) | Atributos e métodos **apenas** |
| **(default)** — nenhum modificador | Visível para todas as classes do **mesmo pacote** | Classes, atributos e métodos |
| **`private`** | Visível **somente para a própria classe** | Classes internas, atributos e métodos |

### 12.2. Tabela de visibilidade cruzada (memorize)

| Acesso a partir de... | `private` | (default) | `protected` | `public` |
|---|:---:|:---:|:---:|:---:|
| Mesma classe | ✅ | ✅ | ✅ | ✅ |
| Outra classe do mesmo pacote | ❌ | ✅ | ✅ | ✅ |
| Subclasse em outro pacote | ❌ | ❌ | ✅ | ✅ |
| Classe qualquer em outro pacote | ❌ | ❌ | ❌ | ✅ |

### 12.3. Exemplo

```java
package br.unb.sb;

public class Base {
    public    int pub  = 1;
    protected int prot = 2;
              int def  = 3;   // default / package-private
    private   int priv = 4;

    public void mostrarTudo() {
        System.out.println(pub + prot + def + priv);   // OK: tudo visível aqui
    }
}
```

```java
package br.unb.outro;
import br.unb.sb.Base;

public class Filha extends Base {
    public void testar() {
        System.out.println(pub);     // OK
        System.out.println(prot);    // OK — sou subclasse
        // System.out.println(def);  // ERRO — pacote diferente
        // System.out.println(priv); // ERRO — private
    }
}

class Estranha {
    public void testar() {
        Base b = new Base();
        System.out.println(b.pub);     // OK
        // System.out.println(b.prot); // ERRO — não sou subclasse nem do mesmo pacote
    }
}
```

> ⚠️ **Pegadinha de prova**
> - Uma **classe de topo** só pode ser `public` ou **default**. **Não pode** ser `private` nem `protected`. (Classes **internas** podem.)
> - `protected` **inclui** o acesso de pacote: é `default` + subclasses. É **mais permissivo** que default, não menos.
> - A ordem de restritividade é: `private` < `default` < `protected` < `public`.
> - Uma subclasse em outro pacote acessa membros `protected` **apenas através de referências do seu próprio tipo** (não de uma referência genérica da superclasse).
> - `private` **não** significa "invisível para a subclasse na mesma classe" — significa invisível para qualquer outra classe, mesmo no mesmo arquivo... na verdade, classes aninhadas no mesmo arquivo de topo **podem** acessar.

---

## 13. A classe Object

### 13.1. Fatos (slides 57 e 58)

- É o **topo da hierarquia de classes do Java**.
- **Toda classe em Java é "filha" da classe `Object`.**
- Mesmo que uma classe **não use** a palavra reservada `extends`, o compilador gera a classe **estendendo diretamente de `Object`**.

```java
public class Aluno { }
// é EXATAMENTE equivalente a:
public class Aluno extends Object { }
```

### 13.2. Métodos herdados por toda classe

| Grupo | Métodos | Finalidade |
|---|---|---|
| Controle de threads | `wait()`, `notify()`, `notifyAll()` | Sincronização entre threads (usam o monitor do objeto) |
| Informação | `toString()` | Fornece informações úteis sobre o objeto (usado implicitamente em `println` e `+`) |
| Comparação | `equals(Object obj)` | Comparação **detalhada** (de conteúdo) entre dois objetos |
| Outros | `hashCode()`, `getClass()`, `clone()`, `finalize()` | Hash, metadados, cópia, finalização pelo GC |

### 13.3. Exemplo: sobrescrevendo `toString()` e `equals()`

```java
public class Ponto {
    private int x, y;

    public Ponto(int x, int y) { this.x = x; this.y = y; }

    public String toString() {
        return "Ponto(" + x + ", " + y + ")";
    }

    public boolean equals(Object obj) {
        if (this == obj) return true;                    // mesma referência
        if (!(obj instanceof Ponto)) return false;       // tipo incompatível
        Ponto outro = (Ponto) obj;                       // casting seguro
        return this.x == outro.x && this.y == outro.y;   // comparação de conteúdo
    }

    public static void main(String[] args) {
        Ponto p1 = new Ponto(1, 2);
        Ponto p2 = new Ponto(1, 2);
        System.out.println(p1);              // Ponto(1, 2)   <- toString() implícito
        System.out.println(p1 == p2);        // false
        System.out.println(p1.equals(p2));   // true
    }
}
```

Sem o `toString()` sobrescrito, a saída seria algo como `Ponto@1b6d3586` (nome da classe + hashcode em hexa).

> ⚠️ **Pegadinha de prova**
> - **`Object` TEM construtor**: `public Object()`. Toda cadeia de `super()` termina nele.
> - `Object` **não é** uma classe abstrata nem uma interface: é uma **classe concreta e instanciável** (`Object o = new Object();` é válido).
> - `equals()` **da classe `Object`** compara **referências** (funciona igual a `==`). Só compara conteúdo se você **sobrescrever**.
> - A assinatura correta é `public boolean equals(Object obj)`. Se você escrever `equals(Ponto p)`, isso é **sobrecarga**, não sobrescrita — e coleções continuarão usando o `equals(Object)` da `Object`!
> - `finalize()` também vem de `Object` e é usado pelo Garbage Collector.

---

## 14. A referência `this`

### 14.1. Definição (slide 59)

`this` é uma **referência para a instância corrente**. Utilizado em **três situações**:

1. Para **diferenciar um atributo** (variável da classe) de uma variável local ou de um parâmetro.
2. Para **passar o objeto corrente como parâmetro**.
3. Para **encadear chamadas de construtores**.

### 14.2. Caso 1 — desambiguação (slide 60)

```java
public class Pessoa {
    private String nome;

    public void setNome(String nome) {
        // this.nome -> atributo da classe
        // nome      -> variável local (parâmetro) do método
        this.nome = nome;
    }
}
```

Sem o `this`, `nome = nome;` atribuiria o parâmetro a si mesmo e o atributo continuaria `null`.

### 14.3. Caso 2 — passar o objeto corrente

```java
public class Janela {
    public void registrar(Listener l) { /* ... */ }
}

public class Botao implements Listener {
    public void instalar(Janela j) {
        j.registrar(this);      // passa ESTE objeto como parâmetro
    }
}
```

### 14.4. Caso 3 — encadear construtores

```java
public class Retangulo {
    private int largura, altura;

    public Retangulo() {
        this(1, 1);                 // chama o construtor de 2 argumentos
    }

    public Retangulo(int lado) {
        this(lado, lado);
    }

    public Retangulo(int largura, int altura) {
        this.largura = largura;
        this.altura = altura;
    }
}
```

> ⚠️ **Pegadinha de prova**
> - `this` **não existe** em métodos `static` (não há instância corrente) → erro de compilação.
> - `this(...)` deve ser o **primeiro comando** do construtor e **não pode** aparecer junto com `super(...)`.
> - `this` **não pode** ser reatribuído (`this = outro;` é erro).
> - `super` é a referência análoga para a superclasse.

---

## 15. Sintaxe básica, comentários, Javadoc, identificadores e palavras reservadas

### 15.1. Elementos básicos (slide 62)

| Elemento | Definição |
|---|---|
| **Statement** | Uma ou mais linhas terminadas por `;` |
| **Bloco** | Conjunto de statements delimitados por `{` e `}` |
| **Comentário `//`** | Comentário simples, de **uma linha** |
| **Comentário `/* */`** | Comentário simples, de **uma ou mais linhas** |
| **Comentário `/** */`** | Comentário para **documentação** (Javadoc) |

### 15.2. Javadoc (slide 63)

Ferramenta do Java para **geração de documentação de código**. A própria API Java em HTML é gerada assim, a partir dos arquivos-fonte.

```java
/**
 * Retorna o nome do usuário cadastrado.
 *
 * @return String - Nome do usuário
 */
public String getNome() {
    return this.nome;
}
```

Tags comuns: `@param`, `@return`, `@throws`, `@author`, `@version`, `@deprecated`, `@see`.

```bash
$ javadoc -d docs MinhaClasse.java     # gera documentação HTML no diretório docs/
```

### 15.3. Identificadores (slide 64)

São os nomes dados a uma **classe, método, atributo, variável ou parâmetro**. Regras:

- Começam sempre por um **caractere Unicode (letra)**, `_` (underscore) ou `$` (cifrão).
- **Diferenciam maiúsculas e minúsculas** (*case sensitive*): `nome` ≠ `Nome`.
- **Não podem coincidir** com uma palavra reservada.

Exemplos **válidos** do slide:
```
x        y        America        _9_i$to_EH_meio_esquisito
$4outroExemplo    exemploCOMmuitasPALAVRAS
```

Exemplos **inválidos**:
```
9letras      (começa com dígito)
meu-nome     (hífen não é permitido)
class        (palavra reservada)
meu nome     (espaço)
```

### 15.4. Convenções da linguagem (slide 65)

| Elemento | Convenção | Exemplo |
|---|---|---|
| **Constantes** | Todas as letras **maiúsculas**, palavras separadas por `_` | `public static final int QUANTIDADE_MAXIMA = 100;` |
| **Variáveis** | Começam com letra **minúscula** | `String nomeUsuario;` |
| **Classes** | Começam com letra **maiúscula** | `public class Usuario { }` |
| **Métodos** | Começam com letra **minúscula** | `public void recuperaUsuario(int codigoUsuario) { }` |
| **Nome composto** | Cada palavra seguinte com maiúscula (*camelCase*) | `variavelComNomeComposto` |

### 15.5. Palavras reservadas (slide 66)

| | | | | |
|---|---|---|---|---|
| `abstract` | `boolean` | `break` | `byte` | `case` |
| `catch` | `char` | `class` | `const` | `continue` |
| `default` | `do` | `double` | `else` | `extends` |
| `false` | `final` | `finally` | `float` | `for` |
| `goto` | `if` | `implements` | `import` | `instanceof` |
| `int` | `interface` | `long` | `native` | `new` |
| `null` | `package` | `private` | `protected` | `public` |
| `return` | `short` | `static` | `super` | `synchronized` |
| `this` | `throw` | `throws` | `transient` | `true` |
| `try` | `void` | `volatile` | `while` | |

> ⚠️ **Pegadinha de prova**
> - `goto` e `const` são **palavras reservadas mas NÃO implementadas** em Java (reservadas justamente para impedir seu uso). O slide 75 reforça: *"O comando `goto` não é implementado por Java."*
> - `true`, `false` e `null` são **literais**, não tecnicamente palavras-chave — mas o slide os lista como reservados e você **não pode** usá-los como identificador.
> - `main`, `String`, `System`, `length` **não** são palavras reservadas — são apenas nomes da API. Você *pode* (mas não deve) criar uma classe chamada `String`.
> - `$` e `_` são válidos em identificadores, mas **espaço, hífen e dígito inicial não**.
> - `/** */` só vira documentação se estiver **imediatamente antes** da declaração.

---

## 16. Operadores e precedência

### 16.1. Tabela de precedência (slides 68 e 69)

Legenda de operandos: **A** = aritmético, **I** = inteiro, **B** = booleano, **O** = objeto, **S** = String, **P** = primitivo, **C** = classe/tipo, **V** = variável, **Q** = qualquer.
Associatividade: **D** = direita p/ esquerda, **E** = esquerda p/ direita.

| Prec. | Operador | Operandos | Assoc. | Operação |
|:---:|---|:---:|:---:|---|
| **1** | `++`, `--` | A | D | Incremento / decremento unário |
| | `+`, `-` | A | D | Mais / menos unário (sinal) |
| | `~` | I | D | Complemento de 1 (bit a bit) |
| | `!` | B | D | Complemento lógico (*not*) |
| | `(tipo)` | O | D | *Cast* |
| **2** | `*`, `/`, `%` | A,A | E | Multiplicação, divisão, módulo |
| **3** | `+`, `-` | A,A | E | Adição, subtração |
| | `+` | S,S | E | **Concatenação de strings** |
| **4** | `<<` | I,I | E | *Shift left* |
| | `>>` | I,I | E | *Shift right* (com sinal) |
| | `>>>` | I,I | E | *Shift right* **sem sinal** |
| **5** | `<`, `<=` | A,A | E | Menor que, menor ou igual a |
| | `>`, `>=` | A,A | E | Maior que, maior ou igual a |
| | `instanceof` | O,C | E | **Comparação de tipos** |
| **6** | `==`, `!=` | P,P | E | Igual / diferente (**valores**) |
| | `==`, `!=` | O,O | E | Igual / diferente (**referência ao objeto**) |
| **7** | `&` | I,I | E | E (bits) |
| | `&` | B,B | E | E (lógico — **sem** curto-circuito) |
| **8** | `^` | I,I | E | XOR (bits) |
| | `^` | B,B | E | XOR (lógico) |
| **9** | `\|` | I,I | E | OU (bits) |
| | `\|` | B,B | E | OU (lógico — **sem** curto-circuito) |
| **10** | `&&` | B,B | E | E (lógico — **com curto-circuito**) |
| **11** | `\|\|` | B,B | E | OU (lógico — **com curto-circuito**) |
| **12** | `?:` | B,Q,Q | E | Operador condicional (**ternário**) |
| **13** | `=` | V,Q | D | Atribuição |
| | `*=`, `/=`, `%=`, `+=`, `-=`, `<<=`, `>>=`, `>>>=`, `&=`, `^=`, `\|=` | V,Q | D | Atribuição com operação |

### 16.2. Exemplos comentados

**Incremento pré vs pós:**
```java
int i = 5;
System.out.println(i++);   // 5  — imprime DEPOIS usa o valor antigo, i vira 6
System.out.println(i);     // 6
int j = 5;
System.out.println(++j);   // 6  — incrementa ANTES
```

**Divisão inteira e módulo:**
```java
System.out.println(7 / 2);        // 3    <- divisão INTEIRA (ambos são int)
System.out.println(7 % 2);        // 1
System.out.println(7 / 2.0);      // 3.5  <- um operando é double
System.out.println(-7 % 3);       // -1   <- o sinal segue o dividendo
System.out.println(5 / 0);        // ArithmeticException: / by zero
System.out.println(5.0 / 0);      // Infinity  <- ponto flutuante NÃO lança exceção!
```

**Concatenação (pegadinha clássica):**
```java
System.out.println(1 + 2 + "x");    // "3x"  — soma primeiro (esquerda p/ direita)
System.out.println("x" + 1 + 2);    // "x12" — vira String logo no primeiro +
```

**Curto-circuito:**
```java
String s = null;
if (s != null && s.length() > 0) { }   // SEGURO: && não avalia o lado direito
if (s != null &  s.length() > 0) { }   // NullPointerException! & avalia AMBOS
```

**Shifts:**
```java
System.out.println(8 >> 1);     // 4   (8/2)
System.out.println(8 << 2);     // 32  (8*4)
System.out.println(-8 >> 1);    // -4  preserva o sinal
System.out.println(-8 >>> 1);   // 2147483644  preenche com ZEROS à esquerda
```

**Ternário:**
```java
int idade = 20;
String status = (idade >= 18) ? "maior" : "menor";
System.out.println(status);     // maior
```

> ⚠️ **Pegadinha de prova**
> - O `+` é o **único operador sobrecarregado** de Java (aritmética + concatenação). Java **não permite** ao programador sobrecarregar operadores.
> - `&&` e `||` fazem **curto-circuito**; `&` e `|` aplicados a booleanos **avaliam sempre os dois lados**.
> - `>>` preserva o bit de sinal; `>>>` preenche com zero. **Não existe `<<<`**.
> - Divisão inteira por zero lança `ArithmeticException`; divisão de **ponto flutuante** por zero resulta em `Infinity` ou `NaN`, **sem exceção**.
> - `==` entre objetos compara **referências**, não conteúdo (nível de precedência 6, linha "O,O").
> - `instanceof` tem precedência **5**, maior que `==`.
> - Atribuição com operação faz **cast implícito**: `byte b = 10; b += 300;` **compila** (equivale a `b = (byte)(b + 300)`), enquanto `b = b + 300;` **não compila**.

---

## 17. Estruturas de controle

### 17.1. Decisão (slide 70)

Java provê **duas** estruturas de decisão: `if/else` e `switch`.

**`if / else`**
```java
if (expressao_booleana) {
    ....
} else {
    ...
}
```

```java
int nota = 7;
if (nota >= 9) {
    System.out.println("Excelente");
} else if (nota >= 5) {
    System.out.println("Aprovado");
} else {
    System.out.println("Reprovado");
}
// Saída: Aprovado
```

**`switch`**
```java
switch (key) {
    case value:
        <bloco de comandos>
        break;
    default:
        <bloco de comandos>
        break;
}
```

```java
int dia = 3;
switch (dia) {
    case 1: System.out.println("Domingo"); break;
    case 2: System.out.println("Segunda"); break;
    case 3: System.out.println("Terca");   break;
    default: System.out.println("Outro");
}
// Saída: Terca
```

**Efeito cascata (*fall-through*)** quando falta o `break`:
```java
int x = 1;
switch (x) {
    case 1: System.out.println("um");
    case 2: System.out.println("dois");
    case 3: System.out.println("tres"); break;
    case 4: System.out.println("quatro");
}
```
Saída:
```
um
dois
tres
```

### 17.2. Laços (slide 71)

Existem **três** estruturas de laço em Java: `while`, `do/while` e `for`.

**`while`** — usado quando **não se sabe de antemão** a quantidade de iterações.
```java
while (expressao_booleana) {
    <bloco de comandos>
}
```
- Caso a expressão booleana seja falsa, o bloco **não será executado nenhuma vez**.
- O programador deve **garantir que a condição de parada será satisfeita**.

```java
int i = 0;
while (i < 3) {
    System.out.print(i + " ");
    i++;
}
// Saída: 0 1 2
```

**`do/while`** — também para quando não se sabe o número de iterações, mas o trecho é **sempre executado pelo menos uma vez**.
```java
do {
    <bloco de comandos>
} while (expressao_booleana);
```

```java
int j = 10;
do {
    System.out.println("Executou! j = " + j);
} while (j < 3);
// Saída: Executou! j = 10     <- executou 1 vez mesmo com a condição falsa
```

**`for`** — usado quando **sabemos de antemão** o número de iterações.
```java
for (<statement_iniciacao> [, <statement_iniciacao n>];
     <condicao_parada>;
     <expressao_incremento> [, <expressao_incremento n>]) {
    <bloco de comandos>
}
```

```java
for (int i = 0, j = 10; i < j; i++, j--) {
    System.out.print("(" + i + "," + j + ") ");
}
// Saída: (0,10) (1,9) (2,8) (3,7) (4,6)
```

### 17.3. `break` e `continue` (slide 75)

| Comando | Efeito |
|---|---|
| `break` | Comando de **saída** de um laço ou de um `switch` |
| `continue` | Comando de **salto para a próxima iteração** do laço |
| `goto` | **Não é implementado por Java** |

```java
for (int i = 0; i < 10; i++) {
    if (i == 3) continue;    // pula o 3
    if (i == 6) break;       // sai do laço
    System.out.print(i + " ");
}
// Saída: 0 1 2 4 5
```

Java também suporta **labels** (rótulos) para sair de laços aninhados:
```java
externo:
for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
        if (j == 2) continue externo;
        if (i == 2) break externo;
        System.out.print(i + "" + j + " ");
    }
}
// Saída: 00 01 10 11
```

> ⚠️ **Pegadinha de prova**
> - A condição do `if` e do `while` **deve ser booleana**. `if (x = 5)` é **erro de compilação** em Java (funcionaria em C). A exceção é `if (b = true)` com `b` booleano — compila e sempre é verdade.
> - `do/while` termina com **ponto e vírgula**: `} while (cond);`
> - Só o `do/while` garante **pelo menos uma execução**.
> - No `for`, **todas as três partes são opcionais**: `for(;;){}` é um laço infinito válido.
> - Variável declarada na iniciação do `for` tem **escopo limitado ao laço**.
> - 🟦 `switch` (na versão do PDF, Java 1.4) só aceita `byte`, `short`, `char` e `int` — **não aceita `long`, `float`, `double`, `boolean` nem `String`**. **No Java 8** o `switch` aceita também **`enum`** (desde o Java 5) e **`String`** (desde o Java 7). Continua **sem** aceitar `long`, `float`, `double` e `boolean` — inclusive no Java 8. Um `switch` sobre `String` é compilado como `hashCode()` + `lookupswitch` + `equals()`; sobre `enum`, como `tableswitch` sobre o `ordinal()`.
> - Os `case` devem ser **constantes compile-time** e **não podem repetir valores**.
> - `default` **não precisa** ser o último caso e **não precisa** existir.
> - `break` sai de **apenas um** nível de laço; use label para sair de vários.

---

## 18. Arrays

### 18.1. Definição (slide 76)

- Array é uma estrutura de **tamanho fixo** que armazena **múltiplos valores do mesmo tipo**.
- Qualquer tipo permitido em Java pode ser armazenado:
  - Arrays de **tipos primitivos**
  - Arrays de **referências de objetos**
  - Arrays de **outros arrays** (matrizes)
- O **tamanho** precisa ser definido quando o array é **criado**.
- Um elemento é acessado por sua **posição** (índice).

### 18.2. Os três passos (slide 77)

**Declaração → Construção → Iniciação**

### 18.3. Declaração (slide 78)

Diz ao compilador o **nome** do array e o **tipo** dos elementos.

```java
int[]    intArray;
String[] nomes;
Object[] objects;
```

- **Nenhuma memória é alocada** no momento da declaração.
- **Não se pode estabelecer o tamanho** do array no momento da declaração.

```java
int[10] arr;     // ERRO DE COMPILAÇÃO!
int arr2[];      // Válido (estilo C), mas a convenção Java é int[] arr2;
```

### 18.4. Construção (slide 79)

```java
int[] intArray;
intArray = new int[10];                            // aloca 10 posições

Object[] objArray = { "Objeto1", "Objeto2" };      // construção + iniciação
String[][] stringMatrix = new String[10][20];      // matriz 10x20
boolean[] answers = { true, false, true, true, false };
```

- Uma vez definido o tamanho, **ele não pode mais ser alterado**.
- Quando o array é de **referências para objetos**, somente a memória ocupada **pela referência** é alocada. **Nenhum objeto é criado neste momento.**

```java
String[] nomes = new String[3];
System.out.println(nomes[0]);          // null  <- nenhuma String foi criada!
System.out.println(nomes[0].length()); // NullPointerException!
```

### 18.5. Valores default na construção (slide 80)

| Tipo | Valor inicial |
|---|---|
| `byte` | `0` |
| `short` | `0` |
| `int` | `0` |
| `long` | `0L` |
| `float` | `0.0f` |
| `double` | `0.0d` |
| `char` | `'\u0000'` |
| `boolean` | `false` |
| `reference` (qualquer objeto) | `null` |

### 18.6. Iniciação e percurso (slide 81)

```java
int[] anArray;                    // declare an array of integers
anArray = new int[10];            // create an array of integers

// assign a value to each array element and print
for (int i = 0; i < anArray.length; i++) {
    anArray[i] = i;
    System.out.print(anArray[i] + " ");
}
```
Saída:
```
0 1 2 3 4 5 6 7 8 9
```

- O **menor índice** do array é sempre **zero**.
- O **maior índice** é obtido através de `array.length - 1`.

### 18.7. Matrizes (arrays de arrays)

```java
int[][] m = new int[3][4];       // 3 linhas, 4 colunas
for (int i = 0; i < m.length; i++) {           // m.length = 3
    for (int j = 0; j < m[i].length; j++) {    // m[i].length = 4
        m[i][j] = i * 4 + j;
        System.out.print(m[i][j] + "\t");
    }
    System.out.println();
}
```
Saída:
```
0	1	2	3
4	5	6	7
8	9	10	11
```

Arrays **irregulares** (*jagged*) são permitidos:
```java
int[][] jag = new int[3][];
jag[0] = new int[1];
jag[1] = new int[5];
jag[2] = new int[2];
System.out.println(jag[1].length);   // 5
```

> ⚠️ **Pegadinha de prova**
> - `length` em array é **atributo** (`arr.length`), **sem parênteses**. Em `String` é **método** (`s.length()`).
> - Arrays são **objetos** em Java (herdam de `Object`), mesmo arrays de primitivos.
> - Acessar índice fora da faixa lança **`ArrayIndexOutOfBoundsException`** em **tempo de execução** (não de compilação).
> - `new int[-1]` compila, mas lança `NegativeArraySizeException` em execução.
> - `int[] a = new int[0];` é **válido** — array vazio, `a.length == 0`.
> - A sintaxe abreviada `{ ... }` só funciona **na declaração**:
>   ```java
>   int[] a;
>   a = {1, 2, 3};            // ERRO
>   a = new int[]{1, 2, 3};   // OK
>   ```
> - O tamanho é **fixo** — para tamanho variável, use `ArrayList`/`Vector`.

---

## 19. Modificadores `final`, `static`, `synchronized`, `abstract` e outros

### 19.1. Onde cada um se aplica (slide 82)

| Modificador | Pode ser usado em |
|---|---|
| `final` | Classes, Métodos, Variáveis |
| `static` | Métodos, Variáveis, **iniciadores estáticos** |
| `synchronized` | Métodos, blocos de código |

### 19.2. `final` (slide 83)

**Em classe:** define que a classe **não pode ser estendida**.
```java
public final class Math {
    // esta classe não pode ser estendida
}
// public class MinhaMath extends Math { }  // ERRO DE COMPILAÇÃO
```
Exemplos reais: `String`, `Integer`, `Math`, `System`.

**Em método:** define que o método **não pode ser sobrescrito**.
```java
public final void metodoFinal() {
    // este método não pode ser sobre-escrito
}
```

**Em variável:** define que a variável **não pode ser modificada depois de receber um valor**.
- Para **tipos primitivos**: não podem receber outro valor.
- Para **referências**: não podem referenciar um outro objeto, **mas o conteúdo do objeto original pode ser alterado**.

```java
public class ExemploFinal {
    public static void main(String[] args) {
        final int x = 10;
        // x = 20;                          // ERRO

        final StringBuffer sb = new StringBuffer("abc");
        sb.append("def");                   // OK! o CONTEÚDO pode mudar
        System.out.println(sb);             // abcdef
        // sb = new StringBuffer("xyz");    // ERRO! a REFERÊNCIA não pode mudar
    }
}
```

**Constante clássica:** `final` + `static`
```java
public static final int QUANTIDADE_MAXIMA = 100;
```

### 19.3. `static` em variáveis (slide 84)

Define que uma variável terá **somente uma instância em toda a máquina virtual**. Uma variável estática é uma **variável de classe**.

| Tipo | Comportamento |
|---|---|
| **Variável de Classe** (`static`) | Comum a **todos os objetos** da classe. Uma alteração feita por um objeto **é refletida em todos**, pois todos enxergam a mesma variável |
| **Variável de Instância** (não static) | **Cada objeto** possui um valor diferente |

```java
public class Contador {
    private static int totalInstancias = 0;   // VARIÁVEL DE CLASSE
    private int id;                           // VARIÁVEL DE INSTÂNCIA

    public Contador() {
        totalInstancias++;                    // compartilhado
        this.id = totalInstancias;            // individual
    }

    public static int getTotal() {            // MÉTODO DE CLASSE
        return totalInstancias;
    }

    public int getId() { return id; }

    public static void main(String[] args) {
        Contador c1 = new Contador();
        Contador c2 = new Contador();
        Contador c3 = new Contador();
        System.out.println(c1.getId() + " " + c2.getId() + " " + c3.getId());
        System.out.println("Total: " + Contador.getTotal());
    }
}
```
Saída:
```
1 2 3
Total: 3
```

### 19.4. `static` em métodos (slide 85)

Define que o método **se refere à classe e não a alguma instância** da classe. Pode ser chamado sem criar objeto:

```java
double angulo = 3.14;
double cosseno = Math.cos(angulo);      // Math.cos é static — não há "new Math()"
System.out.println(cosseno);            // -0.9999987317275395
```

### 19.5. `static` — iniciador estático (slide 86)

Trecho de código que é **executado uma única vez, quando a classe é carregada**.

```java
public class IniciadorEstatico {
    private static String staticString = null;
    private String string = null;

    static {
        staticString = "classe foi carregada";
        // string = "esta linha não compila";   // ERRO! contexto static não vê
                                                // atributos de instância
    }
}
```

### 19.6. `synchronized` (slide 87)

Utilizado para **controlar o acesso em trechos críticos de código**, para programas *multi-threaded*. Define que **apenas uma thread** poderá executar o trecho delimitado num período de tempo.

```java
public synchronized void metodoSincronizado() {
    /* somente uma thread de cada vez pode executar este trecho */
}

// Também pode ser um bloco:
public void metodo() {
    synchronized (this) {
        // região crítica
    }
}
```

### 19.7. Tabela "Todos os Modificadores" (slide 88) — **CAI NA PROVA**

| Modificador | Classe | Atributo | Método | Construtor | Blocos livres |
|---|:---:|:---:|:---:|:---:|:---:|
| `public` | **sim** | sim | sim | sim | não |
| `protected` | **não** | sim | sim | sim | não |
| *(default)* | sim | sim | sim | sim | **sim** |
| `private` | **não** | sim | sim | sim | não |
| `final` | sim | sim | sim | **não** | não |
| `abstract` | sim | **não** | sim | **não** | não |
| `static` | **não** | sim | sim | **não** | **sim** |
| `native` | não | não | **sim** | não | não |
| `transient` | não | **sim** | não | não | não |
| `volatile` | não | **sim** | não | não | não |
| `synchronized` | não | não | **sim** | não | **sim** |

Significado dos menos comuns:
- **`native`**: método implementado em código nativo (C/C++), via JNI. Só assinatura em Java.
- **`transient`**: atributo que **não** deve ser serializado (não vai para o arquivo/rede).
- **`volatile`**: atributo cujo valor pode ser alterado por múltiplas threads; força leitura/escrita direto na memória principal, sem cache de thread.

> ⚠️ **Pegadinha de prova (esta tabela é uma mina de V/F)**
> - **`static` NÃO se aplica a classes de topo** (só a classes internas — mas a tabela do slide diz "não" para classe).
> - **`abstract` NÃO se aplica a atributos** nem a construtores.
> - **`final` NÃO se aplica a construtores.**
> - **`protected` e `private` NÃO se aplicam a classes de topo.**
> - `abstract` e `final` são **mutuamente exclusivos** (uma classe abstrata precisa ser estendida; `final` proíbe estender).
> - `abstract` e `static` são incompatíveis em métodos; `abstract` e `private` também.
> - `transient` e `volatile` só se aplicam a **atributos**.
> - `native` só se aplica a **métodos**.
> - Blocos livres aceitam apenas *default* (bloco de instância), `static` e `synchronized`.

### 19.8. Restrições dos contextos `static`

```java
public class Regras {
    int instancia = 1;
    static int classe = 2;

    static void metodoStatic() {
        System.out.println(classe);      // OK
        // System.out.println(instancia); // ERRO! contexto static não vê instância
        // this.instancia;                // ERRO! não há "this"
    }

    void metodoInstancia() {
        System.out.println(classe);      // OK — instância VÊ o static
        System.out.println(instancia);   // OK
    }
}
```

> ⚠️ **Pegadinha de prova**
> - Método `static` **não pode** acessar atributos/métodos de instância nem usar `this`/`super`.
> - Método de instância **pode** acessar membros `static` normalmente.
> - Métodos `static` **não são polimórficos**: eles são **ocultados** (*hiding*), não sobrescritos. A chamada é resolvida pelo **tipo da referência**, em tempo de compilação.
>   ```java
>   class A { static void m() { System.out.println("A"); } }
>   class B extends A { static void m() { System.out.println("B"); } }
>   A ref = new B();
>   ref.m();     // imprime "A", não "B"!
>   ```

---

## 20. Modelo de memória, referências e garbage collection

### 20.1. Modelo de memória (slide 90)

- O modelo de memória do Java é baseado na **abordagem de dupla indireção**, isto é, **as referências são endereços de outro endereço**.
- Esta abordagem permite a utilização do **garbage collector** para **realocação de memória** e **redução da fragmentação** (a JVM pode mover o objeto e só precisa atualizar um ponteiro central).

### 20.2. Atribuições entre referências (slide 91)

**Atribuições entre variáveis de um mesmo tipo não criam novos objetos**, mas sim **cópias da referência** para o mesmo objeto.

```java
Cliente cliente1 = new Cliente();
cliente1.setNome("Carolina");
Cliente cliente2 = null;
Cliente cliente3 = cliente1;     // cliente3 aponta para o MESMO objeto
```

```
   cliente1 ──┐
              ├──> [ Cliente: nome="Carolina", sobrenome=null, nomeIndicacao=null ]
   cliente3 ──┘

   cliente2 ──> null
```

```java
cliente3.setNome("Ana");
System.out.println(cliente1.getNome());   // Ana!  — é o mesmo objeto
```

### 20.3. Garbage Collection (slide 100)

- Em Java, **não é preciso fazer alocação dinâmica explícita** para criar objetos, e **também não é preciso desalocar memória**.
- O **Garbage Collector** é um **processo interno (thread) da JVM** que, de tempos em tempos, executa e faz a **desalocação de objetos que não possuem mais referências**.
- **Não é possível saber quando** os objetos serão enviados para o Garbage Collector.
- Algumas classes precisam definir como suas instâncias devem ser excluídas da memória: para isso, o GC utiliza o método **`finalize()`** da classe `Object`, que pode ser estendido para fazer uma desalocação personalizada.

```java
public class Recurso {
    protected void finalize() throws Throwable {
        System.out.println("Liberando recurso...");
        super.finalize();
    }

    public static void main(String[] args) {
        Recurso r = new Recurso();
        r = null;             // objeto ficou ELEGÍVEL para coleta
        System.gc();          // SUGERE ao GC que colete — NÃO garante nada
    }
}
```

> ⚠️ **Pegadinha de prova**
> - `System.gc()` é apenas uma **sugestão**; a JVM pode ignorá-la. **Não há como forçar** a coleta.
> - **Não há garantia** de que `finalize()` será chamado, nem quando.
> - Um objeto se torna elegível quando **não há mais nenhuma referência alcançável** a ele, não quando você chama `finalize()`.
> - O GC **não elimina vazamentos de memória lógicos**: se você mantém referências desnecessárias em uma `List`, o objeto nunca é coletado.
> - Java **não tem `delete`/`free`**. Atribuir `null` apenas remove uma referência.

---

## 21. Igualdade entre objetos: `==` vs `equals()`

### 21.1. Regras (slide 92)

- A comparação entre dois **tipos primitivos** se faz a partir do operador **`==`**.
- A utilização do operador `==` para comparar **objetos** pode gerar desigualdades ao comparar objetos **idênticos em conteúdo** (pois compara referências).
- No caso das `String`s, basta utilizar o método **`equals`**.
- Todas as classes estendem `Object`, que possui o método:
  ```java
  public boolean equals(Object obj)
  ```
- Para comparar dois objetos de uma mesma classe, deve-se **sobrescrever o método `equals`** de maneira que ele compare se o objeto recebido é igual ao atual.

### 21.2. Exemplo completo

```java
public class Aluno {
    private String matricula;

    public Aluno(String matricula) { this.matricula = matricula; }

    // SEM equals sobrescrito, herda o de Object (compara referências)
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null) return false;
        if (!(obj instanceof Aluno)) return false;
        Aluno outro = (Aluno) obj;
        return this.matricula.equals(outro.matricula);
    }

    public int hashCode() {                 // regra de ouro: sobrescreveu equals,
        return matricula.hashCode();        // sobrescreva hashCode também
    }

    public static void main(String[] args) {
        Aluno a1 = new Aluno("190000001");
        Aluno a2 = new Aluno("190000001");
        Aluno a3 = a1;

        System.out.println(a1 == a2);       // false — objetos diferentes
        System.out.println(a1.equals(a2));  // true  — mesmo conteúdo
        System.out.println(a1 == a3);       // true  — mesma referência
    }
}
```

> ⚠️ **Pegadinha de prova**
> - `equals()` **da `Object`** é idêntico a `==` (compara referências). Sem sobrescrever, `a1.equals(a2)` seria `false`.
> - A assinatura tem de ser `public boolean equals(Object obj)` — com parâmetro `Object`!
> - Se você sobrescreve `equals()`, **deve** sobrescrever `hashCode()`, senão `HashSet`/`HashMap` se comportam errado.
> - Para Strings, `==` pode dar `true` por causa do **pool de literais** — o que torna o bug ainda mais traiçoeiro:
>   ```java
>   String a = "java", b = "java";
>   System.out.println(a == b);              // true  (pool)
>   String c = new String("java");
>   System.out.println(a == c);              // false (new)
>   ```

---

## 22. Passagem de parâmetros

### 22.1. A regra (slide 93)

Quando um argumento é passado como parâmetro na chamada de uma função, na realidade **uma cópia do argumento é passada**.

- **Tipos Primitivos**: é passada uma **cópia do valor**. Caso o valor seja alterado dentro do método, **isso não afetará** o valor no método original.
- **Referências a Objetos**: é passada uma **cópia da referência**.
  - Caso a **referência** seja alterada para outro objeto, **isso NÃO afetará** a referência original.
  - Caso o **objeto apontado** pela referência seja alterado, **essa alteração SERÁ perpetuada**.

> **Frase-chave do slide:** *"No método não é possível modificar a referência, mas é possível modificar o objeto referenciado."*

### 22.2. Exemplo completo do PDF (slides 94-96)

```java
public class TesteParametro {

    // Troca a REFERÊNCIA local -> não afeta o chamador
    public static void modificaSB1(StringBuffer aString) {
        aString = new StringBuffer("nova string");
    }

    // Modifica o OBJETO apontado -> AFETA o chamador
    public static void modificaSB2(StringBuffer sb) {
        sb.append("-realizado append");
    }

    // Primitivo: cópia do valor -> não afeta o chamador
    public static void modificaInt1(int i) {
        i += 10;
    }

    // Array é OBJETO: modificar seus elementos AFETA o chamador
    public static void modificaInt2(int[] array) {
        for (int i = 0; i < array.length; i++) {
            array[i] += 10;
        }
    }

    public static void main(String[] args) {
        StringBuffer string = new StringBuffer("TESTE");
        modificaSB1(string);
        System.out.println("Apos execucao modificaSB1: " + string);
        modificaSB2(string);
        System.out.println("Apos execucao modificaSB2: " + string);

        int[] arrayInt = { 10 };
        modificaInt1(arrayInt[0]);
        System.out.println("Apos execucao modificaInt1: " + arrayInt[0]);
        modificaInt2(arrayInt);
        System.out.print("Apos execucao modificaInt2: ");
        for (int j = 0; j < arrayInt.length; j++) {
            System.out.println(arrayInt[j] + ", ");
        }
    }
}
```

**Saída (slide 96):**
```
Apos execucao modifySB1: TESTE
Apos execucao modifySB2: TESTE-realizado append
Apos execucao modifyInt1: 10
Apos execucao modifyInt2: 20,
```

Analisando linha a linha:

| Chamada | O que fez | Resultado |
|---|---|---|
| `modificaSB1` | Reatribuiu a **cópia** da referência | `TESTE` — **inalterado** |
| `modificaSB2` | Chamou `append()` no **objeto** | `TESTE-realizado append` — **alterado** |
| `modificaInt1` | Somou 10 a uma **cópia do primitivo** | `10` — **inalterado** |
| `modificaInt2` | Alterou os **elementos do array** (objeto) | `20` — **alterado** |

### 22.3. Exemplo "Passagem por valor" (slide 97)

```java
class Retangulo {
    float orig_x, orig_y;
    float altura, largura;

    public void translacao(float x, float y) {
        orig_x = x;              // altera o ATRIBUTO do objeto
        orig_y = y;
        x = 0.0f;                // altera apenas a CÓPIA local do parâmetro
        y = 0.0f;
    }

    public static void main(String[] args) {
        Retangulo ret = new Retangulo();
        float x1 = 15.5f;
        float y1 = 10.5f;
        ret.translacao(x1, y1);
        System.out.println("O valor de x1 e " + x1);
        System.out.println("O valor de y1 e " + y1);
    }
}
```
Saída:
```
O valor de x1 e 15.5
O valor de y1 e 10.5
```
> Os atributos do retângulo **mudaram**, mas `x1` e `y1` **não**, porque `float` é primitivo.
>
> *(Observação: no slide o código está escrito `float x1 = 15.5;`, que **não compila** — literal de ponto flutuante é `double` por default. O correto é `15.5f`.)*

### 22.4. Exemplo "Passagem por referência" (slide 98)

```java
class Vetor {
    String mensagem;

    public void inicia() {
        int v[] = {1, 2, 3, 4, 5};
        mensagem = "Os valores originais do vetor sao: ";
        for (int i = 0; i < v.length; i++) mensagem += " " + v[i];

        modificaVetor(v);                 // passa a referência do ARRAY
        mensagem += "\nOs valores do vetor apos modificacao sao: ";
        for (int i = 0; i < v.length; i++) mensagem += " " + v[i];

        modificaElemento(v[2]);           // passa uma CÓPIA de um int
        mensagem += "\nO valor de v[2] e =" + v[2];
    }

    public void modificaVetor(int v1[]) {     // multiplica todos por 3 -> PERSISTE
        for (int j = 0; j < v1.length; j++) v1[j] *= 3;
    }

    public void modificaElemento(int elem) {  // altera uma cópia -> NÃO persiste
        elem *= 3;
    }

    public String getMensagem() { return mensagem; }

    public static void main(String[] args) {
        Vetor v = new Vetor();
        v.inicia();
        System.out.println(v.getMensagem());
    }
}
```
Saída:
```
Os valores originais do vetor sao:  1 2 3 4 5
Os valores do vetor apos modificacao sao:  3 6 9 12 15
O valor de v[2] e =9
```
> `v[2]` continua `9` (e não `27`) porque `modificaElemento` recebeu apenas uma **cópia do int**.
>
> *(No slide, o `main` chama `v.inicializa()` enquanto o método se chama `inicia()` — erro de digitação do PDF.)*

> ⚠️ **Pegadinha de prova**
> - **Java é SEMPRE passagem por valor.** O que confunde é que, para objetos, "o valor" **é a referência**. O título do slide 98 ("Passagem por Referência") é didático, não técnico.
> - Um método **nunca** consegue fazer a variável do chamador apontar para outro objeto.
> - Arrays são objetos → modificar seus elementos dentro de um método **persiste**.
> - Objetos **imutáveis** (`String`, wrappers) nunca são alterados por um método — parecem "passados por valor".

---

## 23. Herança em Java

### 23.1. Conceito (slides 17, 18 e 103)

- **Herança** é o mecanismo de **incorporar automaticamente métodos e atributos** de uma classe definida em suas classes derivadas.
- Implementada com a palavra reservada **`extends`**.
- **Em Java é possível estender SOMENTE uma classe** (não há herança múltipla de classes).
  - Existe uma perda de flexibilidade **compensada por um ganho de legibilidade**.
  - Evita situações dúbias, como saber de qual superclasse se herda atributos de mesmo nome.
- A classe que estende é a **subclasse**; a classe estendida é a **superclasse**.
  - A **subclasse** é uma **especialização** da superclasse.
  - A **superclasse** é uma **generalização** da subclasse.

### 23.2. Sintaxe (slide 105)

```java
public class Pessoa {
    public void getNome() { }
    public void getCPF()  { }
}

public class Funcionario extends Pessoa {
    public void getSalario() { }
}
```

A subclasse `Funcionario` possui: `getNome()`, `getCPF()` (**herdados**) **e** `getSalario()` (**próprio**).

```java
Funcionario f = new Funcionario();
f.getNome();       // OK — herdado de Pessoa
f.getSalario();    // OK — próprio
```

### 23.3. Hierarquia do slide 104

```
                         Forma
                        /     \
         FormaBidimensional   FormaTridimensional
          /     |      \        /      |      \
    Círculo Quadrado Retângulo Esfera Tetraedro Cubo
```

### 23.4. O que a subclasse contém (slide 106)

A subclasse `Quadrado`, que estende `FormaBidimensional`, contém:
- Atributos da FormaBidimensional (herdados)
- Atributos do Quadrado (próprios)
- Métodos do Quadrado (próprios)
- Métodos da FormaBidimensional (herdados)

### 23.5. `super` (slide 109)

Quando uma classe sobrescreve um método da superclasse, o comportamento normal da subclasse é executar **o novo método**. Para executar o método da superclasse, usa-se **`super`**, que é uma referência à superclasse.

```java
public class Animal {
    public void descrever() {
        System.out.println("Sou um animal");
    }
}

public class Cachorro extends Animal {
    public void descrever() {
        super.descrever();                       // executa o da superclasse
        System.out.println("...mais precisamente um cachorro");
    }
}
```
```java
new Cachorro().descrever();
```
Saída:
```
Sou um animal
...mais precisamente um cachorro
```

### 23.6. Herança e construtores (slide 110)

- **Construtores não são herdados** como métodos comuns e **devem ser definidos para cada classe**.
- Se uma classe não tem nenhum construtor definido, o compilador cria automaticamente um **construtor default** que simplesmente **chama o construtor da superclasse**.
- É possível chamar explicitamente o construtor da superclasse através de **`super()`**.
  - Caso `super()` seja chamado, essa chamada deve ser o **primeiro comando** do construtor.

```java
class Pessoa {
    protected String nome;
    public Pessoa(String nome) {
        this.nome = nome;
        System.out.println("Pessoa criada: " + nome);
    }
}

class Funcionario extends Pessoa {
    private double salario;
    public Funcionario(String nome, double salario) {
        super(nome);                      // OBRIGATÓRIO (Pessoa não tem construtor vazio)
        this.salario = salario;
        System.out.println("Funcionario criado com salario " + salario);
    }
}
```
```java
new Funcionario("Ana", 5000);
```
Saída:
```
Pessoa criada: Ana
Funcionario criado com salario 5000.0
```

### 23.7. Resolução de métodos na hierarquia (slide 107)

```java
Wolf w = new Wolf();

w.makeNoise();   // resolvido em Wolf   (sobrescrito)
w.roam();        // resolvido em Canine (sobrescrito)
w.eat();         // resolvido em Wolf   (sobrescrito)
w.sleep();       // resolvido em Animal (herdado sem alteração)
```
Hierarquia: `Animal` (makeNoise, eat, sleep, roam) ← `Canine` (roam) ← `Wolf` (makeNoise, eat).

A JVM procura o método **do tipo mais específico para o mais genérico**, subindo na hierarquia.

> ⚠️ **Pegadinha de prova**
> - **Não existe herança múltipla de classes em Java**, mas uma classe **pode implementar várias interfaces** (herança múltipla de tipo/comportamento).
> - **Construtores não são herdados.**
> - Membros `private` da superclasse **existem** no objeto da subclasse, mas **não são acessíveis** diretamente por ela.
> - Se a superclasse **não tem** construtor sem argumentos e a subclasse **não chama** `super(...)` explicitamente → **erro de compilação**.
> - Uma classe `final` **não pode ser estendida**.
> - `super` **não pode** ser usado em contexto `static`.
> - `super.metodo()` chama **só um nível acima**; não existe `super.super`.

---

## 24. Sobrescrita (override) vs Sobrecarga (overload)

### 24.1. Sobrescrita de métodos (slide 108)

Usada quando é preciso **modificar o comportamento de um método da classe pai**. Para sobrescrever, as condições abaixo **devem** ser satisfeitas:

1. O **nome**, assim como o **tipo e a ordem dos parâmetros**, devem ser **idênticos** aos do método da classe pai.
2. O **tipo de retorno** também deve ser **idêntico**.
3. A **visibilidade não deve ser mais restritiva** que a do método original.
4. O método **não deverá lançar "checked exceptions"** que não são lançadas pelo método original.

```java
class Base {
    protected Number calcular() throws java.io.IOException { return null; }
}

class Ok extends Base {
    public Number calcular() { return new Integer(1); }
    // visibilidade MAIS ampla (protected -> public): OK
    // lança MENOS exceções: OK
}

class Erro1 extends Base {
    private Number calcular() { return null; }   // ERRO: mais restritivo
}

class Erro2 extends Base {
    public Number calcular() throws Exception { return null; }  // ERRO: exceção mais ampla
}
```

### 24.2. Sobrecarga de métodos (slides 111 e 112)

Usada quando é preciso **vários métodos que desempenham papéis semelhantes em diferentes condições**. Condições:

- A **identidade de um método** é determinada pelo **nome completo da classe** a que pertence, pelo seu **nome**, e pelo **tipo, ordem e quantidade dos parâmetros**.
- Dois ou mais métodos na mesma classe (incluindo métodos da superclasse) com o **mesmo nome** mas **lista de parâmetros diferente** são métodos sobrecarregados.
- O **tipo de retorno**, a **visibilidade** e a **lista de exceções** podem variar **livremente**.
- Métodos sobrecarregados **podem chamar uns aos outros**.

```java
public class ExemploSobrecarga {
    public void metodoSobrecarregado(int param1) { }
    public void metodoSobrecarregado(String param1) { }
    public void metodoSobrecarregado(int param1, String param2) { }
    public void metodoSobrecarregado(String param1, int param2) { }  // ORDEM diferente!
    public void metodoSobrecarregado(double param1, String param2, int param3) { }
}
```

### 24.3. Sobrecarga de construtores (slide 113)

```java
class Base {
    public Base(String s) {
        // inicia o objeto usando s
    }
    public Base(int i) {
        // inicia o objeto usando i
    }
}

class Derived extends Base {
    public Derived(String s) {
        super(s);          // passa o controle para Base(String)
    }
    public Derived(int i) {
        super(i);          // passa o controle para Base(int)
    }
}
```

### 24.4. Tabela comparativa (decore!)

| Aspecto | **Sobrescrita** (*override*) | **Sobrecarga** (*overload*) |
|---|---|---|
| Onde ocorre | Entre **superclasse e subclasse** | Na **mesma classe** (ou herdada) |
| Nome do método | Idêntico | Idêntico |
| Lista de parâmetros | **Deve ser idêntica** | **Deve ser diferente** (tipo, ordem ou quantidade) |
| Tipo de retorno | **Deve ser idêntico** | Pode variar livremente |
| Visibilidade | **Não pode ser mais restritiva** | Pode variar livremente |
| Checked exceptions | Não pode lançar novas ou mais amplas | Pode variar livremente |
| Resolução | **Tempo de execução** (ligação dinâmica) | **Tempo de compilação** (ligação estática) |
| Relação com polimorfismo | **É a base do polimorfismo** | Não é polimorfismo (é "açúcar sintático") |

> ⚠️ **Pegadinha de prova**
> - **O tipo de retorno NÃO diferencia métodos sobrecarregados.** Dois métodos com mesmo nome e mesmos parâmetros mas retornos diferentes são **erro de compilação**.
> - Sobrescrita é resolvida em **tempo de execução**; sobrecarga em **tempo de compilação**.
> - Métodos `private`, `static` e `final` **não podem ser sobrescritos**. (Um método `private` "redefinido" na subclasse é simplesmente um método novo.)
> - Um método `static` "sobrescrito" na verdade é **ocultado** (*hiding*) e obedece ao tipo da **referência**, não do objeto.
> - **Atributos não são polimórficos**: `A ref = new B(); ref.x` usa o `x` **de A**, não de B.
> - Na sobrescrita, aumentar a visibilidade é permitido; diminuir **não**.

---

## 25. Abstração: classes abstratas, métodos abstratos e interfaces

### 25.1. O que é abstração (slides 114 a 117)

- Um dos maiores benefícios do paradigma OO é a noção de um **tipo de dado abstrato**.
  - Para usar `java.lang.String`, é importante saber **como** os métodos foram implementados? Se usa array ou lista ligada? **Não.** Para o programador, o importante é **saber que os métodos existem**.
- O primeiro objetivo ao definir uma boa classe **não é pensar na implementação**, mas nas suas **responsabilidades e comportamento**, ou seja, nos seus **métodos públicos**.
- **Todo o comportamento da classe deve ser acessado através de métodos.**
- Só depois de definidas as responsabilidades é que a implementação deve ser levantada.
- A implementação deve estar **bem encapsulada**: atributos e variáveis internas **todos privados**.
- *"Num bom uso da abstração, a implementação de uma classe poderia ser escolhida na hora de execução."*

Em Java, o conceito de abstração é implementado com:
- **Interfaces**
- **Classes abstratas**
- **Métodos abstratos**

### 25.2. Método abstrato

> **Definição do slide 25:** *"Método abstrato é um método que tem a **assinatura declarada mas não tem implementação**."*

```java
public abstract void andar();     // ponto-e-vírgula no lugar do corpo { }
```

### 25.3. Classes abstratas (slides 25 e 121)

- Uma classe **deve** ser declarada abstrata se ela **não está completamente implementada**, isto é, se ela **contém métodos abstratos**.
- Classes abstratas são classes que **podem possuir métodos implementados**, mas que possuem ao menos um método abstrato (segundo o slide 121).
- Uma classe abstrata **não pode ser instanciada**.
- Pode ser **estendida** por uma subclasse que **deve implementar todos os seus métodos abstratos** (ou se tornar abstrata também).
- São úteis quando definem a implementação de **métodos comuns** a todas as classes que as estendem, **obrigando** que cada uma defina a implementação dos métodos abstratos.
- Classes abstratas são utilizadas para **reunir classes em torno de métodos comuns** (p. ex., métodos matemáticos).

### 25.4. Exemplo (slide 122)

```java
public abstract class Animal {
    public void comer() {            // método CONCRETO (implementado)
        System.out.println("Comendo...");
    }
    public abstract void andar();    // método ABSTRATO — obriga as filhas
}

public class Cachorro extends Animal {
    public void andar() {
        System.out.println("anda com quatro patas");
    }
}

public class Canguru extends Animal {
    public void andar() {
        System.out.println("anda com duas patas - pulando");
    }
}
```

```java
// Animal a = new Animal();     // ERRO! classe abstrata não pode ser instanciada

Animal a1 = new Cachorro();     // OK — polimorfismo
Animal a2 = new Canguru();
a1.comer();  a1.andar();
a2.comer();  a2.andar();
```
Saída:
```
Comendo...
anda com quatro patas
Comendo...
anda com duas patas - pulando
```

Se uma subclasse **não** implementar todos os abstratos, ela **também** deve ser abstrata:
```java
public abstract class Ave extends Animal {
    // não implementa andar() -> precisa ser abstract também
    public abstract void voar();
}
```

### 25.5. Interfaces (slides 26, 118 e 119)

Características:
- **Não são classes** ("a interface representa uma ideia; não é considerada uma classe").
- **Não possuem métodos implementados** (só métodos abstratos).
- **Só podem ter atributos constantes**.
- Possuem apenas **definição de comportamento**: métodos abstratos + constantes.
- **Não podem ser instanciadas.**
- Podem ser usadas para **simular herança múltipla**.
- As classes que implementam uma interface **dão suporte àquela ideia**.

```java
// Definição da interface Pet — definição de um COMPORTAMENTO
public interface Pet {
    public abstract void beFriendly();
    public abstract void play();
}

// Implementação da interface Pet
public class Dog implements Pet {
    public void beFriendly() { System.out.println("Abana o rabo"); }
    public void play()       { System.out.println("Busca a bolinha"); }
}
```

### 25.6. Interfaces e abstração (slide 120)

```java
Dog pet = new Dog();
// Não gera erro, porém NÃO usa o conceito de abstração — força a utilização de Dog

Pet pet = new Dog();
// USA o conceito de abstração: o código não depende da implementação do Pet
```

Isso permite trocar a implementação sem alterar o código cliente:
```java
Pet p = new Dog();     // amanhã pode virar new Cat(), new Parrot()...
p.play();
```

### 25.7. Herança múltipla via interfaces

```java
public interface Mercadoria {
    double getPreco();
}

public interface Pet {
    void play();
}

// Uma classe pode implementar VÁRIAS interfaces
public class Papagaio extends AnimalDomestico implements Pet, Mercadoria {
    public void play() { System.out.println("Fala 'Lourooo'"); }
    public double getPreco() { return 250.0; }
}
```

### 25.8. Classes Abstratas × Interfaces (slide 123)

| | **Interface** | **Classe Abstrata** |
|---|---|---|
| Métodos | Somente **métodos abstratos** | Métodos abstratos **e** métodos implementados (quantos forem necessários) |
| Atributos | Somente **constantes** (implicitamente `public static final`) | Qualquer atributo (de instância, estático, com qualquer visibilidade) |
| Construtor | **Não tem** | **Tem** (chamado via `super()` pelas subclasses) |
| Instanciação | **Não pode** | **Não pode** |
| Palavra-chave de uso | `implements` | `extends` |
| Quantidade | Uma classe pode implementar **várias** | Uma classe estende **apenas uma** |
| Modificadores dos métodos | Implicitamente `public abstract` | Qualquer |
| Uso típico | Definir um **contrato / ideia** | Reunir **código comum** em uma família de classes |

> ⚠️ **Pegadinha de prova (bloco denso — leia com atenção)**
> - **"Toda classe abstrata tem pelo menos um método abstrato"** → **FALSO**. Você pode declarar `abstract class X { }` sem nenhum método abstrato, só para impedir instanciação. *(Cuidado: o slide 121 sugere o contrário; a regra real da linguagem é que um método abstrato **obriga** a classe a ser abstrata, mas não o inverso.)*
> - **"Toda classe que tem um método abstrato deve ser abstrata"** → **VERDADEIRO**.
> - **Classe abstrata TEM construtor** (é executado via `super()` quando a subclasse é instanciada), mesmo não podendo ser instanciada diretamente.
> - **Interfaces NÃO têm atributos de instância** — só constantes `public static final` (os modificadores são implícitos, você pode omiti-los).
> - **Interfaces não têm construtor** nem blocos de inicialização.
> - Em interfaces, `public` e `abstract` nos métodos são **implícitos** e redundantes (o PDF os escreve explicitamente, o que é legal mas desnecessário).
> - Um método de interface **não pode** ser `private`, `protected`, `static`, `final` nem `synchronized` (na versão do PDF, Java 1.4).
> - Uma **interface pode estender outra(s) interface(s)** com `extends` (e pode estender **várias**!), mas **nunca** usa `implements`.
> - Uma **classe abstrata pode implementar uma interface sem implementar seus métodos** — eles continuam abstratos.
> - Uma classe **não pode** ser `abstract` e `final` ao mesmo tempo.
> - **Você pode declarar uma variável do tipo da interface/classe abstrata** (`Pet p = ...`), só não pode fazer `new Pet()`.

---

> 🟦 **Divergência Java 8 — a tabela "Interface × Classe Abstrata" acima**
>
> Três linhas mudaram no Java 8:
>
> | Linha da tabela | Java 1.4 (o slide) | **Java 8** |
> |---|---|---|
> | Métodos | Somente abstratos | Abstratos + **`default`** (com corpo) + **`static`** (com corpo) |
> | Modificadores dos métodos | Sempre `public abstract` | `public abstract`, `public default` ou `public static` |
> | "Não pode ser `static`" | Correto | **Incorreto** — `static` passou a ser permitido |
>
> ```java
> interface Pet {
>     int PATAS = 4;                                     // public static final (não mudou)
>     void nome();                                       // public abstract (implícito)
>     default void dormir() { System.out.println("zzz"); }   // Java 8
>     static Pet nenhum() { return null; }                   // Java 8
> }
> ```
>
> **Continua igual em qualquer versão** (e é isto que a prova cobra na Q17): interface **não tem
> atributos de instância**, **não tem construtor** e **não tem blocos de inicialização**. Logo,
> "herdar métodos **e atributos de instância** de várias interfaces" é **FALSO** também no Java 8 —
> herança múltipla de **tipo** e, desde o 8, de **comportamento**, mas **nunca de estado**.
>
> Métodos **`private`** em interface só vieram no **Java 9** — 🟪 não cai nesta prova.
>
> **Reflexo na JVM (JVMS 8):** `ACC_STATIC` em método de interface exige `major_version ≥ 52`;
> `invokespecial` passou a servir para `Interface.super.metodo()`; e, pela **§5.5**, iniciar uma
> classe agora também inicia as **superinterfaces que declaram métodos `default`**.

## 26. Polimorfismo

Embora o PDF não dedique um slide com esse título, o conceito aparece em vários lugares (slides 13, 107, 120, 122). Polimorfismo é a capacidade de uma **mesma referência** assumir **comportamentos diferentes** conforme o objeto real apontado.

### 26.1. Exemplo integrado

```java
abstract class Forma {
    abstract double area();
    public void mostrar() {
        System.out.println(getClass().getName() + " tem area " + area());
    }
}

class Circulo extends Forma {
    private double r;
    Circulo(double r) { this.r = r; }
    double area() { return Math.PI * r * r; }
}

class Quadrado extends Forma {
    private double l;
    Quadrado(double l) { this.l = l; }
    double area() { return l * l; }
}

public class TestePolimorfismo {
    public static void main(String[] args) {
        Forma[] formas = { new Circulo(1), new Quadrado(2) };
        for (int i = 0; i < formas.length; i++) {
            formas[i].mostrar();     // LIGAÇÃO DINÂMICA: decide em tempo de execução
        }
    }
}
```
Saída:
```
Circulo tem area 3.141592653589793
Quadrado tem area 4.0
```

### 26.2. Os três requisitos do polimorfismo em Java

1. **Herança** (ou implementação de interface)
2. **Sobrescrita** de método
3. Uso de uma **referência do supertipo** apontando para um objeto do subtipo

> ⚠️ **Pegadinha de prova**
> - O **compilador** olha o **tipo da referência** (para saber se o método existe); a **JVM** olha o **tipo do objeto** (para saber qual implementação chamar).
>   ```java
>   Forma f = new Circulo(1);
>   f.area();       // OK — area() existe em Forma
>   // f.getRaio(); // ERRO DE COMPILAÇÃO — não existe em Forma, mesmo o objeto sendo Circulo
>   ```
> - **Sobrecarga NÃO é polimorfismo** de tempo de execução.
> - **Atributos não são polimórficos** (resolução estática pelo tipo da referência).
> - **Métodos `static` não são polimórficos**.

---

## 27. API Collection

### 27.1. Visão geral (slide 124)

Um bom exemplo de interfaces muito usadas é a **API Collection**, um conjunto de classes do pacote **`java.util`**. Possui basicamente **4 tipos de interfaces**:

| Interface | Descrição |
|---|---|
| **`Collection`** | Coleção genérica de objetos |
| **`List`** | **Lista** de objetos (ordenada, aceita repetição) |
| **`Set`** | **Conjunto** de objetos (**sem repetição**) |
| **`Map`** | Mapeia **chaves para valores** (objetos) |

### 27.2. Hierarquia Collection (slide 125)

```
Collection (interface)
 ├── List (interface)
 │    ├── AbstractList (classe)
 │    ├── LinkedList   (classe)
 │    ├── Vector       (classe)
 │    └── ArrayList    (classe)
 └── Set (interface)
      ├── AbstractSet (classe)
      ├── HashSet     (classe)
      └── SortedSet (interface)
           └── TreeSet (classe)
```

### 27.3. Hierarquia Map (slide 126)

```
Map (interface)
 ├── SortedMap (interface)
 │    └── TreeMap (classe)
 └── AbstractMap (classe)
      ├── HashMap      (classe)
      ├── TreeMap      (classe)
      └── WeakHashMap  (classe)
```

> **Nota importante:** `Map` **NÃO** estende `Collection`. São hierarquias separadas.

### 27.4. Principais métodos (slide 127)

| Interface | Métodos |
|---|---|
| **`List`** | `add(int index, Object element)`, `add(Object o)`, `get(int index)`, `remove(int index)` |
| **`Map`** | `put(Object key, Object value)`, `get(Object key)` |

### 27.5. Percorrendo uma Collection com Iterator (slide 128)

```java
public void percorre() {
    Collection c = new ArrayList();
    Iterator it = c.iterator();
    while (it.hasNext()) {
        Object ob = it.next();
        System.out.println(ob.toString());
    }
}
```

### 27.6. Percorrendo uma List por índice (slide 129)

```java
public void percorre() {
    List l = new ArrayList();
    for (int i = 0; i < l.size(); i++) {
        Object ob = l.get(i);
        System.out.println(ob.toString());
    }
}
```

### 27.7. Exemplo funcional completo

```java
import java.util.*;

public class ExemploCollection {
    public static void main(String[] args) {
        // LIST — aceita duplicatas, mantém ordem de inserção
        List lista = new ArrayList();
        lista.add("Java");
        lista.add("C");
        lista.add("Java");              // duplicata permitida
        System.out.println(lista);      // [Java, C, Java]
        System.out.println(lista.size());  // 3
        System.out.println(lista.get(1));  // C

        // SET — NÃO aceita duplicatas
        Set conjunto = new HashSet();
        conjunto.add("Java");
        conjunto.add("C");
        conjunto.add("Java");           // IGNORADA
        System.out.println(conjunto.size());   // 2

        // MAP — chave -> valor
        Map mapa = new HashMap();
        mapa.put("SB", "Software Basico");
        mapa.put("APC", "Algoritmos");
        System.out.println(mapa.get("SB"));    // Software Basico

        // Iterator sobre a lista
        Iterator it = lista.iterator();
        while (it.hasNext()) {
            System.out.print(it.next() + " ");
        }
        System.out.println();           // Java C Java
    }
}
```

### 27.8. Comparação rápida das implementações

| Classe | Estrutura | Ordenada? | Duplicatas? | Sincronizada? |
|---|---|---|---|---|
| `ArrayList` | Array dinâmico | Ordem de inserção | Sim | **Não** |
| `Vector` | Array dinâmico | Ordem de inserção | Sim | **Sim** (thread-safe, mais lento) |
| `LinkedList` | Lista duplamente ligada | Ordem de inserção | Sim | Não |
| `HashSet` | Tabela hash | **Não** garante ordem | **Não** | Não |
| `TreeSet` | Árvore | **Ordem natural** (crescente) | Não | Não |
| `HashMap` | Tabela hash | Não garante ordem | Chaves únicas | Não |
| `TreeMap` | Árvore | Ordem das chaves | Chaves únicas | Não |
| `Hashtable` | Tabela hash | Não | Chaves únicas | **Sim** |

> ⚠️ **Pegadinha de prova**
> - **`Map` NÃO é uma `Collection`** — não estende a interface `Collection`.
> - `Collection` é **interface**; `Collections` (com "s") é uma **classe utilitária** com métodos estáticos (`sort`, `reverse`, `max`).
> - **Coleções armazenam apenas objetos**, nunca primitivos — por isso as **classes wrappers** existem (slide 53).
> - `Vector` e `Hashtable` são as versões **legadas e sincronizadas**; `ArrayList` e `HashMap` são as modernas e não sincronizadas.
> - `Set` não aceita duplicatas — e a "duplicata" é determinada por **`equals()`/`hashCode()`**, por isso é essencial sobrescrevê-los.
> - 🟦 `it.next()` retorna `Object` (no Java 1.4, sem generics) — precisa de **casting**. **No Java 8**, com generics, `Iterator<String> it` já devolve `String` direto, e o percurso normal é o **`for` estendido** (`for (String s : lista)`, Java 5) ou `lista.forEach(...)` / `lista.stream()` (Java 8). A interface `Iterator` em si não mudou de semântica: `hasNext()` / `next()` / `remove()`.
> - Chamar `it.next()` sem `it.hasNext()` lança `NoSuchElementException`.

---

## 28. Conversão e casting de referências a objetos + `instanceof`

### 28.1. Definições (slide 130)

- **Conversão**: modificação do tipo de uma variável de forma **implícita** (subir na hierarquia — *upcasting*).
- **Casting**: modificação do tipo de uma variável de forma **explícita** (descer na hierarquia — *downcasting*).

### 28.2. A hierarquia usada nos exemplos (figura do slide 130)

```
              Object
                 │
              Animal
                 │
         AnimalDomestico ──── implements ────  Mercadoria «interface»
            /      |      \
     Cachorro    Gato    Papagaio
```

### 28.3. Conversões VÁLIDAS (slide 131) — implícitas, sempre subindo

```java
Gato g = new Gato();
AnimalDomestico ad = g;       // Gato É-UM AnimalDomestico -> OK
Object o = g;                 // tudo É-UM Object -> OK

Papagaio p = new Papagaio();
Mercadoria m = p;             // Papagaio implementa (via AnimalDomestico) Mercadoria -> OK
Object o2 = m;                // OK
```

### 28.4. Conversões INVÁLIDAS (slide 132)

```java
Gato g = new Gato();
Cachorro c = g;               // ERRO! Gato NÃO é Cachorro (são "irmãos")

Object o = new Object();
Animal a = new Animal();
Papagaio p = a;               // ERRO! Animal não é necessariamente um Papagaio
                              // (descer na hierarquia exige CASTING explícito)
```

### 28.5. Casting de referências (slide 133)

```java
Animal a1 = new Animal();
Papagaio p1 = new Papagaio();
Papagaio p2 = new Papagaio();

AnimalDomestico ad = new AnimalDomestico();
Gato g1 = new Gato();
Gato g2 = new Gato();

a1 = p2;                   // Conversão implícita (upcast) — OK
p1 = (Papagaio) a1;        // Casting válido — a1 REALMENTE aponta para um Papagaio
ad = g1;                   // Conversão válida — OK
g2 = (Gato) a1;            // Casting LEGAL em compilação...
                           // ...mas ERRO EM EXECUÇÃO: ClassCastException!
```

> A última linha resume a regra de ouro: **o compilador só verifica se o casting é *plausível* na hierarquia; a JVM verifica se ele é *real*.**

### 28.6. Tabela de conversões válidas (slide 134)

| **Tipo Novo ↓ / Tipo Original →** | Classe | Interface | Array |
|---|---|---|---|
| **Classe** | ClasseTipoOriginal deve ser **subclasse** de ClasseNovoTipo | Deve ser `Object` | Deve ser `Object` |
| **Interface** | ClasseTipoOriginal deve **implementar** ClasseNovoTipo | Deve ser uma **subinterface** de ClasseNovoTipo | Deve ser `Cloneable` ou `Serializable` |
| **Array** | **Erro** | **Erro** | (compatível se os elementos forem compatíveis) |

### 28.7. Tabela de castings válidos (slide 135)

| **Novo Tipo ↓ / Tipo Original →** | Classe "não-final" | Interface | Array |
|---|---|---|---|
| **Classe "não-final"** | TipoOriginal deve **herdar de** NovoTipo **ou vice-versa** | Sempre OK | TipoOriginal deve ser `Object` |
| **Classe "final"** | NovoTipo deve **herdar de** TipoOriginal | NovoTipo deve implementar uma interface ou `Serializable` | **Erro de compilação** |
| **Interface** | Sempre OK | Sempre OK | **Erro de compilação** |
| **Array** | NovoTipo deve ser `Object` | **Erro de compilação** | TipoOriginal contém objetos que possam sofrer casting para os objetos de NovoTipo |

### 28.8. Operador `instanceof` (slide 136)

Para auxiliar a operação de casting, existe uma maneira de saber **qual a real instância de uma referência** e testar se vai ocorrer erro numa suposta conversão explícita:

```java
Object s1 = new String("objeto do tipo String");
if (s1 instanceof String) {
    String s = (String) s1;      // casting SEGURO
    // s.doSomething();
}
```

Exemplo prático:
```java
public class TesteInstanceof {
    public static void descrever(Object o) {
        if (o instanceof String) {
            System.out.println("String de " + ((String) o).length() + " chars");
        } else if (o instanceof Integer) {
            System.out.println("Inteiro: " + o);
        } else if (o instanceof int[]) {
            System.out.println("Array de " + ((int[]) o).length + " ints");
        } else {
            System.out.println("Outro tipo: " + o.getClass().getName());
        }
    }

    public static void main(String[] args) {
        descrever("Java");
        descrever(new Integer(7));
        descrever(new int[5]);
        descrever(new Object());
    }
}
```
Saída:
```
String de 4 chars
Inteiro: 7
Array de 5 ints
Outro tipo: java.lang.Object
```

> ⚠️ **Pegadinha de prova**
> - **Upcasting** (subir) é **implícito e sempre seguro**; **downcasting** (descer) exige **casting explícito** e pode lançar **`ClassCastException`** em tempo de execução.
> - Um casting sintaticamente legal pode falhar em execução — o exemplo `g2 = (Gato) a1;` do slide 133 é exatamente isso.
> - `null instanceof QualquerCoisa` retorna **`false`** (nunca lança exceção).
> - `instanceof` com tipos **sem relação nenhuma** na hierarquia é **erro de compilação**:
>   ```java
>   String s = "x";
>   // if (s instanceof Integer) { }   // ERRO DE COMPILAÇÃO
>   ```
> - Fazer casting **não muda o objeto**, apenas muda o **tipo da referência** através da qual você o enxerga.
> - Casting entre "irmãos" na hierarquia (`Gato` ↔ `Cachorro`) é **erro de compilação**.

---

## 29. Exceções

### 29.1. Para que servem (slides 138 e 139)

Exceções são usadas para **controle, durante a execução de um programa, de alguma coisa que não é normal** — do ponto de vista do objetivo a ser alcançado — **mas que pode acontecer**.

Tipos de erro:

| Tipo | Exemplos |
|---|---|
| **Previsíveis** | Usuário entra com nome de arquivo inválido, falha num componente de rede, arquivo corrompido |
| **Não previsíveis** | Bugs no programa, acesso a posições inexistentes num array, falta de memória do sistema |

Nas linguagens tradicionais, o tratamento é feito com **`if`s** (ex.: testar se o arquivo existe antes de usá-lo), o que **deixa o código extenso e complexo**. O ideal é **fazer o tratamento somente se o problema ocorrer**.

Em Java, exceções são **classes específicas para cada tipo de erro**, que contêm informações de **quando** e **qual** erro ocorreu.

### 29.2. Sintaxe try/catch (slides 140 e 141)

O trecho de código em que uma exceção é esperada deve ser colocado dentro de um **`try{}`**. Caso a exceção venha a ocorrer, seu tratamento é feito dentro do **`catch{}`** logo em seguida.

```java
int x = (int) (Math.random() * 5);
int y = (int) (Math.random() * 10);
int[] z = new int[5];

try {
    System.out.println("y/x e " + (y / x));                    // pode dar divisão por zero
    System.out.println("y e " + y + " z[y] e " + z[y]);        // pode estourar o índice
} catch (ArithmeticException e) {
    System.out.println("Problema aritmetico " + e);
} catch (ArrayIndexOutOfBoundsException e) {
    System.out.println("Erro no indice " + e);
}
```

Saída possível (quando `x == 0`):
```
Problema aritmetico java.lang.ArithmeticException: / by zero
```

### 29.3. Propagação na pilha (slide 142)

```
main()
  └── calculaMedia()
        └── calculaSoma()   <- exceção lançada aqui
```

> **Se uma exceção ocorrer e não for tratada em um determinado método, ela é passada ao método imediatamente anterior na pilha de execução, e assim por diante.**

Se ninguém tratar, a JVM encerra a thread e imprime o *stack trace*.

### 29.4. Múltiplos catch e `finally` (slide 143)

```java
try {
    // faz alguma coisa
} catch (FileNotFoundException e) {
    // trata o erro
} catch (SQLException e) {
    // trata o erro
} catch (Exception e) {
    // trata o erro genérico
} finally {
    /* finaliza o uso dos recursos (arquivos, transações, etc) */
}
```

O bloco **`finally`** é **executado sempre**, mesmo que uma exceção seja levantada, e mesmo com `return` dentro do `try` (slide 67):

```java
try {     //... código normal
    return;
} catch (Exception e) {
    //... código que trata o erro
} finally {
    // código executado, MESMO levantando exceção
}
```

Demonstração:
```java
public class TesteFinally {
    static int teste() {
        try {
            System.out.println("no try");
            return 1;
        } finally {
            System.out.println("no finally");   // executa ANTES do return efetivar
        }
    }
    public static void main(String[] args) {
        System.out.println("retornou " + teste());
    }
}
```
Saída:
```
no try
no finally
retornou 1
```

### 29.5. Hierarquia de exceções (slide 144)

**Todos os tipos de exceções e erros são filhos da classe `Throwable`.**

```
                        Throwable
                       /         \
                Exception          Error
                /       \             \
       SQLException   RuntimeException  OutOfMemoryError
                          \
                     NullPointerException
```

| Classe | Natureza | Checked? |
|---|---|---|
| `Throwable` | Raiz de tudo | — |
| `Error` | Problemas graves da JVM (`OutOfMemoryError`, `StackOverflowError`) — **não devem ser tratados** | **Não** |
| `Exception` | Condições anormais recuperáveis | **Sim** (exceto `RuntimeException`) |
| `RuntimeException` | Erros de programação (`NullPointerException`, `ArrayIndexOutOfBoundsException`, `ArithmeticException`, `ClassCastException`, `NumberFormatException`) | **Não** |

### 29.6. Lançando exceções — `throw` (slide 145)

```java
throw new IOException("Arquivo nao encontrado");
```

> Após a execução desta linha, o **fluxo normal é interrompido** e resumido somente no **`catch` correspondente**. Se não houver um `catch` explícito, quem trata o problema é o sistema operacional (na prática: a JVM termina e imprime o stack trace).

### 29.7. `throws` vs `throw` vs `finally` (slide 67)

```java
public void setIdade(int idade) throws IdadeException {   // throws: DECLARA que pode lançar
    if (idade < 0) {
        throw new IdadeException("Idade fora da faixa");  // throw: LANÇA de fato
    }
    // ...
}
```

| Palavra | Onde aparece | Função |
|---|---|---|
| **`throw`** | Dentro do corpo do método | **Lança** uma exceção (um objeto) **agora** |
| **`throws`** | Na **assinatura** do método | **Declara** que o método **pode** lançar aquela(s) exceção(ões) |
| **`finally`** | Depois de `try`/`catch` | Bloco **sempre executado** |

### 29.8. Checked Exceptions (slide 146)

> **Em Java, qualquer método que pode lançar uma exceção deve declarar isto.**

```java
public void method1() throws SQLException {
    // este método pode jogar uma SQLException
}
```

> **As exceções checadas são somente as subclasses de `Exception`, EXCETO `RuntimeException` e suas filhas. `Error`s também NÃO são checadas.**

Quem chama um método que lança checked exception deve **tratar** (`try/catch`) **ou propagar** (`throws`):

```java
// Opção 1: tratar
public void usa1() {
    try {
        method1();
    } catch (SQLException e) {
        System.out.println("Erro de SQL: " + e.getMessage());
    }
}

// Opção 2: propagar
public void usa2() throws SQLException {
    method1();
}
```

### 29.9. Criando exceções próprias

```java
public class IdadeException extends Exception {    // checked
    public IdadeException(String msg) {
        super(msg);
    }
}

public class SaldoInsuficienteException extends RuntimeException {  // unchecked
    public SaldoInsuficienteException(String msg) {
        super(msg);
    }
}
```

### 29.10. Vantagens das exceções (slide 147)

- Mantém **separados** os trechos de código que tratam condições anormais/de erro do código normal
- **Propagação** das exceções pela pilha de execução até que seja encontrado um tratador adequado
- **Tratamento genérico** para tipos de exceção (via hierarquia)

### 29.11. Boas práticas (slide 148)

- **Não tratar todas as exceções genericamente.** Faça um tratamento adequado para cada tipo.
- **Não lançar exceções genéricas.** Crie novos tipos de exceções.
- Utilizar um mecanismo de **logging** para registrar a ocorrência da exceção.
- Utilize o bloco **`finally`** para finalizar o uso dos recursos.

### 29.12. Exceções e sobrescrita de métodos (slide 149) — **CAI MUITO**

```java
public class BaseClass {
    public void method() throws IOException { }
}

// LEGAL: mesma exceção
public class LegalOne extends BaseClass {
    public void method() throws IOException { }
}

// LEGAL: NENHUMA exceção (menos é sempre permitido)
public class LegalTwo extends BaseClass {
    public void method() { }
}

// LEGAL: SUBCLASSES de IOException (mais específicas)
public class LegalThree extends BaseClass {
    public void method() throws EOFException, MalformedURLException { }
}

// ILEGAL: IllegalAccessException NÃO é subclasse de IOException
public class IlegallOne extends BaseClass {
    public void method() throws IOException, IllegalAccessException { }
}

// ILEGAL: Exception é MAIS AMPLA que IOException
public class IlegallTwo extends BaseClass {
    public void method() throws Exception { }
}
```

**Regra**: o método sobrescrito pode lançar **as mesmas exceções checadas, subclasses delas, ou menos exceções** — **nunca** exceções checadas **novas** ou **mais amplas**.

> ⚠️ **Pegadinha de prova (bloco denso)**
> - **A ordem dos `catch` importa**: do **mais específico para o mais genérico**. `catch (Exception e)` antes de `catch (IOException e)` é **erro de compilação** (*unreachable catch block*).
> - **`finally` sempre executa** — mesmo com `return`, `break` ou `continue` dentro do `try`. A única exceção prática é `System.exit()` ou o desligamento da JVM.
> - Um `try` pode ter **`try/finally` sem `catch`**, mas **não** pode ter `try` sozinho.
> - **`RuntimeException` e `Error` são UNCHECKED**: não precisam ser declaradas nem tratadas.
> - `Error` **não é** subclasse de `Exception`! Ambas descendem de `Throwable`. Logo, `catch (Exception e)` **não pega** `OutOfMemoryError`.
> - `throw` **lança**; `throws` **declara**. Confundir os dois é pegadinha clássica.
> - Um método pode declarar `throws` de exceções que **nunca** lança — é legal (embora feio).
> - **Sobrescrita de método pode lançar QUALQUER exceção unchecked**, mesmo sem declarar na superclasse.
> - Um `catch` pode **relançar** a exceção com `throw e;` ou encapsulá-la em outra.
> - `System.exit(0)` dentro do `try` **impede** o `finally` de rodar.

---

## 30. Threads e concorrência

### 30.1. O que são (slides 28 e 29)

- Threads são **processos leves** implementados com um **contador de programa**, uma **pilha independente** e uma **área de dados privados**.
- Embora só exista uma JVM e, na maioria dos casos, uma única CPU (impossibilitando paralelismo real), o efeito do uso de threads é **simular a existência de várias JVMs**, dando a **ilusão** de executarem ao mesmo tempo.
- Um **processo real** é caracterizado como um **programa em execução**. Esse processo pode lançar várias threads que se responsabilizam por procedimentos específicos.
- Um exemplo de thread da JVM é o **coletor de lixo** (*garbage collector*).
- **Toda thread em Java é uma instância da classe `Thread`.**

### 30.2. Estados de uma thread (slides 29 e 32)

| Estado | Descrição |
|---|---|
| **Executando** | De posse da CPU |
| **Dormindo** | Por um tempo determinado (`sleep()`) |
| **Bloqueado** | Em uma fila, esperando algum recurso (E/S, monitor) |
| **Pronto para executar** | Na fila do escalonador |
| **Suspenso** | Suspensa explicitamente |

Diagrama do slide 32:
```
                      Executando
                     /    |     \
              Suspenso  Dormindo  Bloqueado
                     \    |     /
                        Pronto  ──────> (volta a Executando)
```

### 30.3. Iniciando uma thread (slide 30)

- Para executar uma thread, você deve chamar o método **`start()`**.
- Quando isso acontece, a thread **não começa a executar imediatamente**: ela é **colocada na fila do escalonador de threads**.
- O escalonador utiliza uma política baseada em diversos fatores (prioridade, preempção, *time slice*, etc.) para determinar a qual thread será alocada a CPU.

```java
public class MinhaThread extends Thread {
    private String nome;
    public MinhaThread(String nome) { this.nome = nome; }

    public void run() {                     // o CÓDIGO da thread vai em run()
        for (int i = 0; i < 3; i++) {
            System.out.println(nome + " - passo " + i);
            try {
                Thread.sleep(100);          // dorme 100 ms
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) {
        new MinhaThread("A").start();       // start() -> entra na fila do escalonador
        new MinhaThread("B").start();
    }
}
```
A saída **intercala** A e B de forma **não determinística**.

Alternativa (preferida, pois preserva a herança): implementar `Runnable`.
```java
public class Tarefa implements Runnable {
    public void run() { System.out.println("rodando"); }
    public static void main(String[] args) {
        new Thread(new Tarefa()).start();
    }
}
```

### 30.4. Controlando os estados (slide 31)

| Método | Descrição |
|---|---|
| **`yield()`** | Método **estático** de `java.lang.Thread` que coloca uma thread que esteja executando **de volta ao estado "pronto para execução"** |
| **`sleep()`** | Método **estático** que faz a thread passar uma quantidade de tempo **sem fazer nada e sem consumir recursos da CPU**. Lança **`InterruptedException`**, que **deve ser tratada** |
| **bloqueio** | Quando uma thread deve ficar esperando por um evento de E/S, a JVM **bloqueia o método** para que outras tarefas possam ser realizadas |

### 30.5. Paralelismo e sincronização (slides 33, 34 e 35)

- Se duas threads se comunicam através de **memória comum**, o acesso deve ser controlado para permitir que **uma única thread a acesse de cada vez**.
- Essa área de memória é a **região crítica**.
- Se mais de uma thread tentar acessar a região crítica ao mesmo tempo, o recurso poderá ser alocado a todas elas, **gerando problemas**.
- Para evitar isso, declaramos uma parte do código (tipicamente um método, mas também blocos livres entre `{}`) como **`synchronized`**. A partir de então, **somente uma thread por vez** terá acesso. Essa forma de controle é conhecida por **lock**.

**Monitores:**
- Exclusão mútua pode ser feita com **semáforos, `wait`/`signal`, monitor**, etc.
- **Em Java, toda instância de objeto e toda classe tem um monitor associado.**
  - Se você nunca usar recursos de sincronização, esse monitor nunca será alocado.
- Um monitor é simplesmente um **recurso de lock que serializa o acesso** ao objeto ou à classe.
- Para ganhar acesso, uma thread primeiro precisa **ganhar controle do monitor** — o que acontece toda vez que entramos em um **método sincronizado**.
- Uma thread esperando pela liberação de um monitor fica **bloqueada**.

**`wait()`:**
- Para liberar o acesso à região crítica, uma thread pode chamar **`wait()`**.
- `wait()` **só pode ser chamado se a thread conseguiu o controle do monitor**, isto é, **dentro de um método sincronizado**.
- Isso possibilita a **sincronização de threads paralelas e a troca de informação entre elas**.

Exemplos de aplicações paralelas citados: operações com matrizes, resolução de expressões aritméticas, problema do leitor vs. escritor.

### 30.6. Exemplo de sincronização

```java
public class ContaSincronizada {
    private int saldo = 0;

    public synchronized void depositar(int valor) {   // apenas 1 thread por vez
        int temp = saldo;
        temp = temp + valor;
        saldo = temp;
    }

    public synchronized int getSaldo() { return saldo; }

    public void exemploBloco() {
        synchronized (this) {           // bloco sincronizado
            // região crítica
        }
    }
}
```

Sem o `synchronized`, duas threads poderiam ler o mesmo `saldo` e perder um depósito (*race condition*).

> ⚠️ **Pegadinha de prova**
> - **`start()` ≠ `run()`**: chamar `run()` diretamente executa o código **na thread atual**, sem criar thread nova!
> - `start()` **não** inicia a execução imediatamente — coloca a thread **na fila do escalonador**.
> - `sleep()` e `yield()` são **métodos estáticos** da classe `Thread` e afetam **a thread corrente**.
> - `sleep()` **NÃO libera o monitor** (o lock); `wait()` **libera**.
> - `wait()`, `notify()` e `notifyAll()` pertencem a **`Object`**, não a `Thread`, e só podem ser chamados dentro de bloco/método `synchronized` (senão: `IllegalMonitorStateException`).
> - `sleep()` lança **`InterruptedException`** — que é **checked** e deve ser tratada.
> - `synchronized` **não se aplica a classes, atributos nem construtores** (ver tabela do slide 88).
> - Uma thread só pode ter `start()` chamado **uma vez** — a segunda lança `IllegalThreadStateException`.
> - `Thread` e `Runnable`: use `implements Runnable` quando precisar estender outra classe (Java não tem herança múltipla).

---

## 31. Resumo em 10 pontos

1. **Pipeline de execução.** `.java` → `javac` → **bytecode** `.class` → **JVM** → código de máquina. O **classpath** diz à JVM onde encontrar as classes. É isso que dá independência de plataforma ("write once, run anywhere").

2. **8 tipos primitivos, o resto é objeto.** `boolean`(8), `char`(16), `byte`(8), `short`(16), `int`(32), `long`(64), `float`(32), `double`(64). Literal inteiro é `int`; literal flutuante é `double`. `String` **não** é primitivo — é uma **classe imutável** com pool de literais. Wrappers (`Integer`, `Character`, ...) permitem guardar primitivos em coleções.

3. **Conversão é implícita (sobe na hierarquia/precisão); casting é explícito (desce).** Vale tanto para primitivos (`byte→short→int→long→float→double`, com `char→int`) quanto para referências (upcast automático, downcast com `(Tipo)` e risco de `ClassCastException`). Use **`instanceof`** para testar antes de descer.

4. **Java é sempre passagem por valor.** Para objetos, passa-se uma **cópia da referência**: dentro do método você **pode alterar o objeto**, mas **não consegue trocar a referência** do chamador. Arrays e `StringBuffer` mudam; `int` e `String` não.

5. **Estrutura fixa do arquivo:** `package` → `import`s → classes. **Uma única classe pública por arquivo**, com o **mesmo nome do arquivo**. Pacotes organizam classes e evitam colisão de nomes.

6. **Quatro níveis de acesso**, do mais restrito ao mais amplo: `private` < *default* (pacote) < `protected` (pacote + subclasses) < `public`. Classes de topo só aceitam `public` ou *default*. Estude a tabela do slide 88 — ela é a fonte preferida de questões V/F (`static` não vale para classe de topo, `final`/`abstract`/`static` não valem para construtor, `abstract` não vale para atributo).

7. **Herança simples de classes, múltipla de interfaces.** `extends` (uma só) + `implements` (várias). Toda classe herda de **`Object`**, que **tem construtor** e fornece `equals()`, `toString()`, `hashCode()`, `wait()`/`notify()`, `finalize()`. Construtores **não são herdados**; o construtor default só existe se **nenhum** outro for declarado; `super(...)`/`this(...)` devem ser o **primeiro comando**; a ordem de execução é **static → instância → construtor**, do topo da hierarquia para baixo.

8. **Sobrescrita ≠ sobrecarga.** Sobrescrita: mesma assinatura e retorno, visibilidade não mais restritiva, sem novas checked exceptions, resolvida em **tempo de execução** — é a base do **polimorfismo**. Sobrecarga: mesma classe, **lista de parâmetros diferente**, resolvida em **tempo de compilação**; o tipo de retorno **não** diferencia.

9. **Abstração = interfaces + classes abstratas + encapsulamento.** Classe abstrata: **não pode ser instanciada**, pode ter métodos concretos, tem construtor, e (ao contrário do que muitos acham) **não precisa ter nenhum método abstrato**. Interface: só métodos abstratos e **constantes** (`public static final`), **sem atributos de instância e sem construtor**, permite simular herança múltipla. A API `Collection` (`List`, `Set`, `Map`) é o exemplo canônico — e lembre: **`Map` não é uma `Collection`**.

10. **Exceções separam o código normal do tratamento de erro.** Hierarquia: `Throwable` → `Exception` (checked, exceto `RuntimeException`) e `Error` (unchecked). `throw` **lança**, `throws` **declara**, `finally` **sempre executa**. `catch` vai do **mais específico para o mais genérico**. Um método sobrescrito **nunca** pode lançar checked exceptions novas ou mais amplas. E memória? O **Garbage Collector** cuida disso — mas você **não controla quando** ele roda.

---

## Apêndice — Divergências deste PDF com o Java SE 8

O `IBM-JavaBasico.pdf` foi escrito para **Java 1.4**. A prova cobre **Java SE 8**. Resumo do que
mudou entre uma coisa e outra e que afeta o que está escrito aqui:

| Tema | O slide (Java 1.4) | Java 8 | Desde |
|---|---|---|:---:|
| Interfaces | Só métodos abstratos | Métodos **`default`** e **`static`** com corpo | Java 8 |
| Coleções | Guardam `Object`, exigem *cast* | **Generics**: `List<String>` já vem tipado | Java 5 |
| Wrappers | `add(new Integer(5))` | **Autoboxing**: `add(5)` | Java 5 |
| Percurso | `Iterator` + `while` | **`for` estendido**, `forEach`, `stream()` | 5 / 8 |
| `switch` | `byte`, `short`, `char`, `int` | \+ **`enum`** e **`String`** | 5 / 7 |
| Parâmetros | Assinatura fixa | **varargs** `f(int... x)` | Java 5 |
| Constantes | `static final int` | **`enum`** como tipo próprio | Java 5 |
| Exceções | `try/catch/finally` simples | ***try-with-resources***, ***multi-catch*** | Java 7 |
| Concorrência | `Thread`, `synchronized`, `wait()` | `java.util.concurrent` (`ExecutorService`, `Lock`, `Atomic*`) | Java 5 |
| Funções | Classes anônimas | **Lambdas** e *method references* (compiladas com `invokedynamic`) | Java 8 |

**O que NÃO mudou** (e é o que a prova cobra): o modelo de objetos, herança simples de classes,
`Object` na raiz, a ordem `static` → bloco de instância → construtor, passagem **sempre por valor**,
`==` × `equals()`, imutabilidade de `String`, hierarquia `Throwable`, *checked* × *unchecked*, e a
regra de que interface **não tem estado de instância**.

🟥 **Independente de versão**, estes pontos do PDF estão errados: o slide 121 ("classe abstrata tem
ao menos um método abstrato" — basta o modificador `abstract`), o slide 52 (`short c = (short) b1 + b2;`
não compila; falta o parêntese), o slide 53 (`Char` em vez de `Character`), o slide 97
(`float x1 = 15.5;` sem o sufixo `f`), o slide 98 (`v.inicializa()` para um método chamado `inicia()`)
e o slide 48 (`boolean` com 8 bits — a JVMS não define o tamanho).

Detalhamento completo em [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).

---

*Bons estudos! Se um item deste resumo aparecer numa questão de verdadeiro/falso, provavelmente está num bloco "⚠️ Pegadinha de prova".*
