# Una prueba de conocimiento cero para el producto interno

En el capítulo anterior, mostramos cómo multiplicar dos escalares entre sí de manera que no exista conocimiento: nos comprometemos con dos polinomios de grado uno y demostramos que calculamos correctamente su producto, y luego demostramos que el término constante de los polinomios de grado uno son los compromisos con los factores secretos que estamos multiplicando.

Si los coeficientes de nuestro polinomio son vectores en lugar de escalares, entonces podemos demostrar que calculamos correctamente el producto interno del vector.

## Polinomios con vectores como coeficientes
Los siguientes son dos polinomios con coeficientes vectoriales:

$$
\begin{align*}
\mathbf{l}(x) &= \begin{bmatrix} 1 \\ 2 \end {bmatrix} x + \begin{bmatrix} 3 \\ 4 \end{bmatrix} \\
\mathbf{r}(x) &= \begin{bmatrix} 2 \\ 3 \end{bmatrix} x +\begin{bmatrix} 7 \\ 2 \end{bmatrix}
\end{align*}
$$

La evaluación de un polinomio vectorial produce otro vector. Por ejemplo, $\mathbf{l}(2)$ produce

$$
\mathbf{l}(2) = \begin{bmatrix} 1 \\ 2 \end{bmatrix} (2) + \begin{bmatrix} 3 \\ 4 \end{bmatrix} = \begin{bmatrix} 5 \\ 8 \end{bmatrix}
$$

y evaluar $\mathbf{r}$ en 2 devuelve:

$$
\mathbf{r}(2) = \begin{bmatrix} 2 \\ 3 \end{bmatrix} (2) + \begin{bmatrix} 7 \\ 2 \end{bmatrix} = \begin{bmatrix} 11 \\ 8 \end{bmatrix}
$$

## Multiplicar polinomios vectoriales
Los polinomios vectoriales pueden se pueden multiplicar entre sí como polinomios escalares. Por ejemplo, multiplicar $\mathbf{l}(x)$ y $\mathbf{r}(x)$ da como resultado:

$$
\mathbf{l}(x)\mathbf{r}(x) =
(\begin{bmatrix}
1\\2
\end{bmatrix}x+
\begin{bmatrix}
3\\4
\end{bmatrix})(
\begin{bmatrix}
2 \\ 3
\end{bmatrix}x +
\begin{bmatrix}
7\\2
\end{bmatrix}
)=$$
$$
=\begin{bmatrix}
2\\6
\end{bmatrix}x^2+
\begin{bmatrix}
7\\4
\end{bmatrix}x+
\begin{bmatrix}
6\\12
\end{bmatrix}x+
\begin{bmatrix}
21\\8
\end{bmatrix}$$
$$=
\begin{bmatrix}
2\\6
\end{bmatrix}x^2+
\begin{bmatrix}
13\\16
\end{bmatrix}x+
\begin{bmatrix}
21\\8
\end{bmatrix}
$$

Cuando multiplicamos cada uno de los vectores, tomamos la Producto de Hadamard (producto elemento a elemento, denotado con $\circ$).

Observe que si introducimos $x = 2$ en el polinomio vectorial resultante, obtenemos lo siguiente:

$$
\begin{bmatrix}
2\\6
\end{bmatrix}(2)^2+
\begin{bmatrix}
13\\16
\end{bmatrix}(2)+
\begin{bmatrix}
21\\8
\end{bmatrix}=
\begin{bmatrix}
55\\64
\end{bmatrix}
$$

Esto es lo mismo que si calculamos:

$\mathbf{l}(2)\circ\mathbf{r}(2) = \begin{bmatrix}5\\8\end{bmatrix}\circ\begin{bmatrix}11\\8\end{bmatrix}=\begin{bmatrix}55\\64\end{bmatrix}$

## Producto interno de polinomios vectoriales
Para calcular el producto interno de dos polinomios vectoriales, los multiplicamos como se describió anteriormente, pero luego sumamos todos los vectores para que se conviertan en escalares. Denotamos esta operación como $\langle \mathbf{l}(x), \mathbf{r}(x) \rangle$. Podemos lograr lo mismo utilizando el producto interno cuando multiplicamos los coeficientes vectoriales en lugar de utilizar el producto de Hadamard.

