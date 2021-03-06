
list.files('../bucket_mount/verde_scratch/')


shakeup = readRDS('../bucket_mount/verde_scratch/payoff.change.1k.RDS')
shakeup = shakeup[sapply(shakeup,class)=='list']
mults = lapply(shakeup,'[[','payoffs')
issues = lapply(lapply(shakeup,'[[','cgr'),'[[','issues')
agents = lapply(lapply(shakeup,'[[','cgr'),'[[','agents')
info.sd = lapply(lapply(shakeup,'[[','issue_sd'),'[[','Mean')

dt = data.table(total.payoff = sapply(lapply(shakeup,'[[','cgr.payout.t'),sum),
                final.payoff = sapply(seq_along(shakeup),function(x)shakeup[[x]]$cgr.payout.t[[50]]),
                issue.sd = unlist(info.sd),
                med.issue = unlist(mapply(function(m,i) median(m[i]),m = mults,i = issues)),
                min.issue = unlist(mapply(function(m,i) min(m[i]),m = mults,i = issues)),
                max.issue = unlist(mapply(function(m,i) max(m[i]),m = mults,i = issues)),
                mean.issue = unlist(mapply(function(m,i) mean(m[i]),m = mults,i = issues)),
                mean.incentive = as.vector(unlist(lapply(lapply(shakeup,'[[',"starting.incentive"),function(x) x['Mean']))),
                med.incentive = as.vector(unlist(lapply(lapply(shakeup,'[[',"starting.incentive"),function(x) x['Median']))),
                min.incentive = as.vector(unlist(lapply(lapply(shakeup,'[[',"starting.incentive"),function(x) x['Min.']))),
                max.incentive = as.vector(unlist(lapply(lapply(shakeup,'[[',"starting.incentive"),function(x) x['Max.']))),
                agents = unlist(sapply(agents,length)),issues =  unlist(sapply(issues,length)))
dt$id = 1:nrow(dt)                          
dyn = lapply(shakeup,'[[','dynamics')
dyn = lapply(dyn,as.data.frame)
dyn_all = rbindlist(dyn,use.names = T)
dyn_all$t =  c(unlist(sapply(unlist(sapply(dyn,nrow)),seq)))
dyn_all$cgr.payout = unlist(lapply(shakeup,'[[','cgr.payout.t'))
dyn_all$total.payout = rep(sapply(lapply(shakeup,'[[','cgr.payout.t'),sum), each = sapply(lapply(shakeup,'[[','cgr.payout.t'),length))
dyn_all$iter = rep(1:length(shakeup),each =length(shakeup[[1]]$cgr.payout.t))
dyn_melt = melt(dyn_all,id.vars = c('total.payout','cgr.payout','t','iter'))
ggplot(dyn_melt,aes(x = as.factor(t),y = log(cgr.payout))) + geom_boxplot()




#####


newagents = readRDS('../bucket_mount/verde_scratch/add.agents.1k.RDS')
newagents = newagents[sapply(newagents,class)=='list']
mults = lapply(newagents,'[[','payoffs')
issues = lapply(lapply(newagents,'[[','cgr'),'[[','issues')
agents = lapply(lapply(newagents,'[[','cgr'),'[[','agents')
info.sd = lapply(lapply(newagents,'[[','issue_sd'),'[[','Mean')

