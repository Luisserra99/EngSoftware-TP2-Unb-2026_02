# Simulado — Prova-J (JVM e Java) — CIC0104 Software Básico

Baseado na estrutura e no conteúdo de `SB_Prova_Java.docx.pdf`.

**Formato original da prova (siga-o aqui também):**
- Questões objetivas: responda **V** (verdade), **F** (falso) ou **NS** (não sei).
- **Duas respostas erradas anulam uma certa.** Resposta em branco conta como errada. Por isso, o **NS** existe: se você não sabe, marcar NS é melhor do que chutar.
- **Justifique toda questão respondida como F** — a justificativa vale nota.
- Objetivas: 0,4 cada. Discursivas: 0,8 cada.

> ⚠️ **Antes de usar o gabarito:** em três questões o gabarito deste simulado segue a especificação oficial (JVMS/JLS) e **diverge da resposta que a prova anterior tratou como correta** — questões **28** (`<clinit>` é sempre o primeiro código executado), **36** (não há instruções específicas para boolean/byte/char/short) e **41** (`static` aplicado a classe). A seção "Divergências" do [README.md](README.md) e o documento [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md) explicam os dois lados de cada uma e recomendam o que responder na prova. Leia antes de decidir que errou.
>
> **Baseline do gabarito:** **Java SE 8** (JLS 8 / JVMS 8, `major_version = 52`). As anotações 🟦 (divergência Java 8), 🟪 (posterior ao Java 8) e 🟥 (divergência com a especificação) marcam onde o slide da disciplina discorda.

**Como usar este simulado:** responda a Parte I e a Parte II *sem olhar o gabarito*. Só depois vá para a Parte III. O gabarito traz não só a resposta, mas a justificativa que você deveria ter escrito.

---

## Parte I — Questões objetivas (V / F / NS) — 40 questões

### Formato do arquivo `.class`

1. Um arquivo `.class` é um arquivo binário contendo a definição de uma única classe ou interface, com itens multibyte armazenados em *big-endian order* e sem bytes de alinhamento.

2. Todo arquivo `.class` começa com o número mágico `0xCAFEBABE`, seguido de `minor_version` e depois `major_version`, nessa ordem.

3. O índice 0 do pool de constantes é uma entrada válida, do tipo `CONSTANT_Utf8_info`, usada para representar a string vazia.

4. O campo `super_class` de um arquivo `.class` sempre contém um índice válido para uma entrada no pool de constantes que representa a superclasse da classe descrita no arquivo.

5. Uma entrada `CONSTANT_Methodref_info` no pool de constantes aponta para um `CONSTANT_Class_info` e para um `CONSTANT_NameAndType_info`.

6. Cada entrada na tabela de métodos (`method_info`) de um `.class` contém uma descrição completa do método, incluindo obrigatoriamente as instruções da JVM que o implementam.

7. As entradas `CONSTANT_Long_info` e `CONSTANT_Double_info` ocupam duas posições consecutivas no pool de constantes.

8. O atributo `Code` é obrigatório em todo `method_info`.

9. Se um `field_info` contém um atributo `ConstantValue` associado a uma variável **não estática**, a JVM deve ignorá-lo silenciosamente.

10. O descritor `([[Ljava/lang/String;IJ)Z` corresponde a um método que recebe um array bidimensional de String, um `int` e um `long`, e retorna `boolean`.

11. No descritor de um método, o código `J` representa `long` e o código `Z` representa `boolean`.

12. O nome de um construtor no arquivo `.class` é o próprio nome da classe, igual ao código-fonte Java.

13. A JVM é obrigada a rejeitar um arquivo `.class` cujo `major_version` seja maior do que a versão que ela suporta.

14. Atributos desconhecidos encontrados em um arquivo `.class` devem fazer a JVM lançar `ClassFormatError`.

### Áreas de dados em tempo de execução

15. Os tipos de dados utilizados na JVM são exatamente os definidos na linguagem Java.

16. A JVM aloca um frame na pilha de frames contendo a pilha de operandos, o vetor de variáveis locais e **o pool de constantes** da classe do método que será executado.

17. Cada thread possui seu próprio registrador PC e sua própria pilha de frames, mas o heap e a área de métodos são compartilhados entre todas as threads.

18. O vetor de variáveis locais contém os parâmetros e as variáveis locais do método, sendo que o primeiro parâmetro é sempre armazenado no índice zero.

19. Valores do tipo `long` e `double` ocupam dois slots consecutivos no vetor de variáveis locais e duas posições na pilha de operandos.

20. Todo bytecode que for executado na máquina virtual utiliza a pilha de operandos.

21. A área de métodos armazena o pool de constantes de runtime, os objetos, os atributos de classe e de instância, o código dos métodos e dos construtores, separados por classe.

22. Objetos e arrays são alocados no heap; apenas as referências a eles ficam no vetor de variáveis locais ou na pilha de operandos.

23. A pilha de métodos nativos é usada para suportar a execução de métodos não-Java e tem a mesma estrutura da pilha de frames, apenas sem o pool de constantes.

24. Apenas um frame está ativo por vez em uma thread — o frame do método em execução — e é o único que pode ser manipulado pelas instruções.

25. O registrador PC de uma thread que executa um método nativo tem valor indefinido.

26. Arrays são alocados em memória estática (isto é, durante a compilação) através do comando `new` em Java.

### Iniciação, carga de classes e execução

27. A iniciação da máquina virtual começa com a carga de uma classe contendo o método `main`, ao qual é passado um array de strings com os parâmetros da linha de comando; `main` deve ser declarado `public static void`.

