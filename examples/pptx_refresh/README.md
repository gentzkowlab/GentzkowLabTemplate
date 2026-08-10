# Refresh a PowerPoint deck from module inputs

This example shows how to use `pptx-refresh` in the standard module layout.
The workflow updates declared figures and rendered TeX tables in an existing
PowerPoint deck while preserving its manually edited content.

## Requirements

- macOS with Microsoft PowerPoint installed and licensed
- `pptx-refresh` installed and passing `pptx-refresh doctor`
- `pptxRefreshCmd` in `local_env.sh` set to the installed command when it is
  not available on `PATH`

## Configure the slide module

1. Place the source presentation at `3_slides/source/main.pptx`.
2. In PowerPoint, give each managed object an `AUTO:` Selection Pane name and
   put its path relative to `3_slides/input` on the first Alt Text line. For
   example:

   ```text
   figures/results.pdf
   ```

3. Declare the upstream assets in `3_slides/get_inputs.sh`. For example, link
   the complete analysis figure directory as `3_slides/input/figures`:

   ```bash
   INPUT_FILES=(
       "../2_analysis/output/figures -> figures"
   )
   ```

4. In `3_slides/make.sh`, source the runner:

   ```bash
   source "${REPO_ROOT}/lib/shell/run_pptx_refresh.sh"
   ```

5. Replace the placeholder command in the source execution block with:

   ```bash
   run_pptx_refresh main.pptx "${LOGFILE}" || exit 1
   ```

Run the module normally:

```bash
bash 3_slides/make.sh
```

The runner derives the module paths automatically and publishes the atomic
bundle without replacing `output/make.log`:

```text
3_slides/output/
├── make.log
└── pptx-refresh/
    ├── main_updated.pptx
    ├── main_updated.pdf
    └── report/
        ├── index.html
        └── report.json
```

An exit status indicating that review is recommended still counts as a
successful module build. Open `output/pptx-refresh/report/index.html` and
inspect every reported item before circulating the deck.
