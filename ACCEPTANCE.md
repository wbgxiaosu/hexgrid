# Acceptance Evidence Map

This document maps the hackathon acceptance criteria to concrete
evidence in this repository, so reviewers can verify each item
directly.

| # | Criterion | Evidence |
|---|---|---|
| 1 | MoonBit as the main implementation language, moonc ≥ 0.10.19 | All functional code is `.mbt` (MoonBit); no implementation in any other language. CI installs the current official stable toolchain, prints `moon version --all` and **fails hard if moonc is below 0.10.19** (dedicated assertion step, see workflow logs); the development toolchain is moonc v0.10.19 / moon 0.1.20261102. |
| 2 | Public GitHub repository with clear commit history | <https://github.com/wbgxiaosu/hexgrid> — commits are split by feature (one package/capability per commit) with descriptive messages; no empty, duplicated or padded commits. |
| 3 | Clear source structure; declared core features work | One package per concern: `hex/` (coordinate systems, grid mathematics, pixel layouts), `path/` (Dijkstra and A*), `fov/` (one-way and symmetric line-of-sight), `hexmap/` (region-shaped map storage), runnable demo in `cmd/main/`. Every declared capability is implemented and exercised by the test suite (40 tests). |
| 4 | README with goals, installation, usage, reproducible examples | `README.md` — goals (reusable hexagonal-grid infrastructure), installation (`moon add wbgxiaosu/hexgrid`), usage snippets, runnable demo (`moon run cmd/main`) and an independent consumer example reproduced on every CI push. |
| 5 | CI covering check, build, test | `.github/workflows/ci.yml` runs `moon check --deny-warn`, `moon build` and `moon test --deny-warn` (plus `moon fmt --check` and the moonc version assertion) on the wasm, wasm-gc and native backends on every push and PR, plus a separate consumer job that runs `examples/consumer` against the library source. |
| 6 | At least one runnable example / minimal usage sample | Two runnable examples: `cmd/main/main.mbt` drives the public API end to end (`moon run cmd/main`); `examples/consumer` is an independent module importing the published package name exactly as an external user would, with `moon.work` redirecting it to the current source (`cd examples/consumer && moon run .`) — CI verifies both on every push. |
| 7 | Complete tests covering core functionality paths | 40 whitebox tests: Red Blob Games reference-value assertions, round-trip consistency across all four offset layouts and every cell, distance/adjacency axioms, region-shape cell-count formulas, map get/set/remove and ASCII-render invariants, Dijkstra single-vs-multi-source equivalence and min-over-sources property, A* agreement with Dijkstra costs, FOV wall-blocking and pairwise symmetry. Run with `moon test`. |
| 8 | Published to mooncakes.io | <https://mooncakes.io/docs/#/wbgxiaosu/hexgrid> — current release 0.2.0. Install with `moon add wbgxiaosu/hexgrid`. |
| 9 | OSI-approved open-source licence; upstream compliance | [LICENSE](LICENSE) — Apache License 2.0 (OSI-approved). Zero third-party package dependencies; every referenced specification/article is named with source and scope in [docs/RULES_REFERENCES.md](docs/RULES_REFERENCES.md). |

## Hackathon-season criteria mapping

The official hackathon rules state six season criteria. Four of them
are covered by rows 1, 3, 4 and 9 above; the remaining two are mapped
here:

| # | Official criterion | Evidence |
|---|---|---|
| 2 | Public repository with continuous, traceable commits and development record | <https://github.com/wbgxiaosu/hexgrid> — feature-split commits from the initial skeleton through the current release; every version published to mooncakes.io and verified in a separate consumer project. |
| 4 | Substantial new work completed this season | [CHANGELOG.md](CHANGELOG.md) 0.1.0 → 0.2.0 documents the November work: the hexmap package with four region shapes and generic map storage, symmetric line-of-sight FOV, multi-source Dijkstra reachability, and the consumer verification for all three — all committed in November 2026. |
| 6 | AI-assisted but explainable and participant-owned | [docs/AI_COLLABORATION.md](docs/AI_COLLABORATION.md) records the division of work: the participant set the goal, chose the technical path, defined the quality gates, approved reference sources and licences, and can explain the architecture and trade-offs. |

## Reproduction script

```bash
git clone https://github.com/wbgxiaosu/hexgrid
cd hexgrid
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash   # or the Windows installer
moon check && moon test && moon run cmd/main && (cd examples/consumer && moon run .)
```

Expected: check passes with zero warnings, 40 tests pass, the demo
prints the geometry/path/FOV lines, and the consumer prints
`consumer example OK`.
