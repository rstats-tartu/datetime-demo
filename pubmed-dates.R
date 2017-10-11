library(tidyverse)
query <- 'expression profiling by high throughput sequencing[DataSet Type]'

library(entrezquery)
ds <- entrez_docsums(query, retmax = 100)
ds

# Extract PubMed Ids
pmid <- ds %>% filter(PubMedIds!="") %>% .$PubMedIds
## Install pubmed_docsums from gist
devtools::source_gist("e5045186f0ac39fe16e0f0bbcd637dd1")

pmds <- pubmed_docsums(pmid)

library(lubridate)
mutate_at(pmds, vars(matches("Date")), ymd)



