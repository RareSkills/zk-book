# Polynomial Commitments Via Pedersen Commitments

A polynomial commitment is a mechanism by which a prover can convince a verifier a polynomial $p(x)$ has an evaluation $y = p(x)$ at point $x$ without revealing anything about $p(x)$. The sequence is as follows:

1. The prover sends to the verifier a commitment $C$, "locking in" their polynomial.
2. The verifier responds with a value $u$ they want the polynomial evaluated at.
3. The prover responds with $y$ and $\pi$, where $y$ is the evaluation of $p(u)$ and $\pi$ is proof that the evaluation was correct.
4. The verifier checks $C$, $u$, $y$, $\pi$ and accepts or rejects that the evaluation of the polynomial was valid.

This commitment scheme does not require a trusted setup. However, the communication overhead is $O(n)$ as the prover must send a commitment for each coefficient in their polynomial.

## Committing to the Polynomial
The prover can commit to the polynomial by creating a [Pedersen Commitment](https://www.rareskills.io/post/pedersen-commitment) of each coefficient. For a Pedersen Committment, the prover and verifier need to agree on two elliptic curve points with unknown discrete logs. We will use $G$ and $B$.

For example, if we have a polynomial

$$p(x) = c_0+c_1x+c_2x^2$$

we can create a Pedersen commitment for each coefficient. We will need three blinding terms $\gamma_0$, $\gamma_1$, $\gamma_2$. For convenience, any scalar used for blinding will use a lower-case Greek letter. We always use the elliptic curve point $B$ for the blinding term. Our commitments are produced as follows:

$$
\begin{align*}
C_0=c_0G+\gamma_0B \\
C_1=c_1G+\gamma_1B \\
C_2=c_2G+\gamma_2B \\
\end{align*}
$$

The prover sends the tuple $(C_0, C_1, C_2)$ to the verifier.

## Verifier chooses $u$
The verifier chooses their value for $x$ and sends that to the prover. We call that value $u$.

## Prover computes the proof
### Prover evaluates the polynomial
The prover computes the original polynomial as:

$$
y = p(u) = c_0 + c_1u + c_2u^2
$$

### Prover evaluates the blinding terms
The proof that the evaluation was done correctly is given by the following polynomial, which uses the blinding terms multiplied by the associated power of $u$. The reason for this will be explained later.

$$
\pi = \gamma_0 + \gamma_1u+\gamma_2u^2
$$

The prover sends $(y, \pi)$ to the verifier. Note that the prover is only sending field elements (scalars) not elliptic curve points.

## Verification step
The verifier runs the following check:

$$
C_0+C_1u+C_2u^2\stackrel{?}{=}yG+\pi B
$$

## Why the verification step works
If we expand the elliptic curve points to their underlying values, we see the equation is balanced:

$$
\begin{align*}
C_0 + C_1u + C_2u^2 &= yG + \pi B \\
(c_0G + \gamma_0B) + (c_1G + \gamma_1B)u + (c_2G + \gamma_2B)u^2 &= (c_0 + c_1u + c_2u^2)G + (\gamma_0 + \gamma_1u + \gamma_2u^2)B \\
c_0G + \gamma_0B + c_1Gu + \gamma_1Bu + c_2Gu^2 + \gamma_2Bu^2 &= (c_0 + c_1u + c_2u^2)G + (\gamma_0 + \gamma_1u + \gamma_2u^2)B \\
c_0G + c_1Gu + c_2Gu^2 + \gamma_0B + \gamma_1Bu + \gamma_2Bu^2 &= (c_0 + c_1u + c_2u^2)G + (\gamma_0 + \gamma_1u + \gamma_2u^2)B \\
(c_0 + c_1u + c_2u^2)G + (\gamma_0 + \gamma_1u + \gamma_2u^2)B &= (c_0 + c_1u + c_2u^2)G + (\gamma_0 + \gamma_1u + \gamma_2u^2)B \\
\end{align*}
$$

In a sense, the prover is evaluating the polynomial using the polynomial's coefficients and their choice of $u$. This will produce the evaluation of the original polynomial plus the blinding terms of the polynomial.

The proof of correct evaluation is that the prover can separate the blinding terms from the evaluation of the polynomial -- even though the prover does not know the discrete logs of $yG$ and $\pi B$.

### An alternative illustration for why the verification works

Recall that $p(x) = c_0 + c_1x + c_2x^2$. Therefore, the commitments to the coefficients are computed as follows:

$$
\begin{matrix}
&\space\space\space c_0G&\space\space\space c_1G&\space\space\space c_2G\\
&+\gamma_0B&+\gamma_1B&+\gamma_2B\\
&\vcenter{\hbox{|}} \vcenter{\hbox{|}}&\vcenter{\hbox{|}} \vcenter{\hbox{|}}&\vcenter{\hbox{|}} \vcenter{\hbox{|}}\\
&C_0&C_1&C_2
\end{matrix}
$$

When the verifier sends $\color{red}{u}$, the prover computes:

$$
\begin{matrix}
y=& c_0& +c_1\color{red}{u}& +c_2\color{red}{u^2}\\
\pi=&\gamma_0&+\gamma_1\color{red}{u}&+\gamma_2\color{red}{u^2}\\
\end{matrix}
$$

In the final step, the verifier checks:

$$yG + \pi B\stackrel{?}=C_0 + C_1 {\color{red} u} + C_2 {\color{red} u^2}$$

If we expand the terms vertically, we see the equation is balanced if the prover was honest:

$$
\begin{matrix}
yG&=& c_0G& c_1G\color{red}{u}& c_2G\color{red}{u^2}\\
\pi B&=&\gamma_0B&\gamma_1B\color{red}{u}&\gamma_2B\color{red}{u^2}\\
\vcenter{\hbox{|}} \vcenter{\hbox{|}}&&\vcenter{\hbox{|}} \vcenter{\hbox{|}}&\vcenter{\hbox{|}} \vcenter{\hbox{|}}&\vcenter{\hbox{|}} \vcenter{\hbox{|}}\\
yG+\pi B&\stackrel{?}=&C_0&+C_1\color{red}{u}&+C_2\color{red}{u^2}
\end{matrix}
$$

**It is <u>very important</u> that you firmly grasp how this technique of proving correct evaluation of a polynomial, given blinding commitments to the coefficients, works because [Bulletproofs](https://www.rareskills.io/post/bulletproofs-zk) use this technique <u>everywhere</u>.**

**Exercise:** Write out the steps for how a prover would convince a verifier they correctly evaluated a degree 1 polynomial, without revealing the polynomial to the verifier.

**Exercise:** Fill in the Python code below to implement the algorithm described in this chapter:

```python
from py_ecc.bn128 import G1, multiply, add, FQ
from py_ecc.bn128 import curve_order as p
import random

def random_field_element():
    return random.randint(0, p)

# these EC points have unknown discrete logs:
G = (FQ(6286155310766333871795042970372566906087502116590250812133967451320632869759), FQ(2167390362195738854837661032213065766665495464946848931705307210578191331138))

B = (FQ(12848606535045587128788889317230751518392478691112375569775390095112330602489), FQ(18818936887558347291494629972517132071247847502517774285883500818572856935411))

# scalar multiplication example: multiply(G, 42)
# EC addition example: add(multiply(G, 42), multiply(G, 100))

# remember to do all arithmetic modulo p

def commit(f_0, f_1, f_2, gamma_0, gamma_1, gamma_2, G, B):
    # fill this in
    # return the commitments as a tuple (C0, C1, C2)
    pass

def evaluate(f_0, f_1, f_2, u):
    return (f_0 + f_1 * u + f_2 * u**2) % p

def prove(gamma_0, gamma_1, gamma_2, u):
    # fill this in
    # return pi
    pass

def verify(C0, C1, C2, G, B, f_u, pi):
    # fill this in
    # Return true or false
    pass

## step 0: Prover and verifier agree on G and B

## step 1: Prover creates the commitments
### f(x) = f_0 + f_1x + f_2x^2
f_0 = ...
f_1 = ...
f_2 = ...

### blinding terms
gamma_0 = ...
gamma_1 = ...
gamma_2 = ...
C0, C1, C2 = commit(f_0, f_1, f_2, gamma_0, gamma_1, gamma_2, G, B)

## step 2: Verifier picks u
u = ...

## step 3: Prover evaluates f(u) and pi

f_u = evaluate(f_0, f_1, f_2, u)
pi = prove(gamma_0, gamma_1, gamma_2, u)

## step 4: Verifier accepts or rejects
if verify(C0, C1, C2, G, B, f_u, pi):
    print("accept")
else:
    print("reject")
```

## Why the prover cannot cheat
Cheating on the prover's part means they don't honestly evaluate $y = p(u)$ but still try to pass the final evaluation step.

Without loss of generality, let's say the prover sends the correct commitments for the coefficients $C_0, C_1, C_2$.

We say without loss of generality because there is a mismatch between the coefficients sent in the commitments and the coefficients used to evaluate the polynomial.

To do so, the prover sends $y'$ where $y' \neq c_0 + c_1u + c_2u^2$.

Using the final equation from the previous section, we see that the prover must satisfy:

$$
(c_0 + c_1u + c_2u^2)G+(\gamma_0 + \gamma_1u+\gamma_2u^2)B=y'G+(\gamma_0 + \gamma_1u+\gamma_2u^2)B
$$

The $G$ terms of the equation are clearly unbalanced. The other "lever" the prover can pull is adjusting the $\pi$ that they send.

$$
(c_0 + c_1u + c_2u^2)G+(\gamma_0 + \gamma_1u+\gamma_2u^2)B=y'G + \boxed{\pi'}B
$$

Since $y' \neq c_0 + c_1u + c_2u^2$ the malicious prover must rebalance the equation by picking a term $\pi'$ that accounts for the mismatch in the $G$ terms. The prover can try to solve for $\pi'$ with 

$$
\pi'B = (c_0 + c_1u + c_2u^2)G+(\gamma_0 + \gamma_1u+\gamma_2u^2)B - y'G
$$

But solving this equation requires the malicious prover to know the discrete logs of $G$ and $B$.

Let's solve for $\pi'$ in the equation above:

$$
\pi' = \frac{(c_0 + c_1u + c_2u^2)G+(\gamma_0 + \gamma_1u+\gamma_2u^2)B - y'G}{B}
$$

and then replace $B$ with $b$ and $G$ with $g$, where $b$ and $g$ are the discrete logs of $B$ and $G$ respectively:

$$\pi' = \frac{(c_0 + c_1u + c_2u^2)g+(\gamma_0 + \gamma_1u+\gamma_2u^2)b - y'g}{b}$$

But again, this is not possible because computing the discrete log of $B$ and $G$ is infeasible. 

## What the verifier learns
The verifier learns that the commitments $C_0, C_1, C_2$ represent valid commitments to a polynomial that is at most degree 2, and that $y$ is the value of the polynomial evaluated at $u$.
