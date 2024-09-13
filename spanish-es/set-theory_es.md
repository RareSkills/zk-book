# Teoría de conjuntos elemental para programadores

¿Por qué otro tutorial de teoría de conjuntos?

El público objetivo de este artículo son las personas a las que no les interesan las matemáticas abstractas a menos que vean un caso de uso directo para ellas. Quieren obtener las partes esenciales que necesitan y seguir adelante. Este artículo está dirigido a ese público.

En concreto, el álgebra abstracta tiene muchos conceptos que se pueden llamar apropiadamente "útiles", pero el álgebra abstracta depende en gran medida de la teoría de conjuntos.

Nuestro objetivo aquí es tomar el camino más directo a través de la teoría de conjuntos hasta el álgebra abstracta de modo que comprendamos toda la terminología y los conceptos con los que trataremos.

Los ingenieros no suelen estar interesados ​​en recopilar abstracciones ni demostrar teoremas, quieren enviar cosas teniendo un conocimiento lo suficientemente profundo del tema como para no crear errores o ineficiencias involuntariamente. Adquirir conocimientos que no ayuden directamente en esta búsqueda se considera una pérdida de tiempo.

Para optimizar este objetivo, he omitido deliberadamente cualquier aspecto de la teoría de conjuntos que no creo que sea directamente útil para comprender los aspectos del álgebra abstracta que necesitamos y, como tal, este recurso no es exhaustivo por diseño. Pero tenga en cuenta que esto es parte de una serie de tutoriales y no pretende ser el tratamiento completo.

## Motivación de la teoría de conjuntos para las pruebas de conocimiento cero
El objetivo de este tutorial es brindarle una comprensión firme de lo que es un **operador binario** en el contexto de la teoría de conjuntos.

El concepto de operador binario es el núcleo de la teoría de grupos, y la teoría de grupos se usa *en todas partes* en las pruebas de conocimiento cero.

## Nuestro tratamiento no es riguroso
Algunos matemáticos se horrorizarán de que ni siquiera analice los axiomas de la teoría de conjuntos aquí. Esto es una característica, no un error. Si desea una prueba de algo, pregúntele a Google o ChatGPT (o mejor aún, descúbralo por su cuenta). Los conceptos discutidos aquí han sido probados hasta la saciedad durante más de un siglo.

La teoría de conjuntos no es difícil (al menos si te saltas la escritura de pruebas, las pruebas de teoría de conjuntos pueden ser sorprendentemente difíciles cuando las haces por primera vez). Probablemente ya entiendas la teoría de conjuntos intuitivamente, y casi seguro que hayas usado conjuntos en tu código, probablemente para eliminar duplicados en una matriz rápidamente. Sin embargo, necesitamos ponerle un lenguaje a esta intuición y hacer explícita nuestra comprensión intuitiva.

Aprender matemáticas abstractas es como aprender un lenguaje humano. Puedes aprender el vocabulario (a qué se refieren las palabras) y la gramática (cómo se combinan de manera válida). Aquí ponemos mucho énfasis en el vocabulario por sobre la gramática, para usar esa analogía. Hay una buena razón para esto.

Si entras a una tienda en un país extranjero y preguntas el equivalente a "¿dónde están los panes que me van a comprar?", el empleado puede ayudarte aunque tu gramática sea terriblemente incorrecta. Pero si dominas la gramática y no conoces el vocabulario, tu conocimiento es inútil. Puedes formar una oración perfecta, pero si no puedes referirte sucintamente a “pan” y “comprar”, tu viaje a la tienda no será un éxito (yo no inventé esta analogía, pero desafortunadamente no recuerdo dónde la vi por primera vez).

Por lo tanto, apenas tocaremos la gramática (pruebas y teoremas) y haremos hincapié en el vocabulario de las matemáticas abstractas (que es muy útil para navegar en este país extranjero).

**Algunos tipos de conocimiento solo se pueden adquirir por experiencia, no por explicación.**

Por lo tanto, debes hacer los ejercicios de este texto. No te preocupes, no escribirás pruebas, solo te asegurarás de que realmente internalizaste lo que acabas de leer.

