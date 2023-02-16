
## Chi-Square Test for Renata's data ##
### Made by Guillermo Garcia Costoya

## Load packages ----

library(tidyverse)
library(readr)

## Load data ----

crossings <- read_csv("~/Desktop/Reno/Hydra/Poolseq_dewlap/Staple_data/Analyses/Chi-square/renata_data.csv")

## Add columns ----

# generate a crossing column
crossings$cross <- paste(crossings$mom_P,"x",crossings$dad_P)

# change values of crossing column such that "B x S" = "S x B"
crossings$cross <- ifelse(crossings$cross == "B x S", "S x B", crossings$cross)

# Estimating crossing genotypes ----

# if B x B then both have to be ss
crossings$cross_G <- ifelse(crossings$cross == "B x B", "ss x ss", NA)

# if S x B and we see 1 offspring that is B then S has to be Ss
crossings$cross_G <- ifelse(crossings$cross == "S x B" & crossings$B_obs > 0, "Ss x ss", crossings$cross_G)

# if S x B but we don't see any B offspring then S has to be SS
crossings$cross_G <- ifelse(crossings$cross == "S x B" & crossings$B_obs < 1, "SS x ss", crossings$cross_G)

# if S x S but we see some offspring B then both S have to be Ss
crossings$cross_G <- ifelse(crossings$cross == "S x S" & crossings$B_obs > 0, "Ss x Ss", crossings$cross_G)

# if S x S but we do not see any B offspring we know that one of the parents is SS
# for sure but the other one we cannot know so I marked as S_
crossings$cross_G <- ifelse(is.na(crossings$cross_G), "S_ x SS", crossings$cross_G)

# Chi Square tests ----

# calculate total offspring number
crossings$N_off <- crossings$S_obs + crossings$B_obs

# calculate expected S
crossings$S_exp <- ifelse(crossings$cross_G == "S_ x SS", 1 * crossings$N_off,
                          ifelse(crossings$cross_G == "SS x ss", 1 * crossings$N_off,
                                 ifelse(crossings$cross_G == "Ss x Ss", 0.75 * crossings$N_off,
                                        ifelse(crossings$cross_G == "Ss x ss", 0.5 * crossings$N_off, 0))))

# calculate expected B
crossings$B_exp <- crossings$N_off - crossings$S_exp

# empty row to get the chi estimate & significance
crossings$Xi <- rep(NA, nrow(crossings))

# loop to get the Xi estimate & significance
for(i in 1:nrow(crossings)){

  # solids
  solids <- ((crossings$S_obs[i] - crossings$S_exp[i]) ^ 2)/crossings$S_exp[i]

  # bicolors
  bicolors <- ((crossings$B_obs[i] - crossings$B_exp[i]) ^ 2)/crossings$B_exp[i]

  # sum of both
  crossings$Xi[i] <- solids + bicolors

}

# significance
crossings$p_value <- pchisq(crossings$Xi, df = 1)






