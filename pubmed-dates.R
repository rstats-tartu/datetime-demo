
library(tidyverse)
library(stringr)

query <- 'expression profiling by high throughput sequencing[DataSet Type]'

# devtools::install_github("tpall/entrezquery")
library(entrezquery)
ds <- entrez_docsums(query, retmax = 500)
ds

# Extract PubMed Ids
pmid <- ds %>% filter(PubMedIds!="") %>% .$PubMedIds
pmid

## Install pubmed_docsums from gist
devtools::source_gist("e5045186f0ac39fe16e0f0bbcd637dd1")

pmds <- pubmed_docsums(pmid)
pmds

library(lubridate)

## Merge tables
merged_ds <- left_join(pmds, select(ds, PubMedIds, Accession, PDAT, GPL))
merged_ds

# Parse dates into common format
merged_ds <- mutate_at(merged_ds, 
                       vars(PDAT, PubDate, EPubDate), ymd) %>% 
  select(Accession, PubMedIds, PDAT, PubDate, EPubDate, Source, LastAuthor, GPL)
merged_ds

# If PubDate is missing, use EPubDate
merged_ds <- merged_ds %>% 
  mutate(PubDate = if_else(is.na(PubDate), EPubDate, PubDate))
merged_ds
# Records still missing publication date
no_pubdate <- filter(merged_ds, is.na(PubDate))
no_pubdate

# Calculate difference between HT-seq data submission and article publication date
merged_ds <- merged_ds %>% mutate(pubdiff = PDAT - PubDate)
merged_ds

## plot pubdiff histogram
library(scales)
merged_ds %>% 
  ggplot(aes(pubdiff)) +
  geom_histogram(aes(y = (..count..)/sum(..count..)), binwidth = 25) +
  labs(title = str_wrap("Time period between article publication and making HT-seq data available", 40),
       y = "Percent of articles",
       x = "Time period in days") +
  scale_y_continuous(labels = percent)
