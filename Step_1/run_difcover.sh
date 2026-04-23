#!/bin/bash

set -euo pipefail

# Prefer config values when available (Docker image provides /sexfindr/config.sh)
if [ -f /sexfindr/config.sh ]; then
  # shellcheck disable=SC1091
  source /sexfindr/config.sh
fi

FOLDER_PATH="${DIFCOVER_DIR:-/sexfindr/DifCover/dif_cover_scripts}"

# Stage 2 runs a C++ binary. A file can pass "test -x" but still fail to execute (wrong arch, bad
# interpreter) — bash then reports "No such file or directory". Always compile from .cpp here so
# the binary matches this container (requires g++ / build-essential in the image).
ensure_difcover_ratio_binary() {
  local d="${FOLDER_PATH}"
  local mk="${d}/Makefile"
  local cpp="${d}/from_unionbed_to_ratio_per_window_CC0.cpp"
  local bin="${d}/from_unionbed_to_ratio_per_window_CC0"
  if [ ! -f "$mk" ] || [ ! -f "$cpp" ]; then
    echo "ERROR: DifCover sources missing: need $mk and $cpp"
    return 1
  fi
  if ! command -v g++ >/dev/null 2>&1; then
    echo "ERROR: g++ not found. Install build-essential in the container image."
    return 1
  fi
  echo "Building DifCover helper: from_unionbed_to_ratio_per_window_CC0 (g++ from .cpp)..."
  # Prefer fixed .cpp from image (not under web uploads mount). Rebuild sexfindr:latest if missing.
  FIXED="/sexfindr/Step_1/patches/from_unionbed_to_ratio_per_window_CC0.cpp"
  if [ -f "$FIXED" ]; then
    cp -f "$FIXED" "$cpp"
  fi
  # Upstream Makefile `clean` is empty — rm binary so make always recompiles (fixes corrupted/stale ELF).
  (cd "$d" && rm -f from_unionbed_to_ratio_per_window_CC0 && make && chmod +x from_unionbed_to_ratio_per_window_CC0) || return 1
  if [ ! -x "$bin" ]; then
    echo "ERROR: Build did not produce executable: $bin"
    return 1
  fi
}

BAM1=$1
BAM2=$2
a=${MIN_COV_SAMPLE1:-10}		# minimum coverage for sample1
A=${MAX_COV_SAMPLE1:-219}		# maximum coverage for sample1
b=${MIN_COV_SAMPLE2:-10}		# minimum coverage for sample2
B=${MAX_COV_SAMPLE2:-240}		# maximum coverage for sample2
v=${TARGET_VALID_BASES:-1000}		# target number of valid bases in the window
l=${MIN_WINDOW_SIZE:-500}		# minimum size of window to output
AC=${3:-${ADJUSTMENT_COEFFICIENT:-1}}	# Adjustment Coefficient
p=${ENRICHMENT_THRESHOLD:-0.7369656}		# enrichment scores threshold
bin=1		# histogram bin precision (1 is fine)

## run stage (1)
if [ "${SKIP_DIFCOVER_STAGE1:-0}" = "1" ]; then
  echo "stage 1 skipped (SKIP_DIFCOVER_STAGE1=1 — resume after unionbedcv is ready)"
  if [ ! -f sample1_sample2.unionbedcv ] || [ ! -s sample1_sample2.unionbedcv ]; then
    echo "ERROR: sample1_sample2.unionbedcv missing or empty. Run stage 1 first without SKIP_DIFCOVER_STAGE1."
    exit 1
  fi
else
  echo "stage 1"
  bash "$FOLDER_PATH/from_bams_to_unionbed.sh" "$BAM1" "$BAM2"
fi
#$FOLDER_PATH/from_bams_to_unionbed_update.sh $BAM1 $BAM2

## run stage (2)
ensure_difcover_ratio_binary || exit 127
echo "stage 2"
# DifCover v3: getopt flags required (timnat/DifCover run_difcover.sh)
"$FOLDER_PATH/from_unionbed_to_ratio_per_window_CC0" -a "$a" -A "$A" -b "$b" -B "$B" -v "$v" -l "$l" sample1_sample2.unionbedcv

## run stage (3)
echo "stage 3"
bash "$FOLDER_PATH/from_ratio_per_window__to__DNAcopy_output.sh" "sample1_sample2.ratio_per_w_CC0_a"$a"_A"$A"_b"$b"_B"$B"_v"$v"_l"$l "$AC"

# R may write log2adj_1.DNAcopyout while AC is 1.0 — resolve the actual *.DNAcopyout path
LOG2ADJ_BASE="sample1_sample2.ratio_per_w_CC0_a${a}_A${A}_b${b}_B${B}_v${v}_l${l}"
DNAOUT="${LOG2ADJ_BASE}.log2adj_${AC}.DNAcopyout"
if [ ! -f "$DNAOUT" ]; then
  DNAOUT=$(ls "${LOG2ADJ_BASE}.log2adj_"*.DNAcopyout 2>/dev/null | head -1)
fi
if [ -z "${DNAOUT:-}" ] || [ ! -f "$DNAOUT" ]; then
  echo "ERROR: No *.DNAcopyout found after stage 3 under ${LOG2ADJ_BASE}.log2adj_* (AC was ${AC})"
  exit 1
fi
echo "Using DNAcopy output file: ${DNAOUT}"

## run stage (4)
echo "stage 4"
# Note: DifCover scripts print a fixed "Usage: ..." banner at the top — not an error.
LENFILE="${DNAOUT}.len"
bash "$FOLDER_PATH/get_DNAcopyout_with_length_of_intervals.sh" "$DNAOUT" ref.length.Vk1s_sorted
if [ ! -s "$LENFILE" ]; then
  echo "ERROR: Expected non-empty ${LENFILE} after get_DNAcopyout_with_length_of_intervals.sh"
  exit 1
fi
echo "OK: wrote ${LENFILE}"

bash "$FOLDER_PATH/generate_DNAcopyout_len_histogram.sh" "$LENFILE" "$bin"
HIST="${LENFILE}.hist_b${bin}"
if [ ! -f "$HIST" ]; then
  echo "WARNING: Expected histogram ${HIST}; check generate_DNAcopyout_len_histogram.sh output."
else
  echo "OK: wrote ${HIST}"
fi

## run stage (5)
echo "stage 5"
bash "$FOLDER_PATH/from_DNAcopyout_to_p_fragments.sh" "$DNAOUT" "$p"
echo "OK: stage 5 filters -> ${DNAOUT}.up${p} and ${DNAOUT}.down-${p}"
