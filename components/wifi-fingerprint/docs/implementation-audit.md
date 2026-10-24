# Historical Implementation Audit

Historical MATLAB files are preserved byte for byte. The archive additionally
provides a separate CSV wrapper and micro synthetic tests; it does not repair
the historical equations or rerun course measurements.

## Version Selection

`Program/` is the audited coordinate experiment. A second copy under
`代码/Program/` is byte-identical for all 12 files, including six MATLAB sources,
two workbooks and four saved figures. It is a duplicate, not independent work.

`Program.zip` is an older snapshot containing the two workbooks, two coordinate
entry scripts and LMS/RLS classes, but no fractional classes. Both workbooks
and the LMS class match the current files. RLS and the two entry scripts differ.
Snapshot order does not establish authorship or a redistribution license.

## Current Coordinate Settings

| Setting | Observed value |
| --- | --- |
| Source features | Three WiFi RSSI columns |
| Training / testing rows | 40 / 16 |
| Coordinate models | Separate x and y linear predictors, no explicit intercept |
| Random initialization | `rng(005)` in each entry script |
| LMS step size | 0.00001 |
| FrLMS step size / order | 0.00001 / 0.8 |
| FrRLS order | 1 |
| Dictionary-size setting | Inf, with stored rows but linear dot-product prediction |
| Active training passes | One |
| Curve ordinate | 10*log10 of per-axis test MSE |

The `dict` property does not make these kernel models. Predictions use the
linear weight/input dot product; stored rows mainly determine initialization
state and the update-count limit.

## Findings That Limit Comparison

1. **RLS state shape and initialization differ.** Baseline `rls_r` starts with
   scalar `P=eye(1)` and retains scalar state through a row-vector gain product.
   Its first sample initializes state but does not update weights using its
   target. `Fr_rls_r` updates weights on the first sample and expands the scalar
   state through a column-vector outer-product subtraction. Scalar expansion
   is not a feature-dimensional identity initialization. These implementations
   are not a controlled ordinary/fractional RLS pair.
2. **Order one is not fractional evidence.** With alpha=1, the implemented input
   transform is the input itself and g=abs(error)^(1-alpha) is unity under the
   MATLAB power convention. Observed curve gaps do not isolate a fractional
   influence. With other orders, division by g, zero errors, denominators and
   matrix conditioning require numerical checks not supplied by a name alone.
3. **Training order differs by axis.** The y entry shuffles training features and
   matching targets. The x entry does not; its random permutation of 16 is
   unused. A common seed does not create a matched x/y order here.
4. **Unused allocations affect plotting.** MSE is preallocated for 1000 updates,
   five methods and ten trials, but 40 updates, four methods and one trial are
   populated. The scripts plot full columns, so unused zeros yield negative
   infinity under log10. Ten allocated trial slots are not ten completed runs.
5. **Test reuse needs careful reporting.** The same 16 test samples are evaluated
   after each training update. This describes a learning curve, not an untouched
   final evaluation if parameters are selected by inspecting those curves.
6. **No explicit temporal fractional convolution is implemented.** The formulas
   apply powers to current errors/features with recursive state. No stored
   history-kernel convolution establishes a physical long-memory channel.

## Separate Synthetic Benchmark

`FrLMS&FrRLS/MAIN.m` uses a Mackey-Glass series plus saved alpha-stable noise,
seven-dimensional embedding, 1000 training points and 100 test points. Its
FrRLS order is 1.32 and its initialization differs by method. This benchmark is
not the 40/16 measured-coordinate experiment. Its plot uses `10*log`, not
`10*log10`; the values therefore must not be relabelled as dB without conversion.
The `stblrnd.m` noise helper includes its `genOutsize` local function. An earlier
handoff incorrectly described this helper as missing; direct inspection corrected
that statement. MAT series/noise files are excluded, and the full benchmark was
not rerun. The generator receives only a four-value synthetic smoke check.

## Possible Follow-Up, Not Changes Made

For a future methodological revision, use a separate revision to unify
the baseline equations, feature-dimensional initialization, training order,
valid curve length and saved per-point predictions. Tune on a validation set,
reserve a final test set, and report repeated-seed results and order ablations.
Do not rewrite the historical files or present a corrected rerun as the original
result. No such rerun is claimed here.
