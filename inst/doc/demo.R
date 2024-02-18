## ----setup, include = FALSE---------------------------------------------------
in_pkgdown <- identical(Sys.getenv("IN_PKGDOWN"), "true")
if (in_pkgdown) {
  options(crayon.enabled = TRUE)
}
options(cli.num_colors = 1)
knitr::opts_chunk$set(
  collapse = TRUE,
  error = !in_pkgdown
)

## ----create-package, eval = FALSE---------------------------------------------
#  pkg <- usethis::create_package("tea")

## ----create-package-real, echo = FALSE, message=FALSE, warning=FALSE----------
parent_dir <- file.path(tempdir(), "fledge")
dir.create(parent_dir, recursive = TRUE)
dir.create(file.path(parent_dir, "remote"))
gert::git_init(file.path(parent_dir, "remote"), bare = TRUE)
pkg <- fledge::create_demo_project("tea", open = FALSE, dir = parent_dir)

## ----change-dir, echo=FALSE---------------------------------------------------
knitr::opts_knit$set(root.dir = pkg)

## ----pkg-location, echo=FALSE-------------------------------------------------
withr::with_options(
  list("usethis.quiet" = TRUE), 
  usethis::proj_set()
)

## ----pkg-location2, eval=FALSE------------------------------------------------
#  usethis::proj_set()

## ----dir-tree-----------------------------------------------------------------
fs::dir_ls()

## ----git-show-init------------------------------------------------------------
# Number of commits until now
nrow(gert::git_log())
# Anything staged?
gert::git_status()

## ----git-no-ff----------------------------------------------------------------
gert::git_config_set("merge.ff", "false")
# gert::git_config_global_set("merge.ff", "false") # to set globally

## ----git-remote, echo=FALSE, message=TRUE-------------------------------------
# In real life this would be an actual URL not a filepath :-)
remote_url <- file.path(parent_dir, "remote")
gert::git_remote_add(remote_url, name = "origin")
gert::git_push(remote = "origin")

## ----git-show-----------------------------------------------------------------
show_files <- function(remote_url) {
  tempdir_remote <- withr::local_tempdir(pattern = "remote")
  withr::with_dir(tempdir_remote, {
    repo <- gert::git_clone(remote_url)  
    suppressMessages(gert::git_branch_checkout("main", force = TRUE, repo = "remote"))
    fs::dir_ls("remote", recurse = TRUE)
  })
}
show_files(remote_url)

show_tags <- function(remote_url) {
  tempdir_remote <- withr::local_tempdir(pattern = "remote")
  withr::with_dir(tempdir_remote, {
    gert::git_clone(remote_url)  
    # Only show name and ref
    gert::git_tag_list(repo = "remote")[, c("name", "ref")]
  })
}

## ----init-news----------------------------------------------------------------
usethis::use_news_md()

## ----init-news-review---------------------------------------------------------
news <- readLines(usethis::proj_path("NEWS.md"))
cat(news, sep = "\n")

## ----init-news-commit, results='hide'-----------------------------------------
gert::git_add("NEWS.md")
gert::git_commit("Initial NEWS.md .")
gert::git_push(remote = "origin")

## ----news-remote--------------------------------------------------------------
show_files(remote_url)

## ----use-cup------------------------------------------------------------------
usethis::use_r("cup")
writeLines("# cup", "R/cup.R")

## ----commit-cup, results='hide'-----------------------------------------------
gert::git_add("R/cup.R")
gert::git_commit("- New cup_of_tea() function makes it easy to drink a cup of tee.")
gert::git_push()

## ----cup-remote---------------------------------------------------------------
show_files(remote_url)

## ----use-cup-test-------------------------------------------------------------
usethis::use_test("cup")
cat(readLines("tests/testthat/test-cup.R"), sep = "\n")

## ----commit-cup-test, results='hide'------------------------------------------
gert::git_add("DESCRIPTION")
gert::git_add("tests/testthat.R")
gert::git_add("tests/testthat/test-cup.R")
gert::git_commit("- Add tests for cup of tea.")
gert::git_push()

## ----cup-test-remote----------------------------------------------------------
show_files(remote_url)

## ----commit-log---------------------------------------------------------------
# Only show number of files, messages
knitr::kable(gert::git_log()[-(1:3)])

## ----bump---------------------------------------------------------------------
fledge::bump_version()

## ----news-review--------------------------------------------------------------
news <- readLines("NEWS.md")
cat(news, sep = "\n")

## ----news-tweak---------------------------------------------------------------
news <- gsub("tee", "tea", news)
cat(news, sep = "\n")
writeLines(news, "NEWS.md")

## ----news-finalize------------------------------------------------------------
show_tags(remote_url)
fledge::finalize_version(push = TRUE)
show_tags(remote_url)

## ----news-second-review-------------------------------------------------------
news <- readLines("NEWS.md")
cat(news, sep = "\n")

## ----bowl-branch--------------------------------------------------------------
gert::git_branch_create("f-bowl", checkout = TRUE)

## ----bowl---------------------------------------------------------------------
usethis::use_test("bowl")

## ----bowl-git, results='hide'-------------------------------------------------
gert::git_add("tests/testthat/test-bowl.R")
gert::git_commit("Add bowl tests.")

## ----bowl-2-------------------------------------------------------------------
usethis::use_r("bowl")
writeLines("# bowl of tea", "R/bowl.R")

## ----bowl-2-git, results='hide'-----------------------------------------------
gert::git_add("R/bowl.R")
gert::git_commit("Add bowl implementation.")

## ----bowl-merge, results='hide'-----------------------------------------------
gert::git_branch_checkout("main")
gert::git_merge("f-bowl", commit = FALSE)
gert::git_commit("- New bowl_of_tea() function makes it easy to drink a bowl of tea.")

## ----bump-two-----------------------------------------------------------------
fledge::bump_version()
news <- readLines("NEWS.md")
writeLines(news)
fledge::finalize_version(push = TRUE)

## ----bump-patch---------------------------------------------------------------
fledge::bump_version("patch")

## ----patch-news-review--------------------------------------------------------
news <- readLines("NEWS.md")
cat(news, sep = "\n")

## ----tag----------------------------------------------------------------------
fledge::tag_version()
show_tags(remote_url)

## ----bump-dev-----------------------------------------------------------------
fledge::bump_version()
news <- readLines("NEWS.md")

## ----end, include=FALSE-------------------------------------------------------
knitr::opts_knit$set(root.dir = dirname(knitr::current_input(dir = TRUE)))

## ----end2, pkg=FALSE, eval=TRUE-----------------------------------------------
unlink(parent_dir, recursive = TRUE)

