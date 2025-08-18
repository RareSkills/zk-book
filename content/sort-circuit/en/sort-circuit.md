# ZK Proof of Selection Sort

Most computations of interest are generally “stateful” — that is, they need to go through a series of steps to produce the final result.

Sometimes, we do not need to show we executed the computation but only show the result. For example, if A is a list, we can prove B is the sorted version of list A by showing B is a permutation of A, and all the elements of B are in order. There is no need to show that we executed each step of the sorting algorithm correctly. We’ve already shown how to prove the elements of a list are in order, but efficiently proving that one list is a permutation of the other is surprisingly tricky, so we will introduce that technique later.

In general, there are many realistic computations that do not allow for simply proving that the result is correct. Notably, proving that we correctly executed `sha256("RareSkills")` requires actually executing every step of the hash function correctly.

Since hash functions are a bit intimidating, we introduce the concept of stateful computation by showing how to prove we carried out Selection Sort on a list correctly. As noted above, this approach is “overkill” because it is simpler to prove the output list is a sorted permutation of the input — it does not matter what algorithm we used to sort the list.

However, we still show the Selection Sort algorithm as we consider it a gentle introduction to stateful computation.

Selection Sort works by

- iterating through the list
- at each index `i`, comparing the value at `i` to the sublist containing `i` and every item in front (`i..n-1` inclusive)
- swapping the item at `i` with the minimum of the sublist `i..n-1`

Selection Sort is illustrated in the animation below:

<video src="https://r2media.rareskills.io/SortCircuit/SelectionSortC.mp4" type="video/mp4" autoplay loop muted controls></video>

Since signals are immutable in ZK circuits, every time we swap, we need to create a new list. For example, if we sorted [5,2,3,4], the sequence of state transitions would be:

1. i = 0, [5,2,3,4] —> swap —> [2,5,3,4]
2. i = 1, [2,5,3,4] —> swap —> [2,3,5,4]
3. i = 2, [2,3,5,4] —> swap —> [2,3,4,5]

To prove we executed Selection Sort properly, we need to prove that at iteration `i`, we swapped the item at `i` with the minimum of the sublist `i…n - 1`. We’ve already built up most of the requisite components for this in the previous chapters:

- We can prove that a certain item is a minimum of a list, and that it is at a certain index.
- We can prove that we swapped two items in a list.

In this chapter, we simply combine these components together. To start, we build a template that proves we correctly identified the index of the minimum value in a sublist:

```jsx
template GetMinAtIdx(n) {
  signal input in[n];
  
  // compute and constrain min and idx
  // to be the min value in the list
  // and the index of the minimum value
  signal output min;
  signal output idx;

  // compute the minimum and its index
  // outside of the constraints
  var minv = in[0];
  var idxv = 0;
  for (var i = 1; i < n; i++) {
    if (in[i] < minv) {
      minv = in[i];
      idxv = i;
    }
  }
  min <-- minv;
  idx <-- idxv;

  // constrain that min is ≤ all others
  component lte[n];
  for (var i = 0 ; i < n; i++) {
    lte[i] = LessEqThan(252);
    lte[i].in[0] <== min;
    lte[i].in[1] <== in[i];
    lte[i].out === 1;
  }
  
  // assert min is really at in[idx]
  component qs = QuinSelector(n);
  qs.index <== idx;
  for (var i = 0; i < n; i++) {
    qs.in[i] <== in[i];
  }
  qs.out === min;
}
```

## One iteration of the sorting algorithm

