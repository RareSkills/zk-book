# Groth16 explicado

El algoritmo Groth16 permite que un probador calcule un programa aritmético cuadrático sobre puntos de curva elíptica derivados en una configuración confiable y que un verificador lo verifique rápidamente. Utiliza puntos de curva elíptica auxiliares de la configuración confiable para evitar pruebas falsificadas.

## Requisitos previos

Este artículo es un capítulo del [Libro ZK Proofs de RareSkills](https://www.rareskills.io/zk-book). Se supone que está familiarizado con los capítulos anteriores.

## Notación

Nos referimos a un [punto de curva elíptica](https://www.rareskills.io/post/elliptic-curves-finite-fields) que pertenece al grupo de curvas elípticas $\mathbb{G}_1$ como $[x]_1$ y a un punto de curva elíptica que pertenece al grupo de curvas elípticas $\mathbb{G}_2$ como $[x]_2$. Un [emparejamiento](https://www.rareskills.io/post/bilinear-pairing) entre $[x]_1$ y $[x]_2$ se denota como $[x]_1\bullet[x]_2$ y produce un elemento en $\mathbb{G}_{12}$. Las variables en negrita como $\mathbf{a}$ son vectores, las letras mayúsculas en negrita como $\mathbf{L}$ son matrices y los elementos de campo (a veces denominados informalmente "escalares") son letras minúsculas como $d$. Todas las operaciones aritméticas ocurren en un [campo finito](https://www.rareskills.io/post/finite-fields) con una característica que es igual al orden del grupo de curvas elípticas.

Dado un [Circuito Aritmético (Circuito ZK)](https://www.rareskills.io/post/arithmetic-circuit), lo convertimos en un [Sistema de Restricciones de Rango 1 (R1CS)](https://www.rareskills.io/post/rank-1-constraint-system) $\mathbf{L}\mathbf{a}\circ \mathbf{R}\mathbf{a} = \mathbf{O}\mathbf{a}$ con matrices de dimensión $n$ filas y $m$ columnas con un vector testigo $\mathbf{a}$. Luego, podemos convertir el R1CS en [Programa Aritmético Cuadrático (QAP)](https://www.rareskills.io/post/quadratic-arithmetic-program) interpolando las columnas de las matrices como valores $y$ sobre los valores $x$ $[1,2,...,n]$. Como $\mathbf{L}$, $\mathbf{R}$ y $\mathbf{O}$ tienen $m$ columnas, terminaremos con tres conjuntos de $m$ polinomios:

$$
\begin{array}{}
u_1(x),...,u_m(x) & m \text{ polinomios interpolados en las }m \text{ columnas de } \mathbf{L}\\
v_1(x),...,v_m(x)& m \text{ polinomios interpolados en las }m \text{ columnas de } \mathbf{R}\\
w_1(x),...,w_m(x)& m \text{ polinomios interpolados en las }m \text{ columnas de } \mathbf{O}\\
\end{array}
$$

A partir de esto, podemos construir un programa aritmético cuadrático (QAP):

$$
\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x) = \sum_{i=1}^m a_iw_i(x) + h(x)t(x)
$$

donde

$$
t(x) = (x - 1)(x - 2)\dots(x - n)
$$

y

$$
h(x) = \frac{\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x) - \sum_{i=1}^m a_iw_i(x)}{t(x)}
$$

Si un tercero crea una cadena de referencia estructurada (srs) a través de una ceremonia de potencias de tau, entonces el probador puede evaluar los términos de suma (los términos $\sum a_if_i(x)$) en el QAP en un punto oculto $\tau$. Calculemos las cadenas de referencia estructuradas de la siguiente manera:

$$
\begin{align*}
[\Omega_{n-1}, \Omega_{n-2},\dots,\Omega_2,\Omega_1,G_1] &= [\tau^nG_1,\tau^{n-1}G_1,\dots,\tau G_1,G_1] && \text{srs para } G_1 \\
[\Theta_{n-1}, \Theta_{n-2},\dots,\Theta_2,\Theta_2,G_2] &= [\tau^nG_2,\tau^{n-1}G_2,\dots,\tau G_2,G_2] && \text{srs para } G_2\\
[\Upsilon_{n-2},\Upsilon_{n-3},\dots,\Upsilon_1,\Upsilon_0]&=[\tau^{n-2}t(\tau)G_1,\tau^{n-3}t(\tau)G_1,\dots,\tau t(\tau)G_1,t(\tau)G_1] && \text{srs para }h(\tau)t(\tau)\\
\end{align*}
$$

Nos referimos a $f(\tau)$ como un polinomio evaluado en una cadena de referencia estructurada $[\tau^dG_1,...,\tau^2G_1,\tau G_1,G_1]$ a través del producto interno:

$$
f(\tau) = \sum_{i=1}^d f_i\Omega_i=\langle[f_d, f_{d-1},...,f_1,f_0],[\Omega_d,\Omega_{d-1},...,G_1]\rangle
$$

o para $\mathbb{G}_2$ srs:

$$
f(\tau) = \sum_{i=1}^d f_i\Theta_i=\langle[f_d, f_{d-1},...,f_1,f_0],[\Theta_d,\Theta_{d-1},...,G_1]\rangle
$$

$f(\tau)$ es una abreviatura de la expresión anterior y produce un punto de curva elíptica. No significa que el demostrador conozca $\tau$.

El probador puede evaluar su QAP en la configuración confiable calculando:

$$
\begin{align*}
[A]_1 &= \sum_{i=1}^m a_iu_i(\tau)\\
[B]_2 &= \sum_{i=1}^m a_iv_i(\tau)\\
[C]_1 &= \sum_{i=1}^m a_iw_i(\tau) + h(\tau)t(\tau)
\end{align*}
$$

Los detalles de este cálculo se analizan en nuestro tutorial [Programas aritméticos cuadráticos sobre curvas elípticas](https://www.rareskills.io/post/elliptic-curve-qap).

Si el QAP está equilibrado, entonces se cumple la siguiente ecuación:

$$
[A]_1\bullet[B]_2 \stackrel{?}= [C]_1\bullet G_2
$$

## Motivación

La simple presentación de $([A]_1, [B]_2, [C]_1)$ no es un argumento convincente de que el probador conoce $\mathbf{a}$ de modo que el QAP está balanceado.

El probador puede simplemente inventar valores $a$, $b$, $c$ donde $ab = c$, calcular

$$
\begin{align*}
[A]_1 &= aG_1\\
[B]_2 &= bG_2\\
[C]_1 &= cG_1
\end{align*}
$$

y presentarlos como puntos de curva elíptica $[A]_1$, $[B]_2$, $[C]_1$ al verificador.

Por lo tanto, el verificador no tiene idea de si $([A]_1, [B]_2, [C]_1)$ fueron el resultado de un QAP satisfecho o no.

Necesitamos obligar al probador a ser honesto sin introducir demasiada carga computacional. El primer algoritmo que logró esto fue "[Pinocchio: Nearly Practical Verifiable Computation](https://eprint.iacr.org/2013/279.pdf)." Esto fue lo suficientemente útil para que ZCash basara la primera versión de su cadena de bloques en él.

Sin embargo, Groth16 pudo lograr lo mismo en muchos menos pasos, y el algoritmo todavía se usa ampliamente en la actualidad, ya que ningún algoritmo desde entonces ha producido un algoritmo tan eficiente para el paso de verificación (aunque otros algoritmos han eliminado la configuración confiable o han reducido significativamente la cantidad de trabajo para el probador).

**Actualización para 2024:** Un artículo titulado de manera bastante triunfal "[Polymath: Groth16 is not the limit](https://eprint.iacr.org/2024/916)" publicado en Cryptology demuestra un algoritmo que requiere menos pasos de verificación que Groth16. Sin embargo, no se conocen implementaciones del algoritmo en este momento.

## Prevención de falsificaciones Parte 1: Introducción a $\alpha$ y $\beta$

### Una fórmula de verificación "irresoluble"

Supongamos que actualizamos nuestra fórmula de verificación a la siguiente:

$$[A]_1 \bullet [B]_2 \stackrel{?}= [D]_{12} + [C]_1\bullet G_2$$

*Tenga en cuenta que estamos usando notación aditiva para el grupo $G_{12}$ por conveniencia.*

Aquí, $[D]_{12}$ es un elemento de $G_{12}$ y tiene un logaritmo discreto desconocido.

Ahora demostramos que es imposible para un verificador proporcionar una solución $([A]_1, [B]_2, [C]_1)$ a esta ecuación, sin conocer el logaritmo discreto de $[D]_{12}$.

#### Ataque 1: falsificar A y B y derivar C

Supongamos que el verificador selecciona aleatoriamente $a’$ y $b’$ para producir $[A]₁$ y $[B]₂$ e intenta derivar un valor $[C’]$ que sea compatible con la fórmula del verificador.

$$[A]_1 \bullet [B]_2 \stackrel{?}= [D]_{12} + [C]_1\bullet G_2$$

Conociendo los logaritmos discretos de $[A]₁$ y $[B]₂$, el probador malicioso intenta resolver $[C’]$ haciendo

$$\begin{align*}\underbrace{[A]_1\bullet [B]_2 - [D]_{12}}_{\chi_{12}}=[C']_1\bullet G_2\\
[\chi]_{12}=[C']_1\bullet G_2
\end{align*}$$

La línea final requiere que el probador resuelva el logaritmo discreto de $\chi_{12}$, por lo que no puede calcular un logaritmo discreto válido para $[C']_1$.

#### Ataque 2: falsificar C y derivar A y B

Aquí el demostrador elige un punto aleatorio $c'$ y calcula $[C']_1$. Como conocen $c'$, pueden intentar descubrir una combinación compatible de $a'$ y $b'$ tal que

$$\begin{align*}[A]_1 \bullet [B]_2 &\stackrel{?}= \underbrace{[D]_{12} + [C]_1\bullet G_2}_{[\zeta]_{12}}\\
[A]_1 \bullet [B]_2 &\stackrel{?}=[\zeta]_{12}
\end{align*}$$

Esto requiere que el demostrador, dado $[\zeta]_{12}$, encuentre un $[A]₁$ y un $[B]₂$ que se emparejen para producir $[\zeta]_{12}$.

De manera similar al problema del logaritmo discreto, nos basamos en suposiciones criptográficas no demostradas de que este cálculo (descomponer un elemento en $\mathbb{G}_{12}$ en un elemento $\mathbb{G}_1$ y $\mathbb{G}_2$) es inviable. En este caso, la suposición de que no podemos descomponer $[\zeta]_{12}$ en $[A]₁$ y $[B]₂$ se denomina *Suposición Diffie-Hellman Bilineal*. El lector interesado puede ver una discusión relacionada sobre la [Suposición Diffie-Hellman Decisional](https://en.wikipedia.org/wiki/Decisional_Diffie–Hellman_assumption).

(No probado no significa poco confiable. Si puede encontrar una manera de probar o refutar esta suposición, ¡lo esperan la fama y la fortuna! En la práctica, no se conoce ninguna manera de descomponer $[\zeta]_{12}$ en $[A]₁$ y $[B]₂$ y se cree que es computacionalmente inviable).

### Cómo se usan $\alpha$ y $\beta$

En la práctica, Groth16 no usa un término $[D]_{12}$. En cambio, la configuración confiable genera dos escalares aleatorios $\alpha$ y $\beta$ y publica los puntos de la curva elíptica $([\alpha]_1,[\beta]_2)$ calculados como:

$$
\begin{align*}
[α]_1 &= α G_1 \\
[β]_2 &= β G_2
\end{align*}
$$

Lo que llamamos $[D]_{12}$ es simplemente $[\alpha]_1 \bullet [\beta]_2$.

### Nueva derivación de las fórmulas de demostración y verificación

Para que la fórmula de verificación $[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1\bullet[\beta]_2 + [C]_1\bullet G_2$ sea "soluble", debemos modificar nuestra fórmula QAP para incorporar $\alpha$ y $\beta$.

$$\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x) = \sum_{i=1}^m a_iw_i(x) + h(x)t(x)$$

Ahora consideremos qué sucede si introducimos los términos $\theta$ y $\eta$ en el lado izquierdo de la ecuación:

$$(\boxed{\theta}+\sum_{i=1}^m a_iu_i(x))(\boxed{\eta} +\sum_{i=1}^m a_iv_i(x)) =$$
$$=\boxed{\theta\eta} + \boxed{\theta}\sum_{i=1}^m a_iv_i(x) + \boxed{\eta}\sum_{i=1}^m a_iu_i(x) + \sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x)$$

Podemos sustituir los términos más a la derecha utilizando la definición original de QAP:
$$=\theta\eta + \theta\sum_{i=1}^m a_iv_i(x) + \eta\sum_{i=1}^m a_iu_i(x) + \boxed{\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x)}$$

$$=\theta\eta + \theta\sum_{i=1}^m a_iv_i(x) + \eta\sum_{i=1}^m a_iu_i(x) + \boxed{\sum_{i=1}^m a_iw_i(x) + h(x)t(x)}$$

Ahora podemos introducir un QAP "expandido" con lo siguiente definición:

$$(\theta+\sum_{i=1}^m u_i(x))(\eta +\sum_{i=1}^m v_i(x)) =\theta\eta + \theta\sum_{i=1}^m a_iv_i(x) + \eta\sum_{i=1}^m a_iu_i(x) + \sum_{i=1}^m a_iw_i(x) + h(x)t(x)$$

Como adelanto de hacia dónde nos dirigimos, si reemplazamos $\theta$ con $[\alpha]_1$ y $\eta$ con $[\beta]_2$, obtenemos la fórmula de verificación actualizada de antes:

$$[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + [C]_1\bullet G_2$$

donde

$$\underbrace{([\alpha]_1+\sum_{i=1}^m a_iu_i(\tau))}_{[A]_1}\underbrace{([\beta]_2 +\sum_{i=1}^m a_iv_i(\tau))}_{[B]_2} =[\alpha]_1\bullet[\beta]_2 + (\underbrace{\alpha\sum_{i=1}^m a_iv_i(\tau) + \beta\sum_{i=1}^m a_iu_i(\tau) + \sum_{i=1}^m a_iw_i(\tau) + h(\tau)t(\tau)}_{[C]_1}) \bullet G_2$$

El demostrador puede calcular $[A]_1$ y $[B]_2$ sin saber $\tau$, $\alpha$ o $\beta$. Dada la cadena de referencia estructurada (potencias de $\tau$) y los puntos de la curva elíptica $([α]_1,[β]_2)$, el probador calcula $[A]_1$ y $[B]_2$ como

$$
\begin{align*}
[A]_1 &= [\alpha]_1 + \sum_{i=1}^m a_iu_i(\tau)\\
[B]_2 &= [\beta]_2 + \sum_{i=1}^m a_iv_i(\tau)\\
\end{align*}
$$

Aquí, $a_iu_i(\tau)$ no significa que el probador conozca $\tau$. El probador está usando la cadena de referencia de estructura $[\tau^{n-1}G_1,\tau^{n-2}G_1,\dots,\tau G_1,G_1]$ para calcular $u_i(\tau)$ para $i=1,2,\dots,m$ y las srs $G_2$ para $[B]_2$.

Sin embargo, actualmente no es posible calcular $[C]_1$ sin conocer $\alpha$ y $\beta$. El probador no puede emparejar $[\alpha]_1$ con $\sum a_iu_i(\tau)$ y $[\beta]_2$ con $\sum a_iv_i(\tau)$ porque eso crearía un punto $\mathbb{G}_{12}$, mientras que el probador necesita un punto $\mathbb{G}_1$ para $[C]_1$.

En cambio, la configuración confiable necesita calcular previamente $m$ polinomios para el término $C$ problemático del QAP expandido.

$$\alpha\sum_{i=1}^m a_iv_i(\tau) + \beta\sum_{i=1}^m a_iu_i(\tau) + \sum_{i=1}^m a_iw_i(\tau)$$

Con alguna manipulación algebraica, combinamos los términos de suma en una única suma:

$$=\sum_{i=1}^m (\alpha a_iv_i(\tau)+\beta a_iu_i(\tau) + a_iw_i(\tau))$$

y factorizamos $a_i$:

$$=\sum_{i=1}^m a_i\boxed{(\alpha v_i(\tau)+\beta u_i(\tau) + w_i(\tau))}$$

La configuración confiable puede crear $m$ polinomios evaluados en $\tau$ a partir de la término enmarcado arriba, y el probador puede usarlo para calcular la suma. Los detalles exactos se muestran en la siguiente sección.

### Resumen del algoritmo hasta ahora

#### Pasos de configuración confiable

Concretamente, la configuración confiable calcula lo siguiente:
$$\begin{align*}
\alpha,\beta,\tau &\leftarrow \text{escalares aleatorios}\\
[\tau^{n-1}G_1,\tau^{n-2}G_1,\dots,\tau G_1,G_1] &\leftarrow \text{srs para } \mathbb{G}_1\\
[\tau^{n-1}G_2,\tau^{n-2}G_2,\dots,\tau G_2,G_2] &\leftarrow \text{srs para } \mathbb{G}_2\\
[\tau^{n-2}t(\tau),\tau^{n-3}t(\tau),\dots,\tau t(\tau),t(\tau)] &\leftarrow \text{srs para }h(\tau)t(\tau)\\
[\Psi_1]_1 &= (\alpha v_1(\tau) + \beta u_1(\tau) + w_1(\tau))G_1\\
[\Psi_2]_1 &= (\alpha v_2(\tau) + \beta u_2(\tau) + w_2(\tau))G_1\\
&\vdots\\
[\Psi_m]_1 &= (\alpha v_m(\tau) + \beta u_m(\tau) + w_m(\tau))G_1\\
\end{align*}$$

La configuración confiable publica

$$([\alpha]_1,[\beta]_2,\text{srs}_{G_1},\text{srs}_{G_2}[\Psi_1]_1,[\Psi_2]_1,\dots,[\Psi_m]_1)$$

#### Pasos del probador

El probador calcula

$$\begin{align*}
[A]_1 &= [\alpha]_1 + \sum_{i=1}^m a_iu_i(\tau)\\
[B]_2 &= [\beta]_2 + \sum_{i=1}^m a_iv_i(\tau)\\
[C]_1 &= \sum_{i=1}^m a_i[\Psi_i]_1 + h(\tau)t(\tau)\\
\end{align*}$$

Tenga en cuenta que reemplazamos el Polinomio "problemático"

$$=\sum_{i=1}^m a_i\boxed{(\alpha v_i(\tau)+\beta u_i(\tau) + w_i(\tau))}$$

(el que contenía $\alpha$ y $\beta$) con

$$\sum_{i=1}^m a_i[\Psi_i]_1$$

#### Pasos del verificador

El verificador calcula:

$$[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + [C]_1\bullet G_2$$

## Compatibilidad con entradas públicas

Hasta ahora, la fórmula del verificador no admite entradas públicas, es decir, hacer pública una parte del testigo.

Por convención, las partes públicas del testigo son los primeros $\ell$ elementos del vector $\mathbf{a}$. Para hacer públicos esos elementos, el verificador simplemente los revela:

$$[a_1, a_2, \dots, a_\ell]$$

Para que el verificador pruebe que esos valores se utilizaron de hecho, debe realizar algunos de los cálculos que el verificador estaba haciendo originalmente.

En concreto, el probador calcula:

$$\begin{align*}
[A]_1 &= [\alpha]_1 + \sum_{i=1}^m a_iu_i(\tau)\\
[B]_2 &= [\beta]_2 + \sum_{i=1}^m a_iv_i(\tau)\\
[C]_1 &= \sum_{i=\ell+1}^m a_i[\Psi_i]_1 + h(\tau)t(\tau)\\
\end{align*}$$

Obsérvese que solo cambió el cálculo de $[C]_1$: el probador solo utiliza los términos $a_i$ y $\Psi_i$ $\ell + 1$ a $m$.

El verificador calcula los primeros términos $\ell$ de la suma:
$$[X]_1=\sum_{i=1}^\ell a_i\Psi_i$$

Y la ecuación de verificación es:

$$[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + [X]_1\bullet G_2 + [C]_1\bullet G_2$$

## Parte 2: Separación de las entradas públicas de las entradas privadas con $\gamma$ y $\delta$

La suposición en la ecuación anterior es que el probador solo está usando $\Psi_{\ell+1}$ a $\Psi_m$ para calcular $[C]_1$, pero nada impide que un probador deshonesto use $\Psi_1$ a $\Psi_{\ell}$ para calcular $[C]_1$, lo que posiblemente lleve a una prueba falsificada.

Para evitar esto, la configuración confiable introduce nuevos escalares $\gamma$ y $\delta$ para forzar que $\Psi_{\ell+1}$ a $\Psi_m$ estén separados de $\Psi_1$ a $\Psi_{\ell}$. Para hacer esto, la configuración confiable divide (multiplica por el inverso modular) los términos privados (que constituyen $[C]_1$) por $\delta$ y los términos públicos (que constituyen $[X]_1$, la suma que calcula el verificador) por $\gamma$.

Dado que el término $h(\tau)t(\tau)$ está incrustado en $[C]_1$, esos términos también deben dividirse por $\delta$.

$$\begin{align*}
\alpha,\beta,\tau,\gamma,\delta &\leftarrow \text{escalares aleatorios}\\
[\tau^{n-1}G_1,\tau^{n-2}G_1,\dots,\tau G_1,G_1] &\leftarrow \text{serie para } \mathbb{G}_1\\
[\tau^{n-1}G_2,\tau^{n-2}G_2,\dots,\tau G_2,G_2] &\leftarrow \text{serie para } \mathbb{G}_2\\
[\frac{\tau^{n-2}t(\tau)}{\delta},\frac{\tau^{n-3}t(\tau)}{\delta},\dots,\frac{\tau t(\tau)}{\delta},
\frac{t(\tau)}{\delta}] &\leftarrow \text{srs para }h(\tau)t(\tau)\\
\\
&\text{parte pública del testigo}\\
[\Psi_1]_1 &= \frac{\alpha v_1(\tau) + \beta u_1(\tau) + w_1(\tau)}{\gamma}G_1\\
[\Psi_2]_1 &= \frac{\alpha v_2(\tau) + \beta u_2(\tau) + w_2(\tau)}{\gamma}G_1\\
&\vdots\\
[\Psi_\ell]_1 &= \frac{\alpha v_m(\tau) + \beta u_m(\tau) + w_m(\tau)}{\gamma}G_1\\
\\
&\text{parte privada del testigo}\\
[\Psi_{\ell+1}]_1 &= \frac{\alpha v_{\ell+1}(\tau) + \beta u_{\ell+1}(\tau) + w_{\ell+1}(\tau)}{\delta}G_1\\
[\Psi_{\ell+2}]_1 &= \frac{\alpha v_{\ell+2}(\tau) + \beta u_{\ell+2}(\tau) + w_{\ell+2}(\tau)}{\delta}G_1\\
&\vdots\\
[\Psi_{m}]_1 &= \frac{\alpha v_{m}(\tau) + \beta u_{m}(\tau) + w_{m}(\tau)}{\delta}G_1\\
\end{align*}$$

La configuración confiable publica
$$([\alpha]_1,[\beta]_2,[\gamma]_2,[\delta]_2,\text{srs}_{G_1},\text{srs}_{G_2},[\Psi_1]_1,[\Psi_2]_1,\dots,[\Psi_m]_1)$$

Los pasos del probador son los mismos que antes:

$$\begin{align*}
[A]_1 &= [\alpha]_1 + \sum_{i=1}^m a_iu_i(\tau)\\
[B]_2 &= [\beta]_2 + \sum_{i=1}^m a_iv_i(\tau)\\
[C]_1 &= \sum_{i=\ell+1}^m a_i[\Psi_i]_1 + h(\tau)t(\tau)\\
\end{align*}$$

Y los pasos del verificador ahora incluyen el emparejamiento por $[\gamma]_2$ y $[\delta]_2$ para cancelar los denominadores:

$$[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + [X]_1\bullet [\gamma]_2 + [C]_1\bullet [\delta]_2$$

## Parte 3: Imposición de un verdadero conocimiento cero: r y s

Nuestro esquema aún no es verdaderamente de conocimiento cero. Si un atacante puede adivinar nuestro vector de testigos (lo cual es posible si solo hay un pequeño rango de entradas válidas, por ejemplo, votación secreta de direcciones privilegiadas), entonces puede verificar que su suposición es correcta comparando su prueba construida con la prueba original.

Como ejemplo trivial, supongamos que nuestra afirmación es $x_1$ y $x_2$ son ambos $0$ o $1$. El circuito aritmético correspondiente sería

$$
\begin{align*}
x_1 (x_1 - 1) = 0\\
x_2 (x_2 - 1) = 0
\end{align*}
$$

Un atacante solo necesita adivinar cuatro combinaciones para averiguar cuál es el testigo. Es decir, adivina un testigo, genera una prueba y ve si su respuesta coincide con la prueba original.

Para evitar adivinar, el probador necesita "salar" su prueba, y la ecuación de verificación debe modificarse para acomodar la sal.

El probador toma muestras de dos elementos de campo aleatorios $r$ y $s$ y los agrega a $A$ y $B$ para hacer que el testigo sea imposible de adivinar: un atacante tendría que adivinar tanto el testigo como las sales $r$ y $s$:

$$
\begin{align*}
[A]_1 &= [\alpha]_1 + \sum_{i=1}^m a_iu_i(\tau) + r[\delta]_1\\
[B]_2 &= [\beta]_2 + \sum_{i=1}^m a_iv_i(\tau) + s[\delta]_2\\
[B]_1 &= [\beta]_1 + \sum_{i=1}^m a_iv_i(\tau) + s[\delta]_1\\
[C]_1 &= \sum_{i=\ell+1}^m a_i[\Psi_i]_1 + h(\tau)t(\tau) + As+Br-rs[\delta]_1\\
\end{align*}
$$

Para derivar la fórmula de verificación final, ignoremos temporalmente que no sabemos los logaritmos discretos de los términos de las letras griegas y calculamos el lado izquierdo de la ecuación de verificación $AB$:

$$\underbrace{(\alpha + \sum_{i=1}^m a_iu_i(x) + r\delta)}_A \underbrace{(\beta + \sum_{i=1}^m a_iv_i(x) + s\delta)}_B$$

Desarrollando los términos obtenemos:

$$
\alpha\beta+\alpha\sum_{i=1}^m a_iv_i(x)+\alpha s\delta + \beta\sum_{i=1}^m a_iu_i(x) + \sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x)+\sum_{i=1}^m a_iu_i(x) s\delta + r\delta\beta + r\delta\sum_{i=1}^m a_iv_i(x) + r\delta s\delta
$$

Podemos seleccionar los términos originales para $C$

$$
\alpha\beta+\boxed{\alpha\sum_{i=1}^m a_iv_i(x)}+\alpha s\delta + \boxed{\beta\sum_{i=1}^m a_iu_i(x)} + \boxed{\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x)}+\sum_{i=1}^m a_iu_i(x) s\delta + r\delta\beta + r\delta\sum_{i=1}^m a_iv_i(x) + r\delta s\delta
$$

Y combinar a la izquierda, dejando los nuevos términos a la derecha:

$$
\alpha\beta + \boxed{\alpha\sum_{i=1}^m a_iv_i(x) + \beta\sum_{i=1}^m a_iu_i(x) + \sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x)}+ \underline{\alpha s\delta + \sum_{i=1}^m a_iu_i(x) s\delta + r\delta\beta + r\delta\sum_{i=1}^m a_iv_i(x) + r\delta s\delta}
$$

Reordenamos aún más los términos subrayados para escribirlos en términos de $As\delta$ y $Br\delta$ de la siguiente manera. También dividimos $r\delta s\delta$ en $rs\delta^2 + rs\delta^2 - rs\delta^2$:

$$
=\alpha s\delta + \sum_{i=1}^m a_iu_i(x) s\delta + rs\delta^2 + r\delta\beta + r\delta\sum_{i=1}^m a_iv_i(x) + rs\delta^2 - rs\delta^2
$$

Agrupamos los términos $s$ y $r$:
$$
=(\alpha s\delta + \sum_{i=1}^m a_iu_i(x) s\delta + rs\delta^2) + (r\delta\beta + r\delta\sum_{i=1}^m a_iv_i(x) + rs\delta^2) - rs\delta^2
$$

Factoriza $s\delta$ y $r\delta$:
$$
=\underbrace{(\alpha+ \sum_{i=1}^m a_iu_i(x) + r\delta)s\delta}_{As\delta} + \underbrace{(\beta + \sum_{i=1}^m a_iv_i(x) + s\delta)r\delta}_{Br\delta} - rs\delta^2
$$

Sustituye $A$ y $B$:
$$
=As\delta + Bs\delta - rs\delta
$$

Entonces nuestra ecuación final es

$$(\alpha + \sum_{i=1}^m a_iu_i(x) + r\delta)(\beta + \sum_{i=1}^m a_iv_i(x) + s\delta)=\alpha\beta+\sum_{i=1}^m a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x)) + h(x)t(x) + As\delta + Bs\delta - rs\delta$$

Ahora lo dividimos en las partes pública y privada:

$$(\alpha + \sum_{i=1}^m a_iu_i(x) + r\delta)(\beta + \sum_{i=1}^m a_iv_i(x) + s\delta)=\alpha\beta+\underbrace{\sum_{i=1}^\ell a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x))}_\text{public} + \underbrace{\sum_{i=\ell+1}^m a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x)) + h(x)t(x) + As\delta + Bs\delta - rs\delta}_\text{private}$$