dt = data.table(total.payoff = sapply(lapply(newagents,'[[','cgr.payout.t'),sum),
                final.payoff = sapply(seq_along(newagents),function(x)newagents[[x]]$cgr.payout.t[[50]]),
                issue.sd = unlist(info.sd),
                med.issue = unlist(mapply(function(m,i) median(m[i]),m = mults,i = issues)),
                min.issue = unlist(mapply(function(m,i) min(m[i]),m = mults,i = issues)),
                max.issue = unlist(mapply(function(m,i) max(m[i]),m = mults,i = issues)),
                mean.issue = unlist(mapply(function(m,i) mean(m[i]),m = mults,i = issues)),
                mean.incentive = as.vector(unlist(lapply(lapply(newagents,'[[',"starting.incentive"),function(x) x['Mean']))),
                med.incentive = as.vector(unlist(lapply(lapply(newagents,'[[',"starting.incentive"),function(x) x['Median']))),
                min.incentive = as.vector(unlist(lapply(lapply(newagents,'[[',"starting.incentive"),function(x) x['Min.']))),
                max.incentive = as.vector(unlist(lapply(lapply(newagents,'[[',"starting.incentive"),function(x) x['Max.']))),
                agents = unlist(sapply(agents,length)),issues =  unlist(sapply(issues,length)))
dt$id = 1:nrow(dt)                          
dyn = lapply(newagents,'[[','dynamics')
dyn = lapply(dyn,as.data.frame)
dyn_all = rbindlist(dyn,use.names = T)
dyn_all$t =  c(unlist(sapply(unlist(sapply(dyn,nrow)),seq)))
dyn_all$cgr.payout = unlist(lapply(newagents,'[[','cgr.payout.t'))
dyn_all$total.payout = rep(sapply(lapply(newagents,'[[','cgr.payout.t'),sum), each = sapply(lapply(newagents,'[[','cgr.payout.t'),length))
dyn_all$iter = rep(1:length(newagents),each =length(newagents[[1]]$cgr.payout.t))
dyn_melt = melt(dyn_all,id.vars = c('total.payout','cgr.payout','t','iter'))


summary(dyn_melt[!is.na(value),]$t)

after_loss = merge(dyn_melt[t > 10,][,sum(cgr.payout),by=.(iter,variable)],dyn_melt[t==11,.(iter,variable,value,t)])

post.payout = dyn_all[t>10,sum(cgr.payout),by=.(iter)]
post.pay = merge(dyn_all[t == 11,.(principled.engagement,capacity.for.joint.action,shared.motivation,iter)],post.payout)

g = ggplot(post.pay,aes(color = log(V1))) + 
  scale_color_viridis_c(name='ln(payoff after exit)',option = 'C') + 
  theme_bw()
g1 = g + geom_point(aes(x = principled.engagement,y = shared.motivation),pch = 19)
legend <- g_legend(g1 + theme(legend.direction = 'horizontal'))
g2 = g + geom_point(aes(x = principled.engagement,y = capacity.for.joint.action),pch = 19)
g3 = g + geom_point(aes(x = shared.motivation,y = capacity.for.joint.action),pch = 19)
grid.arrange(g1+theme(legend.position='hidden'), g2+theme(legend.position='hidden'),
             g3+theme(legend.position='hidden'), legend,
             top = "Total benefits after new agents join")




#################


losecontributor = readRDS('../bucket_mount/verde_scratch/lose.contributor.1k.RDS')
losecontributor = losecontributor[sapply(losecontributor,class)=='list']
mults = lapply(losecontributor,'[[','payoffs')
issues = lapply(lapply(losecontributor,'[[','cgr'),'[[','issues')
agents = lapply(lapply(losecontributor,'[[','cgr'),'[[','agents')
info.sd = lapply(lapply(losecontributor,'[[','issue_sd'),'[[','Mean')

dt = data.table(total.payoff = sapply(lapply(losecontributor,'[[','cgr.payout.t'),sum),
                final.payoff = sapply(seq_along(losecontributor),function(x)losecontributor[[x]]$cgr.payout.t[[50]]),
                issue.sd = unlist(info.sd),
                med.issue = unlist(mapply(function(m,i) median(m[i]),m = mults,i = issues)),
                min.issue = unlist(mapply(function(m,i) min(m[i]),m = mults,i = issues)),
                max.issue = unlist(mapply(function(m,i) max(m[i]),m = mults,i = issues)),
                mean.issue = unlist(mapply(function(m,i) mean(m[i]),m = mults,i = issues)),
                mean.incentive = as.vector(unlist(lapply(lapply(losecontributor,'[[',"starting.incentive"),function(x) x['Mean']))),
                med.incentive = as.vector(unlist(lapply(lapply(losecontributor,'[[',"starting.incentive"),function(x) x['Median']))),
                min.incentive = as.vector(unlist(lapply(lapply(losecontributor,'[[',"starting.incentive"),function(x) x['Min.']))),
                max.incentive = as.vector(unlist(lapply(lapply(losecontributor,'[[',"starting.incentive"),function(x) x['Max.']))),
                agents = unlist(sapply(agents,length)),issues =  unlist(sapply(issues,length)))
