library(tidyverse)
library(stringr)
query <- 'expression profiling by high throughput sequencing[DataSet Type]'

library(entrezquery)
ds <- entrez_docsums(query)
ds

# Extract PubMed Ids
pmid <- ds %>% filter(PubMedIds!="") %>% .$PubMedIds

## Install pubmed_docsums from gist
devtools::source_gist("e5045186f0ac39fe16e0f0bbcd637dd1")

pmds <- pubmed_docsums(pmid)

library(lubridate)
## Merge tables
merged_ds <- left_join(pmds, select(ds, PubMedIds, Accession, PDAT, GPL))
merged_ds

# Parse dates into common format
merged_ds <- mutate_at(merged_ds, 
                       vars(PDAT, PubDate, EPubDate), ymd) %>% 
  select(Accession, PubMedIds, PDAT, PubDate, EPubDate, Source, LastAuthor, GPL)

# If PubDate is missing, use EPubDate
merged_ds <- merged_ds %>% 
  mutate(PubDate = if_else(is.na(PubDate), EPubDate, PubDate))

# Records still missing publication date
no_pubdate <- filter(merged_ds, is.na(PubDate))

# Calculate difference between HT-seq data submission and article publication date
merged_ds <- merged_ds %>% mutate(pubdiff = PDAT - PubDate)

## plot pubdiff histogram
merged_ds %>% 
  ggplot(aes(pubdiff)) +
  geom_histogram(aes(y = (..count..)/sum(..count..)), binwidth = 25) +
  labs(title = str_wrap("Time period between article publication and making HT-seq data available", 40),
       y = "Percent of articles",
       x = "Time period in days") +
  scale_y_continuous(labels = scales::percent)
