# Circuitos aritméticos para ZK

En el contexto de las pruebas de conocimiento-cero, un circuito aritmético es un sistema de ecuaciones que modela un problema en NP.

Un punto clave de nuestro artículo sobre [P vs NP](https://www.rareskills.io/post/p-vs-np) es que cualquier solución a un problema en P o NP puede verificarse modelando el problema como un circuito booleano.

A continuación, convertimos nuestra solución para el problema original en un conjunto de valores para las variables booleanas (llamado el testigo) que da como resultado que el circuito booleano devuelva verdadero.

Este artículo se basa en el anterior, así que léalo primero.

## Circuitos aritméticos como alternativa a los circuitos booleanos

Una desventaja de utilizar un circuito booleano para representar la solución de un problema es que puede resultar prolijo a la hora de representar operaciones aritméticas, como sumas o multiplicaciones.

Por ejemplo, si queremos expresar $a + b = c$ donde $a = 8, b = 4, c = 12$ debemos transformar $a$, $b$ y $c$ en números binarios. Cada bit del número binario corresponderá a una variable booleana distinta. En este ejemplo, supongamos que necesitamos 4 bits para codificar $a$, $b$, y $c$, donde $a₀$ representa el bit menos significativo (LSB), y $a₃$ representa el bit más significativo (MSB) del número $a$, como se muestra a continuación:

- `a₃, a₂, a₁, a₀`
  - $a = 1000$
- b₃, b₂, b₁, b₀`
  - $b = 0100$
- `c₃, c₂, c₁, c₀`
  - $c = 1100$

(No hace falta que sepas convertir un número a binario por ahora, explicaremos el método más adelante en el artículo).

Una vez que tenemos $a$, $b$ y $c$ escritos en binario, podemos escribir un circuito booleano cuyas entradas sean todos los dígitos binarios $(a₀, a₁, ..., c₂, c₃)$. Nuestro objetivo es escribir un circuito booleano de este tipo, de forma que el circuito dé como resultado verdadero si y sólo si $a + b = c$.

Esto resulta ser más complicado de lo esperado, como lo demuestra el circuito grande a continuación, que modela $a + b = c$ en binario. Por brevedad, no mostramos la derivación. Sólo mostramos la fórmula para ilustrar lo verboso que puede ser un circuito de este tipo:

```javascript
((a₄ ∧ b₄ ∧ c₄) ∨ (¬a₄ ∧ ¬b₄ ∧ c₄) ∨ (¬a₄ ∧ b₄ ∧ ¬c₄) ∨ (a₄ ∧ ¬b₄ ∧ ¬c₄) ∧

((a₃ ∧ b₃ ∧ ((a₂ ∧ b₂) ∨ (b₂ ∧ (a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀)))) ∨
 (¬a₃ ∧ ¬b₃ ∧ ((a₂ ∧ b₂) ∨ (b₂ ∧ (a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀)))) ∨
 (¬a₃ ∧ b₃ ∧ ¬((a₂ ∧ b₂) ∨ (b₂ ∧ (a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀)))) ∨
 (a₃ ∧ ¬b₃ ∧ ¬((a₂ ∧ b₂) ∨ (b₂ ∧ (a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀))))) ∧

((a₂ ∧ b₂ ∧ ((a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀)) ∨
 (¬a₂ ∧ ¬b₂ ∧ ((a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀)) ∨
 (¬a₂ ∧ b₂ ∧ ¬((a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀)))) ∨
 (a₂ ∧ ¬b₂ ∧ ¬((a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀))))) ∧

((a₁ ∧ b₁ ∧ c₀) ∨ (¬a₁ ∧ ¬b₁ ∧ c₀) ∨ (¬a₁ ∧ b₁ ∧ ¬c₀) ∨ (a₁ ∧ ¬b₁ ∧ ¬c₀) ∧

((a₀ ∧ b₀ ∧ c₀) ∨ (¬a₀ ∧ ¬b₀ ∧ c₀) ∨ (¬a₀ ∧ b₀ ∧ ¬c₀) ∨ (a₀ ∧ ¬b₀ ∧ ¬c₀) ∧

¬ ((a₄ ∧ b₄) ∨
     (b₄ ∧ (a₃ ∧ b₃) ∨ (b₃ ∧ (a₂ ∧ b₂) ∨ (b₂ ∧ (a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀)) ∨
     (a₃ ∧ (a₂ ∧ b₂) ∨ (b₂ ∧ (a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀))))
```

La cuestión es que, si nos limitamos a entradas booleanas y operaciones booleanas básicas (AND, OR, NOT), la construcción de circuitos puede volverse rápidamente complicada y tediosa para problemas básicos, especialmente cuando implican aritmética.

En cambio, sería más sencillo representar directamente los números dentro de un circuito. En lugar de modelar la suma con una fórmula booleana, utilizamos directamente la suma y la multiplicación en esos números.

Este artículo demuestra que también es posible modelar cualquier problema en P o NP con un *circuito aritmético*.

## Circuitos aritméticos

Un circuito aritmético es un sistema de ecuaciones que sólo utiliza la suma, la multiplicación y la igualdad. Al igual que un circuito booleano, comprueba que un conjunto propuesto de entradas es válido, pero no calcula una solución.

El siguiente es nuestro primer ejemplo de un circuito aritmético:

```javascript
6 = x₁ + x₂
9 = x₁x₂
```

Decimos que un circuito booleano está *satisfecho* si tenemos una asignación a las variables de entrada que resulta en una salida de verdadero. Del mismo modo, un circuito aritmético es satisfecho si hay una asignación a las variables de tal manera que todas las ecuaciones son verdaderas.

Por ejemplo, el circuito anterior se cumple si x₁ = 3, x₂ = 3 porque ambas ecuaciones del circuito son verdaderas. Por el contrario, el circuito no se cumple con `x₁ = 1, x₂ = 6` porque la ecuación `9 = x₁x₂` no es cierta.»

Así pues, podemos pensar indistintamente en un circuito aritmético y en el conjunto de ecuaciones del circuito. Un conjunto de entradas «satisface el circuito» si y sólo si esas entradas hacen que *todas* las ecuaciones sean verdaderas.

## Notación y Terminología

Las variables de un circuito aritmético se denominan **señales** porque [Circom](https://docs.circom.io), el lenguaje de programación que utilizaremos para escribir las Pruebas ZK, se refiere a ellas como tales.

Para expresar igualdad, utilizaremos el operador `===`. Usamos esta notación porque Circom la usa para indicar que dos señales tienen el mismo valor, así que podemos acostumbrarnos a verla.

Hacemos hincapié en que el `===` está afirmando que el lado izquierdo y el lado derecho son iguales. Por ejemplo, en el siguiente circuito

`c === a + b`

**no estamos sumando `a` a `b` y asignando el resultado a `c`**. **En su lugar, suponemos que los valores «a», «b» y «c» se proporcionan como entradas, y estamos afirmando una relación entre ellos. Esto tiene el efecto de «restringir» la suma de «a» y «b» para ser «c».

Piensa que `c === a + b` es completamente equivalente a `assertEq(c, a + b)`. Del mismo modo, la expresión `a + b === c * d` es completamente equivalente a `assertEq(a + b, c * d)`. En esencia, verificar estas ecuaciones en un circuito implica comprobar si se cumplen ciertas condiciones (restricciones). El agente que prueba la validez de su testigo puede asignar cualquier valor a las señales. Sin embargo, su prueba (testigo) sólo se considerará válida si se cumplen todas las restricciones.

Por ejemplo, si un agente desea demostrar:

```javascript
a === b + c + 3
a * u === x * y
```

debe suministrar `(a, b, c, u, x, y)` desde *fuera del circuito* y asignarlas a las señales del circuito.

Recuerda, el código anterior es equivalente a

``javascript
assertEq(a, b + c + 3)
assertEq(a * u, x * y)

```
Un modelo mental útil para el circuito aritmético es que todas las señales se tratan como entradas sin salidas.

Para entenderlo mejor, en el siguiente vídeo se ofrece una visualización. Todas las señales son entradas, y `===` se utiliza para comprobar en lugar de asignar.

<video autoplay loop muted controls>
<source src=«https://video.wixstatic.com/video/706568_f4fb9d3d127c4735a718deffbd9fed70/1080p/mp4/file.mp4» type=«video/mp4»>
</video>

El circuito del vídeo se podría haber escrito como:

```javascript
z + y === x
x + y === u
```

sin cambiar el significado.

El circuito aritmético `x === x + 1` no significa incrementar `x`. Es un circuito aritmético sin solución porque x no puede ser igual a `x + 1`. Por lo tanto, es imposible satisfacer la restricción.

### Interpretación de Circuitos Aritméticos

Considera el siguiente circuito:

```javascript
x₁(x₁ - 1) === 0
x₁x₂ === x₁
```

La primera restricción `x₁(x₁ - 1) === 0` restringe los posibles valores de x₁ a sólo 0 ó 1. Cualquier otro valor de `x₁` no satisfaría esta restricción.

En la segunda restricción `x₁x₂ === x₁` tenemos dos escenarios posibles:

- Si `x₁ = 1`, entonces `x₂` también debe ser 1, o la segunda restricción no se puede satisfacer. Si `x₁ = 1` y `x₂ ≠ 1`, entonces la segunda ecuación se convierte en `1 * x₂ === 1` que sólo puede ser satisfecha por `x₂ = 1`, lo que crea un conflicto.
- Si `x₁ = 0`, entonces `x₂` puede tener cualquier valor porque `0x₂ === 0` es trivial de satisfacer.

Las siguientes asignaciones a `(x₁, x₂)` son todas testigos válidos:

- $(x₁, x₂) = (1, 1)$
- $(x₁, x₂) = (0, 2)$
- $(x₁, x₂) = (0, 1337)$
- $(x₁, x₂) = (0, 404)$

Recuerda que un sistema de ecuaciones puede tener muchas soluciones. Del mismo modo, un circuito aritmético también puede tener muchas soluciones. Sin embargo, por lo general, sólo estamos interesados en verificar una solución dada. No necesitamos encontrar todas las soluciones de un circuito aritmético.

### Circuito Booleano vs Circuito Aritmético

La siguiente tabla muestra en qué se diferencian los circuitos booleanos y los circuitos aritméticos, pero ten en cuenta que sirven para el mismo propósito de validar un testigo:

| Circuito Booleano                                                                                                                             | Circuito Aritmético                                                                       |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| Las variables son 0, 1                                                                                                                        | Las señales contienen números                                                             |
| Las únicas operaciones son AND, OR, NOT                                                                                                       | Las únicas operaciones son suma y multiplicación                                          |
| Se cumple cuando la salida es verdadera Se cumple cuando el lado izquierdo es igual al lado derecho para todas las ecuaciones (no hay salida) |                                                                                           |
| Testigo es una asignación a las variables booleanas que satisface el circuito booleano                                                        | Testigo es una asignación a las señales que satisface todas las restricciones de igualdad |

Aparte de la conveniencia de utilizar menos variables en algunas circunstancias, los circuitos aritméticos y los circuitos booleanos son herramientas que realizan el mismo trabajo: demostrar que se tiene un testigo para un problema en NP.

### Volviendo al ejemplo inicial a + b = c

Volvamos a nuestro ejemplo anterior: escribir un circuito *Booleano* para representar la ecuación `a + b = c`, donde se nos da `c = 12`. Para un circuito booleano, necesitamos codificar «a», «b» y «c» en binario, lo que requiere 4 bits cada uno (en este ejemplo). En total, tenemos 12 entradas en el circuito. En comparación, el circuito aritmético sólo requiere 3 entradas: `a`, `b` y `c`. La reducción en el número de entradas y el tamaño total del circuito es la razón por la que preferimos utilizar circuitos aritméticos para aplicaciones ZK.

### Similitudes entre sistemas de ecuaciones y circuitos aritméticos

Los circuitos booleanos siempre tienen una expresión que devuelve verdadero o falso si se satisface el testigo.

Por ejemplo, si tenemos un conjunto de señales $x$, $y$, y $z$, y deseamos restringir la suma de $x$ y $y$ para ser $5$, entonces necesitamos una ecuación separada para eso. Cualquier forma en que deseamos restringir z tendría su propia ecuación separada.

Para demostrar que los circuitos aritméticos y los circuitos booleanos son equivalentes, más adelante demostraremos que cualquier circuito booleano puede transformarse en un circuito aritmético. Esto demuestra que se pueden utilizar indistintamente con el fin de demostrar que un agente tiene un testigo para un problema en P o NP.

### Todos los problemas P son un subconjunto de los problemas NP

Como se discutió en el anterior [capítulo sobre P vs NP](https://www.rareskills.io/post/p-vs-np), **todos los problemas P son un subconjunto de los problemas NP** en términos de los requisitos de cálculo para validar un testigo, por lo que en adelante sólo nos referiremos a problemas NP, entendiendo que esto incluye a P.

Nuestra conclusión es que si cualquier solución a un problema en NP puede modelarse con un circuito booleano, entonces cualquier solución a un problema en NP (o P) puede modelarse con un circuito aritmético.

Pero antes de demostrar su equivalencia, vamos a proporcionar ejemplos de modelado de las soluciones a los problemas en NP para que tengamos una intuición de cómo se utilizan los circuitos aritméticos.

## Ejemplos de circuitos aritméticos

En nuestro primer ejemplo, rehacemos nuestro problema de 3 colores para Australia. En el segundo, demostramos cómo usar un circuito aritmético para probar que una lista está ordenada.

### Ejemplo 1: Modelado de 3 colores con un circuito aritmético

Cuando usamos un circuito Booleano para modelar un 3-color, cada territorio tenía 3 variables Booleanas - una para cada color - indicando si el país había sido asignado ese color. Luego añadimos restricciones para forzar que cada territorio tenga exactamente un color (restricciones de color) y restricciones para forzar que los territorios adyacentes no tengan el mismo color (restricciones de límite).

Es más fácil modelar este problema utilizando circuitos aritméticos porque podemos asignar una sola señal a cada territorio con los posibles valores $\set{1, 2, 3}$ para modelar sus colores, en lugar de tres variables booleanas. Podemos asignar arbitrariamente colores a los números, como `azul = 1`, `rojo = 2`, y `verde = 3`.

Para cada territorio, escribimos la restricción de color único como:

``javascript
0 === (1 - x) * (2 - x) * (3 - x)

```
para que cada territorio tenga exactamente un color. La restricción anterior sólo puede cumplirse si «x» es 1, 2 ó 3.

**3-Colorear Australia**

![3 coloring of Australia](https://static.wixstatic.com/media/706568_b649d43396ef43cd954f4beb61dc1bc6~mv2.jpg/v1/fill/w_696,h_628,al_c,lg_1,q_85,enc_auto/706568_b649d43396ef43cd954f4beb61dc1bc6~mv2.jpg)

Recordemos que Australia tiene seis territorios:

- `WA` = Australia Occidental
- `SA` = Australia Meridional
- NT = Territorio del Norte
- Q = Queensland
- NSW` = Nueva Gales del Sur
- V = Victoria

Decir `WA = 1` equivale a decir «Colorea de azul Australia Occidental». Del mismo modo, `WA = 2` significa que se asignó «rojo» a Australia Occidental, y `WA = 3` significa que se asignó «verde».

Nuestra restricción de color (restringir cada territorio a ser azul, rojo o verde) para cada territorio se convierte en:

``javascript
1) 0 === (1 - WA) * (2 - WA) * (3 - WA)
2) 0 === (1 - SA) * (2 - SA) * (3 - SA)
3) 0 === (1 - NT) * (2 - NT) * (3 - NT)
4) 0 === (1 - Q) * (2 - Q) * (3 - Q)
5) 0 === (1 - NSW) * (2 - NSW) * (3 - NSW)
6) 0 === (1 - V) * (2 - V) * (3 - V)
```

Ahora queremos que los territorios vecinos no tengan el mismo color. Una forma de conseguirlo es multiplicar las señales de los territorios vecinos y asegurarnos de que el producto es «aceptable». Considere la siguiente tabla para los territorios vecinos `x` y `y`:

| x   | y   | product                            |
| --- | --- | ---------------------------------- |
| 1   | 1   | <span style=«color:red»>1</span>   |
| 1   | 2   | <span style=«color:green»>2</span> |
| 1   | 3   | <span style=«color:green»>3</span> |
| 2   | 1   | <span style=«color:green»>2</span> |
| 2   | 2   | <span style=«color:red»>4</span>   |
| 2   | 3   | <span style=«color:green»>6</span> |
| 3   | 1   | <span style=«color:green»>3</span> |
| 3   | 2   | <span style=«color:green»>6</span> |
| 3   | 3   | <span style=«color:red»>9</span>   |

If two signals (neighboring territories) have the same number (color), then their product will be one of $\set{1,4,9}$, the <span style=«color:red»>red</span> numbers above. If `x` and `y` are constrained to be 1, 2, or 3, and `x` and `y` are not equal to each other, then the product `xy` will be one of $\set{2, 3, 6}$. Therefore, if `xy = 2` or `xy = 3` or `xy = 6`, we accept the assignment because it means the two neighbors have different colors.

For each neighboring territory `x` and `y`, we can use the following constraint to enforce that they are not equal to each other:

```javascript
0 === (2 - xy) * (3 - xy) * (6 - xy)
```

La ecuación anterior se cumple si y sólo si el producto `xy` es igual a 2, 3 ó 6.

Las restricciones de contorno se crean iterando a través de los bordes y aplicando las restricciones de contorno entre cada par de territorios vecinos como ilustra el siguiente vídeo:

<video autoplay loop muted controls>
<source src=«https://video.wixstatic.com/video/706568_71747f743e8e49c0955fa5de2f827ab4/1080p/mp4/file.mp4» type=«video/mp4»>
</video>

Ahora mostramos las restricciones de límites:

```javascript
Australia Occidental y Australia Meridional:
7) 0 === (2 - WA * SA) * (3 - WA * SA) * (6 - WA * SA)