dt$id = 1:nrow(dt)                          
dyn = lapply(losecontributor,'[[','dynamics')
dyn = lapply(dyn,as.data.frame)
dyn_all = rbindlist(dyn,use.names = T)
dyn_all$t =  c(unlist(sapply(unlist(sapply(dyn,nrow)),seq)))
dyn_all$cgr.payout = unlist(lapply(losecontributor,'[[','cgr.payout.t'))
dyn_all$total.payout = rep(sapply(lapply(losecontributor,'[[','cgr.payout.t'),sum), each = sapply(lapply(losecontributor,'[[','cgr.payout.t'),length))
dyn_all$iter = rep(1:length(losecontributor),each =length(losecontributor[[1]]$cgr.payout.t))
dyn_melt = melt(dyn_all,id.vars = c('total.payout','cgr.payout','t','iter'))
ggplot(dyn_melt,aes(x = as.factor(t),y = log(cgr.payout+0.01))) + geom_boxplot()


after_loss = merge(dyn_melt[t > 10,][,sum(cgr.payout),by=.(iter,variable)],dyn_melt[t==11,.(iter,variable,value,t)])

ggplot(after_loss,aes(x = value,y = log(V1))) + geom_point(pch = 21,alpha = 0.5) +
  stat_smooth() + theme_bw() + 
  scale_y_continuous(name = 'ln(payout after contributor exit)')+
  facet_wrap(~variable,ncol = 2) + 
    scale_x_continuous('CGR dynamic value at time of contributor exit') + 
  ggtitle('Total payoffs after exit of significant contributor')


post.payout = dyn_all[t>10,sum(cgr.payout),by=.(iter)]
post.pay = merge(dyn_all[t == 11,.(principled.engagement,capacity.for.joint.action,shared.motivation,iter)],post.payout)


g = ggplot(post.pay,aes(color = log(V1))) + 
  scale_color_viridis_c(name='ln(payoff after exit)',option = 'C') + 
  theme_bw()
g1 = g + geom_point(aes(x = principled.engagement,y = shared.motivation),pch = 19)
legend <- g_legend(g1 + theme(legend.direction = 'horizontal'))
g2 = g + geom_point(aes(x = principled.engagement,y = capacity.for.joint.action),pch = 19)
g3 = g + geom_point(aes(x = shared.motivation,y = capacity.for.joint.action),pch = 19)
grid.arrange(g1+theme(legend.position='hidden'), g2+theme(legend.position='hidden'),
             g3+theme(legend.position='hidden'), legend,
             top = "Total benefits after major contributor exit")

t#################

ggplot(dyn_melt[t==1,],aes(x = value,y = log(total.payout))) +  
  geom_point(pch = 21,alpha = 0.2) + 
  facet_wrap(~variable,ncol = 2,scales = 'free') + 
  ggtitle('Starting values for collaborative dynamics') + 
  ylab('ln(Total public goods generated)') + 
  xlab('Starting group value') + theme_bw() +
  stat_smooth(fullrange = F)






newagents = readRDS('../bucket_mount/verde_scratch/add.agents.1k.RDS')

require(data.table)
newagents = newagents[sapply(newagents,class)=='list']



mults = lapply(newagents,'[[','payoffs')
issues = lapply(lapply(newagents,'[[','cgr'),'[[','issues')
agents = lapply(lapply(newagents,'[[','cgr'),'[[','agents')
info.sd = lapply(lapply(newagents,'[[','issue_sd'),'[[','Mean')