The first step in Selection Sort is to swap the item at index 0 with the minimum item in the entire list (which could be the item at index 0). Below is the code for swapping the number at a particular index with the minimum item in front of it.

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
  qss.index <== s;
  for (var i = 0; i < n; i++) {
    qss.in[i] <== in[i];
  }

  // get the value at t
  component qst = QuinSelector(n);
  qst.index <== t;
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
    dxEqS[i] = IsEqual();
    dxEqS[i].in[0] <== i;
    dxEqS[i].in[1] <== s;

    dxEqT[i] = IsEqual();
    dxEqT[i].in[0] <== i;
    dxEqT[i].in[1] <== t;

    / if IdxEqS[i].out + IdxEqT[i].out
    / equals 0, then it is not i ≠ s and i ≠ t
    dxNorST[i] = IsZero();
    dxNorST[i].in <== IdxEqS[i].out + IdxEqT[i].out;

    / if we are at index s, write in[t]
    / if we are at index t, write in[s]
    / else write in[i]
    ranchS[i] <== IdxEqS[i].out * qst.out;
    ranchT[i] <== IdxEqT[i].out * qss.out;
    ranchNorST[i] <== IdxNorST[i].out * in[i];
    
    / multiply branchS by zero if s equals t
    ut[i] <==  (1-sEqT) * (branchS[i]) + branchT[i] + branchNorST[i];
  }
}

template Select(n, start) {
  // unsorted list
  signal input in[n];
  
  // index start swapped with the min
  signal output out[n];

  // we will define GetMinAtIdxStartingAt in the next codeblock
  component minIdx0 = GetMinAtIdxStartingAt(n, start);
  for (var i = 0; i < n; i++) {
      minIdx0.in[i] <== in[i];
  }

  component Swap0 = Swap(n);
  Swap0.s <== start; // swap 0 with the min
  Swap0.t <== minIdx0.idx; // with the min (could be idx 0)
  for (var i = 0; i < n; i++) {
      Swap0.in[i] <== in[i];
  }

  // copy to out
  for (var i = 0; i < n; i++) {
      out[i] <== Swap0.out[i];
  }
}
```

Of course, we ought to parameterize this because we are going to repeat this process for indexes `0…n - 2`. To do this, we will modify `GetMinAtIdx` to only consider values after a `start` index:

```jsx
// formerly GetMinAtIdx
template GetMinAtIdxStartingAt(n, start) {
  signal input in[n];
  signal output min;
  signal output idx;

  // only look for values start and later
  var minv = in[start];
  var idxv = start;
  for (var i = start + 1; i < n; i++) {
    if (in[i] < minv) {
      minv = in[i];
      idxv = i;
    }
  }
  min <-- minv;
  idx <-- idxv;

  // only compare to values start and later
  component lt[n];
  
  // CHANGES HERE: LOOP FROM START TO N-1
  for (var i = start ; i < n; i++) {
    lt[i] = LessEqThan(252);
    lt[i].in[0] <== min;
    lt[i].in[1] <== in[i];
    lt[i].out === 1;
  }

  // Quin Selector -- ensure that
  // assert min is really at in[idx]
  component qs = QuinSelector(n);
  qs.index <== idx;
  for (var i = 0; i < n; i++) {
    qs.in[i] <== in[i];
  }
  qs.out === min;
}
```

## Final Algorithm

To prove we carried out Selection Sort properly, we simply repeat the template above `n - 2` times.

```jsx
include "circomlib/comparators.circom";

// ----QUIN SELECTOR ----
template CalculateTotal(n) {
  signal input in[n];
  signal output out;

  signal sums[n];

  sums[0] <== in[0];

  for (var i = 1; i < n; i++) {
    sums[i] <== sums[i-1] + in[i];
  }

  out <== sums[n-1];
}

// from https://github.com/darkforest-eth/circuits/blob/master/perlin/QuinSelector.circom
template QuinSelector(choices) {
  signal input in[choices];
  signal input index;
  signal output out;
  
  // Ensure that index < choices
  component lessThan = LessThan(4);
  lessThan.in[0] <== index;
  lessThan.in[1] <== choices;
  lessThan.out === 1;

  component calcTotal = CalculateTotal(choices);
  component eqs[choices];

  // For each item, check whether its index equals the input index.
  for (var i = 0; i < choices; i ++) {
    eqs[i] = IsEqual();
    eqs[i].in[0] <== i;
    eqs[i].in[1] <== index;

    // eqs[i].out is 1 if the index matches. As such, at most one input to
    // calcTotal is not 0.
    calcTotal.in[i] <== eqs[i].out * in[i];
  }

  // Returns 0 + 0 + 0 + item
  out <== calcTotal.out;
}

