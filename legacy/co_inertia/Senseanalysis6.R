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

setwd("D:/ISmalia_DSSAT/co-inertia_analysis")
wd = "D:/ISmalia_DSSAT"
par <- read.csv(paste(wd,"/Corn_calibration.csv",sep=""))
X <- par$Calib_SC10_3_13
#-------------------------
A <- improvedLHS(500,21,dup = 5)
B <- matrix(nrow = nrow(A), ncol = ncol(A))

B[,1] <- qunif(A[,1], min = 150, max = 300)
B[,2] <- qunif(A[,2], min = 600, max = 1100)
B[,3] <- qunif(A[,3], min = 500, max = 1100)
B[,4] <- qunif(A[,4], min = 4, max = 11)
B[,5] <- qunif(A[,5], min = 40, max = 70)
B[,6] <- qunif(A[,6], min = 2.5, max = 5)
B[,7] <- qunif(A[,7], min = 3, max = 12)
B[,8] <- qunif(A[,8], min = 0.5, max = 0.95)
B[,9] <- qunif(A[,9], min = 0.7, max = 1)
B[,10] <- qunif(A[,10], min = 0.01, max = 0.05)
B[,11] <- qunif(A[,11], min = 0.06, max = 0.22)
B[,12] <- qunif(A[,12], min = 0.22, max = 0.6)
B[,13] <- qunif(A[,13], min = 1, max = 1.8)
B[,14] <- qunif(A[,14], min = 0.01, max = 0.07)
B[,15] <- qunif(A[,15], min = 0.08, max = 0.18)
B[,16] <- qunif(A[,16], min = 0.18, max = 0.5)
B[,17] <- qunif(A[,17], min = 1.1, max = 1.8)
B[,18] <- qunif(A[,18], min = 0.2, max = 0.6)
B[,19] <- qunif(A[,19], min = 0.3, max = 0.7)
B[,20] <- qunif(A[,20], min = 0.1, max = 0.5)
B[,21] <- qunif(A[,21], min = 0.3, max = 0.7)


Inputparam <- data.frame("P1"=B[,1],"P5"=B[,2],
                         "G2"=B[,3],"G3"=B[,4],"PHINT"=B[,5],
                         "RUE"=B[,6],"SLU1"=B[,7],"SLDR"=B[,8],"SLPF"=B[,9],"SLLL.30"=B[,10],
                         "SDUL.30"=B[,11],"SSAT.30"=B[,12],"SBDM.30"=B[,13],
                         "SLLL.60"=B[,14],"SDUL.60"=B[,15],"SSAT.60"=B[,16],"SBDM.60"=B[,17],
                         "SAOC.30"=B[,18],"SASC.30"=B[,19],"SAOC.60"=B[,20],"SASC.60"=B[,21])

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
               formatC(X[12],format="f",digits=1,width=5),formatC(X[13],format="f",digits=1,width=6),
               formatC(B[i,6],format="f",digits=1,width=4),
               formatC(X[15],format="f",digits=2,width=6))

  cat(out_string2,
      "IB0001 GENERIC MIDWEST1   ",CalibP2,file="C:/DSSAT47/Genotype/MZCER047.ECO",fill=T,append = F)

  
  sbuild <- readLines("C:/DSSAT47/Soil/ZU.SOL")
  sbuild[70] = paste("     Y   .17 ",formatC(B[i,7],format="f",digits=1,width = 4),"",formatC(B[i,8],format="f",digits=2),"   83    1  ",formatC(B[i,9],format="f",digits=2),"  -99   -99   -99")
  sbuild[72] = paste("     5    AP",formatC(B[i,10],format="f",digits=3),formatC(B[i,11],format="f",digits=3),formatC(B[i,12],format="f",digits=3),"    1   4.3 ",formatC(B[i,13],format="f",digits=2),"",formatC(0.22,format="f",digits=2),"  6.8   3.1     0   -99   8.5   -99  25.5   -99")
  sbuild[73] = paste("    15    AP",formatC(B[i,10],format="f",digits=3),formatC(B[i,11],format="f",digits=3),formatC(B[i,12],format="f",digits=3),"    1   4.3 ",formatC(B[i,13],format="f",digits=2),"",formatC(0.22,format="f",digits=2),"  6.2     3     0   -99   8.5   -99  25.5   -99")
  sbuild[74] = paste("    30    AP",formatC(B[i,10],format="f",digits=3),formatC(B[i,11],format="f",digits=3),formatC(B[i,12],format="f",digits=3),"    1   4.3 ",formatC(B[i,13],format="f",digits=2),"",formatC(0.22,format="f",digits=2),"  6.1   2.8     0   -99   8.5   -99  25.5   -99")
  sbuild[75] = paste("    50    C1",formatC(B[i,14],format="f",digits=3),formatC(B[i,15],format="f",digits=3),formatC(B[i,16],format="f",digits=3)," .449   4.3 ",formatC(B[i,17],format="f",digits=2),"",formatC(0.45,format="f",digits=2),"    4   1.7     0   -99   8.6   -99  24.5   -99")
  sbuild[76] = paste("    60    C1",formatC(B[i,14],format="f",digits=3),formatC(B[i,15],format="f",digits=3),formatC(B[i,16],format="f",digits=3)," .301   4.3 ",formatC(B[i,17],format="f",digits=2),"",formatC(0.45,format="f",digits=2),"    3   1.5     0   -99   8.6   -99  23.5   -99")

  write(sbuild,file="C:/DSSAT47/Soil/ZU.SOL")
  
  xbuild <- readLines("C:/DSSAT47/Maize/SENS1111.MZX")
  xbuild[48] = paste(" 1    30   -99 ",formatC(B[i,18],format="f",digits=2),"  -99   -99   -99   -99   -99 ",formatC(B[i,19],format="f",digits=2,width=2))
  xbuild[49] = paste(" 1    60   -99 ",formatC(B[i,20],format="f",digits=2),"  -99   -99   -99   -99   -99 ",formatC(B[i,21],format="f",digits=2,width=2))
  
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

  Biom <- 0
  GY <- 0 
  Straw <- 0
  MLAI <- 0
  PlantDate <- 0
  Anth <- 0
  Mat <- 0
  Transp <- 0
  sEvap <- 0
  sWater <- 0
  Nup <- 0
  Drin <- 0
  
  datagro=as.data.frame(plantgro[[1]])
  datasumm=as.data.frame(Summaryout[[1]])
  dataET=as.data.frame(ETout[[1]])
  dataSW=as.data.frame(SWout[[1]])
  GY <- tail(datagro$GWAD,n=1)
  Biom <- tail(datagro$CWAD,n=1)
  Straw <- Biom-GY
  MLAI <- max(datagro$LAID)
  PlantDate <- datasumm$PDAT
  Anth <- datasumm$ADAT-PlantDate
  Mat <- datasumm$MDAT-PlantDate
  Transp <- tail(dataET$EPAC,n=1)
  sEvap <- tail(dataET$ESAC,n=1)
  sWater <- tail(dataSW$SWTD,n=1)
  Nup <- datasumm$NUCM
  Drin <- datasumm$DRCM
  
  Simdaday=cbind.data.frame(Anth,Mat,GY,Straw,MLAI,Transp,sEvap,sWater,Nup,Drin)
  
  if(i==1){
    SIMSEN=Simdaday
  }else{
    SIMSEN=rbind.data.frame(SIMSEN,Simdaday)
  }
  
  if(GY < 50){
    print(paste("coming out from for loop where Crop failure growth program terminated"))
          break
   }
}

