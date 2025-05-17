% 
% % Podejście 1
% 
% % function [outputArg1,outputArg2] = phase_angle_data(inputArg1,inputArg2) 
% % AmpPhs == 2
% %     % Phs data
% %     Z= 4740;
% %     Yphs_rmse=zeros(1,size(tarValPhs,4));
% %     for ii=1:size(tarValPhs,4)
% %         GT=tarValPhs(:,:,ii);% ground truth target image
% %         holo=holosValPhs(:,:,ii);% hologram
% %         ps = 256; % pad size
% %         holoP = padarray(holo,[ps,ps],'replicate'); % hologram padding
% %         [~,~,Yphs,~]=UTIRnetReconstruction(holoP,...
% %         CNN_A,CNN_P,Z,lambda,dx,[],0);
% %     Yphs = Yphs(ps+1:end-ps,ps+1:end-ps);
% %%%%% ZMIANA TUTAJ   %%% Yphs_rmse(ii)=rmse(angle(GT(:)),Yphs(:));
% %     end
% %     fnm="RMSE_"+fnm;
% %     save(fnm,"Yphs_rmse")
% % end
% %Yphs_rmse(mean)=0.3382
% 
% % Podejscie 2
% %  AmpPhs == 2
% %     % Phs data
% %     Z= 4740;
% %     Yphs_rmse=zeros(1,size(tarValPhs,4));
% %     for ii=1:size(tarValPhs,4)
% %         GT=tarValPhs(:,:,ii);% ground truth target image
% %         holo=holosValPhs(:,:,ii);% hologram
% %         ps = 256; % pad size
% %         holoP = padarray(holo,[ps,ps],'replicate'); % hologram padding
% %         [~,~,Yphs,~]=UTIRnetReconstruction(holoP,...
% %         CNN_A,CNN_P,Z,lambda,dx,[],0);
% %     Yphs = Yphs(ps+1:end-ps,ps+1:end-ps);
% %%%%% ZMIANA TUTAJ   %%% Yphs_rmse(ii)=rmse((GT(:)-pi),Yphs(:));
% %     end
% %     fnm="RMSE_"+fnm;
% %     save(fnm,"Yphs_rmse")
% % 
% % end
% % 
% % mean(Yphs_rmse)=0.1819
% 
% 
% ax = [];
% if AmpPhs == 1
%     % Amp data
%     Z= 2680;
%     Yamp_rmse=zeros(1,size(tarValAmp,4));
%     for ii=1:size(tarValAmp,4)
%         GT=tarValAmp(:,:,ii);% ground truth target image
%         holo=holosValAmp(:,:,ii);% hologram
%         ps = 256; % pad size
%         holoP = padarray(holo,[ps,ps],'replicate'); % hologram padding
%         [~,Yamp,~,~]=UTIRnetReconstruction(holoP,...
%         CNN_A,CNN_P,Z,lambda,dx,[],0);
%     Yamp = Yamp(ps+1:end-ps,ps+1:end-ps);
%     Yamp_rmse(ii)=rmse(GT(:),Yamp(:));
% 
%     end
%     fnm="RMSE2_"+fnm;
%     save(fnm,"Yamp_rmse")
% elseif AmpPhs == 2
%     % Phs data
%     Z= 4740;
%     Yphs_rmse=zeros(1,size(tarValPhs,4));
%     for ii=1:size(tarValPhs,4)
%         % GT=tarValPhs(:,:,ii)-pi;% ground truth target image - pi
%         GT=tarValPhs(:,:,ii);% ground truth target image no diff
%         holo=holosValPhs(:,:,ii);% hologram
%         ps = 256; % pad size
%         holoP = padarray(holo,[ps,ps],'replicate'); % hologram padding
%         [~,~,Yphs,~]=UTIRnetReconstruction(holoP,...
%         CNN_A,CNN_P,Z,lambda,dx,[],0);
%         Yphs = Yphs(ps+1:end-ps,ps+1:end-ps);
%         Yphs_rmse(ii)=rmse((GT(:)),Yphs(:));
%         rng = [-pi,pi];
%         figure; imagesc(angle(Uout),rng); ax = [ax,gca]; colormap gray;
%         axis image; colorbar; title('input AS phase (with twin-image)')
%         figure; imagesc(Yphs,rng); ax = [ax,gca]; colormap gray;
%         axis image; colorbar; title('UTIRnet reconstruction')
%         figure; imagesc(GT-pi,rng); ax = [ax,gca]; colormap gray;
%         axis image; colorbar; title('Ground truth (without twin-image)')
%         waitforbuttonpress;
%         end
%         fnm="RMSE2_"+fnm;
%         save(fnm,"Yphs_rmse")
% 
% end