28. Se existir, o primeiro código a ser executado é sempre o do método `<clinit>`.

29. O método `<clinit>` é gerado pelo compilador a partir dos blocos `static` e da iniciação de variáveis estáticas, e é executado **uma única vez** por classe.

30. O `<clinit>` da superclasse é executado antes do `<clinit>` da subclasse.

31. Dentro de `<init>`, a sequência é: chamada ao `<init>` da superclasse, depois os blocos de iniciação de instância e iniciadores de campos, e só então o corpo do construtor.

32. A ligação (*linking*) de uma classe compreende verificação, preparação e, opcionalmente, resolução; a preparação atribui às variáveis estáticas os seus valores default.

33. Na ocorrência de uma exceção, a JVM busca o manipulador no método corrente; se não encontrar, o método corrente é encerrado abruptamente e a execução do programa é encerrada.

34. A tabela de exceções do atributo `Code` associa uma faixa de bytecodes `[start_pc, end_pc)` a um `handler_pc` e a um tipo de exceção capturada.

35. `invokestatic` não empilha `this` como primeiro argumento, ao contrário de `invokevirtual` e `invokespecial`.

36. Não há instruções da JVM específicas para os tipos `boolean`, `byte`, `char` e `short` nas operações aritméticas — esses valores são tratados como `int`.

### Linguagem Java — orientação a objetos

37. Classe abstrata é aquela em que **todos** os seus métodos são abstratos; ela não pode ser instanciada.

38. Interfaces podem ser utilizadas para simular herança múltipla em Java, com uma classe herdando métodos e **atributos de instância** de diversas interfaces.

39. Toda classe em Java tem um ou mais métodos construtores, exceto a classe `Object`.

40. A declaração `public final int tamanhoMaximo = 15;` define um atributo de classe.

41. O modificador `static` pode ser aplicado a classe, variável e método.

42. Seja a hierarquia: `Gato` e `Onca` estendem `Felinos`, que estende `Animal`. Os métodos que podem ser chamados em `Gato` são necessariamente os mesmos que podem ser chamados em `Onca`.

43. Um método `private` não pode ser sobrescrito (*override*) por uma subclasse.

44. Por ter porte para diversos ambientes (JavaCard, Java ME, etc.), a linguagem Java é adequada para controle de plantas industriais em sistemas de tempo real com requisitos de resposta determinísticos.

---

## Parte II — Questões discursivas

**D1.** Qual é o protótipo do método `pandemia` que tem a assinatura abaixo?
```
([FIZZ[[[BIS[CIDZLupa_tem_covid_19;Ljava/lang/String;)V
```

**D2.** Descreva as operações realizadas nas estruturas de runtime para retornar um `long` ao método chamador quando o método chamado termina normalmente.

**D3.** Considere o pseudocódigo abaixo e informe a sequência de números impressa (formato `1234567`, sem espaços).
```java
class Uuupa extends Opa {
    static { "imprime 1" }
    { "imprime 2" }
    public Uuupa() { "imprime 3" }
    public static void main(String[] args) {
        "imprime 4";
        Uuupa f = new Uuupa();
    }
}
class Opa {
    static { "imprime 5" }
    { "imprime 6" }
    Opa() { "imprime 7"; }
}
```

**D4.** Seja `B` um vetor de `short`. Descreva e justifique todos os passos para a execução, pela JVM, do comando:
```java
B[2] = (short)(B[2] - 128);
```

**D5.** Escreva o descritor JVM do método `public static double[] calcula(String nome, char[][] grade, long id)`.

**D6.** Explique a diferença entre a **área de métodos** e o **heap**, e diga onde fica cada um destes: o código do método `soma()`, o objeto criado por `new Pessoa()`, o campo `static int contador`, o campo de instância `int idade`.

**D7.** Dado o trecho abaixo, mostre o bytecode gerado e o estado da pilha de operandos a cada instrução.
```java
int f(int a, int b) { return a * b + 3; }
```

**D8.** Explique, passo a passo, o que a JVM faz quando encontra uma exceção que não é tratada em nenhum método da pilha de chamadas.

---
---

## Parte III — GABARITO COMENTADO

> Leia só depois de responder.

### Parte I

| # | Resp. | Tema |
|---|:---:|---|
| 1 | **V** | formato .class |
| 2 | **V** | formato .class |
| 3 | **F** | pool de constantes |
| 4 | **F** | super_class |
| 5 | **V** | pool de constantes |
| 6 | **F** | method_info |
| 7 | **V** | pool de constantes |
| 8 | **F** | atributo Code |
| 9 | **V** | ConstantValue |
| 10 | **V** | descritores |
| 11 | **V** | descritores |
| 12 | **F** | `<init>` |
| 13 | **V** | versionamento |
| 14 | **F** | atributos |
| 15 | **F** | tipos da JVM |
| 16 | **F** | frame |
| 17 | **V** | áreas de runtime |
| 18 | **F** | variáveis locais |
| 19 | **V** | slots |
| 20 | **F** | pilha de operandos |
| 21 | **F** | área de métodos |
| 22 | **V** | heap |
| 23 | **F** | pilha nativa |
| 24 | **V** | frame corrente |
| 25 | **V** | registrador PC |
| 26 | **F** | alocação de arrays |
| 27 | **V** | iniciação da JVM |
| 28 | **F** | `<clinit>` |
| 29 | **V** | `<clinit>` |
| 30 | **V** | ordem de iniciação |
| 31 | **V** | `<init>` |
| 32 | **V** | linking |
| 33 | **F** | exceções |
| 34 | **V** | tabela de exceções |
| 35 | **V** | invocação |
| 36 | **V** | conjunto de instruções |
| 37 | **F** | classe abstrata |
| 38 | **F** | interfaces |
| 39 | **F** | construtores |
| 40 | **F** | atributo de classe x instância |
| 41 | **F** | static |
| 42 | **F** | herança |
| 43 | **V** | override |
| 44 | **F** | Java em tempo real |

