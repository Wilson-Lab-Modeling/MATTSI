function [vDohd,RMSEval] = TMinRMSE2(D,cBC1,cBC2,cold,T,dx,nnodes,dt,ntsteps,obsnodes,kstart,first_guess,lb,ub,v,X,logflag,FunctionTolerance,xTolerance)
% This function finds the best fit (smallest RMSE) for observed and simulated T data.
    options = optimset('Algorithm','interior-point','Display','none','TolX',xTolerance,'TolFun',FunctionTolerance);
    [vDohd,RMSEval,exitflag] = fmincon(@ErrVec,first_guess,[],[],[],[],lb,ub,{},options);
    %######################Nested Function ErrVec##################
    function [ev] = ErrVec(vDohd)

            c = SolTransFE2(D,vDohd,v,cBC1,cBC2,cold,dx,nnodes,dt,ntsteps,X);

        for kk=1:length(obsnodes)

            diff(kk) = c(obsnodes(kk)) - T(kstart+ntsteps,kk);  % if you are using the bottom water as a boundary condition

        end

        % The Root Mean Squared Error
        ev = sqrt(mean(diff.*diff));

    end  % fcn ErrVec

end  % fcn MinRMSE
