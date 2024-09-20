# Homomorfismos por ejemplo

Existe un homomorfismo entre dos grupos si existe una *mapa que preserva la estructura* entre los dos grupos.

Supongamos que tenemos dos estructuras de datos algebraicos $(A,\square)$ y $(B, \blacksquare)$, donde el operador binario de $A$ es $\square$ y el operador binario de $B$ es $\blacksquare$.

Existe un homomorfismo de $A$ a $B$ si y solo si existe una función $\phi: A\rightarrow B$ tal que

$$
\phi(a_i \square a_j)=\phi(a_i)\blacksquare\phi(a_j)\space\space\forall a_i,a_j\in A
$$

En otras palabras, si $a_i \square a_j = a_k$, entonces $\phi(a_i) \blacksquare \phi(a_j) = \phi(a_k)$.

Tenga en cuenta que un homomorfismo es unidireccional. La función $\phi$ toma elementos en $A$ y los asigna a elementos en $B$. No tenemos requisitos sobre "ir hacia atrás".

Primero mostraremos algunos ejemplos simples, proporcionaremos algunas aclaraciones y luego proporcionaremos ejemplos más complejos.

## Ejemplos simples de homomorfismos

### Todos los números enteros bajo adición a todos los números enteros pares bajo adición

Sea $A$ el conjunto de todos los números enteros bajo adición y sea $B$ el conjunto de todos los números enteros pares bajo adición. Está claro que tanto $A$ como $B$ son grupos.

Sea $\phi(x)=2x$

Vemos que $\phi$ define un homomorfismo de $A$ a $B$ porque lo siguiente es cierto para cualquier par de enteros $a_i$ y $a_j$

$$
\begin{align*}
\phi(a_i+a_j)&=\phi(a_i)+\phi(a_j)\\
2(a_i+a_j)&=2(a_i)+2(a_j)
\end{align*}
$$

### Todas las cadenas bajo concatenación a todos los enteros cero o mayores

Por ejemplo, sea $A$ el Monoide de todas las cadenas (incluida la cadena vacía) bajo concatenación, y sea $B$ el Monoide de todos los enteros cero o mayores bajo adición.

Existe un homomorfismo de $A$ a $B$ porque existe una función $\phi$ que asigna cadenas a números enteros mayores o iguales a cero y conserva la siguiente propiedad

$$
\phi(a_i+a_j)=\phi(a_i)+\phi(a_j)
$$

En este caso, $\phi$ es la *longitud* de la cadena. Por ejemplo:

$$
\begin{align*}
\text{Raro}&\rightarrow 4\\
\text{Habilidades}&\rightarrow 6\\
\text{HabilidadesRaras}&\rightarrow 10\\
\end{align*}
$$

Aquí tenemos

$$
\begin{align*}
\phi(\text{Raro})&=4\\
\phi(\text{Habilidades})&=6\\
\phi(\text{HabilidadesRaras})&=10\\
\phi(\mathsf{concat}(\text{Raro},\text{Habilidades}))&=\phi(\text{Raro})+\phi(\text{Habilidades})\\
\end{align*}
$$

### Todos los números reales bajo suma a todas las matrices $n\times m$ de números reales bajo suma

Algunas Los homomorfismos pueden parecer bastante triviales una vez que se les toma la mano. Este es un ejemplo de un homomorfismo de este tipo. En este caso, nuestra función $\phi$ simplemente repite el número real $n\times m$ veces. Por ejemplo, si $n=3$ y $m=2$, entonces $\phi(8.8)$ sería:

$$
\begin{bmatrix}
8.8&8.8\\
8.8&8.8\\
8.8&8.8
\end{bmatrix}
$$

Por ejemplo, si $\phi(8.8 + 0.2)=\phi(8.8)+\phi(0.2)$ porque

$$
\begin{bmatrix}
9&9\\
9&9\\
9&9\\
\end{bmatrix}=
\begin{bmatrix}
8.8&8.8\\
8.8&8.8\\
8.8&8.8
\end{bmatrix}+
\begin{bmatrix}
0.2&0.2\\
0.2&0.2\\
0.2&0.2\\
\end{bmatrix}
$$