Australia Occidental y Territorio del Norte
8) 0 === (2 - WA * NT) * (3 - WA * NT) * (6 - WA * NT)

Territorio del Norte y Australia Meridional
9) 0 === (2 - NT * SA) * (3 - NT * SA) * (6 - NT * SA)

Territorio del Norte y Queensland
10) 0 === (2 - NT * Q) * (3 - NT * Q) * (6 - NT * Q)

Australia Meridional y Queensland
11) 0 === (2 - SA * Q) * (3 - SA * Q) * (6 - SA * Q)

Australia Meridional y Nueva Gales del Sur
12) 0 === (2 - SA * NSW) * (3 - SA * NSW) * (6 - SA * NSW)

Australia Meridional y Victoria
13) 0 === (2 - SA * V) * (3 - SA * V) * (6 - SA * V)

Queensland y Nueva Gales del Sur
14) 0 === (2 - Q * NSW) * (3 - Q * NSW) * (6 - Q * NSW)

Nueva Gales del Sur y Victoria
15) 0 === (2 - NSW * V) * (3 - NSW * V) * (6 - NSW * V)
```

Combinando los dos, vemos el circuito aritmético completo para probar que tenemos una 3-coloración válida para Australia:

```javascript
// restricciones de color
0 === (1 - WA) * (2 - WA) * (3 - WA)
0 === (1 - SA) * (2 - SA) * (3 - SA)
0 === (1 - NT) * (2 - NT) * (3 - NT)
0 === (1 - Q) * (2 - Q) * (3 - Q)
0 === (1 - NSW) * (2 - NSW) * (3 - NSW)
0 === (1 - V) * (2 - V) * (3 - V)

