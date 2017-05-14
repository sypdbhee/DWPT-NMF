function [Ws,Wn,BandStd]=SNMFTraining(InputPar,NoiseNum)

Wn         =cell(2^(InputPar.BandNum-1),NoiseNum);
IterErrCl  =cell(2^(InputPar.BandNum-1),NoiseNum);
Ws         =cell(2^(InputPar.BandNum-1),1);
IterErrNs  =cell(2^(InputPar.BandNum-1),1);

BandStd=zeros(1,2^(InputPar.BandNum-1));
DWTfun =InputPar.DWTfun;
InputPar.BasesNum=InputPar.BasesNumCl;

%%%%%%%%%%% Training
[CleanSubBandCell,OutClnSubNumVec]=SubBandProcess(InputPar.TrCleanData,InputPar.BandNum,InputPar.Wname,InputPar.FrameSize,InputPar.FrameRate,DWTfun);
for band_ind=1:2^(InputPar.BandNum-1)
    InputPar.TriData=CleanSubBandCell{band_ind,1}.^2;
    [Ws{band_ind,1},~,IterErrCl{band_ind,1}]=LSNMF_training(InputPar);
    switch lower(DWTfun)
        case 'dwt'
            Points=OutClnSubNumVec(band_ind);
        case 'dwpt'
            Points=OutClnSubNumVec(1);
    end
    BandStd(1,band_ind)=std(DataMatrix2Sequence(InputPar.TriData,InputPar.FrameRate,Points));
end
InputPar.BasesNum=InputPar.BasesNumNs;
for noty_ind=1:NoiseNum
    for band_ind=1:2^(InputPar.BandNum-1)
        [NoiseSubBandCell,OutNosSubNumVec]=SubBandProcess(InputPar.TrNoiseData{noty_ind},InputPar.BandNum,InputPar.Wname,InputPar.FrameSize,InputPar.FrameRate,DWTfun);
        
        InputPar.TriData=NoiseSubBandCell{band_ind,1}.^2;
        [Wn{band_ind,noty_ind},~,IterErrNs{band_ind,1}]=LSNMF_training(InputPar);
    end
end
%%%%%%%%%%% Training
