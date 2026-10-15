# HISTORICAL RESEARCH SOURCE — ARCHIVE ONLY
# Original scientific logic below is preserved exactly as provided.
# CAUTION: The script assumes local DSSAT executables and external data.
# It may overwrite installed genotype, soil, or experiment files.
# To execute deliberately, use an isolated copy of the environment and
# remove the following stop() only after reviewing all paths and inputs.
stop("ARCHIVED SCRIPT: not safe to run as-is; read legacy/README.md")

library(sensitivity)
library(lhs)
library(`ade4`)
library(Dasst)
library(plotrix)
library(operators)

setwd("D:/ISmalia_DSSAT/co-inertia_analysis/Co_inertia_3_18")
wd = "D:/ISmalia_DSSAT"
par <- read.csv(paste(wd,"/Corn_calibration.csv",sep=""))
X <- par$Calib_SC10_3_13
#-------------------------
A <- improvedLHS(1500,26,dup = 5)
B <- matrix(nrow = nrow(A), ncol = ncol(A))

B[,1] <- qunif(A[,1], min = 167, max = 311)   #+- 30% cal
B[,2] <- qunif(A[,2], min = 620, max = 1100)  #+- 30% cal
B[,3] <- qunif(A[,3], min = 590, max = 1100)  #+- 30% cal
B[,4] <- qunif(A[,4], min = 4.5, max = 10.5)  #+- 40% cal
B[,5] <- qunif(A[,5], min = 35, max = 65)     #+- 30% cal

B[,6] <- qunif(A[,6], min = 4.2, max = 7.8)       #+- 30% default
B[,7] <- qunif(A[,7], min = 120, max = 220)       #+- 30% default
B[,8] <- qunif(A[,8], min = 3.3, max = 5)         #+- 20% default
B[,9] <- qunif(A[,9], min = 0.68, max = 1.02)     #+- 20% default

B[,10] <- qunif(A[,10], min = 3, max = 12)
B[,11] <- qunif(A[,11], min = 0.4, max = 0.95)
B[,12] <- qunif(A[,12], min = 0.7, max = 1)

B[,13] <- qunif(A[,13], min = 0.01, max = 0.05)   #DSSAT default for deep sand 0.025
B[,14] <- qunif(A[,14], min = 0.06, max = 0.22)   #DSSAT default for deep sand 0.096
B[,15] <- qunif(A[,15], min = 0.3, max = 0.6)    #DSSAT default for deep sand 0.345
B[,16] <- qunif(A[,16], min = 1.2, max = 1.8)     #DSSAT default for deep sand 1.66

B[,17] <- qunif(A[,17], min = 0.01, max = 0.05)
B[,18] <- qunif(A[,18], min = 0.06, max = 0.22)
B[,19] <- qunif(A[,19], min = 0.3, max = 0.6)
B[,20] <- qunif(A[,20], min = 1.2, max = 1.8)

B[,21] <- qunif(A[,21], min = 0.2, max = 0.6)    #DSSAT default for deep sand 0.28
B[,22] <- qunif(A[,22], min = 0.3, max = 0.8)
B[,23] <- qunif(A[,23], min = 0.15, max = 0.5)   #DSSAT default for deep sand 0.24
B[,24] <- qunif(A[,24], min = 0.3, max = 0.8)
B[,25] <- qunif(A[,25], min = 0.07, max = 0.3)   #DSSAT default for deep sand 0.18
B[,26] <- qunif(A[,26], min = 0.3, max = 0.8)


Inputparam <- data.frame("P1"=B[,1],"P5"=B[,2],"G2"=B[,3],"G3"=B[,4],"PHINT"=B[,5],
                         "GDDE"=B[,6],"DSGFT"=B[,7],"RUE"=B[,8],"KCAN"=B[,9],
                         "SLU1"=B[,10],"SLDR"=B[,11],"SLPF"=B[,12],
                         "SLLL.30"=B[,13],"SDUL.30"=B[,14],"SSAT.30"=B[,15],"SBDM.30"=B[,16],
                         "SLLL.60"=B[,17],"SDUL.60"=B[,18],"SSAT.60"=B[,19],"SBDM.60"=B[,20],
                         "SAOC.30"=B[,21],"SASC.30"=B[,22],"SAOC.60"=B[,23],"SASC.60"=B[,24],
                         "SAOC.90"=B[,25],"SASC.90"=B[,26])

#---------Global sensitivity based on Co-inertia analysis-----------------

