# Data note: UJIIndoorLoc

The original teaching project uses the public UJIIndoorLoc dataset as a classroom example. This staging component intentionally does **not** redistribute the CSV files or the extracted example record.

## How to obtain it

Use the official UCI page: <https://archive.ics.uci.edu/dataset/310/ujiindoorloc>. The dataset is identified in the source notes as DOI `10.24432/C5MS59` and CC BY 4.0. Follow the dataset page for the current download and license terms.

## Relevant format

The source-side example expects:

- 520 WAP/RSS fields as the signal vector;
- `LONGITUDE`, `LATITUDE` as the recorded planar coordinate fields used by the example;
- `FLOOR` and `BUILDINGID` for the conditional classroom selection;
- training and validation CSVs with the same WAP field layout.

The local extraction script replaces the dataset's “not detected” RSS marker `100` with `-110` for the distance calculation, uses all 520 WAP dimensions, and takes four same-building/same-floor nearest records. Those details are documented here so the example's assumptions are visible; the raw files and extracted coordinates remain excluded.

## Interpretation boundary

The example supplies the true building and floor before searching within the training set. It demonstrates a two-dimensional, same-floor weighted-neighbor calculation. It is not an end-to-end building/floor/coordinate benchmark and must not be presented as one.