// restricciones fronterizas
0 === (2 - WA * SA) * (3 - WA * SA) * (6 - WA * SA)
0 === (2 - WA * NT) * (3 - WA * NT) * (6 - WA * NT)
0 === (2 - NT * SA) * (3 - NT * SA) * (6 - NT * SA)
0 === (2 - NT * Q) * (3 - NT * Q) * (6 - NT * Q)
0 === (2 - SA * Q) * (3 - SA * Q) * (6 - SA * Q)
0 === (2 - SA * NSW) * (3 - SA * NSW) * (6 - SA * NSW)
0 === (2 - SA * V) * (3 - SA * V) * (6 - SA * V)
0 === (2 - Q * NSW) * (3 - Q * NSW) * (6 - Q * NSW)
0 === (2 - NSW * V) * (3 - NSW * V) * (6 - NSW * V)
```

Tenemos 15 restricciones como en el circuito booleano, **pero 1/3 de variables (señales)**. En lugar de 3 variables booleanas para cada territorio, tenemos una señal para cada territorio. Para circuitos más grandes, esta reducción en complejidad y espacio puede ser sustancial.

### Ejemplo 2: Demostrar que una lista está ordenada

Dada una lista de números `[a₁, a₂, ..., aₙ]`, decimos que la lista está «ordenada» si `aₙ ≥ aₙ₋₁ ≥ ... a₃ ≥ a₂ ≥ a₁`. En otras palabras, yendo del final al principio, los números no son crecientes.

Nuestro objetivo es escribir un circuito aritmético que verifique que la lista está ordenada.

Para ello, necesitamos un circuito aritmético que exprese `a ≥ b` para dos señales. Esto resulta ser más complicado de lo que parece a primera vista, porque los circuitos aritméticos sólo permiten igualdades, sumas y multiplicaciones, no comparaciones.

Pero supongamos que tenemos un circuito «mayor o igual que» -llamémoslo `GTE(a,b)`. Entonces construiríamos los circuitos para comparar cada par de elementos consecutivos de la lista: `GTE(aₙ, aₙ₋₁), ..., GTE(a₃, a₂), GTE(a₂, a₁)`, y si se cumplen todos, entonces se ordena la lista.

Para comparar dos números decimales sin el operador $≥$, primero necesitamos un circuito aritmético que valide una representación binaria propuesta para el número, así que primero damos un pequeño rodeo sobre los números binarios.

### Prerrequisito: Codificación binaria

Escribimos los números binarios con el subíndice 2. Por ejemplo, 11₂ es 3 y 101₂ es 5. Cada uno de los 1s y 0s se denomina bit. Decimos que el bit situado más a la izquierda es el bit más significativo (MSB) y el situado más a la derecha es el bit menos significativo (LSB).

Como veremos en breve, durante la conversión a decimal, el bit más significativo se multiplica por el coeficiente mayor y el bit menos significativo se multiplica por el coeficiente menor. Así, si escribimos un número binario de cuatro bits como `b₃b₂b₁b₀`, `b₃` es el MSB y `b₀` es el LSB.

El siguiente vídeo ilustra la conversión de 1101₂ a 13:

<video autoplay loop muted controls>
<source src=«https://video.wixstatic.com/video/706568_e4cf36f8de2d401b94370b279f411b4b/720p/mp4/file.mp4» type=«video/mp4»>
</video>

Como se muestra en el video, un número binario de cuatro bits se puede convertir a un número decimal `v` con la siguiente fórmula:

`v = 8b₃ + 4b₂ + 2b₁ + b₀`

Esto también podría escribirse como:

`v = 2³b₃ + 2²b₂ + 2¹b₁ + 2⁰b₀`.

Por ejemplo, 1001₂ = 9, 1010₂ = 10, y así sucesivamente. Para un número binario general de `n` bits, la conversión es:

`v = 2ⁿ-¹b₃ + ... + 2¹b₁ + 2⁰b₀`

Omitimos la discusión sobre cómo convertir un número decimal a binario. Por ahora, si el lector desea convertir a binario, puede utilizar la función incorporada `bin` de Python:

```javascript
>>> bin(3)
'0b11'
>>> bin(9)
'0b1001'
>>> bin(10)
'0b1010'
>>> bin(1337)
'0b10100111001'
>>> bin(404)
'0b110010100'
```

Podemos crear un circuito aritmético que afirme «`v` es un número decimal con una representación binaria de cuatro bits `b₃`, `b₂`, `b₁`, `b₀`» utilizando el siguiente circuito:

```javascript
8b₃ + 4b₂ + 2b₁ + b₀ === v

