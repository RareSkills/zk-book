# Conversión de circuitos algebraicos a R1CS (sistema de restricciones de rango uno)

Este artículo explica cómo convertir un conjunto de restricciones aritméticas en un sistema de restricciones de rango uno (R1CS).

El objetivo de este recurso es la implementación: cubrimos muchos más casos especiales de cómo realizar esta transformación que otros materiales, analizamos las optimizaciones y explicamos cómo la biblioteca Circom lo logra.

## Requisitos previos
- Suponemos que el lector comprende cómo utilizar [circuitos aritméticos (circuitos zk)](https://www.rareskills.io/post/arithmetic-circuit) para representar la validez de un cálculo.
- El lector está familiarizado con [aritmética modular](https://www.rareskills.io/post/finite-fields). Todas las operaciones aquí ocurren en un campo finito, por lo que $-5$ realmente significa el inverso aditivo de $5$ módulo $p$ y $2/3$ significa el inverso multiplicativo de $3$ módulo $p$ por $2$.

## Descripción general del sistema de restricciones de rango 1
Un sistema de restricciones de rango 1 (R1CS) es un circuito aritmético con el requisito de que cada restricción de igualdad tenga una multiplicación (y ninguna restricción en el número de adiciones).

Esto hace que la representación del circuito aritmético sea compatible con el uso de emparejamientos bilineales. La salida de un emparejamiento $G_1 \bullet G_2 \rightarrow G_T$ no se puede emparejar nuevamente, ya que un elemento en $G_T$ no se puede usar como parte de la entrada de otro emparejamiento. Por lo tanto, solo permitimos una multiplicación por restricción.

## El vector testigo
En un circuito aritmético, el testigo es una asignación a todas las señales que satisface las restricciones de la ecuación.

En un sistema de restricciones de rango 1, el vector testigo es un vector $1 \times n$ que contiene el valor de todas las variables de entrada, la variable de salida y los valores intermedios. Muestra que ha ejecutado el circuito de principio a fin, conociendo tanto la entrada como la salida y todos los valores intermedios.

Por convención, el primer elemento siempre es 1 para facilitar algunos cálculos, lo que demostraremos más adelante.

Por ejemplo, si tenemos la restricción

$$z = x^2y$$

para la que afirmamos conocer la solución, entonces eso debe significar que conocemos $x$, $y$ y $z$. Debido a que los sistemas de restricciones de rango uno requieren exactamente una multiplicación por restricción, el polinomio anterior a las restricciones debe escribirse como

$$
\begin{align*}
v₁ = xx \\
z = v₁y
\end{align*}
$$

Un testigo significa que no solo conocemos $x$, $y$ y $z$, sino que debemos conocer cada variable intermedia en esta forma expandida. En concreto, nuestro testigo es un vector:

$$[1, z, x, y, v₁]$$

donde cada término tiene un valor que satisface las restricciones anteriores.

Por ejemplo,

$$[1, 18, 3, 2, 9]$$

es un testigo válido porque cuando introducimos los valores,

$$[\text{constant} = 1, z = 18, x = 3, y = 2, v₁ = 9]$$
satisface las restricciones

$$
\begin{align*}
v_1 = x*x \rightarrow 9 = 3\cdot3\\
z = v_1*y \rightarrow 18 = 9\cdot2
\end{align*}
$$

El término adicional 1 no se utiliza en este ejemplo y es una conveniencia que explicaremos más adelante.

## Ejemplo 1: Transformar $z = x \cdot y$ en un sistema de restricciones de rango 1

Para nuestro ejemplo, supongamos que estamos demostrando $41 \times 103 = 4223$.

Por lo tanto, nuestro vector testigo es $[1, 4223, 41, 103]$ como una asignación a $[1, z, x, y]$.

Antes de que podamos crear un R1CS, nuestras restricciones deben tener la forma

```
result = left_hand_side × right_hand_side
```

Por suerte para nosotros, ya lo es
$$
\underbrace{z}_\text{result} = \underbrace{x}_\text{left hand side} \times \underbrace{y}_\text{right hand side}
$$

Obviamente, este es un ejemplo trivial, pero los ejemplos triviales suelen ser un buen punto de partida.

Para crear un sistema de ecuaciones de primer grado válido, se necesita una lista de fórmulas que contengan exactamente una multiplicación.

Más adelante analizaremos cómo manejar casos que no tienen exactamente una multiplicación, como $z = x³$ o $z = x³ + y$.

Nuestro objetivo es crear un sistema de ecuaciones de la forma:

$$
\mathbf{O}\mathbf{a} = \mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}
$$

Donde $O$, $L$ y $R$ son matrices de tamaño $n$ x $m$ ($n$ filas y $m$ columnas).

La matriz $\mathbf{L}$ codifica la variable del lado izquierdo de la multiplicación y $\mathbf{R}$ codifica las variables del lado derecho de la multiplicación. $\mathbf{O}$ codifica las variables resultantes. El vector $\mathbf{a}$ es el vector testigo.

Específicamente, $\mathbf{L}$, $\mathbf{R}$ y $\mathbf{O}$ son matrices con el mismo número de columnas que el vector testigo $\mathbf{a}$, y cada columna representa la misma variable que utiliza el índice.

Entonces, para nuestro ejemplo, el testigo tiene 4 elementos $(1, z, x, y)$, por lo que cada una de nuestras matrices tendrá 4 columnas, por lo que $m = 4$.

El número de filas corresponderá al número de restricciones en el circuito. En nuestro caso, solo tenemos una restricción: $z = x * y$, por lo que solo tendremos una fila, por lo que $n = 1$.

Pasemos a la respuesta y expliquemos cómo la obtuvimos.

$$\mathbf{O}\mathbf{a} = \mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}$$ $$ \underbrace{\begin{bmatrix} 0 y 1 y 0 y 0 \\ \end{bmatrix}}_{\mathbf{O}}\mathbf{a} = \underbrace{\begin{bmatrix} 0 y 0 y 1 y 0 \\ \end{bmatrix}}_{\mathbf{L}}\mathbf{a}\circ \underbrace{\begin{bmatrix} 0 y 0 y 0 y 1 \\ \end{bmatrix}}_{\mathbf{R}}\mathbf{a} $$ $$ \begin{bmatrix} 0 y 1 y 0 & 0 \\
\end{bmatrix}
\begin{bmatrix}
1 \\
4223 \\
41 \\
103 \\
\end{bmatrix}=
\begin{bmatrix}
0 & 0 & 1 & 0 \\
\end{bmatrix}
\begin{bmatrix}
1 \\
4223 \\
41 \\
103 \\
\end{bmatrix}\circ
\begin{bmatrix}
0 & 0 & 0 & 1 \\
\end{bmatrix}
\begin{bmatrix}
1 \\
4223 \\
41 \\
103 \\
\end{bmatrix}
$$

