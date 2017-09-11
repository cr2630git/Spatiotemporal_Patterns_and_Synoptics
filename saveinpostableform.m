%Once all variables are loaded into the workspace, save them to mat files in forms that are easily digestible
%for my website and Github page
%Runtime: 20 sec

wheretosave='/Users/craymon3/General_Academics/Research/Polished_Datasets/Hourly_Station_Dataset/';

finaldatat19811985={};finaldatadewpt19811985={};finaldatawbt19811985={};finaldataq19811985={};
for year=1:5
    for stn=1:190
        finaldatat19811985{year,stn}=finaldatat{year,stn};
        finaldatadewpt19811985{year,stn}=finaldatadewpt{year,stn};
        finaldatawbt19811985{year,stn}=finaldatawbt{year,stn};
        finaldataq19811985{year,stn}=finaldataq{year,stn};
    end
end

finaldatat19861990={};finaldatadewpt19861990={};finaldatawbt19861990={};finaldataq19861990={};
for year=6:10
    for stn=1:190
        finaldatat19861990{year-5,stn}=finaldatat{year,stn};
        finaldatadewpt19861990{year-5,stn}=finaldatadewpt{year,stn};
        finaldatawbt19861990{year-5,stn}=finaldatawbt{year,stn};
        finaldataq19861990{year-5,stn}=finaldataq{year,stn};
    end
end

finaldatat19911995={};finaldatadewpt19911995={};finaldatawbt19911995={};finaldataq19911995={};
for year=11:15
    for stn=1:190
        finaldatat19911995{year-10,stn}=finaldatat{year,stn};
        finaldatadewpt19911995{year-10,stn}=finaldatadewpt{year,stn};
        finaldatawbt19911995{year-10,stn}=finaldatawbt{year,stn};
        finaldataq19911995{year-10,stn}=finaldataq{year,stn};
    end
end

finaldatat19962000={};finaldatadewpt19962000={};finaldatawbt19962000={};finaldataq19962000={};
for year=16:20
    for stn=1:190
        finaldatat19962000{year-15,stn}=finaldatat{year,stn};
        finaldatadewpt19962000{year-15,stn}=finaldatadewpt{year,stn};
        finaldatawbt19962000{year-15,stn}=finaldatawbt{year,stn};
        finaldataq19962000{year-15,stn}=finaldataq{year,stn};
    end
end

finaldatat20012005={};finaldatadewpt20012005={};finaldatawbt20012005={};finaldataq20012005={};
for year=21:25
    for stn=1:190
        finaldatat20012005{year-20,stn}=finaldatat{year,stn};
        finaldatadewpt20012005{year-20,stn}=finaldatadewpt{year,stn};
        finaldatawbt20012005{year-20,stn}=finaldatawbt{year,stn};
        finaldataq20012005{year-20,stn}=finaldataq{year,stn};
    end
end

finaldatat20062010={};finaldatadewpt20062010={};finaldatawbt20062010={};finaldataq20062010={};
for year=26:30
    for stn=1:190
        finaldatat20062010{year-25,stn}=finaldatat{year,stn};
        finaldatadewpt20062010{year-25,stn}=finaldatadewpt{year,stn};
        finaldatawbt20062010{year-25,stn}=finaldatawbt{year,stn};
        finaldataq20062010{year-25,stn}=finaldataq{year,stn};
    end
end

finaldatat20112015={};finaldatadewpt20112015={};finaldatawbt20112015={};finaldataq20112015={};
for year=31:35
    for stn=1:190
        finaldatat20112015{year-30,stn}=finaldatat{year,stn};
        finaldatadewpt20112015{year-30,stn}=finaldatadewpt{year,stn};
        finaldatawbt20112015{year-30,stn}=finaldatawbt{year,stn};
        finaldataq20112015{year-30,stn}=finaldataq{year,stn};
    end
end


save(strcat(wheretosave,'savedarraysstationsmjjaso19811985.mat'),...
    'newstnNumList','newstnNumListlats','newstnNumListlons','newstnNumListnames',...
    'finaldatat19811985','finaldatadewpt19811985','finaldatawbt19811985','finaldataq19811985');
save(strcat(wheretosave,'savedarraysstationsmjjaso19861990.mat'),...
    'newstnNumList','newstnNumListlats','newstnNumListlons','newstnNumListnames',...
    'finaldatat19861990','finaldatadewpt19861990','finaldatawbt19861990','finaldataq19861990');
save(strcat(wheretosave,'savedarraysstationsmjjaso19911995.mat'),...
    'newstnNumList','newstnNumListlats','newstnNumListlons','newstnNumListnames',...
    'finaldatat19911995','finaldatadewpt19911995','finaldatawbt19911995','finaldataq19911995');
save(strcat(wheretosave,'savedarraysstationsmjjaso19962000.mat'),...
    'newstnNumList','newstnNumListlats','newstnNumListlons','newstnNumListnames',...
    'finaldatat19962000','finaldatadewpt19962000','finaldatawbt19962000','finaldataq19962000');
save(strcat(wheretosave,'savedarraysstationsmjjaso20012005.mat'),...
    'newstnNumList','newstnNumListlats','newstnNumListlons','newstnNumListnames',...
    'finaldatat20012005','finaldatadewpt20012005','finaldatawbt20012005','finaldataq20012005');
save(strcat(wheretosave,'savedarraysstationsmjjaso20062010.mat'),...
    'newstnNumList','newstnNumListlats','newstnNumListlons','newstnNumListnames',...
    'finaldatat20062010','finaldatadewpt20062010','finaldatawbt20062010','finaldataq20062010');
save(strcat(wheretosave,'savedarraysstationsmjjaso20112015.mat'),...
    'newstnNumList','newstnNumListlats','newstnNumListlons','newstnNumListnames',...
    'finaldatat20112015','finaldatadewpt20112015','finaldatawbt20112015','finaldataq20112015');

