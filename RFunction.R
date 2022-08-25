library('move')
library('mapdata')
library('mgcv')

rFunction <- function(data,minspeed=4,maxspeed=25)
{

  Sys.setenv(tz="UTC")
  
  #this is copied code from Kami (Safi et al. 2013 MoveEcol)

  wind_support <- function(u,v,heading) {
    angle <- atan2(u,v) - heading/180*pi
    return(cos(angle) * sqrt(u*u+v*v))
  }
  
  cross_wind <- function(u,v,heading) {
    angle <- atan2(u,v) - heading/180*pi
    return(sin(angle) * sqrt(u*u+v*v))
  }
  
  airspeed <- function(x)
  {
    va <- sqrt((x$ground.speed - x$ws)^2 + (x$cw)^2)
    return(va)
  }
  
  make.plot <- function(f, x.df, modgs, modas)
  {
    # Get the predicted values depending on one single variable while keeping the other wind component at 0 and the longitude and latitude at the mean of the entire data set
    # For ground speed
    pcw.gs <- predict(modgs$gam, newdata=data.frame(ws=rep(0,100), cw=seq(min(x.df$cw, na.rm=T), max(x.df$cw, na.rm=T), length.out=100), location.long=rep(mean(x.df$location.long, na.rm=T), 100), location.lat=mean(x.df$location.lat, na.rm=T)))
    pws.gs <- predict(modgs$gam, newdata=data.frame(ws=seq(min(x.df$ws, na.rm=T), max(x.df$ws, na.rm=T), length.out=100), cw=rep(0,100), location.long=rep(mean(x.df$location.long, na.rm=T), 100), location.lat=mean(x.df$location.lat, na.rm=T)))
    # For airspeed
    pcw.as <- predict(modas$gam, newdata=data.frame(ws=rep(0,100), cw=seq(min(x.df$cw, na.rm=T), max(x.df$cw, na.rm=T), length.out=100), location.long=rep(mean(x.df$location.long, na.rm=T), 100), location.lat=mean(x.df$location.lat, na.rm=T)))
    pws.as <- predict(modas$gam, newdata=data.frame(ws=seq(min(x.df$ws, na.rm=T), max(x.df$ws, na.rm=T), length.out=100), cw=rep(0,100), location.long=rep(mean(x.df$location.long, na.rm=T), 100), location.lat=mean(x.df$location.lat, na.rm=T)))
    
    # Open a pdf file and plot all into it
    pdf(paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"Wind_support_plots.pdf"))
    # First page split in 4 areas
    layout(matrix(c(1,1,1,1,5,2,3,6,5,4,4,6), ncol=4, byrow=T), height=c(0.1,0.45,0.45), width=c(0.1,0.4,0.4,0.1))
    par(mar=c(0,0,0,0))
    # Write title
    plot.new()
    plot.window(xlim=c(-1,1), ylim=c(-0.1,0.1))
    text(0,-0.1,paste("Wind Support Report"), pos=3, font=2, cex=1.5)
    # Make a histogram of the airspeed raw values
    par(mar=c(4,4,2,4))
    hist((data.frame(x.df)[,"airspeed"]), xlab="Airspeed", main=NA)
    # Make a histogram of ground speed raw values
    hist((data.frame(x.df)[,"ground.speed"]), xlab="Ground speed", main=NA)
    # Write the means of these measures in the bottom section
    plot(0,0, type="n", xlim=c(-10,10), ylim=c(-10,10), xaxt="n", yaxt="n", ylab=NA, xlab=NA, bty="n")
    text(0,0,paste("Mean airspeed: ", round(mean(x.df$airspeed, na.rm=T), 4), " m/s.\n",
                   "Mean ground speed: ", round(mean(x.df$ground.speed, na.rm=T), 4), " m/s.", sep=""), cex=1.5)
    # Next page split in 4 regions
    layout(matrix(c(1,2,3,4), ncol=2, byrow=T))
    par(mar=c(5, 4, 4, 2) + 0.1)
    # plot airspeed (square root) transformed and add the predicted model estimates as a function of wind support as a line
    plot(sqrt(airspeed)~ws, data=x.df, pch=16, col="grey95", xlab="Wind support", ylab=expression(paste(sqrt("Airspeed"), sep="")))
    points(sqrt(airspeed)~ws, data=x.df, col="grey60")
    lines(seq(min(x.df$ws, na.rm=T), max(x.df$ws, na.rm=T), length.out=100), pws.as, col="red")
    mtext(substitute(paste(sqrt("Airspeed="), i%*%"ws", " + ", j, sep=""), list(i=round(summary(modas$gam)$p.coeff["ws"], 4), j=round(summary(modas$gam)$p.coeff["(Intercept)"], 4))), side=4, cex=0.5, , col="red", line=0)
    # plot airspeed (square root) transformed and add the predicted model estimates as a function of cross wind as a line
    plot(sqrt(airspeed)~cw, data=x.df, pch=16, col="grey95", xlab="Cross wind", ylab=expression(paste(sqrt("Airspeed"), sep="")))
    points(sqrt(airspeed)~cw, data=x.df, col="grey60")
    lines(seq(min(x.df$ws, na.rm=T), max(x.df$ws, na.rm=T), length.out=100), pws.as, col="red")
    mtext(substitute(paste(sqrt("Airspeed="), i%*%"ws", " + ", j, sep=""), list(i=round(summary(modas$gam)$p.coeff["ws"], 4), j=round(summary(modas$gam)$p.coeff["(Intercept)"], 4))), side=4, cex=0.5, , col="red", line=0)
    # plot ground speed (square root) transformed and add the predicted model estimates as a function of wind support as a line
    plot(sqrt(ground.speed)~ws, data=x.df, pch=16, col="grey95", xlab="Wind support", ylab=expression(paste(sqrt("Ground speed"), sep="")))
    points(sqrt(ground.speed)~ws, data=x.df, col="grey60")
    lines(seq(min(x.df$ws, na.rm=T), max(x.df$ws, na.rm=T), length.out=100), pws.gs, col="red")
    mtext(substitute(paste(sqrt("Ground speed="), i%*%"ws", " + ", j, sep=""), list(i=round(summary(modgs$gam)$p.coeff["ws"], 4), j=round(summary(modgs$gam)$p.coeff["(Intercept)"], 4))), side=4, cex=0.5, , col="red", line=0)
    # plot ground speed (square root) transformed and add the predicted model estimates as a function of cross wind as a line
    plot(sqrt(ground.speed)~cw, data=x.df, pch=16, col="grey95", xlab="Cross wind", ylab=expression(paste(sqrt("Ground speed"), sep="")))
    points(sqrt(ground.speed)~cw, data=x.df, col="grey60")
    lines(seq(min(x.df$cw, na.rm=T), max(x.df$cw, na.rm=T), length.out=100), pcw.gs, col="red")
    mtext(substitute(paste(sqrt("Ground speed="), i%*%"cw", " + ", j, sep=""), list(i=round(summary(modgs$gam)$p.coeff["cw"], 4), j=round(summary(modgs$gam)$p.coeff["(Intercept)"], 4))), side=4, cex=0.5, col="red", line=0)
    # next pages
    layout(c(1))
    par(mar=c(5, 4, 4, 2))
    # capture stats output and write it into a plot region
    out <- capture.output(summary(modas$gam))
    plot(0,0, type="n", xlim=c(-10,10), ylim=c(-10,10), xaxt="n", yaxt="n", ylab=NA, xlab=NA, bty="n")
    title("GAMM summary for airspeed")
    text(0,0,"Unsupervised !", cex=5, col="grey70", srt=45)
    text(-10,0,paste(out, collapse="\n"), pos=4, cex=0.5, family="mono")
    # capture stats output and write it into a plot region
    out <- capture.output(summary(modas$lme))
    grep("Fixed effects:", out)
    plot(0,0, type="n", xlim=c(-10,10), ylim=c(-10,10), xaxt="n", yaxt="n", ylab=NA, xlab=NA, bty="n")
    title("LME summary 1 of 2 for airspeed")
    text(0,0,"Unsupervised !", cex=5, col="grey70", srt=45)
    text(-10,0, paste(out[1:19], collapse="\n"), pos=4, cex=0.5, family="mono")
    # capture stats output and write it into a plot region
    plot(0,0, type="n", xlim=c(-10,10), ylim=c(-10,10), xaxt="n", yaxt="n", ylab=NA, xlab=NA, bty="n")
    title("LME summary 2 of 2 for airspeed")
    text(0,0,"Unsupervised !", cex=5, col="grey70", srt=45)
    text(-10,0, paste(out[20:length(out)], collapse="\n"), pos=4, cex=0.5, family="mono")
    dev.off()
    # report successful production
    logger.info("Output report was saved.")
  }
  

