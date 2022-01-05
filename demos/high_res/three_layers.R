library('ggplot2')
library('gridExtra')
library('tidyverse')

layerPath <- '/Users/barilari/Desktop/data_temp/Marco_HighRes/derivatives/LAYNII/'

three_vaso_auditory <- 'three_layer_vaso_con_0001_auditory.txt' 

three_vaso_visual <- 'three_layer_vaso_con_0002_visual.txt' 

three_vaso_bimodal <- 'three_layer_vaso_con_0003_bimodal.txt' 


three_vaso_auditory <- read.table(file = paste(layerPath, three_vaso_auditory, sep = ''), 
                                  header = F)

three_vaso_visual <- read.table(file = paste(layerPath, three_vaso_visual, sep = ''), 
                                header = F)

three_vaso_bimodal <- read.table(file = paste(layerPath, three_vaso_bimodal, sep = ''), 
                                 header = F)

three_vaso_auditory <- three_vaso_auditory %>% 
  set_names(c("meanBeta", "sd", "nbVoxels")) %>% 
  add_column(layer = 1:nrow(three_vaso_auditory), Sequence = "vaso", condition = 'auditory') %>%
  relocate("Sequence", "condition", "layer", "meanBeta", "sd", "nbVoxels")

three_vaso_visual <- three_vaso_visual %>% 
  set_names(c("meanBeta", "sd", "nbVoxels")) %>% 
  add_column(layer = 1:nrow(three_vaso_visual), Sequence = "vaso", condition = 'visual') %>%
  relocate("Sequence", "condition", "layer", "meanBeta", "sd", "nbVoxels")

three_vaso_bimodal <- three_vaso_bimodal %>% 
  set_names(c("meanBeta", "sd", "nbVoxels")) %>% 
  add_column(layer = 1:nrow(three_vaso_bimodal), Sequence = "vaso", condition = 'bimodal') %>%
  relocate("Sequence", "condition", "layer", "meanBeta", "sd", "nbVoxels")

three_bold_auditory <- 'three_layer_bold_con_0001_auditory.txt' 

three_bold_visual <- 'three_layer_bold_con_0002_visual.txt' 

three_bold_bimodal <- 'three_layer_bold_con_0003_bimodal.txt' 

three_bold_auditory <- read.table(file = paste(layerPath, three_bold_auditory, sep = ''), 
                                  header = F)

three_bold_visual <- read.table(file = paste(layerPath, three_bold_visual, sep = ''), 
                                header = F)

three_bold_bimodal <- read.table(file = paste(layerPath, three_bold_bimodal, sep = ''), 
                                 header = F)

three_bold_auditory <- three_bold_auditory %>% 
  set_names(c("meanBeta", "sd", "nbVoxels")) %>% 
  add_column(layer = 1:nrow(three_bold_auditory), Sequence = "bold", condition = 'auditory') %>%
  relocate("Sequence", "condition", "layer", "meanBeta", "sd", "nbVoxels")

three_bold_visual <- three_bold_visual %>% 
  set_names(c("meanBeta", "sd", "nbVoxels")) %>% 
  add_column(layer = 1:nrow(three_bold_visual), Sequence = "bold", condition = 'visual') %>%
  relocate("Sequence", "condition", "layer", "meanBeta", "sd", "nbVoxels")

three_bold_bimodal <- three_bold_bimodal %>% 
  set_names(c("meanBeta", "sd", "nbVoxels")) %>% 
  add_column(layer = 1:nrow(three_bold_bimodal), Sequence = "bold", condition = 'bimodal') %>%
  relocate("Sequence", "condition", "layer", "meanBeta", "sd", "nbVoxels")

three_layers <- bind_rows(three_vaso_auditory, three_vaso_visual, three_vaso_bimodal, 
                          three_bold_auditory, three_bold_visual, three_bold_bimodal)

ggplot(data = three_layers,
       aes(x = layer, 
           y = meanBeta, 
           colour = condition)) +
  geom_point(size = 3, 
             show.legend = F) +
  geom_line(aes(linetype = Sequence),
            size =1.3,
            show.legend = F) +
  theme_classic() +
  scale_y_continuous(limits = c(min(three_layers$meanBeta) - 1,
                                max(three_layers$meanBeta) + 1),
                     breaks = c(round(seq(from = min(three_layers$meanBeta) - 1, 
                                          to = max(three_layers$meanBeta) + 1, 
                                          by = 4), digits = 2))) +
  scale_colour_manual(values=c('#0091d4', "#e35656", "#b66bbe"), breaks=c('auditory','visual', 'bimodal')) +
  scale_x_continuous(limits = c(1, nrow(three_layers)/6),
                     breaks = c(seq(from = 1, 
                                    to = nrow(three_layers)/6, 
                                    by = 1))) +
  labs(color = 'Exp. conditions') + 
  xlab('Layers')+
  ylab('Beta values')+
  ggtitle('Three layers') +
  theme(
    text=element_text(size=20),
    legend.position = 'right',
    legend.text=element_text(size=18),
    axis.line = element_line(size = 1),
    axis.text.x = element_text(size=17,colour="black"),
    axis.text.y = element_text(size=17, colour='black'))

ggsave(paste(layerPath, "/three_layers.png", sep = ""),device="png", units="in", width=4.54, height=4.54, dpi=300)

