# Teoría elemental de grupos para programadores

![Imagen destacada de la teoría de grupos](https://static.wixstatic.com/media/935a00_fd134878f9e449418c68ee94bc24cfd9~mv2.png/v1/fill/w_1000,h_1000,al_c,q_90,enc_auto/935a00_fd134878f9e449418c68ee94bc24cfd9~mv2.png)

Este artículo proporciona varios ejemplos de grupos algebraicos para que puedas hacerte una idea de ellos.

Un grupo es un conjunto con:

- un operador binario cerrado
- el operador binario también es asociativo
- un elemento identidad
- cada elemento tiene una inversa

También analizamos los grupos abelianos. Un grupo abeliano tiene el requisito adicional de que el operador binario sea conmutativo

Ahora es momento de analizar los grupos como una estructura matemática.

Un aspecto confuso sobre el uso de números enteros bajo la adición como ejemplo de un grupo es que los estudiantes suelen responder con "pero ¿no puedes multiplicar también números enteros?"

Es cierto que esto es confuso. Hay otras estructuras algebraicas que esperan dos operadores binarios (anillos y cuerpos), pero por ahora piense en un grupo bajo un operador binario fijo e inmutable y, desde la perspectiva del grupo, cualquier otro operador binario posible no existe o no es una preocupación.

Aquí es donde se vuelve aún más confuso. A veces, los operadores binarios son otros operadores binarios disfrazados.

Por ejemplo, cuando se trata de grupos que solo tienen adición, a veces los escritores se refieren casualmente a la multiplicación aunque el grupo no tenga ese operador binario. Lo que la multiplicación es en este contexto es en realidad una forma abreviada de repetir una operación de adición una cierta cantidad de veces.

## Ejemplos de grupos

La mejor manera de tener una idea de un grupo es ver muchos de ellos. Hagámoslo.

### 1. El grupo trivial

Sea nuestro grupo un conjunto formado por el número $\set{0}$ con el operador binario de adición. Está claro que el operador binario es cerrado y asociativo

$$
(0 + 0) + 0 = (0 + 0) + 0
$$

y cada elemento tiene una identidad y una inversa.

Este no es un grupo interesante, pero es el más pequeño válido que puedes crear.

Ten en cuenta que un grupo no puede estar vacío porque, por definición, debe contener un elemento identidad.

Como ejercicio para el lector, demuestra que el conjunto $\set{1}$ con el operador binario $\times$ es un grupo.

### 2. Los números reales no son un grupo bajo la multiplicación

Aunque los números reales ($\mathbb{R}$) bajo la multiplicación tienen una identidad (el número 1) y son cerrados y asociativos, no todos tienen una inversa.

Los números reales son invertibles tomando la inversa $(1 / n)$, pero el cero es un número real y no se puede invertir porque $1/0$ no es un número real.

Estrictamente hablando, la inversa de $a$, es $b$ tal que $ab = 1$. Aquí estamos diciendo que si $a = 0$ no hay ningún elemento en el conjunto $b$ tal que $ab = 1$.

Sin embargo, los números reales positivos excluyendo el cero son un grupo bajo la multiplicación. Cada elemento tiene una inversa ($1/n$), y el elemento identidad es 1.

**Ejercicio**: Los números enteros (positivos y negativos) no son un grupo bajo la multiplicación. Muestra cuáles de los cuatro requisitos (cerrado, asociativo, existencia de identidad, todos los elementos tienen una inversa) no se cumplen.

### 3. $n \times m$ matrices de números reales son un grupo bajo la adición

Vamos a resolverlo:

La adición de matrices es cerrada y asociativa. Si sumas una matriz de $n × m$ de números reales con otra matriz de $n × m$ de números reales, obtienes una matriz de $n × m$ de números reales.
La matriz identidad es una matriz de $n × m$ de todos ceros
la inversa de una matriz es esa matriz multiplicada por -1.
Un momento, no se nos permite multiplicar por -1, ¿verdad?

Un grupo no requiere que la inversa sea "computable usando el operador binario de grupo" solo para existir. El grupo de matrices de $n × m$ de números reales contiene inversas para cada elemento, y eso es lo que importa.

Si definimos nuestro operador como el producto de Hadamard (multiplicación elemento por elemento), este no puede ser un grupo por la misma razón que se explicó anteriormente.

Si definimos nuestro operador como la multiplicación tradicional de matrices sobre matrices cuadradas, esto puede ser o no un grupo dependiendo de la definición del conjunto, como veremos en el ejemplo 5 de la sección.

### 4. El conjunto de puntos 2D en un plano euclidiano bajo la adición de elementos es un grupo

En realidad, este es un caso especial del ejemplo anterior, pero veámoslo desde un ángulo diferente.

Consideremos que nuestro conjunto es el conjunto de todos los puntos $(x, y)$ de valor real en un plano 2D típico.

Nuestro operador binario es sumar puntos, por ejemplo $(1,1) + (2,2) = (3,3)$.

Nuestro elemento de identidad es el origen, porque sumar con él dará como resultado la misma ubicación del otro punto.

La inversa es simplemente la "imagen reflejada" sobre el origen (la $x$ y la $y$ invertidas) porque cuando las sumamos, dan como resultado el origen.

### 5. $n \times n$ matrices de determinante distinto de cero bajo multiplicación son un grupo

A modo de repaso, si una matriz tiene un determinante distinto de cero, entonces es invertible. Cuando una matriz de determinante distinto de cero se multiplica por otra matriz de determinante distinto de cero, entonces el producto también tiene un determinante distinto de cero. En realidad, podemos ser más específicos, si $A$, $B$ y $C$ son matrices cuadradas y $AB = C$, entonces $\det(a) \times \det(b) = \det(c)$.

Trabajemos con las definiciones

- La multiplicación de matrices de determinante distinto de cero es cerrada porque no se puede "salir del grupo" ya que el producto siempre tendrá determinante distinto de cero. La multiplicación de matrices es asociativa.
- El elemento identidad es la matriz identidad (todos ceros, excepto la diagonal principal que es uno).
- La inversa es simplemente la matriz inversa, y las matrices con determinante distinto de cero son invertibles.

### 6. $n \times n$ matrices con determinante cero bajo multiplicación son un grupo no

Recuerde, una matriz con determinante cero no se puede invertir, por lo que este conjunto no puede tener una inversa. En este caso, no tenemos un elemento identidad porque la matriz identidad tiene determinante uno. Como no tenemos ningún elemento identidad, este conjunto y operador binario ni siquiera es un monoide, es un semigrupo.

### 7. El conjunto de todos los polinomios de un grado fijo acotado superiormente es un grupo bajo adición

Si decimos "todos los polinomios con coeficientes reales de grado 7 como máximo bajo adición", este es un grupo válido.

- La suma de polinomios es cerrada y asociativa
- La identidad es el polinomio 0 (o $0x^0$ para ser precisos)
- La inversa son los coeficientes multiplicados por -1
- No podemos decir que el grado es "exactamente 7" porque el elemento identidad tiene grado 0 y no sería parte del grupo.

Los polinomios de un grado fijo acotado superiormente bajo la multiplicación no son un grupo, porque generalmente el grado aumenta cuando se multiplican polinomios, por lo tanto, el operador no sería cerrado.

### 8. La suma módulo un número primo es un grupo

Tomemos un número primo 7.

Aquí, la identidad sigue siendo 0, porque se suma por 0 y se obtiene el mismo número.

En esta situación, ¿cuál sería la inversa de 5?

Sería simplemente 2, porque 7 - 5 = 2, o 5 + 2 módulo 7 es cero (la identidad).

### 9. La multiplicación módulo de un número primo no es un grupo

El cero no tiene inverso en este ejemplo.

Si omitimos el número 0, entonces tenemos un grupo. El elemento identidad es 1, y el inverso de un elemento $a$ es su inverso modular $a^{-1}$.

### 10. Una base fija elevada a potencias enteras bajo la multiplicación es un grupo

Si se multiplican entre sí dos potencias enteras de $b$, el resultado es la potencia entera del producto de las bases. Por ejemplo, $2^3 \times 2^4 = 2^{3 + 4} = 2^7$. Esto funciona para bases arbitrarias:

$$
b^x \times b^y = b^{x + y}
$$

El elemento identidad es $b^0$, que es $1$, y el inverso de $b^x$ es $b^{-x}$.

## Grupos finitos

Como sugiere el nombre, un grupo finito tiene una cantidad finita de elementos. El conjunto de todos los números enteros bajo la adición no es finito, pero la adición de números enteros módulo un número primo es un grupo finito.

En las demostraciones de conocimiento cero, solo usamos grupos finitos.

## Orden de un grupo

El orden de un grupo es la cantidad de elementos que lo componen.

## Grupos cíclicos

Un grupo cíclico es un grupo que tiene un elemento tal que cada elemento del grupo puede ser "generado" aplicando el operador binario repetidamente a ese elemento, o a su inverso.

### Ejemplos de grupos cíclicos

#### Ejemplo 1: El grupo que consiste en 0 bajo la adición es un grupo cíclico

Esto es trivialmente cierto porque 0 + 0 = 0 genera cada elemento del grupo.

#### Ejemplo 2: La suma módulo 7 es un grupo cíclico

Si empezamos con 1 y sumamos 1 a sí mismo repetidamente, generaremos todos los elementos del grupo. Por ejemplo:

$$
\begin{align*}
&1 + 1 &= 2 \\
&1 + 1 + 1 &= 3 \\
&1 + 1 + 1 + 1 &= 4 \\
&1 + 1 + 1 + 1 + 1 &= 5 \\
&1 + 1 + 1 + 1 + 1 + 1 &= 6 \\
&1 + 1 + 1 + 1 + 1 + 1 &= 0 \\
&1 + 1 + 1 + 1 + 1 + 1 + 1 &= 1 \\
\end{align*}
$$

#### Ejemplo 3: La multiplicación módulo 7 es un grupo cíclico, si excluimos el cero

Debemos tener cuidado al elegir el generador aquí, porque, por ejemplo, 2 no generará todo el grupo.

$$
\begin{align*}
&2 * 2 &\equiv 4 \pmod 7 \\
&2 * 2 * 2 &\equiv 1 \pmod 7 \\
&2 * 2 * 2 * 2 &\equiv 2 \pmod 7 \\
&2 * 2 * 2 * 2 * 2 &\equiv 4 \pmod 7 \\
&...\
\end{align*}
$$

Podemos ver que 2 solo puede generar $\set{1,2,4}$. Sin embargo, si elegimos 3 como generador, entonces podemos generar todo el grupo.

$$
\begin{align*}
3 ^ 2 \equiv 2 \pmod 7 \\
3 ^ 3 \equiv 6 \pmod 7 \\
3 ^ 4 \equiv 4 \pmod 7 \\
3 ^ 5 \equiv 5 \pmod 7 \\
3 ^ 6 \equiv 1 \pmod 7 \\
3 ^ 7 \equiv 3 \pmod 7 \\
&...\
\end{align*}
$$

La razón por la que 3 funciona y 2 no es porque 3 es una *[raíz primitiva](https://en.wikipedia.org/wiki/Primitive_root_modulo_n)*.

Podemos usar la biblioteca Galois para encontrar raíces primitivas:

```python
from galois import GF
GF7 = GF(7)
GF.primitive_elements
# [3, 5]
```

### Si un grupo es cíclico, entonces es abeliano

Este es un poco más sutil, pero considere esto:

En un grupo cíclico, cada elemento del grupo puede generarse como $(g + g + … + g)$. Elijamos arbitrariamente un elemento R. Participemos este conjunto de adiciones de la siguiente manera:

$$
r = \underbrace{g + g + \dots + g}_\text{m veces} + \underbrace{g + g + \dots + g}_\text{n veces}
$$

Debido a la asociatividad, podemos agregar paréntesis

$$
r = \underbrace{(g + g + \dots + g)}_\text{m veces} + \underbrace{(g + g + \dots + g)}_\text{n veces}
$$

Sea $g$ sumado a sí mismo $m$ veces $p$ y $g$ sumado a sí mismo $n$ veces $q$. Por lo tanto,

$$r = p + q$$

Por asociatividad, podemos volver a particionar la ecuación original de la siguiente manera (¡nótese que $m$ y $n$ intercambiaron lugares!)

$$
R = \underbrace{(g + g + \dots + g)}_\text{n veces} + \underbrace{(g + g + \dots + g)}_\text{m veces}
$$

Y obtenemos:

$$r = q + p$$

Por lo tanto, si el grupo es cíclico, entonces el grupo es abeliano.

Nótese que el inverso de esta afirmación no es cierto. Los números reales bajo la adición son un grupo abeliano, pero no son cíclicos.

Los grupos cíclicos no tienen que ser aritméticos módulo algún número primo, pero estos son los únicos grupos cíclicos que usaremos en nuestra discusión de las pruebas de conocimiento cero.

## El elemento identidad de un grupo es único

Un grupo no puede tener dos elementos identidad. No pienses demasiado en esto, se deriva por simple contradicción. Digamos que ▢ es nuestro operador binario y $e$ es nuestro elemento identidad.

Digamos que tenemos un elemento identidad alternativo $e'$. Esto significa lo siguiente:

$$a \square a^{-1} = e \text{ and } a \square a^{-1} = e'$$

Si decimos $e≠e'$, entonces también debe ser cierto que

$$a \square a^{-1} \neq a \square a^{-1}$$

Pero eso es obviamente una contradicción, por lo tanto, los elementos identidad deben ser únicos.

## El uso de grupos en las demostraciones de conocimiento cero

Entender la teoría de grupos para el propósito de las demostraciones de conocimiento cero es más un ejercicio de vocabulario. Cuando decimos "inversa" o "identidad" queremos que entiendas inmediatamente lo que significan.

Además, los grupos nos ayudan a razonar sobre objetos matemáticos muy complejos sin entender cómo funcionan. En este artículo hemos utilizado ejemplos conocidos, pero más adelante trataremos objetos muy desconocidos como las *curvas elípticas sobre extensiones de campo*. Aunque no sepas exactamente qué es eso, si te decimos que es un grupo, ya sabes mucho sobre lo que es.

## Aprende más con RareSkills

Este artículo es parte de una serie sobre ZK Proofs. Consulta nuestro [Libro ZK](https://www.rareskills.io/zk-book) para ver la serie completa.

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*