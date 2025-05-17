% Code showing the exemplary process of generating training data, training
% UTIRnet and reconstructing holograms with UTIRnet without twin-image
% 
% Code is divided into sections, each one designed to present a separate 
% part of the UTIRnet creation and use process. Run this sections
% separately, as some of them may last a long time (expecially network
% training part). "##########" - this sign indicates that the marked line
% may be (or should be) changed to make the network work for an individual
% user.
% 
% Cite as:   
%   M. Rogalski, P. Arcab, L. Stanaszek, V. Micó, C. Zuo and M. Trusiak, 
%   "Physics-driven universal twin-image removal network for digital 
%   in-line holographic microscopy". Submitted 2023 
% 
% Created by:
%   Mikołaj Rogalski,
%   mikolaj.rogalski.dokt@pw.edu.pl
%   Institute of Micromechanics and Photonics,
%   Warsaw University of Technology, 02-525 Warsaw, Poland
%
% Last modified: 01.06.2023

%% Dataset generation
clear; close all; clc

% System parameters ##########################
% Z = 2600; % camera-sample distance (um)  ###########################
% Z = 17000; % ###################
lambda = 0.405; % light source wavelength (um) ###############
dx = 2.4; % pixel size in object plane (cam_pix_size / mag) (um) ##########
Z=4740; %Wilkowiecka_Z for USAFphs
% Path to the directory containing flower recognition dataset (it should
% contain 5 subdirectories with images of different flowers).
% Can be downloaded at: 
% https://www.kaggle.com/datasets/alxmamaev/flowers-recognition
% Alternatively images from other repositories may be applied
pth = 'C:\Users\110_F\Desktop\Wilkowiecka_Miloslawa\Holos\archive\flowers'; % ###############
M=[5,20]; %number of grayscale colors 
% Training dataset
[inTrAmp,tarTrAmp,holosTrAmp] = GenerateDataset(pth,[1,4,5],650,Z,...
    lambda,dx,'amp',M); % for CNN_A
[inTrPhs,tarTrPhs,holosTrPhs] = GenerateDataset(pth,[1,4,5],650,Z,...
    lambda,dx,'phs',M); % for CNN_P
%% 

% Validation dataset
[inValAmp,tarValAmp,holosValAmp] = GenerateDataset(pth,[2,3],50,Z,...
    lambda,dx,'amp',M); % for CNN_A
[inValPhs,tarValPhs,holosValPhs] = GenerateDataset(pth,[2,3],50,Z,...
    lambda,dx,'phs',M); % for CNN_P

% Optionally you can save created datasets for later use ###############
%% Network training
% Generate dataset as in "Dataset generation" section or load previously 
% generated dataset ################################

% Load network architecture (for 512x512 px image size)
load('NetworkArchitecture.mat')

% Number of input images
imgN = size(inTrAmp,4); 

% Train CNN_A
CNN_A_info = trainingOptions('adam', ...
    'MiniBatchSize',1, ...
    'MaxEpochs',1,...  
    'LearnRateDropPeriod',5,... 
    'LearnRateDropFactor',0.5,...
    'LearnRateSchedule','piecewise',...
    'InitialLearnRate',1e-4, ... 
    'Shuffle','every-epoch',...
    'Plots','training-progress',...
    'ValidationData',{(inValAmp), (tarValAmp)},...
    'ValidationFrequency', imgN);

% [CNN_A,info_A] = trainNetwork(inTrAmp, tarTrAmp, lgraph, CNN_A_info);
CNN_A=[];
info_A=[];
CNN_A_info.ValidationData = [];


% Train CNN_P
CNN_P_info = trainingOptions('adam', ...
    'MiniBatchSize',1, ...
    'MaxEpochs',30,...  
    'LearnRateDropPeriod',5,... 
    'LearnRateDropFactor',0.5,...
    'LearnRateSchedule','piecewise',...
    'InitialLearnRate',1e-4, ... 
    'Shuffle','every-epoch',...
    'Plots','training-progress',...
    'ValidationData',{(inValPhs), (tarValPhs)},...
    'ValidationFrequency', imgN);

[CNN_P,info_P] = trainNetwork(inTrPhs, tarTrPhs, lgraph, CNN_P_info);
% CNN_P=[];
% info_P=[];
CNN_P_info.ValidationData = [];
%% 

% System parameters
UTIRnet_info.Z_mm = Z/1000;
UTIRnet_info.lambda_um = lambda;
UTIRnet_info.dx_um = dx;
%% 

% Save network
fnm = ['UTIRnet_my_Z-',num2str(Z/1000),'mm_dx-',num2str(dx),'um_lambda-',...
    num2str(lambda*1000),'nm_M-',num2str(M),'.mat'];
