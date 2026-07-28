# Stata dependencies

Third-party Stata packages used by this project are stored under `/lib/stata/ado`
and committed to Git. The standard `run_stata` runner excludes packages
installed elsewhere on a user's machine.

Project-authored commands used by the build must also be stored under the
appropriate first-letter directory in `/lib/stata/ado`. For example, a project
using the bundled `save_data.ado` example should move it to
`/lib/stata/ado/s/save_data.ado`. Commands left in `/examples` or installed only
on a user's machine are not available through `run_stata`.

Do not install packages during a normal build. To add or update a dependency:

1. Check that its license permits redistribution.
2. In a separate Stata session, point `PLUS` at this repository and install the
   package:

   ```stata
   sysdir set PLUS "/absolute/path/to/repository/lib/stata/ado"
   ssc install package_name, replace
   ```

   When possible, use `net install` with a URL pinned to a release or commit
   instead of a mutable package source.
3. Place any ancillary files copied by `net install, all` under the appropriate
   first-letter directory in `/lib/stata/ado` (for example, `e/`). Commit the
   complete installed package, the generated `stata.trk`, and its license.
   Record the upstream source and version below.
   Stata records installed ado/help files in `stata.trk`; ancillary files are
   tracked directly by Git and may not appear in that generated file.
4. Run the project through `run_stata` to confirm that Stata resolves the
   package from `/lib/stata/ado`.

## Included packages

### estout

- Source: https://github.com/benjann/estout
- Commit: `2c6beb2df405a1aa8940e0432a4a53810eca8e60`
- Included commands: `estadd`, `estout`, `estpost`, `eststo`, and `esttab`
- License: MIT; see `/lib/stata/licenses/estout-LICENSE`