// forzar a que los «bits» sean cero o uno.
b₀(b₀ - 1) === 0
b₁(b₁ - 1) === 0
b₂(b₂ - 1) === 0
b₃(b₃ - 1) === 0
```

Las señales `b₃, b₂, b₁, b₀` están limitadas a ser la representación binaria de `v`. Si `b₃, b₂, b₁, b₀` no son binarios, o no son la representación binaria de `v`, entonces el circuito no se puede satisfacer.

Observe que **no hay ninguna asignación satisfactoria a las señales `(v, b₃, b₂, b₁, b₀)` donde `v > 15`.** Es decir, si ponemos `b₃, b₂, b₁, b₀` a todos 1, lo más alto que permiten las restricciones, entonces la suma será 15. No es posible sumar nada más alto. En ZK, esto se llama a veces una *comprobación de rango* en `v`. El circuito anterior no sólo demuestra la representación binaria de `v`, sino que también obliga a que `v < 16`.

Podemos generalizar esto al siguiente circuito que obliga a $v < 2^n$ y también nos da la representación binaria de `v`:

```javascript
2ⁿ-¹bₙ₋₁ +...+ 2²b₂ + 2¹b₁ + b₀ === v
b₀(b₀ - 1) === 0
b₁(b₁ - 1) === 0
//...
bₙ₋₁(bₙ₋₁ - 1) === 0
```

**Decir que un número `v` está codificado con un máximo de `n` bits equivale a decir $v < 2^n$.**

Para hacerse una idea de cómo cambia $2^n$ en función de $n$, considere la siguiente tabla:

| n bits | valor máximo (binario) | valor máximo (decimal) | 2ⁿ (decimal) | 2ⁿ (binario) |
| ------ | ---------------------- | ---------------------- | ------------ | ------------ |
| 2      | 11₂                    | 3                      | 4            | 100          |
| 3      | 111₂                   | 7                      | 8            | 1000         |
| 4      | 1111₂                  | 15                     | 16           | 10000        |
| 5      | 11111₂                 | 31                     | 32           | 100000       |

Observe que el número $2^n$ en binario requiere 1 bit más para almacenarse que el valor $2^n - 1$. Al restringir el número de bits con los que se codifica un número a $n$ bits, se fuerza a que ese número sea menor que $2^n$.

Es útil recordar la relación entre potencias de $2$ y el número de bits necesarios para almacenarlas.

- $2^n$ requiere $n + 1$ bits para almacenarse. Por ejemplo, $2^0=1_2$, $2^1 = 10_2$, $2^2=100_2$, $2^3=1000_2$ y así sucesivamente.
- $2^{n-1}$ es la mitad de $2^n$ y requiere $n$ bits para almacenar
- $2^n - 1$ requiere $n$ bits para almacenar. Es el valor máximo que podemos almacenar con $n$ bits, cuando todos los bits están a $1$.

Si tomamos un número $n$ y calculamos $2^n$, obtenemos un número de $n + 1$ bits con el bit más significativo a 1, y el resto a cero. $n = 3$ en los ejemplos siguientes:

$$
2^n=\underbrace{1000}_{n+1\space bits}
$$

$2^{n-1}$ es lo mismo que $2^n / 2$. Puesto que se escribe como 2 a alguna potencia, sigue teniendo la misma «forma» de un número binario con un MSB de 1 y el resto cero, pero requerirá $n$ bits para codificarlo en lugar de $n + 1$ bits.

$$
2^{n-1}=\underbrace{100}_{n\space bits}
$$

$2^n -1$ es un número de $n$ bits con todos los bits a uno.

$$
2^n-1=\underbrace{111}_{n\space bits}
$$

### Calcular ≥ en binario

Si trabajamos con números binarios de un tamaño fijo, $n$ bits, el número $2^{n-1}$ es especial porque podemos afirmar fácilmente que un número binario de $n$ bits es mayor o igual que $2^{n-1}$ - o menor que él. Llamamos $2^{n-1}}$ al «punto medio». El siguiente vídeo ilustra cómo comparar el tamaño de un número de $n$ bits con $2^{n-1}$:

<video autoplay loop muted controls>
<source src=«https://video.wixstatic.com/video/706568_adae25cac0e6414ab0643a5792a2ed52/1080p/mp4/file.mp4» type=«video/mp4»>
</video>

Comprobando el bit más significativo de un número de $n$ bits, podemos saber si ese número es mayor o igual que $2^{n-1}$ o menor que $2^{n-1}$.

Si calculamos $2^{n-1} + \Delta$ y miramos el bit más significativo de esa suma, podemos saber rápidamente si $\Delta$ es positivo o negativo. Si $\Delta$ es negativo, entonces $2^{n-1} + \Delta$ debe ser menor que $2^{n-1}$.

<video autoplay loop muted controls>
<source src=«https://video.wixstatic.com/video/706568_6b61fecfedb64a888f6538bc91707f40/1080p/mp4/file.mp4» type=«video/mp4»>
</video>

### Detectar si $u \ge v$

Si sustituimos $\Delta$ por $u - v$ entonces el bit más significativo de $2^{n-1} + (u - v)$ nos dice si $u ≥ v$ o $u < v$.

<video autoplay loop muted controls>
<source src=«https://video.wixstatic.com/video/706568_ea57bc6fb8c5493686c3dc4cf9123c72/1080p/mp4/file.mp4» type=«video/mp4»>
</video>

#### Prevención del desbordamiento en $2^{n-1} + (u - v)$

Si restringimos $u$ y $v$ para que se representen con un máximo de $n - 1$ bits, mientras que $2^{n-1}$ se representa con $n$ bits, entonces no pueden producirse subdesbordamiento ni desbordamiento. Cuando ambos $u$ y $v$ se representan con un máximo de $n - 1$ bits, el valor absoluto máximo de $|u - v|$ es un número de $n - 1$ bits.

Vemos que $2^{n-1} + (u - v)$ no puede desbordarse en este caso, porque $2^{n-1}$ es al menos 1 bit mayor que $|u - v|$.

Consideremos ahora el caso de desbordamiento. Sin pérdida de generalidad, para $n = 4$, es decir, números de cuatro bits, el punto medio es $2^{n-1} = 2^{4-1} = 8$ o $1000_2$. El valor máximo que puede tener $|u - v|$ en este caso, como número de 3 bits, es $111_2$. Sumando $1000_2 + 111_2$ se obtiene $1111_2$, que no es un desbordamiento.

### Resumen del circuito aritmético para $u ≥ v$, cuando $u$ y $v$ son números de $n - 1$ bits.

- Restringimos $u$ y $v$ a ser como máximo números de $n - 1$ bits.
- Creamos un circuito aritmético que codifica la representación binaria de $2^{n-1} + (u - v)$ utilizando $n$ bits.
- Si el bit más significativo de $2^{n-1} + (u - v)$ es 1, entonces $u \geq v$ y viceversa.

El circuito aritmético final para comprobar si $u \geq v$ es el siguiente. Fijamos $n = 4$, lo que significa que $u$ y $v$ deben ser números de 3 bits. El lector interesado puede generalizar esto a otros valores de $n$:

```javascript
// u y v se representan con un máximo de 3 bits:
2²a₂ + 2¹a₁ + a₀ === u
2²b₂ + 2¹b₁ + b₀ === v

