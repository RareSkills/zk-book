# Programas aritméticos cuadráticos

Un programa aritmético cuadrático es un [circuito aritmético](https://www.rareskills.io/post/arithmetic-circuit), específicamente un [sistema de restricciones de rango 1](https://www.rareskills.io/post/rank-1-constraint-system) (R1CS) representado como un conjunto de polinomios. Se deriva utilizando la interpolación de Lagrange en un sistema de restricciones de rango 1. A diferencia de un R1CS, un programa aritmético cuadrático (QAP) se puede probar para comprobar su igualdad en tiempo $\mathcal{O}(1)$ mediante el lema de Schwartz-Zippel.

## Ideas clave
En el capítulo sobre el lema de Schwartz-Zippel, vimos que podemos comprobar si dos vectores son iguales en tiempo $\mathcal{O}(1)$ convirtiéndolos en polinomios y luego ejecutando la prueba del lema de Schwartz-Zippel sobre los polinomios. (Para aclarar, la *prueba* es en tiempo $\mathcal{O}(1)$, convertir los vectores en polinomios genera una sobrecarga).

Debido a que un sistema de restricciones de rango 1 está compuesto completamente de operaciones vectoriales, nuestro objetivo es probar si

$$\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}\stackrel{?}{=}\mathbf{O}\mathbf{a}$$

se cumple en tiempo $\mathcal{O}(1)$ en lugar de tiempo $\mathcal{O}(n)$ (donde $n$ es el número de filas en $\mathbf{L}$, $\mathbf{R}$ y $\mathbf{O}$).

Pero antes de hacerlo, debemos comprender algunas propiedades clave de la relación entre los vectores y los polinomios que los representan.