for(i in 1:nrow(B)){
  
  out_string <- paste0("!MAIZE CULTIVAR COEFFICIENTS: MZCER047 MODEL\n",
                       "!AHMED ATTIA (MAR-2019)\n",
                       "@VAR#  VRNAME.......... EXPNO   ECO#    P1    P2    P5    G2    G3  PHINT")
  
  CalibP <- c(formatC(B[i,1],format="g",digits=3,width=5),formatC(X[2],format="f",digits=1,width=5),
              formatC(B[i,2],format="g",digits=4,width=5),
              formatC(B[i,3],format="g",digits=4,width=5),formatC(B[i,4],format="f",digits=1,width=5),
              formatC(B[i,5],format="g",digits=2,width=4))

  cat(out_string,
      "990001 LONG SEASON          . IB0001",CalibP,file="C:/DSSAT47/Genotype/MZCER047.CUL",fill=T,append = F)
  
  
  out_string2 <- paste0("*MAIZE ECOTYPE COEFFICIENTS: MZCER047 MODEL\n",
                        "@ECO#  ECONAME.........  TBASE  TOPT ROPT   P20  DJTI  GDDE  DSGFT  RUE   KCAN  TSEN  CDAY")

  CalibP2 <- c(formatC(X[7],format="f",digits=1,width=2),formatC(X[8],format="f",digits=1,width=5),
               formatC(X[9],format="f",digits=1,width=4),
               formatC(X[10],format="f",digits=1,width=5),formatC(X[11],format="f",digits=1,width=5),
               formatC(B[i,6],format="f",digits=1,width=5),formatC(B[i,7],format="f",digits=1,width=6),
               formatC(B[i,8],format="f",digits=1,width=4),
               formatC(B[i,9],format="f",digits=2,width=6))

  cat(out_string2,
      "IB0001 GENERIC MIDWEST1   ",CalibP2,file="C:/DSSAT47/Genotype/MZCER047.ECO",fill=T,append = F)

  
  sbuild <- readLines("C:/DSSAT47/Soil/ZU.SOL")
  sbuild[70] = paste("     Y   .17 ",formatC(B[i,10],format="f",digits=1,width = 4),"",formatC(B[i,11],format="f",digits=2),"   83    1  ",formatC(B[i,12],format="f",digits=2),"  -99   -99   -99")
  sbuild[72] = paste("     5    AP",formatC(B[i,13],format="f",digits=3),formatC(B[i,14],format="f",digits=3),formatC(B[i,15],format="f",digits=3),"    1   4.3 ",formatC(B[i,16],format="f",digits=2),"",formatC(0.22,format="f",digits=2),"  6.8   3.1     0   -99   8.5   -99  25.5   -99")
  sbuild[73] = paste("    15    AP",formatC(B[i,13],format="f",digits=3),formatC(B[i,14],format="f",digits=3),formatC(B[i,15],format="f",digits=3),"    1   4.3 ",formatC(B[i,16],format="f",digits=2),"",formatC(0.22,format="f",digits=2),"  6.2     3     0   -99   8.5   -99  25.5   -99")
  sbuild[74] = paste("    30    AP",formatC(B[i,13],format="f",digits=3),formatC(B[i,14],format="f",digits=3),formatC(B[i,15],format="f",digits=3)," .638   4.3 ",formatC(B[i,16],format="f",digits=2),"",formatC(0.22,format="f",digits=2),"  6.1   2.8     0   -99   8.5   -99  25.5   -99")
  sbuild[75] = paste("    50    C1",formatC(B[i,17],format="f",digits=3),formatC(B[i,18],format="f",digits=3),formatC(B[i,19],format="f",digits=3)," .449   4.3 ",formatC(B[i,20],format="f",digits=2),"",formatC(0.45,format="f",digits=2),"    4   1.7     0   -99   8.6   -99  24.5   -99")
  sbuild[76] = paste("    60    C1",formatC(B[i,17],format="f",digits=3),formatC(B[i,18],format="f",digits=3),formatC(B[i,19],format="f",digits=3)," .301   4.3 ",formatC(B[i,20],format="f",digits=2),"",formatC(0.45,format="f",digits=2),"    3   1.5     0   -99   8.6   -99  23.5   -99")

  write(sbuild,file="C:/DSSAT47/Soil/ZU.SOL")
  
  xbuild <- readLines("C:/DSSAT47/Maize/SENS1111.MZX")
  xbuild[49] = paste(" 1    30   -99 ",formatC(B[i,21],format="f",digits=2),"  -99   -99   -99   -99   -99 ",formatC(B[i,22],format="f",digits=2,width=2))
  xbuild[50] = paste(" 1    60   -99 ",formatC(B[i,23],format="f",digits=2),"  -99   -99   -99   -99   -99 ",formatC(B[i,24],format="f",digits=2,width=2))
  xbuild[51] = paste(" 1    90   -99 ",formatC(B[i,25],format="f",digits=2),"  -99   -99   -99   -99   -99 ",formatC(B[i,26],format="f",digits=2,width=2))
  
  write(xbuild,file="C:/DSSAT47/Maize/SENS1111.MZX")
  
  #----write batch file---------
  TREF1111.MZX = "SENS1111.MZX"
  Trt=1
  
  out_stringb <- paste0("$BATCH(MAIZE)\n",
                        "!\n",
                        "! Directory    : C:\\DSSAT47\\Maize\n",
                        "! Command Line : C:\\DSSAT47\\DSCSM047.EXE MZCER047 B DSSBatch.v47\n",
                        "! Crop         : Maize\n",
                        "! Experiment   : SENS1111.MZX\n",
                        "! ExpNo        : 1\n",
                        "! Debug        : C:\\DSSAT47\\DSCSM047.EXE MZCER047 ' B DSSBatch.v47\n",
                        "!\n",
                        "@FILEX                                                                                        TRTNO     RP     SQ     OP     CO")
  
  for(j in 1:length(Trt)){
    Trtp <- paste0("C:\\DSSAT47\\Maize\\SENS1111.MZX                                                                    ",Trt[j],"      1      0      0      0\n")
    if(j==1){
      TrtR=Trtp
    }else{
      TrtR=rbind(TrtR,Trtp)
    }
  }
  
  TrtR2 = gsub("TREF1111.MZX",TREF1111.MZX,TrtR)
  cat(out_stringb,
      file="C:/DSSAT47/Maize/DSSBatch.v47",fill=T,append = F)
  cat(TrtR2,
      file="C:/DSSAT47/Maize/DSSBatch.v47",fill=T,append = T)
  
  setwd(paste("C:/DSSAT47/Maize",sep = ""))
  
  #--- write paramters used on the screen
  message("")
  message("Running DSSAT-MaizeCERES...")
  
  #--- Call DSSAT047.exe and run X files list within DSSBatch.v47
  system("C:/DSSAT47/DSCSM047.EXE MZCER047 B DSSBatch.v47",show.output.on.console = T)
  
  plantgro <- read.dssat("C:/DSSAT47/Maize/PlantGro.OUT")
  Summaryout <- read.dssat("C:/DSSAT47/Maize/Summary.OUT")
  ETout <- read.dssat("C:/DSSAT47/Maize/ET.OUT")
  SWout <- read.dssat("C:/DSSAT47/Maize/SoilWat.OUT")
  SoilN_maize <- read.dssat("C:/DSSAT47/Maize/SoilNi.OUT")
  SoilC_Maize <- read.dssat("C:/DSSAT47/Maize/SOMLITC.OUT")
  SoilON_Maize <- read.dssat("C:/DSSAT47/Maize/SOMLITN.OUT")
  
  Biom <- 0
  GY <- 0 
  Straw <- 0
  MLAI <- 0
  PlantDate <- 0
  Emer <- 0
  Anth <- 0
  Mat <- 0
  Transp <- 0
  sEvap <- 0
  sWater <- 0
  Nup <- 0
  Drin <- 0
  Nleach <- 0
  sN <- 0
  TsC <- 0
  
  datagro=as.data.frame(plantgro[[1]])
  datasumm=as.data.frame(Summaryout[[1]])
  dataET=as.data.frame(ETout[[1]])
  dataSW=as.data.frame(SWout[[1]])
  dataN=as.data.frame(SoilN_maize[[1]])
  dataC=as.data.frame(SoilC_Maize[[1]])
  dataON=as.data.frame(SoilON_Maize[[1]])
  GY <- tail(datagro$GWAD,n=1)                  #GY
  Biom <- tail(datagro$CWAD,n=1)                #Biom
  Straw <- Biom-GY                              #Straw
  Nleach <- tail(dataN$NLCC,n=1)                #N leaching
  sN <- tail(dataN$NIAD,n=1)                    #Total soil N
  TsC <- datasumm$OCTAM                         #Total soil C
  MLAI <- max(datagro$LAID)                     #Max LAL
  PlantDate <- datasumm$PDAT
  Emer <- datasumm$EDAT-PlantDate               #Emerg DAP
  Anth <- datasumm$ADAT-PlantDate               #Anth DAP
  Mat <- datasumm$MDAT-PlantDate                #Mat DAP
  Transp <- tail(dataET$EPAC,n=1)               #Transpiration
  sEvap <- tail(dataET$ESAC,n=1)                #Soil evaporation
  sWater <- tail(dataSW$SWTD,n=1)               #Soil water
  Nup <- datasumm$NUCM                          #N uptake
  Drin <- datasumm$DRCM                         #Drainage rate
  
  Simdaday=cbind.data.frame(Emer,Anth,Mat,GY,Straw,Nleach,sN,MLAI,TsC,Transp,sEvap,sWater,Nup,Drin)
  
  if(i==1){
    SIMSEN=Simdaday
  }else{
    SIMSEN=rbind.data.frame(SIMSEN,Simdaday)
  }
  
  if(GY < 25){
    print(paste("coming out from for loop where Crop failure growth program terminated"))
          break
   }
}