Queremos que la parte pública y la parte privada estén separadas por $\gamma$ y $\delta$ respectivamente:

$$(\alpha + \sum_{i=1}^m a_iu_i(x) + r\delta)(\beta + \sum_{i=1}^m a_iv_i(x) + s\delta)=\alpha\beta+\gamma\frac{\sum_{i=1}^\ell a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x))}{\gamma} + \delta\frac{\sum_{i=\ell+1}^m a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x)) + h(x)t(x) + As\delta + Bs\delta - rs\delta}{\delta}$$

$\delta$ se cancela para algunos de los términos:

$$(\alpha + \sum_{i=1}^m a_iu_i(x) + r\delta)(\beta + \sum_{i=1}^m a_iv_i(x) + s\delta)=\alpha\beta+\gamma\frac{\sum_{i=1}^\ell a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x))}{\gamma} + \delta\frac{\sum_{i=\ell+1}^m a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x)) + h(x)t(x)}{\delta} + As + Bs - rs\delta$$

Ahora separamos esta ecuación en las partes del verificador y del probador. Los términos enmarcados son la parte del verificador, los términos entre llaves son los términos que proporciona el demostrador:

$$\underbrace{(\alpha + \sum_{i=1}^m a_iu_i(x) + r\delta)}_{[A]_1}\underbrace{(\beta + \sum_{i=1}^m a_iv_i(x) + s\delta)}_{[B]_2}=\boxed{\alpha\beta}+\boxed{\gamma}\boxed{\frac{\sum_{i=1}^\ell a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x))}{\gamma}} + \boxed{\delta}\underbrace{\frac{\sum_{i=\ell+1}^m a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x)) + h(x)t(x)}{\delta} + As + Bs - rs\delta}_{[C]_1}$$