Para todas las matemáticas aquí, asumimos que estamos trabajando en un [cuerpo finito](https://www.rareskills.io/post/finite-fields), pero omitimos la notación $\mod p$ para ser más breves.

## Homomorfismos entre la suma de vectores y la suma de polinomios
### La suma de vectores es homomórfica a la suma de polinomios

Si tomamos dos vectores, los interpolamos con polinomios y luego sumamos los polinomios, obtenemos el mismo polinomio que si sumamos los vectores y luego interpolamos el vector suma.

Expresado de manera más matemática, sea $\mathcal{L}(\mathbf{v})$ el polinomio resultante de la interpolación de Lagrange sobre el vector $\mathbf{v}$ utilizando $(1, 2, ..., n)$ como los valores de $x$, donde $n$ es la longitud de $\mathbf{v}$. Lo siguiente es cierto:

$$\mathcal{L}(\mathbf{v} + \mathbf{w}) = \mathcal{L}(\mathbf{v}) + \mathcal{L}(\mathbf{w})$$

En otras palabras, los polinomios resultantes de interpolar los vectores $\mathbf{v}$ y $\mathbf{w}$ son los mismos que los polinomios resultantes de interpolar los vectores $\mathbf{v} + \mathbf{w}$.

#### Ejemplo resuelto
Sea $f_1(x) = x^2$ y $f_2(x) = x^3$ $f_1$ interpola $(1, 1), (2, 4), (3, 9)$ o el vector $[1,4,9]$ y $f_2$ interpola $[1,8,27]$.

La suma de los vectores es $[2,12,36]$ y está claro que $x^3 + x^2$ interpola eso. Sea $f_3(x) = f_1(x) + f_2(x) = x^3 + x^2$.

$$
\begin{align*}
f_3(1) &= 1 + 1 = 2\\
f_3(2) &= 8 + 4 = 12\\
f_3(3) &= 27 + 9 = 36
\end{align*}
$$

#### Probar las matemáticas en Python

Hacer pruebas unitarias de una identidad matemática propuesta no la convierte en verdadera, pero sí ilustra lo que está sucediendo. Se anima al lector a probar algunos vectores diferentes para ver que la identidad se cumple.

```python
import galois
import numpy as np

p = 17
GF = galois.GF(p)

xs = GF(np.array([1,2,3]))

# dos vectores arbitrarios
v1 = GF(np.array([4,8,2]))
v2 = GF(np.array([1,6,12]))

def L(v):
return galois.lagrange_poly(xs, v)

assert L(v1 + v2) == L(v1) + L(v2)
```

### Multiplicación escalar
Sea $\lambda$ un escalar (específicamente, un elemento de campo en un campo finito). Entonces

$$\mathcal{L}(\lambda \mathbf{v}) = \lambda \mathcal{L}(\mathbf{v})$$

#### Ejemplo resuelto
Supongamos que nuestros 3 puntos son $[3, 6, 11]$. El polinomio que interpola esto es $f(x) = x^2 + 2$. Si multiplicamos el vector por 3 obtenemos $[9, 18, 33]$. El polinomio que interpola esto es

```python
from scipy.interpolate import lagrange

x_values ​​= [1, 2, 3]
y_values ​​= [9, 18, 33]

print(lagrange(x_values, y_values))

# 2
# 3 x + 6
```

$3x^2 + 6$, que es igual a $3 \cdot (x^2 + 2)$.

#### Ejemplo resuelto en código
```python
import galois
import numpy as np

p = 17
GF = galois.GF(p)

xs = GF(np.array([1,2,3]))

# vector arbitrario
v = GF(np.array([4,8,2]))

# constante arbitraria
lambda_ = GF(15)

def L(v):
return galois.lagrange_poly(xs, v)

assert L(lambda_ * v) == lambda_ * L(v)
```

### La multiplicación escalar es en realidad una suma de vectores
Cuando decimos "multiplicar un vector por 3", en realidad estamos diciendo "sumar el vector a sí mismo tres veces". Como solo trabajamos en un campo finito, no nos preocupamos por la interpretación de escalares como "0,5".

Podemos pensar en los vectores bajo una suma elemento a elemento (en un campo finito) y en los polinomios bajo una suma (también en un campo finito) como [grupos](https://www.rareskills.io/post/group-theory-and-coding).

La lección más importante de este capítulo es que

**El grupo de vectores bajo adición en un cuerpo finito es homomórfico al grupo de polinomios bajo adición en un cuerpo finito.**

Esto es fundamental porque **la prueba de igualdad de vectores requiere $\mathcal{O}(n)$ tiempo, pero la prueba de igualdad de polinomios requiere $\mathcal{O}(1)$ tiempo.**

Por lo tanto, mientras que la prueba de igualdad de R1CS requiere $\mathcal{O}(n)$ tiempo, podemos aprovechar este homomorfismo para probar la igualdad de R1CS en $\mathcal{O}(1)$ tiempo.

Esto es lo que es un *Programa Aritmético Cuadrático*.

## Un sistema de restricciones de rango 1 en polinomios

Considere que la multiplicación de matrices entre una matriz rectangular y un vector se puede escribir en términos de adición de vectores y multiplicación escalar.

Por ejemplo, si tenemos una matriz $A$ de $3 \times 4$ y un vector $v$ de 4 dimensiones, entonces podemos escribir la multiplicación de matrices como

$$
\mathbf{A} \cdot \mathbf{v} = \begin{bmatrix}
a_{11} & a_{12} & a_{13} & a_{14}\\
a_{21} & a_{22} & a_{23} & a_{24}\\
a_{31} & a_{32} & a_{33} & a_{34}
\end{bmatrix}
\begin{bmatrix}
v_1\\
v_2\\
v_3\\
v_4
\end{bmatrix}
$$

Normalmente pensamos en el vector $v$ "volteándolo" y haciendo un producto interno (producto escalar generalizado) con cada una de las filas, es decir

$$
\mathbf{A}\cdot \mathbf{v} =
\begin{bmatrix}
a_{11}\cdot v_1 + a_{12}\cdot v_2 + a_{13}\cdot v_3 + a_{14}\cdot v_4\\
a_{21}\cdot v_1 + a_{22}\cdot v_2 + a_{23}\cdot v_3 + a_{24}\cdot v_4\\
a_{31}\cdot v_1 + a_{32}\cdot v_2 + a_{33}\cdot v_3 + a_{34}\cdot v_4
\end{bmatrix}
$$

Sin embargo, podríamos pensar en dividir la matriz $A$ en un conjunto de vectores de la siguiente manera:

$$
\mathbf{A} = \begin{bmatrix}
a_{11} \\
a_{21} \\
a_{31}
\end{bmatrix}
,
\begin{bmatrix}
a_{12} \\
a_{22} \\
a_{32}
\end{bmatrix}
,
\begin{bmatrix}
a_{13} \\
a_{23} \\
a_{33}
\end{bmatrix}
,
\begin{bmatrix}
a_{14} \\
a_{24} \\
a_{34}
\end{bmatrix}
$$

y multiplicando cada vector por un escalar del vector $\mathbf{v}$:

$$
\mathbf{A}\cdot \mathbf{v} = \begin{bmatrix}
a_{11} \\
a_{21} \\
a_{31}
\end{bmatrix}\cdot v_1
+
\begin{bmatrix}
a_{12} \\
a_{22} \\
a_{32}
\end{bmatrix}\cdot v_2
+
\begin{bmatrix}
a_{13} \\
a_{23} \\
a_{33}
\end{bmatrix}\cdot v_3
+
\begin{bmatrix}
a_{14} \\
a_{24} \\
a_{34}
\end{bmatrix}\cdot v_4
$$

Hemos expresado la multiplicación de matrices entre $\mathbf{A}$ y $\mathbf{v}$ puramente en términos de suma vectorial y multiplicación escalar.

Debido a que establecimos anteriormente que el grupo de vectores bajo adición en un campo finito es homomórfico al grupo de polinomios bajo adición en un campo finito, podemos expresar el cálculo anterior en términos de polinomios que representan los vectores.

## Probando sucintamente que $\mathbf{A}\mathbf{v}_1 = \mathbf{B}\mathbf{v}_2$

Supongamos que tenemos la matriz $\mathbf{A}$ y $\mathbf{B}$ tales que

$$
\begin{align*}
\mathbf{A} = \begin{bmatrix}
6 & 3\\
4 & 7\\
\end{bmatrix}\\
\mathbf{B} = \begin{bmatrix}
3 & 9 \\
12 & 6\\
\end{bmatrix}
\end{align*}
$$

y los vectores $\mathbf{v}_1$ y $\mathbf{v}_2$

$$
\begin{align*}
\mathbf{v}_1 = \begin{bmatrix}
2 \\
4 \\
\end{bmatrix}\\
\mathbf{v}_2 = \begin{bmatrix}
2 \\
2 \\
\end{bmatrix}
\end{align*}
$$

Queremos comprobar si

$$
\mathbf{A}\mathbf{v}_1 = \mathbf{B}\mathbf{v}_2
$$

es verdadero.

Obviamente podemos realizar la aritmética matricial, pero la comprobación final requerirá $n$ comparaciones, donde $n$ es el número de filas en $\mathbf{A}$ y $\mathbf{B}$. Queremos hacerlo en $\mathcal{O}(1)$ tiempo.

Primero, convertimos la multiplicación de matrices $\mathbf{A}\mathbf{v}_1$ y $\mathbf{B}\mathbf{v}_2$ al grupo de vectores bajo la suma:

$$
\begin{align*}
\mathbf{A} &= \begin{bmatrix}
6 \\
4 \\
\end{bmatrix}
,
\begin{bmatrix}
3 \\
7 \\
\end{bmatrix}\\
\mathbf{B} &= \begin{bmatrix}
3 \\
12 \\
\end{bmatrix}
,
\begin{bmatrix}
9 \\
6 \\
\end{bmatrix}
\end{align*}
$$

Ahora queremos encontrar el equivalente homomórfico de

$$
\begin{bmatrix}
6 \\
4 \\
\end{bmatrix}\cdot 2+
\begin{bmatrix}
3 \\
7 \\
\end{bmatrix}\cdot 4\stackrel{?}{=}
\begin{bmatrix}
3 \\
12 \\
\end{bmatrix}\cdot 2=
\begin{bmatrix}
9 \\
6 \\
\end{bmatrix}\cdot 2
$$

en el grupo de polinomios.

Convirtamos cada uno de los vectores en polinomios sobre los valores $x$ $[1,2]$:

$$
\underbrace{
\begin{bmatrix}
6 \\
4 \\
\end{bmatrix}}_{p_1(x)}\cdot 2+
\underbrace{
\begin{bmatrix}
3 \\
7 \\
\end{bmatrix}}_{p_2(x)}\cdot 4\stackrel{?}{=}
\underbrace{
\begin{bmatrix}
3 \\
12 \\
\end{bmatrix}}_{q_1(x)}\cdot 2=
\underbrace{
\begin{bmatrix}
9 \\
6 \\
\end{bmatrix}}_{q_2(x)}\cdot 2
$$

Invocaremos algo de Python para calcular la interpolación de Langrage:

```python
import galois
import numpy as np

p = 17
GF = galois.GF(p)

x_values ​​= GF(np.array([1, 2]))

def L(v):
return galois.lagrange_poly(x_values, v)

p1 = L(GF(np.array([6, 4])))
p2 = L(GF(np.array([3, 7])))
q1 = L(GF(np.array([3, 12])))
q2 = L(GF(np.array([9, 6])))

print(p1)
# 15x + 8 (mod 17)
print(p2)
# 4x + 16 (mod 17)
print(q1)
# 9x + 11 (mod 17)
print(q2)
# 14x + 12 (mod 17)
```

Finalmente, podemos comprobar si

$$p_1(x) \cdot 2+ p_2(x) \cdot 4 \stackrel{?}= q_1(x) \cdot 2 + q_2(x) \cdot 2$$

es verdadero invocando el lema de Schwartz-Zippel:

```python
import random
u = random.randint(0, p)
tau = GF(u) # un punto aleatorio

left_hand_side = p1(tau) * GF(2) + p2(tau) * GF(4)
right_hand_side = q1(tau) * GF(2) + q2(tau) * GF(2)

assert left_hand_side == right_hand_side
```

**La declaración assert final puede probar si $\mathbf{A}\mathbf{v}_1 = \mathbf{B}\mathbf{v}_2$ haciendo una sola comparación en lugar de $n$.**

## R1CS a QAP: Probar sucintamente que $\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}=\mathbf{O}\mathbf{a}$
Dado que sabemos cómo probar $\mathbf{A}\mathbf{v}_1 = \mathbf{B}\mathbf{v}_2$ sucintamente, ¿podemos también probar si $\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}=\mathbf{O}\mathbf{a}$ de manera sucinta?

Las matrices tienen $m$ columnas, así que vamos a dividir cada una de las matrices en $m$ vectores columna e interpolarlos en $(1, 2, ..., n)$ para producir $m$ polinomios cada uno.

Sean $u_1(x), u_2(x), ..., u_m(x)$ los polinomios que interpolan los vectores columna de $\mathbf{L}$.

Sean $v_1(x), v_2(x), ..., v_m(x)$ los polinomios que interpolan los vectores columna de $\mathbf{R}$.

Sean $w_1(x), w_2(x), ..., w_m(x)$ los polinomios que interpolan los vectores columna de $\mathbf{O}$.

Sin pérdida de generalidad, digamos que tenemos 4 columnas ($m = 4$) y tres filas ($n = 3$).

Visualmente, esto se puede representar como
$$
\begin{array}{c}
\mathbf{L} = \begin{bmatrix}
\quad l_{11} \quad& l_{12} \quad& l_{13} \quad& l_{14} \quad\\
\quad l_{21} \quad& l_{22} \quad& l_{23} \quad& l_{24} \quad\\
\quad l_{31} \quad& l_{32} \quad& l_{33} \quad& l_{34} \quad
\end{bmatrix} \\
\\
\qquad u_1(x) \quad u_2(x) \quad u_3(x) \quad u_4(x)
\end{array}
\begin{array}{c}
\mathbf{R} = \begin{bmatrix}
\quad r_{11} \quad& r_{12} \quad& r_{13} \quad& r_{14} \quad\\
\quad r_{21} \quad& r_{22} \quad& r_{23} \quad& r_{24} \quad\\
\quad r_{31} \quad& r_{32} \quad& r_{33} \quad& r_{34} \quad
\end{bmatrix} \\
\\
\qquad v_1(x) \quad v_2(x) \quad v_3(x) \quad v_4(x)
\end{array}
$$

$$
\begin{array}{c}
\mathbf{O} = \begin{bmatrix}
\quad o_{11} \quad& o_{12} \quad& o_{13} \quad& o_{14} \quad\\
\quad o_{21} \quad& o_{22} \quad& o_{23} \quad& o_{24} \quad\\
\quad o_{31} \quad& o_{32} \quad& o_{33} \quad& o_{34} \quad
\end{bmatrix} \\
\\
\qquad w_1(x) \quad w_2(x) \quad w_3(x) \quad w_4(x)
\end{array}
$$

Dado que multiplicar un vector columna por un escalar es homomórfico a multiplicar un polinomio por un escalar, cada uno de los polinomios se puede multiplicar por el elemento respectivo en el testigo.

Por ejemplo,

$$
\mathbf{L}\mathbf{a} = \begin{bmatrix}
\quad l_{11} \quad& l_{12} \quad& l_{13} \quad& l_{14} \quad\\
\quad l_{21} \quad& l_{22} \quad& l_{23} \quad& l_{24} \quad\\
\quad l_{31} \quad& l_{32} \quad& l_{33} \quad& l_{34} \quad
\end{bmatrix}
\begin{bmatrix}
a_1 \\
a_2 \\
a_3 \\
a_4
\end{bmatrix}
$$

se convierte en

$$
\begin{align*}
&=\begin{bmatrix}
u_1(x) & u_2(x) & u_3(x) & u_4(x)
\end{bmatrix}
\begin{bmatrix}
a_1 \\
a_2 \\
a_3 \\
a_4
\end{bmatrix}\\
&=a_1u_1(x) + a_2u_2(x) + a_3u_3(x) + a_4u_4(x)\\
&=\sum_{i=1}^4 a_iu_i(x)
\end{align*}
$$

Observe que el resultado final es un único polinomio con grado como máximo $n - 1$ (ya que hay $n$ filas en $\mathbf{L}$, $u_1(x), ..., u_n(x)$ tienen grado como máximo $n - 1$).

En el caso general, $\mathbf{L}\mathbf{a}$ se puede escribir como

$$
\sum_{i=1}^m a_iu_i(x)
$$

después de convertir cada una de las $m$ columnas en polinomios.

Usando los mismos pasos anteriores, cada producto de matriz testigo en el R1CS $\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a} = \mathbf{O}\mathbf{a}$ se puede transformar como