# now apply functions
  
if(sum(length(grep("U.Component", names(data))), length(grep("V.Component", names(data))))!=2)
  {
    logger.info("No U and V components found! Input data will be returned.")
  } else
  {
    if(sum(as.numeric(names(data) %in% c("ground.speed", "heading")))!=2)
    {
      logger.info("No heading and ground speed were provided and were calculated from next locations!")
      data$heading <- unlist(lapply(lapply(split(data), angle), "c", NA))
      data$ground.speed <- unlist(lapply(lapply(split(data), speed), "c", NA))
    } else logger.info("Analysis will be based on heading and ground speed provided.")
    
    uix <- grep("U.Component", names(data))
    vix <- grep("V.Component", names(data))
    
    data@data$ws <- wind_support(data@data[,uix],data@data[,vix],data@data$heading)
    data@data$cw <- cross_wind(data@data[,uix],data@data[,vix],data@data$heading)
    data@data$airspeed <- airspeed(data)
    
    data.df <- as.data.frame(data)
    logger.info(paste("The ground speed range will be limited to between ", minspeed, " and ", maxspeed, " m/s.", sep=""))
    data.df <- data.df[data.df$ground.speed>minspeed & data.df$ground.speed<maxspeed,]
    modgs <- gamm(sqrt(ground.speed)~s(location.long, location.lat)+cw*ws, 
                  random=list(individual.local.identifier=~1), 
                  data=data.df)
    modas <- gamm(sqrt(airspeed)~s(location.long, location.lat)+cw*ws, 
                  random=list(individual.local.identifier=~1), 
                  data=data.df)
    
    make.plot(data, data.df, modgs, modas)
  }
  
  names(data)[which(names(data)=="ws")] <- "wind.support"
  names(data)[which(names(data)=="cw")] <- "cross.wind"

  return(data)
}

  
  
  
  
  
  
  
  
  
  
