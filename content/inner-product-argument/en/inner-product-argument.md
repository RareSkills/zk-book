# A Zero Knowledge Proof for the Inner Product
An inner product argument is a proof that the prover carried out the inner product computation correctly. This chapter shows how to construct a zero knowledge proof for an inner product argument.

In the previous chapter, we showed how to multiply two scalars together in a zero knowledge fashion: we commit to two degree-one polynomials, and prove that we correctly computed their product, and then show that the constant term of the degree one polynomials are the commitments to the secret factors we are multiplying.

If the coefficients of our polynomial are vectors instead of scalars, then we can prove that we computed the inner product of the vector correctly. We now introduce the *vector polynomial*.

## Vector polynomials: polynomials with vectors as coefficients
The following are two polynomials with vector coefficients:

$$
\begin{align*}
\mathbf{l}(x) &= \begin{bmatrix} 1 \\ 2 \end {bmatrix} x + \begin{bmatrix} 3 \\ 4 \end{bmatrix} \\
\mathbf{r}(x) &= \begin{bmatrix} 2 \\ 3 \end{bmatrix} x +\begin{bmatrix} 7 \\ 2 \end{bmatrix}
\end{align*}
$$

Evaluating a vector polynomial produces another vector. For example, $\mathbf{l}(2)$ produces

$$
\begin{align*}
\mathbf{l}(2) &= \begin{bmatrix} 1 \\ 2 \end{bmatrix} (2) + \begin{bmatrix} 3 \\ 4 \end{bmatrix}\\
&= \begin{bmatrix} 2 \\ 4  \end{bmatrix}+\begin{bmatrix} 3 \\ 4 \end{bmatrix}\\
&=\begin{bmatrix} 5 \\ 8 \end{bmatrix}
\end{align*}
$$


and evaluating $\mathbf{r}$ at 2 returns:

$$
\begin{align*}
\mathbf{r}(2) &= \begin{bmatrix} 2 \\ 3 \end{bmatrix} (2) + \begin{bmatrix} 7 \\ 2 \end{bmatrix}\\
&= \begin{bmatrix} 4 \\ 6 \end{bmatrix} + \begin{bmatrix} 7 \\ 2 \end{bmatrix}\\
&= \begin{bmatrix} 11 \\ 8 \end{bmatrix}
\end{align*}
$$

$\mathbf{l}(x)$ and $\mathbf{r}(x)$ are written as bold since they produce vectors when evaluated at some scalar $x$.

## Multiplying vector polynomials
Vector polynomials can be multiplied together like scalar polynomials. For example, multiplying $\mathbf{l}(x)$ and $\mathbf{r}(x)$ yields:

$$
\begin{align*}
\mathbf{l}(x)\mathbf{r}(x) &= 
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
)\\
&=\begin{bmatrix}
1\\2
\end{bmatrix}\circ
\begin{bmatrix}
2\\3
\end{bmatrix}x^2+
\begin{bmatrix}
1\\2
\end{bmatrix}\circ
\begin{bmatrix}
7\\2
\end{bmatrix}x+
\begin{bmatrix}
3\\4
\end{bmatrix}\circ
\begin{bmatrix}
2\\3
\end{bmatrix}x+
\begin{bmatrix}
3\\4
\end{bmatrix}\circ
\begin{bmatrix}
7\\2
\end{bmatrix}&&\\
&=\begin{bmatrix}
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
\end{bmatrix}\\
&=\begin{bmatrix}
2\\6
\end{bmatrix}x^2+
\begin{bmatrix}
13\\16
\end{bmatrix}x+
\begin{bmatrix}
21\\8
\end{bmatrix}
\end{align*}
$$

When we multiply each of the vectors together, we take the Hadamard product (element-wise product, denoted with $\circ$).

Note that if we plug $x = 2$ into the resulting vector polynomial, we get the following:

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

This is the same as if we compute:

$$\mathbf{l}(2)\circ\mathbf{r}(2) = \begin{bmatrix}5\\8\end{bmatrix}\circ\begin{bmatrix}11\\8\end{bmatrix}=\begin{bmatrix}55\\64\end{bmatrix}$$

In other words, multiplying two vector polynomials together and then evaluating the product at some point is the same as evaluating the vector polynomials separately and then taking the Hadamard product on the resulting vectors.

## Inner product of vector polynomials
To compute the inner product of two vector polynomials, we multiply them together as described above, but then sum up the vector entries so the result becomes a scalar. We denote this operation as $\langle \mathbf{l}(x), \mathbf{r}(x) \rangle$. We can accomplish the same thing by using the inner product when we multiply vector coefficients instead of using the Hadamard product.

