# Álgebra Abstracta

El álgebra abstracta es el estudio de los conjuntos que tienen uno o más operadores sobre ese conjunto. Para nuestros propósitos, sólo nos interesan los operadores binarios.

Si tenemos conjuntos y un operador binario sobre ese conjunto, podemos categorizar esos conjuntos basándonos en cómo se comporta el operador binario, y qué elementos se permite (o se espera) que estén en el conjunto.

Los matemáticos tienen una palabra para cada tipo posible de comportamiento del operador binario sobre el conjunto. Como programadores aplicados, nos preocupamos por el Grupo (de la Teoría de Grupos) en particular, pero vamos a ir avanzando de forma incremental. El grupo es sólo un tipo de animal en este gran zoo. Así que en lugar de estudiar el grupo de forma aislada, vamos a estudiar el grupo en su contexto más amplio de estructuras algebraicas relacionadas (es decir, conjuntos con un operador binario).

El álgebra abstracta es un campo enorme, pero nuestro objetivo aquí es entender claramente lo que es un *Grupo* porque eso se usa en todas partes en Zero Knowledge Proofs. Podríamos dar una definición ahora mismo:

*Un Grupo es un conjunto con un operador binario que es cerrado, asociativo, tiene un elemento identidad, y donde cada elemento tiene un inverso.*

Pero eso no sería muy ilustrativo. Es más útil entender los grupos en su relación con el campo más amplio del Álgebra Abstracta.

## Magma

Un Magma es un conjunto con un operador binario cerrado. Eso es todo.

Un Magma es definitivamente algo que entiendes intuitivamente como programador. Ahora tienes una palabra para definirlo.

Como ejemplo, consideremos que nuestro conjunto sean todos los enteros positivos y que nuestro operador binario sea $x^y$. Tenga en cuenta que no permitimos números negativos porque si $y$ es negativo, obtenemos una fracción.

Evidentemente, la salida estará en el espacio de los números enteros. Nuestra función es un subconjunto del producto cartesiano $(\mathbb{Z}\times\mathbb{Z})\times\mathbb{Z}$.

Curiosamente, este ejemplo no es conmutativo ni asociativo. Puedes convencerte de ello eligiendo valores para a, b, y c en el código python de abajo.

```python
assert a ** (b ** c) != (a ** b) ** c
assert a ** b != b ** a
```

Pero no nos importa. Un Magma es uno de los tipos menos restrictivos de *estructuras algebraicas*. Lo único que importa es que el operador binario sea cerrado. Todo lo demás es válido.

Una estructura algebraica es un conjunto con una colección de operaciones sobre ese conjunto. Para nuestros propósitos, la única operación que nos importa es un operador binario.

## Semigrupo

Un Semigrupo es un Magma donde el operador binario debe ser asociativo.

Todos los Semigrupos son Magmas, pero no todos los Magmas son Semigrupos.

En otras palabras, un Semigrupo es un conjunto con un operador binario que es cerrado y asociativo.

Sea nuestro conjunto (infinito) el conjunto de todas las posibles cadenas no vacías del alfabeto tradicional a, b, c, ..., x, y, z. Por ejemplo, “az”, “programador”, “cero”, “asdfghjk”, “foo” y “bar” están todas en este conjunto.

Sea nuestro operador binario la concatenación de cadenas. Esto es cerrado, porque produce otra cadena en el conjunto.

Observa que si conmutamos “foo” y “bar”, la cadena de salida no será la misma, es decir, “foobar” y “barfoo”. Sin embargo, eso no importa. Tanto “foobar” como “barfoo” son miembros del conjunto, por lo que el operador binario “concatenar” es cerrado. Como tenemos un conjunto con un operador binario cerrado y asociativo, el conjunto de todas las cadenas bajo concatenación es un Semigrupo.

**Ejercicio:** Comprueba por ti mismo que concatenar “foo”, “bar”, “baz” en ese orden es asociativo. Recuerda, asociativo significa $(A \square B) \square C = A \square (B \square C)$, donde $\square$ es el operador binario del Semigrupo.

