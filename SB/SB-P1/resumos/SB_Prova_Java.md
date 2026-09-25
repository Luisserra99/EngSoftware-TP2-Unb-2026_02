# Prova-J (CIC0104 Software Básico) — Gabarito comentado

> Prova anterior: **21/2, Turma A**, resolvida pelo aluno Lucas Vinicius Magalhães Pinheiro (17/0061001).
> As respostas manuscritas no PDF são **as do aluno** e várias estão erradas. Este documento traz o
> **gabarito correto**, confrontado com a *Java Virtual Machine Specification, Java SE 8 Edition*
> (JVMS 8) e com a *Java Language Specification* (JLS 8), além dos slides da disciplina.

> 🔎 **Revisão Java 8** — a base deste gabarito já é o **Java SE 8**. As anotações 🟦/🟪/🟥
> acrescentadas marcam as questões em que o **slide da disciplina** e o **Java 8** dão respostas
> diferentes, para você saber o que escrever na justificativa. Apanhado em
> [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).

---

## 1. Formato e regras da prova

| Item | Regra |
|---|---|
| Peso da prova | **1,5** na média da disciplina |
| Tipo | Individual e **sem consulta** (cola ⇒ nota zero para quem colou e para quem deu cola) |
| Respostas objetivas | **V** (verdade), **F** (falso) ou **NS** (não sei) |
| Penalidade | **Duas respostas erradas anulam uma certa** |
| Resposta em branco | Conta como **resposta errada** |
| Justificativa | Obrigatória **para toda questão respondida como F**. Sem justificativa (ou com justificativa errada) a questão não pontua |
| Valor de cada objetiva | **0,4** (22 questões) |
| Valor de cada discursiva | **0,8** (4 questões) |

**Estratégia decorrente das regras:** o "NS" não pontua, mas **também não penaliza** — ele é
preferível a um chute, porque um chute errado custa meia questão certa. Um "F" com justificativa
frágil equivale, na prática, a um erro. Ou seja: só responda F se souber **por que** é falso.

### Como o aluno se saiu (resumo)

- **Acertos:** 1, 3, 4, 5, 6, 7, 11, 13, 16, 18, 19 → 11 questões
- **Erros (resposta divergente do gabarito):** 9, 14, 17, 22 → 4 questões
- **NS (não pontuam):** 2, 8, 10, 12, 15, 20, 21 → 7 questões
- **Acertou a resposta mas com justificativa errada/incompleta** (risco real de perder o ponto):
  **1, 3, 4, 5, 7, 16**

Aplicando a regra "duas erradas anulam uma certa": 11 certas − (4 erradas ÷ 2) = **9 questões
efetivas × 0,4 = 3,6** — e isso *antes* de descontar as justificativas mal feitas. Note que as
questões 7, 5 e 4 têm resposta certa por motivo errado, o que na correção costuma ser anulado.

---

## 2. Tabela-resumo das 22 objetivas

| # | Enunciado resumido | Aluno | **Correta** | Situação |
|:--:|---|:--:|:--:|---|
| 1 | .class = uma única classe **pública** ou interface, big-endian, sem padding | F | **F** | Certo (justificativa fraca) |
| 2 | Se existir, o primeiro código executado é sempre o de `<clinit>` | NS | **V** | Não pontuou |
| 3 | Cada entrada da tabela de métodos contém descrição completa, **incluindo as instruções** | F | **F** | Certo (justificativa incompleta) |
| 4 | O campo `super` **sempre** contém índice válido para a superclasse | F | **F** | Certo (justificativa errada) |
| 5 | Os tipos de dados da JVM são os definidos na linguagem Java | F | **F** | Certo (justificativa imprecisa) |
| 6 | Frame contém pilha de operandos, vetor de locais e pool de constantes | V | **V** | Certo |
| 7 | Vetor de locais tem parâmetros e locais; **o 1º parâmetro está no índice 0** | F | **F** | Certo (justificativa **errada**) |
| 8 | **Todo** bytecode executado usa a pilha de operandos | NS | **F** | Não pontuou |
| 9 | **Não há** instruções JVM específicas para boolean, byte, char e short | V | **F** | **Errado** |
| 10 | Área de métodos armazena pool, **objetos**, atributos de instância, código… | NS | **F** | Não pontuou |
| 11 | `ConstantValue` em campo **estático** deve ser ignorado em silêncio | F | **F** | Certo |
| 12 | Pilha de método nativo tem **a mesma estrutura** da pilha de frames, sem o pool | NS | **F** | Não pontuou |
| 13 | Iniciação da JVM carrega a classe com `main`; `public static void main(String[])` | V | **V** | Certo |
| 14 | Sem manipulador no método corrente, **o programa é encerrado** | V | **F** | **Errado** |
| 15 | Java é adequada a tempo real com resposta **determinística** | NS | **F** | Não pontuou |
| 16 | Classe abstrata é aquela em que **os seus métodos são abstratos** | F | **F** | Certo (justificativa errada) |
| 17 | Interfaces simulam herança múltipla herdando **atributos de instância** | V | **F** | **Errado** |
| 18 | Toda classe tem construtor, **exceto `Object`** | F | **F** | Certo |
| 19 | Métodos chamáveis em `Gato` == métodos chamáveis em `Onça`? | F | **F** | Certo |
| 20 | `public final int tamanhoMaximo = 15;` define **atributo de classe** | NS | **F** | Não pontuou |
| 21 | `static` pode ser aplicado a classe, variável e método | F | **V** | Não pontuou (e a justificativa está errada) |
| 22 | Arrays são alocados em **memória estática** (em compilação) via `new` | V | **F** | **Errado** |

---

## 3. As 22 objetivas, uma a uma

### Questão 1 — V/F: **F**

> *"Um arquivo .class é um arquivo binário contendo a definição de uma única classe pública ou
> interface com campos representados como um stream de bytes com itens multibytes armazenados em
> big-endian order, sempre sem bytes de preenchimento (alinhamento)."*

**Resposta do aluno:** F — *"…podendo ela ser pública, privada ou outra classificação."*

**Justificativa correta.** Tudo no enunciado está certo **menos a palavra "pública"**. JVMS §4.1:
cada arquivo `.class` contém a definição de **uma única classe ou interface**, sem exigência de que
seja pública. Classes com visibilidade de pacote (*package-private*), classes aninhadas, internas,
locais e anônimas geram, cada uma, o seu próprio `.class` (ex.: `Uuupa$1.class`). O que é verdadeiro:

- o arquivo é um **stream de bytes de 8 bits**;
- quantidades **multibyte são big-endian** (byte mais significativo primeiro), montadas como
  `(byte1 << 8) | byte2`;
- os itens são **sucessivos, sem caracteres de preenchimento ou alinhamento**. (O *padding* só
  aparece **dentro do bytecode**, nas instruções `tableswitch` e `lookupswitch`, que usam de 0 a 3
  bytes nulos para alinhar o primeiro operando em fronteira de 4 bytes — mas isso é o formato da
  instrução, não do arquivo.)

**Onde o aluno errou.** A resposta (F) está certa, mas a justificativa está tecnicamente incorreta:
**uma classe de topo (top-level) não pode ser `private`**. Só classes **aninhadas** (membros de
outra classe) aceitam `private`/`protected`. O correto seria: *"a classe definida no `.class` não
precisa ser pública — pode ter acesso de pacote, ou ser uma classe aninhada/interna/anônima."*

---

### Questão 2 — V/F: **V**

> *"Se existir, o primeiro código a ser executado é sempre o do método `<clinit>`."*

**Resposta do aluno:** NS (não pontua).

**Justificativa correta.** JVMS §5.2 e §5.5: a JVM inicia carregando (*load*), ligando (*link*) e
**inicializando** (*initialize*) a classe inicial; só **depois** invoca `main`. Inicializar uma
classe significa executar o seu método de inicialização de classe `<clinit>`, que o compilador
sintetiza a partir dos **blocos `static { }`** e das **atribuições a variáveis estáticas**. Além
disso, antes do `<clinit>` de uma classe C, a JVM executa o `<clinit>` de **todas as superclasses**
de C (§5.5, passo 7). Logo, se `<clinit>` existir, ele roda antes de qualquer outro código daquela
classe — como a própria questão discursiva 3 demonstra (imprime 5 e 1 antes do 4 do `main`).