En este ejemplo, cada elemento de la matriz sirve como una variable indicadora de si la variable a la que corresponde la columna está presente o no. (Técnicamente, es el coeficiente de la variable, pero llegaremos a eso más adelante).

Para los términos de la izquierda, $x$ es la única variable presente en el lado izquierdo de la multiplicación, por lo que si las columnas representan $[1, z, x, y]$, entonces…

$\mathbf{L}$ es $[0, 0, 1, 0]$, porque $x$ está presente y ninguna de las otras variables lo está.

$\mathbf{R}$ es $[0, 0, 0, 1]$ porque la única variable en el lado derecho de la multiplicación es $y$, y

$\mathbf{O}$ es $[0, 1, 0, 0]$ porque solo tenemos la variable $z$ en la "salida" de la multiplicación.

No tenemos ninguna constante en ninguna parte, por lo que la columna 1 es cero en todas partes (hablaremos de cuándo es distinta de cero más adelante).

Esta ecuación es correcta, lo cual podemos verificar en Python

```python
import numpy as np

# define las matrices
O = np.matrix([[0,1,0,0]])
L = np.matrix([[0,0,1,0]])
R = np.matrix([[0,0,0,1]])

# vector testigo
a = np.array([1, 4223, 41, 103])

# La multiplicación `*` es elemento por elemento, no multiplicación de matrices.
# El resultado contiene un bool que indica un indicador elemento por elemento de que la igualdad es verdadera para ese elemento.
result = np.matmul(O, a) == np.matmul(L, a) * np.matmul(R, a)

# comprobar que cada igualdad elemento por elemento sea verdadera
assert result.all(), "result contiene una desigualdad"
```

Quizás te preguntes cuál es el sentido de esto, ¿no estamos diciendo simplemente que $41 \times 103 = 4223$ es una forma mucho menos compacta?

Tendrías razón.

Un R1CS puede ser bastante detallado, pero se correlaciona muy bien con [Programas Aritméticos Cuadráticos (QAPs)](https://www.rareskills.io/post/quadratic-arithmetic-program), que se pueden resumir. Pero no nos ocuparemos de los QAPs aquí.

Pero este es un punto importante de R1CS. Una R1CS comunica exactamente la misma información que las restricciones aritméticas originales, pero con solo una multiplicación por restricción de igualdad. En este ejemplo, solo tenemos una restricción, pero agregaremos más en el siguiente ejemplo.

## Ejemplo 2: Transformación de r = x * y * z * u
En este ejemplo un poco más complicado, ahora debemos tratar con variables intermedias. Cada fila de nuestro cálculo solo puede tener una multiplicación, por lo que debemos descomponer nuestra ecuación de la siguiente manera:

$$
\begin{align*}
v_1 &= xy \\
v_2 &= zu \\
r &= v_1v_2
\end{align*}
$$

No hay ninguna regla que diga que debemos descomponerla de esa manera, lo siguiente también es válido:

$$
\begin{align*}
v_1 &= xy \\
v_2 &= v_1z \\
r &= v_2u
\end{align*}
$$

Usaremos la primera transformación para este ejemplo.

### Tamaño de $\mathbf{L}$, $\mathbf{R}$ y $\mathbf{O}$
Como estamos tratando con 7 variables $(r, x, y, z, u, v_1, v_2)$, nuestro vector testigo tendrá ocho elementos (el primero es la constante 1) y nuestras matrices tendrán ocho columnas.

Como tenemos tres restricciones, las matrices tendrán tres filas.

### Términos de la mano izquierda y términos de la mano derecha
Este ejemplo reforzará fuertemente la idea de un "término de la mano izquierda" y un "término de la mano derecha". Específicamente, $x$, $z$ y $v_1$ son términos de la mano izquierda, e $y$, $u$ y $v_2$ son términos de la mano derecha.

$$
\underbrace{
\begin{matrix}
v_1 \\
v_2 \\
r \\
\end{matrix}
}_\text{ Términos de salida }
\begin{matrix}
=\\
=\\
=
\end{matrix}
\underbrace{
\begin{matrix}
x \\
z \\
v_1 \\
\end{matrix}
}_\text{ Términos de la mano izquierda }
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
\underbrace{
\begin{matrix}
y \\
u \\
v_2 \\
\end{matrix}
}_\text{ Términos de la mano derecha }
$$

### Constructing matrix $\mathbf{L}$ from left hand terms
Let’s construct the matrix A. We know it will have three rows (since there are three constraints) and eight columns (since there are eight variables).

$$
\begin{bmatrix}
& l_{1,2} & l_{1,3} & l_{1,4} & l_{1,5} & l_{1,6} &  l_{1,7} & l_{1,8} \\
& l_{2,2} & l_{2,3} & l_{2,4} & l_{2,5} & l_{2,6} &  l_{2,7} & l_{2,8} \\
& l_{3,2} & l_{3,3} & l_{3,4} & l_{3,5} & l_{3,6} &  l_{3,7} & l_{3,8} \\
\end{bmatrix}
$$

Our witness vector will be multiplied by this, so let’s define our witness vector to have the following layout:

$$
\begin{bmatrix}
1 & r &x & y & z & u & v_1 & v_2
\end{bmatrix}
$$

This informs us as to what $\mathbf{L}$’s columns represents:

$$
\mathbf{L} = 
\begin{bmatrix}
l_{1, 1} & l_{1, r} y l_{1, x} y l_{1, y} y l_{1, z} y l_{1, u} y l_{1, v_1} y l_{1, v_2} \\
l_{2, 1} y l_{2, r} y l_{2, x} y l_{2, y} y l_{2, z} y l_{2, u} y l_{2, v_1} y l_{2, v_2} \\
l_{3, 1} y l_{3, r} y l_{3, x} y l_{3, y} y l_{3, z} y l_{3, u} y l_{3, v_1} y l_{3, v_2} \\
\end{bmatrix}
$$

#### Primera fila de $\mathbf{L}$
En la primera fila, para la primera variable de la izquierda, tenemos $v₁ = xy$:

$$
\begin{matrix}
v_1 \\
v_2 \\
r \\
\end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}
\underset{\mathbf{L}}{\boxed{
\begin{matrix}
\color{red}{x} \\
z \\
v_1 \\
\end{matrix}
}}
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
\begin{matrix}
y \\
u \\
v_2 \\
\end{matrix}
$$

