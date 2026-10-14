# Compromisos polinomiales a través de los compromisos de Pedersen

Un compromiso polinomial es un mecanismo por el cual un probador puede convencer a un verificador de que un polinomio $p$ tiene una evaluación $y = p(x)$ en el punto $x$ sin revelar nada acerca de $p$. La secuencia es la siguiente:

1. El probador envía al verificador un *compromiso* $C$ con el polinomio, "bloqueando" su polinomio.
2. El verificador responde con un valor $u$ en el que desea que se evalúe el polinomio.
3. El probador responde con $y$ y $\pi$, donde $y$ es la evaluación de $f(u)$ y $\pi$ es la prueba de que la evaluación fue correcta.
4. El verificador verifica $C$, $u$, $y$, $\pi$ y acepta o rechaza que la evaluación del polinomio fue válida.

Este esquema de compromiso no requiere una configuración confiable. Sin embargo, la sobrecarga de comunicación es $O(n)$ ya que el probador debe enviar un compromiso para cada coeficiente en su polinomio.

## Los pasos para comprometerse con el polinomio
### El probador compromete cada coeficiente del polinomio
El probador puede comprometerse con el polinomio creando un [Compromiso de Pedersen](https://www.rareskills.io/post/pedersen-commitment) de cada coeficiente. Para un Compromiso de Pedersen, el probador y el verificador deben acordar dos puntos de curva elíptica con logaritmos discretos desconocidos. Usaremos $G$ y $B$.

Por ejemplo, si tenemos polinomio

$$f(x) = f_0+f_1x+f_2x^2$$

Donde $f_0$ es el término constante, $f_1$ es el coeficiente lineal y $f_2$ es el coeficiente cuadrático.

Podemos crear un compromiso de Pedersen para cada coeficiente. Necesitaremos tres términos de cegamiento $\gamma_0$, $\gamma_1$, $\gamma_2$. Por conveniencia, cualquier escalar usado para cegar usará una letra griega minúscula. Siempre usamos el punto de curva elíptica $B$ para el término de cegamiento. Nuestros compromisos se producen de la siguiente manera:

$$
\begin{align*}
C_0=f_0G+\gamma_0B \\
C_1=f_1G+\gamma_1B \\
C_2=f_2G+\gamma_2B \\
\end{align*}
$$

El probador envía la tupla $(C_0, C_1, C_2)$ al verificador. Estos son esencialmente compromisos de Pedersen para cada uno de los coeficientes del polinomio $f(x)$.

### El verificador elige $u$
El verificador elige su valor para $u$ y lo envía al probador.

### El probador evalúa el polinomio y calcula la prueba
El probador calcula el polinomio original como:

$$
y = f_0 + f_1u + f_2u^2
$$

### El probador evalúa los términos ciegos
La prueba de que la evaluación se realizó correctamente se da mediante el siguiente polinomio, que utiliza los términos ciegos multiplicados por la potencia asociada de $u$. La razón de esto se explicará más adelante.

$$
\pi = \gamma_0 + \gamma_1u+\gamma_2u^2
$$

El probador envía $(y, \pi)$ al verificador. Tenga en cuenta que el probador solo envía elementos de campo (escalares), no puntos de curva elíptica.

**La prueba es simplemente la suma de los términos cegadores para cada coeficiente multiplicado por las potencias de $u$ para ese coeficiente.**

## Paso de verificación
El verificador realiza la siguiente comprobación:

$$
C_0+C_1u+C_2u^2\stackrel{?}{=}yG+\pi B
$$

Si el verificador fue honesto, $y$ será la suma de los coeficientes polinómicos multiplicados por potencias sucesivas de $u$, y $\pi$ será la suma de los términos cegadores multiplicados por las potencias de $u$.

## Por qué funciona el paso de verificación
Si expandimos los puntos de la curva elíptica a sus valores subyacentes, vemos que la ecuación está balanceada:

$$
\begin{align*}
C_0 + C_1u + C_2u^2 &= yG + \pi B \\
(f_0G + \gamma_0B) + (f_1G + \gamma_1B)u + (f_2G + \gamma_2B)u^2 &= (f_0 + f_1u + f_2u^2)G + (\gamma_0 + \gamma_1u + \gamma_2u^2)B \\
f_0G + \gamma_0B + f_1Gu + \gamma_1Bu + f_2Gu^2 + \gamma_2Bu^2 &= (f_0 + f_1u + f_2u^2)G + (\gamma_0 + \gamma_1u + \gamma_2u^2)B \\
f_0G + f_1Gu + f_2Gu^2 + \gamma_0B + \gamma_1Bu + \gamma_2Bu^2 &= (f_0 + f_1u + f_2u^2)G + (\gamma_0 + \gamma_1u + \gamma_2u^2)B \\
(f_0 + f_1u + f_2u^2)G + (\gamma_0 + \gamma_1u + \gamma_2u^2)B &= (f_0 + f_1u + f_2u^2)G + (\gamma_0 + \gamma_1u + \gamma_2u^2)B \\
\end{align*}
$$

En cierto sentido, el demostrador está evaluando el polinomio usando los coeficientes del polinomio y su elección de $u$. Esto producirá la evaluación del polinomio original más los términos ciegos del polinomio.

La prueba de una evaluación correcta es que el demostrador puede separar los términos ciegos de la evaluación del polinomio, aunque el demostrador no conozca los logaritmos discretos de $yG$ y $\pi B$.

El siguiente código Python ilustra el algoritmo:

``` python
import random
from functools import reduce
from py_ecc.bn128 import G1, add, eq, field_modulus, multiply
# WARNING: Points are generated in this manner for convenience. In practice, the point's (g, b) value must be selected randomly and the discrete logs should never be known to anyone.
g, b = random.randint(1, field_modulus - 1), random.randint(1, field_modulus - 1)
G, B = multiply(G1, g), multiply(G1, b)

def commit(secret, salt):
    return add(multiply(G, secret), multiply(B, salt))

# Let's say polynomial be f(x) = x^2 + 2x + 3
salts = [random.randint(1, 10**9+7) for _ in range(3)]
C0, C1, C2 = commit(3, salts[0]), commit(2, salts[1]), commit(1, salts[2])
commitments = [C0, C1, C2]
u = random.randint(1, 10**9+7) # verifier receives the commitments and responds with u
y, pi = u**2 + 2*u + 3, salts[2]*u**2 + salts[1]*u + salts[0] # prover computes the value of y and pi and sends it to verifier

def verify(commitments, y, pi):
    u_powers = [u**i for i in range(len(commitments))]
    combined_commitment = reduce(add, [multiply(commitments[i], u_powers[i]) for i in range(len(commitments))])
    commitment_to_y_pi = commit(y, pi)
    return eq(combined_commitment, commitment_to_y_pi)

is_valid = verify(commitments, y, pi)
print("Verification result:", is_valid)
```

## Por qué el probador no puede hacer trampa
Hacer trampa por parte del probador significa que no evalúa honestamente $y = p(u)$ pero aún así intenta pasar el paso de evaluación final.

Sin pérdida de generalidad, digamos que el probador envía los compromisos correctos para los coeficientes $C_0, C_1, C_2$.

Decimos sin pérdida de generalidad porque hay un desajuste entre los coeficientes enviados en los compromisos y los coeficientes utilizados para evaluar el polinomio.

Para ello, el probador envía $y'$ donde $y' \neq f_0 + f_1u + f_2u^2$.

Usando la ecuación final de la sección anterior, vemos que el probador debe satisfacer:

$$
(f_0 + f_1u + f_2u^2)G+(\gamma_0 + \gamma_1u+\gamma_2u^2)B=y'G+(\gamma_0 + \gamma_1u+\gamma_2u^2)B
$$

Los términos $G$ de la ecuación están claramente desequilibrados. La otra "palanca" que puede utilizar el probador es ajustar el $\pi$ que envía.

$$
(f_0 + f_1u + f_2u^2)G+(\gamma_0 + \gamma_1u+\gamma_2u^2)B=y'G + \boxed{\pi'}B
$$

