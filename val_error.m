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
Z=4740;
%Wilkowiecka_Z for USAFamp

imNo = 50; % image number ################################

AmpPhs = 2; % 1 - amplitude data, 2 - phase data ##########################

Z= 4740;
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
    figure; imagesc(angle(Yphs),rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('UTIRnet reconstruction')
    figure; imagesc(GT-pi,rng); ax = [ax,gca]; colormap gray;
    axis image; colorbar; title('Ground truth (without twin-image)')
end
linkaxes(ax)

% save results for dingle image
if AmpPhs==1
    fnm=['Yamp_my_Z-',num2str(Z/1000),'mm_dx-',num2str(dx),'um_lambda-',...
    num2str(lambda*1000),'nm_M-',num2str(M),'.mat'];
    % save(fnm,"Yamp")
elseif AmpPhs==2
    fnm=['Yphs_my_Z-',num2str(Z/1000),'mm_dx-',num2str(dx),'um_lambda-',...
    num2str(lambda*1000),'nm_M-',num2str(M),'.mat'];
    % save(fnm,"Yphs")
end

if AmpPhs == 1
    % Amp data
    Z= 2680;
    Yamp_rmse=zeros(1,size(tarValAmp,4));
    for ii=1:size(tarValAmp,4)
        GT=tarValAmp(:,:,ii);% ground truth target image
        holo=holosValAmp(:,:,ii);% hologram
        ps = 256; % pad size
        holoP = padarray(holo,[ps,ps],'replicate'); % hologram padding
        [~,Yamp,~,~]=UTIRnetReconstruction(holoP,...
        CNN_A,CNN_P,Z,lambda,dx,[],0);
    Yamp = Yamp(ps+1:end-ps,ps+1:end-ps);
    Yamp_rmse(ii)=rmse(GT(:),Yamp(:));
    end
    fnm="RMSE_"+fnm;
    save(fnm,"Yamp_rmse")
elseif AmpPhs == 2
    % Phs data
    Z= 4740;
    Yphs_rmse=zeros(1,size(tarValPhs,4));
    for ii=1:size(tarValPhs,4)
        GT=tarValPhs(:,:,ii);% ground truth target image
        holo=holosValPhs(:,:,ii);% hologram
        ps = 256; % pad size
        holoP = padarray(holo,[ps,ps],'replicate'); % hologram padding
        [~,~,Yphs,~]=UTIRnetReconstruction(holoP,...
        CNN_A,CNN_P,Z,lambda,dx,[],0);
    Yphs = Yphs(ps+1:end-ps,ps+1:end-ps);
    Yphs_rmse(ii)=rmse(GT(:),Yphs(:));
    end
    fnm="RMSE_"+fnm;
    save(fnm,"Yphs_rmse")
end