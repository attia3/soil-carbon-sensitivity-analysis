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


#------------------sens_3-8-2020--------------

par.ranges=list(v1=c(0.20,0.60),v2=c(0.2,0.70),
                v3=c(0,5000),v4=c(0,10000))

S <- parameterSets(par.ranges,samples=300,method="sobol")

S1 <- S[sample(nrow(S)),]

variables =c("mean_SOCD_all")

out <- vector("list",length(variables))

for(e in 1:length(variables)){
  
my.function <- function(S){
  
  for(i in 1:nrow(S)){
    
    xbuild <- readLines("C:/DSSAT47/Sequence/SENE8400.SQX")

    xbuild[31] = paste(" 1    90   -99 ",formatC(S[i,1],format="f",digits=2),"  -99   -99   -99   -99   -99 ",formatC(S[i,2],format="f",digits=2,width=2))
    xbuild[35] = paste(" 1    MZ 05263   200     0     1     1   180 ",formatC(S[i,3],format="g",digits=4,width=4)," 1.1    .2     0      0 residue")
    xbuild[91] = paste(" 1 05121 RE005 ",formatC(S[i,4],format="g",digits=4,width=4)," 0.53   .31   .55     0     0 AP001 compost")
    
    write(xbuild,file="C:/DSSAT47/Sequence/SENE8400.SQX")
    
    #----write batch file---------  
    TREF1111.MZX = "SENE8400.SQX"
    Trt=c(1,2)
    
    out_stringb <- paste0("$BATCH(SEQUENCE)\n",
                          "!\n",
                          "! Directory    : C:\\DSSAT47\\Sequence\n",
                          "! Command Line : C:\\DSSAT47\\DSCSM047.EXE Q DSSBatch.v47\n",
                          "! Crop         : Sequence\n",
                          "! Experiment   : SENE8400.SQX\n",
                          "! ExpNo        : 1\n",
                          "! Debug        : C:\\DSSAT47\\DSCSM047.EXE ' Q DSSBatch.v47\n",
                          "!\n",
                          "@FILEX                                                                                        TRTNO     RP     SQ     OP     CO")
    
    for(j in 1:length(Trt)){
      Trtp <- paste0("C:\\DSSAT47\\Sequence\\SENE8400.SQX                                                                 1       1      ",Trt[j],"      1      0\n")
      if(j==1){
        TrtR=Trtp
      }else{
        TrtR=rbind(TrtR,Trtp)
      }
    }
    
    TrtR2 = gsub("TREF1111.MZX",TREF1111.MZX,TrtR)
    cat(out_stringb,
        file="C:/DSSAT47/Sequence/DSSBatch.v47",fill=T,append = F)
    cat(TrtR2,
        file="C:/DSSAT47/Sequence/DSSBatch.v47",fill=T,append = T)
    
    setwd(paste("C:/DSSAT47/Sequence",sep = ""))
    
    #--- write paramters used on the screen
    message("")
    message("Running DSSAT-MaizeCERES...")
    
    #--- Call DSSAT047.exe and run X files list within DSSBatch.v47
    system("C:/DSSAT47/DSCSM047.EXE Q DSSBatch.v47",show.output.on.console = F)
    
    plantgro <- read.dssat("C:/DSSAT47/Sequence/PlantGro.OUT")
    Summ <- read.dssat("C:/DSSAT47/Sequence/Summary.OUT")
    SoilN <- read.dssat("C:/DSSAT47/Sequence/SoilNi.OUT")
    SoilC <- read.dssat("C:/DSSAT47/Sequence/SOMLITC.OUT")
    datasumm=as.data.frame(Summ[[1]])

    for(x in unique(SoilN[[1]]$YEAR)){
      NLCC <- SoilN[[1]]$NLCC[SoilN[[1]]$YEAR==x & SoilN[[1]]$DOY == 230]
      NMNC <- SoilN[[1]]$NMNC[SoilN[[1]]$YEAR==x & SoilN[[1]]$DOY == 230]
      NNMNC <- SoilN[[1]]$NNMNC[SoilN[[1]]$YEAR==x & SoilN[[1]]$DOY == 230]
      if(x == unique(SoilN[[1]]$YEAR)[1]){
        NLCC_all = NLCC
        NMNC_all = NMNC
        NNMNC_all =NNMNC
      }else{
        NLCC_all=c(NLCC_all,NLCC)
        NMNC_all=c(NMNC_all,NMNC)
        NNMNC_all=c(NNMNC_all,NNMNC)
      }
    }
    mean_NLCC <- mean(NLCC_all)
    mean_NMNC <- mean(NMNC_all)
    mean_NNMNC <- mean(NNMNC_all)
    
    for(z in unique(SoilC[[1]]$YEAR)){
      SOCD <- SoilC[[1]]$SOCD[SoilC[[1]]$YEAR==z & SoilC[[1]]$DOY == 230] #Total SOC
      SCS20D <- SoilC[[1]]$`SC%20D`[SoilC[[1]]$YEAR==z & SoilC[[1]]$DOY == 230]
      S1CTD <- SoilC[[1]]$S1CTD[SoilC[[1]]$YEAR==z & SoilC[[1]]$DOY == 230] #SOC1 soil
      S1C0D <- SoilC[[1]]$S1C0D[SoilC[[1]]$YEAR==z & SoilC[[1]]$DOY == 230] #SOC1 surface
      if(z == unique(SoilC[[1]]$YEAR)[1]){
        SCS20D_all = SCS20D
        S1CTD_all = S1CTD
        S1C0D_all= S1C0D
        SOCD_all=SOCD
      }else{
        SCS20D_all=c(SCS20D_all,SCS20D)
        S1CTD_all=c(S1CTD_all,S1CTD)  #SOC1 in soil
        S1C0D_all=c(S1C0D_all,S1C0D)  #SOC1 in surface
        SOCD_all=c(SOCD_all,SOCD) #Total SOC
      }
      TSOC1 <- S1C0D_all+S1CTD_all    #Total SOC1 
    }
    mean_SCS20D <- mean(SCS20D_all)
    mean_TSOC1 <- mean(TSOC1)
    mean_SOCD <- mean(SOCD_all)


    for(s in 1:nrow(datasumm[datasumm$TNAM %in% " Maize component          ",])){
      DMPEM <- datasumm$DMPEM[datasumm$TNAM %in% " Maize component          "][s]
      OCAM <- datasumm$OCAM[datasumm$TNAM %in% " Maize component          "][s]
      CO2EC <- datasumm$CO2EC[datasumm$TNAM %in% " Maize component          "][s]
      OCTAM <- datasumm$OCTAM[datasumm$TNAM %in% " Maize component          "][s]
    if(s==1){
      DMPEM_all = DMPEM
      OCAM_all = OCAM
      CO2EC_all = CO2EC
      OCTAM_all = OCTAM
    }else{
      DMPEM_all=c(DMPEM_all,DMPEM)
      OCAM_all=c(OCAM_all,OCAM)
      CO2EC_all=c(CO2EC_all,CO2EC)
      OCTAM_all=c(OCTAM_all,OCTAM)
      }
    }
    mean_DMPEM=mean(DMPEM_all)
    mean_OCAM=mean(OCAM_all)
    mean_CO2EC=mean(CO2EC_all)
    mean_OCTAM=mean(OCTAM_all)
    
    if(i==1){
      mean_NLCC_all <- mean_NLCC
      mean_NMNC_all <- mean_NMNC
      mean_NNMNC_all <- mean_NNMNC
      mean_DMPEM_all <- mean_DMPEM
      mean_OCAM_all <- mean_OCAM
      mean_SOCD_all <- mean_SOCD
      mean_OCTAM_all <- mean_OCTAM
      mean_CO2EC_all <- mean_CO2EC
      mean_SCS20D_all <- mean_SCS20D
      mean_TSOC1_all <- mean_TSOC1
    }else{
      mean_NLCC_all=c(mean_NLCC_all,mean_NLCC)   #N leaching (kg N/ha)
      mean_NMNC_all=c(mean_NMNC_all,mean_NMNC)   #N minerazlization (kg N/ha)
      mean_NNMNC_all=c(mean_NNMNC_all,mean_NNMNC) #net N mineralization
      mean_DMPEM_all=c(mean_DMPEM_all,mean_DMPEM) #water productivity (kg DM/ha/mm)
      mean_OCAM_all=c(mean_OCAM_all,mean_OCAM)   #Soil OC (kg/ha)
      mean_OCTAM_all=c(mean_OCTAM_all,mean_OCTAM) #Total OC soil plus surface (kg/ha)
      mean_SOCD_all=c(mean_SOCD_all,mean_SOCD) #Total OC soil plus surface (kg/ha) at 230 DOY
      mean_CO2EC_all=c(mean_CO2EC_all,mean_CO2EC) #Cumulative CO2 emission from soil (kg C/ha)
      mean_SCS20D_all=c(mean_SCS20D_all,mean_SCS20D) #SOM C % in top 20 cm layer
      mean_TSOC1_all=c(mean_TSOC1_all,mean_TSOC1) #TSOC1 
    }
   
    SIMGY <- 0 

    for(v in 1:length(plantgro)){
      plantgrdf2=as.data.frame(plantgro[[v]])
      SIMGY[v] <- tail(plantgrdf2$GWAD,n=1)
      Ave_GY <- mean(SIMGY)
    }
    
    if(i==1){
      GY_vec = Ave_GY
    }else{
      GY_vec = c(GY_vec,Ave_GY)
    }
    
    if(SIMGY[v] <= 0){
      print(paste("coming out from for loop where Crop failure growth program terminated"))
      break
    }
  }
  
  my.objects=cbind.data.frame(mean_SOCD_all)
  
  return(my.objects[,e])
}

out[[e]] <- sobolSalt(model = my.function, X1=S, X2=S1,scheme = "A",nboot = 100)

}


# #--------------run sobol sensitivity index--------

SobolGY <- sobolSalt(model = my.function, X1=S, X2=S1, scheme = "A",nboot = 100)
setwd("D:/ISmalia_DSSAT/co-inertia_analysis/Sobol_3_18")