## Algoritmo de prueba Groth16

Ahora estamos listos para mostrar el algoritmo Groth16 de principio a fin.

### Configuración confiable

$$\begin{align*}
\alpha,\beta,\tau,\gamma,\delta &\leftarrow \text{escalares aleatorios}\\
[\tau^{n-1}G_1,\tau^{n-2}G_1,\dots,\tau G_1,G_1] &\leftarrow \text{srs for } \mathbb{G}_1\\
[\tau^{n-1}G_2,\tau^{n-2}G_2,\dots,\tau G_2,G_2] &\leftarrow \text{srs for } \mathbb{G}_2\\
[\frac{\tau^{n-2}t(\tau)}{\delta},\frac{\tau^{n-3}t(\tau)}{\delta},\dots,\frac{\tau t(\tau)}{\delta},
\frac{t(\tau)}{\delta}] &\leftarrow \text{srs para }h(\tau)t(\tau)\\
\\
&\text{parte pública del testigo}\\
[\Psi_1]_1 &= \frac{\alpha v_1(\tau) + \beta u_1(\tau) + w_1(\tau)}{\gamma}G_1\\
[\Psi_2]_1 &= \frac{\alpha v_2(\tau) + \beta u_2(\tau) + w_2(\tau)}{\gamma}G_1\\
&\vdots\\
[\Psi_\ell]_1 &= \frac{\alpha v_m(\tau) + \beta u_m(\tau) + w_m(\tau)}{\gamma}G_1\\
\\
&\text{parte privada del testigo}\\
[\Psi_{\ell+1}]_1 &= \frac{\alpha v_{\ell+1}(\tau) + \beta u_{\ell+1}(\tau) + w_{\ell+1}(\tau)}{\delta}G_1\\
[\Psi_{\ell+2}]_1 &= \frac{\alpha v_{\ell+2}(\tau) + \beta u_{\ell+2}(\tau) + w_{\ell+2}(\tau)}{\delta}G_1\\
&\vdots\\
[\Psi_{m}]_1 &= \frac{\alpha v_{m}(\tau) + \beta u_{m}(\tau) + w_{m}(\tau)}{\delta}G_1\\
\end{align*}$$

