%Master control script for exploratorydataanalysis, invoked if desired
%Before running this, must set takenoverbymaster=1 in exploratorydataanalysis, to allow this to take control

initialrun=0; %3 sec
domaptwbtorqscores=1; %10 sec
domaptqstananomsduringextremewbt=0; %8 sec

if initialrun==1 %sets every option to 0
    yeariwf=1981;yeariwl=2015; %defaults
    monthiwf=5;monthiwl=10;

    loadvariables=0; %30 sec
    validstnmap=0;
    histogramrejstns=0;
    linechartrejstns=0;
    threelinesofxstwbtq=0; %timeline showing when each hot day ranked by T, WBT, and q occurred, for selected stations
        %(to get a feel for how much overlap there is between them, and the amount of temporal clustering in general)
        dostns=0;
        stnorregioniwf=1;stnorregioniwl=8; %stnorregion is the station or region for which timeline will be calculated (depending on the value of dostns)
        if dostns==1;stnname='Dallas, TX';end %modify according to stnorregion choice
    maptwbtorqscores=0; %15 sec
        makefinal=1;
        var1='t';var2='q'; %var1='wbt', 't', or 'ratio'; var2='t' or 'q'
            %-- ratio is (pct overlap wbt-t)/(pct overlap wbt-q)
        lastcolor='gray'; %'gray' or 'purple'
        prec=0.01; %precision to which to round colorbar text
    histogramtwbtscores=0;
    maptqtermsdiff=0;
    mapmediantopxxwbtbystn=0;
    maptqstananomsduringextremewbt=1;
        variwfhere=1;variwlhere=1;
        usequantiles=0; %if 0, uses preset values to define categories
        makefinal=1;
    plottrendsinregavgstnsp50corresptandq=0;
    plotmonthbymonthregavgstnsp50corresptandq=0;
    mapnumberofevents=0;
    mapnumberofyears=0;
    maptwbtqdates=0;
        if maptwbtqdates==1
            makefinal=1;
            plotnarr=0;plotstdev=0;
        end
    maptwbtqhours=0;
        if maptwbtqhours==1
            plotnarr=1;plotstdev=0;
        end
    histogramhoursofoccurrencebyregion=0;
    maptqhoursanddatesdiffs=0;
    histogramtwbthoursselcities=0;
    plothourlytracestwbt=0;
    plottopXXtraces=0;
    bargraphoccurrences=0;
    linegraphoccurrencebyyearandregion=0;
        makefinal=1;                %whether to make the final multipanel figure
        plotregavgcounts=0;         %if 1, just shows avg for each region, with all regions on same plot
        showvariancewithinregion=1; 
            avg3=1;                 %if 1, uses avg of 3 highest days per year; if 0, uses (original) count of top 100 days per year
        showselindivstns=0;         %if 1, plots ~10 figures showing in detail T and WBT occurrence for selected stations
        useseasonalmeans=0;         %if 1, each region gets its own plot just like with showvariancewithinregion, but plots are of seasonal-mean max T or WBT
        usetop3daysavg=0;           %if 1, shows avg of top-3 days in each year, both for stations and regions
    makescatterregionalinterannvar=0;
    mapinterannualvarbystn=0;
    mapcorrelsstwbt=0;
    mapcorrelssteverygridptwbt=0;
        cutoffcorrelval=0.44; %for 33 dof and two tails, minimum abs value of r that is stat signif at the:
            %95% confidence level: 0.34
            %99% confidence level: 0.44
            %99.9% confidence level: 0.545
    plotnarrcompositemaps=0; %plot as 10-day windows, months, or everything all together, depending on the value of plotmonth
        if plotnarrcompositemaps==1
            %Variables to set (these control climatology, summation, and mapping)
            makefinal=1; %whether to make the final multipanel figure
                numrowstomake=3;numcolstomake=3; %if so, the dimensions of it
            numdaysbefore=0;
            variwf=2;variwl=2;
            regiwf=1;regiwl=8;

            %Loops
            computeclimo=0; %monthly climatology for variables that will later be plotted (2 hours)
            sumupdates=0; %do the necessary calculations (about 1 hr)
                whethertosave=0; %only do if a full/official run is being done
            dothemapping=1; %actually make the maps (about 3 min per map)
                readvarsbackin=0; %if calculations were done remotely and variables need to be read back in (1 min)
                timeciwf=1;timeciwl=1; %ordinate of the window or month to plot composites for (or 1 if doing all-inclusive composites)
                optstoplot=[1]; %1 for 850 t overlaid with 850 wind, 2 for 850 q overlaid with 850 wind,
                    %3 for 300 gh overlaid with 300 wind
                stepprec=0.1; %will round steps to the nearest stepprec -- adapt for each optstoplot
                plotanom=1; %plots anomalies if ==1, or averages if ==0
                plotmonth=2;%plots months if ==1, 10-day windows if ==0, or everything all together if ==2
                tvsq=1; %plots relatively-T-dominated hot days only if ==1, relatively-q-dominated only if ==0, 
                %T-dominated >p80 if ==3, q-dominated >p80 if ==4, and both (i.e. totally disregards T/q split) if ==10
        end
    plotncepcompositemapsnowindows=0; %plots gh500 anomalies
        if plotncepcompositemapsnowindows==1
            makefinal=1; %whether to make the final multipanel figure
                numrowstomake=3;numcolstomake=3; %if so, the dimensions of it
            variwf=2;variwl=2;
            regiwf=1;regiwl=8;
            numdaysbefore=10; %number of days before the extreme day to show
                    %(e.g. 2 means plot 2 days before) -- defaults are 0, 2, 5, 10, or 25
            needtodocalc=0; %20 sec
                plotstananoms=1;
                ensocomposite=0; %1 if plotting seasonal anomalies for 5 El Nino or La Nina summers, 0 for the normal anomaly-during-extreme-WBT-days 
                if ensocomposite==1;elnino=1;plotstananoms=1;makefinal=0;regiwl=regiwf;end %elnino is 1 for El Nino summers, 0 for La Nina summers
                    %don't want to make the multipanel figure in this case, and regions don't matter
                monthlystdevs=0; %5 sec; 1 if need to compute st devs of gh500 for each month (using daily data)
            domapping=1; %5 sec per var & region
                stepprec=5;
        end
    plotsstcompositemapsnowindows=0; %NOAA ERSST data
        if plotsstcompositemapsnowindows==1
            numlons=180;numlats=83; %because 2-degree resolution
            usedetrended=0; %not possible for this loop, in fact (at least yet)
            needtodocalc=1; %2 sec
            domapping=1;
        end
    computestananomsnoaaoisst=0; %stan anoms for each day of the year, using NOAA OISST data; about 2 hr 15 min
    plotsstcompositemapsnowindowsdaily=0; %NOAA OISST data
        if plotsstcompositemapsnowindowsdaily==1
            makefinal=1; %whether to make the final multipanel figure
                numrowstomake=3;numcolstomake=3; %if so, the dimensions of it
            usinganomdata=0; %whether using anomaly data, or absolute (in which case anomalies will be calculated herein)
            numlons=1440;numlats=720; %because quarter-degree resolution
            variwf=2;variwl=2;
            regiwf=1;regiwl=8;
            usedetrended=0; %not possible for this loop, in fact (at least yet)
            %Actual sub-loops
            needtodocalc=0; %about 4 min per variable & region using absolute data, 15 min if using anomaly data
            domapping=1; %10 sec per var & region
                numdaysbefore=0; %number of days before the extreme day to show
                    %(e.g. 2 means plot 2 days before) -- defaults are 0, 2, 5, 10, or 25
        end
    plotwvfluxconv=0;
        if plotwvfluxconv==1
            makefinal=1; %whether to make the final multipanel figure
                numrowstomake=3;numcolstomake=3; %if so, the dimensions of it
            needtoloadandprocessdata=1; %12 min total
                newversion=0; %new version wasn't all it was cracked up to be... old version is being used now
                needtocomputemonthlyclimo=0; %1 min for new version, 7 min for old version
                computetopXX=1;
                    numdaysbefore=5; %number of days before the extreme day to compute & show
                    %(e.g. 2 means plot 2 days before) -- defaults are 0, 2, 5, 10, or 25
            domapping=1;
        end
    plotwbtoftop100t=0; %for selected stations
    plotnumqspikes=0;
    plotspikescontribhighwbt=0;
        if plotspikescontribhighwbt==1
            makefinal=1;
        end
    pctstnsinvalid1monthormore=0; %15 sec


    %Have to edit selindivstns and selindivstnsnumwithinregion whenever the number of stations is changed
    selindivstns=[7;18;27;35;40;41;43;44;80;94;121;176];
    selindivstnsnames={'Fairbanks';'Orlando';'Mobile';'Brownsville';'Dallas';'Tucson';'San Diego';'Los Angeles';'Evansville'; 
        'Newark';'Omaha';'Seattle'};
    selindivstnsregions=[1;7;7;5;5;3;3;3;6;8;4;2]; %discover these numbers manually once stations are chosen
    selindivstnsnumwithinregion=[7;3;13;3;8;1;3;5;4;6;1;13]; %use ncaregionnames to assist in determining these numbers

    figletterlabels={'a';'b';'c';'d';'e';'f';'g';'h'};


    exist numdates;if ans==0;numdates=100;end %set numdates, to match that set in findmaxtwbt
    exist figc;if ans==0;figc=1;end

    if runremotely==1
        curDir='/cr/cr2630/WBTT_Overlap_Paper/';
        narrDir='/cr/cr2630/NARR_3-hourly_data_mat/';
        addpath('/cr/cr2630/Scripts/GeneralPurposeScripts');savepath;
    elseif runworkcomputer==1
        curDir='/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/';
        curArrayDir='/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/';
        narrDir='/Volumes/MacFormatted4TBExternalDrive/NARR_3-hourly_data_mat/';
        ncepdailydataDir='/Volumes/MacFormatted4TBExternalDrive/NCEP_daily_data_mat/';
        narrncDir='/Volumes/MacFormatted4TBExternalDrive/NARR_3-hourly_data_raw/';
        dailyanomsstfileloc='/Volumes/MacFormatted4TBExternalDrive/NOAA_OISST_Daily_Anoms/';
        narrhmdDir='/Volumes/MacFormatted4TBExternalDrive/NARR_Daily_Horiz_Moisture_Divergence/';
    else
        curDir='/Users/colin/Documents/General_Academics/Research/WBTT_Overlap_Paper/';
        narrDir='/Volumes/MacFormatted4TBExternalDrive/NARR_3-hourly_data_mat/';
        ncepdailydataDir='/Volumes/MacFormatted4TBExternalDrive/NCEP_daily_data_mat/';
        narrncDir='/Volumes/MacFormatted4TBExternalDrive/NARR_3-hourly_data_raw/';
        dailyanomsstfileloc='/Volumes/MacFormatted4TBExternalDrive/NOAA_OISST_Daily_Anoms/';
        narrhmdDir='/Volumes/MacFormatted4TBExternalDrive/NARR_Daily_Horiz_Moisture_Divergence/';
    end
    varlist={'temp';'wbt';'q'};
    temp=load('-mat','soilm_narr_01_01');soilm_narr_01_01=temp(1).soilm_0000_01_01;
    narrlats=soilm_narr_01_01{1};narrlons=soilm_narr_01_01{2};
    exist ersstlats;
    if ans==0 && connectedtoexternaldrive==1
        ersstlatsorig=ncread('/Volumes/MacFormatted4TBExternalDrive/NOAA_ERSST_Data/sst.mnmean.nc','lat');
        ersstlonsorig=ncread('/Volumes/MacFormatted4TBExternalDrive/NOAA_ERSST_Data/sst.mnmean.nc','lon');
        for i=1:size(ersstlonsorig,1)
            for j=1:size(ersstlatsorig,1)
                ersstlats(i,j)=ersstlatsorig(j);
                ersstlons(i,j)=ersstlonsorig(i);
            end
        end
        save(strcat(curDir,'correlsstarrays'),'ersstlats','ersstlons','-append');
    end
    exist oisstlats;
    if ans==0 && connectedtoexternaldrive==1
        oisstlatsorig=...
            ncread('/Volumes/MacFormatted4TBExternalDrive/NOAA_OISST_Daily_Data/tos_OISST_L4_AVHRR-only-v2_19820101-19820630.nc','lat');
        oisstlonsorig=...
            ncread('/Volumes/MacFormatted4TBExternalDrive/NOAA_OISST_Daily_Data/tos_OISST_L4_AVHRR-only-v2_19820101-19820630.nc','lon');
        for i=1:size(oisstlonsorig,1)
            for j=1:size(oisstlatsorig,1)
                oisstlats(i,j)=oisstlatsorig(j);
                oisstlons(i,j)=oisstlonsorig(i);
            end
        end
        save(strcat(curDir,'dailysstarrays'),'oisstlats','oisstlons','-append');
    end
    dailysstfileloc='/Volumes/MacFormatted4TBExternalDrive/NOAA_OISST_Daily_Data/';
    temp=load('-mat','hgt_1979_01_500_ncep');hgt_1979_01_500_ncep=temp(1).hgt_1979_01_500;
    nceplats=double(hgt_1979_01_500_ncep{1});nceplons=double(hgt_1979_01_500_ncep{2});
    shortregnames={'ak';'nw';'sw';'gpn';'gps';'mw';'se';'ne'};
    monthnames={'May';'Jun';'Jul';'Aug';'Sep';'Oct'};
    exist numdaysbefore;
    if ans==1
        if numdaysbefore==0;ndbcateg=1;ndbc=1;elseif numdaysbefore==2;ndbcateg=2;ndbc=2;elseif numdaysbefore==5;ndbcateg=3;ndbc=3;
        elseif numdaysbefore==10;ndbcateg=4;ndbc=4;elseif numdaysbefore==25;ndbcateg=5;ndbc=5;
        else disp('Please adjust numdaysbefore');return;
        end
    end
    vars={'t';'shum';'uwnd';'vwnd';'uwnd';'vwnd';'gh';'gh'};
    vrs={'t';'shum';'u';'v';'u';'v';'gh';'gh'};
    levels={'850';'850';'850';'850';'300';'300';'500';'300'};
    levelindices=[2;2;2;2;4;4;3;4];
    varnum=size(vars,1);

    %Use newstnNumListnames to conveniently look up name-number correspondences for any station

    %Load variables from .mat files
    if loadvariables==1
        loadsavedvariables;
    end
