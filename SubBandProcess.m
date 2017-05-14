function [OutCellMatrix,OutSubNumVec,MeanVarInfo]=SubBandProcess(input_data,bandNum,wname,frameSize,frameShift,DWTINDICATOR)

if nargin == 5; DWTINDICATOR='dwt';end
if size(input_data,1)~=1;InData=input_data';else InData=input_data;end

OutSubNumVec=zeros(1,bandNum);
MeanVarInfo.Mean=zeros(bandNum,1);
MeanVarInfo.Vari=zeros(bandNum,1);

switch lower(DWTINDICATOR)
    case 'dwt'
        OutCellMatrix=cell(bandNum,1);
        
        [sub_band,e_sb_len]=wavedec(InData,bandNum-1,wname);
    case 'dwpt'
        OutCellMatrix=cell(2^(bandNum-1),1);
        
        [sub_band,e_sb_len]=DWPTDec(InData,bandNum-1,wname);
        bandNum=length(sub_band)/e_sb_len(1,1);
end

fram_shift=frameShift;frame_Size=frameSize;
for col_ind=1:bandNum
    
    switch lower(DWTINDICATOR)
        case 'dwt'
            to_pot=sum(e_sb_len(1:col_ind));
            from_pot=to_pot-e_sb_len(1,col_ind)+1;
            
            points=to_pot-from_pot+1;
        case 'dwpt'
            to_pot=e_sb_len(1,1)*col_ind;
            from_pot=to_pot-e_sb_len(1,1)+1;
            
            points=e_sb_len(1,1);
    end
    
    if fram_shift~=0;frames=floor(ceil((points-frame_Size)/fram_shift)+1);else frames=1;end
    if frames<= 0;frames=1;end
    
    MeanVarInfo.Mean(col_ind)=mean(sub_band(from_pot:to_pot));
    MeanVarInfo.Vari(col_ind)=std(sub_band(from_pot:to_pot));
    
    OutCellMatrix{col_ind,1}=zeros(frame_Size,frames);
    for this_frame=1:frames-1
        begin_point=(this_frame-1)*fram_shift+1;
        end_point=begin_point+frame_Size-1;
        
        OutCellMatrix{col_ind,1}(:,this_frame)=sub_band(from_pot+begin_point-1:from_pot+end_point-1)';
    end
    begin_point=(frames-1)*fram_shift+1;
    OutCellMatrix{col_ind,1}(1:points-begin_point+1,frames)=sub_band(1,from_pot+begin_point-1:to_pot)';
    
end
OutSubNumVec=e_sb_len;


function [sub_band,e_sb_len]=DWPTDec(InputData,CutNum,wname)

e_sb_len=length(InputData);
[CA,CD]=dwt(InputData,wname);
if CutNum == 1
    sub_band=[CA,CD];
    e_sb_len=[length(CA),e_sb_len];
else if CutNum == 0
        sub_band=InputData;
    else
        [NCA,sb_len]=DWPTDec(CA,CutNum-1,wname);
        e_sb_len=[sb_len,e_sb_len];
        NCD         =DWPTDec(CD,CutNum-1,wname);
        sub_band=[NCA,NCD];
    end
end