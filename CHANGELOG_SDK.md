# Changelog SDK

## 2023-06 `v3.0.0`

- introduces template versioning (starting w/ `v3.0.0` as this is the third major iteraction)
- introduces `dotenv` to control/adjust local app-development
- updates developer readme
- introduces a _Template Syncronisation_ GH action. Use it to synchronize your forked app with template updates. If you already forked from the template before SDK `v3.0.0` you can manually add the file `.github/workflows/template-sync.yml` to your fork and execute the GH action manually.

- fix app-configuration for execution on moveapps.org
- clear app output of previously app run at each start of the SDK

- SDK supports [`move2`](https://gitlab.com/bartk/move2/) and prefers it over [`move`](https://gitlab.com/bartk/move/).
- output is always move2
- Upgrade `R` framework to `4.3.1`