Para los dos polinomios de ejemplo anteriores, esto sería:

$$\langle \mathbf{l}(x), \mathbf{r}(x) \rangle = \langle \begin{align*}\end{align*} \begin{bmatrix} 1 \\ 2 \end{bmatrix} x +\begin{bmatrix} 3 \\ 4 \end{bmatrix},\begin{bmatrix}2\\3\end{bmatrix}x+\begin{bmatrix}7\\2\end{bmatrix}\rangle$$

$$=\langle \begin{bmatrix} 1 \\ 2 \end{bmatrix},\begin{bmatrix}2 \\ 3 \end{bmatrix}\rangle x^2 + \langle \begin{bmatrix} 3 \\ 4 \end{bmatrix},\begin{bmatrix}2 \\ 3 \end{bmatrix}\rangle x + \langle \begin{bmatrix} 1 \\ 2 \end{bmatrix},\begin{bmatrix}7 \\ 2 \end{bmatrix}\rangle x+\langle \begin{bmatrix} 3 \\ 4 \end{bmatrix},\begin{bmatrix}7 \\ 2 \end{bmatrix}\rangle$$

$$=8x^2 + 18x + 11x + 29$$

$$=8x^2 + 29x + 29$$

Observe que $\langle\mathbf{l}(2), \mathbf{r}(2)\rangle$ es lo mismo que $\langle \mathbf{l}(x), \mathbf{r}(x)\rangle$ se evalúa en $x = 2$. Es decir, $\langle [5, 8], [11, 8]\rangle = 119$ y $8(2)^2 + 29(2) + 29 = 119$.

### Por qué funciona esto en general
Supongamos que multiplicamos polinomios vectoriales de la manera "normal", es decir, tomamos el producto elemento por elemento (producto de Hadamard) de los coeficientes en lugar del producto interno. El producto interno de cada uno de los coeficientes es simplemente la suma de los términos del producto de Hadamard de cada uno de los coeficientes. Por lo tanto, podemos decir que si tenemos dos polinomios vectoriales $\mathbf{l}(x)$ y $\mathbf{r}(x)$, y los multiplicamos entre sí como $\mathbf{t}(x)=\mathbf{l}(x)\mathbf{r}(x)$ entonces el producto interno de $\langle \mathbf{l}(x), \mathbf{r}(x) \rangle$ es igual a la suma elemento por elemento de los coeficientes de $\mathbf{t}$. Nótese que la multiplicación de dos polinomios vectoriales da como resultado un polinomio vectorial, pero el producto interno de dos polinomios vectoriales da como resultado un polinomio donde todos los coeficientes son escalares.

## Prueba del producto interno con conocimiento cero
En el capítulo anterior sobre la multiplicación con conocimiento cero, demostramos que tenemos una multiplicación válida al probar que el producto de los términos constantes de dos polinomios lineales es igual al término constante en el producto de los polinomios.

Para probar el cálculo correcto de un producto interno, reemplazamos los polinomios con polinomios vectoriales y reemplazamos la multiplicación de polinomios escalares con el producto interno de polinomios vectoriales.

Todo lo demás permanece igual.

## El algoritmo
El objetivo es que el probador convenza al verificador de que $A$ es un compromiso con $\mathbf{a}$ y $\mathbf{b}$, $V$ es un compromiso con $v$, y que $\langle \mathbf{a}, \mathbf{b} \rangle = v$ sin revelar $\mathbf{a}$, $\mathbf{b}$ o $v$.

### Configuración
El probador y el verificador acuerdan los *vectores base* $\mathbf{G}$ y $\mathbf{H}$ con los que el probador puede asignar los vectores y el punto de curva elíptica $B$ a los términos de cegamiento.

### Probador
El probador genera los términos ciegos $\alpha$, $\beta$, $\gamma$, $\tau_1$ y $\tau_2$ y calcula:

