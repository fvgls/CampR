#'Compara la distribución geográfica de una especie entre campañas
#'
#'Compara la distribución geográfica de la especie gr,esp entre las campañas camps y la newcamp
#'@param gr Grupo de la especie: 1 peces, 2 crustáceos 3 moluscos 4 equinodermos 5 invertebrados
#'@param esp Código de la especie numérico o carácter con tres espacios. 999 para todas las especies del grupo
#'@param camps Campaña (o grupo de campañas) a representar en el mapa de un año (o grupo de años) concreto (s) (XX) con los que se quiere comparar la última campaña (newcamp): Demersales "NXX", Porcupine "PXX", Arsa primavera "1XX" y Arsa otoño "2XX"
#'@param newcamp última campaña (que se compara con las anteriores) Demersales "NXX", Porcupine "PXX", Arsa primavera "1XX" y Arsa otoño "2XX"
#'@param dns Elige el origen de las bases de datos: Porcupine "Pnew", Cantábrico "Cant", Golfo de Cadiz "Arsa" (proporciona los datos para Medits pero no saca mapas)
#'@param cor.time si T corrige la captura del lance a media hora
#'@param bw Gráfico en blanco en negro si T o en color si F.
#'@param ti Si T añade título al gráfico, el nombre de la especie en latín.
#'@param plot saca el gráfico (T) o lo guardar como objeto para componer con otros gráficos (F)
#'@param ind saca los datos en "p"eso o "n"úmero.
#'@param idi Nombre científico de la especie ("l") o nombre común ("e").
#'@param cexleg Varia el tamaño de letra de los ejes y del número de la leyenda.
#'@examples map.check(1,17,Nsh[1:27],"N11","Cant",ind="n")
#'@export
map.check<-function(gr,esp,camps,newcamp,dns="Pnew",cor.time=T,ind="p",bw=T,ti=T,plot=T,idi="l",pts=T,cexleg=1) {
  require(lattice)
  require(grid)
  require(maps)
  trellis.par.set(col.whitebg())
  #trellis.par.set("strip.background",list(col=c("white")))
  trellis.par.set("strip.text"=list(cex=cexleg*.9,font=2))
  ndat<-length(camps)
  dumb<-NULL
  for (i in 1:ndat) {
    if (!is.null(datgr.camp(gr,esp,camps[i],dns,cor.time=cor.time))) dumb<-rbind(dumb,cbind(datgr.camp(gr,esp,camps[i],dns,cor.time=cor.time),camp="Olds",oldcamp=camps[i]))
  }
  dumb<-rbind(dumb,cbind(datgr.camp(gr,esp,camps[i],dns,cor.time=cor.time),camp=newcamp,oldcamp=newcamp))
  dumb<-dumb[dumb$numero>0,]
  dumb$camp<-factor(as.character(dumb$camp))
  if (ind=="p") {
    dumb$peso<-dumb$peso.gr/1000
    leyenda<-signif(max(dumb$peso)*.9,1)
    escala<-signif(max(dumb$peso),1)*35/150 }
  else {
    leyenda<-signif(max(dumb$numero)*.9,1)
    escala<-signif(max(dumb$numero),1)*35/150 }
  if (ti) titulo<-list(label=buscaesp(gr,esp,id=idi),font=ifelse((idi=="l" & gr!="9" & esp!="999"),4,2))
  else titulo<-NULL
  if (bw) {colo=gray(.1)
           trellis.par.set("strip.background",list(col=c(gray(.80))))
  }
  else colo=4
  # print(dumb[dumb[,5]>0,])
  if (pts) dumb[dumb[,5]>0,8]<-0
  if (substr(dns,1,4)=="Pnew" | substr(dns,1,4)=="Porc") {
    layout=c(2,1)
    asp<-diff(c(50.5,54.5))/(diff(c(-15.5,-10.5))*cos(mean(c(50.5,54.5))*pi/180))
    mapdist<-xyplot(lat~long|camp,dumb,layout=layout,xlim=c(-15.5,-10.5),main=titulo,xlab=NULL,ylab=NULL,
                ylim=c(50.5,54.5),aspect=asp,par.strip.text=list(cex=cexleg*.8,font=2),scales=list(alternating=F,
                tck=c(1,0),cex=cexleg*.7,x=list(at=c(-15:-11),labels=as.character(abs(-15:11))),y=list(at=(51:54),rot=90)),
                as.table=T,panel=function(x,y,subscripts=subscripts) {
                  panel.xyplot(Porc.map$x,Porc.map$y,type="l",lty=3,col=gray(.2))
                  grid.polygon(map(Porc.map,"narr",plot=F)[[1]],map(Porc.map,"narr",plot=F)[[2]],
                    default.units = "native",gp=gpar(fill=gray(.8)))
                  panel.xyplot(x[dumb$numero[subscripts]>0],y[dumb$numero[subscripts]>0],cex=cexleg*.6,
                    pch=16,col=colo)
                  })
  }
  if (substr(dns,1,4)=="Cant") {
    layout=c(1,2)
    asp<-diff(c(41.82,44.3))/(diff(c(-10.25,-1.4))*cos(mean(c(41.82,44.3))*pi/180))
    leyenda<-signif(c(1,.5,.25)*leyenda,1)
    mapdist<-xyplot(lat~long|camp,dumb,layout=layout,xlim=c(-10.25,-1.4),main=titulo,xlab=NULL,ylab=NULL,subscripts=T,
                    ylim=c(41.82,44.3),aspect=asp,par.strip.text=list(cex=cexleg*.8,font=2),scales=list(alternating=F,tck=c(1,0),cex=cexleg*.7,
                                                                                                        x=list(at=c(-10:-2),labels=as.character(abs(-10:-2))),y=list(at=seq(42,44,by=1),rot=90)),as.table=T,
                    panel=function(x,y,subscripts=subscripts) {
                      panel.xyplot(Nort.str$x,Nort.str$y,type="l",lty=3,col=gray(.4))
                      grid.polygon(map(Nort.map,"Costa",plot=F)[[1]],map(Nort.map,"Costa",plot=F)[[2]],
                                   default.units = "native",gp=gpar(fill=gray(.8)))
                      panel.xyplot(x[dumb$numero[subscripts]>0],y[dumb$numero[subscripts]>0],cex=cexleg*.6,
                                   pch=16,col=colo)
                    })
  }
  if (substr(dns,1,4)=="Arsa") {
    layout=c(1,2)
    asp<-diff(c(35.95,37.30))/(diff(c(-8.1,-5.5))*cos(mean(c(35.95,37.30))*pi/180))
    leyenda<-signif(c(1,.5,.25)*leyenda,1)
    mapdist<-xyplot(lat~long|camp,dumb,layout=layout,xlim=c(-8.1,-5.5),main=titulo,xlab=NULL,ylab=NULL,subscripts=T,
                    ylim=c(35.95,37.30),aspect=asp,par.strip.text=list(cex=cexleg*.8,font=2),par.strip.background=list(col=c(gray(.8))),
                    scales=list(alternating=F,tck=c(1,0),cex=cexleg*.7,x=list(at=c(-10:-5),labels=as.character(abs(-10:-5))),y=list(at=seq(35,36,by=1),rot=90)),
                    as.table=T,panel=function(x,y,subscripts=subscripts) {
                      panel.xyplot(Arsa.str$x,Arsa.str$y,type="l",lty=3,col=gray(.4))
                      grid.polygon(map(Arsa.map,c("Portugal","Costa"),plot=F)[[1]],map(Arsa.map,c("Portugal","Costa"),plot=F)[[2]],default.units = "native",gp=gpar(fill=gray(.8)))
                      panel.xyplot(x[dumb$numero[subscripts]>0],y[dumb$numero[subscripts]>0],cex=cexleg*.6,
                                   pch=16,col=colo)
                    })
  }
  if (plot) {print(mapdist)
             print(dumb[dumb[,5]>0,])}
  else {print(dumb)}
}