dt = data.table(total.payoff = sapply(lapply(newagents,'[[','cgr.payout.t'),sum),
                final.payoff = sapply(seq_along(newagents),function(x)newagents[[x]]$cgr.payout.t[[50]]),
                issue.sd = unlist(info.sd),
                med.issue = unlist(mapply(function(m,i) median(m[i]),m = mults,i = issues)),
                min.issue = unlist(mapply(function(m,i) min(m[i]),m = mults,i = issues)),
                max.issue = unlist(mapply(function(m,i) max(m[i]),m = mults,i = issues)),
                mean.issue = unlist(mapply(function(m,i) mean(m[i]),m = mults,i = issues)),
                mean.incentive = as.vector(unlist(lapply(lapply(newagents,'[[',"starting.incentive"),function(x) x['Mean']))),
                med.incentive = as.vector(unlist(lapply(lapply(newagents,'[[',"starting.incentive"),function(x) x['Median']))),
                min.incentive = as.vector(unlist(lapply(lapply(newagents,'[[',"starting.incentive"),function(x) x['Min.']))),
                max.incentive = as.vector(unlist(lapply(lapply(newagents,'[[',"starting.incentive"),function(x) x['Max.']))),
                agents = unlist(sapply(agents,length)),issues =  unlist(sapply(issues,length)))
dt$id = 1:nrow(dt)                          


dyn = lapply(newagents,'[[','dynamics')
dyn = lapply(dyn,as.data.frame)

dyn_all = rbindlist(dyn,use.names = T)
dyn_all$t =  c(unlist(sapply(unlist(sapply(dyn,nrow)),seq)))
dyn_all$cgr.payout = unlist(lapply(newagents,'[[','cgr.payout.t'))

dyn_all$total.payout = rep(sapply(lapply(newagents,'[[','cgr.payout.t'),sum), each = sapply(lapply(newagents,'[[','cgr.payout.t'),length))
dyn_all$iter = rep(1:length(newagents),each =length(newagents[[1]]$cgr.payout.t))


ggplot(dyn_all,aes(x = t,y = cgr.payout)) + geom_point()

dyn_melt = melt(dyn_all,id.vars = c('total.payout','cgr.payout','t','iter'))


ggplot(dyn_melt[t==1,],aes(x = value,y = log(total.payout))) +  
  geom_point(pch = 21,alpha = 0.2) + 
  facet_wrap(~variable,ncol = 2,scales = 'free') + 
  ggtitle('Starting values for collaborative dynamics') + 
  ylab('ln(Total public goods generated)') + 
  xlab('Starting group value') + theme_bw() +
  stat_smooth(fullrange = F)


#colnames(dt) <- c('benefits','sd(starting info)','median(issue multiplier)','mean(starting motivation)',
#                  '# agents in CGR','# issues in CGR','id')

dtl = melt(dt,id.vars = c('id','total.payoff','final.payoff'))
require(tidyverse)
ggplot(dtl[variable%in%c('issues','agents'),],aes(x = value,y = log(total.payoff),group = value)) + 
  geom_boxplot() + facet_wrap(~variable,scales = 'free_x') + theme_bw() +
  scale_x_continuous('# of agents (left) and issues (right) in CGR') + 
  scale_y_continuous('ln(total benefits generated by CGR)')

ggplot(dtl[variable%in%c('issues','agents'),],aes(x = value,y = log(total.payoff/value),group = value)) + 
  geom_boxplot() + facet_wrap(~variable,scales = 'free_x') + theme_bw() +
  scale_x_continuous('# of agents (left) and issues (right) in CGR') + 
  scale_y_continuous('ln(benefits/# of agents or # of issues)')


temp = dtl[variable %in% c('mean.incentive','issue.sd','mean.issue'),]
temp$variable = as.factor(as.character(temp$variable))
require(forcats)

