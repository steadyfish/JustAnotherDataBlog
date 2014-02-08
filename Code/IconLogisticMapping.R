library(ggplot2)

mapping <- function(k,x){
  k*x*(1-x)
}
l1 <- 1000 #no. of iterations
l2 <- 500 #no. of different values of "k"
l3 <- 50 #no. of different initial starting points
result <- matrix(nrow = l2*l3,ncol = 2)
start = 3.5
end = 3.6
k_array <- seq(from = start, to = end, by = ((end - start)/(l2 - 1)))
j=1
for(k in k_array){
  for(m in 1:l3){
    x = runif(1) #initial value
    for(i in 1:l1){
      x <- mapping(k,x)
    }
    result[l3*(j-1)+m,1] = k
    result[l3*(j-1)+m,2]=x 
  }
j=j+1
}

result.df <- data.frame(cbind(result,index = 1:l2*l3))
colnames(result.df) <- c("Constant","Equilibrium","Index")
#alpha = I(0.2),
#+ geom_density2d(colour="red")
p = ggplot(data=result.df,aes(x=Constant,y=Equilibrium)) + stat_density2d(geom="tile", aes(fill = ..density..), contour = FALSE)
#geom_point( colour="blue", size=0.2, alpha = I(0.3)) 
p
png(file="D:/JustAnotherDataBlog/Plots/Icon_logistic_mapping_histogram_ggplot.png",width=600,height=400)

p2 = ggplot(data=result.df,aes(x=Equilibrium)) + geom_histogram(binwidth=(end - start)/(l2 - 1))
p2 + theme(axis.text.x = element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),
          axis.text.y = element_blank(),axis.title.y=element_blank(),axis.ticks.y=element_blank())
dev.off()