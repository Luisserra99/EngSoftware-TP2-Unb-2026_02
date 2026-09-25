# Divergências com o Java SE 8

> **Baseline desta revisão:** **Java SE 8** (março/2014) — **JLS 8**, **JVMS 8**, arquivo `.class` com `major_version = 52`.
> Tudo neste material foi conferido contra essa versão. Este documento reúne **todos os pontos em que o material da disciplina diverge do Java 8**, em qualquer direção.

Cada divergência aparece **anotada no arquivo de origem**, com um destes marcadores:

| Marcador | Significado | O que fazer na prova |
|---|---|---|
| 🟦 **Divergência Java 8** | O material é **anterior** ao Java 8 e a regra mudou até lá | Responda pelo slide, mas **saiba** a regra atual — pode ser cobrada |
| 🟪 **Posterior ao Java 8** | O fato citado só passou a valer **depois** do Java 8 | **Não cai** nesta prova; está aqui só para você não se confundir |
| 🟥 **Divergência com a especificação** | O material contradiz a JLS/JVMS **independentemente de versão** | Responda pelo slide, mas a justificativa correta é a da especificação |

---

## 1. Linha do tempo (o que existia em cada versão)

| Versão | `major_version` | O que introduziu que afeta este material |
|---|:---:|---|
| Java 1.0–1.3 | 45–47 | Base da linguagem e da JVM |
| **Java 1.4** | **48** | `assert`. **É a versão em que o PDF da IBM foi escrito** |
| Java 5 | 49 | **Generics**, **autoboxing**, **`for` estendido**, **varargs**, **`enum`**, anotações, `java.util.concurrent` |
| Java 6 | 50 | `StackMapTable` (verificação por *type checking*) |
| Java 7 | 51 | **`invokedynamic`** + tags **15/16/18** do pool, atributo `BootstrapMethods`, `switch` com `String`, *try-with-resources*, *multi-catch*, diamante `<>`, literais binários e com `_`. **`jsr`/`ret` proibidas** a partir daqui. Pool de strings movido para o heap |
| **Java 8** | **52** | **Lambdas** e *method references* (compiladas com `invokedynamic`), **métodos `default` e `static` em interfaces**, Streams, `java.time`, `Optional`, anotações repetíveis, **anotações de tipo** (JSR 308), atributo **`MethodParameters`**, flag `ACC_MANDATED`, **fim da PermGen → Metaspace** |
| *(depois do 8)* | 53+ | Módulos e métodos `private` em interface (9), `CONSTANT_Dynamic` tag 17 e *nestmates* (11), *records* (16), *sealed* e ponto flutuante sempre estrito (17) |

> **Regra prática:** o material da JVM (`java-jvm8-*`, `formato-class`) está alinhado ao Java 8. O material da **linguagem** (`IBM-JavaBasico`) é de **Java 1.4** — é dele que vem quase toda a divergência.

---

## 2. As 5 divergências que podem valer ponto

Estas são as que têm chance real de aparecer numa questão. As demais são detalhe.

### 2.1 🟦 Interface "só tem métodos abstratos"

**O material diz:** interface não pode ter métodos concretos; todo método de interface é implicitamente `public abstract`; método de interface não pode ser `static`.

**No Java 8:** **falso**. A partir do Java 8 uma interface pode ter:
- **métodos `default`** — com corpo, herdados pelas classes que a implementam;
- **métodos `static`** — com corpo, chamados por `Interface.metodo()`.

```java
interface Veiculo {
    int RODAS = 4;                                  // continua public static final
    void acelerar();                                // abstrato (implícito)
    default void buzinar() { System.out.println("bi"); }   // Java 8: TEM corpo
    static Veiculo padrao() { return null; }        // Java 8: static com corpo
}
```

**O que NÃO mudou:** interface continua **sem atributos de instância** (todo campo é `public static final`) e **sem construtor**. Por isso a afirmação "uma classe herda métodos **e atributos de instância** de várias interfaces" continua **FALSA** no Java 8 — é assim que Java evita o problema do diamante de estado.

**Consequência na JVM (JVMS 8):**
- `invokespecial` passou a ser usada também para `Interface.super.metodo()`;
- `invokevirtual` pode resolver para um método `default` herdado;
- `ACC_STATIC` em método de interface exige `major_version ≥ 52`;
- **§5.5:** ao iniciar uma classe, agora também são iniciadas as **superinterfaces que declaram métodos `default`** (antes, superinterfaces nunca eram iniciadas por causa da subclasse).

