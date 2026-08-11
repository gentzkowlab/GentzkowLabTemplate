# Converting Beamer slides to PowerPoint

This example uses the `tex2pptx` package installed by the template setup to
convert a Beamer source file into an editable PowerPoint presentation.

## Setup

Enable this optional package in the machine-specific `local_env.sh`:

```bash
export installTex2Pptx="true"
```

If the file does not exist yet, setup creates it and pauses so you can make
this change before continuing. From the repository root, run:

```bash
bash setup.sh
```

Setup then installs the pinned `tex2pptx` version into the existing Python
interpreter configured by `pythonCmd` in the generated, Git-ignored
`local_env.sh`. It does not create or activate a Python environment.

The complete conversion requires macOS, Python 3.10 or newer, Node.js 22 or
newer, Pandoc, MacTeX or equivalent TeX Live commands, and an installed and
licensed copy of Microsoft PowerPoint. The first conversion may require macOS
Automation permission for the terminal or application running the module.

Check these prerequisites with:

```bash
python3 -m tex2pptx doctor
```

Replace `python3` with the `pythonCmd` value from `local_env.sh` when using a
different interpreter.

## Add the conversion to a slides module

Copy the example source into the slides module:

```bash
cp examples/tex2pptx/main.tex 3_slides/source/main.tex
```

The example contains a figure and an inline illustrative regression table.
Declare the existing figure input in `3_slides/get_inputs.sh`:

```bash
INPUT_FILES=(
    "../examples/inputs_for_examples/figure_city.jpg"
)
```

Running `3_slides/get_inputs.sh` makes the image available to the Beamer source
as `../input/figure_city.jpg`. In a real project, figures and generated table
fragments would normally point to outputs from an upstream analysis module.

The template's `3_slides/make.sh` loads the runner automatically. Call it from
the existing block that runs scripts from `3_slides/source/`:

```bash
run_tex2pptx main.tex "${LOGFILE}" || exit 1
```

The runner installs nothing at build time. It uses the interpreter configured
by `pythonCmd`, appends conversion output to `3_slides/output/make.log`, and
publishes these files under `3_slides/output/`:

```text
main.pptx
main-from-latex.pdf
main-from-powerpoint.pdf
main-report/
```

Review the PowerPoint, both PDFs, and `main-report/conversion-report.html`
before using the deck. A successful best-effort conversion may still contain
differences that require review; these are reported without failing the
module.

Source-relative figures and included TeX files should use the template's usual
module paths. For example, a Beamer source under `3_slides/source/` can refer to
an input as `../input/figures/result.pdf`, with that input declared in
`3_slides/get_inputs.sh`.