Esto significa que, con respecto al lado izquierdo, la variable $x$ está presente y no hay otras variables. Por lo tanto, transformamos la primera fila de la siguiente manera:

$$
\mathbf{L}=\begin{bmatrix}
0 & 0 & \color{red}{1} & 0 & 0 & 0 & 0 & 0 \\
l_{2, 1} & l_{2, r} & l_{2, x} & l_{2, y} & l_{2, z} & l_{2, u} & l_{2, v_1} & l_{2, v_2} \\
l_{3, 1} & l_{3, r} & l_{3, x} & l_{3, y} & l_{3, z} & l_{3, u} & l_{3, v_1} & l_{3, v_2} \\
\end{bmatrix}
$$

Recordemos que las columnas de $\mathbf{L}$ están etiquetadas de la siguiente manera:

$$
\begin{bmatrix}
1 & r &x & y & z & u & v_1 & v_2\\
\end{bmatrix}
$$

y vemos que el $1$ está en la columna $x$.

#### Segunda fila de $\mathbf{L}$
Continuando hacia abajo, vemos que solo $z$ está presente para el lado izquierdo de nuestros sistemas de ecuaciones.

$$
\begin{matrix}
v_1 \\
v_2 \\
r \\
\end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}
\underset{\mathbf{L}}{\boxed{
\begin{matrix}
x \\
\color{green}{z} \\
v_1 \\
\end{matrix}
}}
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
\begin{matrix}
y \\
u \\
v_2 \\
\end{matrix}
$$

Por lo tanto, establecemos todo en esa fila como cero, excepto la columna que representa $z$.

$$
\mathbf{L}=\begin{bmatrix}
0 & 0 & \color{red}{1} & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & \color{green}{1} & 0 & 0 & 0 \\
l_{3, 1} & l_{3, r} & l_{3, x} & l_{3, y} & l_{3, z} & l_{3, u} & l_{3, v_1} & l_{3, v_2} \\
\end{bmatrix}
$$

#### Tercera fila de $\mathbf{L}$
Finalmente, tenemos $v₁$ como la única variable presente en los operadores de la izquierda en la tercera fila

$$
\begin{matrix}
v_1 \\
v_2 \\
r \\
\end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}
\underset{\mathbf{L}}{\boxed{
\begin{matrix}
x \\
z \\
\color{violet}{v_1} \\
\end{matrix}
}}
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
\begin{matrix}
y \\
u \\
v_2 \\
\end{matrix}
$$

Esto completa la matriz $\mathbf{L}$

$$
\mathbf{L}=\begin{bmatrix}
0 & 0 & \color{red}{1} & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & \color{green}{1} & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & \color{violet}{1} & 0 \\
\end{bmatrix}
$$

La siguiente imagen debería hacer que la asignación sea más clara:

$$
\begin{matrix}
v_1 \\
v_2 \\
r \\
\end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}
\underset{\mathbf{L}}{\boxed{
\begin{matrix}
\color{red}{x} \\
\color{green}{z} \\
\color{violet}{v_1} \\
\end{matrix}
}}
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
\begin{matrix}
y \\
u \\
v_2 \\
\end{matrix}
\space\space\space\space
\begin{array}{c}
\begin{array}{cc}
\begin{matrix}
1 & r & x & y & z & u & v_1 & v_2 \\
\end{matrix}
\end{array} \\[10pt]
\begin{array}{cc}
\begin{bmatrix}
0 & 0 & \color{rojo}{1} & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & \color{verde}{1} & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & \color{violeta}{1} & 0 \\
\end{bmatrix}
\end{array}
\end{array}
$$

#### Transformación alternativa de $\mathbf{L}$
Podríamos realizar estos mismos ejercicios expandiendo los valores de la mano izquierda de

$$
\begin{matrix}
v_1 \\
v_2 \\
r \\
\end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}
{
\begin{matrix}
x \\
z \\
v_1 \\
\end{matrix}
}
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
\begin{matrix}
y \\
u \\
v_2 \\
\end{matrix}
$$

as

$$
\begin{align*}
v_1 &= (0\cdot 1 + 0\cdot r + \boxed{1\cdot x} + 0\cdot y + 0\cdot z + 0\cdot u + 0\cdot v_1 + 0\cdot v_2) \times y\\
v_2 &= (0\cdot 1 + 0\cdot r + 0\cdot x + 0\cdot y + \boxed{1\cdot z} + 0\cdot u + 0\cdot v_1 + 0\cdot v_2) \times u\\
r &= (0\cdot 1 + 0\cdot r + 0\cdot x + 0\cdot y + 0\cdot z + 0\cdot u + \boxed{1\cdot v_1} + 0\cdot v_2) \times v_2 \\
\end{align*}
$$

Podemos hacerlo porque agregar términos cero no cambia los valores. Solo debemos tener cuidado de expandir las variables cero para que tengan las mismas "columnas" que como hemos definido el vector testigo.

Y luego, si sacamos los coeficientes (mostrados en recuadros) de la expansión anterior,

