# AI Collaboration Statement

hexgrid is developed for the 2026 MoonBit Hackathon (November season)
with AI assistance, under the season rule that AI may help write code
while the participant owns the project's goals, technical path and
quality. The division of work:

## Participant-owned decisions

- **Topic selection and duplication check.** The participant chose the
  hexagonal-grid domain after a full mooncakes duplication sweep
  (11 batches, 100+ keywords across all of categories from regex to
  YAML to game engines) established that flat 2D hexagonal grid
  geometry is a genuine gap, and that Uber H3 (geodesic indexing) is a
  different problem domain.
- **Scope and architecture.** Three single-responsibility packages
  (hex / path / fov), pure deterministic APIs, caller-injected game
  semantics (passability, terrain cost, transparency), zero third-party
  dependencies.
- **Reference policy.** Red Blob Games and the classical Dijkstra/A*
  literature are the sole mathematical references; their sources,
  referenced scope and licence terms are recorded in
  [RULES_REFERENCES.md](RULES_REFERENCES.md), and no third-party code
  or text is copied.
- **Quality gates.** `moon check --deny-warn`, `moon test --deny-warn`
  on three backends, `moon fmt --check`, a hard `moonc >= 0.10.19`
  assertion, and an independent consumer module (examples/consumer)
  that CI runs on every push.
- **Acceptance of every change.** All tests, docs and commits are
  reviewed by the participant before pushing; the commit history is
  split by feature.

## AI-assisted work

- Drafting MoonBit implementations of the referenced algorithms.
- Drafting tests (including property-style roundtrip tests) and
  documentation.
- Fixing toolchain-level build issues.

## Evidence

- Commit history: <https://github.com/wbgxiaosu/hexgrid/commits>
- CI runs: <https://github.com/wbgxiaosu/hexgrid/actions>
- Duplication-check and reference provenance:
  [RULES_REFERENCES.md](RULES_REFERENCES.md)

## Lessons carried from the October season

The participant's October submission failed acceptance over
large-parameter crashes and mishandled edge cases (illegal-move
enumeration at 26 routes, stalemate scoring, split pools with equal
ranks, negative chips and repeated payouts). For hexgrid those
lessons were converted into concrete quality gates owned by the
participant:

- every algorithm is exercised at production-like scale (radius-100
  enumerations, million-scale coordinates, 50-source floods), not
  only on toy inputs;
- degenerate inputs (empty/duplicate sources, zero budgets, NaN or
  non-positive costs) have specified, tested behaviour instead of
  undefined hangs;
- performance cliffs are closed by design (O(1) source membership
  indexing), and the reasoning is documented in ACCEPTANCE.md.
