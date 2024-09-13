# ¿Qué son los compromisos de Pedersen y cómo funcionan?
Los compromisos de Pedersen nos permiten codificar vectores arbitrariamente grandes con un único punto de curva elíptica, mientras que opcionalmente ocultamos cualquier información sobre el vector.

Nos permite hacer afirmaciones sobre un vector sin revelar el vector en sí.

## Motivación
Cuando hablamos de pruebas de conocimiento cero a prueba de balas, generalmente serán de la forma "Tengo dos vectores cuyo producto interno es $v$". Esto puede parecer básico, pero en realidad puedes usar este mecanismo para probar afirmaciones muy no triviales. Llegaremos a eso más adelante.

Pero para que una prueba de este tipo funcione, los vectores no pueden simplemente existir en la cabeza del probador; de lo contrario, el probador puede cambiarlos a voluntad. Tienen que ser entidades matemáticas en el mundo real. Generalmente, el probador no quiere simplemente pasar los dos vectores al verificador, pero aún necesita "pasar algo" al verificador para representar que ha seleccionado un par de vectores y no puede cambiarlo.

Aquí es donde entran en escena los compromisos de Pedersen.

En un argumento de producto interno, el demostrador proporciona dos *compromisos* con dos vectores, luego proporciona una prueba de que los vectores comprometidos tienen un determinado producto interno.

## Requisitos previos
Suponemos que el lector ya está familiarizado con la [suma de puntos de curva elíptica](https://www.rareskills.io/post/elliptic-curve-addition) y la multiplicación escalar y lo que significa que un punto esté "en la curva".

En cuanto a la notación, las letras mayúsculas son puntos de curva elíptica, las letras minúsculas son elementos de campo finito.

Decimos que $A$ es un punto de curva elíptica (EC), a es un elemento de [campo finito](rareskills.io/post/finite-fields) y $aA$ es la multiplicación de puntos entre el elemento de campo finito $a$ y el punto EC $A$. La expresión $A + B$ denota la suma de puntos de curva elíptica.

## Compromisos tradicionales
Cuando diseñamos funciones de revelación de confirmación en contratos inteligentes, normalmente tienen la forma

$$
\text{commitment} = \mathsf{hash}(\text{value}, \text{salt})
$$

donde $\text{salt}$ es un valor aleatorio para evitar que un atacante adivine por fuerza bruta $\text{value}$.

Por ejemplo, si estuviéramos confirmando un voto, solo hay una cantidad limitada de opciones y, por lo tanto, la selección del voto se puede adivinar probando todos los votos para ver qué hash coincide.

La terminología académica para la variable *salt* en el caso de los compromisos de Pedersen es el *factor cegador*. Debido a que es aleatorio, el atacante está "ciego" y no puede adivinar el valor confirmado.

Debido a que un adversario no puede adivinar el valor "compromiso", decimos que este esquema de compromiso es *oculto*.

Durante la fase de revelación, el autor revela el valor y la sal, para que la otra parte (o el contrato inteligente) pueda validar que coincide con el compromiso original. No es posible obtener otro par $(\text{value}, \text{salt})$ que pueda dar como resultado el mismo compromiso, por lo que decimos que este esquema es vinculante: el autor no puede cambiar (es decir, está obligado a) su valor comprometido después del hecho.

Un par $(\text{value}, \text{salt})$ que da como resultado el hash se denomina *apertura*. Decir que alguien "conoce una apertura al compromiso" significa que conoce (valor, sal). *Revelar* $(\text{value}, \text{salt})$ significa *abrir* el compromiso.

Al hablar de los compromisos de Pedersen, existe una distinción entre *conocer la apertura* y *abrir* el compromiso. Por lo general, queremos demostrar que *conocemos* la apertura, pero no necesariamente *abrirla*.

## Resumen de terminología
- Un compromiso **oculto** no permite que un adversario sepa qué valor seleccionó el autor del compromiso. Esto se logra generalmente incluyendo un término aleatorio que el atacante no puede adivinar.
- Un término **cegador** es el número aleatorio que hace que el compromiso sea imposible de adivinar.
- Una **apertura** son los valores que se calcularán para el compromiso.
- Un compromiso **vinculante** no permite que el autor del compromiso calcule un hash con diferentes valores. Es decir, no puede encontrar dos pares (valor, sal) que generen el mismo valor.
## Compromisos de Pedersen
Los compromisos de Pedersen se comportan de manera muy similar al esquema de confirmación-revelación descrito anteriormente, excepto que utilizan grupos de curvas elípticas en lugar de funciones hash criptográficas.

Bajo el supuesto de logaritmo discreto, dados los puntos de curva elíptica $V$ y $U$, no podemos calcular $x$ donde $V$ = $xU$. Es decir, no conocemos su *relación de logaritmo discreto*, es decir, cuántas veces $V$ debe sumarse a sí mismo para obtener $U$.

Cuando decimos que $u$ es el logaritmo discreto de $U$, todavía nos referimos a $u$ como el logaritmo discreto de $U$ aunque no podamos calcularlo, porque sabemos que existe. Todos los puntos de curva elíptica (criptográficos) tienen un logaritmo discreto, incluso si no se pueden calcular.

En este sentido, la multiplicación de puntos de curva elíptica se comporta como una función hash. Son vinculantes siempre que solo permitamos aperturas dentro del orden de la curva.

Sin embargo, si el rango de logaritmos discretos es pequeño y está limitado por el contexto de la aplicación (como las opciones de votación), entonces el logaritmo discreto podría volverse adivinable.

Podemos hacer un escondite de Pedersen de la siguiente manera:

$$
\text{commitment} = vG + sB
$$

donde $v$ es el valor que estamos confirmando y $s$ es la sal (o factor de cegamiento) y $B$ es otro punto de la curva elíptica cuyo logaritmo discreto el confirmador no conoce.

Debemos enfatizar que, aunque los logaritmos discretos son desconocidos, los puntos $G$ y $B$ son públicos y conocidos tanto por el verificador como por el confirmador.

### Por qué el confirmador no debe conocer el logaritmo discreto de $Q$
Supongamos que el confirmador conoce la relación de logaritmo discreto entre $B$ y $G$. Es decir, conocen $u$ tal que $B = uG$.

En ese caso, pueden abrir el compromiso

$$
\text{commitment} = vG + sB
$$

a un $(v', s')$ diferente del valor que originalmente comprometieron.

Así es como el autor del compromiso podría hacer trampa si sabe que $g$ es el logaritmo discreto de $G$ y $b$ es el logaritmo discreto de $B$.

El autor del compromiso elige un nuevo valor $v'$ y calcula

$$
s' = \frac{\text{commitment}- v'g}{b}
$$

