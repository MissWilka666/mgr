function [startRow,endRow,startCol,endCol] = startstop(foldername)  
    if foldername=="Bio"     
        startCol=[2672,2768,2769,1962,3420];
        endCol=[2740,2851,2880,2055,3554];
        startRow=[1275,156,136,2837,2022];
        endRow=[1311,206,187,2886,2049];
    
    elseif foldername=="USAF amp"
        startCol=[2348,1607,2801,1905,2837];
        endCol=[2478,1708,2861,1996,2928];
        startRow=[740,389,385,708,854];
        endRow=[822,471,439,758,907];
    
    elseif foldername=="USAF phsv2"
        startCol=[4240,4048,1348,3736,4498];
        endCol=[4318,4142,1423,3797,4695];
        startRow=[1000,2220,2523,3157,1372];
        endRow=[1046,2299,2561,3259,1499];
    
    elseif foldername=="USAF phs"
        startCol=[1520,1876,2861,1207,1748];
        endCol=[1618,1927,3051,1347,1883];
        startRow=[2471,668,3101,2590,3109];
        endRow=[2543,798,3247,2704,3205];

   else
        startCol=ones(1,5);
        endCol=ones(1,5);
        startRow=ones(1,5);
        endRow=ones(1,5);  
    end

end