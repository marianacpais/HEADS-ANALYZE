db <- read.csv("Lesson 1/Dataset_Diab_Example1_long.csv")

str (db)
factor <- c("Subject","Gender","Group","Medication","Measure")

str(db)
db$Subject <- as.factor(db$Subject)
db$Gender <- as.factor(db$Gender)
db$Group <- as.factor(db$Group)
db$Medication <- as.factor(db$Medication)
db$Measure <- as.factor(db$Measure)
db$Age <- as.numeric(db$Age)

str(db)
summary(db)
table(db$Subject)
install.packages("table1")
library(table1)

table1 <- table1(~ Gender + Medication + Age + Glucose | Group, data=db)
table1
