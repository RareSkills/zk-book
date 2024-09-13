# El lema de Schwartz-Zippel y su aplicación a las pruebas de conocimiento cero

Casi todos los algoritmos de pruebas de conocimiento cero se basan en el lema de Schwartz-Zippel para lograr la concisión.

El lema de Schwartz-Zippel establece que si se nos dan dos polinomios $p(x)$ y $q(x)$ con grados $d_p$ y $d_q$ respectivamente, y si $p(x) \neq q(x)$, entonces el número de puntos donde $p(x)$ y $q(x)$ se intersecan es menor o igual que $\mathsf{max}(d_p, d_q)$.

Consideremos algunos ejemplos.

## Ejemplos de polinomios y el lema de Schwartz-Zippel
### Una línea recta que corta una parábola

Considere el polinomio $p(x) = x$ y $q(x) = x^2$. Se intersecan en $x = 0$ y $x = 1$.
![Gráfico de y = x e y = x^2](https://pub-32882f615aa84e4a94e1279ccf3ab85a.r2.dev/schwartz-zippel-x-x2-example.png)

Se intersecan en dos puntos, que es el grado máximo entre los polinomios $y = x$ e $y = x^2$.

### Un polinomio de grado tres y un polinomio de grado uno

Considere los polinomios $p(x) = x^3$ y $q(x) = x$. Los polinomios se intersecan en $x = -1$, $x = 0$ y $x = 1$ y en ningún otro lugar. El número de intersecciones está limitado por el grado máximo de los polinomios, que en este caso es 3.

![Gráfico de y = x^3 e y = x](https://pub-32882f615aa84e4a94e1279ccf3ab85a.r2.dev/schwartz-zippel-x-x3-example.png)

## Polinomios en cuerpos finitos y el lema de Schwartz-Zippel
El lema de Schwartz-Zippel se aplica a polinomios en [cuerpos finitos](https://www.rareskills.io/post/finite-fields) (es decir, todos los cálculos se realizan módulo un primo $p$).

## Prueba de igualdad de polinomios
Podemos probar que dos polinomios son iguales verificando si todos sus coeficientes son iguales, pero esto lleva $\mathcal{O}(d)$ tiempo, donde $d$ es el grado del polinomio.

Si, en cambio, podemos evaluar los polinomios en un punto aleatorio $u$, comparemos las evaluaciones en un tiempo $\mathcal{O}(1)$.

Es decir, en un cuerpo finito $\mathbb{F}_{p}$, elegimos un valor aleatorio $u$ de $[0,p)$. Luego evaluamos $y_f=f(u)$ y $y_g=g(u)$. Si $y_f = y_g$, entonces una de dos cosas debe ser cierta:

1. $f(x) = g(x)$
2. $f(x) \neq g(x)$ y elegimos uno de los $d$ puntos donde se intersecan donde $d = \mathsf{max}(\deg(f), \deg(g))$

Si $d << p$, entonces la situación 2 es improbable hasta el punto de ser despreciable.

Por ejemplo, si el campo $\mathbb{F}_{p}$ tiene $p \approx 2^{254}$ (un poco más pequeño que un [uint256](https://www.rareskills.io/post/uint-max-value-solidity)), y si los polinomios no tienen más de un millón de grados, entonces la probabilidad de elegir un punto donde se intersecan es

$$
\frac{1\times 10^6}{2^{254}} \approx \frac{2^{20}}{2^{254}} \approx \frac{1}{2^{234}} \approx \frac{1}{10^{70}}
$$

Para darle una idea de la escala, la cantidad de átomos en el universo es de aproximadamente $10^{78}$ a $10^{82}$, por lo que es extremadamente improbable que elijamos un punto donde la Los polinomios se intersecan si no son iguales.

## Uso del lema de Schwartz-Zippel para comprobar si dos vectores son iguales

Podemos combinar la interpolación de Lagrange con el lema de Schwartz-Zippel para comprobar si dos vectores son iguales.

Normalmente, comprobaríamos la igualdad de vectores comparando si cada uno de los $n$ componentes de los vectores son iguales.

En cambio, si utilizamos un conjunto común de valores $x$ (por ejemplo, $[1,2,..,n]$) para interpolar los vectores:

1. podemos interpolar un polinomio para cada vector $f(x)$ y $g(x)$
2. elegir un punto aleatorio $u$
3. evaluar los polinomios en $u$
4. comprobar si $f(u) = g(u)$

Aunque calcular los polinomios es más trabajo, la comprobación final es mucho más barata.

Aquí hay un ejemplo de cómo realizar este cálculo en Python:

```python
import galois
import numpy as np

p = 103
GF = galois.GF(p)

xs = GF(np.array([1,2,3]))

# vectores arbitrarios
v1 = GF(np.array([4,8,19]))
v2 = GF(np.array([4,8,19]))

def L(v):
return galois.lagrange_poly(xs, v)

p1 = L(v1)
p2 = L(v2)

import random
u = random.randint(0, p)

lhs = p1(u)
rhs = p2(u)

# solo se requiere una comprobación
assert lhs == rhs
```

## Uso de la función Lema de Schwartz-Zippel en demostraciones ZK
Nuestro objetivo final es que el probador envíe una pequeña cadena de datos al verificador para que este pueda comprobarla rápidamente.

La mayoría de las veces, una demostración ZK es esencialmente un polinomio evaluado en un punto aleatorio.

La dificultad que tenemos que resolver es que no sabemos si el polinomio se evalúa *honestamente*; de alguna manera, tenemos que confiar en que el probador no miente cuando evalúa $f(u)$.

Pero antes de llegar a eso, tenemos que aprender a representar un circuito aritmético completo como un pequeño conjunto de polinomios evaluados en un punto aleatorio, que es la motivación de los [Programas aritméticos cuadráticos](rareskills.io/post/quadratic-arithmetic-program).

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*
