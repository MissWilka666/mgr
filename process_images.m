function img_result=process_images(img_org,M)
if isfile('tableM.mat')
    load('tableM.mat','tableM');
else
    disp('Lack of table with STD to use');
end

mean_org=mean2(img_org);
img_org=img_org/mean_org; %img_org to mean=1
rowM=tableM(:,1)==M;
valM=tableM(rowM,2);

img_noise=randn(size(img_org))*valM; %szum na podstawie odchyleń standardowych
img_result=img_org+img_noise; %dodawanie szumu do obrazu
% img_min=min(img_result(:));
% img_max=max(img_result(:));
% img_result=(img_result-img_min)/(img_max-img_min);
% if M>1
%     img_result=round(img_result*(M-1))/(M-1);
% else
%     img_result=round(img_result*(M))/(M);
% end
img_result=round(img_result*(M))/(M); % Dodawanie szumu kwantyfikacji
img_result = img_result*mean_org; % Przywracanie sredniej do oryginalnej
end
