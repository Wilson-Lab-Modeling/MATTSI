function c = SolTransFE2(D,vDohd,v,cBC1,cBC2,cold,dx,nnodes,dt,ntsteps,X)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% General form of the finite element approximation for the advection-
% dispersion equation AMW Feb 2009
% Final solution is Fc = G
% Governing equation is dc/dt = D*d^2c/dx^2 - v*dc/dx
%
% ARGUMENTS
% D is the dispersion coefficient (for solute transport)
% v is the average linear velocity (for solute transport)
% cBC1 is a vector containing the upper/lefthand boundary condition for each time
%      step, i.e. length(cBC1) = ntsteps = tmax/dt
% cBC2 is a vector containing the lower/righthand boundary condition for
%      each time step (same length as cBC1)
% cold is the initial condition
% dx, xmax, dt, tmax -- time and space domain + discretization

%theta: Crank-Nicholson = 0.5 (best); 0.0 = explicit; 1.0 = implicit
theta = 0.5;

nume = nnodes - 1;

Do = vDohd(1);
halfd = vDohd(2);

Dopt = 0;
if(Dopt == 0)
%set up the half depth for exponential version
    k = log(2)/halfd;
elseif(Dopt > 0)
    % Find out how deep to change Do
    kdum = round(dsearchn(X',halfd));
    %writeit = [kdum halfd]
    if (kdum>1)
        if(Dopt == 1)
            % constant with depth
            DoVec(1:kdum) = Do;
        else
            % linear decrease with depth
            for i=1:kdum
                DoVec(i) = Do*(kdum-i+1)/kdum;
            end
        end
        DoVec(kdum+1:nume) = 0;
    else
        DoVec(1:nume) = 0;
    end
end

% set up element data
depth = -dx(1)/2;
for j=1:nume
  ELID(j,1) = j;
  ELID(j,2) = j+1;
  if(Dopt == 0)
% for the exponential version
      depth = depth + dx(j)/2;
      disp(j) = D + Do*exp(-k*depth);
  else
      disp(j) = D + DoVec(j);
  end
end

A = zeros(nnodes,nnodes);
B = zeros(nnodes,nnodes);
for j=1:nume
    AE = disp(j)/dx(j)*[1 -1;-1 1] + v/2*[-1 1;-1 1];
    BE = (dx(j)/6)*[2 1;1 2];
    N1 = ELID(j,1);
    N2 = ELID(j,2);
    A(N1,N1) = A(N1,N1) + AE(1,1);
    A(N1,N2) = A(N1,N2) + AE(1,2);
    A(N2,N1) = A(N2,N1) + AE(2,1);
    A(N2,N2) = A(N2,N2) + AE(2,2);
    B(N1,N1) = B(N1,N1) + BE(1,1);
    B(N1,N2) = B(N1,N2) + BE(1,2);
    B(N2,N1) = B(N2,N1) + BE(2,1);
    B(N2,N2) = B(N2,N2) + BE(2,2);
end
    
% Set up the F matrix and parts of G that don't vary
% F = zeros(nnodes,nnodes);
F = theta*A + B/dt;
Gmat = -(1-theta)*A + B/dt;

% Boundary conditions
F(1,:) = 0.0;
F(1,1) = 1.0;
F(nnodes,:) = 0.0;          % lefthand boundary condition
F(nnodes,nnodes) = 1.0;     % lefthand boundary condition
% G(1:nnodes) = 0.0;

% TIME LOOP %
for k = 1:ntsteps
    G = Gmat*cold;
    G(1) = cBC1(k);
    G(nnodes) = cBC2(k);       % lefthand boundary condition
    
    % SOLVE
    c = linsolve(F,G);
    cold = c;
end
