# Cuerpos finitos y aritmética modular para pruebas de conocimiento cero

*Este artículo es el tercero de una serie. Presentamos cuerpos finitos en el contexto de circuitos para pruebas de conocimiento cero. Los capítulos anteriores son [P vs NP y su aplicación a pruebas de conocimiento cero](https://www.rareskills.io/post/p-vs-np) y [Circuitos aritméticos](https://www.rareskills.io/post/arithmetic-circuit).*

En el capítulo anterior sobre circuitos aritméticos, señalamos una limitación: no podemos codificar el número $2/3$ porque no se puede representar con precisión usando binario. También señalamos que no teníamos una forma explícita de manejar el desbordamiento.

Ambos problemas se pueden solucionar sin problemas con una variante de la aritmética, popular en la criptografía general, llamada *campos finitos*.

## Campos finitos

Dado un número primo `p`, podemos crear un campo finito con `p` elementos tomando el conjunto de números enteros $\set{0, 1, 2, …, p-1}$ y definiendo que la suma y la multiplicación se realicen módulo $p$. Comenzaremos limitándonos a los campos donde el número de elementos es primo.

Por ejemplo, si el número primo $p$ es $7$, entonces los elementos en el campo finito son $\set{0, 1, 2, 3, 4, 5, 6}$. Cualquier número fuera de este rango ($≥ p$ o $< 0$) siempre se asigna a un número "equivalente" en este rango usando módulo. La palabra técnica para "equivalente" es *congruente*.

El módulo calcula el resto de la división del número por el número primo. Por ejemplo, si nuestro módulo es 7, el número 12 es *congruente* con 5, es decir, $12 \pmod 7 = 5$, y el número 14 es congruente con 0. De manera similar, cuando sumamos dos números, digamos 3 + 5, la suma resultante de 8 es congruente con 1 (8 mod 7 = 1). La siguiente animación ilustra esto:

![Gif de línea numérica](https://static.wixstatic.com/media/706568_27817a32acf7429ca035667488ebce27~mv2.gif)

En Python, el cálculo que se muestra arriba se puede realizar de la siguiente manera:

```python
p = 7
result = (3 + 5) % p
print(result) # imprime 1
```

En este capítulo, siempre que realicemos cálculos, expresaremos nuestro resultado como un número en el rango de $0…(p-1)$, que es el conjunto de elementos en nuestro campo finito `p`. Por ejemplo, 2 * 5 = 10, que “simplificamos” a 3 (módulo 7).

Observe cómo 3 + 5 "desbordó" el límite de 6. **En campos finitos, el desbordamiento no es algo malo, definimos el comportamiento de desbordamiento como parte del cálculo.** En un campo finito módulo 7, 5 + 3 se define como 1.

Los desbordamientos por defecto también se manejan de manera similar. Por ejemplo, $3 - 5 = - 2$, pero en módulo 7 obtenemos $5$ porque $7 - 2 = 5$.

## Cómo funciona la aritmética modular

En un lenguaje de programación típico, escribimos la suma en un cuerpo finito como `(6 + 1) % 7 == 0`, pero en notación matemática, normalmente decimos

$$0 = 6 + 1 \pmod 7$$

O de forma más general,

$$c = a + b \pmod p$$

donde $a$ y $b$ son números en el cuerpo finito, $c$ es el resto que asigna cualquier número $≥ p$ y $< 0 $ al conjunto $\set{0, 1, …, p - 1}$.

La notación $\pmod p$ significa que *toda* la aritmética se realiza módulo $p$. Por ejemplo,

$$a + b = c + d \pmod p$$

Es equivalente (en Python o C) a `a + b % p == c + d % p`.

La multiplicación funciona de manera similar, al multiplicar los números entre sí y luego tomar el módulo:

$$3 = 4 × 6 \pmod 7 = 24 \pmod 7 = 3$$

La operación de multiplicación anterior se puede visualizar de dos maneras:

<video autoplay loop muted controls>
<source src="https://video.wixstatic.com/video/706568_30c0c24e6c344dd786b813c99a76bb50/1080p/mp4/file.mp4" type="video/mp4">
</video>

O alternativamente:

<video autoplay loop muted controls>
<source src="https://video.wixstatic.com/video/706568_011ac2a6b52a48c5a5ffc6221df889a3/1080p/mp4/file.mp4" type="video/mp4">
</video>

Nos referimos a un número en un cuerpo finito como un "elemento".

## $p$ y el orden del cuerpo

El número con el que tomamos el módulo lo llamaremos $p$. En todos nuestros ejemplos es un número primo. En el campo más amplio de las matemáticas, $p$ podría no ser necesariamente primo, pero solo nos ocuparemos de los casos en los que $p$ sea primo.

Debido a esta restricción, el *orden* del cuerpo siempre es igual a $p$. El *orden* es el número de elementos en el cuerpo. El término general para el número con el que tomamos el módulo es la *característica* del cuerpo.

Por ejemplo, si tenemos $p = 5$, los elementos son $\set{0, 1, 2, 3, 4}$. Hay 5 elementos, por lo que el orden de ese campo es 5.

## La identidad de la suma $p$

Cualquier elemento más $p$ es el mismo elemento. Por ejemplo, $(3 + 7) \pmod 7 = 3$. Considere los ejemplos en la siguiente animación:

![Animación de la línea numérica que muestra 3 + 7 = 3 (mod 7)](https://static.wixstatic.com/media/706568_bb147f17337d49788e9e74718b23dcd5~mv2.gif)

## Inverso aditivo

Considere que $5 + (-5) = 0$.

En matemáticas, el inverso aditivo de $a$ es un número $b$ tal que $a + b = 0$. Generalmente, expresamos el inverso aditivo de un número colocando un signo negativo al frente. $-a$ es, por definición, el número que al sumarse con $a$ da como resultado 0.

### Reglas generales de los inversos aditivos

- El cero es su propio inverso aditivo.
- Cada número tiene exactamente un inverso aditivo

Estas reglas de los inversos aditivos también se aplican a los cuerpos finitos. Aunque no tenemos elementos con signos negativos como $-5$, algunos elementos pueden “comportarse” como números negativos entre sí utilizando el operador módulo.

En aritmética regular, $-5$ es el número que, al sumarse a $5$, da como resultado $0$. Si nuestro cuerpo finito es $p = 7$, entonces $2$ puede considerarse como $-5$ porque $(5 + 2) \pmod 7 = 0$. De manera similar, $5$ puede considerarse como $-2$ porque son el inverso aditivo del otro. Para ser precisos, $-2$ es congruente con $5$ o $-2 \equiv 5 \pmod 7$.

Para calcular el inverso aditivo de un elemento, simplemente calcula $p - a$ donde $a$ es el elemento del que estamos tratando de encontrar el inverso aditivo. Por ejemplo, para encontrar el inverso aditivo de 14 módulo 23, calculamos $23 - 14 = 9$. Podemos ver que $14 + 9 \pmod {23} = 0$. $p$ es congruente con cero, por lo que esto es equivalente a calcular $-5$ como $0 - 5$.

Al igual que con los números reales:

- cada elemento en un campo finito tiene exactamente un inverso aditivo
- cero es su propio inverso aditivo.

El patrón general para los inversos aditivos en un campo finito es que los elementos en la primera mitad del campo finito son los inversos aditivos de los elementos en la segunda mitad, como se muestra en la figura siguiente. El cero es la excepción ya que es su propio inverso aditivo. Los números conectados por la línea verde son sus inversos aditivos en el campo $p = 7$:

![Imagen que muestra la relación inversa aditiva](https://static.wixstatic.com/media/706568_b60115959b634536b3ddfc7b8461625b~mv2.jpg/v1/fill/w_956,h_718,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/706568_b60115959b634536b3ddfc7b8461625b~mv2.jpg)

**Ejercicio:** Supongamos que elegimos un $p \geq 3$. ¿Cuáles valores distintos de cero, si los hay, son sus propios inversos aditivos?

## Inverso multiplicativo

Considere que $5 × (1/5) = 1$.

El inverso multiplicativo de $a$ es un número $b$ tal que $ab = 1$. Cada elemento excepto cero tiene un inverso multiplicativo. Con "números regulares", un inverso multiplicativo es $1 / \text{num}$. Por ejemplo, el inverso multiplicativo de $5$ es $1/5$, y el inverso multiplicativo de $19$ es $1/19$.

Aunque no tenemos números fraccionarios en cuerpos finitos, aún podemos encontrar pares de números que "se comportan como" fracciones cuando se suman o multiplican entre sí.

Por ejemplo, el inverso multiplicativo de $4$ en el cuerpo finito $p = 7$ es $2$, porque $4 * 2 = 8$, y $8 \pmod 7 = 1$. Por lo tanto, $2$ "se comporta" como $1/4$ en el cuerpo finito, o para ser más precisos, $1/4$ es congruente con $2 \pmod 7$.

### Reglas generales de los inversos multiplicativos en la aritmética de cuerpos finitos:

- 0 no tiene un inverso multiplicativo
- 1 es su propio inverso multiplicativo
- Cada número (excepto 0) tiene exactamente un inverso multiplicativo (que podría ser él mismo)
- el elemento de valor $(p - 1)$ es su propio inverso multiplicativo. Por ejemplo, en un cuerpo finito de $p = 103$, $1$ y $102$ son sus propios inversos multiplicativos. En un cuerpo finito de $p = 23$, $1$ y $22$ son sus propios inversos multiplicativos (la razón se explica en la próxima sección). Otro ejemplo: en el cuerpo finito módulo 5, 1 es su propio inverso y 4 es su propio inverso. $4 \times 4 = 16$, y $16 \pmod 5 = 1$.

### Por qué el elemento de valor $p - 1$ es su propio inverso multiplicativo

Cuando multiplicamos $-1$ por sí mismo, obtenemos $1$. Por lo tanto, $-1$ es su propio inverso multiplicativo para números reales. El elemento de valor $(p - 1)$ es congruente con $-1$. Por lo tanto, esperamos que $(p - 1)$ sea su propio inverso multiplicativo, y de hecho ese es el caso.

Otra forma de ver por qué $p - 1$ es su propio inverso multiplicativo es considerar que $(p - 1)(p - 1) = p² - 2p + 1$. Dado que $p$ es congruente con $0$, entonces $p² - 2p + 1$ se simplifica a $0^2 - 2*0 + 1 = 1$.

#### Soluciones para circuitos aritméticos sobre cuerpos finitos

Si consideramos el siguiente circuito aritmético sobre números regulares, esperamos que `x = -1` sea la única asignación satisfactoria.

```python
x * x === 1
x + 1 === 0
```

En un cuerpo finito, la asignación satisfactoria es el elemento congruente con $-1$, o $p - 1$.

### Cálculo del inverso multiplicativo con el pequeño teorema de Fermat

El [pequeño teorema de Fermat](https://en.wikipedia.org/wiki/Fermat%27s_little_theorem) establece que

$$
a^{p}=a\pmod p, a\neq0
$$

En otras palabras, si elevas un elemento distinto de cero a $p$, recuperas ese elemento. Algunos ejemplos:

- $3⁵ \pmod 5 = 3$
- $4⁷ \pmod 7 = 4$
- $14⁵³ \pmod {53} = 14$

Ahora considere si dividimos ambos lados de $aᵖ = a \pmod p$ por $a$ (recuerde, $a ≠ 0$):

$$a^p=a$$
$$\frac{a^p}{a}=\frac{a}{a}$$
$$a^{p-1}=1$$

Podemos escribir el resultado como

$$
a(a^{p-2}) = 1
$$

**Esto significa que $aᵖ⁻² \pmod p$ es el inverso multiplicativo de $a$**, ya que $a$ por $aᵖ⁻²$ es 1.

Algunos ejemplos:

- El inverso multiplicativo de $3$ en el cuerpo finito $p = 7$ es $5$. $3⁷⁻² = 5 \pmod 7$
- El inverso multiplicativo de 8 en el cuerpo finito $p = 11$ es $7$. $8¹¹⁻² = 7 \pmod {11}$

La ventaja de este enfoque es que podemos usar el `expmod` [precompilación en Ethereum](https://www.rareskills.io/post/solidity-precompiles) para calcular el inverso modular en un contrato inteligente.

En la práctica, esta no es una forma ideal de calcular inversos multiplicativos porque elevar un número a una gran potencia es computacionalmente costoso. Las bibliotecas que calculan el inverso multiplicativo usan algoritmos más eficientes en segundo plano. Sin embargo, cuando dicha biblioteca no está disponible y se desea una solución rápida y simple, y calcular un exponente grande no es excesivamente costoso, se puede usar el Pequeño Teorema de Fermat.

## Calcular el inverso multiplicativo con Python

Usando Python 3.8 o posterior, podemos hacer `pow(a, -1, p)` para calcular el inverso multiplicativo de `a` en el cuerpo finito `p`. El primer argumento de `pow` es la base, el segundo es el exponente y el tercero es el módulo.

Ejemplo:

```python
p = 17
print(pow(5, -1, p))
# 7
assert (5 * 7) % p == 1
```

**Ejercicio:** Halla el inverso multiplicativo de 3 módulo 5. Solo hay 5 posibilidades, así que pruébalas todas y ve cuáles funcionan.

**Ejercicio:** ¿Cuál es el inverso multiplicativo de 50 en el cuerpo finito $p = 51$? No necesitas Python para calcular esto, consulta los principios descritos en “Reglas generales de los inversos multiplicativos”.

**Ejercicio:** Usa Python para calcular el inverso multiplicativo de 288 en el cuerpo finito de `p = 311`. Puedes comprobar tu trabajo validando que `(288 * respuesta) % 311 == 1`.

## La suma de inversos multiplicativos es consistente con la suma "regular" de fracciones

En un cuerpo finito de `p = 7`, los números 2 y 4 son inversos multiplicativos entre sí porque $(2 \times 4) \pmod 7 = 1$. Esto significa que en el cuerpo finito $p = 7$, $4$ es congruente con $1/2$ y $2$ es congruente con $1/4$.

Decimos que $4$ es congruente con $1/2$ en el cuerpo finito de $p = 7$ porque $2 \times \mathsf{mul\_inv}(2) = 1$. El inverso multiplicativo de $2$ es $4$ en este cuerpo finito, por lo que podemos tratar a $4$ como $1/2$.

Con números reales, si sumamos $1/2 + 1/2$, esperamos obtener $1$. Lo mismo sucede en un cuerpo finito. Como $4$ se "comporta como" $1/2$, esperamos $4 + 4 \pmod 7 = 1$, y de hecho lo hace.

Podemos codificar el número $5/6$ en un cuerpo finito al pensar en él como la operación $5 * (1/6)$, o $5 \times \mathsf{mul\_inv}(6)$.

Considere que $1/2 + 1/3 = 5/6$. Si nuestro campo finito es $p = 7$, entonces $1/2$ es el inverso multiplicativo de $2$, $1/3$ es el inverso multiplicativo de 3, y $5/6$ es $5$ multiplicado por el inverso multiplicativo de 6:

```python
p = 7
one_half = pow(2, -1, p)
one_third = pow(3, -1, p)
five_over_six = (pow(6, -1, p) * 5) % p

assert (one_half + one_third) % p == five_over_six
# True
```

La forma general de calcular una "fracción" en un campo finito es el numerador multiplicado por el inverso multiplicativo del denominador, módulo `p`:

```python
def calculate_field_element_from_fraction(num, den, p):
inv_den = pow(den, -1, p)
return (num * inv_den) % p
```

No es posible hacer esto cuando el denominador es un múltiplo de `p`. Por ejemplo, $1/7$ no se puede representar en el cuerpo finito $p = 7$ porque `pow(7, -1, 7)` no tiene solución. El módulo toma el resto después de la división, y el resto de $7/7$ es cero, o más generalmente, $7/d$ es cero cuando $d$ es un múltiplo de $7$. El inverso multiplicativo significa que podemos multiplicar un número y su inverso para obtener $1$, pero si uno de los números es cero, no hay nada que podamos multiplicar por cero para obtener 1.

**Ejercicio:** ejecuta `pow(7, -1, 7)` en Python. Deberías ver que se lanza una excepción, `ValueError: la base no es invertible para el módulo dado`. $7$ mod $7$ es igual a cero. No hay nada que podamos multiplicar por cero para obtener $1$.

### La "división" de un cuerpo finito no sufre pérdida de precisión

Si dividimos `1 / 3` en la mayoría de los lenguajes de programación, sufriremos pérdida de precisión porque $0.\overline{3}$ no es representable en binario.

Sin embargo, `1 / 3` en un cuerpo finito es simplemente el inverso multiplicativo de 3.

Esto significa que el circuito aritmético

```rust
x + y + z === 1;
x === y;
y === z;
```

tiene una solución exacta cuando se realiza en un cuerpo finito. Esto no sería posible de hacer de manera confiable si usáramos números de punto fijo o flotante como tipos de datos para nuestros circuitos aritméticos (considere que sumar 0.33333 + 0.33333 + 0.33333 dará como resultado 0.99999 en lugar de 1).

La siguiente implementación en Python ilustra el circuito:

```python
p = 11

# x, y, z tienen valor 1/3
x = pow(3, -1, 11)
y = pow(3, -1, 11)
z = pow(3, -1, 11)

assert x == y;
assert y == z;
assert (x + y + z) % p == 1
```

## Los elementos de un campo finito no tienen una noción tradicional de "par" o "impar"

Decimos que un número es "par" si se puede dividir por dos sin residuo.

**En un campo finito, cualquier elemento se puede dividir por 2 sin residuo.**

Es decir, "dividir por dos" es en realidad multiplicar por el inverso multiplicativo de 2, y eso siempre dará como resultado otro elemento de campo sin "residuo".

Sin embargo, si tenemos una representación binaria del elemento de campo, entonces podemos verificar si el elemento es par o impar si se convierte a un entero. Si el bit menos significativo es 1, entonces el número es impar (si se interpreta como un entero, no como un elemento de campo finito).

## Biblioteca de campos finitos en Python

Debido a que puede ser un poco tedioso seguir escribiendo `pow` y `% p` en Python, el lector puede desear usar la [biblioteca de Galois](https://pypi.org/project/galois/) en su lugar (los campos finitos a veces se denominan campos de Galois, que se pronuncian "Gal-wah"). Se puede instalar con `python3 -m pip install galois`.

A continuación, traducimos el código de adición de fracciones de la sección anterior $(1/2 + 1/3 = 1/6)$ para usar la biblioteca `galois` en su lugar. La biblioteca sobrescribe los operadores matemáticos para trabajar en un campo finito:

```python
import galois
GF7 = galois.GF(7) # GF7 es una clase que encapsula 7

one_half = GF7(1) / GF7(2)
one_third = GF7(1) / GF7(3)
five_over_six = GF7(5) / GF7(6)

assert one_half + one_third == five_over_six
```

La operación `1 / GF(a)` calcula el inverso multiplicativo de `a`.

La biblioteca `galois` puede calcular el inverso aditivo agregando un signo negativo al frente:

```python
negative_two = -GF(2)
assert negative_two + GF(2) == 0
```

## La multiplicación de fracciones también es consistente

Usemos un cuerpo finito `p = 11` para este ejemplo.

Con números regulares sabemos que $1/3 * 1/2 = 1/6$.

Hagamos esta misma operación en un cuerpo finito:

```python
import galois
GF = galois.GF(11)

one_third = GF(1) / GF(3)
one_half = GF(1) / GF(2)
one_sixth = GF(1) / GF(6)

assert one_third * one_half == one_sixth
```

**Ejercicio:** use la biblioteca galois para verificar que $3/4 * 1/2 = 3/8$ en el cuerpo finito $p = 17$.

## a × b ≠ 0 para todos los a, b distintos de cero

No es posible multiplicar dos elementos para obtener cero en un cuerpo finito a menos que uno de los elementos sea cero. Esto también es cierto para los números regulares.

Para entender esto, considere el cuerpo finito $p = 7$. Para multiplicar dos números y obtener $0$ como resultado, entonces uno de los términos $a$ debe ser un múltiplo de 7, de modo que $a \pmod 7$ sea cero. Sin embargo, ninguno de $\set{0, 1, 2, 3, 5, 6}$ es un múltiplo de 7, por lo que esto no puede suceder.

Haremos referencia a este hecho con frecuencia cuando diseñemos circuitos aritméticos. Por ejemplo, si sabemos

```python
x₁ * x₂ * ... * xₙ ≠ 0
```

Entonces podemos estar seguros de que todas las variables `x₁, x₂, xₙ` son distintas de cero, incluso si no conocemos sus valores.

A continuación, se muestra cómo podemos usar este truco para un circuito aritmético realista. Supongamos que tenemos señales `x₁, x₂, x₃`. Deseamos restringir al menos una de estas señales para que tenga el valor 8 sin especificar cuál lo tiene. Primero calculamos el inverso aditivo de 8 `a_inv(8)` para nuestro campo. Entonces hacemos:

`(x₁ + a_inv(8))(x₂ + a_inv(8))(x₃ + a_inv(8)) === 0`

Esto se podría escribir como

`(x₁ - 8)(x₂ - 8)(x₃ - 8) === 0`

con el entendimiento de que `-8` es el inverso aditivo de 8 para nuestro campo finito.

Siempre que una de las señales tenga el valor 8, entonces ese término será cero y toda la expresión se multiplicará a cero. Este truco se basa en dos hechos:

- Si todos los términos son distintos de cero, no hay forma de que la expresión evalúe a cero
- El inverso aditivo de 8 es único, y 8 es el inverso aditivo único para el inverso aditivo de 8. En otras palabras, no hay ningún valor excepto 8 que resulte en que 8 + inv(8) sea cero.

Por lo tanto, el circuito aritmético `(x₁ + a_inv(8))(x₂ + a_inv(8))(x₃ + a_inv(8)) === 0` indica que al menos uno de `x₁, x₂, xₙ` tiene el valor 8.

## Las operaciones de cuerpo finito son asociativas, conmutativas y distributivas

Al igual que con las matemáticas regulares, con la aritmética modular, las propiedades asociativa, conmutativa y distributiva se cumplen, es decir,

**asociativa**

$(a + b) + c = a + (b + c) \pmod p$

**suma conmutativa**

$(a + b) = (b + a) \pmod p$

**multiplicación conmutativa**

$ab = ba \pmod p$

**distributiva**

$a(b + c) = ab + ac \pmod p$

## Raíces cuadradas modulares

En "matemáticas regulares", los números cuadrados perfectos tienen raíces cuadradas enteras. Por ejemplo, 25 tiene una raíz cuadrada de 5, 49 tiene una raíz cuadrada de 7, y así sucesivamente.

### Los elementos en un cuerpo finito no necesitan ser cuadrados perfectos para tener una raíz cuadrada

Considere que $5 × 5 \pmod {11} = 3$. Esto significa que la raíz cuadrada de 3 es 5, módulo 11. Debido a la forma en que se envuelven los cuerpos finitos, los elementos de los cuerpos finitos no tienen que ser cuadrados perfectos para tener una raíz cuadrada.

Al igual que las raíces cuadradas regulares, que tienen dos soluciones: una positiva y una negativa, las raíces cuadradas modulares en un cuerpo finito también tienen dos soluciones. La excepción es el elemento 0, que solo tiene 0 como raíz cuadrada.

En el cuerpo finito módulo 11, los siguientes elementos tienen raíces cuadradas:

| Elemento | 1.ª raíz cuadrada | 2.ª raíz cuadrada |
| -------- | ----------------- | ----------------- |
| 0        | 0                 | n/a               |
| 1        | 1                 | 10                |
| 3        | 5                 | 6                 |
| 4        | 2                 | 9                 |
| 5        | 4                 | 7                 |
| 9        | 3                 | 8                 |

**Ejercicio**: Verifique que las raíces cuadradas indicadas en la tabla sean correctas en el cuerpo finito módulo 11.

Observe que la segunda raíz cuadrada es siempre la inversa aditiva de la primera raíz cuadrada, al igual que los números reales.

Por ejemplo:

- En matemáticas regulares, las raíces cuadradas de $9$ son $3$ y $-3$, donde ambas son inversas aditivas entre sí.
- En un cuerpo finito de $p = 11$, las raíces cuadradas de 9 son 3 y 8. 8 es el inverso aditivo de 3 porque $8 + 3 \pmod {11}$ es $0$, así como $3$ es el inverso aditivo de $-3$.

Los elementos 2, 6, 7, 8 y 10 no tienen raíces cuadradas modulares en el cuerpo finito $p = 11$. Esto se puede descubrir elevando al cuadrado cada elemento de 0 a 10 inclusive, y viendo que 2, 6, 7, 8 y 10 nunca se producen.

```python
numeros_con_raices = set()
p = 11
for i in range(0, p):
numeros_con_raices.add(i * i % p)

print("numeros_con_raices:", numeros_con_raices)
# numeros_con_raices: {0, 1, 3, 4, 5, 9}
```

Tenga en cuenta que 3 no es un cuadrado perfecto, pero sí tiene una raíz cuadrada en este cuerpo finito.

### Cálculo de la raíz cuadrada modular

La raíz cuadrada modular se puede calcular en Python con la [biblioteca libnum](https://github.com/hellman/libnum). A continuación, calculamos la raíz cuadrada de 5 módulo 11. El tercer argumento de las funciones `has_sqrtmod_prime_power` y `sqrtmod_prime_power` se puede establecer en 1 para nuestros propósitos.

```python
# install libnum with `python -m pip install libnum`

from libnum import has_sqrtmod_prime_power, sqrtmod_prime_power
has_sqrtmod_prime_power(5, 11, 1) # True
list(sqrtmod_prime_power(5, 11, 1)) # [4, 7]
# Las raíces cuadradas generalmente tienen dos soluciones. 4 y 7 son las raíces cuadradas de 5 (mod 11)
```

Cuando `p` se puede escribir como `4k + 3` donde `k` es un entero, entonces la raíz cuadrada modular se puede calcular de la siguiente manera:

```python
def mod_sqrt(x, p):
assert (p - 3) % 4 == 0, "prime not 4k + 3"
exponent = (p + 1) // 4
return pow(x, exponent, p) # x ^ e % p
```

La función anterior devuelve una de las raíces cuadradas de x módulo p. La otra raíz cuadrada se puede calcular calculando el inverso aditivo del valor devuelto. Si el número primo no tiene la forma `4k + 3`, entonces se debe utilizar el [algoritmo de Tonelli-Shanks](https://en.wikipedia.org/wiki/Tonelli–Shanks_algorithm) para calcular la raíz cuadrada modular (que implementa la biblioteca libnum anterior).

**La implicación de esto es que el circuito aritmético `x * x === y` puede tener dos soluciones.** Por ejemplo, en un cuerpo finito `p = 11`, podría parecer que el circuito aritmético `x * x === 4` solo admite el valor 2 porque -2 no es un elemento de cuerpo finito. Sin embargo, ¡esa suposición es muy errónea! La asignación `x = 9`, que es congruente con -2, también satisface el circuito.

**Ejercicio:** Utilice el fragmento de código anterior para calcular la raíz cuadrada modular de 5 en el cuerpo finito de `p = 23`. El código solo le dará una de las respuestas. ¿Cómo se puede calcular el otro?

## Sistemas lineales de ecuaciones en cuerpos finitos

Como se señaló en el capítulo anterior, un circuito aritmético es esencialmente un sistema de ecuaciones. Los sistemas lineales de ecuaciones en un cuerpo finito comparten muchas propiedades con un sistema lineal de ecuaciones sobre números regulares. Sin embargo, existen algunas diferencias que inicialmente pueden resultar inesperadas. Dado que los circuitos aritméticos se calculan sobre cuerpos finitos, debemos comprender dónde pueden estar estas desviaciones sorprendentes.

Un [sistema lineal de ecuaciones](https://math.libretexts.org/Bookshelves/Algebra/Algebra_and_Trigonometry_1e_(OpenStax)/11%3A_Systems_of_Equations_and_Inequalities/11.01%3A_Systems_of_Linear_Equations_-_Two_Variables) es una colección de ecuaciones de línea recta con un conjunto de incógnitas (variables) que intentamos resolver juntos. Para encontrar la solución única de un sistema de ecuaciones lineales, debemos hallar un valor numérico para cada variable que satisfaga todas las ecuaciones del sistema simultáneamente.

Los sistemas de ecuaciones lineales con números reales tienen:

1) **Sin solución:** lo que significa que las dos ecuaciones representan líneas que son paralelas en dos dimensiones o que nunca se cruzan en tres dimensiones o más

![Líneas paralelas](https://static.wixstatic.com/media/706568_3c9b8369fd064afe93c2a7ac7816bbf7~mv2.gif)

2) **Una solución** lo que significa que las líneas se intersecan en un punto

![Líneas que se intersecan](https://static.wixstatic.com/media/706568_140802e7d9534b448073e17ea95ff821~mv2.gif)

3) **Soluciones infinitas:** si las dos ecuaciones representan la misma línea, entonces hay infinitos puntos de intersección y el sistema de ecuaciones lineal tiene un número infinito de soluciones.

![Dos líneas que son iguales](https://static.wixstatic.com/media/706568_a16e84f93c44406486a5a1ee540f281c~mv2.gif)

Los sistemas de ecuaciones de campos finitos también tienen

1. ninguna solución o

2. una solución o

3. $p$ soluciones, es decir, tantas soluciones como el orden del campo

**Sin embargo, el hecho de que un sistema lineal de ecuaciones sobre números reales tenga cero, una o infinitas soluciones *no implica* que el mismo sistema lineal de ecuaciones sobre un campo finito también tendrá cero, una o `p` muchas soluciones.**

La razón por la que enfatizamos esto es porque usamos circuitos aritméticos y una asignación a las señales para codificar nuestra solución a un problema en NP. Sin embargo, debido a que los circuitos aritméticos están codificados con campos finitos, podemos terminar codificando el problema de una manera que no capture el comportamiento de las ecuaciones que estamos tratando de modelar.

Los siguientes tres ejemplos muestran cómo el comportamiento de un sistema de ecuaciones puede cambiar cuando se realiza sobre un campo finito.

### Ejemplo 1: Un sistema de ecuaciones con una solución sobre números regulares puede tener `p` muchas soluciones en un cuerpo finito

Por ejemplo, graficamos:

$$
x+2y=1\\6x+y=6
$$

![Dos rectas con una sola intersección](https://static.wixstatic.com/media/706568_26aa180e616f434ab16a76673e03b530~mv2.png/v1/fill/w_1214,h_712,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/706568_26aa180e616f434ab16a76673e03b530~mv2.png)

Tiene una solución: $(1, 0)$ para los números reales números, pero sobre el cuerpo finito $p = 11$, tiene 11 soluciones: $\set{(0, 6), (1, 0), (2, 5), (3, 10), (4, 4), (5, 9), (6, 3), (7, 8), (8, 2), (9, 7), (10, 1)}$.

**¡No suponga que un sistema de ecuaciones (circuito aritmético) que tiene una única solución en números reales tiene una única solución en un cuerpo finito!**

A continuación, graficamos las soluciones de los sistemas de ecuaciones sobre los cuerpos finitos para ilustrar que ambas ecuaciones "se intersecan en todas partes", es decir, tienen el mismo conjunto de puntos que satisfacen ambas ecuaciones:

![Gráfico aritmético modular de la misma ecuaciones](https://static.wixstatic.com/media/706568_079fc534789a431cbe3e52bf0081012c~mv2.png/v1/fill/w_1234,h_758,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/706568_079fc534789a431cbe3e52bf0081012c~mv2.png)

Esto puede parecer extremadamente contraintuitivo: veamos cómo sucede. Si resolvemos las ecuaciones originales:

$$
x+2y=1\\6x+y=6
$$

para $y$ obtenemos:

$$
y = 1/2 - 1/2*x\\y=6-6x
$$

$1/2$ es el inverso multiplicativo de $2$. En un cuerpo finito de $p = 11$, $6$ es el inverso multiplicativo de $2$, es decir, $2 * 6 \pmod {11} = 1$. Por lo tanto, $x + 2y = 1$ y $6x + y = 6$ son en realidad la misma ecuación en el cuerpo finito $p = 11$. Es decir, la ecuación $y = 1/2 - 1/2x$ cuando se codifica en un cuerpo finito es $y = \mathsf{mul\_inv}(2) - \mathsf{mul\_inv}(2)x$ que es $y = 6 - 6x$, que es la misma que la otra ecuación en el sistema.

### Ejemplo 2: Un sistema de ecuaciones con una solución sobre números regulares puede tener cero soluciones en un cuerpo finito

También contraintuitivamente, un sistema de ecuaciones con una única solución sobre números reales puede no tener solución en un cuerpo finito:

$$
x + 2y=1\\
7x+3y=2
$$

![Un gráfico diferente sobre números reales que muestra una única solución intersección](https://static.wixstatic.com/media/706568_c194df52697f4010943ff4e927f206b6~mv2.png/v1/fill/w_1480,h_604,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/706568_c194df52697f4010943ff4e927f206b6~mv2.png)

Claramente, este sistema de ecuaciones tiene un punto de intersección, pero sobre un cuerpo finito no tiene solución.

A continuación mostramos el gráfico de las dos ecuaciones en un cuerpo finito:

![Un gráfico en un cuerpo finito que no muestra intersección](https://static.wixstatic.com/media/706568_a737888a0bbc4f4e88d4209b47d0911f~mv2.png/v1/fill/w_1164,h_714,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/706568_a737888a0bbc4f4e88d4209b47d0911f~mv2.png)

**Ejercicio:** Escriba código para aplicar fuerza bruta a cada combinación de `(x, y)` sobre `x = 0..10, y = 0..10` para verificar que el sistema anterior no tiene solución sobre el cuerpo finito campo de `p = 11`.

¿Por qué este sistema de ecuaciones no tiene solución en el campo finito $p = 11$?

Si resolvemos

$$
x + 2y=1\\7x+3y=2
$$

para números reales, obtenemos las soluciones

$$
x = \frac{1}{11},\space y=\frac{5}{11}
$$

Las fracciones anteriores no tienen un elemento congruente en el campo finito `p = 11`.

Recuerde que dividir por un número es equivalente a multiplicar por su inverso multiplicativo. Además, recuerde que el orden del campo (en este caso 11) no tendrá un inverso multiplicativo, porque el orden del campo es congruente con 0.

El inverso multiplicativo de `a` es el valor `b` tal que `a * b = 1`. Sin embargo, si `a = 0` (o cualquier valor congruente con él) entonces no hay solución para `b`. Por lo tanto, las expresiones que escribimos para las soluciones en los números reales no se pueden traducir a elementos de nuestro cuerpo finito.

Por lo tanto, las soluciones (x, y) anteriores no son parte del cuerpo finito. Por lo tanto, en un cuerpo finito `p = 11`, `x + 2y = 1` y `7x + 3y = 2` son líneas paralelas.

Para ver esto desde otro ángulo, podríamos resolver las ecuaciones para y y obtener:

$$
y = 1/2 - x/2\\y=2/3-7x/3
$$

Vimos en la sección anterior que 6 es el inverso multiplicativo de 2, por lo que la primera ecuación tiene una "pendiente" de 6 en el cuerpo finito. En la segunda ecuación, calculamos la pendiente calculando 7 veces el inverso multiplicativo de 3: `(7 * pow(3, -1, 11)) % 11 = 6` . Ahora demostramos que sus pendientes son las mismas en un cuerpo finito.

La pendiente es el coeficiente de `x` en la forma `y = c + bx`. Para las dos ecuaciones anteriores, la primera pendiente es `-1/2` y la segunda pendiente es `-7/3`. Si convertimos ambas fracciones en un elemento del cuerpo finito de `p = 11`, obtenemos el mismo valor de 5:

```python
import galois
GF11 = galois.GF(11)

negative_1 = -GF11(1)
negative_7 = -GF11(7)

slope1 = GF11(negative_1) / GF11(2)
slope2 = GF11(negative_7) / GF11(3)

assert slope1 == slope2 # 5 == 5
```

La implicación de este hecho para el circuito aritmético:

```python
x + 2 * y === 1
7 * x + 3 * y === 2
```

es que el circuito aritmético no tiene una asignación satisfactoria en un cuerpo finito `p = 11`.

### Ejemplo 3: Un sistema de ecuaciones con cero soluciones sobre números regulares puede tener `p` soluciones en un cuerpo finito

Las dos fórmulas siguientes trazan líneas que son paralelas y, por lo tanto, no tienen solución sobre números reales:

$$
x + 2y = 3\\4x + 8y = 1
$$

![Dos líneas paralelas](https://static.wixstatic.com/media/706568_90da5d94046042f28be6d681d4cb8dce~mv2.png/v1/fill/w_1480,h_592,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/706568_90da5d94046042f28be6d681d4cb8dce~mv2.png)

Sin embargo, sobre el cuerpo finito campo `p = 11`, tiene 11 soluciones: $\set{(0, 7), (1, 1), (2, 6), (3, 0), (4, 5), (5, 10), (6, 4), (7, 9), (8, 3), (9, 8), (10, 2)}$. Las soluciones se representan gráficamente a continuación:

![Gráfico de líneas superpuestas en un campo finito](https://static.wixstatic.com/media/706568_f5d5e95e4b5340a496f3756d67626e15~mv2.png/v1/fill/w_1128,h_718,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/706568_f5d5e95e4b5340a496f3756d67626e15~mv2.png)

**Ejercicio:** Convierte las dos ecuaciones a su representación en el campo finito y observa que son iguales.

Supongamos que codificamos este sistema de ecuaciones como un circuito aritmético:

$$
x + 2y = 3\\4x + 8y = 1
$$

```python
x + 2 * y === 3
4 * x + 8 * y === 1
```

Para el cuerpo finito que estamos usando, nuestras restricciones son redundantes aunque "se vean diferentes". Es decir, dos restricciones que se ven diferentes en realidad restringen a $x$ e $y$ a tener los mismos valores.

## Polinomios en cuerpos finitos

En el capítulo sobre circuitos aritméticos, usamos el polinomio `x(x - 1) === 0` para hacer cumplir que `x` solo puede ser 0 o 1. Esto podría escribirse como una ecuación polinómica. Para hacerlo, expandimos completamente nuestra expresión hasta que se exprese como potencias separadas de x, cada una multiplicada por un coeficiente. En este caso: `x² - x === 0`.

La suposición de que el polinomio `x² - x === 0` solo tiene soluciones 0 o 1 en un cuerpo finito (así como con números reales) es válida en este caso. Sin embargo, en general, no se debe suponer que las raíces de un polinomio sobre números reales tengan las mismas raíces en un cuerpo finito. Mostraremos algunos contraejemplos más adelante.

Sin embargo, los polinomios en cuerpos finitos comparten muchas propiedades con los polinomios sobre números reales:

- Un polinomio de grado $d$ tiene como máximo $d$ raíces. Las raíces de un polinomio $p(x)$ son los valores $r$ tales que $p(r) = 0$.
- Si sumamos dos polinomios $p_1$ y $p_2$, el grado de $p_1 + p_2$ será como máximo $\max(\deg(p_1), \deg(p_2))$. Es posible que el grado de $p_1 + p_2$ sea menor que $\max(\deg(p_1), \deg(p_2))$. Por ejemplo, $p_1=x³ + 5x + 7$, y $p_2 = -x³$,
- La suma de polinomios en un cuerpo finito sigue las leyes asociativas, conmutativas y distributivas.
- Si multiplicamos dos polinomios $p_1$ y $p_2$, las raíces del producto serán la unión de las raíces de $p_1$ y $p_2$.

Dibujemos como ejemplo $y = x² \pmod {17}$.

![gráfica de x^2 mod 17](https://static.wixstatic.com/media/706568_3917656775e4477598b9afad9dea92d7~mv2.png/v1/fill/w_1428,h_856,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/706568_3917656775e4477598b9afad9dea92d7~mv2.png)

El dominio de $x$ son los elementos del campo finito, y la salida (rango) también debe ser un miembro del campo finito. Es decir, observe cómo todos los valores de $x$ e $y$ se encuentran en el intervalo de $[0,16]$. Un polinomio sobre un cuerpo finito solo puede tener valores $x$ e $y$ menores que $p$.

El equivalente de $y = -x²$ en el cuerpo finito $p = 17$ es $y = 16x² \pmod 17$ ya que 16 es el inverso aditivo de 1 en ese cuerpo finito. El polinomio $y = 16x² \pmod {17}$ se representa gráficamente a continuación:

![plot of y = 16x^2 mod 17](https://static.wixstatic.com/media/706568_983e1638b445495ebf2d99ab0d4f7027~mv2.png/v1/fill/w_1440,h_864,al_c,q_90,enc_auto/706568_983e1638b445495ebf2d99ab0d4f7027~mv2.png)

### Los polinomios que no tienen raíces en números reales pueden tener raíces en un cuerpo finito

Al igual que nuestros ejemplos anteriores con sistemas de ecuaciones lineales, no se debe asumir que un polinomio con ciertas raíces en números reales tiene las mismas raíces en un cuerpo finito.

A continuación, graficamos $y = x² + 1$ en el cuerpo finito $p = 17$. En números reales, $y = x² + 1$ no tiene raíces reales. Pero en un cuerpo finito, tiene dos raíces en $4$ y $13$, marcadas con puntos rojos a continuación:

![Gráfico de y = x^2 + 1 mod 17](https://static.wixstatic.com/media/706568_c1a9510ce859456d8a20fb705c35c604~mv2.png/v1/fill/w_1436,h_871,al_c,q_90,enc_auto/706568_c1a9510ce859456d8a20fb705c35c604~mv2.png)

Expliquemos ahora por qué $y = x² + 1$ no tiene raíces en números reales, pero sí en el cuerpo finito $p = 17$. En el cuerpo finito $p = 17$, 17 es congruente con cero. Por lo tanto, si introducimos un valor en $x$ de modo que $x² + 1$ se convierta en $17$, el polinomio dará como resultado cero, no $17$. Podemos resolver $x² + 1 = 17$ para $x² = 17 - 1 = 16$. En un cuerpo finito de $p = 17$, $x² = 16$ tiene soluciones $4$ y $13$. Por lo tanto, $y = x² + 1$ tiene raíces $4$ y $13$ en el cuerpo finito $p = 17$.

### Los polinomios con raíces reales pueden no tener raíces en un cuerpo finito

Consideremos el polinomio $y = x² − 5$. Podemos ver que tiene raíces en $\sqrt{5}$ y $-\sqrt{5}$. Sin embargo, si lo graficamos sobre un cuerpo finito módulo 17, podemos ver que nunca cruza el eje x:

![Gráfico de y = x^2 + 5 (mod 17)](https://static.wixstatic.com/media/706568_a87f571b1af9454db2b27d4a9fd3d8f6~mv2.png/v1/fill/w_1399,h_864,al_c,q_90,enc_auto/706568_a87f571b1af9454db2b27d4a9fd3d8f6~mv2.png)

No hay raíces porque $\sqrt{5}$ no se puede representar en un cuerpo finito módulo 17. Sin embargo, en el cuerpo finito $p = 11$, entonces habría dos raíces porque 5 tiene raíces cuadradas modulares en el cuerpo finito de $p = 11$.

### Limitaciones en circuitos aritméticos para demostraciones ZK

Si deseamos escribir un circuito aritmético para mostrar "Sé la raíz del polinomio $y = x² − 5$" usando un circuito aritmético sobre un cuerpo finito, entonces podemos encontrarnos con el problema de no poder codificar $\sqrt{5}$. Es decir, sobre números reales, $y = x² − 5$ tiene una raíz de $\sqrt{5}$, pero esto no se puede expresar en algunos cuerpos finitos. Dependiendo de $p$, el circuito aritmético `x² === 5` puede no tener ningún testigo satisfactorio.

### Polinomios en cuerpos finitos con Python

Al experimentar con circuitos aritméticos, a veces es útil escribir código Python para simularlos. Cuando nuestro circuito aritmético tiene una forma polinómica, podemos usar la biblioteca `galois` de antes para probar su comportamiento. Los siguientes ejemplos de código ilustran cómo usar esta biblioteca para trabajar con polinomios.

### Sumar polinomios en un cuerpo finito

En el código a continuación, definimos dos polinomios: `p1 = x² + 2x + 102` y `p2 = x² + x + 1` y luego los sumamos simbólicamente para producir `2x² + 3x`. Tenga en cuenta que los términos de coeficiente constante suman cero en el cuerpo finito `p = 103`.

```python
import galois
GF103 = [galois.GF](http://galois.gf/)(103) # p = 103

# definimos un polinomio x^2 + 2x + 102 mod 103
p1 = galois.Poly([1,2,102], GF103)

print(p1)
# x^2 + 2x + 102

# definimos un polinomio x^2 + x + 1 mod 103
p2 = galois.Poly([1,1,1], GF103)

print(p1 + p2)
# 2x^2 + 3x
```

La biblioteca `galois` es lo suficientemente inteligente como para interpretar números enteros negativos como inversos aditivos, como lo demuestra el código a continuación:

```python
import galois
GF103 = galois.GF(103) # p = 13

# Podemos ingresar "-1" como coeficiente, y esto se calculará
# automáticamente como `p - 1`
# -1 se convierte en 102 en un campo p = 103
p3 = galois.Poly([-1, 1], GF103)
p4 = galois.Poly([-1, 2], GF103)

print(p3)
# 102x + 1
print(p4)
# 102x + 2
```

### Multiplicación de polinomios en un campo finito

Podemos multiplicar polinomios entre sí:

```python
print(p3 * p4)
# x^2 + 100x + 2
```

Tenga en cuenta que `p3` y `p4` son polinomios de grado 1 y su producto es de grado 2 polinomio.

### Encontrar las raíces de un polinomio en un cuerpo finito

Encontrar las raíces de polinomios en cuerpos finitos es un tema aparte (consulte la página de Wikipedia para conocer los algoritmos sobre [factorización de polinomios en cuerpos finitos](https://en.wikipedia.org/wiki/Factorization_of_polynomials_over_finite_fields)). La biblioteca `galois` puede calcular las raíces con la función `roots`. Esto puede ser útil para verificar que las restricciones aritméticas en forma polinómica realmente creen las restricciones deseadas.

```python
print((p3 * p4).roots())
# [1, 2]
```

### Problemas con la biblioteca `galois`

La biblioteca toma silenciosamente el valor mínimo de los números de punto flotante que se pasan como coeficientes:

```python
# La biblioteca galois convertirá silenciosamente
# los números de punto flotante en un entero
galois.Poly([2.5], GF103)
# Poly(2, GF(103))
```

La biblioteca revertirá si se pasa un número mayor o igual a `p`:

```python
# El siguiente código falla porque no podemos
# tener coeficientes del orden del campo o mayor
galois.Poly([103], GF103)
# ValueError: las matrices GF(103) deben tener elementos en `0 <= x < 103`, no [103].
```

## Obtenga más información con RareSkills

Consulte nuestro [Libro ZK](https://www.rareskills.io/zk-book) para obtener más información sobre las pruebas de conocimiento cero

## Problemas de práctica

En los problemas a continuación, use un campo finito `p` de `21888242871839275222246405745257275088548364400416034343698204186575808495617`. Tenga en cuenta que la biblioteca `galois` tarda un tiempo en inicializar un objeto `GF`, `galois.GF(p)`, de este tamaño.

1. Un desarrollador crea un circuito aritmético `x * y * z === 0` y `x + y + z === 0` con la intención de restringir todas las señales a cero. Encuentra un contraejemplo de esto donde se satisfacen las restricciones, pero no todos los valores de `x`, `y` y `z` son 0.
2. Un desarrollador crea un circuito con el polinomio `x² + 2x + 3 === 11` y demuestra que 2 es una solución. ¿Cuál es la otra solución? Pista: escribe el circuito como `x² + 2x - 8 === 0` y luego factoriza el polinomio a mano para encontrar las raíces. Finalmente, calcula el elemento congruente de las raíces en el cuerpo finito para encontrar la otra solución.

*Traducido al Español por ARCADIO Garcia, Septiembre 2024*
