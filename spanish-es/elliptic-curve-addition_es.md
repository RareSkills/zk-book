# Suma de puntos de Curva Elíptica

Este artículo describe cómo funciona la suma de curvas elípticas sobre números reales.

La criptografía utiliza curvas elípticas sobre campos finitos, pero las curvas elípticas son más fáciles de conceptualizar en un plano cartesiano real. Este artículo está dirigido a programadores e intenta lograr un equilibrio entre ser demasiado matemático y demasiado impreciso.

## Definición teórica de conjuntos de curvas elípticas
El [conjunto](https://www.rareskills.io/post/set-theory) de puntos en una curva elíptica forma un grupo bajo la suma de puntos de curva elíptica.

Con suerte, si has estado siguiendo nuestra [introducción a la teoría de grupos](rareskills.io/post/group-theory-and-coding), entonces realmente entendiste la mayor parte de esto, además de qué es la “suma de puntos”. Pero esa es la belleza del álgebra abstracta, ¿no? No necesitas saber qué es eso, y aún así entiendes la oración anterior.

Las curvas elípticas son una familia de curvas que tienen la fórmula

$$ y^2 = x^3 + ax + b $$

Dependiendo del valor de a y b que elijas, obtendrás una curva que se parece a alguna de las siguientes:

![Curvas elípticas](https://static.wixstatic.com/media/935a00_26f928a28e2b424690c1e3df172f783a~mv2.png/v1/fill/w_1480,h_632,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/935a00_26f928a28e2b424690c1e3df172f783a~mv2.png)

Un punto en una curva elíptica es un Par $(x, y)$ que satisface $y² = x³ + ax + b$ para $a$ y $b$ dados.

Por ejemplo, el punto $(3, 6)$ está en la curva $y² = x³ + 9$ porque $6² = 3³ + 9$. En términos de teoría de grupos, $(3, 6)$ es un miembro del conjunto definido por $y² = x³ + 9$. Como estamos tratando con números reales, el conjunto tiene cardinalidad infinita.

La idea aquí es que podemos tomar dos puntos de este conjunto, hacer un operador binario y obtendremos otro punto que también está en el conjunto. Es decir, es un par $(x, y)$ que también se encuentra en la curva.

**En lugar de pensar en las curvas elípticas como un gráfico, piense en ellas como un conjunto infinito de puntos. Los puntos están en el conjunto si y solo si satisfacen la ecuación de la curva elíptica.**

Una vez que vemos estos puntos como un conjunto, verlos como un grupo no es un misterio. Simplemente tomamos dos puntos y producimos un tercero de acuerdo con las reglas de un grupo.

Específicamente, para ser un grupo, el conjunto de puntos debe tener:

- un operador binario que sea cerrado y asociativo, es decir, que produzca otro punto en el conjunto
- el conjunto debe tener un elemento de identidad $I$
- cada punto en el conjunto debe tener un inverso tal que cuando los dos se combinen con el operador binario, el resultado sea $I$

## Las curvas elípticas forman un grupo abeliano bajo la adición

Aunque no sabemos cómo funciona el operador binario, sí sabemos que toma dos puntos $(x, y)$ en la curva y devuelve otro punto en la curva. Debido a que el operador es cerrado, sabemos que el punto será de hecho una solución válida para la ecuación de la curva elíptica, no un punto en otro lugar.

También sabemos que este operador binario es asociativo (y conmutativo, según el encabezado de la sección).

Entonces, dados tres puntos en la curva elíptica $A$, $B$ y $C$ (o $(x_a, y_a)$, $(x_b, y_b)$ y $(x_c, y_c)$ si lo prefiere), sabemos que lo siguiente es cierto:

- $(A ⊕ B) ⊕ C = A ⊕ (B ⊕ C)$
- $A ⊕ B = B ⊕ A$

Uso $⊕$ porque sabemos que este operador binario no es una suma en ningún sentido normal, sino un operador binario (de nuevo, recuerde que, según la teoría de conjuntos, un operador binario toma dos elementos de un conjunto y devuelve otro elemento de un conjunto; cómo lo hace no es central para la definición).

También sabemos que tiene que haber un elemento identidad en alguna parte. Es decir, cualquier punto $(x, y)$ que caiga en la curva se combina con el elemento identidad, el resultado es el mismo punto $(x, y)$ sin cambios.

Y como se trata de un grupo y no de un monoide, cada punto debe tener una inversa tal que $P ⊕ P⁻¹ = I$, donde $I$ es el elemento identidad.

### El elemento identidad

Intuitivamente, podríamos pensar que $(0, 0)$ o $(1, 1)$ son el elemento identidad, ya que algo así suele estar en otros grupos, pero se puede ver en los gráficos anteriores que esos puntos generalmente no se encuentran en la curva. Como no pertenecen al conjunto de puntos en $y² = x³ + ax + b$, no son parte del grupo.

Pero recordemos que, según la teoría de conjuntos, podemos definir operadores binarios como queramos sobre conjuntos definidos arbitrariamente. Esto nos permite añadir un elemento especial que técnicamente no está en la curva pero que, por definición, es el elemento identidad.

Me gusta pensar en el elemento identidad como "el punto que está en ninguna parte" porque si combinas la nada con cualquier punto real, nada cambia. Es molesto que los matemáticos llamen a este punto, el elemento identidad, "el punto en el infinito".

Un momento, ¿no se supone que este punto satisface $y² = x³ + ax + b$? La nada (o el infinito) no es un valor válido para $(x, y)$.

Ahh, pero recuerda, ¡podemos definir conjuntos como queramos! Definimos el conjunto que forma la curva elíptica como puntos en la curva elíptica y el punto de la nada.

Porque los operadores binarios son solo subconjuntos de un producto cartesiano (una relación), y podemos definir la relación como queramos. Podemos tener tantas declaraciones “if” chapuceras en nuestra aritmética como queramos y aun así seguir las leyes de grupo.

## La suma es cerrada.

Sin pérdida de generalidad, tomemos la curva elíptica

$$ y² = x³ + 10 $$

Para ilustrar cómo se intersecan las líneas en las curvas elípticas, dibujemos una línea casi vertical $y = 10x$

(Podría ser 1000x para hacerla más vertical, pero obtendríamos inestabilidad numérica como verás más adelante)

Obtenemos el siguiente conjunto de gráficos.

![Curva elíptica con una línea dibujada a través de ella](https://static.wixstatic.com/media/935a00_fe30b49a14b448b2a306925812e052f5~mv2.png/v1/fill/w_1480,h_960,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/935a00_fe30b49a14b448b2a306925812e052f5~mv2.png)

Resulta que, aunque parezca que la línea violeta ($y = 10x$) sube más rápido que la curva azul ($y² = x³ + 10$), siempre se cruzarán.

Si nos alejamos lo suficiente, podemos ver la intersección. Esto es cierto en general.

**Siempre que x no sea "perfectamente vertical", si cruza dos puntos de la curva, siempre cruzará un tercero.** Dos de esos puntos podrían ser el mismo punto si uno de los puntos de intersección es un punto tangente.

El "si intersectamos dos puntos" es importante. Si desplazamos nuestra línea violeta hacia la izquierda para que no cruce el "giro en U" de la curva elíptica, entonces sólo se cruzará en un punto

Otra forma de entenderlo:

**Si una línea recta cruza una curva elíptica exactamente en dos puntos, y ninguno de los puntos de intersección son intersecciones tangentes, entonces debe ser perfectamente vertical.**

Podrías elaborar una prueba algebraica a partir de las fórmulas anteriores, pero creo que el argumento geométrico es más intuitivo.

Te recomiendo que te detengas aquí y dibujes algunas curvas y líneas elípticas y te convenzas de esto visualmente.

Nuestra excepción para las líneas verticales en realidad hace que los elementos inversos e identidades encajen perfectamente.

**La inversa de un punto de una curva elíptica es el negativo del valor y del par.** Es decir, la inversa de $(x, y)$ es $(x, -y)$ y viceversa. Dibujar una línea a través de dichos puntos crea una línea perfectamente vertical.

El elemento de identidad es el "punto en el infinito" al que aludimos antes, es simplemente el punto "allá arriba" cuando dibujamos una línea vertical.

### Grupo abeliano

El hecho de que los puntos de la curva elíptica sean un grupo bajo nuestro principio "2 puntos siempre dan como resultado un tercero excepto por la identidad" hace que su naturaleza conmutativa sea obvia.

Cuando elegimos dos puntos, solo hay otro tercer punto. No se pueden obtener cuatro intersecciones en una curva elíptica. Como solo tenemos una solución posible, entonces está claro que $A ⊕ B = B ⊕ A$.

## Por qué la suma de curvas elípticas invierte el eje x

Pasamos por alto un detalle muy importante en la última sección, porque realmente merece una sección propia.

En su forma actual, tiene un error si agregamos dos puntos donde la intersección ocurre en el medio.

![Intersección de 3 puntos a través de una curva elíptica](https://static.wixstatic.com/media/935a00_cffa7b60afd8486f8cc2f97de8b07f17~mv2.png/v1/fill/w_1480,h_812,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/935a00_cffa7b60afd8486f8cc2f97de8b07f17~mv2.png)

Usando nuestras definiciones anteriores, lo siguiente debe ser verdadero

$$
\begin{align*}
A ⊕ B &= C \\
A ⊕ C &= B \\
B ⊕ C &= A
\end{align*}
$$

Con un poco de álgebra, derivaremos una contradicción

$$
\begin{align*}
(B ⊕ C) ⊕ B &= C \\
B ⊕ C &= \mathsf{inv}(B) ⊕ C \\
B &= \mathsf{inv}(B)
\end{align*}
$$

Esto dice que $B$ es igual a su inverso. Pero $B$ no es el elemento identidad (que es el único elemento que puede ser el inverso de sí mismo), por lo que tenemos una contradicción.

Afortunadamente, hay una manera de solucionar esto. Simplemente defina la suma de puntos como el tercer punto *volteado sobre el eje y*. Nuevamente, se nos *permite hacer esto* porque los operadores binarios se pueden definir como queramos, solo nos preocupamos de que nuestras definiciones satisfagan las leyes de grupo.

A continuación se muestra gráficamente la forma correcta de sumar puntos de una curva elíptica

![Suma de puntos de una curva elíptica](https://static.wixstatic.com/media/935a00_47a61dc12ed54c2b9a36415cceea5b54~mv2.png/v1/fill/w_1255,h_1228,al_c,q_90,enc_auto/935a00_47a61dc12ed54c2b9a36415cceea5b54~mv2.png)

## Fórmula para la suma

Usando algo de álgebra y dados dos puntos

$$
\begin{align*}
P₁ &= (x₁, y₁) \\
P₂ &= (x₂, y₂)
\end{align*}
$$

Se puede obtener la forma de calcular $P₃ = (x₃, y₃)$ donde $P₃ = P₁ ⊕ P₂$ usando la siguiente fórmula.

$$
\begin{align*}
\lambda &= \frac{y₂ - y₁}{x₂ - x₁} \\
x₃ &= \lambda² - x₁ - x₂ \\
y₃ &= \lambda(x₃ - x₁) - y₁
\end{align*}
$$

### Demostración algebraica de conmutatividad y asociatividad

Como tenemos una ecuación en forma cerrada, podemos demostrar algebraicamente que $T⊕U = U⊕T$ dados los puntos $T$ y $U$.

Lo hacemos de la siguiente manera:

$$\begin{align*}
P &= T ⊕ U \\
Q &= U ⊕ T \\
P &= Q
\end{align*}$$

```python
var('y_t', 'y_u', 'x_t', 'x_u')
lambda_p = (y_u - y_t)/(x_u - x_t)
x_p = lambda_p^2 - x_t - x_u
y_p = (lambda_p*(x_t - x_p) - y_t)

lambda_q = (y_t - y_u)/(x_t - x_u)
x_q = lambda_q^2 - x_u - x_t
y_q = (lambda_q*(x_u - x_q) - y_u)
```

Aquí hay una captura de pantalla de la ejecución del código anterior en Jupyter Notebook y la impresión del resultado. El sistema de álgebra computacional necesita un poco de persuasión, pero podemos ver claramente `x_q == x_p` y `y_q == y_p`.

![Demostración algebraica de la conmutatividad y la asociatividad](https://static.wixstatic.com/media/935a00_fb8599e0572c4987b88525005917b394~mv2.png/v1/fill/w_1246,h_1140,al_c,q_90,enc_auto/935a00_fb8599e0572c4987b88525005917b394~mv2.png)

$P = Q$ para todos los valores de $(x_t, y_t)$ y $(x_u, y_u)$. Obtenemos un error de división por cero si $x_t = x_u$, pero esto significa que son el mismo punto y eso es obviamente conmutativo.

Podemos utilizar técnicas similares para demostrar la asociatividad, pero desafortunadamente esto es extremadamente complicado, por lo que remitimos al lector interesado a otra [prueba de asociatividad](https://www.scirp.org/journal/paperinformation.aspx).

## Las curvas elípticas cumplen con la propiedad de grupo abeliano

Veamos que las curvas elípticas cumplen con la propiedad de grupo.

1. El operador binario es cerrado. Se interseca con un tercer punto en la curva o con el punto en el infinito (identidad). Tenemos la garantía de obtener un tercer punto válido cuando intersecamos dos puntos. El operador binario es asociativo.
2. El grupo tiene un elemento identidad.
3. Cada punto tiene un inverso.
4. El grupo es abeliano porque A ⊕ B = B ⊕ A

Un operador binario debe aceptar todos los pares posibles del conjunto. ¿Qué sucede si el par es el mismo elemento, es decir, A ⊕ A?

## Multiplicación de puntos: sumando un punto consigo mismo

Pensemos en esto en términos límite. Sumar un punto consigo mismo es como acercar dos puntos infinitesimalmente hasta que se convierten en el mismo punto. Cuando ocurre esta convergencia, la pendiente de la línea será tangente a la curva.

Por lo tanto, sumar un punto consigo mismo es simplemente tomar la derivada en ese punto, obtener la intersección y luego invertir el eje $y$.

La siguiente imagen demuestra gráficamente $A ⊕ A = 2A$.

![Multiplicación de puntos en una curva elíptica](https://static.wixstatic.com/media/935a00_61ed6a7a5ba14b53a95cf5c16e54f3f5~mv2.png/v1/fill/w_1230,h_1228,al_c,q_90,enc_auto/935a00_61ed6a7a5ba14b53a95cf5c16e54f3f5~mv2.png)

### Atajo para la multiplicación de puntos

¿Qué sucede si queremos calcular $1000A$ en lugar de $2A$? Parecería que se trata de una operación $\mathcal{O}(n)$, pero no lo es.

Debido a la asociatividad, podemos escribir $1000A$ como

$$1000A = 512A ⊕ 256A ⊕ 128A ⊕ 64A ⊕ 32A ⊕ 8A$$

$512A$ (y los otros términos) se pueden calcular rápidamente porque 512 es simplemente $A$ duplicado 9 veces.

Por lo tanto, en lugar de hacer 1000 operaciones, podemos hacerlo en 14 (9 para calcular 512, almacenar en caché los resultados intermedios y luego 5 sumas).

En realidad, esta es una propiedad importante cuando llegamos a la criptografía:

*Podemos multiplicar eficientemente un punto de una curva elíptica por un entero grande de manera eficiente.*

## Detalles de implementación de la suma

No es demasiado difícil derivar la fórmula para la suma de puntos usando álgebra simple. Cuando intersectamos dos puntos, conocemos la pendiente y los puntos por los que pasa, por lo que podemos calcular el punto de intersección.

Prefiero no hacerlo aquí porque no quiero perderme en un montón de manipulaciones simbólicas.

El poder de la teoría de grupos es que no nos importa cómo se ve esa manipulación simbólica. Sabemos que si hacemos nuestro operador binario en dos puntos, obtendremos otro punto en nuestro conjunto, y nuestro conjunto sigue las leyes del grupo.

Si lo piensas de esa manera, las curvas elípticas son mucho más fáciles de entender.

En lugar de intentar comprender las curvas elípticas de manera aislada desde cero, estudiamos un montón de otros grupos algebraicos y luego transferimos ese conocimiento e intuición a las curvas elípticas.

Los números racionales bajo la suma son un grupo. Los números enteros módulo primo son un grupo bajo la multiplicación. Las matrices de determinante distinto de cero bajo la multiplicación son un grupo.

Si se realiza el operador binario, se obtiene otro elemento en el conjunto. El grupo tiene un elemento identidad y cada elemento tiene un inverso. Se cumple la ley asociativa. Con todo eso en mente, no debería importarle lo que el operador ⊕ esté haciendo detrás de escena.

En mi opinión, si intentas entender las matemáticas de las curvas elípticas de forma aislada de los principios básicos de la teoría de grupos, lo estás haciendo de la manera difícil. Es mucho más fácil entenderlas en el contexto de sus parientes.

Eso hace que la experiencia de aprendizaje sea más fluida.

### La manipulación algebraica es en realidad solo una suma asociativa.

Sea $P$ un punto de la curva elíptica. ¿Qué sucede si hacemos algo como esto?

$$(a + b)P + cP = aP + (a + c)P$$

Al principio, puede parecer extraño que podamos hacer eso, porque si tratamos de visualizar lo que está sucediendo con la curva elíptica, seguramente nos perderemos.

Recuerda, lo que parece una multiplicación es en realidad un punto que se suma consigo mismo repetidamente, así que esto es lo que sucede en realidad cuando lo miramos como un grupo

$$\underbrace{(a + b)P + cP}_{((a + b + c)P)} = \underbrace{aP + (b + c)P}_{(a + b + c)P}$$

$$
\begin{align*}
(a + b + c)P &= (a + b + c)P \\
(aP + bP) + cP &= aP + (bP + cP) \\
(a + b)P + cP& = aP (b + c)P
\end{align*}
$$

La "multiplicación" escalar no es "distributiva" en el sentido en que pensaríamos en el álgebra normal. Es solo una forma abreviada de reorganizar el orden en el que sumamos P a sí mismo.

En realidad, simplemente sumamos $P$ a sí mismo $(a + b + c)$ veces. El orden en que lo hacemos no importa debido a la asociatividad.

Por lo tanto, cuando se ve una manipulación como esa, nuestro grupo no obtuvo de repente un operador binario de multiplicación, es solo una abreviatura engañosa.

## Curvas elípticas en cuerpos finitos

Si hiciéramos curvas elípticas sobre números reales para una aplicación real, serían muy inestables numéricamente porque el punto de intersección podría requerir muchos decimales para calcularse.

En realidad, todo lo hacemos con [aritmética modular](https://www.rareskills.io/post/finite-fields).

Pero no perdemos nada de la intuición que hemos adquirido anteriormente al hacer esto.

## Obtenga más información con RareSkills

Este material es de nuestro curso de conocimiento cero, consulte allí para obtener más información.

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*