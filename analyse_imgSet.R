library(ggplot2)
library(jpeg)
library(plyr)
library(scales)
library(grid)

# set parameters
username <- 'bibzzzz'
n_cols <- 20
specificity <- 1  #specify level of colour aggregation (higher = more detailed rgb selection)
col_measure_cutoff <- 0.2

# find pixelated images for analysis
current_dir <- getwd()
photo_dir <- paste0(current_dir,"/",username,"/")
setwd(photo_dir)
filename_list <- list.files(pattern = "\\_pix.jpg$")

# aggregate pixel data from user image collection
user_rgb_data <- data.frame()
for (filename in filename_list){
  img_data <- readJPEG(paste0(photo_dir,filename))
  img_rgb_data <- data.frame(r=c(img_data[ , , 1]),g=c(img_data[ , , 2]),b=c(img_data[ , , 3]))
  user_rgb_data <- rbind(user_rgb_data,img_rgb_data)
}

# summarise pixel colour data
col_sum <- count(round(user_rgb_data,specificity))
col_sum <- data.frame(col_sum[order(-col_sum$freq),])
col_sum$pct <- col_sum$freq/sum(col_sum$freq)
col_sum$rgb <- rgb(col_sum$r,col_sum$g,col_sum$b)
col_sum$col_measure <- abs(apply(data.frame(col_sum$r,col_sum$g,col_sum$b), 1, max) - apply(data.frame(col_sum$r,col_sum$g,col_sum$b), 1, min))
# col_sum$label_col <- ifelse(round(1-col_sum$r) + round(1-col_sum$g) + round(1-col_sum$b) > 1, rgb(1,1,1), rgb(0,0,0)) # in case we want to choose an appropriate colour to display labels within the bars
plot_data <- col_sum[col_sum$col_measure >= col_measure_cutoff,][1:n_cols,]
plot_data$rank <- 1:nrow(plot_data)

# plot colour prevelance summary
colfreq_plot <- ggplot(data=plot_data,aes(x=rank,y=pct,fill=rgb)) +
  geom_bar(stat="identity", colour = "black") +
  geom_text(data = plot_data, aes(colour = "black", label = sprintf("%1.1f%%", 100*pct)), vjust = -1, size = 5, position=position_dodge(.9)) +
  # labs(title = paste0(username,"\ninstagram colour palette")) +
  xlab(paste0("\ntop ", nrow(plot_data), " colours (",100*round(sum(plot_data$pct),2),"% of image(s))")) +
  scale_x_discrete(limit = factor(plot_data$rgb)) +
  scale_fill_identity() +
  scale_colour_identity() +
  # scale_y_log10()
  scale_y_continuous(labels = percent, limits = c(0,max(plot_data$pct)+0.05)) +
  theme(
    legend.position="none"
    , panel.grid.major = element_line(size=0)
    , panel.grid.minor = element_line(size=0)
    , panel.background = element_blank()
    , plot.background = element_blank()
    #, plot.margin = unit(1,"lines")
    , plot.title = element_text(face = "bold", color = "black", size = 16)
    , axis.title.x = element_text(face = "bold", color = "black", size = 14)
    , axis.title.y = element_blank()
    , axis.text.x = element_text(angle = -90, vjust = 1, hjust = 0, size = 14,colour = "black")
    , axis.text.y = element_blank()
    , axis.ticks = element_blank()
  )

ggsave(paste0(photo_dir,username,"_summary.jpg"),colfreq_plot,height = 5, width = 12)

#create gradient based on the 2 most common colours
n_points <- 50000
df <- data.frame(x=runif(n_points),y=runif(n_points))
point <- df[sample.int(n_points,1),]

df$dist <- abs(df$x - point$x) + abs(df$y - point$y)

grad_plot <- ggplot(data=df,aes(x=x,y=y,colour=dist)) +
  geom_point(size=7,alpha=0.5) + 
  scale_colour_gradient(low=plot_data$rgb[1],high=plot_data$rgb[2]) +
  theme(
    legend.position="none"
    , panel.grid.major = element_line(size=0)
    , panel.grid.minor = element_line(size=0)
    , panel.background = element_blank()
    , plot.background = element_blank()
    #, plot.margin = unit(1,"lines")
    , axis.title.x = element_blank()
    , axis.title.y = element_blank()
    , axis.text.x = element_blank()
    , axis.text.y = element_blank()
    , axis.ticks = element_blank()
  )

ggsave(paste0(photo_dir,username,"_gradient.jpg"),grad_plot,height = 5, width = 5)