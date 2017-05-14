function OutputData=DataMatrix2Sequence(InputData,FrameShift,Points)

OutputData=zeros(1,Points);
frameShift=FrameShift;

BandData=InputData;

[FrameSize,frames]=size(BandData);

TpCombData=zeros(1,FrameSize);TpCombData=BandData(:,1)';
TpCombData=[TpCombData,zeros(1,frameShift)];
for this_frames=2:frames-1
    end_point=length(TpCombData);start_point=end_point-FrameSize+1;
    TpCombData(1,start_point:end_point)=TpCombData(1,start_point:end_point)+BandData(:,this_frames)';
    TpCombData=[TpCombData,zeros(1,frameShift)];
end
if frames > 2; this_frames=this_frames+1; else if frames == 2; this_frames=2;else this_frames=1;end;  end;
end_point=length(TpCombData);start_point=end_point-FrameSize+1;
TpCombData(1,start_point:end_point)=TpCombData(1,start_point:end_point)+BandData(:,this_frames)';
if frameShift == 0;
    TpCombData=TpCombData/2;
end
OutputData=TpCombData(1,1:Points);
