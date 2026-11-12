source("renv/activate.R")

# Point reticulate at the uv-managed Python env (create it with `uv sync`).
local({
  py <- file.path(getwd(), ".venv", "bin", "python")
  if (file.exists(py)) Sys.setenv(RETICULATE_PYTHON = py)
})