Observação fina: `<clinit>` é invocado **implicitamente pela JVM**, nunca por uma instrução
`invoke*`; e a classe só tem `<clinit>` se houver bloco estático ou inicialização estática não
constante.

---

### Questão 3 — V/F: **F**

> *"Cada entrada na tabela de métodos de um arquivo .class contém uma descrição completa de um
> método nessa classe ou em uma interface, incluindo as instruções da JVM que o implementam."*

**Resposta do aluno:** F — *"O único caso em que as instruções são fornecidas na tabela é quando o
método não é nativo."*

**Justificativa correta.** JVMS §4.6 diz exatamente: *"Each method_info structure gives a complete
description of a method… **including the Java Virtual Machine instructions that implement the
method, unless the method is either `native` or `abstract`**."* O enunciado suprimiu a exceção, e é
justamente ela que o torna falso: métodos **`native`** (implementados em outra linguagem) e métodos
**`abstract`** (inclusive os métodos de interface sem `default`) **não possuem o atributo `Code`** e,
portanto, não trazem instruções. O inverso também é regra do formato: se o método é `native` ou
`abstract`, ter `Code` é erro de formato.

**Onde o aluno errou.** A resposta está certa, mas a justificativa **esqueceu os métodos
abstratos**, que são o caso mais comum. Justificativa completa: *"métodos `native` e `abstract` não
têm atributo `Code`, logo sua entrada na tabela de métodos não contém instruções da JVM."*

---

### Questão 4 — V/F: **F**

> *"O campo `super` de um arquivo .class sempre contém um índice válido para uma entrada no pool de
> constante que representa a superclasse da classe descrita neste arquivo."*

**Resposta do aluno:** F — *"Quase, o campo que indica a superclasse é na verdade chamado de
super_class."*

**Justificativa correta.** O erro está no **"sempre"**. JVMS §4.1: o item `super_class` ou é um
índice válido para uma entrada `CONSTANT_Class_info` do pool de constantes, **ou vale 0**. O valor
**0** ocorre exatamente para a classe **`java.lang.Object`**, a única classe sem superclasse. Para
todas as demais classes e para **todas as interfaces** (cuja superclasse é obrigatoriamente
`Object`), o índice é válido. Como existe o caso `super_class == 0`, a afirmação com "sempre" é
**falsa**.

**Onde o aluno errou.** Justificativa **inválida**: reclamar do nome do campo (`super` vs.
`super_class`) é uma observação de nomenclatura, não um argumento técnico — e o professor
evidentemente abreviou o nome no enunciado. O ponto que se cobrava é o **`java.lang.Object`, cujo
`super_class` é 0**.

---

### Questão 5 — V/F: **F**

> *"Os tipos de dados utilizados na JVM são os definidos na linguagem Java."*

**Resposta do aluno:** F — *"Alguns tipos de java não existem em JVM, como por exemplo char e bool,
que em JVM são representados como um integer."*

**Justificativa correta.** Os conjuntos **não coincidem**, em duas direções:

1. **A JVM tem um tipo que a linguagem Java não tem:** o tipo primitivo **`returnAddress`**
   (JVMS §2.3.3), usado pelas instruções `jsr`, `jsr_w` e `ret` para implementar `finally`. Ele não
   é acessível ao programador Java e não corresponde a nenhum tipo da linguagem.
2. **A JVM não trata todos os tipos Java como tipos de primeira classe:** `boolean`, `byte`, `char`
   e `short` têm **suporte limitado** (JVMS §2.11.1). Não há instruções aritméticas próprias para
   eles: os valores são **estendidos para `int`** ao serem carregados e operados com o conjunto
   `int`, sendo truncados de volta na hora de armazenar. `boolean` em particular é representado por
   `int` (0/1) e seus arrays como `byte`.

Também vale citar o tipo de referência **`reference`** com seus três subtipos (*class*, *array*,
*interface*) e o valor `null`, além da distinção entre o tipo do valor armazenado e o tipo estático
da variável.

**Onde o aluno errou.** A resposta (F) está certa, mas a justificativa está invertida e imprecisa:

- o argumento mais forte é o contrário do que ele disse — é a **JVM que tem um tipo a mais**
  (`returnAddress`), não a linguagem;
- `char` e `boolean` **existem** na JVM (há `caload`/`castore`, `baload`/`bastore`, `i2c`,
  `newarray T_BOOLEAN`, e o descritor `C`/`Z`); o que não existe é **aritmética dedicada** a eles;
- `bool` não é palavra-chave de Java — o tipo se chama **`boolean`**.

---

### Questão 6 — V/F: **V**

> *"A máquina virtual Java aloca um frame na pilha de frames contendo a pilha de operandos (com
> max_stack slots de 32 bits), o vetor de variáveis locais (com max_locals slots de 32 bits), e o
> pool de constantes da classe do método que será executado."*

**Resposta do aluno:** V ✔

**Justificativa correta.** JVMS §2.6: um novo frame é criado **a cada invocação de método** e
destruído quando o método termina (normal ou abruptamente). Cada frame contém:

- um **vetor de variáveis locais**, cujo tamanho é dado pelo atributo `Code.max_locals`;
- uma **pilha de operandos**, cuja profundidade máxima é `Code.max_stack`;
- uma **referência ao run-time constant pool** da classe do método corrente (usada para a ligação
  dinâmica / resolução simbólica);
- ainda, informação para retorno normal e para despacho de exceções.

Cada *slot* (tanto de locais quanto da pilha) comporta um valor de 32 bits; `long` e `double`
**ocupam dois slots consecutivos**. Apenas o frame do **método corrente** está ativo.

**Nuance para a prova:** rigorosamente o frame guarda uma **referência ao** pool de constantes, e
não o pool em si (que fica na **área de métodos**, compartilhada por todas as threads). O enunciado
usa a redação dos slides, então **V** é a resposta esperada.

---

### Questão 7 — V/F: **F**

> *"O vetor de variáveis locais contém os parâmetros e as variáveis locais do método, sendo que o
> primeiro parâmetro é armazenado no índice zero."*

**Resposta do aluno:** F — *"Os parâmetros tem sua própria stack, sendo essa a stack de parâmetros."*

**Justificativa correta.** A primeira metade do enunciado é **verdadeira**: JVMS §2.6.1 — na
invocação, os parâmetros são passados **no vetor de variáveis locais** do novo frame, ocupando os
índices iniciais, seguidos das variáveis locais declaradas no corpo. O que torna a afirmação
**falsa** é a segunda metade:

- em um **método de instância** (e em `<init>`), a **variável local 0 é sempre a referência `this`**
  (o objeto sobre o qual o método foi invocado); o primeiro parâmetro declarado fica no **índice 1**;
- apenas em um **método `static`** o primeiro parâmetro fica no **índice 0** (não há `this`).

Complemento: os parâmetros são copiados em ordem de declaração, e cada `long`/`double` consome
**dois índices consecutivos** — então, mesmo em método estático, o segundo parâmetro nem sempre está
no índice 1.

**Onde o aluno errou.** A justificativa está **completamente errada**: **não existe "pilha de
parâmetros" na JVM**. As estruturas de tempo de execução são: registrador PC, pilha da JVM (de
frames), heap, área de métodos, pool de constantes de execução e pilha de método nativo — nenhuma
"pilha de parâmetros". Os parâmetros ficam, sim, **no vetor de variáveis locais**; o erro do
enunciado é apenas o **índice 0, que é `this` em métodos de instância**.

---

### Questão 8 — V/F: **F**

> *"Todo bytecode que for executado na máquina virtual utiliza a pilha de operandos."*

**Resposta do aluno:** NS (não pontua).

**Justificativa correta.** É verdade que a JVM é uma **máquina de pilha** e que a **maioria** das
instruções opera sobre a pilha de operandos, mas **há contraexemplos**:

- **`nop`** (0x00) — não faz nada, não mexe na pilha;
- **`iinc index, const`** — incrementa **diretamente** uma variável local, sem empilhar nem
  desempilhar nada (é exatamente por isso que ela existe: otimizar `i++`);
- **`goto` / `goto_w`** — desvio incondicional, só altera o PC;
- **`return`** — retorno de método `void`: não desempilha valor algum (apenas descarta o frame);
- **`jsr` / `ret`** — `ret` desvia usando um `returnAddress` guardado em uma **variável local**;
- **`wide`** — prefixo de extensão de índice.