#--------------Co-inertia analysis-----------------------

dinput <- dudi.pca(Inputparam, scale = T, scannf = F, nf = 3)
dout <- dudi.pca(SIMSEN, scale = T, scannf = F, nf = 3)
coinD <- coinertia(dinput,dout, scannf = T,nf=3)
#---------------------plot-------------------------------------
plot(coinD)
summary(coinD)
g1 <- ade4::s.arrow(coinD$l1,xax=1,yax=3, boxes = FALSE,clabel=0.8,grid=T)
g2_1 <- ade4::s.arrow(coinD$c1,boxes = F,xax=1,yax=3,clabel=1)

ResC1 <-  coinD$c1[row.names(coinD$c1) %!in% "SSAT.90",]
g2 <- ade4::s.arrow(ResC1,boxes = F,xax=1,yax=2,label=c("P1","P2","P5"," "," ","PHINT"," ",
                                                           "RUE"," "," ","SLDR","SLPF","SLLL.30",
                                                           "SDUL.30","SSAT.30","SBDM.30","SLOC.30",
                                                           "SLLL.60","SDUL.60"," "," "," "," "," ",
                                                           " "," "),clabel=0.8,grid=T) 
draw.circle(0,0,0.12,col=adjustcolor("gray", alpha.f = 0.40))

# row.names(coinD$c1)[9]  <- "SDUL.30"
# row.names(coinD$c1)[14]  <-"NA"
# row.names(coinD$c1)[14]  <-"KCAN"


Zoom1 <- ResC1[row.names(ResC1) %!in% c("P1","P2","P5"," "," ","PHINT"," ",
                                                       "RUE"," "," ","SLDR","SLPF","SLLL.30",
                                                       "SDUL.30","SSAT.30","SBDM.30","SLOC.30",
                                                       "SLLL.60","SDUL.60"," "," "," "," "," ",
                                                       " "," "),]

g3 <- ade4::s.arrow(Zoom1,boxes = F,xax=1,yax=2,label=row.names(Zoom1),clabel=0.8,
              grid=F) 



# g4 <- ade4::s.arrow(coinD$l1,xax=1,yax=3, boxes = FALSE,label=c("Anth","Mat","GY"," ","MLAI",
#                                                                   "Transp","sEvap","sWater","Nup","Drin"),clabel=1,grid=T) 
g4 <- ade4::s.arrow(coinD$l1,xax=1,yax=3, boxes = FALSE,clabel=0.8,grid=T) 
g5 <- ade4::s.arrow(ResC1,boxes = F,xax=1,yax=3,clabel=0.8)

g5 <- ade4::s.arrow(ResC1,boxes = F,xax=1,yax=3,label=c("P1","P2","P5","G2","G3"," ",
                                                        "DSGFT","RUE","KCAN"," ","SLDR",
                                                        "SLPF"," ","SDUL.30","SSAT.30",
                                                        " "," "," "," "," "," "," ",
                                                        " "," "," "," "),clabel=0.8,grid=T) 
draw.circle(0,0,0.13,col=adjustcolor("gray", alpha.f = 0.4))

Zoom2 <- ResC1[row.names(ResC1) %!in% c("P1","P2","P5","G2","G3"," ",
                                        "DSGFT","RUE","KCAN"," ","SLDR",
                                        "SLPF"," ","SDUL.30","SSAT.30",
                                        " "," "," "," "," "," "," ",
                                        " "," "," "," "),]

g3 <- ade4::s.arrow(Zoom2,boxes = F,xax=1,yax=3,label=row.names(Zoom2),clabel=0.8,
                    grid=F) 



#library(ade4TkGUI)
#ade4TkGUI()
#polygon.shadow(0,0,
#               offset=c(0,0),inflate=c(0.1,0.1))
setwd("D:/ISmalia_DSSAT/co-inertia_analysis/Co_interia_19_12_22/new")
