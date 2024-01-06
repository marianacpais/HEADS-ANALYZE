####################################################################################
#
# Machine Learning Evaluation Methods
#
# by Pedro Pereira Rodrigues <pprodrigues@med.up.pt>
#
####################################################################################

install.packages("caret")
install.packages("pROC")

################
### Packages

# Load package 'caret'
library(caret)
# Load package 'pROC'
library(pROC)

################
### Data

# Get data set from UCI repository - Breast Cancer Coimbra
# - available from https://archive.ics.uci.edu/ml/datasets/Breast+Cancer+Coimbra

# Define the filename
filename <- "Lesson 09/dataR2.csv"

# Load the CSV file from the local directory
dataset <- read.csv(filename, header=T)
dim(dataset)

# Define Classification as factor
dataset$Classification <- factor(dataset$Classification, levels=1:2, labels=c("Control", "Patient"))

################
# Holdout a validation set, by defining the indices of the training set
training.index <- createDataPartition(dataset$Classification, p=0.8, list=FALSE)
validation <- dataset[-training.index,]
dim(validation)
dataset <- dataset[training.index,]
dim(dataset)

################
### Summarize

# Dimensions (should be 116 observations and 10 variables) # TODO @mariana.pais should it?!
dim(dataset)

# Types of variables
sapply(dataset, class)

# Take a peek at the data
head(dataset)

# Levels of the class
levels(dataset$Classification)

# Class distribution
proportions <- prop.table(table(dataset$Classification))
cbind(
  Frequency=table(dataset$Classification),
  Proportion=round(proportions*100,2)
)

# Statistical Summary
summary(dataset)

################
# Visualize

# Split input and output
input <- dataset[,-10]
output <- dataset[,10]

# Boxplot for each variable
par(mfrow=c(3,3))
bplots <- lapply(input, boxplot)

# Barplot for class breakdown
par(mfrow=c(1,1))
plot(output)

# Multivariate plot
featurePlot(x=input, y=output, plot="ellipse")

# Box and whisker plots
scales <- list(x=list(relation="free"), y=list(relation="free"))
featurePlot(x=input, y=output, plot="box", scales=scales)

# Density plots for each attribute by class value
scales <- list(x=list(relation="free"), y=list(relation="free"))
featurePlot(x=input, y=output, plot="density", scales=scales)

################
# Test harness

# Define the metric
# metric <- "ROC"
# Define the estimation method
# control <- trainControl(...)
# Train the model with chosen metric and method (output is factor with "Yes" or "No")
# fit.model <- train(output ~ ., data=dataset, method="nnet", metric=metric, trControl=control)
# Plot ROC curve
# plot.roc(fit.model$pred$obs,fit.model$pred$Yes, main=fit.model$method, print.auc=T)

# Run algorithm using different validation approaches
metric <- "ROC"

# Run algorithm using 20% hold-out validation
control <- trainControl(method="LGOCV", p=0.8, number=1,
                        summaryFunction=twoClassSummary,
                        classProbs=T,
                        savePredictions = T)

set.seed(7)
fit.cart.hold <- train(Classification ~ ., data=dataset, method="rpart", metric=metric, trControl=control)

set.seed(7)
fit.nb.hold <- train(Classification ~ ., data=dataset, method="naive_bayes", metric=metric, trControl=control)

# Summarize accuracy of models
fit.models <- list(rpart=fit.cart.hold, nb=fit.nb.hold)
results <- resamples(fit.models)
summary(results)

# ROC curves for models
par(mfrow=c(1,2))
rocs <- lapply(fit.models, function(fit){plot.roc(fit$pred$obs,fit$pred$Patient, main=paste("20% Hold-out -",fit$method), debug=F, print.auc=T)})

# Compare accuracy of models
dotplot(results)

# Run algorithm using multiple 20% hold-out validation
control <- trainControl(method="LGOCV", p=0.8, number=25,
                        summaryFunction=twoClassSummary,
                        classProbs=T,
                        savePredictions = T)

set.seed(7)
fit.cart.mhold <- train(Classification ~ ., data=dataset, method="rpart", metric=metric, trControl=control)

set.seed(7)
fit.nb.mhold <- train(Classification ~ ., data=dataset, method="naive_bayes", metric=metric, trControl=control)

# Summarize accuracy of models
fit.models <- list(rpart=fit.cart.mhold, nb=fit.nb.mhold)
results <- resamples(fit.models)
summary(results)

