#tryer
setwd("C:\\Users\\Piyo\\Documents\\R\\markdown knitr\\RepData_PeerAssessment1\\")

library(dplyr)
library(tidyr)
library(lubridate)
library(gridExtra)
library(ggplot2)

#Loads and processes to format for analysis
activity.dat<-read.csv(unz("activity.zip","activity.csv"))
activity.dat<-mutate(activity.dat,date=parse_date_time(date,"%Y%m%d"))

#total mean number of steps/day

#activity.grouped<-group_by(mutate(activity.dat,Date2=parse_date_time(date,"%Y%m%d")),Date2)
activity.grouped<-group_by(activity.dat,date)
activity.summary<-summarize(activity.grouped,total_steps=sum(steps),mean_steps=mean(steps),median_steps=median(steps))
#filter(activity.grouped,Date2=ymd("xx-xx-xx"))
#qplot(activity.summary$mean_steps,geom="histogram",main="Histogram: mean nos. steps",xlab="steps",log="y",ylab="log10(count)")

qplot(activity.summary$total_steps,geom="histogram",main="Histogram: Total steps/day",
      xlab="steps",ylab="count")

barplot(activity.summary$total_steps,main="mean steps per day",
      xlab="steps",ylab="count")
barplot(activity.summary$median_steps,main="median steps per day",
        xlab="steps",ylab="count")

#average daily pattern
activity.grp2<-activity.dat
#activity.grp2<-factor(activity.grp2$interval)
activity.grp2<-group_by(activity.dat,interval)
#activity.grp2<-group_by(activity.dat,factor(activity.dat$interval))
grp2.summary<-summarize(activity.grp2,mean.steps=mean(steps,na.rm=TRUE),sum.steps=sum(steps,na.rm=TRUE))
plot(grp2.summary$interval,grp2.summary$mean.steps,type="l",xlab="interval",ylab="mean nos. steps")
max_step.int<-grp2.summary$interval[which.max(grp2.summary$mean.steps)]

#imputing mssing values
nos_NA.days<-sum(is.na(activity.dat$steps))

NA.removed<-spread(activity.dat,interval,steps)
temp<-NA.removed[2:289]
dat.colMeans<-colMeans(temp,na.rm=TRUE)
index<-which(is.na(temp),arr.ind=TRUE)
temp[index]<-dat.colMeans[index[,2]]
NA.removed[2:289]<-temp

NA.removed<-arrange(gather(NA.removed,"interval","steps",2:289),date)
NA.removed<-group_by(NA.removed,date)
NA.removed_summary<-summarize(NA.removed,total_steps=sum(steps),mean_steps=mean(steps),median_steps=median(steps))
qplot(NA.removed_summary$total_steps,geom="histogram",main="Histogram: total nos. steps",
      xlab="steps",ylab="count")
#only the dates with NA will change to the mean steps per interval (averaged over all days)
#def<-left_join(activity.summary,NA.removed_summary,by="date")

weekdayerizer<-mutate(NA.removed,day=wday(date),wkd=as.factor(ifelse(day%in%c(1,7),"weekend","weekday")))
weekdayerizer<-mutate(NA.removed,day=wday(date),wkd=(ifelse(day%in%c(1,7),"weekend","weekday")))
weekdayerizer$wkd<-as.factor(weekdayerizer$wkd)
weekdayerizer$interval<-as.numeric(weekdayerizer$interval)
weekdayerizer.summ<-group_by(weekdayerizer,wkd,interval)
weekday.summary<-summarize(weekdayerizer.summ,mean_steps=mean(steps))
ggplot(weekday.summary,aes(x=interval,y=mean_steps))+geom_line()+facet_grid(wkd~.)

