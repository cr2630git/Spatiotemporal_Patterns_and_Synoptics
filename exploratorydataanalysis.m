%Some EDA maps and plots for the WBT/T-overlap paper
%This is primarily a graphing/plotting script -- most arrays visualized here are created
    %in findmaxtwbt
%However, this script does do some computations like averaging, temporally combining, etc
    
%If graphs look bad on the initial output, remember that in many cases their settings are optimized for
%highqualityfiguresetup and the resulting nice png file -- look at that instead!

%Maps were originally made with usaminushawaii-tight region, but then were re-created with usa region (eliminating AK)
    
runremotely=0;
runworkcomputer=1;
connectedtoexternaldrive=0; %whether can currently access data stored on 4TB external drive
takenoverbymasterscript=0; %whether this script is actually controlled by a master one
    %(useful for e.g. running this script twice, changing an option or two, when making a multipanel figure)

if takenoverbymasterscript==0
    yeariwf=1981;yeariwl=2015; %defaults
    monthiwf=5;monthiwl=10;

    loadvariables=0; %30 sec
    validstnmap=0;
    histogramrejstns=0;
    linechartrejstns=0;
    showregions=0;
    scatterplottqconstantwbtlines=1; %scatterplot helping to explore the data as well as illustrate 'essential constraints' on T vs q excursions
        if scatterplottqconstantwbtlines==1
            stntouse=94; %typical options are 94 (Newark NJ), 187 (OK City OK), 93 (San Francisco CA)
            recomputeperct=0; %30 sec; the main calculation in this loop
            doplot=0; %whether to actually make the scatterplot, or just do the preliminary computation (i.e. if only looking at centroids)
            docentroidplot=0; %whether to map centroid positions for each stn
            scatterplotvectorslope=0; %some verification plots requested by Radley, using the vector information from the above scatterplot
            makefinalfig=1; %selects the best of the above figures to put into a 4-panel figure for inclusion in the paper
        end
    threelinesofxstwbtq=0; %timeline showing when each hot day ranked by T, WBT, and q occurred, for selected stations
        %(to get a feel for how much overlap there is between them, and the amount of temporal clustering in general)
        dostns=0;
        stnorregioniwf=2;stnorregioniwl=8; %stnorregion is the station or region for which timeline will be calculated (depending on the value of dostns)
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
        if mapmediantopxxwbtbystn==1
            plotnarr=1;
            twopanels=0; %0 if NARR & stn data in the same panel, 1 if not
        end
    maptqstananomsduringextremewbt=0;
        if maptqstananomsduringextremewbt==1
            variwfhere=4;variwlhere=4;
            plotending='anomstan'; %'anomstan' or '', the latter if plotting actual values
            usequantiles=0; %if 0, uses preset values to define categories
            makefinal=0; %enables multipanel figures -- if only 1 panel is desired, set ==0
        end
    plottrendsinregavgstnsp50corresptandq=0;
    plotmonthbymonthregavgstnsp50corresptandq=0; %need to run tqanomsextremewbt loop (with determinetandqeffectsonwbt=1) in findmaxtwbt first
        valoranomstan='anomstan';
        plotappendix=1;
    mapnumberofevents=0;
    mapnumberofyears=0;
    maptwbtqdates=0;
        if maptwbtqdates==1
            variwfhere=2;variwlhere=2;
            makefinal=1;
            twopanels=0; %0 if NARR & stn data in the same panel, 1 if not
            plotnarr=1;plotstdev=0;
        end
    maptwbtqhours=0;
        if maptwbtqhours==1
            variwfhere=2;variwlhere=2;
            makefinal=1;
            plotnarr=0;plotstdev=0;
        end
    plotp25p75plot=0;
        dooldstyleplot=0;
    histogramhoursofoccurrencebyregion=0;
    histogramdatesofoccurrencebyregion=0;
    maptqhoursanddatesdiffs=0;
    histogramtwbthoursselcities=0;
    plothourlytracestwbt=0;
    plottopXXtraces=0;
    bargraphoccurrences=0;
    linegraphoccurrencebyyearandregion=0;
        if linegraphoccurrencebyyearandregion==1
            makefinal=1;                %whether to make the final multipanel figure
            plotregavgcounts=0;         %if 1, just shows avg for each region, with all regions on same plot
            showvariancewithinregion=0; 
                avg3=1;                 %if 1, uses avg of 3 highest days per year; if 0, uses (original) count of top 100 days per year
            showselindivstns=0;         %if 1, plots ~10 figures showing in detail T and WBT occurrence for selected stations
            useseasonalmeans=1;         %if 1, each region gets its own plot just like with showvariancewithinregion, but plots are of seasonal-mean max T or WBT
            usetop3daysavg=0;           %if 1, shows avg of top-3 days in each year, both for stations and regions
        end
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
            variwf=2;variwl=2; %as a general rule, do not change this setting (modifications are made as necessary within indiv loops)
            regiwf=2;regiwl=8;
            regcenterlats=[65;45.3;36.95;45;33.65;42.4;34.75;42.2];
            regcenterlons=[-160;-118.15;-113.35;-105;-98.2;-89.25;-83.7;-74.75];

            %Loops
            computeclimo=0; %monthly climatology for variables that will later be plotted (2 hours)
            sumupdates=0; %do the necessary calculations (about 1 hr)
                whethertosave=0; %only do if a full/official run is being done
            dothemapping=1; %actually make the maps (about 20 sec per map)
                readvarsbackin=0; %if calculations were done remotely and variables need to be read back in (1 min)
                timeciwf=1;timeciwl=1; %ordinate of the window or month to plot composites for (or both 1, if doing all-inclusive composites)
                optstoplot=[1]; %1 for 850 t overlaid with 500 gh, 2 for 850 q overlaid with 850 wind,
                    %3 for 300 gh overlaid with 300 wind, 4 for 500 gh overlaid with 850 wind
                stepprec=0.1; %will round steps to the nearest stepprec -- applies only to NCEP composites
                plotanom=1; %plots anomalies if ==1, or averages if ==0
                plotmonth=2;%plots months if ==1, 10-day windows if ==0, or everything all together if ==2
                tvsq=10; %plots relatively-T-dominated hot days only if ==1, relatively-q-dominated only if ==0, 
                %T-dominated >p80 if ==3, q-dominated >p80 if ==4, and both (i.e. totally disregards T/q split) if ==10
                includeclimoaslastpanel=1; %whether to include an analogous plot showing the climatology on top-XX days
        end
    plotncepcompositemapsnowindows=0; %plots gh500 anomalies
        if plotncepcompositemapsnowindows==1
            makefinal=1; %whether to make the final multipanel figure
                numrowstomake=4;numcolstomake=2; %if so, the dimensions of it
            variwf=2;variwl=2;
            regiwf=2;regiwl=2;
            numdaysbefore=10; %number of days before the extreme day to show
                    %(e.g. 2 means plot 2 days before) -- defaults are 0, 2, 5, 10, or 20
            needtodocalc=1; %20 sec
                plotstananoms=0;
                ensocomposite=0; %1 if plotting seasonal anomalies for 5 El Nino or La Nina summers, 0 for the normal anomaly-during-extreme-WBT-days 
                if ensocomposite==1;elnino=1;plotstananoms=1;makefinal=0;regiwl=regiwf;end %elnino is 1 for El Nino summers, 0 for La Nina summers
                    %don't want to make the multipanel figure in this case, and regions don't matter
                monthlystdevs=0; %5 sec; 1 if need to compute st devs of gh500 for each month (using daily data)
            dosigniftest=1; %this & other surrogate stuff takes 3 min for altapproach=1, 15 min for altapproach=2 (with 1000 surrogates)
                altapproach=2; %1 or 2
            domapping=1; %10 sec per var & region
                stepprec=10;
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
            %Options
            makefinal=1; %whether to make the final multipanel figure
                numrowstomake=3;numcolstomake=3; %if so, the dimensions of it
            usinganomdata=0; %whether using anomaly data, or absolute (in which case anomalies will be calculated herein)
            numlons=1440;numlats=720; %because quarter-degree resolution
            variwf=2;variwl=2;
            regiwf=2;regiwl=8;
            numdaysbefore=0; %number of days before the extreme day to show
                    %(e.g. 2 means plot 2 days before) -- defaults are 0, 2, 5, 10, or 20
            usedetrended=0; %not possible for this loop, in fact (at least yet)
            
            %Actual sub-loops
            needtodocalc=1; %about 4 min per variable & region using absolute data, 15 min if using anomaly data
            domapping=0; %10 sec per var & region    
        end
    plotz500sstfiguresdaily=0; %5 min per subplot (i.e. 35 min for all 7 regions)
        %do final calculations and make final figures using results from the above NCEP and OISST loops
        if plotz500sstfiguresdaily==1
            loadarraysagain=1;
            needtodefinestipplematrix=0; %30 sec
            numdaysbefore=0;
            variwf=2;variwl=2;regiwf=2;regiwl=8;
            numrowstomake=7;numcolstomake=1;
        end
    plotwvfluxconv=0;
        if plotwvfluxconv==1
            makefinal=1; %whether to make the final multipanel figure
                numrowstomake=4;numcolstomake=2; %if so, the dimensions of it
            needtoloadandprocessdata=0;
                newversion=0; %new version wasn't all it was cracked up to be... old version is being used now
                needtocomputemonthlyclimo=0; %1 min for new version, 7 min for old version
                computetopXX=1; %40 min total
                    ndbset=[20;10;5;4;3;2;1;0;-1;-2]; %number of days before (or after, if negative) the extreme day to compute & show
            domapping=1; %10 sec per region
                regiwf=2;regiwl=8;
        end
    plotwbtoftop100t=0; %for selected stations
    plotnumqspikes=0;
    plotspikescontribhighwbt=0;
        if plotspikescontribhighwbt==1
            makefinal=0; %puts both T and q spikes on the same figure
        end
    pctstnsinvalid1monthormore=0; %15 sec
    dryyearsbyregion=0;
    plotpredictabilityfromgh500=0;
        if plotpredictabilityfromgh500==1
            ncareg=8;lagcateg=2;
        end
    analyzehourofoccurrence=0;
        if analyzehourofoccurrence==1
            plottq=0; %10 sec
            plotwinddirspeed=0; %10 sec
            domultipanelnarrcomposites=1; 
                makefinal=1;
                computepart=0; %45 min
                plotpart=1; %1 min
        end
    readpdsidata=0; %3 sec
    winddiff=0; %5 sec; wind difference between Jul 1 and Aug 15
    traceanomsforasingleregion=0;
        readinarrays=0;
    sfcfluxanalysis=0; %Analyze and make nice figures comparing 'horizontal' fluxes (advection) and 'vertical' fluxes
        if sfcfluxanalysis==1
            fluxestop100=0; %2 hr total for all 7 regions
            computeclimo=0; %2 hr 30 min total
            plotavgtraces=0;
            plotanomtraces=1;
                plotbothregions=0;
                if plotbothregions~=1;region=3;end %which region to plot, if not plotting both
            dotest=0;
        end


    %Have to edit selindivstns and selindivstnsnumwithinregion whenever the number of stations is changed
    selindivstns=[7;18;27;35;40;41;43;44;80;94;121;176];
    selindivstnsnames={'Fairbanks';'Orlando';'Mobile';'Brownsville';'Dallas';'Tucson';'San Diego';'Los Angeles';'Evansville'; 
        'Newark';'Omaha';'Seattle'};
    selindivstnsregions=[1;7;7;5;5;3;3;3;6;8;4;2]; %discover these numbers manually once stations are chosen
    selindivstnsnumwithinregion=[7;3;13;3;8;1;3;5;4;6;1;13]; %use ncaregionnames to assist in determining these numbers
    ncaregionnameslong={'Northwest';'Southwest';'Great Plains North';'Great Plains South';'Midwest';'Southeast';'Northeast'};

    
    figletterlabels={'a';'b';'c';'d';'e';'f';'g';'h'};
    lagcategs={'0';'1-3';'4-7';'8-14';'16-25'};


    exist numdates;if ans==0;numdates=100;end %set numdates, to match that set in findmaxtwbt
    exist figc;if ans==0;figc=1;end
    
    newstnNumListnamesclean{18}='Orlando, FL';
    newstnNumListnamesclean{44}='Los Angeles, CA';
    newstnNumListnamesclean{93}='San Francisco, CA';
    newstnNumListnamesclean{94}='Newark, NJ';
    newstnNumListnamesclean{121}='Omaha, NE';
    newstnNumListnamesclean{176}='Seattle, WA';
    newstnNumListnamesclean{179}='Queens (JFK), NY';
    newstnNumListnamesclean{187}='Oklahoma City, OK';

    if runremotely==1 %Lamont cluster
        curDir='/cr/cr2630/WBTT_Overlap_Paper/';
        narrDir='/cr/cr2630/NARR_3-hourly_data_mat/';
        addpath('/cr/cr2630/Scripts/GeneralPurposeScripts');savepath;
    else %personal or work computer
        curDir='~/Library/Mobile Documents/com~apple~CloudDocs/General_Academics/Research/WBTT_Overlap_Paper/';
        curArrayDir='~/Library/Mobile Documents/com~apple~CloudDocs/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/';
        figDir='~/Library/Mobile Documents/com~apple~CloudDocs/General_Academics/Research/WBTT_Overlap_Paper/Figures/';
        narrDir='/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/';
        ncepdailydataDir='/Volumes/ExternalDriveA/NCEP_daily_data_mat/';
        narrncDir='/Volumes/ExternalDriveA/NARR_3-hourly_data_raw/';
        dailyanomsstfileloc='/Volumes/ExternalDriveA/NOAA_OISST_Daily_Anoms/';
        narrhmdDir='/Volumes/ExternalDriveA/NARR_Daily_Horiz_Moisture_Divergence/';
        pdsiDir='/Volumes/ExternalDriveA/Dai_PDSI/';
    end
    varlist={'temp';'wbt';'q'};
    temp=load('-mat','soilm_narr_01_01');soilm_narr_01_01=temp(1).soilm_0000_01_01;
    narrlats=soilm_narr_01_01{1};narrlons=soilm_narr_01_01{2};
    exist ersstlats;
    if ans==0 && connectedtoexternaldrive==1
        ersstlatsorig=ncread('/Volumes/ExternalDriveA/NOAA_ERSST_Data/sst.mnmean.nc','lat');
        ersstlonsorig=ncread('/Volumes/ExternalDriveA/NOAA_ERSST_Data/sst.mnmean.nc','lon');
        for i=1:size(ersstlonsorig,1)
            for j=1:size(ersstlatsorig,1)
                ersstlats(i,j)=ersstlatsorig(j);
                ersstlons(i,j)=ersstlonsorig(i);
            end
        end
        save(strcat(curArrayDir,'correlsstarrays'),'ersstlats','ersstlons','-append');
    end
    exist oisstlats;
    if ans==0 && connectedtoexternaldrive==1
        oisstlatsorig=...
            ncread('/Volumes/ExternalDriveA/NOAA_OISST_Daily_Data/tos_OISST_L4_AVHRR-only-v2_19820101-19820630.nc','lat');
        oisstlonsorig=...
            ncread('/Volumes/ExternalDriveA/NOAA_OISST_Daily_Data/tos_OISST_L4_AVHRR-only-v2_19820101-19820630.nc','lon');
        for i=1:size(oisstlonsorig,1)
            for j=1:size(oisstlatsorig,1)
                oisstlats(i,j)=oisstlatsorig(j);
                oisstlons(i,j)=oisstlonsorig(i);
            end
        end
        save(strcat(curArrayDir,'dailysstarrays'),'oisstlats','oisstlons','-append');
    end
    dailysstfileloc='/Volumes/ExternalDriveA/NOAA_OISST_Daily_Data/';
    temp=load('-mat','hgt_1979_01_500');hgt_1979_01_500_ncep=temp(1).hgt_1979_01_500;
    nceplats=double(hgt_1979_01_500_ncep{1});nceplons=double(hgt_1979_01_500_ncep{2});
    shortregnames={'ak';'nw';'sw';'gpn';'gps';'mw';'se';'ne'};
    monthnames={'May';'Jun';'Jul';'Aug';'Sep';'Oct'};
    exist numdaysbefore;
    if ans==1
        if numdaysbefore==0;ndbcateg=1;ndbc=1;elseif numdaysbefore==2;ndbcateg=2;ndbc=2;elseif numdaysbefore==5;ndbcateg=3;ndbc=3;
        elseif numdaysbefore==10;ndbcateg=4;ndbc=4;elseif numdaysbefore==20;ndbcateg=5;ndbc=5;elseif numdaysbefore==1;ndbcateg=6;ndbc=6;
        elseif numdaysbefore==-1;ndbcateg=7;ndbc=7;elseif numdaysbefore==-2;ndbcateg=8;ndbc=8;elseif numdaysbefore==-5;ndbcateg=9;ndbc=9;
        else disp('Please adjust numdaysbefore');return;
        end
    end
    vars={'t';'shum';'uwnd';'vwnd';'uwnd';'vwnd';'gh';'gh'};
    vrs={'t';'shum';'u';'v';'u';'v';'gh';'gh'};
    levels={'850';'850';'850';'850';'300';'300';'500';'300'};
    levelindices=[2;2;2;2;5;5;4;5];
    varnum=size(vars,1);

    %Use newstnNumListnames to conveniently look up name-number correspondences for any station

    %Load variables from .mat files
    if loadvariables==1
        loadsavedvariables;
    end
    
    mastername='';
else
    mastername='master';
end


%Map of valid stations
if validstnmap==1
    validstnlats=newstnNumListlats;
    validstnlons=newstnNumListlons;
    if size(validstnlats,1)==1;validstnlats=validstnlats';validstnlons=validstnlons';end
    plotBlankMap(figc,'usa');figc=figc+1;
    for i=1:size(validstnlats,1)
        h=geoshow(validstnlats(i),validstnlons(i),'DisplayType','Point','Marker','s',...
            'MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',7);hold on;
    end
    title('Stations Used in Analysis','FontWeight','bold','FontSize',20,'FontName','Arial');
end

%Histogram of number of stn/year combos rejected for various reasons (the on-screen output of ncdcHourlyTxtToMat2)
if histogramrejstns==1
    figure(figc);figc=figc+1;
    y=[86;8;0;45;0]; %good stations; # disallowed b/c temporal gaps; # disallowed b/c Jan or Dec missing; 
        %number disallowed b/c too much data missing overall; # disallowed b/c too many consecutive missing MJJAS T or dewpt values
    bar(y);
    a=text(0.8,95,'Valid Stns','FontWeight','bold','FontSize',14,'FontName','Arial');set(a,'rotation',0);
    a=text(1.5,95,'>5-hour Time Gaps','FontWeight','bold','FontSize',14,'FontName','Arial');set(a,'rotation',0);
    a=text(2.7,95,'No Jan or Dec','FontWeight','bold','FontSize',14,'FontName','Arial');set(a,'rotation',0);
    a=text(3.5,95,'>3% T or Dewpt Missing','FontWeight','bold','FontSize',14,'FontName','Arial');set(a,'rotation',0);
    a=text(4.6,95,'>5-hour MJJAS T or Dewpt Gaps','FontWeight','bold','FontSize',14,'FontName','Arial');set(a,'rotation',0);
    ylabel('Number of Stations','FontSize',16,'FontWeight','bold','FontName','Arial');
end

%Line charts of temporal gaps and % data missing (for stations that were rejected for those reasons)
if linechartrejstns==1
    figure(figc);figc=figc+1;
    temporalgaps=sort(disallowedstnstemporalgaps');
    plot(temporalgaps);ylim([0 max(temporalgaps)]);
    title('Size of maximum temporal gaps (in hours), among stations disallowed for exceeding 5 hours',...
        'FontWeight','bold','FontSize',20,'FontName','Arial');
    xlabel('Station Count','FontWeight','bold','FontSize',16,'FontName','Arial');
    ylabel('Size of Maximum Temporal Gap (Hours)','FontWeight','bold','FontSize',16,'FontName','Arial');
    set(gca,'FontWeight','bold','FontName','Arial','FontSize',14);

    figure(figc);figc=figc+1;
    percdatamissing=sort(disallowedstnspercdatamissing');
    plot(percdatamissing);ylim([0 max(percdatamissing)]);
    title('Percent T or dewpt data missing, among stations disallowed for exceeding 3%',...
        'FontWeight','bold','FontSize',20,'FontName','Arial');
    xlabel('Station Count','FontWeight','bold','FontSize',16,'FontName','Arial');
    ylabel('Percent of Total Annual Data Missing (of 8760 Hours)','FontWeight','bold','FontSize',16,'FontName','Arial');
    set(gca,'FontWeight','bold','FontName','Arial','FontSize',14);
end

%Illustrate the NCA regions
if showregions==1
    plotBlankMap(figc,'usa');figc=figc+1;curpart=1;highqualityfiguresetup;
    states=shaperead('usastatelo','UseGeoCoords',true);
    symspec=makesymbolspec('Polygon',{'Name','Alabama','FaceColor',colors('light pink')},...
        {'Name','Mississippi','FaceColor',colors('light pink')},{'Name','Georgia','FaceColor',colors('light pink')},...
        {'Name','Louisiana','FaceColor',colors('light pink')},{'Name','Arkansas','FaceColor',colors('light pink')},...
        {'Name','Florida','FaceColor',colors('light pink')},{'Name','South Carolina','FaceColor',colors('light pink')},...
        {'Name','Kentucky','FaceColor',colors('light pink')},{'Name','Tennessee','FaceColor',colors('light pink')},...
        {'Name','North Carolina','FaceColor',colors('light pink')},{'Name','Virginia','FaceColor',colors('light pink')},...
        {'Name','Maryland','FaceColor',colors('mint')},{'Name','West Virginia','FaceColor',colors('mint')},...
        {'Name','Delaware','FaceColor',colors('mint')},{'Name','Pennsylvania','FaceColor',colors('mint')},...
        {'Name','New Jersey','FaceColor',colors('mint')},{'Name','New York','FaceColor',colors('mint')},...
        {'Name','Connecticut','FaceColor',colors('mint')},{'Name','Rhode Island','FaceColor',colors('mint')},...
        {'Name','Massachusetts','FaceColor',colors('mint')},{'Name','Vermont','FaceColor',colors('mint')},...
        {'Name','New Hampshire','FaceColor',colors('mint')},{'Name','Maine','FaceColor',colors('mint')},...
        {'Name','Ohio','FaceColor',colors('light blue')},{'Name','Michigan','FaceColor',colors('light blue')},...
        {'Name','Indiana','FaceColor',colors('light blue')},{'Name','Illinois','FaceColor',colors('light blue')},...
        {'Name','Wisconsin','FaceColor',colors('light blue')},{'Name','Minnesota','FaceColor',colors('light blue')},...
        {'Name','Iowa','FaceColor',colors('light blue')},{'Name','Missouri','FaceColor',colors('light blue')},...
        {'Name','Nebraska','FaceColor',colors('light red')},{'Name','South Dakota','FaceColor',colors('light red')},...
        {'Name','North Dakota','FaceColor',colors('light red')},{'Name','Montana','FaceColor',colors('light red')},...
        {'Name','Wyoming','FaceColor',colors('light red')},{'Name','Idaho','FaceColor',colors('gold')},...
        {'Name','Washington','FaceColor',colors('gold')},{'Name','Oregon','FaceColor',colors('gold')},...
        {'Name','California','FaceColor',colors('light purple')},{'Name','Nevada','FaceColor',colors('light purple')},...
        {'Name','Arizona','FaceColor',colors('light purple')},{'Name','Utah','FaceColor',colors('light purple')},...
        {'Name','Colorado','FaceColor',colors('light purple')},{'Name','New Mexico','FaceColor',colors('light purple')},...
        {'Name','Kansas','FaceColor',colors('light grey')},{'Name','Oklahoma','FaceColor',colors('light grey')},...
        {'Name','Texas','FaceColor',colors('light grey')});
    geoshow(states,'SymbolSpec',symspec,'DefaultFaceColor','w','DefaultEdgeColor','k');
    %Add region labels
    x=[0.9 0.8];y=[0.6 0.6];
    a=annotation('textarrow',x,y,'string','Northeast');set(a,'fontsize',18,'linewidth',2);
    x=[0.8 0.72];y=[0.3 0.37];
    a=annotation('textarrow',x,y,'string','Southeast');set(a,'fontsize',18,'linewidth',2);
    x=[0.55 0.52];y=[0.24 0.31];
    a=annotation('textarrow',x,y,'string','Great Plains South');set(a,'fontsize',18,'linewidth',2);
    x=[0.13 0.23];y=[0.35 0.43];
    a=annotation('textarrow',x,y,'string','Southwest');set(a,'fontsize',18,'linewidth',2);
    x=[0.1 0.18];y=[0.73 0.7];
    a=annotation('textarrow',x,y,'string','Northwest');set(a,'fontsize',18,'linewidth',2);
    x=[0.35 0.35];y=[0.93 0.86];
    a=annotation('textarrow',x,y,'string','Great Plains North');set(a,'fontsize',18,'linewidth',2);
    x=[0.68 0.63];y=[0.9 0.82];
    a=annotation('textarrow',x,y,'string','Midwest');set(a,'fontsize',18,'linewidth',2);
    title('Regions','fontname','arial','fontsize',24,'fontweight','bold');
    curpart=2;figloc=figDir;figname='regions';
    highqualityfiguresetup;
end


%Scatterplot of T vs q, including lines of constant WBT, for stn 94 (Newark NJ)
if scatterplottqconstantwbtlines==1
    %WBT curves are calculated in wbtcurves.xlsx
    %T, q points for each of the WBT curves
    wbt18curvet=[45;40;35;30;25;20;18];wbt18curveq=[2.6;4.1;5.6;7.4;9.8;12;12.7];
    yi18=linspace(wbt18curveq(1),wbt18curveq(end),5);
    xi18=interp1(wbt18curveq,wbt18curvet,yi18,'spline');
    
    wbt20curvet=[45;40;35;30;25;20];wbt20curveq=[4.5;6;7.7;9.9;12.3;14.3];
    yi20=linspace(wbt20curveq(1),wbt20curveq(end),5);
    xi20=interp1(wbt20curveq,wbt20curvet,yi20,'spline');
    
    wbt22curvet=[45;40;35;30;25;22];wbt22curveq=[6.6;8.2;10.2;12.6;15.1;16.2];
    yi22=linspace(wbt22curveq(1),wbt22curveq(end),5);
    xi22=interp1(wbt22curveq,wbt22curvet,yi22,'spline');
    
    wbt24curvet=[45;40;35;30;25;24];wbt24curveq=[8.9;10.8;13;15.6;17.9;18.2];
    yi24=linspace(wbt24curveq(1),wbt24curveq(end),5);
    xi24=interp1(wbt24curveq,wbt24curvet,yi24,'spline');
    
    wbt26curvet=[45;40;35;30;27.5;26];wbt26curveq=[11.6;13.7;16.2;18.8;19.9;20.4];
    yi26=linspace(wbt26curveq(1),wbt26curveq(end),5);
    xi26=interp1(wbt26curveq,wbt26curvet,yi26,'spline');
    
    wbt28curvet=[45;40;35;30;28];wbt28curveq=[14.7;17;19.7;22.2;22.9];
    yi28=linspace(wbt28curveq(1),wbt28curveq(end),5);
    xi28=interp1(wbt28curveq,wbt28curvet,yi28,'spline');
    
    wbt30curvet=[45;40;35;30];wbt30curveq=[18.1;20.7;23.4;25.6];
    yi30=linspace(wbt30curveq(1),wbt30curveq(end),5);
    xi30=interp1(wbt30curveq,wbt30curvet,yi30,'spline');
    
    wbt32curvet=[45;40;35;32];wbt32curveq=[22;24.7;27.4;28.6];
    yi32=linspace(wbt32curveq(1),wbt32curveq(end),5);
    xi32=interp1(wbt32curveq,wbt32curvet,yi32,'spline');
    
    wbt34curvet=[45;40;35;34];wbt34curveq=[26.2;29;31.5;31.8];
    yi34=linspace(wbt34curveq(1),wbt34curveq(end),5);
    xi34=interp1(wbt34curveq,wbt34curvet,yi34,'spline');
    
    if recomputeperct==1
        for stntouse=1:190
            assoct=correspt{stntouse}; %T associated with top-100 extreme WBT values
            assocq=correspq{stntouse}; %q associated with top-100 extreme WBT values

            %Also include all MJJASO hours OR next 900 (after the 1st top 100) --
            %see actual plotting of scatterplot, below, to toggle between
            alltdatavec=0;allqdatavec=0;
            for year=1:35
                for month=1:6
                    tdata=stndatat{stntouse,year,month};%numvalstoadd=size(tdata,1);
                    qdata=stndataq{stntouse,year,month};
                    alltdatavec=[alltdatavec;tdata];
                    allqdatavec=[allqdatavec;qdata];
                end
            end

            %Compute centroid of top-100 T and q, and of next-900 T and q
            centroidtop100t=nanmean(assoct(1:100));
            centroidtop100q=nanmean(assocq(1:100));
            centroidnext900t=nanmean(corresptnext900{stntouse}(101:1000));
            centroidnext900q=nanmean(correspqnext900{stntouse}(101:1000));
            xdisplacement=centroidtop100t-centroidnext900t;ydisplacement=centroidtop100q-centroidnext900q;
            perct(stntouse)=atan(ydisplacement/xdisplacement)*180/3.1416; %e.g. 45 deg if displacements are equal
        end
        save(strcat(curArrayDir,'extraarrays'),'perct','-append');
    end
    
    
    %Finally, make the plot
    if doplot==1
        figure(figc);clf;figc=figc+1;curpart=1;highqualityfiguresetup;
        
        plot([xi18(end) xi18(1)],[yi18(end) yi18(1)],'color',colors('gray'),'linewidth',3);hold on;
        plot([xi20(end) xi20(1)],[yi20(end) yi20(1)],'color',colors('purple'),'linewidth',3);
        plot([xi22(end) xi22(1)],[yi22(end) yi22(1)],'color',colors('blue'),'linewidth',3);
        plot([xi24(end) xi24(1)],[yi24(end) yi24(1)],'color',colors('light blue'),'linewidth',3);
        plot([xi26(end) xi26(1)],[yi26(end) yi26(1)],'color',colors('teal'),'linewidth',3);
        plot([xi28(end) xi28(1)],[yi28(end) yi28(1)],'color',colors('green'),'linewidth',3);
        plot([xi30(end) xi30(1)],[yi30(end) yi30(1)],'color',colors('orange'),'linewidth',3);
        plot([xi32(end) xi32(1)],[yi32(end) yi32(1)],'color',colors('red'),'linewidth',3);
        plot([xi34(end) xi34(1)],[yi34(end) yi34(1)],'color',colors('crimson'),'linewidth',3);
        text(15.7,13.2,sprintf('WBT=18%cC',char(176)),'fontsize',12,'fontweight','bold','fontname','arial');
        text(17.7,14.8,sprintf('WBT=20%cC',char(176)),'fontsize',12,'fontweight','bold','fontname','arial');
        text(19.7,16.7,sprintf('WBT=22%cC',char(176)),'fontsize',12,'fontweight','bold','fontname','arial');
        text(21.7,18.7,sprintf('WBT=24%cC',char(176)),'fontsize',12,'fontweight','bold','fontname','arial');
        text(23.7,20.9,sprintf('WBT=26%cC',char(176)),'fontsize',12,'fontweight','bold','fontname','arial');
        text(25.7,23.5,sprintf('WBT=28%cC',char(176)),'fontsize',12,'fontweight','bold','fontname','arial');
        text(27.7,26.1,sprintf('WBT=30%cC',char(176)),'fontsize',12,'fontweight','bold','fontname','arial');
        text(29.7,29.1,sprintf('WBT=32%cC',char(176)),'fontsize',12,'fontweight','bold','fontname','arial');
        
        %scatter(alltdatavec,allqdatavec,10,'filled');hold on;
        scatter(corresptnext900{stntouse}(101:1000),correspqnext900{stntouse}(101:1000),10,'k','filled');hold on;
        scatter(assoct(1:100),assocq(1:100),25,'r','filled');
        scatter(centroidtop100t,centroidtop100q,200,'r','filled','marker','s');
        scatter(centroidnext900t,centroidnext900q,200,'k','filled','marker','s')
        
        ylim([0 30]);set(gca,'fontsize',12,'fontweight','bold','fontname','arial');
        ylabel('q (g/kg)','fontsize',14,'fontweight','bold','fontname','arial');
        xlabel(sprintf('T (%cC)',char(176)),'fontsize',14,'fontweight','bold','fontname','arial');
        title(sprintf('T and q for Extreme WBT at %s',newstnNumListnamesclean{stntouse}),'fontsize',16);
        curpart=2;figloc=figDir;figname=strcat('scatterplottqwbtcurvesforstn',num2str(stntouse));
        highqualityfiguresetup;
    end
    %Centroid plot, if desired -- more accurately, a map of q-domination at each station
    if docentroidplot==1
        colorcutoffs=[63;54;45;36;27]; %smaller number --> WBT extremes are more T-dom --> appears as purple on map
            %numbers are chosen so that when converted to %qdom (by multiplying by 100/90) they are nice round numbers
        figure(figc);clf;
        title('Percent q-Domination of Top-100 WBT Extremes vs Next 900','FontSize',20,'FontWeight','bold','FontName','Arial');
        savingdir=curDir;figurename='scatterplottqwbtcurvessupportcentroidsmap';
        quicklymapsomethingusa(10/9.*perct',newstnNumListlats,newstnNumListlons,'s',colorcutoffs,mycolormap,7,savingdir,figurename);
        mycolormap=[colors('red');colors('orange');colors('green');colors('light blue');colors('blue');colors('purple')];
        colormap(mycolormap);
        %3-digit colors in table are from colors in colormap.*255
        ctable=[0 229 0 0 27 229 0 0;
            27 249 115 6 36 249 115 6;
            36 21 176 26 45 21 176 26;
            45 149 208 252 54 149 208 252;
            54 3 67 223 63 3 67 223;
            63 126 30 156 100 126 30 156];
        save mycol.cpt ctable -ascii;
        cptcmap('mycol','mapping','direct');
        cbar=cptcbar(gca,'mycol','eastoutside',false);cb=cbar.cb;
        set(cbar.ax,'FontSize',16,'FontWeight','bold','FontName','Arial');
        h=text(1.13,0.3,'Percent q-Domination','FontSize',14,'FontWeight','bold','FontName','Arial','units','normalized');
        set(h,'rotation',90);
        set(gca,'FontSize',16,'FontWeight','bold','FontName','Arial');
        curpart=2;figloc=figDir;figname=figurename;highqualityfiguresetup;
    end
    %Scatterplot of slope of vector (i.e. perct) vs baseline T and q on 1000 hottest days
    if scatterplotvectorslope==1
        for stn=1:190;baselinet(stn)=nanmean(top1000tbystn{stn}(:,1));end
        figure(figc);clf;figc=figc+1;curpart=1;highqualityfiguresetup;
        scatter(baselinet,perct.*10/9,'filled','o');
        xlabel('Average T on 1000 hottest days','FontSize',14,'FontWeight','bold','FontName','Arial');
        ylabel('Percent q-domination (=(10/9)*slope of vector)','FontSize',14,'FontWeight','bold','FontName','Arial');
        set(gca,'FontSize',14,'FontWeight','bold','FontName','Arial');
        curpart=2;figloc=figDir;figname='scatterplottqwbtvstop1000t';highqualityfiguresetup;
        
        for stn=1:190;baselineq(stn)=nanmean(top1000qbystn{stn}(:,1));end
        figure(figc);clf;figc=figc+1;
        scatter(baselineq,perct.*10/9,'filled','o');
        xlabel('Average q on 1000 hottest days','FontSize',14,'FontWeight','bold','FontName','Arial');
        ylabel('Percent q-domination (=(10/9)*slope of vector)','FontSize',14,'FontWeight','bold','FontName','Arial');
        set(gca,'FontSize',14,'FontWeight','bold','FontName','Arial');
        curpart=2;figloc=figDir;figname='scatterplottqwbtvstop1000q';highqualityfiguresetup;
        
        for stn=1:190;avg3highestwbt(stn)=nanmean(avg3highestwbtbystn(stn,:));end
        figure(figc);clf;figc=figc+1;
        scatter(avg3highestwbt,perct.*10/9,'filled','o');
        xlabel('Average of 3 highest WBT','FontSize',14,'FontWeight','bold','FontName','Arial');
        ylabel('Percent q-domination (=(10/9)*slope of vector)','FontSize',14,'FontWeight','bold','FontName','Arial');
        set(gca,'FontSize',14,'FontWeight','bold','FontName','Arial');
        curpart=2;figloc=figDir;figname='scatterplottqwbtvstop3wbt';highqualityfiguresetup;
    end
    
    %Use a script that picks and chooses certain of the above plots to fill its four subplots 
    if makefinalfig==1
        edascatterplot;
    end
end

%Timeline of x's (100 on each line) marking the occurrence of each hot T, WBT, and q days, for regions and for selected stations
if threelinesofxstwbtq==1
    if dostns==1 %doing this loop with selected stations
        topXXt=topXXtbystn;topXXwbt=topXXwbtbystn;topXXq=topXXqbystn;figphrase='stn';
    else %doing this loop with regions
        topXXt=topXXtbyregionsorted;topXXwbt=topXXwbtbyregionsorted;topXXq=topXXqbyregionsorted;figphrase='region';
    end
    for i=stnorregioniwf:stnorregioniwl
        %Sort hot-days arrays chronologically
        if dostns==1
            tarr=sortrows(topXXt{i},[2 3 4]);
            wbtarr=sortrows(topXXwbt{i},[2 3 4]);
            qarr=sortrows(topXXq{i},[2 3 4]);
        else
            tarr=sortrows(topXXt{i}(1:100,:),[1 2 3]);
            wbtarr=sortrows(topXXwbt{i}(1:100,:),[1 2 3]);
            qarr=sortrows(topXXq{i}(1:100,:),[1 2 3]);
        end
        %In a sixth column, convert date to number of MJJASO days since Apr 30, 1981
        for j=1:numdates
            if dostns==1
                numwinterstosubtract=tarr(j,2)-1981;numleapyears=round2((tarr(j,2)-1983)/4,1,'ceil');
                tarr(j,6)=DaysApart(4,30,1981,tarr(j,3),tarr(j,4),tarr(j,2))-numwinterstosubtract*181-numleapyears;
                numwinterstosubtract=wbtarr(j,2)-1981;numleapyears=round2((wbtarr(j,2)-1983)/4,1,'ceil');
                wbtarr(j,6)=DaysApart(4,30,1981,wbtarr(j,3),wbtarr(j,4),wbtarr(j,2))-numwinterstosubtract*181-numleapyears;
                numwinterstosubtract=qarr(j,2)-1981;numleapyears=round2((qarr(j,2)-1983)/4,1,'ceil');
                qarr(j,6)=DaysApart(4,30,1981,qarr(j,3),qarr(j,4),qarr(j,2))-numwinterstosubtract*181-numleapyears;
            else
                numwinterstosubtract=tarr(j,1)-1981;numleapyears=round2((tarr(j,1)-1983)/4,1,'ceil');
                tarr(j,5)=DaysApart(4,30,1981,tarr(j,2),tarr(j,3),tarr(j,1))-numwinterstosubtract*181-numleapyears;
                numwinterstosubtract=wbtarr(j,1)-1981;numleapyears=round2((wbtarr(j,1)-1983)/4,1,'ceil');
                wbtarr(j,5)=DaysApart(4,30,1981,wbtarr(j,2),wbtarr(j,3),wbtarr(j,1))-numwinterstosubtract*181-numleapyears;
                numwinterstosubtract=qarr(j,1)-1981;numleapyears=round2((qarr(j,1)-1983)/4,1,'ceil');
                qarr(j,5)=DaysApart(4,30,1981,qarr(j,2),qarr(j,3),qarr(j,1))-numwinterstosubtract*181-numleapyears;
            end
        end
        
        %Create figure
        line1=1*ones(6400,1);line2=2*ones(6400,1);line3=3*ones(6400,1);
        if makefinal==0
            figure(figc);clf;figc=figc+1;
        else
            if i==stnorregioniwf;figure(figc);clf;figc=figc+1;end
            h=subplot(4,2,i-1);
            temp=get(h,'pos');if i==8;set(h,'pos',[0.3325 0.09 0.335 0.16]);end
        end
        curpart=1;highqualityfiguresetup;
        plot(line1,'k');hold on;plot(line2,'k');plot(line3,'k');ylim([0 4]);xlim([0 6400]);
        for j=1:numdates
            if dostns==1
                xcoord=tarr(j,6);text(xcoord,1,'x','color','r');
                xcoord=wbtarr(j,6);text(xcoord,2,'x','color','r');
                xcoord=qarr(j,6);text(xcoord,3,'x','color','r');
            else
                xcoord=tarr(j,5);text(xcoord,1,'x','color','r');
                xcoord=wbtarr(j,5);text(xcoord,2,'x','color','r');
                xcoord=qarr(j,5);text(xcoord,3,'x','color','r');
            end
        end
        set(gca,'ytick',[]);
        if makefinal==0
            xlabel('MJJASO Days Since Apr 30, 1981','FontSize',16,'fontweight','bold','fontname','arial');
            text(-0.03,0.255,'T','Units','normalized','FontSize',16,'fontweight','bold','fontname','arial');
            text(-0.06,0.505,'WBT','Units','normalized','FontSize',16,'fontweight','bold','fontname','arial');
            text(-0.03,0.755,'q','Units','normalized','FontSize',16,'fontweight','bold','fontname','arial');
            set(gca,'FontSize',16,'fontweight','bold','fontname','arial');
        else
            text(-0.09,0.255,'T','Units','normalized','FontSize',10,'fontweight','bold','fontname','arial');
            text(-0.12,0.505,'WBT','Units','normalized','FontSize',10,'fontweight','bold','fontname','arial');
            text(-0.09,0.755,'q','Units','normalized','FontSize',10,'fontweight','bold','fontname','arial');
            set(gca,'FontSize',10,'fontweight','bold','fontname','arial');
            %Shade years to indicate where 5 El Nino and 5 La Nina summers are located
                %(these are defined down in plotncepcompositemapsnowindows)
            for j=1:size(elninoyears)
                curyear=elninoyears(j);
                numwinterstosubtract=curyear-1981;numleapyears=round2((curyear-1983)/4,1,'ceil');
                may1loc=DaysApart(4,30,1981,5,1,curyear)-numwinterstosubtract*181-numleapyears;oct31loc=may1loc+183;
                x=[may1loc may1loc oct31loc oct31loc may1loc];y=[0 4 4 0 0];
                patch(x,y,-1*ones(size(x)),[0.88 0.88 0.88],'LineStyle','none'); %light gray
            end
            for j=1:size(laninayears)
                curyear=laninayears(j);
                numwinterstosubtract=curyear-1981;numleapyears=round2((curyear-1983)/4,1,'ceil');
                may1loc=DaysApart(4,30,1981,5,1,curyear)-numwinterstosubtract*181-numleapyears;oct31loc=may1loc+183;
                x=[may1loc may1loc oct31loc oct31loc may1loc];y=[0 4 4 0 0];
                patch(x,y,-1*ones(size(x)),[0.98 0.88 1],'LineStyle','none'); %light purple
            end
        end
        
        if i==1;theornot='';else theornot='the ';end %for Alaska
        if makefinal==0
            if dostns==1
                title(sprintf('Dates of Top-%d T, WBT, and q at %s',numdates,stnname),'FontSize',20,'fontweight','bold','fontname','arial');
            else
                title(sprintf('Dates of Top-%d T, WBT, and q for %s%s',numdates,theornot,ncaregionnamemaster{i}),...
                    'FontSize',20,'fontweight','bold','fontname','arial');
            end
            figname=strcat('threelines',figphrase);
        else
            figname=strcat('threelines',figphrase,'final');
        end
        if makefinal==0;curpart=2;figloc=figDir;highqualityfiguresetup;end
    end
    %Add appropriate text annotations
    if makefinal==1
        for i=2:8
            %if rem(i,2)==1;colpos=-1.37;else colpos=-0.05;end

            if rem(i,2)==1;colpos=0.66;elseif i~=8;colpos=-0.64;else colpos=-0.05;end
            if i<=3;rowpos=5.25;elseif i<=5;rowpos=3.87;elseif i<=7;rowpos=2.5;else rowpos=1.1;end
            if i~=8
                newrowposletter=rowpos+0.08;newrowposbr1=rowpos-0.32;newrowposn1=rowpos-0.37;
                newrowposbr2=rowpos-0.62;newrowposn2=rowpos-0.67;
            else
                newrowposletter=rowpos+0.02;newrowposbr1=rowpos-0.38;newrowposn1=rowpos-0.43;
                newrowposbr2=rowpos-0.68;newrowposn2=rowpos-0.73;
            end
            text(colpos,newrowposletter,strcat('(',figletterlabels{i-1},')'),'units','normalized',...
                'FontSize',16,'fontweight','bold','fontname','arial');
            text(colpos+1.1,newrowposbr1,'}','units','normalized','FontSize',24,'fontname','arial');
            text(colpos+1.15,newrowposn1,sprintf('%d',pctoverlapwbtqreg(i)),...
                'units','normalized','FontSize',14,'fontweight','bold','fontname','arial');
            text(colpos+1.1,newrowposbr2,'}','units','normalized','FontSize',24,'fontname','arial');
            text(colpos+1.15,newrowposn2,sprintf('%d',pctoverlapwbttreg(i)),...
                'units','normalized','FontSize',14,'fontweight','bold','fontname','arial');
            if i==4 || i==5;xpos=colpos+0.35;else xpos=colpos+0.45;end
            if i==8;ypos=rowpos-0.03;else ypos=rowpos;end
            text(xpos,ypos+0.06,strcat(ncaregionnamemaster{i}),'units','normalized',...
                    'fontsize',14,'fontweight','bold','fontname','arial');
        end
        curpart=2;figloc=figDir;highqualityfiguresetup;
    end
end


%T/WBT or q scores are converted to percent overlap and plotted for each station and NARR gridpt
if maptwbtorqscores==1
    regular=1; %whether to plot the full range of scores ("regular"), or to focus in on the lowest quartile (i.e. the one with the most overlap)
    if makefinal==1
        figure(figc);if panelnumber==1;clf;end
        subplot(2,1,panelnumber);plotBlankMap(figc,'usa');
        curpart=1;highqualityfiguresetup;
    else
        plotBlankMap(figc,'usa');figc=figc+1;
        curpart=1;highqualityfiguresetup;
    end
    clear hardlowerbound;
    if strcmp(var1,'wbt') && strcmp(var2,'t')
        pctoverlap=pctoverlapwbtt;pctoverlapnarr=pctoverlapwbttnarr;hardlowerbound=1;flexibleupperbound=1;
        if makefinal==0
            topofrange=64;bottomofrange=0;interval=8; %bottomofrange+8*interval=topofrange
        else
            topofrange=80;bottomofrange=0;interval=10;
        end
    elseif strcmp(var1,'wbt') && strcmp(var2,'q')
        pctoverlap=pctoverlapwbtq;pctoverlapnarr=pctoverlapwbtqnarr;flexibleupperbound=1;
        if makefinal==0
            topofrange=90;bottomofrange=10;interval=10; %bottomofrange+8*interval=topofrange
        else
            topofrange=80;bottomofrange=0;interval=10;
        end
    elseif strcmp(var1,'t') && strcmp(var2,'q')
        pctoverlap=pctoverlaptq;hardlowerbound=1;flexibleupperbound=1;
        if makefinal==0
            topofrange=40;bottomofrange=0;interval=5; %bottomofrange+8*interval=topofrange
        else
            topofrange=80;bottomofrange=0;interval=10;
        end
    elseif strcmp(var1,'ratio')
        pctoverlapwbtt=(numdates*2-wbttscore)/2;pctoverlapwbtq=(numdates*2-wbtqscore)/2;
        temp=pctoverlapwbtt==0;pctoverlapwbtt(temp)=NaN;
        temp=pctoverlapwbtq==0;pctoverlapwbtq(temp)=NaN;
        pctoverlap=pctoverlapwbtt./pctoverlapwbtq;
        pctoverlapwbttnarr=(numdates*2-wbttscorenarr)/2;pctoverlapwbtqnarr=(numdates*2-wbtqscorenarr)/2;
        temp=pctoverlapwbttnarr==0;pctoverlapwbttnarr(temp)=NaN;temp=pctoverlapwbttnarr==100;pctoverlapwbttnarr(temp)=NaN;
        temp=pctoverlapwbtqnarr==0;pctoverlapwbtqnarr(temp)=NaN;temp=pctoverlapwbtqnarr==100;pctoverlapwbtqnarr(temp)=NaN;
        pctoverlapnarr=pctoverlapwbttnarr./pctoverlapwbtqnarr;
        temp=pctoverlapnarr==100;pctoverlapnarr(temp)=NaN;
        hardlowerbound=1;
        if strcmp(lastcolor,'gray')
            topofrange=1.0;bottomofrange=0;interval=1/8;flexibleupperbound=1;
        elseif strcmp(lastcolor,'purple')
            topofrange=1.0;bottomofrange=0;interval=1/6;flexibleupperbound=1;
        end
    end
    for i=1:size(newstnNumList,1)
        if regular==1
            if strcmp(lastcolor,'gray')
                if pctoverlap(i)>=topofrange-interval
                    color='r';
                elseif pctoverlap(i)>=topofrange-2*interval
                    color=colors('orange');
                elseif pctoverlap(i)>=topofrange-3*interval
                    color=colors('green');
                elseif pctoverlap(i)>=topofrange-4*interval
                    color=colors('sky blue');
                elseif pctoverlap(i)>=topofrange-5*interval
                    color=colors('blue');
                elseif pctoverlap(i)>=topofrange-6*interval
                    color=colors('purple');
                elseif pctoverlap(i)>=topofrange-7*interval
                    color=colors('brown');
                else
                    color=colors('gray');
                end
                mycolormap=[colors('gray');colors('brown');colors('purple');colors('blue');...
                    colors('sky blue');colors('green');colors('orange');colors('red')];
            else
                if pctoverlap(i)>=topofrange-interval
                    color='r';
                elseif pctoverlap(i)>=topofrange-2*interval
                    color=colors('orange');
                elseif pctoverlap(i)>=topofrange-3*interval
                    color=colors('green');
                elseif pctoverlap(i)>=topofrange-4*interval
                    color=colors('sky blue');
                elseif pctoverlap(i)>=topofrange-5*interval
                    color=colors('blue');
                else
                    color=colors('purple');
                end
                mycolormap=[colors('purple');colors('blue');...
                    colors('sky blue');colors('green');colors('orange');colors('red')];
            end
        else
            if pctoverlap(i)>=quantile(pctoverlap,0.25)
                color='r';
            elseif pctoverlap(i)>=quantile(pctoverlap,0.125)
                color=colors('orange');
            elseif pctoverlap(i)>=quantile(pctoverlap,0.0625)
                color=colors('green');
            elseif pctoverlap(i)>=quantile(pctoverlap,0.031)
                color=colors('sky blue');
            elseif pctoverlap(i)>=quantile(pctoverlap,0.0155)
                color=colors('blue');
            else
                color=colors('purple');
            end
            colorbarc=2.75;mycolormap=[colors('purple');colors('blue');colors('sky blue');colors('green');...
                colors('orange');colors('red')];
        end
        h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
            'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
    end
    %disp('line 780');disp(mycolormap);
    colormap(mycolormap);numcolors=size(mycolormap,1);
    if makefinal==0
        cbar=colorbar;set(cbar,'YDir','reverse');
        set(cbar,'YTick',[]);
        numplotsinfig=1;colorbartext;
    end
    thingbeingplotted=pctoverlap;units='';inclcblabel=0;
    if strcmp(var1,'ratio');titlec=3.75;prec=0.05;else titlec=3.5;prec=1;end
    if strcmp(var1,'wbt');var1name='WBT';elseif strcmp(var1,'t');var1name='T';elseif strcmp(var1,'q');var1name='q';end %useful for nice titles
    if strcmp(var2,'wbt');var2name='WBT';elseif strcmp(var2,'t');var2name='T';elseif strcmp(var2,'q');var2name='q';end %ditto
    if makefinal==1
        if panelnumber==1
            set(gca,'Position',[0 1.01-0.5*panelnumber 1 0.48]);
            text(-0.11,0.97,'a','units','normalized','fontsize',16,'fontname','arial','fontweight','bold');
        elseif panelnumber==numpanels
            clear titlec;clear colorbarc;
            cbar=colorbar;set(cbar,'YDir','reverse');
            set(cbar,'YTick',[]);
            colorbartext;
            cblabel='Percent';
            h=text(1.3,0.875,cblabel,'units','normalized','FontSize',18,'FontWeight','bold','FontName','Arial');
            set(h,'Rotation',90);
            set(gca,'Position',[0 1.01-0.5*panelnumber 1 0.48]);
            cpos=get(cbar,'Position');cpos(1)=0.85;cpos(2)=0.05;cpos(3)=0.017;cpos(4)=0.9;
            set(cbar,'Position',cpos);%disp(panelnumber);
            text(-0.11,0.97,'b','units','normalized','fontsize',16,'fontname','arial','fontweight','bold');
            %set(gca,'Position',[0.05 1.1-0.5*panelnumber 0.7 0.3],'units','normalized');
        end
    else
        cblabel='Percent';
        set(get(cbar,'Ylabel'),'String',cblabel,'FontSize',14,'FontWeight','bold','FontName','Arial');
        set(cbar,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
    end
    return; %stop here and then copy-and-paste the last couple lines
    %edamultipurposelegendcreator;
    curpart=2;figloc=figDir;
    if takenoverbymasterscript==1
        figname='mapwbttandwbtqscoresmaster';
    else
        figname=strcat('map',var1,var2,'scores',mastername);
    end
    highqualityfiguresetup;
    
    %Same thing for NARR gridpts
    plotnarrtoo=0;
    if plotnarrtoo==1
        clear temp;temp=pctoverlapnarr==0;pctoverlapnarr(temp)=NaN;
        cbmin=bottomofrange;cbmax=topofrange;mystep=interval;
        regionformap='usa';datatype='NARR';
        data={narrlats;narrlons;pctoverlapnarr};overlaydata=data;
        vararginnew={'variable';'generic scalar';'contour';1;'mystep';mystep;'plotCountries';1;...
            'caxismin';cbmin;'caxismax';cbmax;'overlaynow';0;'anomavg';'avg'};
        %vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=0;
        plotModelData(data,regionformap,vararginnew,datatype);
        curpart=1;highqualityfiguresetup;
        mycolormap=[colors('gray');colors('brown');colors('purple');colors('blue');...
            colors('sky blue');colors('green');colors('orange');colors('red')];
        colormap(mycolormap);
        caxisrange=[cbmin cbmax];caxis(caxisrange);
        cbar=colorbar;set(cbar,'YDir','reverse');
        set(cbar,'YTick',[]);
        colorbartext;
        if strcmp(var1,'ratio');titlec=3.75;prec=0.05;else titlec=3.5;prec=1;end
        if strcmp(var1,'wbt');var1name='WBT';elseif strcmp(var1,'t');var1name='T';elseif strcmp(var1,'q');var1name='q';end %useful for nice titles
        if strcmp(var2,'wbt');var2name='WBT';elseif strcmp(var2,'t');var2name='T';elseif strcmp(var2,'q');var2name='q';end %ditto
        edamultipurposelegendcreator;
        curpart=2;figloc=figDir;figname=strcat('map',var1,var2,'scoresnarr');
        highqualityfiguresetup;
        flexibleupperbound=0;
    end
end


%Histogram of T/WBT scores
if histogramtwbtscores==1
    curpart=1;highqualityfiguresetup;
    hist(twbtscore,10);
    title('Histogram of T/WBT Overlap Scores','FontSize',20,'FontWeight','bold','FontName','Arial');
    set(gca,'FontWeight','bold','fontname','arial','fontsize',12);
    xlabel('T/WBT Overlap Score','FontWeight','bold','fontname','arial','fontsize',16);
    ylabel('Count','FontWeight','bold','fontname','arial','fontsize',16);
    curpart=2;figloc=figDir;figname=strcat('histtwbtscores');
    highqualityfiguresetup;
end


%Map of difference between T and q terms (from determinetandqeffectsonwbt)
    %the nonlinear term is not as obviously meaningful
if maptqtermsdiff==1
    plotBlankMap(figc,'usa');figc=figc+1;
    curpart=1;highqualityfiguresetup;
    tqdiff=Ttermbystn-qtermbystn;
    for i=1:size(newstnNumList,1)
        if tqdiff(i)>=quantile(tqdiff,0.9)
            color='r';
        elseif tqdiff(i)>=quantile(tqdiff,0.75)
            color=colors('orange');
        elseif tqdiff(i)>=quantile(tqdiff,0.5)
            color=colors('green');
        elseif tqdiff(i)>=quantile(tqdiff,0.25)
            color=colors('sky blue');
        elseif tqdiff(i)>=quantile(tqdiff,0.1)
            color=colors('blue');
        else
            color=colors('purple');
        end
        h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
            'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
    end
    thingbeingplotted=tqdiff;units='';prec=1;
    colorbarc=2;titlec=12;
    edamultipurposelegendcreator;
    curpart=2;figloc=figDir;figname=strcat('maptqdiff');
    highqualityfiguresetup;
end

%Map of median value of top-XX WBT for each stn, slightly modified to plot only the contiguous US
%Include NCA regions as shaded in pastel colors
if mapmediantopxxwbtbystn==1
    if makefinal==1
        %if var==1;figc=figc+1;end
        dontclear=1;figure(figc);if twopanels==1;subplot(2,1,1);end
    else
        figc=figc+1;curpart=1;highqualityfiguresetup;
    end
    if twopanels==1;plotBlankMap(figc,'usa');hold on;curpart=1;highqualityfiguresetup;end
    mycolormap=colormaps('t','fewereven','not');colormap(flipud(mycolormap)); %6 colors
    if twopanels==1 %if twopanels=0, this will be plotted a little later on, after the NARR stuff
        for i=16:size(newstnNumList,1)
            if mediantopxxwbtbystn(i)>=quantile(mediantopxxwbtbystn(16:190),0.9)
                color=mycolormap(6,:);
            elseif mediantopxxwbtbystn(i)>=quantile(mediantopxxwbtbystn(16:190),0.75)
                color=mycolormap(5,:);
            elseif mediantopxxwbtbystn(i)>=quantile(mediantopxxwbtbystn(16:190),0.5)
                color=mycolormap(4,:);
            elseif mediantopxxwbtbystn(i)>=quantile(mediantopxxwbtbystn(16:190),0.25)
                color=mycolormap(3,:);
            elseif mediantopxxwbtbystn(i)>=quantile(mediantopxxwbtbystn(16:190),0.1)
                color=mycolormap(2,:);
            else
                color=mycolormap(1,:);
            end
            h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
                'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
        end
    end
    thingbeingplotted=mediantopxxwbtbystn;units='';prec=1;
    
    if makefinal==1
        if twopanels==1
            cpos(1)=0.15;cpos(2)=0.48;cpos(3)=0.6;cpos(4)=0.45;
        else
            cpos(1)=0.05;cpos(2)=0.1;cpos(3)=0.8;cpos(4)=0.8;
        end
        set(gca,'Position',cpos);clear colorbarc;clear titlec;edamultipurposelegendcreator;
    else
        curpart=2;figloc=figDir;figname='medianvaltopxxwbt';
        highqualityfiguresetup;titlec=18;
        colorbarc=2.75;colorbarlabel='Value (deg C)';inclcblabel=1;
        edamultipurposelegendcreator;
    end
    
    
    %Analogously, plot the same metric for the NARR heat waves
    if plotnarr==1
        for i=1:277
            for j=1:349
                mediantopxxwbtbynarr(i,j)=topXXdatawbtnarr(i,j,50,1);
            end
        end
        if twopanels==1;transparency=1;subplot(2,1,2);else transparency=0.5;end
        temp=mediantopxxwbtbynarr==0;mediantopxxwbtbynarr(temp)=NaN;
        cbmin=18;cbmax=30;mystep=2;
        regionformap='usa';datatype='NARR';
        data={narrlats;narrlons;mediantopxxwbtbynarr};underlaydata=data;
        vararginnew={'variable';'generic scalar';'underlayvariable';'generic scalar';
            'contour';1;'mystepunderlay';mystep;'plotCountries';1;'datatounderlay';data;...
            'underlaycaxismin';cbmin;'underlaycaxismax';cbmax;'overlaynow';0;'anomavg';'avg';...
            'transparency';transparency};
        if makefinal==1;vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=1;end
        plotModelData(data,regionformap,vararginnew,datatype);
        if twopanels==0;curpart=1;highqualityfiguresetup;end

        mycolormap=[mycolormap(6,:);mycolormap(5,:);mycolormap(4,:);mycolormap(3,:);mycolormap(2,:);mycolormap(1,:)];
        caxisrange=[cbmin cbmax];caxis(caxisrange);colormap(flipud(mycolormap));
        if makefinal~=1
            colorbarc=2.75;titlec=18;colorbarlabel='Value (deg C)';inclcblabel=1;
            edamultipurposelegendcreator;
            curpart=2;figloc=figDir;figname=strcat('avgdate',varlist{var},'narr');
            highqualityfiguresetup;
        else
            if twopanels==1;cpos(1)=0.15;cpos(2)=0.015;cpos(3)=0.6;cpos(4)=0.45;end
            set(gca,'Position',cpos);
        end
        
        %Plot stn data on top, if desired
        if twopanels==0
            %mycolormap=flipud(mycolormap);
            for i=16:size(newstnNumList,1)
                if mediantopxxwbtbystn(i)>=quantile(mediantopxxwbtbystn(16:190),0.9)
                    color=mycolormap(1,:);
                elseif mediantopxxwbtbystn(i)>=quantile(mediantopxxwbtbystn(16:190),0.75)
                    color=mycolormap(2,:);
                elseif mediantopxxwbtbystn(i)>=quantile(mediantopxxwbtbystn(16:190),0.5)
                    color=mycolormap(3,:);
                elseif mediantopxxwbtbystn(i)>=quantile(mediantopxxwbtbystn(16:190),0.25)
                    color=mycolormap(4,:);
                elseif mediantopxxwbtbystn(i)>=quantile(mediantopxxwbtbystn(16:190),0.1)
                    color=mycolormap(5,:);
                else
                    color=mycolormap(6,:);
                end
                h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
                    'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
            end
            thingbeingplotted=mediantopxxwbtbystn;units='';prec=1;
            colorbarc=2.75;colorbarlabel='Value (deg C)';inclcblabel=1;
            edamultipurposelegendcreator;
        end
    end
    title('Median Value of Top-100 WBT Daily Maxes','FontSize',20,'FontName','Arial','FontWeight','bold');
    if makefinal==1
        %Make one large colorbar for all subplots
        %cbar=colorbar;
        titlesz=16;labelsz=12;
        colorbarc=2.75;clear titlec;colorbarlabel='Value (deg C)';inclcblabel=1;
        edamultipurposelegendcreator;
        p90val=round2(quantile(thingbeingplotted,0.9),prec);
        p10val=round2(quantile(thingbeingplotted,0.1),prec);
        valspacing=(p90val-p10val)/4;
        val1=round2(p10val+valspacing,prec);
        val2=round2(p10val+valspacing*2,prec);
        val3=round2(p10val+valspacing*3,prec);
        ticklabel1=char(strcat('>=',num2str(p90val),{' '},units));
        ticklabel2=char(strcat(num2str(val3),'-',num2str(p90val),{' '},units));
        ticklabel3=char(strcat(num2str(val2),'-',num2str(val3),{' '},units));
        ticklabel4=char(strcat(num2str(val1),'-',num2str(val2),{' '},units));
        ticklabel5=char(strcat(num2str(p10val),'-',num2str(val1),{' '},units));
        exist hardlowerbound;
        if ans==1
            ticklabel6=char(strcat(num2str(p10val),{' '},units));
        else
            ticklabel6=char(strcat('<=',num2str(p10val),{' '},units));
        end
        clear hardlowerbound;
        cbar=colorbar('YTick',[0.083 0.25 0.417 0.583 0.75 0.917],...
            'YTickLabel',{ticklabel1,ticklabel2,ticklabel3,ticklabel4,ticklabel5,ticklabel6});
        %if inclcblabel==1;set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',18,'FontWeight','bold','FontName','Arial');end
        set(cbar,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
        %set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
        if twopanels==1;xpos=1.13;ypos=[1.82;1.52;1.22;0.92;0.62;0.32;1];else xpos=1.075;ypos=[1;0.8;0.6;0.4;0.2;0;0.45];end
        text(xpos,ypos(1),ticklabel1,'units','normalized','FontSize',labelsz,'FontWeight','bold','FontName','Arial');
        text(xpos,ypos(2),ticklabel2,'units','normalized','FontSize',labelsz,'FontWeight','bold','FontName','Arial');
        text(xpos,ypos(3),ticklabel3,'units','normalized','FontSize',labelsz,'FontWeight','bold','FontName','Arial');
        text(xpos,ypos(4),ticklabel4,'units','normalized','FontSize',labelsz,'FontWeight','bold','FontName','Arial');
        text(xpos,ypos(5),ticklabel5,'units','normalized','FontSize',labelsz,'FontWeight','bold','FontName','Arial');
        text(xpos,ypos(6),ticklabel6,'units','normalized','FontSize',labelsz,'FontWeight','bold','FontName','Arial');
        h=text(xpos+0.07,ypos(7),sprintf('Value (%cC)',char(176)),'units','normalized','FontSize',titlesz,'FontWeight','bold','FontName','Arial');
        set(h,'rotation',90);
        cpos=get(cbar,'Position');
        if twopanels==1
            cpos(1)=0.775;cpos(2)=0.1;cpos(3)=0.017;cpos(4)=0.8;
        else
            cpos(1)=0.875;cpos(2)=0.1;cpos(3)=0.017;cpos(4)=0.8;
        end
        set(cbar,'Position',cpos);
        curpart=2;figloc=figDir;figname='medianvaltopxxwbtnarr';
        highqualityfiguresetup;
    end
end

%Map of median standardized anomalies of T and q at hours of top-XX WBT, computed separately for each station
%These arrays are calculated in the tqanomsextremewbt loop of findmaxtwbt
%Also show the median standardized anomaly of the top-XX WBT itself, to see how 'extreme' it is
%Additional option: map ratio of median std anom of T to median std anom of q --> high (low) means T (q) contributes more to extreme WBT
if maptqstananomsduringextremewbt==1
    for var=variwfhere:variwlhere
        if var==1
            varname='T';thingtoplot=eval(['p50correspt' plotending ';']);
        elseif var==2
            varname='q';thingtoplot=eval(['p50correspq' plotending ';']);
        elseif var==3
            varname='WBT';thingtoplot=p50wbtanomstan;
        elseif var==4
            varname='T/q Ratio';thingtoplot=p50corresptanomstan./p50correspqanomstan;
        end
        
        if usequantiles==1
            bp1=round2(quantile(thingtoplot,0.9),0.01); %breakpoint 1
            bp2=round2(quantile(thingtoplot,0.75),0.01);
            bp3=round2(quantile(thingtoplot,0.5),0.01);
            bp4=round2(quantile(thingtoplot,0.25),0.01);
            bp5=round2(quantile(thingtoplot,0.1),0.01);
        elseif var==1 && strcmp(plotending,'') %preset values for T vals
            bp1=37;bp2=35;bp3=33;bp4=31;bp5=29;
        elseif var==1 && strcmp(plotending,'anomstan') %preset values for T stan anoms
            bp1=2;bp2=1.8;bp3=1.4;bp4=1.1;bp5=0.8;
        elseif var==2 && strcmp(plotending,'') %preset values for q vals
            bp1=21;bp2=19;bp3=17;bp4=15;bp5=13;
        elseif var==2 && strcmp(plotending,'anomstan') %preset values for q stan anoms
            bp1=2.4;bp2=2.2;bp3=2;bp4=1.8;bp5=1.6;
        elseif var==4 %ratio of T stan anoms to q stan anoms
            bp1=1;bp2=0.85;bp3=0.7;bp4=0.55;bp5=0.4;
        else
            disp('Please add some preset values to use here!');return;
        end
        if makefinal==0 || var==4
            plotBlankMap(figc,'usa');figc=figc+1;
            curpart=1;highqualityfiguresetup;
            %Set up colors to use
            vartoplot='t';
            moreorfewercolors='fewereven';
            curax=gca;
        else
            if panelnumber==1
                figure(figc);
                %Set up colors to use
                vartoplot='t';
                moreorfewercolors='fewereven';
            elseif panelnumber==2
                %Set up colors to use
                vartoplot='q';
                moreorfewercolors='fewereven';
            end
            
            if strcmp(plotending,'')
                plotBlankMap(figc,'usa');
            elseif strcmp(plotending,'anomstan')
                subplot(2,1,panelnumber);curax=subplot(2,1,panelnumber);
                plotBlankMap(figc,'usa');
                set(gca,'Position',[0 1.01-0.5*panelnumber 1 0.48]);
            end
        end
        if var<=3 && strcmp(plotending,'')
            mycolormap=colormaps(vartoplot,moreorfewercolors,'not');
        else
            mycolormap=colormaps('category','fewereven','not');
        end
        
        for i=1:size(newstnNumList,1)
            if thingtoplot(i)>=bp1
                color=mycolormap(6,:);
            elseif thingtoplot(i)>=bp2
                color=mycolormap(5,:);
            elseif thingtoplot(i)>=bp3
                color=mycolormap(4,:);
            elseif thingtoplot(i)>=bp4
                color=mycolormap(3,:);
            elseif thingtoplot(i)>=bp5
                color=mycolormap(2,:);
            else
                color=mycolormap(1,:);
            end
            h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
                'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
        end
        %if panelnumber==2;return;end
        thingbeingplotted=thingtoplot;units='';
        colorbarc=2.5;
        %Only add title if not a multipanel figure
        if makefinal==0;if var<=3;titlec=13;prec=0.2;elseif var==4;titlec=14;prec=0.05;end;end
        if strcmp(plotending,'') && var~=4;inclcblabel=1;else inclcblabel=0;end
        if inclcblabel==1
            if var==1
                colorbarlabel=strcat('Value (',sprintf('%c',char(176)),'C)');
            elseif var==2
                colorbarlabel=strcat('Value (g/kg)');
            end
            h=text(0.97,0.25,colorbarlabel,'units','normalized');
            set(h,'Rotation',90,'fontsize',16,'fontweight','bold','fontname','arial');
        end
        
        edamultipurposelegendcreator;
        
        curpart=2;figloc=figDir;
        if strcmp(plotending,'')
            figname=strcat('maptqvalsoption',num2str(var));
        elseif strcmp(plotending,'anomstan')
            figname=strcat('maptqstananomsoption',num2str(var));
        end
        highqualityfiguresetup;
    end
end

%Plot final figure of trends over time in the regional avg of stations' p50corresptanomstan and p50correspqanomstan
if plottrendsinregavgstnsp50corresptandq==1
    figure(figc);clf;figc=figc+1;
    curpart=1;highqualityfiguresetup;
    yearvec=(1981:2015)';
    for region=2:8
        h=subplot(4,2,region-1);
        if region==8;set(h,'pos',[0.3325 0.09 0.335 0.16]);end
        plot(yearvec,p50corresptanomstanbyregionandyear(region,:),'linewidth',2,'color','r');hold on;
        plot(yearvec,p50correspqanomstanbyregionandyear(region,:),'linewidth',2,'color','b');
        xlim([yeariwf yeariwl]);ylim([0 3]);
        set(gca,'fontsize',12,'fontname','arial','fontweight','bold');
        text(-0.11,1.05,figletterlabels{region-1},'units','normalized',...
            'fontsize',16,'fontname','arial','fontweight','bold');

        if region==4 || region==5;xpos=.35;else xpos=.4;end
        ypos=1.1;
        text(xpos,ypos,strcat(ncaregionnamemaster{region}),'units','normalized',...
                    'fontsize',14,'fontweight','bold','fontname','arial');
        %Add in shading to represent drought and pluvial summers
            %PDSI dataset starts in 1895
        for yr=1981:2015
            x=[yr+0.5 yr+0.5 yr+1.5 yr+1.5 yr];y=[0 2.98 2.98 0 0];
            if droughtspluvials(region,yr-1894)==1 %pluvial
                patch(x,y,-1*ones(size(x)),[0.98 0.88 1],'LineStyle','none'); %light purple
            elseif droughtspluvials(region,yr-1894)==-1 %drought
                patch(x,y,-1*ones(size(x)),[0.88 0.88 0.88],'LineStyle','none'); %light gray
            end
        end
    end
    curpart=2;figloc=figDir;figname='trendsinregavgcorresptandq';
    highqualityfiguresetup;
end

%Analogously, plot final figure of month-by-month p50correspt{val,anomstan} and p50correspq{val,anomstan}
if plotmonthbymonthregavgstnsp50corresptandq==1
    figure(figc);clf;figc=figc+1;
    curpart=1;highqualityfiguresetup;
    
    for region=2:8
        if region<=8
            h=subplot(4,2,region-1);
            if region==8;set(h,'pos',[0.3325 0.09 0.335 0.16]);end
            ax=gca;
            if strcmp(valoranomstan,'anomstan') %Standardized anomalies
                startDate=datenum('05-01-2016');endDate=datenum('09-30-2016');
                xData=linspace(startDate,endDate,5);
                plot(xData,eval(['p50correspt',valoranomstan,'byregionandmonth(region,1:5)']),'linewidth',2,'color','r');hold on;
                plot(xData,eval(['p50correspq',valoranomstan,'byregionandmonth(region,1:5)']),'linewidth',2,'color','b');hold on;
                ylim([0 4]);
                set(ax,'XTick',xData);
            else %Actual values
                startDate=datenum('05-01-2016');endDate=datenum('9-30-2016');
                xData=linspace(startDate,endDate,5);
                [ax,hline1,hline2]=plotyy(xData,p50corresptvalbyregionandmonth(region,1:5),xData,p50correspqvalbyregionandmonth(region,1:5));hold on;
                doextra=1;
                if doextra==1
                set(hline1,'linewidth',2,'color','r');set(hline2,'linewidth',2,'color','b');
                set(ax(1),'ytick',[]);set(ax(2),'ytick',[]);set(gca,'ytick',[]);
                set(ax(1),'YLim',[29 38]);set(ax(2),'YLim',[9 25]);
                set(ax(1),'YTick',[29:3:38]);set(ax(2),'YTick',[]);
                set(ax(2),'YTick',[9:4:25]);
                set(ax(2),'Box','Off');set(ax(1),'Box','Off'); %removes y1 & y2 ticks from the wrong sides
                set(ax,'XTick',[]);
                set(ax,'fontsize',12,'fontname','arial','fontweight','bold');
                ylabel(ax(1),'T (C)','color','r');ylabel(ax(2),'q (g/kg)','color','b');
                set(ax(1),'ycolor','r');set(ax(2),'ycolor','b');
                end
            end
            ax=gca;set(ax,'XTick',xData);
            datetick(ax,'x','mmm','keepticks');
            set(gca,'fontsize',12,'fontname','arial','fontweight','bold');
            text(-0.11,1.05,figletterlabels{region-1},'units','normalized',...
                'fontsize',16,'fontname','arial','fontweight','bold');
        else %regions 9 and 10 are actually EITHER SW coast and SW interior, OR AZ/NM and all other SW stns    
            subplot(4,2,3-1);if region==9;cla;end
            if region==9;markerstyle='s';else markerstyle='^';end
            if strcmp(valoranomstan,'anomstan') %Standardized anomalies
                plot(xData,eval(['p50correspt',valoranomstan,'byregionandmonth(region,:)']),'s','linewidth',2,'color','r','markersize',8);hold on;
                plot(xData,eval(['p50correspq',valoranomstan,'byregionandmonth(region,:)']),'s','linewidth',2,'color','b','markersize',8);hold on;
                if strcmp(valoranomstan,'anomstan');ylim([0 4]);end
            else %Actual values
                startDate=datenum('05-01-2016');endDate=datenum('9-30-2016');
                xData=linspace(startDate,endDate,5);
                [ax,hline1,hline2]=plotyy(xData,p50corresptvalbyregionandmonth(region,1:5),xData,p50correspqvalbyregionandmonth(region,1:5));hold on;
                set(hline1,'linewidth',2,'color','r','marker',markerstyle);set(hline2,'linewidth',2,'color','b','marker',markerstyle);
                set(ax(1),'ytick',[]);set(ax(2),'ytick',[]);set(gca,'ytick',[]);
                set(ax(1),'YLim',[29 41]);set(ax(2),'YLim',[9 25]);
                set(ax(1),'YTick',[29:4:41]);set(ax(2),'YTick',[]);
                set(ax(2),'YTick',[9:4:25]);
                set(ax(2),'Box','Off');set(ax(1),'Box','Off'); %removes y1 & y2 ticks from the wrong sides
                set(ax,'XTick',[]);
                set(ax,'fontsize',12,'fontname','arial','fontweight','bold');
                ylabel(ax(1),'T (C)','color','r');ylabel(ax(2),'q (g/kg)','color','b');
                set(ax(1),'ycolor','r');set(ax(2),'ycolor','b');
            end
        end
        %if region==4 || region==5;xpos=colpos+0.95;else xpos=colpos+1.0;end
        %if i==8;ypos=rowpos-0.08;else ypos=rowpos-0.05;end
        if region==4 || region==5;xpos=0.3;else xpos=0.35;end
        if region<=7;ypos=1.13;elseif region==8;ypos=1.09;end
        if region<=8
            text(xpos,ypos,strcat(ncaregionnamemaster{region}),'units','normalized',...
                    'fontsize',14,'fontweight','bold','fontname','arial');
        end
    end
    curpart=2;figloc=figDir;figname='monthbymonthregavgcorresptandq';
    highqualityfiguresetup;
    
    
    %Self-contained appendix code
    if plotappendix==1
        figure(1);clf;subplot(2,1,1);region=9;
        markerstyle='s';
        startDate=datenum('05-01-2016');endDate=datenum('9-30-2016');
        xData=linspace(startDate,endDate,5);
        [ax,hline1,hline2]=plotyy(xData,p50corresptanomstanreltomjjasoallhoursbyregionandmonth(region,1:5),...
            xData,p50correspqanomstanreltomjjasoallhoursbyregionandmonth(region,1:5));hold on;
        set(ax,'XTick',[]);
        set(hline1,'linewidth',2,'color','r','marker',markerstyle,'markerfacecolor','r');
        set(hline2,'linewidth',2,'color','b','marker',markerstyle,'markerfacecolor','b');
        set(ax(1),'ytick',[]);set(ax(2),'ytick',[]);set(gca,'ytick',[]);
        set(ax(1),'YLim',[0 7]);set(ax(2),'YLim',[0 4]);
        set(ax(1),'YTick',[0:1:7]);set(ax(2),'YTick',[0:1:4]);
        set(ax(2),'Box','Off');set(ax(1),'Box','Off'); %removes y1 & y2 ticks from the wrong sides
        %ylabel(ax(1),sprintf('T (%cC)',char(176)),'color','r','fontsize',16);
        %ylabel(ax(2),'q (g/kg)','color','b','fontsize',16);
        ylabel(ax(1),'Std Anom. of T','color','r','fontsize',16,'fontweight','bold');
        ylabel(ax(2),'Std Anom. of q','color','b','fontsize',16,'fontweight','bold');
        set(ax(1),'ycolor','r','fontsize',16,'fontweight','bold');set(ax(2),'ycolor','b','fontsize',16,'fontweight','bold');
        set(ax(1),'XTick',xData);datetick(ax(1),'x','mmm','keepticks');
        set(ax(2),'XTick',xData);datetick(ax(2),'x','mmm','keepticks');set(ax(2),'XTick',[]);
        ax=gca;
        set(ax,'fontsize',16,'fontname','arial','fontweight','bold');
        title('Southwest Coast','fontsize',16,'fontweight','bold','fontname','arial','units','normalized');
        subplot(2,1,2);region=10;
        markerstyle='^';
        startDate=datenum('05-01-2016');endDate=datenum('9-30-2016');
        xData=linspace(startDate,endDate,5);
        [ax,hline1,hline2]=plotyy(xData,p50corresptanomstanreltomjjasoallhoursbyregionandmonth(region,1:5),...
            xData,p50correspqanomstanreltomjjasoallhoursbyregionandmonth(region,1:5));hold on;
        set(ax,'XTick',[]);
        set(hline1,'linewidth',2,'color','r','marker',markerstyle,'markerfacecolor','r');
        set(hline2,'linewidth',2,'color','b','marker',markerstyle,'markerfacecolor','b');
        set(ax(1),'ytick',[]);set(ax(2),'ytick',[]);set(gca,'ytick',[]);
        set(ax(1),'YLim',[0 7]);set(ax(2),'YLim',[0 4]);
        set(ax(1),'YTick',[0:1:7]);set(ax(2),'YTick',[0:1:4]);
        set(ax(2),'Box','Off');set(ax(1),'Box','Off'); %removes y1 & y2 ticks from the wrong sides
        ylabel(ax(1),'Std Anom. of T','color','r','fontsize',16,'fontweight','bold');
        ylabel(ax(2),'Std Anom. of q','color','b','fontsize',16,'fontweight','bold');
        set(ax(1),'ycolor','r','fontsize',16,'fontweight','bold');set(ax(2),'ycolor','b','fontsize',16,'fontweight','bold');
        set(ax(1),'XTick',xData);datetick(ax(1),'x','mmm','keepticks');
        set(ax(2),'XTick',xData);datetick(ax(2),'x','mmm','keepticks');set(ax(2),'XTick',[]);
        ax=gca;
        %h=ylabel(ax(1),sprintf('T (%cC)',char(176)),'color','r','fontsize',16);
        %h=ylabel(ax(2),'q (g/kg)','color','b','fontsize',16);
        set(ax,'fontsize',16,'fontname','arial','fontweight','bold');
        title('Arizona/New Mexico','fontsize',16,'fontweight','bold','fontname','arial','units','normalized');
        
        curpart=2;figloc=figDir;figname='monthbymonthregavgcorresptandqappendix';
        highqualityfiguresetup;
    end
end

%Map of # of events represented among the top XX dates for each station
if mapnumberofevents==1
    for var=1:2
        plotBlankMap(figc,'usaminushawaii-tight');figc=figc+1;
        curpart=1;highqualityfiguresetup;
        if var==1
            numevents=numeventstbystn;varname='Temperatures';
        elseif var==2
            numevents=numeventswbtbystn;varname='Wet-Bulb Temperatures';
        end
        for i=1:size(newstnNumList,1)
            if numevents(i)>=quantile(numevents,0.9)
                color='r';
            elseif numevents(i)>=quantile(numevents,0.75)
                color=colors('orange');
            elseif numevents(i)>=quantile(numevents,0.5)
                color=colors('green');
            elseif numevents(i)>=quantile(numevents,0.25)
                color=colors('sky blue');
            elseif numevents(i)>=quantile(numevents,0.1)
                color=colors('blue');
            else
                color=colors('purple');
            end
            h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
                'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
        end
        thingbeingplotted=numevents;units='';prec=1;
        colorbarc=2;titlec=6;
        edamultipurposelegendcreator;
        curpart=2;figloc=figDir;figname=strcat('numevents',varlist{var});
        highqualityfiguresetup;
    end
end

%Map of # of years required to represent 50% of the top XX dates for each station
    %(smaller numbers mean greater concentration of extreme heat/humidity in certain years relative to others)
if mapnumberofyears==1
    for var=1:2
        plotBlankMap(figc,'usaminushawaii-tight');figc=figc+1;
        curpart=1;highqualityfiguresetup;
        if var==1
            numyears=numyearsrequired(1,:);varname='Temperatures';
        elseif var==2
            numyears=numyearsrequired(2,:);varname='Wet-Bulb Temperatures';
        end
        for i=1:size(newstnNumList,1)
            if numyears(i)>=quantile(numyears,0.9)
                color='r';
            elseif numyears(i)>=quantile(numyears,0.75)
                color=colors('orange');
            elseif numyears(i)>=quantile(numyears,0.5)
                color=colors('green');
            elseif numyears(i)>=quantile(numyears,0.25)
                color=colors('sky blue');
            elseif numyears(i)>=quantile(numyears,0.1)
                color=colors('blue');
            else
                color=colors('purple');
            end
            h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
                'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
        end
        thingbeingplotted=numyears;units='';prec=0.25;
        colorbarc=2;titlec=7;
        edamultipurposelegendcreator;
        curpart=2;figloc=figDir;figname=strcat('numyears',varlist{var});
        highqualityfiguresetup;
    end
end


%Average and st dev of top-XX dates of T and WBT, both to see what the spatial patterns of these are,
    %and to compare T and WBT for particular stations
%New windows are Jun 21-30, Jul 1-10, Jul 11-20, Jul 21-31, Aug 1-10, Aug 11-20, Aug 21-31, Sep 1-10
if maptwbtqdates==1
    %First, for averages
    for var=variwfhere:variwlhere
        if var==1
            avgmonth=avgmontht;avgday=avgdayt;varname='Temperatures';
        elseif var==2
            avgmonth=avgmonthwbt;avgday=avgdaywbt;varname='Wet-Bulb Temperatures';
            avgmonthnarr=avgmonthwbtnarr;avgdaynarr=avgdaywbtnarr;
        elseif var==3
            avgmonth=avgmonthq;avgday=avgdayq;varname='Specific Humidities';
        end
        
        if makefinal==1
            %if var==1;figc=figc+1;end
            dontclear=1;figure(figc);subplot(2,1,1);
        else
            figc=figc+1;curpart=1;highqualityfiguresetup;
        end
        plotBlankMap(figc,'usa');hold on;
        if makefinal==1
            if var==variwlhere;curpart=1;highqualityfiguresetup;end
        else
            curpart=1;highqualityfiguresetup;
        end
        
        for i=1:size(newstnNumList,1)
            if avgmonth(i)==6 && avgday(i)>=21 %Jun 21-30
                color='r';
            elseif avgmonth(i)==7 && avgday(i)<=10 %Jul 1-10
                color=colors('orange');
            elseif avgmonth(i)==7 && avgday(i)<=20 %Jul 11-20
                color=colors('green');
            elseif avgmonth(i)==7 %Jul 21-31
                color=colors('sky blue');
            elseif avgmonth(i)==8 && avgday(i)<=10 %Aug 1-10
                color=colors('blue');
            elseif avgmonth(i)==8 && avgday(i)<=20 %Aug 11-20
                color=colors('purple');
            elseif avgmonth(i)==8 %Aug 21-31
                color=colors('brown');
            elseif avgmonth(i)==9 && avgday(i)<=10 %Sep 1-10
                color=colors('gray');
            end
            h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
                'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
        end
        
        if makefinal==1
            if var==variwfhere;titlec=1;clear colorbarc;edamultipurposelegendcreator;else clear titlec;end
        else
            titlec=1;
        end
        mycolormap=[colors('gray');colors('brown');colors('purple');colors('blue');...
            colors('sky blue');colors('green');colors('orange');colors('red')];
        colormap(flipud(mycolormap));
        if makefinal~=1
            cbar=colorbar;set(cbar,'YDir','reverse');
            set(cbar,'YTickLabel',{'Jun 20','Jun 30','Jul 10','Jul 20',...
                'Jul 31','Aug 10','Aug 20','Aug 31','Sep 10'},'fontsize',10,'fontweight','bold',...
                'fontname','arial');
            colorbarc=1;edamultipurposelegendcreator;
        end
        if makefinal==1
            cpos(1)=0.15;cpos(2)=0.48;cpos(3)=0.6;cpos(4)=0.45;
            set(gca,'Position',cpos);
        else
            curpart=2;figloc=figDir;figname=strcat('avgdate',varlist{var});
            highqualityfiguresetup;
        end

        %Analogously, plot the same metric for the NARR heat waves
        %Either two panels or one, controlled by the variable twopanels
        if plotnarr==1
            cbmin=170;cbmax=250;mystep=10;
            regionformap='usa';datatype='NARR';
            data={narrlats;narrlons;avgdoywbtnarr};underlaydata=data;
            vararginnew={'variable';'generic scalar';'underlayvariable';'generic scalar';
                'contour';1;'mystepunderlay';mystep;'plotCountries';1;...
                'underlaycaxismin';cbmin;'underlaycaxismax';cbmax;'overlaynow';0;'anomavg';'avg';...
                'transparency';0.15;'nonewfig';1};
            if twopanels==1
                if makefinal==1;vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=1;subplot(2,1,2);end
                width=9;
            else %plot NARR & stn data in the same panel
                subplot(2,1,1);cpos(1)=0.1;cpos(2)=0.51;cpos(3)=0.7;cpos(4)=0.48;set(gca,'position',cpos);%disp('line 1440');
                width=9;
            end
            plotModelData(data,regionformap,vararginnew,datatype);
            
            curpart=1;highqualityfiguresetup;
            mycolormap=[colors('gray');colors('brown');colors('purple');colors('blue');...
                colors('sky blue');colors('green');colors('orange');colors('red')];
            colormap(flipud(mycolormap));
            caxisrange=[cbmin cbmax];caxis(caxisrange);
            text(-0.02,1.02,'a','fontname','arial','fontweight','bold','fontsize',16,'units','normalized');
            plotstndataontop=1;
            if makefinal~=1
                cbar=colorbar;set(cbar,'YDir','reverse');
                set(cbar,'YTickLabel',{'Jun 20','Jun 30','Jul 10','Jul 20',...
                    'Jul 31','Aug 10','Aug 20','Aug 31','Sep 10'},'fontsize',10,'fontweight','bold',...
                    'fontname','arial');
                titlec=1;edamultipurposelegendcreator;
                curpart=2;figloc=figDir;figname=strcat('avgdate',varlist{var},'narr');
                highqualityfiguresetup;
            elseif plotstndataontop==1
                for i=1:size(newstnNumList,1)
                    if avgmonth(i)==6 && avgday(i)>=21 %Jun 21-30
                        color='r';
                    elseif avgmonth(i)==7 && avgday(i)<=10 %Jul 1-10
                        color=colors('orange');
                    elseif avgmonth(i)==7 && avgday(i)<=20 %Jul 11-20
                        color=colors('green');
                    elseif avgmonth(i)==7 %Jul 21-31
                        color=colors('sky blue');
                    elseif avgmonth(i)==8 && avgday(i)<=10 %Aug 1-10
                        color=colors('blue');
                    elseif avgmonth(i)==8 && avgday(i)<=20 %Aug 11-20
                        color=colors('purple');
                    elseif avgmonth(i)==8 %Aug 21-31
                        color=colors('brown');
                    elseif avgmonth(i)==9 && avgday(i)<=10 %Sep 1-10
                        color=colors('gray');
                    end
                    h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
                        'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
                end
            else
                subplot(2,1,2);
                cpos(1)=0.15;cpos(2)=0.015;cpos(3)=0.6;cpos(4)=0.45;
                set(gca,'Position',cpos);
            end
        end
        
        if plotstndataontop==1 %if doing this, also plot dates for T extremes in an analogous second subplot
            %First plot avg date of T extremes from NARR
            subplot(2,1,2);cpos(1)=0.1;cpos(2)=0.01;cpos(3)=0.7;cpos(4)=0.48;set(gca,'position',cpos);
            text(-0.02,1.02,'b','fontname','arial','fontweight','bold','fontsize',16,'units','normalized');
            cbmin=170;cbmax=250;mystep=10;
            regionformap='usa';datatype='NARR';
            data={narrlats;narrlons;avgdoytnarr};underlaydata=data;
            vararginnew={'variable';'generic scalar';'underlayvariable';'generic scalar';
                'contour';1;'mystepunderlay';mystep;'plotCountries';1;...
                'underlaycaxismin';cbmin;'underlaycaxismax';cbmax;'overlaynow';0;'anomavg';'avg';...
                'transparency';0.15;'nonewfig';1};
            plotModelData(data,regionformap,vararginnew,datatype);
            curpart=1;highqualityfiguresetup;
            mycolormap=[colors('gray');colors('brown');colors('purple');colors('blue');...
                colors('sky blue');colors('green');colors('orange');colors('red')];
            colormap(flipud(mycolormap));
            caxisrange=[cbmin cbmax];caxis(caxisrange);
            
            %Then overlay with the same thing for stns
            avgmonth=avgmontht;avgday=avgdayt;varname='Temperatures';
            for i=1:size(newstnNumList,1)
                if avgmonth(i)==6 && avgday(i)>=21 %Jun 21-30
                    color='r';
                elseif avgmonth(i)==7 && avgday(i)<=10 %Jul 1-10
                    color=colors('orange');
                elseif avgmonth(i)==7 && avgday(i)<=20 %Jul 11-20
                    color=colors('green');
                elseif avgmonth(i)==7 %Jul 21-31
                    color=colors('sky blue');
                elseif avgmonth(i)==8 && avgday(i)<=10 %Aug 1-10
                    color=colors('blue');
                elseif avgmonth(i)==8 && avgday(i)<=20 %Aug 11-20
                    color=colors('purple');
                elseif avgmonth(i)==8 %Aug 21-31
                    color=colors('brown');
                elseif avgmonth(i)==9 && avgday(i)<=10 %Sep 1-10
                    color=colors('gray');
                end
                h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
                    'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
            end
        end
        if makefinal==1
            %Make one large colorbar for all subplots
            cbar=colorbar;%colorbarlabel='Date';
            titlesz=16;
            set(cbar,'YDir','reverse');
            set(cbar,'YTickLabel',{'Jun 20','Jun 30','Jul 10','Jul 20',...
                'Jul 31','Aug 10','Aug 20','Aug 31','Sep 10'},'fontsize',10,'fontweight','bold',...
                'fontname','arial');
            %set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
            set(cbar,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
            cbarpos=get(cbar,'Position');
            if twopanels==1
                cbarpos(1)=0.775;cbarpos(2)=0.1;cbarpos(3)=0.017;cbarpos(4)=0.8;set(cbar,'Position',cbarpos);
            else
                cbarpos(1)=0.875;cbarpos(2)=0.1;cbarpos(3)=0.017;cbarpos(4)=0.8;set(cbar,'Position',cbarpos,'units','normalized');
            end
            curpart=2;figloc=figDir;figname=strcat('avgdate',varlist{var},'narr');
            highqualityfiguresetup;
        end
    end
    %END OF LOOP FOR FIGURE THAT IS PRIMARILY OF INTEREST
    %Second, for st devs
    if plotstdev==1
        for var=2:2
            if var==1
                stdevhere=stdevdoyt;varname='Temperatures';
            elseif var==2
                stdevhere=stdevdoywbt;varname='Wet-Bulb Temperatures';
            elseif var==3
                stdevhere=stdevdoyq;varname='Specific Humidities';
            end
            figc=figc+1;clf;plotBlankMap(figc,'usa');figc=figc+1;
            curpart=1;highqualityfiguresetup;
            for i=1:size(newstnNumList,1)
                if stdevhere(i)>=quantile(stdevhere,0.9)
                    color='r';
                elseif stdevhere(i)>=quantile(stdevhere,0.75)
                    color=colors('orange');
                elseif stdevhere(i)>=quantile(stdevhere,0.5)
                    color=colors('green');
                elseif stdevhere(i)>=quantile(stdevhere,0.25)
                    color=colors('sky blue');
                elseif stdevhere(i)>=quantile(stdevhere,0.1)
                    color=colors('blue');
                else
                    color=colors('purple');
                end
                h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
                    'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
            end
            thingbeingplotted=stdevhere;units='days';prec=1;
            colorbarc=2;titlec=2;
            edamultipurposelegendcreator;
            curpart=2;figloc=figDir;figname=strcat('stdevdate',varlist{var});
            highqualityfiguresetup;
            close;
        end
    end
end

%Average and st dev of top-XX hours of T, WBT, and q for each city, both to see the spatial patterns 
    %and to compare them for particular stations
%IF UNDEFINED, RERUN CALCTWBTQHOURS AND CALCTWBTQDATES LOOPS OF FINDMAXTWBT
if maptwbtqhours==1
    %First, for averages
    for var=variwfhere:variwlhere
        if var==1
            avghour=avghourofmaxt;varname='Temperatures';
        elseif var==2
            avghour=avghourofmaxwbt;varname='Wet-Bulb Temperatures';
        elseif var==3
            avghour=avghourofmaxq;varname='Specific Humidities';
        end
        if makefinal==1
            %if var==1;figc=figc+1;end
            dontclear=1;figure(figc);%subplot(2,1,1);
        else
            figc=figc+1;curpart=1;highqualityfiguresetup;
        end
        plotBlankMap(figc,'usa');hold on;
        if makefinal==1
            %if var==variwlhere;curpart=1;highqualityfiguresetup;end
        else
            curpart=1;highqualityfiguresetup;
        end
        for i=1:size(newstnNumList,1)
            if avghour(i)<12
                color='r';
            elseif avghour(i)<13
                color=colors('orange');
            elseif avghour(i)<14
                color=colors('green');
            elseif avghour(i)<15
                color=colors('sky blue');
            elseif avghour(i)<16
                color=colors('blue');
            elseif avghour(i)<17
                color=colors('purple');
            elseif avghour(i)<18
                color=colors('brown');
            else
                color=colors('gray');
            end
            h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
                'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
        end
        if makefinal==1
            if var==variwfhere;titlec=4;clear colorbarc;edamultipurposelegendcreator;else clear titlec;end
        else
            titlec=4;
        end
        %mycolormap=[colors('gray');colors('brown');colors('purple');colors('blue');...
        %    colors('sky blue');colors('green');colors('orange');colors('red')];
        mycolormap=[colors('red');colors('orange');colors('green');colors('sky blue');...
            colors('blue');colors('purple');colors('brown');colors('gray')];
        colormap(mycolormap);
        cbar=colorbar;set(cbar,'YDir','reverse');
        if makefinal~=1
            set(cbar,'YTickLabel',{'Jun 20','Jun 30','Jul 10','Jul 20',...
                'Jul 31','Aug 10','Aug 20','Aug 31','Sep 10'},'fontsize',10,'fontweight','bold',...
                'fontname','arial');
            colorbarc=3;edamultipurposelegendcreator;
        end
        if makefinal==1
            %cpos(1)=0.15;cpos(2)=0.48;cpos(3)=0.6;cpos(4)=0.45;
            cpos(1)=0.05;cpos(2)=0.15;cpos(3)=0.8;cpos(4)=0.7;
            set(gca,'Position',cpos);
        else
            curpart=2;figloc=figDir;figname=strcat('avghourofmax',varlist{var});
            highqualityfiguresetup;
        end
    end 
        
    %Analogously, plot the same metric for the NARR heat waves
    for var=2:2
        if plotnarr==1
            cbmin=12;cbmax=18;mystep=1;
            regionformap='usa';datatype='NARR';
            data={narrlats;narrlons;avghourofmaxnarr};overlaydata=data;
            vararginnew={'variable';'generic scalar';'contour';1;'mystep';mystep;'plotCountries';1;...
                'caxismin';cbmin;'caxismax';cbmax;'overlaynow';0;'anomavg';'avg'};
            if makefinal==1;vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=1;subplot(2,1,2);end
            [~,~,~,~,~,~,~,~,~]=plotModelData(data,regionformap,vararginnew,datatype);
            curpart=1;highqualityfiguresetup;
            mycolormap=[colors('gray');colors('brown');colors('purple');colors('blue');...
                colors('sky blue');colors('green');colors('orange');colors('red')];
            colormap(flipud(mycolormap));
            caxisrange=[cbmin cbmax];caxis(caxisrange);
            if makefinal~=1
                cbar=colorbar;set(cbar,'YDir','reverse');
                set(cbar,'YTickLabel',[]);
                text(1.07,1,'09:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.07,0.875,'12:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.07,0.75,'13:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.07,0.625,'14:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.07,0.5,'15:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.07,0.375,'16:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.07,0.25,'17:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.07,0.125,'18:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.07,0,'21:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                titlec=4;edamultipurposelegendcreator;
                curpart=2;figloc=figDir;figname=strcat('avghour',varlist{var},'narr');
                highqualityfiguresetup;
            else
                subplot(2,1,2);
                cpos(1)=0.15;cpos(2)=0.015;cpos(3)=0.6;cpos(4)=0.45;
                set(gca,'Position',cpos);
            end
        end
        if makefinal==1
            %Make one large colorbar for all subplots
            cbar=colorbar;
            set(cbar,'YDir','reverse');
            if plotnarr==1
                set(cbar,'YTick',[0.1 0.1+.7/8 0.1+1.4/8]);
                set(cbar,'YTickLabel',[]);
                text(1.13,0.2+8*1.76/8,'09:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.13,0.2+7*1.76/8,'12:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.13,0.2+6*1.76/8,'13:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.13,0.2+5*1.76/8,'14:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.13,0.2+4*1.76/8,'15:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.13,0.2+3*1.76/8,'16:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.13,0.2+2*1.76/8,'17:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.13,0.2+1.76/8,'18:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.13,0.2,'21:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                set(cbar,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
                cpos=get(cbar,'Position');cpos(1)=0.775;cpos(2)=0.1;cpos(3)=0.017;cpos(4)=0.8;
            else
                set(cbar,'YTick',[]);
                set(cbar,'YTickLabel',[]);
                text(1.08,1.09,'09:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.08,-.08+7*1.17/8,'12:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.08,-.08+6*1.17/8,'13:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.08,-.08+5*1.17/8,'14:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.08,-.08+4*1.17/8,'15:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.08,-.08+3*1.17/8,'16:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.08,-.08+2*1.17/8,'17:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.08,-.08+1.17/8,'18:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                text(1.08,-0.08,'21:00','units','normalized','fontsize',14,'fontname','arial','fontweight','bold');
                set(cbar,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
                cpos=get(cbar,'Position');cpos(1)=0.88;cpos(2)=0.1;cpos(3)=0.017;cpos(4)=0.8;
            end
            set(cbar,'Position',cpos,'units','normalized');
            curpart=2;figloc=figDir;figname=strcat('avghour',varlist{var},'narr');
            highqualityfiguresetup;
        end
    end
    
    %Second, for st devs
    if plotstdev==1
        for var=2:2
            if var==1
                stdevhere=stdevhourofmaxt;varname='Temperatures';
            elseif var==2
                stdevhere=stdevhourofmaxwbt;varname='Wet-Bulb Temperatures';
            elseif var==3
                stdevhere=stdevhourofmaxq;varname='Specific Humidities';
            end
            figc=figc+1;clf;plotBlankMap(figc,'usaminushawaii-tight');figc=figc+1;
            curpart=1;highqualityfiguresetup;
            for i=1:size(newstnNumList,1)
                if stdevhere(i)>=quantile(stdevhere,0.9)
                    color='r';
                elseif stdevhere(i)>=quantile(stdevhere,0.75)
                    color=colors('orange');
                elseif stdevhere(i)>=quantile(stdevhere,0.5)
                    color=colors('green');
                elseif stdevhere(i)>=quantile(stdevhere,0.25)
                    color=colors('sky blue');
                elseif stdevhere(i)>=quantile(stdevhere,0.1)
                    color=colors('blue');
                else
                    color=colors('purple');
                end
                h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
                    'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
            end
            thingbeingplotted=stdevhere;units='hrs';prec=0.1;
            colorbarc=2;titlec=5;
            edamultipurposelegendcreator;
            curpart=2;figloc=figDir;figname=strcat('stdevhourofmax',varlist{var});
            highqualityfiguresetup;
        end
    end
end

if plotp25p75plot==1
    %Sort stations by NCA region, to ease in creating the plot
    for i=1:8;regionsvec{i}=0;counter(i)=0;end
    for stn=1:190
        counter(ncaregionnum{stn})=counter(ncaregionnum{stn})+1;
        regionsvec{ncaregionnum{stn}}(counter(ncaregionnum{stn}))=stn;
    end
    neworder=[regionsvec{1} regionsvec{2} regionsvec{3} regionsvec{4} regionsvec{5} regionsvec{6} regionsvec{7} regionsvec{8}];
    %Re-order arrays that will be plotted according to this new ordering
    for i=1:190
        p25hourofmaxqsortbyreg(i)=p25hourofmaxq(neworder(i));p75hourofmaxqsortbyreg(i)=p75hourofmaxq(neworder(i));
        p25hourofmaxtsortbyreg(i)=p25hourofmaxt(neworder(i));p75hourofmaxtsortbyreg(i)=p75hourofmaxt(neworder(i));
        p25hourofmaxwbtsortbyreg(i)=p25hourofmaxwbt(neworder(i));p75hourofmaxwbtsortbyreg(i)=p75hourofmaxwbt(neworder(i));
        p25doyqsortbyreg(i)=p25doyq(neworder(i));p75doyqsortbyreg(i)=p75doyq(neworder(i));
        p25doytsortbyreg(i)=p25doyt(neworder(i));p75doytsortbyreg(i)=p75doyt(neworder(i));
        p25doywbtsortbyreg(i)=p25doywbt(neworder(i));p75doywbtsortbyreg(i)=p75doywbt(neworder(i));
    end
    
    %Distribution of dates and hours of max for each variable in each region
    alldoybyreg={};allhourbyreg={};
    for var=1:3
        if var==1;topXXbystn=topXXtbystn;elseif var==2;topXXbystn=topXXwbtbystn;else topXXbystn=topXXqbystn;end
        totalcountbyreg=zeros(8,1);
        for stn=1:190
            thisreg=ncaregionnum{stn};
            for row=1:100
                totalcountbyreg(thisreg)=totalcountbyreg(thisreg)+1;
                alldoybyreg{var,thisreg}(totalcountbyreg(thisreg))=DatetoDOY(topXXbystn{stn}(row,3),topXXbystn{stn}(row,4),topXXbystn{stn}(row,2));
                allhourbyreg{var,thisreg}(totalcountbyreg(thisreg))=topXXbystn{stn}(row,5);
            end
        end
    end
    
    %Now, make a boxplot of each variable in each region, for a. dates of max and b. hours of max
    ncaregionnameshort={'NW';'SW';'GPN';'GPS';'MW';'SE';'NE'};
    
    %Plot boxplot of days of year
    figure(figc);clf;figc=figc+1;
    curpart=1;highqualityfiguresetup;
    for i=2:8
        subplot(1,7,i-1);
        x1=alldoybyreg{1,i};x2=alldoybyreg{2,i};x3=alldoybyreg{3,i};x=[x1 x2 x3];
        g=[ones(size(x1)),2*ones(size(x2)),3*ones(size(x3))];
        bh=boxplot(x,g,'Labels',{'T','WBT','q'});set(bh,'linewidth',2);
        text(0.35,-0.08,ncaregionnameshort{i-1},'units','normalized','fontsize',16,'fontweight','bold','fontname','arial');
        set(gca,'xtick',[]);set(gca,'xticklabel',[]);
        if i~=2;set(gca,'ytick',[]);set(gca,'yticklabel',[]);end
        set(gca,'fontsize',14,'fontweight','bold','fontname','arial');
        set(findobj(gca,'Type','text'),'fontsize',14,'fontweight','bold','fontname','arial');
        if i==2;ylabel('Day of Year','fontsize',14,'fontweight','bold','fontname','arial');end
        if i==2
            cpos=[0.12 0.137 0.09 0.787];
            set(gca,'Position',cpos,'units','normalized');
        end
        
    end
    curpart=2;figloc=figDir;figname=strcat('p25p75dayofmaxfinal');
    highqualityfiguresetup;
    
    %Plot boxplot of hours of day
    figure(figc);clf;figc=figc+1;
    curpart=1;highqualityfiguresetup;
    for i=2:8
        subplot(1,7,i-1);
        x1=allhourbyreg{1,i};x2=allhourbyreg{2,i};x3=allhourbyreg{3,i};x=[x1 x2 x3];
        g=[ones(size(x1)),2*ones(size(x2)),3*ones(size(x3))];
        bh=boxplot(x,g,'Labels',{'T','WBT','q'});set(bh,'linewidth',2);
        text(0.35,-0.08,ncaregionnameshort{i-1},'units','normalized','fontsize',16,'fontweight','bold','fontname','arial');
        set(gca,'xtick',[]);set(gca,'xticklabel',[]);
        if i~=2;set(gca,'ytick',[]);set(gca,'yticklabel',[]);end
        set(gca,'fontsize',14,'fontweight','bold','fontname','arial');
        set(findobj(gca,'Type','text'),'fontsize',14,'fontweight','bold','fontname','arial');
        if i==2;ylabel('Hour of Day (LST)','fontsize',14,'fontweight','bold','fontname','arial');end
        if i==2
            cpos=[0.12 0.137 0.09 0.787];
            set(gca,'Position',cpos,'units','normalized');
        end
    end
    curpart=2;figloc=figDir;figname=strcat('p25p75hourofmaxfinal');
    highqualityfiguresetup;
    
    %Plot 25th & 75th percentiles of hours as ranked by T, WBT, and q, filled in
    if dooldstyleplot==1
        figure(figc);clf;figc=figc+1;
        curpart=1;highqualityfiguresetup;
        subplot(2,1,1);hold on;
        x=1:175;
        %X=[x,fliplr(x)];
        %Y=[p25hourofmaxqsortbyreg(16:190),fliplr(p75hourofmaxqsortbyreg(16:190))];
        %fill(X,Y,'b');
        plot(x,p25hourofmaxqsortbyreg(16:190),'b','linewidth',2);
        plot(x,p25hourofmaxwbtsortbyreg(16:190),'g','linewidth',2);
        plot(x,p25hourofmaxtsortbyreg(16:190),'r','linewidth',2);
        plot(x,p75hourofmaxqsortbyreg(16:190),'b','linewidth',2);
        plot(x,p75hourofmaxwbtsortbyreg(16:190),'g','linewidth',2);
        plot(x,p75hourofmaxtsortbyreg(16:190),'r','linewidth',2);
        %Y=[p25hourofmaxwbtsortbyreg(16:190),fliplr(p75hourofmaxwbtsortbyreg(16:190))];
        %fill(X,Y,'g');
        %Y=[p25hourofmaxtsortbyreg(16:190),fliplr(p75hourofmaxtsortbyreg(16:190))];
        %fill(X,Y,'r');
        ylim([0 24]);xlim([1 175]);
        legend('q','WBT','T','Location','NortheastOutside');
        set(gca,'fontsize',14,'fontweight','bold','fontname','arial');
        ylabel('Hour of Day (LST)','fontsize',14,'fontweight','bold','fontname','arial');
        %title('25th-75th Percentile Range of Hour of Maximum, by Ranking Variable',...
        %    'fontsize',20,'fontweight','bold','fontname','arial');
        %text(180,12,'q','fontsize',18,'fontweight','bold','fontname','arial');
        set(gca,'Xtick',[0 14 33 56 77 114 152 175]);
        set(gca,'Xticklabel',[]);
        text(6,-2,'NW','fontsize',14,'fontweight','bold','fontname','arial');
        text(22,-2,'SW','fontsize',14,'fontweight','bold','fontname','arial');
        text(43,-2,'GPN','fontsize',14,'fontweight','bold','fontname','arial');
        text(65,-2,'GPS','fontsize',14,'fontweight','bold','fontname','arial');
        text(94,-2,'MW','fontsize',14,'fontweight','bold','fontname','arial');
        text(131,-2,'SE','fontsize',14,'fontweight','bold','fontname','arial');
        text(162,-2,'NE','fontsize',14,'fontweight','bold','fontname','arial');
        subplot(2,1,2);hold on;
        plot(x,p25doyqsortbyreg(16:190),'b','linewidth',2);
        plot(x,p25doywbtsortbyreg(16:190),'g','linewidth',2);
        plot(x,p25doytsortbyreg(16:190),'r','linewidth',2);
        plot(x,p75doyqsortbyreg(16:190),'b','linewidth',2);
        plot(x,p75doywbtsortbyreg(16:190),'g','linewidth',2);
        plot(x,p75doytsortbyreg(16:190),'r','linewidth',2);
        ylim([140 290]);
        set(gca,'Ytick',[150 175 200 225 250 275]);
        legend('q','WBT','T','Location','NortheastOutside');
        set(gca,'fontsize',14,'fontweight','bold','fontname','arial');
        ylabel('Day of Year','fontsize',14,'fontweight','bold','fontname','arial');
        set(gca,'Xtick',[0 14 33 56 77 114 152 175]);
        set(gca,'Xticklabel',[]);
        text(6,130,'NW','fontsize',14,'fontweight','bold','fontname','arial');
        text(22,130,'SW','fontsize',14,'fontweight','bold','fontname','arial');
        text(43,130,'GPN','fontsize',14,'fontweight','bold','fontname','arial');
        text(65,130,'GPS','fontsize',14,'fontweight','bold','fontname','arial');
        text(94,130,'MW','fontsize',14,'fontweight','bold','fontname','arial');
        text(131,130,'SE','fontsize',14,'fontweight','bold','fontname','arial');
        text(162,130,'NE','fontsize',14,'fontweight','bold','fontname','arial');
    
        curpart=2;figloc=figDir;figname=strcat('p25p75hourofmaxfinal');
        highqualityfiguresetup;
    end
end

%Histogram of hours of occurrence for each region
%Hard to see many (if any) differences between regions in this formulation
if histogramhoursofoccurrencebyregion==1
    for var=2:2
        for region=1:8
            thisregionhoursofmax=allhoursofmaxbyregion{2,region}; %rows are stations within region, columns are ranking of day within 100
                %(but all hours of max will be treated equally in making these histograms)
            c=1;
            for i=1:size(thisregionhoursofmax,1)
                for j=1:size(thisregionhoursofmax,2)
                    thingtoplot(c)=thisregionhoursofmax(i,j);c=c+1;
                end
            end
            
            %Make the histogram itself
            edges=0:1:24;
            figure(figc);figc=figc+1;
            hist(thingtoplot,edges);xlim([-1 24]);
        end
    end
end

%Histogram of dates of occurrence (i.e. months) for each region -- intended
    %to illustrate that all of these occur in JJA
if histogramdatesofoccurrencebyregion==1
    figure(figc);figc=figc+1;curpart=1;highqualityfiguresetup;
    numrowstomake=4;numcolstomake=2;
    for region=2:8
        yearsofmax=topXXwbtbyregionsorted{region}(1:100,1);
        monthsofmax=topXXwbtbyregionsorted{region}(1:100,2);
        datesofmax=topXXwbtbyregionsorted{region}(1:100,3);
        doysofmax=DatetoDOY(monthsofmax,datesofmax,yearsofmax);

        %Make the histogram itself
        edges=150:10:260;
        subplot(numrowstomake,numcolstomake,region-1);
        %hist(doysofmax,edges);
        h=histogram(doysofmax,edges);h.Normalization='probability';
        xlim([145 265]);
        set(gca,'fontweight','bold','fontname','arial','fontsize',12);
        text(0.15,-0.28,'Jun','fontweight','bold','fontname','arial','fontsize',12,'units','normalized');
        text(0.4,-0.28,'Jul','fontweight','bold','fontname','arial','fontsize',12,'units','normalized');
        text(0.65,-0.28,'Aug','fontweight','bold','fontname','arial','fontsize',12,'units','normalized');
        text(0.9,-0.28,'Sep','fontweight','bold','fontname','arial','fontsize',12,'units','normalized');
        title(ncaregionnameslong{region-1},'fontweight','bold','fontname','arial','fontsize',14);
        text(-0.15,1.2,figletterlabels{region-1},'fontweight','bold','fontname','arial','fontsize',14,'units','normalized');
        
        %Position each subplot
        rownow=round2((region-1)/numcolstomake,1,'ceil');
        if rem(region-1,2)==0;colnow=2;else colnow=1;end
        disp('Rownow is:');disp(rownow);disp('Colnow is:');disp(colnow);
        if rownow==1;rownowpos=0.23;elseif rownow==2;rownowpos=0.46;elseif rownow==3;rownowpos=0.69;else rownowpos=0.92;end
        if colnow==1;colnowpos=0.08;elseif colnow==2;colnowpos=0.54;end
        if region==8;colnowpos=0.31;end
        set(gca,'Position',[colnowpos 1-rownowpos 0.38 0.14]);
    end
    figloc=figDir;figname='histdatesofoccurrence';
    curpart=2;highqualityfiguresetup;
end

%Difference between 1. avg hour of extreme T and avg hour of extreme q, and 
    %2. avg date of extreme T and avg date of extreme q
if maptqhoursanddatesdiffs==1
    for option=1:2
        if option==1
            avgdiff=avghourofmaxt-avghourofmaxq;optionname='hours';optionnametitle='Hour';
        elseif option==2
            avgdiff=avgdoyt-avgdoyq;optionname='dates';optionnametitle='Date';
        end
        plotBlankMap(figc,'usaminushawaii-tight');figc=figc+1;
        curpart=1;highqualityfiguresetup;
        for i=1:size(newstnNumList,1)
            if avgdiff(i)>=quantile(avgdiff,0.9)
                color='r';
            elseif avgdiff(i)>=quantile(avgdiff,0.75)
                color=colors('orange');
            elseif avgdiff(i)>=quantile(avgdiff,0.5)
                color=colors('green');
            elseif avgdiff(i)>=quantile(avgdiff,0.25)
                color=colors('sky blue');
            elseif avgdiff(i)>=quantile(avgdiff,0.1)
                color=colors('blue');
            else
                color=colors('purple');
            end
            h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
                'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
        end
        thingbeingplotted=avgdiff;units='';prec=0.5;
        colorbarc=2;titlec=15;
        edamultipurposelegendcreator;
        curpart=2;figloc=figDir;figname=strcat('maptqdiff',optionname);
        highqualityfiguresetup;
    end
end

%Histograms of hours of top-XX T and WBT for selected cities
if histogramtwbthoursselcities==1
    for city=1:size(selindivstns,1)
        for var=1:2
            if var==1
                arrforhist=topXXtbystn{selindivstns(city)};titledescr='Temperature';
            else
                arrforhist=topXXwbtbystn{selindivstns(city)};titledescr='Wet-Bulb Temperature';
            end
            arrforhist=arrforhist(:,5)-newstnTZList(selindivstns(city)); %hours only, in LST
            for j=1:size(arrforhist)
                if arrforhist(j)<=0;arrforhist(j)=arrforhist(j)+24;end
            end
            figure(figc);clf;figc=figc+1;
            centers=round2(min(arrforhist),0.5):0.5:round2(max(arrforhist),0.5);
            hist(arrforhist,centers);
            xlim([min(arrforhist)-1 max(arrforhist)+1]);
            title(sprintf('Histogram of Top-100-%s Times for %s',titledescr,newstnNameList{selindivstns(city)}),...
                'fontname','arial','fontweight','bold','fontsize',20);
            set(gca,'fontname','arial','fontweight','bold','fontsize',14);
            xlabel('Hour of Day (LST)','fontname','arial','fontweight','bold','fontsize',16);
            ylabel('Count','fontname','arial','fontweight','bold','fontsize',16);
        end
    end
end

%Line graph of 5th, 50th, and 95th percentiles of T and WBT by hour for selected stations
if plothourlytracestwbt==1
    timesforlabels={'12 AM, Day -3';'12 PM, Day -3';'12 AM, Day -2';'12 PM, Day -2';'12 AM, Day -1';...
        '12 PM, Day -1';'12 AM, Day 0';'12 PM, Day 0';'12 AM, Day 1';'12 PM, Day 1';'12 AM, Day 2';...
        '12 PM, Day 2';'12 AM, Day 3';'12 PM, Day 3';'12 AM, Day 4'};
    %for stn=1:size(selindivstns,1)
    for stn=11:11
        figure(figc);clf;figc=figc+1;curpart=1;highqualityfiguresetup;
        subplot(2,1,1);
        plot(pct95ttrace{stn},'r','linewidth',2);hold on;plot(pct50ttrace{stn},'g','linewidth',2);plot(pct5ttrace{stn},'linewidth',2);
        xlim([0 168]);if stn==11;ylim([10 45]);end
        ylabel('Temperature (C)','fontname','arial','fontweight','bold','fontsize',16);
        set(gca,'xtick',0:12:168);set(gca,'XTickLabel',timesforlabels,'fontname','arial','fontweight','bold','fontsize',14);
        xticklabel_rotate([],45,[],'fontsize',12,'fontname','arial','fontweight','bold');
        legend({'95th pct';'50th pct';'5th pct'},'FontSize',16,'FontWeight','bold',...
                'FontName','Arial','Location','NortheastOutside');
        title(sprintf('Hourly T For Weeks Centered on the Top 100 Hottest T Days: %s',selindivstnsnames{stn}),...
            'fontname','arial','fontweight','bold','fontsize',20);
        set(gca,'fontname','arial','fontweight','bold','fontsize',14);
        
        
        subplot(2,1,2);
        plot(pct95wbttrace{stn},'r','linewidth',2);hold on;plot(pct50wbttrace{stn},'g','linewidth',2);plot(pct5wbttrace{stn},'linewidth',2);
        xlim([0 168]);
        ylabel('Wet-Bulb Temperature (C)','fontname','arial','fontweight','bold','fontsize',16);
        set(gca,'xtick',0:12:168);set(gca,'XTickLabel',timesforlabels,'fontname','arial','fontweight','bold','fontsize',14);
        xticklabel_rotate([],45,[],'fontsize',12,'fontname','arial','fontweight','bold');
        legend({'95th pct';'50th pct';'5th pct'},'FontSize',16,'FontWeight','bold',...
                'FontName','Arial','Location','NortheastOutside');
        title('Hourly WBT','fontname','arial','fontweight','bold','fontsize',20);
        set(gca,'fontname','arial','fontweight','bold','fontsize',14);
        curpart=2;figloc=figDir;figname=strcat('hourlytracestwbt',num2str(stn));
        highqualityfiguresetup;
    end
end

%Plots of anomalies of T, WBT, and q averaged for each station over the weeks surrounding each extreme-WBT day (no overlap of days allowed)
if plottopXXtraces==1
    figure(figc);clf;figc=figc+1;curpart=1;highqualityfiguresetup;
    xvec=-84:83;
    timesforlabels={'12 AM, Day -3';'12 PM, Day -3';'12 AM, Day -2';'12 PM, Day -2';'12 AM, Day -1';...
        '12 PM, Day -1';'12 AM, Day 0';'12 PM, Day 0';'12 AM, Day 1';'12 PM, Day 1';'12 AM, Day 2';...
        '12 PM, Day 2';'12 AM, Day 3';'12 PM, Day 3';'12 AM, Day 4'};
    for region=2:8
        h=subplot(4,2,region-1);
        if region==8;set(h,'pos',[0.3325 0.09 0.335 0.16]);end
        plot(xvec,squeeze(tanomtraceregavg{region}),'r','linewidth',2);hold on;
        plot(xvec,squeeze(wbtanomtraceregavg{region}),'g','linewidth',2);
        plot(xvec,squeeze(qanomtraceregavg{region}),'b','linewidth',2);
        %xlim([0 168]);
        %set(gca,'xtick',0:12:168);set(gca,'XTickLabel',timesforlabels,'fontname','arial','fontweight','bold','fontsize',14);
        %xticklabel_rotate([],45,[],'fontsize',12,'fontname','arial','fontweight','bold');
        xlim([-84 83]);
        if region==1;ylim([0 5]);elseif region==2;ylim([-2 7]);elseif region==3;ylim([-2 3]);elseif region==4;ylim([-2 5]);
            elseif region==5;ylim([-2 3]);elseif region==6;ylim([0 5]);elseif region==7;ylim([-1 3]);elseif region==8;ylim([0 6]);end
        set(gca,'fontsize',12,'fontweight','bold','fontname','arial');
        set(gca,'xtick',-72:24:72);
        ylim([-2.5 7.5]);
        if region==4 || region==5;xpos=colpos+0.95;else xpos=colpos+1.0;end
        %if i==8;ypos=rowpos-0.08;else ypos=rowpos-0.05;end
        text(xpos,ypos+0.06,strcat(ncaregionnamemaster{region}),'units','normalized',...
                    'fontsize',14,'fontweight','bold','fontname','arial');
    end
    curpart=2;figloc=figDir;figname='topXXtracesfinal';
    highqualityfiguresetup;
end

%Bar graph of occurrences of top-XX T and WBT by decade and region
%This perhaps should be normalized by the number of invalid station-year combos, but OTOH in most years this is fewer than 10%
if bargraphoccurrences==1
    for var=1:2
        if var==1
            normnumoccur=normnumoccurt;varname='T';ypostitle=48.5;
        else
            normnumoccur=normnumoccurwbt;varname='WBT';ypostitle=48.5;
        end
        figure(figc);clf;figc=figc+1;
        curpart=1;highqualityfiguresetup;
        decadelabel={'1980s';'1990s';'2000s';'2010s*2'};
        for i=1:8
            subplot(2,4,i);
            bar([0.7 2.15 3.85 5.3],normnumoccur(i,:));
            if i==1;text(2,ypostitle,sprintf('Occurrence of top-100 %s Days by Region and Decade',varname),...
                    'FontSize',20,'FontWeight','bold','FontName','Arial');end
            title(ncaregionnamemaster{i},'FontSize',16,'FontWeight','bold','FontName','Arial');
            text(0,-2,decadelabel{1},'FontWeight','bold','fontname','arial','fontsize',11);
            text(1.5,-2,decadelabel{2},'FontWeight','bold','fontname','arial','fontsize',11);
            text(3,-2,decadelabel{3},'FontWeight','bold','fontname','arial','fontsize',11);
            text(4.5,-2,decadelabel{4},'FontWeight','bold','fontname','arial','fontsize',11);
            set(gca,'XTickLabel','');
            set(gca,'FontWeight','bold','fontname','arial','fontsize',12);
            %xlabel('Decade','FontWeight','bold','fontname','arial','fontsize',16);
            if i==1 || i==5;ylabel('Avg Count per Station','FontWeight','bold','fontname','arial','fontsize',16);end
        end
        curpart=2;figloc=figDir;figname=strcat('bargraphoccurrencesbydecade',varname);
        highqualityfiguresetup;
    end
end

%Line graph of occurrences of top-XX T and WBT by year and region
%Array derived using old method of computing regional hot days: allregionsyearc or allregionsyearcbystn
%Array derived using new method: avg3highestbyregion or avg3highestbystn
if linegraphoccurrencebyyearandregion==1
    regionalcolorstouse=varycolor(7);
    if plotregavgcounts==1
        yearvec=yeariwf:yeariwl;
        for var=1:3
            figure(figc);clf;figc=figc+1;
            curpart=1;highqualityfiguresetup;
            if var==1
                arrtouse=topXXtbyregionsorted;varname='T';ypostitle=47;legendloc='NortheastOutside';
            elseif var==2
                arrtouse=topXXwbtbyregionsorted;varname='WBT';ypostitle=58;legendloc='NortheastOutside';
            elseif var==3
                arrtouse=topXXqbyregionsorted;varname='q';ypostitle=58;legendloc='NortheastOutside';
            end
            
            for i=1:8
                plot(yearvec,arrtouse{i}(1:100,1),'Color',regionalcolorstouse(i,:),'LineWidth',2);hold on;
                title(sprintf('Year of Occurrence of Top-100 %s Days, by Region',varname),...
                        'FontSize',20,'FontWeight','bold','FontName','Arial');
                set(gca,'FontWeight','bold','fontname','arial','fontsize',12);
                xlabel('Year','FontWeight','bold','fontname','arial','fontsize',16);
                ylabel('Region-Averaged Percent of the 100 Days Set in Each Year','FontWeight','bold','fontname','arial','fontsize',16);
            end
            legend({'NW';'SW';'GPN';'GPS';'MW';'SE';'NE'},'FontSize',18,'FontWeight','bold',...
                'FontName','Arial','Location',legendloc);
            curpart=2;figloc=figDir;figname=strcat('linegraphoccurrencesbyyear',varname);
            highqualityfiguresetup;
        end
    %Plot intra-region variance, also normalizing plots by # missing months for each region, and also,
        %for the individual-station plots, taking out (by making NaN) stn-year combinations with any missing months
    %For WBT only, plot includes region-average NARR-gridpt line as well, for purposes of comparison/validation
    elseif showvariancewithinregion==1
        for var=2:2
            if var==1
                if avg3==1
                    arrtouse=avg3highesttbystn;arrtousereg=avg3highesttbyregion;
                else
                    arrtouse=allregionsyearcbystn{1};arrtousereg=allregionsyearc{1};
                end
                varname='T';ypostitle=47;legendloc='Northeast';units=' (C)';
            elseif var==2
                if avg3==1
                    arrtouse=avg3highestwbtbystn;arrtousereg=avg3highestwbtbyregion;
                else
                    arrtouse=allregionsyearcbystn{2};arrtousereg=allregionsyearc{2};
                    arrtouseregnarr=allregionsyearcnarr{2};
                end
                varname='WBT';ypostitle=58;legendloc='Northwest';units=' (C)';
            elseif var==3
                if avg3==1
                    arrtouse=avg3highestqbystn;arrtousereg=avg3highestqbyregion;
                else
                    arrtouse=allregionsyearcbystn{3};arrtousereg=allregionsyearc{3};
                end
                varname='q';ypostitle=58;legendloc='Northwest';units=' (g/kg)';
            end
            
            if makefinal==1
                figure(figc);clf;figc=figc+1;hold on;
                curpart=1;highqualityfiguresetup;
                axissz=12;labelsz=10;titlesz=12;
            else
                axissz=14;labelsz=18;titlesz=20;
            end
            for regionhere=2:8
                if makefinal==0
                    figure(figc);clf;figc=figc+1;
                    curpart=1;highqualityfiguresetup;
                end
                
                if makefinal==1;h=subplot(4,2,regionhere-1);temp=get(h,'pos');end
                if regionhere==8;set(h,'pos',[0.3325 0.09 0.335 0.16]);end
                
                yearvec=yeariwf:yeariwl;
                anomcurvectoplot={};
                
                %Do the plotting of individual stations, to get a visualization of the variance within each region
                %Each is centered around its own mean (so differences in mean are adjusted for, but differences in st dev are not)
                for stnwithinregion=1:size(stnordinateseachregion{regionhere},2)
                    %But first, add NaNs where stn-year combinations have any missing months
                    if avg3==1
                        curvectoplot=arrtouse(stnordinateseachregion{regionhere}(stnwithinregion),:);
                        meancurvectoplot=nanmean(curvectoplot);
                        plot(yearvec,curvectoplot-meancurvectoplot,'Color',colors('gray'));hold on;
                    else
                        curvectoplot=squeeze(arrtouse(:,regionhere,stnwithinregion));
                        plot(yearvec,curvectoplot,'Color',colors('gray'));hold on;
                    end
                end
                
                %Also plot the regional average, using whichever metric we have chosen to define it
                if avg3==1
                    meanarrtousereg=mean(arrtousereg(regionhere,:));
                    plot(yearvec,arrtousereg(regionhere,:)-meanarrtousereg,'Color',regionalcolorstouse(regionhere-1,:),'linewidth',3);
                else
                    normallregionsyearc=arrtousereg(:,regionhere);
                    plot(yearvec,normallregionsyearc,'Color',regionalcolorstouse(regionhere-1,:),'linewidth',3);
                end
                
                %Finally, plot as a dashed line the NARR regional average
                if avg3==0
                    normallregionsyearcnarr=arrtouseregnarr(:,regionhere);
                    plot(yearvec,normallregionsyearcnarr,'--','Color',regionalcolorstouse(regionhere-1,:),'linewidth',3);
                end
                
                if regionhere==1;theornot='';else theornot='the ';end %for Alaska
                if regionhere==3 && avg3==0;ylim([0 50]);elseif avg3==1;ylim([-5 7]);end
                xlim([1980 2015]);
                set(gca,'fontname','arial','fontweight','bold','fontsize',axissz);
                if makefinal==0;xlabel('Year','fontname','arial','fontweight','bold','fontsize',labelsz);end
                if avg3==1
                    if makefinal==0
                        ylabel(strcat('Anomaly from 1981-2015 Average',units),'fontname','arial','fontweight','bold','fontsize',labelsz);
                        title(sprintf('Average of the 3 Highest %s Days Per Year: %s',...
                        varname,ncaregionnamemaster{regionhere}),'fontname','arial','fontweight','bold','fontsize',titlesz);
                    else
                        t=title(sprintf(figletterlabels{regionhere-1}),'fontname','arial','fontweight','bold','fontsize',titlesz);
                        set(t,'horizontalalignment','left');set(t,'units','normalized');
                        h1=get(t,'position');set(t,'position',[-0.1 h1(2) h1(3)]);
                    end
                else
                    if makefinal==0
                        ylabel('Number of Days','fontname','arial','fontweight','bold','fontsize',labelsz);
                        title(sprintf('Number of Top-100 %s Days Per Year: %s',...
                        varname,ncaregionnamemaster{regionhere}),'fontname','arial','fontweight','bold','fontsize',titlesz);
                    else
                        t=title(strcat('(',sprintf(figletterlabels{regionhere-1}),')'),'fontname','arial','fontweight','bold','fontsize',titlesz);
                        set(t,'horizontalalignment','left');set(t,'units','normalized');
                        h1=get(t,'position');set(t,'position',[-0.1 h1(2) h1(3)]);
                    end
                end
                
                if makefinal==0
                    if avg3==1;figdescrip='top3daysavg';else figdescrip='occurrencesbyyear';end
                    curpart=2;figloc=figDir;figname=strcat('linegraph',figdescrip,'var',varname,shortregnames{regionhere});
                    highqualityfiguresetup;close;
                end
                if regionhere==4 || regionhere==5;xpos=0.28;else xpos=0.38;end
                text(xpos,1.09,strcat(ncaregionnamemaster{regionhere}),'units','normalized',...
                    'fontsize',14,'fontweight','bold','fontname','arial');
            end
            
            if makefinal==1
                if avg3==1;figdescrip='top3daysavg';else figdescrip='occurrencesbyyear';end
                curpart=2;figloc=figDir;figname=strcat('linegraph',figdescrip,'var',varname,'final');
                highqualityfiguresetup;
            end
        end
    elseif showselindivstns==1
        for stn=1:size(selindivstns,1)
            thisstnnum=newstnNumList(selindivstns(stn));
            figure(figc);clf;figc=figc+1;
            for var=1:2
                if var==1
                    allregionscbystn=allregionsyearcbystn{1};varname='T';color='r';
                else
                    allregionscbystn=allregionsyearcbystn{2};varname='WBT';color='b';
                end
                plot(yearvec,allregionscbystn(:,selindivstnsregions(stn),selindivstnsnumwithinregion(stn)),...
                    'Color',color,'linewidth',2);hold on;
                if var==2;title(sprintf('Top-%d T and WBT Occurrence by Year: %s',numdates,selindivstnsnames{stn}),...
                       'fontname','arial','fontweight','bold','fontsize',20);end
                xlabel('Year','fontname','arial','fontweight','bold','fontsize',16);
                ylabel('Percent of Occurrences in a Given Year','fontname','arial','fontweight','bold','fontsize',16);
                legend({'T','WBT'},'fontname','arial','fontweight','bold','fontsize',16);
                set(gca,'fontname','arial','fontweight','bold','fontsize',14);
                if stn~=7;ylim([0 30]);end
            end
        end
    elseif useseasonalmeans==1 %instead of top-XX counts (this is mainly intended for comparison only, not deep analysis)
        for var=2:2
            if var==1
                seasonalmeanbystn=seasonalmeantbystn;seasonalmeanbyregion=seasonalmeantbyregion;
                varname='T';ypostitle=47;legendloc='Northeast';units=' (C)';
            elseif var==2
                seasonalmeanbystn=seasonalmeanwbtbystn;seasonalmeanbyregion=seasonalmeanwbtbyregion;
                varname='WBT';ypostitle=58;legendloc='Northwest';units=' (C)';
            elseif var==3
                seasonalmeanbystn=seasonalmeanqbystn;seasonalmeanbyregion=seasonalmeanqbyregion;
                varname='q';ypostitle=58;legendloc='Northwest';units=' (g/kg)';
            end
            for regionhere=2:8
                if makefinal==1
                    if regionhere==1
                        figure(figc);clf;figc=figc+1;
                        curpart=1;highqualityfiguresetup;
                    end
                    h=subplot(4,2,regionhere-1);
                    if regionhere==8;set(h,'pos',[0.3325 0.09 0.335 0.16]);end
                else
                    figure(figc);clf;figc=figc+1;
                    curpart=1;highqualityfiguresetup;
                end
                yearvec=yeariwf:yeariwl;
                
                stnlistthisregion=stnordinateseachregion{regionhere};
                %Do the plotting of individual stations, to get a visualization of the variance within each region
                for stn=1:maxnumstns
                    outputhere=checkifthingsareelementsofvector(stnlistthisregion,stn);
                    if outputhere==1
                        curvectoplot=seasonalmeanbystn(stn,:);
                        avgofcurvectoplot=nanmean(curvectoplot);
                        curvectoplotanom{stn}=curvectoplot-avgofcurvectoplot;
                        %refvec=badmonthscbystndividedbyregion(:,regionhere,stnwithinregion);
                        %temp=refvec>=1;
                        %curvectoplot(temp)=NaN;
                        savedstuff{stn}=curvectoplotanom{stn};
                        plot(yearvec,curvectoplotanom{stn},'Color',colors('gray'));hold on;
                    end
                end
                %Also plot the regional average
                avgofseasonalmeanbyregion=nanmean(seasonalmeanbyregion(regionhere,:));
                seasonalmeanbyregionanom=seasonalmeanbyregion(regionhere,:)-avgofseasonalmeanbyregion;
                plot(yearvec,seasonalmeanbyregionanom,'Color',regionalcolorstouse(regionhere-1,:),'linewidth',3);
                %Set up axes, title, etc.
                if regionhere==1;theornot='';else theornot='the ';end
                
                set(gca,'fontname','arial','fontweight','bold','fontsize',12);
                xlim([1980 2015]);ylim([-5 5]);
                if makefinal==1
                else
                    xlabel('Year','fontname','arial','fontweight','bold','fontsize',16);
                    ylabel(sprintf('Anomaly from 1981-2015 Average%s',units),'fontname','arial','fontweight','bold','fontsize',16);
                    title(sprintf('Anomalies of JJA-Average Daily-Max %s: %s',...
                        varname,ncaregionnamemaster{regionhere}),'fontname','arial','fontweight','bold','fontsize',20);
                end
                curpart=2;figloc=figDir;
                if makefinal~=1
                    figname=strcat('linegraphseasonalmeanvar',varname,shortregnames{regionhere});
                    highqualityfiguresetup;
                    close;
                end
            end
            if makefinal==1
                figname=strcat('linegraphseasonalmeanvar',varname,'final');
                highqualityfiguresetup;
            end
        end
    elseif usetop3daysavg==1 %average of top-3 days in each year (a defensible alternative to counts)
        for var=2:2
            if var==1
                avg3bystn=tavgeachstn;avg3byregion=tavgoverstns;
                varname='T';ypostitle=47;legendloc='Northeast';units=' (C)';
            elseif var==2
                avg3bystn=wbtavgeachstn;avg3byregion=wbtavgoverstns;
                varname='WBT';ypostitle=58;legendloc='Northwest';units=' (C)';
            elseif var==3
                avg3bystn=qavgeachstn;avg3byregion=qavgoverstns;
                varname='q';ypostitle=58;legendloc='Northwest';units=' (g/kg)';
            end
            for regionhere=3:3
                figure(figc);clf;figc=figc+1;
                curpart=1;highqualityfiguresetup;
                yearvec=yeariwf:yeariwl;
                
                stnlistthisregion=stnordinateseachregion{regionhere};
                %Do the plotting of individual stations, to get a visualization of the variance within each region
                for stn=1:maxnumstns
                    outputhere=checkifthingsareelementsofvector(stnlistthisregion,stn);
                    if outputhere==1
                        curvectoplot=avg3bystn(stn,:);
                        avgofcurvectoplot=nanmean(curvectoplot);
                        curvectoplotanom{stn}=curvectoplot-avgofcurvectoplot;
                        %refvec=badmonthscbystndividedbyregion(:,regionhere,stnwithinregion);
                        %temp=refvec>=1;
                        %curvectoplot(temp)=NaN;
                        savedstuff{stn}=curvectoplotanom{stn};
                        plot(yearvec,curvectoplotanom{stn},'Color',colors('gray'));hold on;
                    end
                end
                %Also plot the regional average
                meanavg3byregion=nanmean(avg3byregion(regionhere,:));
                avg3byregionanom=avg3byregion(regionhere,:)-meanavg3byregion;
                plot(yearvec,avg3byregionanom,'Color',regionalcolorstouse(regionhere,:),'linewidth',3);
                %Set up axes, title, etc.
                if regionhere==1;theornot='';else theornot='the ';end
                set(gca,'fontname','arial','fontweight','bold','fontsize',14);
                xlabel('Year','fontname','arial','fontweight','bold','fontsize',16);
                ylabel(sprintf('Anomaly from 1981-2015 Average%s',units),'fontname','arial','fontweight','bold','fontsize',16);
                title(sprintf('Anomalies of Top-3-Day-Average Daily-Max %s: %s',...
                    varname,ncaregionnamemaster{regionhere}),'fontname','arial','fontweight','bold','fontsize',20);
                curpart=2;figloc=figDir;figname=strcat('linegraphtop3daysavgvar',varname,shortregnames{regionhere});
                highqualityfiguresetup;close;
            end
        end
    end
end

%Scatterplot of regional interannual variance/st dev of top-XX T vs of top-XX WBT
if makescatterregionalinterannvar==1
    for region=1:8
        thisregiontvar(region)=std(allregionsyearc{1}(:,region));
        thisregionwbtvar(region)=std(allregionsyearc{2}(:,region));
    end
    figure(figc);clf;figc=figc+1;
    colorstouse=varycolor(8);
    for region=1:8
        plot(thisregionwbtvar(region),thisregiontvar(region),'Color',colorstouse(region,:),...
            'Marker','s','MarkerFaceColor',colorstouse(region,:),'MarkerEdgeColor',colorstouse(region,:),...
            'MarkerSize',10,'Marker','s');hold on;
    end
    xlim([0 5]);ylim([0 5]);
    xlabel('St. Dev. of Interannual Top-100-WBT-Days Occurrence (Days)','fontname','arial','fontweight','bold','fontsize',16);
    ylabel('St. Dev. of Interannual Top-100-T-Days Occurrence (Days)','fontname','arial','fontweight','bold','fontsize',16);
    title('Scatterplot of Interannual Standard Deviations of Extreme T and WBT, by Region',...
        'fontname','arial','fontweight','bold','fontsize',20);
    set(gca,'fontname','arial','fontweight','bold','fontsize',12);
    legend({'AK';'NW';'SW';'GPN';'GPS';'MW';'SE';'NE'},'FontSize',16,'FontWeight','bold',...
                'FontName','Arial','Location','Northeast');
end

%Map of the interannual variance of top-XX days for all the stations
%Note: it's called variance but can extremely easily become st. dev. as well...
if mapinterannualvarbystn==1
    for var=1:2
        if var==1
            allregionscbystn=allregionsyearcbystnnoreg{1};varname='T';
        else
            allregionscbystn=allregionsyearcbystnnoreg{2};varname='WBT';
        end
        for stn=1:size(newstnNumList,1)
            interannvarthisstn(stn)=std(allregionscbystn(:,stn));
        end
        %Now that all the stations are done for this variable, create the map!
        plotBlankMap(figc,'usaminushawaii-tight');figc=figc+1;
        curpart=1;highqualityfiguresetup;
        for stn=1:size(newstnNumList,1)
            stnlat=newstnNumListlats(stn);
            stnlon=newstnNumListlons(stn);
            if interannvarthisstn(stn)>=quantile(interannvarthisstn,0.9)
                 color='r';
            elseif interannvarthisstn(stn)>=quantile(interannvarthisstn,0.75)
                color=colors('orange');
            elseif interannvarthisstn(stn)>=quantile(interannvarthisstn,0.5)
                color=colors('green');
            elseif interannvarthisstn(stn)>=quantile(interannvarthisstn,0.25)
                color=colors('sky blue');
            elseif interannvarthisstn(stn)>=quantile(interannvarthisstn,0.1)
                color=colors('blue');
            else
                color=colors('purple');
            end
            h=geoshow(stnlat,stnlon,'DisplayType','Point','Marker','s',...
                'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
        end
        thingbeingplotted=interannvarthisstn;units='days';prec=0.1;
        colorbarc=2;titlec=8;
        edamultipurposelegendcreator;
        curpart=2;figloc=figDir;figname=strcat('interannvarbystn',varlist{var});
        highqualityfiguresetup;
    end
end


%Map of the interannual correlation between the count of top-XX WBT days in a year and the Jun-Aug SST anomaly in a region of interest
if mapcorrelsstwbt==1
    for var=1:2
        if var==1
            correlsst=correlsstt;varname='T';
        elseif var==2
            correlsst=correlsstwbt;varname='WBT';
        end
        plotBlankMap(figc,'usaminushawaii-tight');figc=figc+1;
        curpart=1;highqualityfiguresetup;
        howtoexamine='highest';
        if strcmp(howtoexamine,'regular')
            pctstouse=[0.9;0.75;0.5;0.25;0.1];
        elseif strcmp(howtoexamine,'lowest')
            pctstouse=[0.25;0.125;0.0625;0.031;0.155];
        elseif strcmp(howtoexamine,'highest')
            pctstouse=[0.9845;0.969;0.9375;0.875;0.75];
        end
        for stn=1:size(newstnNumList,1)
            stnlat=newstnNumListlats(stn);
            stnlon=newstnNumListlons(stn);
            if correlsst(stn)>=quantile(correlsst,pctstouse(1))
                 color='r';
            elseif correlsst(stn)>=quantile(correlsst,pctstouse(2))
                color=colors('orange');
            elseif correlsst(stn)>=quantile(correlsst,pctstouse(3))
                color=colors('green');
            elseif correlsst(stn)>=quantile(correlsst,pctstouse(4))
                color=colors('sky blue');
            elseif correlsst(stn)>=quantile(correlsst,pctstouse(5))
                color=colors('blue');
            else
                color=colors('purple');
            end
            h=geoshow(stnlat,stnlon,'DisplayType','Point','Marker','s',...
                'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
        end
        thingbeingplotted=correlsst;units='';prec=0.01;
        if strcmp(howtoexamine,'regular');colorbarc=5;else colorbarc=6;end
        titlec=9;month1='Jun';month2='Aug';
        edamultipurposelegendcreator;
        curpart=2;figloc=figDir;figname=strcat('mapcorrelsst',varname,roishort,howtoexamine,detrremark,shortsstdataset);
        highqualityfiguresetup;
    end
end


%Map of the interannual correlation between the count of top-XX WBT days in a year for a region or station,
    %and the Jun-Aug SST anomaly for every gridpt on the planet, with significant gridpts hatched
%With 35 years, the cutoff for significance at the 95% confidence level is r=0.33
%" "                                               99%                     r=0.44
if mapcorrelssteverygridptwbt==1
    if usedetrended==1
        detrremark='detr';detrtitleremark=' (Detrended)';
    else
        detrremark='';detrtitleremark='';
    end
    for var=1:1
        if var==1
            correlsst=correlsstteverygridptregions;varname='T';
        elseif var==2
            correlsst=correlsstwbteverygridptregions;varname='WBT';
        end
        howtoexamine='regular';
        curpart=1;highqualityfiguresetup;
        for region=5:5
            %Get the data for this region
            roiname=ncaregionnamemaster{region};
            if region==1;theornot='';else theornot='the ';end
            temp=double(correlsst(:,:,region));
            newtemp=[temp(91:180,:);temp(1:90,:)];
            underlaydata={double(ersstlats);double(ersstlons);temp};
            
            %The old way, (attempting to) use geoshow
            dooldway=0;
            if dooldway==1
                worldmap world;mapproj='mercator';mlabel off;plabel off;
                southlat=-90;northlat=90;westlon=-180;eastlon=180;
                Z=flipud(underlaydata{3}');
                R=georasterref('RasterSize',size(Z),'Latlim',[-90 90],'Lonlim',[-180 180]);
                geoshow(Z,R,'ZData',zeros(size(Z)),'CData',Z);
                caxisRange=[-0.8 0.8];caxis(caxisRange);cb=colorbar;
                set(get(cb,'Ylabel'),'String','This is my colorbar label');
                temp=abs(Z)>=cutoffcorrelval;
                adjlats=ersstlats';adjlons=[ersstlons-180]'; %if doubts, verify the correctness of these lat/lon manipulations
                boxcornerlat=zeros(size(temp,1),size(temp,2));boxcornerlon=zeros(size(temp,1),size(temp,2));
                boxhatch=0;
                for i=1:size(temp,1)
                    for j=1:size(temp,2)
                        if temp(i,j)==1 %a significant value
                            boxcornerlat(i,j)=adjlats(i,j);boxcornerlon(i,j)=adjlons(i,j);boxhatch(i,j)=1;
                        else
                            boxhatch(i,j)=0;
                        end
                    end
                end
                newboxhatch=boxhatch;%newboxcornerlat=flipud(boxcornerlat);newboxcornerlon=flipud(boxcornerlon);
                for i=1:size(temp,1)
                    for j=1:size(temp,2)
                        if newboxhatch(i,j)==1
                            newroutelat=-boxcornerlat(i,j);newroutelon=boxcornerlon(i,j);
                            geoshow([newroutelat newroutelat+2],[newroutelon newroutelon+2],'linewidth',3,'color','k');
                        end
                    end
                end
            end
            
            %The new way, using imagescnan
            datarsu=flipud(fliplr(underlaydata{3})');
            latsrsu=flipud(fliplr(ersstlats)');
            lonsrsu=flipud(fliplr(ersstlons)');
            figure(figc);clf;figc=figc+1;
            imagescnan(datarsu,'NanColor',colors('gray'));
            temp2=abs(datarsu)>=cutoffcorrelval;
            boxcornerlat=zeros(size(datarsu,1),size(datarsu,2));
            boxcornerlon=zeros(size(datarsu,1),size(datarsu,2));
            boxhatch=0;
            for i=1:size(temp2,1)
                for j=1:size(temp2,2)
                    if temp2(i,j)==1 %a significant gridpt
                        boxcornerlat(i,j)=latsrsu(i,j);boxcornerlon(i,j)=lonsrsu(i,j);
                        boxhatch(i,j)=1;
                    else
                        boxhatch(i,j)=0;
                    end
                end
            end
            %boxhatch=flipud(boxhatch);
            %Make lines that actually do the hatching
            for i=1:size(temp2,1)
                for j=1:size(temp2,2)
                    if boxhatch(i,j)==1
                        newroutelat=-boxcornerlat(i,j);newroutelon=boxcornerlon(i,j);
                        line([j j+1],[i i+1],'linewidth',1.5,'color','k');
                    end
                end
            end

            thingbeingplotted=correlsst;units='';prec=0.01;
            colorbarc=7;cbmin=-0.8;cbmax=0.8;colorbarlabel='Correlation coefficient';
            colormap(colormaps('t','more','not'));
            xlabel('Longitude (deg E)','FontSize',14,'FontWeight','bold','fontname','arial');
            ylabel('Latitude','FontSize',14,'FontWeight','bold','fontname','arial');
            titlec=10;month1='Jun';month2='Aug';
            edamultipurposelegendcreator;
            yticklabels=70:-146/7:-76;yticklabels=round(yticklabels);
            xticklabels=40:320/8:360;
            set(gca,'XTickLabel',xticklabels);
            set(gca,'YTickLabel',yticklabels);
            set(gca,'FontSize',12,'FontWeight','bold','fontname','arial');
            curpart=2;figloc=figDir;figname=strcat('mapcorrelssteverygridpt',varname,...
                'region',shortregnames{region},detrremark,shortsstdataset);
            highqualityfiguresetup;
        end
    end
end

%Composite maps of T, WBT, winds, etc. on regional hot days within different 10-day windows or months
%Uses the daily sum of 3-hourly NARR data
if plotnarrcompositemaps==1
    if computeclimo==1
        %First, compute a climatology of each variable (shum, gh, wind, etc)
        for wndw=1:11
            for varc=1:varnum
                eval([char(vars(varc)) 'climo' char(levels(varc)) '{wndw}=zeros(277,349);']);
            end
        end
        for year=yeariwf:yeariwl
            for month=5:9 %no regional hot days in Oct
                fprintf('Computing NARR climo for year %d and month %d\n',year,month);
                monlen=monthlengthsdays(month-monthiwf+1)*8;
                tfile=load(strcat(narrDir,'air/',num2str(year),'/air_',num2str(year),'_0',num2str(month),'_01.mat'));
                tdata=eval(['tfile.air_' num2str(year) '_0' num2str(month) '_01;']);tdata=tdata{3};clear tfile;
                shumfile=load(strcat(narrDir,'shum/',num2str(year),'/shum_',num2str(year),'_0',num2str(month),'_01.mat'));
                shumdata=eval(['shumfile.shum_' num2str(year) '_0' num2str(month) '_01;']);shumdata=shumdata{3};clear shumfile;
                uwndfile=load(strcat(narrDir,'uwnd/',num2str(year),'/uwnd_',num2str(year),'_0',num2str(month),'_01.mat'));
                uwnddata=eval(['uwndfile.uwnd_' num2str(year) '_0' num2str(month) '_01;']);uwnddata=uwnddata{3};clear uwndfile;
                vwndfile=load(strcat(narrDir,'vwnd/',num2str(year),'/vwnd_',num2str(year),'_0',num2str(month),'_01.mat'));
                vwnddata=eval(['vwndfile.vwnd_' num2str(year) '_0' num2str(month) '_01;']);vwnddata=vwnddata{3};clear vwndfile;
                ghfile=load(strcat(narrDir,'hgt/',num2str(year),'/hgt_',num2str(year),'_0',num2str(month),'_01.mat'));
                ghdata=eval(['ghfile.hgt_' num2str(year) '_0' num2str(month) '_01;']);ghdata=ghdata{3};clear ghfile;
                if month==5
                    tclimo850{1}=tclimo850{1}+(mean(tdata(:,:,2,:),4));
                    shumclimo850{1}=shumclimo850{1}+(mean(shumdata(:,:,2,:),4));
                    uwndclimo850{1}=uwndclimo850{1}+(mean(uwnddata(:,:,2,:),4));
                    vwndclimo850{1}=vwndclimo850{1}+(mean(vwnddata(:,:,2,:),4));
                    ghclimo500{1}=ghclimo500{1}+(mean(ghdata(:,:,3,:),4));
                    ghclimo300{1}=ghclimo300{1}+(mean(ghdata(:,:,4,:),4));
                    uwndclimo300{1}=uwndclimo300{1}+(mean(uwnddata(:,:,4,:),4));
                    vwndclimo300{1}=vwndclimo300{1}+(mean(vwnddata(:,:,4,:),4));
                elseif month==6
                    tclimo850{2}=tclimo850{2}+(mean(tdata(:,:,2,1:80),4));
                    tclimo850{3}=tclimo850{3}+(mean(tdata(:,:,2,81:160),4));
                    tclimo850{4}=tclimo850{4}+(mean(tdata(:,:,2,161:monlen),4));
                    shumclimo850{2}=shumclimo850{2}+(mean(shumdata(:,:,2,1:80),4));
                    shumclimo850{3}=shumclimo850{3}+(mean(shumdata(:,:,2,81:160),4));
                    shumclimo850{4}=shumclimo850{4}+(mean(shumdata(:,:,2,161:monlen),4));
                    uwndclimo850{2}=uwndclimo850{2}+(mean(uwnddata(:,:,2,1:80),4));
                    uwndclimo850{3}=uwndclimo850{3}+(mean(uwnddata(:,:,2,81:160),4));
                    uwndclimo850{4}=uwndclimo850{4}+(mean(uwnddata(:,:,2,161:monlen),4));
                    vwndclimo850{2}=vwndclimo850{2}+(mean(vwnddata(:,:,2,1:80),4));
                    vwndclimo850{3}=vwndclimo850{3}+(mean(vwnddata(:,:,2,81:160),4));
                    vwndclimo850{4}=vwndclimo850{4}+(mean(vwnddata(:,:,2,161:monlen),4));
                    ghclimo500{2}=ghclimo500{2}+(mean(ghdata(:,:,3,1:80),4));
                    ghclimo500{3}=ghclimo500{3}+(mean(ghdata(:,:,3,81:160),4));
                    ghclimo500{4}=ghclimo500{4}+(mean(ghdata(:,:,3,161:monlen),4));
                    ghclimo300{2}=ghclimo300{2}+(mean(ghdata(:,:,4,1:80),4));
                    ghclimo300{3}=ghclimo300{3}+(mean(ghdata(:,:,4,81:160),4));
                    ghclimo300{4}=ghclimo300{4}+(mean(ghdata(:,:,4,161:monlen),4));
                    uwndclimo300{2}=uwndclimo300{2}+(mean(uwnddata(:,:,4,1:80),4));
                    uwndclimo300{3}=uwndclimo300{3}+(mean(uwnddata(:,:,4,81:160),4));
                    uwndclimo300{4}=uwndclimo300{4}+(mean(uwnddata(:,:,4,161:monlen),4));
                    vwndclimo300{2}=vwndclimo300{2}+(mean(vwnddata(:,:,4,1:80),4));
                    vwndclimo300{3}=vwndclimo300{3}+(mean(vwnddata(:,:,4,81:160),4));
                    vwndclimo300{4}=vwndclimo300{4}+(mean(vwnddata(:,:,4,161:monlen),4));
                elseif month==7
                    tclimo850{5}=tclimo850{5}+(mean(tdata(:,:,2,1:80),4));
                    tclimo850{6}=tclimo850{6}+(mean(tdata(:,:,2,81:160),4));
                    tclimo850{7}=tclimo850{7}+(mean(tdata(:,:,2,161:monlen),4));
                    shumclimo850{5}=shumclimo850{5}+(mean(shumdata(:,:,2,1:80),4));
                    shumclimo850{6}=shumclimo850{6}+(mean(shumdata(:,:,2,81:160),4));
                    shumclimo850{7}=shumclimo850{7}+(mean(shumdata(:,:,2,161:monlen),4));
                    uwndclimo850{5}=uwndclimo850{5}+(mean(uwnddata(:,:,2,1:80),4));
                    uwndclimo850{6}=uwndclimo850{6}+(mean(uwnddata(:,:,2,81:160),4));
                    uwndclimo850{7}=uwndclimo850{7}+(mean(uwnddata(:,:,2,161:monlen),4));
                    vwndclimo850{5}=vwndclimo850{5}+(mean(vwnddata(:,:,2,1:80),4));
                    vwndclimo850{6}=vwndclimo850{6}+(mean(vwnddata(:,:,2,81:160),4));
                    vwndclimo850{7}=vwndclimo850{7}+(mean(vwnddata(:,:,2,161:monlen),4));
                    ghclimo500{5}=ghclimo500{5}+(mean(ghdata(:,:,3,1:80),4));
                    ghclimo500{6}=ghclimo500{6}+(mean(ghdata(:,:,3,81:160),4));
                    ghclimo500{7}=ghclimo500{7}+(mean(ghdata(:,:,3,161:monlen),4));
                    ghclimo300{5}=ghclimo300{5}+(mean(ghdata(:,:,4,1:80),4));
                    ghclimo300{6}=ghclimo300{6}+(mean(ghdata(:,:,4,81:160),4));
                    ghclimo300{7}=ghclimo300{7}+(mean(ghdata(:,:,4,161:monlen),4));
                    uwndclimo300{5}=uwndclimo300{5}+(mean(uwnddata(:,:,4,1:80),4));
                    uwndclimo300{6}=uwndclimo300{6}+(mean(uwnddata(:,:,4,81:160),4));
                    uwndclimo300{7}=uwndclimo300{7}+(mean(uwnddata(:,:,4,161:monlen),4));
                    vwndclimo300{5}=vwndclimo300{5}+(mean(vwnddata(:,:,4,1:80),4));
                    vwndclimo300{6}=vwndclimo300{6}+(mean(vwnddata(:,:,4,81:160),4));
                    vwndclimo300{7}=vwndclimo300{7}+(mean(vwnddata(:,:,4,161:monlen),4));
                elseif month==8
                    tclimo850{8}=tclimo850{8}+(mean(tdata(:,:,2,1:80),4));
                    tclimo850{9}=tclimo850{9}+(mean(tdata(:,:,2,81:160),4));
                    tclimo850{10}=tclimo850{10}+(mean(tdata(:,:,2,161:monlen),4));
                    shumclimo850{8}=shumclimo850{8}+(mean(shumdata(:,:,2,1:80),4));
                    shumclimo850{9}=shumclimo850{9}+(mean(shumdata(:,:,2,81:160),4));
                    shumclimo850{10}=shumclimo850{10}+(mean(shumdata(:,:,2,161:monlen),4));
                    uwndclimo850{8}=uwndclimo850{8}+(mean(uwnddata(:,:,2,1:80),4));
                    uwndclimo850{9}=uwndclimo850{9}+(mean(uwnddata(:,:,2,81:160),4));
                    uwndclimo850{10}=uwndclimo850{10}+(mean(uwnddata(:,:,2,161:monlen),4));
                    vwndclimo850{8}=vwndclimo850{8}+(mean(vwnddata(:,:,2,1:80),4));
                    vwndclimo850{9}=vwndclimo850{9}+(mean(vwnddata(:,:,2,81:160),4));
                    vwndclimo850{10}=vwndclimo850{10}+(mean(vwnddata(:,:,2,161:monlen),4));
                    ghclimo500{8}=ghclimo500{8}+(mean(ghdata(:,:,3,1:80),4));
                    ghclimo500{9}=ghclimo500{9}+(mean(ghdata(:,:,3,81:160),4));
                    ghclimo500{10}=ghclimo500{10}+(mean(ghdata(:,:,3,161:monlen),4));
                    ghclimo300{8}=ghclimo300{8}+(mean(ghdata(:,:,4,1:80),4));
                    ghclimo300{9}=ghclimo300{9}+(mean(ghdata(:,:,4,81:160),4));
                    ghclimo300{10}=ghclimo300{10}+(mean(ghdata(:,:,4,161:monlen),4));
                    uwndclimo300{8}=uwndclimo300{8}+(mean(uwnddata(:,:,4,1:80),4));
                    uwndclimo300{9}=uwndclimo300{9}+(mean(uwnddata(:,:,4,81:160),4));
                    uwndclimo300{10}=uwndclimo300{10}+(mean(uwnddata(:,:,4,161:monlen),4));
                    vwndclimo300{8}=vwndclimo300{8}+(mean(vwnddata(:,:,4,1:80),4));
                    vwndclimo300{9}=vwndclimo300{9}+(mean(vwnddata(:,:,4,81:160),4));
                    vwndclimo300{10}=vwndclimo300{10}+(mean(vwnddata(:,:,4,161:monlen),4));
                elseif month==9
                    tclimo850{11}=tclimo850{11}+(mean(tdata(:,:,2,:),4));
                    shumclimo850{11}=shumclimo850{11}+(mean(shumdata(:,:,2,:),4));
                    uwndclimo850{11}=uwndclimo850{11}+(mean(uwnddata(:,:,2,:),4));
                    vwndclimo850{11}=vwndclimo850{11}+(mean(vwnddata(:,:,2,:),4));
                    ghclimo500{11}=ghclimo500{11}+(mean(ghdata(:,:,3,:),4));
                    ghclimo300{11}=ghclimo300{11}+(mean(ghdata(:,:,4,:),4));
                    uwndclimo300{11}=uwndclimo300{11}+(mean(uwnddata(:,:,4,:),4));
                    vwndclimo300{11}=vwndclimo300{11}+(mean(vwnddata(:,:,4,:),4));
                end
            end
            if rem(year,5)==0
                fprintf('Year is %d; saving data up to this checkpoint\n',year);
                save(strcat(curDir,'compositemapsarrays'),'tclimo850','shumclimo850','uwndclimo850','vwndclimo850',...
                    'ghclimo500','ghclimo300','uwndclimo300','vwndclimo300','-append');
            end
        end
        for wndw=1:11
            tclimo850{wndw}=(tclimo850{wndw}./(yeariwl-yeariwf+1))-273.15;
            for varc=2:varnum
                eval([char(vars(varc)) 'climo' char(levels(varc))...
                    '{wndw}=' char(vars(varc)) 'climo' char(levels(varc)) '{wndw}./(yeariwl-yeariwf+1);']);
            end
        end
        %Also combine into months in case windows are too specific (also concerned that they have too few days)
        %Dimensions of these will be 2x8x5 (var ranked by, region, month)
        tclimo850months={};shumclimo850months={};uwndclimo850months={};vwndclimo850months={};
        ghclimo500months={};ghclimo300months={};uwndclimo300months={};vwndclimo300months={};
        for repeatnum=1:8
            if repeatnum==1;thisarr=tclimo850;elseif repeatnum==2;thisarr=shumclimo850;...
            elseif repeatnum==3;thisarr=uwndclimo850;elseif repeatnum==4;thisarr=vwndclimo850;...
            elseif repeatnum==5;thisarr=ghclimo500;elseif repeatnum==6;thisarr=ghclimo300;...
            elseif repeatnum==7;thisarr=uwndclimo300;elseif repeatnum==8;thisarr=vwndclimo300;
            end
            thisarrmonths{1}=thisarr{1}; %May was its own window
            thisarrmonths{2}=(thisarr{2}+thisarr{3}+thisarr{4})/3; %June
            thisarrmonths{3}=(thisarr{5}+thisarr{6}+thisarr{7})/3; %July
            thisarrmonths{4}=(thisarr{8}+thisarr{9}+thisarr{10})/3; %Aug
            thisarrmonths{5}=thisarr{11}; %Sep was also its own window
            if repeatnum==1;tclimo850months=thisarrmonths;elseif repeatnum==2;shumclimo850months=thisarrmonths;...
            elseif repeatnum==3;uwndclimo850months=thisarrmonths;elseif repeatnum==4;vwndclimo850months=thisarrmonths;...
            elseif repeatnum==5;ghclimo500months=thisarrmonths;elseif repeatnum==6;ghclimo300months=thisarrmonths;...
            elseif repeatnum==7;uwndclimo300months=thisarrmonths;elseif repeatnum==8;vwndclimo300months=thisarrmonths;
            end
        end
        save(strcat(curDir,'compositemapsarrays'),'tclimo850','shumclimo850','uwndclimo850','vwndclimo850',...
            'ghclimo500','ghclimo300','tclimo850months','shumclimo850months','uwndclimo850months','vwndclimo850months',...
            'ghclimo500months','ghclimo300months','uwndclimo300months','vwndclimo300months','-append');
    end
      
    %Average variables over top-XX days, or over a set number of days before or after them
    if sumupdates==1
        for var=1:3;for reg=1:8;for i=1:2;for varc=1:varnum;
                        eval([char(vrs(varc)) 'sumanom' char(levels(varc)) 'bytqstananom{var,reg,i}=zeros(277,349);']);end;end;end;end
        for var=variwf:variwl %which variable we're ranking by
            if var==1
                hotdaysbywindow=hotdaysbywindowt;topXXbyregion=topXXtbyregionsorted;varname='T';
            elseif var==2
                hotdaysbywindow=hotdaysbywindowwbt;topXXbyregion=topXXwbtbyregionsorted;varname='WBT';
            elseif var==3
                hotdaysbywindow=hotdaysbywindowq;topXXbyregion=topXXqbyregionsorted;varname='q';
            end
            
            %Go through the list of regional hot days for each region and window,
            %summing up and then averaging the variables of interest from reanalysis .mat files for those days
            %or a fixed number of days before/after
            
            %First: make list of all years & months with any day of interest (whatever we are compiling on this run)
            yrsmnstoopen=zeros(yeariwl-yeariwf+1,5); %all years, May-Sep
            for region=regiwf:regiwl
                reghotdaylist=topXXbyregion{region}(1:numdates,:);
                if max(reghotdaylist)~=0
                    for row=1:size(reghotdaylist,1)
                        thisyear=reghotdaylist(row,1)-yeariwf+1;
                        thisdoy=DatetoDOY(reghotdaylist(row,2),reghotdaylist(row,3),reghotdaylist(row,1));
                        thisdoyadj=thisdoy-numdaysbefore;
                        
                        if thisyear+yeariwf-1>=yeariwf && thisyear+yeariwf-1<=yeariwl
                            rlvmn=DOYtoMonth(thisdoyadj,reghotdaylist(row,1))-monthiwf+1;
                            if yrsmnstoopen(thisyear,rlvmn)==0
                                yrsmnstoopen(thisyear,rlvmn)=1;
                            end
                        end
                    end
                end
                topXXsortedchrono{region}=sortrows(topXXbyregion{region}(1:100,:),[1 2 3]);
            end
            %Initialize sums
            for region=regiwf:regiwl
                for wndw=1:11
                    for varc=1:varnum
                        eval([char(vrs(varc)) 'sum' char(levels(varc)) '{var,region,wndw}=zeros(277,349);']);
                    end
                end
                for i=1:4 %further splitting according to the ratio of the T/q stan anoms
                    %as defined in the determinetandqeffectsonwbt loop of findmaxtwbt
                    for varc=1:varnum
                        eval([char(vrs(varc)) 'sum' char(levels(varc)) 'bytqstananom{var,region,1,ndbc,i}=zeros(277,349);']);
                        eval([char(vrs(varc)) 'sumanom' char(levels(varc)) 'bytqstananom{var,region,1,ndbc,i}=zeros(277,349);']);
                    end
                end
            end
            %Get and sum up data for all years and months necessary, keeping sums separate for each region-window combo
            regrow=ones(8,1);regcbyfilter=zeros(8,4);
            for yr=1981:2015
                fprintf('Working on summing up %d data for NARR composites\n',yr);
                for mn=5:9
                    ryr=yr-yeariwf+1;rmn=mn-monthiwf+1;
                    if yrsmnstoopen(ryr,rmn)==1 %only continue if there are any regional hot days in this year-month at all (in any region)
                        tfile=load(strcat(narrDir,'air/',num2str(yr),'/air_',num2str(yr),'_0',num2str(mn),'_01.mat'));
                        tdata=eval(['tfile.air_' num2str(yr) '_0' num2str(mn) '_01;']);tdata=tdata{3};clear tfile;fclose('all');
                        shumfile=load(strcat(narrDir,'shum/',num2str(yr),'/shum_',num2str(yr),'_0',num2str(mn),'_01.mat'));
                        shumdata=eval(['shumfile.shum_' num2str(yr) '_0' num2str(mn) '_01;']);shumdata=shumdata{3};clear shumfile;fclose('all');
                        uwndfile=load(strcat(narrDir,'uwnd/',num2str(yr),'/uwnd_',num2str(yr),'_0',num2str(mn),'_01.mat'));
                        uwnddata=eval(['uwndfile.uwnd_' num2str(yr) '_0' num2str(mn) '_01;']);uwnddata=uwnddata{3};clear uwndfile;fclose('all');
                        vwndfile=load(strcat(narrDir,'vwnd/',num2str(yr),'/vwnd_',num2str(yr),'_0',num2str(mn),'_01.mat'));
                        vwnddata=eval(['vwndfile.vwnd_' num2str(yr) '_0' num2str(mn) '_01;']);vwnddata=vwnddata{3};clear vwndfile;fclose('all');
                        ghfile=load(strcat(narrDir,'hgt/',num2str(yr),'/hgt_',num2str(yr),'_0',num2str(mn),'_01.mat'));
                        ghdata=eval(['ghfile.hgt_' num2str(yr) '_0' num2str(mn) '_01;']);ghdata=ghdata{3};clear ghfile;fclose('all');
                        
                        %Now, get data for hot days (or associated days if numdaysbefore~=0) by region-window combination
                        for region=regiwf:regiwl
                            for wndw=1:11
                                reghotdaylist=hotdaysbywindow{region,wndw};
                                if reghotdaylist(1,1)~=0 %i.e. there is at least one day for this region-window combo
                                    for i=1:size(reghotdaylist,1) %go through all the days of interest for this region-window combo, looking for matches
                                        yrthishotday=reghotdaylist(i,1);
                                        mnthishotday=reghotdaylist(i,2);
                                        dythishotday=reghotdaylist(i,3);
                                        doythishotday=DatetoDOY(mnthishotday,dythishotday,yrthishotday);
                                        
                                        doydoi=doythishotday-numdaysbefore;
                                        mndoi=DOYtoMonth(doydoi,yrthishotday);
                                        dydoi=DOYtoDOM(doydoi,yrthishotday); %could be the hot day itself, or 5, 25, etc days before it
                                        
                                        if yrthishotday==yr && mndoi==mn %a day is associated with the window of the hot day it corresponds to,
                                            %which for numdaysbefore~=0 can be different than its own window, strictly speaking
                                            for varc=1:varnum
                                                eval([char(vrs(varc)) 'sum' char(levels(varc)) '{var,region,wndw}=' char(vrs(varc)) 'sum'...
                                                    char(levels(varc)) '{var,region,wndw}+(sum(' char(vars(varc)) ...
                                                    'data(:,:,' num2str(levelindices(varc)) ',dydoi*8-7:dydoi*8),4));']);
                                            end
                                        end
                                    end
                                end
                                %if region==8 && wndw==5
                                %   fprintf('Max of ghsum300 for yr %d, mn %d is region 8, wndw 5 is %d\n',yr,mn,max(max(ghsum300{var,8,5})));
                                %end
                            end
                        end
                        
                        %Similarly, but a sleeker more-modern version developed for the t/q-stan-anom filter,
                            %is to ignore the windows and just get sums for each region separated out by the filter
                        if tvsq~=10
                            for region=regiwf:regiwl
                                moveontonextmonth=0;
                                while moveontonextmonth==0 && regrow(region)<=numdates
                                    nextentryyear=topXXsortedchrono{region}(regrow(region),1);
                                    nextentrymon=topXXsortedchrono{region}(regrow(region),2);
                                    nextentryday=topXXsortedchrono{region}(regrow(region),3);
                                    doynextentry=DatetoDOY(nextentrymon,nextentryday,nextentryyear);
                                    doydoi=doynextentry-numdaysbefore;
                                    mndoi=DOYtoMonth(doydoi,nextentryyear);
                                    dydoi=DOYtoDOM(doydoi,nextentryyear);
                                    if nextentryyear==yr && mndoi==mn %a day is associated with the window of the hot day it corresponds to,
                                        %which for numdaysbefore~=0 can be different than its own window strictly speaking
                                        %First, get the window of the associated hot day (i.e. the next entry)
                                        if nextentrymon==5
                                            wndw=1;
                                        elseif nextentrymon==6 && nextentryday<=10
                                            wndw=2;
                                        elseif nextentrymon==6 && nextentryday<=20
                                            wndw=3;
                                        elseif nextentrymon==6
                                            wndw=4;
                                        elseif nextentrymon==7 && nextentryday<=10
                                            wndw=5;
                                        elseif nextentrymon==7 && nextentryday<=20
                                            wndw=6;
                                        elseif nextentrymon==7
                                            wndw=7;
                                        elseif nextentrymon==8 && nextentryday<=10
                                            wndw=8;
                                        elseif nextentrymon==8 && nextentryday<=20
                                            wndw=9;
                                        elseif nextentrymon==8
                                            wndw=10;
                                        else
                                            wndw=11;
                                        end
                                        %Then, sum up daily anomalies separately for the two sets of days
                                        %1. If doing regular filtration
                                        if topXXwbtbyregionfilter{region}(regrow(region))==1 %"relatively-T-dominated" regional hot day
                                            tsumanom850bytqstananom{var,region,1,ndbc,1}=tsumanom850bytqstananom{var,region,1,ndbc,1}+...
                                                    ((sum(tdata(:,:,2,dydoi*8-7:dydoi*8),4))-273.15*8*ones(277,349)-(8.*tclimo850{doydoi}))./8;
                                            for varc=2:varnum
                                                if varc~=5 && varc~=6
                                                eval([char(vrs(varc)) 'sumanom' char(levels(varc)) 'bytqstananom{var,region,1,ndbc,1}=' char(vrs(varc))...
                                                    'sumanom' char(levels(varc)) 'bytqstananom{var,region,1,ndbc,1}+((sum(' char(vars(varc))...
                                                    'data(:,:,' num2str(levelindices(varc)) ',dydoi*8-7:dydoi*8),4))-(8.*' char(vars(varc))...
                                                    'climo' char(levels(varc)) '{doydoi}))./8;']);
                                                end
                                            end
                                            regcbyfilter(region,1)=regcbyfilter(region,1)+1;
                                        else %"relatively-q-dominated" regional hot day
                                            tsumanom850bytqstananom{var,region,1,ndbc,2}=tsumanom850bytqstananom{var,region,1,ndbc,2}+...
                                                    ((sum(tdata(:,:,2,dydoi*8-7:dydoi*8),4))-273.15*8*ones(277,349)-(8.*tclimo850{doydoi}))./8;
                                            for varc=2:varnum
                                                if varc~=5 && varc~=6
                                                eval([char(vrs(varc)) 'sumanom' char(levels(varc)) 'bytqstananom{var,region,1,ndbc,2}=' char(vrs(varc))...
                                                    'sumanom' char(levels(varc)) 'bytqstananom{var,region,1,ndbc,2}+((sum(' char(vars(varc))...
                                                    'data(:,:,' num2str(levelindices(varc)) ',dydoi*8-7:dydoi*8),4))-(8.*' char(vars(varc))...
                                                    'climo' char(levels(varc)) '{doydoi}))./8;']);
                                                end
                                            end
                                            regcbyfilter(region,2)=regcbyfilter(region,2)+1;
                                        end
                                        %2. If doing extreme filtration
                                        if topXXwbtbyregionfilterqrt{region}(regrow(region))==1 %same, but more extreme (T/q diff >stn's 80th pct)
                                            tsumanom850bytqstananom{var,region,1,ndbc,3}=tsumanom850bytqstananom{var,region,1,ndbc,3}+...
                                                    ((sum(tdata(:,:,2,dydoi*8-7:dydoi*8),4))-273.15*8*ones(277,349)-(8.*tclimo850{doydoi}))./8;
                                            for varc=2:varnum
                                                if varc~=5 && varc~=6
                                                eval([char(vrs(varc)) 'sumanom' char(levels(varc)) 'bytqstananom{var,region,1,ndbc,3}=' char(vrs(varc))...
                                                    'sumanom' char(levels(varc)) 'bytqstananom{var,region,1,ndbc,3}+((sum(' char(vars(varc))...
                                                    'data(:,:,' num2str(levelindices(varc)) ',dydoi*8-7:dydoi*8),4))-(8.*' char(vars(varc))...
                                                    'climo' char(levels(varc)) '{doydoi}))./8;']);
                                                end
                                            end
                                            regcbyfilter(region,3)=regcbyfilter(region,3)+1;
                                        elseif topXXwbtbyregionfilterqrt{region}(regrow(region))==-1 %T/q diff <stn's 20th pct
                                            tsumanom850bytqstananom{var,region,1,ndbc,4}=tsumanom850bytqstananom{var,region,1,ndbc,4}+...
                                                    ((sum(tdata(:,:,2,dydoi*8-7:dydoi*8),4))-273.15*8*ones(277,349)-(8.*tclimo850{doydoi}))./8;
                                            for varc=2:varnum
                                                if varc~=5 && varc~=6
                                                eval([char(vrs(varc)) 'sumanom' char(levels(varc)) 'bytqstananom{var,region,1,ndbc,4}=' char(vrs(varc))...
                                                    'sumanom' char(levels(varc)) 'bytqstananom{var,region,1,ndbc,4}+((sum(' char(vars(varc))...
                                                    'data(:,:,' num2str(levelindices(varc)) ',dydoi*8-7:dydoi*8),4))-(8.*' char(vars(varc))...
                                                    'climo' char(levels(varc)) '{doydoi}))./8;']);
                                                end
                                            end
                                            regcbyfilter(region,4)=regcbyfilter(region,4)+1;
                                        end
                                        regrow(region)=regrow(region)+1;
                                    else %no more regional hot days found in this month
                                        moveontonextmonth=1;
                                    end
                                end
                            end
                        end
                        fprintf('Done with all summing for this year-month combination (year: %d, month: %d)\n',yr,mn);
                    end
                end
            end

            
            %Turn sums into averages
            for region=regiwf:regiwl
                for varc=1:varnum
                    eval([char(vrs(varc)) 'topXXsum' char(levels(varc)) 'all{region}=0;']);
                    eval([char(vrs(varc)) 'topXXsumanom' char(levels(varc)) 'all{region}=0;']);
                    eval([char(vrs(varc)) 'topXXsumclimo' char(levels(varc)) 'all{region}=0;']);
                end
                totalmeasallwndws{region}=0;numtodivideby{region}=0;
                for wndw=1:11
                    %Calculate the avg over all days in this category
                    ttopXXavg850{var,region,wndw,ndbc}=(tsum850{var,region,wndw}./(8*size(hotdaysbywindow{region,wndw},1)))-273.15;
                    for varc=2:varnum
                        eval([char(vrs(varc)) 'topXXavg' char(levels(varc)) '{var,region,wndw,ndbc}=' char(vrs(varc)) 'sum'...
                            char(levels(varc)) '{var,region,wndw}./(8*size(hotdaysbywindow{region,wndw},1));']);
                    end
                    %Also add up 1. everything as regular values and 2. everything as anomalies, in preparation for the all-inclusive plots
                        %that will be made for the final editions of these figures
                    %This part adds up everything as regular values
                    for varc=1:varnum
                        eval([char(vrs(varc)) 'topXXsum' char(levels(varc)) 'all{region}=' char(vrs(varc)) 'topXXsum'...
                            char(levels(varc)) 'all{region}+' char(vrs(varc)) 'sum' char(levels(varc)) '{var,region,wndw};']);
                    end
                    if max(max(hotdaysbywindow{region,wndw}))~=0
                        numtodivideby{region}=numtodivideby{region}+(8*size(hotdaysbywindow{region,wndw},1));
                    end
                    %This part adds up everything as anomalies from the relevant monthly climatology
                    %Saves sums so anomalies can be computed with weights on months according to the number of hot days they contain
                    %THIS IS THE PART THAT IS USED FOR THE FINAL FIGURES
                    if max(max(hotdaysbywindow{region,wndw}))~=0
                        ttotalanomthiswndw=(tsum850{var,region,wndw}-(273.15*(8*size(hotdaysbywindow{region,wndw},1))))-...
                            (tclimo850{doydoi}*(8*size(hotdaysbywindow{region,wndw},1)));
                        ttopXXsumanom850all{region}=ttopXXsumanom850all{region}+ttotalanomthiswndw;
                        ttopXXsumclimo850all{region}=ttopXXsumclimo850all{region}+tclimo850{doydoi}*(8*size(hotdaysbywindow{region,wndw},1));
                        for varc=2:varnum
                            if varc~=5 && varc~=6
                            eval([char(vrs(varc)) 'totalanomthiswndw=(' char(vrs(varc)) 'sum'...
                                char(levels(varc)) '{var,region,wndw})-(' char(vars(varc)) 'climo' char(levels(varc))...
                                '{doydoi}*(8*size(hotdaysbywindow{region,wndw},1)));']);
                            eval([char(vrs(varc)) 'topXXsumanom' char(levels(varc)) 'all{region}='...
                                char(vrs(varc)) 'topXXsumanom' char(levels(varc)) 'all{region}+'...
                                char(vrs(varc)) 'totalanomthiswndw;']);
                            eval([char(vrs(varc)) 'topXXsumclimo' char(levels(varc)) 'all{region}='...
                                char(vrs(varc)) 'topXXsumclimo' char(levels(varc)) 'all{region}+'...
                                char(vars(varc)) 'climo' char(levels(varc)) '{doydoi}*(8*size(hotdaysbywindow{region,wndw},1));']);
                            end
                        end
                        totalmeasallwndws{region}=totalmeasallwndws{region}+(8*size(hotdaysbywindow{region,wndw},1));
                    end
                end
                %Divide to get averages
                for varc=1:varnum
                    %The array usually plotted as the actual values
                    eval([char(vrs(varc)) 'topXXavg' char(levels(varc)) 'all{var,region,1,ndbc}=(' char(vrs(varc))...
                        'topXXsum' char(levels(varc)) 'all{region}./numtodivideby{region});']);
                    %The array usually plotted as the anomalies
                    eval([char(vrs(varc)) 'topXXavganom' char(levels(varc)) 'all{var,region,1,ndbc}=(' char(vrs(varc))...
                        'topXXsumanom' char(levels(varc)) 'all{region}./totalmeasallwndws{region});']);
                    %The climo array, computed just like the two above
                    eval([char(vrs(varc)) 'topXXavgclimo' char(levels(varc)) 'all{var,1,ndbc}=(' char(vrs(varc))...
                        'topXXsumclimo' char(levels(varc)) 'all{region}./totalmeasallwndws{region});']);
                    %Final creation of arrays of anoms filtered by T/q stan anom ratio
                    for i=1:4
                        eval([char(vrs(varc)) 'avganom' char(levels(varc)) 'bytqstananom{var,region,1,ndbc,i}=' char(vrs(varc))...
                            'sumanom' char(levels(varc)) 'bytqstananom{var,region,1,ndbc,i}./regcbyfilter(region,i);']);
                    end
                end
            end
            %For arrays for which it is necessary, combine windows into months, in case windows are too specific (also concerned that they have too few days)
            for repeatnum=1:8
                if repeatnum==1;thisarr=ttopXXavg850;elseif repeatnum==2;thisarr=shumtopXXavg850;...
                elseif repeatnum==3;thisarr=utopXXavg850;elseif repeatnum==4;thisarr=vtopXXavg850;...
                elseif repeatnum==5;thisarr=ghtopXXavg500;elseif repeatnum==6;thisarr=ghtopXXavg300;...
                elseif repeatnum==7;thisarr=utopXXavg300;elseif repeatnum==8;thisarr=vtopXXavg300;
                end
                for region=regiwf:regiwl
                    thisarrmonths{var,region,1,ndbc}=thisarr{var,region,1,ndbc}; %May was its own window
                    thisarrmonths{var,region,2,ndbc}=(thisarr{var,region,2,ndbc}+thisarr{var,region,3,ndbc}+thisarr{var,region,4,ndbc})/3; %June
                    thisarrmonths{var,region,3,ndbc}=(thisarr{var,region,5,ndbc}+thisarr{var,region,6,ndbc}+thisarr{var,region,7,ndbc})/3; %July
                    thisarrmonths{var,region,4,ndbc}=(thisarr{var,region,8,ndbc}+thisarr{var,region,9,ndbc}+thisarr{var,region,10,ndbc})/3; %Aug
                    thisarrmonths{var,region,5,ndbc}=thisarr{var,region,11,ndbc}; %Sep was also its own window
                end
                if repeatnum==1;ttopXXavg850months=thisarrmonths;elseif repeatnum==2;shumtopXXavg850months=thisarrmonths;...
                elseif repeatnum==3;utopXXavg850months=thisarrmonths;elseif repeatnum==4;vtopXXavg850months=thisarrmonths;...
                elseif repeatnum==5;ghtopXXavg500months=thisarrmonths;elseif repeatnum==6;ghtopXXavg300months=thisarrmonths;...
                elseif repeatnum==7;utopXXavg300months=thisarrmonths;elseif repeatnum==8;vtopXXavg300months=thisarrmonths;
                end
            end
            %Add an extra dimension for optstoplot
            dothis=0;
            if dothis==1
                for varc=1:varnum
                    for region=regiwf:regiwl
                        for wndw=1:11
                            for ndbc=1:3
                                eval([vrs(varc) 'topXXavg' levels(varc) '{var,region,wndw,ndbc,optstoplot}='...
                                    vrs(varc) 'topXXavg' levels(varc) '{var,region,wndw,ndbc};']);
                            end
                            eval([vrs(varc) 'sum' levels(varc) '{var,region,wndw,ndbc,optstoplot}='...
                                vrs(varc) 'sum' levels(varc) '{var,region,wndw};']);
                        end
                        for month=1:5;eval([vrs(varc) 'topXXavg' levels(varc) 'months{var,region,month,ndbc,optstoplot}='...
                            vrs(varc) 'topXXavg' levels(varc) 'months{var,region,month};']);end
                        for ndbc=1:3;eval([vrs(varc) 'topXXavg' levels(varc) 'all{var,region,1,ndbc,optstoplot}='...
                            vrs(varc) 'topXXavg' levels(varc) 'all{var,region,1,ndbc};']);end
                        for ndbc=1:3;eval([vrs(varc) 'topXXavg' levels(varc) 'anomall{var,region,1,ndbc,optstoplot}='...
                            vrs(varc) 'topXXavg' levels(varc) 'anomall{var,region,1,ndbc};']);end
                        for ndbc=1:3;eval([vrs(varc) 'topXXavg' levels(varc) 'climoall{var,region,1,ndbc,optstoplot}='...
                            vrs(varc) 'topXXavg' levels(varc) 'climoall{var,region,1,ndbc};']);end
                    end
                end
            end
            %If desired, save what was found to a file
            if whethertosave==1
                save(strcat(curArrayDir,'compositemapsarrays'),'ttopXXavg850','shumtopXXavg850','utopXXavg850',...
                    'utopXXavg300','vtopXXavg850','vtopXXavg300','ghtopXXavg500','ghtopXXavg300','ttopXXavg850months',...
                    'shumtopXXavg850months','utopXXavg850months','utopXXavg300months','vtopXXavg850months','vtopXXavg300months',...
                    'ghtopXXavg500months','ghtopXXavg300months','tsum850','shumsum850','usum850','vsum850',...
                    'usum300','vsum300','ghsum500','ghsum300','ttopXXavg850all','shumtopXXavg850all','utopXXavg850all',...
                    'vtopXXavg850all','utopXXavg300all','vtopXXavg300all','ghtopXXavg500all','ghtopXXavg300all',...
                    'ttopXXavganom850all','shumtopXXavganom850all','utopXXavganom850all','vtopXXavganom850all','utopXXavganom300all',...
                    'vtopXXavganom300all','ghtopXXavganom500all','ghtopXXavganom300all','tavganom850bytqstananom',...
                    'shumavganom850bytqstananom','uavganom850bytqstananom','vavganom850bytqstananom','uavganom300bytqstananom',...
                    'vavganom300bytqstananom','ghavganom500bytqstananom','ghavganom300bytqstananom',...
                    'ttopXXavgclimo850all','shumtopXXavgclimo850all','utopXXavgclimo850all','vtopXXavgclimo850all',...
                    'utopXXavgclimo300all','vtopXXavgclimo300all','ghtopXXavgclimo500all','ghtopXXavgclimo300all','-append');
            end
        end
    end
    
    if dothemapping==1
       disp('Now let us map (NARR)');
       %Read variables back in if they were calculated remotely
        if readvarsbackin==1
            datafile=load(strcat(curArrayDir,'compositemapsarrays'));
            for varc=1:varnum
                eval([char(vrs(varc)) 'topXXavg' char(levels(varc)) '=datafile.' char(vrs(varc)) 'topXXavg' char(levels(varc)) ';']);
                eval([char(vrs(varc)) 'topXXavg' char(levels(varc)) 'months=datafile.' ...
                    char(vrs(varc)) 'topXXavg' char(levels(varc)) 'months;']);
                eval([char(vrs(varc)) 'topXXavganom' char(levels(varc)) 'all=datafile.'...
                    char(vrs(varc)) 'topXXavganom' char(levels(varc)) 'all;']);
                %note that climo is WEIGHTED BY THE DAY OF OCCURRENCE OF
                %EACH TOP XX EXTREME (i.e. it's not just the JJA average)
                eval([char(vrs(varc)) 'topXXavgclimo' char(levels(varc)) 'all=datafile.'... 
                    char(vrs(varc)) 'topXXavgclimo' char(levels(varc)) 'all;']);
            end
        end
        exist uwndclimo300;if ans==0;uwndclimo300={};end
        exist vwndclimo300;if ans==0;vwndclimo300={};end
        exist uwndclimo300months;if ans==0;uwndclimo300months={};end
        exist vwndclimo300months;if ans==0;vwndclimo300months={};end
        if strcmp(class(uwndclimo300months),'double')
                clear uwndclimo300months;clear vwndclimo300months;
            for relmonth=1:5;uwndclimo300months{relmonth}=0;end
            for relmonth=1:5;vwndclimo300months{relmonth}=0;end
        end
        exist utopXXanom300months;if ans==0;utopXXanom300months={};end
        exist vtopXXanom300months;if ans==0;vtopXXanom300months={};end
        %For window- and month-specific arrays, create anomalies (those for the all-inclusive arrays have already been created)
        if plotmonth~=2 %i.e. if we need to care about these at all
        for var=variwf:variwl
            for region=regiwf:regiwl
                for wndw=1:11
                    for varc=1:varnum
                        if varc~=5 && varc~=6
                        eval([char(vrs(varc)) 'topXXanom' char(levels(varc)) '{var,region,wndw,ndbc}=' char(vrs(varc))...
                        'topXXavg' char(levels(varc)) '{var,region,wndw,ndbc}-' char(vars(varc)) 'climo' char(levels(varc)) '{doydoi};']);
                        end
                    end
                end
                for relmonth=1:5
                    for varc=1:varnum
                        if varc~=5 && varc~=6 %u300 & v300 not yet ready for primetime (not fully calculated)
                            eval([char(vrs(varc)) 'topXXanom' char(levels(varc)) 'months{var,region,relmonth,ndbc}=' char(vrs(varc))...
                            'topXXavg' char(levels(varc)) 'months{var,region,relmonth,ndbc}-' char(vars(varc)) 'climo' ...
                            char(levels(varc)) 'months{relmonth};']);
                        end
                    end
                end
            end
        end
        end
        

        %Do mapping itself, keeping mind that each region-window or region-month combination is already a composite
        for option=1:1 %how many different options to plot -- *which ones* are set by optstoplot
            for var=variwf:variwl
                if var==1;varname='T';elseif var==2;varname='WBT';elseif var==3;varname='q';end
                if plotanom==1
                    anomavg='anom';anomavgtitle='anomalous';
                    cmin1=-5;cmax1=5;cmin2=-5;cmax2=5;cmin3=-200;cmax3=200;cmin4=-200;cmax4=200;
                else
                    anomavg='avg';anomavgtitle='average';
                    cmin1=20;cmax1=35;cmin2=3;cmax2=15;cmin3=5400;cmax3=6000;cmin4=cmin3;cmax4=cmax3;
                end
                if plotmonth==1;fignamepart='month';elseif plotmonth==0;fignamepart='wndw';elseif plotmonth==2;fignamepart='all';end
                if tvsq==1;fignamepart2='tdom';tqset=tvsq;elseif tvsq==2;fignamepart2='qdom';tqset=2;
                    elseif tvsq==3;fignamepart2='p80tdom';tqset=3;elseif tvsq==4;fignamepart2='p80qdom';tqset=4;
                    elseif tvsq==10;fignamepart2='';tqset=1;
                end
                    %if tvsq==10, tqset doesn't matter since the arrays don't have stan anom filtering anyway
                explhelper; %this script gets the right version of arrays to use subsequently, given anomavg & plotmonth selections
                if includeclimoaslastpanel==1;endat=regiwl+1;else;endat=regiwl;end
                
                for timec=timeciwf:timeciwl %10-day windows (of which there are 11), months (of which there are 5, May-Sep), or all-inclusive (just 1)
                    for region=regiwf:endat
                        %%if region==regiwl+2;region=3;end %necessary to repeat one of the panels when the option to plot the climo panel is on,
                            %because otherwise the colorbar doesn't have the right caxis
                        if region<=regiwl %i.e. everything but the climo plots that are sometimes the last panel
                            if optstoplot(option)==1 %850 T overlaid with gh500
                                overlaydata={narrlats;narrlons;gh500arr{var,region,timec,ndbc,tqset}};
                                underlaydata={narrlats;narrlons;t850arr{var,region,timec,ndbc,tqset}};data=underlaydata;
                                vararginnew={'variable';'height';'contour';1;'mystepunderlay';1;'plotCountries';1;...
                                    'datatounderlay';underlaydata;'underlaycaxismin';cmin1;'underlaycaxismax';cmax1;'overlaynow';1;...
                                    'overlayvariable';'height';'datatooverlay';overlaydata;'caxismin';-100;'caxismax';100;'mystep';20;...
                                    'underlayvariable';'temperature';'anomavg';anomavg;'centeredon';180;'addtext';'dontaddtext';...
                                    'contourlabels';1;'manualcontourlabels';1};
                                if makefinal==1;vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=1;end
                                titledescrip='850-hPa T and 500-hPa height';
                                units=' (C)';shadingdescrip='Temperature';colormap(colormaps('t','more','not'));
                                %cmin=-100;cmax=100;underlaycmin=-1;underlaycmax=1;
                            elseif optstoplot(option)==2 %850 shum overlaid with 850 wind
                                overlaydata={narrlats;narrlons;u850arr{var,region,timec,ndbc,tqset};v850arr{var,region,timec,ndbc,tqset}};
                                underlaydata={narrlats;narrlons;shum850arr{var,region,timec,ndbc,tqset}*1000};data=underlaydata;
                                vararginnew={'variable';'wind';'contour';1;'mystepunderlay';0.5;'plotCountries';1;...
                                    'underlaycaxismin';cmin2;'underlaycaxismax';cmax2;'vectorData';overlaydata;'overlaynow';1;...
                                    'overlayvariable';'wind';'datatooverlay';overlaydata;'underlayvariable';...
                                    'specific humidity';'datatounderlay';underlaydata;'anomavg';anomavg;'centeredon';180;'addtext';'dontaddtext';...
                                    'nolinesbetweenfilledcontours';1};
                                if makefinal==1;vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=1;end
                                titledescrip='850-hPa specific humidity and 850-hPa wind';
                                units=' (g/kg)';shadingdescrip='Specific-Humidity';colormap(colormaps('q','more','not'));
                            elseif optstoplot(option)==3 %gh300 overlaid with 300 wind
                                overlaydata={narrlats;narrlons;u300arr{var,region,timec,ndbc,tqset};v300arr{var,region,timec,ndbc,tqset}};data=overlaydata;
                                underlaydata={narrlats;narrlons;gh300arr{var,region,timec,ndbc,tqset}};
                                vararginnew={'variable';'wind';'contour';1;'mystep';20;'plotCountries';1;...
                                    'caxismin';cmin3;'caxismax';cmax3;'vectorData';overlaydata;'overlaynow';1;...
                                    'overlayvariable';'wind';'datatooverlay';overlaydata;'underlayvariable';...
                                    'height';'datatounderlay';underlaydata;'anomavg';anomavg;'levelplotted';300};
                                if makefinal==1;vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=1;end
                                titledescrip='300-hPa geopotential height and 300-hPa wind';
                                units=' (m)';shadingdescrip='Geopotential-Height';colormap(colormaps('gh','more','not'));
                            elseif optstoplot(option)==4 %gh500 overlaid with 850 wind, AND computed as the extreme WBT-extreme T difference
                                overlaydata={narrlats;narrlons;...
                                    u850arr{2,region,timec,ndbc,tqset}-u850arr{1,region,timec,ndbc,tqset};...
                                    v850arr{2,region,timec,ndbc,tqset}-v850arr{1,region,timec,ndbc,tqset}};data=overlaydata;
                                underlaydata={narrlats;narrlons;gh500arr{2,region,timec,ndbc,tqset}-gh500arr{1,region,timec,ndbc,tqset}};
                                vararginnew={'variable';'wind';'contour';1;'mystep';19;'mystepunderlay';19;'plotCountries';1;...
                                    'underlaycaxismin';cmin4;'underlaycaxismax';cmax4;'vectorData';overlaydata;'overlaynow';1;...
                                    'overlayvariable';'wind';'datatooverlay';overlaydata;'underlayvariable';...
                                    'height';'datatounderlay';underlaydata;'anomavg';anomavg;'levelplotted';500};
                                if makefinal==1;vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=1;end
                                titledescrip='500-hPa geopotential height and 850-hPa wind';
                                units=' (m)';shadingdescrip='Geopotential-Height';colormap(colormaps('gh','more','not'));
                            end
                        else %%%%for climatology subplots only%%%
                            if optstoplot(option)==1 %850 T overlaid with gh500
                                overlaydata={narrlats;narrlons;gh500climoarr{var,timec,ndbc,tqset}};
                                underlaydata={narrlats;narrlons;t850climoarr{var,timec,ndbc,tqset}};data=underlaydata;
                                vararginnew={'variable';'height';'contour';1;'mystepunderlay';2;'plotCountries';1;...
                                    'datatounderlay';underlaydata;'underlaycaxismin';0;'underlaycaxismax';22;'overlaynow';1;...
                                    'overlayvariable';'height';'datatooverlay';overlaydata;'caxismin';5400;'caxismax';5900;'mystep';100;...
                                    'underlayvariable';'temperature';'anomavg';anomavg;'centeredon';180;'addtext';'dontaddtext';...
                                    'contourlabels';1;'manualcontourlabels';1};
                                if makefinal==1;vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=1;end
                                titledescrip='850-hPa T and 500-hPa height';
                                units=' (C)';shadingdescrip='Temperature';colormap(colormaps('t','more','not'));
                            elseif optstoplot(option)==2 %850 shum overlaid with 850 wind
                                overlaydata={narrlats;narrlons;u850climoarr{var,timec,ndbc,tqset};v850climoarr{var,timec,ndbc,tqset}};
                                underlaydata={narrlats;narrlons;shum850climoarr{var,timec,ndbc,tqset}*1000};data=underlaydata;
                                vararginnew={'variable';'wind';'contour';1;'mystepunderlay';1;'plotCountries';1;...
                                    'underlaycaxismin';5;'underlaycaxismax';14;'vectorData';overlaydata;'overlaynow';1;...
                                    'overlayvariable';'wind';'datatooverlay';overlaydata;'underlayvariable';...
                                    'specific humidity';'datatounderlay';underlaydata;'anomavg';anomavg;'centeredon';180;'addtext';'dontaddtext';...
                                    'nolinesbetweenfilledcontours';1};
                                if makefinal==1;vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=1;end
                                titledescrip='850-hPa specific humidity and 850-hPa wind';
                                units=' (g/kg)';shadingdescrip='Specific-Humidity';colormap(colormaps('q','more','not'));
                            end
                        end
                        
                        %Create and then touch up plot
                        %Note that 'after-market' text, if any, is added in highqualityfiguresetup for reasons of clarity
                            %in the final png figures
                        regionformap='usa';datatype='NARR';
                        if makefinal==1
                            if region==regiwf;figure(figc);clf;figc=figc+1;end
                            hold on;
                            axissz=8;labelsz=10;titlesz=12;
                            if numrowstomake==3 && numcolstomake==3
                                if region>=8;subplot(3,3,region);else subplot(3,3,region-1);end
                            elseif numrowstomake==4 && numcolstomake==2
                                subplot(4,2,region-1);
                            end
                        else
                            figure(figc);clf;figc=figc+1;
                            axissz=14;labelsz=18;titlesz=20;
                        end
                        
                        curpart=1;highqualityfiguresetup;

                        %The actual plotting of the data
                        if ~max(max(data{3}))==0 %i.e. if the data is valid and not missing e.g. b/c there are no days in this region-window combo
                            plotModelData(data,regionformap,vararginnew,datatype);
                            if makefinal==1;clear fullshadingdescr;clear windbarbsdescr;end
                            if region==1;theornot='';else theornot='the ';end
                            titlepart1=sprintf('Composite map of %s %s',anomavgtitle,titledescrip);
                            if region<=8
                                if plotmonth==1 %grouping into months
                                    if numdaysbefore==0
                                        titlepart2=sprintf('for extreme %s days in %s%s: %s',...
                                        varname,theornot,ncaregionnamemaster{region},monthnames{timec});
                                    else
                                        titlepart2=sprintf('%d days before extreme %s days in %s%s: %s',...
                                        numdaysbefore,varname,theornot,ncaregionnamemaster{region},monthnames{timec});
                                    end
                                elseif plotmonth==0 %grouping into 10-day windows
                                    if numdaysbefore==0
                                        titlepart2=sprintf('for extreme %s days in %s%s: %s',...
                                        varname,theornot,ncaregionnamemaster{region},tendaywindownames11{timec});
                                    else
                                        titlepart2=sprintf('%d days before extreme %s days in %s%s: %s',...
                                        numdaysbefore,varname,theornot,ncaregionnamemaster{region},tendaywindownames11{timec});
                                    end
                                elseif plotmonth==2 %no grouping at all
                                    if numdaysbefore==0
                                        titlepart2=sprintf('for extreme %s days in %s%s',varname,theornot,ncaregionnamemaster{region});
                                    else
                                        titlepart2=sprintf('%d days before extreme %s days in %s%s',...
                                            numdaysbefore,varname,theornot,ncaregionnamemaster{region});
                                    end
                                end
                            end
                            if makefinal==1 %title is just letters
                                t=title(sprintf(figletterlabels{region-1}),'fontname','arial','fontweight','bold','fontsize',titlesz);
                                set(t,'horizontalalignment','left');set(t,'units','normalized');
                                h1=get(t,'position');set(t,'position',[0 h1(2)-0.1 h1(3)]);
                            else %otherwise, title is descriptive as defined above
                                title({titlepart1,titlepart2},'fontname','arial','fontweight','bold','fontsize',titlesz);
                            end
                            
                            
                            maxcbval=max(abs(eval(['cmin' num2str(optstoplot(option)) ';'])),abs(eval(['cmax' num2str(optstoplot(option))])));
                            if optstoplot(option)<=3 %want colorbar to be centered on 0
                                if region<=8
                                    if strcmp(anomavg,'anom');caxisRange=[-1*maxcbval maxcbval];caxis(caxisRange);end
                                else %climatology only
                                    if optstoplot(option)==1
                                        caxis([0 22]);
                                    elseif optstoplot(option)==2
                                        caxis([3 14]);
                                    end
                                end
                            else
                                caxis([-200 200]);
                            end
                            
                            if plotanom==1
                                cblabel=sprintf('%s Anomaly%s',shadingdescrip,units);
                            else
                                cblabel=sprintf('%s Average%s',shadingdescrip,units);
                            end
                            cblabelclimosubplot=sprintf('%s \nClimatology%s',shadingdescrip,units);
                            if optstoplot(option)==4;cblabel='Geopotential-Height Anomaly Difference (m)';end
                            if makefinal==0
                                cbar=colorbar;set(cbar,'ylim',[-1*maxcbval maxcbval]); %so colorbar is centered on 0
                                set(get(cbar,'Ylabel'),'String',cblabel,'FontSize',labelsz,'FontWeight','bold','FontName','Arial');
                                set(cbar,'FontSize',labelsz,'FontWeight','bold','FontName','Arial');
                            end
                            %Add white or black dot at center of each region
                            colorstouse={'ghost white';'black';'ghost white';'ghost white'};
                            if region<=8;geoshow(regcenterlats(region),regcenterlons(region),'displaytype','point','marker','o','markerfacecolor',colors(colorstouse{optstoplot(option)}),...
                                'markeredgecolor','k','markersize',10);end
                            
                            curpart=2;figloc=figDir;
                            if makefinal==1
                                if tvsq==2
                                    if numdaysbefore==0
                                        figname=strcat('compositeopt',num2str(optstoplot(option)),'rb',varlist{var},...
                                        fignamepart,anomavg,'final');
                                    else
                                        figname=strcat('compositeopt',num2str(optstoplot(option)),'rb',varlist{var},...
                                        fignamepart,anomavg,'ndb',num2str(numdaysbefore),'final');
                                    end
                                else
                                    if numdaysbefore==0
                                        figname=strcat('compositeopt',num2str(optstoplot(option)),'rb',varlist{var},...
                                        fignamepart,anomavg,fignamepart2,'final');
                                    else
                                        figname=strcat('compositeopt',num2str(optstoplot(option)),'rb',varlist{var},...
                                        fignamepart,anomavg,fignamepart2,'ndb',num2str(numdaysbefore),'final');
                                    end
                                end
                            else
                                if numdaysbefore==0
                                    figname=strcat('compositeopt',num2str(optstoplot(option)),'rb',varlist{var},...
                                    'reg',num2str(region),fignamepart,num2str(timec),anomavg);
                                else
                                    figname=strcat('compositeopt',num2str(optstoplot(option)),'rb',varlist{var},...
                                    'reg',num2str(region),fignamepart,num2str(timec),anomavg,'ndb',num2str(numdaysbefore));
                                end
                            end
                            exist windbarbsdescr;
                            if ans==1
                                if strcmp(windbarbsdescr,'');inclrefvectext=0;else inclrefvectext=1;end %info to be passed to highqualityfiguresetup
                            else
                                inclrefvectext=0;
                            end
                            %Determine left and bottom bounds (in normalized units) of subplots in each position within the multipanel figure
                            if makefinal==1
                                rownow=round2((region-1)/numrowstomake,1,'ceil');
                                colnow=rem((region-1),numcolstomake);if colnow==0;colnow=numcolstomake;end
                                if numrowstomake==3;if region==8;colnow=1.5;elseif region==9;colnow=2.5;end;end
                                if numrowstomake==4 && numcolstomake==2
                                    if rownow==1;rownowpos=0.24;elseif rownow==2;rownowpos=0.49;elseif rownow==3;rownowpos=0.74;else rownowpos=0.99;end
                                    if colnow==1;colnowpos=0.075;elseif colnow==2;colnowpos=0.075+0.5;end
                                    set(gca,'Position',[colnowpos 1-rownowpos 0.35 0.23]);
                                elseif numrowstomake==3 && numcolstomake==3
                                    if rownow==1;rownowpos=0.323;elseif rownow==2;rownowpos=0.657;else rownowpos=0.99;end
                                    %if colnow==1;colnowpos=0.01;elseif colnow==1.5;colnowpos=0.1735;elseif colnow==2;colnowpos=0.344;...
                                    %elseif colnow==2.5;colnowpos=0.506;else colnowpos=0.677;end
                                    %disp(rownowpos);disp(colnowpos);
                                    %set(gca,'Position',[colnowpos 1-rownowpos 0.313 0.313]);
                                    if colnow==1;colnowpos=0.02;elseif colnow==1.5;colnowpos=0.1668;elseif colnow==2;colnowpos=0.3206;...
                                    elseif colnow==2.5;colnowpos=0.466;else colnowpos=0.6202;end
                                    %disp(rownowpos);disp(colnowpos);
                                    set(gca,'Position',[colnowpos 1-rownowpos 0.2796 0.313]);
                                end
                            else
                                highqualityfiguresetup;
                            end
                            if region==4 || region==5;leftpos=0.3;else leftpos=0.4;end
                            if region<=8
                                text(leftpos,1.08,sprintf(ncaregionnamemaster{region}),'units','normalized',...
                                'fontsize',14,'fontweight','bold','fontname','arial');
                            else
                                text(leftpos,1.08,'Climatology','units','normalized',...
                                'fontsize',14,'fontweight','bold','fontname','arial');
                            end
                        end
                        if optstoplot(option)==1
                            colormap(colormaps('t','more','not'));
                        elseif optstoplot(option)==2
                            colormap(colormaps('q','more','not'));
                        elseif optstoplot(option)==3
                            colormap(colormaps('gh','more','not'));
                        elseif optstoplot(option)==4
                            colormap(colormaps('wbt','more','not'));
                        end
                        
                        %Make one big colorbar for all subplots
                        if makefinal==1 && region==regiwl
                            caxis(caxisRange);
                            cbar=colorbar;
                            set(get(cbar,'Ylabel'),'String',cblabel,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
                            set(cbar,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
                            cpos=get(cbar,'Position');cpos(1)=0.925;cpos(2)=0.05;cpos(3)=0.017;cpos(4)=0.9;
                            set(cbar,'Position',cpos);
                            %If plotting wind, show reference vector
                            if optstoplot(option)==2
                                %old xcoords were [0.665 0.685]
                                xcoords=[0.845 0.865];ycoords=[0.31 0.31];
                                annotation('textarrow',xcoords,ycoords,'headwidth',6,'headlength',6);
                                if includeclimoaslastpanel==1;textloc=2.4;else textloc=1.2;end
                                text(textloc,1,'5 m/s','fontname','arial','fontweight','bold','fontsize',14,'units','normalized');
                            end
                            highqualityfiguresetup;
                        elseif makefinal==1 && region==endat && includeclimoaslastpanel==1
                            %Create the colorbar for the climatology subplot, if there is one
                            cbar=colorbar;
                            set(get(cbar,'Ylabel'),'String',cblabelclimosubplot,'FontSize',10,'FontWeight','bold','FontName','Arial');
                            set(gca,'Position',[colnowpos 1-rownowpos 0.2796 0.313]);
                        end
                    end
                    highqualityfiguresetup;
                end
            end
        end
    end
end

%Composite maps of gh500 ANOMALIES on regional hot days and preceding them
%Also, there is an option to plot seasonal composites for the 5 strongest ENSO summers during the 1981-2015 period
    %El Nino -- 1982, 1987, 1997, 2002, 2015
    %La Nina -- 1988, 1998, 1999, 2000, 2010
if plotncepcompositemapsnowindows==1
    if needtodocalc==1
        %St devs of gh500 for every month May-Sep, to be able to calculate standardized anomalies
        if monthlystdevs==1
            thismoncount=ones(6,1);
            for mn=monthiwf:monthiwl
                relmn=mn-monthiwf+1;
                if mn<=9;addedzero='0';else addedzero='';end
                fprintf('Computing st devs for month %d\n',mn);
                for yr=yeariwf:yeariwl
                    relevantmatfile=load(strcat(ncepdailydataDir,'hgt/',num2str(yr),'/',...
                        'hgt_',num2str(yr),'_',addedzero,num2str(mn),'_500.mat'));
                    actualdata=eval(['relevantmatfile.hgt_' num2str(yr) '_' addedzero num2str(mn) '_500']);
                    actualdata=actualdata{3};
                    for i=1:monthlengthsdays(relmn)
                        alldatabymon{relmn}(:,:,thismoncount(relmn))=squeeze(actualdata(:,:,1,i));
                        thismoncount(relmn)=thismoncount(relmn)+1;
                    end
                    clear relevantmatfile;
                end
                for i=1:144
                    for j=1:73
                        stdevdatabymon{relmn}(i,j)=std(alldatabymon{relmn}(i,j,:));
                    end
                end
            end
            save(strcat(curArrayDir,'extraarrays'),'stdevdatabymon','-append');
        end
        
        
        if ensocomposite==1
            ensoindex=load('indicesmonthlyoni.txt','r'); %http://www.cpc.ncep.noaa.gov/data/indices/sstoi.indices
            ensoindex=ensoindex(:,4); %using Nino 3.4
            %Actually, just use http://www.cpc.ncep.noaa.gov/products/analysis_monitoring/ensostuff/ensoyears.shtml
                %to identify the 5 years noted above
            %Now, get data from every JJA day in those 5 summers and compute the composite anomaly for them
            
            if elnino==1
                years=[1982;1987;1997;2002;2015];elninoyears=years;
                sumanomselninosummers=zeros(144,73);allanomselninosummers=zeros(144,73,10);
            else
                years=[1988;1998;1999;2000;2010];laninayears=years;
                sumanomslaninasummers=zeros(144,73);allanomslaninasummers=zeros(144,73,10);
            end
            count=1;
            for i=1:size(years,1)
                thisyear=years(i);
                for thismon=6:8
                    relevantmatfile=load(strcat(ncepdailydataDir,'hgt/',num2str(thisyear),'/',...
                        'hgt_',num2str(thisyear),'_0',num2str(thismon),'_500.mat'));
                    actualdata=eval(['relevantmatfile.hgt_' num2str(thisyear) '_0' num2str(thismon) '_500']);
                    actualdata=actualdata{3};
                    meanactualdata=mean(actualdata,4);
                    thismonthavg=fullhgtdatancep{thismon-monthiwf+1,15}; %for monthly average, use average for the 15th of the month
                    thismonthanomgivenactualdata=meanactualdata-thismonthavg;
                    if elnino==1
                        sumanomselninosummers=sumanomselninosummers+thismonthanomgivenactualdata;
                        allanomselninosummers(:,:,count)=thismonthanomgivenactualdata;
                    else
                        sumanomslaninasummers=sumanomslaninasummers+thismonthanomgivenactualdata;
                        allanomslaninasummers(:,:,count)=thismonthanomgivenactualdata;
                    end
                    count=count+1;
                end
            end
            if elnino==1
                avgofanomselninosummers=double(sumanomselninosummers./(count-1));
                for i=1:144;for j=1:73;avgofanomsstanelninosummers(i,j)=avgofanomselninosummers(i,j)./std(allanomselninosummers(i,j,1:15));end;end
                save(strcat(curDir,'griddedavgsarrays'),'avgofanomselninosummers','avgofanomsstanelninosummers','elninoyears','-append');
            else
                avgofanomslaninasummers=double(sumanomslaninasummers./(count-1));
                for i=1:144;for j=1:73;avgofanomsstanlaninasummers(i,j)=avgofanomslaninasummers(i,j)./std(allanomslaninasummers(i,j,1:15));end;end
                save(strcat(curDir,'griddedavgsarrays'),'avgofanomslaninasummers','avgofanomsstanlaninasummers','laninayears','-append');
            end
            %With a 95% confidence standard, determine which gridpts are significant for this var & region -- ANSWER: none are, so no point in
                %including this info in the plots (probably b/c 15 months is just not enough to bring down the variance)
            for i=1:144
                for j=1:73
                    if elnino==1
                        anomsforthisgridpt(i,j,1:size(allanomselninosummers,3))=squeeze(allanomselninosummers(i,j,:));
                        stdevanomsthisgridpt(i,j)=std(anomsforthisgridpt(i,j,1:15));
                        if (avgofanomselninosummers(i,j)-2*stdevanomsthisgridpt(i,j))>0 || (avgofanomselninosummers(i,j)+2*stdevanomsthisgridpt(i,j))<0
                            gridptsignifarrayelninosummers(i,j)=1;
                        else
                            gridptsignifarrayelninosummers(i,j)=0;
                        end
                    else
                        anomsforthisgridpt(i,j,:)=squeeze(allanomslaninasummers(i,j,:));
                        stdevanomsthisgridpt(i,j)=std(anomsforthisgridpt(i,j,1:15));
                        if (avgofanomslaninasummers(i,j)-2*stdevanomsthisgridpt(i,j))>0 || (avgofanomslaninasummers(i,j)+2*stdevanomsthisgridpt(i,j))<0
                            gridptsignifarraylaninasummers(i,j)=1;
                        else
                            gridptsignifarraylaninasummers(i,j)=0;
                        end
                    end
                end
            end
        else %z500 anomalies for all 100 hot days of a given variable in a given region
            %avgofanomsactualdataz500={};
            for var=variwf:variwl
                for region=regiwf:regiwl
                    if var==1
                        reghotdaylist=topXXtbyregionsorted{region}(1:numdates,:);
                    elseif var==2
                        reghotdaylist=topXXwbtbyregionsorted{region}(1:numdates,:);
                    elseif var==3
                        reghotdaylist=topXXqbyregionsorted{region}(1:numdates,:);
                    end
                    for i=1:5 %5 possible days, exact one dictated by numdaysbefore
                        sumtopXXanomsactualdata{var,region,i}=zeros(144,73);
                    end 
                    for i=1:5;alltopXXanomsactualdata{var,region,i}=zeros(100,144,73);end %save all the data so can determine which
                        %gridpts are significant to 95% confidence (i.e. which have at least 95% of their anomalies with the same sign)
                    for i=1:5;gridptsignifarray{var,region,i}=zeros(144,73);end
                    for row=1:size(reghotdaylist,1)
                        thisyear=reghotdaylist(row,1);
                        thismon=reghotdaylist(row,2);if thismon<=9;addedzero='0';else addedzero='';end
                        thisday=reghotdaylist(row,3);
                        thisdoy=DatetoDOY(thismon,thisday,thisyear);
                        %If plotting a day several days before, get a revised date so the right mat files can be fetched
                        thisdoy=thisdoy-numdaysbefore;%disp(row);disp(thisdoy);
                        thismon=DOYtoMonth(thisdoy,thisyear);
                        thisday=DOYtoDOM(thisdoy,thisyear);

                        relevantmatfile=load(strcat(ncepdailydataDir,'hgt/',num2str(thisyear),'/',...
                            'hgt_',num2str(thisyear),'_',addedzero,num2str(thismon),'_500.mat'));
                        actualdata=eval(['relevantmatfile.hgt_' num2str(thisyear) '_' addedzero num2str(thismon) '_500']);
                        actualdata=actualdata{3}; %size of actualdata should now be (144)x(73)x(1 level)x(# days in month)
                        actualdata=actualdata(:,:,:,thisday);
                        thisdayavg=fullhgtdatancep{thismon-monthiwf+1,thisday};
                        thisdayanomgivenactualdata=actualdata-thisdayavg;
                        %thisdaystananomgivenactualdata=(actualdata-thisdayavg)./stdevdatabymon{thismon-monthiwf+1};
                        alltopXXanomsactualdata{var,region,ndbcateg}(row,:,:)=thisdayanomgivenactualdata;
                    end
                    %Compute mean & st dev
                    avgofanomsactualdata{var,region,ndbcateg}=mean(alltopXXanomsactualdata{var,region,ndbcateg},1);
                    stdevofanomsactualdata{var,region,ndbcateg}=std(alltopXXanomsactualdata{var,region,ndbcateg},1);
                    %Now that we know the st dev, compute standardized anomalies
                    for row=1:size(reghotdaylist,1)
                        alltopXXstananomsactualdata{var,region,ndbcateg}(row,:,:)=...
                            alltopXXanomsactualdata{var,region,ndbcateg}(row,:,:)./stdevofanomsactualdata{var,region,ndbcateg};
                    end
                    avgofstananomsactualdata{var,region,ndbcateg}=mean(alltopXXstananomsactualdata{var,region,ndbcateg},1);
                    stdevofstananomsactualdata{var,region,ndbcateg}=std(alltopXXstananomsactualdata{var,region,ndbcateg},1);

                    %With a 95% confidence standard, determine which gridpts are significant for this var & region
                    temp=double(squeeze(avgofstananomsactualdata{var,region,ndbcateg}-2*stdevofstananomsactualdata{var,region,ndbcateg}));
                    gridptsignifarray{var,region,ndbcateg}=zeros(144,73);
                    temp2=temp>0;gridptsignifarray{var,region,ndbcateg}(temp2)=1;
                    clear alltopXXanomsactualdata;
                end
            end
            disp('Finished computing z500 anomaly composites');
            save(strcat(curArrayDir,'griddedavgsarrays'),'avgofanomsactualdata','avgofstananomsactualdata','gridptsignifarray',...
                'stdevofanomsactualdata','stdevofstananomsactualdata','-append');
        end
    end
    
    %Bootstrapping follows McKinnon et al. 2016 method, which is as follows:
        %-the actual comparison consists of 100 ordered hot days and 100 co-occurring z500/SST/etc anomalies
        %-take the list of ordered hot days and, using a block size of 1 year, shuffle it 10,000 times
        %-keep the original z500/SST/etc anomalies, in the original order, as the 'corresponding' ones
        %therefore, surrogate timeseries 1 might be {year 17 hot days;year 5 hot days;year 29 hot days;...}
        %   paired with {year 1 SST anomalies;year 2 SST anomalies;year 3 SST anomalies;...}
        %-the actual z500/SST/etc anomaly is significant if its magnitude is >=95th percentile of surrogate magnitudes
    if dosigniftest==1 %various approaches to ascertain the signif of NCEP z500 anomalies
        meananom={};
        for var=variwf:variwl
            for region=regiwf:regiwl
                if var==1
                    reghotdaylist=topXXtbyregionsorted{region}(1:numdates,:);
                elseif var==2
                    reghotdaylist=topXXwbtbyregionsorted{region}(1:numdates,:);
                elseif var==3
                    reghotdaylist=topXXqbyregionsorted{region}(1:numdates,:);
                end
                actualtopXXanoms=zeros(numdates,144,73);
                for row=1:size(reghotdaylist,1)
                    thisyear=reghotdaylist(row,1);
                    thismon=reghotdaylist(row,2);if thismon<=9;addedzero='0';else addedzero='';end
                    thisday=reghotdaylist(row,3);
                    thisdoy=DatetoDOY(thismon,thisday,thisyear);
                    %If plotting a day several days before, get a revised date so the right mat files can be fetched
                    thisdoy=thisdoy-numdaysbefore;%disp(row);disp(thisdoy);
                    thismon=DOYtoMonth(thisdoy,thisyear);
                    thisday=DOYtoDOM(thisdoy,thisyear);
                    %Hot day list including numdaysbefore (same as reghotdaylist if ndb=0)
                    reghotdaylistinclndb(row,1)=thisyear;
                    reghotdaylistinclndb(row,2)=thismon;
                    reghotdaylistinclndb(row,3)=thisday;

                    relevantmatfile=load(strcat(ncepdailydataDir,'hgt/',num2str(thisyear),'/',...
                        'hgt_',num2str(thisyear),'_',addedzero,num2str(thismon),'_500.mat'));
                    actualdata=eval(['relevantmatfile.hgt_' num2str(thisyear) '_' addedzero num2str(thismon) '_500']);
                    actualdata=actualdata{3}; %size of actualdata should now be (144)x(73)x(1 level)x(# days in month)
                    actualdata=actualdata(:,:,:,thisday);
                    thisdayavg=fullhgtdatancep{thismon-monthiwf+1,thisday};
                    thisdayanomgivenactualdata=actualdata-thisdayavg;
                    actualtopXXanoms(row,:,:)=thisdayanomgivenactualdata;
                end
                
                %Now, create the surrogates
                reghotdaylistchron=sortrows(reghotdaylistinclndb,[1 2 3]);
                
                %Alternative approach 1 (not McKinnon):
                %Simply choose 100 random days (actually ~50, see a couple lines down), and get the avg SSTs for these
                %Repeat 100 times
                %Actual SST anomalies are significant if their magnitude is >=95th percentile of surrogates
                %To address autocorrelation, treat each month as a block (so ~50 independent members, not 100)
                %First order of business is to determine how many different months are represented in
                    %the current version of reghotdaylistchron, and how many are Jun, Jul, etc
                %Then, if we know that say Jun 1995 has 4 dates, Jul 1995 has 2 dates, etc, then we can pick
                    %random Jun and Jul dates and repeat them 4 and 2 times respectively in the surrogates to
                    %match the observed autocorrelation
                
                
                %first column of randdatessetup is month to pick from in the following surrogate loops
                %second column is whether to repeat the same information in the next row (i.e. because it's essentially
                    %the same as the current one)
                for row=1:numdates-1
                    randdatessetup(row,1)=reghotdaylistchron(row,2);
                    if reghotdaylistchron(row,1)==reghotdaylistchron(row+1,1) &&...
                        reghotdaylistchron(row,2)==reghotdaylistchron(row+1,2) %next entry has same month & year
                        randdatessetup(row,2)=1;
                    else
                        randdatessetup(row,2)=0;
                    end
                end
                    
                %Actually do the surrogate loops
                if altapproach==1
                    for surrnum=1:100
                        if rem(surrnum,20)==0;fprintf('Computing surrogate number %d\n',surrnum);end
                        %Choose random months in random years (and within those, random days) from which to pull SST data
                        for i=1:size(randdatessetup,1)
                            curmonth=randdatessetup(i,1);curmonthlen=monthlengthsdays(curmonth);
                            if i==1 %new random day & year
                                randdatessetup(i,3)=randi([1,curmonthlen]); %random day within month
                                randdatessetup(i,4)=randi([yeariwf,yeariwl]); %random year
                            elseif randdatessetup(i-1,2)==1 %repeat previous day & year
                                randdatessetup(i,3)=randdatessetup(i-1,3);
                                randdatessetup(i,4)=randdatessetup(i-1,4);
                            elseif randdatessetup(i-1,2)==0 %new random day & year
                                randdatessetup(i,3)=randi([1,curmonthlen]); %random day within month
                                randdatessetup(i,4)=randi([yeariwf,yeariwl]); %random year
                            end
                        end
                        %Pull data for each of these surrogate dates
                        for i=1:size(randdatessetup,1)
                            thismon=randdatessetup(i,1);thisday=randdatessetup(i,3);thisyear=randdatessetup(i,4);
                            relevantmatfile=load(strcat(ncepdailydataDir,'hgt/',num2str(thisyear),'/',...
                                    'hgt_',num2str(thisyear),'_',addedzero,num2str(thismon),'_500.mat'));
                            actualdata=eval(['relevantmatfile.hgt_' num2str(thisyear) '_' addedzero num2str(thismon) '_500']);
                            clear relevantmatfile;
                            actualdata=actualdata{3}; %size of actualdata should now be (144)x(73)x(1 level)x(# days in month)
                            actualdata=actualdata(:,:,:,thisday);
                            thisdayavg=fullhgtdatancep{thismon-monthiwf+1,thisday};
                            thisdayanomgivenactualdata=actualdata-thisdayavg;clear actualdata;clear thisdayavg;
                            surrogatetopXXanoms(i,:,:)=thisdayanomgivenactualdata;
                        end
                        %For this set of surrogate dates, compute the mean anomaly magnitude for each gridbox
                        surrogatetopXXanommagns=abs(surrogatetopXXanoms);
                        meananom{var,region}(surrnum,:,:)=squeeze(mean(surrogatetopXXanommagns,1));
                        clear surrogatetopXXanoms;
                    end
                    %90th & 95th pct of mean-anom magnitudes for each gridbox
                    meananom90pct{var,region,ndbcateg}=squeeze(quantile(meananom{var,region},0.90));
                    meananom95pct{var,region,ndbcateg}=squeeze(quantile(meananom{var,region},0.95));
                elseif altapproach==2
                    %Alternative approach 2: simply do a categorical test, rather than a magnitude-based one
                    %Point is to test: are patterns on hot days *robust*, even if they're not especially *strong*?
                    
                    %a. for hot days, at each gridpt, what % of days have a pos vs neg anomaly?
                        %--> this defines the pattern which will be tested against
                    for row=1:144
                        for col=1:73
                            posc=0;
                            for i=1:100
                                if actualtopXXanoms(i,row,col)>=0;posc=posc+1;end
                            end
                            actualfractionposanomalies{var,region,ndbcateg}(row,col)=posc;
                        end
                    end
                    
                    %b. get 1000 sets of 100 days each, and, for each set, compute the % of days with a pos vs neg anomaly
                    %Now we have the 100 actual dates and a measure of their autocorrelation
                    %Establish how many dates from each month we want to pick
                    
                    %first column of randdatessetup is month to pick from in the following surrogate loops
                    %second column is whether to repeat the same information in the next row (i.e. because it's essentially
                        %the same as the current one)
                    for row=1:numdates-1
                        randdatessetup(row,1)=reghotdaylistchron(row,2);
                        if reghotdaylistchron(row,1)==reghotdaylistchron(row+1,1) &&...
                            reghotdaylistchron(row,2)==reghotdaylistchron(row+1,2) %next entry has same month & year
                            randdatessetup(row,2)=1;
                        else
                            randdatessetup(row,2)=0;
                        end
                    end

                    %Surrogate loop
                    for surrnum=1:1000
                        if rem(surrnum,100)==0;fprintf('Computing surrogate %d for var %d, region %d \n',surrnum,var,region);end
                        %Choose random months in random years (and within those, random days) from which to pull SST data
                        for i=1:size(randdatessetup,1)
                            curmonth=randdatessetup(i,1);curmonthlen=monthlengthsdays(curmonth-4);
                            if i==1 %new random day & year
                                randdatessetup(i,3)=randi([1,curmonthlen]); %random day within month
                                randdatessetup(i,4)=randi([yeariwf,yeariwl]); %random year
                            elseif randdatessetup(i-1,2)==1 %repeat previous day & year
                                randdatessetup(i,3)=randdatessetup(i-1,3);
                                randdatessetup(i,4)=randdatessetup(i-1,4);
                            elseif randdatessetup(i-1,2)==0 %new random day & year
                                randdatessetup(i,3)=randi([1,curmonthlen]); %random day within month
                                randdatessetup(i,4)=randi([yeariwf,yeariwl]); %random year
                            end
                        end
                        %Pull data for each of these surrogate dates
                        for i=1:size(randdatessetup,1)
                            thismon=randdatessetup(i,1);thisday=randdatessetup(i,3);thisyear=randdatessetup(i,4);
                            relevantmatfile=load(strcat(ncepdailydataDir,'hgt/',num2str(thisyear),'/',...
                                    'hgt_',num2str(thisyear),'_',addedzero,num2str(thismon),'_500.mat'));
                            actualdata=eval(['relevantmatfile.hgt_' num2str(thisyear) '_' addedzero num2str(thismon) '_500']);
                            clear relevantmatfile;
                            actualdata=actualdata{3}; %size of actualdata should now be (144)x(73)x(1 level)x(# days in month)
                            actualdata=actualdata(:,:,:,thisday);
                            thisdayavg=fullhgtdatancep{thismon-monthiwf+1,thisday};
                            thisdayanomgivenactualdata=actualdata-thisdayavg;clear actualdata;clear thisdayavg;
                            surrogatetopXXanoms(i,:,:)=thisdayanomgivenactualdata;
                        end
                        %For this set of surrogate dates, compute the % of anomalies that are pos vs neg for each gridbox
                        for row=1:144
                            for col=1:73
                                posc=0;
                                for i=1:size(surrogatetopXXanoms,1)
                                    if surrogatetopXXanoms(i,row,col)>=0;posc=posc+1;end
                                end
                                surrogatefractionposanomalies(surrnum,row,col)=100*posc./size(surrogatetopXXanoms,1);
                            end
                        end
                        clear surrogatetopXXanoms;
                    end
                    %90th & 95th pct of these pos/neg percentages for each gridbox, for comparison to the actual number computed in part (a)
                    surrogate2point5pctposanom{var,region,ndbcateg}=squeeze(quantile(surrogatefractionposanomalies,0.025));
                    surrogate5pctposanom{var,region,ndbcateg}=squeeze(quantile(surrogatefractionposanomalies,0.05));
                    surrogate95pctposanom{var,region,ndbcateg}=squeeze(quantile(surrogatefractionposanomalies,0.95));
                    surrogate97point5pctposanom{var,region,ndbcateg}=squeeze(quantile(surrogatefractionposanomalies,0.975));
                    save(strcat(curArrayDir,'nceparrays'),'surrogate2point5pctposanom','surrogate5pctposanom',...
                        'surrogate95pctposanom','surrogate97point5pctposanom','actualfractionposanomalies','-append');
                end
            end
        end
    end
    
    if domapping==1 %NCEP mapping
        for var=variwf:variwl
            if var==1;varname='T';elseif var==2;varname='WBT';elseif var==3;varname='q';end
            for region=regiwf:regiwl
                %disp(region);
                if ensocomposite==1
                    if elnino==1
                        if plotstananoms==1
                            data={nceplats;nceplons;avgofanomsstanelninosummers};overlaydata=data;
                        else
                            data={nceplats;nceplons;avgofanomselninosummers};overlaydata=data;
                        end
                    else
                        if plotstananoms==1
                            data={nceplats;nceplons;avgofanomsstanlaninasummers};overlaydata=data;
                        else
                            data={nceplats;nceplons;avgofanomslaninasummers};overlaydata=data;
                        end
                    end
                else
                    %Binary (1/0) stippling matrices indicating significance at the 90th and 95th percentiles
                    stipplematrix95{var,region,ndbcateg}=zeros(144,73);stipplematrix90{var,region,ndbcateg}=zeros(144,73);
                    
                    if plotstananoms==1
                        data={nceplats;nceplons;avgofstananomsactualdata{var,region,ndbcateg}};overlaydata=data;
                        for i=1:144
                            for j=1:73
                                if altapproach==2
                                    if actualfractionposanomaliessst{var,region,ndbcateg}(i,j)>=surrogate97point5pctposanom{var,region,ndbcateg}(i,j) ||...
                                            actualfractionposanomaliessst{var,region,ndbcateg}(i,j)<=surrogate2point5pctposanom{var,region,ndbcateg}(i,j)
                                        stipplematrix95{var,region,ndbcateg}(i,j)=1; %i.e. 95% confidence level
                                    else
                                        stipplematrix95{var,region,ndbcateg}(i,j)=0;
                                    end
                                    if actualfractionposanomaliessst{var,region,ndbcateg}(i,j)>=surrogate95pctposanom{var,region,ndbcateg}(i,j) ||...
                                            actualfractionposanomaliessst{var,region,ndbcateg}(i,j)<=surrogate5pctposanom{var,region,ndbcateg}(i,j)
                                        stipplematrix90{var,region,ndbcateg}(i,j)=1; %i.e. 90% confidence level
                                    else
                                        stipplematrix90{var,region,ndbcateg}(i,j)=0;
                                    end
                                end
                            end
                        end
                    else
                        if altapproach==1
                            data={nceplats;nceplons;avgofanomsactualdata{var,region,ndbcateg}};overlaydata=data;
                            temp=squeeze(data{3});
                        elseif altapproach==2
                            data={nceplats;nceplons;avgofanomsactualdata{var,region,ndbcateg}};overlaydata=data;
                        end
                        
                        for i=1:144
                            for j=1:73
                                if altapproach==1
                                    if abs(temp(i,j))>=meananom95pct{var,region,ndbcateg}(i,j)
                                        stipplematrix95{var,region,ndbcateg}(i,j)=1;
                                    else
                                        stipplematrix95{var,region,ndbcateg}(i,j)=0;
                                    end
                                    if abs(temp(i,j))>=meananom90pct{var,region,ndbcateg}(i,j)
                                        stipplematrix90{var,region,ndbcateg}(i,j)=1;
                                    else
                                        stipplematrix90{var,region,ndbcateg}(i,j)=0;
                                    end
                                elseif altapproach==2
                                    if actualfractionposanomaliessst{var,region,ndbcateg}(i,j)>=surrogate97point5pctposanom{var,region,ndbcateg}(i,j) ||...
                                            actualfractionposanomaliessst{var,region,ndbcateg}(i,j)<=surrogate2point5pctposanom{var,region,ndbcateg}(i,j)
                                        stipplematrix95{var,region,ndbcateg}(i,j)=1; %i.e. 95% confidence level
                                    else
                                        stipplematrix95{var,region,ndbcateg}(i,j)=0;
                                    end
                                    if actualfractionposanomaliessst{var,region,ndbcateg}(i,j)>=surrogate95pctposanom{var,region,ndbcateg}(i,j) ||...
                                            actualfractionposanomaliessst{var,region,ndbcateg}(i,j)<=surrogate5pctposanom{var,region,ndbcateg}(i,j)
                                        stipplematrix90{var,region,ndbcateg}(i,j)=1; %i.e. 90% confidence level
                                    else
                                        stipplematrix90{var,region,ndbcateg}(i,j)=0;
                                    end
                                end
                            end
                        end
                    end
                end
                save(strcat(curArrayDir,'nceparrays'),'stipplematrix90','stipplematrix95','-append');
                %Set color range and step size
                if plotstananoms==1
                    cmin=-1;cmax=1;
                    if var==1
                        if region==1;mystep=0.18;elseif region==2;mystep=0.19;elseif region==3;mystep=0.21;...
                        elseif region==4;mystep=0.21;elseif region==5;mystep=0.18;elseif region==6;mystep=0.21;...
                        elseif region==7;mystep=0.19;elseif region==8;mystep=0.17;
                        end
                    elseif var==2 && numdaysbefore==0
                        if region==1;mystep=0.18;elseif region==2;mystep=0.19;elseif region==3;mystep=0.18;...
                        elseif region==4;mystep=0.21;elseif region==5;mystep=0.21;elseif region==6;mystep=0.21;...
                        elseif region==7;mystep=0.21;elseif region==8;mystep=0.21;
                        end
                    elseif var==2 && numdaysbefore==5
                        if region==1;mystep=0.18;elseif region==2;mystep=0.18;elseif region==3;mystep=0.18;...
                        elseif region==4;mystep=0.19;elseif region==5;mystep=0.19;elseif region==6;mystep=0.19;...
                        elseif region==7;mystep=0.19;elseif region==8;mystep=0.19;
                        end
                    elseif var==2 && numdaysbefore==10
                        if region==1;mystep=0.19;elseif region==2;mystep=0.19;elseif region==3;mystep=0.21;...
                        elseif region==4;mystep=0.21;elseif region==5;mystep=0.2;elseif region==6;mystep=0.21;...
                        elseif region==7;mystep=0.21;elseif region==8;mystep=0.21;
                        end
                    end
                else
                    cmin=-100;cmax=100;
                    if numdaysbefore==0
                        if region==5;mystep=14;elseif region==8;mystep=14;else mystep=14;end
                    else
                        if region<=5;mystep=25;elseif region==8;mystep=25;else mystep=25;end
                        %3 & 8 worked with 20
                    end
                end
                %Set other arguments
                vararginnew={'variable';'height';'contour';1;'mystepunderlay';mystep;'plotCountries';1;...
                    'underlaycaxismin';cmin;'underlaycaxismax';cmax;'datatounderlay';data;'underlayvariable';'temperature';...
                    'overlaynow';0;'anomavg';'avg';'centeredon';180;'addtext';'dontaddtext'};
                if makefinal==1;vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=1;end
                %vararginnew={'variable';'height';'contour';1;'mystep';20;'plotCountries';1;...
                %    'caxismethod';'regional10';'datatooverlay';overlaydata;'overlaynow';0;...
                %    'datatounderlay';data;'anomavg';'avg';'centeredon';180;'addtext';'dontaddtext'};
                titledescrip='500-hPa Geopotential Height';
                regionformap='nhplustropics';datatype='NCEP';
                if makefinal==1
                    if region==regiwf;figure(figc);clf;figc=figc+1;end
                    hold on;
                    axissz=8;labelsz=10;titlesz=12;
                    if numrowstomake==3 && numcolstomake==3
                        if region==8;subplot(3,3,region);hold on;else subplot(3,3,region-1);end
                    elseif numrowstomake==4 && numcolstomake==2
                        subplot(4,2,8);
                    end
                else
                    figure(figc);clf;figc=figc+1;
                    axissz=14;labelsz=18;titlesz=20;
                end

                data{3}=double(squeeze(data{3}));
                %Actually do the plotting
                plotModelData(data,regionformap,vararginnew,datatype);
                if makefinal==1;clear fullshadingdescr;clear fullcontoursdescr;end
                
                %Add hatching/stippling if and where gridpts' anomalies are significantly different from zero
                for i=1:144
                    for j=1:73
                        if stipplematrix95{var,region,ndbcateg}(i,j)==1
                            thislat=nceplats(i,j);thislon=nceplons(i,j);
                            geoshow(thislat,thislon,'displaytype','point','marker','o','markerfacecolor','k',...
                                'markeredgecolor','k','markersize',1);
                        end
                    end
                end
                    
                %Add title, colorbar, etc.
                if region==1;theornot='';else theornot='the ';end
                titlepart1=sprintf('Composited Daily Anomalies of %s',titledescrip);
                if numdaysbefore==0
                    if ensocomposite==0 %doing normal top-XX-days composite
                        titlepart2=sprintf('for %d Extreme %s Days in %s%s',numdates,varname,theornot,ncaregionnamemaster{region});
                    elseif elnino==1 %doing ENSO composite (El Nino)
                        titlepart2='for 5 El Nino Summers';
                    else %doing ENSO composite (La Nina)
                        titlepart2='for 5 La Nina Summers';
                    end
                else
                    titlepart2=sprintf('%d Days Before %d Extreme %s Days in %s%s',...
                        numdaysbefore,numdates,varname,theornot,ncaregionnamemaster{region});
                end
                maxcbval=max(abs(cmin),abs(cmax));
                caxisRange=[-1*maxcbval maxcbval];caxis(caxisRange);
                if plotstananoms==1;colorbarlabel='Standardized Height Anomaly';else colorbarlabel='Height Anomaly (m)';end
                colormap(colormaps('gh','more','not'));
                if makefinal==0;colorbarc=7;edamultipurposelegendcreator;end
                
                
                if makefinal==1 %title is just letters identifying the subplots, plus region names
                    t=title(sprintf(figletterlabels{region-1}),'fontname','arial','fontweight','bold','fontsize',titlesz);
                    set(t,'horizontalalignment','left');set(t,'units','normalized');
                    h1=get(t,'position');set(t,'position',[0 h1(2)-0.1 h1(3)]);
                    if region==4 || region==5;horizpos=0.3;else horizpos=0.4;end
                    text(horizpos,1.12,ncaregionnamemaster{region},'units','normalized','fontname','arial',...
                        'fontweight','bold','fontsize',14);
                else %otherwise, title is descriptive as defined above
                    title({titlepart1,titlepart2},'fontname','arial','fontweight','bold','fontsize',titlesz);
                end
                
                curpart=2;figloc=figDir;
                if plotstananoms==1
                    wordadd='stan';
                else
                    wordadd='';
                end
                if makefinal==1
                    if numdaysbefore==0
                        figname=strcat('compmap',wordadd,'anomgh500onlyvar',num2str(varname),'final');
                    else
                        figname=strcat('compmap',wordadd,'anomgh500onlyvar',num2str(varname),'ndb',num2str(numdaysbefore),'final');
                    end
                else
                    if ensocomposite==0
                        if numdaysbefore==0
                            figname=strcat('compmap',wordadd,'anomgh500var',num2str(varname),'region',shortregnames{region});
                        else
                            figname=strcat('compmap',wordadd,'anomgh500var',num2str(varname),'region',shortregnames{region},...
                                'ndb',num2str(numdaysbefore));
                        end
                    else
                        if elnino==1
                            figname=strcat('compmap',wordadd,'anomgh500elninosummers');
                        else
                            figname=strcat('compmap',wordadd,'anomgh500laninasummers');
                        end
                    end
                end
                exist windbarbsdescr;
                if ans==0;inclrefvectext=0;else inclrefvectext=1;end %info to be passed to highqualityfiguresetup
                if makefinal==1
                    %if numrowstomake==3;if region==7;colnow=1.5;elseif region==8;colnow=2.5;end;end %centered b/c only 2 elements in row of 3
                    if numrowstomake==4 && numcolstomake==2
                        rownow=rem((region-1),numrowstomake);if rownow==0;rownow=numrowstomake;end
                        if region-1<=numrowstomake;colnow=1;else colnow=2;end
                        disp('Rownow is:');disp(rownow);disp('Colnow is:');disp(colnow);
                        if rownow==1;rownowpos=0.24;elseif rownow==2;rownowpos=0.49;elseif rownow==3;rownowpos=0.74;else rownowpos=0.99;end
                        if colnow==1;colnowpos=0.075;elseif colnow==2;colnowpos=0.075+0.5;end
                        if colnow==2;rownowpos=rownowpos+0.125;end
                        %disp(rownowpos);disp(colnowpos);if region==8;break;end
                        set(gca,'Position',[colnowpos-0.02 1-rownowpos 0.35 0.24]);
                    elseif numrowstomake==3 && numcolstomake==3
                        rownow=round2((region-1)/numrowstomake,1,'ceil');
                        colnow=rem(region-1,numcolstomake);if colnow==0;colnow=numcolstomake;end
                        if rownow==1;rownowpos=0.323;elseif rownow==2;rownowpos=0.657;else rownowpos=0.99;end
                        if colnow==1;colnowpos=0.02;elseif colnow==1.5;colnowpos=0.1668;elseif colnow==2;colnowpos=0.3206;...
                        elseif colnow==2.5;colnowpos=0.466;else colnowpos=0.6202;end
                        %disp(rownowpos);disp(colnowpos);
                        set(gca,'Position',[colnowpos 1-rownowpos 0.2796 0.313]);
                        if region==8;set(gca,'Position',[0.3325 1-rownowpos 0.2796 0.313]);end
                    end
                else
                    highqualityfiguresetup;
                    close;
                end
                %disp(region);
                %return;
            end
            if makefinal==1
                %Make one large colorbar for all subplots
                cbar=colorbar;
                set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
                set(cbar,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
                cpos=get(cbar,'Position');cpos(1)=0.925;cpos(2)=0.05;cpos(3)=0.017;cpos(4)=0.9;
                set(cbar,'Position',cpos);
                highqualityfiguresetup;
            end
        end
    end
end


%Same as above but for NOAA ERSST SST anomalies
if plotsstcompositemapsnowindows==1
    if usedetrended==1
        detrremark='detr';detrtitleremark=' (Detrended)';
    else
        detrremark='';detrtitleremark='';
    end
    if needtodocalc==1
        %avgofanomsactualdata={};
        for var=1:2
            for region=1:8
                if var==1
                    reghotdaylist=topXXtbyregionsorted{region}(1:numdates,:);
                elseif var==2
                    reghotdaylist=topXXwbtbyregionsorted{region}(1:numdates,:);
                end
                %Sort reghotdaylist chronologically
                reghotdaylist=sortrows(reghotdaylist,[1 2 3]);
                sumtopXXanomsactualdata{var,region}=zeros(numlons,numlats);
                alltopXXanomsactualdata{var,region}=zeros(100,numlons,numlats); %save all the data so can determine which
                    %gridpts are significant to 95% confidence (i.e. which have at least 95% of their anomalies with the same sign)
                gridptsignifarray{var,region}=zeros(numlons,numlats);
                for row=1:size(reghotdaylist,1)
                    thisyear=reghotdaylist(row,1);
                    thismon=reghotdaylist(row,2);if thismon<=9;addedzero='0';else addedzero='';end
                    thisday=reghotdaylist(row,3);
                    thismonthanom=monthbymonthgridptanomsst(:,:,thisyear-yeariwf+1,thismon);
                    sumtopXXanomsactualdata{var,region}=sumtopXXanomsactualdata{var,region}+thismonthanom;
                    alltopXXanomsactualdata{var,region}(row,:,:)=thismonthanom;
                end
                %Divide by numdates (the number of days summed over)
                avgofanoms{var,region}=double(sumtopXXanomsactualdata{var,region}./numdates);
                
                %Deal with coasts by applying a homogeneity requirement (rather than having to track
                %the number of valid points for all gridcells in the whole domain)
                unphysicalvalue=1;
                temp=avgofanoms{var,region}>=unphysicalvalue;
                avgofanoms{var,region}(temp)=NaN;
                unphysicaldiff=0.3; %unphysical if difference from surrounding-8-cell average (excluding NaN's) is at least this much
                x=avgofanoms{var,region};
                for i=2:179
                    for j=2:82
                        avgaroundthisgridcell=nanmean([x(i+1,j);x(i+1,j-1);x(i,j-1);x(i-1,j-1);x(i-1,j);x(i-1,j+1);x(i,j+1);x(i+1,j+1)]);
                        thisgridcellval=x(i,j);
                        if abs(thisgridcellval-avgaroundthisgridcell)>=unphysicaldiff
                            avgofanoms{var,region}(i,j)=NaN;
                        end
                    end
                end
                
                %With a 95% confidence standard, determine which gridpts are significant for this var & region
                for i=1:numlons
                    for j=1:numlats
                        anomsforthisgridpt=sort(squeeze(alltopXXanomsactualdata{var,region}(:,i,j)));
                        if (anomsforthisgridpt(5)>0 && anomsforthisgridpt(numdates)>0) ||...
                                (anomsforthisgridpt(5)<0 && anomsforthisgridpt(numdates)<0)
                            gridptsignifarray{var,region}(i,j)=1;
                        else
                            gridptsignifarray{var,region}(i,j)=0;
                        end
                    end
                end
            end
        end
        avgofanomsersst=avgofanoms;gridptsignifarrayersst=gridptsignifarray;
        save(strcat(curDir,'correlsstarrays'),'avgofanomsersst','gridptsignifarrayersst','-append');
    end
    
    if domapping==1
        for var=1:1
            if var==1
                correlsst=correlsstteverygridptregions;varname='T';
            elseif var==2
                correlsst=correlsstwbteverygridptregions;varname='WBT';
            end
            for region=6:6
                howtoexamine='regular';
                roiname=ncaregionnamemaster{region};
                if region==1;theornot='';else theornot='the ';end
                temp=double(avgofanomsersst{var,region});
                newtemp=[temp(91:numlons,:);temp(1:90,:)];
                underlaydata={double(ersstlats);double(ersstlons);temp};
                curpart=1;highqualityfiguresetup;
                datarsu=flipud(fliplr(underlaydata{3})');
                latsrsu=flipud(fliplr(ersstlats)');
                lonsrsu=flipud(fliplr(ersstlons)');
                gridptsignifarrayrsu=flipud(fliplr(gridptsignifarray{var,region})');
                
                figure(figc);clf;figc=figc+1;
                temp=datarsu==0;datarsu(temp)=NaN;
                imagescnan(datarsu,'NanColor',colors('gray')); %gray out the continents
                boxcornerlat=zeros(size(datarsu,1),size(datarsu,2));
                boxcornerlon=zeros(size(datarsu,1),size(datarsu,2));
                boxhatch=0;
                for i=1:numlats
                    for j=1:numlons
                        if gridptsignifarrayrsu(i,j)==1 %a significant gridpt
                            boxcornerlat(i,j)=latsrsu(i,j);boxcornerlon(i,j)=lonsrsu(i,j);
                            boxhatch(i,j)=1;
                        else
                            boxhatch(i,j)=0;
                        end
                    end
                end
                %boxhatch=flipud(boxhatch);
                %Make lines that actually do the hatching
                for i=1:numlats
                    for j=1:numlons
                        if boxhatch(i,j)==1
                            newroutelat=-boxcornerlat(i,j);newroutelon=boxcornerlon(i,j);
                            line([j-0.5 j+0.5],[i-0.5 i+0.5],'linewidth',1.5,'color','k');
                        end
                    end
                end

                thingbeingplotted=avgofanoms{var,region};units='deg C';prec=0.01;
                colorbarc=7;cbmin=-1;cbmax=1;colorbarlabel='SST Anomaly (deg C)';
                colormap(colormaps('t','more','not'));
                xlabel('Longitude (deg E)','FontSize',14,'FontWeight','bold','fontname','arial');
                ylabel('Latitude','FontSize',14,'FontWeight','bold','fontname','arial');
                titlec=11;month1='Jun';month2='Aug';
                edamultipurposelegendcreator;
                ylabels={'90';'60';'30';'0';'-30';'-60';'-90'};
                set(gca,'ytick',1:numlats/6:numlats);
                set(gca,'YTickLabel',ylabels,'fontname','arial','fontweight','bold','fontsize',16);
                xlabels={'0';'60';'120';'180';'240';'300';'360'};
                set(gca,'xtick',1:numlons/6:numlons);
                set(gca,'XTickLabel',xlabels,'fontname','arial','fontweight','bold','fontsize',16);
                set(gca,'FontSize',16,'FontWeight','bold','fontname','arial');
                curpart=2;figloc=figDir;figname=strcat('mapanomssteverygridpt',varname,...
                    'region',shortregnames{region});
                highqualityfiguresetup;
            end
        end
    end
end

%Same as above but for daily NOAA OISST anomalies

%But first, calculate standardized anomalies for future use (here and in other scripts/projects)
if computestananomsnoaaoisst==1
    %Read in data 20 days at a time, as a compromise between speed and application-memory constraints
    %allsstdatabydoy={};oisststananombydoy={};disp(clock);
    secondhalfofyear=0;
    for outerdoy=1:20:365
    %for outerdoy=361:20:365
        firstdoy=outerdoy;lastdoy=outerdoy+19;
        fprintf('Computing stan anoms of daily SST data for doys=%d-%d\n',firstdoy,lastdoy);
        for year=1982:2014
            fprintf('year is %d\n',year);
            relyear=year-1981;
            needtoreread=1; %always need to reread when starting on a new year
            for innerdoy=1:20
                if rem(year,4)==0;ly=1;jun30doy=182;yearlen=366;else ly=0;jun30doy=181;yearlen=365;end
                if innerdoy==1 || outerdoy+innerdoy-1==182 || outerdoy+innerdoy-1==183;needtoreread=1;else needtoreread=0;end
                if needtoreread==1
                    if ly==1 && outerdoy+innerdoy-1<=182
                        dailysstfile=ncread(strcat(dailysstfileloc,'tos_OISST_L4_AVHRR-only-v2_',num2str(year),'0101-',...
                                num2str(year),'0630.nc'),'tos'); %daily data from Jan 1 to Jun 30
                        secondhalfofyear=0;
                    elseif ly==1
                        dailysstfile=ncread(strcat(dailysstfileloc,'tos_OISST_L4_AVHRR-only-v2_',num2str(year),'0701-',...
                                    num2str(year),'1231.nc'),'tos'); %daily data from Jul 1 to Dec 31
                        secondhalfofyear=1;
                    elseif ly==0 && outerdoy+innerdoy-1<=181
                        dailysstfile=ncread(strcat(dailysstfileloc,'tos_OISST_L4_AVHRR-only-v2_',num2str(year),'0101-',...
                                num2str(year),'0630.nc'),'tos'); %daily data from Jan 1 to Jun 30
                        secondhalfofyear=0;
                    else
                        dailysstfile=ncread(strcat(dailysstfileloc,'tos_OISST_L4_AVHRR-only-v2_',num2str(year),'0701-',...
                                    num2str(year),'1231.nc'),'tos'); %daily data from Jul 1 to Dec 31
                        secondhalfofyear=1;
                    end
                end
                if outerdoy+innerdoy-1<=yearlen
                    if secondhalfofyear==0
                        allsstdatabydoy{outerdoy+innerdoy-1}(relyear,:,:)=squeeze(dailysstfile(:,:,outerdoy+innerdoy-1));
                    else
                        allsstdatabydoy{outerdoy+innerdoy-1}(relyear,:,:)=squeeze(dailysstfile(:,:,outerdoy+innerdoy-1-jun30doy));
                    end
                end
            end
        end
        %Compute stan anoms for all outerdoy in this chunk
        for innerdoy=1:20
            if outerdoy+innerdoy-1<=366
                oisststananombydoy{outerdoy+innerdoy-1}=std(allsstdatabydoy{outerdoy+innerdoy-1});
                oisststananombydoy{outerdoy+innerdoy-1}=squeeze(oisststananombydoy{outerdoy+innerdoy-1});
            end
        end
        %Delete data to free up space
        clear allsstdatathisdoy;allsstdatabydoy={};
        disp(clock);
    end
    save(strcat(curDir,'dailysstarrays'),'oisststananombydoy','-append');
end

%Now, make the composites and do the plotting
if plotsstcompositemapsnowindowsdaily==1
    if needtodocalc==1
        avgofanoms=load(strcat(curArrayDir,'dailysstarrays'),'avgofanomsoisst');
        avgofanoms=avgofanoms.avgofanomsoisst;
        for var=variwf:variwl
            for region=regiwf:regiwl
                if var==1
                    reghotdaylist=topXXtbyregionsorted{region}(1:numdates,:);
                elseif var==2
                    reghotdaylist=topXXwbtbyregionsorted{region}(1:numdates,:);
                end
                reghotdaylist=sortrows(reghotdaylist,[1 2 3]); %sort reghotdaylist chronologically
                
                %Calculate and compile anomalies on hot days
                for ndbcateghere=1:9;sumtopXXanomsactualdata{var,region,ndbcateghere}=zeros(numlons,numlats);end
                %allanomsactualdata{var,region}=zeros(100,numlons,numlats); %save all the data for these days so can determine which
                    %gridpts are significant to 95% confidence (i.e. which have at least 95% of their anomalies with the same sign)
                    %HOWEVER, this is currently problematic because of RAM overload -- if needed, figure out a way around this
                gridptsignifarray{var,region}=zeros(numlons,numlats);numdaysdatafound=0;
                for row=1:size(reghotdaylist,1)
                    thisyear=reghotdaylist(row,1);
                    thismon=reghotdaylist(row,2);if thismon<=9;addedzero='0';else addedzero='';end
                    thisday=reghotdaylist(row,3);
                    thisdoy=DatetoDOY(thismon,thisday,thisyear)-numdaysbefore; %numdaysbefore = 0, 5, 20, etc.
                    if rem(row,10)==0;fprintf('Doing daily-SST calculations -- row is currently %d\n',row);end
                        
                    datafoundthisday=0;
                    %Load in data for this day -- ACTUAL OR ANOMALY, ACCORDING TO WHICH DATASET IS BEING USED
                    if usinganomdata==1
                        dailysstfile=ncread(strcat(dailyanomsstfileloc,'sst.day.anom.',num2str(thisyear),'.v2.nc'),'anom');
                        thisdayobs=dailysstfile(:,:,thisdoy);
                        thisdayanom=thisdayobs; %data IS the anomaly
                        datafoundthisday=1;numdaysdatafound=numdaysdatafound+1;
                        fclose('all');
                    else
                        if thisyear>=1982 && thisyear<=2014 %don't have daily data for 1981 or 2015
                            if thisdoy<=181
                                dailysstfile=ncread(strcat(dailysstfileloc,'tos_OISST_L4_AVHRR-only-v2_',num2str(thisyear),'0101-',...
                                    num2str(thisyear),'0630.nc'),'tos'); %daily data from Jan 1 to Jun 30
                                temp=0;
                            else
                                dailysstfile=ncread(strcat(dailysstfileloc,'tos_OISST_L4_AVHRR-only-v2_',num2str(thisyear),'0701-',...
                                    num2str(thisyear),'1231.nc'),'tos'); %daily data from Jul 1 to Dec 31
                                temp=181;
                            end
                            thisdayobs=dailysstfile(:,:,thisdoy-temp)-273.15;
                            fclose('all');

                            %Get this day's climatology
                            thisdayclimo=fullyearavgdailysst(:,:,thisdoy);
                            %Now, it's straightforward to calculate this day's anomaly
                            thisdayanom=thisdayobs-thisdayclimo;
                            datafoundthisday=1;numdaysdatafound=numdaysdatafound+1;
                        end
                    end
                    
                    if datafoundthisday==1;sumtopXXanomsactualdata{var,region,ndbcateg}=sumtopXXanomsactualdata{var,region,ndbcateg}+thisdayanom;end
                    %allanomsactualdata{var,region}(row,:,:)=thisdayanom;
                end
                %Divide by numdaysdatafound (the number of days summed over)
                avgofanoms{var,region,ndbcateg}=double(sumtopXXanomsactualdata{var,region,ndbcateg}./numdaysdatafound);
                
                %With a 95% confidence standard, determine which gridpts are significant for this var & region
                %NOT CURRENTLY USING
                %for i=1:numlons
                %    for j=1:numlats
                %        anomsforthisgridpt=sort(squeeze(allanomsactualdata{var,region}(:,i,j)));
                %        if (anomsforthisgridpt(5)>0 && anomsforthisgridpt(numdates)>0) ||...
                %                (anomsforthisgridpt(5)<0 && anomsforthisgridpt(numdates)<0)
                %            gridptsignifarray{var,region}(i,j)=1;
                %        else
                %            gridptsignifarray{var,region}(i,j)=0;
                %        end
                %    end
                %end
            end
        end
        avgofanomsoisst=avgofanoms;gridptsignifarrayoisst=gridptsignifarray;
        save(strcat(curArrayDir,'dailysstarrays'),'avgofanomsoisst','gridptsignifarrayoisst','-append');
    end
    
    if domapping==1
        for var=variwf:variwl
            if var==1
                correlsst=correlsstteverygridptregions;varname='T';
            elseif var==2
                correlsst=correlsstwbteverygridptregions;varname='WBT';
            end
            for region=regiwf:regiwl
                howtoexamine='regular';
                roiname=ncaregionnamemaster{region-1};
                if region==1;theornot='';else theornot='the ';end
                temp=double(avgofanomsoisst{var,region});
                underlaydata={double(oisstlats);double(oisstlons);temp};
                datarsu=flipud(underlaydata{3}'); %data, right-side-up
                latsrsu=flipud(underlaydata{1}');
                lonsrsu=flipud(underlaydata{2}');
                gridptsignifarrayrsu=flipud(gridptsignifarray{var,region}');
                
                curpart=1;highqualityfiguresetup;
                
                if makefinal==1
                    if region==regiwf;figure(figc);clf;figc=figc+1;end
                    hold on;
                    axissz=8;labelsz=10;titlesz=12;
                    if numrowstomake==3 && numcolstomake==3
                        if region==8;subplot(3,3,region);else subplot(3,3,region-1);end
                    elseif numrowstomake==4 && numcolstomake==2
                        subplot(4,2,region-1);
                    end
                else
                    figure(figc);clf;figc=figc+1;
                    axissz=14;labelsz=18;titlesz=20;
                end
                
                temp=datarsu==0;datarsu(temp)=NaN;
                imagescnan(datarsu,'NanColor',colors('gray')); %gray out the continents
                boxcornerlat=zeros(size(datarsu,1),size(datarsu,2));
                boxcornerlon=zeros(size(datarsu,1),size(datarsu,2));
                boxhatch=0;
                for i=1:numlats
                    for j=1:numlons
                        %if gridptsignifarrayrsu(i,j)==1 %a significant gridpt
                        %    boxcornerlat(i,j)=latsrsu(i,j);boxcornerlon(i,j)=lonsrsu(i,j);
                        %    boxhatch(i,j)=1;
                        %else
                        %    boxhatch(i,j)=0;
                        %end
                    end
                end
                %Make lines that actually do the hatching
                for i=1:numlats
                    for j=1:numlons
                        %if boxhatch(i,j)==1
                            %newroutelat=-boxcornerlat(i,j);newroutelon=boxcornerlon(i,j);
                            %line([j-0.5 j+0.5],[i-0.5 i+0.5],'linewidth',0.5,'color',colors('forest green'));
                        %end
                    end
                end

                thingbeingplotted=avgofanomsoisst{var,region};units='deg C';prec=0.1;
                cbmin=-1.5;cbmax=1.5;caxisrange=[cbmin cbmax];caxis(caxisrange);
                colormap(colormaps('sst','more','not'));colorbarlabel=sprintf('SST Anomaly (%cC)',char(176));
                if makefinal==0
                    xlabel('Longitude (deg E)','FontSize',labelsz,'FontWeight','bold','fontname','arial');
                    ylabel('Latitude','FontSize',labelsz,'FontWeight','bold','fontname','arial');
                    colorbarc=7;
                end
                titlepart1='Composited Daily Anomalies of SST';
                if numdaysbefore==0
                    titlepart2=sprintf('for %d Extreme %s Days in %s%s',numdates,varname,theornot,ncaregionnamemaster{region-1});
                else
                    titlepart2=sprintf('%d Days Before %d Extreme %s Days in %s%s',...
                        numdaysbefore,numdates,varname,theornot,ncaregionnamemaster{region-1});
                end
                if makefinal==1 %title is just letters
                    t=title(sprintf(figletterlabels{region-1}),'fontname','arial','fontweight','bold','fontsize',titlesz);
                    set(t,'horizontalalignment','left');set(t,'units','normalized');
                    h1=get(t,'position');set(t,'position',[-0.05 h1(2)-0.1 h1(3)]);
                else %otherwise, title is descriptive as defined above
                    title({titlepart1,titlepart2},'fontname','arial','fontweight','bold','fontsize',titlesz);
                end
                
                
                if makefinal==1
                    set(gca,'ytick',[]);set(gca,'xtick',[]);
                else
                    edamultipurposelegendcreator;
                    ylabels={'90';'60';'30';'0';'-30';'-60';'-90'};
                    set(gca,'ytick',1:numlats/6:numlats);
                    set(gca,'YTickLabel',ylabels,'fontname','arial','fontweight','bold','fontsize',labelsz);
                    xlabels={'0';'60';'120';'180';'240';'300';'360'};
                    set(gca,'xtick',1:numlons/6:numlons);
                    set(gca,'XTickLabel',xlabels,'fontname','arial','fontweight','bold','fontsize',labelsz);
                end
                set(gca,'FontSize',labelsz,'FontWeight','bold','fontname','arial');
                curpart=2;figloc=figDir;
                if makefinal==1
                    if numdaysbefore==0
                        figname=strcat('mapanomsstdaily',varname,'final');
                    else
                        figname=strcat('mapanomsstdaily',varname,'ndb',num2str(numdaysbefore),'final');
                    end
                else
                    if numdaysbefore==0
                        figname=strcat('mapanomsstdaily',varname,'reg',shortregnames{region-1});
                    else
                        figname=strcat('mapanomsstdaily',varname,...
                        'reg',shortregnames{region-1},'ndb',num2str(numdaysbefore));
                    end
                end
                if makefinal==1
                    rownow=round2((region-1)/numrowstomake,1,'ceil');
                    colnow=rem(region-1,numcolstomake);if colnow==0;colnow=numcolstomake;end
                    if numrowstomake==3;if region==regiwl;colnow=2;end;end %centered b/c only 2 elements in row of 3
                    if numrowstomake==4 && numcolstomake==2
                        %IF USING, ADJUSTif rownow==1;rownowpos=0.24;elseif rownow==2;rownowpos=0.49;elseif rownow==3;rownowpos=0.74;else rownowpos=0.99;end
                        %if colnow==1;colnowpos=0.075;elseif colnow==2;colnowpos=0.075+0.5;end
                        set(gca,'Position',[colnowpos 1-rownowpos 0.35 0.23]);
                    elseif numrowstomake==3 && numcolstomake==3
                        if rownow==1;rownowpos=0.323;elseif rownow==2;rownowpos=0.657;else rownowpos=0.99;end
                        if colnow==1;colnowpos=0.02;elseif colnow==1.5;colnowpos=0.1668;elseif colnow==2;colnowpos=0.3206;...
                        elseif colnow==2.5;colnowpos=0.466;else colnowpos=0.6202;end
                        %disp(rownowpos);disp(colnowpos);
                        set(gca,'Position',[colnowpos 1-rownowpos 0.2796 0.313]);
                    end
                else
                    highqualityfiguresetup;
                    close;
                end
            end
            if makefinal==1
                %Make one large colorbar for all subplots
                cbar=colorbar;
                set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
                set(cbar,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
                cpos=get(cbar,'Position');cpos(1)=0.925;cpos(2)=0.05;cpos(3)=0.017;cpos(4)=0.9;
                set(cbar,'Position',cpos);
                highqualityfiguresetup;
            end
        end
    end
end

%Creates final figures with SST (stipped for significance) underlaying z500 anomalies without stippling,
    %following McKinnon et al. 2016 figure 3
%Uses the revised stippling approach (altapproach=2 in the NCEP loop)
%Actualfractionposanomaliessst is computed in helperscript because it's so time-consuming
if plotz500sstfiguresdaily==1
    if loadarraysagain==1
        %Load SST-related data
        avgofanomsactualdatasst=load(strcat(curArrayDir,'dailysstarrays'),'avgofanomsoisst');
        avgofanomsactualdatasst=avgofanomsactualdatasst.avgofanomsoisst;
        %for reg=1:8;avgofanomsactualdatasst{2,reg,3}=avgofanomsactualdatasst{2,reg,5};end
        oisstlats=load(strcat(curArrayDir,'dailysstarrays'),'oisstlats');oisstlats=oisstlats.oisstlats;
        oisstlons=load(strcat(curArrayDir,'dailysstarrays'),'oisstlons');oisstlons=oisstlons.oisstlons;
        surrogate2point5pctposanomsst=load(strcat(curArrayDir,'dailysstarrays'),'surrogate2point5pctposanomsst');
        surrogate2point5pctposanomsst=surrogate2point5pctposanomsst.surrogate2point5pctposanomsst;
        surrogate5pctposanomsst=load(strcat(curArrayDir,'dailysstarrays'),'surrogate5pctposanomsst');
        surrogate5pctposanomsst=surrogate5pctposanomsst.surrogate5pctposanomsst;
        surrogate95pctposanomsst=load(strcat(curArrayDir,'dailysstarrays'),'surrogate95pctposanomsst');
        surrogate95pctposanomsst=surrogate95pctposanomsst.surrogate95pctposanomsst;
        surrogate97point5pctposanomsst=load(strcat(curArrayDir,'dailysstarrays'),'surrogate97point5pctposanomsst');
        surrogate97point5pctposanomsst=surrogate97point5pctposanomsst.surrogate97point5pctposanomsst;
        actualfractionposanomaliessst=load(strcat(curArrayDir,'dailysstarrays'),'actualfractionposanomaliessst');
        actualfractionposanomaliessst=actualfractionposanomaliessst.actualfractionposanomaliessst;
        surrogatefractionposanomaliessst=load(strcat(curArrayDir,'dailysstarrays'),'surrogatefractionposanomaliessst');
        surrogatefractionposanomaliessst=surrogatefractionposanomaliessst.surrogatefractionposanomaliessst;

        %Load z500-related data
        avgofanomsactualdataz500=load(strcat(curArrayDir,'griddedavgsarrays'),'avgofanomsactualdata');
        avgofanomsactualdataz500=avgofanomsactualdataz500.avgofanomsactualdata;
    end
    
    %Do the plotting
    for var=variwf:variwl
        disp('line 4208');disp(numrowstomake);
        if var==1;varname='T';elseif var==2;varname='WBT';end
        for region=regiwf:regiwl
            %Set up arrays
            underlaydata={oisstlats;oisstlons;avgofanomsactualdatasst{var,region,ndbcateg}};
            overlaydata={nceplats;nceplons;squeeze(avgofanomsactualdataz500{var,region,ndbcateg})};
            data=overlaydata;data{3}=double(squeeze(data{3}));
            
            %Define stippling matrix for significance of SST anomalies -- 1 if significant, 0 if not
            if needtodefinestipplematrix==1
                for i=1:1440
                    for j=1:720
                        if actualfractionposanomalies{var,region,ndbcateg}(i,j)==0
                            stipplematrix95{var,region,ndbcateg}(i,j)=NaN;
                            stipplematrix90{var,region,ndbcateg}(i,j)=NaN;
                        else
                            if actualfractionposanomalies{var,region,ndbcateg}(i,j)>=surrogate97point5pctposanomsst{var,region,ndbcateg}(i,j) ||...
                                    actualfractionposanomalies{var,region,ndbcateg}(i,j)<=surrogate2point5pctposanomsst{var,region,ndbcateg}(i,j)
                                stipplematrix95{var,region,ndbcateg}(i,j)=1; %i.e. 95% confidence level
                            else
                                stipplematrix95{var,region,ndbcateg}(i,j)=0;
                            end
                            if actualfractionposanomalies{var,region,ndbcateg}(i,j)>=surrogate95pctposanomsst{var,region,ndbcateg}(i,j) ||...
                                    actualfractionposanomalies{var,region,ndbcateg}(i,j)<=surrogate5pctposanomsst{var,region,ndbcateg}(i,j)
                                stipplematrix90{var,region,ndbcateg}(i,j)=1; %i.e. 90% confidence level
                            else
                                stipplematrix90{var,region,ndbcateg}(i,j)=0;
                            end
                        end
                    end
                end
            end
            
            cmin=-100;cmax=100;underlaycmin=-1;underlaycmax=1;
            if numdaysbefore==0
                mystep=20;if region~=6;mystepunderlay=0.27;else mystepunderlay=0.26;end
            else
                mystep=20;if region~=6;mystepunderlay=0.27;else mystepunderlay=0.26;end
            end
            %Set other arguments
            titledescrip='500-hPa Geopotential Height';
            regionformap='nhplustropics';datatype='NCEP';
            if region==regiwf;figure(figc);clf;figc=figc+1;end
            hold on;
            axissz=8;labelsz=10;titlesz=12;
            if numrowstomake==3 && numcolstomake==3
                if region==8;subplot(3,3,region);hold on;else subplot(3,3,region-1);end
            elseif numrowstomake==4 && numcolstomake==2
                subplot(4,2,8);
            elseif numrowstomake==7 && numcolstomake==1
                subplot(7,1,region-1);
            end
            
            %Plot SST, underlaid
            vararginnew={'variable';'temperature';'contour';1;'mystepunderlay';mystepunderlay;'plotCountries';1;...
                'underlaycaxismin';underlaycmin;'underlaycaxismax';underlaycmax;...
                'datatounderlay';underlaydata;'underlayvariable';...
                'temperature';'overlaynow';0;'anomavg';'avg';'centeredon';180;'addtext';'dontaddtext';...
                'countryboundaries';0;'stateboundaries';0};
            vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=1;
            plotModelData(underlaydata,regionformap,vararginnew,datatype);
            clear fullshadingdescr;clear fullcontoursdescr;
            %figure(100);imagescnan(underlaydata{3});colorbar;
            
            %Add hatching/stippling if and where gridpts' SST anomalies are significantly different from zero
            if ndbcateg<=3
                for i=1:size(stipplematrix95{var,region,ndbcateg},1)
                    for j=1:size(stipplematrix95{var,region,ndbcateg},2)
                        if rem(i,6)==0 && rem(j,6)==0 %if all points are plotted, you can't see the contoured stuff below...
                            if stipplematrix95{var,region,ndbcateg}(i,j)==1
                                thislat=oisstlats(i,j);thislon=oisstlons(i,j);
                                geoshow(thislat,thislon,'displaytype','point','marker','o','markerfacecolor','k',...
                                    'markeredgecolor','k','markersize',1.25);
                            end
                        end
                    end
                end
            end
            
            %Plot z500, overlaid
            vararginnew={'variable';'height';'contour';1;'mystep';mystep;'plotCountries';1;...
                'caxismin';cmin;'caxismax';cmax;...
                'datatooverlay';overlaydata;'overlaynow';1;...
                'overlayvariable';'height';'anomavg';'avg';'centeredon';180;...
                'addtext';'dontaddtext';'contourlabels';0;'countryboundaries';0;'stateboundaries';0;...
                'omitzerocontour';1};
            vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=1;
            %Actually do the plotting
            plotModelData(overlaydata,regionformap,vararginnew,datatype);
            clear fullshadingdescr;clear fullcontoursdescr;

            

            %Add title, colorbar, etc.
            if region==1;theornot='';else theornot='the ';end
            titlepart1=sprintf('Composited Daily Anomalies of %s',titledescrip);
            if numdaysbefore==0
                titlepart2=sprintf('for %d Extreme %s Days in %s%s',numdates,varname,theornot,ncaregionnamemaster{region});
            else
                titlepart2=sprintf('%d Days Before %d Extreme %s Days in %s%s',...
                    numdaysbefore,numdates,varname,theornot,ncaregionnamemaster{region});
            end
            maxcbval=max(abs(underlaycmin),abs(underlaycmax));
            caxisRange=[-1*maxcbval maxcbval];caxis(caxisRange);
            colorbarlabel='SST Anomaly (C)';
            colormap(colormaps('sst','more','pale'));
            
            %Add continents below
            land = shaperead('landareas', 'UseGeoCoords', true);
            ax=gca;geoshow(ax,land,'facecolor',colors('ghost white'));

            %title is just letters identifying the subplots, plus region names
            if numrowstomake<=4
                t=title(sprintf(figletterlabels{region-1}),'fontname','arial','fontweight','bold','fontsize',titlesz);
                set(t,'horizontalalignment','left');set(t,'units','normalized');
                h1=get(t,'position');set(t,'position',[0 h1(2)-0.1 h1(3)]);
                if region==4 || region==5;horizpos=0.3;else horizpos=0.4;end
                text(horizpos,1.12,ncaregionnamemaster{region},'units','normalized','fontname','arial',...
                    'fontweight','bold','fontsize',14);
            else
                h=text(0.01,1,sprintf(figletterlabels{region-1}),'fontname','arial','fontweight','bold',...
                    'fontsize',14,'units','normalized');
                horizpos=-0.1;
                if region==4 || region==5
                    h1=text(horizpos-0.05,0,ncaregionnamemaster{region}(1:12),'units','normalized','fontname','arial',...
                        'fontweight','bold','fontsize',16);
                    h2=text(horizpos,0.2,ncaregionnamemaster{region}(13:18),'units','normalized','fontname','arial',...
                        'fontweight','bold','fontsize',16);
                    set(h1,'rotation',90);set(h2,'rotation',90);
                else
                    h1=text(horizpos,0.2,ncaregionnamemaster{region},'units','normalized','fontname','arial',...
                        'fontweight','bold','fontsize',16);
                    set(h1,'rotation',90);
                end
            end

            curpart=2;figloc=figDir;
            wordadd='';
            if numdaysbefore==0
                figname=strcat('compmap',wordadd,'anomgh500var',num2str(varname),'final');
            else
                figname=strcat('compmap',wordadd,'anomgh500var',num2str(varname),'ndb',num2str(numdaysbefore),'final');
            end
            exist windbarbsdescr;
            if ans==0;inclrefvectext=0;else inclrefvectext=1;end %info to be passed to highqualityfiguresetup
            %Set exact position of each subplot within figure
            if numrowstomake==4 && numcolstomake==2
                rownow=rem((region-1),numrowstomake);if rownow==0;rownow=numrowstomake;end
                if region-1<=numrowstomake;colnow=1;else colnow=2;end
                disp('Rownow is:');disp(rownow);disp('Colnow is:');disp(colnow);
                if rownow==1;rownowpos=0.24;elseif rownow==2;rownowpos=0.49;elseif rownow==3;rownowpos=0.74;else rownowpos=0.99;end
                if colnow==1;colnowpos=0.075;elseif colnow==2;colnowpos=0.075+0.5;end
                if colnow==2;rownowpos=rownowpos+0.125;end
                %disp(rownowpos);disp(colnowpos);if region==8;break;end
                set(gca,'Position',[colnowpos-0.02 1-rownowpos 0.35 0.24]);
            elseif numrowstomake==3 && numcolstomake==3
                rownow=round2((region-1)/numrowstomake,1,'ceil');
                colnow=rem(region-1,numcolstomake);if colnow==0;colnow=numcolstomake;end
                if rownow==1;rownowpos=0.323;elseif rownow==2;rownowpos=0.657;else rownowpos=0.99;end
                if colnow==1;colnowpos=0.02;elseif colnow==1.5;colnowpos=0.1668;elseif colnow==2;colnowpos=0.3206;...
                elseif colnow==2.5;colnowpos=0.466;else colnowpos=0.6202;end
                %disp(rownowpos);disp(colnowpos);
                set(gca,'Position',[colnowpos 1-rownowpos 0.2796 0.313]);
                if region==8;set(gca,'Position',[0.3325 1-rownowpos 0.2796 0.313]);end
            elseif numrowstomake==7 && numcolstomake==1
                rownow=region-1;
                colnow=1;
                if rownow==1;rownowpos=0.15;elseif rownow==2;rownowpos=0.28;elseif rownow==3;rownowpos=0.41;...
                elseif rownow==4;rownowpos=0.54;elseif rownow==5;rownowpos=0.67;elseif rownow==6;rownowpos=0.8;...
                else rownowpos=0.93;end
                if colnow==1;colnowpos=0.1;end
                disp(rownowpos);disp(colnowpos);
                %set(gca,'Position',[colnowpos 1-rownowpos 0.14 0.155]);
                set(gca,'Position',[colnowpos 1-rownowpos 0.92 0.12]);
            end
            %disp(region);

            %Make one large colorbar for all subplots
            if numrowstomake<=4
                cbar=colorbar;
                set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
                set(cbar,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
                cpos=get(cbar,'Position');cpos(1)=0.925;cpos(2)=0.05;cpos(3)=0.017;cpos(4)=0.9;
                set(cbar,'Position',cpos);
                width=7;height=11.5;
                highqualityfiguresetup;
            end
        end
        width=7;height=11.5;curpart=2;highqualityfiguresetup;
        if numrowstomake>=7
            width=7;height=11.5;curpart=1;highqualityfiguresetup;
            cbar=colorbar;
            set(cbar,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
            cpos=get(cbar,'Position');cpos(1)=0.21;cpos(2)=0.03;cpos(3)=0.7;cpos(4)=0.03;
            set(cbar,'Location','southoutside','Position',cpos);
            %set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
            %text(0.3,0.05,colorbarlabel,'FontSize',titlesz,'FontWeight','bold','FontName','Arial','units','normalized');
            width=7;height=11.5;curpart=2;highqualityfiguresetup;
        end
    end
end

%OLD VERSION:
%Composite of daily (aggregated 3-hourly values) water-vapor flux convergence over US regions on extreme T and WBT days
%Uses the NARR product specially tailored to this application (wvconv)
%NEW VERSION:
%Composite of daily horizontal moisture convergence at hybrid level 1 over US regions on extreme T and WBT days
%Uses the NARR product specially tailored to this application (mconv.hl1)
if plotwvfluxconv==1
    %Load in data
    if needtoloadandprocessdata==1
        for var=2:2
            for region=1:8
                datatopXXdays{var,region}=zeros(277,349,100);datatopXXdaysanom{var,region}=zeros(277,349,100);
                datatopXXdaysstananom{var,region}=zeros(277,349,100);daysfoundc{var,region}=1;
            end
        end
        %Compute monthly climatologies
        if needtocomputemonthlyclimo==1
            for i=1:6;wvormconvclimo{i}=zeros(277,349);end
            for year=yeariwf:yeariwl
                fprintf('Computing monthly wv climatologies for year %d\n',year);
                if newversion==1
                    datafile=ncread(strcat(narrhmdDir,'mconv.hl1.',num2str(year),'.nc'),'mconv');
                else
                    datafile=ncread(strcat(narrncDir,'wvconv.',num2str(year),'.nc'),'wvconv');
                end
                temp=abs(datafile)>10^4;datafile(temp)=NaN;
                datafile=permute(datafile,[2 1 3]); %so its dims are 277x349x2920

                %Add chunks of this year's data to the various monthly climos, as appropriate
                %Save mean & st dev for each month of each year, and then use a convenient formula to combine them all together
                %into the st dev at each gridpt for each month for the whole time series
                if newversion==1
                    maydatadays=datafile(:,:,121:151);
                    jundatadays=datafile(:,:,152:181);
                    juldatadays=datafile(:,:,182:212);
                    augdatadays=datafile(:,:,213:243);
                    sepdatadays=datafile(:,:,244:273);
                    octdatadays=datafile(:,:,274:304);
                else
                    maydata=datafile(:,:,121*8-7:151*8);
                    jundata=datafile(:,:,152*8-7:181*8);
                    juldata=datafile(:,:,182*8-7:212*8);
                    augdata=datafile(:,:,213*8-7:243*8);
                    sepdata=datafile(:,:,244*8-7:273*8);
                    octdata=datafile(:,:,274*8-7:304*8);
                    for day=1:31;maydatadays(:,:,day)=nanmean(maydata(:,:,day*8-7:day*8),3);end
                    for day=1:30;jundatadays(:,:,day)=nanmean(jundata(:,:,day*8-7:day*8),3);end
                    for day=1:31;juldatadays(:,:,day)=nanmean(juldata(:,:,day*8-7:day*8),3);end
                    for day=1:31;augdatadays(:,:,day)=nanmean(augdata(:,:,day*8-7:day*8),3);end
                    for day=1:30;sepdatadays(:,:,day)=nanmean(sepdata(:,:,day*8-7:day*8),3);end
                    for day=1:31;octdatadays(:,:,day)=nanmean(octdata(:,:,day*8-7:day*8),3);end
                end
                %For May
                wvormconvstdmonths{1}(:,:,year-yeariwf+1)=nanstd(maydatadays,0,3);
                wvormconvmeanmonths{1}(:,:,year-yeariwf+1)=nanmean(maydatadays,3);
                wvormconvclimo{1}=wvormconvclimo{1}+nanmean(maydatadays,3);
                %For June
                wvormconvstdmonths{2}(:,:,year-yeariwf+1)=nanstd(jundatadays,0,3);
                wvormconvmeanmonths{2}(:,:,year-yeariwf+1)=nanmean(jundatadays,3);
                wvormconvclimo{2}=wvormconvclimo{2}+nanmean(jundatadays,3);
                %For July
                wvormconvstdmonths{3}(:,:,year-yeariwf+1)=nanstd(juldatadays,0,3);
                wvormconvmeanmonths{3}(:,:,year-yeariwf+1)=nanmean(juldatadays,3);
                wvormconvclimo{3}=wvormconvclimo{3}+nanmean(juldatadays,3);
                %For August
                wvormconvstdmonths{4}(:,:,year-yeariwf+1)=nanstd(augdatadays,0,3);
                wvormconvmeanmonths{4}(:,:,year-yeariwf+1)=nanmean(augdatadays,3);
                wvormconvclimo{4}=wvormconvclimo{4}+nanmean(augdatadays,3);
                %For September
                wvormconvstdmonths{5}(:,:,year-yeariwf+1)=nanstd(sepdatadays,0,3);
                wvormconvmeanmonths{5}(:,:,year-yeariwf+1)=nanmean(sepdatadays,3);
                wvormconvclimo{5}=wvormconvclimo{5}+nanmean(sepdatadays,3);
                %For October
                wvormconvstdmonths{6}(:,:,year-yeariwf+1)=nanstd(octdatadays,0,3);
                wvormconvmeanmonths{6}(:,:,year-yeariwf+1)=nanmean(octdatadays,3);
                wvormconvclimo{6}=wvormconvclimo{6}+nanmean(octdatadays,3);

                if newversion==1 %if doing oldversion, stan anoms will be calculated using the partial but sufficient method elaborated just above
                    mconvall{1}(:,:,year-yeariwf+1)=nanmean(datafile(:,:,121*8:151*8-1),3);
                    mconvall{2}(:,:,year-yeariwf+1)=nanmean(datafile(:,:,152*8:181*8-1),3);
                    mconvall{3}(:,:,year-yeariwf+1)=nanmean(datafile(:,:,182*8:212*8-1),3);
                    mconvall{4}(:,:,year-yeariwf+1)=nanmean(datafile(:,:,213*8:243*8-1),3);
                    mconvall{5}(:,:,year-yeariwf+1)=nanmean(datafile(:,:,244*8:273*8-1),3);
                    mconvall{6}(:,:,year-yeariwf+1)=nanmean(datafile(:,:,274*8:304*8-1),3);
                end
                fclose('all');
            end
            for i=1:6;wvormconvclimo{i}=wvormconvclimo{i}./(yeariwl-yeariwf+1);end
            %Use saved means & st devs for each month & year to calculate month-specific 3-hourly st devs for the whole time series
            %Formula is the one extending to k groups at http://stats.stackexchange.com/questions/55999/is-it-possible-to-find-the-combined-standard-deviation
            %n is number of points in each subset, s is each subset's st dev, and y is each subset's mean
            for mon=1:6
                if mon==1;d1=121;d2=151;elseif mon==2;d1=152;d2=181;elseif mon==3;d1=182;d2=212;
                elseif mon==4;d1=213;d2=243;elseif mon==5;d1=244;d2=273;else d1=274;d2=304;end
                termsum=zeros(277,349);overally=zeros(277,349);
                for year=1:yeariwl-yeariwf+1;overally=overally+wvormconvmeanmonths{mon}(:,:,year);end
                overally=overally./(yeariwl-yeariwf+1);
                for year=1:yeariwl-yeariwf+1
                    nthisyear=(d2-d1).*ones(277,349);sthisyear{year}=wvormconvstdmonths{mon}(:,:,year);ythisyear=wvormconvmeanmonths{mon}(:,:,year);
                    tempnewpart(1:277,1:349,:)=((nthisyear-1).*sthisyear{year}.^2)+(nthisyear.*(ythisyear-overally).^2);
                    tempprev(1:277,1:349,:)=termsum;
                    temp2=cat(3,tempprev,tempnewpart);
                    termsum=nansum(temp2,3);
                end
                wvconvstdev{mon}=sqrt(termsum./((d2-d1)*(yeariwl-yeariwf)));
            end
            
            if newversion==1
                for i=1:6;mconvclimo{i}=wvormconvclimo{i};end;save(strcat(curArrayDir,'compositemapsarrays'),'mconvclimo','mconvall','-append');
            else
                for i=1:6;wvconvclimo{i}=wvormconvclimo{i};end;save(strcat(curArrayDir,'compositemapsarrays'),'wvconvclimo','wvconvstdev','-append');
            end
        end
        
        %Now, compute averages (absolute and anomalies) for top-XX days
        if computetopXX==1
            %Preliminarily, set up arrays
            clear datatopXXdays;clear datatopXXdaysanom;clear datatopXXdaysstananom;
            for var=2:2
                for region=2:8
                    wvconvdatatopXXdaysavg{var,region}=NaN.*ones(277,349,26);
                    wvconvdatatopXXdaysanommean{var,region}=NaN.*ones(277,349,26);
                    wvconvdatatopXXdaysstananommean{var,region}=NaN.*ones(277,349,26);
                    wvconvdatatopXXdaysanommedian{var,region}=NaN.*ones(277,349,26);
                    wvconvdatatopXXdaysstananommedian{var,region}=NaN.*ones(277,349,26);
                    datatopXXdays{var,region}=NaN.*ones(277,349,26,100);
                    datatopXXdaysanom{var,region}=NaN.*ones(277,349,26,100);
                    datatopXXdaysstananom{var,region}=NaN.*ones(277,349,26,100);
                end
            end
            %Load in climo data
            if newversion==1
                wvormconvclimo=compmapsfile.mconvclimo;
            else
                wvormconvclimo=compmapsfile.wvconvclimo;wvconvstdev=compmapsfile.wvconvstdev;
            end
            %Compute top-XX averages
            for year=yeariwf:yeariwl
                fprintf('Loading in wvconv data for year %d\n',year);
                relyear=year-yeariwf+1;
                datafile=ncread(strcat(narrncDir,'wvconv.',num2str(year),'.nc'),'wvconv');
                temp=abs(datafile)>10^4;datafile(temp)=NaN;
                datafile=permute(datafile,[2 1 3]);

                %For each region, one at a time, get the data corresponding to the
                    %regional hot days contained within these year, and aggregate the 3-hourly fluxes into a daily sum on those days
                for var=2:2
                    if var==1
                        topXXbyregionsorted=topXXtbyregionsorted;
                    elseif var==2
                        topXXbyregionsorted=topXXwbtbyregionsorted;
                    end
                    for region=2:8
                        fprintf('Computing top-XX-day averages; getting data for region %d\n',region);
                        reghotdaylist=topXXbyregionsorted{region}(1:100,:);
                        reghotdaylistsorted=sortrows(sortrows(sortrows(reghotdaylist,3),2),1);
                        
                        %This loop is useful for getting the fluxes for all extreme days in the current year
                            %(and thus speeding the computation along)
                        for i=1:100
                            if i<=100;thisyear=reghotdaylistsorted(i,1);end;if thisyear>year;break;end
                            if thisyear==year %found a top-XX day
                                %Now, run through the days surrounding it
                                for k=1:size(ndbset,1)
                                    numdaysbefore=ndbset(k);
                                    thismon=reghotdaylistsorted(i,2);
                                    thisday=reghotdaylistsorted(i,3);
                                    thisdoy=DatetoDOY(thismon,thisday,thisyear)-numdaysbefore;
                                    %This day preliminarily passes -- but considering that it's numdays before its
                                        %associated extreme, is there another extreme in between? If so, it shouldn't be used
                                    correspwbtextremedoy=DatetoDOY(reghotdaylistsorted(i,2),reghotdaylistsorted(i,3),reghotdaylistsorted(i,1));
                                    correspwbtextremeyear=reghotdaylistsorted(i,1);
                                    whethertocontinue=1;
                                    if i~=1
                                        prevwbtextremedoy=DatetoDOY(reghotdaylistsorted(i-1,2),reghotdaylistsorted(i-1,3),reghotdaylistsorted(i-1,1));
                                        prevwbtextremeyear=reghotdaylistsorted(i-1,1);
                                        if prevwbtextremeyear==correspwbtextremeyear && prevwbtextremedoy>=thisdoy %the previous extreme does fall in between
                                            whethertocontinue=0;
                                            %fprintf('Not continuing because year=%d, prevwbtextremedoy=%d, and thisdoy=%d (for region=%d, i=%d)\n',...
                                            %    correspwbtextremeyear,prevwbtextremedoy,thisdoy,region,i);
                                        end
                                    end

                                    if whethertocontinue==1
                                        %Get data array for this day
                                        %Arrays are arranged such that numdaysbefore=20 is in column 1,
                                        %    extreme day is in column 21, and daysprior=5 is in column 26
                                        fprintf('Getting data array for the extreme on %d, %d, %d, with ndb=%d and i=%d\n',...
                                            thisyear,thismon,thisday,numdaysbefore,i);
                                        datatopXXdays{var,region}(:,:,21-numdaysbefore,i)=nanmean(datafile(:,:,thisdoy*8:thisdoy*8+7),3);
                                        datatopXXdaysanom{var,region}(:,:,21-numdaysbefore,i)=...
                                            nanmean(datafile(:,:,thisdoy*8:thisdoy*8+7),3)-(wvormconvclimo{thismon-monthiwf+1});
                                        datatopXXdaysstananom{var,region}(:,:,21-numdaysbefore,i)=...
                                            datatopXXdaysanom{var,region}(:,:,21-numdaysbefore,i)./wvconvstdev{thismon-monthiwf+1};

                                        %a=datatopXXdays{var,region}(:,:,21-numdaysbefore,i);
                                        %b=datatopXXdaysanom{var,region}(:,:,21-numdaysbefore,i);
                                        %fprintf('Value and anomaly at 150,260 are %d, %d\n',a(150,260),b(150,260));
                                    end
                                end
                            end
                        end
                        %Arrays are arranged such that numdaysbefore=20 is in column 1, extreme day is in column 21, and daysprior=5 is in column 26
                        wvconvdatatopXXdaysavg{var,region}=nanmean(datatopXXdays{var,region},4); %mean over the regional 100 days
                        wvconvdatatopXXdaysanommean{var,region}=nanmean(datatopXXdaysanom{var,region},4); %mean of anomalies over the regional 100 days
                        wvconvdatatopXXdaysstananommean{var,region}=nanmean(datatopXXdaysstananom{var,region},4);
                        wvconvdatatopXXdaysanommedian{var,region}=nanmedian(datatopXXdaysanom{var,region},4); %median of anomalies over the regional 100 days
                        wvconvdatatopXXdaysstananommedian{var,region}=nanmedian(datatopXXdaysstananom{var,region},4); 
                            %median of standardized anomalies over the regional 100 days
                    end
                end
                clear datafile;  
                %wvconvdailydata{relyear}=datafile;
            end
        end
        %Save for posterity
        save(strcat(curArrayDir,'compositemapsarrays'),'wvconvdatatopXXdaysavg',...
            'wvconvdatatopXXdaysanommean','wvconvdatatopXXdaysstananommean',...
            'wvconvdatatopXXdaysanommedian','wvconvdatatopXXdaysstananommedian','-append');
    end
    
    %Now, do the actual mapping
    if domapping==1
        for var=2:2
            if var==1;varname='T';elseif var==2;varname='WBT';end
            for region=regiwf:regiwl
                %Compute average over the 3 days of ndb=3 to ndb=1 -- i.e. columns 18 to 20 of wvconvdatatopXXdaysanommedian
                wvconvdatatopXXdaysanommedianndb3ndb1=squeeze(nanmean(wvconvdatatopXXdaysanommedian{var,region}(:,:,18:20),3));
                cbmin=-1;cbmax=1;mystep=0.25;
                regionformap='usa';datatype='NARR';
                data={narrlats;narrlons;wvconvdatatopXXdaysanommedianndb3ndb1};overlaydata=data;
                vararginnew={'variable';'wv flux convergence';'underlayvariable';'wv flux convergence';...
                    'contour';1;'mystepunderlay';mystep;'plotCountries';1;...
                    'underlaycaxismin';cbmin;'underlaycaxismax';cbmax;'overlaynow';0;'anomavg';'avg';...
                    'omitfirstsubplotcolorbar';1};
                if makefinal==1 && region~=regiwf;vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=1;end
                if region==1;theornot='';else theornot='the ';end
                if makefinal==1;clear fullshadingdescr;clear fullcontoursdescr;end
                if makefinal==1
                    %if region==1;figure(figc);clf;figc=figc+1;end
                    hold on;curpart=1;width=10;highqualityfiguresetup;
                    axissz=8;labelsz=10;titlesz=12;
                    if numrowstomake==3 && numcolstomake==3
                        if region==8;subplot(3,3,region+1);else subplot(3,3,region);end
                    elseif numrowstomake==4 && numcolstomake==2
                        subplot(4,2,region-1);
                    end
                else
                    figure(figc);clf;figc=figc+1;
                    axissz=14;labelsz=18;titlesz=20;
                end

                plotModelData(data,regionformap,vararginnew,datatype);
                
                %Add title
                titlepart1=sprintf('Water-Vapor Flux Convergence');
                if numdaysbefore==0
                    titlepart2=sprintf('for Extreme %s Days in %s%s',varname,theornot,ncaregionnamemaster{region});
                else
                    titlepart2=sprintf('%d Days before Extreme %s Days in %s%s',numdaysbefore,varname,theornot,ncaregionnamemaster{region});
                end
                if makefinal==1 %title is just letters
                    t=title(sprintf(figletterlabels{region-1}),'fontname','arial','fontweight','bold','fontsize',titlesz);
                    set(t,'horizontalalignment','left');set(t,'units','normalized');
                    h1=get(t,'position');set(t,'position',[0 h1(2)-0.1 h1(3)-0.02]);
                else %otherwise, title is descriptive as defined above
                    title({titlepart1,titlepart2},'fontname','arial','fontweight','bold','fontsize',titlesz);
                end
                
                colorbarlabel='Anomaly (kg/m^-^2)';
                colormap(colormaps('q','more','not'));
                caxisrange=[cbmin cbmax];caxis(caxisrange);
                if makefinal==0;colorbarc=9;edamultipurposelegendcreator;end
                curpart=2;figloc=figDir;
                if makefinal==1
                    if numdaysbefore==0
                        figname=strcat('wvfluxconvvar',varlist{var},'final');
                    else
                        figname=strcat('wvfluxconvvar',varlist{var},'ndb',num2str(numdaysbefore),'final');
                    end
                else
                    if numdaysbefore==0
                        figname=strcat('wvfluxconvvar',varlist{var},'region',shortregnames{region});
                    else
                        figname=strcat('wvfluxconvvar',varlist{var},'region',shortregnames{region},'ndb',num2str(numdaysbefore));
                    end
                end
                
                exist windbarbsdescr;
                if ans==1
                    if strcmp(windbarbsdescr,'');inclrefvectext=0;else inclrefvectext=1;end %info to be passed to highqualityfiguresetup
                end
                
                if makefinal==1
                    rownow=round2(region/numcolstomake,1,'floor');
                    colnow=rem(region+1,numcolstomake);if colnow==0;colnow=numcolstomake;end
                    if numrowstomake==3;if region==7;colnow=1.5;elseif region==8;colnow=2.5;end;end %centered b/c only 2 elements in row of 3
                    if numrowstomake==4 && numcolstomake==2
                        if rownow==1;rownowpos=0.24;elseif rownow==2;rownowpos=0.48;elseif rownow==3;rownowpos=0.72;else rownowpos=0.96;end
                        if colnow==1;colnowpos=0.03;elseif colnow==2;colnowpos=0.41;end
                        if region==8;colnowpos=0.22;end
                        set(gca,'Position',[colnowpos 1-rownowpos 0.35 0.22]);
                    elseif numrowstomake==3 && numcolstomake==3
                        if rownow==1;rownowpos=0.323;elseif rownow==2;rownowpos=0.657;else rownowpos=0.99;end
                        if colnow==1;colnowpos=0.02;elseif colnow==1.5;colnowpos=0.1668;elseif colnow==2;colnowpos=0.3206;...
                        elseif colnow==2.5;colnowpos=0.466;else colnowpos=0.6202;end
                        %disp(rownowpos);disp(colnowpos);
                        set(gca,'Position',[colnowpos 1-rownowpos 0.2796 0.313]);
                    end
                else
                    highqualityfiguresetup;
                    close;
                end
                disp('line 4671');
            end
            if makefinal==1
                %Make one large colorbar for all subplots
                cbar=colorbar;
                set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
                set(cbar,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
                cpos=get(cbar,'Position');cpos(1)=0.79;cpos(2)=0.05;cpos(3)=0.017;cpos(4)=0.9;
                set(cbar,'Position',cpos);
                highqualityfiguresetup;
            end
        end
    end         
end

%Recall: there are 5520 days in all so top 100=top 1.8%
if plotwbtoftop100t==1
    stnstoplot=[19;45;98;125;191;194;195;206];
    regionalcolorstouse=varycolor(8);
    figure(figc);clf;figc=figc+1;
    for i=1:size(stnstoplot,1)
        wbtpcts=thisdayswbtpct{stnstoplot(i)};
        categc=zeros(20,1);
        for j=1:size(wbtpcts,2)
            if wbtpcts(j)>=95
                categc(1)=categc(1)+1;
            elseif wbtpcts(j)>=90
                categc(2)=categc(2)+1;
            elseif wbtpcts(j)>=85
                categc(3)=categc(3)+1;
            elseif wbtpcts(j)>=80
                categc(4)=categc(4)+1;
            elseif wbtpcts(j)>=75
                categc(5)=categc(5)+1;
            elseif wbtpcts(j)>=70
                categc(6)=categc(6)+1;
            elseif wbtpcts(j)>=65
                categc(7)=categc(7)+1;
            elseif wbtpcts(j)>=60
                categc(8)=categc(8)+1;
            elseif wbtpcts(j)>=55
                categc(9)=categc(9)+1;
            elseif wbtpcts(j)>=50
                categc(10)=categc(10)+1;
            elseif wbtpcts(j)>=45
                categc(11)=categc(11)+1;
            elseif wbtpcts(j)>=40
                categc(12)=categc(12)+1;
            elseif wbtpcts(j)>=35
                categc(13)=categc(13)+1;
            elseif wbtpcts(j)>=30
                categc(14)=categc(14)+1;
            elseif wbtpcts(j)>=25
                categc(15)=categc(15)+1;
            elseif wbtpcts(j)>=20
                categc(16)=categc(16)+1;
            elseif wbtpcts(j)>=15
                categc(17)=categc(17)+1;
            elseif wbtpcts(j)>=10
                categc(18)=categc(18)+1;
            elseif wbtpcts(j)>=5
                categc(19)=categc(19)+1;
            else
                categc(20)=categc(20)+1;
            end
        end
        finalc{i}=categc;
        plot(finalc{i},'color',regionalcolorstouse(i,:),'linewidth',2);hold on;
        stnnames{i}=newstnNameList{stnstoplot(i)};
    end
    set(gca,'fontsize',12,'fontweight','bold','fontname','arial');
    title('Percentiles of WBT for Top-100 T Days, for Selected Stations',...
        'fontname','arial','fontweight','bold','fontsize',18);
    ylabel('Percent of Total Observations in Bin','fontname','arial','fontweight','bold','fontsize',14);
    xlabel('Percentile Bin','fontname','arial','fontweight','bold','fontsize',14);
    legend(stnnames,'fontsize',16,'fontweight','bold');
    xlim([1 20]);
end


if plotnumqspikes==1
    plotBlankMap(figc,'usaminushawaii-tight');figc=figc+1;
    curpart=1;highqualityfiguresetup;
    breakvals=[4;2;1;0.5;0.25];
    for i=1:size(newstnNumList,1)
        if stnspikesc(i)>=breakvals(1)
            color='r';
        elseif stnspikesc(i)>=breakvals(2)
            color=colors('orange');
        elseif stnspikesc(i)>=breakvals(3)
            color=colors('green');
        elseif stnspikesc(i)>=breakvals(4)
            color=colors('sky blue');
        elseif stnspikesc(i)>=breakvals(5)
            color=colors('blue');
        else
            color=colors('purple');
        end
        h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
            'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
    end
    colorbarc=8;titlec=16;colorbarlabel='Average Yearly Count';
    edamultipurposelegendcreator;
    curpart=2;figloc=figDir;figname='mapnumqspikes';
    highqualityfiguresetup;
end


if plotspikescontribhighwbt==1
    for var=1:1
        if var==1
            stnspikespctcontribhighwbt=stntspikespctcontribhighwbt;titlename='T';breakvals=[20;10;7;4;1];
        else
            stnspikespctcontribhighwbt=stnqspikespctcontribhighwbt;titlename='q';breakvals=[50;40;30;20;10];
        end
        if makefinal==1
            figure(figc);
            subplot(1,2,var);plotBlankMap(figc,'usa');
            if var==1;curpart=1;highqualityfiguresetup;end
        else
            plotBlankMap(figc,'usa');figc=figc+1;curpart=1;highqualityfiguresetup;
        end
        for i=1:size(newstnNumList,1)
            if stnspikespctcontribhighwbt(i)>=breakvals(1)
                color='r';
            elseif stnspikespctcontribhighwbt(i)>=breakvals(2)
                color=colors('orange');
            elseif stnspikespctcontribhighwbt(i)>=breakvals(3)
                color=colors('green');
            elseif stnspikespctcontribhighwbt(i)>=breakvals(4)
                color=colors('sky blue');
            elseif stnspikespctcontribhighwbt(i)>=breakvals(5)
                color=colors('blue');
            elseif ~isnan(stnspikespctcontribhighwbt(i))
                color=colors('purple');
            elseif isnan(stnspikespctcontribhighwbt(i))
                color=colors('gray');
            end
            h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
                'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',7);hold on;
        end
        units='';colorbarc=8;if makefinal==1;clear titlec;else titlec=17;end
        edamultipurposelegendcreator;
        curpart=2;figloc=figDir;
        if makefinal==1
            figname='mapspikescontribhighwbtfinal';
        else
            if var==1;figname='maptspikescontribhighwbt';else figname='mapqspikescontribhighwbt';end
        end
        if makefinal==0;highqualityfiguresetup;end
    end
    if makefinal==1;highqualityfiguresetup;end
end


%Determine what percent of stations are missing/have invalid data for at least one full month,
%and therefore how feasible it would be to drop all of these in the intra-region variance analysis
if pctstnsinvalid1monthormore==1
    invalidtc=zeros(211,1);invalidwbtc=zeros(211,1);
    for i=1:211
        for year=1:30
            for relmonth=1:6
                if size(max(stndatat{i,year,relmonth}),1)==0
                    tmaxeseachmonth(i,year,relmonth)=0;
                else
                    tmaxeseachmonth(i,year,relmonth)=max(stndatat{i,year,relmonth});
                end
                if size(max(stndatawbt{i,year,relmonth}),1)==0
                    wbtmaxeseachmonth(i,year,relmonth)=0;
                else
                    wbtmaxeseachmonth(i,year,relmonth)=max(stndatawbt{i,year,relmonth});
                end
                
                %Count invalid or missing data for each station
                if tmaxeseachmonth(i,year,relmonth)==0 || tmaxeseachmonth(i,year,relmonth)>=50
                    invalidtc(i)=invalidtc(i)+1;
                end
                if wbtmaxeseachmonth(i,year,relmonth)==0 || wbtmaxeseachmonth(i,year,relmonth)>=40
                    invalidwbtc(i)=invalidwbtc(i)+1;
                end
            end
        end
    end
end

%Investigate hypothesis that the years for which NARR tends to overestimate the number of extreme-WBT days
%are the dry ones -- i.e. it overweights the influence of high T on extreme WBT, and discounts the influence of high q
if dryyearsbyregion==1
    %Read in PDSI dataset -- 2.5x2.5 global, so 144x55 because poles are not included
    ncdata=ncread(strcat(pdsiDir,'pdsi.mon.mean.selfcalibrated.nc'),'pdsi');
    %Limit to 01/1981 to 12/2014 (34 years=408 months)
    ncdata=ncdata(:,:,1573:1980);
    %Make invalid values (i.e. continents) NaN for ease of plotting
    temp=abs(ncdata)>20;ncdata(temp)=NaN;
    %Go through points and determine which (if any) NCA region they most appropriately belong to
    %Do this by first computing the lat/lon corresponding to each point
    for row=1:144
        for col=1:55
            pdsilons(row,col)=-(180-2.5*(row-1)-1.25);
            if col<=24
                pdsilats(row,col)=-(58.75-col*2.5+2.5);
            else
                pdsilats(row,col)=76.25-(55-col)*2.5;
            end
        end
    end
    %Now, get corresponding NCA regions for this matrix of points
    correspncaregions=ncaregionsfromlatlon(pdsilats,pdsilons);
    
    %Calculate the avg PDSI in each region for each month
    avgpdsi=zeros(34,12,8);year=0;
    for mon=1:408
        monofyear=rem(mon,12);if monofyear==0;monofyear=12;end
        if monofyear==1;year=year+1;end
        regnumptsc=zeros(8,1);
        for row=1:144
            for col=1:55
                if correspncaregions(row,col)~=0
                    ncareg=correspncaregions(row,col);
                    if ~isnan(ncdata(row,col,mon))
                        avgpdsi(year,monofyear,ncareg)=avgpdsi(year,monofyear,ncareg)+ncdata(row,col,mon);
                        regnumptsc(ncareg)=regnumptsc(ncareg)+1;
                    end
                end
            end
        end
        %Divide by number of points to get NCA-region averages
        for ncaregion=1:8
            avgpdsi(year,monofyear,ncaregion)=avgpdsi(year,monofyear,ncaregion)./regnumptsc(ncaregion);
        end
    end
end

if plotpredictabilityfromgh500==1
    %Plot georeferenced arrays
     if strcmp(wbtort,'wbt');wbtorttitle='WBT';else wbtorttitle='T';end
    regionformap='midlatband';datatype='NCEP';
    data={nceplats;nceplons;squeeze(georefarray(:,:,ncareg,lagcateg))};overlaydata=data;
    vararginnew={'variable';'generic scalar';'contour';1;'mystep';0.2;'plotCountries';1;...
        'caxismin';0;'caxismax';2;'overlaynow';0;'anomavg';'avg';'centeredon';180};
    [~,~,~,~,~,~,~,~,~]=plotModelData(data,regionformap,vararginnew,datatype);
    curpart=1;highqualityfiguresetup;
    colormap(colormaps('t','more','not'));
    text(0.33,1.05,sprintf('Positive gh500 Anomalies &'),'units','normalized',...
        'fontweight','bold','fontname','arial','fontsize',14);
    text(0.31,1,sprintf('%s Extreme-%s Events,',ncaregionnamemaster{ncareg},wbtorttitle),'units','normalized',...
        'fontweight','bold','fontname','arial','fontsize',14);
    text(0.39,0.95,sprintf('at Lags of %s Days',lagcategs{lagcateg}),'units','normalized',...
        'fontweight','bold','fontname','arial','fontsize',14);
    cblabel='Rate of Occurrence Relative to Normal';
    h=text(1.12,0.05,cblabel,'units','normalized','FontSize',14,'FontWeight','bold','FontName','Arial');
    set(h,'Rotation',90);
    curpart=2;figloc=figDir;figname=strcat('predgh500lag',lagcategs{lagcateg},...
        'region',shortregnames{ncareg},wbtort);
    highqualityfiguresetup;
end

if analyzehourofoccurrence==1
    %Try to figure out the spatial patterns of the hour of the day at which WBT maxima occur
    stnstoanalyze=[121;179;43;59]; %Omaha, JFK, San Diego, Memphis
    stntzs=[6;5;8;6];
    thisdayttrace=zeros(4,100,24);thisdayqtrace=zeros(4,100,24);
    thisdaywinddirtrace=zeros(4,100,24);thisdaywindspeedtrace=zeros(4,100,24);
    thisdayttraceanom=zeros(4,100,24);thisdayqtraceanom=zeros(4,100,24);
    ttracestnp25=zeros(4,24);qtracestnp25=zeros(4,24);winddirtracestnp25=zeros(4,24);windspeedtracestnp25=zeros(4,24);
    ttracestnmedian=zeros(4,24);qtracestnmedian=zeros(4,24);winddirtracestnmedian=zeros(4,24);windspeedtracestnmedian=zeros(4,24);
    ttracestnp75=zeros(4,24);qtracestnp75=zeros(4,24);winddirtracestnp75=zeros(4,24);windspeedtracestnp75=zeros(4,24);
    ttraceanomstnmedian=zeros(4,24);qtraceanomstnmedian=zeros(4,24);
    for stn=1:size(stnstoanalyze,1)
        thisstn=stnstoanalyze(stn);
        for i=1:100
            thisyear=topXXwbtbystn{thisstn}(i,2);thisyearrel=thisyear-yeariwf+1;
            thismonth=topXXwbtbystn{thisstn}(i,3);thismonthrel=thismonth-monthiwf+1;
            thisday=topXXwbtbystn{thisstn}(i,4); %hour listed is LST
            thisdoy=DatetoDOY(thismonth,thisday,thisyear);apr30doy=DatetoDOY(4,30,thisyear);
            
            %Get T, q, and wind traces for this day
            thisdayttrace(stn,i,:)=finaldatat{thisyearrel,thisstn}((thisdoy-apr30doy)*24-23+stntzs(stn):(thisdoy-apr30doy)*24+stntzs(stn));
            thisdayqtrace(stn,i,:)=finaldataq{thisyearrel,thisstn}((thisdoy-apr30doy)*24-23+stntzs(stn):(thisdoy-apr30doy)*24+stntzs(stn));
            if size(finaldatawinddir{thisyearrel,thisstn},1)==4416 && size(finaldatawindspeed{thisyearrel,thisstn},1)==4416
                thisdaywinddirtrace(stn,i,:)=...
                    finaldatawinddir{thisyearrel,thisstn}((thisdoy-apr30doy)*24-23+stntzs(stn):(thisdoy-apr30doy)*24+stntzs(stn));
                thisdaywindspeedtrace(stn,i,:)=...
                    finaldatawindspeed{thisyearrel,thisstn}((thisdoy-apr30doy)*24-23+stntzs(stn):(thisdoy-apr30doy)*24+stntzs(stn));
            else
                thisdaywinddirtrace(stn,i,:)=NaN.*ones(24,1);
                thisdaywindspeedtrace(stn,i,:)=NaN.*ones(24,1);
            end
            %For T and q, calculate anomalies
            thisdayttraceanom(stn,i,:)=squeeze(thisdayttrace(stn,i,:))-squeeze(avgthishourofdayandmonth{1}(thisstn,thismonthrel,:));
            thisdayqtraceanom(stn,i,:)=squeeze(thisdayqtrace(stn,i,:))-squeeze(avgthishourofdayandmonth{3}(thisstn,thismonthrel,:));
        end
        %Compute station 25th, median, and 75th percentiles
        ttracestnp25(stn,:)=squeeze(quantile(thisdayttrace(stn,:,:),0.25));
        qtracestnp25(stn,:)=squeeze(quantile(thisdayqtrace(stn,:,:),0.25));
        winddirtracestnp25(stn,:)=squeeze(quantile(thisdaywinddirtrace(stn,:,:),0.25));
        windspeedtracestnp25(stn,:)=squeeze(quantile(thisdaywindspeedtrace(stn,:,:),0.25));
        ttracestnmedian(stn,:)=squeeze(quantile(thisdayttrace(stn,:,:),0.5));
        qtracestnmedian(stn,:)=squeeze(quantile(thisdayqtrace(stn,:,:),0.5));
        winddirtracestnmedian(stn,:)=squeeze(quantile(thisdaywinddirtrace(stn,:,:),0.5));
        windspeedtracestnmedian(stn,:)=squeeze(quantile(thisdaywindspeedtrace(stn,:,:),0.5));
        ttracestnp75(stn,:)=squeeze(quantile(thisdayttrace(stn,:,:),0.75));
        qtracestnp75(stn,:)=squeeze(quantile(thisdayqtrace(stn,:,:),0.75));
        winddirtracestnp75(stn,:)=squeeze(quantile(thisdaywinddirtrace(stn,:,:),0.75));
        windspeedtracestnp75(stn,:)=squeeze(quantile(thisdaywindspeedtrace(stn,:,:),0.75));
        ttraceanomstnmedian(stn,:)=squeeze(quantile(thisdayttraceanom(stn,:,:),0.5));
        qtraceanomstnmedian(stn,:)=squeeze(quantile(thisdayqtraceanom(stn,:,:),0.5));
    end
    
    if plottq==1
        for i=1:4
            figure(figc);figc=figc+1;
            x=1:24;xrev=24:-1:1;
            y1=ttracestnp25(i,:);y2=fliplr(ttracestnp75(i,:));
            X=[x,xrev];Y=[y1,y2];
            fill(X,Y,'r','FaceAlpha',0.25);hold on;
            y1=qtracestnp25(i,:);y2=fliplr(qtracestnp75(i,:));
            X=[x,xrev];Y=[y1,y2];
            fill(X,Y,'b','FaceAlpha',0.25);
            xlim([1 24]);
            title(sprintf('T and q anomalies for stn %d',i));
        end
    end
    if plotwinddirspeed==1
        for i=1:4
            figure(figc);figc=figc+1;
            x=1:24;xrev=24:-1:1;
            y1=winddirtracestnp25(i,:);y2=fliplr(winddirtracestnp75(i,:));
            X=[x,xrev];Y=[y1,y2];
            xlim([1 24]);
            fill(X,Y,'r','FaceAlpha',0.25);
            title(sprintf('Wind dir for stn %d',i));
            figure(figc);figc=figc+1;
            y1=windspeedtracestnp25(i,:);y2=fliplr(windspeedtracestnp75(i,:));
            X=[x,xrev];Y=[y1,y2];
            fill(X,Y,'b','FaceAlpha',0.25);
            xlim([1 24]);
            title(sprintf('Wind speed for stn %d',i));
        end
    end
    if domultipanelnarrcomposites==1 %small-scale, for Omaha
        if computepart==1
            shumsum=zeros(277,349,8);uwndsum=zeros(277,349,8);vwndsum=zeros(277,349,8); %dims are x by y by 3-hourly interval of the day
            for i=1:100
                fprintf('i is %d\n',i);
                yr=topXXwbtbystn{121}(i,2);thisyearrel=yr-yeariwf+1;
                mn=topXXwbtbystn{121}(i,3);thismonthrel=mn-monthiwf+1;
                dy=topXXwbtbystn{121}(i,4);
                %Load NARR files for this month
                shumfile=load(strcat(narrDir,'shum/',num2str(yr),'/shum_',num2str(yr),'_0',num2str(mn),'_01.mat'));
                shumdata=eval(['shumfile.shum_' num2str(yr) '_0' num2str(mn) '_01;']);shumdata=shumdata{3};clear shumfile;fclose('all');
                uwndfile=load(strcat(narrDir,'uwnd/',num2str(yr),'/uwnd_',num2str(yr),'_0',num2str(mn),'_01.mat'));
                uwnddata=eval(['uwndfile.uwnd_' num2str(yr) '_0' num2str(mn) '_01;']);uwnddata=uwnddata{3};clear uwndfile;fclose('all');
                vwndfile=load(strcat(narrDir,'vwnd/',num2str(yr),'/vwnd_',num2str(yr),'_0',num2str(mn),'_01.mat'));
                vwnddata=eval(['vwndfile.vwnd_' num2str(yr) '_0' num2str(mn) '_01;']);vwnddata=vwnddata{3};clear vwndfile;fclose('all');

                %Retrieve data specifically for each hour on this day
                thisdoy=DatetoDOY(mn,dy,yr);
                for hourinterval=1:8
                    shumthishour=100.*(shumdata(:,:,2,dy*8-8+hourinterval));
                    uwndthishour=(uwnddata(:,:,2,dy*8-8+hourinterval));
                    vwndthishour=(vwnddata(:,:,2,dy*8-8+hourinterval));

                    shumanomthishour=shumthishour-shumclimo850{thisdoy};
                    uwndanomthishour=uwndthishour-uwndclimo850{thisdoy};
                    vwndanomthishour=vwndthishour-vwndclimo850{thisdoy};

                    shumsum(:,:,hourinterval)=shumsum(:,:,hourinterval)+shumanomthishour;
                    uwndsum(:,:,hourinterval)=uwndsum(:,:,hourinterval)+uwndanomthishour;
                    vwndsum(:,:,hourinterval)=vwndsum(:,:,hourinterval)+vwndanomthishour;
                end
            end
            %Divide to get average (of anomalies)
            shumavg=shumsum./100;uwndavg=uwndsum./100;vwndavg=vwndsum./100;
            save(strcat(curDir,'finalarrays'),'shumavg','uwndavg','vwndavg');
            disp(clock);
        end
        
        if plotpart==1
            figure(figc);localtimes={'1930 LST';'2230 LST';'0130 LST';'0430 LST';'0730 LST';'1030 LST';'1330 LST';'1630 LST'};
            ordertogoin=[3;4;5;6;7;8;1;2];
            for count=1:1 %each of the 3-hour intervals
                i=ordertogoin(count);
                underlaydata={narrlats;narrlons;squeeze(shumavg(:,:,i))};
                overlaydata={narrlats;narrlons;squeeze(uwndavg(:,:,i));squeeze(vwndavg(:,:,i))};data=overlaydata;
                vararginnew={'variable';'wind';'contour';1;'mystepunderlay';0.25;'plotCountries';1;...
                    'underlaycaxismin';0;'underlaycaxismax';2;'vectorData';overlaydata;'overlaynow';1;...
                    'overlayvariable';'wind';'datatooverlay';overlaydata;'underlayvariable';...
                    'specific humidity';'datatounderlay';underlaydata;'anomavg';'avg'};
                %if i~=1
                    if makefinal==1;vararginnew{size(vararginnew,1)+1}='nonewfig';vararginnew{size(vararginnew,1)+1}=1;end
                %end
                titledescrip='850-hPa specific humidity and 850-hPa wind';
                units=' (g/kg)';shadingdescrip='Specific-Humidity';
                regionformap='us-mw';datatype='NARR';
                subplot(2,4,count);
                if count<=4;thisrow=1;else thisrow=2;end
                if count<=4;thiscol=count;else thiscol=count-4;end
                cpos=[(thiscol-1)*0.35+(thiscol)*0.01 1-thisrow*0.23 0.35 0.2];set(gca,'Position',cpos,'units','normalized');
                %curpart=1;highqualityfiguresetup;
                plotModelData(data,regionformap,vararginnew,datatype);
                colormap(colormaps('q','more','not'));
                %if rem(i,2)==1;thisrow=round2(i/2,1,'ceil');else thisrow=i/2;end
                %if rem(i,2)==1;thiscol=1;else thiscol=2;end
                
                text((thiscol-1)*0.2375+(thiscol)*0.01-0.35,1-thisrow*0.21+0.18,figletterlabels{count},...
                    'fontsize',14,'fontweight','bold','fontname','arial');
                title(sprintf(localtimes{i}),'fontsize',14,'fontweight','bold','fontname','arial');
            end
            if makefinal==1
                %Make one large colorbar for all subplots
                cbar=colorbar;
                colorbarlabel='Specific-Humidity Anomaly (g/kg)';titlesz=16;
                %set(cbar,'YDir','reverse');
                set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
                set(cbar,'FontSize',titlesz,'FontWeight','bold','FontName','Arial');
                cbarpos=get(cbar,'Position');cbarpos(1)=0.9;cbarpos(2)=0.1;cbarpos(3)=0.017;cbarpos(4)=0.8;
                set(cbar,'Position',cbarpos);
                %Add reference vector
                xcoords=[0.813 0.828];ycoords=[0.15 0.15];annotation('textarrow',xcoords,ycoords,'headwidth',6,'headlength',6);
                text(0.62,-0.25,'5 m/s','fontname','arial','fontweight','bold','fontsize',14,'units','normalized');
            end
            curpart=2;figloc=figDir;figname='analyzehourofoccurrence';highqualityfiguresetup;
        end
    end
end


if readpdsidata==1
    pdsidata=csvread('pdsidata.csv');
    pdsidatabyregion={};
    regrowc=ones(8,1);
    %Read in PDSI data, sorting by NCA region
    for row=1:123:size(pdsidata,1)-122
        if pdsidata(row,1)==10 || pdsidata(row,1)==35 || pdsidata(row,1)==45
            region=2;
        elseif pdsidata(row,1)==2 || pdsidata(row,1)==4 || pdsidata(row,1)==5 || pdsidata(row,1)==26 ||...
                pdsidata(row,1)==29 || pdsidata(row,1)==42
            region=3;
        elseif pdsidata(row,1)==24 || pdsidata(row,1)==25 || pdsidata(row,1)==32 || pdsidata(row,1)==39 ||...
                pdsidata(row,1)==48
            region=4;
        elseif pdsidata(row,1)==14 || pdsidata(row,1)==34 || pdsidata(row,1)==41
            region=5;
        elseif pdsidata(row,1)==11 || pdsidata(row,1)==12 || pdsidata(row,1)==13 || pdsidata(row,1)==20 ||...
                pdsidata(row,1)==21 || pdsidata(row,1)==23 || pdsidata(row,1)==33 || pdsidata(row,1)==47
            region=6;
        elseif pdsidata(row,1)==1 || pdsidata(row,1)==3 || pdsidata(row,1)==8 || pdsidata(row,1)==9 ||...
                pdsidata(row,1)==15 || pdsidata(row,1)==16 || pdsidata(row,1)==22 || pdsidata(row,1)==31 ||...
                pdsidata(row,1)==38 || pdsidata(row,1)==40 || pdsidata(row,1)==44
            region=7;
        elseif pdsidata(row,1)==6 || pdsidata(row,1)==7 || pdsidata(row,1)==17 || pdsidata(row,1)==18 ||...
                pdsidata(row,1)==19 || pdsidata(row,1)==27 || pdsidata(row,1)==28 || pdsidata(row,1)==30 ||...
                pdsidata(row,1)==36 || pdsidata(row,1)==37 || pdsidata(row,1)==42 || pdsidata(row,1)==46
            region=8;
        end
        
        if min(min(pdsidata(row:row+121,4:15)))>=-20 %ensures only valid data is selected
            pdsidatabyregion{region}(regrowc(region):regrowc(region)+121,:)=pdsidata(row:row+121,4:15);
            regrowc(region)=regrowc(region)+122;
        end
    end
    
    %Get averages for each month & year, for each NCA region
    for region=2:8
        thisregionsum=zeros(122,12);
        for row=1:122:size(pdsidatabyregion{region},1)-120
            thisregionsum=thisregionsum+pdsidatabyregion{region}(row:row+121,:);
        end
        pdsiavgbyncaregion{region}=thisregionsum./(size(pdsidatabyregion{region},1)/122);
    end
    
    %Compute JJA-mean PDSI in each year, for each NCA region
    for region=2:8
        for year=1:122
            pdsijjabyncaregion(region,year)=mean(pdsiavgbyncaregion{region}(year,6:8));
        end
    end
    
    %Compute summer droughts and pluvials, based on <-2 as drought as >2 as pluvial
    for region=2:8
        for year=1:122
            if pdsijjabyncaregion(region,year)<-2
                droughtspluvials(region,year)=-1; %drought
            elseif pdsijjabyncaregion(region,year)>2
                droughtspluvials(region,year)=1; %pluvial
            else
                droughtspluvials(region,year)=0; %neutral
            end
        end
    end
end

%Difference between low-level winds on Jul 1 and Aug 15
if winddiff==1
    clear underlaydata;
    uwnddiff=uwndclimo850{227}-uwndclimo850{182};
    vwnddiff=vwndclimo850{227}-vwndclimo850{182};
    overlaydata={narrlats;narrlons;uwnddiff;vwnddiff};
    vararginnew={'variable';'wind';'contour';1;'mystep';0.25;'plotCountries';1;...
        'vectorData';overlaydata;'overlaynow';1;...
        'overlayvariable';'wind';'datatooverlay';overlaydata;'anomavg';'avg';...
        'centeredon';180;'addtext';'dontaddtext'};
    regionformap='usa';datatype='NARR';curpart=1;highqualityfiguresetup;
    plotModelData(data,regionformap,vararginnew,datatype);
    title('Difference in 850-hPa Wind Speed: Aug 15 vs Jul 1',...
        'fontname','arial','fontsize',18,'fontweight','bold');
    x=[0.75 0.767];y=[0.22 0.22];
    annotation('textarrow',x,y,'string','4 m/s','fontname','arial',...
        'fontsize',12,'fontweight','bold','headstyle','vback2','headwidth',6,'headlength',5);
    curpart=2;figloc=figDir;figname='winddiff';
    highqualityfiguresetup;
end


%Trace anoms for a single region (default=Midwest)
%First idea: graph of z500 anoms, averaged over the region, for 20 days
    %prior to the top-XX WBT days to 5 days after
if traceanomsforasingleregion==1
    if readinarrays==1
        %Read in necessary arrays
        datafile=load(strcat(curArrayDir,'compositemapsarrays'));
        for varc=1:varnum
            eval([char(vrs(varc)) 'topXXavganom' char(levels(varc)) 'all=datafile.'...
                char(vrs(varc)) 'topXXavganom' char(levels(varc)) 'all;']);
        end
    end

    %Set options
    anomavg='anom';
    var=2; %i.e. WBT
    region=6; %Midwest
    timeciwf=1;timeciwl=1;timec=1; %not splitting up WBT extremes by 10-day window or month of occurrence
    plotmonth=2; %again, not splitting up by time of occurrence
    tqset=1; %no separating out T-dom and q-dom WBT extremes
    tvsq=10; %same meaning as tqset
    ncaregions=ncaregionsfromlatlon(narrlats,narrlons);
    %%%%explhelper; %sets stuff up
    gh500arr=ghtopXXavganom500all;
    
    for ndbc=1:9 %corresponding to numdaysbefore of 0,2,5,10,20,1,-1,-2,-5
        thisarr{ndbc}=gh500arr{var,region,timec,ndbc};
        temp=ncaregions~=region;thisarr{ndbc}(temp)=NaN;
    end
    %Compute avg z500 anom for the MW, in actual chronological order
    meanz500anom(1)=nanmean(nanmean(thisarr{5}));meanz500anom(2)=nanmean(nanmean(thisarr{4}));
    meanz500anom(3)=nanmean(nanmean(thisarr{3}));meanz500anom(4)=nanmean(nanmean(thisarr{2}));
    meanz500anom(5)=nanmean(nanmean(thisarr{6}));meanz500anom(6)=nanmean(nanmean(thisarr{1}));
    
    %Now, make the line-plot figure
    figure(figc);figc=figc+1;clf;
    xvals=[-20;-10;-5;-2;-1;0];
    scatter(xvals,meanz500anom,'fill');
end

%Compare sensible, latent, ground, and upwelling & downwelling shortwave &
%longwave radiation to evaluate the relative importance of each of these
%(along with T and q advection) to WBT extremes
if sfcfluxanalysis==1
    addpath('/Volumes/ExternalDriveA/NARR_daily_data_raw');savepath;
    addpath('/Volumes/ExternalDriveA/NARR_3-hourly_data_raw');savepath;
    
    %Compute climatologies for each flux
    if computeclimo==1
        %Do in two parts so that Matlab isn't overwhelmed by the size of the arrays
        for thisyear=1981:2015
            uswrfdata=ncread(strcat('uswrf.sfc.',num2str(thisyear),'.nc'),'uswrf');uswrfdata=permute(uswrfdata,[2 1 3]);
                temp=abs(uswrfdata)>1000;uswrfdata(temp)=NaN;
            ulwrfdata=ncread(strcat('ulwrf.sfc.',num2str(thisyear),'.nc'),'ulwrf');ulwrfdata=permute(ulwrfdata,[2 1 3]);
                temp=abs(ulwrfdata)>1000;ulwrfdata(temp)=NaN;
            dswrfdata=ncread(strcat('dswrf.',num2str(thisyear),'.nc'),'dswrf');dswrfdata=permute(dswrfdata,[2 1 3]);
                temp=abs(dswrfdata)>1000;dswrfdata(temp)=NaN;
            dlwrfdata=ncread(strcat('dlwrf.',num2str(thisyear),'.nc'),'dlwrf');dlwrfdata=permute(dlwrfdata,[2 1 3]);
                temp=abs(dlwrfdata)>1000;dlwrfdata(temp)=NaN;
              
            alluswrfdata(thisyear-1980,:,:,1:365)=uswrfdata(:,:,1:365);
            allulwrfdata(thisyear-1980,:,:,1:365)=ulwrfdata(:,:,1:365);
            alldswrfdata(thisyear-1980,:,:,1:365)=dswrfdata(:,:,1:365);
            alldlwrfdata(thisyear-1980,:,:,1:365)=dlwrfdata(:,:,1:365);

            fprintf('Year for climo computation #1 is %d\n',thisyear);
        end
        uswrfclimo=squeeze(nanmean(alluswrfdata,1));
        ulwrfclimo=squeeze(nanmean(allulwrfdata,1));
        dswrfclimo=squeeze(nanmean(alldswrfdata,1));
        dlwrfclimo=squeeze(nanmean(alldlwrfdata,1));
        clear alluswrfdata;clear allulwrfdata;clear alldswrfdata;clear alldlwrfdata;
        
        save('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/fluxarrays.mat',...
                'uswrfclimo','ulwrfclimo','dswrfclimo','dlwrfclimo','-append');
        
        for thisyear=1981:2015
            gfluxdata=ncread(strcat('gflux.',num2str(thisyear),'.nc'),'gflux');gfluxdata=permute(gfluxdata,[2 1 3]);
                temp=abs(gfluxdata)>1000;gfluxdata(temp)=NaN;
            shtfldata=ncread(strcat('shtfl.',num2str(thisyear),'.nc'),'shtfl');shtfldata=permute(shtfldata,[2 1 3]);
                temp=abs(shtfldata)>1000;shtfldata(temp)=NaN;
            lhtfldata=ncread(strcat('lhtfl.',num2str(thisyear),'.nc'),'lhtfl');lhtfldata=permute(lhtfldata,[2 1 3]);
                temp=abs(lhtfldata)>1000;lhtfldata(temp)=NaN;
            for day=1:365
                shtfldailydata(:,:,day)=squeeze(nanmean(shtfldata(:,:,day*8-7:day*8),3));
                lhtfldailydata(:,:,day)=squeeze(nanmean(lhtfldata(:,:,day*8-7:day*8),3));
            end
            
            allgfluxdata(thisyear-1980,:,:,1:365)=gfluxdata(:,:,1:365);
            allshtfldata(thisyear-1980,:,:,1:365)=shtfldailydata(:,:,1:365);
            alllhtfldata(thisyear-1980,:,:,1:365)=lhtfldailydata(:,:,1:365);
            
            fprintf('Year for climo computation #2 is %d\n',thisyear);
        end
        gfluxclimo=squeeze(nanmean(allgfluxdata,1));
        shtflclimo=squeeze(nanmean(allshtfldata,1));
        lhtflclimo=squeeze(nanmean(alllhtfldata,1));
        clear allgfluxdata;clear allshtfldata;clear alllhtfldata;
        
        %save('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/fluxarrays.mat',...
        %        'gfluxclimo','shtflclimo','lhtflclimo','-append');
            
        dayvec=[1:365]';
        improveduswrfclimo=NaN.*ones(277,349,365);improvedulwrfclimo=NaN.*ones(277,349,365);
        improveddswrfclimo=NaN.*ones(277,349,365);improveddlwrfclimo=NaN.*ones(277,349,365);
        improvedgfluxclimo=NaN.*ones(277,349,365);improvedshtflclimo=NaN.*ones(277,349,365);
        improvedlhtflclimo=NaN.*ones(277,349,365);
        for i=1:277
            for j=1:349
                nansumuswrf=sum(isnan(squeeze(uswrfclimo(i,j,:))));
                if nansumuswrf<=50
                    thisfit=fit(dayvec,squeeze(uswrfclimo(i,j,:)),'fourier2');
                    improveduswrfclimo(i,j,:)=thisfit(dayvec);
                else
                    improveduswrfclimo(i,j,:)=NaN.*ones(365,1);
                end
                nansumulwrf=sum(isnan(squeeze(ulwrfclimo(i,j,:))));
                if nansumulwrf<=50
                    thisfit=fit(dayvec,squeeze(ulwrfclimo(i,j,:)),'fourier2');
                    improvedulwrfclimo(i,j,:)=thisfit(dayvec);
                else
                    improvedulwrfclimo(i,j,:)=NaN.*ones(365,1);
                end
                nansumdswrf=sum(isnan(squeeze(dswrfclimo(i,j,:))));
                if nansumdswrf<=50
                    thisfit=fit(dayvec,squeeze(dswrfclimo(i,j,:)),'fourier2');
                    improveddswrfclimo(i,j,:)=thisfit(dayvec);
                else
                    improveddswrfclimo(i,j,:)=NaN.*ones(365,1);
                end
                nansumdlwrf=sum(isnan(squeeze(dlwrfclimo(i,j,:))));
                if nansumdlwrf<=50
                    thisfit=fit(dayvec,squeeze(dlwrfclimo(i,j,:)),'fourier2');
                    improveddlwrfclimo(i,j,:)=thisfit(dayvec);
                else
                    improveddlwrfclimo(i,j,:)=NaN.*ones(365,1);
                end
                nansumgflux=sum(isnan(squeeze(gfluxclimo(i,j,:))));
                if nansumgflux<=50
                    thisfit=fit(dayvec,squeeze(gfluxclimo(i,j,:)),'fourier2');
                    improvedgfluxclimo(i,j,:)=thisfit(dayvec);
                else
                    improvedgfluxclimo(i,j,:)=NaN.*ones(365,1);
                end
                nansumshtfl=sum(isnan(squeeze(shtflclimo(i,j,:))));
                if nansumshtfl<=50
                    thisfit=fit(dayvec,squeeze(shtflclimo(i,j,:)),'fourier2');
                    improvedshtflclimo(i,j,:)=thisfit(dayvec);
                else
                    improvedshtflclimo(i,j,:)=NaN.*ones(365,1);
                end
                nansumlhtfl=sum(isnan(squeeze(lhtflclimo(i,j,:))));
                if nansumlhtfl<=50
                    thisfit=fit(dayvec,squeeze(lhtflclimo(i,j,:)),'fourier2');
                    improvedlhtflclimo(i,j,:)=thisfit(dayvec);
                else
                    improvedlhtflclimo(i,j,:)=NaN.*ones(365,1);
                end
            end
            if rem(i,5)==0;fprintf('i=%d\n',i);end
        end
        save('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/fluxarrays.mat',...
                'improveduswrfclimo','improvedulwrfclimo','improveddswrfclimo','improveddlwrfclimo',...
                'improvedgfluxclimo','improvedshtflclimo','improvedlhtflclimo','-append');
    end
    
    daysbeforestarts=[20;9;4;1;0;-1;-2];daysbeforestops=[10;5;2;1;0;-1;-4];
    if fluxestop100==1
        for region=3:3
            topXX=topXXwbtbyregionsorted{region}(1:100,:);
            topXX=sortrows(topXX,[1 2 3]);
            for i=1:100
                thisyear=topXX(i,1);
                if i~=1
                    if topXX(i,1)~=topXX(i-1,1) %i.e. only need to read in again if this year differs from the previous
                        uswrfdata=ncread(strcat('uswrf.sfc.',num2str(thisyear),'.nc'),'uswrf');uswrfdata=permute(uswrfdata,[2 1 3]);
                            temp=abs(uswrfdata)>1000;uswrfdata(temp)=NaN;
                        ulwrfdata=ncread(strcat('ulwrf.sfc.',num2str(thisyear),'.nc'),'ulwrf');ulwrfdata=permute(ulwrfdata,[2 1 3]);
                            temp=abs(ulwrfdata)>1000;ulwrfdata(temp)=NaN;
                        dswrfdata=ncread(strcat('dswrf.',num2str(thisyear),'.nc'),'dswrf');dswrfdata=permute(dswrfdata,[2 1 3]);
                            temp=abs(dswrfdata)>1000;dswrfdata(temp)=NaN;
                        dlwrfdata=ncread(strcat('dlwrf.',num2str(thisyear),'.nc'),'dlwrf');dlwrfdata=permute(dlwrfdata,[2 1 3]);
                            temp=abs(dlwrfdata)>1000;dlwrfdata(temp)=NaN;
                        gfluxdata=ncread(strcat('gflux.',num2str(thisyear),'.nc'),'gflux');gfluxdata=permute(gfluxdata,[2 1 3]);
                            temp=abs(gfluxdata)>1000;gfluxdata(temp)=NaN;
                        shtfldata=ncread(strcat('shtfl.',num2str(thisyear),'.nc'),'shtfl');shtfldata=permute(shtfldata,[2 1 3]);
                            temp=abs(shtfldata)>1000;shtfldata(temp)=NaN;
                        lhtfldata=ncread(strcat('lhtfl.',num2str(thisyear),'.nc'),'lhtfl');lhtfldata=permute(lhtfldata,[2 1 3]);
                            temp=abs(lhtfldata)>1000;lhtfldata(temp)=NaN;
                    end
                else
                    uswrfdata=ncread(strcat('uswrf.sfc.',num2str(thisyear),'.nc'),'uswrf');uswrfdata=permute(uswrfdata,[2 1 3]);
                        temp=abs(uswrfdata)>1000;uswrfdata(temp)=NaN;
                    ulwrfdata=ncread(strcat('ulwrf.sfc.',num2str(thisyear),'.nc'),'ulwrf');ulwrfdata=permute(ulwrfdata,[2 1 3]);
                        temp=abs(ulwrfdata)>1000;ulwrfdata(temp)=NaN;
                    dswrfdata=ncread(strcat('dswrf.',num2str(thisyear),'.nc'),'dswrf');dswrfdata=permute(dswrfdata,[2 1 3]);
                        temp=abs(dswrfdata)>1000;dswrfdata(temp)=NaN;
                    dlwrfdata=ncread(strcat('dlwrf.',num2str(thisyear),'.nc'),'dlwrf');dlwrfdata=permute(dlwrfdata,[2 1 3]);
                        temp=abs(dlwrfdata)>1000;dlwrfdata(temp)=NaN;
                    gfluxdata=ncread(strcat('gflux.',num2str(thisyear),'.nc'),'gflux');gfluxdata=permute(gfluxdata,[2 1 3]);
                        temp=abs(gfluxdata)>1000;gfluxdata(temp)=NaN;
                    shtfldata=ncread(strcat('shtfl.',num2str(thisyear),'.nc'),'shtfl');shtfldata=permute(shtfldata,[2 1 3]);
                        temp=abs(shtfldata)>1000;shtfldata(temp)=NaN;
                    lhtfldata=ncread(strcat('lhtfl.',num2str(thisyear),'.nc'),'lhtfl');lhtfldata=permute(lhtfldata,[2 1 3]);
                        temp=abs(lhtfldata)>1000;lhtfldata(temp)=NaN;
                end

                for dbi=1:7
                    %Ranges of days (c.f. computemwavgs loop of findmaxtwbt) are 20 to 10 before; 9 to 5 before; 4 to
                        %2 before; 1 before; day of; 1 after; 2 to 4 after
                    numdaysbeforestart=daysbeforestarts(dbi);numdaysbeforestop=daysbeforestops(dbi);
                    thisdoystart=DatetoDOY(topXX(i,2),topXX(i,3),topXX(i,1))-numdaysbeforestart; %first day of range
                    thisdoystop=DatetoDOY(topXX(i,2),topXX(i,3),topXX(i,1))-numdaysbeforestop; %last day of range
                    whethertocontinue=1;

                    %Check if there's a WBT-extreme day in between this day
                        %being evaluated and its corresponding WBT extreme -- if
                        %so, don't continue with the calculation
                    correspwbtextremedoy=DatetoDOY(topXX(i,2),topXX(i,3),topXX(i,1));
                    correspwbtextremeyear=topXX(i,1);
                    if i~=1
                        prevwbtextremedoy=DatetoDOY(topXX(i-1,2),topXX(i-1,3),topXX(i-1,1));
                        prevwbtextremeyear=topXX(i-1,1);
                        if prevwbtextremeyear==correspwbtextremeyear && prevwbtextremedoy>=thisdoystart %the previous extreme does fall in between
                            whethertocontinue=0;
                            %fprintf('Not continuing because year=%d, prevwbtextremedoy=%d, and thisdoy=%d (for region=%d, i=%d)\n',...
                            %    correspwbtextremeyear,prevwbtextremedoy,thisdoy,region,i);
                        end
                    end

                    if whethertocontinue==1
                        %Get data for this range of days specifically
                        uswrfdatathisday=squeeze(nanmean(uswrfdata(:,:,thisdoystart:thisdoystop),3));ulwrfdatathisday=squeeze(nanmean(ulwrfdata(:,:,thisdoystart:thisdoystop),3));
                        dswrfdatathisday=squeeze(nanmean(dswrfdata(:,:,thisdoystart:thisdoystop),3));dlwrfdatathisday=squeeze(nanmean(dlwrfdata(:,:,thisdoystart:thisdoystop),3));
                        gfluxdatathisday=squeeze(nanmean(gfluxdata(:,:,thisdoystart:thisdoystop),3));
                        shtfldatathisday=squeeze(nanmean(shtfldata(:,:,thisdoystart*8-7:thisdoystop*8),3));
                        lhtfldatathisday=squeeze(nanmean(lhtfldata(:,:,thisdoystart*8-7:thisdoystop*8),3));
                        
                        %Compute anomaly
                        uswrfanomthisday=uswrfdatathisday-squeeze(nanmean(improveduswrfclimo(:,:,thisdoystart:thisdoystop),3));
                        ulwrfanomthisday=ulwrfdatathisday-squeeze(nanmean(improvedulwrfclimo(:,:,thisdoy),3));
                        dswrfanomthisday=dswrfdatathisday-squeeze(nanmean(improveddswrfclimo(:,:,thisdoy),3));
                        dlwrfanomthisday=dlwrfdatathisday-squeeze(nanmean(improveddlwrfclimo(:,:,thisdoy),3));
                        gfluxanomthisday=gfluxdatathisday-squeeze(nanmean(improvedgfluxclimo(:,:,thisdoy),3));
                        shtflanomthisday=shtfldatathisday-squeeze(nanmean(improvedshtflclimo(:,:,thisdoy),3));
                        lhtflanomthisday=lhtfldatathisday-squeeze(nanmean(improvedlhtflclimo(:,:,thisdoy),3));

                        %Average fluxes (and flux anomalies) over this region
                        thisregion=ncaregionsfromlatlon(narrlats,narrlons)==region;
                        uswrfdaymasked=NaN.*ones(277,349);uswrfdaymasked(thisregion)=uswrfdatathisday(thisregion);uswrfavg(region,i,dbi)=nanmean(nanmean(uswrfdaymasked));
                        ulwrfdaymasked=NaN.*ones(277,349);ulwrfdaymasked(thisregion)=ulwrfdatathisday(thisregion);ulwrfavg(region,i,dbi)=nanmean(nanmean(ulwrfdaymasked));
                        dswrfdaymasked=NaN.*ones(277,349);dswrfdaymasked(thisregion)=dswrfdatathisday(thisregion);dswrfavg(region,i,dbi)=nanmean(nanmean(dswrfdaymasked));
                        dlwrfdaymasked=NaN.*ones(277,349);dlwrfdaymasked(thisregion)=dlwrfdatathisday(thisregion);dlwrfavg(region,i,dbi)=nanmean(nanmean(dlwrfdaymasked));
                        gfluxdaymasked=NaN.*ones(277,349);gfluxdaymasked(thisregion)=gfluxdatathisday(thisregion);gfluxavg(region,i,dbi)=nanmean(nanmean(gfluxdaymasked));
                        shtfldaymasked=NaN.*ones(277,349);shtfldaymasked(thisregion)=shtfldatathisday(thisregion);shtflavg(region,i,dbi)=nanmean(nanmean(shtfldaymasked));
                        lhtfldaymasked=NaN.*ones(277,349);lhtfldaymasked(thisregion)=lhtfldatathisday(thisregion);lhtflavg(region,i,dbi)=nanmean(nanmean(lhtfldaymasked));
                        
                        uswrfanommasked=NaN.*ones(277,349);uswrfanommasked(thisregion)=uswrfanomthisday(thisregion);uswrfanom(region,i,dbi)=nanmean(nanmean(uswrfanommasked));
                        ulwrfanommasked=NaN.*ones(277,349);ulwrfanommasked(thisregion)=ulwrfanomthisday(thisregion);ulwrfanom(region,i,dbi)=nanmean(nanmean(ulwrfanommasked));
                        dswrfanommasked=NaN.*ones(277,349);dswrfanommasked(thisregion)=dswrfanomthisday(thisregion);dswrfanom(region,i,dbi)=nanmean(nanmean(dswrfanommasked));
                        dlwrfanommasked=NaN.*ones(277,349);dlwrfanommasked(thisregion)=dlwrfanomthisday(thisregion);dlwrfanom(region,i,dbi)=nanmean(nanmean(dlwrfanommasked));
                        gfluxanommasked=NaN.*ones(277,349);gfluxanommasked(thisregion)=gfluxanomthisday(thisregion);gfluxanom(region,i,dbi)=nanmean(nanmean(gfluxanommasked));
                        shtflanommasked=NaN.*ones(277,349);shtflanommasked(thisregion)=shtflanomthisday(thisregion);shtflanom(region,i,dbi)=nanmean(nanmean(shtflanommasked));
                        lhtflanommasked=NaN.*ones(277,349);lhtflanommasked(thisregion)=lhtflanomthisday(thisregion);lhtflanom(region,i,dbi)=nanmean(nanmean(lhtflanommasked));
                    else
                        uswrfavg(region,i,dbi)=NaN;ulwrfavg(region,i,dbi)=NaN;dswrfavg(region,i,dbi)=NaN;dlwrfavg(region,i,dbi)=NaN;
                        gfluxavg(region,i,dbi)=NaN;shtflavg(region,i,dbi)=NaN;lhtflavg(region,i,dbi)=NaN;
                        uswrfanom(region,i,dbi)=NaN;ulwrfanom(region,i,dbi)=NaN;dswrfanom(region,i,dbi)=NaN;dlwrfanom(region,i,dbi)=NaN;
                        gfluxanom(region,i,dbi)=NaN;shtflanom(region,i,dbi)=NaN;lhtflanom(region,i,dbi)=NaN;
                    end
                end
                if rem(i,10)==0;fprintf('Just finished i=%d, region=%d\n',i,region);end
            end
            save('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/fluxarrays.mat',...
                'uswrfavg','ulwrfavg','dswrfavg','dlwrfavg','gfluxavg','shtflavg','lhtflavg',...
                'uswrfanom','ulwrfanom','dswrfanom','dlwrfanom','gfluxanom','shtflanom','lhtflanom','-append');
        end
    end
    
    
    %Average traces as a WBT-extreme day approaches, for the Midwest
    if plotavgtraces==1
        uswrfavgtrace=squeeze(nanmean(uswrfavg(6,:,:),2));
        ulwrfavgtrace=squeeze(nanmean(ulwrfavg(6,:,:),2));
        dswrfavgtrace=squeeze(nanmean(dswrfavg(6,:,:),2));
        dlwrfavgtrace=squeeze(nanmean(dlwrfavg(6,:,:),2));
        gfluxavgtrace=squeeze(nanmean(gfluxavg(6,:,:),2));
        shtflavgtrace=squeeze(nanmean(shtflavg(6,:,:),2));
        lhtflavgtrace=squeeze(nanmean(lhtflavg(6,:,:),2));
        figure(figc);clf;figc=figc+1;
        plot(uswrfavgtrace,'r','linewidth',2);hold on;plot(ulwrfavgtrace,'color',colors('orange'),'linewidth',2);
        plot(dswrfavgtrace,'color',colors('green'),'linewidth',2);plot(dlwrfavgtrace,'color',colors('light blue'),'linewidth',2);
        plot(gfluxavgtrace,'color',colors('blue'),'linewidth',2);
        plot(shtflavgtrace,'color',colors('purple'),'linewidth',2);plot(lhtflavgtrace,'color',colors('brown'),'linewidth',2);
    end
    
    %Anomalous traces as a WBT-extreme day approaches, for the Midwest
    if plotanomtraces==1
        if plotbothregions==1;regstoplot=[3;6];else regstoplot=region;end
        if plotbothregions~=1 || (plotbothregions==1 && region==3);figure(figc);clf;figc=figc+1;curpart=1;highqualityfiguresetup;end
        dayvector=[-15;-7;-3;-1;0;1;3];
        for i=1:size(regstoplot)
            curregion=regstoplot(i);
            if curregion==3;regionname='Southwest';elseif curregion==6;regionname='Midwest';end
            %Load regtadvvector and regqadvvector, computed in the computeregavgs section of findmaxtwbt
            savedfile=load(strcat('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/region',...
                num2str(curregion),'tqadvmatrix',num2str(sfcor850)));
            regtadvvector=savedfile.regtadvvector;regqadvvector=savedfile.regqadvvector;
            %Compute means to prepare for plotting
            uswrfanomtrace=squeeze(nanmean(uswrfanom(curregion,:,:),2));
            ulwrfanomtrace=squeeze(nanmean(ulwrfanom(curregion,:,:),2));
            dswrfanomtrace=squeeze(nanmean(dswrfanom(curregion,:,:),2));
            dlwrfanomtrace=squeeze(nanmean(dlwrfanom(curregion,:,:),2));
            gfluxanomtrace=squeeze(nanmean(gfluxanom(curregion,:,:),2));
            shtflanomtrace=squeeze(nanmean(shtflanom(curregion,:,:),2));
            lhtflanomtrace=squeeze(nanmean(lhtflanom(curregion,:,:),2));
            %sumanomtrace=dswrfanomtrace+dlwrfanomtrace-uswrfanomtrace-ulwrfanomtrace+gfluxanomtrace+shtflanomtrace+lhtflanomtrace;
            sumanomtrace=dswrfanomtrace+dlwrfanomtrace-uswrfanomtrace-ulwrfanomtrace+gfluxanomtrace+shtflanomtrace+lhtflanomtrace+regtadvvector+regqadvvector;
            %Do the plotting itself
            if plotbothregions==1;subplot(2,1,i);end
            scatter(dayvector,uswrfanomtrace,50,'filled','markerfacecolor',colors('red'),'markeredgecolor',colors('red'));hold on;
            scatter(dayvector,ulwrfanomtrace,50,'filled','markerfacecolor',colors('orange'),'markeredgecolor',colors('orange'));
            scatter(dayvector,dswrfanomtrace,50,'filled','markerfacecolor',colors('green'),'markeredgecolor',colors('green'));
            scatter(dayvector,dlwrfanomtrace,50,'filled','markerfacecolor',colors('light blue'),'markeredgecolor',colors('light blue'));
            scatter(dayvector,gfluxanomtrace,50,'filled','markerfacecolor',colors('blue'),'markeredgecolor',colors('blue'));
            scatter(dayvector,shtflanomtrace,50,'filled','markerfacecolor',colors('purple'),'markeredgecolor',colors('purple'));
            scatter(dayvector,lhtflanomtrace,50,'filled','markerfacecolor',colors('brown'),'markeredgecolor',colors('brown'));
            %Also include Tadv and qadv fluxes (tadvvector and qadvvector), computed in the computeregavgs section of findmaxtwbt
            scatter(dayvector,regtadvvector,50,'filled','d','markerfacecolor',colors('pink'),'markeredgecolor',colors('pink'));
            scatter(dayvector,regqadvvector,50,'filled','d','markerfacecolor',colors('gray'),'markeredgecolor',colors('gray'));
            %Sum of all fluxes
            scatter(dayvector,sumanomtrace,100,'filled','s','markerfacecolor',colors('black'),'markeredgecolor',colors('black'));
            %Finalize plot
            xhelper=[-16:4]';yhelper=zeros(21,1);plot(xhelper,yhelper,'--k','linewidth',2);
            l=legend('Upward Shortwave','Upward Longwave','Downward Shortwave','Downward Longwave','Ground Heat','Sensible Heat',...
                'Latent Heat','T Advection','q Advection','Net','location','northeastoutside');
            l.Title.FontName='arial';l.Title.FontWeight='bold';l.Title.FontSize=16;
            if plotbothregions~=1
                title(sprintf('Energy-Flux Anomalies for Extreme-WBT Days in the %s',regionname),...
                'fontname','arial','fontweight','bold','fontsize',16);
            else
                text(-0.1,1.1,figletterlabels{i},'units','normalized','fontname','arial','fontweight','bold','fontsize',14);
            end
            if curregion==3;ylim([-50 100]);elseif curregion==6;ylim([-500 250]);end
            ylabel('Anomaly (W/m^2)','fontname','arial','fontweight','bold','fontsize',14);
            xlabel('Days Relative to Extreme-WBT Day','fontname','arial','fontweight','bold','fontsize',14);
            set(gca,'fontname','arial','fontweight','bold','fontsize',12);
            if plotbothregions~=1 || (plotbothregions==1 && curregion==6)
                curpart=2;figloc=figDir;figname=strcat('tracesanomregion',num2str(curregion));
                highqualityfiguresetup;
            end
        end
    end
    
    if dotest==1
        %Compare for point 130,260
        for doy=1:365
            uswrfthisday(doy)=uswrfdata(130,260,doy);
            ulwrfthisday(doy)=ulwrfdata(130,260,doy);
            dswrfthisday(doy)=dswrfdata(130,260,doy);
            dlwrfthisday(doy)=dlwrfdata(130,260,doy);
            gfluxthisday(doy)=gfluxdata(130,260,doy);
            shtflthisday(doy)=mean(shtfldata(130,260,doy*8-7:doy*8));
            lhtflthisday(doy)=mean(lhtfldata(130,260,doy*8-7:doy*8));
            totaldown(doy)=dswrfthisday(doy)+dlwrfthisday(doy);
            totalup(doy)=uswrfthisday(doy)+ulwrfthisday(doy);
            if ~isnan(gfluxthisday)
                totalofall(doy)=totaldown(doy)-totalup(doy)+gfluxthisday(doy)+shtflthisday(doy)+lhtflthisday(doy);
            else
                totalofall(doy)=totaldown(doy)-totalup(doy)+shtflthisday(doy)+lhtflthisday(doy);
            end
        end

        %Plot for every day in 1992
        figure(figc);clf;plot(totalofall);title('net radiation at Ithaca, 1992');
    end
end

