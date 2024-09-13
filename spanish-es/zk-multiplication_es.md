# Multiplicación de conocimiento cero

Usando el esquema de compromiso polinomial del capítulo anterior, un probador puede demostrar que tiene tres polinomios $l(x)$, $r(x)$ y $t(x)$ y probar que $t(x) = l(x)r(x)$.

El probador compromete dos polinomios lineales (de grado 1) $l(x)$, $r(x)$ y un polinomio cuadrático (de grado 2) $t(x)$, y envía los compromisos al verificador. El verificador responde con un valor aleatorio $u$, y el probador evalúa $l_u = l(u)$, $r_u = r(u)$ y $t_u = t(u)$ junto con las pruebas de evaluación $\pi_l, \pi_r, \pi_t$. El verificador afirma que todos los polinomios se evaluaron correctamente y que $t_u = l_ur_u$.

El lema de Schwartz-Zippel establece que la probabilidad de que dos polinomios no iguales tengan el mismo valor (se intersequen) en un punto aleatorio es menor que $d/p$, donde $d$ es el grado máximo de los dos polinomios. Si $d << p$, donde $p$ es el orden del campo, entonces la probabilidad de que $u$ sea un punto de intersección de dos polinomios no iguales es insignificante.

Para tener una idea de la escala, $d$ en este caso es 2, pero el orden de la curva de nuestras curvas elípticas (y, por lo tanto, el orden del campo) es aproximadamente $2^{253}$. Entonces, si $t(x) \neq l(x)r(x)$, entonces la probabilidad de $t_u = l_ur_u$ es $1/2^{252}$, que es extremadamente pequeña. Si $t_u = l_ur_u$, es abrumadoramente probable que $t(x) = l(x)r(x)$.

Ahora describimos el algoritmo en detalle y luego mostramos una optimización.

## Pasos para demostrar el conocimiento de la multiplicación de polinomios
### Configuración
El demostrador y el verificador coinciden en los puntos de la curva elíptica $G$ y $B$ con una relación logarítmica discreta desconocida (es decir, los puntos se eligen al azar).

### El probador se compromete con $l(x)$, $r(x)$ y $t(x)$
El probador crea tres polinomios:

$$
\begin{align*}
l(x) &= a + s_Lx \\
r(x) &= b + s_Rx \\
t(x) &= l(x)r(x) = (a + s_Lx)(b + s_Rx) = ab+(as_R+bs_L)x+s_Ls_Rx^2\\
\end{align*}
$$

Por lo tanto, deben producir un total de 7 compromisos de Pedersen para cada uno de los coeficientes, lo que requerirá cinco términos ciegos $\alpha_0, \alpha_1, \beta_0, \beta_1, \tau_0, \tau_1, \tau_2$

