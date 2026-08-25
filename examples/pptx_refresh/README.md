# Refreshing managed PowerPoint content

This guide walks through the complete `pptx-refresh` example from a current template checkout and explains how to add the workflow to an older template repository. The example replaces one figure and one rendered TeX table using `AUTO:` declarations stored in PowerPoint Alt Text.

## Contents

- [Choose your starting point](#choose-your-starting-point)
- [Requirements](#requirements)
- [Try the example](#try-the-example)
- [Apply pptx-refresh to your own presentation](#apply-pptx-refresh-to-your-own-presentation)
- [Add pptx-refresh to an existing template repository (one time)](#add-pptx-refresh-to-an-existing-template-repository-one-time)

## Choose your starting point

- If your repository was created from the current template, continue to [Try the example](#try-the-example).
- If the workflow is already installed and you do not need the example, continue to [Apply pptx-refresh to your own presentation](#apply-pptx-refresh-to-your-own-presentation).
- If your repository predates the PowerPoint workflows, complete [Add pptx-refresh to an existing template repository](#add-pptx-refresh-to-an-existing-template-repository-one-time) first.

## Requirements

- macOS with Microsoft PowerPoint installed
- PowerPoint Automation permission for the terminal or application running the example
- Python 3.10 or newer
- TeX Live or MacTeX for the rendered-table example

## Try the example

Run every shell command in this section from the repository root.

### 1. Install the pinned package

Create the machine-specific settings file if it does not already exist, enable `pptx-refresh`, and run setup:

```bash
test -f local_env.sh || cp lib/setup/local_env_template.sh local_env.sh
sed -i '' 's/^export installPptxRefresh="false"$/export installPptxRefresh="true"/' local_env.sh
printf 'n\n' | bash setup.sh
```

The last command skips the initial input-link pass because the example inputs are declared in step 3. The slides-module build will create those links.

By default, setup installs into `python3`. To use an existing virtual or Conda environment, change `pythonCmd` in `local_env.sh` to that environment's Python executable before running setup.

Confirm that the package and system requirements are ready:

```bash
source local_env.sh
"${pythonCmd}" -m pptx_refresh doctor
```

The diagnostic should finish with `SUCCESS`.

### 2. Copy the example deck into the slides module

```bash
cp examples/pptx_refresh/slides.pptx 3_slides/source/slides.pptx
```

The deck has two managed objects:

- Slide 1 contains a figure frame whose Alt Text declares `AUTO: example_inputs/figure_city.jpg`.
- Slide 2 contains a native shape whose Alt Text declares `AUTO: example_inputs/table_reg.tex`.

### 3. Declare the example inputs

In `3_slides/get_inputs.sh`, replace the existing `INPUT_FILES` block with:

```bash
INPUT_FILES=(
    "../examples/inputs_for_examples -> example_inputs"
)
```

This makes the example inputs available under `3_slides/input/example_inputs/` when the module builds.

### 4. Add the refresh command

Open `3_slides/make.sh` and **find** this line:

```bash
run_shell my_shell_script.sh "${LOGFILE}" || exit 1
```

**Add** the following line directly below it:

```bash
run_pptx_refresh slides.pptx "${LOGFILE}" || exit 1
```

The template already loads `run_pptx_refresh`; no additional shell setup is needed.

### 5. Build the slides module

```bash
bash 3_slides/make.sh
```

A successful example prints:

```text
BUILD PUBLISHED - REVIEW RECOMMENDED
Review items: 2
```

The two review items are expected for these deliberately simple inputs:

- `figure_city.jpg` is below the managed frame's 300-DPI target.
- The rendered regression table has a different natural aspect ratio from its placeholder shape.

The report should still show that both managed objects were updated and that no pixels outside those objects changed unexpectedly.

### 6. Review the outputs

The build publishes:

```text
3_slides/output/pptx-refresh/slides_updated.pptx
3_slides/output/pptx-refresh/slides_updated.pdf
3_slides/output/pptx-refresh/report/index.html
3_slides/output/pptx-refresh/report/report.json
```

Open the PowerPoint and PDF and confirm that slide 1 contains the city fuel-economy figure and slide 2 contains the rendered regression table. Use the HTML report to review the two expected warnings and the before/after slide previews.

## Apply pptx-refresh to your own presentation

### 1. Put the presentation in the slides module

Put the PowerPoint file in `3_slides/source/`. The examples below assume the file is `3_slides/source/slides.pptx`.

### 2. Mark each managed object with Alt Text

Select an ungrouped picture, text box, ordinary shape, or native table and put an `AUTO:` declaration in its Alt Text. The source path is relative to the module's `input/` directory:

```text
AUTO: figures/result.pdf
```

The `AUTO:` prefix is case-sensitive. A visible `AUTO:` declaration inside an ordinary text box or shape is also supported.

### 3. Declare the managed content inputs

Declare every file or directory referenced by an `AUTO:` declaration in `3_slides/get_inputs.sh`. For example, this declaration makes the analysis module's figure directory available as `3_slides/input/figures/`:

```bash
INPUT_FILES=(
    "../2_analysis/output/figures -> figures"
)
```

### 4. Add the refresh command

In `3_slides/make.sh`, add the refresh command directly below the existing `run_shell` line:

```bash
run_shell my_shell_script.sh "${LOGFILE}" || exit 1
run_pptx_refresh slides.pptx "${LOGFILE}" || exit 1
```

### 5. Build the slides module

Build the module from the repository root:

```bash
bash 3_slides/make.sh
```

### 6. Review the outputs

Open the updated PowerPoint, its PDF, and the HTML report under `3_slides/output/pptx-refresh/`. Confirm that each managed object was refreshed and review every warning in the report.

The runner appends command output to the module log and publishes an atomic bundle under `output/pptx-refresh/`. Exit status `2` means publication succeeded but the report contains items to review; the runner records that warning without failing the module.

For direct use outside the template runner, create persistent project settings with:

```bash
python3 -m pptx_refresh init 3_slides
```

## Add pptx-refresh to an existing template repository (one time)

Repositories created from an older version of the template do not contain the runner or optional package setup. Merge the additions below into the existing files; do not overwrite customized `local_env.sh`, `setup.sh`, or `3_slides/make.sh` files.

### 1. Copy the runner

Copy [`lib/shell/run_pptx_refresh.sh`](../../lib/shell/run_pptx_refresh.sh) from the updated template into the same path in the existing repository.

### 2. Add the package setup controls

Merge the `installPptxRefresh` setting from [`lib/setup/local_env_template.sh`](../../lib/setup/local_env_template.sh) and the optional PowerPoint package installation block from [`setup.sh`](../../setup.sh) into the corresponding existing files.

### 3. Enable pptx-refresh in the local settings

Add `export installPptxRefresh="true"` to the existing root `local_env.sh`. Do not replace the file because it contains machine-specific project settings.

### 4. Load the runner in the slides module

In `3_slides/make.sh`, add `source "${REPO_ROOT}/lib/shell/run_pptx_refresh.sh"` beside the other runner imports.

### 5. Install the package and choose the next workflow

Run `bash setup.sh` and confirm that `pptx-refresh` installs successfully. Then either [try the example from step 2](#2-copy-the-example-deck-into-the-slides-module) or [apply pptx-refresh to your own presentation](#apply-pptx-refresh-to-your-own-presentation).
