% close all;fclose all;clear all;clc;

warning off

fs=8000;

%%
%
OutFolder='./DATA/Enhanced';
OutPerfFd='./DATA/performanceout';
OutCleFold=sprintf('%s/ProcClean',OutFolder);mkdir(OutCleFold);
OutNoyFold=sprintf('%s/ProcNoisy',OutFolder);mkdir(OutNoyFold);
OutEClFold=sprintf('%s/EnhancedClean',OutFolder);mkdir(OutEClFold);
OutENsFold=sprintf('%s/EnhancedNoise',OutFolder);mkdir(OutENsFold);

TrNoiseType   ={'Subway';'Exhibition';'Car';'Street'};
TsNoiseType   ={'Subway';'Exhibition';'Car';'Street';'Restaurant';'Babble';'Airport';'Train'};
TsNoisesnr    =[-5,0,5,10,15,20];

TriClnFileStart=51;TriClnFilTolNum=10;

% BandNum=1:10;
BandNum         = 4;
InputPar.DWTfun ='dwpt';

%%%%%%  Normal Setting
InputPar.FrameSize =1000;
InputPar.FrameRate =20;
InputPar.FFTSize   =256;
InputPar.PowIndex  =2; % 2:power, 1:magnitude
InputPar.Wname     ='db10';

%%%%%%  NMF Setting
InputPar.BasesNumNs  =40;
InputPar.BasesNumCl  =40;
InputPar.ErrThres    =1E-7;
InputPar.IterNum     =200;

Folder   = sprintf('MHINTNMF_NormalRateStd_TrC%s_%s_%s_Frs%s_FrR%s_Bs%s_Bn%s_BandNum_'...
    ,num2str(TriClnFilTolNum),InputPar.DWTfun,InputPar.Wname,num2str(InputPar.FrameSize)...
    ,num2str(InputPar.FrameRate),num2str(InputPar.BasesNumCl),num2str(InputPar.BasesNumNs));

FolderFT = sprintf('MHINTNMF_STFT_NormalRateStd_TrC%s_%s_%s_Frs%s_FrR%s_Bs%s_Bn%s_BandNum_'...
    ,num2str(TriClnFilTolNum),InputPar.DWTfun,InputPar.Wname,num2str(InputPar.FrameSize)...
    ,num2str(InputPar.FrameRate),num2str(InputPar.BasesNumCl),num2str(InputPar.BasesNumNs));