---

#### 1 — **V**
O `.class` é binário, define **uma** classe ou interface, é *big-endian* e a especificação não prevê bytes de preenchimento: as estruturas são lidas sequencialmente, byte a byte.

> Cuidado com a variante que apareceu na prova real, que dizia "uma única classe **pública** ou interface". Essa versão é **F**: o arquivo `.class` descreve uma classe ou interface qualquer (uma classe *package-private*, por exemplo, também gera seu próprio `.class`). O que vale é "uma única classe **ou** interface", não "pública".

#### 2 — **V**
Ordem: `magic` (`0xCAFEBABE`, 4 bytes) → `minor_version` (2 bytes) → `major_version` (2 bytes) → `constant_pool_count`… O `minor` vem **antes** do `major`; trocar a ordem é pegadinha clássica.

#### 3 — **F**
**Justificativa:** o pool de constantes é indexado de **1 a `constant_pool_count - 1`**. O índice **0 é inválido** e é usado apenas como "nenhuma entrada" em alguns campos (por exemplo, `super_class == 0` na classe `Object`).

#### 4 — **F**
**Justificativa:** *quase sempre*, mas não **sempre**. Para a classe `java.lang.Object`, `super_class` vale **0**, porque `Object` não tem superclasse. Logo, a palavra "sempre" torna a afirmação falsa.

> Na prova real, o aluno respondeu F com a justificativa "o campo se chama `super_class`, não `super`". Essa justificativa é fraca/errada em espírito: o motivo real da falsidade é o caso `Object`.

#### 5 — **V**
`CONSTANT_Methodref_info { tag; class_index; name_and_type_index; }` — o `class_index` aponta para um `CONSTANT_Class_info` e o `name_and_type_index` para um `CONSTANT_NameAndType_info` (que por sua vez aponta para dois `CONSTANT_Utf8_info`: nome e descritor).

#### 6 — **F**
**Justificativa:** o `method_info` contém nome, descritor, flags e atributos — mas o atributo `Code` (que carrega as instruções) **não existe** para métodos **abstratos** nem **nativos** (`native`). Portanto a descrição nem sempre inclui as instruções da JVM.

#### 7 — **V**
Por herança histórica do projeto original da JVM, `CONSTANT_Long_info` e `CONSTANT_Double_info` consomem duas entradas: se ocupam o índice `n`, o índice `n+1` é inutilizável. A própria especificação chama isso de "uma decisão pobre em retrospecto".

#### 8 — **F**
**Justificativa:** ver questão 6 — métodos `abstract` e `native` **não** têm atributo `Code`. E, reciprocamente, um método não-abstrato e não-nativo **deve** tê-lo (exatamente um).

#### 9 — **V**
A regra da JVMS: se o campo é `static`, o valor de `ConstantValue` é atribuído na fase de **preparação**. Se o campo **não** é `static`, a JVM **ignora o atributo silenciosamente** (não lança erro).

> Isto é o inverso do que dizia a questão 11 da prova real (que falava em variável estática) — e por isso aquela era **F**. Preste atenção em qual dos dois casos o enunciado está tratando.

#### 10 — **V**
Decompondo `([[Ljava/lang/String;IJ)Z`:
| Token | Significado |
|---|---|
| `[[Ljava/lang/String;` | `String[][]` |
| `I` | `int` |
| `J` | `long` |
| `)Z` | retorna `boolean` |

#### 11 — **V**
Tabela completa dos códigos de descritor:
| Código | Tipo | | Código | Tipo |
|---|---|---|---|---|
| `B` | byte | | `J` | **long** |
| `C` | char | | `S` | short |
| `D` | double | | `Z` | **boolean** |
| `F` | float | | `V` | void (só retorno) |
| `I` | int | | `L<classe>;` | referência |
| | | | `[` | array (prefixo, uma dimensão) |

`J` é long porque `L` já estava tomado por referências; `Z` é boolean porque `B` já era byte.

#### 12 — **F**
**Justificativa:** no arquivo `.class` o construtor recebe o nome especial **`<init>`**, e o inicializador estático da classe recebe o nome **`<clinit>`**. Os sinais `<` e `>` garantem que esses nomes nunca colidam com identificadores válidos de Java.

#### 13 — **V**
Uma JVM que suporta até a versão *V* deve rejeitar (com `UnsupportedClassVersionError`) arquivos com `major_version` superior — é o que garante a compatibilidade "para frente" controlada.

#### 14 — **F**
**Justificativa:** é exatamente o contrário. A JVM deve **ignorar silenciosamente** atributos que não reconhece. Isso é o que permite que novos atributos (anotações, genéricos, `StackMapTable`…) sejam adicionados sem quebrar JVMs antigas.

#### 15 — **F**
**Justificativa:** os conjuntos não coincidem. A JVM tem o tipo **`returnAddress`**, que não existe na linguagem Java. E, na prática das instruções, `boolean`, `byte`, `char` e `short` **não têm representação própria** nas operações: são manipulados como `int`. Os tipos da JVM são: numéricos (`byte`, `short`, `int`, `long`, `char`, `float`, `double`), `boolean`, `returnAddress` e os tipos de referência (classe, array, interface).

