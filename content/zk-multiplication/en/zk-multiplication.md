# Zero Knowledge Multiplication

Using the polynomial commitment scheme from the previous chapter, a prover can show they have three polynomials $l(x)$, $r(x)$, and $t(x)$ and prove that $t(x) = l(x)r(x)$.


The prover commits two linear (degree 1) polynomials $l(x)$, $r(x)$ a quadratic (degree 2) polynomial $t(x)$, and sends the commitments to the verifier. The verifier responds with a random value $u$, and the prover evaluates $l_u = l(u)$, $r_u = r(u)$, and $t_u = t(u)$ along with the proofs of evaluation $\pi_l, \pi_r, \pi_t$. The verifier asserts that all the polynomials were evaluated properly and that $t_u = l_ur_u$.

The Schwartz-Zippel lemma states that probability of two non-equal polynomials having equal value (intersecting) at a random point is less than $d/p$ where $d$ is the maximum degree of the two polynomials. If $d << p$ where $p$ is the order of the field, then the probability of $u$ being an intersection point of two non-equal polynomials is negligible.

To get a sense of scale, $d$ in this case is 2, but the curve order of our elliptic curves (and hence the order of the field) is about $2^{253}$. So if $t(x) \neq l(x)r(x)$, then the probability of $t_u = l_ur_u$ is $1/2^{252}$ which is vanishingly small. If $t_u = l_ur_u$, it is overwhelmingly likely that $t(x) = l(x)r(x)$.

We now describe the algorithm in detail, and then show an optimization.

## Steps to prove knowledge of polynomial multiplication
### Setup
The prover and verifier agree on elliptic curve points $G$ and $B$ with an unknown discrete log relationship (i.e. the points are chosen randomly).

### Prover commits to $l(x)$, $r(x)$, and $t(x)$
The prover creates three polynomials:

$$
\begin{align*}
l(x) &= a + s_Lx \\
r(x) &= b + s_Rx \\
t(x) &= l(x)r(x) = (a + s_Lx)(b + s_Rx) = ab+(as_R+bs_L)x+s_Ls_Rx^2\\
\end{align*}
$$

So they need to produce a total of 7 Pedersen commitments for each of the coefficients, which will require five blinding terms $\alpha_0, \alpha_1, \beta_0, \beta_1, \tau_0, \tau_1, \tau_2$