Basta **um** contraexemplo para derrubar um "todo". Resposta: **F**.

---

### Questão 9 — V/F: **F**

> *"Não há instruções JVM específicas para os tipos booleano, byte, char e short."*

**Resposta do aluno:** V ❌

**Justificativa correta.** A afirmação é **falsa como está escrita**, porque **existem, sim,
instruções específicas** para esses tipos (JVMS §2.11.1 e Cap. 6):

| Tipo | Instruções específicas |
|---|---|
| `boolean` | `baload`, `bastore` (arrays de boolean usam as de byte), `newarray T_BOOLEAN` |
| `byte` | `bipush`, `baload`, `bastore`, `i2b`, `newarray T_BYTE` |
| `char` | `caload`, `castore`, `i2c`, `newarray T_CHAR` |
| `short` | `sipush`, `saload`, `sastore`, `i2s`, `newarray T_SHORT` |

O que **é verdade** — e é o que os slides querem dizer — é que **não existem instruções
aritméticas/lógicas dedicadas** a esses tipos: não há `sadd`, `bmul`, `cdiv`. Valores desses tipos
são **estendidos com sinal (ou com zero, no caso de `char`) para `int`**, manipulados pelas
instruções `int` (`iadd`, `isub`, `imul`…) e **truncados de volta** por `i2b`/`i2c`/`i2s` ou pela
própria instrução de armazenamento de array.

**Onde o aluno errou.** Respondeu V, generalizando "não há aritmética dedicada" para "não há
instrução nenhuma". A **própria prova se contradiz**: a questão discursiva 4 exige descrever o
acesso a um vetor de `short`, que usa **`saload`/`sastore`** — instruções específicas de `short`.
Enunciados absolutos ("não há", "sempre", "todo") quase sempre escondem exceções.

---

### Questão 10 — V/F: **F**

> *"A área de métodos armazena pool de constantes, objetos, atributos de classe ou de instâncias,
> código de métodos e código de construtores, separadas por classe."*

**Resposta do aluno:** NS (não pontua).

**Justificativa correta.** JVMS §2.5.4 e os slides da disciplina: a **área de métodos** é criada na
iniciação da JVM, é **compartilhada por todas as threads** e é análoga à área de código compilado de
uma linguagem tradicional. Ela armazena **estruturas por classe**:

- o **pool de constantes de execução** (*run-time constant pool*);
- dados de **fields** e de **métodos** (nomes, descritores, flags);
- o **código dos métodos e dos construtores**;
- as **variáveis estáticas** (atributos de classe).

O que **não** fica na área de métodos: **os objetos** e os **atributos de instância**, que são
alocados no **heap** (§2.5.3, área também compartilhada e gerenciada pelo coletor de lixo). Como o
enunciado inclui "objetos" e "atributos… de instâncias", ele é **falso**.

(Pode lançar `OutOfMemoryError` se não houver memória para atender a uma requisição de alocação.)

---

### Questão 11 — V/F: **F**

> *"Se um `field_info` de um .class contém um atributo `ConstantValue` associado a uma variável
> estática, a JVM deve ignorá-lo em silêncio."*

**Resposta do aluno:** F — *"A JVM deve ignorar no caso de uma variável NÃO estática."* ✔

**Justificativa correta.** JVMS §4.7.2: o atributo `ConstantValue` representa o valor de uma
**variável constante**. O comportamento é o **oposto** do que o enunciado diz:

- se o campo **é `static`**, o `ConstantValue` é **usado na inicialização da classe** — a JVM atribui
  o valor ao campo durante a **preparação** (§5.4.2), **antes** e independentemente de `<clinit>`;
- se o campo **não é `static`**, então **"the attribute must be silently ignored"** — o `.class` não
  é rejeitado, mas o atributo não tem efeito.

O tipo do item apontado no pool (`CONSTANT_Integer_info`, `Long`, `Float`, `Double`, `String`) tem de
ser compatível com o descritor do campo. Pode haver **no máximo um** `ConstantValue` por
`field_info`.

*(Justificativa do aluno correta e suficiente.)*

---

### Questão 12 — V/F: **F**

> *"A pilha de método nativo é utilizada para suporte a execução de métodos não Java e tem a mesma
> estrutura da pilha de frames, mas sem o pool de constantes."*

**Resposta do aluno:** NS (não pontua).

**Justificativa correta.** A primeira metade está certa (JVMS §2.5.6 e slides): a pilha de método
nativo dá suporte à execução de **métodos nativos**, isto é, **não escritos em Java** (via JNI), e é
tipicamente alocada **por thread**, no momento em que a thread é criada. Mas a segunda metade é
**falsa**:

- trata-se de uma **pilha convencional da plataforma hospedeira**, coloquialmente chamada de
  **"pilha C"** — sua estrutura é **dependente de implementação**, **não** a estrutura de frames da
  JVM (vetor de locais + pilha de operandos + referência ao pool);
- a especificação **nem sequer exige** que a JVM ofereça pilhas de método nativo: uma implementação
  que não suporte métodos nativos pode não tê-las.

Além disso, enquanto um método **nativo** é o método corrente, o **registrador PC fica indefinido**
(pode conter um ponteiro nativo), justamente porque não há bytecode sendo executado.
Exceções possíveis: `StackOverflowError` e `OutOfMemoryError`.

---

### Questão 13 — V/F: **V**

> *"Iniciação da máquina virtual começa com a carga de uma classe contendo o método `main`, passando
> um array de strings (parâmetros da linha de comandos). O método `main` deve ser declarado
> `public static void`."*

**Resposta do aluno:** V ✔

**Justificativa correta.** JVMS §5.2 (*Java Virtual Machine Startup*): a JVM começa criando a classe
inicial (*initial class*), especificada de modo dependente da implementação (tipicamente o nome
passado na linha de comando), **carregando, ligando e inicializando** essa classe; em seguida invoca
o método `main`, que precisa ser:

```java
public static void main(String[] args)
```

isto é: **`public`** (acessível ao lançador), **`static`** (invocável sem instância — não há objeto
ainda) e com retorno **`void`**; o descritor é `([Ljava/lang/String;)V`. Os argumentos da linha de
comando chegam como o array `String[]`. A JVM termina quando todas as threads *não-daemon* terminam
ou quando se chama `Runtime.exit`/`System.exit`.

---

### Questão 14 — V/F: **F**

> *"Na ocorrência de uma exceção, a JVM deve buscar o manipulador da exceção (código para tratar a
> exceção) no método corrente. Se o manipulador não for encontrado, o método corrente é encerrado de
> forma abrupta e a execução do programa é encerrada."*

**Resposta do aluno:** V ❌

**Justificativa correta.** A primeira metade está certa: ao lançar uma exceção, a JVM consulta a
**tabela de exceções** (`exception_table` do atributo `Code`) do método corrente, procurando uma
entrada cujo intervalo `[start_pc, end_pc)` contenha o PC atual e cujo `catch_type` seja compatível
com a classe da exceção (JVMS §2.10 e §3.12).

O erro está no final. Se **não** houver manipulador no método corrente:

1. o frame do método corrente é **descartado** (término **abrupto**, sem valor de retorno) e os
   monitores adquiridos por ele são liberados;
2. a exceção é **repropagada para o método invocador** (*re-thrown*), e a busca **recomeça no frame
   do chamador** — repetindo-se pilha acima;
3. **somente se a exceção percorrer toda a pilha da thread sem manipulador** é que a thread termina
   (chamando `ThreadGroup.uncaughtException`, que imprime o *stack trace*).

E mesmo aí **o programa não necessariamente é encerrado**: só a **thread** morre. Se outras threads
não-daemon continuarem vivas, a aplicação segue rodando. Dizer que "a execução do programa é
encerrada" ignora tanto a propagação quanto o modelo de threads. Antes disso ainda executam-se os
blocos `finally` (implementados via tabela de exceções / `jsr`-`ret` ou duplicação de código).

**Onde o aluno errou.** Aceitou como verdadeira uma descrição que suprime justamente o mecanismo
central do tratamento de exceções: a **propagação pilha acima (*stack unwinding*)**.

---

### Questão 15 — V/F: **F**

> *"Por ter porte para diversos ambientes (JavaCard, Java Micro Edition, etc.) a linguagem Java é
> adequada para uso em controle de plantas industriais em sistemas de tempo real com requisitos de
> tempo de resposta determinísticos."*

