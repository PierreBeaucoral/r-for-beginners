# Pre-render step (see _quarto.yml): extract one runnable R script per session,
# scripts/seance-N.R, from the page's code chunks.
# babelquarto renders each language in its own copy of the project, where the
# French page has already been renamed seances/seance-N.qmd, so each language
# gets a script with its own comments. Code is identical in both (see
# tools/check_fr_twin.py); only comments and chart labels differ.
gsub_chunks <- function(src) {
  m <- gregexpr("(?s)```\\{r\\}\\n.*?\\n```", src, perl = TRUE)
  regmatches(src, m) <- list(vapply(regmatches(src, m)[[1]], function(chunk) {
    body <- sub("(?s)^```\\{r\\}\\n(.*)\\n```$", "\\1", chunk, perl = TRUE)
    code <- grep("^#\\|", strsplit(body, "\n")[[1]], value = TRUE, invert = TRUE)
    demo_error <- any(grepl("^#\\|\\s*error:\\s*true", strsplit(body, "\n")[[1]]))
    if (!demo_error && !inherits(try(parse(text = code), silent = TRUE), "try-error")) return(chunk)
    sub("```{r}\n", "```{r}\n#| eval: false\n", chunk, fixed = TRUE)   # purl comments these out
  }, character(1)))
  src
}

dir.create("scripts", showWarnings = FALSE)
for (f in Sys.glob("seances/seance-[0-9].qmd")) {
  out <- file.path("scripts", sub("\\.qmd$", ".R", basename(f)))
  # Drop what is not R to run: mermaid diagrams and the example report shown
  # inside a ````markdown block (session 6), then extract the R chunks.
  src <- paste(readLines(f, warn = FALSE), collapse = "\n")
  src <- gsub("(?s)```\\{mermaid\\}.*?\n```", "", src, perl = TRUE)
  src <- gsub("(?s)````markdown.*?\n````", "", src, perl = TRUE)
  # Chunks that show a deliberate error (`error: true`, or code that does not
  # parse) would stop a script run top to bottom: comment them out instead.
  src <- gsub_chunks(src)
  tmp <- tempfile(fileext = ".qmd")
  writeLines(src, tmp)
  knitr::purl(tmp, output = out, documentation = 0, quiet = TRUE)
  lines <- readLines(out, warn = FALSE)
  title <- rmarkdown::yaml_front_matter(f)$title
  fr <- startsWith(title, "Séance")
  header <- c(sprintf("# %s", title),
              if (fr) "# Source : https://pierrebeaucoral.github.io/r-for-beginners/fr/"
              else    "# Source: https://pierrebeaucoral.github.io/r-for-beginners/",
              if (fr) "# Ouvrez votre projet r-course dans RStudio, puis exécutez ce fichier ligne par ligne."
              else    "# Open your r-course project in RStudio, then run this file line by line.", "")
  writeLines(c(header, lines), out)
}
