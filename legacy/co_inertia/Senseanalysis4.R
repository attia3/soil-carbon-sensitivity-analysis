# HISTORICAL RESEARCH SOURCE — ARCHIVE ONLY
# Original scientific logic below is preserved exactly as provided.
# CAUTION: The script assumes local DSSAT executables and external data.
# It may overwrite installed genotype, soil, or experiment files.
# To execute deliberately, use an isolated copy of the environment and
# remove the following stop() only after reviewing all paths and inputs.
stop("ARCHIVED SCRIPT: not safe to run as-is; read legacy/README.md")

library(sensitivity)
library(lhs)
#library(ade4TkGUI)
library(`ade4`)
library(Dasst)
library(plotrix)

setwd("D:/ISmalia_DSSAT/co-inertia_analysis")
wd = "D:/ISmalia_DSSAT"
par <- read.csv(paste(wd,"/Corn_calibration.csv",sep=""))
X <- par$Calib_SC10_12_9

A <- improvedLHS(1500,23,dup = 5)
B <- matrix(nrow = nrow(A), ncol = ncol(A))

B[,1] <- qunif(A[,1], min = 150, max = 350)
B[,2] <- qunif(A[,2], min = 0, max = 2)
B[,3] <- qunif(A[,3], min = 600, max = 1100)
B[,4] <- qunif(A[,4], min = 400, max = 1100)
B[,5] <- qunif(A[,5], min = 4, max = 11.5)
B[,6] <- qunif(A[,6], min = 30, max = 55)
B[,7] <- qunif(A[,7], min = 153, max = 187)
B[,8] <- qunif(A[,8], min = 2, max = 5)
B[,9] <- qunif(A[,9], min = 0.45, max = 0.9)
B[,10] <- qunif(A[,10], min = 3, max = 12)
B[,11] <- qunif(A[,11], min = 0.3, max = 0.95)
B[,12] <- qunif(A[,12], min = 0.5, max = 0.90)
B[,13] <- qunif(A[,13], min = 0.015, max = 0.055)
B[,14] <- qunif(A[,14], min = 0.06, max = 0.15)
B[,15] <- qunif(A[,15], min = 0.20, max = 0.41)
B[,16] <- qunif(A[,16], min = 1.2, max = 1.8)
B[,17] <- qunif(A[,17], min = 0.1, max = 1.1)
B[,18] <- qunif(A[,18], min = 0.015, max = 0.055)
B[,19] <- qunif(A[,19], min = 0.065, max = 0.12)
B[,20] <- qunif(A[,20], min = 0.15, max = 0.35)
B[,21] <- qunif(A[,21], min = 1.2, max = 1.8)
B[,22] <- qunif(A[,22], min = 0.1, max = 1.1)
B[,23] <- qunif(A[,23], min = 0.5, max = 0.9)


Inputparam <- data.frame("P1"=B[,1],"P2"=B[,2],"P5"=B[,3],
                         "G2"=B[,4],"G3"=B[,5],"PHINT"=B[,6],
                         "DSGFT"=B[,7],"RUE"=B[,8],"KCAN"=B[,9],
                         "SLU1"=B[,10],"SLDR"=B[,11],"SLPF"=B[,12],"SLLL.30"=B[,13],
                         "SDUL.30"=B[,14],"SSAT.30"=B[,15],"SBDM.30"=B[,16],"SLOC.30"=B[,17],
                         "SLLL.90"=B[,18],"SDUL.90"=B[,19],"SSAT.90"=B[,20],"SBDM.90"=B[,21],
                         "SLOC.90"=B[,22])

#---------Global sensitivity based on Co-inertia analysis-----------------

