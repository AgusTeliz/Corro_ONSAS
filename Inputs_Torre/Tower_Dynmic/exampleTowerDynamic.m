%% Transimission Tower input
%
%%
clear all, close all
TorreOptimized  = 1; % one to omptimzed any alse to classic

if TorreOptimized == 1
  dirTowerGeometry  = [pwd '/../..\auxTowerGeometryOptimized'] ;
else
  dirTowerGeometry  = [pwd '/../..\auxCableGeometry']          ;
end


dirOnsas = [ pwd '\..\..\..\..\ONSAS\ONSAS' ]                   ;
dirFuerzaViento  = [pwd '/../..\Fuerza_Viento']              ; 

addpath (dirOnsas,dirTowerGeometry,dirFuerzaViento)          ;
% ======================================================================
%% Time
timeIncr  = 1   ;
finalTime = 1200 ;
%% General data

problemName = 'Dynamic_Tower' ;

Nodes = load('MatNodos.txt');
Num_nodes = size (Nodes,1);

Conec_elem = load('Conec_elem.txt');
Cambio_areas= load('Vec_sec.txt');
Conec_elem(:,4) = Cambio_areas;

Conec_Nod = load('Conec_Nod.txt');
Num_elem  = size(Conec_elem,1);

%Convert 2 cell
Conec_Nod_cell  = mat2cell(Conec_Nod,[ones(1,size(Conec_Nod,1))]);
Conec_elem_cell = mat2cell(Conec_elem,[ones(1,size(Conec_elem,1))]);
Conec           = [Conec_Nod_cell;Conec_elem_cell];
 

% ======================================================================
%% --- MELCS parameters ---
materialsParams = cell(1,1) ; % M
elementsParams  = cell(1,1) ; % E
loadsParams     = cell(1,1) ; % L
crossSecsParams = cell(1,1) ; % C
springsParams   = cell(1,1) ; % S

E = 210e9 ;  nu = 0.3 ;  rho = 7850 ;
						% 3 green 2 ing (tipo de deformacion unitaria)
materialsParams = {[ rho 3 E nu ]} ;

elementsParams = { 1; [ 2 1 ]} ; 

if TorreOptimized ==0
    A1 = 5100e-6;
    d1 = sqrt (4*A1/pi);
    A2 = 1790e-6;
    d2 = sqrt (4*A2/pi);
    A3 = 1790e-6;
    d3 = sqrt (4*A3/pi);
    A4 = 2270e-6;
    d4 = sqrt (4*A4/pi);
    A5 = 1790e-6;
    d5 = sqrt (4*A5/pi);
    A6 = 1790e-6;
    d6 = sqrt (4*A6/pi);
    A7 = 1790e-6;
    d7 = sqrt (4*A7/pi);
else
    %A1 A2 = A3  A4 A5=A6 A7
    A1 = 3480e-6;
    d1 = sqrt (4*A1/pi);
    A2 = 1140e-6;
    d2 = sqrt (4*A2/pi);
    A3 = A2;
    d3 = sqrt (4*A3/pi);
    A4 = 1710e-6;
    d4 = sqrt (4*A4/pi);
    A5 = 390e-6;
    d5 = sqrt (4*A5/pi);
    A6 = A5;
    d6 = sqrt (4*A6/pi);
    A7 = 903e-6;
    d7 = sqrt (4*A7/pi);
end

crossSecsParams = { [3 d1];[3 d2];[3 d3];[3 d4];[3 d5];[3 d6];[3 d7] } ;

springsParams = { [ inf  0  inf  0  inf   0 ]} ;


% ======================================================================
%% Method Params

%Static

controlDofs = [ 183 5 -1 ] ;

% analysis parameters
stopTolIts       = 30     ;
stopTolDeltau    = 1.0e-8 ;
stopTolForces    = 1.0e-8  ;

		
% Static
% targetLoadFactrNR  = 1e3    ;
% nLoadSteps         = 10     ;
% numericalMethodParams = [ 1 stopTolDeltau stopTolForces stopTolIts ...
%                              targetLoadFactrNR nLoadSteps ] ; 

%Dynamic
alphaHHT = -0.1 ;
numericalMethodParams = [ 4 timeIncr finalTime stopTolDeltau stopTolForces stopTolIts alphaHHT ] ;
% ======================================================================
%% Loads
booleanSelfWeightZ = 0 ;
loadsParams   = {[ 1 1   1 0 0 0 0 0 ]} ;
%compute Fviento
DensidadAire = 1.2   ;
C_d          = 3.4   ; 
Plot_ft      = 1     ;
factAmpVel   = 1     ;
Atotal       = 233.6 ;  
[F_t,v_sim]=Fuerza_Viento_Torre (timeIncr,finalTime, DensidadAire, C_d, Atotal,Num_nodes,Plot_ft,factAmpVel);

vmedia = mean(v_sim) ;

%Dampint
factorAmplDamping = 0.6;

 %nodalDispDamping = DensidadAire*C_d*dc*lc1/NelemC*vmedia/2  *  factorAmplDamping ;

Tinicio             = 0 ;
Tfinal              = finalTime;
loadFactorsFunc     = @(t) F_t(round(t/timeIncr)+1)*(t>Tinicio)*(t<Tfinal);

userLoadsFilename = 'myFuerzaZtorre'

%% Booleans
reportBoolean = 1 ;
storeBoolean = 1 ;
stabilityAnalysisBoolean = 0 ;

% ================================================================= 
%% Ploteo
plotParamsVector = [0 ];
plotParamsVector = [ 3 300 ]; sectPar = [ 12 .25 .25 ] ;
printFlag = 0 ;


ONSAS

