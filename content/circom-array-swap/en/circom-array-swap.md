# Swapping Two Items in an Array in Circom

This chapter shows how to swap two signals in a list of signals. This is an important subroutine for a sorting algorithm. More generally, lists are a fundamental building block for more interesting functions like hash functions or modeling memory in a CPU, so we must learn how to update their values.

Swapping two items in a list is one of the first things programmers learn, a typical solution looks like the following:

```python
# s and t are indexes of array arr
def swap(arr, s, t):
  temp = arr[s];
  arr[s] = arr[t];
  arr[t] = temp;
  return arr
```

However, in a ZK circuit, this operation can be surprisingly tricky.

- First, we cannot directly index an array of signals. For that, we need to use a Quin selector.
- Second, we cannot “write to” a signal in an array of signals because signals are immutable.

Instead, we need to create a new array and copy the old values to the new array, subject to the following conditions:

- If we are at index `s`, write the value at `arr[t]`
- If we are at index `t`, write the value at `arr[s]`
- Otherwise, write the original value

Every write we make to the new array is a conditional operation.

The Quin selector was explained in a prior chapter — we won’t replicate the code here to save space.

## Swap in Circom

The component below will swap the item at index `s` with the item at index `t` and return a new array. (The following code has a bug, try to find it! The answer is given later.)

```jsx
template Swap(n) {
  signal input in[n];
  signal input s;
  signal input t;
  signal output out[n];
  
  // we do not check that
  // s < n or t < n
  // because the Quin selector
  // does that

  // get the value at s
  component qss = QuinSelector(n);
  qss.idx <== s;
  for (var i = 0; i < n; i++) {
    qss.in[i] <== in[i];
  }

  // get the value at t
  component qst = QuinSelector(n);
  qst.idx <== t;
  for (var i = 0; i < n; i++) {
    qst.in[i] <== in[i];
  }
  
  // qss.out holds in[s]
  // qst.out holds in[t]

  component IdxEqS[n];
  component IdxEqT[n];
  component IdxNorST[n];
  signal branchS[n];
  signal branchT[n];
  signal branchNorST[n];
  for (var i = 0; i < n; i++) {
    IdxEqS[i] = IsEqual();
    IdxEqS[i].in[0] <== i;
    IdxEqS[i].in[1] <== s;

    IdxEqT[i] = IsEqual();
    IdxEqT[i].in[0] <== i;
    IdxEqT[i].in[1] <== t;

    // if IdxEqS[i].out + IdxEqT[i].out
    // equals 0, then it is not i ≠ s and i ≠ t
    IdxNorST[i] = IsZero();
    IdxNorST[i].in <== IdxEqS[i].out + IdxEqT[i].out;

    // if we are at index s,
    // write in[t]
    // if we are at index t,
    // write in[s]
    // else write in[i]
    branchS[i] <== IdxEqS[i].out * qst.out;
    branchT[i] <== IdxEqT[i].out * qss.out;
    branchNorST[i] <== IdxNorST[i].out * in[i];
    out[i] <==  branchS[i] + branchT[i] + branchNorST[i];
  }
}
```

Note that the final conditional statement

```jsx
branchS[i] <== IdxEqS[i].out * qst.out;
branchT[i] <== IdxEqT[i].out * qss.out;
branchNorST[i] <== IdxNorST[i].out * in[i];
out[i] <==  branchS[i] + branchT[i] + branchNorST[i];
```

cannot be written as

```jsx
out[i] <==  IdxEqS[i].out * qst.out + IdxEqT[i].out * qss.out + IdxNorST[i].out * in[i]
```

because that would produce a non-quadratic constraints error (there is more than one multiplication in the constraint).

## Catch the bug

There is a bug in the code above — can you catch it before scrolling down?

## The bug in the code

The problem with the code above is that it doesn’t account for the fact that the value at `s` might equal the value at `t` (`s == t`). In that circumstance, the value written to the index will be the value at that index added to itself. 

## Fixing the problem

To prevent this, we need to explicitly detect if `s == t` and multiply one of either `branchS` or `branchT` by zero to avoid doubling the value. In other words, if the switches for `s` and `t` are both active, then the resulting value would be `s + t`. But we don’t want that, we want the value to effectively remain unchanged by selecting `branchS` or `branchT` arbitrarily (they will have the same value):

```jsx
template Swap(n) {
  signal input in[n];
  signal input s;
  signal input t;
  signal output out[n];

  // NEW CODE to detect if s == t
  signal sEqT;
  sEqT <== IsEqual()([s, t]);

  // get the value at s
  component qss = QuinSelector(n);
  qss.idx <== s;
  for (var i = 0; i < n; i++) {
    qss.in[i] <== in[i];
  }

  // get the value at t
  component qst = QuinSelector(n);
  qst.idx <== t;
  for (var i = 0; i < n; i++) {
    qst.in[i] <== in[i];
  }

  component IdxEqS[n];
  component IdxEqT[n];
  component IdxNorST[n];
  signal branchS[n];
  signal branchT[n];
  signal branchNorST[n];
  for (var i = 0; i < n; i++) {
    IdxEqS[i] = IsEqual();
    IdxEqS[i].in[0] <== i;
    IdxEqS[i].in[1] <== s;

    IdxEqT[i] = IsEqual();
    IdxEqT[i].in[0] <== i;
    IdxEqT[i].in[1] <== t;

    // if IdxEqS[i].out + IdxEqT[i].out
    // equals 0, then it is not i ≠ s and i ≠ t
    IdxNorST[i] = IsZero();
    IdxNorST[i].in <== IdxEqS[i].out + IdxEqT[i].out;

    // if we are at index s, write in[t]
    // if we are at index t, write in[s]
    // else write in[i]
    branchS[i] <== IdxEqS[i].out * qst.out;
    branchT[i] <== IdxEqT[i].out * qss.out;
    branchNorST[i] <== IdxNorST[i].out * in[i];
    
    // multiply branchS by zero if s equals T
    out[i] <==  (1-sEqT) * (branchS[i]) + branchT[i] + branchNorST[i];
  }
}
```

## Conclusion

Any array manipulation in Circom requires creating a new array and copying the old values to the new one, except where the update happens.

By using this pattern in a loop, we can do things like sort a list, model data structures like stacks and queues, and even change the state of a CPU or VM. We will see examples of those in the following chapters.