$$
\begin{align*}
L_0&=aG + \alpha_0B &&\text{// constant coefficient of }l(x)\\
L_1&=s_LG + \alpha_1B &&\text{// linear coefficient of }l(x)\\
\\
R_0&=bG + \beta_0B &&\text{// constant coefficient of }r(x)\\
R_1&=s_RG + \beta_1B &&\text{// linear coefficient of }r(x)\\
\\
T_0 &= abQ + \tau_0 B &&\text{// constant coefficient of }t(x)\\
T_1 &=(as_R + bs_L)G + \tau_1B &&\text{// linear coefficient of }t(x)\\
T_2 &= s_Ls_RG + \tau_2B &&\text{// quadratic coefficient of }t(x)
\end{align*}
$$

The prover sends $(L_0, L_1, R_0, R_1, T_0, T_1, T_2)$ to the verifier.

### Verifier generates random scalar $u$
... and sends the field element $u$ to the prover.

### Prover evaluates the three polynomials and creates three proofs

The prover plugs in $u$ to the polynomials and computes the sum of the blinding terms of the polynomial coefficient commitments when $u$ is applied.

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

The prover sends the values $(l_u, r_u, t_u, \pi_l, \pi_r, \pi_t)$ to the verifier. Note that these are all field elements, not elliptic curve points.

### Final verification step
The prover checks that each of the polynomials were evaluated correctly and that the evaluation of $t(u)$ is the product of the evaluation of $l(u)$ and $r(u)$

$$
\begin{align*}
l_uG + \pi_l B &\stackrel{?}= L_0+L_1u &&\text{// Check that }l(u) \text{ was evaluated correctly}\\
r_uG + \pi_r B &\stackrel{?}= R_0+R_1u &&\text{// Check that }r(u) \text{ was evaluated correctly}\\
t_uG + \pi_t B &\stackrel{?}= T_0+T_1u+T_2u^2&&\text{// Check that }t(u) \text{ was evaluated correctly}\\
t_u &\stackrel{?}= l_ur_u &&\text{// Check that }t(u)=l(u)r(u)
\end{align*}
$$

When we expand the terms, we see they balance if the prover was honest:
$$
\begin{align*}
\underbrace{(a + s_Lu)}_{l_u}G + \underbrace{(\alpha_0 + \alpha_1u)}_{\pi_l} B &\stackrel{?}= \underbrace{(aG + \alpha_0B)}_{L_0}+\underbrace{(s_LG + \alpha_1B)}_{L_1}u \\
\underbrace{(b + s_Ru)}_{r_u}G + \underbrace{(\beta_0 + \beta_1u)}_{\pi_r} B &\stackrel{?}= \underbrace{(bG + \beta_0B)}_{R_0}+\underbrace{(s_RG + \beta_1B)}_{R_1}u \\
\underbrace{(ab + (as_R + bs_l)u + s_Ls_Ru^2)}_{t_u}G + \underbrace{(\tau_0 + \tau_1u + \tau_2u^2)}_{\pi_t} B &\stackrel{?}= \underbrace{(abG + \tau_0 B)}_{T_0}+\underbrace{(as_R + bs_L+ \tau_1B)}_{T_1}u+\underbrace{(s_Ls_R+ \tau_2B)}_{T_2}u^2 \\
t_u &\stackrel{?}= l_ur_u 
\end{align*}
$$


## Optimization: sending fewer commitments
In the first step, the prover sends 7 elliptic curve points and in the final step, the verifier checks 4 equalities. We can improve the algorithm to only send 5 elliptic curve points and do 3 equality checks.

This is done by putting the constant coefficients of $l(x)$ and $r(x)$ into a single commitment and the linear coefficients of those polynomials into a separate commitment. This is similar to how we would commit a vector. We are in a sense committing the constant coefficients as a vector and the linear coefficients as another vector.

### Setup
During the setup, we now need 3 elliptic curve points: $G$, $H$, and $B$.

### Polynomial commitment
$$
\begin{align*}
A &= aG + bH + \alpha B &&\text{// commit the constant terms}\\
S &= s_LG + s_RH  + \beta B &&\text{// commit the linear terms}\\
T_0 &= abG + \tau_0 B &&\text{// commit to the constant coefficient} \\
T_1 &=(as_R + bS_L)G + \tau_1B &&\text{// linear coefficient of }t(x)\\
T_2 &= s_Ls_RG + \tau_2B &&\text{// quadratic coefficient of }t(x)
\end{align*}
$$

Note that the coefficients of $l(x)$ are applied to $G$ and the coefficients of $r(x)$ are applied to $H$. The prover sends $(A, S, T_0, T_1, T_2)$ to the verifier, who responds with $u$.

### Polynomial evaluation
$$
\begin{align*}
l_u &= a + s_Lu\\
r_u &= b + s_Ru\\
t_u &= ab + (as_R + bs_l)u + s_Ls_Ru^2\\
\pi_{lr} &= \alpha + \beta u  \\
\pi_t &= \tau_0 + \tau_1u + \tau_2u^2
\end{align*}
$$

$l_u$, $r_u$, $t_u$, and $\pi_t$ are computed as before, but the proof of evaluations for $l(x)$ and $r(x)$ are combined into one. This is acceptable to do since the blinding terms are separated by $u$, which the prover does not control.

### Final verification
$$
\begin{align*}
A + Su &\stackrel{?}= l_uG + r_uH+\pi_{lr}B \\
t_uG + \pi_tB &\stackrel{?}= T_0 + T_1u + T_2u^2 \\
t_u &\stackrel{?}= l_ur_u
\end{align*}
$$

The check $A + Su \stackrel{?}= l_uG + r_uH+\pi_{lr}B$ expands to

$$
\underbrace{(aG + bH + \alpha B)}_A + \underbrace{(s_LG + s_RH + \beta B)u}_{Su} = \underbrace{(a + s_Lu)}_{l_u}G + \underbrace{(b + s_Ru)}_{r_u}H + \underbrace{(\alpha + \beta u)}_{\pi_{lr}}B
$$

With some rearranging on the left-hand-side, we can see the equality check simultaneously checks that both $l(x)$ and $r(x)$ were evaluated correctly.

$$
(a + s_Lu)G + (b + s_Ru)H + (\alpha + \beta u)B=\underbrace{(a + s_Lu)}_{l_u}G + \underbrace{(b + s_Ru)}_{r_u}H + \underbrace{(\alpha + \beta u)}_{\pi_{lr}}B
$$

## Zero Knowledge Multiplication
Our proof that we multiplied two polynomials together correctly to obtain a third can be used to prove that we multiplied two *scalars* together to obtain a third. No changes to the algorithm are necessary, only a minor change in semantics (how we interpret the commitments).

Let's say we want to prove that we carried out the multiplication $ab = v$.

### Problem statement
$A$ is a commitment to $a$ and $b$, and $V$ is a commitment to $v$ where $v = ab$. We wish to prove that $A$ and $V$ are committed as claimed without revealing $a$, $b$, or $v$.

### Solution
The high level idea is that a scalar can be turned into a polynomial by adding an arbitrarily chosen linear term, e.g. $a$ becomes $a + s_Lx$ and $b$ becomes $b + s_Rx$.

When the polynomials $a + s_Lx$ and $b + s_Rx$ are multiplied together, the multiplication of $ab$ happens "inside" the polynomial multiplication.

$$(a + s_Lx)(b + s_Rx) = \boxed{ab} + (as_R + bs_L)x + s_Ls_rx^2$$

Recall the prover begins the algorithm by sending commitments:

$$
\begin{align*}
A &= aG + bH + \alpha B &&\text{// commitment to }a\text{ and }b\\
S &= s_LG + s_RH  + \beta B &&\text{// commit the linear terms}\\
V &= abG + \tau_0 B &&\text{// commit the product V} \\
T_1 &=(as_R + bS_L)G + \tau_1B &&\text{// linear coefficient of }t(x)\\
T_2 &= s_Ls_RG + \tau_2B &&\text{// quadratic coefficient of }t(x)
\end{align*}
$$

We simply change the "interpretation" of $A$ from being the constant terms of the polynomials to the constants we are multiplied. We change $T_0$ to $V$ to reflect the change of interpretation as a commitment to $V$ in the multiplication we are trying to prove we did correctly, i.e. $v = ab$.