for(i in 1:nrow(B)){
  
  out_string <- paste0("!MAIZE CULTIVAR COEFFICIENTS: MZCER047 MODEL\n",
                       "!AHMED ATTIA (MAR-2019)\n",
                       "@VAR#  VRNAME.......... EXPNO   ECO#    P1    P2    P5    G2    G3  PHINT")
  
  CalibP <- c(formatC(B[i,1],format="f",digits=1),formatC(B[i,2],format="f",digits=3),formatC(B[i,3],format="f",digits=0),
              formatC(B[i,4],format="f",digits=0), formatC(B[i,5],format="f",digits=1),
              formatC(B[i,6],format="f",digits=2))
  CalibP[3] <- paste("",CalibP[3],sep=" ")
  CalibP[4] <- paste("",CalibP[4],sep="")
  CalibP[5] <- paste("  ",CalibP[5],sep="")
  CalibP[6] <- paste("  ",CalibP[6],sep=" ")
  
  
  cat(out_string,
      "990001 LONG SEASON          . IB0001",CalibP,file="C:/DSSAT47/Genotype/MZCER047.CUL",fill=T,append = F)
  
  out_string2 <- paste0("*MAIZE ECOTYPE COEFFICIENTS: MZCER047 MODEL\n",
                        "@ECO#  ECONAME.........  TBASE  TOPT ROPT   P20  DJTI  GDDE  DSGFT  RUE   KCAN  TSEN  CDAY")
  
  
  CalibP2 <- c(formatC(X[7],format="f",digits=1),formatC(X[8],format="f",digits=1),formatC(X[9],format="f",digits=1),
               formatC(X[10],format="f",digits=1),formatC(X[11],format="f",digits=1),
               formatC(X[12],format="f",digits=1),formatC(B[i,7],format="f",digits=1),formatC(B[i,8],format="f",digits=1),
               formatC(B[i,9],format="f",digits=2))
  CalibP2[2] <- paste(" ",CalibP2[2],sep="")
  CalibP2[3] <- paste("",CalibP2[3],sep="")
  CalibP2[4] <- paste(" ",CalibP2[4],sep="")
  CalibP2[5] <- paste("  ",CalibP2[5],sep="")
  CalibP2[6] <- paste("  ",CalibP2[6],sep="")
  CalibP2[7] <- paste(" ",CalibP2[7],sep="")
  CalibP2[8] <- paste(" ",CalibP2[8],sep="")
  CalibP2[9] <- paste("  ",CalibP2[9],sep="")
  
  cat(out_string2,
      "IB0001 GENERIC MIDWEST1   ",CalibP2,file="C:/DSSAT47/Genotype/MZCER047.ECO",fill=T,append = F)
  
  sbuild <- readLines("C:/DSSAT47/Soil/ZU.SOL")
  sbuild[49] = paste("     Y   .17 ",formatC(B[i,10],format="f",digits=2),"",formatC(B[i,11],format="f",digits=2),"   83    1  ",formatC(B[i,12],format="f",digits=2),"  -99   -99   -99")
  sbuild[53] = paste("    30    AP",formatC(B[i,13],format="f",digits=3),formatC(B[i,14],format="f",digits=3),formatC(B[i,15],format="f",digits=3)," .607   4.3 ",formatC(B[i,16],format="f",digits=2),"",formatC(B[i,17],format="f",digits=2),"  6.1   2.8     0   -99   8.5   -99  25.5   -99")
  sbuild[57] = paste("    90    C2",formatC(B[i,18],format="f",digits=3),formatC(B[i,19],format="f",digits=3),formatC(B[i,20],format="f",digits=3)," .183   4.3 ",formatC(B[i,21],format="f",digits=2),"",formatC(B[i,22],format="f",digits=2),"  2.0   1.3     0   -99   8.5   -99  22.5   -99")
  write(sbuild,file="C:/DSSAT47/Soil/ZU.SOL")
  
  # xbuild <- readLines("C:/DSSAT47/Maize/SENS0503.MZX")
  # xbuild[57] = paste(" 1 ",formatC(B[i,23],format="f",digits=2),"  30    50   100  GS000 IR001    10 IrrigationF2")
  # write(xbuild,file="C:/DSSAT47/Maize/SENS0503.MZX")
  
  #----write batch file---------
  TREF1111.MZX = "SENS0503.MZX"
  Trt=1
  
  out_stringb <- paste0("$BATCH(MAIZE)\n",
                        "!\n",
                        "! Directory    : C:\\DSSAT47\\Maize\n",
                        "! Command Line : C:\\DSSAT47\\DSCSM047.EXE MZCER047 B DSSBatch.v47\n",
                        "! Crop         : Maize\n",
                        "! Experiment   : SENS0503.MZX\n",
                        "! ExpNo        : 1\n",
                        "! Debug        : C:\\DSSAT47\\DSCSM047.EXE MZCER047 ' B DSSBatch.v47\n",
                        "!\n",
                        "@FILEX                                                                                        TRTNO     RP     SQ     OP     CO")
  
  for(j in 1:length(Trt)){
    Trtp <- paste0("C:\\DSSAT47\\Maize\\SENS0503.MZX                                                                    ",Trt[j],"      1      0      0      0\n")
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
 }

#--------------Co-inertia analysis-----------------------

dinput <- dudi.pca(Inputparam, scale = T, scannf = F, nf = 3)
dout <- dudi.pca(SIMSEN, scale = T, scannf = F, nf = 3)
coinD <- coinertia(dinput,dout, scannf = T,nf=3)
#---------------------plot-------------------------------------
plot(coinD)
summary(coinD)
g1 <- ade4::s.arrow(coinD$l1,xax=1,yax=2, boxes = FALSE,clabel=1,grid=T)
g2_1 <- ade4::s.arrow(coinD$c1,boxes = F,xax=1,yax=2)
g2 <- ade4::s.arrow(coinD$c1,boxes = F,xax=1,yax=2,label=c("P1"," ","P5","G2",
                                                           " ","PHINT"," ","RUE"," ",
                                                           " ","SLDR","SLPF"," "," "," "," "," ","SLLL.90",
                                                           " "," "," ","SLOC.90")
                                                           ,clabel=1,grid=T) 
draw.circle(0,0,0.17,col=adjustcolor("gray", alpha.f = 0.4))

row.names(coinD$c1)[9]  <- "SDUL.30"
row.names(coinD$c1)[14]  <-"NA"
row.names(coinD$c1)[14]  <-"KCAN"


dfd <- coinD$c1[row.names(coinD$c1)%in% c(" ","P2"," "," ",
                                           "G3"," ","DSGFT"," ","SDUL.30",
                                           "SLU1"," "," ","SLLL.30","KCAN","SSAT.30","SBDM.30","SLOC.30"," ",
                                           "SDUL.90","SSAT.90","SBDM.90"," "),]

g3 <- ade4::s.arrow(dfd,boxes = F,xax=1,yax=2,label=row.names(dfd),clabel=1,
              grid=F) 



g4 <- ade4::s.arrow(coinD$l1,xax=1,yax=3, boxes = FALSE,label=c("Anth","Mat","GY"," ","MLAI",
                                                                  "Transp","sEvap","sWater","Nup","Drin"),clabel=1,grid=T) 
g4 <- ade4::s.arrow(coinD$l1,xax=1,yax=3, boxes = FALSE,clabel=1,grid=T) 
g5 <- ade4::s.arrow(coinD$c1,boxes = F,xax=1,yax=3)

g5 <- ade4::s.arrow(coinD$c1,boxes = F,xax=1,yax=3,label=c("P1","P2","P5"," ","G3","PHINT"," ","RUE",
                                                           "SDUL.30"," ","SLDR","SLPF","SLLL.30"," ",
                                                           " "," "," ","SLLL.90"," "," "," ","SLOC.90")
                    ,clabel=1,grid=T) 
draw.circle(0,0,0.13,col=adjustcolor("gray", alpha.f = 0.4))
Cy3 <- coinD$c1[(row.names(coinD$c1)%in% c(" "," "," ","G2"," "," ","DSGFT"," ",
                                           " ","SLU1"," "," "," ","KCAN",
                                           "SSAT.30","SBDM.30","SLOC.30"," ","SDUL.90","SSAT.90","SBDM.90"," ")),]

g6 <- ade4::s.arrow(Cy3,boxes = F,xax=1,yax=3,label=row.names(Cy3),clabel=1,
                    grid=F)


#library(ade4TkGUI)
#ade4TkGUI()
#polygon.shadow(0,0,
#               offset=c(0,0),inflate=c(0.1,0.1))
setwd("D:/ISmalia_DSSAT/co-inertia_analysis/Co_interia_19_12_22/new")
#------------sobol sensitivity-----------------

my.function <- function(S){

for(i in 1:nrow(S)){
  
  out_string <- paste0("!MAIZE CULTIVAR COEFFICIENTS: MZCER047 MODEL\n",
                       "!AHMED ATTIA (MAR-2019)\n",
                       "@VAR#  VRNAME.......... EXPNO   ECO#    P1    P2    P5    G2    G3  PHINT")
  
  CalibP <- c(formatC(S[i,1],format="f",digits=1),formatC(S[i,2],format="f",digits=3),formatC(S[i,3],format="f",digits=0),
              formatC(S[i,4],format="f",digits=0), formatC(S[i,5],format="f",digits=1),
              formatC(S[i,6],format="f",digits=2))
  CalibP[3] <- paste("",CalibP[3],sep=" ")
  CalibP[4] <- paste("",CalibP[4],sep="")
  CalibP[5] <- paste("  ",CalibP[5],sep="")
  CalibP[6] <- paste("  ",CalibP[6],sep=" ")
  
  
  cat(out_string,
      "990001 LONG SEASON          . IB0001",CalibP,file="C:/DSSAT47/Genotype/MZCER047.CUL",fill=T,append = F)
  
  out_string2 <- paste0("*MAIZE ECOTYPE COEFFICIENTS: MZCER047 MODEL\n",
                        "@ECO#  ECONAME.........  TBASE  TOPT ROPT   P20  DJTI  GDDE  DSGFT  RUE   KCAN  TSEN  CDAY")
  
  
  CalibP2 <- c(formatC(X[7],format="f",digits=1),formatC(X[8],format="f",digits=1),formatC(X[9],format="f",digits=1),
               formatC(X[10],format="f",digits=1),formatC(X[11],format="f",digits=1),
               formatC(X[12],format="f",digits=1),formatC(S[i,7],format="f",digits=1),formatC(S[i,8],format="f",digits=1),
               formatC(S[i,9],format="f",digits=2))
  CalibP2[2] <- paste(" ",CalibP2[2],sep="")
  CalibP2[3] <- paste("",CalibP2[3],sep="")
  CalibP2[4] <- paste(" ",CalibP2[4],sep="")
  CalibP2[5] <- paste("  ",CalibP2[5],sep="")
  CalibP2[6] <- paste("  ",CalibP2[6],sep="")
  CalibP2[7] <- paste(" ",CalibP2[7],sep="")
  CalibP2[8] <- paste(" ",CalibP2[8],sep="")
  CalibP2[9] <- paste("  ",CalibP2[9],sep="")
  
  cat(out_string2,
      "IB0001 GENERIC MIDWEST1   ",CalibP2,file="C:/DSSAT47/Genotype/MZCER047.ECO",fill=T,append = F)
  
  sbuild <- readLines("C:/DSSAT47/Soil/ZU.SOL")
  sbuild[49] = paste("     Y   .17 ",formatC(S[i,10],format="f",digits=2),"",formatC(S[i,11],format="f",digits=2),"   83    1  ",formatC(S[i,12],format="f",digits=2),"  -99   -99   -99")
  sbuild[53] = paste("    30    AP",formatC(S[i,13],format="f",digits=3),formatC(S[i,14],format="f",digits=3),formatC(S[i,15],format="f",digits=3)," .607   4.3 ",formatC(S[i,16],format="f",digits=2),"",formatC(S[i,17],format="f",digits=2),"  6.1   2.8     0   -99   8.5   -99  25.5   -99")
  sbuild[57] = paste("    90    C2",formatC(S[i,18],format="f",digits=3),formatC(S[i,19],format="f",digits=3),formatC(S[i,20],format="f",digits=3)," .183   4.3 ",formatC(S[i,21],format="f",digits=2),"",formatC(S[i,22],format="f",digits=2),"  2.0   1.3     0   -99   8.5   -99  22.5   -99")
  write(sbuild,file="C:/DSSAT47/Soil/ZU.SOL")
  
  xbuild <- readLines("C:/DSSAT47/Maize/SENS0503.MZX")
  xbuild[57] = paste(" 1 ",formatC(S[i,23],format="f",digits=2),"  30    50   100  GS000 IR001    10 IrrigationF2")
  write(xbuild,file="C:/DSSAT47/Maize/SENS0503.MZX")
  
  # #----write batch file---------
  # TREF1111.MZX = "SENS0503.MZX"
  # Trt=1
  # 
  # out_stringb <- paste0("$BATCH(MAIZE)\n",
  #                       "!\n",
  #                       "! Directory    : C:\\DSSAT47\\Maize\n",
  #                       "! Command Line : C:\\DSSAT47\\DSCSM047.EXE MZCER047 B DSSBatch.v47\n",
  #                       "! Crop         : Maize\n",
  #                       "! Experiment   : SENS0503.MZX\n",
  #                       "! ExpNo        : 1\n",
  #                       "! Debug        : C:\\DSSAT47\\DSCSM047.EXE MZCER047 ' B DSSBatch.v47\n",
  #                       "!\n",
  #                       "@FILEX                                                                                        TRTNO     RP     SQ     OP     CO")
  # 
  # for(j in 1:length(Trt)){
  #   Trtp <- paste0("C:\\DSSAT47\\Maize\\SENS0503.MZX                                                                    ",Trt[j],"      1      0      0      0\n")
  #   if(j==1){
  #     TrtR=Trtp
  #   }else{
  #     TrtR=rbind(TrtR,Trtp)
  #   }
  # }
  # 
  # TrtR2 = gsub("TREF1111.MZX",TREF1111.MZX,TrtR)
  # cat(out_stringb,
  #     file="C:/DSSAT47/Maize/DSSBatch.v47",fill=T,append = F)
  # cat(TrtR2,
  #     file="C:/DSSAT47/Maize/DSSBatch.v47",fill=T,append = T)
  
  setwd(paste("C:/DSSAT47/Maize",sep = ""))
  
  #--- write paramters used on the screen
  message("")
  message("Running DSSAT-MaizeCERES...")
  
  #--- Call DSSAT047.exe and run X files list within DSSBatch.v47
  system("C:/DSSAT47/DSCSM047.EXE MZCER047 B DSSBatch.v47",show.output.on.console = F)
  
  
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
  transp <- 0
  sEvap <- 0
  sWater <- 0

    
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
    transp <- tail(dataET$EPAC,n=1)
    sEvap <- tail(dataET$ESAC,n=1)
    sWater <- tail(dataSW$SWTD,n=1)
  

  Simdaday=cbind.data.frame(Anth,Mat,GY,Straw,MLAI,transp,sEvap,sWater)
  
  if(i==1){
    SIMSEN=Simdaday
    GYall= tail(datagro$GWAD,n=1)
  }else{
    SIMSEN=rbind.data.frame(SIMSEN,Simdaday)
    GYall=rbind(GYall, tail(datagro$GWAD,n=1))
  }
}

return(SIMSEN$GY)
  
}



C <- improvedLHS(2000,23,dup = 5)
S <- matrix(nrow = nrow(C), ncol = ncol(C))

S[,1] <- qunif(C[,1], min = 130, max = 380)
S[,2] <- qunif(C[,2], min = 0, max = 2)
S[,3] <- qunif(C[,3], min = 600, max = 1100)
S[,4] <- qunif(C[,4], min = 400, max = 1100)
S[,5] <- qunif(C[,5], min = 4, max = 11.5)
S[,6] <- qunif(C[,6], min = 30, max = 90)
S[,7] <- qunif(C[,7], min = 153, max = 187)
S[,8] <- qunif(C[,8], min = 2, max = 5)
S[,9] <- qunif(C[,9], min = 0.45, max = 0.9)
S[,10] <- qunif(C[,10], min = 3, max = 12)
S[,11] <- qunif(C[,11], min = 0.01, max = 0.95)
S[,12] <- qunif(C[,12], min = 0.5, max = 1)
S[,13] <- qunif(C[,13], min = 0.015, max = 0.055)
S[,14] <- qunif(C[,14], min = 0.06, max = 0.15)
S[,15] <- qunif(C[,15], min = 0.20, max = 0.41)
S[,16] <- qunif(C[,16], min = 1.2, max = 1.8)
S[,17] <- qunif(C[,17], min = 0.1, max = 0.4)
S[,18] <- qunif(C[,18], min = 0.015, max = 0.055)
S[,19] <- qunif(C[,19], min = 0.065, max = 0.12)
S[,20] <- qunif(C[,20], min = 0.15, max = 0.35)
S[,21] <- qunif(C[,21], min = 1.2, max = 1.8)
S[,22] <- qunif(C[,22], min = 0.1, max = 0.4)
S[,23] <- qunif(C[,23], min = 0.5, max = 0.9)


InputparamS <- data.frame("P1"=S[,1],"P2"=S[,2],"P5"=S[,3],
                         "G2"=S[,4],"G3"=S[,5],"PHINT"=S[,6],
                         "DSGFT"=S[,7],"RUE"=S[,8],"KCAN"=S[,9],
                         "SLU1"=S[,10],"SLDR"=S[,11],"SLPF"=S[,12],"SLLL.30"=S[,13],
                         "SDUL.30"=S[,14],"SSAT.30"=S[,15],"SBDM.30"=S[,16],"SLOC.30"=S[,17],
                         "SLLL.90"=S[,18],"SDUL.90"=S[,19],"SSAT.90"=S[,20],"SBDM.90"=S[,21],
                         "SLOC.90"=S[,22],"IrrigE"=S[,23])

S <- as.data.frame(S)
S1 <- S[sample(nrow(S)),]
S1 <- as.data.frame(S1)
S2 <- S[sample(nrow(S)),]
S2 <- as.data.frame(S2)

my.function(S)

sobolGY <- sobolowen(model = my.function, X1=S, X2=S1, X3=S2, nboot = 100, conf = 0.95)  





plot(Sens$SLDR[Sens$line=="1"],Sens$GY[Sens$line=="1"],
     type="o",ylim=c(0,7000),pch=1)
lines(Sens$SLDR[Sens$line=="2"],Sens$GY[Sens$line=="2"],type="o",pch=2)
lines(Sens$SLDR[Sens$line=="3"],Sens$GY[Sens$line=="3"],type="o",pch=3)
lines(Sens$SLDR[Sens$line=="4"],Sens$GY[Sens$line=="4"],type="o",pch=4)

plot(Sens2$SLPF[Sens2$line=="1"],Sens2$GY[Sens2$line=="1"],
     type="o",ylim=c(0,7000),pch=1)
lines(Sens2$SLPF[Sens2$line=="2"],Sens2$GY[Sens2$line=="2"],type="o",pch=2)
lines(Sens2$SLPF[Sens2$line=="3"],Sens2$GY[Sens2$line=="3"],type="o",pch=3)
lines(Sens2$SLPF[Sens2$line=="4"],Sens2$GY[Sens2$line=="4"],type="o",pch=4)

plot(Sens3$SLOC30[Sens3$line=="1"],Sens3$GY[Sens3$line=="1"],
     type="o",ylim=c(0,7000),pch=1)
lines(Sens3$SLOC30[Sens3$line=="2"],Sens3$GY[Sens3$line=="2"],type="o",pch=2)
lines(Sens3$SLOC30[Sens3$line=="3"],Sens3$GY[Sens3$line=="3"],type="o",pch=3)
lines(Sens3$SLOC30[Sens3$line=="4"],Sens3$GY[Sens3$line=="4"],type="o",pch=4)

plot(Sens4$SWC[Sens4$line=="1"],Sens4$GY[Sens4$line=="1"],
     type="o",ylim=c(0,7000),pch=1)
lines(Sens4$SWC[Sens4$line=="2"],Sens4$GY[Sens4$line=="2"],type="o",pch=2)
lines(Sens4$SWC[Sens4$line=="3"],Sens4$GY[Sens4$line=="3"],type="o",pch=3)
lines(Sens4$SWC[Sens4$line=="4"],Sens4$GY[Sens4$line=="4"],type="o",pch=4)
