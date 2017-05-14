function OutSpchData=Wavelet2Time(InputEncData,InpSubInfo,bandNum,wname,DWTINDICATOR)

if nargin == 4; DWTINDICATOR='dwt';end;

switch lower(DWTINDICATOR)
    case 'dwt'
        IDWTCounter=[];
        for col_ind=1:bandNum
            TpCombData=InputEncData{col_ind,1}; %%%%%%%%%%%%%%%%%%
            IDWTCounter=[IDWTCounter TpCombData(1,1:InpSubInfo(1,col_ind))];
        end
    case 'dwpt'
        IDWTCounter=[];
        for col_ind=1:2^(bandNum-1)
            TpCombData=InputEncData{col_ind,1}; %%%%%%%%%%%%%%%%%%
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