# Using the Convolution Theorem to Prove Equivalence Between Multiplication in Coefficient Form and Point Form

At the beginning of this series, we argued that the [multiplication of two polynomials](https://app.notion.com/p/Using-Convolution-Theorem-to-Prove-Equivalence-Between-Multiplication-in-Coefficient-Form-and-Point--2c709cb3e9628091b6cac7c0d9737423?pvs=21) of degree at most $n$ can be performed in $\mathcal{O}(n)$ complexity time if both polynomials are in point-value form.

In practice, the difficulty is that polynomials are usually given in coefficient form, and we want the result of the multiplication to also be in coefficient form.

Fortunately, these problems can be solved by using the fast versions of the NTT and INTT.

To multiply two polynomials represented in coefficient form in $\mathcal{O}(n \log n)$ time, the procedure is as follows:

- Using the NTT, the polynomials are converted from coefficient form to point-value form.
- The polynomials in point-value form are multiplied pointwise. This can be performed in time complexity $\mathcal{O}(n)$, and the result is obtained in point-value form.
- The INTT is used to transform the resulting polynomial back to coefficient form.

Using $n$-th roots of unity, where $n$ is a power of $2$, steps 1 and 3 can be performed in $\mathcal{O}(n \log n)$ time. 

The only limitation is that we must impose a maximum degree of $n-1$ on the resulting polynomial. Therefore, the sum of the degrees of the two polynomials we want to multiply cannot exceed $n-1$.

In practice, this is generally not a problem, since we can usually use fields containing sufficiently large $n$-th roots of unity so that the degrees of the polynomials remain within the allowed bound.

Polynomials of degree less than $n-1$ do not represent a problem, since they can be padded with zero-valued coefficients up to degree $n-1$.

Without using the fast NTT and INTT, polynomial multiplication would have time complexity $\mathcal{O}(n^2)$.

The aim of this chapter is to prove our claim. We will show that multiplying two polynomials in coefficient form is equivalent to applying the NTT to each polynomial, performing pointwise multiplication, and then applying the INTT to the resulting polynomial obtained from this operation.

This result is known as the **convolution theorem** in the context of polynomial multiplication. In a more general context, the convolution theorem states that

“convolution in the original domain is equivalent to pointwise multiplication in the transformed domain.”

To properly understand this theorem, we need to start by defining what convolution is.

*Readers less inclined toward mathematics can skip this chapter without loss of continuity. In the rest of the text, we prove the convolution theorem, but if the reader is only interested in its application, it is sufficient to accept that it can be used to multiply polynomials in time complexity $\mathcal{O}(n \log n)$ instead of $\mathcal{O}(n^2)$.*

## Convolution

Multiplying two polynomials in coefficient form is an example of a convolution operation.

Consider two polynomials of degree 2,

$$
f(x) = a_0 + a_1x + a_2 x^2
$$

and

$$
g(x) = b_0 + b_1 x + b_2 x^2.
$$

Multiplication in coefficient form yields the polynomial

$$
\begin{aligned}
h(x) = f(x)g(x) &= a_0b_0 + a_0b_1 x+a_0b_2x^2 + \\
&+ a_1b_0x + a_1b_1x^2 + a_1b_2x^3 \\
&+ a_2 b_0 x^2 + a_2 b_1 x^3 +  a_2b_2x^4.
\end{aligned}
$$

Rearranging this expression, we obtain

$$
\begin{aligned}
h(x) = f(x)g(x) &= a_0b_0 \\
&+ (a_0 b_1 + a_1b_0)x \\
&+ (a_0 b_2 + a_1 b_1 + a_2 b_0) x^2 \\
&+ (a_1 b_2 + a_2 b_1) x^3 \\
&+ a_2 b_2 x^4.

\end{aligned}
$$

Thus, the coefficients of the polynomial resulting from the multiplication of $f(x)$ and $g(x)$ are

$$
\begin{aligned}
c_0 &= a_0b_0, \\
c_1 &= a_0 b_1 + a_1b_0, \\
c_2 &= a_0 b_2 + a_1 b_1 + a_2 b_0, \\
c_3 &= a_1 b_2 + a_2 b_1, \\
c_4 &= a_2 b_2.
\end{aligned}
$$

These coefficients can be compactly expressed by the formula

$$
c_k = \sum_{i=0}^{k} a_i b_{k-i}
$$

for $k=0,1,2,3,4$, which is the degree of the polynomial $h(x)$. Let us examine this for one of the coefficients, $c_3$. For this coefficient, we have

$$
c_3 = \sum_{i=0}^{3} a_i b_{3-i} = a_0 b_3 + a_1 b_ 2 + a_2 b_1 + a_3 b_0.
$$

Since both $a_3$ and $b_3$ are zero (because the polynomials $f(x)$ and $g(x)$ have degree 2), this reduces to

$$
c_3 = a_1 b_2 + a_2 b_1,
$$

as expected.

The operation defined by

$$
c_k = \sum_{i=0}^{k} a_i b_{k-i}
$$

is called a **convolution** and is usually written as

$$
c_k = (a \ast b)_k,
$$

where $\ast$ denotes the convolution operator.

## The Convolution Theorem

Our goal is to prove that converting $f(x)$ and $g(x)$ to point-value form, multiplying the corresponding points, and converting the result back to coefficient form is equivalent to performing the convolution of the coefficients of $f(x)$ and $g(x)$.

Consider the polynomials 

$$
f(x)=a_0 + a_1x+a_2x^2 + ... +a_px^p
$$

and

$$
g(x)=b_0 + b_1x+b_2x^2 + ... +b_qx^q
$$

of degree $p$ and $q$.

Multiplying $f(x)$ and $g(x)$ produces a new polynomial $h(x)$ whose degree is the **sum** of the degrees $p$ and $q$ of $f(x)$ and $g(x)$, respectively. 

Suppose that the degree of $h(x)$ is $n-1$. 

Thus, we want to compute

$$
h(x) = f(x)g(x) = c_0 + c_1 x + c_2 x^2 + \ldots + c_{n-1} x^{n-1}
$$

*If the degree is less than $n-1$, we can pad the coefficients of the higher-degree terms with zeros.*

Let us represent the coefficients of the polynomials $f(x)$ and $g(x)$ as

$$
\begin{aligned}
[a_0, a_1, a_2, ..., a_{n-1}], \\
[b_0, b_1, b_2, ..., b_{n-1}].
\end{aligned}
$$

Some of the higher-degree coefficients above will be zero, as the degrees of $f(x)$ and $g(x)$ must sum to at most $n-1$. This is not a problem. Our only restriction is that

$$
deg⁡(f)+deg⁡(g)=deg⁡(h)≤n−1.
$$

Our first step is to convert the polynomials $f(x)$ and $g(x)$ from coefficient form to point-value form.

### **First step:** convert the polynomials to point-value form.

To convert these polynomials to point-value form, we use the NTT. By choosing $n$ to be a power of $2$, we can apply the fast transform. However, since the final result is equivalent to multiplication by the Vandermonde matrix, we will present the matrix formulation. 

For instance, for the polynomial $f(x)$, its evaluations at the $n$-th roots of unity are given by

$$
\begin{bmatrix} f(1) \\ f(\omega) \\ f(\omega^2) \\ \vdots \\ f(\omega^{n-1}) \end{bmatrix} =  \begin{bmatrix}1 & 1 & 1 & \cdots & 1 \\1 & \omega & \omega^{2} & \cdots & \omega^{n-1} \\1 & \omega^{2} & \omega^{4} & \cdots & \omega^{2(n-1)} \\\vdots & \vdots & \vdots & \ddots & \vdots \\1 & \omega^{n-1} & \omega^{2(n-1)} & \cdots & \omega^{(n-1)(n-1)}\end{bmatrix} \begin{bmatrix} a_0 \\ a_1 \\ a_2\\ \vdots \\ a_{n-1} \end{bmatrix}.
$$

Similarly, for $g(x)$,

$$
\begin{bmatrix} g(1) \\ g(\omega) \\ g(\omega^2) \\ \vdots \\ g(\omega^{n-1}) \end{bmatrix} =  \begin{bmatrix}1 & 1 & 1 & \cdots & 1 \\1 & \omega & \omega^{2} & \cdots & \omega^{n-1} \\1 & \omega^{2} & \omega^{4} & \cdots & \omega^{2(n-1)} \\\vdots & \vdots & \vdots & \ddots & \vdots \\1 & \omega^{n-1} & \omega^{2(n-1)} & \cdots & \omega^{(n-1)(n-1)}\end{bmatrix} \begin{bmatrix} b_0 \\ b_1 \\ b_2\\ \vdots \\ b_{n-1} \end{bmatrix}.
$$

These matrix operations can be written componentwise as

$$
f(\omega^i) = \sum_{r=0}^{n-1} a_r \omega^{ri}
$$

and

$$
g(\omega^i) = \sum_{s=0}^{n-1} b_s \omega^{si}.
$$

For example, the evaluation of $f(\omega^2)$ is given by

$$
f(\omega^2) = \sum_{r=0}^{n-1} a_r \omega^{r2} = a_0 \omega^{0 \cdot 2} + a_1 \omega^{1 \cdot 2} + a_2 \omega^{2 \cdot 2} + \ldots + a_{n-1} \omega^{{(n-1)} \cdot 2}
$$

### **Second step:** perform pointwise multiplication of the polynomials in point-value form.

We now multiply the evaluations of $f(x)$ and $g(x)$ pointwise to obtain the evaluations of the product polynomial $h(x)$:

$$
\begin{aligned}
h(\omega^0)&= f(\omega^0)g(\omega^0) \\
h(\omega^1)&= f(\omega^1)g(\omega^1) \\
&\vdots
\\
h(\omega^{n-1})&= f(\omega^{n-1})g(\omega^{n-1})
\end{aligned}
$$

In index notation, this can be written as

$$
h(\omega^i) = f(\omega^i) g(\omega^i).
$$

Using the expressions for $f(\omega^i)$ and $g(\omega^i)$ obtained in the previous step, we obtain

$$
h(\omega^i) = \left(\sum_{r=0}^{n-1} a_r \omega^{ri} \right) \left( \sum_{s=0}^{n-1} b_s \omega^{si}\right).
$$

To recap, what we want to show is that if we perform the INTT on the polynomial $h(x)$ in its point-value form (the above form), the result is the same as performing the convolution of $f(x)$ and $g(x)$.

### **Last step:** apply the INTT to the polynomial $h(x)$ in point-value form

The **I**nverse Number Theoretic Transform over the $n$-th roots of unity is performed using the Vandermonde matrix $V(\omega^{-1})$ scaled by a factor of $\frac{1}{n}$.

Thus, by applying the INTT to the set of points $h(\omega^i)$, we obtain the polynomial $h(x)$ in coefficient form:

$$
\begin{bmatrix} c_0 \\ c_1 \\ c_2\\ \vdots \\ c_{n-1} \end{bmatrix} = \frac{1}{n}\begin{bmatrix}1 & 1 & 1 & \cdots & 1 \\1 & \omega^{-1} & \omega^{-2} & \cdots & \omega^{-(n-1)} \\1 & \omega^{-2} & \omega^{-4} & \cdots & \omega^{-2(n-1)} \\\vdots & \vdots & \vdots & \ddots & \vdots \\1 & \omega^{-(n-1)} & \omega^{-2(n-1)} & \cdots & \omega^{-(n-1)(n-1)}\end{bmatrix} \begin{bmatrix} h(\omega^0) \\ h(\omega^1) \\ h(\omega^2) \\ \vdots \\ h(\omega^{n-1}) \end{bmatrix}
$$

This can be written component-wise as

$$
c_p = \frac{1}{n} \sum_{i=0}^{n-1} h(\omega^i) \omega^{-ip}.
$$

Using the fact that $h(\omega^i)$ is given by

$$
h(\omega^i) = \left(\sum_{r=0}^{n-1} a_r \omega^{ri} \right) \left( \sum_{s=0}^{n-1} b_s \omega^{si} \right),
$$

we have that

$$
c_p = \frac{1}{n} \sum_{i=0}^{n-1}   \underbrace{\left(\sum_{r=0}^{n-1} a_r \omega^{ri} \right) \left( \sum_{s=0}^{n-1} b_s \omega^{si} \right)}_{h(\omega^i)} \omega^{-ip}.
$$

This expression is large, but it can be simplified by applying the [orthogonality property of the roots of unity.](https://rareskills.io/post/orthogonality-of-roots-of-unity)

First, let us group all powers of $\omega$:

$$
\begin{aligned}
c_p
&= \frac{1}{n}
\sum_{i=0}^{n-1}
\left(\sum_{r=0}^{n-1} a_r \omega^{ri} \right)
\left( \sum_{s=0}^{n-1} b_s \omega^{si} \right)
\omega^{-ip}
&& \text{\small The expression obtained above} \\

&= \frac{1}{n}
\sum_{i=0}^{n-1}
\sum_{r=0}^{n-1}
\sum_{s=0}^{n-1}
(a_r b_s)\,\omega^{ri}\,\omega^{si}\,\omega^{-ip}
&& \text{\small Group the sums and terms} \\

&= \frac{1}{n}
\sum_{i=0}^{n-1}
\sum_{r=0}^{n-1}
\sum_{s=0}^{n-1}
(a_r b_s)\,\omega^{i(r+s-p)}
&& \text{\small Combine the exponents of }\omega^i \\

&= \frac{1}{n}
\sum_{r=0}^{n-1}
\sum_{s=0}^{n-1}
(a_r b_s)
\left(
\sum_{i=0}^{n-1}
\omega^{i(r+s-p)}
\right)
&& \text{\small Isolate the sum of roots of unity}.
\end{aligned}
$$

The expression above indicates that we can use the orthogonality of the roots of unity to simplify it.

Recall that the orthogonality property of the roots of unity is given by

$$
\sum_{i=0}^{n-1} (\omega^{i})^{r-s}=\begin{cases}n, & \text{if } r\equiv s \pmod{n},\\[6pt]0, & \text{otherwise}.\end{cases}
$$

Using the above formula for the isolated sum of roots of unity in $c_p$, we note that

$$
\sum_{i=0}^{n-1} \omega^{i(r+s-p)} 
$$

is equal to $n$ if $s = p-r \pmod{n}$ (or equivalently $r=p-s \pmod{n}$), and zero otherwise. 

This can be represented as $n$ multiplied by the Kronecker delta:

$$
\sum_{i=0}^{n-1} \omega^{i(r+s-p)} = n \delta_{s,p-r}
$$

Replacing 

$$
\sum_{i=0}^{n-1} \omega^{i(r+s-p)}
$$

in the expression for $c_p$, we have that

$$
c_p = \frac{1}{n} \sum_{r=0}^{n-1} \sum_{s=0}^{n-1} (a_r b_s)(n \delta_{s, p-r})
$$

The constants $\frac{1}{n}$ and $n$ cancel out:

$$
c_p = \frac{1}{\cancel{n}} \sum_{r=0}^{n-1} \sum_{s=0}^{n-1} (a_r b_s)(\cancel{n} \delta_{s, p-r})
$$

 More importantly, when summing over the index $s$, all terms vanish except when $s=p-r$. This is due to the [orthogonality of the roots of unity.](https://rareskills.io/post/orthogonality-of-roots-of-unity)

As a result, the summation over $s$ collapses, and we can replace the summation in $b_s$ with the single element $b_{p-r}$. We obtain

$$
c_p =  \sum_{r=0}^{n-1} a_r b_{p-r}
$$

This is exactly the **convolution formula!**

Let us recall what we did:

1. We applied the NTT to the polynomials $f(x)$ and $g(x)$, converting their coefficient representations into point-value representations, that is, vectors containing their evaluations at the $n$-th roots of unity:

$$
\big(f(1), f(\omega), \ldots, f(\omega^{n-1})\big)\quad \text{and} \quad\big(g(1), g(\omega), \ldots, g(\omega^{n-1})\big)
$$

1. We multiplied these evaluation values pointwise, meaning that for each root of unity $\omega^i$ we computed

$$
h(\omega^i)=f(\omega^i)g(\omega^i)
$$

obtaining the point-value representation of the product polynomial $h(x)$.

1. We applied the INTT to this vector of values

$$
\big(h(1), h(\omega), \ldots, h(\omega^{n-1})\big)
$$

to recover the coefficient representation of $h(x)$.

We showed that these three steps produce exactly the same result as multiplying the polynomials $f(x)$ and $g(x)$, namely, convolving the coefficients of $f(x)$ and $g(x)$. 

However, while direct convolution has time complexity $\mathcal{O}(n^2)$, the procedure above can be executed in $\mathcal{O}(n \log n)$ time, yielding the same final polynomial.

This is exactly what the convolution theorem states. In a more formal way, we can write it as follows:

Let $f$ and $g$ be two polynomials in their coefficient form. Let $*$ denote the convolution operation and $\cdot$ denote multiplication. 

Let $\mathcal{F}(f)$ denote the application of the NTT to $f$ — that is, while $f$ is the vector of coefficients, $\mathcal{F}(f)$  is the vector of evaluations — and $\mathcal{F}^{-1}(\mathcal{F}(f))$ denote the application of the INTT to $\mathcal{F}(f)$. Then,

$$
f *g =\mathcal{F}^{-1}(\mathcal{F}(f)\cdot\mathcal{F}(g)).
$$

Another way to express the convolution theorem is

$$
\mathcal{F}(f *g) =\mathcal{F}(f)\cdot\mathcal{F}(g).
$$

This is a linear transformation, and it can be understood as follows: convolution in the coefficient domain is equivalent to pointwise multiplication in the point-value domain.

*This article is part of a series on the Number Theoretic Transform in our [ZK Book](https://rareskills.io/zk-book)*