save(fnm,'CNN_A','CNN_P','CNN_A_info','CNN_P_info','UTIRnet_info')

%% Network testing - on validation data
% Train network as in "Network training" section or load previously 
% trained network ################################
% Generate validation dataset as in "Dataset generation" section or load 
% previously generated dataset ################################

% System parameters (ensure that are the same as used for network training)
% Z = 2600; % camera-sample distance (um)  ###########################
% Z = 17000; % ###################
lambda = 0.405; % light source wavelength (um) ###############
dx = 2.4; % pixel size in object plane (cam_pix_size / mag) (um) ##########
M=[5,20];
imNo = 7; % image number ################################
AmpPhs = 2; % 1 - amplitude data, 2 - phase data ##########################

if AmpPhs == 1
        Z= 2680;
        GT = tarValAmp(:,:,imNo);       % ground truth amplitude
        holo = holosValAmp(:,:,imNo);   % hologram amplitude
    elseif AmpPhs == 2
        Z= 4740;
        GT = tarValPhs(:,:,imNo);       % ground truth phase
        holo = holosValPhs(:,:,imNo);   % hologram phase
end

ps = 256; % pad size
holoP = padarray(holo,[ps,ps],'replicate'); % hologram padding

% reconstruction
[Yout,Yamp,Yphs,Uout] = UTIRnetReconstruction(holoP,...
    CNN_A,CNN_P,Z,lambda,dx,[],0);

% remove padding
Yout = Yout(ps+1:end-ps,ps+1:end-ps);
Uout = Uout(ps+1:end-ps,ps+1:end-ps);
Yamp = Yamp(ps+1:end-ps,ps+1:end-ps);
Yphs = Yphs(ps+1:end-ps,ps+1:end-ps);