// Given array in[n]
// swap the items at index
// s and t
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
  qss.index <== s;
  for (var i = 0; i < n; i++) {
    qss.in[i] <== in[i];
  }

  // get the value at t
  component qst = QuinSelector(n);
  qst.index <== t;
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
    
    // multiply branchS by zero if s equals t
    out[i] <==  (1-sEqT) * (branchS[i]) + branchT[i] + branchNorST[i];
  }
}

// Find the smallest element starting
// at index start
template GetMinAtIdxStartingAt(n, start) {
  signal input in[n];
  signal output min;
  signal output idx;

  // only look for values start and later
  var minv = in[start];
  var idxv = start;
  for (var i = start + 1; i < n; i++) {
    if (in[i] < minv) {
      minv = in[i];
      idxv = i;
    }
  }
  min <-- minv;
  idx <-- idxv;

  // only compare to values start and later
  component lt[n];
  
  // CHANGES HERE: LOOP FROM START TO N-1
  for (var i = start ; i < n; i++) {
    lt[i] = LessEqThan(252);
    lt[i].in[0] <== min;
    lt[i].in[1] <== in[i];
    lt[i].out === 1;
  }

  // Quin Selector -- ensure that
  // assert min is really at in[idx]
  component qs = QuinSelector(n);
  qs.index <== idx;
  for (var i = 0; i < n; i++) {
    qs.in[i] <== in[i];
  }
  qs.out === min;
}

// Given an array in, swap
// start with the smallest element
// in front of it
template Select(n, start) {
  // unsorted list
  signal input in[n];
  
  // index 0 swapped with the min
  signal output out[n];

  component minIdx0 = GetMinAtIdxStartingAt(n, start);
  for (var i = 0; i < n; i++) {
    minIdx0.in[i] <== in[i];
  }

  component Swap0 = Swap(n);
  Swap0.s <== start; // swap 0 with the min
  Swap0.t <== minIdx0.idx; // with the min (could be idx 0)
  for (var i = 0; i < n; i++) {
    Swap0.in[i] <== in[i];
  }

  // copy to out
  for (var i = 0; i < n; i++) {
    out[i] <== Swap0.out[i];
  }
}

// ---- CORE ALGORITHM ----
template SelectionSort(n) {
  assert(n > 0);

  signal input in[n];
  signal output out[n];

  signal intermediateStates[n][n];

  component SSort[n - 1];
  for (var i = 0; i < n; i++) {
    // copy the input to the first row of
    // intermediateStates. Note that we can do
    // if(i == 0) because i is not a signal
    // and i is known at compile time
    if (i == 0) {
      for (var j = 0; j < n; j++) {
        intermediateStates[0][j] <== in[j];
      }
    }

    else {
      // select sort n items starting at i - 1
      // for i = 1, we compare item at 0 to
      // the rest of the list
      SSort[i - 1] = Select(n, i - 1);
      
      // load in the intermediate state i -1
      for (var j = 0; j < n; j++) {
        SSort[i - 1].in[j] <== intermediateStates[i - 1][j];
      }
      // write the sorted result to row i
      for (var j = 0; j < n; j++) {
        SSort[i - 1].out[j] ==> intermediateStates[i][j];
      }
    }
  }

  // write the final state to the ouput
  for (var i = 0; i < n; i++) {
    intermediateStates[n-1][i] ==> out[i];
  }
}

component main = SelectionSort(9);

/* INPUT = {"in": [3,1,8,2,4,0,1,2,4]} */
```

# Conclusion

The concept of an “intermediate state” and proving that we moved between intermediate states correctly is core to the verification of most ZK algorithms proved in practice, notably hash functions and ZK Virtual Machines. The Selection Sort algorithm presented in this chapter provides a gentle introduction to stateful computation.