La configuración confiable publica
$$([\alpha]_1,[\beta]_1[\beta]_2,[\gamma]_2,[\delta]_1[\delta]_2,\text{srs}_{G_1},\text{srs}_{G_2},[\Psi_1]_1,[\Psi_2]_1,\dots,[\Psi_m]_1)$$

### Pasos del probador

El probador tiene un testigo $\mathbf{a}$ y genera números aleatorios escalares $r$ y $s$.
$$\begin{align*}
[A]_1 &= [\alpha]_1 + \sum_{i=1}^m a_iu_i(\tau)+r[\delta]_1\\
[B]_1 &= [\beta]_1 + \sum_{i=1}^m a_iv_i(\tau)+s[\delta]_1\\
[B]_2 &= [\beta]_2 + \sum_{i=1}^m a_iv_i(\tau)+s[\delta]_2\\
[C]_1 &= \sum_{i=\ell+1}^m a_i[\Psi_i]_1 + h(\tau)t(\tau)+[A]_1s+[B]_2r-rs[\delta]_1\\
\end{align*}$$

El demostrador publica $([A]_1, [B]_2, [C]_1, [a_1,...,a_\ell])$.

### Pasos del verificador

El verificador verifica

$$
\begin{align*}
[X]_1&=\sum_{i=1}^\ell a_i\Psi_i\\
[A]_1\bullet[B]_2 &\stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + [X]_1\bullet [\gamma]_2 + [C]_1\bullet [\delta]_2
\end{align*}
$$