$$
\begin{align*}
v_1 &= (\boxed{0}\cdot 1 + \boxed{0}\cdot r + \boxed{1}\cdot x + \boxed{0}\cdot y + \boxed{0}\cdot z + \boxed{0}\cdot u + \boxed{0}\cdot v_1 + \boxed{0}\cdot v_2) \times y\\
v_2 &= (\boxed{0}\cdot 1 + \boxed{0}\cdot r + \boxed{0}\cdot x + \boxed{0}\cdot y + \boxed{1}\cdot z + \boxed{0}\cdot u + \boxed{0}\cdot v_1 + \boxed{0}\cdot v_2) \times u\\
r &= (\boxed{0}\cdot 1 + \boxed{0}\cdot r + \boxed{0}\cdot x + \boxed{0}\cdot y + \boxed{0}\cdot z + \boxed{0}\cdot u + \boxed{1}\cdot v_1 + \boxed{0}\cdot v_2) \times v_2 \\
\end{align*}
$$

Obtenemos la misma matriz para $\mathbf{L}$ que generamos hace un momento.

$$
\mathbf{L}=\begin{bmatrix}
0 & 0 & 1 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 1 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 1 & 0 \\
\end{bmatrix}
$$

### Construcción de la matriz $\mathbf{R}$ a partir de términos de la mano derecha
$$
R = \begin{bmatrix}
r_{1,1} & r_{1,r} & r_{1,x} & r_{1,y} & r_{1,z} & r_{1,u} & r_{1,v_1} & r_{1,v_2} \\
r_{2,1} & r_{2,r} & r_{2,x} & r_{2,y} & r_{2,z} & r_{2,u} & r_{2,v_1} & r_{2,v_2} \\
r_{3,1} & r_{3,r} & r_{3,x} & r_{3,y} & r_{3,z} & r_{3,u} & r_{3,v_1} & r_{3,v_2} \\
\end{bmatrix}
$$

La matriz $\mathbf{R}$ representa los términos de la derecha de nuestra ecuación:

$$
\begin{matrix}
v_1 \\
v_2 \\
r \\
\end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}
{
\begin{matrix}
x \\
z \\
v_1 \\
\end{matrix}
}
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
\underset{\mathbf{R}}{\boxed{
\begin{matrix}
y \\
u \\
v_2 \\
\end{matrix}}}
$$

La matriz $\mathbf{R}$ debe tener 1 que representen $y$, $u$ y $v_2$. La fila de la matriz corresponde a la fila de la restricción aritmética, es decir, podemos numerar las restricciones (filas) de la siguiente manera:

$$
\begin{matrix}
(1) \\
(2) \\
(3) \\
\end{matrix}
\space\space
\begin{matrix}
v_1 \\
v_2 \\
r \\
\end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}
{
\begin{matrix}
x \\
z \\
v_1 \\
\end{matrix}
}
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
\underset{\mathbf{R}}{\boxed{
\begin{matrix}
y \\
u \\
v_2 \\
\end{matrix}}}
$$

Entonces, la primera fila tiene 1 en la columna $y$, la segunda fila tiene 1 en la columna $u$ y la tercera fila tiene 1 en la columna $v_2$. Todo lo demás es cero.

Esto da como resultado lo siguiente para la matriz $\mathbf{R}$:

$$
\begin{array}{c}
\begin{array}{cc}
\begin{matrix}
1 & r & x & y & z & u & v_1 & v_2 \\
\end{matrix}
\end{array} \\[10pt]
\begin{array}{cc}
\begin{bmatrix}
0 & 0 & 0 & 1 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 1 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 1 \\
\end{bmatrix}
\end{array}
\end{array}
$$

Este diagrama ilustra la transformación.

$$
\begin{matriz}
v_1 \\
v_2 \\
r \\
\end{matriz}

\begin{matriz}
=\\
=\\
=
\end{matriz}

\begin{matriz}
x \\
z \\
v_1 \\
\end{matriz}

\begin{matriz}
\times\\
\times\\
\times
\end{matriz}
\underset{\mathbf{R}}
{\boxed{
\begin{matriz}
\color{rojo}{y} \\
\color{verde}{u} \\
\color{violeta}{v_2} \\
\end{matriz}
}}
\space\space\space\space
\begin{matriz}{c}
\begin{matriz}{cc}
\begin{matriz}
1 & r & x & y & z & u & v_1 & v_2 \\
\end{matrix}
\end{array} \\[10pt]
\begin{array}{cc}
\begin{bmatrix}
0 & 0 & 0 & \color{red}{1} & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & \color{green}{1} & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 &\color{violet}{1} \\
\end{bmatrix}
\end{array}
\end{array}
$$

### Construcción de la matriz $\mathbf{O}$
Es un ejercicio para el lector determinar que la matriz $\mathbf{O}$ es

$$
\mathbf{O}=\begin{bmatrix}
0 & 0 & 0 & 0 & 0 & 0 & 1 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 1 \\
0 & 1 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
\end{bmatrix}
$$

usando las etiquetas de columna consistentes con las matrices anteriores.

A modo de recordatorio, $\mathbf{C}$ se deriva del resultado de la multiplicación

$$
\underset{\mathbf{O}}{
\boxed{\begin{matrix}
v_1 \\
v_2 \\
r \\
\end{matrix}}}

\begin{matrix}
=\\
=\\
=
\end{matrix}

\begin{matrix}
x \\
z \\
v_1 \\
\end{matrix}

\begin{matrix}
\times\\
\times\\
\times
\end{matrix}

\begin{matrix}
y \\
u \\
v_2 \\
\end{matrix}
$$

Y las etiquetas de las columnas son las siguientes

$$
\begin{array}{c}
\begin{array}{cc}
\begin{matrix}
1 & r & x & y & z & u & v_1 & v_2 \\
\end{matrix}
\end{array} \\[10pt]
\begin{array}{cc}
\begin{bmatrix}
0 & 0 & 0 & 0 & 0 & 0 & 1 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 1 \\
0 & 1 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
\end{bmatrix}
\end{array}
\end{array}
$$

Comprobando nuestro trabajo para $r = x \cdot y \cdot z \cdot u$