$$
\begin{align*}
\mathbf{L}\mathbf{a} \rightarrow \sum_{i=1}^m a_iu_i(x) \\
\mathbf{R}\mathbf{a} \rightarrow \sum_{i=1}^m a_iv_i(x) \\
\mathbf{O}\mathbf{a} \rightarrow \sum_{i=1}^m a_iw_i(x)
\end{align*}
$$

Dado que cada uno de los términos de suma produce un solo polinomio, podemos escribirlos como:

$$
\begin{align*}
\mathbf{L}\mathbf{a} &\rightarrow \sum_{i=1}^m a_iu_i(x) = u(x)\\
\mathbf{R}\mathbf{a} &\rightarrow \sum_{i=1}^m a_iv_i(x) = v(x)\\
\mathbf{O}\mathbf{a} &\rightarrow \sum_{i=1}^m a_iw_i(x) = w(x)
\end{align*}
$$

### ¿Por qué interpolar todas las columnas?
Debido a los homomorfismos $\mathcal{L}(\mathbf{v}_1) + \mathcal{L}(\mathbf{v}_2) = \mathcal{L}(\mathbf{v}_1 + \mathbf{v}_2)$ y $\mathcal{L}(\lambda \mathbf{v}) = \lambda \mathcal{L}(\mathbf{v})$, si calculamos $u(x)$ como $\mathcal{L}(\mathbf{L}\mathbf{a})$ obtenemos el mismo resultado que si aplicamos la interpolación de Lagrange a las columnas de $\mathbf{L}$ y luego multiplicamos cada uno de los polinomios por el elemento respectivo en $\mathbf{a}$ y sumamos el resultado.