## Aclaraciones sobre homomorfismos

- $\phi$ debe funcionar con cada par posible de elementos de $A$ (incluidos pares del mismo elemento). Sin embargo, no necesita “acceder” a todos los elementos de $B$. Por ejemplo, un homomorfismo que mapea cada elemento en $A$ al elemento identidad en $B$ es un homomorfismo válido, pero no útil. Se llama *homomorfismo trivial*.
- Si elegimos dos conjuntos arbitrarios con un operador binario, no necesariamente existe un homomorfismo.
- Puede haber un homomorfismo de $A$ a $B$, pero no necesariamente de $B$ a $A$.
- Si existe un homomorfismo de $A$ a $B$ y de $B$ a $A$, y $\phi$ es la función de $A$ a $B$, la inversa de $\phi$ puede no ser necesariamente una función válida para el homomorfismo de $B$ a $A$

## Más ejemplos de homomorfismos

### Números enteros bajo la adición a potencias enteras de $b$ bajo la multiplicación

Supongamos que tenemos el grupo $A=(\mathbb{Z},+)$ (el conjunto de todos los números enteros bajo la adición) y el grupo $B$, que es el conjunto de todas las potencias enteras de $b$ bajo la multiplicación, es decir, $B=(b^i\space:\space i\in\mathbb{Z}, \times)$. Podemos fijar arbitrariamente $b=2$ para que el ejemplo sea más fácil de entender.

Existe un homomorfismo de $A$ a $B$, definido por $\phi(x)=b^x$. Según las reglas del álgebra,

$$
\begin{align*}
\phi(a_i+a_j)&=\phi(a_i)\times\phi(a_j)\\
b^{a_i + a_j}&=b^{a_i}b^{a_j}
\end{align*}
$$

Para entender por qué se cumple esta relación, considere que

$$
b^{a_i}=\underbrace{b\cdot b\cdot\dots\cdot b}_{{a_i} \text{ veces}}
$$

$$
b^{a_j}=\underbrace{b\cdot b\cdot\dots\cdot b}_{{a_j} \text{ veces}}
$$

$$
b^{a_i +a_j}=\underbrace{b\cdot b\cdot\dots\cdot b}_{{a_i} \text{ veces}}\cdot\underbrace{b\cdot b\cdot\puntos\cdot b}_{{a_j} \text{ veces}}
$$

$$
b^{a_i +a_j}=\underbrace{b\cdot b\cdot\dots\cdot b\cdot b\cdot b\dots\cdot b}_{{a_i+a_j} \text{ veces}}
$$

### Números enteros bajo la suma de potencias enteras de $b$ bajo la multiplicación módulo un número primo

### Matrices de $n\times m$ bajo la suma de números enteros bajo la suma

En este caso, $\phi$ simplemente suma todos los elementos de una matriz. Por qué esto funciona se deja como ejercicio para el lector.

### Matrices de $2\times2$ números enteros bajo la multiplicación a números enteros bajo la multiplicación

Hay un homomorfismo del primer al segundo Monoide porque $\phi$ es el *determinante* de la matriz y se cumple la siguiente regla:

$$
XY=Z\rightarrow\det(X)\det(Y)=\det(Z)
$$

donde $X,Y,Z$ son matrices de números enteros de $2\times2$. Por qué estas dos estructuras de datos algebraicos son Monoides y no grupos se deja como ejercicio para el lector.

### El grupo de los números racionales (excluidos los números racionales cuyo denominador es un múltiplo de $p$) a la suma módulo $p$