```python
import numpy as np

# ingrese A, B y C de arriba
L = np.matrix([[0,0,1,0,0,0,0,0],
[0,0,0,0,1,0,0,0],
[0,0,0,0,0,0,1,0]])

R = np.matrix([[0,0,0,1,0,0,0,0],
[0,0,0,0,0,1,0,0],
[0,0,0,0,0,0,0,1]])

O = np.matrix([[0,0,0,0,0,0,1,0],
[0,0,0,0,0,0,0,1],
[0,1,0,0,0,0,0,0]])

# valores aleatorios para x, y, z y u
import random
x = random.randint(1,1000)
y = random.randint(1,1000)
z = random.randint(1,1000)
u = random.randint(1,1000)

# calcular el circuito algebraico
r = x * y * z * u
v1 = x*y
v2 = z*u

# crear el vector testigo
a = np.array([1, r, x, y, z, u, v1, v2])

# multiplicación elemento por elemento, no multiplicación de matrices
result = np.matmul(O, a) == np.multiply(np.matmul(L, a), np.matmul(R, a))

assert result.all(), "el sistema contiene una desigualdad"
```

## Ejemplo 3: Suma con una constante
¿Qué pasa si queremos ¿Cómo construir un sistema de restricciones de rango uno para lo siguiente?

$$z = x * y + 2$$

Aquí es donde resulta útil esa columna 1.

### La suma es gratuita
Probablemente haya escuchado la afirmación "la suma es gratuita" en el contexto de ZK-SNARK. Lo que eso significa es que no tenemos que crear una restricción adicional cuando tenemos una operación de suma.

Podríamos escribir la fórmula anterior como

$$\begin{align*}
v_1 = xy \\
z = v_1 + 2 \\
\end{align*}$$

pero eso haría que nuestro R1CS fuera más grande de lo que necesita ser.

En cambio, podemos escribirlo como

$$-2 + z = xy$$

Entonces la variable $z$ y la constante $-2$ se "combinan" automáticamente cuando multiplicamos $\mathbf{a}$ por $\mathbf{O}$ con nuestro vector testigo.

Nuestro vector testigo tiene la forma `[1, z, x, y]`, por lo que nuestras matrices $\mathbf{L}$, $\mathbf{R}$ y $\mathbf{O}$ son las siguientes:

$$
\mathbf{L} = \begin{bmatrix}
0 & 0 & 1 & 0 \\
\end{bmatrix}$$

$$
\mathbf{R} = \begin{bmatrix}
0 & 0 & 0 & 1 \\
\end{bmatrix}$$

$$
\mathbf{O} = \begin{bmatrix}
-2 & 1 & 0 & 0 \\
\end{bmatrix}$$

Siempre que haya constantes aditivas, simplemente las colocamos en la columna $1$, que por convención es la primera columna.

Nuevamente, hagamos algunas pruebas unitarias en nuestras matemáticas:

```python
import numpy as np
import random

# Definir las matrices
A = np.matrix([[0,0,1,0]])
B = np.matrix([[0,0,0,1]])
C = np.matrix([[-2,1,0,0]])

# Elegir valores aleatorios para probar la ecuación
x = random.randint(1,1000)
y = random.randint(1,1000)
z = x * y + 2 # vector testigo
a = np.array([1, z, x, y])

# Verificar la igualdad
result = C.dot(w) == np.multiply(np.matmul(L, a), B.dot(w))
assert result.all(), "result contains una desigualdad"
```

## Ejemplo 4: Multiplicación con una constante
En todos los ejemplos anteriores, nunca multiplicamos variables por constantes. Es por eso que las entradas en la R1CS siempre fueron 1. Como puede haber adivinado a partir del ejemplo anterior, la entrada en las matrices es el mismo valor de la constante por la que se multiplica la variable, como lo mostrará el siguiente ejemplo.

Calculemos la solución para

$$z = 2x^2 + y$$

Tenga en cuenta que cuando decimos "una multiplicación por restricción" nos referimos a la multiplicación de dos variables. La multiplicación con una constante no es una multiplicación "real" porque en realidad es una suma repetida de la misma variable.

La siguiente solución es válida, pero crea filas innecesarias:

$$
\begin{align*}
v_1 &= xx \\
z &= 2v_1
\end{align*}
$$

La solución más óptima es la siguiente:

$$-y + z = 2xx$$

Usando la solución más óptima, nuestro vector testigo tendrá la forma `[1, out, x, y]`.

Las matrices se definirán de la siguiente manera:

$$
\begin{align*}
\mathbf{L} &= \begin{bmatrix}
0 & 0 & 1 & 0 \\
\end{bmatrix} \\
\mathbf{R} &= \begin{bmatrix}
0 & 0 & 1 & 0 \\
\end{bmatrix} \\
\mathbf{O} &= \begin{bmatrix}
0 & 1 & 0 & -1 \\
\end{bmatrix} \\
\end{align*}
$$

Si multiplicamos simbólicamente lo anterior por `[1, z, x, y]` en la forma r1cs, obtenemos nuestra ecuación original:

$$
\begin{bmatrix}
0 & 1 & 0 & -1 \\
\end{bmatrix}
\begin{bmatrix}
1 \\
z \\
x \\
y \\
\end{bmatrix}
=
\begin{bmatrix}
0 & 0 & 1 & 0 \\
\end{bmatrix}
\begin{bmatrix}
1 \\
z \\
x \\
y \\
\end{bmatrix}\circ
\begin{bmatrix}
0 & 0 & 1 & 0 \\
\end{bmatrix}
\begin{bmatrix}
1 \\
z \\
x \\
y \\
\end{bmatrix}
$$
$$
z - y = 2xx
$$
$$
z = 2x^2 + y
$$

así que sabemos que configuramos $\mathbf{L}$, $\mathbf{R}$ y $\mathbf{O}$ correctamente.

Aquí tenemos una fila (restricciones) y una multiplicación
"verdadera". Como regla general:

La cantidad de restricciones en un sistema de restricciones de rango uno debe ser igual a la cantidad de multiplicaciones no constantes.

## Ejemplo 5: Una restricción grande
Hagamos algo menos trivial que incorpore todo lo aprendido anteriormente

Supongamos que tenemos la siguiente restricción:

$$
z = 3x^2 + 5xy - x - 2y + 3
$$

La dividiremos de la siguiente manera:

$$
\begin{align*}
v_1 &= 3xx \\
v_2 &= v_1y \\
-v_2 + x + 2y - 3 + z &= 5xy \\
\end{align*}
$$

