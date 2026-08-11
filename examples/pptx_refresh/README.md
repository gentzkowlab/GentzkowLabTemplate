# Refreshing managed PowerPoint content

This example shows how to refresh a PowerPoint presentation from a module's
declared inputs with the `pptx-refresh` package installed by the template
setup. The included `slides.pptx` is a ready-to-run example with visible
instructions:

- Slide 1 contains a managed picture. The source deck embeds
  `figure_hwy.jpg`, while its Selection Pane name and Alt Text declare
  `example_inputs/figure_city.jpg` as the refresh target.
- Slide 2 contains an ungrouped native shape whose metadata declares
  `example_inputs/table_reg.tex`. Refreshing replaces that shape with a
  rendered table image.

## Setup

Enable this optional package in the machine-specific `local_env.sh`:

```bash
export installPptxRefresh="true"
```

If the file does not exist yet, setup creates it and pauses so you can make
this change before continuing. From the repository root, run:

```bash
bash setup.sh
```

Setup then installs the pinned `pptx-refresh` version into the existing Python
interpreter configured by `pythonCmd` in `local_env.sh`.

The generated, Git-ignored `local_env.sh` is a machine-specific settings file;
it does not create or activate a Python environment. It configures `python3`
by default:

```bash
# In local_env.sh
export pythonCmd="python3"
```

To use an existing virtual or Conda environment, edit that line to point to
the environment's Python executable when setup prompts you, or edit it later
and rerun `setup.sh`:

```bash
# In local_env.sh
export pythonCmd="/path/to/environment/bin/python"
```

Copy the example presentation into a slides module:

```bash
cp examples/pptx_refresh/slides.pptx 3_slides/source/slides.pptx
```

For your own presentation, give each managed object a unique Selection Pane
name beginning with `AUTO:` and put its source path on the first line of Alt
Text. The source path is relative to the module's `input/` directory, for
example:

```text
Selection Pane name:
AUTO:figures/result.pdf

Alt Text:
figures/result.pdf
```

Declare the input in `3_slides/get_inputs.sh`. The usual template mechanism may
create either file or directory symlinks:

```bash
INPUT_FILES=(
    "../examples/inputs_for_examples -> example_inputs"
)
```

The template's `3_slides/make.sh` loads the runner automatically. Call it from
the existing block that runs scripts from `3_slides/source/`:

```bash
run_pptx_refresh slides.pptx "${LOGFILE}" || exit 1
```

The runner derives the module from `LOGFILE`, reads managed sources through
`3_slides/input/`, appends command output to `3_slides/output/make.log`, and
publishes the atomic bundle under `3_slides/output/pptx-refresh/`. Exit status
`2` means publication succeeded but the report contains items to review; the
runner logs that warning without failing the module.

## Requirements

- macOS with Microsoft PowerPoint installed
- PowerPoint Automation permission for the invoking terminal or application
- TeX only when the presentation contains managed rendered tables