Este concepto ya se enseñó en nuestro artículo sobre [campos finitos](https://www.rareskills.io/post/finite-fields), pero no usamos el término “homomorfismo” para describirlo.

Sea $A$ el grupo de todos los números racionales cuyos denominadores no son múltiplos de $p$, bajo la suma. Sea $B$ el cuerpo finito módulo $p$.

Existe un homomorfismo del grupo $A$ al grupo $B$. $\phi$ es

$$
\phi(x) = \mathsf{numerador}(x)\times\mathsf{modular\_inverse}(\mathsf{denominador}(x)) \pmod p
$$

O en Python:

```python
p = 11
def phi(num, den):
    return num * pow(den, -1, p) % p
```

Por ejemplo:

- $1/3 + 3/5 = 14/15$
- $1/3$ es congruente con $6 \pmod {17}$
- $3/5$ es congruente con $4 \pmod {17}$
- $4 + 6\equiv10 \pmod {17}$
- $14/15\equiv 10 \pmod {17}$

Decir que $1/3$ es congruente con $6 \pmod {17}$ es equivalente a la afirmación $\phi(1/3)=6$.

### El Monoide de los números racionales (excluyendo los números racionales donde el denominador es un múltiplo de $p$) a la multiplicación módulo $p$ (excluyendo cero)

Usemos el mismo ejemplo que el anterior, pero con multiplicación. La función $\phi$ sigue siendo la misma.

- $1/3 * 3/5 = 1/5$
- $1/3$ es congruente con $6 \pmod {17}$
- $3/5$ es congruente con $4 \pmod {17}$
- $4 \times 6\equiv7 \pmod {17}$
- $1/5\equiv 7 \pmod {17}$

## Ejercicios para el lector

Encuentre un homomorfismo para los siguientes pares de estructuras de datos algebraicos. Si te quedas atascado (o simplemente no quieres resolver el problema), puedes buscar la respuesta en Google o consultar con un chatbot.

1. Números reales bajo adición a polinomios con coeficientes reales bajo adición.
2. Polinomios con coeficientes reales a números reales bajo adición. Pista: aunque esto parezca similar al problema 1, la función $\phi$ no tendrá ninguna relación con la respuesta del problema anterior.
3. Números reales positivos mayores que cero bajo multiplicación a todos los números reales bajo adición.

## Cifrado homomórfico

Si $\phi$ es computacionalmente difícil de invertir, entonces $\phi$ *cifra homomórficamente* los elementos de $A$.

Sea $A$ todos los números enteros bajo adición, y $B$ el grupo objetivo y $\blacksquare$ el operador binario de $B$.

### Adición con conocimiento cero, ejemplo 1
Supongamos que queremos demostrarle a un verificador que calculamos $2 + 3=5$. Le daríamos al verificador $(x, y, 5)$ donde $x=\phi(2), y= \phi(3)$ y el verificador verificaría que:

$$
x\blacksquare y \stackrel{?}=\phi(5)
$$

Tenga en cuenta que el cifrado homomórfico implica que el verificador conoce la función $\phi$.

### Adición con conocimiento cero, ejemplo 2
Un probador afirma: "Tengo dos números $a$ y $b$, y $b$ es cinco veces $a$". El probador envía $\phi(a)$ y $\phi(b)$ al verificador, y el verificador verifica que

$$\phi(a) + \phi(a) + \phi(a) + \phi(a) + \phi(a) = \phi(b)$$

Recuerde, "multiplicación" aquí no es el operador binario, es simplemente una forma abreviada de suma repetida.

En estos ejemplos, tenga en cuenta que no dijimos nada sobre qué son los elementos de $B$ o qué es $\blacksquare$. $B$ pueden ser objetos matemáticos aterradores, y $\blacksquare$ puede ser un operador matemático aterrador, pero *eso no importa*.

Esta es la belleza del álgebra abstracta: *no necesitamos saberlo*. Mientras tenga las propiedades que nos interesan, podemos razonar sobre su comportamiento incluso si no sabemos nada sobre la implementación.

## Motivación

Bien, genial; entendemos los grupos y los homomorfismos, pero ¿cómo nos ayuda esto? La razón por la que me tomé todo el esfuerzo de explicar esto es porque quiero que entiendas la siguiente afirmación:

“Los puntos de la curva elíptica en un cuerpo finito bajo la adición son un grupo cíclico finito y los números enteros bajo la adición son homomórficos a este grupo”.

Probablemente no sepas qué son los puntos de la curva elíptica o qué significa sumarlos, pero sí sabes:

1. El conjunto de puntos de la curva elíptica bajo la adición produce otro punto de la curva elíptica.
2. El operador binario que toma dos puntos de la curva elíptica y devuelve otro punto de la curva elíptica es asociativo.
3. El conjunto de puntos de la curva elíptica contiene un elemento identidad.
4. El grupo de la curva elíptica tiene un elemento identidad, que es único.
5. Cada punto de la curva elíptica tiene una inversa, de modo que sumar un punto y su inversa produce la identidad.
6. Debido a que el grupo es cíclico, cada punto de la curva elíptica se puede generar aplicando repetidamente el operador binario a algún elemento generador.
7. Debido a que el grupo de puntos de la curva elíptica es cíclico, también es un grupo abeliano.
8. Debido a que es un grupo finito, el orden es finito.
9. Debido al homomorfismo, tenemos una idea clara de cómo se comporta el operador binario para los puntos de la curva elíptica. Podemos usar el operador binario de punto de la curva elíptica para "sumar números enteros" en cierto sentido.

Aunque no sepas qué son los puntos de la curva elíptica, ¡ya sabes nueve cosas sobre ellos!

Así que, sean lo que sean estos extraños objetos "puntos de la curva elíptica", sabes que se comportan como los grupos que analizamos anteriormente y que tienen las mismas propiedades.

Lo creas o no, ya has recorrido el 90 % del camino para comprender las curvas elípticas. Es mucho más fácil entender las curvas elípticas si se entiende su similitud con otras estructuras conocidas que si se intenta comprender su matemática extraña desde el principio.

Esto es similar a que yo te diga que Ethereum utiliza "árboles Patricia Merkle" para almacenar el estado. Puede que no sepas qué es un "árbol Patricia" o un "árbol Merkle", pero sí sabes:

- Tiene una raíz.
- Probablemente puedas acceder a los elementos en tiempo logarítmico, o al menos esa es la intención.
- Algo útil se almacena en las hojas.
- Existe algún algoritmo para recorrer el árbol y acceder a una hoja que te interese.

Por lo tanto, cuando te digo que los puntos de la curva elíptica bajo la suma forman un grupo, ya deberías saber qué buscar cuando aprendas sobre ese tema.

Una vez más, los grupos no necesitan ser matemáticas lunares misteriosas. Has trabajado con grupos intuitivamente como programador. Ahora tienes una palabra concreta para describir este fenómeno recurrente.

Es mucho más eficiente decir "grupo" que decir "este es un conjunto con una forma de combinar elementos asociativamente y todos los elementos tienen bla, bla, bla".

Sé que esto puede parecer una gran digresión, pero créanme, comprender el "homomorfismo" nos permite describir de manera sucinta un concepto que veremos con regularidad. También será útil nuevamente cuando discutamos [Programas aritméticos cuadráticos](https://www.rareskills.io/post/quadratic-arithmetic-program). Los homomorfismos aparecen con frecuencia en el mundo de ZK.

Imagínense intentar discutir estructuras de datos de árboles sin una palabra para "raíces" u "hojas". Eso sería inmensamente frustrante.

## Resumen

Existe un homomorfismo de $A$ a $B$ **si y solo si** existe una función $\phi$ que toma un elemento de $A$ y devuelve un elemento de $B$ y $\phi(a_i \square a_j)=\phi(a_i)\blacksquare\phi(a_j)$ o todos los $a_i$ y $a_j$ en $A$, donde $\square$ es el operador binario de $A$ y $\blacksquare$ es el operador binario de $B$. **La existencia de $\phi$ es suficiente para que exista el homomorfismo.**

Los homomorfismos no son necesariamente bidireccionales. Solo se requiere que funcionen en una dirección, de $A$ a $B$.

Si $\phi: A \rightarrow B$ es computacionalmente difícil de invertir, entonces $\phi$ encripta homomórficamente los elementos de $A$. Eso significa que podemos validar afirmaciones sobre cálculos en $A$ usando elementos en $B$.

La buena noticia es que hemos terminado con nuestro tratamiento del álgebra abstracta y ahora tenemos una base sólida para pasar a las [curvas elípticas](https://www.rareskills.io/post/elliptic-curve-addition).

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*