Luego, el probador presenta $(v', s')$ como la apertura falsificada.

Esto funciona porque
$$
\begin{align*}
\text{commitment} &= v'G + \frac{\text{commitment}- v'g}{b} B \\
\text{commitment} &= v'G + (\text{commitment}- v'gG) \\
\text{commitment} &= \text{commitment} \\
\end{align*}
$$
**El autor de la confirmación no debe conocer la relación logarítmica discreta entre los puntos de la curva elíptica que está utilizando.**

Una forma de lograr esto es que un verificador proporcione los puntos de la curva elíptica al autor de la confirmación. Sin embargo, una forma más sencilla es elegir los puntos de la curva elíptica de forma aleatoria y transparente, como por ejemplo seleccionando puntos de la curva elíptica de forma pseudoaleatoria. Dado un punto de la curva elíptica aleatorio, no conocemos su logaritmo discreto.

Por ejemplo, podríamos empezar con el punto generador, hacer un hash de los valores $x$ e $y$, y luego usarlo para generar una búsqueda pseudoaleatoria pero determinista para el siguiente punto.

## ¿Por qué son útiles los compromisos de Pedersen?
Parece que los compromisos de Pedersen son solo una revelación de compromiso normal con una función hash diferente, entonces, ¿cuál es el punto?

Este esquema tiene un par de ventajas.

### Los compromisos de Pedersen son homomórficos aditivamente
Dado un punto $G$, podemos sumar dos compromisos $a_1G + a_2G$ = $(a_1 + a_2)G$.

Si incluimos términos de cegamiento aleatorios, aún podemos hacer una apertura válida sumando los términos de cegamiento y proporcionándoselos al verificador. Sea $C$ compromisos. Ahora, pensemos en lo que sucede cuando sumamos $C_1 + C_2$:

$$
\begin{aligned}
C_1 &= a_1G + s_1B \\
C_2 &= a_2G + s_2B \\
C_3 &= C_1 + C_2 \\
\pi &= s_1 + s_2 \\
\text{el confirmador revela...} \\
&(a_1, a_2, \pi) \\
\text{y el verificador comprueba...} \\
C_3 &\stackrel{?}{=} a_1G + a_2G + \pi B
\end{aligned}
$$

Alternativamente, el verificador puede comprobar que

$$C_3 = (a_1 + a_2)G + \pi B$$

Los hashes regulares (como SHA-256) no se pueden sumar de esta manera.

Dados dos compromisos de Pedersen que utilizan los mismos puntos de curva elíptica para comprometerse, podemos sumar los compromisos y aún así tener una apertura válida para ellos.

Los compromisos de Pedersen permiten que un probador haga afirmaciones sobre las sumas de los valores comprometidos.

### Podemos codificar tantos puntos como queramos en un solo punto
Nuestro ejemplo de uso de $G$ y $B$ también puede considerarse como un compromiso de vector 2D sin un término cegador. Pero podemos agregar tantos puntos de curva elíptica como queramos $[G₁, G₂, …, Gₙ]$ y comprometer tantos escalares como queramos. (Aquí, $G_1$, $G_2$, etc. significan diferentes puntos en el mismo grupo, no generadores de diferentes grupos).

## Compromisos de vector de Pedersen
Podemos tomar el esquema anterior como un paso más y comprometer un conjunto de valores en lugar de un valor y un término cegador.

## Esquema de compromiso de vector
Supongamos que tenemos un conjunto de puntos de curva elíptica aleatorios $(G₁,…,Gₙ)$ (del que no conocemos el logaritmo discreto), y hacemos lo siguiente:

