# Transformer Notes for Indoor Localization

This component is a compact, beginner-facing teaching note extracted from a local Chinese classroom presentation. It explains how the ideas from the Transformer lecture connect to Wi-Fi fingerprint indoor localization, using the mnemonic **look up → compare → take** (`查 → 比 → 取`) and the 2023 Anchor-agnostic Transformers (AaT) paper as the main thread.

This is the reading and classroom-sharing component of `wudi-tech/kernel-adaptive-localization`. Return to the [repository overview](../../README.md). It is not an implementation of a Transformer localization model, a benchmark report, or a replacement for the cited papers.

## Contents

- [`docs/DETAILS.zh-CN.md`](docs/DETAILS.zh-CN.md) — Chinese explanation from Transformer and Attention to AaT.
- [`docs/DATA.md`](docs/DATA.md) — UJIIndoorLoc format, provenance, and how to obtain it. No dataset files are redistributed here.
- [`docs/VALIDATION.md`](docs/VALIDATION.md) — What was checked in the source project and what remains unverified for publication.

## Public entry points

The original local web deck is the source artifact, not part of this staging component. The source entry point is `ppt-v2/index.html`; the selected version is the 12-page AaT-focused deck dated 2026-09-21. This component keeps only explanatory notes so that a downstream repository can choose its own presentation format.

## Scope

The note covers:

1. Attention as a weighted information lookup.
2. Wi-Fi fingerprints as location-dependent signal vectors.
3. The difference between a hand-designed weighted-nearest-neighbor analogy and learned Q/K/V projections.
4. The full Transformer context: multi-head attention, residual connections, LayerNorm, FFN, and a task head.
5. AaT's motivation, Anchor2Vec input translation, and self-attention within one scan.
6. The interpretation limits of the recorded UJIIndoorLoc example and the paper-reported numbers.

## References

- Vaswani et al., *Attention Is All You Need* (2017), [arXiv:1706.03762](https://arxiv.org/abs/1706.03762).
- Torres-Sospedra et al., *UJIIndoorLoc* (2014), [UCI dataset 310](https://archive.ics.uci.edu/dataset/310/ujiindoorloc), DOI [10.24432/C5MS59](https://doi.org/10.24432/C5MS59).
- Nguyen, Le & Havinga, *Anchor-agnostic Transformers for Fingerprint-based Indoor Localization* (IEEE PerCom 2023), DOI [10.1109/PERCOM56429.2023.10099376](https://doi.org/10.1109/PERCOM56429.2023.10099376).

## Provenance and contribution boundary

The explanatory prose in this component is a new, condensed organization of the user's local teaching material. No team roster or separate collaborator contribution record was found in the inspected source directories. Paper authors, dataset maintainers, and KaTeX/animation vendors are third parties; their work is cited or excluded rather than presented as local work.

## Non-goals

- No training, fine-tuning, hardware integration, or large experiment is included.
- No raw UJIIndoorLoc CSV, extracted sample JSON, paper PDF, course slide deck, personal roster, credentials, or chat transcript is included.
- Reported metrics are quoted as existing source-record values with their scope stated; they are not claimed as a fresh reproduction in this publishing task.