Observe cómo todos los términos de adición se han movido hacia la izquierda (esto es lo que hicimos en el ejemplo de adición, pero es más evidente aquí).

Dejar el lado derecho como $5xy$ en la tercera fila es arbitrario. Podríamos dividir ambos lados por 5 y la restricción final sería

$$
\frac{-v_2}{5} + \frac{x}{5} + \frac{2y}{5} - \frac{3}{5} + \frac{z}{5}= xy
$$

Sin embargo, esto no cambia el testigo, por lo que ambos son válidos. Como todo se hace en un campo finito, esta operación es multiplicar el lado izquierdo y el lado derecho por el inverso multiplicativo de 5.

Nuestro vector testigo tendrá la forma

$$[1, z, x, y, v_1, v_2]$$

Y nuestras matrices tendrán tres filas, ya que tenemos tres restricciones:

$$
\begin{align*}
\color{red}{v_1} &= \color{green}{3x}\color{violet}{x} \\
\color{red}{v_2} &= \color{green}{v_1}\color{violet}{y} \\
\color{red}{-v_2 + x + 2y - 3 + z} &= \color{green}{5x}\color{violet}{y} \\
\end{align*}
$$

Hemos marcado la salida $\mathbf{O}$ en <span style="color:red">rojo</span>, el lado izquierdo $\mathbf{L}$ en <span style="color:green">verde</span>, y el lado derecho $\mathbf{R}$ en <span style="color:violet">violeta</span>. Esto produce las siguientes matrices:

$$
A = \begin{bmatrix}
0 & 0 & \textcolor{violet}{3} & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & \textcolor{violet}{1} \\
0 & 0 & \textcolor{violet}{5} & 0 & 0 & 0 \\
\end{bmatrix}
$$

$$
B = \begin{bmatrix}
0 & 0 & \textcolor{blue}{1} & 0 & 0 & 0 \\
0 & 0 & 0 & \textcolor{blue}{1} & 0 & 0 \\
0 & 0 & 0 & 0 & \textcolor{blue}{1} & 0 \\
\end{bmatrix}
$$

$$
C = \begin{bmatrix}

0 & 0 & 0 & 0 & \textcolor{red}{1} & 0 \\
0 & 0 & 0 & 0 & 0 & \textcolor{red}{1} \\
\textcolor{red}{-3} & 1 & 1 & 2 & 0 & \textcolor{red}{-1} \\
\end{bmatrix}
$$

con etiquetas de columna

$$\begin{bmatrix}1 & \text{out} & x & y & v_1 & v_2\end{bmatrix}$$

Revisemos nuestro trabajo como siempre.

```python
import numpy as np
import random

# Definir las matrices
A = np.array([[0,0,3,0,0,0],
[0,0,0,0,1,0],
[0,0,1,0,0,0]])

B = np.array([[0,0,1,0,0,0],
[0,0,0,1,0,0],
[0,0,0,5,0,0]])

C = np.array([[0,0,0,0,1,0],
[0,0,0,0,0,1],
[-3,1,1,2,0,-1]])

# Elegir valores aleatorios para x e y
x = random.randint(1,1000)
y = random.randint(1,1000)

# Esta es nuestra fórmula original
out = 3 * x * x * y + 5 * x * y - x- 2*y + 3# el vector testigo con las variables intermedias dentro
v1 = 3*x*x
v2 = v1 * y
w = np.array([1, out, x, y, v1, v2])

result = C.dot(w) == np.multiply(A.dot(w),B.dot(w))
assert result.all(), "result contiene una desigualdad"
```

## Los sistemas de restricciones de rango 1 no requieren comenzar con un solo polinomio
Para simplificar las cosas, hemos estado usando ejemplos de la forma $z = xy + ...$ pero la mayoría de las restricciones aritméticas realistas serán un conjunto de restricciones aritméticas, no una sola.

Por ejemplo, supongamos que estamos demostrando que una matriz $[x₁, x₂, x₃, x₄]$ es binaria y $v$ es menor que 16. El conjunto de restricciones será

$$
\begin{align*}
x₁² &= x₁\\
x₂² &= x₂\\
x₃² &= x₃\\
x₄² &= x₄ \\
v &= 8x₄ + 4x₃ + 2x₂ + x₁
\end{align*}
$$

Para obtener un sistema de restricciones de rango uno, notamos que la fila final no tiene ninguna multiplicación, por lo que podemos sustituir $x_1$ en la primera restricción:

$$
\begin{align*}
x₁² &= v - 8x₄ - 4x₃ - 2x₂\\
x₂² &= x₂\\
x₃² &= x₃\\
x₄² &= x₄ \\
\end{align*}
$$

Suponiendo que nuestro vector testigo es $[1, v, x_1, x_2, x_3, x_4]$, podemos crear el R1CS de la siguiente manera:

$$
\begin{align*}
\mathbf{L} &= \begin{bmatrix}
0 & 0 & 1 & 0 & 0 & 0 \\
0 & 0 & 0 & 1 & 0 & 0 \\
0 & 0 & 0 & 0 & 1 & 0 \\
0 & 0 & 0 & 0 & 1 & 0 \\
0 & 0 & 0 & 0 & 0 & 1 \\
\end{bmatrix} \\
\mathbf{R} &= \begin{bmatrix}
0 & 0 & 1 & 0 & 0 & 0 \\
0 & 0 & 0 & 1 & 0 & 0 \\
0 & 0 & 0 & 0 & 1 & 0 \\
0 & 0 & 0 & 0 & 0 & 1 \\
\end{bmatrix} \\
\mathbf{O} &= \begin{bmatrix}
0 & 1 & 0 & -2 & -4 & -8 \\
0 & 0 & 0 & 1 & 0 & 0 \\
0 & 0 & 0 & 0 & 1 & 0 \\
0 & 0 & 0 & 0 & 1 & 0 \\
0 & 0 & 0 & 0 & 0 & 1 \\
\end{bmatrix} \\
\end{align*}
$$

Realizar la sustitución no es estrictamente necesario, pero ahorra una fila en el R1CS. En una sección posterior, mostraremos un R1CS válido en el que no realizamos la sustitución.