No dejes que la relativa brevedad de este texto te engañe. Te llevará al menos una tarde (o dos, tal vez tres) resolverlo si realmente haces los ejercicios. Si una determinada sección no tiene sentido, consulta Internet para encontrar explicaciones alternativas de ese subtema.

## Definición de un conjunto
Un conjunto es una colección bien definida de objetos. El poder abstracto proviene de que estos podrían ser *cualquier cosa* y las reglas que aprendemos de la teoría de conjuntos se aplican a ellos.

Lo que los números enteros, racionales, reales, complejos, matrices, polinomios, polígonos y muchas otras cosas tienen en común es que todos son conjuntos.

Hay una regla bien definida que decide si algo es miembro del conjunto o no. No entraremos en detalles, pero está claro que un polígono no es un polinomio y un polinomio no es una matriz, etc.

Se permite que los conjuntos estén vacíos. A esto lo llamamos el *conjunto vacío*.

Los conjuntos no contienen elementos duplicados por definición, $\{a, a, b\}$ es en realidad $\{a, b\}$.

**Ejercicio:** Suponga que tiene una definición adecuada para los números enteros. Cree un conjunto bien definido de números racionales.

## Superconjunto y subconjuntos
Cuando observamos los números enteros y racionales, parece haber una relación entre algunos de ellos. En concreto, todos los números enteros son números racionales, pero no todos los números racionales son enteros. La relación entre ellos es que los números enteros son un *subconjunto* de los números racionales. Por otro lado, los números racionales son un superconjunto de los números enteros.

Un subconjunto no tiene por qué ser estrictamente menor que el conjunto del que forma parte. Está perfectamente bien decir que los números enteros son un subconjunto de los números enteros.

La definición precisa de la relación entre números enteros y racionales es un *subconjunto propio*, es decir, existen números racionales que no son enteros.

**Ejercicio:** Defina la relación de subconjunto entre números enteros, números racionales, números reales y números complejos.

**Ejercicio:** Defina la relación entre el conjunto de números trascendentales y el conjunto de números complejos en términos de subconjuntos. ¿Es un subconjunto propio?

## Igualdad de conjuntos
Los conjuntos se definen como iguales si contienen los mismos elementos, independientemente del orden. Por ejemplo, $\{4, 2, 5\}$ es el mismo conjunto que $\{2, 5, 4\}$. Al hacer demostraciones formales para conjuntos, decimos que si $A$ es un subconjunto de $B$ y $B$ es un subconjunto de $A$, entonces $A = B$. O en una notación más matemática: $A = B \iff A \subseteq B$ y $B \subseteq A$. Eso se lee como $A = B$ si y solo si $A$ es un subconjunto de $B$ y $B$ es un subconjunto de $A$.

## Cardinalidad
En algunos de nuestros ejemplos anteriores, hay un número infinito de números enteros, racionales, etc. Sin embargo, también podemos definir conjuntos de forma finita, como los números $\{0,1,2,3,4,5,6,7,8,9,10\}$. La cardinalidad del conjunto anterior es 11. Si $A = \{5,9,10\}$, entonces $|A| = 3$, donde las dos barras verticales alrededor de A significan cardinalidad.

Hay diferentes niveles de infinito en la teoría de conjuntos. Por ejemplo, hay una cantidad infinita de números reales más que números enteros. En concreto, decimos que los números enteros son infinitos contables porque literalmente se pueden contar. Pero no hay forma de empezar a contar números reales que son infinitos contables.

**Ejercicio:** Utilizando la definición formal de igualdad, demuestra que si dos conjuntos finitos tienen diferente cardinalidad, no pueden ser iguales. (Demostrar esto para conjuntos infinitos es un poco más complicado, así que lo omitimos).

## Letras elegantes de pizarra
Como los “números enteros como un conjunto” y los “números reales como un conjunto” se utilizan con tanta frecuencia, existe una abreviatura matemática que da miedo.

