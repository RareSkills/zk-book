# Creación de una prueba de conocimiento cero a partir de un R1CS

Dado un [circuito aritmético](https://www.rareskills.io/post/arithmetic-circuit) codificado como un [sistema de restricciones de rango 1](https://www.rareskills.io/post/rank-1-constraint-system), es posible crear una prueba de conocimiento cero de tener un testigo, aunque no sea sucinta. Este artículo describe cómo lograrlo.

Una prueba de conocimiento cero para un R1CS se logra convirtiendo el vector testigo en [puntos de curva elíptica de campo finito](https://www.rareskills.io/post/elliptic-curves-finite-fields) y reemplazando el producto de Hadamard con un [emparejamiento bilineal](https://www.rareskills.io/post/bilinear-pairing) para cada fila.

Dado un sistema de restricciones de rango 1 donde cada matriz tiene $n$ filas y $m$ columnas, lo escribimos como

$$\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}=\mathbf{O}\mathbf{a}$$

Donde $\mathbf{L}$, $\mathbf{R}$, $\mathbf{O}$ son matrices con $n$ filas y $m$ columnas, y $\mathbf{a}$ es el vector de wintess (que contiene una asignación satisfactoria para cada una de las señales en el circuito aritmético). $\mathbf{a}$ tiene 1 columna y $m$ filas y $\circ$ es la multiplicación elemento por elemento (producto de Hadamard).

En forma expandida, se ve como

$$
\left[ \begin{array}{ccc}
l_{1,1} & \cdots & l_{1,m} \\
\vdots & \ddots & \vdots \\
l_{n,1} & \cdots & l_{n,m}
\end{array} \right]
\left[ \begin{array}{c}
a_1 \\
\vdots \\
a_m
\end{array} \right]
\left[ \begin{array}{ccc}
r_{1,1} & \cdots & r_{1,m} \\
\vdots & \ddots & \vdots \\
r_{n,1} & \cdots & r_{n,m}
\end{array} \right]
\circ
\left[ \begin{array}{ccc}
r_{1,1} & \cdots & r_{1,m} \\
\vdots & \ddots & \vdots \\
r_{n,1} & \cdots & r_{n,m}
\end{array} \right]
=
\left[ \begin{array}{ccc}
o_{1,1} & \cdots & o_{1,m} \\
\vdots & \ddots & \vdots \\
o_{n,1} & \cdots & o_{n,m}
\end{array} \right]
\left[ \begin{array}{c}
a_1 \\
\vdots \\
a_m
\end{array} \right]
$$

$$
=
\left[ \begin{array}{ccc}
a_1 l_{1,1} + \cdots + a_m l_{1,m} \\
\vdots \\
a_1 l_{n,1} + \cdots + a_m l_{n,m}
\end{array} \right]
\circ
\left[ \begin{array}{ccc}
a_1 r_{1,1} + \cdots + a_m r_{1,m} \\
\vdots \\
a_1 r_{n,1} + \cdots + a_m r_{n,m}
\end{array} \right]
=
\left[ \begin{array}{ccc}
a_1 o_{1,1} + \cdots + a_m o_{1,m} \\
\vdots \\
a_1 o_{n,1} + \cdots + a_m o_{n,m}
\end{array} \right]
$$

$$
=
\left[ \begin{array}{ccc}
\sum_{i=1}^m a_i l_{1,i} \\
\sum_{i=1}^m a_i l_{2,i} \\
\vpuntos \\
\sum_{i=1}^m a_i l_{n,i}
\end{matriz} \right]
\circ
\left[ \begin{matriz}{ccc}
\sum_{i=1}^m a_i r_{1,i} \\
\sum_{i=1}^m a_i r_{2,i} \\
\vpuntos \\
\sum_{i=1}^m a_i r_{n,i}
\end{matriz} \right]
=
\left[ \begin{matriz}{ccc}
\sum_{i=1}^m a_i o_{1,i} \\
\sum_{i=1}^m a_i o_{2,i} \\
\vpuntos \\
\sum_{i=1}^m a_i o_{n,i}
\end{array} \right]
$$

$$
=
\left[ \begin{array}{ccc}
\sum_{i=1}^m a_i l_{1,i} \sum_{i=1}^m a_i r_{1,i} = \sum_{i=1}^m a_i o_{1,i} \\
\sum_{i=1}^m a_i l_{2,i} \sum_{i=1}^m a_i r_{2,i} = \sum_{i=1}^m a_i o_{2,i} \\
\vdots \\
\sum_{i=1}^m a_i l_{n,i} \sum_{i=1}^m a_i r_{n,i} = \sum_{i=1}^m a_i o_{n,i}
\end{array} \right]
$$

En esta configuración, podemos demostrar a un Verificador de que tenemos un vector testigo $\mathbf{a}$ que satisface el R1CS simplemente dándoles el vector $\mathbf{a}$, pero con el inconveniente obvio de que no es una prueba de conocimiento cero.

## Algoritmo de prueba de conocimiento cero para un R1CS.
Si "encriptamos" el vector testigo multiplicando cada entrada con $G₁$ o $G₂$, ¡la matemática seguirá funcionando correctamente!

Para entender esto, considere que si realizamos la multiplicación de matrices

$$
\begin{bmatrix}
1 & 2 \\
3 & 4 \\
\end{bmatrix}
\begin{bmatrix}
4 \\
5
\end{bmatrix}
= \begin{bmatrix}
14 \\
32
\end{bmatrix}
$$

y también

$$
\begin{bmatrix}
1 & 2 \\
3 & 4 \\
\end{bmatrix}
\begin{bmatrix}
4G_1 \\
5G_1
\end{bmatrix}
= \begin{bmatrix}
14G_1 \\
32G_1
\end{bmatrix}
$$

Los logaritmos discretos de los dos puntos de la curva elíptica en la segunda multiplicación de matrices son el mismo valor como los elementos de la primera multiplicación de matrices.

En otras palabras, cada vez que multiplicamos el vector columna por una fila en la matriz cuadrada, realizamos dos multiplicaciones de puntos de curva elíptica y una suma de curva elíptica.

### Notación para curvas elípticas
Decimos que $[aG₁]₁$ es un punto de curva elíptica $\mathbb{G}_1$ creado a partir de la multiplicación del elemento de campo $a$ por $\mathbb{G}_1$. Decimos que $[aG₂]₂$ es un punto de curva elíptica $\mathbb{G}_2$ generado al multiplicar a con el generador $G₂$. Debido al problema del logaritmo discreto, no podemos extraer $a$ dado $[aG₁]₁$ o $[aG₂]₂$. Dado un punto $A \in \mathbb{G}_1$ y $B \in \mathbb{G}_2$, decimos que el emparejamiento de los dos puntos es $A\bullet B$.

### Pasos del demostrador
Encriptemos nuestro vector $\mathbf{a}$ multiplicando cada entrada por el punto generador $G₁$ para producir el punto de curva elíptica $[aᵢG₁]₁$.

Para la matriz $\mathbf{L}$, hacemos lo siguiente:

$$
\left[ \begin{array}{ccc}
l_{1,1} & \cdots & l_{1,m} \\
\vdots & \ddots & \vdots \\
l_{n,1} & \cdots & l_{n,m}
\end{array} \right]
\left[ \begin{array}{c}
[a_1 G_1]_1 \\
\vdots \\
[a_m G_1]_1
\end{array} \right]
=
\left[ \begin{array}{ccc}
l_{1,1}[a_1 G_1]_1 & + \cdots + & l_{1,m}[a_m G_1]_1 \\
\vdots & \ddots & \vdots \\
l_{n,1}[a_1 G_1]_1 & + \cdots + & l_{n,m}[a_m G_1]_1
\end{array} \right]
=
\left[ \begin{array}{c}
\sum_{i=1}^m l_{1,i}[a_i G_1]_1 \\
\sum_{i=1}^m l_{2,i}[a_i G_1]_1 \\
\vdots \\
\sum_{i=1}^m l_{n,i}[a_i G_1]_1
\end{array} \right]
$$

En previsión de que el producto Hadamard se convierta en una lista de pares de curvas elípticas, podemos usar $G₂$ puntos para cifrar también el vector $\mathbf{a}$ de modo que el verificador pueda realizar el pareo.

$$
\left[ \begin{array}{ccc}
r_{1,1} & \cdots & r_{1,m} \\
\vdots & \ddots & \vdots \\
r_{n,1} & \cdots & r_{n,m}
\end{array} \right]
\left[ \begin{array}{c}
[s_1 G_2]_2 \\
\vdots \\
[s_m G_2]_2
\end{array} \right]
=
\left[ \begin{array}{ccc}
r_{1,1}[a_1 G_2]_2 & + \cdots + & r_{1,m}[a_m G_2]_2 \\
\vdots & \ddots & \vdots \\
r_{n,1}[a_1 G_2]_2 & + \cdots + & r_{n,m}[a_m G_2]_2
\end{array} \right]
=
\left[ \begin{array}{c}
\sum_{i=1}^m r_{1,i}[a_i G_2]_2 \\
\sum_{i=1}^m r_{2,i}[a_i G_2]_2 \\
\vdots \\
\sum_{i=1}^m r_{n,i}[a_i G_2]_2
\end{array} \right]
$$

Después de esta operación, tenemos una única columna de puntos de la curva elíptica en $G₁$ que se originan a partir de la multiplicación $\mathbf{L}\mathbf{a}$ y una única columna de puntos $G₂$ a partir de $\mathbf{R}\mathbf{a}$.

El siguiente paso ingenuo sería cifrar el vector $\mathbf{a}$ con $G₁₂$ puntos para que el verificador pueda emparejar el resultado de $\mathbf{L}\mathbf{a}$ con $\mathbf{R}\mathbf{a}$ para ver si es igual a $\mathbf{O}\mathbf{a}$, pero los $G₁₂$ puntos son masivos, por lo que preferiríamos que el verificador empareje los $\mathbf{O}\mathbf{a}$ puntos de la curva elíptica en $G₁$ y luego empareje cada entrada con un punto $G₂$. El emparejamiento con un punto $G₂$ es, en cierto sentido, "multiplicar por uno" pero convertir el punto $G₁$ en un punto $G₁₂$.

El probador luego entrega el vector $G₁$ y el vector $G₂$ al verificador.

### Paso de verificación
Por lo tanto, el paso de verificación se convierte en

$$

\left[ \begin{array}{c}
\sum_{i=1}^m l_{i,1}[a_i G_1]_1 \\
\sum_{i=1}^m l_{i,1}[a_i G_1]_1 \\
\vdots \\
\sum_{i=1}^m l_{i,1}[a_i G_1]_1
\end{array} \right]
\begin{matrix}
\bullet \\
\bullet \\
\vdots \\
\bullet
\end{matrix}
\left[ \begin{array}{c}
\sum_{i=1}^m r_{i,1}[a_i G_2]_2 \\
\sum_{i=1}^m r_{i,1}[a_i G_2]_2 \\
\vpuntos \\
\sum_{i=1}^m r_{i,1}[a_i G_2]_2
\end{matriz} \right]

\stackrel{?}{=}
\left[ \begin{matriz}{c}
\sum_{i=1}^m o_{i,1}[a_i G_1]_1 \\
\sum_{i=1}^m o_{i,1}[a_i G_1]_1 \\
\vpuntos \\
\sum_{i=1}^m o_{i,1}[a_i G_1]_1
\end{matriz} \right]
\begin{matriz}
\bullet \\
\bullet \\
\vpuntos \\
\bullet
\end{matriz}
\left[ \begin{matriz}{c}
G_2 \\
G_2 \\
\vpuntos \\
G_2
\end{array} \right]
$$

$$
=
\begin{array}{c}
\sum_{i=1}^m l_{i,1}[a_i G_1]_1\bullet \sum_{i=1}^m r_{i,1}[a_i G_2]_2 \\
\sum_{i=1}^m l_{i,2}[a_i G_1]_1\bullet \sum_{i=1}^m r_{i,2}[a_i G_2]_2 \\
\vdots \\
\sum_{i=1}^m l_{i,n}[a_i G_1]_1\bullet \sum_{i=1}^m r_{i,n}[a_i G_2]_2
\end{array}
\stackrel{?}{=}
\begin{array}{c}
\sum_{i=1}^m o_{i,1}[a_i G_1]_1\bullet G_2 \\
\sum_{i=1}^m o_{i,2}[a_i G_1]_1\bullet G_2 \\
\vdots \\
\sum_{i=1}^m o_{i,n}[a_i G_1]_1 \bullet G_2
\end{array}
$$

Los vectores anteriores de $G₁₂$ elementos serán iguales elemento a elemento si y solo si el demostrador ha proporcionado un testigo válido.

Bueno, casi. Llegaremos a eso en una sección siguiente.

Primero debemos mencionar un detalle de implementación importante

### Entradas públicas
Si nuestra afirmación de conocimiento es "Sé que $x$ es tal que $x³ + 5x + 5 = y$ donde $y = 155$", entonces nuestro vector testigo probablemente se verá así:

$$[1, y, x, v]$$

donde $v = x^2$. En este caso, necesitamos que $[1, y]$ sea público. Para lograrlo, simplemente no ciframos los dos primeros elementos del testigo. El verificador verificará las salidas públicas y luego cifrará las entradas públicas multiplicándolas por un punto $G₁$ o $G₂$ para que la fórmula de verificación no cambie.

### Cómo lidiar con un probador malintencionado.
Debido a que los vectores están cifrados, el verificador no puede saber inmediatamente si el vector de $\mathbb{G}₁$ puntos cifra los mismos valores que el vector de $\mathbb{G}₂$ puntos.

Es decir, el probador proporciona $\mathbf{a}G_1$ y $\mathbf{a}G_2$. Dado que el verificador no conoce los logaritmos discretos del vector de puntos, ¿cómo sabe el verificador que el vector de $\mathbb{G}₁$ puntos tiene los mismos logaritmos discretos que el vector de $\mathbb{G}₂$ puntos?

El verificador puede comprobar la igualdad de los logaritmos discretos (sin conocerlos) emparejando ambos vectores de puntos con un vector del generador *opuesto* y viendo que los puntos $\mathbb{G}_{12}$ resultantes son iguales. Específicamente,

$$
\begin{bmatrix}
a_1G_1 \\
a_2G_1 \\
\vdots \\
a_mG_1
\end{bmatrix}
\begin{matrix}
\bullet \\
\bullet \\
\vdots \\
\bullet
\end{matrix}
\begin{bmatrix}
G_2 \\
G_2 \\
\vdots \\
G_2
\end{bmatrix}
\stackrel{?}{=}
\begin{bmatrix}
a_1G_2 \\
a_2G_2 \\
\vdots \\
a_mG_2
\end{bmatrix}
\begin{matrix}
\bullet \\
\bullet \\
\vdots \\
\bullet
\end{matrix}
\begin{bmatrix}
G_1 \\
G_1 \\
\vdots \\
G_1
\end{bmatrix}
$$

## Este algoritmo es principalmente académico
Este algoritmo es muy ineficiente para el verificador. Si las matrices en el R1CS son grandes (y para algoritmos interesantes, lo serán), entonces el verificador tiene que hacer muchos emparejamientos y adiciones de curvas elípticas. La adición de curvas elípticas es bastante rápida, pero los emparejamientos de curvas elípticas son lentos (y cuestan mucho gas en Ethereum).

Sin embargo, es bueno ver que en esta etapa, las pruebas de conocimiento cero son posibles, y si tienes un buen conocimiento de las operaciones de curvas elípticas (y no has olvidado tu aritmética de matrices), no son difíciles de entender.

### Hacer que esta técnica sea verdaderamente de conocimiento cero
Tal como está ahora, nuestro vector testigo no se puede descifrar, sin embargo, se puede adivinar. Si un atacante (alguien que intenta descubrir el testigo no cifrado) utiliza alguna información auxiliar para hacer una suposición fundamentada sobre el testigo, puede comprobar su trabajo multiplicando el vector de testigo adivinado por los generadores de puntos de la curva elíptica y viendo si el resultado es el mismo que los vectores de testigo del probador.

Aprenderemos a defendernos de las suposiciones de testigos en nuestra cobertura de [Groth16](https://www.rareskills.io/post/groth16).

Además, tenga en cuenta que nadie hace el algoritmo descrito en el mundo real, ya que es demasiado ineficiente. Sin embargo, si lo implementa, le ayudará a practicar la implementación de aritmética de curva elíptica significativa y a construir una prueba de conocimiento cero (casi) funcional de extremo a extremo.

Puede ver un ejemplo de implementación del algoritmo descrito aquí por Obront en [este repositorio](https://github.com/zobront/homerolled-zk).

## Obtenga más información con RareSkills
Este material es de nuestro [Curso de conocimiento cero](https://www.rareskills.io/zk-bootcamp).

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*
