function std_vector = std_adder()
    folder = 'C:\Users\milka\Desktop\MGR\Holograms'; 
    m=0;
    if isfile('std_vector.mat')
       load('std_vector.mat','std_vector');
       load('mean_vector.mat','mean_vector');
       % load('name_vectror.mat','name')
       m=length(std_vector);
    end
    
    file_pattern='**/USAF-?.mat';
    filelist=dir(fullfile(folder,file_pattern));
    n=length(filelist);
    img_calc=cell(1,n);
    

    % uc=length(unique({filelist.name}));
    
    
    for ii=1:n   
        % file=filelist(ii).name;
        foldername=extractBetween(filelist(ii).folder, 'Holograms\', '\');
        [startRow,endRow,startCol,endCol]=startstop(foldername);
        indx=str2num(filelist(ii).name(end-4:end-4));
        data=load(fullfile(filelist(ii).folder, filelist(ii).name));
        img_calc{ii}=double(data.u);
        img_calc{ii}=img_calc{ii}(startRow(indx):endRow(indx)-1,startCol(indx):endCol(indx)-1);
        mean_vector(m+ii)=mean2(img_calc{ii});
        img_calc{ii}=img_calc{ii}/mean_vector(m+ii);
        std_vector(m+ii)=std2(img_calc{ii});
        % if ii==120
        %     ii
        % end
    end
    save('std_vector.mat','std_vector');
    save('mean_vector.mat','mean_vector');
    % save('name_vector.mat','name')
end