$$
\begin{align*}
L_0&=aG + \alpha_0B &&\text{// coeficiente constante de }l(x)\\
L_1&=s_LG + \alpha_1B &&\text{// coeficiente lineal de }l(x)\\
\\
R_0&=bG + \beta_0B &&\text{// coeficiente constante de }r(x)\\
R_1&=s_RG + \beta_1B &&\text{// coeficiente lineal de }r(x)\\
\\
T_0 &= abQ + \tau_0 B &&\text{// coeficiente constante de }t(x)\\
T_1 &=(as_R + bs_L)G + \tau_1B &&\text{// coeficiente lineal de }t(x)\\
T_2 &= s_Ls_RG + \tau_2B &&\text{// coeficiente cuadrático de }t(x)
\end{align*}
$$

El probador envía $(L_0, L_1, R_0, R_1, T_0, T_1, T_2)$ al verificador.

### El verificador genera un escalar aleatorio $u$
... y envía el elemento de campo $u$ al probador.

### El probador evalúa los tres polinomios y crea tres pruebas

El probador introduce $u$ en los polinomios y calcula la suma de los términos ciegos de los compromisos de coeficientes polinómicos cuando se aplica $u$.

$$
\begin{align*}
l_u &= a + s_Lu\\
r_u &= b + s_Ru\\
t_u &= ab + (as_R + bs_l)u + s_Ls_Ru^2\\
\\
\pi_l &= \alpha_0 + \alpha_1u \\
\pi_r &= \beta_0 + \beta_1u \\
\pi_t &= \tau_0 + \tau_1u + \tau_2u^2
\end{align*}
$$

El probador envía los valores $(l_u, r_u, t_u, \pi_l, \pi_r, \pi_t)$ al verificador. Tenga en cuenta que todos estos son elementos de campo, no puntos de curva elíptica.

### Paso final de verificación
El probador verifica que cada uno de los polinomios se evaluó correctamente y que la evaluación de $t(u)$ es el producto de la evaluación de $l(u)$ y $r(u)$

$$
\begin{align*}
l_uG + \pi_l B &\stackrel{?}= L_0+L_1u &&\text{// Verifica que }l(u) \text{ se evaluó correctamente}\\
r_uG + \pi_r B &\stackrel{?}= R_0+R_1u &&\text{// Verifica que }r(u) \text{ se evaluó correctamente}\\
t_uG + \pi_t B &\stackrel{?}= T_0+T_1u+T_2u^2&&\text{// Verifica que }t(u) \text{ se evaluó correctamente}\\
t_u &\stackrel{?}= l_ur_u &&\text{// Verifica que }t(u)=l(u)r(u)
\end{align*}
$$

Cuando desarrollamos los términos, vemos que se equilibran si el demostrador fue honesto:

$$
\begin{align*}
\underbrace{(a + s_Lu)}_{l_u}G + \underbrace{(\alpha_0 + \alpha_1u)}_{\pi_l} B &\stackrel{?}= \underbrace{(aG + \alpha_0B)}_{L_0}+\underbrace{(s_LG + \alpha_1B)}_{L_1}u \\
\underbrace{(b + s_Ru)}_{r_u}G + \underbrace{(\beta_0 + \beta_1u)}_{\pi_r} B &\stackrel{?}= \underbrace{(bG + \beta_0B)}_{R_0}+\underbrace{(s_RG + \beta_1B)}_{R_1}u \\
\underbrace{(ab + (as_R + bs_l)u + s_Ls_Ru^2)}_{t_u}G + \underbrace{(\tau_0 + \tau_1u + \tau_2u^2)}_{\pi_t} B &\stackrel{?}= \underbrace{(abG + \tau_0 B)}_{T_0}+\underbrace{(as_R + bs_L+ \tau_1B)}_{T_1}u+\underbrace{(s_Ls_R+ \tau_2B)}_{T_2}u^2 \\
t_u &\stackrel{?}= l_ur_u
\end{align*}
$$

## Optimización: enviar menos compromisos
En el primer paso, el probador envía 7 puntos de curva elíptica y en el paso final, el verificador verifica 4 igualdades. Podemos mejorar el algoritmo para enviar solo 5 puntos de curva elíptica y hacer 3 verificaciones de igualdad.

Esto se hace colocando los coeficientes constantes de $l(x)$ y $r(x)$ en un único compromiso y los coeficientes lineales de esos polinomios en un compromiso separado. Esto es similar a cómo comprometeríamos un vector. En cierto sentido, estamos comprometiendo los coeficientes constantes como un vector y los coeficientes lineales como otro vector.

### Configuración
Durante la configuración, ahora necesitamos 3 puntos de curva elíptica: $G$, $H$ y $B$.

### Compromiso polinomial
$$
\begin{align*}
A &= aG + bH + \alpha B &&\text{// compromete los términos constantes}\\
S &= s_LG + s_RH + \beta B &&\text{// compromete los términos lineales}\\
T_0 &= abG + \tau_0 B &&\text{// compromete el coeficiente constante} \\
T_1 &=(as_R + bS_L)G + \tau_1B &&\text{// coeficiente lineal de }t(x)\\
T_2 &= s_Ls_RG + \tau_2B &&\text{// coeficiente cuadrático de }t(x)
\end{align*}
$$

Tenga en cuenta que los coeficientes de $l(x)$ se aplican a $G$ y los coeficientes de $r(x)$ se aplican a $H$. El probador envía $(A, S, T_0, T_1, T_2)$ al verificador, quien responde con $u$.

### Evaluación polinómica
$$
\begin{align*}
l_u &= a + s_Lu\\
r_u &= b + s_Ru\\
t_u &= ab + (as_R + bs_l)u + s_Ls_Ru^2\\
\pi_{lr} &= \alpha + \beta u \\
\pi_t &= \tau_0 + \tau_1u + \tau_2u^2
\end{align*}
$$

$l_u$, $r_u$, $t_u$ y $\pi_t$ se calculan como antes, pero la prueba de las evaluaciones para $l(x)$ y $r(x)$ se combinan en una. Esto es aceptable ya que los términos cegadores están separados por $u$, que el demostrador no controla.

### Verificación final
$$
\begin{align*}
A + Su &\stackrel{?}= l_uG + r_uH+\pi_{lr}B \\
t_uG + \pi_tB &\stackrel{?}= T_0 + T_1u + T_2u^2 \\
t_u &\stackrel{?}= l_ur_u
\end{align*}
$$

La comprobación $A + Su \stackrel{?}= l_uG + r_uH+\pi_{lr}B$ se expande a

$$
\underbrace{(aG + bH + \alpha B)}_A + \underbrace{(s_LG + s_RH + \beta B)u}_{Su} = \underbrace{(a + s_Lu)}_{l_u}G + \underbrace{(b + s_Ru)}_{r_u}H + \underbrace{(\alpha + \beta u)}_{\pi_{lr}}B
$$

Si reorganizamos un poco el lado izquierdo, podemos ver que la comprobación de igualdad verifica simultáneamente que $l(x)$ y $r(x)$ se evaluaron correctamente.

$$
(a + s_Lu)G + (b + s_Ru)H + (\alpha + \beta u)B=\underbrace{(a + s_Lu)}_{l_u}G + \underbrace{(b + s_Ru)}_{r_u}H + \underbrace{(\alpha + \beta u)}_{\pi_{lr}}B
$$

## Multiplicación con conocimiento cero
Nuestra prueba de que multiplicamos dos polinomios juntos correctamente para obtener un tercero se puede utilizar para demostrar que multiplicamos dos *escalares* juntos para obtener un tercero. No es necesario realizar cambios en el algoritmo, solo un cambio menor en la semántica (cómo interpretamos los compromisos).

Digamos que queremos demostrar que realizamos la multiplicación $ab = v$.

### Enunciado del problema
$A$ es un compromiso con $a$ y $b$, y $V$ es un compromiso con $v$ donde $v = ab$. Queremos demostrar que $A$ y $V$ están comprometidos como se afirma sin revelar $a$, $b$ o $v$.

### Solución
La idea de alto nivel es que un escalar se puede convertir en un polinomio agregando un término lineal elegido arbitrariamente, por ejemplo, $a$ se convierte en $a + s_Lx$ y $b$ se convierte en $b + s_Rx$.

Cuando los polinomios $a + s_Lx$ y $b + s_Rx$ se multiplican entre sí, la multiplicación de $ab$ ocurre "dentro" de la multiplicación del polinomio.

$$(a + s_Lx)(b + s_Rx) = \boxed{ab} + (as_R + bs_L)x + s_Ls_rx^2$$

Recuerde que el demostrador comienza el algoritmo enviando compromisos:

$$
\begin{align*}
A &= aG + bH + \alpha B &&\text{// compromiso con }a\text{ y }b\\
S &= s_LG + s_RH + \beta B &&\text{// compromiso de los términos lineales}\\
V &= abG + \tau_0 B &&\text{// compromiso del producto V} \\
T_1 &=(as_R + bS_L)G + \tau_1B &&\text{// coeficiente lineal de }t(x)\\
T_2 &= s_Ls_RG + \tau_2B &&\text{// coeficiente cuadrático de }t(x)
\end{align*}
$$

Simplemente cambiamos la "interpretación" de $A$ de ser los términos constantes de los polinomios a las constantes por las que multiplicamos. Cambiamos $T_0$ por $V$ para reflejar el cambio de interpretación como un compromiso con $V$ en la multiplicación que estamos tratando de demostrar que hicimos correctamente, es decir, $v = ab$.

*Traducido al Español por **ARCADIO Garcia**, Septiembre 2024*
