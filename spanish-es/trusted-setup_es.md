# Configuración confiable
Una configuración confiable es un mecanismo que utilizan los ZK-SNARK para evaluar un polinomio en un valor secreto.

Observe que un polinomio $f(x)$ se puede evaluar calculando el producto interno de los coeficientes con potencias sucesivas de $x$:

Por ejemplo, si $f(x)=3x^3+2x^2+5x+10$, entonces los coeficientes son $[3,2,5,10]$ y podemos calcular el polinomio como

$$
f(x)=\langle[3,2,5,10],[x^3,x^2,x, 1]\rangle
$$

En otras palabras, normalmente pensamos en evaluar $f(2)$ para el polinomio anterior como

$$
f(2)=3(2)^3+2(2)^2+5(2)+10
$$

pero también podríamos evaluarlo como

$$
f(2)=\langle[3,2,5,10],[8,4,2,1]\rangle = 3\cdot8+2\cdot4+5
\cdot2+10\cdot1
$$

Ahora supongamos que alguien elige un escalar secreto $\tau$ y calcula

$$
[\tau^3,\tau^2,\tau,1]
$$

luego multiplica cada uno de esos puntos con el punto generador de un grupo de curvas elípticas criptográficas. El resultado sería el siguiente:

$$
[\Omega_3, \Omega_2, \Omega_1, G_1]=[\tau^3G_1,\tau^2G_1,\tau G_1,G_1]
$$

Ahora cualquiera puede tomar la *cadena de referencia de estructura* $[\Omega_3, \Omega_2, \Omega_1, G_1]$ y evaluar un polinomio de grado tres (o menos) en $\tau$.

Por ejemplo, si tenemos un polinomio de grado 2 $g(x)=4x^2+7x+8$, podemos evaluar $g(\tau)$ tomando el producto interno de la cadena de referencia estructurada con el polinomio:

$$
\langle[0,4,7,8],[\Omega_3, \Omega_2, \Omega_1, G_1]\rangle=4\Omega_2+7\Omega_1+8G_1
$$

¡Ahora hemos calculado $g(\tau)$ *sin saber qué es $\tau$!*

Esto también se llama una *configuración confiable* porque, aunque *nosotros* no sabemos cuál es el logaritmo discreto de $g(\tau)$, la persona que creó la cadena de referencia estructurada sí lo sabe. Esto podría provocar una fuga de información en el futuro, por lo que *confiamos* en que la entidad que crea la configuración confiable elimine $\tau$ y no lo recuerde de ninguna manera.

## Ejemplo en Python

```python
from py_ecc.bn128 import G1, multiplicar, sumar
from functools import reduce

def inner_product(points, coeffs):
return reduce(add, map(multiply, points, coeffs))

## Configuración confiable
tau = 88
grado = 3

# tau^3, tau^2, tau, 1
srs = [multiply(G1, tau**i) for i in range(degree,-1,-1)]

## Evaluar
# p(x) = 4x^2 + 7x + 8
coeffs = [0, 4, 7, 8]

poly_at_tau = inner_product(srs, coeffs)
```

## Verificar que una configuración confiable se generó correctamente

Dada una referencia estructurada cadena, ¿cómo sabemos siquiera que siguen la estructura $[x^d, x^{d-1},\dots,x,1]$ y no fueron elegidos por el lanzamiento de los dados?

Si la persona que realiza la configuración confiable también proporciona $\Theta=\tau G_2$, podemos validar que la cadena de referencia estructurada es de hecho potencias sucesivas de $\tau$.

$$
e(\Theta, \Omega_i)\stackrel{?}=e(G_2,\Omega_{i+1})
$$

donde $e$ es un [emparejamiento bilineal](https://www.rareskills.io/post/bilinear-pairing). Intuitivamente, estamos calculando $\tau\cdot\tau^i$ en el lado izquierdo y $1\cdot\tau^{i+1}$.

Para validar que $\Theta$ y $\Omega_1$ tienen los mismos logaritmos discretos (se supone que $\Omega_1$ es $\tau G_1$), podemos comprobar que

$$
e(\Theta,G_1)\stackrel{?}=e(G_2,\Omega_1)
$$

## Generar una cadena de referencia estructurada como parte de un cálculo multipartito

No es una buena suposición de confianza que la persona que genera la cadena de referencia estructurada realmente haya eliminado $\tau$.

Ahora describimos el algoritmo para que varias partes creen de manera colaborativa la cadena de referencia estructurada y, siempre que una de ellas sea honesta (es decir, elimine $\tau$), los logaritmos discretos de la cadena de referencia estructurada serán desconocidos.

Alice genera la cadena de referencia de estructura $([\Omega_n,...,\Omega_2,\Omega_1, G_1],\Theta)$ y se lo pasa a Bob.

Bob verifica que el srs sea “correcto” usando las comprobaciones de la sección anterior. Luego, Bob elige su propio parámetro secreto $\gamma$ y calcula

$$
([\gamma^n\Omega_n,...,\gamma^2\Omega_2,\gamma\Omega_1,G_1],\gamma\Theta)
$$

Observe que los logaritmos discretos de los srs ahora son

$$
([(\tau\gamma)^n,...,(\tau\gamma)^2,(\tau\gamma),1],\tau\gamma)
$$

Si Alice o Bob eliminan sus $\tau$ o $\gamma$, entonces los logaritmos discretos de los srs finales no son recuperables.

Por supuesto, no necesitamos limitar los participantes a dos, podríamos tener tantos participantes como queramos.

Este cálculo multipartito se suele denominar informalmente la *ceremonia de los poderes de tau*.

## El uso de una configuración confiable en ZK-SNARK
La evaluación de un polinomio en una cadena de referencia estructurada no revela información sobre el polinomio al verificador, y el probador no sabe en qué punto está evaluando. Más adelante veremos que este esquema ayuda a evitar que el probador haga trampa y ayuda a mantener a su testigo con conocimiento cero.

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*