#### 16 — **F**
**Justificativa:** o frame contém a pilha de operandos, o vetor de variáveis locais e uma **referência** (ponteiro) para o pool de constantes de runtime da classe do método — o pool **em si** mora na **área de métodos** e é compartilhado, não copiado para dentro de cada frame. Copiar o pool a cada chamada seria proibitivo.

> Mais duas imprecisões na mesma frase: a pilha de operandos tem `max_stack` **entradas** e o vetor tem `max_locals` **slots**; falar em "slots de 32 bits" é uma simplificação — `long` e `double` usam dois slots, e a especificação não fixa o tamanho físico do slot.

#### 17 — **V**
- **Por thread:** registrador PC, pilha de frames (JVM stack), pilha de métodos nativos.
- **Compartilhados:** heap e área de métodos (incluindo o pool de constantes de runtime).

#### 18 — **F**
**Justificativa:** em um método **de instância**, o índice **0 do vetor de variáveis locais contém a referência `this`**; o primeiro parâmetro declarado vai para o índice 1. Só em métodos `static` é que o primeiro parâmetro ocupa o índice 0. Logo, "sempre" é falso.

> ⚠️ A justificativa dada na prova real — "os parâmetros têm sua própria stack, a stack de parâmetros" — está **errada**. Não existe "pilha de parâmetros" na JVM. Os parâmetros são de fato copiados para o vetor de variáveis locais; o erro do enunciado está só no índice.

#### 19 — **V**
`long` e `double` são os tipos de 64 bits: consomem dois slots consecutivos (`n` e `n+1`, endereçados pelo índice `n`) e duas unidades da pilha de operandos. É por isso que `max_locals` pode ser maior que o número de variáveis declaradas.

#### 20 — **F**
**Justificativa:** várias instruções não tocam a pilha de operandos. Exemplos: `goto` (desvio incondicional), `nop`, `iinc` (incrementa uma variável local **diretamente** no vetor de variáveis locais, sem empilhar/desempilhar), `ret`, `wide`. O `iinc` é o exemplo canônico e é por isso que `for (i=0; i<n; i++)` é eficiente.

#### 21 — **F**
**Justificativa:** a área de métodos guarda as informações **por classe**: pool de constantes de runtime, código dos métodos e construtores, e os **campos estáticos** (atributos de classe). Ela **não** armazena **objetos** nem **atributos de instância** — esses ficam no **heap**, dentro de cada objeto.

#### 22 — **V**
Todo objeto e todo array vivem no heap, que é compartilhado e gerenciado pelo coletor de lixo. O que aparece nas variáveis locais e na pilha de operandos é sempre uma **referência** (tipo `reference`), nunca o objeto em si — Java não tem objetos alocados na pilha no nível do modelo da JVM.

#### 23 — **F**
**Justificativa:** a pilha de métodos nativos (quando existe — ela é **opcional**) é uma pilha **convencional em C/assembly**, no formato da plataforma hospedeira. Ela **não** tem a estrutura de frames da JVM (pilha de operandos + variáveis locais + referência ao pool). Algumas implementações sequer a fornecem.

#### 24 — **V**
Só o **frame corrente** (o do método em execução na thread) é ativo. As instruções que manipulam variáveis locais e a pilha de operandos operam exclusivamente sobre ele. Os demais frames estão suspensos, aguardando o retorno.

#### 25 — **V**
Se o método sendo executado pela thread é `native`, o valor do registrador PC é **undefined**, já que o código nativo não é endereçado por bytecodes. Para métodos Java, o PC contém o endereço da instrução em execução.

#### 26 — **F**
**Justificativa:** duas coisas erradas. Arrays em Java são criados com `new` (ou `newarray`/`anewarray`/`multianewarray` em bytecode) em **tempo de execução**, e são alocados **no heap**, dinamicamente — nunca em memória estática nem em tempo de compilação. O próprio uso de `new` já denuncia alocação dinâmica.

#### 27 — **V**
A JVM inicia carregando, ligando e iniciando uma classe inicial; depois invoca seu método `main`, cuja assinatura obrigatória é `public static void main(String[] args)`, recebendo os argumentos da linha de comando como `String[]`.

#### 28 — **F**
**Justificativa:** o `<clinit>` da classe inicial só roda depois que a classe é **carregada e ligada** (verificação e preparação). E, em uma hierarquia, o `<clinit>` da **superclasse** roda antes do da subclasse — então "sempre o primeiro" é falso. Além disso, uma classe pode simplesmente não ter `<clinit>` (o enunciado se protege com "se existir", mas ainda assim a ordem entre `<clinit>`s e as fases de carga quebra o "sempre").

#### 29 — **V**
O compilador reúne todos os blocos `static { }` e as iniciações de variáveis estáticas, **na ordem textual em que aparecem**, dentro de um único método `<clinit>`. A JVM garante que ele execute **no máximo uma vez** por classe e de forma *thread-safe* (por isso o idiom do *holder* para singletons).

#### 30 — **V**
A iniciação de uma classe exige que sua superclasse já tenha sido iniciada. Daí a cadeia: `<clinit>` de `Object` → … → `<clinit>` da superclasse direta → `<clinit>` da classe.

