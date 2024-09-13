## Interpolación de Lagrange con Python

La interpolación de Lagrange es una técnica para calcular un polinomio que pasa por un conjunto de $n$ puntos.

## Interpolación de un vector como polinomio
## Ejemplos

### Una línea recta que pasa por dos puntos
Consideremos que si tenemos dos puntos, se pueden interpolar con una línea. Por ejemplo, dados $(1, 1)$ y $(2, 2)$, podemos dibujar una línea que intersecta ambos puntos, sería un polinomio de grado 1 $y = x$.

### Un solo punto
Ahora consideremos que si tenemos un punto, podemos dibujar una línea a través de ese punto con un polinomio de grado 0. Por ejemplo, si el punto es $(3, 5)$ podemos dibujar una línea a través de él $y = 5$ (que es un polinomio de grado 0).

### Tres puntos y una parábola
El patrón de que podemos "dibujar un polinomio a través de" $n$ puntos con un polinomio de grado $n - 1$ (como máximo) se cumple para cualquier número de puntos. Por ejemplo, los puntos $(0, 0), (1, 1), (2, 4)$ se pueden interpolar con $y = x^2$. Si esos puntos fueran una línea recta, por ejemplo $(0, 0), (1, 1), (2, 2)$, entonces podríamos dibujar una línea a través de $(1, 1)$ y $(2, 2)$ con un polinomio de grado 1 $y = x$, pero en general, tres puntos no serán colineales, por lo que necesitaremos un polinomio de grado 2 para cruzar todos los puntos.

## Código Python para la interpolación de Lagrange
Para nuestros propósitos no es importante entender cómo calcular este polinomio, ya que hay bibliotecas matemáticas que lo harán por nosotros. El algoritmo más común es la *interpolación de Lagrange* y mostramos cómo hacerlo en Python.

#### Ejemplo de coma flotante
Podemos calcular un polinomio $p(x)$ que cruce los puntos $(1,4), (2,8), (3,2), (4,1)$ usando la interpolación de Lagrange.

```python
from scipy.interpolate import lagrange
x_values ​​= [1, 2, 3, 4]
y_values ​​= [4, 8, 2, 1]

print(lagrange(x_values, y_values))
# 3 2
# 2.5 x - 20 x + 46.5 x - 25
```

#### Ejemplo de campo finito
Usemos el mismo polinomio que antes, pero esta vez usaremos un campo finito $\mathbb{F}_{17}$ en lugar de números de punto flotante.

```python
import galois
import numpy as np
GF17 = galois.GF(17)

xs = GF17(np.array([1,2,3,4]))
ys = GF17(np.array([4,8,2,1]))

p = galois.lagrange_poly(xs, ys)

assert p(1) == GF17(4)
assert p(2) == GF17(8)
assert p(3) == GF17(2)
assert p(4) == GF17(1)
```

### Unicidad del polinomio de interpolación
Volviendo a nuestro ejemplo de los puntos $(1, 1), (2, 2)$, el polinomio de menor grado que los interpola, $y = x$. En general,

**Para un conjunto de $n$ puntos, existe un único polinomio de grado más bajo de grado $n - 1$ como máximo que los interpola.**

El polinomio de grado más bajo que interpola los polinomios a veces se denomina *polinomio de Lagrange*.

La consecuencia de esto es que

**Si usamos los puntos $(1,2,...,n)$ como los valores $x$ para convertir un vector de longitud $n$ en un polinomio mediante la interpolación de Lagrange, entonces el polinomio resultante es único.**

En otras palabras, dada una base consistente de valores x sobre los cuales interpolar un vector, existe un único polinomio que interpola un vector dado. Dicho de otra manera, cada vector de longitud $n$ tiene una representación polinómica única.

De manera informal, cada vector de grado $n$ tiene un polinomio de grado $n - 1$ único que lo "representa". El grado podría ser menor si, por ejemplo, los puntos son colineales, pero el vector será único.

La parte del "grado más bajo" es importante. Dados dos puntos, hay una cantidad extremadamente grande de polinomios que cruzan esos dos puntos, pero el polinomio de grado más bajo es único.

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*