Dicho de otra manera,

$$
\sum_{i=1}^m a_iu_i(x) = \mathcal{L}(\mathbf{L}\mathbf{a}) \mid u_i(x) \text{ es la interpolación de Lagrange de la columna } i \text{ de } \mathbf{L}
$$

Entonces, ¿por qué no calcular una única interpolación de Lagrange en lugar de $m$?

Necesitamos hacer una distinción entre *quién* está usando el QAP. El verificador (y la configuración confiable que veremos más adelante) no conocen al testigo $\mathbf{a}$ y, por lo tanto, no pueden calcular $\mathcal{L}(\mathbf{L}\mathbf{a})$. Esta es una optimización que puede hacer el probador, pero otras partes en el protocolo ZK no pueden hacer uso de esa optimización.

Todas las partes involucradas deben tener un acuerdo común sobre el QAP (las interpolaciones polinómicas de las matrices) antes de que se realicen las pruebas y verificaciones.

### Desequilibrio de grado polinómico

Sin embargo, no podemos expresar simplemente el resultado final como

$$u(x)v(x) = w(x)$$

porque los grados no coincidirán.

La multiplicación de dos polinomios da como resultado un polinomio producto cuyo grado es la suma de los grados de los dos polinomios que se multiplican.

Como cada uno de $u(x)$, $v(x)$ y $w(x)$ tendrá grado $n - 1$, $u(x)v(x)$ generalmente tendrá grado $2n - 2$ y $w(x)$ tendrá grado $n - 1$, por lo que no serán iguales aunque los vectores subyacentes que multiplicaron sean iguales.

