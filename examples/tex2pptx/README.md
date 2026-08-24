# Converting Beamer slides to PowerPoint

This guide walks through the complete `tex2pptx` example from an untouched template checkout. The example converts a four-slide Beamer source file into an editable PowerPoint presentation and publishes LaTeX and PowerPoint PDFs for comparison.

Run every shell command below from the repository root.

## Requirements

- macOS with an installed and licensed copy of Microsoft PowerPoint
- PowerPoint Automation permission for the terminal or application running the example
- Python 3.10 or newer
- Node.js 22 or newer
- Pandoc
- TeX Live or MacTeX

## 1. Install the pinned package

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

## 2. Copy the Beamer example into the slides module

```bash
cp examples/tex2pptx/main.tex 3_slides/source/main.tex
```

The example contains a title slide, a text slide, a figure, and an illustrative regression table.

## 3. Declare the figure input

In `3_slides/get_inputs.sh`, replace the existing `INPUT_FILES` block with:

```bash
INPUT_FILES=(
    "../examples/inputs_for_examples/figure_city.jpg"
)
```

This makes the figure available to the Beamer source as `../input/figure_city.jpg` when the module builds.

## 4. Add the conversion command

Open `3_slides/make.sh` and find this line:

```bash
run_shell my_shell_script.sh "${LOGFILE}" || exit 1
```

Add the following line directly below it:

```bash
run_tex2pptx main.tex "${LOGFILE}" || exit 1
```

The template already loads `run_tex2pptx`; no additional shell setup is needed.

## 5. Build the slides module

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

## 6. Review the outputs

The build publishes:

```text
3_slides/output/tex2pptx/main.pptx
3_slides/output/tex2pptx/main-from-latex.pdf
3_slides/output/tex2pptx/main-from-powerpoint.pdf
3_slides/output/tex2pptx/main-report/conversion-report.html
3_slides/output/tex2pptx/main-report/conversion-report.json
```

Open the PowerPoint and confirm that it has four slides and that its text, figure, and regression table are editable. Compare the two PDFs side by side, then review the HTML report for conversion metrics and any findings.

## Use the workflow in your own Beamer project

Declare figures and included TeX fragments in the module's `get_inputs.sh`, add `run_tex2pptx` to the module's `make.sh`, and build the module normally. Source-relative figures and included TeX files should use the template's module paths. For example, a Beamer source under `3_slides/source/` can refer to an input as `../input/figures/result.pdf` when that input is declared in `3_slides/get_inputs.sh`.

The runner installs nothing at build time. It uses the interpreter configured by `pythonCmd`, appends conversion output to the module log, and verifies that the PowerPoint, both PDFs, and conversion report were published.
