# Validation and evidence level

## Source-project checks

The selected source version is the 12-page AaT-focused web deck dated 2026-09-21. Its local verifier was run against the source tree during this audit:

```text
pages: 12
minutes: 9.2
mathBlocks: 2
notesParagraphs: 45
sampleErrorMeters: 3.19
sources: 3
checks: PASS
```

The verifier checks page order, page count, planned duration, notes presence, source links, the recorded example values, the AaT topic markers, the absence of the deleted “特征坍塌” page, and the absence of the 2025 paper from the selected mainline. It also checks that the web entry point's local assets exist and that the deck does not require remote JavaScript/CSS at runtime.

## What this does and does not prove

- **Verified:** the selected local teaching artifact is internally consistent at the level covered by its script, and this staging note keeps the intended scope and citations.
- **Not re-run here:** model training, paper experiments, hardware collection, end-to-end localization, or a fresh recomputation from the raw UJIIndoorLoc CSV.
- **Not claimed:** the source's recorded 3.19 m example or paper-reported eAaT metrics are new benchmark results produced by this publication task.

## Reproduction boundary

The original project contains source-side scripts for extracting the classroom example and checking deck content. They are retained only as provenance in the audit record; this component does not copy the raw data or vendor bundles, and no large experiment was executed while preparing it.