**Resposta do aluno:** NS (não pontua).

**Justificativa correta.** Existência de portes **não implica determinismo temporal**. Os slides de
*Conceitos sobre Linguagem Java* dizem explicitamente, comparando Java e C: Java tem **gerência de
heap com coletor de lixo**, logo **tempo não determinístico → não indicada para tempo real**;
C tem gerência de heap a cargo do programador, com **tempo determinístico → indicada para tempo
real**. As fontes de não determinismo em Java são:

- **coletor de lixo**: pausas imprevisíveis (*stop-the-world*), sem garantia de latência máxima;
- **compilação JIT**: o mesmo trecho executa em tempos muito diferentes antes e depois da compilação
  dinâmica; a carga de classes também é preguiçosa (*lazy*), acontecendo na primeira utilização;
- **escalonamento de threads e prioridades**: o modelo padrão de threads Java não garante
  escalonamento preemptivo por prioridade nem herança de prioridade;
- **alocação dinâmica** e fragmentação.

Para **tempo real duro** existe uma especificação separada — **RTSJ (Real-Time Specification for
Java, JSR-1/282)**, com `NoHeapRealtimeThread`, memória de escopo e imortal — que **não é o Java
padrão** de que a questão trata. Portanto, **F**.

---

### Questão 16 — V/F: **F**

> *"Classe abstrata é aquela em que os seus métodos são abstratos; não pode ser instanciada."*

**Resposta do aluno:** F — *"…só um dos métodos precisa ser abstrato para ela ser considerada
abstrata."*

**Justificativa correta.** A segunda metade é verdadeira (**classe abstrata não pode ser
instanciada** — `new` sobre ela é erro de compilação, e no bytecode `new` de classe abstrata lança
`InstantiationError`). A primeira metade é falsa por **duas** razões, e a mais importante é a que o
aluno não deu:

1. **Uma classe abstrata pode não ter nenhum método abstrato.** Basta declarar
   `abstract class C { }` — sem nenhum método abstrato — e `C` é abstrata e não instanciável. O que
   define a classe como abstrata é o **modificador `abstract` na declaração** (flag `ACC_ABSTRACT`),
   não a natureza dos seus métodos. É uma técnica comum para impedir instanciação.
2. **Uma classe abstrata pode (e normalmente vai) ter métodos concretos**, com corpo, além de
   atributos de instância e construtores (chamados via `super()` pelas subclasses). Isso é
   exatamente o que a diferencia de uma interface clássica.

A regra na direção inversa é que vale: **se a classe tiver ao menos um método `abstract`, ela
obrigatoriamente deve ser declarada `abstract`** (inclusive se herdar método abstrato não
implementado).

**Onde o aluno errou.** A resposta (F) está certa, mas a justificativa está **errada**: ele afirmou
que "só um dos métodos precisa ser abstrato", o que troca "todos" por "pelo menos um" — quando na
verdade **zero métodos abstratos já bastam**. A justificativa correta é: *"o que torna a classe
abstrata é o modificador `abstract`; ela pode ter nenhum, alguns ou todos os métodos abstratos, e
pode ter métodos concretos, atributos e construtores."*

> 🟥 **Divergência com a especificação (não é questão de versão)** — o **slide 121 do
> `IBM-JavaBasico.pdf` afirma o contrário**: que toda classe abstrata tem ao menos um método
> abstrato. Isso está errado pela **JLS §8.1.1.1**, em qualquer versão do Java, inclusive no 8.
> Se o gabarito oficial vier do slide, essa questão é contestável — e a justificativa acima
> (`abstract class C { }` é legal) é o argumento a apresentar.

---

### Questão 17 — V/F: **F**

> *"Interfaces podem ser utilizadas para simular herança múltipla em Java com uma classe herdando
> métodos e atributos de instância de diversas interfaces."*

**Resposta do aluno:** V ❌

**Justificativa correta.** A **primeira** parte é verdadeira e está nos slides: *"[interfaces] podem
ser usadas para simular herança múltipla"*, já que **em Java não há herança múltipla de classes** —
uma classe só pode ter **uma** superclasse (`extends` único), mas pode **implementar várias
interfaces** (`implements A, B, C`).

A afirmação é **falsa** por causa de **"atributos de instância"**: **interfaces não possuem
atributos de instância**. Pelos slides: *"a interface não pode ter métodos concretos e só pode ter
atributos constantes"*. Pela JLS §9.3, todo campo declarado em uma interface é **implicitamente
`public static final`** — ou seja, uma **constante de classe**, nunca estado por objeto. Por isso é
que se diz que Java permite herança múltipla **de tipo** (e, a partir do Java 8, de
**comportamento**, via métodos `default`), mas **nunca herança múltipla de estado** — o que
justamente evita o "problema do diamante" com atributos ambíguos de mesmo nome, ponto destacado nos
slides.

**Onde o aluno errou.** Concentrou-se na primeira metade ("simular herança múltipla", verdadeira) e
não percebeu que a expressão **"atributos de instância"** invalida a frase inteira. Atenção: numa
questão V/F, **basta uma parte falsa para a proposição inteira ser falsa**.

> 🟦 **Divergência Java 8 — o que mudou e o que não mudou nesta questão**
>
> | Afirmação | Java 1.4 (slides) | **Java 8** |
> |---|:---:|:---:|
> | Interface tem **atributos de instância** | ❌ | ❌ — **não mudou**, e é o que torna a Q17 falsa |
> | Interface tem **construtor** | ❌ | ❌ — não mudou |
> | Interface tem **métodos concretos** | ❌ | ✅ — métodos **`default`** e **`static`** |
> | Herança múltipla de **tipo** | ✅ | ✅ |
> | Herança múltipla de **comportamento** | ❌ | ✅ — via métodos `default` |
> | Herança múltipla de **estado** | ❌ | ❌ — **nunca**, em nenhuma versão |
>
> Ou seja: a questão continua **F** no Java 8, **pelo mesmo motivo**. Mas se o enunciado tivesse dito
> apenas *"herdando métodos de diversas interfaces"* (sem "atributos de instância"), a resposta
> **mudaria de F para V no Java 8**, por causa dos métodos `default`. É a palavra **"atributos de
> instância"** que sustenta o F — e é por isso que ela merece ser citada na justificativa.

---

### Questão 18 — V/F: **F**

> *"Toda classe em Java tem um ou mais métodos construtores, exceto a classe `Object`."*

**Resposta do aluno:** F — *"A classe Object possui sim um método construtor."* ✔

**Justificativa correta.** A regra geral está certa — **toda classe tem pelo menos um
construtor**: se o programador não declarar nenhum, o compilador gera o **construtor padrão**
(*default constructor*), sem argumentos, com a mesma acessibilidade da classe, cujo corpo é apenas
`super();`. No `.class`, o construtor aparece como o método de inicialização de instância
**`<init>`**, com retorno `V`.

A **exceção citada é falsa**: `java.lang.Object` **tem** um construtor público sem argumentos,
`public Object()`. Ele é indispensável, porque **todo** `<init>` de qualquer classe termina
encadeando, direta ou indiretamente, em `Object.<init>` — o verificador exige que todo construtor
invoque `this(...)` ou `super(...)` antes de usar `this`. O que `Object` não tem é **superclasse**
(por isso seu `super_class` é 0 — ver questão 4).

Detalhe adicional: **interfaces** não têm construtores, mas a questão fala em *classe*.

---

### Questão 19 — V/F: **F**

> *"Seja a estrutura de classes: Gato e Onça estendem Felinos que estende Animal. Os métodos que
> podem ser chamados na classe Gato são os mesmos que podem ser chamados na classe Onça?"*

**Resposta do aluno:** F — *"…gato pode definir internamente um método pessoal que onça não terá
acesso, pois onça não estende gato."* ✔

**Justificativa correta.** A hierarquia é:

```
Animal → Felinos → { Gato , Onça }
```

`Gato` e `Onça` são **irmãs**: ambas herdam de `Felinos` (e transitivamente de `Animal` e de
`Object`) o **mesmo conjunto** de métodos acessíveis herdados. Mas cada subclasse pode **declarar
métodos próprios** — `Gato.ronronar()`, `Onça.rugir()` — que **não existem na irmã**, porque a
herança em Java é **estritamente descendente** e não há relação de herança entre `Gato` e `Onça`.
Logo os conjuntos de métodos invocáveis **não** são iguais: são iguais apenas na **interseção
herdada** de `Felinos`. A afirmação é **falsa**.