#--------------Co-inertia analysis-----------------------
par(mfrow=c(1,1),mar=c(4,4,3,2)+0.1,mgp=c(2.5,0.7,0))

dinput <- dudi.pca(Inputparam, scale = T, scannf = F, nf = 3)
dout <- dudi.pca(SIMSEN, scale = T, scannf = F, nf = 3)
coinD <- coinertia(dinput,dout, scannf = T,nf=3)
#---------------------plot-------------------------------------
plot(coinD)
summary(coinD)
g1 <- ade4::s.arrow(coinD$l1,xax=1,yax=2, boxes = FALSE,clabel=0.8,grid=T)
g2_1 <- ade4::s.arrow(coinD$c1,boxes = F,xax=1,yax=2,clabel=0.8)

ResC1 <-  coinD$c1[row.names(coinD$c1),]
ade4::s.arrow(ResC1,boxes = F,xax=1,yax=2,label=c("P1","P5","G2"," ","PHINT",
                                                        " "," ","RUE","KCAN"," ","SLDR"," ",
                                                        " ","SDUL.30","SSAT.30","SBDM.30",
                                                        "SLLL.60","SDUL.60","SSAT.60"," ","SAOC.30",
                                                        "SASC.30","SAOC.60","SASC.60"),
                                                         clabel=0.8,grid=T) 