For the two example polynomials above, this would be:

$$\langle \mathbf{l}(x), \mathbf{r}(x) \rangle = \langle \begin{align*}\end{align*} \begin{bmatrix} 1 \\ 2 \end{bmatrix} x +\begin{bmatrix} 3 \\ 4 \end{bmatrix},\begin{bmatrix}2\\3\end{bmatrix}x+\begin{bmatrix}7\\2\end{bmatrix}\rangle$$

$$=\langle \begin{bmatrix} 1 \\ 2 \end{bmatrix},\begin{bmatrix}2 \\ 3 \end{bmatrix}\rangle x^2 + \langle \begin{bmatrix} 3 \\ 4 \end{bmatrix},\begin{bmatrix}2 \\ 3 \end{bmatrix}\rangle x + \langle \begin{bmatrix} 1 \\ 2 \end{bmatrix},\begin{bmatrix}7 \\ 2 \end{bmatrix}\rangle x+\langle \begin{bmatrix} 3 \\ 4 \end{bmatrix},\begin{bmatrix}7 \\ 2 \end{bmatrix}\rangle$$

$$=(1\cdot2+2\cdot3)x^2+(3\cdot2+4\cdot3)x + (1\cdot7+2\cdot2) x + (3\cdot7+4\cdot2)$$

$$=8x^2 + 18x + 11x + 29$$

$$=8x^2 + 29x + 29$$

Observe that $\langle\mathbf{l}(2), \mathbf{r}(2)\rangle$ is the same as $\langle \mathbf{l}(x), \mathbf{r}(x)\rangle$ evaluated at $x = 2$. That is, $\langle [5, 8], [11, 8]\rangle = 119$ and $8(2)^2 + 29(2) + 29 = 119$.

### Why this works in general
Suppose we multiplied vector polynomials together the "normal" way -- i.e. we take the elementwise-product (Hadamard product) of the coefficients instead of the inner product. The inner product of each of the coefficients is simply the sum of the terms of the Hadamard product of each of the coefficients.

Therefore, we can say that if we have two vector polynomials $\mathbf{l}(x)$ and $\mathbf{r}(x)$, and we multiply them together as $\mathbf{t}(x)=\mathbf{l}(x)\mathbf{r}(x)$ then the inner product of $\langle \mathbf{l}(x), \mathbf{r}(x) \rangle$ is equal to the element-wise sum of the coefficients of $\mathbf{t}$. Note that the multiplication of two vector polynomials results in a vector polynomial, but the inner product of two vector polynomials results in polynomial where all the coefficients are scalars.

## Zero knowledge inner product proof
In the previous chapter on zero knowledge multiplication, we demonstrated that we have a valid multiplication by proving that the product of the constant terms of two linear polynomials equals the constant term in the product of the polynomials.

To prove correct computation of an inner product, we replace the polynomials with vector polynomials and we replace the multiplication of scalar polynomials with the inner product of vector polynomials.

Everything else remains the same.

## The algorithm
The goal is for the prover to convince the verifier that $A$ is a commitment to $\mathbf{a}$ and $\mathbf{b}$, $V$ is a commitment to $v$, and that $\langle \mathbf{a}, \mathbf{b} \rangle = v$ without revealing $\mathbf{a}$, $\mathbf{b}$, or $v$.

### Setup
The prover and verifier agree on:
- *basis vectors* $\mathbf{G}$ and $\mathbf{H}$ with which the prover can commit the vectors
- elliptic curve point $G$ (separate from $\mathbf{G}$) which will be used for committing the coefficients of $t(x)$ and the inner product committed to $V$
- elliptic curve point $B$ for the blinding terms

### Prover
The prover generates the blinding terms $\alpha$, $\beta$, $\gamma$, $\tau_1$, and $\tau_2$ and computes:

$$
\begin{align}
A &= \langle\mathbf{a},\mathbf{G}\rangle + \langle\mathbf{b},\mathbf{H}\rangle+\alpha B\\
S &= \langle\mathbf{s}_L,\mathbf{G}\rangle + \langle\mathbf{s}_R,\mathbf{H}\rangle+\beta B\\
V &= vG + \gamma B \\
T_1 &= (\langle\mathbf{a},\mathbf{s}_R\rangle + \langle\mathbf{b},\mathbf{s}_L\rangle )G + \tau_1B\\
T_2 &= \langle\mathbf{s}_L,\mathbf{s}_R\rangle G + \tau_2B
\end{align}$$