Complementos que enriqueceriam a resposta: métodos `private` da superclasse **não são herdados** (não
são acessíveis nas subclasses); métodos de pacote só são herdados dentro do mesmo pacote; e, por
**polimorfismo**, uma referência declarada `Felinos f = new Gato();` só permite chamar os métodos
**declarados em `Felinos`** (o tipo estático limita o que o compilador aceita, ainda que o despacho
em tempo de execução, via `invokevirtual`, use a implementação de `Gato`).

---

### Questão 20 — V/F: **F**

> *"A declaração `public final int tamanhoMaximo = 15;` define um atributo de classe."*

**Resposta do aluno:** NS (não pontua).

**Justificativa correta.** Falta o modificador **`static`**. A distinção, exatamente como nos slides
do material IBM:

- **atributo (variável) de classe** = declarado **`static`**: existe **uma única cópia** por classe
  em toda a JVM, compartilhada por todos os objetos; fica na **área de métodos**; é inicializado na
  preparação/`<clinit>`;
- **atributo (variável) de instância** = **sem `static`**: **cada objeto** tem a sua própria cópia,
  alocada no **heap** junto com o objeto; é inicializada nos blocos de instância/`<init>`.

Como `public final int tamanhoMaximo = 15;` **não é `static`**, trata-se de um **atributo de
instância** — `final` apenas impede reatribuição **depois de inicializado**, em cada objeto; se você
criar 1000 objetos, haverá 1000 cópias do valor 15. Seria atributo de classe se fosse
`public static final int tamanhoMaximo = 15;` (a forma usual de constante, que aí sim geraria um
`field_info` estático com atributo `ConstantValue` — ver questão 11).

Curiosidade: essa declaração é literalmente o exemplo de **atributo de instância** usado nos slides
do material IBM-JavaBasico, logo abaixo do exemplo `private static int numero;`.

---

### Questão 21 — V/F: **V**

> *"O modificador `static` pode ser aplicado a classe, variável e método."*

**Resposta do aluno:** F — *"Uma classe não pode ser estática."* ❌ (dupla perda: resposta e
justificativa erradas)

**Justificativa correta.** Em Java, `static` pode ser aplicado a:

1. **variáveis** → variáveis de classe, uma cópia por JVM (`private static int numero;`);
2. **métodos** → métodos de classe, invocados sem instância, sem `this`, via `invokestatic`
   (`Math.cos(angulo)`);
3. **classes aninhadas** → `static class Interna { }`, a *nested class* estática, que difere da
   classe interna (*inner class*) por **não** guardar referência implícita à instância externa e por
   poder ser instanciada com `new Externa.Interna()`;
4. (bônus) **blocos de inicialização estática** — `static { ... }` — que o material chama de
   *iniciador estático*: trecho executado **uma única vez**, quando a classe é carregada/inicializada
   (compilado para `<clinit>`; ver questões 2 e discursiva 3).

A restrição real é: **uma classe de topo (top-level) não pode ser declarada `static`** — para ela o
modificador não teria sentido, pois não há instância envolvente. Mas como **classes aninhadas
aceitam `static`**, a afirmação do enunciado é **verdadeira**.

**Onde o aluno errou.** Generalizou "classe top-level não pode ser `static`" para "nenhuma classe
pode ser `static`", esquecendo as **classes aninhadas estáticas** — um recurso muito usado (p.ex.
`Map.Entry`, `AbstractMap.SimpleEntry`). Repare no contraste com a questão 16, em que ele foi
excessivamente permissivo, e aqui excessivamente restritivo.

---

### Questão 22 — V/F: **F**

> *"Arrays são alocados em memória estática (isto é durante a compilação) através do comando `new`
> em Java."*

**Resposta do aluno:** V ❌

**Justificativa correta.** A frase é **autocontraditória**: `new` é, por definição, **alocação
dinâmica em tempo de execução**. Em Java:

- **arrays são objetos** (JVMS §2.4 e §2.9): o tipo *array* é um tipo de **referência**, e toda
  instância de array é criada **no heap**, em tempo de execução, pelas instruções
  **`newarray`** (arrays de tipos primitivos), **`anewarray`** (arrays de referência) ou
  **`multianewarray`** (multidimensionais);
- o **tamanho** do array é um valor desempilhado da **pilha de operandos** no momento da execução —
  pode até vir de uma variável (`new int[n]`), o que seria impossível se a alocação fosse em tempo de
  compilação. Se o tamanho for negativo, lança-se `NegativeArraySizeException`; se faltar memória,
  `OutOfMemoryError`;
- a memória é **gerenciada pelo coletor de lixo**, liberada quando não há mais referências — Java não
  tem `free`/`delete`.

O que fica no `.class` em tempo de compilação é apenas a **referência simbólica ao tipo** do array
no pool de constantes, nunca o espaço dos elementos. Nada em Java é alocado "em memória estática
durante a compilação": o mais próximo disso são as **variáveis estáticas**, que ficam na **área de
métodos** — mas ainda assim criadas **em tempo de execução**, na preparação da classe.

**Onde o aluno errou.** Provavelmente transferiu o conceito de *array estático* de C
(`int v[10];` em escopo global, alocado pelo montador/ligador em uma seção de dados). Em Java não
existe esse caso: o `new` deixa explícito que a alocação é **dinâmica, no heap**.

---

## 4. Questões discursivas (0,8 cada)

### Discursiva 1 — Decodificação de descritor de método

> *"Qual é o protótipo do método `pandemia` que tem a assinatura abaixo?"*
>
> ```
> ([FIZZ[[[BIS[CIDZLupa_tem_covid_19;Ljava/lang/String;)V
> ```

**Resposta do aluno:**

```java
void pandemia(float[] a, int b, bool c, bool d, byte[][][] e, int f, short g,
              char[] h, int i, double j, bool l, upa_tem_covid_19 m, string n)
```

#### Tabela de códigos de descritor (JVMS §4.3.2)

| Código | *FieldType* | Tipo Java | Tamanho |
|:--:|---|---|---|
| `B` | `BaseType` | `byte` | 8 bits com sinal |
| `C` | `BaseType` | `char` | 16 bits Unicode, sem sinal |
| `D` | `BaseType` | `double` | 64 bits IEEE 754 (**2 slots**) |
| `F` | `BaseType` | `float` | 32 bits IEEE 754 |
| `I` | `BaseType` | `int` | 32 bits com sinal |
| `J` | `BaseType` | `long` | 64 bits com sinal (**2 slots**) |
| `S` | `BaseType` | `short` | 16 bits com sinal |
| `Z` | `BaseType` | `boolean` | `true`/`false` |
| `L<nome_da_classe>;` | `ObjectType` | instância da classe (nome **interno**, com `/` no lugar de `.`); o **`;` é obrigatório** | referência |
| `[` | `ArrayType` | uma dimensão de array; prefixa o descritor do componente (`[[[B` = `byte[][][]`) | referência |
| `V` | — | `void` — **só** como tipo de **retorno** | — |

Forma geral: **`( <descritores dos parâmetros, sem separadores> ) <descritor de retorno>`**.
Note que não há vírgulas: a decodificação é feita **caractere a caractere, da esquerda para a
direita**, e cada `[` "consome" o descritor seguinte.

#### Decodificação campo a campo

| # | Trecho | Leitura | Tipo Java | Slots |
|:--:|---|---|---|:--:|
| — | `(` | início da lista de parâmetros | — | — |
| 1 | `[F` | array de `F` | `float[]` | 1 |
| 2 | `I` | inteiro | `int` | 1 |
| 3 | `Z` | booleano | `boolean` | 1 |
| 4 | `Z` | booleano | `boolean` | 1 |
| 5 | `[[[B` | array de array de array de `B` | `byte[][][]` | 1 |
| 6 | `I` | inteiro | `int` | 1 |
| 7 | `S` | short | `short` | 1 |
| 8 | `[C` | array de `C` | `char[]` | 1 |
| 9 | `I` | inteiro | `int` | 1 |
| 10 | `D` | double | `double` | **2** |
| 11 | `Z` | booleano | `boolean` | 1 |
| 12 | `Lupa_tem_covid_19;` | objeto da classe `upa_tem_covid_19` (o `L` é o marcador, **não** faz parte do nome; termina no `;`) | `upa_tem_covid_19` | 1 |
| 13 | `Ljava/lang/String;` | objeto da classe `java.lang.String` (`/` → `.`) | `String` | 1 |
| — | `)V` | retorno **`void`** | `void` | — |

