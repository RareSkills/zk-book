# P vs NP y su aplicación a las pruebas de conocimiento cero

El problema P = NP plantea la siguiente pregunta: "Si podemos verificar rápidamente que la solución de un problema es correcta, ¿podemos también calcular rápidamente la solución?" La mayoría de los investigadores creen que la respuesta es no, es decir, P ≠ NP.

Al comprender el problema P vs NP, podemos ver cómo las Zero Knowledge Proofs (ZKPs) encajan en el campo más amplio de la informática y comprender lo que las ZKP pueden y no pueden hacer.

Es mucho más fácil "entender" las pruebas de conocimiento cero relacionándolas con el problema P vs NP.

Este tutorial tiene tres partes:
1. Explicación del problema P vs NP
2. Expresar problemas y soluciones como una fórmula booleana
3. P vs NP y cómo se relacionan con las pruebas de conocimiento cero

## Requisitos previos
Suponemos que el lector está familiarizado con la complejidad temporal y la notación $\mathcal{O}$ mayúscula.

Decimos que un algoritmo tarda un tiempo polinomial si se ejecuta en un tiempo de $\mathcal{O}(nᶜ)$ o más rápido, donde $n$ es el tamaño de la entrada y $c$ es una constante no negativa. Podemos referirnos a los algoritmos que se ejecutan en un tiempo polinomial o más rápido como *algoritmos eficientes* porque su tiempo de ejecución no crece demasiado rápido con el tamaño de la entrada.

Decimos que un algoritmo tarda *tiempo exponencial* o es *costoso* si se ejecuta en $\mathcal{O}(cⁿ)$ donde $c$ es una constante mayor que 1 y $n$ es el tamaño de la entrada porque el algoritmo se vuelve exponencialmente lento a medida que aumenta el tamaño de la entrada.

## Parte 1: Explicación del problema P vs NP
### Los problemas en P son problemas que son fáciles de resolver y fáciles de verificar sus soluciones.

Los problemas que se pueden resolver en tiempo polinómico y cuyas soluciones se pueden verificar en tiempo polinómico se denominan problemas en P.

A continuación se muestran algunos ejemplos de problemas cuyas soluciones son fáciles de calcular y verificar. Estas tareas pueden ser realizadas por diferentes partes, una que realiza el cálculo y otra que verifica que los resultados sean válidos:

#### Ejemplo 1 de P: Ordenar una lista
Podemos ordenar una lista de manera eficiente y podemos verificar de manera eficiente que una lista esté ordenada.
- **Resolución:** Ordenar la lista requiere $\mathcal{O}(n \log n)$ tiempo (por ejemplo, utilizando mergesort), que es tiempo polinómico. Aunque $n \log n$ no es un polinomio, sabemos que $\log n < n$ y, por lo tanto, $(n \log n) < n²$, por lo que el tiempo de ejecución de nuestro algoritmo está limitado por encima de algún polinomio, que es el requisito para el "tiempo polinómico".

- **Verificación:** Podemos verificar que la lista esté ordenada recorriéndola y comprobando que cada elemento sea mayor que su vecino izquierdo, lo que llevaría $\mathcal{O}(n)$ tiempo.

#### Ejemplo 2 de P: Devolver el índice de un número en una lista, si aparece en la lista
Podemos buscar de manera eficiente para ver si un número está en una lista y luego verificar de manera aún más eficiente que el número esté presente si conocemos el índice en el que está.

- **Resolución:** Por ejemplo, dada la lista `[8, 2, 1, 6, 7, 3]`, necesitamos $\mathcal{O}(n)$ tiempo para determinar si el número `7` está en la lista.

- **Verificación:** Pero si le damos la lista y decimos que 7 está en el índice 4, puede verificar que el número esté en la lista en esa posición en $\mathcal{O}(1)$ tiempo. Buscar un elemento, si no nos dicen su posición, toma $\mathcal{O}(n)$ tiempo en el caso general, ya que tenemos que buscar en la lista. Si nos dicen la supuesta ubicación del elemento, toma $\mathcal{O}(1)$ tiempo verificar que el elemento está, de hecho, en la lista en esa ubicación.

#### Ejemplo 3 de P: Determinar si dos nodos en un gráfico están conectados
Podemos determinar de manera eficiente si dos nodos en un gráfico están conectados usando una búsqueda en amplitud: comenzar en un nodo, luego visitar todos sus vecinos excepto los nodos que ya hemos visitado, luego buscar los vecinos de los vecinos, y así sucesivamente.

- **Resolución:** Descubrir la ruta entre nodos usando una búsqueda en amplitud tomará $\mathcal{O}(n + e)$ tiempo, donde $n$ es el número de nodos en el gráfico y $e$ es el número de aristas. El número de aristas $e$ no puede ser mayor que $n^2$, por lo que podemos tratar a $\mathcal{O}(n + e)$ como $\mathcal{O}(n²)$ en el peor de los casos.

- **Verificación:** Podemos verificar que la ruta propuesta sea válida en tiempo $\mathcal{O}(n)$ simplemente siguiendo la ruta propuesta para ver si los dos puntos realmente están conectados por esa ruta.

**En todos los ejemplos anteriores, tanto el cálculo como la verificación de la solución se pueden realizar en tiempo polinomial.**

#### El testigo
Un *testigo* en informática es una prueba de que resolviste el problema correctamente. En los ejemplos anteriores, el testigo es la respuesta correcta al problema. Para los ejemplos anteriores, estas son las cosas que podríamos usar como testigo:
1. La lista ordenada
2. El índice donde aparece un número en la lista
3. La ruta entre dos nodos en un gráfico

Veremos más adelante que un testigo no necesariamente tiene que ser la solución al problema original. También podría ser una solución para una representación alternativa del mismo problema.