- El símbolo ℕ es el conjunto de números naturales (1,2,3,…). Definitivamente no incluye números negativos, pero si incluye o no el cero depende de con quién estés hablando.
- El símbolo ℤ es el conjunto de todos los números enteros (porque “zahlen” es entero en alemán)
- El símbolo ℚ es el conjunto de todos los números racionales (lo recuerdo como el cociente del numerador y el denominador)
- El símbolo ℝ es el conjunto de todos los números reales, porque R significa real. Obvio.
- El símbolo ℂ es el conjunto de todos los números complejos por razones igualmente obvias.

A veces la gente escribe ℝ² como un vector de dos números reales, por lo que a ∈ ℝ² significa que “a” es un vector 2d. Recomiendo escribirlo de la segunda manera porque es más conciso y también te hace parecer más inteligente.

![Meme matemático sobre vectores 2D de números reales](https://static.wixstatic.com/media/935a00_9815078a1a9d44b0ae354484a71d8052~mv2.png/v1/fill/w_829,h_600,al_c,lg_1,q_90,enc_auto/935a00_9815078a1a9d44b0ae354484a71d8052~mv2.png)

## Pares ordenados
Aunque los conjuntos no respetan el orden, puede surgir un nuevo tipo de estructura de datos a partir de los conjuntos, llamada par ordenado. Por ejemplo, $(a, b)$ es un par ordenado, mientras que $\{a, b
\}$ es un conjunto.

Los programadores solemos pensar en esto como una tupla. Decimos que dos pares ordenados son iguales en el mismo sentido en que decimos que dos tuplas son iguales.

¿Cómo creamos orden a partir de algo que no está ordenado?

El detalle de implementación es que escribimos $(a, b)$ en forma de conjunto como ${a, {b}}$. Podemos hacer esto porque podemos definir nuestro conjunto como que contiene letras o un conjunto de cardinalidad uno que contiene una letra. Es por eso que podemos decir $(a, b) \neq (b, a)$ porque ${a, {b}} \neq {b, {a}}$. No nos ocuparemos más de este detalle de implementación.

Al igual que en otros lenguajes de programación, nuestro par ordenado puede ser arbitrariamente largo; por ejemplo, $(a,b,c,d)$ es válido. También podemos codificar un par ordenado que contenga un par ordenado como $((a, b), c)$, lo que será útil más adelante.

## Producto cartesiano
Dado que los conjuntos están bien definidos, podemos definir un conjunto de modo que cada elemento de un conjunto sea parte de un par ordenado con un elemento de otro conjunto. Por ejemplo, si $A = {1,2,3}$ y $B = {x, y, z}$ entonces $A × B$ es el conjunto $\{(1, x), (1, y), (1, z), (2, x), …, (3, z)\}$ o se puede hacer como una tabla:

$$
A \times B =\space\space
\begin{array}{c|ccc}
& x & y & z \\
\hline
1 & (1,x) & (1,y) & (1,z) \\
2 & (2,x) & (2,y) & (2,z) \\
3 & (3,x) & (3,y) & (3,z)
\end{array}
$$

Los productos cartesianos no son conmutativos, como lo demostrará el siguiente ejercicio. Conmutativo significa $B × A = A × B$ en el caso general.

**Ejercicio:** Calcula el producto cartesiano de B × A usando las definiciones anteriores.

## Los subconjuntos del producto cartesiano forman una función
¿Qué sucedería si quisiéramos decir que tenemos una función?

$$
\begin{align*}
1 \rightarrow y \\
2 \rightarrow z \\
3 \rightarrow x \\
\end{align*}
$$

(Elegí este ejemplo fuera de orden para hacerlo un poco más interesante).

Podemos definir un conjunto que defina esta función. Simplemente tomamos un subconjunto de nuestro producto cartesiano anterior para incluir $(1, y)$, $(2, z)$ y $(3, x)$.

**En términos de teoría de conjuntos, una función es un subconjunto del producto cartesiano de los conjuntos de dominio y codominio.**

Para nuestro ejemplo de 1 que se asigna a y, 2 que se asigna a z y 3 que se asigna a x, el subconjunto del producto cartesiano se muestra en negrita a continuación:

$$
\{1,2,3\} \times \{x, y, z\} =\space\space
\begin{array}{c|ccc}
& x & y & z \\
\hline
1 & (1,x) & \mathbf{(1,y)} & (1,z) \\
2 & (2,x) & (2,y) & \mathbf{(2,z)} \\
3 & \mathbf{(3,x)} & (3,y) & (3,z) \\
\end{array}
$$

Por lo tanto, nuestra función está definida por el conjunto $\{(1, y), (2, z), (3, x)\}$.

Para definir el conjunto, necesitamos el conjunto del que partimos y el conjunto en el que terminamos. Tomamos el producto cartesiano de estos dos conjuntos, que da como resultado todas las asignaciones posibles del conjunto de entrada al conjunto de salida. Luego tomamos el subconjunto del producto cartesiano para definir la función como queramos. Cuando trabajamos con conjuntos infinitos como los enteros, no nos preocupa no poder enumerar todos los puntos ordenados explícitamente.

### Las funciones no son necesariamente computables
Una nota muy importante es que los matemáticos rara vez se preocupan por la *computabilidad*. Una función es una aplicación entre conjuntos. Cómo se *calcula* esa función, si es que es posible calcularla con una computadora razonable, no es una preocupación de la mayoría de los matemáticos.

Aquí es donde los programadores a veces se equivocan. A menudo solo piensan en las funciones como algo que se puede calcular de manera eficiente con líneas de código. Si bien esto es útil, limita nuestra comprensión de las propiedades generales de las funciones.

La razón por la que hago hincapié en esto es que en las pruebas de conocimiento cero, vamos a tratar con funciones que son de un nivel mucho más “alto” que introducir un argumento en una función y obtener un valor de retorno. Necesitamos poder apreciar el “panorama general” de las funciones. *Son una aplicación de un conjunto a otro conjunto*. Y una aplicación entre conjuntos se produce tomando un subconjunto de su producto cartesiano.

#### Funciones con dominios y codominios diferentes
En concreto, vamos a saltar entre números enteros, polinomios, matrices, curvas elípticas en una dimensión, luego curvas elípticas en otra dimensión, y así sucesivamente.

Te marearás mucho tratando de conceptualizar esto a menos que entiendas a un nivel básico que, según la teoría de conjuntos, ¡podemos definir los saltos como queramos!

Por supuesto, la forma en que asignamos el salto tendrá un fuerte efecto en su utilidad; si asignamos todo a cero, ese es un mapa válido, pero no muy útil.

Quiero que entiendas desde el principio que no estamos haciendo nada raro cuando nos deformamos entre universos de esta manera.

Al final del día, se nos permite tomar dos conjuntos cualesquiera que queramos, crear un nuevo conjunto tomando su producto cartesiano, tomando un subconjunto de ese conjunto de pares ordenados y, ¡boom!, tenemos una función.

#### Axioma de elección
Si estás pensando "oye, espera un minuto, ¿puedo simplemente elegir un subconjunto y definir la función como quiera?", no eres el único que se lo pregunta. Si quieres profundizar en el tema, realmente hemos estado discutiendo el [axioma de elección](https://en.wikipedia.org/wiki/Axiom_of_choice) todo este tiempo, y ha sido objeto de controversia a pesar de que la definición parece no serlo:

>El producto cartesiano de una colección de conjuntos no vacíos es no vacío.

## Los subconjuntos del producto cartesiano forman una función: ejemplo
Definamos una función entre números reales no negativos (cero o mayor) y números enteros no negativos (cero o mayor) utilizando la función floor. La función floor simplemente elimina la parte decimal de un número. No podemos mostrar todos los números reales (o enteros), pero podemos crear un esquema.

Cuando hacemos $\mathbb{R}\times\mathbb{Z}$ y tomamos un subconjunto, simplemente elegimos los pares ordenados que corresponden a tomar el piso del elemento de los números reales. Los pares ordenados que no mostramos en la tabla son pares ordenados que no están en nuestro subconjunto que define la función. Por ejemplo, 2 no es el piso de 500,3, por lo que ese par ordenado (500,3, 2) no está incluido.

$$
\begin{array}{c|ccccc}
& 1 & 2 & \puntos & 499 & 500 \\
\hline
1.5 & \color{rojo}{\mathbf{(1.5, 1)}} & (1.5, 2) & \puntos & (1.5, 499) & (1.5, 500) \\
2.7772 & (2.7772, 1) & \color{rojo}{\mathbf{(2.7772, 2)}} & \puntos & (2.7772, 499) & (2.7772, 500) \\
\vpuntos & \vpuntos & \vpuntos & \dpuntos & \vpuntos & \vpuntos & \vpuntos \\
500.3 & (500.3, 1) & (500.3, 2) & \dots & (500.3, 499) & \color{red}{\mathbf{(500.3, 500)}} \\
\end{array}
$$

**Ejercicio:** Definir una función de mapeo de los números enteros $\{1,2,3,4,5,6\}$ al conjunto $\{\text{even}, \text{odd}\}$.

**Ejercicio:** Calcular el producto cartesiano de los polígonos $\{\text{triángulo}, \text{cuadrado}, \text{pentágono}, \text{hexágono}, \text{heptágono}, \text{octágono}\}$ y el conjunto de números enteros $\{0,1,2,…,8\}$. Definir una función de mapeo tal que el polígono se mapee a un número entero que represente el número de lados. Por ejemplo, el par ordenado $(□, 4$) debería estar en el subconjunto, pero $(△, 7)$ no debería estar en el subconjunto del producto cartesiano.

**Ejercicio:** Defina una correspondencia entre números enteros positivos y números racionales positivos (no todo, obviamente). Es posible correlacionar perfectamente los números enteros con números racionales. Pista: dibuje una tabla para construir números racionales donde las columnas sean los numeradores y las filas los denominadores. Dedíquele al menos 15 minutos a esto antes de buscar la respuesta.

### Subconjuntos válidos e inválidos del producto cartesiano.
Hay una restricción importante sobre cómo elegimos nuestro subconjunto. Por ejemplo, el siguiente subconjunto del producto cartesiano $\{1,2,3\}$, $\{p,q,r\}$ no es válido porque 1 corresponde a $p$ y 1 corresponde a $q$. Al definir una función con un producto cartesiano, el mismo elemento de dominio no puede mapearse a dos elementos de codominio diferentes.

$$
\begin{array}{c|cc}
& p & q & r\\
\hline
1&(1,p) & (1,q)\\
2&&(2,q)\\
3&&&(3,4)\\
\end{array}
$$

## Un producto cartesiano de un conjunto consigo mismo
No debería sorprender que en lugar de hacer un producto cartesiano entre $A$ y $B$, se pueda hacer un producto cartesiano entre $A$ y $A$. Esto es simplemente mapear un conjunto consigo mismo.

Este es el primer paso de una forma más abstracta de lo que tradicionalmente consideramos como *funciones* sobre números enteros.

Por ejemplo, $y=x^2$ (sobre números enteros positivos) se puede visualizar en términos de teoría de conjuntos como el subconjunto de $\mathbb{Z}\times\mathbb{Z}$:

$$
\begin{array}{|c|c|c|c|c|c|c|c|c|c|c|c|}
\hline
& 1 & 2 & 3 & 4 & 5 & 6 & 7 & 8 & 9 & 10 &...\\
\hline
1 & \color{red}{\mathbf{(1,1)}} & (1,2) & (1,3) & (1,4) & (1,5) & (1,6) & (1,7) & (1,8) & (1,9) & (1,10) \\
\hline
2 & (2,1) & (2,2) & (2,3) & \color{red}{\mathbf{(2,4)}} & (2,5) & (2,6) & (2,7) & (2,8) & (2,9) & (2,10) \\
\hline
3 & (3,1) & (3,2) & (3,3) & (3,4) & (3,5) & (3,6) & (3,7) & (3,8) & \color{red}{\mathbf{(3,9)}} & (3,10) \\
\hline
...\\
\hline
\end{array}
$$

## Relaciones entre conjuntos
La frase “tomar un subconjunto del producto cartesiano” es tan común que tenemos una palabra para ella. Es una *relación*.

Una relación puede provenir de un producto cartesiano de un conjunto consigo mismo o de un conjunto con otro conjunto. Si tenemos dos conjuntos $A$ y $B$ ($B$ puede o no ser igual a $A$ sin pérdida de generalidad), y tomamos un subconjunto de $A \times B$, entonces decimos que un elemento $a$ de $A$ está relacionado con un elemento $b$ de $B$ si hay un par ordenado $(a, b)$ en el subconjunto de $A \times B$.

En el ejemplo $y=x^2$, 2 de $X$ está relacionado con 4 de $Y$, pero 3 en $X$ no está relacionado con 6 de $Y$.

## Un “operador binario” en términos de teoría de conjuntos
Un operador binario es una función de $A \times A \rightarrow A$. Básicamente, tomamos cada par posible de $A \times A$ (el producto cartesiano de $A$ consigo mismo) y lo asignamos a un elemento en $A$.

Usemos un ejemplo del conjunto ${0,1,2}$ con operador binario adición módulo 3. Primero tomamos el producto cartesiano del conjunto consigo mismo (es decir, $A \times A$):

$$
\begin{array}{c|ccc}
& 0 & 1 & 2 \\
\hline
0 & (0,0) & (0,1) & (0,2) \\
1 & (1,0) & (1,1) & (1,2) \\
2 & (2,0) & (2,1) & (2,2) \\
\end{array}
$$

Luego tomamos el producto cartesiano de este nuevo conjunto de pares con el conjunto original

$$
\begin{array}{c|ccc}
& 0 & 1 & 2 \\
\hline
(0,0) & ((0,0),0) & ((0,0),1) & ((0,0),2) \\ (0,1) & ((0,1),0) & ((0,1),1) & ((0,1),2) \\ (0,2) & ((0,2),0) & ((0,2),1) & ((0,2),2) \\ (1,0) & ((1,0),0) & ((1,0),1) & ((1,0),2) \\ (1,1) & ),0) & ((1,1),1) & ((1,1),2) \\ (1,2) & ((1,2),0) & ((1,2),1) & ((1,2),2) \\ (2,0) & ((2,0),0) & ((2,0),1) & ((2,0),2) \\ (2,1) & ((2,1),0) & ((2,1),1) & ((2,1),2) \\
(2,2) & ((2,2),0) & ((2,2),1) & ((2,2),2) \\
\end{array}
$$