Note that this time the linear coefficients $\mathbf{s}_L$ and $\mathbf{s}_R$ are vectors instead of scalars. The prover transmits $(A, S, V, T_1, T_2)$ to the verifier. After the verifier responds with a random $u$, the prover evaluates $\mathbf{l}(x)$, $\mathbf{r}(x)$, and their inner product $\mathbf{t}(x)$ at $u$.

$$
\begin{align*}
\mathbf{l}_u &= \mathbf{l}(u)=\mathbf{a} + \mathbf{s}_Lu \\
\mathbf{r}_u &= \mathbf{r}(u)=\mathbf{b} + \mathbf{s}_Ru \\
t_u &= v + (\langle\mathbf{a},\mathbf{s}_R\rangle + \langle\mathbf{b},\mathbf{s}_L\rangle)u + \langle\mathbf{s}_L,\mathbf{s}_R\rangle u^2\\
\pi_{lr} &=\alpha+\beta u\\
\pi_t &= \gamma + \tau_1u + \tau_2u^2\\
\end{align*}
$$

### Final verification step
First, the verifier checks that $t_u$ is the inner product of $\mathbf{l}_u$ and $\mathbf{r}_u$ evaluated at $u$.

$$t_u \stackrel{?}{=} \langle \mathbf{l}_u, \mathbf{r}_u \rangle$$

This should hold if the prover is honest, because the inner product of the polynomials evaluated at $u$ is the same as the inner product of the vector polynomials $\mathbf{l}_x$ and $\mathbf{r}_x$ evaluated at $x = u$.

Second, the verifier checks that $A$ and $S$ are commitments to the constant and linear terms of $\mathbf{l}$ and $\mathbf{r}$ respectively.

$$A + Su \stackrel{?}{=} \langle \mathbf{l}_u, \mathbf{G} \rangle + \langle \mathbf{r}_u, \mathbf{H} \rangle + \pi_{lr} B$$

Recall that $A$ and $S$ are commitments to the constant and linear terms of $\mathbf{l}$ and $\mathbf{r}$ and $\pi_{lr}$ is the sum of the blinding terms $\alpha$ and $\beta$ in $A$ and $S$ respectively.

Finally, the verifier checks that $t_u$ is the evaluation of the quadratic polynomial commited to $V, T_1, T_2$:

$$t_uG + \pi_tB \stackrel{?}{=} V + T_1 u + T_2 u^2$$

## Improving the proof size
When the prover sends $(\mathbf{l}, \mathbf{r}, t, T_1, T_2, \pi)$, the prover sends over $2n$ elements (the length of $\mathbf{l}$ and $\mathbf{r}$) which is not succinct.

In the following chapters we will learn how to reduce the size of the proof. It is possible to create a proof of size $\log n$ that an inner product is correct. That is, if we wanted to prove we computed the inner product of two vectors of length $n$, then the proof would only be of size $\log n$ -- exponentially smaller.

Specifically, we will optimize the step $t_u\stackrel{?}=\langle\mathbf{l}_u,\mathbf{r}_u\rangle$ and $A + Su \stackrel{?}{=} \langle \mathbf{l}_u, \mathbf{G} \rangle + \langle \mathbf{r}_u, \mathbf{H} \rangle + \pi_{lr} B$ by sending a commitment to $\mathbf{l}_u$ and $\mathbf{r}_u$ instead of the actual vectors, along with a logarithmic size proof to show that the commitment holds the vectors whose inner product is $t_u$.

## Summary
We have described a protocol that proves that $A$ is a commitment to $\mathbf{a}$ and $\mathbf{b}$, $V$ is a commitment to $v$, and that $\langle \mathbf{a}, \mathbf{b} \rangle = v$ without revealing $\mathbf{a}$, $\mathbf{b}$, or $v$. The proof size, however, is linear, as $\mathbf{l}_u$ and $\mathbf{r}_u$ in $(\mathbf{l}_u, \mathbf{r}_u, t, T_1, T_2, \pi_{lr},\pi_t)$ are each of size $n$.

**Exercise:** Fill in the missing code to implement the algorithm in this lecture. Prove you know the inner product for an $n=4$ vector without revealing it. Note that numpy arrays allow for element-wise addition and multiplication. For example:
```python
import numpy as np
a = np.array([1,2,3,4])
b = np.array([2,2,2,2])

print(a + b) # np.array([3,4,5,6])
print(a * b) # np.array([2,4,6,8])
print(numpy.inner(a, b)) # 20

# casting a numpy array to numpy doesn't do anything
print(np.array(a) + b) # np.array([3,4,5,6])
```