%%%%%%% Preparing sound file
InpClFolder  ='./DATA/train/clean';TrCleanData=[];file_list=dir(InpClFolder);
InpNeFolder  ='./DATA/noise/';TrNoiseData=cell(length(TrNoiseType),1);
InpNyFolder  ='./DATA/Test/';TsNoisyData=cell(length(TsNoiseType),length(TsNoisesnr),50);
InpTsClFolder='./DATA/Test/clean';TsCleanData=cell(50,1);
for fil_ind=TriClnFileStart+2:TriClnFileStart+TriClnFilTolNum+2
    file_name=sprintf('%s/%s',InpClFolder,file_list(fil_ind).name);
    x=audioread(file_name);
    TrCleanData=[TrCleanData (x-mean(x))'/std(x)];
end
for noty_ind=1:length(TrNoiseType)
    InpNsFile=sprintf('%s%s.raw',InpNeFolder,lower(TrNoiseType{noty_ind}));
    noise_fid=fopen(InpNsFile,'r','b');
    x=fread(noise_fid,'short');
    TrNoiseData{noty_ind}=x'/std(x);
    fclose(noise_fid);
end
for tsnoty_ind=1:length(TsNoiseType)
    for notsnr_ind=1:length(TsNoisesnr)
        InpTsNyFolder=sprintf('%s%s/%sdb/',InpNyFolder,lower(TsNoiseType{tsnoty_ind}),lower(num2str(TsNoisesnr(notsnr_ind))));
        file_list=dir(InpTsNyFolder);
        for fil_ind=3:length(file_list)
            file_name=sprintf('%s/%s',InpTsNyFolder,file_list(fil_ind).name);
            x=audioread(file_name);
            TsNoisyData{tsnoty_ind,notsnr_ind,fil_ind-2}=[x(InputPar.FrameSize:-1:2)',(x-mean(x))'/std(x),x(end-1:-1:end-InputPar.FrameSize)'];
        end
    end
end
file_list=dir(InpTsClFolder);
for fil_ind=3:length(file_list)
    file_name=sprintf('%s/%s',InpTsClFolder,file_list(fil_ind).name);
    x=audioread(file_name);
    TsCleanData{fil_ind-2,1}=[x(InputPar.FrameSize:-1:2)',(x-mean(x))'/std(x),x(end-1:-1:InputPar.FrameSize)'];
end

InputPar.TrCleanData=TrCleanData;
InputPar.TrNoiseData=TrNoiseData;
InputPar.TsNoisyData=TsNoisyData;

clear TrCleanData TrNoiseData TsNoisyData;

for bd_ind=1:length(BandNum)

    InputPar.BandNum=BandNum(bd_ind);
    InputPar.IterNum=200;

    NoiyFolderName=sprintf('%s%s_Rate',Folder,num2str(2^(InputPar.BandNum-1)));
    RateFolderName=sprintf('%s%s_Rate',Folder,num2str(2^(InputPar.BandNum-1)));
    mkdir(sprintf('%s/%s',OutEClFold,RateFolderName));

    IterErr    =cell(2^(InputPar.BandNum-1),length(TrNoiseType),50,2^(InputPar.BandNum-1));

    %%%%%%%%%%% Training
    NoiseNum=length(TrNoiseType);
    [Ws,Wn,BandStd]=SNMFTraining(InputPar,NoiseNum);
    %%%%%%%%%%% Training

    %%%%%%%%%%% Testing
    InputPar.IterNum=50;

    %%% Clean No NMF
    for fil_ind=1:length(TsCleanData)
        [CleanSubBandCell,OutClnSubNumVec,CleanSubBandCellOrg]=SubBandProcess(TsCleanData{fil_ind,1},InputPar.BandNum,InputPar.Wname,InputPar.FrameSize,InputPar.FrameRate,InputPar.DWTfun);
        ProcClWav=WaveletCell2Time(CleanSubBandCell,OutClnSubNumVec,InputPar.BandNum,InputPar.FrameRate,InputPar.Wname,InputPar.DWTfun);
        audiowrite(sprintf('%s/%s',OutCleFold,file_list(fil_ind+2).name),ProcClWav(InputPar.FrameSize:end-InputPar.FrameSize)/50,fs);
    end

    %%% Noisy
    for tsnoty_ind=1:length(TsNoiseType)
        for notsnr_ind=1:length(TsNoisesnr)
            fprintf('Noise Type: %s,%s; SNR:%s\n',num2str(tsnoty_ind),TsNoiseType{tsnoty_ind},num2str(TsNoisesnr(notsnr_ind)));
            mkdir(sprintf('%s/%s/%s/%sdB',OutEClFold,RateFolderName,TsNoiseType{tsnoty_ind},num2str(TsNoisesnr(notsnr_ind))));
            mkdir(sprintf('%s/%s/%s/%sdB',OutNoyFold,RateFolderName,TsNoiseType{tsnoty_ind},num2str(TsNoisesnr(notsnr_ind))));
            
            filenum=50;
            for file_ind=1:filenum
                TsNiyData=InputPar.TsNoisyData{tsnoty_ind,notsnr_ind,file_ind};
                [NoisySubBandCell,OutNiySubNumVec,NoisySubBandCellOrg]=SubBandProcess(TsNiyData,InputPar.BandNum,InputPar.Wname,InputPar.FrameSize,InputPar.FrameRate,InputPar.DWTfun);
                OutWavCellMatrix_Rate=cell(2^(InputPar.BandNum-1),1);OutNosCellMatrix_Rate=cell(2^(InputPar.BandNum-1),1);
                WavRate=[];NosRate=[];
                for band_ind=1:2^(InputPar.BandNum-1)
                    W=[];W=[W,Ws{band_ind,1}];
                    for noty_ind=1:length(TrNoiseType)
                        W=[W,Wn{band_ind,noty_ind}];
                    end
                    InputPar.TesData=NoisySubBandCell{band_ind,1}.^2;
                    [~,HCell{band_ind,1},IterErr{tsnoty_ind,notsnr_ind,file_ind,band_ind}]=LSNMF_testing(InputPar,W);RateDen=[];RateN=[];
                    RateDen=sqrt(Ws{band_ind,1}*HCell{band_ind,1}(1:InputPar.BasesNumCl,:));RateN=RateDen;
                    for noty_ind=1:length(TrNoiseType)
                        RateDen=RateDen+sqrt(Wn{band_ind,noty_ind}*HCell{band_ind,1}(InputPar.BasesNumNs*(noty_ind-1)+1:InputPar.BasesNumNs*noty_ind,:));
                    end
                    WavRate=(RateN./RateDen);NosRate=1-WavRate;

                    switch lower(InputPar.DWTfun)
                        case 'dwt'
                            Points=OutNiySubNumVec(band_ind);
                        case 'dwpt'
                            Points=OutNiySubNumVec(1);
                    end
                    OutputData=[];OutputData=DataMatrix2Sequence(NoisySubBandCell{band_ind,1},InputPar.FrameRate,Points).*DataMatrix2Sequence(WavRate,InputPar.FrameRate,Points);
                    OutWavCellMatrix_Rate{band_ind,1}=OutputData/std(OutputData)*BandStd(band_ind);
                end

                EnhcClWav=Wavelet2Time(OutWavCellMatrix_Rate,OutNiySubNumVec,InputPar.BandNum,InputPar.Wname,InputPar.DWTfun);OEnhcClWav=[];
                OEnhcClWav=EnhcClWav(InputPar.FrameSize:end-InputPar.FrameSize)/std(EnhcClWav(InputPar.FrameSize:end-InputPar.FrameSize))*std(TsNiyData(InputPar.FrameSize:end-InputPar.FrameSize));

                audiowrite(sprintf('%s/%s/%s/%sdB/%s',OutEClFold,RateFolderName,TsNoiseType{tsnoty_ind},num2str(TsNoisesnr(notsnr_ind)),file_list(file_ind+2).name),OEnhcClWav/50,fs);

                EnhcNyWav=WaveletCell2Time(NoisySubBandCell,OutNiySubNumVec,InputPar.BandNum,InputPar.FrameRate,InputPar.Wname,InputPar.DWTfun);
                OEnhcNyWav=EnhcNyWav(InputPar.FrameSize:end-InputPar.FrameSize);

                audiowrite(sprintf('%s/%s/%s/%sdB/%s',OutNoyFold,RateFolderName,TsNoiseType{tsnoty_ind},num2str(TsNoisesnr(notsnr_ind)),file_list(file_ind+2).name),OEnhcNyWav/50,fs);

            end           
        end
    end  
end
