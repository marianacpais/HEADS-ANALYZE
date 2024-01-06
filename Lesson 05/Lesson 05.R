# install.packages("haven")
# install.packages("devtools")
# install.packages("psy")

library(haven)
library(devtools)
library(obs.agree)
library(psy)
library(boot)

devtools::install_local("Lesson 05/obs.agree_1.0.tar.gz")

agree <- read_sav("Lesson 05/agree.sav")
head(agree)
agree <- as.data.frame(agree)
agree <- data.matrix(agree)


# Question 1: assess the inter-rater agreement and reliability among doctors

# To asssess the agreement: Proportions of overall and specific agreement

RAI(agree[,c(1,2,3,4,5)])

# If one doctor, selected at random, makes a diagnosis (particular condition present: yes or no), the probability of another doctor making an equal diagnosis is 0.896 # nolint

# If one doctor, selected at random, makes the diagnosis yes (the particular condition is present), the probability of another doctor making the same diagnosis is 0.942 # nolint

# If one doctor, selected at random, makes the diagnosis no (the particular condition is not present), the probability of another doctor making the same diagnosis is 0.517 # nolint

# To assess reliability: Kappa

lkappa(agree[, c(1, 2, 3, 4, 5)])

lkappa.boot <- function(data, x) {
  lkappa(data[x, ])
}
res <- boot(agree[, c(1, 2, 3, 4, 5)], lkappa.boot, 1000)
boot.ci(res, type = "bca")

# The reliability of raters was K=0.473 # nolint

# Question 2: to know if the tests are inter substitutable you can do the Bland and Altaman limits of agreemnt (try it with JAMOVI :-) ) # nolint

# It is also possible to assess the reliability of scores obtained by the two tests using the Intraclass Correlation coefficient, ranging from 0 (no reliability) to 1 (maximum reliability). # nolint

icc(agree[, c(6, 7)]) 

# It is also possible to assess the disagreement of scores obtained by the testes using the Information Based Measure of disagreement ranging from 0 (no disagreement=total agreement) to 1 (maximum disagreement). # nolint

IBMD(agree[, c(6, 7)])