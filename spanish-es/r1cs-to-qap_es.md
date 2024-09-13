# Programa de conversión de R1CS a aritmética cuadrática sobre un cuerpo finito en Python

Para que la transformación de R1CS a QAP sea menos abstracta, usemos un ejemplo real.

Digamos que estamos codificando el [circuito aritmético](https://www.rareskills.io/post/arithmetic-circuit)

$$z = x⁴ - 5y²x²$$

Convertido a un [sistema de restricciones de rango 1](https://www.rareskills.io/post/rank-1-constraint-system), esto se convierte en

$$\begin{align*}
v_1 &= xx \\
v_2 &= v_1 * v_1 && //x^4\\
v_3 &= -5yy \\
-v_2 + z &= v_3 * v_1 && //-5y^2 * x^2\\
\end{align*}$$

Necesitamos elegir una característica del [campo finito](https://www.rareskills.io/post/finite-fields) sobre el que haremos esto. Cuando luego combinamos esto con [curvas elípticas](https://www.rareskills.io/post/elliptic-curves-finite-fields), el orden de nuestro campo primo debe ser igual al orden de la curva elíptica. (No hacer coincidir los dos es un error muy común).

Pero por ahora, elegiremos un número pequeño para que sea manejable. Elegiremos el número primo 79.

Primero, definimos nuestras matrices $\mathbf{L}$, $\mathbf{R}$ y $\mathbf{O}$ de la siguiente manera:

```python
import numpy as np

# 1, out, x, y, v1, v2, v3
L = np.array([
[0, 0, 1, 0, 0, 0, 0],
[0, 0, 0, 0, 1, 0, 0],
[0, 0, 0, -5, 0, 0, 0],
[0, 0, 0, 0, 0, 0, 1],
])

R = np.array([
[0, 0, 1, 0, 0, 0, 0],
[0, 0, 0, 0, 1, 0, 0],
[0, 0, 0, 1, 0, 0, 0],
[0, 0, 0, 0, 1, 0, 0],
])

O = np.array([
[0, 0, 0, 0, 1, 0, 0],
[0, 0, 0, 0, 0, 1, 0],
[0, 0, 0, 0, 0, 0, 1],
[0, 1, 0, 0, 0, -1, 0],
])
```

Para verificar que construimos el R1CS correctamente (¡es muy fácil equivocarse cuando se hace manualmente!) creamos un testigo válido y hacemos la multiplicación de matrices:

```python
x = 4
y = -2
v1 = x * x
v2 = v1 * v1 # x^4
v3 = -5*y * y
z = v3*v1 + v2 # -5y^2 * x^2

# witness
a = np.array([1, z, x, y, v1, v2, v3])

assert all(np.equal(np.matmul(L, a) * np.matmul(R, a), np.matmul(O, a))), "not equal"
```
## Aritmética de campos finitos en Python
El siguiente paso es convertir esto en una matriz de campos. Realizar aritmética modular en Numpy será muy complicado, pero es sencillo con la biblioteca Galois. Esto se presentó en nuestro artículo sobre campos finitos, pero aquí hay un breve resumen sobre cómo usarlo:

```python
import galois

GF = galois.GF(79)

a = GF(70)
b = GF(10)

print(a + b)
# imprime 1
```

No podemos darle valores negativos como GF(-1) o lanzará una excepción. Para convertir números negativos a su representación congruente en el campo, podemos agregarles el orden de la curva. Para evitar "desbordar" los valores positivos, tomamos el módulo con el orden de la curva.

```python
L = (L + 79) % 79
R = (R + 79) % 79
O = (O + 79) % 79
```

Nuestras nuevas matrices son
```python
## Nuevos valores de L, R, O
'''
L

[[ 0 0 1 0 0 0 0]
[ 0 0 0 0 1 0 0]
[ 0 0 0 74 0 0 0]
[ 0 0 0 0 0 0 1]]

R
[[ 0 0 1 0 0 0 0]
[ 0 0 0 0 1 0 0]
[ 0 0 0 0 1 0 0]
[ 0 0 0 0 1 0 0]]

O

[[ 0 0 0 0 1 0 0]
[ 0 0 0 0 0 1 0]
[ 0 0 0 0 0 0 1]
[ 0 1 0 0 0 78 0]]
'''
```

Podemos convertirlos en matrices de campos simplemente envolviéndolos con GF ahora. También necesitaremos volver a calcular nuestro testigo, porque contiene valores negativos.

```python
L_galois = GF(L)
R_galois = GF(R)
O_galois = GF(O)

x = GF(4)
y = GF(-2 + 79) # estamos usando 79 como el tamaño del campo, por lo que 79 - 2 es -2
v1 = x * x
v2 = v1 * v1 # x^4
v3 = GF(-5 + 79)*y * y
out = v3*v1 + v2 # -5y^2 * x^2

witness = GF(np.array([1, out, x, y, v1, v2, v3]))

assert all(np.equal(np.matmul(L_galois, witness) * np.matmul(R_galois, witness), np.matmul(O_galois, witness))), "no igual"
```

## Interpolación polinómica en cuerpos finitos
Ahora, necesitamos convertir cada una de las columnas de las matrices en una lista de polinomios de Galois que interpolen las columnas. Los puntos que vamos a interpolar son `x = [1,2,3,4]`, ya que tenemos 4 filas.

```python
def interpolate_column(col):
xs = GF(np.array([1,2,3,4]))
return galois.lagrange_poly(xs, col)

# El eje 0 son las columnas.
# apply_along_axis es lo mismo que hacer un bucle for sobre las columnas y recopilar los resultados en una matriz
U_polys = np.apply_along_axis(interpolate_column, 0, L_galois)
V_polys = np.apply_along_axis(interpolate_column, 0, R_galois)
W_polys = np.apply_along_axis(interpolate_column, 0, O_galois)
```

Si volvemos a observar el contenido de nuestras matrices, esperamos que los dos primeros polinomios de `U_polys` y `V_polys` sean cero, y que la primera columna de `W_polys` también sea cero.

Ejecutamos la siguiente comprobación de cordura:

```python
print(U_polys[:2])
print(V_polys[:2])
print(W_polys[:1])

# [Poly(0, GF(79)) Poly(0, GF(79))]# [Poly(0, GF(79)) Poly(0, GF(79))]# [Poly(0, GF(79))]
```

El término `Poly(0, GF(79))` es simplemente un polinomio donde todos los coeficientes son cero.

Se recomienda al lector que evalúe los polinomios en los valores de la matriz R1CS para ver si interpolan correctamente los valores de la matriz.

## Cálculo de h(x)
Ya sabemos que $t(x)$ será $(x - 1)(x - 2)(x - 3)(x - 4)$ ya que hay cuatro filas.

A modo de recordatorio, esta es la fórmula para un programa aritmético cuadrático. El vector $\mathbf{a}$ es el testigo:

$$
\underbrace{\sum_{i=1}^{m} a_i u_i(x)}_\text{término 1} \underbrace{\sum_{i=1}^m a_i v_i(x)}_\text{término 2} = \underbrace{\sum_{i=1}^{m} a_i w_i(x)}_\text{término 3} + h(x)t(x)
$$

Cada uno de los términos toma el producto interno del testigo con los polinomios de interpolación de columnas. Es decir, cada uno de los términos de suma es efectivamente el producto interno entre $[a₁, …, aₘ]$ y $[u₁(x), ..., uₘ(x)]$

```python
def inner_product_polynomials_with_witness(polys, witness):
mul_ = lambda x, y: x * y
sum_ = lambda x, y: x + y
return reduce(sum_, map(mul_, polys, witness))

term_1 = inner_product_polynomials_with_witness(U_polys, witness)

term_2 = inner_product_polynomials_with_witness(V_polys, witness)

term_3 = inner_product_polynomials_with_witness(W_polys, witness)
```

Para calcular $h(x)$, simplemente lo resolvemos. Tenga en cuenta que no podemos calcular $h(x)$ a menos que tengamos un testigo válido, de lo contrario habrá un resto.

```python
# t = (x - 1)(x - 2)(x - 3)(x - 4)
t = galois.Poly([1, 78], field = GF) * galois.Poly([1, 77], field = GF) * galois.Poly([1, 76], field = GF) * galois.Poly([1, 75], field = GF)

h = (term_1 * term_2 - term_3) // t
```

A diferencia de [poly1d de numpy](https://numpy.org/doc/stable/reference/generated/numpy.poly1d.html), la biblioteca de Galois no nos indicará si hay un resto, por lo que debemos verificar si la fórmula QAP sigue siendo verdadera.

```python
assert term_1 * term_2 == term_3 + h * t, "la división tiene un resto"
```

La comprobación ejecutada anteriormente es muy similar a la que comprobará el verificador.

El esquema anterior no funcionará cuando evaluemos los polinomios en un punto oculto desde una configuración confiable. Sin embargo, la computadora que realiza la configuración confiable aún tendrá que ejecutar muchos de los cálculos anteriores.

## Resumen
En este artículo, presentamos el código Python para convertir un R1CS en un QAP.

## Obtenga más información con RareSkills
Este material es de nuestro [Curso de conocimiento cero](https://www.rareskills.io/zk-bootcamp).

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*