draw.circle(0,0,0.11,col=adjustcolor("gray", alpha.f = 0.40))

# row.names(coinD$c1)[9]  <- "SDUL.30"
# row.names(coinD$c1)[14]  <-"NA"
# row.names(coinD$c1)[14]  <-"KCAN"


Zoom1 <- ResC1[row.names(ResC1) %!in% c("P1","P5","G2"," ","PHINT",
                                        " "," ","RUE","KCAN"," ","SLDR"," ",
                                        " ","SDUL.30","SSAT.30","SBDM.30",
                                        "SLLL.60","SDUL.60","SSAT.60"," ","SAOC.30",
                                        "SASC.30","SAOC.60","SASC.60"),]

ade4::s.arrow(Zoom1,boxes = F,xax=1,yax=2,label=row.names(Zoom1),clabel=0.8,
              grid=F) 



# g4 <- ade4::s.arrow(coinD$l1,xax=1,yax=3, boxes = FALSE,label=c("Anth","Mat","GY"," ","MLAI",
#                                                                   "Transp","sEvap","sWater","Nup","Drin"),clabel=1,grid=T) 
g4 <- ade4::s.arrow(coinD$l1,xax=1,yax=3, boxes = FALSE,clabel=0.8,grid=T) 
g5 <- ade4::s.arrow(ResC1,boxes = F,xax=1,yax=3,clabel=1)

g5 <- ade4::s.arrow(ResC1,boxes = F,xax=1,yax=3,label=c("P1","P5","G2","G3"," ",
                                                        "GDDE"," ","RUE"," ",
                                                        " ","SLDR"," ",
                                                        "SLLL.30","SDUL.30","SSAT.30","SBDM.30",
                                                        " "," "," "," ",
                                                        "SAOC.30","SASC.30"," "," "),
                                        clabel=0.8,grid=T) 

draw.circle(0,0,0.15,col=adjustcolor("gray", alpha.f = 0.4))

Zoom2 <- ResC1[row.names(ResC1) %!in% c("P1","P5","G2","G3"," ",
                                        "GDDE"," ","RUE"," ",
                                        " ","SLDR"," ",
                                        "SLLL.30","SDUL.30","SSAT.30","SBDM.30",
                                        " "," "," "," ",
                                        "SAOC.30","SASC.30"," "," "),]

g3 <- ade4::s.arrow(Zoom2,boxes = F,xax=1,yax=3,label=row.names(Zoom2),clabel=0.8,
                    grid=F) 



#library(ade4TkGUI)
#ade4TkGUI()
#polygon.shadow(0,0,
#               offset=c(0,0),inflate=c(0.1,0.1))
setwd("D:/ISmalia_DSSAT/co-inertia_analysis/Co_interia_19_12_22/new")
