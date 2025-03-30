function [img_result,img_noise]=process_images(img_org,M,n)
    if isfile('tableM.mat')
       load('tableM.mat','tableM');
    else
        disp('Lack of table with STD to use');
    end

    img_result=cell(1,n);
    img_noise=cell(1,n);

    mean_org=mean2(img_org);
    img_org=img_org/mean_org; %img_org to mean=1
    rowM=tableM(:,1)==M;
    valM=tableM(rowM,2);
    for ii=1:n
        img_noise{ii}=randn(size(img_org))*valM; %szum na podstawie odchyleń standardowych
        img_result{ii}=img_org+img_noise{ii}; %dodawanie szumu do obrazu
        img_min=min(img_result{ii}(:));
        img_max=max(img_result{ii}(:));
        img_result{ii}=(img_result{ii}-img_min)/(img_max-img_min);
        if M>1
            img_result{ii}=round(img_result{ii}*(M-1))/(M-1);
        else
            img_result{ii}=round(img_result{ii}*(M))/(M);
        end
        
    end
end
