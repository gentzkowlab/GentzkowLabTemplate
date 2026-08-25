# Converting Beamer slides to PowerPoint

This guide walks through the complete `tex2pptx` example from a current template checkout and explains how to add the workflow to an older template repository. The example converts a four-slide Beamer source file into an editable PowerPoint presentation and publishes LaTeX and PowerPoint PDFs for comparison.

## Contents

- [Choose your starting point](#choose-your-starting-point)
- [Requirements](#requirements)
- [Try the example](#try-the-example)
- [Apply tex2pptx to your own Beamer slides](#apply-tex2pptx-to-your-own-beamer-slides)
- [Add tex2pptx to an existing template repository (one time)](#add-tex2pptx-to-an-existing-template-repository-one-time)

## Choose your starting point

- If your repository was created from the current template, continue to [Try the example](#try-the-example).
- If the workflow is already installed and you do not need the example, continue to [Apply tex2pptx to your own Beamer slides](#apply-tex2pptx-to-your-own-beamer-slides).
- If your repository predates the PowerPoint workflows, complete [Add tex2pptx to an existing template repository](#add-tex2pptx-to-an-existing-template-repository-one-time) first.

## Requirements

- macOS with an installed and licensed copy of Microsoft PowerPoint
- PowerPoint Automation permission for the terminal or application running the example
- Python 3.10 or newer
- Node.js 22 or newer
- Pandoc
- TeX Live or MacTeX

## Try the example

Run every shell command in this section from the repository root.

### 1. Install the pinned package

Create the machine-specific settings file if it does not already exist, enable `tex2pptx`, and run setup:

```bash
test -f local_env.sh || cp lib/setup/local_env_template.sh local_env.sh
sed -i '' 's/^export installTex2Pptx="false"$/export installTex2Pptx="true"/' local_env.sh
printf 'n\n' | bash setup.sh
```

The last command skips the initial input-link pass because the example input is declared in step 3. The slides-module build will create that link.

By default, setup installs into `python3`. To use an existing virtual or Conda environment, change `pythonCmd` in `local_env.sh` to that environment's Python executable before running setup.

Confirm that the package and system requirements are ready:

```bash
source local_env.sh
"${pythonCmd}" -m tex2pptx doctor
```

Every dependency in the diagnostic table should have status `OK`.

### 2. Copy the Beamer example into the slides module

```bash
cp examples/tex2pptx/main.tex 3_slides/source/main.tex
```

The example contains a title slide, a text slide, a figure, and an illustrative regression table.

### 3. Declare the figure input

In `3_slides/get_inputs.sh`, replace the existing `INPUT_FILES` block with:

```bash
INPUT_FILES=(
    "../examples/inputs_for_examples/figure_city.jpg"
)
```

This makes the figure available to the Beamer source as `../input/figure_city.jpg` when the module builds.

### 4. Add the conversion command

Open `3_slides/make.sh` and find this line:

```bash
run_shell my_shell_script.sh "${LOGFILE}" || exit 1
```

Add the following line directly below it:

```bash
run_tex2pptx main.tex "${LOGFILE}" || exit 1
```

The template already loads `run_tex2pptx`; no additional shell setup is needed.

### 5. Build the slides module

```bash
bash 3_slides/make.sh
```

A successful conversion prints output similar to:

```text
Created validated deck: 3_slides/output/tex2pptx/main.pptx
Mode: best effort (tolerant)
tex2pptx published 3_slides/output/tex2pptx/main.pptx.
```

`best effort (tolerant)` is the normal conversion mode. The report records any differences that still require review.

### 6. Review the outputs

The build publishes:

```text
3_slides/output/tex2pptx/main.pptx
3_slides/output/tex2pptx/main-from-latex.pdf
3_slides/output/tex2pptx/main-from-powerpoint.pdf
3_slides/output/tex2pptx/main-report/conversion-report.html
3_slides/output/tex2pptx/main-report/conversion-report.json
```

Open the PowerPoint and confirm that it has four slides and that its text, figure, and regression table are editable. Compare the two PDFs side by side, then review the HTML report for conversion metrics and any findings.

## Apply tex2pptx to your own Beamer slides

### 1. Put the Beamer source in the slides module

Put the Beamer source file and any source-local TeX files in `3_slides/source/`. The examples below assume the main file is `3_slides/source/main.tex`.

### 2. Declare the external inputs

Declare every figure, table, or included TeX file produced outside `3_slides/source/` in `3_slides/get_inputs.sh`. For example, this declaration makes the analysis module's figure directory available as `3_slides/input/figures/`:

```bash
INPUT_FILES=(
    "../2_analysis/output/figures -> figures"
)
```

### 3. Refer to the inputs from the Beamer source

Refer to each declared input through the slides module's `input/` directory. Because `main.tex` is under `3_slides/source/`, the corresponding figure path is:

```tex
\includegraphics{../input/figures/result.pdf}
```

### 4. Add the conversion command

In `3_slides/make.sh`, add the conversion command directly below the existing `run_shell` line:

```bash
run_shell my_shell_script.sh "${LOGFILE}" || exit 1
run_tex2pptx main.tex "${LOGFILE}" || exit 1
```

### 5. Build the slides module

Build the module from the repository root:

```bash
bash 3_slides/make.sh
```

### 6. Review the outputs

Review the PowerPoint, both comparison PDFs, and the HTML report under `3_slides/output/tex2pptx/`. Output names are derived from the Beamer source filename.

The runner installs nothing at build time. It uses the interpreter configured by `pythonCmd`, appends conversion output to the module log, and verifies that the PowerPoint, both PDFs, and conversion report were published.

## Add tex2pptx to an existing template repository (one time)

Repositories created from an older version of the template do not contain the runner or optional package setup. Merge the additions below into the existing files; do not overwrite customized `local_env.sh`, `setup.sh`, or `3_slides/make.sh` files.

### 1. Copy the runner

Copy [`lib/shell/run_tex2pptx.sh`](../../lib/shell/run_tex2pptx.sh) from the updated template into the same path in the existing repository.

### 2. Add the package setup controls

Merge the `installTex2Pptx` setting from [`lib/setup/local_env_template.sh`](../../lib/setup/local_env_template.sh) and the optional PowerPoint package installation block from [`setup.sh`](../../setup.sh) into the corresponding existing files.

### 3. Enable tex2pptx in the local settings

Add `export installTex2Pptx="true"` to the existing root `local_env.sh`. Do not replace the file because it contains machine-specific project settings.

### 4. Load the runner in the slides module

In `3_slides/make.sh`, add `source "${REPO_ROOT}/lib/shell/run_tex2pptx.sh"` beside the other runner imports.

### 5. Install the package and choose the next workflow

Run `bash setup.sh` and confirm that `tex2pptx` installs successfully. Then either [try the example from step 2](#2-copy-the-beamer-example-into-the-slides-module) or [apply tex2pptx to your own Beamer slides](#apply-tex2pptx-to-your-own-beamer-slides).