temp$variable = fct_recode(temp$variable,'sd(starting info.)'='issue.sd','avg(starting incent.)'='mean.incentive',
                           'avg(public good mult.)'='mean.issue')
ggplot(temp,aes(x = value,y = log(total.payoff))) + 
  facet_wrap(~variable,scales = 'free_x',ncol = 2) + 
  geom_point(pch = 21,alpha = 0.2) + geom_smooth() + theme_bw() + 
  ggtitle('CGR benefits generated by starting parameter values') +   
  scale_y_continuous('ln(total benefits generated by CGR') +
  scale_x_continuous("starting value")


dyn = lapply(base,'[[','dynamics')
dyn = lapply(dyn,as.data.frame)

dyn_all = rbindlist(dyn,use.names = T)
dyn_all$t =  c(unlist(sapply(unlist(sapply(dyn,nrow)),seq)))
dyn_all$cgr.payout = unlist(lapply(base,'[[','cgr.payout.t'))

dyn_all$total.payout = rep(sapply(lapply(base,'[[','cgr.payout.t'),sum), each = sapply(lapply(base,'[[','cgr.payout.t'),length))
dyn_all$iter = rep(1:length(base),each =length(base[[1]]$cgr.payout.t))

dyn_melt = melt(dyn_all,id.vars = c('total.payout','cgr.payout','t','iter'))
     
ggplot(dyn_melt[t==1,],aes(x = value,y = log(total.payout))) +  
  geom_point(pch = 21,alpha = 0.2) + 
  facet_wrap(~variable,ncol = 2,scales = 'free') + 
  ggtitle('Starting values for collaborative dynamics') + 
  ylab('ln(Total public goods generated)') + 
  xlab('Starting group value') + theme_bw() +
  stat_smooth(fullrange = F)

ggplot(dyn_melt[,mean(value),by=.(variable,iter,total.payout)],aes(x = V1,y = log(total.payout))) +  
  geom_point(pch = 21,alpha = 0.2) + 
  facet_wrap(~variable,ncol = 2,scales = 'free') + 
  ggtitle('Average value for collaborative dynamics') + 
  ylab('ln(Total public goods generated)') + 
  xlab('Average value across periods') + theme_bw() +
  stat_smooth(fullrange = F)



dyn.avg = dyn_all[,list(mean(principled.engagement),
              mean(capacity.for.joint.action),
              mean(shared.motivation)),by=.(iter,total.payout)]
setnames(dyn.avg,c('V1','V2','V3'),c('principled.engagement','capacity.for.joint.action','shared.motivation'))


library(GGally)
library(lemon)
g = ggplot(dyn.avg,aes(col = log(total.payout))) + theme_bw() + 
  scale_color_viridis_c(option = 'C',direction = -1) + scale_y_continuous(limits = c(0,1)) +
  scale_x_continuous(limits = c(0,1))

g1 = g + geom_point(aes(x = principled.engagement,y = capacity.for.joint.action),
          pch = 21,alpha = 0.75) 
legend <- g_legend(g1 + theme(legend.direction = 'horizontal'))

g2 = g + geom_point(aes(x = principled.engagement,y = shared.motivation),
                    pch = 21,alpha = 0.75) 
g3 = g + geom_point(aes(x = shared.motivation,y = capacity.for.joint.action),
                    pch = 21,alpha = 0.75) 
grid.arrange(g1+theme(legend.position='hidden'), g2+theme(legend.position='hidden'),
             g3+theme(legend.position='hidden'), legend,
             top = "Average collaborative dynamics, 2-way combinations")
  
  


dyn.avg = dyn_all[,list(mean(principled.engagement),
                        mean(capacity.for.joint.action),
                        mean(shared.motivation)),by=.(iter,total.payout)]
setnames(dyn.avg,c('V1','V2','V3'),c('principled.engagement','capacity.for.joint.action','shared.motivation'))



