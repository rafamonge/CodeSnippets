Test1 <- data.frame(A=c(1,2,3),DataSet="1")
Test2 <- data.frame(A=c(10,20,33),DataSet="2")
Test3 <- data.frame(A=c(100,200,333),DataSet="3")
Test4 <- rbind(Test1,Test2,Test3)
# A basic box plot
ggplot(Test4, aes(x=DataSet, y=A)) + geom_boxplot()