$$
\begin{align}
A &= \langle\mathbf{a},\mathbf{G}\rangle + \langle\mathbf{b},\mathbf{H}\rangle+\alpha B\\
S &= \langle\mathbf{s}_L,\mathbf{G}\rangle + \langle\mathbf{s}_R,\mathbf{H}\rangle+\beta B\\
V &= vG + \gamma B \\
T_1 &= \langle\mathbf{a},\mathbf{s}_R\rangle + \langle\mathbf{b},\mathbf{s}_L\rangle + \tau_1B\\
T_2 &= \langle\mathbf{s}_L,\mathbf{s}_R\rangle G + \tau_2B
\end{align}$$

Observe que esta vez los coeficientes lineales $\mathbf{s}_L$ y $\mathbf{s}_R$ son vectores en lugar de escalares. El probador transmite $(A, S, V, T_1, T_2)$ al verificador. Después de que el verificador responde con una $u$ aleatoria, el probador evalúa $\mathbf{l}(x)$, $\mathbf{r}(x)$ y su producto interno $\mathbf{t}(x)$.

$$
\begin{align*}
\mathbf{l}_u &= \mathbf{a} + \mathbf{s}_Lu \\
\mathbf{r}_u &= \mathbf{b} + \mathbf{s}_Ru \\
t_u &= v + (\langle\mathbf{a},\mathbf{s}_R\rangle + \langle\mathbf{b},\mathbf{s}_L\rangle)u + \langle\mathbf{s}_L,\mathbf{s}_R\rangle u^2\\
\pi_{lr} &=\alpha+\beta u\\
\pi_t &= \gamma + \tau_1u + \tau_2u^2\\
\end{align*}
$$

### Paso de verificación final
Primero, el verificador verifica que $t_u$ sea la variable interna producto de $\mathbf{l}_u$ y $\mathbf{r}_u$ evaluados en $u$.

$t_u \stackrel{?}{=} \langle \mathbf{l}, \mathbf{r} \rangle$

Esto debería ser válido si el verificador es honesto, porque el producto interno de los polinomios evaluados en $u$ es el mismo que el producto interno de los polinomios vectoriales $\mathbf{l}_x$ y $\mathbf{r}_x$ evaluados en $x = u$.

En segundo lugar, el verificador comprueba que $A$ y $S$ sean compromisos con los términos constantes y lineales de $\mathbf{l}$ y $\mathbf{r}$ respectivamente.

$A + Su \stackrel{?}{=} \langle \mathbf{l}_u, \mathbf{G} \rangle + \langle \mathbf{r}_u, \mathbf{H} \rangle + \pi_{lr} B$

Recuerde que $A$ y $S$ son compromisos con los términos constantes y lineales de $\mathbf{l}$ y $\mathbf{r}$ y $\pi_{lr}$ es la suma de los términos cegadores en $A$ y $S$.

Finalmente, el verificador comprueba que $t_u$ es la evaluación del polinomio cuadrático asignado a $V, T_1, T_2$:

$t_u \stackrel{?}{=} V + T_1 u + T_2 u^2 + \pi B$

## Mejora del tamaño de la prueba
Cuando el probador envía $(\mathbf{l}, \mathbf{r}, t, T_1, T_2, \pi)$, envía más de $2n$ elementos (la longitud de $\mathbf{l}$ y $\mathbf{r}$), lo cual no es sucinto.

En los siguientes capítulos aprenderemos a reducir el tamaño de la prueba. En concreto, es posible crear una prueba de tamaño $\log n$ de que un producto interno es correcto.

## Resumen
Hemos descrito un protocolo que demuestra que $A$ es un compromiso con $\mathbf{a}$ y $\mathbf{b}$, $V$ es un compromiso con $v$, y que $\langle \mathbf{a}, \mathbf{b} \rangle = v$ sin revelar $\mathbf{a}$, $\mathbf{b}$ o $v$. Sin embargo, el tamaño de la prueba es lineal, ya que $\mathbf{l}$ y $\mathbf{r}$ en $(\mathbf{l}, \mathbf{r}, t, T_1, T_2, \pi_{lr},\pi_t)$ tienen cada uno un tamaño $n$.

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*
