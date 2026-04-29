# The Inverse Number Theoretic Transform

In the previous chapters, we studied the Number Theoretic Transform (NTT), which evaluates a polynomial at its $k$-th roots of unity. It can be understood as transforming a polynomial from its coefficient form into its point-value form.

The NTT can be performed by multiplying the coefficient vector of a degree-$(k-1)$ polynomial by a Vandermonde matrix, with time complexity $\mathcal{O}(k^2)$. It is also possible, and more interesting, to use a fast and recursive version of the transformation, which reduces the time complexity to $\mathcal{O}(k \log k)$. 

In this chapter, we begin the study of the inverse transformation of the NTT, called the **Inverse Number Theoretic Transform**, or **INTT.** It can be used to convert a polynomial from its point-valu form back to its coefficient form. This process is called **interpolation**.

In our article on [Lagrange interpolation](https://rareskills.io/post/python-lagrange-interpolation), we have already seen a method to perform interpolation. The difference between using Lagrange interpolation and the Inverse Number Theoretic Transform is twofold: Lagrange interpolation can be performed from any set of points, while the INTT can only be performed on the set of $k$-th roots of unity. Conversely, Lagrange interpolation always has time complexity $\mathcal{O}(k^2)$, while the INTT can be performed in time complexity $\mathcal{O}(k \log k)$. 

In this chapter, we will:

- Recall how evaluation can be performed using a Vandermonde matrix;
- Propose an inverse transformation that is also perfomed using a Vandermonde matrix;
- Show that this inverse transformation undoes the original transformation. In other words, we show that evaluation through NTT, followed by interpolation through INTT, returns the polynomial to its original coefficient form.

For now, we will work with the INTT for a polynomial of degree $3$ so that the reader can more easily follow the calculations.

In a subsequent chapter, we will prove that the proposed inverse transformation applies to polynomials of any degree.

## Recap: From coefficient form to point form

Consider the polynomial

$$
f(x)=a_0+a_1x+a_2x^2+a_3x^3
$$

To convert this polynomial from coefficient form to point-value form, it is necessary to evaluate it at least at $4$ points. 

For example, if the set $S=\{1,\omega, \omega^2, \omega^3\}$ represents the evaluation points, where $\omega$ is a primitive $4$th root of unity, the evaluations at these points are given by:

$$
\begin{aligned}
f(1) &= a_0 &+& a_1 &+& a_2 &+& a_3 \\ 
f(\omega) &= a_0 &+& a_1\omega &+& a_2\omega^2 &+& a_3\omega^3 \\
f(\omega^2) &= a_0 &+& a_1\omega^2 &+& a_2\omega^4 &+& a_3\omega^6 \\ f(\omega^3) &= a_0 &+& a_1\omega^3 &+& a_2\omega^6 &+& a_3\omega^9
\end{aligned}
$$

This can be expressed by the following matrix multiplication:

$$
\begin{aligned}\begin{bmatrix}f(1) \\f(\omega) \\f(\omega^2) \\f(\omega^3)\end{bmatrix}&=\begin{bmatrix}1 & 1 & 1 & 1 \\1 & \omega & \omega^2 & \omega^3 \\1 & \omega^2 & \omega^4 & \omega^6 \\1 & \omega^3 & \omega^6 & \omega^9\end{bmatrix}\begin{bmatrix}a_0 \\a_1 \\a_2 \\a_3\end{bmatrix} \\
\mathbf{y} &=V(\omega) \cdot \ \mathbf{a} \\
\end{aligned}
$$

where $V(\omega)$ is called a Vandermonde Matrix, and $\mathbf{a}$ is the column vector representing the coefficients. You may refer to the article on [Vandermonde Matrices](https://rareskills.io/post/vandermonde-matrix) to learn about them in detail. A **Vandermonde matrix** has the property that each of its rows forms a **geometric progression**, which is a sequence of numbers in which each term is obtained by multiplying the previous one by a constant ratio.

In the matrix $V(\omega)$ above, we can note that:

- 1st row: $[1 \ \ 1\ \ 1\ \ 1]$ $\rightarrow$ first term: $1$, common ratio: $1$
- 2nd row: $[1 \ \omega\  \omega^2\  \omega^3]$ $\rightarrow$ first term: $1$, common ratio: $\omega$
- 3rd row: $[1 \ \omega^2\  \omega^4\  \omega^6]$ $\rightarrow$ first term: $1$, common ratio: $\omega^2$
- 4th row: $[1 \ \omega^3\  \omega^6\  \omega^9]$ $\rightarrow$ first term: $1$, common ratio: $\omega^3$

Let us recall how the multiplication $\mathbf{y} =V(\omega) \cdot \ \mathbf{a}$ gives the evaluations of $f(x)$:

$$
\mathbf{y}=\begin{bmatrix}f(1)\\[4pt]f(\omega)\\[4pt]f(\omega^2)\\[4pt]f(\omega^3)\end{bmatrix}=\begin{bmatrix}1 & 1 & 1 & 1\\[4pt]1 & \omega & \omega^2 & \omega^3\\[4pt]1 & \omega^2 & \omega^4 & \omega^6\\[4pt]1 & \omega^3 & \omega^6 & \omega^9\end{bmatrix}\begin{bmatrix} a_0\\ a_1\\ a_2\\ a_3 \end{bmatrix}
$$

If we carry out the matrix multiplication of $V(\omega)$ in a row-wise manner, we obtain:

$$
\begin{aligned}f(1) = [1\ 1\ 1\ 1]\cdot\begin{bmatrix}a_0\\ a_1\\ a_2\\ a_3\end{bmatrix} &= 1\cdot a_0 + 1 \cdot a_1 + 1\cdot a_2 + 1\cdot a_3\\
&= a_0 + a_1 + a_2 + a_3\\[6pt]f(\omega) = [1\ \omega\ \omega^2\ \omega^3]\cdot\begin{bmatrix}a_0\\ a_1\\ a_2\\ a_3\end{bmatrix} &= 1 \cdot a_0 + \omega \cdot a_1  + \omega^2 \cdot a_2   + \omega^3 \cdot a_3 \\
&= a_0 + a_1\omega + a_2\omega^2 + a_3\omega^3\\[6pt]f(\omega^2) = [1\ \omega^2\ \omega^4\ \omega^6]\cdot\begin{bmatrix}a_0\\ a_1\\ a_2\\ a_3\end{bmatrix} &= 1 \cdot a_0 + \omega^2 \cdot a_1 + \omega^4 \cdot a_2 + \omega^6 \cdot a_3\\
&= a_0 + a_1\omega^2 + a_2\omega^4 + a_3\omega^6
\\[6pt]f(\omega^3) = [1\ \omega^3\ \omega^6\ \omega^9]\cdot\begin{bmatrix}a_0\\ a_1\\ a_2\\ a_3\end{bmatrix} &= 1 \cdot a_0 + \omega^3 \cdot a_1  + \omega^6 \cdot a_2   + \omega^9 \cdot a_3   \\
&= a_0 + a_1\omega^3 + a_2\omega^6 + a_3\omega^9
\end{aligned}
$$

Therefore, we obtain:

$$
\begin{aligned}\mathbf{y}=\begin{bmatrix}f(1) \\f(\omega) \\f(\omega^2) \\f(\omega^3)\end{bmatrix}&=\begin{bmatrix}a_0 &+& a_1 &+& a_2 &+& a_3\\a_0 &+& a_1\omega &+& a_2\omega^2 &+& a_3\omega^3 \\a_0 &+& a_1\omega^2 &+& a_2\omega^4 &+& a_3\omega^6 \\a_0 &+& a_1\omega^3 &+& a_2\omega^6 &+& a_3\omega^9\end{bmatrix}
\end{aligned}
$$

Thus, if we are given the coefficient form of a polynomial, represented by the vector $\mathbf{a}$, we can obtain its point-value form, represented by the vector $\mathbf{y}$, by left-multiplying $\mathbf{a}$ by the Vandermonde matrix $V(\omega)$. 

But what if we are given the evaluations instead, that is, the vector $\mathbf{y}$, and are asked to compute the coefficients, that is, the vector $\mathbf{a}$?

This can be done using the inverse of the Vandermonde matrix $V(\omega)$, denoted by $V^{-1}(\omega)$, through the following operation:

$$
\mathbf{a} = V(\omega)^{-1}\cdot \mathbf{y} 
$$

Our claim is that the matrix $V(\omega)^{-1}$ is given by

$$
V(\omega)^{-1} =\frac{1}{4}\begin{bmatrix}1 & 1 & 1 & 1 \\1 & \omega^{-1} & \omega^{-2} & \omega^{-3} \\1 & \omega^{-2} & \omega^{-4} & \omega^{-6} \\1 & \omega^{-3} & \omega^{-6} & \omega^{-9}\end{bmatrix}
$$

Observe that $V(\omega)^{-1}$ also has the property that each of its rows forms a geometric progression:

- 1st row: $[1 \ \ 1\ \ 1\ \ 1]$ $\rightarrow$ first term: $1$, common ratio: $1$
- 2nd row: $[1 \ \omega^{-1}\  \omega^{-2}\  \omega^{-3}]$ $\rightarrow$ first term: $1$, common ratio: $\omega^{-1}$
- 3rd row: $[1 \ \omega^{-2}\  \omega^{-4}\  \omega^{-6}]$ $\rightarrow$ first term: $1$, common ratio: $\omega^{-2}$
- 4th row: $[1 \ \omega^{-3}\  \omega^{-6}\  \omega^{-9}]$ $\rightarrow$ first term: $1$, common ratio: $\omega^{-3}$

Therefore, the inverse of the Vandermonde matrix in this case is itself another Vandermonde matrix.

In the following sections, we will show that our claim is true in this example using the $4$-th roots of unity. In the subsequent chapter, we will prove it in general.

We will prove that, in the case of $k$-th roots of unity, when the NTT is realized using the following Vandermonde matrix,

$$
V(\omega)=\begin{bmatrix}1 & 1 & 1 & \cdots & 1 \\1 & \omega & \omega^{2} & \cdots & \omega^{k-1} \\1 & \omega^{2} & \omega^{4} & \cdots & \omega^{2(k-1)} \\\vdots & \vdots & \vdots & \ddots & \vdots \\1 & \omega^{k-1} & \omega^{2(k-1)} & \cdots & \omega^{(k-1)(k-1)}\end{bmatrix},
$$

the inverse matrix $V(\omega)^{-1}$ can be obtained by replacing each power of $\omega$ with $\frac{1}{\omega}$ and dividing by a factor of $k$, as follows

$$
V(\omega)^{-1}=\frac{1}{k}\begin{bmatrix}1 & 1 & 1 & \cdots & 1 \\1 & \omega^{-1} & \omega^{-2} & \cdots & \omega^{-(k-1)} \\1 & \omega^{-2} & \omega^{-4} & \cdots & \omega^{-2(k-1)} \\\vdots & \vdots & \vdots & \ddots & \vdots \\1 & \omega^{-(k-1)} & \omega^{-2(k-1)} & \cdots & \omega^{-(k-1)(k-1)}\end{bmatrix}.
$$

The inverse Vandermonde matrix, when multiplied by the vector of evaluations of a given polynomial at the roots of unity, returns the coefficient vector of that polynomial.

## Evaluating $V(\omega)^{-1} \cdot \mathbf{y}$

To demonstrate that the matrix multiplication between $V(\omega)^{-1}$ and $\mathbf{y}$ gives us back the coefficient vector $\mathbf{a}$, let us use our earlier example, where $f(x)=a_0+a_1x+a_2x^2+a_3x^3$, $S=\{1,\omega,\omega^2,\omega^3\}$ and $k=4$.

Recall that $\mathbf{y}$, the vector of evaluations of $f(x)$ at the points in $S$, is given by:

$$
\begin{aligned}\mathbf{y}=\begin{bmatrix}f(1) \\f(\omega) \\f(\omega^2) \\f(\omega^3)\end{bmatrix}&=\begin{bmatrix}a_0 &+& a_1 &+& a_2 &+& a_3\\a_0 &+& a_1\omega &+& a_2\omega^2 &+& a_3\omega^3 \\a_0 &+& a_1\omega^2 &+& a_2\omega^4 &+& a_3\omega^6 \\a_0 &+& a_1\omega^3 &+& a_2\omega^6 &+& a_3\omega^9\end{bmatrix}
\end{aligned}
$$

Let us perform the matrix multiplication between $V(\omega)^{-1}$ and $\mathbf{y}$:

$$
\begin{aligned}
\tilde{\mathbf{a}} &= V(\omega)^{-1}\cdot \mathbf{y} \\
\begin{bmatrix}\tilde{a_0} \\\tilde{a_1} \\\tilde{a_2} \\\tilde{a_3}\end{bmatrix}&= \frac{1}{4}\begin{bmatrix}1 & 1 & 1 & 1 \\1 & \omega^{-1} & \omega^{-2} & \omega^{-3} \\1 & \omega^{-2} & \omega^{-4} & \omega^{-6} \\1 & \omega^{-3} & \omega^{-6} & \omega^{-9}\end{bmatrix}\begin{bmatrix}f(1) \\f(\omega) \\f(\omega^2) \\f(\omega^3)\end{bmatrix}
\end{aligned}
$$

We aim to show that the vector $\tilde{\mathbf{a}}$ obtained from the above matrix multiplication is equal to the coefficient vector $\mathbf{a}$ of $f(x)$.

Substituting the evaluations $f(1),f(\omega),f(\omega^2)$ and $f(\omega^3)$ from the vector $\mathbf{y}$, we can compute the coefficients $\tilde{\mathbf{a}}$ as:

$$
\begin{aligned}
\tilde{\mathbf{a}} &= V(\omega)^{-1}\cdot \mathbf{y} \\

\begin{bmatrix}\tilde{a_0} \\\tilde{a_1} \\\tilde{a_2} \\\tilde{a_3}\end{bmatrix} &= \frac{1}{4}\begin{bmatrix}1 & 1 & 1 & 1 \\1 & \omega^{-1} & \omega^{-2} & \omega^{-3} \\1 & \omega^{-2} & \omega^{-4} & \omega^{-6} \\1 & \omega^{-3} & \omega^{-6} & \omega^{-9}\end{bmatrix}\begin{bmatrix}a_0 &+& a_1 &+& a_2 &+& a_3\\a_0 &+& a_1\omega &+& a_2\omega^2 &+& a_3\omega^3 \\a_0 &+& a_1\omega^2 &+& a_2\omega^4 &+& a_3\omega^6 \\a_0 &+& a_1\omega^3 &+& a_2\omega^6 &+& a_3\omega^9\end{bmatrix}
\end{aligned}
$$

We now show that the vectors $\tilde{\mathbf{a}}$ and ${\mathbf{a}}$ are equal. In other words, we want to show that

$$
\begin{aligned}
\tilde{a_0} &= a_0, \\
\tilde{a_1} &= a_1, \\
\tilde{a_2} &= a_2, \\
\tilde{a_3} &= a_3. \\
\end{aligned}
$$

### Calculating the coefficients $\tilde{a_0},\tilde{a_1},\tilde{a_2}$ and $\tilde{a_3}$

Let us carry out the matrix multiplication row by row on the right-hand side (RHS) to see how the corresponding coefficients on the left-hand side (LHS) are obtained. For the coefficient $\tilde{a_0}$, we take the dot product of the first row of $V(\omega)^{-1}$ with the vector $\mathbf{y}$:

$$
\begin{aligned}
\begin{bmatrix}\color{red}\tilde{a_0} \\\tilde{a_1} \\\tilde{a_2} \\\tilde{a_3}\end{bmatrix} &= \frac{1}{4}\begin{bmatrix}\color{red}1 & \color{red}1 & \color{red}1 & \color{red}1 \\1 & \omega^{-1} & \omega^{-2} & \omega^{-3} \\1 & \omega^{-2} & \omega^{-4} & \omega^{-6} \\1 & \omega^{-3} & \omega^{-6} & \omega^{-9}\end{bmatrix}\begin{bmatrix}\color{red}f(1) \\ \color{red}f(\omega) \\\color{red}f(\omega^2) \\\color{red}f(\omega^3)\end{bmatrix} \\
\end{aligned}

$$

$$
\begin{aligned}
&\quad \quad\text{ \ \ Dot product of the first row of } V(\omega)^{-1} \text{ with } \mathbf{y}\\
\tilde{a_0}&= \frac{1}{4}\big(1\cdot f(1)+1\cdot f(\omega)+1\cdot f(\omega^2)+1\cdot f(\omega^3)\big) \\[6pt]
&=\frac{1}{4}\Big(1\cdot \underbrace{(a_0+a_1+a_2+a_3)}_{f(1)} \\
&\qquad\; + 1\cdot \underbrace{(a_0+a_1\omega+a_2\omega^2+a_3\omega^3)}_{f(\omega)}\\
&\qquad\; + 1\cdot \underbrace{(a_0+a_1\omega^2+a_2\omega^4+a_3\omega^6)}_{f(\omega^2)}\\
&\qquad\; + 1\cdot \underbrace{(a_0+a_1\omega^3+a_2\omega^6+a_3\omega^9)}_{f(\omega^3)}\Big)\\[6pt]
&=\frac{1}{4}\Big(4a_0 \;+\; a_1(1+\omega+\omega^2+\omega^3) \\
&\qquad\; +\; a_2(1+\omega^2+\omega^4+\omega^6) \\
&\qquad\; +\; a_3(1+\omega^3+\omega^6+\omega^9)\Big)
\end{aligned}
$$

Recall from the previous chapter that, since $\omega$ is a primitive $4$-th root of unity, the sum 

$$
\sum_{k=0}^3 \omega^{mk}
$$

is equal to zero whenever $m$ is not a multiple of $4$. Explicitly,

$$

\sum_{k=0}^3 \omega^{mk}
= \omega^{m\cdot 0} + \omega^{m\cdot 1} + \omega^{m\cdot 2} + \omega^{m\cdot 3}
\\= 1 + \omega^m + \omega^{2m} + \omega^{3m}=0\\
$$

For a detailed look at this concept, please refer to the article on [Orthogonality of Roots of Unity](https://rareskills.io/post/orthogonality-of-roots-of-unity). 
By substituting values of $m$ that are not multiples of $4$, we obtain the following identities:

$$
\begin{aligned}
\text{for } m&=1 &\rightarrow& 1+\omega+\omega^2+\omega^3=0, \quad \\\text{for }m&=2&\rightarrow&1+\omega^2+\omega^4+\omega^6=0 , \quad \\\text{for }m&=3&\rightarrow&1+\omega^3+\omega^6+\omega^9=0, \quad \\
\text{for }m&=-1&\rightarrow&1+\omega^{-1}+\omega^{-2}+\omega^{-3}=0, \quad  \\\text{for }m&=-2&\rightarrow&1+\omega^{-2}+\omega^{-4}+\omega^{-6}=0, \quad \\\text{for }m&=-3&\rightarrow&1+\omega^{-3}+\omega^{-6}+\omega^{-9}=0, \quad
\end{aligned}
$$

Therefore, all terms multiplying $a_1$, $a_2$, and $a_3$ vanish, leaving

$$
\begin{aligned}
\tilde{a_0}&=\frac{1}{4}\Big(4a_0 \;&+&\; a_1\underbrace{(1+\omega+\omega^2+\omega^3)}_{=\,0} \\
&\qquad\; &+&\; a_2\underbrace{(1+\omega^2+\omega^4+\omega^6)}_{=\,0} \\
&\qquad\; &+&\; a_3\underbrace{(1+\omega^3+\omega^6+\omega^9)}_{=\,0}\Big) \\
\tilde{a_0}&=\frac{1}{4}\cdot 4a_0 \\
&= a_0\\
\end{aligned}
$$

Similarly, to compute 
$\tilde{a_1}$, we take the dot product of the second row of $V(\omega)^{-1}$ with $\mathbf{y}$:

$$
\begin{aligned}
\begin{bmatrix}\tilde{a_0} \\\color{red}\tilde{a_1} \\\tilde{a_2} \\\tilde{a_3}\end{bmatrix} &= \frac{1}{4}\begin{bmatrix}1 & 1 & 1 & 1 \\\color{red}1 & \color{red}\omega^{-1} & \color{red}\omega^{-2} & \color{red}\omega^{-3} \\1 & \omega^{-2} & \omega^{-4} & \omega^{-6} \\1 & \omega^{-3} & \omega^{-6} & \omega^{-9}\end{bmatrix}\begin{bmatrix}\color{red}f(1) \\ \color{red}f(\omega) \\\color{red}f(\omega^2) \\\color{red}f(\omega^3)\end{bmatrix} \\
\end{aligned}

$$

$$
\begin{aligned}
&\qquad \text{Dot product of 2nd row of } V(\omega)^{-1} \text{ with } \mathbf{y} \\
\tilde{a_1}
&= \frac{1}{4}\big(1\cdot f(1) + \omega^{-1}f(\omega) + \omega^{-2}f(\omega^2) + \omega^{-3}f(\omega^3)\big) \\[6pt]
\end{aligned}
$$

Substituting the expressions for the evaluations $f(1), f(\omega), f(\omega^2)$ and $f(\omega^3)$, we get,

$$
\begin{aligned}
\tilde{a_1}
&= \frac{1}{4}\Big(
    1(a_0+a_1+a_2+a_3) \\
&\qquad + \omega^{-1}(a_0 + a_1\omega + a_2\omega^2 + a_3\omega^3) \\
&\qquad + \omega^{-2}(a_0 + a_1\omega^2 + a_2\omega^4 + a_3\omega^6) \\
&\qquad + \omega^{-3}(a_0 + a_1\omega^3 + a_2\omega^6 + a_3\omega^9)
\Big) \\[6pt]
 
\end{aligned}
$$

Grouping the terms to get the factors of $a_0,a_1,a_2$ and $a_3$ yields

$$
\begin{aligned}
\tilde{a_1}
&= \frac{1}{4}\Big(
    a_0(1+\omega^{-1}+\omega^{-2}+\omega^{-3}) \\
&\qquad + a_1(1+\omega^{-1}\omega+\omega^{-2}\omega^2+\omega^{-3}\omega^3) \\
&\qquad + a_2(1+\omega^{-1}\omega^2+\omega^{-2}\omega^4+\omega^{-3}\omega^6) \\
&\qquad + a_3(1+\omega^{-1}\omega^3+\omega^{-2}\omega^6+\omega^{-3}\omega^9)
\Big) \\[6pt]
&= \frac{1}{4}\Big(
    a_0(1+\omega^{-1}+\omega^{-2}+\omega^{-3}) + 4a_1 \\
&\qquad + a_2(1+\omega^{1}+\omega^{2}+\omega^{3}) \\
&\qquad + a_3(1+\omega^{2}+\omega^{4}+\omega^{6})
\Big)
\end{aligned}
$$

Again, the terms within the parentheses associated with the factors of $a_0,a_2,a_3$ vanish, leaving

$$
\begin{aligned}
\tilde{a_1}&=\frac{1}{4}\cdot 4a_1 = a_1\\
\end{aligned}
$$

Try expanding the multiplication for $\tilde{a_2}$ and $\tilde{a_3}$ on your own and observe how they simplify according to the same logic we have used above. You will find that $\tilde{a_2}=a_2$ and $\tilde{a_3} = a_3$, as expected.

This completes the demonstration that $V(\omega)^{-1} \cdot \mathbf{y} = \mathbf{a}$. With this, we have shown that the inverse of the Vandermonde matrix for the case $k=4$ is also a Vandermonde matrix. The case for a general value of $k$ will be proved in the subsequent chapter.

This article is part of a series on the Number Theoretic Transform in our [ZK Book](https://rareskills.io/zk-book)