#### 31 — **V**
O `<init>` gerado pelo compilador tem esta ordem fixa:
1. `invokespecial` para o `<init>` da superclasse (ou para outro `<init>` da mesma classe, se o construtor começa com `this(...)`);
2. blocos de iniciação de instância `{ }` e iniciadores de campos de instância, na ordem textual;
3. o corpo do construtor.

#### 32 — **V**
- **Carga:** encontra a representação binária e cria a classe na área de métodos.
- **Ligação:** *verificação* (o `.class` é bem-formado e seguro), *preparação* (aloca os campos estáticos e atribui **valores default** — `0`, `0.0`, `false`, `null`; **ainda não** os valores do código-fonte), *resolução* (transforma referências simbólicas do pool em referências diretas — pode ser preguiçosa).
- **Iniciação:** executa `<clinit>`, aí sim atribuindo os valores escritos no fonte.

#### 33 — **F**
**Justificativa:** o erro está no final. Se o manipulador não é encontrado no método corrente, o frame corrente é descartado e a exceção é **relançada no método chamador** — a busca **continua propagando pela pilha de frames**. Só quando a pilha da thread se esgota sem nenhum manipulador é que a thread é encerrada (e o programa termina se for a última thread não-daemon). O programa **não** encerra ao primeiro método que não trata a exceção.

#### 34 — **V**
Cada entrada da `exception_table` do atributo `Code` tem `start_pc`, `end_pc`, `handler_pc` e `catch_type` (índice no pool para um `CONSTANT_Class_info`, ou **0** para significar "qualquer exceção" — usado por `finally`). A faixa protegida é **`[start_pc, end_pc)`**: inclusiva no início, exclusiva no fim.

#### 35 — **V**
- `invokestatic`: não há `this`; o primeiro argumento está na posição mais baixa.
- `invokevirtual` / `invokespecial` / `invokeinterface`: a `objectref` (`this`) é empilhada **antes** dos argumentos e vai para o índice 0 das variáveis locais do novo frame.
- `invokevirtual` faz despacho dinâmico pelo tipo real; `invokespecial` não (usado para `<init>`, `private` e chamadas via `super`).

#### 36 — **V**
A JVM não tem `badd`, `sadd`, `cadd`, `zadd`. Valores de `boolean`, `byte`, `char` e `short` são **estendidos para `int`** ao serem carregados e operados com as instruções `i*`. Existem apenas instruções especializadas para **carga/armazenamento em arrays** (`baload`/`bastore`, `caload`/`castore`, `saload`/`sastore`) e para **conversão de volta** (`i2b`, `i2c`, `i2s`). Daí o `(short)` do cast ser compilado como `i2s`.

