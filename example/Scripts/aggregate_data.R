library(tidyverse)

setwd("E:/git_repos/PhoneGraphs")
folder <- 'example/Outputs'

full_df <- tibble()

for (f in list.files(folder)) {
  full_path <- file.path(folder, f)
  data <- read_csv(full_path, col_types = cols())
  full_df <- rbind(full_df, data)
}

full_df <- full_df %>%
  separate(model_name, sep = '_', into=c('language', 'cluster_type', 'edge_type', NA, 'weighting', 'tails'), remove=FALSE) %>%
  mutate(weighting = ifelse(weighting == 'tokens', 'lex', 'att'),
         tails = ifelse(tails == '1', TRUE, FALSE))

write_csv(full_df, 'nelson_model_correlations.csv')

judgements_folder <- 'example/Judgements'
judgements_df <- tibble()

for (f in list.files(judgements_folder)) {
  if (!str_detect(f, 'Template')) {
    full_path <- file.path(judgements_folder, f)
    data <- read_tsv(full_path, col_names=FALSE, col_types = cols())
    colnames(data) <- c("form", "rating")

    foo <- lapply(str_split(data$form, ' ',), head, 2)
    bar <- unlist(lapply(foo, paste, sep='', collapse=' '))
    data$form <- bar

    data <- data %>%
      group_by(form) %>%
      summarize(rating=mean(rating))

    data$model_name <- f
    data <- data %>%
      separate(model_name, sep = '_', into=c('language', 'cluster_type', 'edge_type', NA, 'weighting', 'tails'), remove=FALSE) %>%
      mutate(weighting = ifelse(weighting == 'tokens', 'lex', 'att'),
             tails = ifelse(tails == '1', TRUE, FALSE))
    judgements_df <- rbind(judgements_df, data)
  }
}

write_csv(judgements_df, 'nelson_model_judgements.csv')