# ROC curves for models
par(mfrow=c(1,2))
rocs <- lapply(fit.models, function(fit){plot.roc(fit$pred$obs,fit$pred$Patient, main=paste("25 x 20% Hold-out -",fit$method), debug=F, print.auc=T)})

# Compare accuracy of models
dotplot(results)

# Run algorithm using 10-fold cross validation
control <- trainControl(method="cv", number=10,
                        summaryFunction=twoClassSummary,
                        classProbs=T,
                        savePredictions = T, repeats = 1)

set.seed(7)
fit.cart.cv <- train(Classification ~ ., data=dataset, method="rpart", metric=metric, trControl=control)

set.seed(7)
fit.nb.cv <- train(Classification ~ ., data=dataset, method="naive_bayes", metric=metric, trControl=control)

# Summarize accuracy of models
fit.models <- list(rpart=fit.cart.cv, nb=fit.nb.cv)
results <- resamples(fit.models)
summary(results)

# ROC curves for models
par(mfrow=c(1,2))
rocs <- lapply(fit.models, function(fit){plot.roc(fit$pred$obs,fit$pred$Patient, main=paste("10-fold CV -",fit$method), debug=F, print.auc=T)})

# Compare accuracy of models
dotplot(results)

# Run algorithm using 25 times 10-fold cross validation
control <- trainControl(method="repeatedcv", number=10,
                        summaryFunction=twoClassSummary,
                        classProbs=T,
                        savePredictions = T, repeats = 25)

set.seed(7)
fit.cart.rcv <- train(Classification ~ ., data=dataset, method="rpart", metric=metric, trControl=control)

set.seed(7)
fit.nb.rcv <- train(Classification ~ ., data=dataset, method="naive_bayes", metric=metric, trControl=control)

# Summarize accuracy of models
fit.models <- list(rpart=fit.cart.rcv, nb=fit.nb.rcv)
results <- resamples(fit.models)
summary(results)

# ROC curves for models
par(mfrow=c(1,2))
rocs <- lapply(fit.models, function(fit){plot.roc(fit$pred$obs,fit$pred$Patient, main=paste("25 x 10-fold CV -",fit$method), debug=F, print.auc=T)})

# Compare accuracy of models
dotplot(results)

# Run algorithm using leave-one-out validation
control <- trainControl(method="LOOCV",
                        summaryFunction=twoClassSummary,
                        classProbs=T,
                        savePredictions = T)

set.seed(7)
fit.cart.loo <- train(Classification ~ ., data=dataset, method="rpart", metric=metric, trControl=control)

set.seed(7)
fit.nb.loo <- train(Classification ~ ., data=dataset, method="naive_bayes", metric=metric, trControl=control)

# Summarize accuracy of models
fit.models <- list(rpart=fit.cart.loo, nb=fit.nb.loo)
#results <- resamples(fit.models)
#summary(results)
summary(fit.models)

# ROC curves for models
par(mfrow=c(1,2))
rocs <- lapply(fit.models, function(fit){plot.roc(fit$pred$obs,fit$pred$Patient, main=paste("Leave-One-Out -",fit$method), debug=F, print.auc=T)})

# Compare accuracy of models
dotplot(results)

# Run algorithm using bootstrap validation
control <- trainControl(method="boot_all", number=25,
                        summaryFunction=twoClassSummary,
                        classProbs=T,
                        savePredictions = T)

set.seed(7)
fit.cart.boot <- train(Classification ~ ., data=dataset, method="rpart", metric=metric, trControl=control)

set.seed(7)
fit.nb.boot <- train(Classification ~ ., data=dataset, method="naive_bayes", metric=metric, trControl=control)

# Summarize accuracy of models
fit.models <- list(rpart=fit.cart.boot, nb=fit.nb.boot)
results <- resamples(fit.models)
summary(results)

# ROC curves for models
par(mfrow=c(1,2))
rocs <- lapply(fit.models, function(fit){plot.roc(fit$pred$obs,fit$pred$Patient, main=paste("25 x Bootstrap -",fit$method), debug=F, print.auc=T)})

# Compare accuracy of models
dotplot(results)

################
# Make predictions

par(mfrow=c(1,1))

# Estimate skill of GLM Step AIC on the validation dataset
predictions.prob <- predict(fit.nb.boot, validation, type="prob")
predictions <- predict(fit.nb.boot, validation, type="raw")
confusionMatrix(predictions, validation$Classification)
plot.roc(validation$Classification, predictions.prob$Patient, print.auc=T)
