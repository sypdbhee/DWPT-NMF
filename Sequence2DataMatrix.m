function OutputData=Sequence2DataMatrix(InputData,FrameSize,FrameShift)

fram_shift=FrameShift;frame_Size=FrameSize;

points=length(InputData);
if fram_shift ~= 0;frames=floor(ceil((points-frame_Size)/fram_shift)+1);else frames=1;end;
if frames <= 0; frames=1;end;

OutputData=zeros(frame_Size,frames);
for this_frame=1:frames-1;
    begin_point=(this_frame-1)*fram_shift+1;
    end_point=begin_point+frame_Size-1;
    
    OutputData(:,this_frame)=InputData(1,begin_point:end_point)';
end
begin_point=(frames-1)*fram_shift+1;
end_point=length(InputData);
OutputData(1:end_point-begin_point+1,frames)=InputData(1,begin_point:end_point)';