**Ejercicio:** Pon un ejemplo de un Magma y un Semigrupo. El Magma no debe ser un Semigrupo. No utilices los ejemplos anteriores. Esto significa que debes pensar en un operador binario que sea cerrado pero no asociativo.

## Monoide

Un Monoide es un Semigrupo con un elemento identidad.

Awww sí, este es el mismo Monoide de «Una mónada es un monoide en la categoría de endofunctores».

![Math meme about monad tutorials](https://static.wixstatic.com/media/935a00_bd9a8814842b4359b63050555a1c1c95~mv2.png/v1/fill/w_500,h_991,al_c,q_90,enc_auto/935a00_bd9a8814842b4359b63050555a1c1c95~mv2.png)

Si miramos la [documentación del monoide](https://typelevel.org/cats/typeclasses/monoid.html) en la librería Cats para Scala, vemos estas definiciones explícitamente:

```scala
trait Semigroup[A] {
    def combine(x: A, y: A): A
}

trait Monoid[A] extends Semigroup[A] {
    def empty: A
}
```

La librería Cats simplemente se refiere a la «identidad» como `empty` y al operador binario como `combine`. El hecho de que Monoid extends Semigroup muestra que un Monoid es un Semigrupo con el requisito de que tiene un "vacío" (identidad).

El fragmento anterior no lo muestra, pero se requiere que combine sea asociativo.

Un semigrupo sólo tiene un operador binario sin restricciones, excepto que la salida sea del mismo tipo (`A`) que las entradas (`x` e `y`).

Por ejemplo, la suma de números enteros positivos sin cero es un semigrupo, pero si se incluye el cero, se convierte en un monoide.

Un *elemento identidad* significa que si haces un operador binario con el elemento identidad y otro elemento $a$ , obtienes $a$ . En el ejemplo de la suma 8 + 0 = 8, donde 0 es el elemento identidad. Si nuestro operador binario fuera la multiplicación, entonces el elemento identidad sería 1, ya que al multiplicar por 1 obtenemos el mismo número.

Si nuestro conjunto fuera el conjunto de todas las matrices de 2x2, el elemento identidad sería la matriz identidad

$$
\begin{bmatrix}
1&0\\
0&1\\
\end{bmatrix}
$$

### Conjuntos de conjuntos sobre la unión y la intersección

Algo que extrañamente estuvo ausente de nuestra discusión anterior sobre conjuntos fue la discusión sobre la unión y la intersección de conjuntos. Se trata de operadores binarios, y ahora es un buen momento para introducirlos.

Si tomamos la unión de dos conjuntos $\set{1,2,3,4}$ y $\set{3,4,5,6}$, se obtiene $\set{1,2,3,4,5,6}$. Si se toma la intersección de $\set{1,2,3,4}$ y $\set{3,4,5,6}$ se obtiene $\set{3, 4}$ .

Debe quedar claro que ambos operadores son asociativos.

Si definimos nuestro dominio como el conjunto de todos los conjuntos finitos de números enteros, entonces los operadores binarios unión e intersección son cerrados porque su resultado es un conjunto de números enteros.

La unión de conjuntos tiene un elemento de identidad en este dominio: el conjunto vacío $\set{}$. Si se toma la unión de un conjunto con el conjunto vacío, se obtiene el conjunto original, es decir, $A \cup \set{} = A$.

Por lo tanto, el conjunto de todos los conjuntos *finitos* de números enteros sobre la unión es un Monoide.

Sin embargo, en el conjunto de todos los posibles conjuntos finitos de enteros bajo intersección ($\cap$), es un Semigrupo -- ningún conjunto finito funcionará como la identidad. Pero si ampliamos este conjunto para incluir ℤ sí mismo -- es decir, nuestro conjunto es $\{\text{todos los conjuntos finitos de enteros}\}\cup\mathbb{\{Z\}}$ bajo la intersección, entonces eso es ser un Monoide, como $\mathbb{Z}$ es el elemento identidad.

Si se siente como que hemos «hackeado» el elemento de identidad, es que lo hemos hecho.

Veremos más adelante que las curvas elípticas utilizan un truco como este e incluyen un punto especial llamado «punto en el infinito» para mantener la coherencia con las leyes algebraicas. La cuestión es que tenemos que tener muy claro cuál es nuestro elemento de identidad si decimos que un conjunto es un Monoide sobre algún operador binario.

Como otro ejemplo, podríamos decir que nuestro conjunto son todos los enteros positivos bajo adición, con el elemento adicional $\text{mug}$. Definimos $\text{mug} + x = x$ y $x + \text{mug} = x$. Como arquitectos de los sistemas, podemos hacer que nuestro conjunto consista en lo que queramos, y que el operador binario se comporte como queramos. Sin embargo, el operador binario debe ser cerrado, asociativo, y el conjunto debe tener un elemento identidad para que esa estructura algebraica de datos sea un Monoide.

Si restringimos el dominio a todos los subconjuntos de $\set{0,1,2,3,4,5}$ entonces la intersección se convierte claramente en un Monoide porque el elemento identidad sería $\set{0,1,2,3,4,5}$, ya que cualquier conjunto de enteros que se intersecte con él producirá el otro conjunto, es decir, $A ∩ \set{0,1,2,3,4,5} = A$. Por ejemplo, $\set{1,3,4} ∩ \set{0,1,2,3,4,5} = \set{1,3,4}$.

Llegados a este punto debe quedar claro que la categoría de una estructura algebraica para un operador binario dado es muy sensible al dominio del conjunto.

**Ejercicio:** Sea nuestro operador binario la función `min(a,b)` sobre enteros. ¿Se trata de un magma, semigrupo o monoide? ¿Y si restringimos el dominio a enteros positivos (cero o mayor)? ¿Qué pasa con el operador binario `max(a,b)` sobre esos dos dominios?

**Ejercicio:** Sea nuestro conjunto todos los números binarios de 3 bits (un conjunto de cardinalidad 8). Los operadores binarios posibles son y, o, xor, nor, xnor y nand. Es evidente que esto es cerrado porque la salida es un número binario de 3 bits. Para cada operador binario, determinar si el conjunto bajo ese operador binario es un Magma, Semigrupo o Monoide.

## Grupo - La estrella del espectáculo

Un Grupo es un Monoide donde cada elemento tiene un inverso.

O para ser explícitos, es un conjunto con cuatro propiedades:

1. El operador binario es cerrado (Magma)
2. El operador binario es asociativo (Semigrupo)
3. El conjunto tiene un elemento identidad (Monoide)
4. Todo elemento tiene un inverso

Es decir, para cualquier elemento $a$ en el conjunto $A$ , existe un $a′$ tal que $a \square a' = i$ donde $i$ es el elemento identidad y $\square$ es el operador binario. Dicho más matemáticamente, sería:

$$
\forall a \in A \space\space \exists a' \in A: a\square a' = i
$$

Aquí, $\square$ es el operador binario del conjunto.

Es bastante incorrecto decir «el conjunto tiene un inverso». Para ser precisos, cada elemento tiene otro elemento en el conjunto que es el inverso de ese elemento.

Usando números enteros con suma, el elemento identidad es cero (porque si sumas cero, obtienes el mismo número), y el inverso de un número entero es ese número entero con el signo invertido (por ejemplo, el inverso de 5 es -5 y el inverso de -7 es 7).

Volviendo a la sensibilidad del dominio, la suma sobre enteros positivos no es un grupo porque no puede haber elementos inversos.

Aquí tienes una tabla para entenderlo

| dominio de conjuntos                | operador binario | estructura algebraica | razón                              |
| ----------------------------------- | ---------------- | --------------------- | ---------------------------------- |
| enteros positivos distintos de cero | suma             | Semigrupo             | sin identidad                      |
| enteros positivos incluyendo cero   | suma             | Monoide               | tiene identidad, no tiene inversos |
| todos los enteros                   | suma             | Grupo                 | cada elemento tiene un inverso     |

Nótese que «inverso» no tiene sentido si el conjunto no tiene identidad, porque la definición de inverso es hacer un operador binario de un elemento con su inverso produce la identidad.

**Ejercicio:** ¿Por qué las cadenas bajo concatenación no pueden ser un conjunto?
**Ejercicio:** Los polinomios bajo adición satisfacen la propiedad de grupo. Demuestra que es así mostrando que cumple todas las propiedades que definen un grupo.

Desgraciadamente, nuestro tutorial debe terminar aquí, porque la teoría elemental de grupos es el tema de otro capítulo.

Pero ahora tienes mucho contexto para entender qué es un grupo, ¡aunque apenas lo hayamos discutido aquí!

### Unas palabras sobre la conmutatividad

No es necesario que ninguna de las estructuras algebraicas de datos anteriores sea conmutativa. Si lo son, decimos que son abelianas sobre su operador binario. Un grupo abeliano significa que el operador binario no es sensible al orden.

Abeliano significa que el operador binario es conmutativo.

Pero di abeliano, sonarás más inteligente.

El tecnicismo es que normalmente no decimos "la suma es abeliana" sino "el grupo es abeliano sobre la suma".

## Subconjuntos  de nuevo

Volvamos a lo que aprendimos al principio. Magmas, Semigrupos, Monoides y Grupos son conjuntos que tienen un operador binario cerrado. Un operador binario no es más que un mapa desde todos los pares ordenados del producto cartesiano del conjunto consigo mismo hacia sí mismo.

Los Grupos son un subconjunto de los Monoides, los Monoides son un subconjunto de los Semigrupos, los Semigrupos son un subconjunto de los Magmas, y los Magmas son un subconjunto de los conjuntos en general. Todo Grupo es también un Magma o un conjunto, pero un Magma no es necesariamente un Grupo.

Los "conjuntos" son fáciles de conceptualizar, pero cuando empezamos a hablar de grupos y otras estructuras algebraicas, es fácil empezar a perderse. Los grupos son muy importantes en nuestro estudio de la criptografía. Recuérdalo:

**Los grupos son conjuntos con un operador binario que sigue cuatro reglas.**

Además, es hora de liberar tu mente de la "suma" y la "multiplicación" como forma principal de combinar cosas.

Se nos permite tomar un producto cartesiano de un conjunto (que puede ser cualquier cosa) consigo mismo y, a continuación, asignar ese conjunto de pares ordenados de nuevo al conjunto. Se trata de un operador binario. Si sigue la construcción anterior, entonces es cerrado.

## El vocabulario matemático no tiene por qué asustarnos

Antes de empezar este tutorial, la frase:

"El conjunto de cadenas sobre el operador binario concatenación de cadenas es un Semigrupo o un Monoide dependiendo de la presencia o ausencia de la cadena vacía en el conjunto"

probablemente no tenía sentido.

Puede que aún tengas que traducirlo en tu cabeza, como la mayoría de los que aprenden un segundo idioma, pero te das cuenta de que en realidad está metiendo mucha información en un espacio minúsculo.

¿Podría decir esa frase sin las matemáticas? Claro que sí, pero necesitaría al menos 500 palabras para hacerlo con claridad. En realidad, merece la pena entender lo que significan esos términos. A la larga nos ahorrará muchos problemas.

Lo que lo hace genial es que hay una plétora de teoremas sobre Grupos que nos permiten hacer afirmaciones sobre el grupo *sin entender cómo funciona el operador binario del grupo bajo el capó*. Esto es muy parecido al polimorfismo en la programación orientada a objetos o a los rasgos en los lenguajes funcionales. Te ocultan los detalles de implementación y te permiten centrarte en el alto nivel. Esto es muy potente.

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*