g = ggplot(dyn_all[t==1,],aes(col = log(total.payout))) + theme_bw() + 
  scale_color_viridis_c(option = 'C',direction = -1) + scale_y_continuous(limits = c(0,1)) +
  scale_x_continuous(limits = c(0,1))

g1 = g + geom_point(aes(x = principled.engagement,y = capacity.for.joint.action),
                    pch = 21,alpha = 0.75) 
legend <- g_legend(g1 + theme(legend.direction = 'horizontal'))

g2 = g + geom_point(aes(x = principled.engagement,y = shared.motivation),
                    pch = 21,alpha = 0.75) 
g3 = g + geom_point(aes(x = shared.motivation,y = capacity.for.joint.action),
                    pch = 21,alpha = 0.75) 
grid.arrange(g1+theme(legend.position='hidden'), g2+theme(legend.position='hidden'),
             g3+theme(legend.position='hidden'), legend,
             top = "Starting collaborative dynamics, 2-way combinations")




start.finish = dcast(dyn_all[t%in%c(1,50),],iter +total.payout ~ t,value.var = c('principled.engagement','shared.motivation','capacity.for.joint.action'))


g = ggplot(start.finish,aes(col = log(total.payout))) +
  theme_bw() + 
  scale_color_viridis_c(option = 'C',direction = -1)
#+ scale_y_continuous(limits = c(0,1)) +
#  scale_x_continuous(limits = c(0,1))

g1 = g + geom_point(aes(x = principled.engagement_1,y = capacity.for.joint.action_1))+
  geom_segment(aes(x = principled.engagement_1,xend = principled.engagement_50,
                          y = capacity.for.joint.action_1,yend = capacity.for.joint.action_50),
               arrow = arrow(ends = 'last',angle=10,unit(0.1, "inches"),type = 'closed'),lwd = 0.15,alpha = 0.5) +
  scale_x_continuous(name = 'principled engagement',limits = c(0,1)) +
  scale_y_continuous(name = 'capacity for joint action',limits = c(0,1))
legend <- g_legend(g1 + theme(legend.direction = 'horizontal'))

g2 = g + geom_point(aes(x = principled.engagement_1,y = shared.motivation_1))+
  geom_segment(aes(x = principled.engagement_1,xend = principled.engagement_50,
                   y = shared.motivation_1,yend = shared.motivation_50),
               arrow = arrow(ends = 'last',angle=10,unit(0.1, "inches"),type = 'closed'),lwd = 0.15,alpha = 0.5) +
  scale_x_continuous(name = 'principled engagement',limits = c(0,1))+
  scale_y_continuous(name = 'shared motivation',limits = c(0,1))

g3 = g + geom_point(aes(x = shared.motivation_1,y = capacity.for.joint.action_1))+
  geom_segment(aes(x = shared.motivation_1,xend = shared.motivation_50,
                   y = capacity.for.joint.action_1,yend = capacity.for.joint.action_50),
               arrow = arrow(ends = 'last',angle=10,unit(0.1, "inches"),type = 'closed'),lwd = 0.15,alpha = 0.5) +
  scale_x_continuous(name = 'shared motivation',limits = c(0,1)) +  
  scale_y_continuous(name = 'capacity for joint action',limits = c(0,1))

grid.arrange(g1+theme(legend.position='hidden'), g2+theme(legend.position='hidden'),
             g3+theme(legend.position='hidden'), legend,
             top = "Starting and finishing collaborative dynamics, 2-way combinations")




require(plotly)
require(viridis)

fig <- plot_ly(dyn.avg, x = ~principled.engagement, y = ~capacity.for.joint.action, z = ~shared.motivation, size = 0.2,
               color = ~log(total.payout),
               fill = ~log(total.payout),
               colors = viridis_pal(option = "C")(3),
               fills = viridis_pal(option = "C")(3))
fig <- fig %>% add_markers()
fig <- fig %>% layout(scene = list(xaxis = list(title = 'principled engagement'),
                                   yaxis = list(title = 'Capacity for joint action'),
                                   zaxis = list(title = 'Shared motivation')))