Esto se debe a que los homomorfismos que establecimos anteriormente solo hacen afirmaciones sobre la suma de vectores, no sobre el producto de Hadamard.

Sin embargo, el vector que $u(x)v(x)$ interpola, es decir,

$$((1, u(1)v(1)), (2, u(2)v(2)), ..., (n, u(n)v(n)))$$

es el mismo que el vector que $w(x)$ interpola, es decir,

$$((1, w(1)), \quad (2, w(2)), \quad ..., \quad (n, w(n)))$$

En otras palabras

$$((1, u(1)v(1)), (2, u(2)v(2)), ..., (n, u(n)v(n))) = ((1, w(1)), (2, w(2)), ..., (n, w(n)))$$

Aunque los vectores "subyacentes" son iguales, los polinomios que los interpolan no son iguales.

### Ejemplo de igualdad subyacente
Digamos que $u(x)$ es el polinomio que interpola

$$(1,\boxed{2}), (2,\boxed{4}), (3,\boxed{8})$$

y $v(x)$ es el polinomio que interpola

$$(1,\boxed{4}), (2,\boxed{2}), (3,\boxed{8})$$

Si tratamos a $u(x)$ como interpolando el vector $[2,4,8]$ y a $v(x)$ como interpolando el vector $[4,2,8]$, entonces podemos ver que su polinomio producto interpola el producto Hadamard de los dos vectores. El producto Hadamard de $[2,4,8]$ y $[4,2,8]$ es $[8,8,64]$.

