# Historical Results And Evidence Boundaries

No newly reproduced measured-data localization metric is reported. Historical
presentation claims are retained below as claims, with their limitations. New
software checks use only small artificial arrays and establish no field accuracy.

| Historical item | What it establishes | What is not established |
| --- | --- | --- |
| Workbooks with 40/16 rows and three WiFi features | Small measured-data offline coordinate task; measured origin is participant-reported | Site, timestamps, raw sampling, calibration, public license |
| Saved x/y figures and slide learning curves | Historical plotting artifacts exist | Fresh reproduction, matched implementation, confidence intervals |
| Lower FrRLS-labelled x-axis curve in the presentation | A historical qualitative observation | Isolated fractional benefit, general superiority, deployment acceptance |
| Slide/report claim of 4.2 to 1.8 m or 57% | A claim in presentation materials | Recomputed paired 2D RMSE or verified independent performance |
| RSSI row-index and residual histograms | Exploratory variability visualization | Time evolution, proven NLOS, identified multipath, temporal nonstationarity |
| Other geometric-localization slides or UWB literature results | Separate simulations and literature discussion | Scores of this WiFi fingerprint component |

## Metrics Must Match The Task

The source computes per-axis MSE on 16 fixed test rows and plots 10log10(MSE).
For paired coordinate predictions, a future evaluation could compute
`sqrt(mean((x_pred-x_true)^2 + (y_pred-y_true)^2))` for 2D RMSE. That value is
not obtained by directly subtracting dB curves or attaching metres to their
ordinate. A single point's Euclidean error is also not a repeated-run RMSE.

## Interpretation Of The RSSI Figure

Rows correspond to fingerprint records at different coordinates, not known
equally spaced observations over time at a fixed point. Differences can reflect
spatial signal structure as well as measurement disturbances. Residual tails
depend on the fitted trend and on pooling different channels/locations. A
histogram, especially with small sample size and missing condition labels,
cannot identify a physical source of noise or establish nonstationarity.

## Validation Performed In This Archive

The private audit records workbook schema/count checks, content hashes and
duplicate/version comparisons. The public CSV inspector and MATLAB micro tests use artificial fixtures. The
MATLAB tests execute four historical classes, four sequence helper functions,
the stable-noise helper, and a CSV-wrapper round trip with four training/two
test rows. These are software checks, not course-data retraining, field or
hardware validation, full benchmark reproduction, or parameter selection.