fig
fig2 <- plot_ly(dyn_all[iter%in%2,], 
               x = ~principled.engagement, y = ~capacity.for.joint.action, color = ~t,
               z = ~shared.motivation, type = 'scatter3d',mode = 'lines',showlegend = F)
fig2 %>% layout(
  showlegend=T,legend = list(x = 0.5,y =0.1,z = 0.9),margin = list(l = 0,r = 0,t = 0,b = 0))


fig <- plot_ly(data, x = ~age, y = ~Tree1, type = 'scatter', mode = 'lines', name = 'Tree 1')
fig <- fig %>% add_trace(y = ~Tree2, name = 'Tree 2')
fig <- fig %>% add_trace(y = ~Tree3, name = 'Tree 3')


layout(legend = list(x = 0.1, y = 0.1,z = 0.9)
layout(fig2, 
            legend = list(
              legendgroup="", # Sets legend group for trace; 
              #Traces of same legend group hide/show at same time
              font = list(family = "sans-serif", 
                          size = 12, color = "#000"),
              bgcolor = "#E2E2E2", bordercolor = "black",
              borderwidth = 2, x = 0.9, y = 0.9,
              #yanchor = "auto",
              #xanchor = "auto",
              traceorder = "reversed"
              #orientation = "v",
            ))



     fig2 %>% layout(legend = list(x = 0.1, y = 0.9,z = 0.9))
                      
                           
colorscale = viridis_pal(option = "D")(3)))
       fig2
               
               color = ~log(cgr.payout),colors = viridis_pal(option = "C")(3))

fig <- plot_ly(data, x = ~x, y = ~y, z = ~z, type = 'scatter3d', mode = 'lines',
               line = list(width = 4, color = ~c, colorscale = list(c(0,"#440154FF"),(0.5, "#21908CFF"), (1,"#FDE725FF"))))
                           
                           
                           , c(1,'#FCB040'))))

fig


fig2 %>% add_trace()

pdyn_all[iter==1,],aes(x = )



dyn.avg$z = log(dyn.avg$total.payout)
dyn.avg$z2 <- dyn.avg$z + 1
dyn.avg$z3 <- dyn.avg$z + 2

fig <- plot_ly(dyn.avg, x = ~principled.engagement, y = ~capacity.for.joint.action, z = ~shared.motivation, 
               
fig <- plot_ly(showscale = FALSE)
fig <- fig %>% add_surface(z = ~z)
fig <- fig %>% add_surface(z = ~z2, opacity = 0.98)
fig <- fig %>% add_surface(z = ~z3, opacity = 0.98)

fig




install.packages('plotly')

library(gridExtra)




require(gridExtra)
grid.arrange(g1,g2,g3,ncol = 2)



+ 
  ggtitle('Collaborative dynamics two-way scatterplots')


?ggpairs

ggplot(dyn_melt[,mean(principled.engagement),by=.(iter,total.payout)]) + 
  geom_point(pch = 21, aes(x = V1,y = total.payout))

ggplot(dyn_all[,mean(shared.motivation),by=.(iter,total.payout)]) + 
  geom_point(pch = 21, aes(x = V1,y = total.payout))

ggplot(dyn_all[,mean(capacity.for.joint.action),by=.(iter,total.payout)]) + 
  geom_point(pch = 21, aes(x = V1,y = total.payout))


dyn_all[,mean(principled.engagement)]

ggplot(dyn_all[t==1,],aes(x = principled.engagement,y = total.payout)) + 
  geom_point(pch = 21,alpha = 0.5)

ggplot(dyn_all,aes(x = shared.motivation,y = cgr.payout)) + 
  geom_point(pch = 21,alpha = 0.5)


ggplot(dyn_all[t==1,],aes(x = capacity.for.joint.action,y = total.payout)) + 
  geom_point(pch = 21,alpha = 0.5)


dyn_all
base[[1]]$cgr.payout.t

dyn_all[]