**Na prova:** se o enunciado for sobre **atributos de instância** em interface → **F** (vale em qualquer versão). Se for sobre **métodos concretos** em interface → o slide diz que não pode; responda pelo slide, mas escreva na justificativa que *"desde o Java 8 existem métodos `default` e `static`"*. Isso mostra domínio e protege se o gabarito for pela versão nova.

*Arquivos afetados:* [IBM-JavaBasico.md](IBM-JavaBasico.md) §1.2, §25.8, §Resumo; [java-conceitos.md](java-conceitos.md) §16; [SB_Prova_Java.md](SB_Prova_Java.md) Q17; [00-SIMULADO.md](00-SIMULADO.md) Q38.

---

### 2.2 🟦 Área de métodos = PermGen

**O material diz (implicitamente):** a área de métodos é a *permanent generation*.

**No Java 8:** a **PermGen foi removida** (JEP 122). Os metadados de classe passaram para a **Metaspace**, alocada em **memória nativa** fora do heap. A flag `-XX:MaxPermSize` **deixou de existir**; a equivalente é `-XX:MaxMetaspaceSize`. O erro `OutOfMemoryError: PermGen space` foi substituído por `OutOfMemoryError: Metaspace`.

Antes disso, o **pool de strings internadas** já havia saído da PermGen para o **heap** no **Java 7**.

**O que não muda:** a **especificação** nunca falou em PermGen nem em Metaspace — ela só define a *área de métodos* logicamente. PermGen e Metaspace são **detalhes de implementação da HotSpot**.

**Na prova:** a resposta conceitual é sempre a da especificação (área de métodos = estruturas por classe, compartilhada entre threads). Só cite Metaspace se a questão falar de implementação.

*Arquivos afetados:* [java-jvm8-1-3.md](java-jvm8-1-3.md) §4.

---

### 2.3 🟦 `invokedynamic` "não é usada" / opcode 0xba vazio

**O material diz:** a tabela de opcodes da 2ª edição da JVMS mostra `0xba` como não utilizado.

**No Java 8:** `invokedynamic` existe desde o **Java 7** e é **central no Java 8** — é com ela que **toda lambda e todo *method reference*** são compilados. Uma lambda **não** gera uma classe anônima: gera um `invokedynamic` que, na primeira execução, chama o *bootstrap method* `LambdaMetafactory.metafactory` (registrado no atributo `BootstrapMethods`) e devolve uma instância da interface funcional.

```java
Runnable r = () -> System.out.println("oi");
// bytecode: invokedynamic #2, 0   // run()Ljava/lang/Runnable;
```

Por isso as tags **15 (`MethodHandle`)**, **16 (`MethodType`)** e **18 (`InvokeDynamic`)** do pool de constantes são reais e usadas em Java 8.

**Na prova:** se a tabela do slide mostrar `0xba` vazio, é a tabela da 2ª edição (Java 1.x). Na JVMS 8 o opcode 186 é `invokedynamic` e o conjunto tem **5** instruções de invocação.

*Arquivos afetados:* [java-jvm8-3-3.md](java-jvm8-3-3.md) tabela de opcodes; [formato-class.md](formato-class.md) §5 (tags do pool).

---

### 2.4 🟥 "Classe abstrata tem ao menos um método abstrato"

**O material diz (slide 121 do IBM):** toda classe abstrata tem pelo menos um método abstrato.

**Pela JLS (qualquer versão, incluindo 8):** **falso**. O que torna a classe abstrata é o **modificador `abstract`** (flag `ACC_ABSTRACT`). A implicação vale **só no sentido inverso**: se a classe **tem** um método abstrato, ela **deve** ser declarada abstrata.

```java
abstract class Base { }                  // legal: zero métodos abstratos
// new Base();                           // erro de compilação: não pode instanciar
```

**Esta não é uma divergência de versão** — o slide está simplesmente errado, e sempre esteve.

**Na prova:** responda **F** e justifique com "basta o modificador `abstract`; zero métodos abstratos já bastam". Cuidado com a armadilha em que o aluno da prova anterior caiu: ele respondeu F, mas justificou *"só um método precisa ser abstrato"* — o que ainda está errado, porque **nenhum** precisa.