**Total: 13 parâmetros, ocupando 14 slots** no vetor de variáveis locais (o `double` consome dois).
Se `pandemia` for um **método de instância**, os parâmetros começam no índice **1**, pois o índice 0
guarda `this` (ver questão 7) — nesse caso o método usaria ao menos 15 slots.

#### Protótipo correto

```java
void pandemia(float[] a, int b, boolean c, boolean d, byte[][][] e, int f,
              short g, char[] h, int i, double j, boolean k,
              upa_tem_covid_19 l, String m)
```

**Comentário.** O aluno **acertou a estrutura inteira** — inclusive os dois pontos que mais derrubam
gente: (i) o `[[[B` como `byte[][][]` e (ii) o `L` de `Lupa_tem_covid_19;` ser o **marcador de
`ObjectType`**, de modo que a classe se chama `upa_tem_covid_19` (e não `Lupa...`). Os defeitos são
de **sintaxe da linguagem Java**, que numa prova de Software Básico custam pontos:

- **`bool` não existe em Java** — o tipo primitivo é **`boolean`** (3 ocorrências);
- **`string` com `s` minúsculo não existe** — é a classe **`String`** (`java.lang.String`);
- o descritor **não informa o modificador de acesso nem `static`** (essas informações estão nas
  `access_flags` do `method_info`), então escrever apenas `void pandemia(...)` é adequado;
- vale sempre conferir o **retorno `V` = `void`** e lembrar que `V` só aparece em retorno.

---

### Discursiva 2 — Retorno de um `long` ao método chamador

> *"Descreva as operações realizadas nas estruturas em runtime para retornar um `long` ao método
> chamador quando o método chamado termina."*

**Resposta do aluno:**
> *"Ao terminar sua execução, a pilha de frames é desempilhada e se checa a array de variáveis
> locais, onde o valor do long estará. Caso não haja exceções, o valor desse long será então passado
> para a array de variáveis locais do método chamador."*

#### Resposta modelo

O retorno é feito pela instrução **`lreturn`** (opcode `0xAD`), a variante de `return` para o tipo
`long`. O processo, em tempo de execução (JVMS §2.6.4, §3.4 e §6.5 *lreturn*):

1. **Estado prévio.** No frame do método **chamado** (o corrente), o valor `long` a ser devolvido foi
   deixado **no topo da pilha de operandos**, ocupando **dois slots de 32 bits** (o par conta como
   um único valor de 64 bits). Em geral ele chega ali via `lload_<n>` (cópia do vetor de variáveis
   locais para a pilha), `ladd`, `lconst_*`, `getfield`, etc.
2. **Verificação de tipo.** O verificador de bytecode já garantiu em tempo de ligação que o descritor
   do método termina em `J` e que a instrução executada é `lreturn` (usar `ireturn` aqui seria erro
   de verificação).
3. **Liberação de monitores.** Se o método for `synchronized`, o monitor adquirido na entrada é
   **liberado**; se o método contiver `monitorenter` sem `monitorexit` correspondente, a JVM
   trata como término abrupto.
4. **Desempilhamento do valor.** `lreturn` **desempilha o `long` (2 slots) da pilha de operandos do
   frame do método chamado**.
5. **Descarte do frame.** O frame do método chamado é **removido do topo da pilha da JVM** da thread
   (*pop*). Com ele desaparecem **o vetor de variáveis locais, a pilha de operandos e a referência ao
   pool de constantes** daquele método — toda a memória do frame é liberada de uma vez.
6. **Restauração do chamador.** O frame do **invocador** volta a ser o **frame corrente**; o
   **registrador PC** da thread é restaurado para a instrução **seguinte** à instrução `invoke*`
   que originou a chamada.
7. **Entrega do valor.** O valor `long` desempilhado no passo 4 é **empilhado na pilha de operandos
   do frame do chamador**, novamente ocupando **2 slots**. É ali — **na pilha de operandos, não nas
   variáveis locais** — que ele fica disponível.
8. **Uso pelo chamador.** Só **depois**, e apenas se o código-fonte atribuiu o resultado a uma
   variável, o chamador executa um **`lstore_<n>`** para mover o valor da pilha de operandos para
   **duas posições consecutivas** do seu vetor de variáveis locais. Se o resultado não for usado
   (`obj.metodo();` com retorno ignorado), o compilador emite **`pop2`** para descartá-lo.

Em resumo: **operando sai da pilha de operandos do chamado → frame do chamado é descartado →
operando entra na pilha de operandos do chamador**.

*(Simetricamente, na chamada: os argumentos saem da pilha de operandos do chamador e entram no vetor
de variáveis locais do novo frame — §2.6.1. É por isso que o `max_stack` do chamador precisa comportar
os 2 slots do resultado.)*

**Comentário / onde o aluno errou.**

- **Erro central:** ele diz que o valor está **no vetor de variáveis locais** do método chamado e que
  é entregue **no vetor de variáveis locais** do chamador. Está errado nos dois lados: a **passagem
  de resultados é feita pela pilha de operandos**. O vetor de variáveis locais do chamado é
  **destruído junto com o frame** — se o valor estivesse só lá, ele se perderia.
- **Ordem invertida:** ele desempilha o frame **antes** de recuperar o valor, o que é impossível —
  primeiro `lreturn` desempilha o valor, **depois** o frame é descartado.
- **Faltou:** dizer que `long` ocupa **2 slots**; nomear a instrução **`lreturn`**; mencionar a
  restauração do **PC**; e mencionar a liberação de monitor em método `synchronized`.
- A ressalva "caso não haja exceções" está deslocada: uma exceção levaria a um **término abrupto**
  (`athrow`/propagação, ver questão 14), caminho em que **nenhum valor de retorno é produzido**.

---

### Discursiva 3 — Ordem de inicialização e sequência impressa

> Considere o pseudocódigo:
>
> ```java
> class Uuupa extends Opa {
>         static { "imprime 1" }
>                { "imprime 2" }
>         public Uuupa() { "imprime 3" }
>         public static void main(String[] args) {
>                 "imprime 4";
>                 Uuupa f = new Uuupa();
>         }
> }
> class Opa {
>         static { "imprime 5" }
>                { "imprime 6" }
>         Opa() { "imprime 7"; }
> }
> ```

**Resposta do aluno:** `5146723`

#### Resposta modelo — **`5146723` está CORRETA** ✔

A sequência decorre de duas regras distintas: a **inicialização de classe** (`<clinit>`, uma única
vez por classe) e a **inicialização de instância** (`<init>`, a cada `new`).

**Fase A — Inicialização de classe (`<clinit>`), antes de `main`**

O compilador reúne, **na ordem textual**, todos os blocos `static { }` e as atribuições a variáveis
estáticas de cada classe em um método `<clinit>`, invocado **implicitamente pela JVM** (nunca por
`invokestatic`), **uma única vez**, sob trava, na inicialização da classe.

1. A JVM carrega a classe inicial `Uuupa` e vai inicializá-la. Pela JVMS §5.5, **antes** de executar
   `Uuupa.<clinit>` ela deve inicializar a **superclasse** `Opa`.
2. `Opa.<clinit>` executa → **imprime 5**.
3. `Uuupa.<clinit>` executa → **imprime 1**.

**Fase B — Execução de `main`**

4. `main` começa → **imprime 4**.
5. `new Uuupa()` executa: a instrução **`new`** aloca o objeto no heap e zera seus campos; em seguida
   **`invokespecial Uuupa.<init>()V`** é chamada sobre a referência duplicada (`dup`).

**Fase C — Inicialização de instância (`<init>`)**

O compilador monta cada `<init>` (construtor) nesta ordem fixa:
**(i)** chamada a `super(...)` (ou `this(...)`); **(ii)** **blocos de inicialização de instância
`{ }` e inicializadores de campos de instância, na ordem textual**; **(iii)** corpo do construtor.
É por isso que os blocos `{ }` são **copiados para dentro de todo construtor** da classe.