## Todo se hace módulo primo en r1cs
En los ejemplos anteriores, usamos aritmética tradicional por el bien de la simplicidad, pero las implementaciones del mundo real usan aritmética modular en su lugar.

La razón es simple: codificar números como 2/3 conduce a números flotantes con mal comportamiento que requieren mucho cálculo y son propensos a errores.

Si hacemos todos nuestros cálculos módulo un número primo, digamos 23, entonces codificar $2/3$ es sencillo. Es lo mismo que $2 \cdot 3^{-1}$, y multiplicar por dos y elevar a la potencia de menos 1 son sencillos en aritmética modular

## Implementación de Circom.
En Circom, un lenguaje para construir sistemas de restricciones de rango 1, el campo finito utiliza el número primo $21888242871839275222246405745257275088548364400416034343698204186575808495617$ (esto es igual al orden de la curva BN128 que analizamos en [Curvas elípticas sobre campos finitos](https://www.rareskills.io/post/elliptic-curves-finite-fields)).

Esto significa que $-1$ en esa representación es

```python
p = 21888242871839275222246405745257275088548364400416034343698204186575808495617

# 1 - 2 = -1
(1 - 2) % p

# 21888242871839275222246405745257275088548364400416034343698204186575808495616
```

### Circom para out = x * y
Si escribimos `out = x * y` en Circom, se vería como siguiente:

```javascript
pragma circom 2.0.0;

plantilla Multiply2() {
señal de entrada x;
señal de entrada y;
señal de salida;

salida <== x * y;
}

componente principal = Multiply2();
```

Convirtamos esto en un archivo R1CS e imprimamos el archivo R1CS

```bash
circom calculate2.circom --r1cs --sym
snarkjs r1cs print calculate2.r1cs
```

Obtenemos el siguiente resultado:

![resultado de la consola de la compilación de Circom](https://static.wixstatic.com/media/935a00_ce8574af090e4b4d8465fd45d7dda8ff~mv2.png/v1/fill/w_1480,h_496,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/935a00_ce8574af090e4b4d8465fd45d7dda8ff~mv2.png)

Esto parece bastante es un poco diferente de nuestra solución R1CS, pero en realidad codifica la misma información.

A continuación se muestran las diferencias en la implementación de Circom:
- Las columnas con valor cero no se imprimen
- Circom escribe $\mathbf{O}\mathbf{a} = \mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}$ como $\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a} - \mathbf{O}\mathbf{a} = \mathbf{0}$

¿Qué sucede con 21888242871839275222246405745257275088548364400416034343698204186575808495616 que en realidad es -1?

La solución de Circom es

$$
\begin{align*}
A &= \begin{bmatrix}
0 & 0 & -1 & 0
\end{bmatrix}\\

B &= \begin{bmatrix}
0 & 0 & 0 & 1
\end{bmatrix}\\

C &= \begin{bmatrix}
0 & -1 & 0 & 0
\end{bmatrix}
\end{align*}
$$

Aunque los negativos pueden ser inesperados, con el vector testigo `[1 out x y]`, esto es en realidad consistente con la forma $\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a} - \mathbf{O}\mathbf{a} = \mathbf{0}$. (Veremos en un segundo que Circom efectivamente utilizó esta asignación de columnas).

Puedes introducir valores para $x$, $y$ y ver que la ecuación $\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a} - \mathbf{O}\mathbf{a} = \mathbf{0}$ es válida.

Veamos la asignación de variable a columna de Circom. Recompilemos nuestro circuito con un solucionador wasm:

```bash
circom calculate2.circom --r1cs --wasm --sym

cd calculate2_js/
```

Creamos el archivo `input.json`

```bash
echo '{"x": "11", "y": "9"}' > input.json
```

Y calculamos el testigo

```bash
node generate_witness.js calculate2.wasm input.json witness.wtns

snarkjs wtns export json witness.wtns witness.json

cat witness.json
```

Obtenemos el siguiente resultado:

![salida de la terminal después de calcular el testigo](https://static.wixstatic.com/media/935a00_6ffb172a2e7649cab8cc6db8cace8de8~mv2.png/v1/fill/w_1428,h_316,al_c,lg_1,q_90,enc_auto/935a00_6ffb172a2e7649cab8cc6db8cace8de8~mv2.png)

Está claro que Circom está usando el mismo diseño de columnas que hemos estado usando: `[1, out, x, y]`, ya que $x$ se estableció en $11$ e $y$ en $9$ en nuestro `input.json`.

Si usamos el testigo generado de Circom (reemplazando el número masivo con -1 para facilitar la lectura), entonces vemos que el R1CS de Circom es correcto

$$
\begin{align*}
\mathbf{a} &= \begin{bmatrix}
1 & 99 & 11 & 9
\end{bmatrix}\\
\mathbf{L} &= \begin{bmatrix}
0 & 0 & -1 & 0
\end{bmatrix} \rightarrow \mathbf{L}\mathbf{a} = -11\\
\mathbf{R} &= \begin{bmatrix}
0 & 0 & 0 & 1
\end{bmatrix} \rightarrow \mathbf{R}\mathbf{a} = 9\\
\mathbf{O} &= \begin{bmatrix}
0 & -1 & 0 & 0 \end{bmatrix} \rightarrow \mathbf{O}\mathbf{a} = -99 \end{align*} $$ $$ \begin{align*} Aw \cdot Bw - Cw &= 0\\ (-11)(9) - (-99) &= 0 \\ -99 + 99 &= 0 \end{align*} $$

$\mathbf{L}$ tiene un coeficiente de $-1$ para $x$, $\mathbf{R}$ tiene un coeficiente de $+1$ para $y$, y $\mathbf{O}$ tiene $-1$ para $\text{out}$. En forma modular, esto es idéntico a lo que la terminal generó anteriormente:

![salida de la terminal de R1CS](https://static.wixstatic.com/media/935a00_36651c70d5aa49d89059cbae553be7e9~mv2.png/v1/fill/w_1480,h_114,al_c,lg_1,q_85,enc_auto/935a00_36651c70d5aa49d89059cbae553be7e9~mv2.png)

### Comprobando el resto de nuestro trabajo
A modo de repaso, las fórmulas que exploramos fueron

$$
\begin{align}
z &= x * y \\
z &= x * y * z * u \\
z &= x * y + 2 \\
z &= 3x^2 y + 5xy - x - 2y + 3
\end{align}
$$

Acabamos de hacer (1) en la sección anterior, para esta sección ilustraremos el principio de que la cantidad de multiplicaciones no constantes es la cantidad de restricciones.

El circuito para (2) es:
```javascript
pragma circom 2.0.8;

template Multiply4() {
signal input x;
signal input y;
signal input z;
signal input u;

signal v1;
signal v2;

signal out;

v1 <== x * y;
v2 <== z * u;

out <== v1 * v2;
}

template main = Multiply4();
```

Con todo lo que hemos discutido hasta ahora, la salida de Circom y las anotaciones deberían explicarse por sí solas.

![anotación de generación de restricciones para Multiply4()](https://static.wixstatic.com/media/935a00_21b46f6f9ffd4a80b1a2a374be0de279~mv2.png/v1/fill/w_990,h_420,al_c,q_90,enc_auto/935a00_21b46f6f9ffd4a80b1a2a374be0de279~mv2.png)

Teniendo esto en cuenta, nuestras otras fórmulas deberían tener restricciones como las siguientes:

$$
\begin{align}
z &= x * y && \text{1 restricción} \\
z &= x * y * z * u && \text{3 restricciones} \\
z &= x * y + 2 && \text{1 restricción} \\
z &= 3x^2 y + 5xy - x - 2y + 3 && \text{3 restricciones}
\end{align}
$$

Es un ejercicio para el lector escribir los circuitos Circom y verificar lo anterior.

### No necesita un testigo para calcular el R1CS
Tenga en cuenta que en el código Circom nunca proporcionamos el testigo antes de calcular el R1CS. Proporcionamos el testigo antes para hacer el ejemplo menos abstracto y para facilitar la verificación de nuestro trabajo, pero no es necesario. Esto es importante, porque si un verificador necesitara un testigo para construir un R1CS, entonces el probador tendría que revelar la solución oculta.

Cuando decimos "testigo", nos referimos a un vector con valores poblados. El verificador conoce la "estructura" del testigo, es decir, las asignaciones de variable a columna, pero no conoce los valores.

## Un R1CS es válido incluso si no está optimizado
Una transformación válida de un polinomio a un R1CS no es única. Puedes codificar el mismo problema con más restricciones, lo que es menos eficiente. Aquí tienes un ejemplo.

En algunos tutoriales de R1CS, las restricciones para una fórmula como

$$z = x² + y$$

se transforman en

$$
\begin{align*}
v₁ &= x x \\
z &= v₁ + y
\end{align*}
$$

Como hemos señalado, esto no es eficiente. Sin embargo, puedes crear un R1CS válido para esto utilizando la metodología de este artículo. Simplemente sumamos una multiplicación ficticia de la siguiente manera:

$$
\begin{align*}
v₁ &= x x \\
z &= (v₁ + y) * 1
\end{align*}
$$

Nuestro vector testigo tiene la forma $[1, z, x, y, v1]$ y $\mathbf{L}$, $\mathbf{R}$ y $\mathbf{O}$ se definen de la siguiente manera:

$$
\mathbf{L} = \begin{bmatrix}
0 & 0 & 1 & 0 & 0 \\
0 & 0 & 0 & 1 & 1
\end{bmatrix}
$$

$$
\mathbf{R} = \begin{bmatrix}
0 & 0 & 1 & 0 & 0 \\
1 & 0 & 0 & 0 & 0
\end{bmatrix}
$$

$$
\mathbf{O} = \begin{bmatrix}
0 & 0 & 0 & 0 & 1 \\
0 & 1 & 0 & 0 & 0
\end{bmatrix}
$$

La segunda fila de $\mathbf{L}$ realiza la suma, y ​​la multiplicación por uno se realiza utilizando el primer elemento de la segunda fila de $\mathbf{R}$.

Esto es perfectamente válido, pero la solución tiene una fila más y una columna más de las que necesita.

## ¿Qué pasa si no hay multiplicaciones?
¿Qué pasa si queremos codificar el siguiente circuito?

$$
z = x + y
$$

Esto es bastante inútil en la práctica, pero para completar, se puede resolver con una multiplicación ficticia por uno.

$$
out = (x + y)*1
$$

Con nuestra disposición típica de vector testigo de $[1, z, x, y]$, tenemos las siguientes matrices:

$$
\begin{align*}
\mathbf{L} &= \begin{bmatrix}
0 & 0 & 1 & 1 \\
\end{bmatrix} \\
\mathbf{R} &= \begin{bmatrix}
1 & 0 & 0 & 0 \\
\end{bmatrix} \\
\mathbf{O} &= \begin{bmatrix}
0 & 1 & 0 & 0 \\
\end{bmatrix}
\end{align*}
$$

## Los sistemas de restricciones de rango uno son para conveniencia
El [artículo original para Groth16](https://eprint.iacr.org/2016/260.pdf) no tiene ninguna referencia al término Sistema de restricciones de rango uno. Un R1CS es útil desde una perspectiva de implementación, pero desde una perspectiva matemática pura, simplemente etiqueta y agrupa explícitamente los coeficientes de diferentes variables. Por lo tanto, cuando lees artículos académicos sobre el tema, generalmente no se incluye porque es un detalle de implementación de un concepto más abstracto.

## Recursos útiles
- Esta [herramienta web calcula R1CS](https://asecuritysite.com/zero/go_r1cs) para un conjunto de restricciones (pero solo funciona con una variable de entrada y salida).

- [El famoso ejemplo de Vitalik de x**3 + x + 5 == 35](https://medium.com/@VitalikButerin/quadratic-arithmetic-programs-from-zero-to-hero-f6d558cea649)

- [Tutorial de R1CS del blog de conocimiento cero](https://www.zeroknowledgeblog.com/index.php/the-pinocchio-protocol/r1cs)

## Obtenga más información con RareSkills
Esta publicación del blog está extraída de los materiales de aprendizaje de nuestro [curso de conocimiento cero](https://www.rareskills.io/zk-bootcamp).

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*
