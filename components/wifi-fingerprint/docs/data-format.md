# Data Format And Acquisition

## Private CSV Contract

The required UTF-8 or UTF-8-with-BOM header is exactly:

```text
x,y,RSSI A,RSSI B,RSSI C
```

No measurement rows are shipped. Every record must contain five finite numeric
values. Blank records, missing values, additional columns, duplicate headers,
NaN and infinity are rejected. Row ordering is retained conceptually; the
inspector does not reorder, normalize, train on, or write the supplied files.

| Field | Historical role | Unit boundary |
| --- | --- | --- |
| x | Supervised x-coordinate target | Preserve the source coordinate system; independently confirm units |
| y | Supervised y-coordinate target | Preserve the source coordinate system; independently confirm units |
| RSSI A/B/C | Three processed Wi-Fi features | Raw dBm/sign/normalization are not established |

The default expected counts are 40 training rows and 16 test rows. They describe
this historical component, not a universal dataset split. Duplicate coordinate
pairs and coordinates shared between train/test trigger summary warnings;
shared coordinates alone do not prove duplicate measurements or leakage.

## Historical Workbook Structure

The private training and test workbooks each have Zigbee, BLE and WiFi sheets
with the same five-column schema. The coordinate scripts read WiFi only.
The archive does not bundle, mirror or provide a download for these workbooks.
The teaching team's measurement origin is based on the participant's statement;
this is not an independently audited acquisition record.

## Obtain Data Lawfully

1. Request explicit access and redistribution terms from the course/data owner,
   or collect a new dataset under the relevant site and participant permissions.
2. Keep private measurements outside the public repository. If privately
   exporting an authorized workbook to CSV, preserve the WiFi sheet values and
   order. Do not infer an RSSI sign conversion.
3. Record site geometry, coordinate units, device/AP identifiers, sample timing,
   aggregation and preprocessing, consent/privacy terms and permitted use.
4. Run the inspector. Its success establishes only schema validity, not physical
   correctness, legal authorization, independence or model accuracy.

The separate `matlab/run_fingerprint_csv.m` wrapper reads this CSV contract and
uses the unmodified historical classes. It returns valid-length per-axis MSE
and paired predictions, without recreating the original full plot arrays. The
original x/y scripts remain available and still require the private workbooks.