## Verificación de Groth16 en Solidity

En este punto, tienes el conocimiento suficiente para comprender el código de verificación de pruebas en Solidity. Aquí se encuentra el código de verificación de prueba de Tornado Cash (https://github.com/tornadocash/tornado-core/blob/master/contracts/Verifier.sol#L192). Se recomienda al lector que lea atentamente el código fuente. Si el lector se siente cómodo con la programación en ensamblador de Solidity, comprender este código fuente no será difícil, ya que los nombres de las variables son consistentes con los de este artículo.

También hay soporte de biblioteca para [Groth16 en Solana] (https://lib.rs/crates/groth16-solana).

## Problemas de seguridad que se deben tener en cuenta

### Groth16 es maleable

Las pruebas de Groth16 son maleables. Dada una prueba válida

$([A]_1, [B]_2, [C]_1)$, un atacante puede calcular la negación puntual de $[A]_1$ y $[B]_2$ y presentar una nueva prueba como $([A']_1, [B']_2, [C]_1)$ donde $[A']_1 = \mathsf{neg}([A]_1)$ y $[B']_2 = \mathsf{neg}([B]_2)$.

Para ver que $[A]_1\bullet[B]_2 = [A']_1\bullet[B']_2$, considere el siguiente código:

```python
from py_ecc.bn128 import G1, G2, multiplicar, neg, eq, pairing

# elegido arbitrariamente
x = 10
y = 100
A = multiplicar(G1, x)
B = multiplicar(G2, y)

A_p = neg(A)
B_p = neg(B)

assert eq(pairing(B, A), pairing(B_p, A_p))
```

Intuitivamente, el atacante está multiplicando $A$ y $B$ por $-1$, y $(-1)\times(-1)$ se cancela a sí mismo en el emparejamiento.

Por lo tanto, si la fórmula de verificación acepta
$$[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + [X]_1\bullet [\gamma]_2 + [C]_1\bullet [\delta]_2$$

entonces también aceptará

$$\mathsf{neg}([A]_1)\bullet\mathsf{neg}([B]_2) \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + [X]_1\bullet [\gamma]_2 + [C]_1\bullet [\delta]_2$$

La defensa contra este ataque se describe en la siguiente sección.

Puede ver una prueba de concepto de este ataque en este [artículo](https://medium.com/@cryptofairy/exploring-vulnerabilities-the-zksnark-malleability-attack-on-the-groth16-protocol-8c80d13751c5).

### El probador puede crear una cantidad ilimitada de pruebas para el mismo testigo

Esto no es un "problema de seguridad" en sí mismo: es necesario para lograr el Conocimiento Cero. Sin embargo, la aplicación necesita un mecanismo para rastrear qué hechos ya se han probado y no puede depender de la singularidad de la prueba para lograrlo.

## Obtenga más información con RareSkills

Nuestra capacidad para publicar material como este de forma gratuita depende del apoyo continuo de nuestros estudiantes. Considere inscribirse en nuestro [Zero Knowledge Bootcamp](https://www.rareskills.io/zk-bootcamp), [Web3 Bootcamps](https://www.rareskills.io/web3-blockchain-bootcamps) o conseguir un trabajo en [RareTalent](https://www.raretalent.xyz).

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*