> 🟥 **Atenção à redação.** Esta questão diz **"nas operações aritméticas"** de propósito — com essa
> restrição, a resposta é **V**. O enunciado da **Q9 da prova real** omite "aritméticas" e diz apenas
> *"não há instruções JVM específicas"*; nessa forma ampla a resposta vira **F**, porque existem
> `baload`/`bastore`, `caload`/`castore`, `saload`/`sastore`, `i2b`/`i2c`/`i2s`, `bipush`/`sipush` e
> `newarray` com `atype` 4/5/8/9. A JVMS 8 §2.11.1 fala em **"suporte limitado"** — o que sustenta a
> leitura restrita. Decisivo: a **discursiva 4 da própria prova** usa `saload`/`sastore`/`i2s`.
> Ver [DIVERGENCIAS-JAVA8.md §2.5](DIVERGENCIAS-JAVA8.md#25--não-há-instruções-específicas-para-boolean-byte-char-e-short).

#### 37 — **F**
**Justificativa:** basta **um** método abstrato para a classe ter de ser declarada `abstract`. Uma classe abstrata pode inclusive ter **zero** métodos abstratos — declarar `abstract` já basta para impedir a instanciação. O correto da afirmação é só a segunda parte: classe abstrata não pode ser instanciada.

> 🟥 **Divergência com o slide.** O **slide 121 do `IBM-JavaBasico.pdf`** afirma que toda classe
> abstrata tem ao menos um método abstrato — o que é **falso pela JLS §8.1.1.1 em qualquer versão**,
> inclusive no Java 8. Se o gabarito oficial seguir o slide, apresente `abstract class C { }` como
> contraexemplo. Cuidado com o erro do aluno na prova anterior: ele respondeu F, mas justificou
> *"basta um método ser abstrato"* — **nenhum** precisa ser.

#### 38 — **F**
**Justificativa:** interfaces **não têm atributos de instância**. Todo campo declarado em uma interface é implicitamente `public static final` — ou seja, constante de classe. Uma classe pode implementar várias interfaces (e isso de fato simula herança múltipla **de tipo/assinatura**, e desde o Java 8 de **implementação** via métodos `default`), mas **nunca** herda estado de instância de múltiplas fontes. É justamente assim que Java evita o "problema do diamante".

#### 39 — **F**
**Justificativa:** invertido. A classe `Object` **tem** construtor — `public Object()` — e ele é chamado no topo de toda cadeia de `<init>`. A afirmação correta é: toda classe tem ao menos um construtor, **inclusive** `Object`; se o programador não declara nenhum, o compilador gera o construtor default sem argumentos.

#### 40 — **F**
**Justificativa:** sem `static`, é um **atributo de instância** (cada objeto tem sua própria cópia), não um atributo de classe. `final` apenas impede a reatribuição depois de iniciado. Para ser atributo de classe seria preciso `public static final int tamanhoMaximo = 15;`.

> 🟦 **Divergência Java 8 — leia com cuidado qual metade da frase é falsa.** O que torna esta
> questão **F** é **"atributos de instância"**, e isso vale em **todas** as versões. Mas a parte
> "herdando métodos de diversas interfaces" **passou a ser verdadeira no Java 8**, por causa dos
> métodos **`default`**. Se um enunciado falar só em *métodos*, a resposta muda para **V** no Java 8;
> se falar em *atributos de instância* ou *estado*, continua **F**. Métodos `private` em interface só
> vieram no **Java 9** (🟪 fora desta prova).

#### 41 — **F**
**Justificativa:** `static` **não** pode ser aplicado a uma classe **de topo** (*top-level*). Ele se aplica a variáveis, métodos, blocos de iniciação e a **classes aninhadas** (*nested*), mas não a uma classe declarada diretamente em um arquivo. Como o enunciado diz "classe" sem qualificar, é falso.

> ⚠️ **Divergência com o gabarito da prova real.** A **Q21 da prova anterior** tem o mesmo enunciado
> e foi tratada como **V**, pelo argumento de que **classes aninhadas aceitam `static`**. Os dois
> lados são defensáveis: o simulado responde F porque o enunciado não qualifica "classe" (e classe de
> topo não aceita); a prova responde V porque existe *uma* espécie de classe que aceita. A tabela
> "Todos os Modificadores" do slide 88 do IBM diz **não**. **Recomendação:** responda **V** se o
> enunciado vier da prova do professor; em qualquer caso, escreva na justificativa que *classe de
> topo não aceita `static`, mas classe aninhada aceita* — isso cobre as duas leituras.

#### 42 — **F**
**Justificativa:** `Gato` e `Onca` herdam o mesmo conjunto de `Felinos`/`Animal`/`Object`, mas cada uma pode **declarar métodos próprios**. Um método `cacarMiar()` definido só em `Gato` não existe em `Onca`. Os conjuntos têm a mesma **base**, mas não são iguais.

#### 43 — **V**
Métodos `private` não são visíveis às subclasses, portanto não são herdados e não podem ser sobrescritos. Um método de mesma assinatura na subclasse é um método **novo**, sem relação polimórfica. Isso combina com o fato de o compilador usar `invokespecial` (despacho estático) para chamadas a métodos `private`. O mesmo vale para métodos `static` (que sofrem *hiding*, não *override*) e `final` (proibidos de sobrescrever).

#### 44 — **F**
**Justificativa:** o problema não é a portabilidade — é o **não-determinismo temporal**. O **coletor de lixo** pode interromper a aplicação em momentos imprevisíveis, a compilação **JIT** introduz variação no tempo de execução do mesmo código e a JVM padrão não garante escalonamento de tempo real. Por isso existe a especificação separada **RTSJ (Real-Time Specification for Java, JSR-1)** e JVMs de tempo real — o Java padrão, mesmo em Java ME ou JavaCard, **não** dá garantias determinísticas de tempo de resposta.

---

### Parte II — respostas modelo

#### D1 — Protótipo de `pandemia`

Decodificando `([FIZZ[[[BIS[CIDZLupa_tem_covid_19;Ljava/lang/String;)V` **da esquerda para a direita**, um token por vez:

| # | Token | Tipo Java |
|---|---|---|
| 1 | `[F` | `float[]` |
| 2 | `I` | `int` |
| 3 | `Z` | `boolean` |
| 4 | `Z` | `boolean` |
| 5 | `[[[B` | `byte[][][]` |
| 6 | `I` | `int` |
| 7 | `S` | `short` |
| 8 | `[C` | `char[]` |
| 9 | `I` | `int` |
| 10 | `D` | `double` |
| 11 | `Z` | `boolean` |
| 12 | `Lupa_tem_covid_19;` | `upa_tem_covid_19` (tipo de referência) |
| 13 | `Ljava/lang/String;` | `String` |
| — | `)V` | retorno `void` |

**Protótipo:**
```java
void pandemia(float[] a, int b, boolean c, boolean d, byte[][][] e, int f,
              short g, char[] h, int i, double j, boolean k,
              upa_tem_covid_19 l, String m);
```

**Cuidados:** o tipo Java é `boolean` (não `bool`) e `String` (com S maiúsculo — é uma classe). Os nomes dos parâmetros são livres: o descritor **não** guarda nomes, só tipos. Um `[` sempre se aplica ao token **seguinte**, por isso `[[[B` é um array de três dimensões de `byte`, e um `L...;` só termina no `;`.

#### D2 — Retorno de um `long` ao método chamador

1. O método chamado executa uma instrução **`lreturn`**.
2. O valor `long` é **retirado do topo da pilha de operandos do frame corrente** (ocupando duas posições). *Não* é lido do vetor de variáveis locais — se o valor estava em uma variável local, o compilador já emitiu um `lload` para empilhá-lo antes do `lreturn`.
3. Se o método é `synchronized`, o monitor é liberado.
4. Todos os demais valores da pilha de operandos do frame corrente são **descartados**.
5. O **frame corrente é desempilhado** da pilha de frames da thread, liberando sua pilha de operandos e seu vetor de variáveis locais.
6. O frame do **chamador volta a ser o frame corrente**; o registrador PC é restaurado para a instrução **seguinte** à instrução de invocação.
7. O valor `long` é **empilhado na pilha de operandos do frame do chamador** (ocupando duas posições).
8. Cabe ao chamador decidir o que fazer com ele: um `lstore_n` para guardá-lo em uma variável local, ou usá-lo direto em outra operação; se o retorno é ignorado, o compilador emite `pop2`.

> ⚠️ O erro típico (e o que aparece na prova real) é dizer que o valor "está na array de variáveis locais" e vai para "a array de variáveis locais do chamador". A transferência de retorno acontece **de pilha de operandos para pilha de operandos**. O vetor de variáveis locais só entra em cena se houver um `lstore` explícito depois.

#### D3 — Sequência impressa: **`5146723`**

A resposta está correta. O raciocínio:

| Ordem | Saída | Por quê |
|:---:|:---:|---|
| 1 | **5** | Iniciar `Uuupa` exige iniciar antes a superclasse `Opa` → `<clinit>` de `Opa` (bloco `static`). |
| 2 | **1** | `<clinit>` de `Uuupa` (bloco `static`). |
| 3 | **4** | `main` começa a executar. |
| 4 | **6** | `new Uuupa()` → `<init>` de `Uuupa` chama primeiro `<init>` de `Opa`, que executa o **bloco de instância** de `Opa`… |
| 5 | **7** | …e depois o **corpo do construtor** `Opa()`. |
| 6 | **2** | De volta em `<init>` de `Uuupa`: bloco de instância de `Uuupa`. |
| 7 | **3** | Corpo do construtor `Uuupa()`. |

**As duas regras que resolvem qualquer questão desse tipo:**
1. Tudo que é **`static`** roda **uma vez só**, na iniciação da classe, e **de cima para baixo na hierarquia** (super antes de sub).
2. Em cada `<init>`: **super primeiro**, depois **blocos de instância**, depois **corpo do construtor** — e isso vale recursivamente.

#### D4 — Execução de `B[2] = (short)(B[2] - 128);`

Suponha `B` na variável local 1 de um método de instância. O bytecode gerado é:

```
aload_1        // empilha a referência para o array B (do vetor de vars locais)
iconst_2       // empilha o índice 2  → destino do armazenamento
aload_1        // empilha de novo a referência a B
iconst_2       // empilha de novo o índice 2
saload         // desempilha (ref, índice), lê B[2], estende o short para int e empilha
sipush 128     // empilha a constante 128 como int
isub           // desempilha os dois ints, empilha (B[2] - 128) como int
i2s            // converte o int do topo para short e o estende de volta para int  ← o cast (short)
sastore        // desempilha (ref, índice, valor), trunca o valor para short e grava em B[2]
```

Estado da pilha de operandos, passo a passo:

| Instrução | Pilha depois (topo à direita) |
|---|---|
| `aload_1` | `ref(B)` |
| `iconst_2` | `ref(B), 2` |
| `aload_1` | `ref(B), 2, ref(B)` |
| `iconst_2` | `ref(B), 2, ref(B), 2` |
| `saload` | `ref(B), 2, B[2]` |
| `sipush 128` | `ref(B), 2, B[2], 128` |
| `isub` | `ref(B), 2, (B[2]-128)` |
| `i2s` | `ref(B), 2, (short)(B[2]-128)` |
| `sastore` | *(vazia)* — o valor foi gravado em `B[2]` |

**Justificativas exigidas:**
- **Por que `aload`?** `B` é um array, logo uma **referência** — carregada com `aload`, não `iload`.
- **Por que a referência e o índice são empilhados duas vezes?** Porque `sastore` consome `(arrayref, index, value)` nessa ordem, e eles precisam estar **abaixo** do valor na pilha. Então são empilhados **antes** de calcular a expressão.
- **Por que o valor vira `int`?** Não existem instruções aritméticas para `short`. O `saload` já **estende o sinal** do `short` para `int`, e a subtração é feita com `isub`.
- **Por que `i2s`?** É a tradução do cast `(short)` — trunca para 16 bits com extensão de sinal. Sem o cast, o compilador Java recusaria a atribuição de um `int` a um elemento `short`.
- **Onde está o resultado?** Em `B[2]`, ou seja, **no heap** (o array é um objeto). Nada é "atualizado quando o frame é desempilhado" — o `sastore` escreve na memória do array imediatamente.

> ⚠️ Esse é o ponto em que a resposta da prova real erra mais: ela fala em consultar o **pool de constantes** para acessar o array (não — o array está numa variável local, via `aload`) e em atualizar `B[2]` **depois** que o frame é desempilhado (não — a escrita acontece na hora, com `sastore`). O pool de constantes só seria consultado se `B` fosse um campo (`getfield`/`getstatic`, que usam um índice no pool).

#### D5 — Descritor de `public static double[] calcula(String nome, char[][] grade, long id)`

```
(Ljava/lang/String;[[CJ)[D
```
Parâmetros: `Ljava/lang/String;` + `[[C` + `J`. Retorno: `[D`. Note que o descritor **não** codifica `public` nem `static` — isso vive em `access_flags`, não no descritor. Nomes de parâmetros também não aparecem.

#### D6 — Área de métodos x heap

| | **Área de métodos** | **Heap** |
|---|---|---|
| O que guarda | Estruturas **por classe**: pool de constantes de runtime, código (bytecode) dos métodos e construtores, campos **estáticos**, metadados (nome, superclasse, flags, tabela de métodos) | **Objetos** e **arrays** — as instâncias |
| Quando é preenchida | Na **carga/ligação** da classe | Em tempo de execução, a cada `new`/`newarray` |
| Compartilhamento | Compartilhada entre todas as threads | Compartilhado entre todas as threads |
| Coleta de lixo | Só quando a classe é descarregada (raro) | É o alvo principal do coletor de lixo |

Localização de cada item do enunciado:
- **Código do método `soma()`** → área de métodos (no atributo `Code` do `method_info` da classe).
- **Objeto criado por `new Pessoa()`** → heap.
- **`static int contador`** → área de métodos (campo estático, uma única cópia por classe).
- **`int idade` (campo de instância)** → heap, dentro de cada objeto `Pessoa`.

#### D7 — `int f(int a, int b) { return a * b + 3; }`

Método de instância, então: local 0 = `this`, local 1 = `a`, local 2 = `b`.

```
iload_1        // carrega a
iload_2        // carrega b
imul           // a * b
iconst_3       // constante 3
iadd           // (a*b) + 3
ireturn        // retorna o int do topo
```

| Instrução | Pilha depois |
|---|---|
| `iload_1` | `a` |
| `iload_2` | `a, b` |
| `imul` | `a*b` |
| `iconst_3` | `a*b, 3` |
| `iadd` | `a*b+3` |
| `ireturn` | *(frame desempilhado; valor empilhado no chamador)* |

`max_stack = 2`, `max_locals = 3`. Repare que a pilha de operandos implementa naturalmente a **notação pós-fixa**: operandos primeiro, operador depois — é exatamente por isso que a JVM é uma máquina de pilha.

#### D8 — Exceção não tratada em nenhum método

1. A exceção é lançada (por `athrow`, ou levantada pela própria JVM em casos como `NullPointerException`, `ArrayIndexOutOfBoundsException`, `ArithmeticException`).
2. A JVM consulta a **`exception_table`** do atributo `Code` do método corrente, procurando uma entrada cuja faixa `[start_pc, end_pc)` contenha o PC atual e cujo `catch_type` seja a classe da exceção **ou uma superclasse dela** (ou `catch_type == 0`, que casa com tudo).
3. **Se encontra:** a pilha de operandos do frame é esvaziada, a referência da exceção é empilhada, e o PC salta para `handler_pc`. A execução continua normalmente no `catch`.
4. **Se não encontra:** o método é encerrado **abruptamente**. Qualquer bloco `finally` do método corrente (implementado como entrada com `catch_type` 0) é executado, o monitor é liberado se o método é `synchronized`, e o frame é **desempilhado**.
5. A exceção é então **relançada no frame do chamador**, no ponto da instrução de invocação, e o processo volta ao passo 2. Isso é a **propagação pela pilha de chamadas**.
6. Se a pilha de frames da thread se esgota sem nenhum manipulador, a **thread** é encerrada. Antes disso, a JVM invoca o `UncaughtExceptionHandler` da thread (ou de seu `ThreadGroup`), cujo comportamento padrão é imprimir o *stack trace* em `System.err` — é justamente a lista de frames desempilhados.
7. A **JVM** só termina quando **todas as threads não-daemon** tiverem encerrado. Uma exceção não tratada em uma thread secundária **não derruba** as outras threads nem a aplicação.

---

## Apêndice — Conferência do gabarito contra o Java SE 8

Este gabarito foi escrito com baseline **Java SE 8**. Resumo dos pontos em que ele e o material da
disciplina podem divergir:

| Q | Assunto | Gabarito daqui | Slide / prova | Marcador |
|:---:|---|:---:|:---:|:---:|
| 28 | `<clinit>` é sempre o primeiro código executado | **F** | V (prova Q2) | ⚠️ |
| 36 | Instruções específicas para `boolean`/`byte`/`char`/`short` | **V** (redação "aritméticas") | F, na redação ampla da Q9 | 🟥 |
| 37 | Classe abstrata tem todos os métodos abstratos | **F** | Slide 121 sugere V | 🟥 |
| 38 | Interfaces e herança múltipla de atributos de instância | **F** | F (mesma resposta, motivos distintos) | 🟦 |
| 41 | `static` em classe | **F** | V (prova Q21) | ⚠️ |

Questões cuja resposta **não muda nada** entre Java 1.4 e Java 8 — ou seja, as seguras: 1 a 35, 39,
40, 42, 43 e 44, além de todas as discursivas. Todo o conteúdo de `.class`, áreas de runtime, frames,
bytecode e exceções é estável; a instabilidade está só nas questões de **orientação a objetos**, por
causa dos métodos `default`, e na redação da questão sobre instruções por tipo.

Detalhamento em [DIVERGENCIAS-JAVA8.md](DIVERGENCIAS-JAVA8.md).

---

## Erros mais caros nesta matéria (revise antes da prova)

1. `this` ocupa o índice **0** das variáveis locais em métodos de instância.
2. O frame tem uma **referência** ao pool de constantes; o pool mora na **área de métodos**.
3. Área de métodos guarda **classes**; heap guarda **objetos**.
4. Exceção não tratada **propaga** pela pilha de frames — não encerra o programa de imediato.
5. Classe abstrata precisa de **pelo menos um** método abstrato (ou nenhum) — não de todos.
6. Interfaces não têm **atributos de instância**; seus campos são `public static final`.
7. `Object` **tem** construtor.
8. `static` não se aplica a classe de topo.
9. `boolean`/`byte`/`char`/`short` viram `int` nas operações; só arrays e conversões têm instruções próprias.
10. `long`/`double` ocupam **dois** slots.
11. Ordem de iniciação: `<clinit>` super → `<clinit>` sub → `<init>` super → blocos de instância → corpo do construtor.
12. Retorno de método vai de **pilha de operandos para pilha de operandos**.