Si multiplicamos $u(x)$ y $v(x)$, obtenemos $w(x) = 4x^4 - 18x^3 + 36x^2 - 42x + 28$.

Podemos ver en el gráfico a continuación que el polinomio producto interpola el producto de Hadamard $[8, 8, 64]$ de los dos vectores.

![Intersección de 3 puntos de u, v y w](https://pub-32882f615aa84e4a94e1279ccf3ab85a.r2.dev/qap-3-point-cross.png)

Entonces, ¿cómo podemos "hacer" que $w(x)$ sea igual a $u(x)v(x)$ si interpolan los mismos valores de $y$ sobre $(1,2,...,n)$?

### Interpolación del vector $\mathbf{0}$
Si $\mathbf{v_1} \circ \mathbf{v_2} = \mathbf{v_3}$, entonces $\mathbf{v_1} \circ \mathbf{v_2} = \mathbf{v_3} + \mathbf{0}$.

En lugar de interpolar $\mathbf{0}$ con la interpolación de Lagrange y obtener $f(x) = 0$ (recuerde que la interpolación de Lagrange encuentra el polinomio de interpolación de grado más bajo), podemos usar un polinomio de grado más alto que equilibrará la discrepancia en grados.

Por ejemplo, el polinomio negro ($b(x)$) en la imagen de abajo interpola $[(1,0), (2,0), (3,0)]$:

![gráfico de polinomio cero](https://pub-32882f615aa84e4a94e1279ccf3ab85a.r2.dev/qap-zero-polynomial.png)

Ahora, dado que $4x^4 -18x^3 + 8x^2 + 42x - 36$ es una interpolación válida de $[0,0,0]$, podemos escribir nuestra ecuación original

$u(x)v(x) = w(x) + b(x)$

¡y la ecuación estará balanceada!

$b(x)$ se calculó simplemente como $u(x)v(x) - w(x)$ (el polinomio <span style="color:#008aff">azul</span> menos el polinomio <span style="color:red">rojo</span>)

Sin embargo, no podemos dejar que el probador elija *cualquier* $b(x)$, de lo contrario podría elegir un $b(x)$ que equilibre $u(x)v(x)$ y $w(x)$ incluso si no interpola el mismo vector ($[8, 8, 64]$ en nuestro ejemplo). El probador tiene demasiada flexibilidad para elegir $b(x)$. Específicamente, queremos exigir que $b(x)$ tenga raíces en $x = 1,2,\dots,n$, es decir, que interpole el vector $\mathbf{0}$. De esa manera, la transformación polinómica de $\mathbf{v}_1 \circ \mathbf{v}_2 = \mathbf{v}_3 + \mathbf{0}$ aún respeta los vectores subyacentes.

Para restringir su elección de $b(x)$, podemos usar el siguiente teorema:

#### La unión de raíces del producto polinómico
**Teorema**: Si $h(x) = f(x)g(x)$ y $f(x)$ tiene un conjunto de raíces $\set{r_f}$ y $g(x)$ tiene un conjunto de raíces $\set{r_g}$, entonces $h(x)$ tiene raíces $\set{r_f} \cup \set{r_g}$.

##### Ejemplo
Sea $f(x) = (x - 3)(x - 4)$ y $g(x) = (x - 5)(x - 6)$. Entonces $h(x) = f(x)g(x)$ tiene raíces $\set{3,4,5,6}$.

Podemos usar el teorema anterior para hacer cumplir que $b(x)$ tiene raíces en $x = 1,2,\dots,n$.

#### Forzando a $b(x)$ a ser el vector cero
Descomponemos $b(x)$ en $b(x) = h(x)t(x)$ donde $t(x)$ es el polinomio

$$
t(x) = (x-1)(x-2)\dots(x-n)
$$

entonces cualquier polinomio multiplicado por $t(x)$ también será el vector cero, ya que debe tener raíces en $x = 1,2,\dots,n$.

Por lo tanto, reemplazaremos $b(x)$ con $h(x)t(x)$ en nuestra ecuación.

Por lo tanto, nuestra igualdad se convertirá en

$$
u(x)v(x) = w(x) + h(x)t(x)
$$

Podemos calcular $h(x)$ usando álgebra básica:

$$
h(x) = \frac{u(x)v(x) - w(x)}{t(x)}
$$

## QAP de extremo a extremo
Supongamos que tenemos un R1CS con matrices $\mathbf{L}$, $\mathbf{R}$ y $\mathbf{O}$ y el vector testigo $\mathbf{a}$.

$$\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a} = \mathbf{O}\mathbf{a}$$

Las matrices tienen $n$ columnas y $m$ filas donde $n = 3$ y $m = 4$.

Es decir, $\mathbf{L}$, $\mathbf{R}$ y $\mathbf{O}$ son los siguientes:

$$
\begin{array}{c}
\mathbf{L} = \begin{bmatrix}
\quad l_{11} \quad& l_{12} \quad& l_{13} \quad& l_{14} \quad\\
\quad l_{21} \quad& l_{22} \quad& l_{23} \quad& l_{24} \quad\\
\quad l_{31} \quad& l_{32} \quad& l_{33} \quad& l_{34} \quad
\end{bmatrix} \\
\\
\mathbf{R} = \begin{bmatrix}
\quad r_{11} \quad& r_{12} \quad& r_{13} \quad& r_{14} \quad\\
\quad r_{21} \quad& r_{22} \quad& r_{23} \quad& r_{24} \quad\\
\quad r_{31} \quad& r_{32} \quad& r_{33} \quad& r_{34} \quad
\end{bmatrix} \\
\\
\mathbf{O} = \begin{bmatrix}
\quad o_{11} \quad& o_{12} \quad& o_{13} \quad& o_{14} \quad\\
\quad o_{21} \quad& o_{22} \quad& o_{23} \quad& o_{24} \quad\\
\quad o_{31} \quad& o_{32} \quad& o_{33} \quad& o_{34} \quad
\end{bmatrix}
\end{array}
$$

Y el vector testigo $\mathbf{a}$ es

$$\mathbf{a} = \begin{bmatrix}
a_1 \\ a_2 \\ a_3 \\ a_4
\end{bmatrix}$$

Dividimos cada una de las matrices en $m$ vectores columna y los interpolamos en $(1, 2, ..., n)$ para producir $m$ polinomios cada uno.

$$
\begin{array}{c}
\mathbf{L} = \underbrace{\begin{bmatrix}
l_{11} \\l_{12} \\ l_{13} \\ l_{14} \\
\end{bmatrix}}_{u_1(x)}
\quad
\underbrace{\begin{bmatrix}
l_{21} \\ l_{22} \\ l_{23} \\ l_{24}
\end{bmatrix}}_{u_2(x)}
\quad
\underbrace{\begin{bmatrix}
l_{31} \\ l_{32} \\ l_{33} \\ l_{34} \\
\end{bmatrix}}_{u_3(x)}
\quad
\underbrace{\begin{bmatrix}
l_{41} \\ l_{42} \\ l_{43} \\ l_{44}
\end{bmatrix}}_{u_4(x)}
\end{array}
$$

$$
\begin{array}{c}
\mathbf{R} = \underbrace{\begin{bmatrix}
r_{11} \\r_{12} \\ r_{13} \\ r_{14} \\
\end{bmatrix}}_{v_1(x)}
\quad
\underbrace{\begin{bmatrix}
r_{21} \\ r_{22} \\ r_{23} \\ r_{24}
\end{bmatrix}}_{v_2(x)}
\quad
\underbrace{\begin{bmatrix}
r_{31} \\ r_{32} \\ r_{33} \\ r_{34} \\
\end{bmatrix}}_{v_3(x)}
\quad
\underbrace{\begin{bmatrix}
r_{41} \\ r_{42} \\ r_{43} \\ r_{44}
\end{bmatrix}}_{v_4(x)}
\end{array}
$$

$$
\begin{array}{c}
\mathbf{O} = \underbrace{\begin{bmatrix}
o_{11} \\o_{12} \\ o_{13} \\ o_{14} \\
\end{bmatrix}}_{w_1(x)}
\quad
\underbrace{\begin{bmatrix}
o_{21} \\ o_{22} \\ o_{23} \\ o_{24}
\end{bmatrix}}_{w_2(x)}
\quad
\underbrace{\begin{bmatrix}
o_{31} \\ o_{32} \\ o_{33} \\ o_{34} \\
\end{bmatrix}}_{w_3(x)}
\quad
\underbrace{\begin{bmatrix}
o_{41} \\ o_{42} \\ o_{43} \\ o_{44}
\end{bmatrix}}_{w_4(x)}
\end{array}
$$

Cada uno de los productos matriz-vector $\mathbf{L}\mathbf{a}$, $\mathbf{R}\mathbf{a}$ y $\mathbf{O}\mathbf{a}$ son homomórficamente equivalentes de la siguiente manera polinomios:

$$
\begin{align*}
\sum_{i=1}^4 a_iu_i(x) &= a_1u_1(x) + a_2u_2(x) + a_3u_3(x) + a_4u_4(x) = u(x) \\
\sum_{i=1}^m a_iv_i(x) &= a_1v_1(x) + a_2v_2(x) + a_3v_3(x) + a_4v_4(x) = v(x) \\
\sum_{i=1}^m a_iw_i(x) &= a_1w_1(x) + a_2w_2(x) + a_3w_3(x) + a_4w_4(x) = w(x) \\
\end{align*}
$$

En nuestro caso, $t(x)$ será

$$t(x) = (x - 1)(x - 2)(x - 3)$$

y $h(x)$ será

$$h(x) = \frac{u(x)v(x) - w(x)}{t(x)}$$

La fórmula final para una representación QAP del R1CS original es

$$\sum_{i=1}^4 a_iu_i(x)\sum_{i=1}^4 a_iv_i(x) = \sum_{i=1}^4 a_iw_i(x) + h(x)t(x)$$

## Fórmula final para un QAP
Un QAP es la siguiente fórmula:

$$\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x) = \sum_{i=1}^m a_iw_i(x) + h(x)t(x)$$

