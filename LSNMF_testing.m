function [OutWav,H,IterErr]=LSNMF_testing(InputPar,W)

input_data=InputPar.TesData;

basesNum=size(W,2);
errthres=InputPar.ErrThres;
maxiter=InputPar.IterNum;

[dim,frames]=size(input_data);

%%

H=rand(basesNum,frames);

%%

iter_ind=1;IterErr(iter_ind)=sum(sum((input_data-W*H).^2))/(dim*frames);
while (iter_ind <= maxiter+1) && (IterErr(iter_ind) >= errthres)
    % while (IterErr(iter_ind) >= errthres)
    
    if ~mod(iter_ind,100) ;fprintf('IterNum: %05s; Err: %.5d\n',num2str(iter_ind),IterErr(iter_ind));end;
    
    iter_ind=iter_ind+1;
    
    H=H.*((W'*input_data)./(W'*(W*H)));
    
    IterErr(iter_ind)=sum(sum((input_data-W*H).^2))/(dim*frames);
end

OutWav=W*H;