end

%Subsequent runs will have exploratorydataanalysis execute the below-specified loops
    %with the below-specified options, one at a time

if domaptwbtorqscores==1
    numpanels=2;
    %Run 1
    maptwbtorqscores=1;
        makefinal=1;if makefinal==1;panelnumber=1;end
        var1='wbt';var2='t'; %var1='wbt', 't', or 'ratio'; var2='t' or 'q'
            %-- ratio is (pct overlap wbt-t)/(pct overlap wbt-q)
        lastcolor='gray'; %'gray' or 'purple'
        prec=0.01; %precision to which to round colorbar text
        plotending='';
    exploratorydataanalysis;

    %Run 2
    maptwbtorqscores=1;
        makefinal=1;if makefinal==1;panelnumber=2;end
        var1='wbt';var2='q'; %var1='wbt', 't', or 'ratio'; var2='t' or 'q'
            %-- ratio is (pct overlap wbt-t)/(pct overlap wbt-q)
        lastcolor='gray'; %'gray' or 'purple'
        prec=0.01; %precision to which to round colorbar text
        plotending='';
    exploratorydataanalysis;
end

if domaptqstananomsduringextremewbt==1
    %Run 1
    maptqstananomsduringextremewbt=1;
        variwfhere=1;variwlhere=1;
        usequantiles=0; %if 0, uses preset values to define categories
        makefinal=1;if makefinal==1;panelnumber=1;end
        plotending='anomstan';
    exploratorydataanalysis;
    
    %Run 2
    maptqstananomsduringextremewbt=1;
        variwfhere=2;variwlhere=2;
        usequantiles=0; %if 0, uses preset values to define categories
        makefinal=1;if makefinal==1;panelnumber=2;end
        plotending='anomstan';
    exploratorydataanalysis;
end