// 0 1 restricciones para aᵢ, bᵢ
a₀(a₀ - 1) === 0
a₁(a₁ - 1) === 0
a₂(a₂ - 1) === 0
b₀(b₀ - 1) === 0
b₁(b₁ - 1) === 0
b₂(b₂ - 1) === 0

// 2ⁿ⁻¹ + (u - v) representación binaria
2³ + (u - v) === 8c₃ + 4c₂ + 2c₁ + c₀

// 0 1 restricciones para cᵢ
c₀(c₀ - 1) === 0
c₁(c₁ - 1) === 0
c₂(c₂ − 1) === 0
c₃(c₃ − 1) === 0

// Verificar que el MSB sea 1
c₃ === 1
```

### Afirmar que una lista está ordenada

Ahora que tenemos un circuito aritmético para comparar pares de señales, repetimos este circuito para cada par secuencial en la lista y verificamos que esté ordenado.

## Resumen de ejemplos

Hemos mostrado cómo podemos crear un circuito aritmético que modele la solución a los problemas del capítulo anterior.

Ahora podemos generalizar esto para decir que podemos modelar cualquier problema en NP usando un circuito aritmético.

## Cómo se puede modelar un circuito booleano con un circuito aritmético

Cualquier circuito booleano se puede modelar utilizando un circuito aritmético. Esto significa que podemos definir un proceso para convertir un circuito booleano B en un circuito aritmético A, de modo que un conjunto de entradas que satisfacen B se pueda traducir en un conjunto de señales que satisfacen A. A continuación, describimos los componentes clave de este proceso y analizamos un ejemplo de conversión de un circuito booleano específico en un circuito aritmético.

Supongamos que tenemos la siguiente fórmula booleana: `out = (x ∧ ¬ y) ∨ z`. Esta fórmula es verdadera si (`x` es verdadera Y `y` es falsa) O `z` es verdadera.

Codificamos `x`, `y` y `z` como señales de circuito aritmético y las restringimos a tener valores 0 o 1.

El siguiente circuito aritmético solo se puede satisfacer si `x`, `y` y `z` son cada uno 0 o 1.

```javascript
x(x - 1) === 0
y(y - 1) === 0
z(z - 1) === 0
```

Ahora, mostremos cómo mapear operadores de circuito booleanos a operadores de circuito aritmético, suponiendo que las variables de entrada han sido restringidas a ser 0 o 1.

### Puerta AND

Traducimos el AND booleano `t = u ∧ v` a un circuito aritmético de la siguiente manera:

```javascript
u(u - 1) === 0
v(v - 1) === 0
t === uv
```

`t` solo será 1 si tanto `u` como `v` son 1, por lo tanto, este circuito aritmético modela una compuerta AND. Debido a las restricciones `u(u - 1) = 0` y `v(v - 1) = 0`, `t` solo puede ser 0 o 1.

### Puerta NOT

Traducimos la función NOT booleana `t = ¬u` a un circuito aritmético de la siguiente manera:

```javascript
u(u - 1) === 0
t === 1 - u
```

`t` es 1 cuando `u` es 0 y viceversa. Debido a la restricción `u(u - 1) === 0`, `t` solo puede ser 0 o 1.

### Puerta OR

Traducimos la función OR booleana `t === u ∨ v` a un circuito aritmético de la siguiente manera:

```javascript
u(u - 1) === 0
v(v - 1) === 0
t === u + v - uv
```

Para ver por qué modela la puerta OR, considere la siguiente tabla:

| u   | v   | u + v | uv  | t (u + v - uv) |
| --- | --- | ----- | --- | -------------- |
| 0   | 0   | 0     | 0   | 0              |
| 0   | 1   | 1     | 0   | 1              |
| 1   | 0   | 1     | 0   | 1              |
| 1   | 1   | 2     | 1   | 1              |

Si `u` o `v` son 1, entonces `t` será al menos 1. Para evitar que `t` sea igual a 2 (que es una salida no válida de un operador booleano), restamos `uv`, que será 1 cuando tanto `u` como `v` sean 1.

Observe que con todas las puertas anteriores, no necesitamos aplicar una restricción `t(t - 1) === 0`. La salida `t` está implícitamente restringida a ser 0 o 1 porque no hay ninguna asignación a las entradas que pueda resultar en un valor 2 o mayor para `t`.

### Transformando `out = (x ∧ ¬ y) ∨ z` en un circuito aritmético

Ahora que hemos visto cómo traducir todas las operaciones permitidas de los circuitos booleanos en circuitos aritméticos, veamos un ejemplo de conversión de un circuito booleano en uno aritmético.

### Crea las restricciones 0 1

```javascript
x(x - 1) === 0
y(y - 1) === 0
z(z - 1) === 0
```

### Reemplaza `¬ y` con el circuito aritmético para NOT

out = (x ∧ <span style="color:red">¬ y</span>) ∨ z

out = (x ∧ (1 - y)) ∨ z

### Reemplaza `∧` con el circuito aritmético para AND

out = (x <span style="color:red">∧</span> (1 - y)) ∨ z

out = (x(1 - y)) ∨ z

### Reemplaza `∨` con el circuito aritmético para OR

out = (x(1 - y)) <span style="color:red">∨</span> z

out = (x(1 - y)) + z - (x(1 - y))z

Nuestro circuito aritmético final para `out = (x ∧ ¬ y) ∨ z` es:

```javascript
x(x - 1) === 0
y(y - 1) === 0
z(z - 1) === 0
out === (x(1 - y)) + z - (x(1 - y))z
```

Si se desea, podemos simplificar la última ecuación:

```javascript
out === (x(1 - y)) + z - ((x(1 - y))z)
out === x - xy + z - ((x - xy)z)
out === x - xy + z - (xz - xyz)