6. `Uuupa.<init>` começa chamando **`super()`** → entra em `Opa.<init>`.
7. `Opa.<init>` chama `super()` → `Object.<init>` (nada imprime).
8. Executa o **bloco de instância de `Opa`** → **imprime 6**.
9. Executa o **corpo do construtor `Opa()`** → **imprime 7**.
10. Volta a `Uuupa.<init>`: executa o **bloco de instância de `Uuupa`** → **imprime 2**.
11. Executa o **corpo do construtor `Uuupa()`** → **imprime 3**.

**Sequência final: 5 → 1 → 4 → 6 → 7 → 2 → 3 ⇒ `5146723`** ✔

| Ordem | Saída | Origem | Método sintetizado |
|:--:|:--:|---|---|
| 1º | 5 | `static { }` da **superclasse** `Opa` | `Opa.<clinit>` |
| 2º | 1 | `static { }` da subclasse `Uuupa` | `Uuupa.<clinit>` |
| 3º | 4 | corpo de `main` | `main` |
| 4º | 6 | bloco de instância `{ }` de `Opa` | `Opa.<init>` |
| 5º | 7 | corpo do construtor `Opa()` | `Opa.<init>` |
| 6º | 2 | bloco de instância `{ }` de `Uuupa` | `Uuupa.<init>` |
| 7º | 3 | corpo do construtor `Uuupa()` | `Uuupa.<init>` |

**Armadilhas para não cair na prova:**

- **Estático antes de instância, e superclasse antes de subclasse — nas duas fases.** Daí
  `5,1` (clinit) e depois `6,7,2,3` (init).
- **Bloco de instância vem ANTES do corpo do construtor**, ainda que apareça depois no texto: `6`
  antes de `7`, `2` antes de `3`.
- **Se houvesse um segundo `new Uuupa()`**, a saída adicional seria apenas `6723` — os `<clinit>`
  **não** se repetem.
- **Se `main` não instanciasse nada**, a saída seria só `514`. Os `<clinit>` rodam de qualquer forma,
  porque a classe inicial é sempre inicializada.

**Comentário.** Resposta **correta**. Numa prova discursiva, porém, valeria acompanhar o número com
a justificativa (`<clinit>` da superclasse → `<clinit>` da subclasse → `main` → `super()` → blocos de
instância → construtores), pois é a justificativa que distingue quem sabe de quem acertou por sorte.

---

### Discursiva 4 — Passos da JVM para `B[2] = (short) B[2] - 128;`

> *"Seja `B` um vetor de `short`. Descreva e justifique todos os passos para a execução do comando a
> seguir pela JVM Java: `B[2] = (short) B[2] – 128;`"*

**Resposta do aluno:**
> *"No frame atual, para acessar o valor na array B, é usada a referência para a constant_pool e esse
> valor é inserido na pilha de variáveis locais. Esse valor é usado na pilha de operandos para
> realizar a subtração, e o valor resultante é empilhado na pilha de operações. Ao chegar no final da
> execução do método, a pilha de operadores é desempilhada para se obter o valor resultante e o frame
> é desempilhado da pilha de frames. Por último o valor de B[2] é atualizado com base no valor que
> foi desempilhado do frame encerrado."*

#### Observação preliminar sobre o código-fonte

Escrito **exatamente** como está, `B[2] = (short) B[2] - 128;` **não compila**: o cast `(short)`
liga-se apenas a `B[2]`, e a subtração promove os operandos a `int` (**promoção numérica binária**,
JLS §5.6.2), de modo que a expressão à direita tem tipo **`int`** e não pode ser atribuída a um
elemento `short` sem cast explícito — `error: incompatible types: possible lossy conversion from int
to short`. O comando pretendido (e o que descrevemos) é:

```java
B[2] = (short) (B[2] - 128);
```

#### Bytecode gerado e evolução da pilha de operandos

Suponha `B` na variável local de índice 1 (método de instância: 0 = `this`). O `javac` gera:

| # | Instrução | O que faz | Pilha de operandos depois |
|:--:|---|---|---|
| 0 | `aload_1` | empilha a **referência** ao array `B` (alvo do **store**) | `B` |
| 1 | `iconst_2` | empilha o **índice** 2 como `int` (alvo do store) | `B, 2` |
| 2 | `aload_1` | empilha de novo a referência a `B` (agora para o **load**) | `B, 2, B` |
| 3 | `iconst_2` | empilha de novo o índice 2 | `B, 2, B, 2` |
| 4 | `saload` | desempilha (arrayref, index) e empilha `B[2]` **estendido com sinal para `int`** | `B, 2, valor` |
| 5 | `sipush 128` | empilha a constante 128 como `int` | `B, 2, valor, 128` |
| 6 | `isub` | desempilha os dois `int`, empilha `valor − 128` (`int`) | `B, 2, resultado` |
| 7 | `i2s` | trunca o `int` para 16 bits e reestende com sinal (o cast `(short)`) | `B, 2, resultado16` |
| 8 | `sastore` | desempilha (arrayref, index, value) e grava em `B[2]`, truncando para `short` | *(vazia)* |

**`max_stack` necessário para esse trecho: 4.** Ao final, a pilha de operandos volta ao estado
anterior: **o comando não deixa resíduo**.

#### Justificativa de cada passo

- **Ordem de avaliação (passos 0–3).** Java avalia a expressão **da esquerda para a direita**
  (JLS §15.26.1): para uma atribuição a elemento de array, **primeiro** avalia-se a referência do
  array e o índice do **destino**, **depois** a expressão da direita. Por isso `B` e `2` são
  empilhados **duas vezes**: o primeiro par fica "embaixo", esperando o `sastore`. (Como o índice é
  uma constante, alguns compiladores poderiam usar `dup2`, mas o `javac` emite o código acima.)
- **`aload_1` (e não `iload_1`).** **Arrays são objetos** (ver questão 22): a variável `B` guarda uma
  **referência** ao objeto array no heap, e referências são carregadas com `aload`. É aqui que o
  aluno mais erra: **não há consulta ao pool de constantes** para acessar uma variável local — o
  acesso é direto, por **índice** no vetor de variáveis locais do frame. O pool só entraria se `B`
  fosse um campo (`getfield`/`getstatic`).
- **`iconst_2`.** Para índices e constantes pequenas há instruções compactas: `iconst_m1` a
  `iconst_5` (1 byte, sem operando); fora dessa faixa usa-se `bipush` (−128…127), `sipush`
  (−32768…32767) ou `ldc` (pool de constantes).
- **`saload` (passo 4).** É a instrução **específica de array de `short`** — prova de que a
  questão 9 é falsa. Ela desempilha `arrayref` e `index`, verifica **`NullPointerException`** (se a
  referência for `null`) e **`ArrayIndexOutOfBoundsException`** (se `index < 0` ou
  `index >= arraylength`), lê os 16 bits, **estende o sinal para 32 bits** e empilha um `int`. Ou
  seja: **na pilha de operandos não existe "um short"** — existe um `int`.
- **`sipush 128` (passo 5).** Aqui está a pegadinha clássica: **`bipush` NÃO serve**, porque seu
  operando é um `byte` com sinal, faixa **−128 a +127** — e **128 está fora**. Por isso o `javac`
  emite **`sipush 128`** (operando de 16 bits com sinal). Curiosamente, `-128` caberia em `bipush`;
  `+128` não.
- **`isub` (passo 6).** **Não existe `ssub`**: a aritmética de `short` (e de `byte`, `char`,
  `boolean`) é feita com o conjunto de instruções de **`int`** (JVMS §2.11.1 e questão 5). `isub`
  desempilha dois `int`, calcula `value1 − value2` e empilha o `int` resultante, com
  **aritmética em complemento de dois e *overflow* silencioso** (sem exceção).
- **`i2s` (passo 7).** É a tradução direta do cast `(short)`: **descarta os 16 bits mais
  significativos** do `int` e **estende o sinal** do bit 15 de volta para 32 bits. É uma **conversão
  com perda** (*narrowing*) — por exemplo, se `B[2]` valesse −32768, então −32768 − 128 = −32896, que
  não cabe em `short`, e o `i2s` devolveria +32640. O resultado continua **fisicamente como `int` na
  pilha**, apenas com o valor já reduzido à faixa de `short`.
