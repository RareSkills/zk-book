# Curvas elípticas sobre campos finitos

¿Cómo se ven las curvas elípticas en campos finitos?

Es fácil visualizar curvas elípticas suaves, pero ¿cómo se ven las curvas elípticas sobre un campo finito?

El siguiente es un gráfico de $y² = x³ + 3 \pmod {23}$

![Gráfico de y² = x³ + 3 \pmod 23](https://static.wixstatic.com/media/935a00_9b8594bdeb9b4eb580847f1d5ffcd6c0~mv2.png/v1/fill/w_614,h_678,al_c,lg_1,q_90,enc_auto/935a00_9b8594bdeb9b4eb580847f1d5ffcd6c0~mv2.png)

Como solo permitimos entradas de números enteros (más específicamente, elementos de [campo finito](https://www.rareskills.io/post/finite-fields)), no vamos a obtener un gráfico uniforme.

No todos los valores de $x$ darán como resultado un entero para el valor de $y$ cuando resolvemos la ecuación, por lo que no habrá ningún punto presente en ese valor para $x$. Puedes ver esos espacios en el gráfico anterior.

El código para generar este gráfico se proporcionará más adelante.

### El número primo cambia el gráfico drásticamente

A continuación se muestran algunos gráficos de $y² = x³ + 3$ realizados sobre los módulos 11, 23, 31 y 41 respectivamente. Cuanto mayor sea el módulo, más puntos contiene y más complejo parece ser el gráfico.

![Gráfico de curvas elípticas módulo 11, 23](https://static.wixstatic.com/media/935a00_e592040ff7174e81a1f32ed7ed70a150~mv2.png/v1/fill/w_1053,h_565,al_c,q_90,enc_auto/935a00_e592040ff7174e81a1f32ed7ed70a150~mv2.png)

![Gráfico de curvas elípticas módulo 23, 31](https://static.wixstatic.com/media/935a00_382bd8455deb45efba13fdb7d77517b4~mv2.png/v1/fill/w_1053,h_565,al_c,q_90,enc_auto/935a00_382bd8455deb45efba13fdb7d77517b4~mv2.png)

En el artículo anterior, establecimos que los puntos de la curva elíptica con la operación "conectar y voltear" son un grupo. Cuando hacemos esto sobre un cuerpo finito, sigue siendo un grupo, pero se convierte en un grupo cíclico, lo que resulta tremendamente útil para nuestra aplicación. Lamentablemente, para entender por qué es cíclico se necesitarán algunos cálculos muy complejos, por lo que, por ahora, tendrás que aceptarlo. Pero esto no debería sorprenderte demasiado. Tenemos una cantidad finita de puntos, por lo que generar cada punto mediante la ejecución de $(x + 1)G, (x + 2)G, … (x + \text{order} - 1)G$ debería parecer al menos plausible.

En la aplicación de la criptografía, $p$ debe ser grande. En la práctica, es de más de 200 bits. Volveremos a tratar este tema en una sección posterior.

## Antecedentes

### Elemento de campo

En este artículo, vamos a decir "elemento de campo" con frecuencia y, con suerte, gracias a nuestros tutoriales anteriores (especialmente sobre [campos finitos](rareskills.io/post/finite-fields)) ya te resultará cómodo ese término. Pero, si no, es un entero positivo que está dentro de una operación de módulo.

Es decir, si hacemos una suma módulo 11, entonces los elementos de campo finitos de ese conjunto son $\set{0,1,…,9,10}$. No es correcto decir "enteros", aunque ese sea el tipo de datos que usaremos en nuestros ejemplos de Python. No puedes tener un elemento de campo negativo (aunque los enteros pueden ser negativos) cuando haces una suma módulo un número primo. Un número "negativo" en un campo finito es simplemente el inverso aditivo de otro número, es decir, un número que, cuando se suma, da como resultado cero. Por ejemplo, en un cuerpo finito de módulo 11, 4 puede considerarse "-7" porque $7 + 4 \pmod {11}$ es $0$, en un sentido comparativo a cómo 7 + (-7) es cero para los números regulares.

En el cuerpo de los números racionales, la multiplicación tiene como elemento identidad 1, y el inverso de un número es simplemente el numerador y el denominador invertidos. Por ejemplo, 500/303 es el inverso de 303/500 porque si los multiplicas, obtienes 1.

En un cuerpo finito, el inverso de un elemento es el número con el que lo multiplicas para obtener el elemento de cuerpo finito 1. Por ejemplo, en módulo 23, 6 es el inverso de 4 porque cuando los multiplicas juntos módulo 23, obtienes 1. Cuando el orden del cuerpo es primo, todos los números excepto cero tienen un inverso.

### Grupos cíclicos

Un [grupo] cíclico (https://www.rareskills.io/group-theory-and-coding) es un grupo en el que cada elemento puede calcularse comenzando con un elemento generador y aplicando repetidamente el operador binario del grupo.

Un ejemplo muy simple son los números enteros módulo 11 bajo la suma. Si su generador es 1 y continúa sumando el generador a sí mismo, puede generar todos los elementos del grupo de 0 a 10.

Decir que los puntos de una curva elíptica forman un grupo cíclico (bajo la suma de curvas elípticas) significa que podemos representar cada número en un cuerpo finito como un punto de curva elíptica y sumarlos como lo haríamos con los números enteros regulares en un cuerpo finito.

Es decir,

$5 + 7 \pmod p$ es homomórfico a $5G + 7G$

Donde G es el generador del grupo cíclico de curva elíptica.

Esto sólo es cierto en el caso de curvas elípticas sobre cuerpos finitos que tienen un número primo de puntos, que son los tipos de curvas que utilizamos en la práctica. Esto es algo que volveremos a tratar más adelante.

## Fórmula BN128

La curva BN128, que utilizan las precompilaciones de Ethereum para verificar las pruebas ZK, se especifica de la siguiente manera:

$$
p = 21888242871839275222246405745257275088696311157297823662689037894645226208583
$$

$$
y² = x³ + 3 \pmod p
$$

Aquí $p$ es el módulo de campo.

El `field_modulus` no debe confundirse con el orden de la curva, que es la cantidad de puntos en la curva.

Para la curva bn128, el orden de la curva es el siguiente:

```python
from py_ecc.bn128 import curve_order
# 21888242871839275222246405745257275088548364400416034343698204186575808495617
print(curve_order)
```

El módulo del campo es muy grande, lo que hace que experimentar con él sea complicado. En la siguiente sección, desarrollaremos una intuición para los puntos de la curva elíptica en campos finitos utilizando la misma fórmula, pero con un módulo más pequeño.

## Generación de un grupo cíclico de curvas elípticas $y² = x³ + 3 \pmod {11}$

Para resolver la ecuación anterior y determinar qué puntos $(x, y)$ están en la curva, necesitaremos calcular $\sqrt{(x³ + 3)} \pmod {11}$.

### Raíces cuadradas modulares

Usamos el [algoritmo de Tonelli Shanks](https://en.wikipedia.org/wiki/Tonelli%E2%80%93Shanks_algorithm) para calcular raíces cuadradas modulares. Puedes leer sobre cómo funciona el algoritmo si tienes curiosidad, pero por ahora puedes tratarlo como una caja negra que calcula la raíz cuadrada matemática de un elemento de campo sobre un módulo, o te permite saber si la raíz cuadrada no existe.

Por ejemplo, la raíz cuadrada de 5 módulo 11 es 4 (4 \times 4 \mod 11 = 5), pero no existe una raíz cuadrada de 6 módulo 11. (Se anima al lector a descubrir que esto es cierto mediante la fuerza bruta).

Las raíces cuadradas suelen tener dos soluciones, una positiva y una negativa. Aunque no tenemos números con un signo negativo en un cuerpo finito, aún tenemos una noción de "números negativos" en el sentido de tener una inversa.

Puede encontrar código en línea para implementar el algoritmo descrito anteriormente, pero para evitar poner grandes fragmentos de código en este tutorial, instalaremos una biblioteca de Python en su lugar.

Por ejemplo, la raíz cuadrada de 5 módulo 11 es 4 (4 × 4 mod 11 = 5), pero no existe una raíz cuadrada de 6 módulo 11. (Se anima al lector a descubrir que esto es cierto mediante la fuerza bruta).

Las raíces cuadradas tienen dos soluciones, una positiva y una negativa. Aunque no tenemos números con un signo negativo en un cuerpo finito, aún tenemos una noción de “números negativos” en el sentido de tener una inversa.

Puede encontrar código en línea para implementar el algoritmo descrito anteriormente, pero para evitar colocar grandes fragmentos de código en este tutorial, instalaremos una biblioteca de Python en su lugar.

```bash
python3 -m pip install libnum
```

Después de instalar [libnum](https://pypi.org/project/libnum/), podemos ejecutar el siguiente código para demostrar su uso.

```python
from libnum import has_sqrtmod_prime_power, has_sqrtmod_prime_power

# las funciones toman argumentos# has_sqrtmod_prime_power(n, field_mod, k), donde n**k,
# pero no nos interesan las potencias en campos modulares, por lo que establecemos k = 1
# verificamos si existe sqrt(8) mod 11
print(has_sqrtmod_prime_power(8, 11, 1))
# Falso

# verificamos si existe sqrt(5) mod 11
print(has_sqrtmod_prime_power(5, 11, 1))
# Verdadero

# calculamos sqrt(5) mod 11
print(list(libnum.sqrtmod_prime_power(5, 11, 1)))
# [4, 7]

assert (4 ** 2) % 11 == 5
assert (7 ** 2) % 11 == 5

# esperamos que 4 y 7 sean inversos entre sí, porque en matemáticas "regulares", las dos soluciones de una raíz cuadrada son sqrt y -sqrt
assert (4 + 7) % 11 == 0
```

Ahora que sabemos cómo calcular raíces cuadradas modulares, podemos iterar a través de los valores de $x$ y calcular $y$ a partir de la fórmula $y² = x³ + b$. Resolver $y$ es solo una cuestión de tomar la raíz cuadrada modular de ambos lados (si existe) y guardar los pares $(x, y)$ resultantes para que podamos graficarlos más tarde.

Creemos un gráfico simple de una curva elíptica

$$y² = x³ + 3 \pmod {11}$$

```python
import libnum
import matplotlib.pyplot as plt

def generate_points(mod):
    xs = []
    ys = []
    def y_squared(x):
        return (x**3 + 3) % mod

    for x in range(0, mod):
        if libnum.has_sqrtmod_prime_power(y_squared(x), mod, 1):
            square_roots = libnum.sqrtmod_prime_power(y_squared(x), mod, 1)

            # we might have two solutions
            for sr in square_roots:
                ys.append(sr)
                xs.append(x)
    return xs, ys


xs, ys = generate_points(11)
fig, (ax1) = plt.subplots(1, 1);
fig.suptitle('y^2 = x^3 + 3 (mod p)');
fig.set_size_inches(6, 6);
ax1.set_xticks(range(0,11));
ax1.set_yticks(range(0,11));
plt.grid()
plt.scatter(xs, ys)
plt.plot();
```

El resultado del gráfico se muestra a continuación:

![Gráfico de y² = x³ + 3 (mod 11)](https://static.wixstatic.com/media/935a00_2355ae79d450498eb3ee5b6721634b43~mv2.png/v1/fill/w_614,h_678,al_c,lg_1,q_90,enc_auto/935a00_2355ae79d450498eb3ee5b6721634b43~mv2.png)

Algunas observaciones:

- No habrá ningún valor de x o y mayor o igual que el módulo que usemos
- Al igual que el gráfico de valores reales, el modular "parece simétrico"

## Adición de puntos de curva elíptica

Aún más interesante, nuestro "unir los puntos" ¡La operación “y voltear” para calcular curvas elípticas todavía funciona!

Pero dado que estamos haciendo esto sobre un campo finito, esto no debería sorprendernos. Nuestras fórmulas sobre números reales utilizan las operaciones de campo normales de suma y multiplicación. Aunque utilizamos raíces cuadradas para determinar si un punto está en la curva, y las raíces cuadradas no son un operador de campo válido, no utilizamos raíces cuadradas para calcular la suma y duplicación de puntos.

El lector puede verificar esto eligiendo dos puntos de los gráficos anteriores, luego insertándolos en el código a continuación para sumar puntos y ver que siempre caen en otro punto (o en el punto del infinito si los puntos son inversos entre sí). Estas fórmulas se toman de la [página de Wikipedia sobre la multiplicación de puntos de curvas elípticas](https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication).

```python
def double(x, y, a, p):
    lambd = (((3 * x**2) % p ) *  pow(2 * y, -1, p)) % p
    newx = (lambd**2 - 2 * x) % p
    newy = (-lambd * newx + lambd * x - y) % p
    return (newx, newy)

def add_points(xq, yq, xp, yp, p, a=0):
    if xq == yq == None:
        return xp, yp
    if xp == yp == None:
        return xq, yq

    assert (xq**3 + 3) % p == (yq ** 2) % p, "q not on curve"
    assert (xp**3 + 3) % p == (yp ** 2) % p, "p not on curve"

    if xq == xp and yq == yp:
        return double(xq, yq, a, p)
    elif xq == xp:
        return None, None

    lambd = ((yq - yp) * pow((xq - xp), -1, p) ) % p
    xr = (lambd**2 - xp - xq) % p
    yr = (lambd*(xp - xr) - yp) % p
    return xr, yr
```

Aquí hay algunas visualizaciones de cómo se ve "conectar y voltear" en un cuerpo finito:

![ejemplos de suma de EC en un cuerpo finito](https://pub-32882f615aa84e4a94e1279ccf3ab85a.r2.dev/elliptic-curve-finite-fields-example.jpg)

## Cada punto de la curva elíptica en un grupo cíclico tiene un "número"

Un grupo cíclico, por definición, se puede generar sumando repetidamente el generador a sí mismo.

Usemos un ejemplo real de $y² = x³ + 3 \pmod {11}$ con el punto generador siendo $(4, 10)$.

Usando las funciones de Python anteriores, podemos comenzar con el punto $(4, 10)$ y generar cada punto en el grupo:

```python
# for our purposes, (4, 10) is the generator point G
next_x, next_y = 4, 10print(1, 4, 10)
points = [(next_x, next_y)]
for i in range(2, 12):
    # repeatedly add G to the next point to generate all the elements
    next_x, next_y = add_points(next_x, next_y, 4, 10, 11)
    print(i, next_x, next_y)
    points.append((next_x, next_y))
```

La salida será

```bash
0 4 10
1 7 7
2 1 9
3 0 6
4 8 8
5 2 0
6 8 3
7 0 5
8 1 2
9 7 4
10 4 1
11 None None
12 4 10 # note que este es el mismo punto que el primero
```

Observe que $(\text{order} + 1)G = G$. Al igual que la adición modular, cuando "desbordamos", el ciclo comienza de nuevo.

Aquí, "None" significa el punto en el infinito, que de hecho es parte del grupo. Agregar el punto en el infinito al generador devuelve el generador, ya que así es como se supone que se comporta el elemento de identidad.

Podemos asignar a cada punto un "número" en función de cuántas veces agregamos el generador a sí mismo para llegar a ese punto.

Podemos usar el siguiente código para trazar la curva y asignarle un número

```python
xs11, ys11 = generate_points(11)

fig, (ax1) = plt.subplots(1, 1);
fig.suptitle('y^2 = x^3 + 3 (mod 11)');
fig.set_size_inches(13, 6);

ax1.set_title("modulo 11")
ax1.scatter(xs11, ys11, marker='o');
ax1.set_xticks(range(0,11));
ax1.set_yticks(range(0,11));
ax1.grid()

for i in range(0, 11):
    plt.annotate(str(i+1), (points[i][0] + 0.1, points[i][1]), color="red");
```

Se puede pensar que el texto rojo comienza con el elemento de identidad y cuántas veces le agregamos el generador.

![gráfica de y^2 = x^3 + 3 (mod 11) con los puntos numerados](https://static.wixstatic.com/media/935a00_3e9b90d38e9c4c4a82b34d138fa9f49c~mv2.png/v1/fill/w_1063,h_565,al_c,q_90,enc_auto/935a00_3e9b90d38e9c4c4a82b34d138fa9f49c~mv2.png)

### Las inversas de puntos siguen siendo simétricas verticalmente

Aquí hay una observación interesante: observe que los puntos que comparten el mismo valor x suman 12, lo que corresponde al elemento identidad $(12 \mod 12 = 0)$. Si sumamos el punto $(4, 1)$, que es el punto 11 en nuestro gráfico a $(4, 10)$, obtendremos el punto en el infinito, que sería el elemento número 12 del grupo.

### El orden no es el módulo

En este ejemplo, el orden del grupo es 12 (número total de puntos de la curva elíptica en nuestro grupo), a pesar de que la fórmula para la curva elíptica es módulo 11. Esto se enfatizará varias veces, pero NO debe asumir que el módulo en la curva elíptica es el orden del grupo. Sin embargo, puede estimar el rango de orden de la curva a partir del módulo del campo mismo usando el [Teorema de Hasse](https://en.wikipedia.org/wiki/Hasse%27s_theorem_on_elliptic_curves).

### Si el número de puntos es primo, entonces la suma de puntos se comporta como un campo finito

En el gráfico anterior, hay 12 puntos (incluido 0). La suma módulo 12 no es un cuerpo finito porque 12 no es primo.

Sin embargo, si elegimos nuestros parámetros para la curva con cuidado, podemos crear una curva elíptica donde los puntos corresponden a elementos en un cuerpo finito. Es decir, el orden de la curva es igual al orden del cuerpo finito.

Por ejemplo, $y^2 = x^3 + 7 \pmod {43}$ crea una curva con 31 puntos en total como se puede ver en el gráfico a continuación:

![curva elíptica con 31 puntos](https://pub-32882f615aa84e4a94e1279ccf3ab85a.r2.dev/elliptic-curve-finitie-order-31.jpg)

Cuando el orden de la curva coincide con el orden del cuerpo finito, **toda operación que realice en el cuerpo finito tiene un equivalente homomórfico en la curva elíptica**.

Para pasar de un campo finito a una curva elíptica, elegimos un punto (arbitrariamente) para que sea el generador y luego multiplicamos el elemento del campo finito por el generador.

## La multiplicación es en realidad una suma repetida

No existe la multiplicación de puntos de curva elíptica. Cuando decimos "multiplicación escalar" en realidad nos referimos a la suma repetida. No se pueden tomar dos puntos de curva elíptica y multiplicarlos (bueno, se puede hacer con [emparejamientos bilineales](https://www.rareskills.io/post/bilinear-pairing), pero eso es algo que veremos más adelante).

Cuando usamos la biblioteca de Python para hacer `multiply(G1, x)`, esto es realmente lo mismo que `G1 + G1 + … + G1` `x` veces. En realidad, no sumamos tantas veces, usamos algunos atajos inteligentes con duplicación de puntos para completar la operación en tiempo logarítmico.

Por ejemplo, si quisiéramos calcular 135G, realmente calcularíamos los siguientes valores de manera eficiente usando la duplicación de puntos, los almacenaríamos en caché,

```
G, 2G, 4G, 8G, 16G, 32G, 64G, 128G
```

... luego sumaríamos 128G + 4G + 2G + G = 135G.

Cuando decimos `5G + 6G = 11G`, esencialmente estamos sumando G a sí mismo 11 veces. Usando el atajo ilustrado arriba, podemos calcular 11G con una cantidad logarítmica de cálculos, pero al final del día, es solo una suma repetida.

## Biblioteca Python bn128

La biblioteca que usa la implementación de EVM pyEVM para las precompilaciones de curva elíptica es `py_ecc`, y dependeremos en gran medida de esa biblioteca. El código a continuación muestra cómo se ven los puntos del generador y también muestra algunas operaciones de suma y multiplicación escalar.

Así es como se ve un punto G1:

```python
from py_ecc.bn128 import G1, multiplicar, sumar, eq, neg

print(G1)
# (1, 2)

print(add(G1, G1))
# (1368015179489954701390400359078579693043519447331113978918064868415326638035, 9918110051302171585080402603319702774565515993150576347155970296011118125764)

print(multiplicar(G1, 2))
#(1368015179489954701390400359078579693043519447331113978918064868415326638035, 9918110051302171585080402603319702774565515993150576347155970296011118125764)

# 10G + 11G = 21G
assert eq(add(multiply(G1, 10), multiplicar(G, 11)), multiplicar(G1, 21))
```

Aunque los números son grandes y difíciles de leer, podemos ver que sumar un punto a sí mismo da como resultado El mismo valor que "multiplicar" un punto por 2. Los dos puntos anteriores son claramente el mismo punto. La tupla sigue siendo un par $(x, y)$, solo que sobre un dominio muy grande.

El número impreso arriba es enorme por una razón. No queremos que los atacantes puedan tomar un punto de curva elíptica y calcular el elemento de campo que lo generó. Si el orden de nuestro grupo cíclico es demasiado pequeño, entonces el atacante puede simplemente forzarlo.

Aquí hay un gráfico de los primeros 1000 puntos:

![gráfico de los primeros 1000 puntos de bn128](https://static.wixstatic.com/media/935a00_d9bd567f47c247f588061305dc97940e~mv2.png/v1/fill/w_656,h_514,al_c,lg_1,q_85,enc_auto/935a00_d9bd567f47c247f588061305dc97940e~mv2.png)

Y este es el código para generar el gráfico anterior:

```python
import matplotlib.pyplot as plt
from py_ecc.bn128 import G1, multiply, neg
import math
import numpy as np
xs = []
ys = []
for i in range(1,1000):
    xs.append(i)
    ys.append(int(multiply(G1, i)[1]))
    xs.append(i)
    ys.append(int(neg(multiply(G1, i))[1]))
plt.scatter(xs, ys, marker='.')
```

Esto puede parecer aterrador, pero la única diferencia con lo que hicimos en la sección anterior es que usamos un módulo mucho más grande y un punto diferente para el generador.

### Suma en la biblioteca

La biblioteca `py_ecc` nos facilita la suma de puntos y la sintaxis debería ser autoexplicativa:

```python
from py_ecc.bn128 import G1, multiplicar, añadir, eq

# 5 = 2 + 3
assert eq(multiply(G1, 5), add(multiply(G1, 2), multiplicar(G1, 3)));
```

La suma en un cuerpo finito es homomórfica a la suma entre puntos de curva elíptica (cuando su orden es igual). Debido al logaritmo discreto, otra parte puede sumar puntos de curva elíptica sin saber qué elementos del cuerpo generaron esos puntos.

En este punto, es de esperar que el lector tenga una buena intuición para sumar puntos de curvas elípticas, tanto teórica como prácticamente, porque los algoritmos de conocimiento cero modernos dependen *en gran medida* de esto.

### Detalle de implementación sobre el homomorfismo entre la suma modular y la suma de curvas elípticas

Aquí debemos hacer una distinción cuidadosa entre las terminologías:

El **módulo de campo** es el módulo sobre el que hacemos la curva. El **orden de la curva** es la cantidad de puntos en la curva.

Si comienza con un punto $R$ y agrega el orden de la curva $o$, obtendrá $R$ de regreso. Si agrega el módulo de campo, obtendrá un punto diferente.

```python
from py_ecc.bn128 import curve_order, field_modulus, G1, multiplicar, eq

x = 5 # elegido aleatoriamente
# Esto pasa
assert eq(multiply(G1, x), multiplicar(G1, x + curve_order))

# Esto falla
assert eq(multiply(G1, x), multiplicar(G1, x + field_modulus))
```

La implicación de esto es que `(x + y) mod curve_order == xG + yG`.

```python
x = 2 ** 300 + 21
y = 3 ** 50 + 11

# (x + y) == xG + yG
assert eq(multiply(G1, (x + y)), add(multiply(G1, x), multiplicar(G1, y)))
```

Aunque la operación `x + y` claramente "se desbordará" sobre el orden de la curva, esto no importa. Al igual que en un cuerpo finito, este es el comportamiento que esperamos. La multiplicación de la curva elíptica ejecuta implícitamente la misma operación que tomar el módulo antes de realizar la multiplicación.

De hecho, ni siquiera necesitamos hacer el módulo si solo nos interesan los números positivos, la siguiente identidad también se cumple:

```python
x = 2 ** 300 + 21
y = 3 ** 50 + 11

assert eq(multiply(G1, (x + y) % curve_order), add(multiply(G1, x), multiplicar(G1, y)))
```

Sin embargo, si hacemos el módulo matemático finito con el número incorrecto (algún número que no sea el orden de la curva), la igualdad se romperá si "desbordamos"

```python
x = 2 ** 300 + 21
y = 3 ** 50 + 11 # estos valores son lo suficientemente grandes como para desbordarse:

assert eq(multiply(G1, (x + y) % (curve_order - 1)), add(multiply(G1, x), multiplicar(G1, y))), "esto se rompe"
```

#### Codificación de números racionales

Cuando tomamos el módulo, podemos codificar un concepto de división.

Por ejemplo, no podemos hacer lo siguiente utilizando números enteros regulares.

```python
# esto genera una excepción
eq(add(multiply(G1, 5 / 2), multiplicar(G1, 1 / 2), multiplicar(G1, 3)
```

Sin embargo, en un campo finito, 1/2 se puede calcular de manera significativa como el inverso multiplicativo de 2. Por lo tanto, 5 / 2 se puede codificar como $5 \cdot \mathsf{inv}(2)$.

Así es como podemos hacerlo en Python:

```python
five_over_two = (5 * pow(2, -1, curve_order)) % curve_order
one_half = pow(2, -1, curve_order)

# Básicamente 5/2 = 2.5# 2.5 + 0.5 = 3
# pero estamos haciendo esto en un campo finito
assert eq(add(multiply(G1, five_over_two), multiplicar(G1, uno_medio)), multiplicar(G1, 3))
```

#### Asociatividad

Sabemos que los grupos son asociativos, por lo que esperamos que la siguiente identidad sea verdadera en general:

```python
x = 5
y = 10
z = 15

lhs = add(add(multiply(G1, x), multiplicar(G1, y)), multiplicar(G1, z))

rhs = add(multiply(G1, x), add(multiply(G1, y), multiplicar(G1, z)))

assert eq(lhs, rhs)
```

Se anima al lector a probar diferentes valores de `x`, `y` y `z` por sí mismo.

#### Cada elemento tiene una inversa

La biblioteca `py_ecc` nos proporciona la función `neg` que proporcionará la inversa de un elemento dado al girarlo sobre el eje y (en un cuerpo finito). La biblioteca codifica el "punto en el infinito" como `None` de Python.

```python
from py_ecc.bn128 import G1, multiplicar, neg, is_inf, Z1

# elegir un elemento de campo
x = 12345678# generar el punto
p = multiplicar(G1, x)

# invertir
p_inv = neg(p)

# cada elemento sumado a su inverso produce el elemento identidadassert is_inf(add(p, p_inv))

# Z1 es simplemente None, que es el punto en el infinito
assert Z1 es None

# caso especial: el inverso de la identidad es en sí mismo
assert eq(neg(Z1), Z1)
```

Como es el caso con las curvas elípticas sobre números reales, el inverso de un punto de una curva elíptica tiene el mismo valor x, pero el valor y es el inverso.

```python
from py_ecc.bn128 import G1, neg, multiply

field_modulus = 21888242871839275222246405745257275088696311157297823662689037894645226208583
for i in range(1, 4):
    point = multiply(G1, i)
    print(point)
    print(neg(point))
    print('----')

    # x values are the same
    assert int(point[0]) == int(neg(point)[0])

    # y values are inverses of each other, we are adding y values
    # not ec points
    assert int(point[1]) + int(neg(point)[1]) == field_modulus
```

##### Cada elemento puede ser generado por un generador

Cuando se trata de más de $2^{200}$ puntos, esto no es posible verificarlo por fuerza bruta. Sin embargo, considere el hecho de que `eq(multiply(G1, x), multiplicar(G1, x + order))` siempre es verdadero. Eso significa que podemos generar hasta puntos de orden, luego vuelve al punto de partida.

#### ¿Qué pasa con `optimized_bn128`?

Al examinar la biblioteca, verá una implementación llamada optimized_bn128. Si compara el tiempo de ejecución, verá que esta versión se ejecuta mucho más rápido y es la implementación utilizada por pyEvm. Sin embargo, para fines educativos, es preferible utilizar la versión no optimizada, ya que estructura los puntos de una manera más intuitiva (la tupla x, y habitual). La versión optimizada estructura los puntos EC como 3-tuplas, que son más difíciles de interpretar.

```python
from py_ecc.optimized_bn128 import G1, multiplicar, neg, is_inf, Z1
print(G1)
# (1, 2, 1)
```

## Pruebas básicas de conocimiento cero con curvas elípticas

Considere este ejemplo bastante trivial:

Afirmación: "Conozco dos valores $x$ e $y$ tales que $x + y = 15$"

Prueba: multiplico `x` por `G1` e `y` por `G1` y te los doy como `A` y `B`.

Verificador: Multiplicas 15 por G1 y compruebas que `A + B == 15G1`.

Aquí está en Python:

```python
from py_ecc.bn128 import G1, multiply, add

# Prover
secret_x = 5
secret_y = 10

x = multiply(G1, 5)
y = multiply(G1, 10)

proof = (x, y, 15)

# verifier
if multiply(G1, proof[2]) == add(proof[0], proof[1]):
    print("statement is true")
else:
    print("statement is false")
```

Aunque el verificador no sabe qué son `x` e `y`, puede verificar que `x` e `y` suman 15 en el espacio de curva elíptica, por lo tanto `secret_x` y `secret_y` suman 15 como elementos de campo finito.

Es un ejercicio para que el lector haga algo más sofisticado, como demostrar el conocimiento de una solución a un sistema lineal de ecuaciones.

Como pista (muy importante), multiplicar un número por una constante es lo mismo que la suma repetida. La suma repetida es lo mismo que la multiplicación escalar de curva elíptica. Por lo tanto, si x es un punto de curva elíptica, podemos multiplicarlo por un escalar 9 como `multiply(x, 9)`. Esto es coherente con nuestra afirmación de que no podemos multiplicar puntos de curva elíptica: en realidad, estamos multiplicando un punto de curva elíptica por un escalar, no por otro punto.

¿Puedes demostrar que conoces $x$ de modo que $23x = 161$? ¿Puedes generalizar esto a más variables?

Otra pista: tú (el probador) y el verificador deben acordar la fórmula de antemano, ya que el verificador ejecutará la misma "estructura" de la fórmula original cuya solución afirmas conocer.

### Supuestos de seguridad

Para que el esquema anterior sea seguro, asumimos que si publicamos un punto como `multiplicar(G1, x)`, un atacante no puede inferir del valor $(x, y)$ creado cuál era el valor original de $x$. Este es el supuesto del logaritmo discreto. Es por eso que el número primo sobre el que calculamos la fórmula debe ser grande, de modo que el atacante no pueda adivinarlo por fuerza bruta.

Hay algoritmos más sofisticados, como el algoritmo [baby step giant step](https://en.wikipedia.org/wiki/Baby-step_giant-step) que puede superar la fuerza bruta.

Nota: El BN128 se basa en el supuesto de que tiene 128 bits de seguridad. La curva elíptica se calcula en un campo finito de 254 bits, pero se cree que tiene 128 bits de seguridad ya que hay mejores algoritmos que la fuerza bruta ingenua para calcular el logaritmo discreto.

### Verdadero conocimiento cero

También debemos señalar que nuestro ejemplo `A + B = 15G` no es verdaderamente conocimiento cero. Si un atacante adivina `a` y `b`, puede verificar su suposición comparando los puntos de la curva elíptica generados con los nuestros.

La solución a este problema se abordará en un capítulo posterior.

## Tratar las curvas elípticas sobre campos finitos como una caja negra mágica

Al igual que no necesita saber cómo funciona una función hash bajo el capó para usarla, no necesita saber los detalles de implementación de agregar puntos de curva elíptica y multiplicarlos con un escalar.

Sin embargo, necesita saber las reglas que siguen. A riesgo de sonar como un disco rayado en este punto, siguen las reglas de los grupos cíclicos:

- la suma de los puntos de la curva elíptica es cerrada: produce otro punto de la curva elíptica
- la suma de los puntos de la curva elíptica es asociativa
- existe un elemento identidad
- cada elemento tiene un inverso que, cuando se suma, produce el elemento identidad

Siempre que entiendas esto, puedes sumar, multiplicar e invertir a tu gusto sin hacer nada inválido. Cada una de estas operaciones tiene una función correspondiente en la biblioteca `py_ecc`.

Esto es lo más importante que debes recordar para esta lección:

**Las curvas elípticas sobre cuerpos finitos cifran homomórficamente la suma en un cuerpo finito.**

### Matemáticas lunares: ¿cómo sabemos el orden de la curva?

El lector puede preguntarse cómo podemos determinar el orden de la curva bn128 sin contar todas las soluciones válidas de la fórmula. Hay más puntos válidos de los que cualquier computadora puede enumerar, entonces, ¿cómo llegamos al orden de la curva?

Este es un ejemplo del tipo de matemática que intentamos evitar, porque es bastante avanzada. Resulta que calcular la cantidad de puntos se puede hacer en tiempo polinómico con el [algoritmo de Schoof](https://en.wikipedia.org/wiki/Schoof%27s_algorithm). No se espera que comprenda cómo funciona este algoritmo, pero es suficiente saber que existe. Cómo llegamos al orden de la curva no es importante desde el punto de vista de la implementación, solo nos importa que los diseñadores lo calcularan correctamente.

Los materiales aquí en RareSkills están cuidadosamente diseñados para mantenerse alejados de estos campos minados matemáticos.

## Aprende más con RareSkills

Es por eso que nuestro [curso de conocimiento cero](https://www.rareskills.io/zk-bootcamp) enfatiza tanto los conceptos básicos del álgebra abstracta. Entender los detalles de implementación de las curvas elípticas es terriblemente difícil. Pero entender el comportamiento de los grupos cíclicos, aunque inusual al principio, es completamente comprensible para la mayoría de los programadores. Una vez que entendemos eso, el comportamiento general de agregar puntos de curva elíptica se vuelve intuitivo, a pesar de que la operación es difícil de visualizar.

*Traducido al Español por ARCADIO Garcia, Septiembre 2024*