Dado que $y' \neq f_0 + f_1u + f_2u^2$, el probador malintencionado debe reequilibrar la ecuación eligiendo un término $\pi'$ que explique la falta de coincidencia en los términos $G$. El probador puede intentar resolver $\pi'$ con

$$
\pi'B = (f_0 + f_1u + f_2u^2)G+(\gamma_0 + \gamma_1u+\gamma_2u^2)B - y'G
$$

Pero para resolver esta ecuación, el probador malintencionado debe conocer los logaritmos discretos de $G$ y $B$.

Por ejemplo, si sabemos que el logaritmo discreto de $B$ es $b$ y el logaritmo discreto de $G$ es $g$, entonces podemos calcular $\pi'$ como

$$
\begin{align*}
\pi'b = (f_0 + f_1u + f_2u^2)g+(\gamma_0 + \gamma_1u+\gamma_2u^2)b - y'g \\
\\
\pi' = \frac{(f_0 + f_1u + f_2u^2)g+(\gamma_0 + \gamma_1u+\gamma_2u^2)b - y'g}{b}
\end{align*}
$$

Pero, nuevamente, esto no es posible porque calcular el logaritmo discreto de $B$ y $G$ no es factible.

## Lo que aprende el verificador
El verificador aprende que los compromisos $C_0, C_1, C_2$ representan compromisos válidos con un polinomio que tiene como máximo grado 2, y que $y$ es el valor del polinomio evaluado en $u$.

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*