$$C_1 = \underbrace{v_1G_1 + v_2G_2 + … + v_nG_n}_\text{vector comprometido} + \underbrace{sB}_\text{término ciego}$$

Esto nos permite comprometer $n$ valores a $C$ y ocultarlo con $s$.

Como el comprometidor no conoce el logaritmo discreto de ninguno de $G_i$, no conoce el logaritmo discreto de $C$. Por lo tanto, este esquema es vinculante: solo puede revelar $(v₁,…,vₙ)$ para producir $C$ más tarde, no puede producir otro vector.

### Los compromisos de vector se pueden combinar
Podemos sumar dos compromisos de vector de Pedersen para obtener un compromiso con dos vectores. Esto solo permitirá que el comprometidor abra los vectores originales. El detalle de implementación importante es que tenemos que usar un conjunto diferente de puntos de curva elíptica para comprometerse.

$$
\begin{align*}
C_1 &= v_1 G_1 + v_2 G_2 + \ldots + v_n G_n + r B \\
C_2 &= w_1 H_1 + w_2 H_2 + \ldots + w_n H_n + s B \\
C_3 &= C_1 + C_2
\end{align*}
$$

Al sumar $C_1$ y $C_2$, estamos comprometiendo funcionalmente un vector más grande de tamaño $2n$.

Aquí, $rB$ y $sB$ son los términos cegadores. Incluso si el autor confirma el vector cero, la confirmación seguirá pareciendo un punto aleatorio.

El autor revelará más tarde los vectores originales $(v₁…vₙ)$ y $(w₁…wₙ)$ y el término cegador $r + s$. Esto es vinculante: no pueden revelar otro par de vectores y términos cegadores.

El hecho de que estemos usando $(G₁,…,Gₙ)$ para un vector y $(H₁,…,Hₙ)$ no debería implicar que exista una relación especial entre los puntos $G$ y una relación especial entre los puntos $H$. Todos los puntos deben seleccionarse de forma pseudoaleatoria. Esto es simplemente una conveniencia de notación para decir "este vector de puntos de curva elíptica va con este vector de elementos de campo, y este otro vector de puntos EC va con este otro vector de elementos de campo".

No existe un límite superior práctico para la cantidad de vectores que podemos confirmar.

**Ejercicio para el lector:** Si usamos el mismo $G₁…Gₙ$ para ambos vectores antes de sumarlos, ¿cómo podría un autor abrir dos vectores diferentes para $C_3$? Dé un ejemplo. ¿Cómo se evita esto utilizando un conjunto diferente de puntos $H₁…Hₙ$?

**Ejercicio para el lector:** ¿Qué sucede si el autor intenta intercambiar los mismos elementos dentro del vector?

Por ejemplo, hacen el envío:

$$C_1 = v_1G_1 + v_2G_2 + \ldots + v_nG_n + rB$$

Pero abren con los dos primeros elementos intercambiados:

$$[v_2, v_1, v_3, ..., v_n]$$

Es decir, intercambian los dos primeros elementos dejando todo lo demás sin cambios. Supongamos que el vector $G₁…Gₙ$ no está permutado.

## Generar puntos aleatorios de forma transparente
¿Cómo podemos generar estos puntos aleatorios de curva elíptica? Una solución obvia es utilizar una configuración de confianza, pero no es necesaria. El autor de la confirmación puede configurar los puntos de forma que no pueda conocer su logaritmo discreto seleccionando aleatoriamente los puntos de forma transparente.

Puede elegir el punto generador, mezclarlo con un número aleatorio elegido públicamente y hacer un hash de ese resultado (y tomarlo módulo del módulo de campo) para obtener otro valor. Si eso da como resultado un valor x que se encuentra en la curva elíptica, utilícelo como el siguiente generador y haga un hash del par $(x, y)$ nuevamente. De lo contrario, si el valor x no se encuentra en la curva, incremente $x$ hasta que lo haga. Debido a que el autor de la confirmación no está generando los puntos, no conoce su logaritmo discreto. Los detalles de implementación de este algoritmo se dejan como ejercicio para el lector.

En ningún momento se debe generar un punto eligiendo un escalar y luego multiplicándolo por el generador, ya que eso daría como resultado que se conozca el logaritmo discreto. Debe seleccionar los valores $x$ del punto de la curva de forma pseudoaleatoria mediante una función hash y determinar si está en la curva.

Está bien comenzar con el generador (que tiene un logaritmo discreto conocido de 1) y generar los otros puntos.

**Ejercicio para el lector:** Supongamos que confirmamos un vector 2D en los puntos $G_1$ y $G_2$. Se conoce el logaritmo discreto de $G_1$, pero no se conoce el logaritmo discreto de $G_2$. Ignoraremos el término ciego por ahora. ¿Puede el confirmador abrir dos vectores diferentes? ¿Por qué sí o por qué no?

Obtenga más información con RareSkills
Consulte nuestro campamento de entrenamiento ZK si desea [aprender pruebas de conocimiento cero](https://www.rareskills.io/zk-bootcamp).

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*