Y luego tomamos el subconjunto de lo que define nuestra suma de operadores binarios módulo 3:

$$
\begin{array}{c|ccc}
& 0 & 1 & 2 \\
\hline
(0,0) & \color{red}{\mathbf{((0,0),0)}} & ((0,0),1) & ((0,0),2) \\
(0,1) & ((0,1),0) & \color{red}{\mathbf{((0,1),1)}} & ((0,1),2) \\
(0,2) & ((0,2),0) & ((0,2),1) & \color{rojo}{\mathbf{((0,2),2)}} \\
(1,0) y ((1,0),0) y \color{rojo}{\mathbf{((1,0),1)}} y ((1,0),2) \\
(1,1) y ((1,1),0) y ((1,1),1) y \color{rojo}{\mathbf{((1,1),2)}} \\
(1,2) y \color{rojo}{\mathbf{((1,2),0)}} y ((1,2),1) y ((1,2),2) \\
(2,0) y ((2,0),0) y ((2,0),1) y \color{rojo}{\mathbf{((2,0),2)}} \\
(2,1) y \color{rojo}{\mathbf{((2,1),0)}} y ((2,1),1) & ((2,1),2) \\
(2,2) & ((2,2),0) & \color{red}{\mathbf{((2,2),1)}} & ((2,2),2) \\
\end{array}
$$

