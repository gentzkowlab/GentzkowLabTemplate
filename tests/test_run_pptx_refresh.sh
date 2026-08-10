#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname -- "$0")/.." && pwd -P)"
source "${REPO_ROOT}/lib/shell/run_pptx_refresh.sh"

TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/run_pptx_refresh.XXXXXX")
trap 'rm -rf "$TEST_ROOT"' EXIT

MODULE_DIR="${TEST_ROOT}/project with spaces/3_slides"
SOURCE_DIR="${MODULE_DIR}/source"
INPUT_DIR="${MODULE_DIR}/input"
OUTPUT_DIR="${MODULE_DIR}/output"
LOGFILE="${OUTPUT_DIR}/make.log"
CALL_LOG="${TEST_ROOT}/call.log"
FAKE_CMD="${TEST_ROOT}/fake-pptx-refresh"

mkdir -p "$SOURCE_DIR" "$INPUT_DIR" "$OUTPUT_DIR"
MODULE_DIR="$(cd "$MODULE_DIR" && pwd -P)"
SOURCE_DIR="${MODULE_DIR}/source"
INPUT_DIR="${MODULE_DIR}/input"
OUTPUT_DIR="${MODULE_DIR}/output"
LOGFILE="${OUTPUT_DIR}/make.log"
touch "${SOURCE_DIR}/main.pptx" "$LOGFILE"

cat > "$FAKE_CMD" <<'EOF'
#!/bin/bash
set -euo pipefail
printf '%s\n' "$@" > "$CALL_LOG"
if [ "${FAKE_STATUS:-0}" -ne 0 ] && [ "${FAKE_STATUS:-0}" -ne 2 ]; then
    exit "$FAKE_STATUS"
fi
output_dir=""
presentation="$2"
shift 2
while [ "$#" -gt 0 ]; do
    case "$1" in
        --output-dir)
            output_dir="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done
stem=$(basename "$presentation")
stem="${stem%.*}"
mkdir -p "${output_dir}/report"
touch "${output_dir}/${stem}_updated.pptx"
touch "${output_dir}/${stem}_updated.pdf"
touch "${output_dir}/report/report.json"
exit "${FAKE_STATUS:-0}"
EOF
chmod +x "$FAKE_CMD"

export CALL_LOG FAKE_STATUS
pptxRefreshCmd="$FAKE_CMD"

cd "$SOURCE_DIR"
FAKE_STATUS=0
run_pptx_refresh main.pptx "$LOGFILE"

[ "$(sed -n '1p' "$CALL_LOG")" = "build" ]
[ "$(sed -n '2p' "$CALL_LOG")" = "${SOURCE_DIR}/main.pptx" ]
[ "$(sed -n '3p' "$CALL_LOG")" = "--input-dir" ]
[ "$(sed -n '4p' "$CALL_LOG")" = "$INPUT_DIR" ]
[ "$(sed -n '5p' "$CALL_LOG")" = "--output-dir" ]
[ "$(sed -n '6p' "$CALL_LOG")" = "${OUTPUT_DIR}/pptx-refresh" ]

FAKE_STATUS=2
if ! run_pptx_refresh main.pptx "$LOGFILE"; then
    echo "Expected status 2 to publish successfully" >&2
    exit 1
fi
grep -q "published with review items" "$LOGFILE"

FAKE_STATUS=5
if run_pptx_refresh main.pptx "$LOGFILE"; then
    echo "Expected status 5 to fail" >&2
    exit 1
fi

FAKE_STATUS=0
if run_pptx_refresh missing.pptx "$LOGFILE"; then
    echo "Expected a missing presentation to fail" >&2
    exit 1
fi

pptxRefreshCmd="missing-pptx-refresh-command"
if run_pptx_refresh main.pptx "$LOGFILE"; then
    echo "Expected a missing command to fail" >&2
    exit 1
fi

echo "run_pptx_refresh tests passed"