Donde $u_i(x)$, $v_i(x)$ y $w_i(x)$ son polinomios que interpolan las columnas de $\mathbf{L}$, $\mathbf{R}$ y $\mathbf{O}$ respectivamente, $t(x)$ es $(x - 1)(x - 2)...(x - n)$, donde $n$ es el número de filas en $\mathbf{L}$, $\mathbf{R}$ y $\mathbf{O}$, y $h(x)$ es

$$
h(x) = \frac{\sum_{i=1}^ma_iu_i(x)\sum_{i=1}^ma_iv_i(x) - \sum_{i=1}^ma_iw_i(x)}{t(x)}
$$

## Conocimiento cero sucinto Pruebas con programas de aritmética cuadrática
Supongamos que tuviéramos una forma para que el verificador envíe un valor aleatorio $\tau$ al probador y que este respondiera con

$$
\begin{align*}
A &= u(\tau)\\
B &= v(\tau)\\
C &= w(\tau) + h(\tau)t(\tau)
\end{align*}
$$

El verificador podría verificar que $AB = C$ y aceptar que el probador tiene un testigo válido $\mathbf{a}$ que satisface tanto el R1CS como el QAP.

Sin embargo, esto requeriría que el verificador confíe en que el probador está evaluando los polinomios correctamente, y no tenemos un mecanismo para obligar al probador a hacerlo.

En el próximo capítulo, mostraremos el código Python para [convertir un R1CS en un QAP](https://www.rareskills.io/post/r1cs-to-qap) según lo que analizamos en este capítulo.

Luego, analizaremos las configuraciones confiables para comenzar a abordar el problema de cómo lograr que el demostrador evalúe los polinomios de manera honesta.

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*