*Arquivos afetados:* [IBM-JavaBasico.md](IBM-JavaBasico.md) §25.8; [SB_Prova_Java.md](SB_Prova_Java.md) Q16; [00-SIMULADO.md](00-SIMULADO.md) Q37.

---

### 2.5 🟥 "Não há instruções específicas para `boolean`, `byte`, `char` e `short`"

Esta caiu na prova anterior (Q9) e o gabarito é ambíguo. A JVMS 8 **§2.11.1** diz que a JVM oferece **"suporte limitado"** a esses tipos:

| Leitura | Resposta | Argumento |
|---|:---:|---|
| **Restrita** (aritmética) | **V** | Não existe `badd`, `sadd`, `cadd`, `zadd`. Esses tipos são **estendidos para `int`** e operados com as instruções `i*` |
| **Ampla** (qualquer instrução) | **F** | Existem `baload`/`bastore`, `caload`/`castore`, `saload`/`sastore`, `i2b`/`i2c`/`i2s`, `bipush`/`sipush`, `newarray` com `atype` = 4 (`T_BOOLEAN`), 8 (`T_BYTE`), 5 (`T_CHAR`), 9 (`T_SHORT`) |

**Reforço decisivo:** a **própria prova** usa `saload`/`sastore`/`i2s` na discursiva 4. Ou seja, o enunciado da Q9 e o da D4 se contradizem.

**Na prova:** se o enunciado disser *"instruções **aritméticas**"* ou *"suporte direto"* → **V**. Se disser apenas *"instruções específicas"* (caso da Q9) → **F**, e justifique citando `saload`/`sastore`/`i2s` — que é exatamente o que a D4 da mesma prova exige.

> Observação sobre `boolean`: a JVMS 8 **lista `boolean` entre os tipos da JVM** (§2.3.4). O que ele não tem é representação própria em runtime — é tratado como `int`, e arrays de `boolean` usam `baload`/`bastore`, como os de `byte`.

*Arquivos afetados:* [00-SIMULADO.md](00-SIMULADO.md) Q36; [SB_Prova_Java.md](SB_Prova_Java.md) Q9; [java-jvm8-3-3.md](java-jvm8-3-3.md) §byte/char/short.

---

## 3. Divergências do material da linguagem (IBM = Java 1.4)

O PDF da IBM foi escrito para **Java 1.4** — antes do Java 5. Tudo abaixo **já valia no Java 8** e contradiz o slide.

| Tema | O slide diz (Java 1.4) | No Java 8 | Desde |
|---|---|---|:---:|
| **Coleções** | Guardam `Object`; `it.next()` exige *cast* | **Generics**: `List<Integer> l` e `l.get(0)` já vem tipado | Java 5 |
| **Wrappers** | `lista.add(new Integer(5))` é obrigatório | **Autoboxing**: `lista.add(5)` compila | Java 5 |
| **Percorrer coleção** | `Iterator` + `while (it.hasNext())` | **`for` estendido**: `for (Integer i : lista)` | Java 5 |
| **`switch`** | Só `byte`, `short`, `char`, `int` | Também **`enum`** (Java 5) e **`String`** (Java 7) | 5 / 7 |
| **Parâmetros variáveis** | Não existe | **varargs**: `void f(int... x)` | Java 5 |
| **Tipos enumerados** | Constantes `static final int` | **`enum`** é um tipo de primeira classe | Java 5 |
| **Exceções** | Só `try/catch/finally` com um tipo por `catch` | ***try-with-resources*** e ***multi-catch*** (`catch (A \| B e)`) | Java 7 |
| **Concorrência** | `Thread`, `synchronized`, `wait()`/`notify()` | `java.util.concurrent`: `ExecutorService`, `Lock`, `AtomicInteger`, `ConcurrentHashMap` | Java 5 |
| **`new Integer(5)`** | Forma normal | Continua compilando no 8, mas `Integer.valueOf(5)` é o recomendado (usa cache −128..127) | Java 5 |
| **Interfaces** | Só métodos abstratos | Métodos **`default`** e **`static`** | Java 8 |

> Nada disso torna o slide *inválido* para a prova — a semântica de `Iterator`, `synchronized` e `try/catch` continua correta. O que mudou foi a **sintaxe disponível**, não o modelo.

### Erros de código do próprio PDF da IBM
Estes não são questão de versão — são erros que não compilam em **nenhuma** versão:

| Slide | Está escrito | Correto |
|---|---|---|
| 52 | `short c = (short) b1 + b2;` | `short c = (short)(b1 + b2);` — o *cast* liga mais forte que o `+` |
| 53 | `Char` | `Character` |
| 97 | `float x1 = 15.5;` | `float x1 = 15.5f;` — literal decimal é `double` |
| 98 | `v.inicializa()` | `v.inicia()` — o método declarado tem outro nome |
| 48 | `boolean` = 8 bits | A JVMS **não define** o tamanho de `boolean` |

---

## 4. Conteúdo posterior ao Java 8 citado nos resumos

Aparece nos resumos como contexto. **Não cai nesta prova** — está aqui para você reconhecer e descartar.

| Assunto | Versão | Onde aparece |
|---|:---:|---|
| Métodos `private` em interface | Java 9 | [java-conceitos.md](java-conceitos.md) §interfaces |
| Módulos (`module-info`), tags 19/20 do pool | Java 9 | — |
| `CONSTANT_Dynamic` (tag **17**) | Java 11 | [formato-class.md](formato-class.md) §tags — em Java 8 a tag 17 **não existe** |
| *Nestmates* (`NestHost`/`NestMembers`) | Java 11 | — |
| *Records* | Java 16 | — |
| *Sealed classes* | Java 17 | — |
| Ponto flutuante **sempre** estrito (fim do `strictfp`, JEP 306) | Java 17 | [java-jvm8-1-3.md](java-jvm8-1-3.md) §IEEE 754 — **em Java 8 a distinção FP-strict × non-FP-strict ainda vale** |
| Concatenação de String via `invokedynamic` (JEP 280) | Java 9 | Em Java 8, `a + b` compila para **`StringBuilder`** |

---

## 5. Divergências com a especificação, independentes de versão

Valem para o Java 8 e para qualquer outra versão.

| # | O material diz | A especificação diz |
|:---:|---|---|
| 1 | Slots de **32 bits** no vetor de variáveis locais e na pilha de operandos | A JVMS **não define o tamanho** do slot. O que ela define é que `long`/`double` ocupam **2 slots** e os demais, 1 |
| 2 | O frame **contém** o pool de constantes | O frame contém uma **referência** ao pool de constantes de runtime, que vive na **área de métodos** |
| 3 | `UnsupportedClassVersionError` = "versão **antiga** do `.class`" | É lançado quando a versão é **mais nova** do que a JVM suporta |
| 4 | Na ausência de manipulador, o programa encerra | A exceção é **repropagada ao invocador**, frame a frame. Só a **thread** morre ao fim |
| 5 | Interface "não pode ter métodos concretos" e classe abstrata "tem ao menos um método abstrato" | Ver §2.1 e §2.4 |
| 6 | `SourceFile` é atributo obrigatório (slide 43, contra o 45) | É **opcional** |
| 7 | `CONSTANT_Class_info.name_index` = `Ljava/lang/Thread;` | Guarda o **nome interno** `java/lang/Thread`, sem `L` e sem `;` |
| 8 | `class_index` aponta para um `CONSTANT_Utf8_info` | Aponta para um **`CONSTANT_Class_info`** |
| 9 | `jsr`/`ret` como parte normal do conjunto | **Proibidas** em `major_version ≥ 51` — ou seja, **não podem aparecer** num `.class` de Java 8. O tipo `returnAddress` continua na especificação |
| 10 | `istore_<n>` com pilha e variável invertidas (errata do slide 51) | `istore_<n>` **desempilha** e grava na variável local `n` |

---

## 6. Resumo em uma tabela

| Se a questão for sobre… | Responda… |
|---|---|
| Atributos **de instância** em interface | **F** — nunca existiram, em nenhuma versão |
| Métodos **concretos** em interface | Pelo slide (**não pode**), citando `default`/`static` do Java 8 na justificativa |
| Classe abstrata precisar de método abstrato | **F** — basta o modificador `abstract` |
| Instruções específicas para `byte`/`char`/`short`/`boolean` | Depende da palavra "aritméticas" — ver §2.5 |
| Onde fica o pool de constantes | **Área de métodos**; o frame só tem a **referência** |
| Área de métodos ser PermGen | É implementação; no Java 8 é **Metaspace**. A resposta conceitual é a da especificação |
| Tamanho do slot | Não é definido; o que vale é **2 slots para `long`/`double`** |
| Exceção sem manipulador | **Propaga** pela pilha de frames; não encerra o programa de imediato |