- **`sastore` (passo 8).** Desempilha `value` (int), `index` e `arrayref`, refaz as verificações de
  `NullPointerException`/`ArrayIndexOutOfBoundsException`, **trunca o `int` para 16 bits** e escreve
  em `B[2]` **no heap** (o array é objeto; a escrita é no objeto, não no frame). Repare que
  `sastore` já trunca — o `i2s` é tecnicamente redundante aqui, mas é emitido porque o **cast
  explícito** existe no código-fonte; sem o cast, o programa nem compilaria.

**Comentário / onde o aluno errou.** A resposta tem **quatro erros conceituais graves**:

1. **"é usada a referência para a constant_pool"** — errado. `B` é uma **variável local**, acessada
   por **índice** no vetor de variáveis locais (`aload_1`). O pool de constantes serve para
   **referências simbólicas** (classes, campos, métodos, strings, constantes grandes) resolvidas por
   `ldc`, `getfield`, `invoke*` etc.
2. **"esse valor é inserido na pilha de variáveis locais"** — não existe "pilha de variáveis
   locais": é um **vetor (array) indexado**, de acesso aleatório, e nesse comando **nada é escrito**
   nele. Todo o trabalho acontece na **pilha de operandos**.
3. **"ao chegar no final da execução do método… o frame é desempilhado… por último o valor de B[2] é
   atualizado"** — errado e invertido. A escrita em `B[2]` acontece **na própria instrução
   `sastore`**, imediatamente, **muito antes** de o método terminar. O término do frame não tem
   nenhuma relação com a atribuição (ele confundiu este comando com o **retorno de valor** da
   discursiva 2).
4. **Faltou** nomear qualquer instrução (`aload`, `saload`, `sipush`, `isub`, `i2s`, `sastore`),
   mencionar a **promoção a `int`**, o **truncamento do cast** e as **exceções** (`NullPointerException`,
   `ArrayIndexOutOfBoundsException`) — que é exatamente o que a questão pedia ao dizer "descreva **e
   justifique todos os passos**".

---

## 5. Temas que essa prova cobra

| Tema | Questões | Onde estudar |
|---|---|---|
| Estrutura do arquivo `.class`: stream de bytes, big-endian, ausência de padding | 1 | `formato-class.pdf` (Introdução); JVMS §4.1 |
| `super_class`, `this_class`, `access_flags` e o caso `Object` (`super_class = 0`) | 4 | `formato-class.pdf`; JVMS §4.1 |
| `method_info`, atributo `Code`, métodos `native` e `abstract` | 3 | `formato-class.pdf`; JVMS §4.6, §4.7.3 |
| `field_info` e atributo `ConstantValue` (estático vs. não estático) | 11 | `formato-class.pdf`; JVMS §4.7.2 |
| **Descritores** de campo e de método (`B C D F I J S Z L…; [ V`) | Disc. 1 | `formato-class.pdf`; JVMS §4.3.2 e §4.3.3 |
| Tipos de dados da JVM: primitivos, `returnAddress`, `reference`; suporte limitado a `boolean`/`byte`/`char`/`short` | 5, 9 | `java-jvm8-1-3.pdf` (Tipos de Dados); JVMS §2.2–2.4, §2.11.1 |
| Áreas de memória em tempo de execução: PC, pilha da JVM, **heap**, **área de métodos**, pool de constantes de execução, pilha de método nativo | 10, 12, 22 | `java-jvm8-1-3.pdf` (Estrutura de Dados em Tempo de Execução); JVMS §2.5 |
| **Frames**: `max_stack`, `max_locals`, vetor de variáveis locais, pilha de operandos, `this` no índice 0 | 6, 7 | `java-jvm8-1-3.pdf` (Frames); JVMS §2.6 |
| Invocação e **retorno** de métodos; passagem de parâmetros e de resultados | Disc. 2 | `java-jvm8-1-3.pdf`, `java-jvm8-2-3.pdf`; JVMS §2.6.1–2.6.4, §6.5 (`lreturn`) |
| Conjunto de instruções: formato, opcode + operandos, `tableswitch`/`lookupswitch` e padding | 8 | `java-jvm8-2-3.pdf` (Interpretador / Conjunto de Instruções); JVMS Cap. 6 |
| Instruções de array (`newarray`, `saload`, `sastore`), de constante (`iconst`, `bipush`, `sipush`, `ldc`), aritméticas (`isub`) e de conversão (`i2b`, `i2c`, `i2s`) | 9, 22, Disc. 4 | `java-jvm8-2-3.pdf` e `java-jvm8-3-3.pdf`; JVMS Cap. 6 |
| Carga, ligação, **inicialização de classe** e `<clinit>`; iniciação da JVM e `main` | 2, 13, Disc. 3 | `java-jvm8-1-3.pdf`; `IBM-JavaBasico.pdf` (iniciador estático); JVMS §5.2, §5.4.2, §5.5 |
| Inicialização de instância: `<init>`, blocos `{ }`, `super()`, ordem de execução | 18, Disc. 3 | `IBM-JavaBasico.pdf` (construtores); JLS §12.5; JVMS §2.9 |
| **Exceções**: tabela de exceções, busca de manipulador, propagação pilha acima | 14 | `java-jvm8-2-3.pdf`; JVMS §2.10, §3.12 |
| Java × C: coletor de lixo, referências vs. ponteiros, (não) determinismo e tempo real | 15, 22 | `java-conceitos.pdf` (Introdução) |
| POO em Java: classes abstratas, interfaces, herança (simples) e simulação de herança múltipla | 16, 17, 19 | `IBM-JavaBasico.pdf` (Herança múltipla, Interfaces); `java-conceitos.pdf` |
| Modificadores: `static` (variável, método, classe aninhada, bloco), `final`, atributo de classe × de instância | 20, 21 | `IBM-JavaBasico.pdf` (Modificador static; declaração de atributos) |

### Checklist de revisão rápida

- [ ] Sei decodificar **qualquer** descritor de método em um protótipo Java (e o caminho inverso).
- [ ] Sei dizer **o que há dentro de um frame** e o que há **fora** dele (heap, área de métodos).
- [ ] Sei a diferença entre **pilha de operandos** (passagem de resultados) e **vetor de variáveis
      locais** (parâmetros + locais, `this` no índice 0, 2 slots para `long`/`double`).
- [ ] Sei a ordem **`<clinit>` da superclasse → `<clinit>` da subclasse → `main` → `super()` →
      blocos de instância → corpo do construtor**.
- [ ] Sei traduzir um comando de atribuição a elemento de array em bytecode, com as verificações de
      exceção e as conversões `i2b`/`i2c`/`i2s`.
- [ ] Desconfio de todo enunciado com **"sempre"**, **"todo"**, **"nunca"** ou **"não há"** — na
      prova, são justamente as questões 1, 3, 4, 8, 9 e 14.

---

## Apêndice — Onde o slide e o Java 8 divergem nesta prova

Três questões desta prova têm resposta diferente conforme você siga o **slide** ou a
**especificação do Java 8**. Saber disso é o que permite escrever a justificativa que salva o ponto.

| Q | Enunciado (resumido) | Pelo slide | Pelo Java 8 | O que escrever |
|:---:|---|:---:|:---:|---|
| **9** | "Não há instruções específicas para `boolean`, `byte`, `char` e `short`" | **V** | **F** | 🟥 Ambígua. Se o enunciado disser "**aritméticas**" → V. Se disser só "específicas" → **F**, citando `saload`/`sastore`/`i2s` — que a **discursiva 4 da própria prova** usa |
| **16** | "Classe abstrata é aquela em que os seus métodos são abstratos" | ambíguo | **F** | 🟥 F. O que define é o **modificador `abstract`**; **zero** métodos abstratos já bastam. O slide 121 do IBM afirma o contrário e está errado |
| **17** | "Interfaces... herdando métodos **e atributos de instância** de diversas interfaces" | **F** | **F** | 🟦 F nas duas leituras, mas **pelo trecho "atributos de instância"**. Sem essa expressão, seria **V no Java 8** (métodos `default`) |

E uma quarta, que não é divergência mas é a mesma armadilha de "sempre":

| **21** | "`static` pode ser aplicado a classe, variável e método" | **V** | **V** | Classe **aninhada** aceita `static`; classe **de topo** não. A prova considerou **V**; o simulado, **F**. Ver [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md) |

Detalhamento completo em [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).