## Las funciones generalmente "existen", pero la computabilidad es una historia diferente

Pensar en las funciones como un subconjunto de un producto cartesiano puede resultar un poco extraño al principio, especialmente porque tales definiciones no se traducen fácilmente en código.

Pero ZK está muy influenciado por las definiciones matemáticas, por lo que es útil tener este vocabulario a mano.

Es útil conceptualizar las funciones como un mapa que toma un elemento de un conjunto y devuelve un elemento de otro conjunto.

**Ejercicio:** Elija un subconjunto de pares ordenados que defina a * b mod 3.

**Ejercicio:** Defina nuestro conjunto $A$ como los números $\{0,1,2,3,4\}$ y nuestro operador binario como la resta módulo 5. Defina todos los pares ordenados de $A \times A$ en una tabla, luego asigne ese conjunto de pares ordenados a $A$.

Un operador binario *cerrado* toma dos elementos cualesquiera de un conjunto y genera otro elemento del mismo conjunto. La parte cerrada es importante, ya que restringe el resultado para que esté en el mismo conjunto.

Específicamente, comience con un conjunto A y construya un operador binario de la siguiente manera:

Tome un producto cartesiano de un conjunto consigo mismo, $A \times A$ y llame a este conjunto de pares ordenados $P$.

Tome el producto cartesiano de $P$ con $A$ y tome un subconjunto de ese tal que $P\times A$ esté bien definido.

