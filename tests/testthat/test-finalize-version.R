test_that("finalize_version(push = FALSE)", {
  news_tempdir <- withr::local_tempdir(pattern = "news")

  with_demo_project(quiet = TRUE, {
    use_r("bla")
    gert::git_add("R/bla.R")
    gert::git_commit("* Ad cool bla.")
    shut_up_fledge(bump_version())

    news <- readLines("NEWS.md")
    news <- sub("Ad cool", "Add cool", news)
    writeLines(news, "NEWS.md")

    expect_snapshot(finalize_version(push = FALSE), variant = rlang_version())
    file.copy("NEWS.md", file.path(news_tempdir, "NEWS-push-false.md"))
  })

  expect_snapshot_file(
    file.path(news_tempdir, "NEWS-push-false.md"),
    compare = compare_file_text
  )
})

test_that("finalize_version(push = TRUE)", {
  news_tempdir <- withr::local_tempdir(pattern = "news")

  with_demo_project(quiet = TRUE, {
    remote_url <- create_remote()
    use_r("bla")
    gert::git_add("R/bla.R")
    gert::git_commit("* Ad cool bla.")
    shut_up_fledge(bump_version())

    news <- readLines("NEWS.md")
    news <- sub("Ad cool", "Add cool", news)
    writeLines(news, "NEWS.md")

    expect_snapshot(finalize_version(push = TRUE), variant = rlang_version())
    file.copy("NEWS.md", file.path(news_tempdir, "NEWS-push-true.md"))
    expect_snapshot(show_tags(remote_url))
    expect_snapshot(show_files(remote_url))
  })

  expect_snapshot_file(
    file.path(news_tempdir, "NEWS-push-true.md"),
    compare = compare_file_text
  )
})
