# deploy_portfolio() against a throwaway workspace repo with a local bare
# repository standing in for GitHub. The portfolio sits inside the workspace,
# as it does for students.

local_git_identity <- function(env = parent.frame()) {
  withr::local_envvar(c(
    GIT_AUTHOR_NAME = "v2v test", GIT_AUTHOR_EMAIL = "test@example.com",
    GIT_COMMITTER_NAME = "v2v test", GIT_COMMITTER_EMAIL = "test@example.com"
  ), .local_envir = env)
}

git <- function(dir, ...) {
  out <- system2("git", c("-C", shQuote(dir), ...), stdout = TRUE, stderr = TRUE)
  status <- attr(out, "status")
  if (!is.null(status) && status != 0) stop(paste(out, collapse = "\n"))
  out
}

# A workspace repo holding a minimal HTML-only Quarto site in `site/`, pushed to
# a bare origin. Returns the paths.
local_workspace <- function(env = parent.frame()) {
  root <- withr::local_tempdir(.local_envir = env)
  origin <- file.path(root, "origin.git")
  ws <- file.path(root, "workspace")
  site <- file.path(ws, "site")
  dir.create(site, recursive = TRUE)
  system2("git", c("init", "-q", "--bare", shQuote(origin)))
  system2("git", c("init", "-q", shQuote(ws)))
  writeLines(c("project:", "  type: website", "  output-dir: docs"),
             file.path(site, "_quarto.yml"))
  writeLines(c("---", "title: \"Test\"", "---", "", "Hello."), file.path(site, "index.qmd"))
  writeLines("# workspace", file.path(ws, "README.md"))
  git(ws, "add", ".")
  git(ws, "commit", "-q", "-m", shQuote("init"))
  git(ws, "branch", "-M", "main")
  git(ws, "remote", "add", "origin", shQuote(origin))
  git(ws, "push", "-q", "origin", "main")
  list(origin = origin, ws = ws, site = site)
}

deploy_messages <- function(...) {
  paste(testthat::capture_messages(deploy_portfolio(...)), collapse = "")
}

test_that("portfolio_output_dir() reads output-dir and defaults to docs", {
  dir <- withr::local_tempdir()
  expect_equal(portfolio_output_dir(dir), "docs")
  writeLines(c("project:", "  type: book", "  output-dir: \"_site\""),
             file.path(dir, "_quarto.yml"))
  expect_equal(portfolio_output_dir(dir), "_site")
})

test_that("the uncommitted check skips the output folder and files outside the project", {
  skip_on_cran()
  skip_if(!nzchar(Sys.which("git")), "git not available")
  local_git_identity()
  w <- local_workspace()

  # A rendered output folder and an unsaved journal elsewhere in the workspace
  # do not block a deploy.
  dir.create(file.path(w$site, "docs"))
  writeLines("rendered", file.path(w$site, "docs", "index.html"))
  writeLines("journal", file.path(w$ws, "journal.md"))
  msgs <- deploy_messages(w$site, render = FALSE, ask = FALSE)
  expect_match(msgs, "no uncommitted changes")

  # An unsaved change to the paper itself does.
  writeLines("Changed.", file.path(w$site, "index.qmd"))
  msgs <- deploy_messages(w$site, render = FALSE, ask = FALSE)
  expect_match(msgs, "uncommitted changes detected")
  expect_match(msgs, "index.qmd")
})

test_that("ensure_gh_pages() creates the branch on origin without touching the working tree", {
  skip_on_cran()
  skip_if(!nzchar(Sys.which("git")), "git not available")
  local_git_identity()
  w <- local_workspace()

  expect_length(git(w$ws, "ls-remote", "--heads", "origin", "gh-pages"), 0)
  expect_null(ensure_gh_pages(w$site))
  expect_match(git(w$ws, "ls-remote", "--heads", "origin", "gh-pages"), "refs/heads/gh-pages")
  expect_equal(git(w$ws, "branch", "--show-current"), "main")
  expect_length(git(w$ws, "status", "--porcelain"), 0)

  # A second call finds the branch and changes nothing.
  before <- git(w$ws, "ls-remote", "--heads", "origin", "gh-pages")
  expect_null(ensure_gh_pages(w$site))
  expect_equal(git(w$ws, "ls-remote", "--heads", "origin", "gh-pages"), before)
})

test_that("ensure_gh_pages() names a missing origin remote", {
  skip_on_cran()
  skip_if(!nzchar(Sys.which("git")), "git not available")
  dir <- withr::local_tempdir()
  system2("git", c("init", "-q", shQuote(dir)))
  expect_match(ensure_gh_pages(dir), "not connected to a GitHub repository")
})

test_that("deploy_portfolio() renders and publishes a nested project to gh-pages", {
  skip_on_cran()
  skip_if(!nzchar(Sys.which("git")), "git not available")
  skip_if(!nzchar(quarto_cli_path()), "Quarto CLI not available")
  skip_if_not_installed("quarto")
  local_git_identity()
  w <- local_workspace()

  expect_true(suppressMessages(deploy_portfolio(w$site, ask = FALSE)))
  published <- system2("git", c("--git-dir", shQuote(w$origin), "ls-tree", "--name-only", "gh-pages"),
                       stdout = TRUE)
  expect_true("index.html" %in% published)
  expect_equal(git(w$ws, "branch", "--show-current"), "main")
})
