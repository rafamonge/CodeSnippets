res <- apply(mtcars[1:11],2,fivenum)
res2 <- colMeans(mtcars)
res<- rbind(res,res2)
colnames(res) <- colnames(mtcars)
rownames(res) <- c("Minimum", "1st Q", "median", "3rd Q", "Maximum", "Mean")
write.csv(t(as.matrix(res)), file="C:/statistics2.csv") 


library(dplyr)

fiveNumSummary <- apply(mtcars[1:11],2,fivenum)
rownames(fiveNumSummary)  <- c("Minimum", "1st Q", "median", "3rd Q", "Maximum") 
write.csv(t(as.matrix(res)), file="C:/statistics3.csv") 