Fill in the following code:
```python
from py_ecc.bn128 import G1, multiply, add, FQ, eq, Z1
from py_ecc.bn128 import curve_order as p
import numpy as np
from functools import reduce
import random

def random_element():
    return random.randint(0, p)

def add_points(*points):
    return reduce(add, points, Z1)

# if points = G1, G2, G3, G4 and scalars = a,b,c,d vector_commit returns
# aG1 + bG2 + cG3 + dG4
def vector_commit(points, scalars):
    return reduce(add, [multiply(P, i) for P, i in zip(points, scalars)], Z1)


# these EC points have unknown discrete logs:
G = [(FQ(6286155310766333871795042970372566906087502116590250812133967451320632869759), FQ(2167390362195738854837661032213065766665495464946848931705307210578191331138)),
     (FQ(6981010364086016896956769942642952706715308592529989685498391604818592148727), FQ(8391728260743032188974275148610213338920590040698592463908691408719331517047)),
     (FQ(15884001095869889564203381122824453959747209506336645297496580404216889561240), FQ(14397810633193722880623034635043699457129665948506123809325193598213289127838)),
     (FQ(6756792584920245352684519836070422133746350830019496743562729072905353421352), FQ(3439606165356845334365677247963536173939840949797525638557303009070611741415))]

H = [(FQ(13728162449721098615672844430261112538072166300311022796820929618959450231493), FQ(12153831869428634344429877091952509453770659237731690203490954547715195222919)),
    (FQ(17471368056527239558513938898018115153923978020864896155502359766132274520000), FQ(4119036649831316606545646423655922855925839689145200049841234351186746829602)),
    (FQ(8730867317615040501447514540731627986093652356953339319572790273814347116534), FQ(14893717982647482203420298569283769907955720318948910457352917488298566832491)),
    (FQ(419294495583131907906527833396935901898733653748716080944177732964425683442), FQ(14467906227467164575975695599962977164932514254303603096093942297417329342836))]

B = (FQ(12848606535045587128788889317230751518392478691112375569775390095112330602489), FQ(18818936887558347291494629972517132071247847502517774285883500818572856935411))

# scalar multiplication example: multiply(G, 42)
# EC addition example: add(multiply(G, 42), multiply(G, 100))

# remember to do all arithmetic modulo p
def commit(a, sL, b, sR, alpha, beta, gamma, tau_1, tau_2):
    pass
    # return (A, S, V, T1, T2)


def evaluate(f_0, f_1, f_2, u):
    return (f_0 + f_1 * u + f_2 * u**2) % p

def prove(blinding_0, blinding_1, blinding_2, u):
    # fill this in
    # return pi
    pass

## step 0: Prover and verifier agree on G and B

## step 1: Prover creates the commitments
a = np.array([89,15,90,22])
b = np.array([16,18,54,12])
sL = ...
sR = ...
t1 = ...
t2 = ...

### blinding terms
alpha = ...
beta = ...
gamma = ...
tau_1 = ...
tau_2 = ...

A, S, V, T1, T2 = commit(a, sL, b, sR, alpha, beta, gamma, tau_1, tau_2)

## step 2: Verifier picks u
u = ...

## step 3: Prover evaluates l(u), r(u), t(u) and creates evaluation proofs
l_u = evaluate(a, sL, 0, u)
r_u = evaluate(b, sR, 0, u)
t_u = evaluate(np.inner(a, b), t1, t2, u)

pi_lr = prove(alpha, beta, 0, u)
pi_t = prove(gamma, tau_1, tau_2, u)

## step 4: Verifier accepts or rejects
assert t_u == np.mod(np.inner(np.array(l_u), np.array(r_u)), p), "tu !=〈lu, ru〉"
assert eq(add(A, commit(S, u)), add_points(vector_commit(G, l_u), vector_commit(H, r_u), multiply(B, pi_lr))), "l_u or r_u not evaluated correctly"
assert eq(add(multiply(G, t_u), multiply(B, pi_t)), add_points(V, multiply(T1, u), multiply(T2, u**2 % p))), "t_u not evaluated correctly"
```

This tutorial is part of a series on [ZK Bulletproofs](rareskills.io/post/bulletproofs-zk).
