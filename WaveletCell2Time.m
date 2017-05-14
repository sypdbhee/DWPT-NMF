function OutSpchData=WaveletCell2Time(InputEncData,InpSubInfo,bandNum,FrameShift,wname,DWTINDICATOR)

if nargin == 5; DWTINDICATOR='dwt';end;

switch lower(DWTINDICATOR)
    case 'dwt'
        IDWTCounter=[];
        for col_ind=1:bandNum
            Points=InpSubInfo(col_ind);frameShift=FrameShift;
            TpCombData=DataMatrix2Sequence(InputEncData{col_ind,1},frameShift,Points);
            IDWTCounter=[IDWTCounter TpCombData(1,1:InpSubInfo(1,col_ind))];
        end
    case 'dwpt'
        IDWTCounter=[];frameShift=FrameShift;
        for col_ind=1:2^(bandNum-1)
            Points=InpSubInfo(1);
            TpCombData=DataMatrix2Sequence(InputEncData{col_ind,1},frameShift,Points);
            IDWTCounter=[IDWTCounter TpCombData(1,1:InpSubInfo(1,1))];
        end
end
OutSpchData=DWPTRec(IDWTCounter,InpSubInfo,wname);


function RecData=DWPTRec(InputData,InpSubInfo,wname)

CA=InputData(1:(length(InputData)/2));CD=InputData((length(InputData)/2+1):end);
if length(InpSubInfo) > 2
    RCA=DWPTRec(CA,InpSubInfo(1:end-1),wname);
    RCD=DWPTRec(CD,InpSubInfo(1:end-1),wname);
    RecData=idwt(RCA,RCD,wname,InpSubInfo(1,end));
else if length(InpSubInfo) == 2
        RecData=idwt(CA,CD,wname,InpSubInfo(1,2));
    else
        RecData=InputData;
    end
end



% BandData=zeros(size(InputEncData{col_ind,1}));
% BandData=InputEncData{col_ind,1};
% 
% [FrameSize,frames]=size(BandData);
% 
% frameShift=ceil(FrameShift/2^(col_ind-1));
% frameShift=FrameShift;
% 
% TpCombData=zeros(1,FrameSize);TpCombData=BandData(:,1)';
% TpCombData=[TpCombData,zeros(1,frameShift)];
% for this_frames=2:frames-1
%     end_point=length(TpCombData);start_point=end_point-FrameSize+1;
%     TpCombData(1,start_point:end_point)=TpCombData(1,start_point:end_point)+BandData(:,this_frames)';
%     TpCombData=[TpCombData,zeros(1,frameShift)];
% end
% if frames > 2; this_frames=this_frames+1; else if frames == 2; this_frames=2;else this_frames=1;end;  end;
% end_point=length(TpCombData);start_point=end_point-FrameSize+1;
% TpCombData(1,start_point:end_point)=TpCombData(1,start_point:end_point)+BandData(:,this_frames)';
% if frameShift == 0;
%     TpCombData=TpCombData/2;
% end
% 
% BandData=zeros(size(InputEncData{col_ind,1}));
% BandData=InputEncData{col_ind,1};
% 
% [FrameSize,frames]=size(BandData);
% 
% TpCombData=zeros(1,FrameSize);TpCombData=BandData(:,1)';
% TpCombData=[TpCombData,zeros(1,frameShift)];
% for this_frames=2:frames-1
%     end_point=length(TpCombData);start_point=end_point-FrameSize+1;
%     TpCombData(1,start_point:end_point)=TpCombData(1,start_point:end_point)+BandData(:,this_frames)';
%     TpCombData=[TpCombData,zeros(1,frameShift)];
% end
% if frames > 2; this_frames=this_frames+1; else if frames == 2; this_frames=2;else this_frames=1;end;  end;
% end_point=length(TpCombData);start_point=end_point-FrameSize+1;
% TpCombData(1,start_point:end_point)=TpCombData(1,start_point:end_point)+BandData(:,this_frames)';
% if frameShift == 0;
%     TpCombData=TpCombData/2;
% end