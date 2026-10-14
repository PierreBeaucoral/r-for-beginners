<!-- Copy of _extensions/r-wasm/live/_knitr.qmd (quarto-live). It is a .md because
     babelquarto deletes every non-.fr .qmd before the French render, including the
     extension's own copy. Refresh it after `quarto update r-wasm/quarto-live`. -->
```{r echo=FALSE}
# Setup knitr for handling {webr} and {pyodide} blocks
# TODO: With quarto-dev/quarto-cli#10169, we can implement this in a filter

# We'll handle `include: false` in Lua, always include cell in knitr output
knitr::opts_hooks$set(include = function(options) {
  if (options$engine == "webr" || options$engine == "pyodide") {
    options$include <- TRUE
  }
  options
})

# Passthrough engine for webr
knitr::knit_engines$set(webr = function(options) {
  knitr:::one_string(c(
    "```{webr}",
    options$yaml.code,
    options$code,
    "```"
  ))
})

# Passthrough engine for pyodide
knitr::knit_engines$set(pyodide = function(options) {
  knitr:::one_string(c(
    "```{pyodide}",
    options$yaml.code,
    options$code,
    "```"
  ))
})
```
