#' Create example repo for fledge demos
#'
#' @param open Whether to open the new project.
#' @param name Package name.
#' @param maintainer Name for DESCRIPTION and git.
#' @param email Email for DESCRIPTION and git.
#' @param date String of time for DESCRIPTION and git.
#' @param dir Directory within which to create the mock package folder.
#' @param news If TRUE, create a NEWS.md file.
#'
#' @return The path to the newly created mock package.
#' @export
#'
create_demo_project <- function(open = rlang::is_interactive(),
                                name = "tea",
                                maintainer = NULL,
                                email = NULL,
                                date = "2021-09-27",
                                dir = file.path(tempdir(), "fledge"),
                                news = FALSE) {
  if (is.null(maintainer)) {
    maintainer <- whoami::fullname(fallback = "Kirill M\u00fcller")
  }

  if (is.null(email)) {
    email <- whoami::email_address(fallback = "mail@example.com")
  }
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)

  withr::local_options(usethis.quiet = TRUE)

  # https://github.com/r-lib/usethis/issues/1504
  if (Sys.getenv("IN_PKGDOWN") != "") {
    withr::local_options(cli.num_colors = 1)
  }

  set_usethis_desc(maintainer = maintainer, email = email, date = date)
  pkg <- usethis::create_package(
    file.path(dir, name),
    fields = list(Date = as.Date(date)),
    rstudio = TRUE,
    open = open
  )

  withr::local_dir(new = pkg)
  desc::desc_del("LazyData")
  gert::git_init()
  gert::git_config_set("user.name", maintainer)
  gert::git_config_set("user.email", email)
  gert::git_add(".")
  gert::git_commit(
    "First commit",
    author = default_gert_author(),
    committer = default_gert_committer()
  )
  current_branch <- gert::git_branch()
  if (current_branch != "main") {
    gert::git_branch_move(current_branch, "main")
    current_branch <- gert::git_branch()
  }
  # Setting the option as get_main_branch() will rely on it
  gert::git_config_set(name = "init.defaultbranch", value = "main")

  if (news) {
    usethis::with_project(
      path = pkg,
      {
        rlang::with_interactive(
          {
            # we now have to create a demo project with a preambled NEWS.md for tests to pass
            withr::with_options(
              list(repos = c("CRAN" = "https://cloud.r-project.org")),
              {
                writeLines(
                  c(
                    paste0("# ", name, " 0.0.0.9000"),
                    "",
                    "* Added a `NEWS.md` file to track changes to the package."
                  ),
                  "NEWS.md"
                )
              }
            )
          },
          value = FALSE
        )
        gert::git_add("NEWS.md")
        gert::git_commit(
          "Add NEWS.md to track changes.",
          author = default_gert_author(),
          committer = default_gert_committer()
        )
      }
    )
  }

  return(pkg)
}


set_usethis_desc <- function(maintainer, email, date) {
  withr::local_options(
    usethis.full_name = maintainer,
    usethis.protocol = "ssh",
    usethis.description = list(
      "Authors@R" = utils::person(
        maintainer,
        email = email,
        role = c("aut", "cre"),
      ),
      Version = "0.0.0.9000",
      context = "fledge-example",
      RoxygenNote = "42"
    ),
    .local_envir = parent.frame(n = 2)
  )
}


#' Run code in temporary project
#'
#' @inheritParams create_demo_project
#' @param quiet Whether to show messages from usethis
#' @param code Code to run with temporary active project
#'
#'
#' @return None
#' @export
#'
#' @example man/examples/with_demo_project.R

with_demo_project <- function(code, dir = NULL, news = TRUE, quiet = FALSE) {
  if (is.null(dir)) {
    dir <- withr::local_tempdir(pattern = "fledge")
  }

  if (!dir.exists(dir)) {
    rlang::abort(message = c(x = sprintf("Can't find the directory `%s`.", dir)))
  }

  repo <- create_demo_project(dir = dir, news = TRUE)
  usethis::with_project(
    path = repo,
    quiet = quiet,
    code
  )
}