### Problemas en PSPACE: No todos los problemas tienen soluciones que se puedan verificar de manera eficiente
Los problemas que requieren recursos exponenciales para resolverse y verificarse se denominan problemas en PSPACE. La razón por la que se denominan PSPACE es que, aunque pueden requerir un tiempo exponencial para resolverse, no necesariamente requieren un espacio de memoria exponencial para ejecutar la búsqueda.

Esta clase de problemas se ha investigado ampliamente, pero no se ha descubierto ningún algoritmo eficiente para resolverlos. Muchos investigadores creen que no existe ningún algoritmo eficiente para resolver estos problemas. Si se pudiera descubrir una solución eficiente a estos problemas, también sería posible reutilizar el algoritmo para romper todos los cifrados modernos y alterar fundamentalmente la informática tal como la conocemos.

A pesar de los incentivos significativos para encontrar soluciones eficientes a estos problemas, la evidencia sugiere que es probable que tales soluciones no existan. Estos problemas son tan desafiantes que no se pueden proporcionar pruebas fácilmente verificables (testigos) incluso si se resuelven correctamente.

#### Ejemplos de problemas en PSPACE
##### Ejemplo 1 de PSPACE: Encontrar el movimiento óptimo en ajedrez
![Imagen de un tablero de ajedrez](https://static.wixstatic.com/media/935a00_71d5fe7538a847ccaef0c82b5bea6b57~mv2.jpeg/v1/fill/w_360,h_360,al_c,q_85,enc_auto/935a00_71d5fe7538a847ccaef0c82b5bea6b57~mv2.jpeg)

Supongamos que le preguntamos a una computadora poderosa: "Dado este tablero de ajedrez con las piezas en esta posición, ¿cuál es el próximo movimiento óptimo?"

La computadora responde "mueva el peón negro en f4 a f3".

¿Cómo puede confiar en que la computadora le está dando la respuesta correcta?

No hay una manera eficiente de comprobarlo; hay que hacer el mismo trabajo que hizo la computadora. Esto implica hacer una búsqueda completa a través de todos los posibles estados futuros del tablero. No hay ningún testigo que la computadora pueda proporcionarnos que nos permita confirmar que "mover el peón negro en f4 a f3" es en realidad el siguiente mejor movimiento. De esta manera, la naturaleza de este problema es muy diferente de los ejemplos discutidos anteriormente: no podemos verificar de manera eficiente que el movimiento óptimo declarado sea el verdadero movimiento óptimo.

En este ejemplo, el "testigo" presentado por la computadora consiste en todos los posibles estados futuros del juego. Sin embargo, el volumen masivo de estos datos hace que sea prácticamente imposible verificar la precisión de la solución de manera eficiente.

##### Ejemplo 2 de PSPACE: Determinar si las expresiones regulares son equivalentes
Las dos expresiones regulares, `a+` y `aa*`, coinciden con las mismas cadenas. Si una cadena coincide con la primera expresión regular, también coincidirá con la segunda, y viceversa.

Sin embargo, comprobar si dos expresiones regulares *arbitrarias* son equivalentes requiere un tiempo de cálculo exponencial. Incluso si una computadora potente le dijera que coinciden con las mismas cadenas, no hay una prueba breve (testigo) que la computadora pueda darle para demostrar que las respuestas son correctas. De manera similar al ejemplo del ajedrez, tendría que buscar en un espacio muy grande de cadenas para comprobar si las expresiones regulares son equivalentes, y eso tomará un tiempo exponencial.

Tanto el ajedrez como la equivalencia de expresiones regulares tienen una característica común: ambos requieren recursos exponenciales para encontrar respuestas y recursos exponenciales para verificar las respuestas.

#### Problemas que requieren un uso computacional aún más intensivo que PSPACE
Hay problemas que son tan difíciles que requieren un tiempo exponencial y una memoria exponencial para resolverlos, pero esos problemas suelen ser teóricos y no aparecen con frecuencia en el mundo real.

Un ejemplo de este tipo de problema son las damas, con una regla según la cual las piezas nunca pueden moverse a una posición que recree un estado anterior del tablero. Para asegurarnos de no repetir un estado del tablero en un juego mientras exploramos el espacio de posibles movimientos, tenemos que llevar un registro de todos los estados del tablero que ya se han visitado. Dado que la duración del juego puede ser exponencial en el tamaño del tablero, los requisitos de memoria también son exponenciales.

### Problemas en NP: Algunos problemas se pueden verificar rápidamente, pero no calcular rápidamente
Si podemos verificar rápidamente la solución de un problema, entonces el problema es en NP. Sin embargo, encontrar la solución puede requerir recursos exponenciales.

Cualquier problema cuya solución propuesta (testigo) se pueda verificar rápidamente como correcta es un problema NP. Si el problema también tiene un algoritmo para encontrar la solución en tiempo polinomial, entonces es un problema P. Todos los problemas P son problemas NP, pero es extremadamente improbable que todos los problemas NP también sean problemas P.

Ejemplos de problemas en NP. Estos se explican con más detalle a continuación:
- Calcular la solución de un sudoku: verificar la solución propuesta para un sudoku.
- Calcular la tricoloración de un mapa (si existe): verificar una tricoloración propuesta de un mapa.
- Encontrar una asignación a una fórmula booleana que dé como resultado verdadero: verificar la asignación propuesta hace que la fórmula dé como resultado verdadero.

**Nota:** NP significa polinomio no determinista. No entraremos en la jerga sobre el origen de ese nombre; solo damos el nombre para que el lector no piense erróneamente que significa "tiempo no polinomial".

#### Ejemplos de problemas en NP
##### Ejemplo 1 de NP: Sudoku
En el juego Sudoku, se le da a un jugador una cuadrícula de $9 \times 9$ con algunos números completos. El objetivo es que el jugador complete el resto de la cuadrícula con los números del 1 al 9 de manera que ningún número aparezca más de una vez en cualquier fila, columna o casilla de $3 \times 3$ (las que están delineadas con líneas en negrita). Las siguientes imágenes de [Wikipedia](https://en.wikipedia.org/wiki/Sudoku) ilustran esto. En la primera imagen, vemos la cuadrícula de 9x9 tal como se le da al jugador. En la segunda imagen, vemos la solución del jugador.

![Un sudoku incompleto](https://static.wixstatic.com/media/935a00_697037a2589d4091a95a9123d3796b4c~mv2.png/v1/fill/w_300,h_300,al_c,lg_1,q_85,enc_auto/935a00_697037a2589d4091a95a9123d3796b4c~mv2.png)

![Un sudoku completo [rompecabezas](https://static.wixstatic.com/media/935a00_2b17812514524ee584f0d9e7c340c73f~mv2.png/v1/fill/w_300,h_300,al_c,lg_1,q_85,enc_auto/935a00_2b17812514524ee584f0d9e7c340c73f~mv2.png)

Dada una *solución* de un sudoku, podemos verificar rápidamente que la solución es correcta simplemente recorriendo las columnas, filas y subcuadrículas de $3\times 3$. El testigo puede verificarse en tiempo polinomial.

Sin embargo, *calcular* la solución requiere significativamente más recursos: hay una cantidad exponencial de combinaciones para buscar. Para una cuadrícula de $9\times 9$, esto no es difícil para una computadora. Sin embargo, si permitimos que el sudoku sea arbitrariamente grande: cada lado tiene un tamaño $n$, donde $n$ es un múltiplo de 9. En ese caso, la dificultad de encontrar la solución crece exponencialmente con $n$.

##### Ejemplo 2 de NP: Tricoloración de un mapa
Cualquier mapa 2D de territorios puede ser “coloreado” con solo cuatro colores (ver el [teorema de los cuatro colores](https://en.wikipedia.org/wiki/Four_color_theorem)). Es decir, podemos asignar un color único (uno de los cuatro colores) a cada territorio de modo que ningún territorio vecino comparta el mismo color. Por ejemplo, la siguiente imagen (de [Wikipedia](https://en.wikipedia.org/wiki/U.S._state#/media/File:Map_of_USA_with_state_names_2.svg)) muestra los Estados Unidos coloreados con cuatro colores: rosa, verde, amarillo y rojo. Tómese un momento para observar la verificación de que no se ha asignado el mismo color a dos estados en contacto:

![Un mapa de los Estados Unidos coloreado con cuatro colores](https://static.wixstatic.com/media/935a00_80bcbb69d39348819f674827b8c25691~mv2.png/v1/fill/w_200,h_123,al_c,lg_1,q_85,enc_auto/935a00_80bcbb69d39348819f674827b8c25691~mv2.png)

El problema de los tres colores pregunta si un mapa se puede colorear usando solo tres colores en lugar de cuatro. Descubrir un tricolor (si existe) es un problema de búsqueda que requiere un uso intensivo de recursos computacionales. Sin embargo, verificar una *propuesta* de 3 colores es fácil: recorra cada una de las regiones y verifique que ninguna región vecina tenga el mismo color que el territorio que se está verificando actualmente.

Resulta que no es posible aplicar 3 colores a los Estados Unidos.

Las razones por las que un mapa en particular no puede tener 3 colores varían, pero en el caso de los Estados Unidos, Nevada (la región <span style="color:red">roja</span> en el mapa a continuación) está rodeada por cinco territorios. Coloreamos Nevada con un color, luego debemos alternar los colores de sus territorios vecinos. Sin embargo, cuando terminemos de rodear a los vecinos de Nevada, terminaremos con un territorio que tiene vecinos con tres colores en sus límites, lo que no deja ningún color válido para el territorio sin colorear.

![Un mapa que muestra Nevada y los estados circundantes](https://static.wixstatic.com/media/935a00_5ddfcf6c6b0f4920bdb3624fbab031d9~mv2.jpg/v1/fill/w_449,h_337,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/935a00_5ddfcf6c6b0f4920bdb3624fbab031d9~mv2.jpg)

Aquí hay un [video rápido e interesante sobre mapas de 3 colores](https://www.youtube.com/watch?v=WlcXoz6tn4g) si desea obtener más información sobre este problema.

Sin embargo, es posible aplicar tres colores a Australia:

![A 3 Coloring of Australia](https://static.wixstatic.com/media/935a00_d8396ac3cd15406281b6c83deb2abc71~mv2.jpg/v1/fill/w_348,h_314,al_c,lg_1,q_85,enc_auto/935a00_d8396ac3cd15406281b6c83deb2abc71~mv2.jpg)

No todos los mapas pueden tener tres colores. Calcular un tricolor para un mapa 2D arbitrario, si existe, no se puede hacer de manera eficiente; por lo general, se requiere una búsqueda de fuerza bruta que puede llevar un tiempo exponencial.

Sin embargo, si alguien resuelve un tricolor, es fácil verificar su solución.

### La relación entre P, NP y PSPACE
#### Recursos computacionales para cada clase
La siguiente tabla resume los recursos computacionales necesarios para cada clase de problema:

| Categoría | Tiempo de cálculo | Tiempo de verificación |
| --- | --- | --- |
| P | Debe ser polinomial o mejor | Debe ser polinomial o mejor
| NP | Sin requisitos | Debe ser polinomial o mejor |
| PSPACE | Sin requisitos | Sin requisitos |

#### Jerarquía de dificultad entre P, NP y PSPACE
Cualquier problema que requiera recursos exponenciales para verificar el testigo es un PSPACE (o un problema más difícil). Si una persona tiene recursos exponenciales para verificar testigos para problemas PSPACE, puede calcular de manera trivial soluciones para cualquier problema P o NP. Por lo tanto, todos los problemas P y NP son un subconjunto de los problemas PSPACE, como se ilustra en la siguiente figura.

En otras palabras, si tienes una computadora lo suficientemente potente para resolver o verificar una clase de problema en el círculo más grande, puedes resolver o verificar un subconjunto de él:

![Jerarquía de clases de complejidad computacional](https://static.wixstatic.com/media/935a00_9a3130175f2945eb8ae7a4d975b36f55~mv2.jpg/v1/fill/w_511,h_383,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/935a00_9a3130175f2945eb8ae7a4d975b36f55~mv2.jpg)

### El problema P vs. NP
P es la clase de problemas que se pueden resolver y verificar de manera eficiente, mientras que NP es la clase de problemas que se pueden verificar de manera eficiente. La pregunta "P vs NP" pregunta, simplemente, si estas dos clases son la misma.

Si P = NP, significaría que siempre que podemos encontrar un método eficiente para verificar una solución, también podemos encontrar un método eficiente para encontrar esa solución. Recuerde que encontrar una solución es siempre al menos tan difícil como verificarla. (Por definición, resolver un problema incluye encontrar la respuesta correcta, lo que significa que un algoritmo que resuelve el problema también verifica su respuesta en el proceso).

Si P = NP es cierto, eso significa que hay un algoritmo eficiente para calcular sudokus (de tamaño arbitrario) y encontrar si existe un color triple. También significa que hay un algoritmo eficiente para descifrar la mayoría de los algoritmos criptográficos modernos.

Actualmente, sigue sin demostrarse si P y NP son el mismo conjunto. Aunque se han hecho numerosos intentos para encontrar algoritmos eficientes para problemas NP, toda la evidencia sugiere que tales algoritmos no existen.

De manera similar, sigue sin saberse si existen soluciones eficientes o mecanismos de verificación para los problemas PSPACE. Aunque los investigadores especulan ampliamente que P ≠ NP y NP ≠ PSPACE, no existe ninguna prueba matemática formal de estas conclusiones. Por lo tanto, a pesar de los grandes esfuerzos, siguen sin descubrirse soluciones eficientes para los problemas NP y métodos de verificación eficientes para los problemas PSPACE.

Para fines prácticos, podemos suponer que P ≠ NP y NP ≠ PSPACE. De hecho, hacemos esa suposición implícitamente cuando confiamos datos importantes a algoritmos criptográficos modernos.

## Parte 2: Expresar problemas y soluciones como fórmulas booleanas
Lo que une a los problemas P y NP es que su solución se puede verificar rápidamente. Sería extremadamente útil si pudiéramos describir todos esos problemas (P y NP) y sus soluciones en un lenguaje común. Es decir, queremos una codificación del problema que funcione para problemas tan diversos como probar que una lista está ordenada, probar que un sudoku está resuelto o probar que tenemos un colorante de tres.

**La verificación de una solución a un problema en NP o P se puede lograr verificando una solución a una fórmula booleana que modela el problema.**

Lo que queremos decir con "una fórmula booleana que modela el problema" quedará claro a medida que describamos lo que queremos decir con "una solución a una fórmula booleana" y observemos algunos ejemplos de modelado de problemas con fórmulas booleanas.

### Soluciones a una fórmula booleana
Para expresar una fórmula booleana, utilizamos el operador $¬$ para representar el NO booleano, $∧$ para representar el AND booleano y $∨$ para representar el OR booleano. Por ejemplo, $a ∧ b$ se evalúa como verdadero si y solo si $a$ y $b$ son ambos verdaderos. $a ∧ ¬b$ se evalúa como verdadero si y solo si $a$ es verdadero y $b$ es falso.

Supongamos que tenemos un conjunto de variables booleanas $x₁$, $x₂$, $x₃$, $x₄$ y una fórmula booleana:

$$
out = (x₁ ∨ ¬x₂ ∨ ¬ x₃) ∧ (¬x₂ ∨ x₃ ∨ x₄) ∧ (x₁ ∨ x₃ ∨ ¬x₄) ∧ (¬x₂ ∨ ¬x₃∨ ¬x₄)
$$

La pregunta es: ¿podemos encontrar valores para $x₁, x₂, x₃, x₄$ tales que $out$ sea verdadero? Para la fórmula anterior, podemos. Escribiendo $T$ para verdadero y $F$ para falso, podemos escribir nuestra solución como:

$$
\begin{align*}
x₁ = T \\
x₂ = F \\
x₃ = T \\
x₄ = F
\end{align*}
$$

Sustituyendo la solución en la fórmula obtenemos:

$$
\begin{align*}
x₁ &= T \\
x₂ &= F \\
x₃ &= T \\
x₄ &= F \\
out &= (x₁ ∨ ¬x₂ ∨ ¬ x₃) ∧ (¬x₂ ∨ x₃ ∨ x₄) ∧ 
      (x₁ ∨ x₃ ∨ ¬x₄)∧ (¬x₂ ∨ ¬x₃∨ ¬x₄) \\
out &= (T ∨ ¬ F ∨ ¬ T) ∧ (¬ F ∨ T ∨ F) ∧
      (T ∨ T ∨ ¬ F) ∧ (¬ F ∨ ¬ T ∨ ¬ F) \\

&= (T) ∧ (T) ∧ (T) ∧ (T) \\

&= T \\
\end{align*}
$$

Eso fue fácil de verificar, pero descubrir la solución para una fórmula booleana muy grande podría requerir tiempo exponencial. Encontrar una solución para una fórmula booleana es un problema NP en sí mismo: puede requerir recursos exponenciales para encontrar la solución, pero verificarla se puede hacer en tiempo polinomial.

Pero debemos enfatizar: nuestro uso de fórmulas booleanas no es para resolverlas, solo para verificar las soluciones propuestas para ellas.

### Todos los problemas en P y NP se pueden verificar transformándolos en fórmulas booleanas y mostrando una solución a la fórmula
En los siguientes ejemplos, la entrada es un problema P o NP y la salida es una fórmula booleana. Si conocemos la solución al problema original, entonces también sabremos la solución a la fórmula booleana.

Nuestra intención es mostrar que conocemos el testigo del problema original, pero en forma booleana.

#### Ejemplo 1: verificar si una lista está ordenada usando una fórmula booleana
Considere los números binarios de un bit $A$ y $B$. La siguiente tabla de verdad devuelve verdadero cuando $A > B$:

| A | B | A > B |
| --- | --- | --- |
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

La columna $A > B$ se puede modelar con la expresión $A ∧ ¬B$, que devuelve verdadero en la única fila donde $A > B$ es uno.

Ahora considere una tabla que expresa $A = B$:

| A | B | A = B |
| --- | --- | --- |
| 0 | 0 | 1 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

La columna $A = B$ se puede modelar con la expresión $(A ∧ B) ∨ ¬(A ∨ B)$. $(A ∧ B)$ devuelve verdadero cuando $A = 1$ y $B = 1$ y $¬(A ∨ B)$ devuelve verdadero cuando $A$ y $B$ son ambos cero.

Las expresiones para números de un bit:

$$
\begin{align*}
A > B &\rightarrow A ∧ ¬B \\
A = B &\rightarrow (A ∧ B) ∨ ¬(A ∨ B)
\end{align*}
$$

serán útiles en breve.

Ahora, ¿cómo comparamos números binarios de más de un bit?

##### Comparación binaria por el bit más significativo diferente
Suponga que comienza desde el bit más significativo (MSB) más a la izquierda de ambos números y se mueve hacia el bit menos significativo (LSB) de la derecha. En el primer bit, donde los dos números difieren:

Si $P$ tiene un valor de $1$ en ese bit y $Q$ tiene un valor de $0$, entonces $P ≥ Q$.
La siguiente animación ilustra el algoritmo que detecta que $P ≥ Q$:

![Algoritmo para comprobar si P es mayor o igual a Q](https://static.wixstatic.com/media/935a00_4dc4955706b54e778847f861f651e486~mv2.gif)

Si $P = Q$, entonces todos los bits son iguales. $P = Q$ significa que $P ≥ Q$ también es cierto:
![Algoritmo para probar P = Q](https://static.wixstatic.com/media/935a00_186a696a8b14493a8d6cd17d7f7bfe0d~mv2.gif)

Si P < Q, entonces detectaremos que en el primer bit donde Q es 1 y P es 0:

![Detección si P < Q](https://static.wixstatic.com/media/935a00_bba4e16f05d34184945faf33fd9a8c53~mv2.gif)

Supongamos, sin pérdida de generalidad, que numeramos los bits en $P$ como $p₄, p₃, p₂, p₁$ y los bits en $Q$ como $q₄, q₃, q₂, q₁$.

Si $P ≥ Q$ entonces una de las siguientes condiciones debe ser verdadera:
- $p₄ > q₄$
- $p₄ = q₄$ y $p₃ > q₃$
- $p₄ = q₄$ y $p₃ = q₃$ y $p₂ > q₂$
- $p₄ = q₄$ y $p₃ = q₃$ y $p₂ = q₂$ y $(p₁ > q₁ \text{ or } p₁ = q₁)$

Podemos combinar los puntos en una sola ecuación.

$$
\begin{align*}
&((p₄ > q₄)) ∨ \\
&((p₄ = q₄) ∧ (p₃ > q₃)) ∨ \\
&((p₄ = q₄) ∧ (p₃ = q₃) ∧ (p₂ > q₂)) ∨ \\
&((p₄ = q₄) ∧ (p₃ = q₃) ∧ (p₂ = q₂) ∧ ((p₁ > q₁) ∨ (p₁ = q₁)))
\end{align*}
$$

Recuerde nuestras expresiones booleanas que modelaron la igualdad y comparación de un bit:

$$
\begin{align*}
A > B &== A ∧ ¬B\\
A = B y== (A ∧ B) ∨ ¬(A ∨ B)
\end{align*}
$$

Podemos sustituir las expresiones para la fórmula $A > B$ y $A = B$ en la ecuación anterior. Para evitar un muro de matemáticas, mostramos las operaciones en formato de video a continuación:

<video autoplay loop muted controls>
<source src="https://video.wixstatic.com/video/935a00_655f627a117f46ecb0a48deb2640b9a1/1080p/mp4/file.mp4" type="video/mp4">
</video>

La fórmula booleana final que expresa $P ≥ Q$, para 4 bits, es:

$$
\begin{align*}
&(p₄ ∧ ¬q₄) ∨ \\
&(((p₄ ∧ q₄) ∨ ¬(p₄ ∨ q₄)) ∧ (p₃ ∧ ¬q₃)) ∨ \\
&(((p₄ ∧ q₄) ∨ ¬(p₄ ∨ q₄)) ∧ ((p₃ ∧ q₃) ∨ ¬(p₃ ∨ q₃)) ∧ (p₂ ∧ ¬q₂)) ∨ \\
&(((p₄ ∧ q₄) ∨ ¬(p₄ ∨ q₄)) ∧ ((p₃ ∧ q₃) ∨ ¬(p₃ ∨ q₃)) ∧ ((p₂ ∧ q₂) ∨ ¬(p₂ ∨ q₂)) ∧ ((p₁ ∧ ¬q₁) ∨ ((p₁ ∧ q₁) ∨ ¬(p₁ ∨ q₁))))
\end{align*}
$$

Llamemos a una expresión booleana que compara dos números binarios de la manera descrita anteriormente una "expresión de comparación".

##### Cómo comprobar si una lista está ordenada
Dada una fórmula booleana para comparar números de un tamaño fijo, podemos aplicar repetidamente la expresión de comparación a cada par de elementos adyacentes de la lista y combinar las expresiones de comparación utilizando la operación AND. La lista está ordenada si y solo si la operación AND de todas las expresiones de comparación es verdadera.

Por lo tanto, vemos que un testigo que demuestra que una lista está ordenada no tiene por qué ser la lista ordenada. También puede ser la entrada a la fórmula booleana que creamos anteriormente que da como resultado que la fórmula devuelva verdadero.

#### Ejemplo 2: Un coloreado de 3 colores como una fórmula booleana
Veamos nuestro mapa de Australia nuevamente:

![Un coloreado de 3 colores de Australia](https://static.wixstatic.com/media/935a00_d8396ac3cd15406281b6c83deb2abc71~mv2.jpg/v1/fill/w_348,h_314,al_c,lg_1,q_85,enc_auto/935a00_d8396ac3cd15406281b6c83deb2abc71~mv2.jpg)

Para modelar la solución como una fórmula booleana, la fórmula debe codificar los siguientes hechos:

- Cada territorio tiene uno de tres colores
- Cada territorio tiene un color diferente al de su vecino

Por ejemplo, para decir que Australia Occidental es verde, azul o roja, necesitamos crear tres Variables `WESTERN_AUSTRALIA_GREEN`, `WESTERN_AUSTRALIA_BLUE`,`WESTERN_AUSTRALIA_RED`. Para evitar nombres de variable largos, las llamaremos `WA_G`, `WA_B` y `WA_R`. Nuestra fórmula booleana es entonces:

```
(WA_G ∧ ¬WA_B ∧ ¬WA_R) ∨ (¬WA_G ∧ WA_B ∧ ¬WA_R) ∨ (¬WA_G ∧ ¬WA_B ∧ WA_R)
```

En otras palabras:

"(Australia Occidental es <span style="color:Green">verde</span> Y Australia Occidental NO es <span style="color:#008aff">azul</span> Y Australia Occidental NO es <span style="color:red">roja</span>)

O

(Australia Occidental NO es <span style="color:Green">verde</span> Y Australia Occidental es <span style="color:#008aff">azul</span> Y Australia Occidental NO es <span style="color:red">roja</span>)

O

(Australia Occidental NO es <span style="color:Green">verde</span> Y Australia Occidental NO es <span style="color:#008aff">azul</span> Y Australia Occidental es <span style="color:red">roja</span>)"

Coloreando la fórmula booleana para enfatizar:

(<span style="color:Green">WA_G</span> ∧ ¬WA_B ∧ ¬WA_R) ∨ (¬WA_G ∧ <span style="color:#008aff">WA_B</span> ∧ ¬WA_R) ∨ (¬WA_G ∧ ¬WA_B ∧ <span style="color:red">WA_R</span>)

Llamemos a la fórmula anterior *restricción de asignación de color*.

Usamos variables booleanas para codificar el color asignado a un territorio. Dado que una variable booleana solo puede contener dos valores, pero un territorio puede tener uno de tres colores, a cada territorio se le asignan tres variables booleanas, una para cada color. Si a un territorio se le asigna un color en particular, la variable correspondiente se establece en verdadero y las demás se establecen en falso.

La fórmula anterior es verdadera si y solo si al territorio de Australia Occidental se le asigna exactamente un color.

##### Restricción de color vecina
A continuación, queremos escribir una fórmula que exprese que WA tiene un color diferente al de su vecina. Creamos tres variables para SA (Australia del Sur) como hicimos para WA. Ahora, nuestra fórmula simplemente dice: "para cada color, WA y SA no son ambos de ese color". Esto es equivalente a decir "WA y SA no son del mismo color". Usemos los nombres de variable `SA_G`, `SA_B` y `SA_R` para referirnos a la asignación de color de Australia del Sur (que es vecina de Australia Occidental). Usamos la siguiente fórmula para expresar que tienen diferentes colores:

<span style="color:Green">¬(WA_G ∧ SA_G)</span> ∧ <span style="color:#008aff">¬(WA_B ∧ SA_B)</span> ∧ <span style="color:red">¬(WA_R ∧ SA_R)</span>

En otras palabras:

**NO** es el caso de que (Australia Occidental sea <span style="color:Green">verde</span> Y Australia del Sur sea <span style="color:Green">verde</span>)

**Y**

**NO** es el caso de que (Australia Occidental sea <span style="color:#008aff">azul</span> Y Australia del Sur sea <span style="color:#008aff">azul</span>)

**Y**

**NO** es el caso de que (Australia Occidental sea <span style="color:#008aff">azul</span>) es <span style="color:red">rojo</span> Y Australia del Sur es <span style="color:red">rojo</span>)"

La fórmula anterior se cumplirá si y solo si a Australia Occidental y Australia del Sur no se les asignó el mismo color. Llamemos a la fórmula anterior *restricción de límite*.

Necesitamos aplicar la restricción de asignación de color a cada territorio y la restricción de color diferente a cada par de vecinos, luego aplicar Y a todas las restricciones juntas.

##### Una fórmula para modelar una coloración 3 de Australia
Ahora mostramos la fórmula booleana final que verifica una coloración 3 válida para Australia. Aquí están los territorios etiquetados:

![3-coloración de Australia etiquetada con colores para los territorios](https://static.wixstatic.com/media/935a00_824140c195b64b20bb5351d8d54464d8~mv2.jpg/v1/fill/w_348,h_314,al_c,lg_1,q_85,enc_auto/935a00_824140c195b64b20bb5351d8d54464d8~mv2.jpg)

Primero, asignamos a cada territorio un nombre de variable:

- `WA` = Australia Occidental
- `SA` = Australia del Sur
- `NT` = Territorio del Norte
- `Q` = Queensland
- `NSW` = Nueva Gales del Sur
- `V` = Victoria

###### Restricciones de color: Cada uno de los seis territorios tiene exactamente un color:

<span style="color:gris">

1. (<span style="color:Verde">WA_G</span> ∧ ¬WA_B ∧ ¬WA_R) ∨ (¬WA_G ∧ <span style="color:#008aff">WA_B</span> ∧ ¬WA_R) ∨ (¬WA_G ∧ ¬WA_B ∧ <span style="color:Rojo">WA_R</span>)

2. (<span style="color:Verde">SA_G</span> ∧ ¬SA_B ∧ ¬SA_R) ∨ (¬SA_G ∧ <span style="color:#008aff">SA_B</span> ∧ ¬SA_R) ∨ (¬SA_G ∧ ¬SA_B ∧ <span style="color:Rojo">SA_R</span>)

3. (<span style="color:Verde">NT_G</span> ∧ ¬NT_B ∧ ¬NT_R) ∨ (¬NT_G ∧ <span style="color:#008aff">NT_B</span> ∧ ¬NT_R) ∨ (¬NT_G ∧ ¬NT_B ∧ <span style="color:Rojo">NT_R</span>)

4. (<span style="color:Verde">Q_G</span> ∧ ¬Q_B ∧ ¬Q_R) ∨ (¬Q_G ∧ <span style="color:#008aff">Q_B</span> ∧ ¬Q_R) ∨ (¬Q_G ∧ ¬Q_B ∧ <span style="color:Rojo">Q_R</span>)

5. (<span style="color:Verde">NSW_G</span> ∧ ¬NSW_B ∧ ¬NSW_R) ∨ (¬NSW_G ∧ <span style="color:#008aff">NSW_B</span> ∧ ¬NSW_R) ∨ (¬NSW_G ∧ ¬NSW_B ∧ <span style="color:Rojo">NSW_R</span>)

6. (<span style="color:Verde">V_G</span> ∧ ¬V_B ∧ ¬V_R) ∨ (¬V_G ∧ <span style="color:#008aff">V_B</span> ∧ ¬V_R) ∨ (¬V_G ∧ ¬V_B ∧ <span style="color:Red">V_R</span>)

</span>

###### Restricciones de límites: cada territorio vecino no comparte un color

A continuación, iteramos a través de los límites y calculamos una restricción de límites para esos vecinos. El siguiente video muestra el algoritmo en acción. Mostramos el conjunto final de fórmulas para las condiciones de límites después del video:

<video autoplay loop muted controls>
<source src="https://video.wixstatic.com/video/935a00_d942bd31ee0d4e0087a0c3fe5ec8b75a/1080p/mp4/file.mp4" type="video/mp4">
</video>

7. Australia Occidental y Australia del Sur:

¬(<span style="color:Green">WA_G ∧ SA_G</span>) ∧ ¬(<span style="color:#008aff">WA_B ∧ SA_B</span>) ∧ ¬(<span style="color:Red">WA_R ∧ SA_R</span>)

8. Australia Occidental y Territorio del Norte:

¬(<span style="color:Green">WA_G ∧ NT_G</span>) ∧ ¬(<span style="color:#008aff">WA_B ∧ NT_B</span>) ∧ ¬(<span style="color:Red">WA_R ∧ NT_R</span>)

9. Territorio del Norte y Australia del Sur:

¬(<span style="color:Green">NT_G ∧ SA_G</span>) ∧ ¬(<span style="color:#008aff">NT_B ∧ SA_B</span>) ∧ ¬(<span style="color:Red">NT_R ∧ SA_R</span>)

10. Territorio del Norte y Queensland:

¬(<span style="color:Green">NT_G ∧ Q_G</span>) ∧ ¬(<span style="color:#008aff">NT_B ∧ Q_B</span>) ∧ ¬(<span style="color:Red">NT_R ∧ Q_R</span>)

11. Australia del Sur y Queensland:

¬(<span style="color:Green">SA_G ∧ Q_G</span>) ∧ ¬(<span style="color:#008aff">SA_B ∧ Q_B</span>) ∧ ¬(<span style="color:Red">SA_R ∧ Q_R</span>)

12. Australia del Sur y Nueva Gales del Sur:

¬(<span style="color:Green">SA_G ∧ NSW_G</span>) ∧ ¬(<span style="color:#008aff">SA_B ∧ NSW_B</span>) ∧ ¬(<span style="color:Red">SA_R ∧ NSW_R</span>)

13. Australia del Sur y Victoria:

¬(<span style="color:Green">SA_G ∧ V_G</span>) ∧ ¬(<span style="color:#008aff">SA_B ∧ V_B</span>) ∧ ¬(<span style="color:Red">SA_R ∧ V_R</span>)

14. Queensland y Nueva Gales del Sur:

¬(<span style="color:Green">Q_G ∧ NSW_G</span>) ∧ ¬(<span style="color:#008aff">Q_B ∧ NSW_B</span>) ∧ ¬(<span style="color:Red">Q_R ∧ NSW_R</span>)

15. Nueva Gales del Sur y Victoria:

¬(<span style="color:Green">NSW_G ∧ V_G</span>) ∧ ¬(<span style="color:#008aff">NSW_B ∧ V_B</span>) ∧ ¬(<span style="color:Red">NSW_R ∧ V_R</span>)

Creamos una fórmula booleana tomando el AND booleano de las 15 fórmulas mencionadas anteriormente. Tener una asignación a las variables que dé como resultado que el resultado de la expresión booleana sea verdadero es equivalente a tener una coloración 3 válida de Australia.

En otras palabras, si conocemos una coloración 3 válida para Australia, entonces también conocemos una asignación a la fórmula booleana construida anteriormente.

### La fórmula booleana debe ser construible en tiempo polinomial
Solo necesitamos tomar una cantidad polinomial de pasos para construir esta fórmula booleana para la coloración 3. Específicamente, necesitamos:

- 3 restricciones de color por territorio
- Como máximo N restricciones de color vecinas por territorio

Es un requisito que los pasos tomados para construir la fórmula booleana se realicen en tiempo polinomial. Si se requiere una cantidad exponencial de pasos, entonces la fórmula booleana será exponencialmente grande y el testigo será exponencialmente grande, y no verificable en tiempo polinomial.

### Resumen del uso de expresiones booleanas para modelar problemas y soluciones propuestas
Todos los problemas en P y NP se pueden expresar como una fórmula booleana que da como resultado verdadero si conocemos la asignación de variable correspondiente (testigo), que codifica una solución correcta al problema original.

Ahora que tenemos un lenguaje estándar para demostrar eficientemente una solución a un problema, estamos un paso más cerca de un método estándar para demostrar que tenemos una solución a un problema, sin revelar la solución, es decir, Zero Knowledge Proofs.

## Parte 3: P vs NP y ZK Proofs
### Cómo se relaciona P = NP con las ZK Proofs
El "conocimiento" en las Zero Knowledge Proofs se refiere al conocimiento del testigo.

Las ZK proofs se ocupan del aspecto de verificación del cálculo. Es decir, dado que ha encontrado una solución de Sudoku o una coloración triple de un mapa, ¿puede darle a alguien evidencia (testigo) que le permita verificar eficientemente que su solución es correcta?

Las ZK proofs buscan demostrar que usted conoce al testigo sin revelarlo.

### Las ZK Proofs solo funcionan con problemas P o NP. No se pueden usar para problemas que no podemos verificar eficientemente.
Si no tenemos un mecanismo para probar eficientemente que las expresiones regulares son equivalentes, o que un cierto movimiento en ajedrez es óptimo, entonces las ZK Proofs no pueden permitirnos mágicamente producir una prueba tan eficiente.

Para los problemas P y NP, la verificación de la solución se puede hacer eficientemente. ZK permite verificar que la solución es válida mientras oculta los detalles del cálculo. Además, ZK no puede ayudarlo a descubrir una solución para un sudoku o descubrir una coloración triple de un mapa. Sin embargo, puede ayudarlo a probarle a otra parte que tiene una solución, si ya la calculó.

### La conexión entre P vs NP y las Zero Knowledge Proofs

**Todos los problemas con soluciones que se pueden verificar rápidamente se pueden convertir en una fórmula booleana.**

Poder convertir cualquier problema en una fórmula booleana no es un truco para encontrar la respuesta de manera eficiente. Resolver una expresión booleana arbitraria es un problema NP y encontrar una solución puede ser difícil.

El tamaño de la fórmula booleana es importante. Volviendo a nuestro ejemplo de ajedrez, si intenta modelar cada estado con una fórmula booleana, entonces el tamaño de su fórmula será exponencialmente grande. Por lo tanto, los únicos problemas factibles son NP o P, que tienen fórmulas booleanas de tamaño razonable que los modelan.

**En la literatura de ZK, a menudo nos referimos a las fórmulas booleanas como circuitos booleanos.**

Crear una zero knowledge proof para un problema se reduce a traducir el problema a un circuito, como se demuestra al probar una tricoloración para Australia o validar una lista ordenada. Luego, demuestras que tienes una entrada válida al circuito (el testigo), que finalmente se transforma en una prueba de conocimiento cero.

La capacidad de verificar eficientemente una solución a un problema es un prerrequisito para crear una zero knowledge proof de que tienes una solución. Uno debe ser capaz de construir un circuito booleano para modelar la solución de manera eficiente. Sin embargo, para problemas como determinar movimientos óptimos de ajedrez, que pertenecen a PSPACE, este enfoque da como resultado circuitos exponencialmente grandes, lo que los hace poco prácticos.

En conclusión, las pruebas de conocimiento cero son factibles solo para problemas dentro de P y NP, donde es posible una verificación eficiente de la solución. Sin una verificación eficiente, crear una prueba de conocimiento cero para un problema se vuelve inviable.

## Más información
Consulta el [Libro de ZK de RareSkills](https://www.rareskills.io/zk-book) para obtener más temas sobre zero knowledge proofs.

## Aspectos técnicos
En este artículo se han simplificado algunos conceptos para que sean lo más comprensibles posible para alguien que los vea por primera vez. La información presentada aquí es suficiente para explicar lo que las ZK Proofs pueden y no pueden hacer. Para aquellos interesados ​​en profundizar en el tema, aquí hay algunas aclaraciones:

- A un tablero de ajedrez de un tamaño fijo $(8 \times 8)$ no se le puede asignar un nivel de dificultad porque la dificultad del problema no se puede expresar como $\mathcal{O}(f(n))$. Técnicamente, decimos que el ajedrez de un tamaño arbitrario es PSPACE. Puede resultar confuso pensar en un tablero de ajedrez de $10 \times 10$, pero uno puede simplemente especificar que los espacios adicionales no tienen ninguna pieza en ellos en la posición inicial.

- El ajedrez tiene una regla menos conocida que establece que si no se ha producido ningún movimiento de captura y ningún peón se ha movido durante los últimos 50 movimientos, entonces un jugador puede declarar tablas. Esto coloca un límite en el espacio de búsqueda que lo coloca en PSPACE. Si se elimina esta regla, entonces esta versión de ajedrez está en EXPSPACE, una categoría de problemas que requiere tiempo exponencial y tamaño de memoria exponencial para calcularse.

- Algunos problemas NP se pueden resolver en *tiempo sub-exponencial*, pero para fines prácticos, su resolución lleva tiempo exponencial. Por ejemplo, $\mathcal{O}(2^{\sqrt{n}})$ es técnicamente sub-exponencial, pero sigue siendo exponencialmente difícil.

- Existen heurísticas muy poderosas para encontrar soluciones a algunos problemas NP. Aunque resolver tres coloraciones lleva un tiempo exponencial, muchas instancias del problema de tamaño razonable se pueden resolver rápidamente. Por ejemplo, [aquí hay problemas de referencia de mapas con 200 territorios y 3 coloraciones válidas](https://www.cs.ubc.ca/~hoos/SATLIB/benchm.html). Los algoritmos inteligentes pueden encontrar la solución sin explorar un espacio de búsqueda exponencialmente grande. Sin embargo, para cualquier heurística diseñada para acelerar la resolución de un problema NP, es posible crear una instancia patológica del problema que esté diseñada para explotar la heurística y hacerla inútil. Sin embargo, la heurística funciona bien para el caso típico de un ejemplo realista del problema.

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*