out === x - xy + z - xz + xyz
```

También podemos escribir el circuito aritmético de la siguiente manera sin cambiar el significado:

```javascript
x² === x
y² === y
z² === z
out === x - xy + z - xz + xyz
```

## Resumen

**Si la solución de cada problema en NP se puede modelar con un circuito booleano y cada circuito booleano se puede transformar en un circuito aritmético equivalente, entonces se deduce que la solución de cada problema en El NP se puede modelar con un circuito aritmético.**

En la práctica, los desarrolladores de ZK prefieren utilizar circuitos aritméticos en lugar de circuitos booleanos porque, como se muestra en los ejemplos anteriores, generalmente requieren menos variables para lograr la misma tarea.

No es necesario calcular un circuito booleano y luego transformarlo en un circuito aritmético. Podemos modelar la solución al problema NP con un circuito aritmético directamente.

## Próximos pasos

Hemos pasado por alto dos detalles muy importantes en este artículo. Existen otros desafíos que deben abordarse. Por ejemplo:

- No analizamos qué tipo de datos usamos para almacenar señales para el circuito aritmético y cómo manejamos el desbordamiento durante la suma o la multiplicación.
- No tenemos forma de expresar el valor 2/3 sin perder precisión. Cualquier representación de punto fijo o punto flotante que elijamos tendrá problemas de redondeo.

Para manejar estos problemas, los circuitos aritméticos se calculan sobre *[campos finitos](rareskills.io/post/finite-fields):* una rama de las matemáticas donde toda la suma y multiplicación se realiza módulo un número primo.

La aritmética de campos finitos tiene algunas diferencias sorprendentes con la aritmética regular introducida por el operador módulo, por lo que el próximo capítulo las explorará en detalle.

## Obtenga más información con RareSkills

Obtenga más información sobre [Pruebas de conocimiento cero](https://www.rareskills.io/zk-book) en nuestro libro gratuito ZK. Este tutorial es un capítulo de ese libro.

## Problemas de práctica

1. Cree un circuito aritmético que tome las señales `x₁`, `x₂`, ..., `xₙ` y se satisfaga si *al menos* una señal es 0.

2. Cree un circuito aritmético que tome las señales `x₁`, `x₂`, ..., `xₙ` y se satisfaga si todas las señales son 1.

3. Un gráfico bipartito es un gráfico que se puede colorear con dos colores de modo que ningún nodo vecino comparta el mismo color. Diseñe un esquema de circuito aritmético para demostrar que tiene un testigo válido de una coloración doble de un gráfico. Sugerencia: el esquema de este tutorial debe ajustarse antes de que funcione con un coloreado de 2 colores.

4. Cree un circuito aritmético que restrinja `k` para que sea el máximo de `x`, `y` o `z`. Es decir, `k` debe ser igual a `x` si `x` es el valor máximo, y lo mismo para `y` y `z`.

5. Cree un circuito aritmético que tome las señales `x₁`, `x₂`, ..., `xₙ`, las restrinja para que sean binarias y genere 1 si *al menos* una de las señales es 1. Sugerencia: esto es más complicado de lo que parece. Considere combinar lo que aprendió en los primeros dos problemas y usar la compuerta NOT.

6. Crea un circuito aritmético para determinar si una señal `v` es una potencia de dos (1, 2, 4, 8, etc.). Sugerencia: crea un circuito aritmético que restrinja otro conjunto de señales para codificar la representación binaria de `v`, luego coloca restricciones adicionales en esas señales.

7. Crea un circuito aritmético que modele el [problema de suma de subconjuntos](https://en.wikipedia.org/wiki/Subset_sum_problem). Dado un conjunto de números enteros (supón que todos son no negativos), determina si hay un subconjunto que sume un valor dado $k$. Por ejemplo, dado el conjunto $\set{3,5,17,21}$ y $k = 22$, hay un subconjunto $\set{5, 17}$ que suma $22$. Por supuesto, un problema de suma de subconjuntos no necesariamente tiene una solución.
   
   <details>
   <summary>Sugerencia</summary>
   <br>
   Utilice un "cambio" que sea 0 o 1 si un número es parte del subconjunto o no.
   </details>

8. El problema del conjunto de recubrimiento comienza con un conjunto $S = \set{1, 2, …, 10}$ y varios subconjuntos bien definidos de $S$, por ejemplo: $\set{1, 2, 3}$, $\set{3, 5, 7, 9}$, $\set{8, 10}$, $\set{5, 6, 7, 8}$, $\set{2, 4, 6, 8}$, y pregunta si podemos tomar como máximo $k$ subconjuntos de $S$ tales que su unión sea $S$. En el problema de ejemplo anterior, la respuesta para $k = 4$ es verdadera porque podemos usar $\set{1, 2, 3}$, $\set{3, 5, 7, 9}$, $\set{8, 10}$, $\set{2, 4, 6, 8}$. Tenga en cuenta que para cada problema, los subconjuntos con los que podemos trabajar se determinan al principio. No podemos construir los subconjuntos nosotros mismos. Si nos hubieran dado los subconjuntos $\set{1,2,3}$, $\set{4,5}$ $\set{7,8,9,10}$ entonces no habría solución porque el número $6$ no está en los subconjuntos.

Por otra parte, si nos hubieran dado $S = \set{1,2,3,4,5}$ y los subconjuntos $\set{1}, \set{1,2}, \set{3, 4}, \set{1, 4, 5}$ y nos hubieran preguntado si se puede cubrir con $k = 2$ subconjuntos, entonces no habría solución. Sin embargo, si $k = 3$ entonces una solución válida sería $\set{1, 2}, \set{3, 4}, \set{1, 4, 5}$.

Nuestro objetivo es demostrar para un conjunto dado $S$ y una lista definida de subconjuntos de $S$, si podemos elegir un conjunto de subconjuntos tales que su unión sea $S$. Específicamente, la pregunta es si podemos hacerlo con $k$ o menos subconjuntos. Deseamos demostrar que sabemos qué $k$ (o menos) subconjuntos usar codificando el problema como un circuito aritmético.

*Publicado originalmente el 23 de abril de 2024*