% display results
close all
ax = [];
if AmpPhs == 1
    rng = [0,1.1];
    figure; imagesc(abs(Uout),rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('input AS amplitude (with twin-image)')
    figure; imagesc(abs(Yamp),rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('UTIRnet amplitude reconstruction')
    figure; imagesc(GT,rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('Ground truth amplitrude (without twin-image)') 
elseif AmpPhs == 2
    rng = [-pi,pi];
    figure; imagesc(angle(Uout),rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('input AS phase (with twin-image)')
    figure; imagesc(Yphs,rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('UTIRnet reconstruction')
    figure; imagesc(GT-pi,rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('Ground truth (without twin-image)')
end
linkaxes(ax)

% save results for single image
if AmpPhs==1
    fnm=['Yamp_my_Z-',num2str(Z/1000),'mm_dx-',num2str(dx),'um_lambda-',...
    num2str(lambda*1000),'nm_M-',num2str(M),'.mat'];
    save(fnm,"Yamp")
elseif AmpPhs==2
    fnm=['Yphs_my_Z-',num2str(Z/1000),'mm_dx-',num2str(dx),'um_lambda-',...
    num2str(lambda*1000),'nm_M-',num2str(M),'.mat'];
    save(fnm,"Yphs")
end

close all
if AmpPhs == 1
    % Amp data
    Z= 2680;
    Yamp_rmse=zeros(1,size(tarValAmp,4));
    h=figure;
    for ii=1:size(tarValAmp,4)
        GT=tarValAmp(:,:,ii);% ground truth target image
        holo=holosValAmp(:,:,ii);% hologram
        ps = 256; % pad size
        holoP = padarray(holo,[ps,ps],'replicate'); % hologram padding
        [~,Yamp,~,~]=UTIRnetReconstruction(holoP,...
        CNN_A,CNN_P,Z,lambda,dx,[],0);
        Yamp = Yamp(ps+1:end-ps,ps+1:end-ps);
        Yamp_rmse(ii)=rmse(GT(:),Yamp(:));

        figure(h); clf;
        subplot(1,2,1); imagesc(Yamp); colormap gray;
        axis image; colorbar; title('UTIRnet reconstruction')
        subplot(1,2,2); imagesc(GT); colormap gray;
        axis image; colorbar; title('Ground truth')
        waitforbuttonpress;
    end
    fnm="RMSE2_"+fnm;
    save(fnm,"Yamp_rmse")

elseif AmpPhs == 2
    % Phs data
    Z= 4740;
    Yphs_rmse=zeros(1,size(tarValPhs,4));
    rng = [-pi,pi];
    h=figure;
    for ii=1:size(tarValPhs,4)
        GT=tarValPhs(:,:,ii)-pi;% ground truth target image - pi
        % GT=tarValPhs(:,:,ii);% ground truth target image no diff
        holo=holosValPhs(:,:,ii);% hologram
        ps = 256; % pad size
        holoP = padarray(holo,[ps,ps],'replicate'); % hologram padding
        [~,~,Yphs,~]=UTIRnetReconstruction(holoP,...
        CNN_A,CNN_P,Z,lambda,dx,[],0);
        Yphs = Yphs(ps+1:end-ps,ps+1:end-ps);
        Yphs_rmse(ii)=rmse((GT(:)),Yphs(:));

        figure(h); clf;
        subplot(1,2,1); imagesc(Yphs,rng); colormap gray;
        axis image; colorbar; title(sprintf('UTIRnet reconstruction | RMSE: %.4f | Img #%d', Yphs_rmse(ii), ii))
        subplot(1,2,2); imagesc(GT,rng); colormap gray;
        axis image; colorbar; title('Ground truth (without twin-image)')
        waitforbuttonpress;
    end
    fnm="RMSE2_"+fnm;
    save(fnm,"Yphs_rmse")
end
%% Network testing - generating and reconstructing synth data
% Train network as in "Network training" section or load previously 
% trained network ################################
% System parameters (ensure that are the same as used for network training)
% Z = 2600; % camera-sample distance (um)  ###########################
% Z = 17000; % ###################
lambda = 0.405; % light source wavelength (um) ###############
dx = 2.4; % pixel size in object plane (cam_pix_size / mag) (um) ##########

AmpPhs = 2; % 1 - amplitude data, 2 - phase data ##########################
Z= 4740;%Wilkowiecka_Z for USAFamp

% Read any image #################################### 
% img = imread('cameraman.tif');
% img = double(imread('coins.png'));
img = double(imread('rice.png'));

if AmpPhs == 1
    [input,GT,holo] = GenerateHologram(img,Z,lambda,dx,'amp',M,1);
elseif AmpPhs == 2
    [input,GT,holo] = GenerateHologram(img,Z,lambda,dx,'phs',M,1);
end

ps = 256; % pad size
holoP = padarray(holo,[ps,ps],'replicate'); % hologram padding

% reconstruction
[Yout,Yamp,Yphs,Uout] = UTIRnetReconstruction(holoP,...
    CNN_A,CNN_P,Z,lambda,dx,[],0);
% remove padding
Yout = Yout(ps+1:end-ps,ps+1:end-ps);
Uout = Uout(ps+1:end-ps,ps+1:end-ps);
Yamp = Yamp(ps+1:end-ps,ps+1:end-ps);
Yphs = Yphs(ps+1:end-ps,ps+1:end-ps);

% display results
close all
ax = [];
if AmpPhs == 1
    rng = [0,1.1];
    figure; imagesc(abs(Uout),rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('input AS amplitude (with twin-image)')
    figure; imagesc(abs(Yout),rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('UTIRnet amplitude reconstruction')
    figure; imagesc(GT,rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('Ground truth amplitrude (without twin-image)') 
elseif AmpPhs == 2
    rng = [-pi,pi];
    figure; imagesc(angle(Uout),rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('input AS phase (with twin-image)')
    figure; imagesc(angle(Yout),rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('UTIRnet reconstruction')
    figure; imagesc(GT-pi,rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('Ground truth (without twin-image)')
end
linkaxes(ax)
%% Network testing - experimental data
clear; close all; clc

m1 = 1;

% load hologram data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('.\Holos\USAF phsv2\LPB20\USAF-1.mat')
% load('.\Holograms\CustomPhsTest_2.64mm.mat'); m1 = -1;
% load('.\Holograms\GlialCells_15.14mm.mat')
% load('.\Holograms\USAFamp_2.72mm.mat');
% load('.\Holograms\USAFamp_17.09mm.mat');
% load('.\Holograms\USAFampSynthetic_2.72mm.mat');
% load('.\Holograms\USAFampSynthetic_17.09mm.mat');
holo=double(u);
[rows,cols]=size(holo);


% load network trained for propper system parameters %%%%%%%%%%%%%%%%%%%%%%
% % load('.\Networks\UTIRnet_Z-2.6mm_dx-2.4um_lambda-405nm.mat')
% path='C:\Users\110_F\Desktop\Wilkowiecka_Miloslawa\Networks\UTIRnet_my_Z-2.68mm_dx-2.4um_lambda-405nm_M-5_plain.mat';
% path=('C:\Users\110_F\Desktop\Wilkowiecka_Miloslawa\Networks\UTIRnet_my_Z-2.68mm_dx-2.4um_lambda-405nm_M-20_plain.mat')
% path=('C:\Users\110_F\Desktop\Wilkowiecka_Miloslawa\Networks\UTIRnet_my_Z-2.68mm_dx-2.4um_lambda-405nm_M-5.mat')
% path=('C:\Users\110_F\Desktop\Wilkowiecka_Miloslawa\Networks\UTIRnet_my_Z-2.68mm_dx-2.4um_lambda-405nm_M-20.mat')
path=('C:\Users\110_F\Desktop\Wilkowiecka_Miloslawa\UTIRnet_my_Z-4.74mm_dx-2.4um_lambda-405nm_M-20.mat');
[~,name,ext]=fileparts(path);
load(path);

lambda = 0.405; % light source wavelength (um) ###############
dx = 2.4; % pixel size in object plane (cam_pix_size / mag) (um) ##########
AmpPhs = 2; % 1 - amplitude data, 2 - phase data ##########################
Z= 4740;%Wilkowiecka_Z for USAFamp

% reconstruction
[Yout,Yamp,Yphs,Uout] = UTIRnetReconstruction(double(holo),...
    CNN_A,CNN_P,Z,lambda,dx,m1,1);

% displaying
ax = [];
rng = [min(abs(Uout(:))),max(abs(Uout(:)))];
figure; imagesc(abs(Uout),rng); ax = [ax,gca]; colormap gray;
axis image; colorbar; title('AS amplitude (with twin-image)')
figure; imagesc(abs(Yamp),rng); ax = [ax,gca]; colormap gray;
axis image; colorbar; title('UTIRnet amplitude reconstruction')
if exist('GS','var')
    figure; imagesc(abs(GS),rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('Reference GS amplitrude')
    figure; imagesc(abs(GS_CFF),rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('Referenmce GS+CFF amplitrude')
end
if exist('GroundTruth','var')
    figure; imagesc(GroundTruth,rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('Ground truth amplitude')
end
rng = [-pi,pi];
figure; imagesc(angle(Uout),rng); ax = [ax,gca]; colormap gray;
axis image; colorbar; title('AS phase (with twin-image)')
figure; imagesc(angle(Yout),rng); ax = [ax,gca]; colormap gray;
axis image; colorbar; title('UTIRnet phase reconstruction')
if exist('GS','var')
    figure; imagesc(angle(GS),rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('Reference GS phase')
    figure; imagesc(angle(GS_CFF),rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('Reference GS+CFF phase')
end

linkaxes(ax)

%% rmse comparison
load('RMSE_Yamp_my_Z-2.68mm_dx-2.4um_lambda-405nm_M-.mat')
RMSEamp_0=Yamp_rmse;
load('RMSE_Yamp_my_Z-2.68mm_dx-2.4um_lambda-405nm_M-5.mat')
RMSEamp_5=Yamp_rmse;
load('RMSE_Yamp_my_Z-2.68mm_dx-2.4um_lambda-405nm_M-20.mat')
RMSEamp_20=Yamp_rmse;
load('RMSE_Yamp_my_Z-2.68mm_dx-2.4um_lambda-405nm_M-5  20.mat')
RMSEamp_5_20=Yamp_rmse;

load('RMSE_Yphs_my_Z-4.74mm_dx-2.4um_lambda-405nm_M-.mat')
RMSEphs_0=Yphs_rmse;
load('RMSE_Yphs_my_Z-4.74mm_dx-2.4um_lambda-405nm_M-5.mat')
RMSEphs_5=Yphs_rmse;
load('RMSE_Yphs_my_Z-4.74mm_dx-2.4um_lambda-405nm_M-20.mat')
RMSEphs_20=Yphs_rmse;
load('RMSE_Yphs_my_Z-4.74mm_dx-2.4um_lambda-405nm_M-5  20.mat')
RMSEphs_5_20=Yphs_rmse;

figure()
subplot(2,4,1)
histogram(RMSEamp_0,10)
title(['AMP M=[], mean=',num2str(mean(RMSEamp_0))])


subplot(2,4,2)
histogram(RMSEamp_5,10)
title(['AMP M=[5], mean=',num2str(mean(RMSEamp_5))])

subplot(2,4,3)
histogram(RMSEamp_20,10)
title(['AMP M=[20], mean=',num2str(mean(RMSEamp_20))])

subplot(2,4,4)
histogram(RMSEamp_5_20)
title(['AMP M=[5,20], mean=',num2str(mean(RMSEamp_5_20))])

subplot(2,4,5)
histogram(RMSEphs_0,10)
title(['PHS M=[], mean=',num2str(mean(RMSEphs_0))])

subplot(2,4,6)
histogram(RMSEphs_5,10)
title(['PHS M=[5], mean=',num2str(mean(RMSEphs_5))])

subplot(2,4,7)
histogram(RMSEphs_20,10)
title(['PHS M=[20], mean=',num2str(mean(RMSEphs_20))])

subplot(2,4,8)
histogram(RMSEphs_5_20,10)
title(['PHS M=[5,20], mean=' num2str(mean(RMSEphs_5_20))])
