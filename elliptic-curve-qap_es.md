# Evaluación de un programa aritmético cuadrático en una configuración confiable

La evaluación de un [programa aritmético cuadrático (QAP)](https://www.rareskills.io/post/quadratic-arithmetic-programs) en una configuración confiable permite al probador demostrar que se satisface un QAP sin revelar el testigo mientras se utiliza una prueba de tamaño constante.

Específicamente, los polinomios QAP se evalúan en un punto desconocido $\tau$. La ecuación QAP

$$\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x) = \sum_{i=1}^m a_iw_i(x) + h(x)t(x)$$

estará balanceada si el vector $\mathbf{a}$ satisface la ecuación y desbalanceada con una probabilidad abrumadora en caso contrario.

El esquema que se muestra aquí no es una prueba ZK segura, pero es un paso adelante para mostrar cómo funciona Groth16.

## Un ejemplo concreto

Para hacerlo un poco menos abstracto, digamos que las matrices del [Sistema de restricciones de rango 1 (R1CS)](https://www.rareskills.io/post/rank-1-constraint-system) $\mathbf{L}$, $\mathbf{R}$ y $\mathbf{O}$ tienen 3 filas y 4 columnas.

$$\mathbf{L}\mathbf{a} \circ \mathbf{R}\mathbf{a} = \mathbf{O}\mathbf{a}$$

Como tenemos 3 filas, significa que nuestros polinomios de interpolación serán de grado 2. Como tenemos 4 columnas, cada matriz dará como resultado 4 polinomios (para un total de 12 polinomios).

Nuestro QAP será

$$\sum_{i=1}^4a_iu_i(x)\sum_{i=1}^4a_iv_i(x) = \sum_{i=1}^4a_iw_i(x) + h(x)t(x)$$

## Notación y preliminares

Nos referimos a los puntos de la curva elíptica generadora en los grupos $\mathbb{G}_1$ y $\mathbb{G}_2$ como $G_1$ y $G_2$ respectivamente. Un elemento en $\mathbb{G}_1$ se denota como $[X]_1$. Un elemento en $\mathbb{G}_2$ se denota como $[X]_2$. Cuando puede haber ambigüedad con los subíndices que hacen referencia a los índices en una lista, decimos $X \in \mathbb{G}_1$ o $X \in \mathbb{G}_2$. Un [emparejamiento de curva elíptica](https://www.rareskills.io/post/bilinear-pairing) entre dos puntos se denota como $[X]_1 \bullet [Y]_2$.

Sea $\mathbf{L}_{(*,j)}$ la $j$-ésima columna de $\mathbf{L}$. En nuestro ejemplo, las filas serán $(1,2,3)$ y las columnas $(1,2,3,4)$. Sea $\mathcal{L}(\mathbf{L}_{(*,j)})$ el polinomio obtenido al ejecutar la interpolación de Lagrange en la $j$-ésima columna de $\mathbf{L}$ utilizando los valores $x$ $(1,2,3)$ y los valores $y$ siendo los valores de la $j$-ésima columna.

Como tenemos 4 columnas, obtenemos cuatro polinomios de $\mathbf{L}$ 

$$ \begin{align*} u_1(x) = \mathcal{L}(\mathbf{L}_{(*,1)}) =u_{12}x^2 + u_{11}x+u_{10}\\ u_2(x) = \mathcal{L}(\mathbf{L}_{(*,2)}) _{22}x^2 + u_{21}x+u_{20}\\ u_3(x) = \mathcal{L}(\mathbf{L}_{(*,3)}) =u_{32}x^2 + u_{31}x+u_{30}\\ u_4(x) = \mathcal{L}(\mathbf{L}_{(*,4)}) =u_{42}x^2 + u_{41}x+u_{40}\\
\end{align*}
$$

cuatro polinomios de $\mathbf{R}$

$$
\begin{align*}
v_1(x) = \mathcal{L}(\mathbf{R}_{(*,1)}) =v_{12}x^2 + v_{11}x+v_{10}\\
v_2(x) = \mathcal{L}(\mathbf{R}_{(*,2)}) =v_{22}x^2 + v_{21}x+v_{20}\\
v_3(x) = \mathcal{L}(\mathbf{R}_{(*,3)}) =v_{32}x^2 + v_{31}x+v_{30}\\
v_4(x) = \mathcal{L}(\mathbf{R}_{(*,4)}) =v_{42}x^2 + v_{41}x+v_{40}\\ \end{align*} $$ 

y cuatro polinomios de $\mathbf{O}$ 

$$ \begin{align*} 
v_1(x) = \mathcal{L}(\mathbf{O}_{(*,1)}) =v_{12}x^2 v_{11}x+v_{10}\\ 
v_2(x) = \mathcal{L}(\mathbf{O}_{(*,2)}) =v_{22}x^2 + v_{21}x+v_{20}\\ 
v_3(x) = \mathcal{L}(\mathbf{O}_{(*,3)}) =v_{32}x^2 + v_{31}x+v_{30}\\
v_4(x) = \mathcal{L}(\mathbf{O}_{(*,4)}) =v_{42}x^2 + v_{41}x+v_{40}\\
\end{align*}
$$

Un polinomio $p_{ij}$ significa el polinomio $i$-ésimo de la potencia y el coeficiente $j$-ésimo (potencia). Por ejemplo, $j=2$ significa el coeficiente asociado con $x^2$.

El QAP para nuestro ejemplo es

$$
\sum_{i=1}^4a_iu_i(x)\sum_{i=1}^4a_iv_i(x) = \sum_{i=1}^4a_iw_i(x) + h(x)t(x)
$$

donde $t(x) = (x - 1)(x - 2)(x - 3)$ y $h(x)$ es

$$
h(x)=\frac{\sum_{i=1}^4a_iu_i(x)\sum_{i=1}^4a_iv_i(x) - \sum_{i=1}^4a_iw_i(x)}{t(x)}
$$

### Los grados de los polinomios en el QAP con respecto al tamaño del R1CS

Un par de observaciones sobre los grados de los polinomios en el caso general:

- El grado de $u(x)$ y $v(x)$ podrían ser tan altos como $n - 1$ porque interpolan $n$ puntos, donde $n$ es el número de filas en el R1CS.
- El grado de $w(x)$ podría ser tan bajo como 0 si la suma de los polinomios $\sum_{i=0}^m a_iw_i(x)$ suma el polinomio cero, es decir, los coeficientes se cancelan entre sí de manera aditiva.
- $t(x)$ es de grado $n$ por definición.
- La multiplicación de polinomios suma sus grados y la división de polinomios resta sus grados.

Por lo tanto, h(x) será como máximo $n - 2$ porque

$$\underbrace{n - 1}_{
\deg{u(x)}} + \underbrace{n - 1}_{\deg{v(x)}} - \underbrace{n}_{\deg{t(x)}} = n - 2$$

## Ampliando los términos

Si ampliamos las sumas de nuestro ejemplo anterior, obtenemos lo siguiente

$$
\begin{align*}
\sum_{i=1}^4 a_iu_i(x) &= a_1(u_{12}x^2 + u_{11}x+u_{10}) + a_2(u_{22}x^2 + u_{21}x+u_{20}) + a_3(u_{32}x^2 + u_{31}x+u_{30}) + a_4(u_{42}x^2 + u_{41}x+u_{40})\\
&= (a_1u_{12}+a_2u_{22}+a_3u_{32}+a_4u_{42})x^2 + (a_1u_{11}+a_2u_{21}+a_3u_{31}+a_4u_{41})x + (a_1u_{10}+a_2u_{20}+a_3u_{30}+a_4u_{40})\\
&=u_{2a}x^2+u_{1a}x+u_{0a}\\
\sum_{i=1}^4 a_iv_i(x) &= a_1(v_{12}x^2 + v_{11}x+v_{10}) + a_2(v_{22}x^2 + v_{21}x+v_{20}) + a_3(v_{32}x^2 + v_{31}x+v_{30}) + a_4(v_{42}x^2 + v_{41}x+v_{40})\\
&= (a_1v_{12}+a_2v_{22}+a_3v_{32}+a_4v_{42})x^2 + (a_1v_{11}+a_2v_{21}+a_3v_{31}+a_4v_{41})x + (a_1v_{10}+a_2v_{20}+a_3v_{30}+a_4v_{40})\\
&=v_{2a}x^2+v_{1a}x+v_{0a}\\
\sum_{i=1}^4 a_iw_i(x) &= a_1(w_{12}x^2 + w_{11}x+w_{10}) + a_2(w_{22}x^2 + w_{21}x+w_{20}) + a_3(w_{32}x^2 + w_{31}x+w_{30}) + a_4(w_{42}x^2 + w_{41}x+w_{40})\\
&= (a_1w_{12}+a_2w_{22}+a_3w_{32}+a_4w_{42})x^2 + (a_1w_{11}+a_2w_{21}+a_3w_{31}+a_4w_{41})x + (a_1w_{10}+a_2w_{20}+a_3w_{30}+a_4w_{40})\\
&=w_{2a}x^2+w_{1a}x+w_{0a}\\
\end{align*}
$$

En cada uno de los casos, dado que estamos sumando 4 polinomios de grado 2, obtenemos un polinomio de grado 2.

En la expresión general $\sum_{i=1}^m a_ip_i(x)$ produce un polinomio con, como máximo, la misma potencia que $p(x)$ (podría ser menor, si, por ejemplo, $(a_1w_{12}+a_2w_{22}+a_3w_{32}+a_4w_{42})x^2$ se suman a 0). Para mayor comodidad, hemos introducido los coeficientes $p_{ia}$, donde $i$ es la potencia del coeficiente y $_a$ significa que combinamos los polinomios con el testigo $\mathbf{a}$.

Estos son los polinomios después de reducirlos de esta manera:

$$
\begin{align*}
\sum_{i=1}^4 a_iu_i(x) &= u_{2a}x^2+u_{1a}+u_{0a}\\
\sum_{i=1}^4 a_iv_i(x) &= v_{2a}x^2+v_{1a}+v_{0a}\\
\sum_{i=1}^4 a_iw_i(x) &= w_{2a}x^2+w_{1a}+w_{0a}\\
\end{align*}
$$

## Combinación de una configuración confiable con un QAP

Ahora podemos aplicar la cadena de referencia estructurada de la configuración confiable para evaluar los polinomios.

Es decir, dada una cadena de referencia estructurada

$$[\Omega_2, \Omega_1, G_1], [\Theta_2, \Theta_1, G_2], \space\Omega_i \in \mathbb{G}_1, \space\Theta_i \in \mathbb{G}_2$$

que se calculó en la configuración confiable como

$$
\begin{align*}
[\Omega_2, \Omega_1, G_1] &= [\tau^2G_1, \tau G_1, G_1], \space\Omega_i \in \mathbb{G}_1\\
[\Theta_2, \Theta_1, G_1] &= [\tau^2G_2, \tau G_2, G_2], \space\Theta_i \in \mathbb{G}_2
\end{align*}
$$

Podemos calcular

$$
\begin{align*}
[A]_1 &=\sum_{i=1}^4 a_iu_i(\tau) = \langle[u_{2a}, u_{1a}, u_{0a}],[\Omega_2, \Omega_1, G_1]\rangle\\
[B]_2 &=\sum_{i=1}^4 a_iv_i(\tau) = \langle[v_{2a}, v_{1a}, v_{0a}],[\Theta_2, \Theta_1, G_2]\rangle\\
[C]_1 &=\sum_{i=1}^4 a_iw_i(\tau) = \langle[v_{2a}, v_{1a}, v_{0a}],[\Omega_2, \Omega_1, G_1]\rangle \\ \end{align*} $$

Aquí, $u_i(\tau), v_i(\tau), w_i(\tau)$ significa que los polinomios se evaluaron utilizando la cadena de referencia estructurada generada a partir de $\tau$ en la configuración confiable, no significa "conectar $\tau$ y evaluar los polinomios". Dado que $\tau$ se destruyó después de la configuración confiable, el valor $\tau$ es desconocido.

Hemos calculado la mayor parte del QAP usando la srs, pero aún no hemos calculado $h(x)t(x)$:

$$

\underbrace{\sum_{i=1}^m a_iu_i(x)}_{[A]_1}\underbrace{\sum_{i=1}^m a_iv_i(x)}_{[B]_2} = \underbrace{\sum_{i=1}^m a_iw_i(x)}_{[C]_1} + \underbrace{h(x)t(x)}_{??}
$$

## Cálculo de $h(x)t(x)$

Recuerde que el grado de $t(x)$ es 3 (generalmente $n$) y el grado de $h(x)$ es 1 (generalmente $n - 2$). Si multiplicamos estos valores, podríamos obtener un polinomio de grado 3, que es más de lo que proporciona la ceremonia de potencias de tau. En cambio, las potencias de la ceremonia de tau deben ajustarse para proporcionar una cadena de referencia estructurada para $h(x)t(x)$.

La persona que realiza la configuración confiable sabe que $t(x)$ es simplemente $(x - 1)(x - 2)...(x - n)$. Sin embargo, $h(x)$ es un polinomio calculado por el demostrador y modificado en función de los valores de $\mathbf{a}$, por lo que no se puede conocer durante la configuración confiable.

Tenga en cuenta que no podemos evaluar $h(\tau)$ y $t(\tau)$ por separado (usando una cadena de referencia estructurada) y luego emparejarlos. Eso no daría como resultado un elemento $\mathbb{G}_1$ que necesitamos.

### SRS para productos polinómicos

Observe que los siguientes cálculos dan como resultado el mismo valor:

- El polinomio $h(x)t(x)$ evaluado en $u$, o $(h(x)t(x))(u)$
- $h(u)$ multiplicado por $t(u)$, o $h(u)t(u)$ ($h$ evaluado en $u$ y $t$ evaluado en $u$)
- $h(x)$ multiplicado por la evaluación $t(u)$, luego evaluado en $u$, es decir, $(h(x)t(u))(u)$

Usaremos el tercer método para calcular $h(\tau)t(\tau)$. Supongamos, sin pérdida de generalidad, que $h(x)$ es $3x^2 + 6x + 2$ y $t(u) = 4$. El cálculo sería:

$$h(x)t(u) = (3x^2 + 6x + 2) \cdot 4 = 12x^2 + 24x + 8$$

Si sustituimos $u$ en $12x^2 + 24x + 8$, quedaría $h(u)t(u)$.

Sin embargo, evaluar este polinomio en $\tau$ requeriría que el probador conociera $\tau$. La idea clave aquí es que el cálculo anterior se puede estructurar como:

$$h(u)t(u) = \langle[3, 6, 2], [4u^2, 4u, 4]\rangle=12u^2+24u+8$$

Si la configuración confiable proporciona $[4u^2, 4u, 4]$, y el probador proporciona $[3, 6, 2]$, entonces el probador puede calcular $h(u)t(u)$ sin conocer $u$, porque cualquier cosa que involucre a $u$ está en el vector correcto del producto interno.

### Cadena de referencia estructurada para $h(\tau)t(\tau)$

Para crear una cadena de referencia estructurada para $h(\tau)t(\tau)$, creamos $n - 1$ evaluaciones de $t(\tau)$ multiplicadas por potencias sucesivas de $\tau$.

$$[\Upsilon_{n-2}, \Upsilon_{n-3}, ..., \Upsilon_1, \Upsilon_0] = [\tau^{n-2}t(\tau)G_1, \tau^{n-3}t(\tau)G_1, ..., \tau t(\tau)G_1, t(\tau)G_1]$$

(De manera un tanto confusa, un polinomio de grado $k$ tiene $k+1$ términos, por lo tanto, generamos $k - 1$ evaluaciones para un polinomio de grado $k - 2$. Nótese que Upsilon comienza en ${n-1}$ y termina en 0).

Aquí, $n$ es el número de filas en el R1CS, y establecimos que $h$ no puede tener un grado mayor que $n - 2$.

Para utilizar la cadena de referencia estructurada para calcular $h(\tau)t(\tau)$, el probador hace lo siguiente:

$$h(\tau)t(\tau) = \langle[h_{n-2}, h_{n-3}, ..., h_1, h_0], [\Upsilon_{n-2}, \Upsilon_{n-3}, ..., \Upsilon_1, \Upsilon_0] \rangle$$

## Evaluación de un QAP en una configuración confiable

Ahora unimos todo. Supongamos que tenemos un R1CS con matrices de $n$ filas y $m$ columnas. A partir de esto, podemos aplicar la interpolación de Lagrange para convertirlo en un QAP

$$\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x) = \sum_{i=1}^m a_iw_i(x) + h(x)t(x)$$

Los términos de suma producirán cada uno un polinomio de grado $n - 1$ (un polinomio de Lagrange tiene un grado menos que la cantidad de puntos que interpola), y el polinomio $h(x)$ tendrá un grado como máximo $n - 2$, y $t(x)$ tendrá un grado $n$.

Una configuración confiable genera un elemento de campo aleatorio $\tau$ y calcula:

$$
\begin{align*}
[\Omega_{n-1},\Omega_{n-2},..., \Omega_1, G_1] &= [\tau^{n-1}G_1, \tau^{n-2}G_1,\puntos, \tau G_1, G_1]\\
[\Theta_{n-1}, \Theta_{n-2}, ..., \Theta_1, G_2] &= [\tau^{n-1}G_2, \tau^{n-2}G_2,\puntos, \tau G_2, G_2]\\
[\Upsilon_{n-2}, \Upsilon_{n-3}, ..., \Upsilon_1, \Upsilon_0] &= [\tau^{n-2}t(\tau)G_1, \tau^{n-3}t(\tau)G_1, ..., \tau t(\tau)G_1, t(\tau)G_1]
\end{align*}
$$

Tenga en cuenta que las cadenas de referencia estructuradas deben tener términos suficientes para acomodar los polinomios en el QAP.

Luego, la configuración confiable destruye $\tau$ y publica las cadenas de referencia estructuradas:

$$([\Omega_2, \Omega_1, G_1], [\Theta_2, \Theta_1, G_2], [\Upsilon_{n-2}, \Upsilon_{n-3}, ..., \Upsilon_1, \Upsilon_0])$$

El probador evalúa los componentes del QAP de la siguiente manera:

$$\underbrace{\sum_{i=1}^m a_iu_i(x)}_{A}\underbrace{\sum_{i=1}^m a_iv_i(x)}_B = \underbrace{\sum_{i=1}^m a_iw_i(x) + h(x)t(x)}_{C}$$

$$
\begin{align*}
[A]_1 &=\sum_{i=1}^m a_iu_i(\tau) = \langle[u_{{n-1}a}, u_{{n-2}a}, \puntos, u_{1a}, u_{0a}],[\Omega_{n-1}, \Omega_{n-2}, \puntos, \Omega_1, G_1]\rangle\\
[B]_2 &=\sum_{i=1}^m a_iv_i(\tau) = \langle[v_{{n-1}a}, v_{{n-2}a}, \puntos, v_{1a}, v_{0a}],[\Theta_{n-1}, \Theta_{n-2}, \puntos, \Theta_1, G_2]\rangle\\
[C]_1 &=\sum_{i=0}^m a_iw_i(\tau) + h(\tau)t(\tau) = \langle[w_{{n-1}a}, w_{{n-2}a}, \dots, w_{1a}, w_{0a}],[\Omega_{n-1}, \Omega_{n-2}, \dots, \Omega_1, G_1]\rangle \\
&+\langle[h_{n-2}, h_{n-3}, \dots, h_1, h_0], [\Upsilon_{n-2}, \Upsilon_{n-3}, \dots, \Upsilon_1, \Upsilon_0] \rangle\\
\end{align*}
$$

El probador publica $([A]_1, [B]_2, [C]_1)$ y el verificador puede comprobar que

$$[A]_1 \bullet [B]_2 \stackrel{?}= [C]_1 \bala G_2$$

Si el testigo $\mathbf{a}$ satisface el QAP, entonces la ecuación anterior estará balanceada. Pero el hecho de que la ecuación esté balanceada no garantiza que el probador conozca un $\mathbf{a}$ satisfactorio porque el probador puede publicar puntos de curva elíptica arbitrarios y el verificador no sabe si en realidad se derivan del QAP.

## La prueba es muy pequeña

Observe que la prueba solo consta de tres puntos de curva elíptica. Si un elemento $\mathbb{G}_1$ tiene 64 bytes de tamaño y un elemento $\mathbb{G}_2$ tiene 128 bytes de tamaño, entonces la prueba tiene solo 256 bytes. ¡Esto es cierto *sin importar* el tamaño del R1CS!

Cuanto más grande sea el R1CS, más trabajo tiene el probador, pero el trabajo del verificador permanece constante.

La solución a este problema se describe en el siguiente capítulo sobre el [protocolo Groth16](https://www.rareskills.io/post/groth16).

La prueba sigue teniendo un tamaño constante en Groth16, como se puede ver en el código fuente de Tornado Cash en la [estructura](https://github.com/tornadocash/tornado-core/blob/master/contracts/Verifier.sol#L167-L171)
denominada `Prueba`.

*Traducido al Español en Septiembre de 2024*