La división de números enteros no es un operador binario porque lo que realmente sucede es que hacemos $P = (\mathbb{Z} \times \mathbb{Z})$ y luego tomamos un subconjunto de $P \times \mathbb{Q}$ para obtener nuestra relación. La división de números enteros no es cerrada porque puede producir números racionales.

Vamos a tratar mucho con operadores binarios en curvas elípticas, números enteros, polinomios, matrices, etc.

Cuando podemos confiar en que el operador binario tendrá ciertas propiedades, entonces podemos abstraer muchos detalles de implementación.

Por ejemplo, "sumar" puntos de curva elíptica no es exactamente trivial, y las matemáticas no son obvias desde el principio.

Sin embargo, si sabes que el operador binario es cerrado y sigue ciertas propiedades, entonces ¡cómo se implementa la "suma" no importa! ¡Es un mapa que sigue ciertas reglas!

Usemos un ejemplo un poco más fácil de entender. Si multiplicas dos matrices cuadradas con determinante 1, el determinante de la matriz producto también será 1. La prueba no es algo que puedas resolver rápidamente en tu cabeza. Pero si modelas esto como un “conjunto de matrices 3x3 con determinante 1 y operador binario multiplicar, y multiplicar es cerrado”, entonces de repente tienes mucho conocimiento funcional de un sistema del cual no conoces los detalles de implementación. Sabes que, sin importar lo que hagas, obtendrás una matriz con determinante 1 sin tener que saber por qué.

Tener el lenguaje para describir un operador binario como “cerrado” te permite operar a un nivel superior y comprender el panorama general de las transformaciones y no empantanarte en los detalles de implementación.

¡Puedes razonar sobre operaciones sin entender cómo funcionan! Esto es *extremadamente útil* cuando se trata de lidiar con matemáticas muy esotéricas como [emparejamientos bilineales de curvas elípticas](https://www.rareskills.io/post/bilinear-pairing).

### Construcción de operaciones binarias válidas
Cuando se trata de operadores binarios, no se nos permite tomar un subconjunto de $A \times A$ antes de mapearlo a $A$. Los operadores binarios deben aceptar *todos* los miembros del conjunto $A$ como sus entradas. Por supuesto, debemos tomar un subconjunto de los pares ordenados entre $A \times A$ y $A$ porque cada par de $A \times A$ debe mapearse a exactamente un A.

## Aprende más con RareSkills
La utilidad del vocabulario del álgebra abstracta es la razón por la que nuestro [curso de conocimiento cero](https://www.rareskills.io/zk-bootcamp) no elude las matemáticas. Solo nos aseguramos de tener el vocabulario esencial aprendido antes de comenzar a usarlo.

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*
