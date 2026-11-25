# Emparejamientos bilineales en Python, Solidity y EVM

A veces también llamados mapeos bilineales, los emparejamientos bilineales nos permiten tomar tres números, $a$, $b$ y $c$, donde $ab = c$, cifrarlos para convertirlos en $E(a)$, $E(b)$, $E(c)$, donde $E$ es una función de cifrado, y luego enviar los dos valores cifrados a un verificador que puede verificar $E(a)E(b) = E(c)$ pero no conocer los valores originales. Podemos usar emparejamientos bilineales para demostrar que un tercer número es el producto de los dos primeros sin conocer los dos primeros números originales.

Explicaremos los emparejamientos bilineales a un alto nivel y brindaremos algunos ejemplos en Python.

## Requisitos previos

- El lector debe saber qué son la [suma de puntos](https://www.rareskills.io/post/elliptic-curve-addition) y la multiplicación escalar en el contexto de las curvas elípticas.
- El lector también debe conocer el problema del logaritmo discreto en este contexto: un escalar multiplicado por un punto dará como resultado otro punto, y en general no es factible calcular el escalar dado el punto de la curva elíptica.
- El lector debe saber qué son un [campo finito](rareskills.io/post/finite-fields) y un grupo cíclico, y qué es un generador en el contexto de las curvas elípticas. Nos referiremos a los generadores con la variable G.
- El lector debe saber sobre las [precompilaciones de Ethereum](https://www.rareskills.io/post/solidity-precompiles).
  Usaremos letras mayúsculas para denotar puntos de EC (curva elíptica) y letras minúsculas para denotar elementos de campos finitos ("escalares"). Cuando decimos elemento, este podría ser un número entero en un campo finito o podría ser un punto en una curva elíptica. El contexto lo aclarará.

Es posible leer este tutorial sin comprender completamente todo lo anterior, pero será más difícil desarrollar una buena intuición sobre este tema.

## Cómo funcionan los emparejamientos bilineales

Cuando un escalar se multiplica por un punto en una curva elíptica, se produce otro punto de la curva elíptica. Es decir, $P = pG$, donde $p$ es un escalar y $G$ es el generador. Dados $P$ y $G$, no podemos determinar $p$.

Supongamos que $pq = r$. Lo que estamos tratando de hacer es tomar

$$
\begin{align*}
P = pG\\
Q = qG\\
R = rG\\
\end{align*}
$$

y convencer a un verificador de que los logaritmos discretos de $P$ y $Q$ se multiplican para producir el logaritmo discreto de $R$.

Si $pq = r$, y $P = pG$, $Q = qG$, y $R = rG$, entonces queremos una función tal que

$$f(P,Q)=R$$

y no sea igual a $R$ cuando $pq ≠ r$. Esto debería ser cierto para todas las combinaciones posibles de $p$, $q$, y $r$ en el grupo.

Sin embargo, normalmente no es así como expresamos $R$ cuando usamos emparejamientos bilineales. Por razones que analizaremos más adelante, normalmente se calcula como

$$f(P,Q) = f(R,G)$$

$G$ es el punto generador y se puede considerar como $1$. En este contexto, por ejemplo, $pG$ significa que hicimos $(G + G + … + G)$ $p$ veces. $G$ simplemente significa que tomamos $G$ y no agregamos nada. Por lo tanto, en cierto sentido, esto es lo mismo que decir $P
\times Q = R \times 1$.

Por lo tanto, nuestro emparejamiento bilineal es una función que, si se introducen dos puntos de la curva elíptica, se obtiene una salida que *corresponde* al producto de los logaritmos discretos de esos dos puntos.

### Notación

Un emparejamiento bilineal normalmente se escribe como $e(P, Q)$. Aquí, $e$ no tiene nada que ver con el logaritmo natural, y $P$ y $Q$ son puntos de la curva elíptica.

### Generalización, comprobación de si dos productos son iguales

Supongamos que alguien nos dio cuatro puntos de curva elíptica $P_1$, $P_2$, $Q_1$ y $Q_2$ y afirmó que los logaritmos discretos de $P_1$ y $P_2$ tienen el mismo producto que $Q_1$ y $Q_2$, es decir, $p_1p_2 = q_1q_2$. Usando un emparejamiento bilineal, podemos comprobar si esto es cierto sin saber $p_1$, $p_2$, $q_1$ o $q_2$. Simplemente hacemos:

$$e(P_1, P_2) \stackrel{?}{=} e(Q_1, Q_2)$$

### Qué significa "bilineal"

Bilineal significa que si una función toma dos argumentos, y uno de ellos se mantiene constante y el otro varía, entonces el resultado varía linealmente con el argumento no constante.

Si $f(x,y)$ es bilineal y $c$ es constante, entonces $z = f(x, c)$ varía linealmente con $x$ y $z = f(c, y)$ varía linealmente con $y$.

De esto podemos inferir que un emparejamiento bilineal de curva elíptica tiene la siguiente propiedad:

$$
f(aG, bG) = f(abG, G) = f(G, abG)
$$

### ¿Qué devuelve $e(P, Q)$?
Para ser honestos, el resultado es tan matemáticamente aterrador que sería contraproducente tratar de explicarlo realmente. Por eso, gran parte del libro anterior dedicó mucho tiempo a explicar los grupos, porque es exponencialmente más fácil entender qué es un grupo que entender qué devuelve $e(P, Q)$.

La salida de un emparejamiento bilineal es un elemento de grupo, específicamente un elemento de un grupo cíclico finito.

**Es mejor tratar a $e(P, Q)$ como una caja negra** de forma similar a cómo la mayoría de los programadores tratan las funciones hash como cajas negras.

Sin embargo, a pesar de ser una caja negra, todavía sabemos mucho sobre las propiedades de la salida, a la que llamamos $G_T$:

- $G_T$ es un grupo cíclico, por lo que tiene un operador binario cerrado.
- El operador binario de $G_T$ es asociativo.
- $G_T$ tiene un elemento identidad.
- Cada elemento de $G_T$ tiene una inversa.
- Debido a que el grupo es cíclico, tiene un generador.
- Como el grupo es cíclico y finito, los grupos cíclicos finitos son homomórficos a $G_T$. Es decir, tenemos alguna forma de mapear homomórficamente elementos en un cuerpo finito a elementos en $G_T$.

Como el grupo es cíclico, tenemos una noción de $G_T$, $2G_T$, $3G_T$, etc. El operador binario de $G_T$ es aproximadamente lo que llamaríamos "multiplicación", por lo que $8G_T = 2G_T * 4G_T$.

Si realmente quieres saber cómo se ve $G_T$, es un objeto de 12 dimensiones. Sin embargo, el elemento de identidad no tiene un aspecto tan aterrador:

$$(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)$$

## Grupos simétricos y asimétricos

La notación anterior implica que estamos usando el mismo generador y grupo de curva elíptica en todas partes cuando decimos

$$e(aG, bG) = e(abG, G)$$

Sin embargo, en la práctica resulta más fácil crear emparejamientos bilineales cuando un grupo diferente (pero del mismo orden) es diferente para ambos argumentos.

En concreto, decimos

$$e(a, b) → c, \space\space a ∈ G_1, b ∈ G_2, c ∈ G_T$$

Ninguno de los grupos utilizados es el mismo.

Sin embargo, la propiedad que nos interesa sigue siendo válida.

$$e(aG_1, bG_2) = e(abG_1, G_2) = e(G_1, abG_2)$$

En la ecuación anterior, el grupo $G_T$ no se muestra explícitamente, pero ese es el codominio (espacio de salida) de $e(G_1, G_2)$.

Se podría pensar que $G_1$ y $G_2$ son ecuaciones de curva elíptica diferentes con parámetros diferentes (pero la misma cantidad de puntos) y eso sería válido porque son grupos diferentes.

En un emparejamiento simétrico, se utiliza el mismo grupo de curva elíptica para ambos argumentos de la función de emparejamiento bilineal. Esto significa que el generador y el grupo de curvas elípticas utilizados en ambos argumentos son los mismos. En este caso, la función de emparejamiento se suele denotar como:

$$e(aG_1, bG_1) = e(abG_1, G_1) = e(G_1, abG_1)$$

En un emparejamiento asimétrico, los argumentos utilizan grupos diferentes. Por ejemplo, el primer argumento puede utilizar un generador y un grupo de curvas elípticas diferentes a los del segundo argumento. La función de emparejamiento puede satisfacer las propiedades deseadas

$$e(aG_1, bG_2) = e(abG_1, G_2) = e(G_1, abG_2)$$

En la práctica, utilizamos grupos asimétricos y la diferencia entre los grupos que utilizamos se explica en la siguiente sección.

$G_1$ es el mismo grupo del que hablamos en capítulos anteriores y, en el contexto de Ethereum, es el mismo `G1` que importamos de la biblioteca:

```python
from py_ecc.bn128 import G1
```

También podemos importar el `G2` de la misma biblioteca como:

```python
from py_ecc.bn128 import G1, G2
```

Pero, ¿qué es $G_2$?

## Extensiones de campo y el punto `G2` en Python

Los emparejamientos bilineales son bastante independientes de los tipos de grupos que elija, pero $G_2$ de Ethereum usa curvas elípticas con extensiones de campo. Si quieres poder leer el código de Solidity que utiliza ZK-SNARKS, necesitarás al menos una idea aproximada de lo que son.

Normalmente pensamos en los puntos EC como dos puntos $x$ e $y$. Con las *extensiones de campo*, los $x$ e $y$ se convierten en objetos bidimensionales pares $(x, y)$. Esto es análogo a cómo los números complejos “extienden” los números reales y los convierten en algo con dos dimensiones (un componente real y un componente imaginario).

Una extensión de campo es un concepto muy abstracto y, francamente, la relación entre un campo y su extensión no importa desde un concepto puramente funcional.

Piénsalo de esta manera:

![Math meme about field extensions](https://static.wixstatic.com/media/935a00_19c62a78929f4cb28ee0e42a14e8ff85~mv2.png/v1/fill/w_461,h_374,al_c,lg_1,q_90,enc_auto/935a00_19c62a78929f4cb28ee0e42a14e8ff85~mv2.png)

Una curva elíptica en $G_2$ es una curva elíptica donde tanto el elemento $x$ como el $y$ son objetos bidimensionales.

### El punto G2 en Python

Basta de teoría, vamos a codificar esto y ver un punto $G_2$. Instala la biblioteca `py_ecc` de la siguiente manera.

```bash
python -m pip install py_ecc
```

Ahora, importemos las funciones que necesitamos de esta

```python
from py_ecc.bn128 import G1, G2, pairing, add, calculate, eq

print(G1)
# (1, 2)
print(G2)
#((10857046999023057135944570762232829481370756359578518086990519993285655852781, 11559732032986387107991004021392285783925812861821192530917403151452391805634), (8495653923123431417604973247489272438418190587263600148770280649306958101930, 4082367875863433681332203403145435568316851327593401208105741076214120093531))
```

Si miras de cerca, Verás que `G2` es un par de tuplas. La primera tupla es el punto $x$ bidimensional y la segunda tupla es el punto $y$ bidimensional.

`G1` y `G2` son los puntos generadores de sus respectivos grupos.

Tanto `G1` como `G2` tienen el mismo orden (número de puntos en la curva):

```python
from py_ecc.bn128 import G1, G2, eq, curve_order, calculate, eq, curve_order

x = 10 # elegido aleatoriamente
assert eq(multiply(G2, x + curve_order), calculate(G2, ​​x))
assert eq(multiply(G1, x + curve_order), calculate(G1, x))
```

Aunque los puntos `G2` pueden parecer un poco extraños, su comportamiento es el mismo que el de otros grupos cíclicos, especialmente el grupo `G1` con el que estamos familiarizados. Esto significa que podemos construir otros puntos con multiplicación escalar (que en realidad es una suma repetida) como se esperaba

```python
print(eq(add(G1, G1), multiplicar(G1, 2)))
# True
print(eq(add(G2, G2), multiplicar(G2, 2)))
# True
```

Debería ser obvio que solo puedes agregar elementos del mismo grupo.

```python
add(G1, G2) # TypeError
```

Por cierto, esta biblioteca anula algunos operadores aritméticos (puedes hacerlo en Python), lo que significa que puedes hacer lo siguiente:

```python
print(G1 + G1 + G1 == G1*3)
# True

# Lo anterior es lo mismo que esto:
eq(add(add(G1, G1), G1), multiplicar(G1, 3))
# True
```

## Emparejamientos bilineales en Python
Al principio de este artículo, dijimos que los emparejamientos bilineales se pueden usar para verificar si los logaritmos discretos de $P$ y $Q$ se multiplican para producir el logaritmo discreto de $R$, es decir, $PQ = R$.

Así es como podemos hacerlo en Python:

```python
from py_ecc.bn128 import G1, G2, pairing, multiplicar, eq

P = multiplicar(G1, 3)
Q = multiplicar(G2, 8)

R = multiplicar(G1, 24)

assert eq(pairing(Q, R), pairing(G2, R))
```

De manera bastante molesta, la biblioteca requiere que pases el punto `G2` como primer argumento para `pairing`.

### Igualdad de productos
También al principio de este artículo dijimos que un emparejamiento puede verificarse:

$$e(P_2, P_1) \stackrel{?}{=} e(Q_2, Q_1)$$

Así es como podemos hacerlo en Python:

```python
from py_ecc.bn128 import G1, G2, pairing, calculate, eq

P_1 = calculate(G1, 3)
P_2 = calculate(G2, ​​8)

Q_1 = calculate(G1, 6)
Q_2 = calculate(G2, ​​4)

assert eq(pairing(P_2, P_1), matching(Q_2, Q_1))
```

### El operador binario de $G_T$
Los elementos en $G_T$ se combinan usando "multiplicación", pero tenga en cuenta que esto es en realidad una anulación sintáctica en Python:

```python
de py_ecc.bn128 import G1, G2, emparejamiento, multiplicar, eq

# 2 * 3 = 6
P_1 = multiplicar(G1, 2)
P_2 = multiplicar(G2, 3)

# 4 * 5 = 20
Q_1 = multiplicar(G1, 4)
Q_2 = multiplicar(G2, 5)

# 10 * 12 = 120 (6 * 20 = 120 también)
R_1 = multiplicar(G1, 13)
R_2 = multiplicar(G2, 2)

assert eq(emparejamiento(P_2, P_1) * emparejamiento(Q_2, Q_1), emparejamiento(R_2, R_1))

# ¡Falla!
```

¡Pero la afirmación falla!

Los elementos en $G_T$ se comportan como "potencias" de una base.

Recuerde del álgebra que

$$b^xb^y = b^{x+y}$$

Supongamos que generamos un elemento en $G_T$ como $e(3G_2, 2G_1)$. Podríamos pensar en el elemento como $6G_T$, pero sería mucho más útil pensar en él como $b^6G_T$. No hay necesidad de saber qué es $b$ en este contexto, solo que existe.

Por lo tanto, para que nuestro código anterior funcione, cambie $R_1$ y $R_2$ para multiplicarlos por 26.

Nuestro código calcula efectivamente:

$$
\begin{align*}
b ^ {2 \cdot 3} * b ^ {4 \cdot 5} = b ^ {13 \cdot 2}\\
b ^ 6 \cdot b ^ {20} = b ^ {26}
\end{align*}
$$

```python
from py_ecc.bn128 import G1, G2, pairing, calculate, eq

# 2 * 3 = 6
P_1 = calculate(G1, 2)
P_2 = calculate(G2, ​​3)

# 4 * 5 = 20
Q_1 = calculate(G1, 4)
Q_2 = calculate(G2, ​​5)

# 13 * 2 = 16
R_1 = multiplicar(G1, 13)
R_2 = multiplicar(G2, 2)

# b ^ {2 * 3} * b ^ {4 * 5} = b ^ {13 * 2}
# b ^ 6 * b ^ 20 = b ^ 26

assert eq(pairing(P_2, P_1) * pairing(Q_2, Q_1), pairing(R_2, R_1))
```

## Emparejamientos bilineales en Ethereum
### Especificación EIP 197
La biblioteca py_ecc es mantenida por la [Fundación Ethereum](https://ethereum.org/), y es lo que alimenta la precompilación en la dirección 0x8 en la [implementación de PyEVM](https://github.com/ethereum/py-evm).

La precompilación de Ethereum definida en [EIP-197](https://eips.ethereum.org/EIPS/eip-197) funciona en puntos en `G1` y `G2`, y *implícitamente* funciona en puntos en $G_T$.

La especificación de esta precompilación parecerá un poco extraña al principio. Toma una lista de puntos G1 y G2 dispuestos de la siguiente manera:

`A₁B₁A₂B₂...AₙBₙ : Aᵢ ∈ G1, Bᵢ ∈ G2`

Estos se crearon originalmente como

```
A₁ = a₁G1
B₁ = b₁G2
A₂ = a₂G1
B₂ = b₂G2
...
Aₙ = aₙG1
Bₙ = bₙG2
```

La precompilación devuelve 1 si lo siguiente es verdadero

```
a₁b₁ + a₂b₂ + ... + aₙbₙ = 0
```

y cero en caso contrario.

Al principio, esto puede resultar un poco confuso. Esto parece implicar que la precompilación toma el logaritmo discreto de cada uno de los puntos, lo que se acepta como inviable en general. Además, ¿por qué no se comporta como el emparejamiento de los ejemplos anteriores de Python? Los ejemplos anteriores devolvieron un elemento en $G_T$, pero esta precompilación devuelve un valor booleano.

#### Justificación de la decisión de diseño de EIP 197
El primer problema es que los elementos en $G_T$ son grandes, específicamente, son objetos de 12 dimensiones.

Esto ocupará mucho espacio en la memoria, lo que generará mayores costos de gas. Además, debido a cómo funcionan la mayoría de los algoritmos de verificación ZK (esto está fuera del alcance de este artículo), generalmente no verificamos el valor de la salida de un emparejamiento, sino solo que sea igual a otros emparejamientos. En concreto, el paso final de [Groth16](https://www.rareskills.io/post/groth16) (el algoritmo de conocimiento cero utilizado por Tornado Cash) se parece al siguiente:

$$
e(A₁, B₂) = e(α₁, β₂) + e(L₁, γ₂) + e(C₁, δ₂)
$$

Donde cada variable es un punto de la curva elíptica de $\mathbb{G}_1$ o $\mathbb{G}_2$ según su notación de subíndice (habríamos utilizado letras griegas mayúsculas para mantener la coherencia con nuestra notación, pero se parecen demasiado al alfabeto latino).

Los significados de estas variables no son importantes en esta etapa. Lo que importa es el hecho de que se puedan escribir como la suma de "productos" (emparejamiento de curvas elípticas). En concreto, podemos escribirlo como

$$
0 = e(−A₁, B₂) + e(α₁, β₂) + e(L₁, γ₂) + e(C₁, δ₂)
$$

¡Y ahora coincide perfectamente con la especificación de precompilación!

No se trata solo de Groth16, la mayoría de los algoritmos zk tienen una fórmula de verificación que se parece a esa, por lo que la precompilación se diseñó para trabajar con sumas de emparejamientos en lugar de devolver el valor de un solo emparejamiento.

Si miramos el código de verificación de [Tornado Cash](https://www.rareskills.io/post/how-does-tornado-cash-work), podemos ver que está implementando esto exactamente (incluso las letras griegas coinciden, pero no te preocupes si aún no lo entiendes). El $\beta_2$ simplemente significa que es un punto $\mathbb{G}_2$, $\alpha_1$ significa un punto $\mathbb{G}_1$, etc.

![anotación del código de verificación en Tornado Cash](https://static.wixstatic.com/media/935a00_63f7afa2360e49a09139ed2de90189fc~mv2.png/v1/fill/w_1480,h_246,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/935a00_63f7afa2360e49a09139ed2de90189fc~mv2.png)

Dentro de la función de emparejamiento es donde se realiza la llamada a `address(8)` para completar el cálculo de emparejamiento y determinar si la prueba es válida o no.

*A veces, el grupo $G_T$ se denomina $G_{12}$ en el contexto de EIP 197.*

#### Suma de logaritmos discretos
La idea clave aquí es que si

$$ab + cd = 0$$

Entonces también debe ser cierto que

$$A₁B₂ + C₁D₂ = 0₁₂ \space\space\space\space A₁,C₁ ∈ G1, B₂,D₂ ∈ G2$$

en el grupo $\mathbb{G}_{12}$.

La precompilación en realidad no calcula el logaritmo discreto, simplemente verifica si la suma de los pares es cero.

La suma de los emparejamientos es cero si y sólo si la suma de los productos de los logaritmos discretos es cero.

## Ejemplo de solidez de extremo a extremo de emparejamientos bilineales

Tomemos estas entradas de `a`, `b`, `c` y `d`.

```
a = 4
b = 3
c = 6
d = 2

-ab + cd = 0
```

Al ponerlo en la fórmula podemos obtener

$$
A₁B₂ + C₁D₂ = e(−aG1, bG2) + e(cG1, dG2) = 0
$$

En Python esto equivaldrá a

```python
from py_ecc.bn128 import neg, multiplicar, G1, G2
a = 4
b = 3
c = 6
d = 2
# Niega G1 * a para que la ecuación sume 0

print(neg(multiply(G1, a)))
#(3010198690406615200373504922352659861758983907867017329644089018310584441462, 17861058253836152797273815394432013122766662423622084931972383889279925210507)
imprimir(multiplicar(G2, b))
# ((2725019753478801796453339367788033689375851816420509565303521482350756874229, 7273165102799931111715871471550377909735733 521218303035754523677688038059653), (2512659008974376214222774206987427162027254181373325676825515531566330959255, 957874124722006818841961785324909313781880061366718538693995380805373202866))
imprimir(multiplicar(G1, c))
# (4503322228978077916651710446042370109107355802721800704639343137502100212473, 6132642251294427119375180147349983541569387941788025780665104001559216576968)
imprimir(multiplicar(G2, d))
# ((18029695676650738226693292988307914797657423701064905010927197838374790804409, 14583779054894525174450323658765874724019480979794335525732096752006891875705, (2140229616977736810657479771656733941598412 651537078903776637920509952744750, 11474861747383700316476719153975578001603231366361248090558603872215261634898)) 
```

Aquí está la salida en un formato estructurado

```python
aG1_x = 3010198690406615200373504922352659861758983907867017329644089018310584441462,
aG1_y = 17861058253836152797273815394432013122766662423622084931972383889279925210507,

bG2_x1 = 2725019753478801796453339367788033689375851816420509565303521482350756874229,
bG2_x2 = 7273165102799931111715871471550377909735733521218303035754523677688038059653,
bG2_y1 = 2512659008974376214222774206987427162027254181373325676825515531566330959255,
bG2_y2 = 957874124722006818841961785324909313781880061366718538693995380805373202866,

cG1_x = 4503322228978077916651710446042370109107355802721800704639343137502100212473,
cG1_y = 6132642251294427119375180147349983541569387941788025780665104001559216576968,

dG2_x1 = 18029695676650738226693292988307914797657423701064905010927197838374790804409,
dG2_x2 = 14583779054894525174450323658765874724019480979794335525732096752006891875705,
dG2_y1 = 2140229616977736810657479771656733941598412651537078903776637920509952744750,
dG2_y2 = 11474861747383700316476719153975578001603231366361248090558603872215261634898
```

Ahora que tenemos los valores cifrados en puntos en los grupos $\mathbb{G}_1$ y $\mathbb{G}_2$, alguien más o un programa puede confirmar que calculamos $e(A_1,B_2)+e(C_1,D_2)=0$ correctamente sin conocer los valores individuales. valores de `a`, `b`, `c` o `d`. Aquí hay un contrato de Solidity que usa la precompilación ecPairing para confirmar que calculamos las ecuaciones con valores válidos.

Creamos un archivo Pairings.sol para [hacer pruebas unitarias en Foundry](https://www.rareskills.io/post/foundry-testing-solidity) (a continuación proporcionaremos el archivo de prueba)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
contract Pairings {
	/**
		* devuelve verdadero si == 0,
		* devuelve falso si != 0,
		* revierte con "Emparejamiento incorrecto" si el emparejamiento no es válido
	*/
     function run(uint256[12] memory input) public view returns (bool) {
        assembly {
            let success := staticcall(gas(), 0x08, input, 0x0180, input, 0x20)
            if success {
                return(input, 0x20)
            }
        }
        revert("Wrong pairing");
    }
}
```

Usamos este archivo de prueba de Foundry para implementar y llamar a nuestro contrato de emparejamientos para confirmar nuestro cálculo de ecPairing. El siguiente archivo lo llamamos `TestPairings.sol`.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../src/Pairings.sol";

contract PairingsTest is Test {
    Pairings public pairings;

    function setUp() public {
        pairings = new Pairings();
    }

    function testPairings() public view {
        uint256 aG1_x = 3010198690406615200373504922352659861758983907867017329644089018310584441462;
        uint256 aG1_y = 17861058253836152797273815394432013122766662423622084931972383889279925210507;

        uint256 bG2_x1 = 2725019753478801796453339367788033689375851816420509565303521482350756874229;
        uint256 bG2_x2 = 7273165102799931111715871471550377909735733521218303035754523677688038059653;
        uint256 bG2_y1 = 2512659008974376214222774206987427162027254181373325676825515531566330959255;
        uint256 bG2_y2 = 957874124722006818841961785324909313781880061366718538693995380805373202866;

        uint256 cG1_x = 4503322228978077916651710446042370109107355802721800704639343137502100212473;
        uint256 cG1_y = 6132642251294427119375180147349983541569387941788025780665104001559216576968;

        uint256 dG2_x1 = 18029695676650738226693292988307914797657423701064905010927197838374790804409;
        uint256 dG2_x2 = 14583779054894525174450323658765874724019480979794335525732096752006891875705;
        uint256 dG2_y1 = 2140229616977736810657479771656733941598412651537078903776637920509952744750;
        uint256 dG2_y2 = 11474861747383700316476719153975578001603231366361248090558603872215261634898;
		  
        uint256[12] memory points = [
            aG1_x,
            aG1_y,
            bG2_x2,
            bG2_x1,
            bG2_y2,
            bG2_y1,
            cG1_x,
            cG1_y,
            dG2_x2,
            dG2_x1,
            dG2_y2,
            dG2_y1
        ];

        bool x = pairings.run(points);
        console2.log("result:", x);
    }
}
```

**Tenga en cuenta que la forma en que se organizan los puntos G2 no es la misma forma en que Python presenta los puntos G2.**

Esto pasa e imprime `true` en la consola. Tenga en cuenta que los puntos han sido etiquetados por su nombre de variable, a qué grupo pertenecen y si representan una `x` o una `y` del punto de la curva elíptica.

Es importante tener en cuenta que la precompilación ecPairing no espera ni requiere una matriz y que nuestra elección de usar una con inline-assembly es simplemente opcional. Uno podría hacer lo mismo con solidity de la siguiente manera:

```solidity
function run(bytes calldata input) public view returns (bool) {
    // optional, the precompile checks this too and reverts (with no error) if false, this helps narrow down possible errors
    if (input.length % 192 != 0) revert("Points must be a multiple of 6");
    (bool success, bytes memory data) = address(0x08).staticcall(input);
    if (success) return abi.decode(data, (bool));
    revert("Wrong pairing");
}
```

Y actualice el archivo de prueba de la siguiente manera:

```solidity
function testPairings() public view {
    uint256 aG1_x = 3010198690406615200373504922352659861758983907867017329644089018310584441462;
    uint256 aG1_y = 17861058253836152797273815394432013122766662423622084931972383889279925210507;

    uint256 bG2_x1 = 2725019753478801796453339367788033689375851816420509565303521482350756874229;
    uint256 bG2_x2 = 7273165102799931111715871471550377909735733521218303035754523677688038059653;
    uint256 bG2_y1 = 2512659008974376214222774206987427162027254181373325676825515531566330959255;
    uint256 bG2_y2 = 957874124722006818841961785324909313781880061366718538693995380805373202866;

    uint256 cG1_x = 4503322228978077916651710446042370109107355802721800704639343137502100212473;
    uint256 cG1_y = 6132642251294427119375180147349983541569387941788025780665104001559216576968;

    uint256 dG2_x1 = 18029695676650738226693292988307914797657423701064905010927197838374790804409;
    uint256 dG2_x2 = 14583779054894525174450323658765874724019480979794335525732096752006891875705;
    uint256 dG2_y1 = 2140229616977736810657479771656733941598412651537078903776637920509952744750;
    uint256 dG2_y2 = 11474861747383700316476719153975578001603231366361248090558603872215261634898;

    bytes memory points = abi.encode(
        aG1_x,
        aG1_y,
        bG2_x2,
        bG2_x1,
        bG2_y2,
        bG2_y1,
        cG1_x,
        cG1_y,
        dG2_x2,
        dG2_x1,
        dG2_y2,
        dG2_y1
    );

    bool x = pairings.run(points);
    console2.log("result:", x);
}
```

Esto se aprobará y devolverá verdadero al igual que la implementación inicial porque envía exactamente los mismos datos de llamada a la precompilación.

La única diferencia es que en la primera implementación, el archivo de prueba envía una matriz de puntos al contrato de emparejamiento que utiliza ensamblaje en línea para cortar los primeros 32 bytes (longitud de la matriz) y envía el resto a la precompilación. Y en la segunda implementación, el archivo de prueba envía los puntos codificados con abi al contrato de emparejamiento que los reenvía tal como están a la precompilación.

## Obtenga más información de RareSkills

Este material se extrajo de nuestro [Curso de conocimiento cero](https://www.rareskills.io/zk-bootcamp). Consulte el programa para obtener más información.

---

## Realmente quiero comprender las matemáticas detrás de los emparejamientos bilineales

Se le advirtió que las matemáticas son bastante complejas y comprenderlas no lo ayudará a implementar ZK Proofs, que es el objetivo de este libro. Probablemente haya utilizado SHA-256 o Keccak256 de manera productiva sin conocer sus componentes internos, y le sugerimos *enfáticamente* que trate los emparejamientos de la misma manera en esta etapa de su recorrido. Sin embargo, si nuestras advertencias no te han disuadido, aquí tienes un buen recurso si aún quieres adentrarte en el tema: [Pairings for Beginners](https://static1.squarespace.com/static/5fdbb09f31d71c1227082339/t/5ff394720493bd28278889c6/1609798774687/PairingsForBeginners.pdf). *Aquí hay dragones.*

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*
