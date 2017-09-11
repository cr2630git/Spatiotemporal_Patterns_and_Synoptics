%Analyzes the station observations (stored as .mat files) to determine dates and values of maximum T and WBT
%Also sets up various more-in-depth analyses such as trends and composite maps

%Analyses were originally conducted with n=211 and yeariwf=1981, yeariwl=2010
%After expanding to yeariwl=2015 and refining & streamlining scripts/methodology, 
    %as well as extensive & ruthless elimination of 1. AK and 2. poor-quality stations, final n=175

%If previous arrays need to be read in, do so using the first loop of exploratorydataanalysis

%When starting up, do the loops in this order:
%1. (if necessary) loadsavedarrays
%2. removebadstnsanddefinefinaldatat
%3. compiledataarrays, createmaxtwbtarrays
%4. troubleshoot using topXXhourdistn -- plot stnflagged, if anything comes up...
%5. (if necessary) rerun compiledataarrays, createmaxtwbtarrays, and topXXhourdistn, then rerun again topXXhourdistn to ensure problems are gone
%6. troubleshoot using findconsecidenticaltopXXdays -- plot suspentriesc, if anything comes up...
%7. (if necessary) rerun compiledataarrays, createmaxtwbtarrays
%8. calcstnnumsordinatesandnumbadmonthsyears, createstnlistbyregion
%9. then, other loops can be run separately and in any order

runworkcomputer=1;

%Runtime options
numdates=100;              %number of high-ranking dates to save, of both T and WBT (default: 100)
yeariwf=1981;yeariwl=2015;  %year range to compute over
monthiwf=5;monthiwl=10;     %month range to compute over
maxnumstns=190;             %the number of stations in the newstnNumList from the latest temparrayholder, ...
                                %MINUS the number of bad stations discovered hiding within it (from the list enumerated below)
                                %this number of bad stations = size(numericstnsremovedfixed,2))
                                %HAVE TO ENTER THIS NUMBER after running removebadstns and before running the rest of the script
missingdatavalt=50;         %value (deg C) beyond which temperature data is considered invalid
missingdatavalwbt=40;       %value (deg C) beyond which WBT data is considered invalid
monthlysstdataset='noaaersst';     %SST dataset to use: 'noaaersst' or 'esrlicoads' (both 2x2)
    justchangedsst=1;       %need to know to determine whether certain arrays must be recalculated


curDir='/Volumes/ExternalDriveA/WBTT_Overlap_Saved_Arrays/';
tfileloc='/Volumes/MacFormatted4TBExternalDrive/NCDC_hourly_station_data_mat/temp';
wbtfileloc='/Volumes/MacFormatted4TBExternalDrive/NCDC_hourly_station_data_mat/wbt';
ncepdailydataDir='/Volumes/MacFormatted4TBExternalDrive/NCEP_daily_data_mat/';
narr3hourlydataDir='/Volumes/MacFormatted4TBExternalDrive/NARR_3-hourly_data_mat/';
if strcmp(monthlysstdataset,'noaaersst')
    sstfileloc='/Volumes/MacFormatted4TBExternalDrive/NOAA_ERSST_Data/';sstfilename='sst.mnmean.nc';
    moncorrtojanofyeariwf=1525;moncorrtodecofyeariwl=1944;shortsstdataset='ersst';
elseif strcmp(monthlysstdataset,'esrlicoads')
    sstfileloc='/Volumes/MacFormatted4TBExternalDrive/ESRL_ICOADS_Data/';sstfilename='sst.mean.nc';
    moncorrtojanofyeariwf=2173;moncorrtodecofyeariwl=2592;shortsstdataset='icoads';
end
dailysstfileloc='/Volumes/MacFormatted4TBExternalDrive/NOAA_OISST_Daily_Data/';

%Best practice is to only run one loop at a time

whethertoloadsavedarrays=0; %whether saved arrays (in a temparrayholderXXX .mat file) need to be loaded in (1 min)
removebadstnsanddefinefinaldatat=0; %10 sec
    savetopolished=0; %only once sure finaldatat is really final (i.e. after checking its quality with topXXhourdistn)
    %removes stations that passed the tests in ncdcHourlyTxtToMat2, and thus were saved, but were bad upon further inspection
    %run this, then stop, run helpfulmanualarraycreator, change maxnumstns in the list of options above, and continue on one's merry way
compiledataarrays=0; %10 sec total
createstnlistbyregion=0; %1 sec
createmaxtwbtqarrays=0; %2 min -- *for stations*
createmaxtwbtqarraysnarroldv=0; %same as above but using 3-hourly NARR data rather than 1-hourly station data
    recreatemainmatrix=0; %1 hr 15 min per variable, so 3 hr 45 min total
    makeotheradjustments=0; %15 sec
createmaxtwbtqarraysnarrnewv=0; %same as old NARR version but using 2-m data instead of interpolating between pressure levels
    recreatemainmatrix=1; %2.5 min per year & variable, so 2 hr 30 min per variable
    makeotheradjustments=1; %15 sec
topXXhourdistn=0; %20 sec
findconsecidenticaltopXXdays=0; %1 sec
calctwbtorqscores=0; %1.5 min for stns, 18 min incl NARR data
    var1='wbt';var2='q'; %if wbt is to be included it must be var1; if doing t and q, var1=t and var2=q
    donarrdataeverygridpt=0; %15 min; whether to laboriously also calculate scores for every NARR gridpt
    leeway=0; %a hot day ranked by var1 has to be within this many days of a hot day ranked by var2 to be considered a match (=0 if exact match required)
determinetandqeffectsonwbt=0; %2 sec; calcseasonalmeantwbtq must be run first, unless sufficient data has already been saved
    computereghws=0; %whether to compute relevant figures & stats for regions as opposed to just stns (default=1)
    maketroubleshootingfig=0;
    makeexplanatoryfig=0;
topXXtraces=0; %5 sec; for weeks surrounding top-XX wbt days, and averaged over regions
groupintoheatevents=0;
calcnumberofyears=0;
calcstnnumsordinatesandnumbadmonthsyears=0; %2 sec
calctwbtqdates=0; %15 sec
calctwbtqhours=0; %2 sec
tstormanalysismaxhour=0; %2 sec; investigate if e.g. t-storms are contributing to the earlier peak in T and WBT in the South
computehourlytracestwbt=0; %2 sec; for selected stations only
mediantopXXwbtbystn=0; %2 sec
mediantopXXwbtbynarr=0; %10 sec
examinetrends=0; %2 sec
    dooccurrenceperdecade=0;
    dooccurrenceperyearandregion=1;
setupcompositemaps=0; %10 sec
createvectoralltwbtq=0; %30 sec
createvectoralltwbtqnarr=0; %4 min per year, 2 hr total
calcnarrdailyclimowbtmax=0;
calcnarrdailyanomwbtmax=0;
calcseasonalmeantwbtq=0; %30 sec; uses dailymaxstruc to find seasonal-mean T, WBT, and q for each stn-year combo, and these
    %time series will then be compared in exploratorydataanalysis to the time series of top-XX counts
calchourlyclimotwbtqeachmonth=0; %15 min; a refinement to the seasonal means that has separate climatologies for each hour of the day
calchourlyclimotwbtqeachdoy=0; %15 min; a further refinement, with climatologies calculated for each day of the year using a smoothing algorithm
    doyiwf=121;doyiwl=302;
calcimprovedhourlyclimo=0; %5 min; an improved version of the previous loop that in fact SUPERSEDES IT, as it uses harmonics rather than a clunky 7-day weighting
tqanomsextremewbt=0; %2 sec; a simpler, more easily interpretable alternative to the determinetandqeffectsonwbt loop
findwbtranksoftop100t=0; %3 sec
calcsstanomalyindex=0; %5 sec, + 30 sec for reading in data on the initial run
    regionofinterest='Gulf of Mexico'; %'Gulf of Mexico', 'NE Pacific Blob', or 'Baja/California'
    roishort='gom'; %'gom', 'nepb', or 'bslashc' (matching the full name of course)
correlsstwbtt=0;
calcsstanomalyindexeverygridpt=0; %8 sec
calcsstanomalyindexdailyeverygridpt=0; %about 10 min per year
    if calcsstanomalyindexdailyeverygridpt==1;rereadindata=1;end %whether to re-read in the daily SST data
correlssteverygridptwbtt=0; %2 min for all stns & gridpts, and for both T and WBT -- only 3 min if just doing regions & gridpts
    usedetrended=1;
    dostncorrels=0;
    doregioncorrels=1;
compilelistreghotdaysfromstnlists=0; %3 sec; list of regional hot days using the new method (ranking by avg T/WBT/q across region)
compilelistreghotdaysfromstnlistsnarr=0; %12 min for each var, 36 min total
reghotdays3highestperyear=0; %15 sec; list of regional hot days scrapping the non-linear count stuff altogether &
    %using as a metric the avg of the 3 highest days per year, for both stations and regions
definecalcsuddenspikes=0; %10 min; define and calculate # sudden spikes of q and T at each station
calcncepghdailyavgs=0; %5 sec; calculate averages from first day of monthiwf to last day of monthiwl
statsignifensopatterns=0; %calculate stat significance at every NCEP gridpt of ENSO on the gh500 anomaly composites calculated in the
    %plotncepcompositemapsnowindows loop of exploratorydataanalysis
predictabilityfromgh500=0; %do grunt work to enable predictability of extreme WBT from certain gh500 patterns at various lead times
    if predictabilityfromgh500==1
        dostep1=0; %10 sec
        dostep2=0; %4 min
        dostep3=1; %20 min
            wbtort='t'; %compute everything for extreme WBT or T
            arraytouse=eval(['topXX' wbtort 'byregionsorted; ']);
        dostep4=1; %5 sec
    end
computetqadvection=0; %compute 2-m advection at 3-hour intervals, using winds 10 m above ground level OR 850-mb advection
    if computetqadvection==1
        readindata=0; %using the default gradient method: 4 min per year, 2 hr 20 min total
            sfcor850='sfc'; %which level to compute advection for
            gradientmethod=1; %5 min per year
            laboriousway=0; %3 min per year; has problems and is not currently in operation
            elimproblemsfirstattempt=0;
        computeclimo=0; %about 15 min
        analyzedata=0; %4 min per region, 30 min total
            regtouse=6; %region to use; same region will have its averages computed in computeregavgs
        computeregavgs=1; %1 min -- closely linked to analyzedata and in most cases can be done right after it
            useanoms=1; %calculate and plot T and q fluxes as averages or anomalies
        verifplots=0;
    end
v200andz200anoms=0; %analyze anoms of v200 and z200 (on the model of Teng & Branstator 2017) to track wave activity
    if v200andz200anoms==1
        establishclimo=0; %16 min
        readinextremesdata=0; %2 min
        setupregression=0; %6 min
        verifplots=1; %2 min for one set of 6 plots
    end
    
    
    
if whethertoloadsavedarrays==1
    overviewarrays=load(strcat(curDir,'temparrayholder220aug31.mat'));
    helpfulmanualarraycreator;
    basicstuff=load(strcat(curArrayDir,'basicstuff'));
    lons=basicstuff.lons;lats=basicstuff.lats;
    narrlsmask=basicstuff.narrlsmask;
    cutoffmatrix=basicstuff.cutoffmatrix;
    narrlatmatrix=basicstuff.narrlatmatrix;
    narrlonmatrix=basicstuff.narrlonmatrix;
    tzlist=basicstuff.tzlist;
    ncaregionnamemaster=basicstuff.ncaregionnamemaster;
    monthlengthsdays=basicstuff.monthlengthsdays;
    extraarraysfile=load(strcat(curArrayDir,'extraarrays'));
    correspt=extraarraysfile.correspt;
    correspq=extraarraysfile.correspq;
    essentialarraysfile=load(strcat(curArrayDir,'essentialarrays'));
    newfitavg=essentialarraysfile.newfitavg;
    newfitstdev=essentialarraysfile.newfitstdev;
end

monthhourstarts=[1;745;1465;2209;2953;3673];
monthhourstops=[744;1464;2208;2952;3672;4416];
monthlengthsdays=[31;30;31;31;30;31];
reglist=ncaregionsfromlatlon(narrlatmatrix,narrlonmatrix);


%A relative handful of stations passed the tests in ncdcHourlyTxtToMat2, and thus were saved, 
    %but turned out to be bad upon further inspection
%Inspection consisted of visually inspecting months for suspicious outliers, identifying stations whose 
%To a large degree, this list can also be obtained by comparing
    %newstnNumList from helpfulmanualarraycreator with stnnumlistforref from stationinfofromnumber
%For some reason, the finaldatat, etc arrays stored in the mat files are all one station too long --->
    %this last unknown station's data can be removed so that the size of finaldatat and newstnNumList match up again
%This loop has to use the pristine (unshifted) versions of finaldatat, etc, so that's why they're read in here
    
%Note: finaldatat, etc were ultimately created in ncdcHourlyTxtToMat2
if removebadstnsanddefinefinaldatat==1
    overviewarrays=load(strcat(curDir,'temparrayholder220aug31pristinearrays.mat'));helpfulmanualarraycreator;
    badstnslist=[703080;722015;722026;722065;722210;722250;722269;722390;722400;722515;722576;722745;722860;722906;724088;724096;724236;...
        724240;724338;724505;725377;725755;726625;726815;727575;727855;742060;742070;745160;745700;745940;745980;746710];
    stnlisttouse=overviewarrays.newstnNumList; %make sure newstnNumList & other arrays being used are actually the *original, unmodified* versions I think they are
    newstnNumList=overviewarrays.newstnNumList;
    newstnNumListnames=overviewarrays.newstnNumListnames;
    newstnNumListlats=overviewarrays.newstnNumListlats;
    newstnNumListlons=overviewarrays.newstnNumListlons;
    finaldatat=overviewarrays.finaldatat;finaldatadewpt=overviewarrays.finaldatadewpt;
    finaldatawbt=overviewarrays.finaldatawbt;finaldataq=overviewarrays.finaldataq;
    origsizestnlisttouse=size(stnlisttouse,1);
    if size(newstnNumList,1)==1;newstnNumList=newstnNumList';end %make it a column vector if it's not already
    if size(newstnNumListnames,1)==1;newstnNumListnames=newstnNumListnames';end
    if size(newstnNumListlats,1)==1;newstnNumListlats=newstnNumListlats';end
    if size(newstnNumListlons,1)==1;newstnNumListlons=newstnNumListlons';end
    %disp(size(newstnNumListnames));
    numstnsremoved=0;
    for stn=1:origsizestnlisttouse
        for badstn=1:size(badstnslist,1)
            if stnlisttouse(stn)==badstnslist(badstn) %get rid of this station
                newstn=stn-numstnsremoved;
                fprintf('Using original numbering, station #%d of newstnNumList (%s) is bad and will be gotten rid of\n',...
                    stn,stationinfofromnumber(newstnNumList(newstn)));%disp(newstnNumList(stn));
                newstnNumList=[newstnNumList(1:newstn-1);newstnNumList(newstn+1:size(newstnNumList,1))];
                newstnNumListnames=[newstnNumListnames(1:newstn-1);newstnNumListnames(newstn+1:size(newstnNumListnames,1))];
                newstnNumListlats=[newstnNumListlats(1:newstn-1);newstnNumListlats(newstn+1:size(newstnNumListlats,1))];
                newstnNumListlons=[newstnNumListlons(1:newstn-1);newstnNumListlons(newstn+1:size(newstnNumListlons,1))];
                finaldatat=[finaldatat(:,1:newstn-1) finaldatat(:,newstn+1:size(finaldatat,2))];
                finaldatadewpt=[finaldatadewpt(:,1:newstn-1) finaldatadewpt(:,newstn+1:size(finaldatadewpt,2))];
                finaldatawbt=[finaldatawbt(:,1:newstn-1) finaldatawbt(:,newstn+1:size(finaldatawbt,2))];
                numstnsremoved=numstnsremoved+1;
                numericstnsremovedfixed(numstnsremoved)=stn+numstnsremoved-1; %where among the 220 stations the removed stations sit
                numericstnsremovednonfixed(numstnsremoved)=stn;
                fprintf('     Size of newstnNumListnames is now %d\n',size(newstnNumListnames,1));
            end
        end
    end
    %As noted above, remove last extraneous station's data from finaldatat, etc if necessary
    if size(finaldatat,2)~=size(newstnNumList,1)
        finaldatat=finaldatat(:,1:size(finaldatat,2)-1);
        finaldatadewpt=finaldatadewpt(:,1:size(finaldatadewpt,2)-1);
        finaldatawbt=finaldatawbt(:,1:size(finaldatawbt,2)-1);
    end
    %Change invalid values in finaldatat & its ilk to NaN
    for year=1:yeariwl-yeariwf+1
        for stn=1:maxnumstns
            invalidvals=finaldatat{year,stn}>=missingdatavalt;finaldatat{year,stn}(invalidvals)=NaN;
            invalidvals=finaldatadewpt{year,stn}>=missingdatavalwbt;finaldatadewpt{year,stn}(invalidvals)=NaN;
            invalidvals=finaldatawbt{year,stn}>=missingdatavalwbt;finaldatawbt{year,stn}(invalidvals)=NaN;
        end
    end
    %Also, fill in missing data with NaN's so that size(finaldatat{year,stn}) is the same for all stn-year combos
    for year=1:yeariwl-yeariwf+1
        for stn=1:maxnumstns
            if size(finaldatat{year,stn},2)==0;finaldatat{year,stn}=NaN.*ones(4416,1);end
            if size(finaldatadewpt{year,stn},2)==0;finaldatadewpt{year,stn}=NaN.*ones(4416,1);end
        end
    end
    %Compute q from Td -- trivial now that there is a dedicated function for this purpose
    for year=1:yeariwl-yeariwf+1
        for stn=1:maxnumstns
            finaldataq{year,stn}=calcqfromTd(finaldatadewpt{year,stn});
        end
    end
    %New method -- to eliminate uncertainty about finaldatawbt's origins, compute it anew from T and q
    for year=1:yeariwl-yeariwf+1
        for stn=1:maxnumstns
            finaldatawbt{year,stn}=calcwbtfromTandshum(finaldatat{year,stn},finaldataq{year,stn}/1000,1);
        end
    end
    
    %Extra corrections to finaldataXXX arrays
    finaldatacorrections;
    
    %In case we're saving to a polished dataset, split finaldatat & its ilk into 1981-1990, 1991-2000, 2001-2010, and 2011-2015
    if savetopolished==1
        finaldatat19811990={};finaldatadewpt19811990={};finaldatawbt19811990={};finaldataq19811990={};
        finaldatat19912000={};finaldatadewpt19912000={};finaldatawbt19912000={};finaldataq19912000={};
        finaldatat20012010={};finaldatadewpt20012010={};finaldatawbt20012010={};finaldataq20012010={};
        finaldatat20112015={};finaldatadewpt20112015={};finaldatawbt20112015={};finaldataq20112015={};
        for year=1:yeariwl-yeariwf+1
            for stn=1:maxnumstns
                if year<=10
                    finaldatat19811990{year,stn}=finaldatat{year,stn};
                    finaldatadewpt19811990{year,stn}=finaldatadewpt{year,stn};
                    finaldatawbt19811990{year,stn}=finaldatawbt{year,stn};
                    finaldataq19811990{year,stn}=finaldataq{year,stn};
                elseif year<=20
                    finaldatat19912000{year-10,stn}=finaldatat{year,stn};
                    finaldatadewpt19912000{year-10,stn}=finaldatadewpt{year,stn};
                    finaldatawbt19912000{year-10,stn}=finaldatawbt{year,stn};
                    finaldataq19912000{year-10,stn}=finaldataq{year,stn};
                elseif year<=30
                    finaldatat20012010{year-20,stn}=finaldatat{year,stn};
                    finaldatadewpt20012010{year-20,stn}=finaldatadewpt{year,stn};
                    finaldatawbt20012010{year-20,stn}=finaldatawbt{year,stn};
                    finaldataq20012010{year-20,stn}=finaldataq{year,stn};
                else
                    finaldatat20112015{year-30,stn}=finaldatat{year,stn};
                    finaldatadewpt20112015{year-30,stn}=finaldatadewpt{year,stn};
                    finaldatawbt20112015{year-30,stn}=finaldatawbt{year,stn};
                    finaldataq20112015{year-30,stn}=finaldataq{year,stn};
                end
            end
        end
    end
    %Update newstnNumListnames because stationinfofromnumber did not know all the stations' info when ncdcHourlyTxtToMat2 was last run
    for i=1:size(newstnNumList,1);newstnNumListnames{i}=stationinfofromnumber(newstnNumList(i));end
    save(strcat(curDir,'temparrayholder220aug31'),'newstnNumList','newstnNumListnames','newstnNumListlats',...
        'newstnNumListlons','finaldatat','finaldatadewpt','finaldatawbt','finaldataq','-append');
    save(strcat(curDir,'temparrayholder220aug31pristinearrays'),'newstnNumList','newstnNumListnames','newstnNumListlats',...
        'newstnNumListlons','finaldatat','finaldatadewpt','finaldatawbt','finaldataq','-append');
    %After saving, move these to Polished Datasets folder
    if savetopolished==1
        save(strcat(curDir,'savedarraysstationsmjjaso19811990'),'newstnNumList','newstnNumListnames','newstnNumListlats',...
           'newstnNumListlons','finaldatat19811990','finaldatadewpt19811990','finaldatawbt19811990','finaldataq19811990');
        save(strcat(curDir,'savedarraysstationsmjjaso19912000'),'newstnNumList','newstnNumListnames','newstnNumListlats',...
           'newstnNumListlons','finaldatat19912000','finaldatadewpt19912000','finaldatawbt19912000','finaldataq19912000');
        save(strcat(curDir,'savedarraysstationsmjjaso20012010'),'newstnNumList','newstnNumListnames','newstnNumListlats',...
           'newstnNumListlons','finaldatat20012010','finaldatadewpt20012010','finaldatawbt20012010','finaldataq20012010');
        save(strcat(curDir,'savedarraysstationsmjjaso20112015'),'newstnNumList','newstnNumListnames','newstnNumListlats',...
           'newstnNumListlons','finaldatat20112015','finaldatadewpt20112015','finaldatawbt20112015','finaldataq20112015');
    end
end



%Repeated below but copied up here for visibility:
    %to get the name of a station: stationinfofromnumber(stnlisttouse(newtdata1(X)))
    %to plot the data for a station: stndatat{X,relyear,month} or equivalently newtdata6(:,X)
    
%Read in data from .mat files and compile into one big array for each station and variable
%Once the data is all in the same place it's easier to analyze

%Take advantage of the fact that the bad stations were already removed from finaldatat in the above loop to simply reshuffle the data a bit
if compiledataarrays==1
    disp('Starting the compilation of stndatat arrays');disp(clock);
    stndatat={};stndatawbt={};stndatadewpt={};stndataq={};
    for year=yeariwf:yeariwl
    %for year=2013:2013
        relyear=year-yeariwf+1;
        for month=monthiwf:monthiwl
        %for month=9:9
            relmonth=month-monthiwf+1;
            thismonthhourstart=monthhourstarts(relmonth);
            thismonthhourstop=monthhourstops(relmonth);
            numhoursthismonth=thismonthhourstop-thismonthhourstart+1;
            fprintf('Compiling data array for year %d and month %d\n',year,month);
           
            tdatathismonthallstns=0;wbtdatathismonthallstns=0;dewptdatathismonthallstns=0;qdatathismonthallstns=0;
            for stn=1:size(finaldatat,2)
                [a,~]=size(finaldatat{relyear,stn});
                if a>=2
                    tdatathismonthallstns(1:numhoursthismonth,stn)=...
                        finaldatat{relyear,stn}(thismonthhourstart:thismonthhourstop);
                else
                    tdatathismonthallstns(1:numhoursthismonth,stn)=zeros(numhoursthismonth,1);
                end
                [b,~]=size(finaldatawbt{relyear,stn});
                if b>=2
                    wbtdatathismonthallstns(1:numhoursthismonth,stn)=...
                        finaldatawbt{relyear,stn}(thismonthhourstart:thismonthhourstop);
                else
                    wbtdatathismonthallstns(1:numhoursthismonth,stn)=zeros(numhoursthismonth,1);
                end
                [c,~]=size(finaldatadewpt{relyear,stn});
                if c>=2
                    dewptdatathismonthallstns(1:numhoursthismonth,stn)=...
                        finaldatadewpt{relyear,stn}(thismonthhourstart:thismonthhourstop);
                else
                    dewptdatathismonthallstns(1:numhoursthismonth,stn)=zeros(numhoursthismonth,1);
                end
                [d,~]=size(finaldataq{relyear,stn});
                if d>=2
                    qdatathismonthallstns(1:numhoursthismonth,stn)=...
                        finaldataq{relyear,stn}(thismonthhourstart:thismonthhourstop);
                else
                    qdatathismonthallstns(1:numhoursthismonth,stn)=zeros(numhoursthismonth,1);
                end
            end
                
            %For each station, check to see if this month-station combination has good data -- 
                %some combinations were excluded back in the readdataintomatfiles loop of ncdcHourlyTxtToMat2
                %because of problematic or missing data
            %Now that everything has been lined up, stndatat{38,x,y} does indeed represent the station stnlisttouse(newdata1(38))
            
            %So, in summary:
                %to get the name of a station: stationinfofromnumber(stnlisttouse(newtdata1(X)))
                %to plot the data for a station: stndatat{X,relyear,month} or equivalently newtdata6(:,X)
            for stnindex=1:maxnumstns
                %fprintf('Current station index is %d out of %d total\n',stnindex,maxnumstns);
                if max(tdatathismonthallstns(:,stnindex))>0 && max(tdatathismonthallstns(:,stnindex))<missingdatavalt
                    stnhasgoodtdata=1;
                end
                if max(wbtdatathismonthallstns(:,stnindex))>0 && max(wbtdatathismonthallstns(:,stnindex))<missingdatavalwbt
                    stnhasgoodwbtdata=1;
                end
                if stnhasgoodtdata==1 && stnhasgoodwbtdata==1 %there is valid data of both kinds for this station-year-month combination
                                           %if there is not, tdata{1} and/or wbtdata{1} would not list this station's stnindex, because
                                           %it would have been skipped when being created in the readdataintomatfiles loop of ncdcHourlyTxtToMat2
                    %fprintf('   Number of columns of newtdata6 right at the end here is %d\n',size(newtdata6,2));
                    %fprintf('This station is supposed to be %s\n',stationinfofromnumber(stnlisttouse(stnindex)));
                    %stndatat{stnindex,relyear,relmonth}=newtdata6(:,stnindex); %all the hours in this month
                    %if varmax>=2;stndatawbt{stnindex,relyear,relmonth}=newwbtdata6(:,stnindex);end
                    stndatat{stnindex,relyear,relmonth}=tdatathismonthallstns(:,stnindex);
                    stndatawbt{stnindex,relyear,relmonth}=wbtdatathismonthallstns(:,stnindex);
                    stndatadewpt{stnindex,relyear,relmonth}=dewptdatathismonthallstns(:,stnindex);
                    stndataq{stnindex,relyear,relmonth}=qdatathismonthallstns(:,stnindex);
                    %If there somehow happen to be any bad values left, replace them with NaN
                    stndatat{stnindex,relyear,relmonth}=replacevalswithnan(stndatat{stnindex,relyear,relmonth},missingdatavalt,'above');
                    stndatawbt{stnindex,relyear,relmonth}=replacevalswithnan(stndatawbt{stnindex,relyear,relmonth},missingdatavalwbt,'above');
                    stndatadewpt{stnindex,relyear,relmonth}=replacevalswithnan(stndatadewpt{stnindex,relyear,relmonth},missingdatavalwbt,'above');
                    stndataq{stnindex,relyear,relmonth}=replacevalswithnan(stndataq{stnindex,relyear,relmonth},missingdatavalwbt,'above');
                else
                    %Set to 0 if station-month combination does not have good data
                    stndatat{stnindex,relyear,relmonth}=0;
                    stndatawbt{stnindex,relyear,relmonth}=0;
                    stndatadewpt{stnindex,relyear,relmonth}=0;
                    stndataq{stnindex,relyear,relmonth}=0;
                end
            end
        end
    end
    
    %Remove certain problematic data (i.e. specific hours at specific stations) that have been encountered
    %If T is bad, WBT must be also (besides, if comparing them, shouldn't be able to have valid data for a particular date
        %in one array and not in the other
    %HAVE TO CHANGE STN ORDINATES IN BELOW LOOP IF FURTHER STATIONS ARE ELIMINATED IN THE MIDDLE OF THE ARRAYS
    %A good way to find timing errors that are affecting the final extremes statistics is to plot(topXXtbystn{Z}(:,5)) for stn Z
    for twbtc=1:4
        if twbtc==1;stndata=stndatat;elseif twbtc==2;stndata=stndatawbt;elseif twbtc==3;stndata=stndatadewpt;elseif twbtc==4;stndata=stndataq;end
        stndata{2,5,6}(508:632)=NaN.*ones(125,1);stndata{2,8,6}(572:668)=NaN.*ones(97,1); %impossibly high q at Bettles AK in 1985 and 1988
        stndata{2,9,6}(328:380)=NaN.*ones(53,1);stndata{2,10,6}(366:494)=NaN.*ones(129,1); %impossibly high q at Bettles AK in 1989 and 1990
        for i=1:6;years=[1;8];for year=1:2;stndata{3,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Nome AK for 1981 & 88
        for i=1:6;for year=9:10;stndata{6,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Talkeetna AK for 1989 & 90
        stndata{8,14,6}=NaN.*ones(744,1); %Gulkana AK's q and WBT for Oct 1994 are erroneously high
        for i=1:6;for year=1:1;stndata{10,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Cold Bay AK for 1981
        stndata{10,34,5}=NaN.*ones(720,1); %various errors at Cold Bay AK for Sep 2014
        for i=1:6;for year=25:35;stndata{12,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Homer AK's T for 2005 onward repeat the same values
        for i=1:6;years=[1;3;4;6;7;14];for year=1:6;stndata{12,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Homer AK for 1981, 1983, 1984, 1986, 87, 1994
        for i=1:6;years=[1];for year=1:1;stndata{13,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Kodiak AK for 1981
        for i=1:6;years=[16;18;21;22];for year=1:4;stndata{15,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Juneau AK's T for 1996,1998,2001-02 are bad
        stndata{16,24,6}(364:399)=NaN.*ones(36,1);stndata{16,24,6}(497:504)=NaN.*ones(8,1); %impossibly low WBTs at Key West in 2004
        for i=1:6;years=[1;16;25];for year=1:3;stndata{16,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Key West's '96 & '05 T & WBT are too low by ~10 C, & 81 has timing errors
        for i=2:3;years=[1];for year=1:1;stndata{24,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Macon GA for Jun & Jul 1981
        for i=1:6;for year=29:31;stndata{27,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Mobile AL's T for 2009-2011 repeat the same values
        for i=1:6;years=[1];for year=1:1;stndata{43,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at San Diego CA for 1981
        for i=1:6;years=[1;7;8;14];for year=1:4;stndata{45,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Long Beach AP CA for 1981, 87, 88, & 94
        stndata{48,3,4}(552:693)=NaN.*ones(142,1); %unreasonable spike in q at Cherry Point NC in Aug 1983
        stndata{48,12,4}(284)=NaN; %unreasonable spike in q for 1 hour at Cherry Point NC in Aug 1992
        stndata{48,12,5}(161)=NaN; %unreasonable spike in q for 1 hour at Cherry Point NC in Sep 1992
        stndata{48,19,5}(198)=NaN; %unreasonable spike in q for 1 hour at Cherry Point NC in Sep 1999
        for i=1:6;for year=25:35;stndata{48,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Cherry Point NC's T and q for 2005 onward repeat the same values
        stndata{49,3,4}(288)=NaN; %unreasonable spike in q at Columbia SC for 1 hour in Aug 1983
        stndata{50,1,2}=NaN.*ones(720,1);stndata{50,1,3}=NaN.*ones(744,1); %timing errors at Athens GA for Jun & Jul 1981
        for i=1:6;stndata{53,16,i}=NaN.*ones(monthlengthsdays(i)*24,1);end %Asheville NC's T for 1996 are erroneously low
        for i=1:6;stndata{59,16,i}=NaN.*ones(monthlengthsdays(i)*24,1);end %Memphis TN's T for 1996 are erroneously low
        for i=1:6;for year=29:30;stndata{63,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Las Vegas NV's T for 2009-2010 repeat the same values
        for i=1:6;stndata{64,14,i}=NaN.*ones(monthlengthsdays(i)*24,1);end %Mercury NV's T for 1994 is unrealistically high
        for i=1:6;years=[3;5;8];for year=1:3;stndata{68,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Reagan National AP VA for 1983, 85, & 88
        for i=1:6;for year=29:32;stndata{89,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Concordia KS's T for 2009-2012 repeat the same values
        for i=1:6;for year=1:1;stndata{90,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Alamosa CO for 1981
        for i=1:6;years=[16;27];for year=1:2;stndata{90,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Alamosa CO's T for 1996 & 2007 are bad
        for i=1:6;years=[7];for year=1:1;stndata{91,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Pueblo CO for 1987
        for i=1:6;for year=29:32;stndata{92,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Reno NV's T for 2009-2012 repeat the same values
        for i=6:6;stndata{93,21,i}=NaN.*ones(monthlengthsdays(i)*24,1);end %bad values for San Francisco CA in Oct 2001
        for i=1:6;stndata{93,30,i}=NaN.*ones(monthlengthsdays(i)*24,1);end %San Francisco CA's T for 2010 repeat the same values
        for i=1:6;years=[1];for year=1:1;stndata{94,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Newark NJ for 1981
        for i=4:5;years=[3];for year=1:1;stndata{96,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Islip NY for Aug & Sep 1983
        for i=1:6;for year=3:3;stndata{103,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Pittsburgh PA for 1983
        for i=1:6;for year=1:1;stndata{104,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Akron OH for 1981
        for i=1:6;for year=29:31;stndata{124,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Norfolk NE's T for 2009-2011 repeat the same values
        for i=1:6;for year=26:35;stndata{132,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Lander WY's T for 2006 onward repeat the same values
        for i=1:6;stndata{134,25,i}=NaN.*ones(monthlengthsdays(i)*24,1);end %Winnemucca NV's T for 2005 repeats the same values
        for i=1:6;for year=6:8;stndata{135,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Red Bluff CA's T and WBT for 1986-88 are erroneously low
        for i=1:6;for year=29:32;stndata{141,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Muskegon MI's T for 2009-2012 repeat the same values
        for i=1:6;years=[1;5];for year=1:2;stndata{143,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Houghton Lake MI for 1981 & 85
        for i=1:6;for year=1:1;stndata{149,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Sioux Falls SD for 1981
        for i=1:6;for year=1:1;stndata{152,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Aberdeen SD for 1981
        for i=1:6;for year=29:30;stndata{158,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Salem OR's T for 2009-2010 repeat the same values
        for i=1:6;for year=29:32;stndata{160,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Sault Ste Marie MI's T for 2009-2012 repeat the same values
        for i=1:6;for year=29:32;stndata{161,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Duluth MN's T for 2009-2012 repeat the same values
        for i=1:6;for year=1:1;stndata{162,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Intl Falls MN for 1981
        for i=1:6;stndata{169,30,i}=NaN.*ones(monthlengthsdays(i)*24,1);end %Havre MT's T for 2010 are erroneously low
        for i=1:6;for year=25:35;stndata{170,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Kalispell MT's T for 2005 onward are erroneously low
        for i=1:6;for year=1:1;stndata{172,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Lewiston ID for 1981
        for i=1:6;stndata{174,32,i}=NaN.*ones(monthlengthsdays(i)*24,1);end %Astoria OR's T for 2012 repeats the same values
        for i=1:6;for year=1:1;stndata{175,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Olympia WA for 1981
        for i=1:6;for year=23:35;stndata{178,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %Brunswick ME's T for 2003 onward repeat the same values
        for i=1:6;for year=1:1;stndata{184,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Abilene TX for 1981
        for i=1:6;for year=1:1;stndata{187,year,i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Oklahoma City OK for 1981
        for i=1:6;years=[5;7;10];for year=1:3;stndata{188,years(year),i}=NaN.*ones(monthlengthsdays(i)*24,1);end;end %timing errors at Fort Smith AR for 1985, 87, 90
        if twbtc==1;stndatat=stndata;elseif twbtc==2;stndatawbt=stndata;elseif twbtc==3;stndatadewpt=stndata;elseif twbtc==4;stndataq=stndata;end
    end
    
    %Verification: for j=1:190;earliesthour(j)=min(topXXtbystn{j}(:,5));end
    
    %Fix stndata arrays that have the missing data in the wrong place (i.e. usually at the beginning when it should be at the end)
    %Each correction made here has been carefully verified by plotting stndatat and finaldatat (with problems identified from topXXdatat), 
        %and comparing all these against Climod records
    %Unless otherwise noted, these also all are related to problems with 1981 data
    %for twbtc=1:4
    %    if twbtc==1;stndata=stndatat;elseif twbtc==2;stndata=stndatawbt;elseif twbtc==3;stndata=stndatadewpt;elseif twbtc==4;stndata=stndataq;end
    %    for month=1:5 %deal with month 6 by itself
    %        stndata{152,1,month}=[stndata{152,1,month}(390:size(stndata{152,1,month},1));stndata{152,1,month+1}(1:389)];
    %    end
    %    stndata{152,1,6}=[stndata{152,1,6}(390:size(stndata{152,1,6},1));NaN.*ones(390,1)];
    %    if twbtc==1;stndatat=stndata;elseif twbtc==2;stndatawbt=stndata;elseif twbtc==3;stndatadewpt=stndata;elseif twbtc==4;stndataq=stndata;end
    %end
    
    %Save the arrays into a .mat file
    save(strcat(curDir,'stndatatandwbt'),'stndatat','stndatawbt','stndatadewpt','stndataq');
    disp(clock);
end


%Simply create a list of the station IDs of all the stations in each of the 8 NCA regions
if createstnlistbyregion==1
    regc=zeros(8,1);stnceachregion=zeros(8,1);
    for stn=1:maxnumstns
        region=ncaregionnum{stn};
        regc(region)=regc(region)+1;
        stnlistbyregion{region}(regc(region))=newstnNumList(stn);
        stnceachregion(region)=stnceachregion(region)+1;
    end
    save(strcat(curDir,'extraarrays'),'stnlistbyregion','stnceachregion','-append');
end

%Now, find the maximum valid T, WBT, and q values -- and their locations -- for each station
%Only one value is allowed per day
%Considerable numbers of stations are missing >10% of years, so keep this in mind when looking at specific stations or specific events
    %-- missing data mean that only analysis in aggregate truly makes sense
%Time is apparently in UTC -- so a UTC-LST offset must be included to get hour-of-max as a LST value, and day-of-max is similarly adjusted
    %(i.e. a max that occurs at 1 AM July 1 [UTC] in NYC will show up as 9 PM June 30 [LST], be listed in the June records, etc)
if createmaxtwbtqarrays==1
    topXXtbystn={};topXXwbtbystn={};topXXqbystn={};
    for var=1:3
        if var==1
            varname='T';stndata=stndatat;
        elseif var==2
            varname='WBT';stndata=stndatawbt;
        elseif var==3
            varname='q';stndata=stndataq;
        end
        
        for stnindex=1:maxnumstns
        %for stnindex=143:143
            fprintf('Calculating maximum %s values; current station index is %d out of %d\n',varname,stnindex,maxnumstns);
            curstnnum=newstnNumList(stnindex);[curstnname,~,~,curstntz]=stationinfofromnumber(curstnnum);
            fprintf('Current station number is %d (%s)\n',curstnnum,curstnname);
            curtopXX=-missingdatavalt*ones(numdates,5);
            
            for year=yeariwf:yeariwl
            %for year=1981:1983
                relyear=year-yeariwf+1;
                for month=monthiwf:monthiwl
                    %fprintf('Year and month are now %d, %d\n',year,month);
                    relmonth=month-monthiwf+1;
                    thismonthdata=stndata{stnindex,relyear,relmonth};
                    thismonthdatawbt=stndatawbt{stnindex,relyear,relmonth}; %need to be able to reference WBT when doing T, and vice versa
                    thismonthdatat=stndatat{stnindex,relyear,relmonth};
                    %Months are defined by UTC, so to get local months, need data from adjacent months also
                    if month~=monthiwf;prevmonthdata=stndata{stnindex,relyear,relmonth-1};end
                    if month~=monthiwl
                        nextmonthdata=stndata{stnindex,relyear,relmonth+1};
                        nextmonthdatat=stndatat{stnindex,relyear,relmonth+1};
                        nextmonthdatawbt=stndatawbt{stnindex,relyear,relmonth+1};
                    end
                    monthlen=monthlengthsdays(relmonth)*24; %length is in hours

                    %Look through hours of the month
                    %Finally, look at the last several hours of the month that (because this is the Western Hemisphere)
                        %are in the next month according to UTC
                    %In each day, hour count goes from 1 (12 AM) to 24 (11 PM)
                    hour=curstntz+1; %i.e. say if the offset is 9 hours, then each day's hour count starts at 9 AM UTC (the 10th hour) --> 12 AM LST
                    prevhour=hour;
                    while hour<=monthlen+curstntz
                        %if rem(hour,numdates)==0;fprintf('Hour is %d\n',hour);end
                        if hour<=monthlen
                            if thismonthdata(hour)>curtopXX(size(curtopXX,1),1) && thismonthdata(hour)<missingdatavalt && ...
                                thismonthdata(hour)~=0 && thismonthdatat(hour)>=thismonthdatawbt(hour) %ensure that data is valid in all respects
                                dataisintopnumdates=1;hourisincurmonth=1;
                                %fprintf('Data for hour=%d is in top numdates\n',hour);
                            else
                                dataisintopnumdates=0;
                            end
                        else %hour is into the next month selon UTC
                            if nextmonthdata(hour-monthlen)>curtopXX(size(curtopXX,1),1) && nextmonthdata(hour-monthlen)<missingdatavalt && ...
                                nextmonthdata(hour-monthlen)~=0 && nextmonthdatat(hour-monthlen)>=nextmonthdatawbt(hour-monthlen) %ditto
                                dataisintopnumdates=1;hourisincurmonth=0;
                            else
                                dataisintopnumdates=0;
                            end
                        end
                        if dataisintopnumdates==1
                            day=round2((hour-curstntz)/24,1,'ceil');
                            
                            %fprintf('Found some data to add; year, month, day are %d, %d, %d\n',year,month,day);
                            %if hour<=monthlen
                            %    fprintf('First qualifying data value found on this day is %0.2f\n',thismonthdata(hour));
                            %else
                            %    fprintf('First qualifying data value found on this day is %0.2f\n',nextmonthdata(hour-monthlen));
                            %end
                            
                            %If we're in this loop at all, at least one of the hours on this day deserves to be in the top XX
                            %First, save it...
                            hourofdayutc=rem(hour,24)-1;
                            hourofdaylst=hourofdayutc-curstntz;if hourofdaylst<=0;hourofdaylst=hourofdaylst+24;end
                            if hourisincurmonth==1
                                highestvalfoundsofar=thismonthdata(hour);
                            else
                                highestvalfoundsofar=nextmonthdata(hour-monthlen);
                            end
                            valtouse=highestvalfoundsofar; %tentatively, unless/until we find something even higher
                            hourofvaltouse=hourofdaylst; %in LST
                           

                            %...Now, let's see if there's a later hour that's even higher than this first one we stumbled across
                            potentialhour=hour;
                            hourofdayutc=rem(potentialhour-1,24);
                            potentialhourofdaylst=rem(hourofdayutc-curstntz,24);
                            if potentialhourofdaylst<0;potentialhourofdaylst=potentialhourofdaylst+24;end
                            %fprintf('Potentialhour: %d; potentialhourofdaylst: %d\n',potentialhour,potentialhourofdaylst);
                            %fprintf('Highestvalfoundsofar is %0.2f\n',highestvalfoundsofar);
                            thisdaycontinues=1;
                            while thisdaycontinues==1
                                %disp(hour);disp(potentialhourofdaylst);
                                if potentialhour>monthlen %last several hours of the month LST --> new month UTC
                                    valtotest=nextmonthdata(potentialhour-monthlen);
                                else
                                    valtotest=thismonthdata(potentialhour);
                                end
                                %fprintf('valtotest: %0.2f\n',valtotest);
                                if valtotest>highestvalfoundsofar && valtotest<missingdatavalt
                                    %fprintf('Valtouse was %0.2f; now it is %0.2f\n',highestvalfoundsofar,valtotest);
                                    valtouse=valtotest;highestvalfoundsofar=valtotest;
                                    hourofvaltouse=potentialhourofdaylst;%if hourofvaltouse<=0;hourofvaltouse=hourofvaltouse+24;end
                                    %fprintf('Found some more data to add for this day; hour of day is %d\n',hourofvaltouse);
                                    %fprintf('Data value is %0.2f\n',valtotest);
                                end
                                potentialhour=potentialhour+1;
                                hourofdayutc=rem(potentialhour-1,24);
                                potentialhourofdaylst=rem(hourofdayutc-curstntz,24);
                                if potentialhourofdaylst<0;potentialhourofdaylst=potentialhourofdaylst+24;end
                                %fprintf('Inside the loop, potentialhour: %d; potentialhourofdaylst: %d\n',potentialhour,potentialhourofdaylst);
                                if potentialhourofdaylst==23;thisdaycontinues=0;end
                            end
                            
                            %fprintf('Daily max on this day is %0.2f, at hour %d\n',valtouse,hourofvaltouse);
                            
                            
                            if hourofvaltouse==24;hourofvaltouse=hourofvaltouse-24;end %so hours of day are in range 0-23

                            
                            curtopXX(numdates,1)=valtouse;
                            curtopXX(numdates,2)=year;curtopXX(numdates,3)=month;
                            curtopXX(numdates,4)=day;curtopXX(numdates,5)=hourofvaltouse;
                            
                            if hourisincurmonth~=1;realhourofmonth=hour-monthlen;else realhourofmonth=hour;end
                            if realhourofmonth==monthlen;realhourofmonth=1;end %ad hoc solution

                            
                            %curtopXX=unique(curtopXX,'rows'); %shouldn't be necessary if the loop is working right
                            curtopXX=sortrows(curtopXX,-1);
                            if year==2000
                            %fprintf('A. New top-numdates value is %0.2f, at potentialhour %d\n',valtouse,realhourofmonth);
                            %fprintf('B. Year, month, day, and hour of day are %d, %d, %d, and %d\n',year,month,day,hourofvaltouse);
                            end
                            highestvalfoundsofar=-50;
                            hour=potentialhour+1; %we move on to the next calendar day
                            %fprintf('New hour is %d; prevhour was %d\n',hour,prevhour);
                            prevhour=hour;
                        else
                            hour=hour+1;prevhour=hour;
                        end
                    end
                end
            end
            curtopXX(:,1)=round2(curtopXX(:,1),0.1);
            %Sort top-XX arrays by temperature and then by day of month
                %(the latter so that there is not a skewing effect of the early years being
                %listed first and filling up the end of the array, distorting trends)
            curtopXX=sortrows(curtopXX,[-1 4]);
            if var==1
                topXXtbystn{stnindex}=curtopXX;
            elseif var==2
                topXXwbtbystn{stnindex}=curtopXX;
            elseif var==3
                topXXqbystn{stnindex}=curtopXX;
            end
        end
    end
    if numdates==100
        save(strcat(curDir,'topXXarrays'),'topXXtbystn','topXXwbtbystn','topXXqbystn','-append');
    elseif numdates==1000
        top1000tbystn=topXXtbystn;top1000wbtbystn=topXXwbtbystn;top1000qbystn=topXXqbystn;
        save(strcat(curDir,'topXXarrays'),'top1000tbystn','top1000wbtbystn','top1000qbystn','-append');
    end
end


%Same as above loop but using NARR data rather than station data
%Uses 1000-hPa NARR data to define hot days, and then on those hot days
%interpolates conditions at the surface from those at 1000 and 850 mb (or 850 and 500 mb for very high-elevation sites)
if createmaxtwbtqarraysnarroldv==1
    %To avoid the need to save huge reels of data, start with a predefined cutoff value for each gridpt,
        %below which I'm sure there won't be any top-XX occurrences
    for var=2:2
        if var==1 %T
            varfname='air';adj=273.15;
        elseif var==2 %WBT
            varfname='shum';adj=0; %WBT will be calculated from shum and T in the loop below
        elseif var==3 %q
            varfname='shum';adj=0;
        end
        cutoffmatrix=load(strcat(narr3hourlydataDir,varfname,'/1981/',varfname,'_1981_05_01.mat'));
        cutoffmatrix=eval(['cutoffmatrix.' varfname '_1981_05_01;']);
        lats=cutoffmatrix{1};lons=cutoffmatrix{2};
        cutoffmatrix=cutoffmatrix{3}-adj;cutoffmatrix=cutoffmatrix(:,:,1,1);
        narrlsmask=(ncread(strcat('/Volumes/MacFormatted4TBExternalDrive/narrlandseamask.nc'),'land'))';
        temp=narrlsmask<0;narrlsmask(temp)=NaN;

        %Another preliminary thing we need to do is calculate the lat/lon and the time zone of each NARR gridpt
        for i=1:277
            for j=1:349
                narrlatmatrix(i,j)=lats(i,j);narrlonmatrix(i,j)=lons(i,j);
            end
        end  
        tzlist=timezonesfromlatlon(narrlatmatrix,narrlonmatrix);
        save(strcat(curDir,'basicstuff'),'lons','lats','narrlsmask','cutoffmatrix','narrlatmatrix','narrlonmatrix','tzlist','-append');

        if recreatemainmatrix==1
            for i=1:120;for col=1:7;topXXdatanarr(:,:,i,col)=cutoffmatrix;end;end %20 extra gives us room to maneuver since some entries
                %may be eliminated below because of local-UTC time effects

            for year=yeariwf:yeariwl
                for month=5:9
                    fprintf('Doing NARR hot-days computation loop for year %d, month %d\n',year,month);
                    if month==10;addzero='';else addzero='0';end
                    data=load(strcat(narr3hourlydataDir,varfname,'/',num2str(year),'/',varfname,'_',num2str(year),...
                        '_',addzero,num2str(month),'_01.mat'));
                    data=eval(['data.' varfname '_' num2str(year) '_' addzero num2str(month) '_01']);data=data{3}-adj;
                    data1000=data(:,:,1,:);data850=data(:,:,2,:);data500=data(:,:,3,:);
                    if var==2
                        tdata=load(strcat(narr3hourlydataDir,'air/',num2str(year),'/air_',num2str(year),...
                        '_',addzero,num2str(month),'_01.mat'));
                        tdata=eval(['tdata.air_' num2str(year) '_' addzero num2str(month) '_01']);tdata=tdata{3}-273.15;
                        tdata1000=tdata(:,:,1,:);tdata850=tdata(:,:,2,:);tdata700=tdata(:,:,3,:);
                    end

                    for i=111:111
                        %if rem(i,100)==0;fprintf('i is %d\n',i);end
                        for j=198:198
                            %Only need to calculate heat waves for land gridpts
                            if narrlsmask(i,j)==1
                                thisgridptdata1000=squeeze(data1000(i,j,1,:)); %size ~ 240x1
                                thisgridptdata1000sorted=squeeze(sort(thisgridptdata1000)); %size ~ 240x1
                                thisgridptdata1000sorted=flipud(thisgridptdata1000sorted);
                                if var==2
                                    thisgridpttdata1000=squeeze(tdata1000(i,j,1,:)); %size ~ 240x1
                                    %Now, use T and q data to calculate WBT
                                    thisgridptdata1000=calcwbtfromTandshum(thisgridpttdata1000,thisgridptdata1000,1);
                                    thisgridptdata1000sorted=squeeze(sort(thisgridptdata1000)); %size ~ 240x1
                                    thisgridptdata1000sorted=flipud(thisgridptdata1000sorted);
                                end
                                cutoffval=topXXdatanarr(i,j,120,1);
                                %Only need to even look more closely at this gridpt-month combo if it has any data > cutoffval
                                if thisgridptdata1000sorted(1)>cutoffval
                                    while max(thisgridptdata1000)>cutoffval
                                        [a,b]=max(thisgridptdata1000);
                                        relhourofmax=rem(b,8);if relhourofmax==0;relhourofmax=8;end
                                        topXXdatanarr(i,j,120,1)=a;    %this hour's value at 1000 hPa
                                        topXXdatanarr(i,j,120,2)=year; 
                                        topXXdatanarr(i,j,120,3)=month;
                                        topXXdatanarr(i,j,120,4)=round2(b/8,1,'ceil');
                                        topXXdatanarr(i,j,120,5)=relhourofmax*3-1.5+tzlist(i,j);
                                        %disp(relhourofmax);disp(relhourofmax*3-1.5+tzlist(i,j));
                                        topXXdatanarr(i,j,120,6)=data850(i,j,1,b); %this hour's value at 850 hPa
                                        topXXdatanarr(i,j,120,7)=data500(i,j,1,b); %this hour's value at 500 hPa
                                        %Set this day's data =0 so the next-highest value can be found
                                        thisgridptdata1000(b-(relhourofmax-1):b+8-relhourofmax)=zeros(8,1);
                                        %Sort topXXdatanarr
                                        topXXdatanarr(i,j,:,:)=sortrows(squeeze(topXXdatanarr(i,j,:,:)),-1);
                                        %Make new cutoff val
                                        cutoffval=topXXdatanarr(i,j,120,1); %the new cutoffval
                                    end
                                end
                            end
                        end
                    end
                    fclose('all');clear data;
                end
            end
            if var==1
                topXXdatatnarr=topXXdatanarr;save(strcat(curDir,'narrarrays'),'topXXdatatnarr','-append');
            elseif var==2
                topXXdatawbtnarr=topXXdatanarr;save(strcat(curDir,'narrarrays'),'topXXdatawbtnarr','-append');
            elseif var==3
                topXXdataqnarr=topXXdatanarr;save(strcat(curDir,'narrarrays'),'topXXdataqnarr','-append');
            end
        end

        if makeotheradjustments==1
            %If hours are <0 (because of local-UTC adjustment), add 24 and decrease day by 1
            for i=1:277
                for j=1:349
                    if narrlsmask(i,j)==1 && tzlist(i,j)~=0
                        for row=1:120
                            if topXXdatanarr(i,j,row,5)<0
                                topXXdatanarr(i,j,row,5)=topXXdatanarr(i,j,row,5)+24;
                                topXXdatanarr(i,j,row,4)=topXXdatanarr(i,j,row,4)-1;
                                if topXXdatanarr(i,j,row,4)==0
                                    topXXdatanarr(i,j,row,3)=topXXdatanarr(i,j,row,3)-1;
                                    relmon=topXXdatanarr(i,j,row,3)-monthiwf+1;
                                    if relmon<4 %outside range of months -- %set it equal to the previous row so it'll be eliminated
                                        if row~=1
                                            topXXdatanarr(i,j,row,2)=topXXdatanarr(i,j,row-1,2);
                                            topXXdatanarr(i,j,row,3)=topXXdatanarr(i,j,row-1,3); 
                                            topXXdatanarr(i,j,row,4)=topXXdatanarr(i,j,row-1,4);
                                        else
                                            topXXdatanarr(i,j,row,2)=topXXdatanarr(i,j,row+1,2);
                                            topXXdatanarr(i,j,row,3)=topXXdatanarr(i,j,row+1,3); 
                                            topXXdatanarr(i,j,row,4)=topXXdatanarr(i,j,row+1,4);
                                        end
                                    else
                                        topXXdatanarr(i,j,row,4)=monthlengthsdays(relmon);
                                    end
                                end
                            end
                        end
                    end
                end
            end

            %Now that lists are complete, go through and eliminate entries that, because of local-UTC time effects,
                %are actually on the same day
            %Runtime: 2 min
            temp=topXXdatanarr;
            for i=1:277
                for j=1:349
                    if narrlsmask(i,j)==1 && tzlist(i,j)~=0
                        subsetarr=squeeze(topXXdatanarr(i,j,:,2:4)); %year,month,day only (so the function 'unique' can be used)
                        [newsubsetarr,uniquerows]=unique(subsetarr,'rows');
                        uniquerows=sort(uniquerows);
                        uniquerowsmatrix=[uniquerows uniquerows uniquerows uniquerows uniquerows uniquerows uniquerows];
                        %temp=squeeze(topXXdatatnarr(i,j,:,:));%temp=temp(uniquerowsmatrix);
                        newrow=0;
                        for row=1:120
                            if checkifthingsareelementsofvector(uniquerows,row)
                                newrow=newrow+1;
                                temp(i,j,newrow,:)=topXXdatanarr(i,j,row,:);
                            end
                        end
                    end
                end
            end
            topXXdatanarr=temp;

            %Cut size down to 100x7
            newtopXXdatanarr=zeros(277,349,100,7);
            for i=1:277
                for j=1:349
                    if narrlsmask(i,j)==1 && tzlist(i,j)~=0
                        temp=topXXdatanarr(i,j,1:100,:);
                        newtopXXdatanarr(i,j,:,:)=temp;
                    else
                        newtopXXdatanarr(i,j,:,:)=zeros(1,1,100,7);
                    end
                end
            end
            topXXdatanarr=newtopXXdatanarr;

            if var==1
                topXXdatatnarr=topXXdatanarr;save(strcat(curDir,'narrarrays'),'topXXdatatnarr','-append');
            elseif var==2
                topXXdatawbtnarr=topXXdatanarr;save(strcat(curDir,'narrarrays'),'topXXdatawbtnarr','-append');
            elseif var==3
                topXXdataqnarr=topXXdatanarr;save(strcat(curDir,'narrarrays'),'topXXdataqnarr','-append');
            end
        end
    end

    for var=1:3
        if var==1
            topXXdatanarr=topXXdatatnarr;
        elseif var==2
            topXXdatanarr=topXXdatawbtnarr;
        elseif var==3
            topXXdatanarr=topXXdataqnarr;
        end
        %Pressure at surface as represented in the NARR model
        ghofsfc=ncread('ghofsfcnarr.nc','hgt');
        temp=ghofsfc<0;ghofsfc(temp)=NaN;
        presofsfc=pressurefromheight(ghofsfc)';

        %Use pressure at surface to interpolate temperature at surface of terrain (for comparison to cities)
        %from the 1000-, 850-, and 500-hPa data
        topXXbynarr=zeros(277,349,100,5);
        for i=1:277
            for j=1:349
                if narrlsmask(i,j)==1 && tzlist(i,j)~=0 %U.S. only
                    if presofsfc(i,j)==1000
                        topXXbynarr(i,j,:,1)=topXXdatanarr(i,j,:,1);
                    elseif presofsfc(i,j)>850
                        wgt1000=(presofsfc(i,j)-850)./(1000-850);
                        wgt850=(1000-presofsfc(i,j))./(1000-850);
                        topXXbynarr(i,j,:,1)=wgt1000.*topXXdatanarr(i,j,:,1)+wgt850.*topXXdatanarr(i,j,:,6);
                    elseif presofsfc(i,j)==850
                        topXXbynarr(i,j,:,1)=topXXdatanarr(i,j,:,6);
                    else
                        wgt850=(presofsfc(i,j)-500)./(850-500);
                        wgt500=(850-presofsfc(i,j))./(850-500);
                        topXXbynarr(i,j,:,1)=wgt850.*topXXdatanarr(i,j,:,6)+wgt500.*topXXdatanarr(i,j,:,7);
                    end
                    topXXbynarr(i,j,:,2:5)=topXXdatanarr(i,j,:,2:5);
                end
            end
        end
        if var==1
            topXXtbynarr=topXXbynarr;save(strcat(curDir,'narrarrays'),'topXXtbynarr','-append');
        elseif var==2
            topXXwbtbynarr=topXXbynarr;save(strcat(curDir,'narrarrays'),'topXXwbtbynarr','-append');
        elseif var==3
            topXXqbynarr=topXXbynarr;save(strcat(curDir,'narrarrays'),'topXXqbynarr','-append');
        end
        %Keep in mind that the absolute values of t, wbt, and q in the NARR gridpts don't matter so much as
        %the fact that the relative positions of different days & heat waves are reasonably well preserved
    end
end


if createmaxtwbtqarraysnarrnewv==1
    %To avoid the need to save huge reels of data, start with a predefined cutoff value for each gridpt,
        %below which I'm sure there won't be any top-XX occurrences
    newdataloc='/Volumes/MacFormatted4TBExternalDrive/NARR_3-hourly_data_raw/';
    for var=2:2
        if var==1 %T
            varfname='air';adj=273.15;
        elseif var==2 %WBT
            varfname='shum';adj=0; %WBT will be calculated from shum and T in the loop below
        elseif var==3 %q
            varfname='shum';adj=0;
        end
        cutoffmatrix=ncread(strcat(newdataloc,varfname,'.2m.1981.nc'),varfname);
        lats=narrlatmatrix;lons=narrlonmatrix;
        cutoffmatrix=permute(cutoffmatrix,[2 1 3])-adj;
        cutoffmatrix=cutoffmatrix(:,:,1);temp=abs(cutoffmatrix)>10^3;cutoffmatrix(temp)=NaN;
        if var==2
            cutoffmatrixt=ncread(strcat(newdataloc,'air.2m.1981.nc'),'air');
            cutoffmatrixt=permute(cutoffmatrixt,[2 1 3])-273.15;cutoffmatrixt=cutoffmatrixt(:,:,1);
            temp=abs(cutoffmatrixt)>10^3;cutoffmatrixt(temp)=NaN;
        end
        cutoffmatrix=calcwbtfromTandshum(cutoffmatrixt,cutoffmatrix,0);
        
        narrlsmask=(ncread(strcat('/Volumes/MacFormatted4TBExternalDrive/narrlandseamask.nc'),'land'))';
        temp=narrlsmask<0;narrlsmask(temp)=NaN;

        %Another preliminary thing we need to do is calculate the lat/lon and the time zone of each NARR gridpt
        for i=1:277
            for j=1:349
                narrlatmatrix(i,j)=lats(i,j);narrlonmatrix(i,j)=lons(i,j);
            end
        end  
        tzlist=timezonesfromlatlon(narrlatmatrix,narrlonmatrix);
        save(strcat(curDir,'basicstuff'),'lons','lats','narrlsmask','cutoffmatrix','narrlatmatrix','narrlonmatrix','tzlist','-append');

        if recreatemainmatrix==1
            topXXdatanarr=zeros(277,349,120,5);
            for i=1:120;for col=1:5;topXXdatanarr(:,:,i,col)=cutoffmatrix;end;end %20 extra (beyond the 100 needed) gives us room to maneuver since some entries
                %may be eliminated below because of local-UTC time effects

            for year=yeariwf:yeariwl
                fprintf('Doing NARR hot-days computation loop for year %d\n',year);disp(clock);
                data=ncread(strcat(newdataloc,varfname,'.2m.',num2str(year),'.nc'),varfname);
                data=permute(data,[2 1 3]);
                data=data-adj;%data=data(:,:,1);
                temp=abs(data)>10^3;data(temp)=NaN;
                if var==2
                    tdata=ncread(strcat(newdataloc,'air.2m.',num2str(year),'.nc'),'air');
                    tdata=permute(tdata,[2 1 3]);tdata=tdata-273.15;temp=abs(tdata)>10^3;tdata(temp)=NaN;
                end

                for i=1:277
                    if rem(i,25)==0;fprintf('i is %d\n',i);end
                    for j=1:349
                        %Only need to calculate for land gridpts
                        if narrlsmask(i,j)==1
                            thisgridptdata=squeeze(data(i,j,:)); %size ~ 2920x1
                            thisgridptdatasorted=flipud(squeeze(sort(thisgridptdata))); %size ~ 2920x1
                            if var==2
                                thisgridpttdata=squeeze(tdata(i,j,:)); %size ~ 2920x1
                                %Now, use T and q data to calculate WBT
                                thisgridptwbtdata=calcwbtfromTandshum(thisgridpttdata,thisgridptdata,1);
                                thisgridptwbtdatasorted=flipud(squeeze(sort(thisgridptwbtdata))); %size ~ 2920x1
                            end
                            cutoffval=topXXdatanarr(i,j,120,1);
                            %Only need to even look more closely at this gridpt-year combo if it has any data > cutoffval
                            if thisgridptwbtdatasorted(1)>cutoffval
                                while max(thisgridptwbtdata)>cutoffval
                                    [a,b]=max(thisgridptwbtdata);
                                    doy=round2(b/8,1,'ceil');
                                    relhourofmax=rem(b,8);if relhourofmax==0;relhourofmax=8;end
                                    topXXdatanarr(i,j,120,1)=a;    
                                    topXXdatanarr(i,j,120,2)=year; 
                                    topXXdatanarr(i,j,120,3)=DOYtoMonth(doy,year);
                                    topXXdatanarr(i,j,120,4)=DOYtoDOM(doy,year);
                                    topXXdatanarr(i,j,120,5)=relhourofmax*3-1.5+tzlist(i,j);
                                    %disp(relhourofmax);disp(relhourofmax*3-1.5+tzlist(i,j));
                                    %Set this day's data =0 so the next-highest value can be found
                                    thisgridptwbtdata(b-(relhourofmax-1):b+8-relhourofmax)=zeros(8,1);
                                    %Sort topXXdatanarr
                                    topXXdatanarr(i,j,:,:)=sortrows(squeeze(topXXdatanarr(i,j,:,:)),-1);
                                    %Make new cutoff val
                                    cutoffval=topXXdatanarr(i,j,120,1); %the new cutoffval
                                end
                            end
                        end
                    end
                end
                fclose('all');clear data;
                
            end
            if var==1
                topXXdatatnarr=topXXdatanarr;save(strcat(curDir,'narrarrays'),'topXXdatatnarr','-append');
            elseif var==2
                topXXdatawbtnarr=topXXdatanarr;save(strcat(curDir,'narrarrays'),'topXXdatawbtnarr','-append');
            elseif var==3
                topXXdataqnarr=topXXdatanarr;save(strcat(curDir,'narrarrays'),'topXXdataqnarr','-append');
            end
        end

        if makeotheradjustments==1
            %If hours are <0 (because of local-UTC adjustment), add 24 and decrease day by 1
            for i=1:277
                for j=1:349
                    if narrlsmask(i,j)==1 && tzlist(i,j)~=0
                        for row=1:120
                            if topXXdatanarr(i,j,row,5)<0
                                topXXdatanarr(i,j,row,5)=topXXdatanarr(i,j,row,5)+24;
                                topXXdatanarr(i,j,row,4)=topXXdatanarr(i,j,row,4)-1;
                                if topXXdatanarr(i,j,row,4)==0
                                    topXXdatanarr(i,j,row,3)=topXXdatanarr(i,j,row,3)-1;
                                    relmon=topXXdatanarr(i,j,row,3)-monthiwf+1;
                                    if relmon<4 %outside range of months -- %set it equal to the previous row so it'll be eliminated
                                        if row~=1
                                            topXXdatanarr(i,j,row,2)=topXXdatanarr(i,j,row-1,2);
                                            topXXdatanarr(i,j,row,3)=topXXdatanarr(i,j,row-1,3); 
                                            topXXdatanarr(i,j,row,4)=topXXdatanarr(i,j,row-1,4);
                                        else
                                            topXXdatanarr(i,j,row,2)=topXXdatanarr(i,j,row+1,2);
                                            topXXdatanarr(i,j,row,3)=topXXdatanarr(i,j,row+1,3); 
                                            topXXdatanarr(i,j,row,4)=topXXdatanarr(i,j,row+1,4);
                                        end
                                    else
                                        topXXdatanarr(i,j,row,4)=monthlengthsdays(relmon);
                                    end
                                end
                            end
                        end
                    end
                end
            end

            %Now that lists are complete, go through and eliminate entries that, because of local-UTC time effects,
                %are actually on the same day
            %Runtime: 2 min
            temp=topXXdatanarr;
            for i=1:277
                for j=1:349
                    if narrlsmask(i,j)==1 && tzlist(i,j)~=0
                        subsetarr=squeeze(topXXdatanarr(i,j,:,2:4)); %year,month,day only (so the function 'unique' can be used)
                        [newsubsetarr,uniquerows]=unique(subsetarr,'rows');
                        uniquerows=sort(uniquerows);
                        uniquerowsmatrix=[uniquerows uniquerows uniquerows uniquerows uniquerows uniquerows uniquerows];
                        %temp=squeeze(topXXdatatnarr(i,j,:,:));%temp=temp(uniquerowsmatrix);
                        newrow=0;
                        for row=1:120
                            if checkifthingsareelementsofvector(uniquerows,row)
                                newrow=newrow+1;
                                temp(i,j,newrow,:)=topXXdatanarr(i,j,row,:);
                            end
                        end
                    end
                end
            end
            topXXdatanarr=temp;

            %Cut size down to 100x5
            newtopXXdatanarr=zeros(277,349,100,5);
            for i=1:277
                for j=1:349
                    if narrlsmask(i,j)==1 && tzlist(i,j)~=0
                        temp=topXXdatanarr(i,j,1:100,:);
                        newtopXXdatanarr(i,j,:,:)=temp;
                    else
                        newtopXXdatanarr(i,j,:,:)=zeros(1,1,100,5);
                    end
                end
            end
            topXXdatanarr=newtopXXdatanarr;

            if var==1
                topXXdatatnarr=topXXdatanarr;save(strcat(curDir,'narrarrays'),'topXXdatatnarr','-append');
            elseif var==2
                topXXdatawbtnarr=topXXdatanarr;save(strcat(curDir,'narrarrays'),'topXXdatawbtnarr','-append');
            elseif var==3
                topXXdataqnarr=topXXdatanarr;save(strcat(curDir,'narrarrays'),'topXXdataqnarr','-append');
            end
        end
    end
end
    

%Some troubleshooting: get the distribution of hours of topXXbystn occurrences for each year,
    %with the aim of identifying (and then correcting) years whose finaldatat and stndatat arrays somehow got misaligned
    %with reality
%Note: just because a station is flagged doesn't automatically mean the offending data should be deleted -- check
    %topXXtbystn to be sure, since it could just be an odd obs
if topXXhourdistn==1
    yearflagged={};p25hour={};p50hour={};p75hour={};
    for stn=1:maxnumstns
    %for stn=97:97
        fprintf('In main part of topXXhourdistn loop, stn # is %d\n',stn);
        for year=1:35;hoursdistn{year}=NaN;end
        yearc=zeros(35,1);
        for row=1:size(topXXtbystn{stn},1)
            thishour=topXXtbystn{stn}(row,5);
            thisyearrel=topXXtbystn{stn}(row,2)-yeariwf+1;
            yearc(thisyearrel)=yearc(thisyearrel)+1;
            hoursdistn{thisyearrel}(yearc(thisyearrel))=thishour;
        end
        for year=1:35
            if min(hoursdistn{year})>=8 && max(hoursdistn{year})<=20 %normal midday situation
                p25hour{stn}(year)=quantile(hoursdistn{year},0.25);
                p50hour{stn}(year)=quantile(hoursdistn{year},0.5);
                p75hour{stn}(year)=quantile(hoursdistn{year},0.75);
            else %a bunch of (probably messed-up) hours fairly close to midnight
                temp=hoursdistn{year}<12;temp2=hoursdistn{year};temp2(temp)=temp2(temp)+24;
                hoursdistn{year}=temp2;
                p25hour{stn}(year)=quantile(hoursdistn{year},0.25);
                p50hour{stn}(year)=quantile(hoursdistn{year},0.5);
                p75hour{stn}(year)=quantile(hoursdistn{year},0.75);
                if p25hour{stn}(year)>24;p25hour{stn}(year)=p25hour{stn}(year)-24;end
                if p50hour{stn}(year)>24;p50hour{stn}(year)=p50hour{stn}(year)-24;end
                if p75hour{stn}(year)>24;p75hour{stn}(year)=p75hour{stn}(year)-24;end
                if year>1
                    if p25hour{stn}(year)==24 && p25hour{stn}(year-1)==24;p25hour{stn}(year)=NaN;end
                    if p50hour{stn}(year)==24 && p50hour{stn}(year-1)==24;p50hour{stn}(year)=NaN;end
                    if p75hour{stn}(year)==24 && p75hour{stn}(year-1)==24;p75hour{stn}(year)=NaN;end
                end
            end
        end
        medianallyears=nanmean(p50hour{stn});
        
        %Look for years that differ substantially from the overall median
        for year=1:35
            if abs(p50hour{stn}(year)-medianallyears)>=5
                yearflagged{stn}(year,1)=1;
                yearflagged{stn}(year,2)=round(-(p50hour{stn}(year)-medianallyears)); %adjustment factor proposed (in hours)
            else
                yearflagged{stn}(year,1)=0;
                yearflagged{stn}(year,2)=0;
            end
        end
        if max(yearflagged{stn}(:,2))>0
            stnflagged(stn)=1;
        else
            stnflagged(stn)=0;
        end
        %stnflagged can now easily be plotted to see which stations are the (potentially) problematic ones
    end
    %Make quick troubleshooting plot
    %figure(figc);clf;
    %desstn=97;
    %plot(p25hour{desstn});hold on;plot(p50hour{desstn},'g');plot(p75hour{desstn},'r');
    
    %Now, use adjustments to modify finaldatat (and then rerun compiledataarrays)
    %A positive adjustment comes from the need to e.g. turn what was recorded as 3 AM into what it should be, 12 PM, and
    %it is accomplished by shifting the window of data comprising finaldatat to the left
        %Of course a negative adjustment is just the sign-flipped version of this
    %Because no data is saved for months outside the May-Oct period, any adjustment results in a few hours at the very beginning
    %or end of finaldatat becoming NaN 
    for stn=1:maxnumstns
    %for stn=97:97
        fprintf('In final (adjustment) part of topXXhourdistn loop, stn # is %d\n',stn);
        for year=1:35
            adjthisstnyear=yearflagged{stn}(year,2);
            if adjthisstnyear>0
                finaldatat{year,stn}(adjthisstnyear+1:4416)=finaldatat{year,stn}(1:4416-adjthisstnyear);
                finaldatat{year,stn}(1:adjthisstnyear)=NaN;
                finaldatadewpt{year,stn}(adjthisstnyear+1:4416)=finaldatadewpt{year,stn}(1:4416-adjthisstnyear);
                finaldatadewpt{year,stn}(1:adjthisstnyear)=NaN;
            elseif adjthisstnyear<0
                finaldatat{year,stn}(1:4416+adjthisstnyear)=finaldatat{year,stn}(-adjthisstnyear+1:4416);
                finaldatat{year,stn}(4416+adjthisstnyear+1:4416)=NaN;
                finaldatadewpt{year,stn}(1:4416+adjthisstnyear)=finaldatadewpt{year,stn}(-adjthisstnyear+1:4416);
                finaldatadewpt{year,stn}(4416+adjthisstnyear+1:4416)=NaN;
            end %if adjthisstnyear==0, do nothing
        end
    end
    %Compute q from Td -- trivial now that there is a dedicated function for this purpose
    for year=1:yeariwl-yeariwf+1
        for stn=1:maxnumstns
            finaldataq{year,stn}=calcqfromTd(finaldatadewpt{year,stn});
        end
    end
    %New method -- to eliminate uncertainty about finaldatawbt's origins, compute it anew from T and q
    for year=1:yeariwl-yeariwf+1
        for stn=1:maxnumstns
            finaldatawbt{year,stn}=calcwbtfromTandshum(finaldatat{year,stn},finaldataq{year,stn}/1000,1);
        end
    end
    save(strcat(curDir,'temparrayholder220aug31'),'newstnNumList','newstnNumListnames','newstnNumListlats',...
        'newstnNumListlons','finaldatat','finaldatadewpt','finaldatawbt','finaldataq','-append');
    %NOW, HAVE TO RERUN COMPILEDATAARRAYS & CREATEMAXTWBTARRAYS
end


%The final piece of troubleshooting: go through each topXXbystn array with a fine-toothed comb,
%pulling out the station, year, and month of entries that are on >=3 consecutive days and have the same value
    %--> these are suspicious because they likely result from missing data that was subsequently extrapolated
    %however, each individual case must be plotted to be sure, before that stn-year combo is eliminated in compiledataarrays
    %(or, if this tips the balance so that too many years are missing for the station, eliminate it entirely in removebadstns
%This loop is not intended to be 100% comprehensive, but rather to point out suspicious stations/years for further investigation
%Visual inspection (with years heuristically chosen) checked for overall quality, this loop is more for ensuring that top-XX days,
    %in particular, are not affected by data-quality issues
if findconsecidenticaltopXXdays==1
    suspentriesc=0;
    for stn=1:maxnumstns
        topXXttouse=sortrows(topXXtbystn{stn},[-1 2 3 4]);
        stnsuspiciousentries{stn}=0;
        stnsuspiciousentriesc=0;
        for row=3:numdates
            if topXXttouse(row,1)==topXXttouse(row-1,1) && topXXttouse(row,1)==topXXttouse(row-2,1) &&...
                    topXXttouse(row,2)==topXXttouse(row-1,2) && topXXttouse(row,2)==topXXttouse(row-2,2) &&...
                    topXXttouse(row,3)==topXXttouse(row-1,3) && topXXttouse(row,3)==topXXttouse(row-2,3) &&...
                    topXXttouse(row,4)==topXXttouse(row-1,4)+1 && topXXttouse(row,4)==topXXttouse(row-2,4)+2
                stnsuspiciousentriesc=stnsuspiciousentriesc+1;
                stnsuspiciousentries{stn}(stnsuspiciousentriesc,1)=topXXttouse(row,1);
                stnsuspiciousentries{stn}(stnsuspiciousentriesc,2)=topXXttouse(row,2);
                stnsuspiciousentries{stn}(stnsuspiciousentriesc,3)=topXXttouse(row,3);
                stnsuspiciousentries{stn}(stnsuspiciousentriesc,4)=topXXttouse(row,4);
            end
        end
    end
    for i=1:190;suspentriesc(i)=size(stnsuspiciousentries{i},1);end
    %plot(suspentriesc);
    %Then, for stations with >=4 or 5, plot finaldatat{year,stn} to visually inspect
end


%For each station and NARR gridpt, calculates the number of days represented by the union of 2 out of 3: top XX T, WBT, or q readings
    %score=numdates*2 --> completely *disjoint* i.e. no overlap
    %also converts this score to a percent overlap, which is arguably more intuitive
%Also does this for regions (with both station and NARR data)
if calctwbtorqscores==1
    if strcmp(var1,'wbt') && strcmp(var2,'t')
        wbttscore=zeros(maxnumstns,1);pctoverlapwbtt=zeros(maxnumstns,1);topXXvar1=topXXwbtbystn;topXXvar2=topXXtbystn;
        wbttscorereg=zeros(8,1);pctoverlapwbttreg=zeros(8,1);topXXvar1reg=topXXwbtbyregionsorted;topXXvar2reg=topXXtbyregionsorted;
        wbttscorenarr=zeros(277,349);pctoverlapwbttnarr=zeros(277,349);topXXvar1narr=topXXwbtbynarr;topXXvar2narr=topXXtbynarr;
        wbttscoreregnarr=zeros(8,1);pctoverlapwbttregnarr=zeros(8,1);topXXvar1regnarr=topXXwbtdatesbyregionnarr;topXXvar2regnarr=topXXtdatesbyregionnarr;
    elseif strcmp(var1,'wbt') && strcmp(var2,'q')
        wbtqscore=zeros(maxnumstns,1);pctoverlapwbtq=zeros(maxnumstns,1);topXXvar1=topXXwbtbystn;topXXvar2=topXXqbystn;
        wbtqscorereg=zeros(8,1);pctoverlapwbtqreg=zeros(8,1);topXXvar1reg=topXXwbtbyregionsorted;topXXvar2reg=topXXqbyregionsorted;
        wbtqscorenarr=zeros(277,349);pctoverlapwbtqnarr=zeros(277,349);topXXvar1narr=topXXwbtbynarr;topXXvar2narr=topXXqbynarr;
        wbtqscoreregnarr=zeros(8,1);pctoverlapwbtqregnarr=zeros(8,1);topXXvar1regnarr=topXXwbtdatesbyregionnarr;topXXvar2regnarr=topXXqdatesbyregionnarr;
    elseif strcmp(var1,'t') && strcmp(var2,'q')
        tqscore=zeros(maxnumstns,1);pctoverlaptq=zeros(maxnumstns,1);topXXvar1=topXXtbystn;topXXvar2=topXXqbystn;
        tqscorereg=zeros(8,1);pctoverlaptqreg=zeros(8,1);topXXvar1reg=topXXtbyregionsorted;topXXvar2reg=topXXqbyregionsorted;
    end
    %Station data -- every station
    for stnindex=1:maxnumstns
        numdayswithmatches=0;
        for tdaysc=1:numdates
            topXXvar1dayyear=topXXvar1{stnindex}(tdaysc,2);
            topXXvar1daymonth=topXXvar1{stnindex}(tdaysc,3);
            topXXvar1dayday=topXXvar1{stnindex}(tdaysc,4);
            topXXvar1daydoy=DatetoDOY(topXXvar1daymonth,topXXvar1dayday,topXXvar1dayyear);

            %Determine whether this day in the variable-1 rankings (+/- leeway) shows up in the variable-2 ones as well 
            thisvar1dayhasamatch=0;
            var2daysc=1;
            while var2daysc<=numdates && thisvar1dayhasamatch==0
                topXXvar2dayyear=topXXvar2{stnindex}(var2daysc,2);
                topXXvar2daymonth=topXXvar2{stnindex}(var2daysc,3);
                topXXvar2dayday=topXXvar2{stnindex}(var2daysc,4);
                topXXvar2daydoy=DatetoDOY(topXXvar2daymonth,topXXvar2dayday,topXXvar2dayyear);
                %if topXXvar2dayyear==topXXvar1dayyear && topXXvar2daymonth==topXXvar1daymonth && topXXvar2dayday==topXXvar1dayday
                if topXXvar2dayyear==topXXvar1dayyear && abs(topXXvar2daydoy-topXXvar1daydoy)<=leeway
                    thisvar1dayhasamatch=1;numdayswithmatches=numdayswithmatches+1;
                else
                    var2daysc=var2daysc+1;
                end
            end
        end
        %numdayswithmatches ranges from 0 (i.e. 0% overlap) to 100 (i.e. 100% overlap)
        if strcmp(var1,'wbt') && strcmp(var2,'t')
            wbttscore(stnindex)=numdates*2-numdayswithmatches;
            pctoverlapwbtt(stnindex)=numdayswithmatches;
        elseif strcmp(var1,'wbt') && strcmp(var2,'q')
            wbtqscore(stnindex)=numdates*2-numdayswithmatches;
            pctoverlapwbtq(stnindex)=numdayswithmatches;
        elseif strcmp(var1,'t') && strcmp(var2,'q')
            tqscore(stnindex)=numdates*2-numdayswithmatches;
            pctoverlaptq(stnindex)=numdayswithmatches;
        end
    end
    %NARR data -- every gridpt
    if donarrdataeverygridpt==1
        for i=1:277
            fprintf('i is %d out of 277\n',i);
            for j=1:349
                if narrlsmask(i,j)==1 && tzlist(i,j)~=0
                    numdayswithmatches=0;
                    for tdaysc=1:numdates
                        topXXvar1dayyear=topXXvar1narr(i,j,tdaysc,2);
                        topXXvar1daymonth=topXXvar1narr(i,j,tdaysc,3);
                        topXXvar1dayday=topXXvar1narr(i,j,tdaysc,4);
                        topXXvar1daydoy=DatetoDOY(topXXvar1daymonth,topXXvar1dayday,topXXvar1dayyear);

                        %Determine whether this day in the variable-1 rankings (+/- leeway) shows up in the variable-2 ones as well 
                        thisvar1dayhasamatch=0;
                        var2daysc=1;
                        while var2daysc<=numdates && thisvar1dayhasamatch==0
                            topXXvar2dayyear=topXXvar2narr(i,j,var2daysc,2);
                            topXXvar2daymonth=topXXvar2narr(i,j,var2daysc,3);
                            topXXvar2dayday=topXXvar2narr(i,j,var2daysc,4);
                            if rem(topXXvar2dayyear,1)==0 %i.e. if there's valid data for this row of this gridpt
                                topXXvar2daydoy=DatetoDOY(topXXvar2daymonth,topXXvar2dayday,topXXvar2dayyear);
                                if topXXvar2dayyear==topXXvar1dayyear && abs(topXXvar2daydoy-topXXvar1daydoy)<=leeway
                                    thisvar1dayhasamatch=1;numdayswithmatches=numdayswithmatches+1;
                                end
                            end
                            var2daysc=var2daysc+1;
                        end
                    end
                    %numdayswithmatches ranges from 0 (i.e. 0% overlap) to 100 (i.e. 100% overlap)
                    if strcmp(var1,'wbt') && strcmp(var2,'t')
                        wbttscorenarr(i,j)=numdates*2-numdayswithmatches;
                        pctoverlapwbttnarr(i,j)=numdayswithmatches;
                    elseif strcmp(var1,'wbt') && strcmp(var2,'q')
                        wbtqscorenarr(i,j)=numdates*2-numdayswithmatches;
                        pctoverlapwbtqnarr(i,j)=numdayswithmatches;
                    elseif strcmp(var1,'t') && strcmp(var2,'q')
                        %tqscorenarr(i,j)=numdates*2-numdayswithmatches;
                        %pctoverlaptqnarr(i,j)=numdayswithmatches;
                    end
                end
            end
        end
    end
    %Exact same loop but for regional hot days
    %Two loops -- loop 1 is for station data, loop 2 is for NARR data
    for region=1:8
        numdayswithmatchesstns=0;numdayswithmatchesnarr=0;if region==3;numdateshere=99;else numdateshere=numdates;end
        for loop=1:2 
            numdayswithmatches=0;
            if loop==1
                var1reg=topXXvar1reg;var2reg=topXXvar2reg;
            else
                var1reg=topXXvar1regnarr;var2reg=topXXvar2regnarr;
            end
            for tdaysc=1:numdateshere
                topXXvar1dayyear=var1reg{region}(tdaysc,1);
                topXXvar1daymonth=var1reg{region}(tdaysc,2);
                topXXvar1dayday=var1reg{region}(tdaysc,3);
                topXXvar1daydoy=DatetoDOY(topXXvar1daymonth,topXXvar1dayday,topXXvar1dayyear);

                %Determine whether this day in the variable-1 rankings (+/- leeway) shows up in the variable-2 ones as well 
                thisvar1dayhasamatch=0;
                var2daysc=1;
                while var2daysc<=numdateshere && thisvar1dayhasamatch==0
                    topXXvar2dayyear=var2reg{region}(var2daysc,1);
                    topXXvar2daymonth=var2reg{region}(var2daysc,2);
                    topXXvar2dayday=var2reg{region}(var2daysc,3);
                    topXXvar2daydoy=DatetoDOY(topXXvar2daymonth,topXXvar2dayday,topXXvar2dayyear);
                    %if topXXvar2dayyear==topXXvar1dayyear && topXXvar2daymonth==topXXvar1daymonth && topXXvar2dayday==topXXvar1dayday
                    if topXXvar2dayyear==topXXvar1dayyear && abs(topXXvar2daydoy-topXXvar1daydoy)<=leeway
                        thisvar1dayhasamatch=1;numdayswithmatches=numdayswithmatches+1;
                    else
                        var2daysc=var2daysc+1;
                    end
                end
            end
            if loop==1;numdayswithmatchesstns=numdayswithmatches;else numdayswithmatchesnarr=numdayswithmatches;end
        end
        %numdayswithmatches ranges from 0 (i.e. 0% overlap) to 100 (i.e. 100% overlap)
        if strcmp(var1,'wbt') && strcmp(var2,'t')
            wbttscorereg(region)=numdates*2-numdayswithmatchesstns;
            pctoverlapwbttreg(region)=numdayswithmatchesstns;
            wbttscoreregnarr(region)=numdates*2-numdayswithmatchesnarr;
            pctoverlapwbttregnarr(region)=numdayswithmatchesnarr;
        elseif strcmp(var1,'wbt') && strcmp(var2,'q')
            wbtqscorereg(region)=numdates*2-numdayswithmatchesstns;
            pctoverlapwbtqreg(region)=numdayswithmatchesstns;
            wbtqscoreregnarr(region)=numdates*2-numdayswithmatchesnarr;
            pctoverlapwbtqregnarr(region)=numdayswithmatchesnarr;
        elseif strcmp(var1,'t') && strcmp(var2,'q')
            tqscorereg(region)=numdates*2-numdayswithmatchesstns;
            pctoverlaptqreg(region)=numdayswithmatchesstns;
        end
    end
    if strcmp(var1,'wbt') && strcmp(var2,'t')
        save(strcat(curDir,'essentialarrays'),'wbttscore','pctoverlapwbtt','wbttscorereg','pctoverlapwbttreg',...
            'wbttscorenarr','pctoverlapwbttnarr','wbttscoreregnarr','pctoverlapwbttregnarr','-append');
    end
    if strcmp(var1,'wbt') && strcmp(var2,'q')
        save(strcat(curDir,'essentialarrays'),'wbtqscore','pctoverlapwbtq','wbtqscorereg','pctoverlapwbtqreg',...
            'wbtqscorenarr','pctoverlapwbtqnarr','wbtqscoreregnarr','pctoverlapwbtqregnarr','-append');
    end
    if strcmp(var1,'t') && strcmp(var2,'q')
        save(strcat(curDir,'essentialarrays'),'tqscore','pctoverlaptq','tqscorereg','pctoverlaptqreg','-append');
    end
end


%An attempt to separate and quantify the effects of T and q on top-XX WBT, to see e.g. if which one is dominant varies by region or temporal window
%Original idea:
%Each station has one tripartite representing the net effect of T and q on its WBT, as well as the nonlinear term
%These can be called 'approximate linearized contributions'
%New idea:
%This loop is just used to calculate correspt and correspq, with the real work of comparison
%being done down in the tqanomsextremewbt loop
if determinetandqeffectsonwbt==1
    correspt={};correspq={};corresptforreghws={};correspqforreghws={};
    for stn=1:maxnumstns
        %JJA-mean daily maxes
        thisstnmeanjjat(stn)=nanmean(seasonalmeantbystn(stn,:));
        thisstnmeanjjaq(stn)=nanmean(seasonalmeanqbystn(stn,:));
        [~,~,~,thisstntz]=stationinfofromnumber(newstnNumList(stn));
        
        %Get the T and q values corresponding to the hour & date of the top-XX WBT values
        for row=1:numdates
        %for row=16:16
            thisyear=topXXwbtbystn{stn}(row,2);thismonth=topXXwbtbystn{stn}(row,3);
            thisday=topXXwbtbystn{stn}(row,4);thishour=topXXwbtbystn{stn}(row,5);
            thismonlen=monthlengthsdays(thismonth-monthiwf+1)*24; %in hours
            %thisdoy=DatetoDOY(thismonth,thisday,thisyear);
            actualwbt{stn}(row)=topXXwbtbystn{stn}(row,1);
            if rem(thisyear,4)==0;leapyear=1;else leapyear=0;end
            if ((thisday-1)*24+thishour+thisstntz+1)>thismonlen && thismonth~=monthiwl %have to go to next month
                %disp('line 753');disp(((thisday-1)*24+thishour+thisstntz+1));disp(thismonlen);disp(thisyear);disp(thismonth);disp(thisday);
                correspt{stn}(row)=stndatat{stn,thisyear-yeariwf+1,thismonth-monthiwf+2}((thisday-1)*24+thishour+thisstntz+1-thismonlen);
                correspq{stn}(row)=stndataq{stn,thisyear-yeariwf+1,thismonth-monthiwf+2}((thisday-1)*24+thishour+thisstntz+1-thismonlen);
            elseif thismonth~=monthiwl
                %disp('line 757');disp(((thisday-1)*24+thishour+thisstntz+1));disp(thismonlen);disp(thisyear);disp(thismonth);disp(thisday);
                correspt{stn}(row)=stndatat{stn,thisyear-yeariwf+1,thismonth-monthiwf+1}((thisday-1)*24+thishour+thisstntz+1);
                correspq{stn}(row)=stndataq{stn,thisyear-yeariwf+1,thismonth-monthiwf+1}((thisday-1)*24+thishour+thisstntz+1);
            else
                correspt{stn}(row)=NaN;
                correspq{stn}(row)=NaN;
            end
        end
        
        %For each top-XX WBT date, calculate the WBT with 1. observed T and climo q, and 2. observed q and climo T
        for row=1:numdates
            wbtobstclimoq{stn}(row)=calcwbtfromTandshum(correspt{stn}(row),thisstnmeanjjaq(stn)/1000,1);
            wbtobsqclimot{stn}(row)=calcwbtfromTandshum(thisstnmeanjjat(stn),correspq{stn}(row)/1000,1);
        end
    end
    %For regional heat waves, the procedure implemented here is:
    %1. Take the regional top-XX WBT days
    %2. Find the hour of WBTmax at each stn for each one (even if that day isn't a hot day at that stn)
    %3. Get the T & q standardized anomaly for that hour
    %4. Average the T & q stan anoms across all stns in a region
    %5. Then, later, can separate heat waves on this basis
    %A principal way this differs from the correspt/correspq calculated just above in that the stan anoms here
    %are calculated irrespective of whether that stn is having a hot day itself,
    %whereas above the hot days are with respect to each stn individually --> this mean that here
    %the stan anoms are less across the board by a considerable margin than they are in the above loop
    if numdates==100;computereghws=1;end
    if computereghws==1
        for region=1:8
            %Get the T and q values (at stations in this region) corresponding to the
            %hour & date of this region's top-XX WBT values
            for row=1:numdates
                thisyear=topXXwbtbyregionsorted{region}(row,1);thismonth=topXXwbtbyregionsorted{region}(row,2);
                thisday=topXXwbtbyregionsorted{region}(row,3);
                thismonlen=monthlengthsdays(thismonth-monthiwf+1)*24; %in hours
                %thisdoy=DatetoDOY(thismonth,thisday,thisyear);
                for i=1:size(stnordinateseachregion{region},2)
                    stn=stnordinateseachregion{region}(i);
                    [~,~,~,thisstntz]=stationinfofromnumber(newstnNumList(stn));
                    stnwbtthisday=stndatawbt{stn,thisyear-yeariwf+1,thismonth-monthiwf+1}(thisday*24-23:thisday*24);
                    [~,hourofmaxwbt]=max(stnwbtthisday);
                    hourofmaxwbt=hourofmaxwbt-thisstntz;
                    if rem(thisyear,4)==0;leapyear=1;else leapyear=0;end
                    if ((thisday-1)*24+hourofmaxwbt+thisstntz)>thismonlen %have to go to next month
                        %disp('line 753');disp(((thisday-1)*24+thishour+thisstntz+1));disp(thismonlen);disp(thisyear);disp(thismonth);disp(thisday);
                        corresptforreghws{stn}(row)=stndatat{stn,thisyear-yeariwf+1,thismonth-monthiwf+2}((thisday-1)*24+hourofmaxwbt+thisstntz-thismonlen);
                        correspqforreghws{stn}(row)=stndataq{stn,thisyear-yeariwf+1,thismonth-monthiwf+2}((thisday-1)*24+hourofmaxwbt+thisstntz-thismonlen);
                        correspmons{stn}(row)=thismonth-monthiwf+2;corresphours{stn}(row)=hourofmaxwbt+thisstntz;
                    else 
                        %disp('line 757');disp(((thisday-1)*24+thishour+thisstntz+1));disp(thismonlen);disp(thisyear);disp(thismonth);disp(thisday);
                        corresptforreghws{stn}(row)=stndatat{stn,thisyear-yeariwf+1,thismonth-monthiwf+1}((thisday-1)*24+hourofmaxwbt+thisstntz);
                        correspqforreghws{stn}(row)=stndataq{stn,thisyear-yeariwf+1,thismonth-monthiwf+1}((thisday-1)*24+hourofmaxwbt+thisstntz);
                        correspmons{stn}(row)=thismonth-monthiwf+1;corresphours{stn}(row)=hourofmaxwbt+thisstntz;
                    end
                    %Daily anomalies
                    corresptforreghwsanom{stn}(row)=corresptforreghws{stn}(row)-thisstnmeanjjat(stn);
                    correspqforreghwsanom{stn}(row)=correspqforreghws{stn}(row)-thisstnmeanjjaq(stn);
                end
            end
        end
        %Building off the previous loop, calculate anomalies & standardized anomalies of T & q at each stn
        %during these regional top-XX WBT days, and the regional avg as well
        for region=1:8
            anomavgtbyreghotdayandregion{region}=zeros(numdates,1);
            anomavgqbyreghotdayandregion{region}=zeros(numdates,1);
            stananomavgtbyreghotdayandregion{region}=zeros(numdates,1);
            stananomavgqbyreghotdayandregion{region}=zeros(numdates,1);
        end
        validctbyreg=zeros(8,1);validcqbyreg=zeros(8,1);
        for stn=1:maxnumstns
            thisregion=ncaregionnum{stn};
            for row=1:numdates
                stdoftthisstnandhour=stdevthishourofdayandmonth{1}(stn,correspmons{stn}(row),corresphours{stn}(row));
                corresptforreghwsanomstan{stn}(row)=corresptforreghwsanom{stn}(row)./stdoftthisstnandhour;
                if ~isnan(corresptforreghwsanomstan{stn}(row))
                    anomavgtbyreghotdayandregion{thisregion}(row)=...
                    anomavgtbyreghotdayandregion{thisregion}(row)+corresptforreghwsanom{stn}(row);
                    stananomavgtbyreghotdayandregion{thisregion}(row)=...
                    stananomavgtbyreghotdayandregion{thisregion}(row)+corresptforreghwsanomstan{stn}(row);
                    validctbyreg(thisregion)=validctbyreg(thisregion)+1;
                end
                stdofqthisstnandhour=stdevthishourofdayandmonth{3}(stn,correspmons{stn}(row),corresphours{stn}(row));
                correspqforreghwsanomstan{stn}(row)=correspqforreghwsanom{stn}(row)./stdofqthisstnandhour;
                if ~isnan(correspqforreghwsanomstan{stn}(row))
                    anomavgqbyreghotdayandregion{thisregion}(row)=...
                    anomavgqbyreghotdayandregion{thisregion}(row)+correspqforreghwsanom{stn}(row);
                    stananomavgqbyreghotdayandregion{thisregion}(row)=...
                    stananomavgqbyreghotdayandregion{thisregion}(row)+correspqforreghwsanomstan{stn}(row);
                    validcqbyreg(thisregion)=validcqbyreg(thisregion)+1;
                end
            end
        end
        %Average these stan anoms across stns to produce regional averages
        for region=1:8
            anomavgtbyreghotdayandregion{region}=anomavgtbyreghotdayandregion{region}./regstnc(region);
            anomavgqbyreghotdayandregion{region}=anomavgqbyreghotdayandregion{region}./regstnc(region);
            stananomavgtbyreghotdayandregion{region}=stananomavgtbyreghotdayandregion{region}./regstnc(region);
            stananomavgqbyreghotdayandregion{region}=stananomavgqbyreghotdayandregion{region}./regstnc(region);
        end
    
        %Separate regional hot days into "relatively more T-dominated" and "relatively more q-dominated" on this basis
        %Filter is 1 for the former case, 0 for the latter case
        regstnc=zeros(8,1);regionavgstananomt=zeros(8,1);regionavgstananomq=zeros(8,1);
        for region=1:8
            regionallstananomt{region}=0;regionallstananomq{region}=0;
            for i=1:size(stnordinateseachregion{region},2)
                stn=stnordinateseachregion{region}(i);regstnc(region)=regstnc(region)+1;
                regionavgstananomt(region)=regionavgstananomt(region)+nanmean(corresptforreghwsanomstan{stn});
                regionallstananomt{region}(regstnc(region))=nanmean(corresptforreghwsanomstan{stn});
                regionavgstananomq(region)=regionavgstananomq(region)+nanmean(correspqforreghwsanomstan{stn});
                regionallstananomq{region}(regstnc(region))=nanmean(correspqforreghwsanomstan{stn});
            end
            regionavgstananomt(region)=regionavgstananomt(region)/regstnc(region);
            regionavgstananomq(region)=regionavgstananomq(region)/regstnc(region);
            regionalldiffsstananomtq{region}=regionallstananomt{region}-regionallstananomq{region};
            p80regstananomtqdiff{region}=quantile(regionalldiffsstananomtq{region},0.8);
            p20regstananomtqdiff{region}=quantile(regionalldiffsstananomtq{region},0.2);
            regionavgstananomtqdiff(region)=regionavgstananomt(region)-regionavgstananomq(region);
            %Because this uses averages rather than medians, the two sets of hot days are not exactly equal,
            %but are close (there are 42-58 members in each half)
            %Similarly, the quartiles have a range of sizes as well
            %Recall that the rows here can be traced back to the rows of topXXwbtbyregionsorted
            for row=1:numdates
                thishotdaystananomtqdiff=...
                    stananomavgtbyreghotdayandregion{region}(row)-stananomavgqbyreghotdayandregion{region}(row);
                if thishotdaystananomtqdiff>regionavgstananomtqdiff(region)
                    topXXwbtbyregionfilter{region}(row)=1;
                    if thishotdaystananomtqdiff>p80regstananomtqdiff{region}
                        topXXwbtbyregionfilterqrt{region}(row)=1; %top quartile only
                    else
                        topXXwbtbyregionfilterqrt{region}(row)=0; %middle half
                    end
                else
                    topXXwbtbyregionfilter{region}(row)=0;
                    if thishotdaystananomtqdiff<p20regstananomtqdiff{region}
                        topXXwbtbyregionfilterqrt{region}(row)=-1; %bottom quartile only
                    else
                        topXXwbtbyregionfilterqrt{region}(row)=0; %middle half
                    end
                end
            end
        end
    end
    
    %Supplementary explanatory/troubleshooting figures for a sample station
    %The black line should roughly parallel the blue, and the wiggles in the black line represent the nonlinearities of the
        %full WBT equation -- dips correspond to combinations of high T and only moderate q (because WBT increases faster
        %with respect to q than to T)
    if maketroubleshootingfig==1
        figure(figc);clf;figc=figc+1;stn=189;
        plot(actualwbt{stn});hold on;
        plot(wbtobstclimoq{stn},'g');plot(wbtobsqclimot{stn},'r');
        plot((wbtobstclimoq{stn}+wbtobsqclimot{stn})/2,'k');
        plot(correspt{stn},'m');plot(correspq{stn},'color',colors('orange'));
    end
    
    for stn=1:maxnumstns
        redbluediff=wbtobsqclimot{stn}-actualwbt{stn};
        greenbluediff=wbtobstclimoq{stn}-actualwbt{stn};
        totalredandgreendiff=redbluediff+greenbluediff;
        %Compute differences
        qtermbystn(stn)=mean(redbluediff);
        Ttermbystn(stn)=mean(greenbluediff);
        nonlineartermbystn(stn)=mean(actualwbt{stn}-((wbtobsqclimot{stn}+wbtobstclimoq{stn})/2));
        %whichever of the q and T terms is larger (more positive or less negative) plays a bigger role in causing extreme WBT,
            %relative to climatological conditions
        %if uncertainties, make troubleshooting figure of this station
    end
    %Explanatory:
    %Note that wbtobstclimoq and wbtobsqclimot are just theoretical quantities that don't really have physical meaning
    %Relative contributions are estimated using the difference from the red or green lines to the blue
    %Note also that red (obsqclimot) is the larger contributor in many cases
    %Use Newark, NJ as example
    if makeexplanatoryfig==1
        stn=94;
        curpart=1;highqualityfiguresetup;
        subplot(2,1,1);
        plot(actualwbt{stn},'linewidth',2);hold on;
        plot(wbtobsqclimot{stn},'r','linewidth',2);plot(wbtobstclimoq{stn},'g','linewidth',2);
        legend({'Obs q, Climo T';'Obs T, Climo q';'Actual'},'Location','Northeast');
        set(gca,'fontsize',12,'fontweight','bold','fontname','arial');
        ylabel('WBT (deg C)','fontsize',14,'fontweight','bold','fontname','arial');
        title('Actual WBT Compared to Theoretical Obtained by Fixing T or q',...
            'fontsize',18,'fontweight','bold','fontname','arial');
        subplot(2,1,2);
        plot(redcontrib,'r','linewidth',2);hold on;plot(greencontrib,'g','linewidth',2);
        legend({'q';'T'},'Location','Northeast');
        set(gca,'fontsize',12,'fontweight','bold','fontname','arial');
        xlabel(sprintf('Ordinate of Top-%d Observation',numdates),'fontsize',14,'fontweight','bold','fontname','arial');
        ylabel('Percent Contribution','fontsize',14,'fontweight','bold','fontname','arial');
        title('Estimated Percent Contribution of T and q to Observed WBT',...
            'fontsize',18,'fontweight','bold','fontname','arial');
        curpart=2;figloc=curDir;figname=strcat('twbtpercentcontrib');
        highqualityfiguresetup;
    end
    if numdates==100;save(strcat(curDir,'extraarrays'),'correspt','correspq','topXXwbtbyregionfilter',...
        'topXXwbtbyregionfilterqrt','regstnc','-append');end
    if numdates==1000;corresptnext900=correspt;correspqnext900=correspq;
        save(strcat(curDir,'extraarrays'),'corresptnext900','correspqnext900','-append');end
end


%Get traces of T, WBT, and q anoms surrounding (and centered on) regional top-XX WBT days
%Traces are saved from 12 AM on Day -3 to 12 AM on Day 4, i.e. centering on Day 0 (the day of the extreme WBT)
if topXXtraces==1
    tanomthistrace={};wbtanomthistrace={};qanomthistrace={};
    tanomthistracebymon={};
    for region=1:8
        regarr=topXXwbtbyregionsorted{region}(1:numdates,:);
        %Get the wbt, t, and q traces surrounding each day
        %Also ensure that no top-XX WBT day is found within any other trace
        numdaystaken=1;vecdaystaken=zeros(1,2);
        stnords=stnordinateseachregion{region};
        
        for stnc=1:size(stnords,2)
            stn=stnords(stnc);
            [~,~,~,thisstntz]=stationinfofromnumber(newstnNumList(stn));
            for row=1:numdates
                thisyr=regarr(row,1);thismn=regarr(row,2);thisdy=regarr(row,3);
                thisyrrel=thisyr-yeariwf+1;thismnrel=thismn-monthiwf+1;thismnlen=monthlengthsdays(thismnrel)*24;
                thisdoy=DatetoDOY(thismn,thisdy,thisyr);
                doyspanstart=thisdoy-3;doyspanstop=thisdoy+3;
 
                if row==1
                    if (thisdy-4)*24+thisstntz+1<=0 %day is close to start of month
                        if thismn==monthiwf %nothing we can do
                            tanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                            wbtanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                            qanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                        else
                            numdaysinprevmon=7-thisdy;prevmonlen=monthlengthsdays(thismnrel-1);
                            for j=1:3
                                if j==1;stndata=stndatat;elseif j==2;stndata=stndatawbt;elseif j==3;stndata=stndataq;end
                                if numdaysinprevmon>0 %14-day period spans two months
                                    datathistracepart1=stndata{stn,thisyrrel,thismnrel-1}(prevmonlen*24-numdaysinprevmon*24+1+thisstntz+1:prevmonlen*24);
                                    datathistracepart2=stndata{stn,thisyrrel,thismnrel}(1:thisdy*24+thisstntz+1);
                                    temp=squeeze(avgthishourofdayandmonth{j}(stn,thismnrel-1,:));
                                    avgthistracepart1=[temp;temp;temp;temp;temp;temp;temp];avgthistracepart1=avgthistracepart1(1:size(datathistracepart1,1));
                                    temp=squeeze(avgthishourofdayandmonth{j}(stn,thismnrel,:));
                                    avgthistracepart2=[temp;temp;temp;temp;temp;temp;temp];avgthistracepart2=avgthistracepart2(1:size(datathistracepart2,1));
                                    avgthistrace=[avgthistracepart1;avgthistracepart2];
                                    anomthistrace{region}(stnc,row,:)=[datathistracepart1-avgthistracepart1;datathistracepart2-avgthistracepart2];
                                else %7-day period is contained entirely within one month
                                    datathistrace{region}(stnc,row,1:168)=stndata{stn,thisyrrel,thismnrel}((thisdy-4)*24+thisstntz+1:(thisdy+3)*24+thisstntz);
                                    temp=squeeze(avgthishourofdayandmonth{j}(stn,thismnrel,:));
                                    avgthistrace=[temp;temp;temp;temp;temp;temp;temp];
                                    anomthistrace{region}(stnc,row,:)=[squeeze(datathistrace{region}(stnc,row,1:168))-avgthistrace];
                                    if max(anomthistrace{region}(stnc,row,:))==0;anomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);end
                                end
                                if max(anomthistrace{region}(stnc,row,:))==0;anomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);end
                                %if region==7 && stnc==15;disp(max(anomthistrace{region}(stnc,row,:)));disp('section 1');fprintf('row: %d\n',row);end
                                if j==1
                                    tanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%tdatathistrace{region}(stnc,row,:)=datathistrace;
                                elseif j==2
                                    wbtanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%wbtdatathistrace{region}(stnc,row,:)=datathistrace;
                                elseif j==3
                                    qanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%qdatathistrace{region}(stnc,row,:)=datathistrace;
                                end
                            end
                            if stnc==size(stnords,2)
                                numdaystaken=numdaystaken+1;
                                vecdaystaken(numdaystaken*7-6:numdaystaken*7,1)=(doyspanstart:doyspanstop)';
                                vecdaystaken(numdaystaken*7-6:numdaystaken*7,2)=thisyr.*ones(7,1);
                            end
                        end
                    elseif (thisdy+3)*24+thisstntz>thismnlen %day is close to end of month
                        if thismn==monthiwl %nothing we can do
                            tanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                            wbtanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                            qanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                        else
                            numdaysinthismon=thismnlen/24-thisdy+1;numdaysinnextmon=7-numdaysinthismon;
                            for j=1:3
                                if j==1;stndata=stndatat;elseif j==2;stndata=stndatawbt;elseif j==3;stndata=stndataq;end
                                if numdaysinnextmon>0
                                    datathistracepart1=stndata{stn,thisyrrel,thismnrel}(thismnlen-numdaysinthismon*24+thisstntz+1:thismnlen);
                                    datathistracepart2=stndata{stn,thisyrrel,thismnrel+1}(1:numdaysinnextmon*24+thisstntz);
                                    temp=squeeze(avgthishourofdayandmonth{j}(stn,thismnrel,:));
                                    avgthistracepart1=[temp;temp;temp;temp;temp;temp;temp];avgthistracepart1=avgthistracepart1(1:size(datathistracepart1,1));
                                    temp=squeeze(avgthishourofdayandmonth{j}(stn,thismnrel+1,:));
                                    avgthistracepart2=[temp;temp;temp;temp;temp;temp;temp];avgthistracepart2=avgthistracepart2(1:size(datathistracepart2,1));
                                    avgthistrace=[avgthistracepart1;avgthistracepart2];
                                    anomthistrace{region}(stnc,row,:)=[datathistracepart1-avgthistracepart1;datathistracepart2-avgthistracepart2];
                                else %7-day period is contained entirely within one month
                                    datathistrace{region}(stnc,row,1:168)=stndata{stn,thisyrrel,thismnrel}((thisdy-4)*24+thisstntz+1:(thisdy+3)*24+thisstntz);
                                    temp=squeeze(avgthishourofdayandmonth{j}(stn,thismnrel,:));
                                    avgthistrace=[temp;temp;temp;temp;temp;temp;temp];
                                    anomthistrace{region}(stnc,row,:)=[squeeze(datathistrace{region}(stnc,row,1:168))-avgthistrace];
                                    if max(anomthistrace{region}(stnc,row,:))==0;anomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);end
                                end
                                if max(anomthistrace{region}(stnc,row,:))==0;anomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);end
                                %if region==7 && stnc==15;disp(max(anomthistrace{region}(stnc,row,:)));disp('section 2');fprintf('row: %d\n',row);end
                                if j==1
                                    tanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%tdatathistrace{region}(stnc,row,:)=datathistrace;
                                elseif j==2
                                    wbtanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%wbtdatathistrace{region}(stnc,row,:)=datathistrace;
                                elseif j==3
                                    qanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%qdatathistrace{region}(stnc,row,:)=datathistrace;
                                end
                            end
                            if stnc==size(stnords,2)
                                numdaystaken=numdaystaken+1;
                                vecdaystaken(numdaystaken*7-6:numdaystaken*7,1)=(doyspanstart:doyspanstop)';
                                vecdaystaken(numdaystaken*7-6:numdaystaken*7,2)=thisyr.*ones(7,1);
                            end
                        end
                    else %day is in middle of month
                        for j=1:3
                            if j==1;stndata=stndatat;elseif j==2;stndata=stndatawbt;elseif j==3;stndata=stndataq;end
                            datathistrace{region}(stnc,row,1:168)=stndata{stn,thisyrrel,thismnrel}((thisdy-4)*24+thisstntz+1:(thisdy+3)*24+thisstntz);
                            temp=squeeze(avgthishourofdayandmonth{j}(stn,thismnrel,:));
                            avgthistrace=[temp;temp;temp;temp;temp;temp;temp];
                            anomthistrace{region}(stnc,row,:)=[squeeze(datathistrace{region}(stnc,row,1:168))-avgthistrace];
                            if max(anomthistrace{region}(stnc,row,:))==0;anomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);end
                            %if region==7 && stnc==15;disp(max(anomthistrace{region}(stnc,row,:)));disp('section 3');fprintf('row: %d\n',row);end
                            if j==1
                                tanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%tdatathistrace{region}(stnc,row,:)=datathistrace;
                            elseif j==2
                                wbtanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%wbtdatathistrace{region}(stnc,row,:)=datathistrace;
                            elseif j==3
                                qanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%qdatathistrace{region}(stnc,row,:)=datathistrace;
                            end
                        end
                        if stnc==size(stnords,2)
                            numdaystaken=numdaystaken+1;
                            vecdaystaken(numdaystaken*7-6:numdaystaken*7,1)=(doyspanstart:doyspanstop)';
                            vecdaystaken(numdaystaken*7-6:numdaystaken*7,2)=thisyr.*ones(7,1);
                        end
                    end
                else %row~=1
                    overlapfound=0;
                    for subrow=1:size(vecdaystaken,1)
                        if vecdaystaken(subrow,1)==thisdoy && vecdaystaken(subrow,2)==thisyr %overlap, so exclude this hot day
                            overlapfound=1;
                            tanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                            wbtanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                            qanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                            %if region==7 && stnc==6;disp(max(tanomthistrace{region}(stnc,row,:)));disp('section 3.5');fprintf('row: %d\n',row);end
                        end
                    end
                    %if region==7 && stnc==6;fprintf('overlapfound is %d\n',overlapfound);fprintf('row: %d\n',row);end
                    if overlapfound==0
                        %if region==5 && stnc==7 && row==60;disp('oh hel');end
                        if (thisdy-4)*24+thisstntz+1<=0 %day is close to start of month
                            if thismn==monthiwf %nothing we can do
                                tanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                                wbtanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                                qanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                            else
                                numdaysinprevmon=7-thisdy;prevmonlen=monthlengthsdays(thismnrel-1);
                                for j=1:3
                                    if j==1;stndata=stndatat;elseif j==2;stndata=stndatawbt;elseif j==3;stndata=stndataq;end
                                    datathistracepart1=stndata{stn,thisyrrel,thismnrel-1}(prevmonlen*24-numdaysinprevmon*24+thisstntz+1:prevmonlen*24);
                                    datathistracepart2=stndata{stn,thisyrrel,thismnrel}(1:thisdy*24+thisstntz);
                                    temp=squeeze(avgthishourofdayandmonth{j}(stn,thismnrel-1,:));
                                    avgthistracepart1=[temp;temp;temp;temp;temp;temp;temp];avgthistracepart1=avgthistracepart1(1:size(datathistracepart1,1));
                                    temp=squeeze(avgthishourofdayandmonth{j}(stn,thismnrel,:));
                                    avgthistracepart2=[temp;temp;temp;temp;temp;temp;temp];avgthistracepart2=avgthistracepart2(1:size(datathistracepart2,1));
                                    avgthistrace=[avgthistracepart1;avgthistracepart2];
                                    anomthistrace{region}(stnc,row,:)=[datathistracepart1-avgthistracepart1;datathistracepart2-avgthistracepart2];
                                    if max(anomthistrace{region}(stnc,row,:))==0;anomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);end
                                    %if region==7 && stnc==6;disp(max(anomthistrace{region}(stnc,row,:)));disp('section 4');fprintf('row: %d\n',row);end
                                    if j==1
                                        tanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%tdatathistrace{region}(stnc,row,:)=datathistrace;
                                    elseif j==2
                                        wbtanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%wbtdatathistrace{region}(stnc,row,:)=datathistrace;
                                    elseif j==3
                                        qanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%qdatathistrace{region}(stnc,row,:)=datathistrace;
                                    end
                                end
                                if stnc==size(stnords,2)
                                    numdaystaken=numdaystaken+1;
                                    vecdaystaken(numdaystaken*7-6:numdaystaken*7,1)=(doyspanstart:doyspanstop)';
                                    vecdaystaken(numdaystaken*7-6:numdaystaken*7,2)=thisyr.*ones(7,1);
                                end
                            end
                        elseif (thisdy+3)*24+thisstntz>thismnlen %day is close to end of month
                            if thismn==monthiwl %nothing we can do
                                tanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                                wbtanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                                qanomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);
                            else
                                numdaysinthismon=7-(thismnlen/24-thisdy)-1;numdaysinnextmon=7-numdaysinthismon;
                                for j=1:3
                                    if j==1;stndata=stndatat;elseif j==2;stndata=stndatawbt;elseif j==3;stndata=stndataq;end
                                    datathistracepart1=stndata{stn,thisyrrel,thismnrel}(thismnlen-numdaysinthismon*24+thisstntz+1:thismnlen);
                                    datathistracepart2=stndata{stn,thisyrrel,thismnrel+1}(1:numdaysinnextmon*24+thisstntz);
                                    temp=squeeze(avgthishourofdayandmonth{j}(stn,thismnrel,:));
                                    avgthistracepart1=[temp;temp;temp;temp;temp;temp;temp];avgthistracepart1=avgthistracepart1(1:size(datathistracepart1,1));
                                    temp=squeeze(avgthishourofdayandmonth{j}(stn,thismnrel+1,:));
                                    avgthistracepart2=[temp;temp;temp;temp;temp;temp;temp];avgthistracepart2=avgthistracepart2(1:size(datathistracepart2,1));
                                    avgthistrace=[avgthistracepart1;avgthistracepart2];
                                    anomthistrace{region}(stnc,row,:)=[datathistracepart1-avgthistracepart1;datathistracepart2-avgthistracepart2];
                                    if max(anomthistrace{region}(stnc,row,:))==0;anomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);end
                                    %if region==7 && stnc==6;disp(max(anomthistrace{region}(stnc,row,:)));disp('section 5');fprintf('row: %d and j:%d\n',row,j);end
                                    if j==1
                                        tanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%tdatathistrace{region}(stnc,row,:)=datathistrace;
                                    elseif j==2
                                        wbtanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%wbtdatathistrace{region}(stnc,row,:)=datathistrace;
                                    elseif j==3
                                        qanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%qdatathistrace{region}(stnc,row,:)=datathistrace;
                                    end
                                    %if region==7 && stnc==6;fprintf('down at line 1533, row is %d\n',row);end
                                end
                                if stnc==size(stnords,2)
                                    numdaystaken=numdaystaken+1;
                                    vecdaystaken(numdaystaken*7-6:numdaystaken*7,1)=(doyspanstart:doyspanstop)';
                                    vecdaystaken(numdaystaken*7-6:numdaystaken*7,2)=thisyr.*ones(7,1);
                                end
                            end
                            %if region==7 && stnc==1;fprintf('down at line 1540, row is %d\n',row);end
                        else %day is in middle of month
                            for j=1:3
                                if j==1;stndata=stndatat;elseif j==2;stndata=stndatawbt;elseif j==3;stndata=stndataq;end
                                %if region==7 && stnc==6 && j==1 && row==8;fprintf('stn, thisyrrel,thismnrel,thisdy are %d, %d, %d, %d\n',stn,thisyrrel,thismnrel,thisdy);end
                                datathistrace{region}(stnc,row,1:168)=stndata{stn,thisyrrel,thismnrel}((thisdy-4)*24+thisstntz+1:(thisdy+3)*24+thisstntz);
                                temp=squeeze(avgthishourofdayandmonth{j}(stn,thismnrel,:));
                                avgthistrace=[temp;temp;temp;temp;temp;temp;temp];
                                anomthistrace{region}(stnc,row,:)=[squeeze(datathistrace{region}(stnc,row,1:168))-avgthistrace];
                                if max(anomthistrace{region}(stnc,row,:))==0;anomthistrace{region}(stnc,row,:)=NaN.*ones(168,1);end
                                if region==7 && stnc==6
                                    %disp(max(anomthistrace{region}(stnc,row,:)));disp('section 6');fprintf('row: %d\n',row);
                                    if row==8 && j==1
                                        %figure(900);plot(squeeze(datathistrace{region}(stnc,row,1:168)));
                                        %figure(901);plot(squeeze(avgthistrace));
                                        %figure(902);plot(squeeze(anomthistrace{region}(stnc,row,:)));
                                    end
                                end
                                if j==1
                                    tanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%tdatathistrace{region}(stnc,row,:)=datathistrace;
                                elseif j==2
                                    wbtanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%wbtdatathistrace{region}(stnc,row,:)=datathistrace;
                                elseif j==3
                                    qanomthistrace{region}(stnc,row,:)=anomthistrace{region}(stnc,row,:);%qdatathistrace{region}(stnc,row,:)=datathistrace;
                                end
                            end
                            if stnc==size(stnords,2)
                                numdaystaken=numdaystaken+1;
                                vecdaystaken(numdaystaken*7-6:numdaystaken*7,1)=(doyspanstart:doyspanstop)';
                                vecdaystaken(numdaystaken*7-6:numdaystaken*7,2)=thisyr.*ones(7,1);
                            end
                        end
                        %if region==7 && stnc==6;fprintf('down at line 1575, row is %d\n',row);end
                    end
                end
            end
            %disp(size(vecdaystaken));
        end
        tanomtraceregavg{region}=nanmean(tanomthistrace{region}(:,:,:),2); %average over rows
        tanomtraceregavg{region}=squeeze(nanmean(tanomtraceregavg{region},1)); %average over stns within region
        wbtanomtraceregavg{region}=nanmean(wbtanomthistrace{region}(:,:,:),2); %average over rows
        wbtanomtraceregavg{region}=squeeze(nanmean(wbtanomtraceregavg{region},1)); %average over stns within region
        qanomtraceregavg{region}=nanmean(qanomthistrace{region}(:,:,:),2); %average over rows
        qanomtraceregavg{region}=squeeze(nanmean(qanomtraceregavg{region},1)); %average over stns within region
        clear datathistrace;clear anomthistrace;
    end
    save(strcat(curDir,'extraarrays'),'tanomtraceregavg','wbtanomtraceregavg','qanomtraceregavg','-append');
end



%Group regional hot days into heat events selon definition in McKinnon et al. 2016
%NOT NECESSARY B/C THEY STATE RESULTS IN THE MAIN TEXT ARE ACTUALLY HOT DAYS UNCORRECTED FOR CONSECUTIVE-DAY EFFECTS
%Relatedly, calculate number of independent events represented by the top-XX values of T and of WBT
if groupintoheatevents==1
    %Regional hot days grouped into regional heat events
    for region=1:8
        reghotwbtdayschronsorted=sortrows(topXXwbtbyregionsorted{region}(1:numdates,:),[1 2 3]);
        partofheatevent=0;
        for row=2:numdates
            yr=reghotwbtdayschronsorted(row,1);
            mn=reghotwbtdayschronsorted(row,2);
            dy=reghotwbtdayschronsorted(row,3);
            doy=DatetoDOY(mn,dy,yr);
            prevyr=reghotwbtdayschronsorted(row-1,1);
            prevmn=reghotwbtdayschronsorted(row-1,2);
            prevdy=reghotwbtdayschronsorted(row-1,3);
            prevdoy=DatetoDOY(prevmn,prevdy,prevyr);
            if partofheatevent==0
                %if yr==prevyr && doy
            end
        end
    end
    
    %Number of independent events for each station
    for stnindex=1:maxnumstns
        for variable=2:2
            %Sort array by year, then by month, then by day so consecutive days are forced to clump together
            if variable==1;topXX=topXXtbystn{stnindex};elseif variable==2;topXX=topXXwbtbystn{stnindex};end
            thisstnchronsorted=sortrows(topXX,[2 3 4]);
            
            numevents=1;
            for row=2:numdates
                %Look through chronsorted and tally up events
                if thisstnchronsorted(row,2)~=thisstnchronsorted(row-1,2)
                    numevents=numevents+1;
                elseif thisstnchronsorted(row,3)~=thisstnchronsorted(row-1,3) && ...
                        thisstnchronsorted(row,4)~=1
                    numevents=numevents+1;
                elseif thisstnchronsorted(row,3)==thisstnchronsorted(row-1,3) && ...
                        thisstnchronsorted(row,4)~=thisstnchronsorted(row-1,4)+1
                    numevents=numevents+1;
                end
            end
            if variable==1
                numeventstbystn(stnindex)=numevents;
            elseif variable==2
                numeventswbtbystn(stnindex)=numevents;
            end
        end
    end
end


%Number of years required to represent half of the top-XX T and WBT, by station
if calcnumberofyears==1
    for stnindex=1:maxnumstns
        for variable=1:2
            if variable==1
                arrayhere=topXXtbystn{stnindex};
            else
                arrayhere=topXXwbtbystn{stnindex};
            end
            
            countnumobseachyear=zeros(yeariwl-yeariwf+1,1);
            %Count up the number of observations in each year for this station 
            %Therefore sum(countnumobseachyear) should =numdates
            for row=1:numdates
                relyear=arrayhere(row,2)-yeariwf+1;
                countnumobseachyear(relyear)=countnumobseachyear(relyear)+1;
            end
            
            %Now determine which years have the most dates representing them, and
            %how many years must be combined to reach the 50% threshold for this station
            helpervec=[1:yeariwl-yeariwf+1]';
            combovec=[countnumobseachyear helpervec];
            countnumobs=sortrows(combovec,-1);
            numobsfoundsofar=0;row=1;
            while numobsfoundsofar<=0.5*numdates
                numobsfoundsofar=numobsfoundsofar+countnumobs(row,1);
                row=row+1;
            end
            
            numyearsrequired(variable,stnindex)=row;
        end
    end
end

%Number of bad (disallowed) months & years for each station
if calcstnnumsordinatesandnumbadmonthsyears==1
    badmonthscbyregion=zeros(8,yeariwl-yeariwf+1);
    badmonthscbystn=zeros(size(newstnNumList,1),yeariwl-yeariwf+1);
    badmonthscbystndividedbyregion=zeros(yeariwl-yeariwf+1,8,max(stnceachregion));
    stnceachregion=zeros(8,1);
    stnnumseachregion={};
    stnordinateseachregion={};
    countsofarthisregion=zeros(8,1);
    for stn=1:size(newstnNumList,1)
        thisstnregion=ncaregionnum{stn};
        stnceachregion(thisstnregion)=stnceachregion(thisstnregion)+1;
        countsofarthisregion(thisstnregion)=countsofarthisregion(thisstnregion)+1;
        stnnumseachregion{thisstnregion}(stnceachregion(thisstnregion))=newstnNumList(stn);
        stnordinateseachregion{thisstnregion}(countsofarthisregion(thisstnregion))=stn;
        for year=1:yeariwl-yeariwf+1
            for month=1:monthiwl-monthiwf+1
                if max(stndatat{stn,year,month})==0
                    %disp(stn);disp(year);disp(month);
                    badmonthscbystn(stn,year)=badmonthscbystn(stn,year)+1;
                    badmonthscbyregion(thisstnregion,year)=badmonthscbyregion(thisstnregion,year)+1;
                    badmonthscbystndividedbyregion(year,thisstnregion,stnceachregion(thisstnregion))=...
                        badmonthscbystndividedbyregion(year,thisstnregion,stnceachregion(thisstnregion))+1;
                end
            end
        end
    end
    
    %Normalize the badmonthsc arrays so that they represent percentages
    for stn=1:size(newstnNumList,1)
        for year=1:yeariwl-yeariwf+1
            badmonthspctbystn(stn,year)=badmonthscbystn(stn,year)/((monthiwl-monthiwf+1));
        end
    end
    for region=1:8
        for year=1:yeariwl-yeariwf+1
            badmonthspctbyregion(region,year)=badmonthscbyregion(region,year)/((monthiwl-monthiwf+1)*(stnceachregion(region)));
        end
    end
    %These badmonthspct arrays can be easily visualized with imagescnan
    save(strcat(curDir,'extraarrays'),'badmonthspctbystn','badmonthspctbyregion',...
        'stnnumseachregion','stnordinateseachregion','-append');
end

%Average and st dev of *dates* of top-XX T, WBT, and q, both to see what the spatial patterns of these are,
%and to compare them for particular stations
if calctwbtqdates==1 
    for var=1:3
        if var==1
            topXXbystn=topXXtbystn;topXXbynarr=topXXtbynarr;
        elseif var==2
            topXXbystn=topXXwbtbystn;topXXbynarr=topXXwbtbynarr;
        elseif var==3
            topXXbystn=topXXqbystn;topXXbynarr=topXXqbynarr;
        end
        for stnindex=1:maxnumstns
            %Have to convert month/day format to DOY format
            for i=1:numdates
                doyofdates(i)=DatetoDOY(topXXbystn{stnindex}(i,3),topXXbystn{stnindex}(i,4),topXXbystn{stnindex}(i,2));
            end
            avgdoy(stnindex)=round(mean(doyofdates(1:100)));
            stdevdoy(stnindex)=round(std(doyofdates(1:100)));
            p25doy(stnindex)=round(quantile(doyofdates(1:100),0.25));
            p75doy(stnindex)=round(quantile(doyofdates(1:100),0.75));
            %Also convert this average DOY, and its p25 and p75 cousins, back to a month/day pairing
            avgmonth(stnindex)=DOYtoMonth(avgdoy(stnindex),2015);
            avgday(stnindex)=DOYtoDOM(avgdoy(stnindex),2015);
            p25month(stnindex)=DOYtoMonth(p25doy(stnindex),2015);
            p75month(stnindex)=DOYtoMonth(p75doy(stnindex),2015);
            p25day(stnindex)=DOYtoDOM(p25doy(stnindex),2015);
            p75day(stnindex)=DOYtoDOM(p75doy(stnindex),2015);
        end
        %if var==2
            for i=1:277
                for j=1:349
                    if narrlsmask(i,j)==1 && tzlist(i,j)~=0
                        %Have to convert month/day format to DOY format
                        for k=1:numdates
                            if topXXbynarr(i,j,k,2)>=1900 %i.e. a plausible year for this obs, and not nonsense filler data
                                doyofdates(k)=DatetoDOY(topXXbynarr(i,j,k,3),topXXbynarr(i,j,k,4),topXXbynarr(i,j,k,2));
                            else
                                doyofdates(k)=NaN;
                            end
                        end
                        avgdoynarr(i,j)=round(nanmean(doyofdates(1:100)));
                        stdevdoynarr(i,j)=round(nanstd(doyofdates(1:100)));
                        %Also convert this average DOY back to a month/day pairing
                        avgmonthnarr(i,j)=DOYtoMonth(round(nanmean(doyofdates(1:100))),2015);
                        avgdaynarr(i,j)=DOYtoDOM(round(nanmean(doyofdates(1:100))),2015);
                    else
                        avgdoynarr(i,j)=NaN;stdevdoynarr(i,j)=NaN;
                        avgmonthnarr(i,j)=NaN;avgdaynarr(i,j)=NaN;
                    end
                end
            end
        %end
        if var==1
            avgdoyt=avgdoy;stdevdoyt=stdevdoy;avgmontht=avgmonth;avgdayt=avgday;
            avgdoytnarr=avgdoynarr;stdevdoytnarr=stdevdoynarr;
            avgmonthtnarr=avgmonthnarr;avgdaytnarr=avgdaynarr;
            p25doyt=p25doy;p25montht=p25month;p75doyt=p75doy;p75montht=p75month;
        elseif var==2
            avgdoywbt=avgdoy;stdevdoywbt=stdevdoy;avgmonthwbt=avgmonth;avgdaywbt=avgday;
            avgdoywbtnarr=avgdoynarr;stdevdoywbtnarr=stdevdoynarr;
            avgmonthwbtnarr=avgmonthnarr;avgdaywbtnarr=avgdaynarr;
            p25doywbt=p25doy;p25monthwbt=p25month;p75doywbt=p75doy;p75monthwbt=p75month;
        elseif var==3
            avgdoyq=avgdoy;stdevdoyq=stdevdoy;avgmonthq=avgmonth;avgdayq=avgday;
            p25doyq=p25doy;p25monthq=p25month;p75doyq=p75doy;p75monthq=p75month;
        end
    end
    save(strcat(curDir,'othercatchallarrays'),'avgdoyt','stdevdoyt','avgdoytnarr','stdevdoytnarr',...
        'avgmontht','avgdayt','p25doyt','p25montht','p75doyt','p75montht','avgmonthtnarr','avgdaytnarr',...
        'avgmonthwbt','avgdaywbt','p25doywbt','p25monthwbt','p75doywbt','p75monthwbt','avgdoywbt','stdevdoywbt',...
        'avgdoywbtnarr','stdevdoywbtnarr','avgmonthwbtnarr','avgdaywbtnarr','avgdoyq','stdevdoyq','avgmonthq',...
        'avgdayq','p25doyq','p25monthq','p75doyq','p75monthq','-append');
end

%Average and st dev of *hours* of top-XX T, WBT, and q, both to see what the spatial patterns of these are,
    %and to compare them for particular stations
if calctwbtqhours==1
    for var=1:3
        if var==1
            topXXbystn=topXXtbystn;
        elseif var==2
            topXXbystn=topXXwbtbystn;
        elseif var==3
            topXXbystn=topXXqbystn;
        end
        regionc=zeros(8,1);temp={};
        for stnindex=1:maxnumstns
            hoursofmax=topXXbystn{stnindex}(:,5);
            %stnnum=newstnNumList(stnindex);
            %[~,~,~,stnhradj]=stationinfofromnumber(stnnum);
            %hoursofmax=hoursofmax-stnhradj; %already have adjusted for LST-UTC offset in createmaxtwbtarrays
            for j=1:size(hoursofmax,1)
                if hoursofmax(j)<0;hoursofmax(j)=hoursofmax(j)+24;end
            end
            temp2=hoursofmax==0;hoursofmax(temp2)=NaN;
            avghourofmax(stnindex)=nanmean(hoursofmax);
            stdevhourofmax(stnindex)=std(hoursofmax);
            p25hourofmax(stnindex)=round(quantile(hoursofmax,0.25));
            p75hourofmax(stnindex)=round(quantile(hoursofmax,0.75));
            allhoursofmax(var,stnindex,:)=hoursofmax;
            region=1;found=0;
            while region<=8 && found==0
                temp{region}=checkifthingsareelementsofvector(stnindex,stnordinateseachregion{region});
                if max(temp{region})==1;found=1;thisstnsregion=region;else region=region+1;end
            end
            regionc(thisstnsregion)=regionc(thisstnsregion)+1;
            allhoursofmaxbyregion{var,thisstnsregion}(regionc(thisstnsregion),:)=hoursofmax;
            %if stnindex==94;disp(hoursofmax(1:5));disp(avghourofmax(stnindex));end
        end
        if var==2
            for i=1:277
                for j=1:349
                    if narrlsmask(i,j)==1 && tzlist(i,j)~=0
                        hoursofmax=squeeze(topXXdatawbtnarr(i,j,:,5));
                        avghourofmaxnarr(i,j)=mean(topXXdatawbtnarr(i,j,:,5),3);
                        %stdevhourofmaxnarr(i,j)=std(topXXwbtbynarr(i,j,:,5),3);
                    else
                        avghourofmaxnarr(i,j)=NaN;
                        stdevhourofmaxnarr(i,j)=NaN;
                    end
                end
            end
        end
        if var==1
            avghourofmaxt=avghourofmax;stdevhourofmaxt=stdevhourofmax;
            p25hourofmaxt=p25hourofmax;p75hourofmaxt=p75hourofmax;
        elseif var==2
            avghourofmaxwbt=avghourofmax;stdevhourofmaxwbt=stdevhourofmax;
            avghourofmaxwbtnarr=avghourofmaxnarr;stdevhourofmaxwbtnarr=stdevhourofmaxnarr;
            p25hourofmaxwbt=p25hourofmax;p75hourofmaxwbt=p75hourofmax;
        elseif var==3
            avghourofmaxq=avghourofmax;stdevhourofmaxq=stdevhourofmax;
            p25hourofmaxq=p25hourofmax;p75hourofmaxq=p75hourofmax;
        end
    end
end

%Investigate if thunderstorm development (if not t-storms then at least convective activity)
    %is contributing to the earlier peak in T and WBT in the South vis-à-vis the North
%Do this by looking at the days of the top-XX T and WBT, and particularly the hours surrounding the max hour
    %Days are defined by LST, and therefore adjustment from UTC is accounted for here
%Recall that finaldatat has 4416 hours annually -- 24 hours for each day in MJJASO
%Therefore midnight on Jul 31/Aug 1 is exactly halfway (2208 hours)
if tstormanalysismaxhour==1
    for stnindex=1:maxnumstns
        %Look for big afternoon drops in T, as described in ProjectOrganiz.doc
        curcityarr=topXXtbystn{stnindex};
        stnnum=newstnNumList(stnindex);
        [~,~,~,tco]=stationinfofromnumber(stnnum); %thiscityoffset
        for day=1:numdates
            %Find this day amongst the original (full) dataset for this station
            thisdayyear=curcityarr(day,2);
            thisdaymonth=curcityarr(day,3);
            thisdayday=curcityarr(day,4);
            thisdaydoy=DatetoDOY(thisdaymonth,thisdayday,thisdayyear);
            if rem(thisdayyear,4)==0;leapyear=1;else leapyear=0;end
            if leapyear==1;may1doy=122;else may1doy=121;end
            thisdaystarthour=((thisdaydoy-may1doy)*24+1);
            thisdayendhour=((thisdaydoy-may1doy)*24+24);
            origdatathisday=finaldatat{thisdayyear-yeariwf+1,stnindex}(thisdaystarthour+tco:thisdayendhour+tco);
            
            %Determine if an afternoon thunderstorm occurred on this day at this station
            %It will most likely be listed as occurring the hour preceding an unexpected T drop
            tstormfound=0;athour=0;
            for lst=13:21
                if origdatathisday(lst)-origdatathisday(lst-1)<=-3.5;tstormfound=1;athour=lst-1;end
            end
            %if tstormfound==0
            %    for lst=18:21
            %        if origdatathisday(lst)-origdatathisday(lst-1)<=-2;tstormfound=1;athour=lst-1;end
            %    end
            %end
            tstormrecord(stnindex,day,1)=tstormfound;
            tstormrecord(stnindex,day,2)=athour;
        end
    end
end


%Hourly traces of T and WBT (5th, 50th, and 95th percentiles) on extreme-WBT days 
%Legacy code for stns includes t references, which should be replaced with 'wbt' if it is to be used again
    %for a. selected stations & b. regional averages from 3 days before to 3 days after each top-XX WBT day at that station or region
if computehourlytracestwbt==1
    pct5ttrace={};pct50ttrace={};pct95ttrace={};pct5wbttrace={};pct50wbttrace={};pct95wbttrace={};
    for stn=1:size(selindivstns,1)
        [a,b,c,d]=stationinfofromnumber(newstnNumList(selindivstns(stn)));stntzoffset=d;
        hottdaysthisstn=topXXtbystn{selindivstns(stn)};validtracesthisstn=0;
        for row=1:100
            thisyear=hottdaysthisstn(row,2);relyear=thisyear-yeariwf+1;
            thismon=hottdaysthisstn(row,3);relmon=thismon-monthiwf+1;
            thisday=hottdaysthisstn(row,4);
            
            if relmon~=1;prevmonlen=monthlengthsdays(relmon-1);end
            thismonlen=monthlengthsdays(relmon);
            skipthistrace=0;
            
            if relmon==1 && thisday<=3 || relmon==6 && thisday>=thismonlen-2 %near the edges of the data available
                skipthistrace=1;
            end
            
            if skipthistrace==0
                validtracesthisstn=validtracesthisstn+1;
                thishourlyttracepart1=0;thishourlyttracepart2=0;thishourlyttrace=0;
                thishourlywbttracepart1=0;thishourlywbttracepart2=0;thishourlywbttrace=0;
                %Get the hourly T and WBT data from 3 days before to 3 days after this hot day (i.e. 7 days total), with special
                    %treatment if this hot day is close to the start or end of a month
                if thismonlen-thisday<=3 %thisday is near the end of the month
                    numdaystoincludethismonth=thismonlen-thisday; %besides the hot day itself, of course
                    numdaystoincludenextmonth=3-numdaystoincludethismonth;
                    thishourlyttracepart1=stndatat{selindivstns(stn),relyear,relmon}((thisday-3)*24-11-stntzoffset:(thisday+numdaystoincludethismonth)*24);
                    thishourlyttracepart2=stndatat{selindivstns(stn),relyear,relmon+1}(1:(numdaystoincludenextmonth*24)+12-stntzoffset);
                    thishourlyttrace=[thishourlyttracepart1;thishourlyttracepart2];
                    thishourlywbttracepart1=stndatawbt{selindivstns(stn),relyear,relmon}((thisday-3)*24-11-stntzoffset:(thisday+numdaystoincludethismonth)*24);
                    thishourlywbttracepart2=stndatawbt{selindivstns(stn),relyear,relmon+1}(1:(numdaystoincludenextmonth*24)+12-stntzoffset);
                    thishourlywbttrace=[thishourlywbttracepart1;thishourlywbttracepart2];
                elseif thisday<=3 %thisday is near the start of a month
                    numdaystoincludethismonth=thisday-1; %besides the hot day itself, of course
                    numdaystoincludeprevmonth=3-numdaystoincludethismonth;
                    thishourlyttracepart1=stndatat{selindivstns(stn),relyear,relmon-1}(prevmonlen*24-(numdaystoincludeprevmonth*24)+13-stntzoffset:prevmonlen*24);
                    thishourlyttracepart2=stndatat{selindivstns(stn),relyear,relmon}(1:(numdaystoincludethismonth+4)*24+12-stntzoffset);
                    thishourlyttrace=[thishourlyttracepart1;thishourlyttracepart2];
                    thishourlywbttracepart1=stndatawbt{selindivstns(stn),relyear,relmon-1}(prevmonlen*24-(numdaystoincludeprevmonth*24)+13-stntzoffset:prevmonlen*24);
                    thishourlywbttracepart2=stndatawbt{selindivstns(stn),relyear,relmon}(1:(numdaystoincludethismonth+4)*24+12-stntzoffset);
                    thishourlywbttrace=[thishourlywbttracepart1;thishourlywbttracepart2];
                else
                    thishourlyttrace=stndatat{selindivstns(stn),relyear,relmon}((thisday-3)*24-11-stntzoffset:(thisday+3)*24+12-stntzoffset);
                    thishourlywbttrace=stndatawbt{selindivstns(stn),relyear,relmon}((thisday-3)*24-11-stntzoffset:(thisday+3)*24+12-stntzoffset);
                end
                %Size of every thishourlytrace should be 168 hours
                hourlytracesoftbystn{stn}(validtracesthisstn,:)=thishourlyttrace;
                hourlytracesofwbtbystn{stn}(validtracesthisstn,:)=thishourlywbttrace;
            end
        end
        %Calculate the 5th, 50th, and 95th percentiles at each hour separately
        for hour=1:168
            pct5ttrace{stn}(hour)=quantile(hourlytracesoftbystn{stn}(:,hour),0.05);
            pct50ttrace{stn}(hour)=quantile(hourlytracesoftbystn{stn}(:,hour),0.50);
            pct95ttrace{stn}(hour)=quantile(hourlytracesoftbystn{stn}(:,hour),0.95);
            pct5wbttrace{stn}(hour)=quantile(hourlytracesofwbtbystn{stn}(:,hour),0.05);
            pct50wbttrace{stn}(hour)=quantile(hourlytracesofwbtbystn{stn}(:,hour),0.50);
            pct95wbttrace{stn}(hour)=quantile(hourlytracesofwbtbystn{stn}(:,hour),0.95);
        end
    end
end

%Median of top-XX WBT by station
if mediantopXXwbtbystn==1
    mediantopxxwbtbystn=0;
    for stnindex=1:maxnumstns
        thisstntopxx=topXXwbtbystn{stnindex};
        mediantopxxwbtbystn(stnindex)=thisstntopxx(50,1);
    end
    save(strcat(curDir,'topXXarrays'),'mediantopxxwbtbystn','-append');
end

%Median of top-XX WBT by NARR grid cell
if mediantopXXwbtbynarr==1
    mediantopxxwbtbynarr=NaN.*ones(277,349);
    for i=1:277
        for j=1:349
            thisgridcelltopxx=sort(squeeze(topXXwbtbynarr(i,j,:,1)));
            mediantopxxwbtbynarr(i,j)=thisgridcelltopxx(50);
        end
    end
    save(strcat(curDir,'topXXarrays'),'mediantopxxwbtbynarr','-append');
end

%Examine trends (simply occurrence by decade) in top-XX T and WBT and in overlap scores, 
    %by station & by NCA region
%Also do the same thing for NARR gridpts
%Decades are 1981-90, 1991-2000, 2001-10, 2011-15 (*2)
if examinetrends==1
    if dooccurrenceperdecade==1
        %For each station and NARR gridpt, look within the top-XX T and WBT days to find the number of occurrences per decade
        for var=2:2
            if var==1;topXXbystn=topXXtbystn;topXXbynarr=topXXtbynarr;else topXXbystn=topXXwbtbystn;topXXbynarr=topXXwbtbynarr;end
            for stn=1:size(topXXbystn,2)
                thisstntopXX=topXXbystn{stn};
                decade1c=1;decade2c=1;decade3c=1;decade4c=1;
                for row=1:numdates
                    if thisstntopXX(row,2)<=1990
                        decadethisday(row)=1;topXXbystnanddecade{stn,1}(decade1c,:)=thisstntopXX(row,:);
                        decade1c=decade1c+1;
                    elseif thisstntopXX(row,2)<=2000
                        decadethisday(row)=2;topXXbystnanddecade{stn,2}(decade2c,:)=thisstntopXX(row,:);
                        decade2c=decade2c+1;
                    elseif thisstntopXX(row,2)<=2010
                        decadethisday(row)=3;topXXbystnanddecade{stn,3}(decade3c,:)=thisstntopXX(row,:);
                        decade3c=decade3c+1;
                    elseif thisstntopXX(row,2)<=2015
                        decadethisday(row)=4;topXXbystnanddecade{stn,4}(decade4c,:)=thisstntopXX(row,:);
                        decade4c=decade4c+1;
                    else
                        disp('There is a problem in assigning decades');return;
                    end
                end
                decadethisdayallstns{stn}=decadethisday;
            end

            %Occurrence of top-XX T and WBT days by decade, for regions (obtained by averaging over stations)
            windowc=ones(8,1);numoccur=zeros(8,4);
            for stn=1:size(topXXtbystn,2)
                stnregion=ncaregionnum{stn};
                numoccur(stnregion,1)=numoccur(stnregion,1)+countnumberofoccurrences(1,decadethisdayallstns{stn}); %decade 1
                numoccur(stnregion,2)=numoccur(stnregion,2)+countnumberofoccurrences(2,decadethisdayallstns{stn}); %decade 2
                numoccur(stnregion,3)=numoccur(stnregion,3)+countnumberofoccurrences(3,decadethisdayallstns{stn}); %decade 3
                numoccur(stnregion,4)=numoccur(stnregion,4)+countnumberofoccurrences(4,decadethisdayallstns{stn}); %decade 4
                windowc(stnregion)=windowc(stnregion)+1;
            end
            for stnregion=1:8
                for decadec=1:4;normnumoccur(stnregion,decadec)=numoccur(stnregion,decadec)/(windowc(stnregion)-1);end
            end
            
            %Multiply 2010s by 2 so it can compete with the others on fair footing
            normnumoccur(:,4)=normnumoccur(:,4)*2;

            if var==1
                normnumoccurt=normnumoccur;
            else
                normnumoccurwbt=normnumoccur;
            end
        end
    end
    if dooccurrenceperyearandregion==1
        %Sum up the number of occurrences of top-XX T and WBT for all stations in a region in a given year,
        %and plot the result as a line graph so the regions and years can be compared in a single chart
        %Also note the number of occurrences for each station individually, to characterize intra-region spread in each year
        %And, do this for NARR gridpts as well
        for var=2:2
            if var==1
                topXXbystn=topXXtbystn;topXXbynarr=topXXtbynarr;
            elseif var==2
                topXXbystn=topXXwbtbystn;topXXbynarr=topXXwbtbynarr;
            elseif var==3
                topXXbystn=topXXqbystn;topXXbynarr=topXXqbynarr;
            end
            allregionsyearc{var}=zeros(yeariwl-yeariwf+1,8); %rows are years, columns are regions
            allregionsyearcbystn{var}=zeros(yeariwl-yeariwf+1,8,max(stnceachregion)); %dim 1=years, dim 2=regions, dim 3=stn # within region
            allregionsyearcnarr{var}=zeros(yeariwl-yeariwf+1,8); %rows are years, columns are regions
            allregionsyearcbystnnarr{var}=zeros(yeariwl-yeariwf+1,8,max(regionnarrgridptc));
            allregionsyearcbystnnoreg{var}=zeros(yeariwl-yeariwf+1,size(newstnNumList,1));
            exist stnceachregion;if ans==0;defineithere=1;stnceachregion=zeros(8,1);else defineithere=0;end %may have been defined already
            regionstnc=zeros(8,1);
            for stn=1:maxnumstns
                thisstnregion=ncaregionnum{stn};
                thisstntopXX=topXXbystn{stn};
                regionstnc(thisstnregion)=regionstnc(thisstnregion)+1;
                if defineithere==1;stnceachregion(thisstnregion)=stnceachregion(thisstnregion)+1;end
                for row=1:numdates %for all the years
                    thisyearrel=thisstntopXX(row,2)-yeariwf+1;
                    allregionsyearc{var}(thisyearrel,thisstnregion)=allregionsyearc{var}(thisyearrel,thisstnregion)+1;
                    allregionsyearcbystn{var}(thisyearrel,thisstnregion,regionstnc(thisstnregion))=...
                        allregionsyearcbystn{var}(thisyearrel,thisstnregion,regionstnc(thisstnregion))+1;
                    allregionsyearcbystnnoreg{var}(thisyearrel,stn)=allregionsyearcbystnnoreg{var}(thisyearrel,stn)+1;
                end
            end
            exist gridptceachregion;if ans==0;defineithere=1;gridptceachregion=zeros(8,1);else defineithere=0;end %may have been defined already
            regiongridptc=zeros(8,1);
            for i=1:277
                for j=1:349
                    if narrlsmask(i,j)==1 && tzlist(i,j)~=0
                        thisgridptregion=reglist(i,j);
                        %if rem(i,10)==0;disp(thisgridptregion);end
                        if thisgridptregion~=0
                            thisgridpttopXX=squeeze(topXXbynarr(i,j,:,:));
                            regiongridptc(thisgridptregion)=regiongridptc(thisgridptregion)+1;
                            gridptceachregion(thisgridptregion)=gridptceachregion(thisgridptregion)+1;
                            for row=1:numdates %for all the years
                                thisyearrel=thisgridpttopXX(row,2)-yeariwf+1;
                                allregionsyearcnarr{var}(thisyearrel,thisgridptregion)=allregionsyearcnarr{var}(thisyearrel,thisgridptregion)+1;
                                allregionsyearcbystnnarr{var}(thisyearrel,thisgridptregion,regiongridptc(thisgridptregion))=...
                                    allregionsyearcbystnnarr{var}(thisyearrel,thisgridptregion,regiongridptc(thisgridptregion))+1;
                            end
                        end
                    end
                end
            end
            
            %Normalize allregionsyearc by the number of stations in each region
            for region=1:8
                allregionsyearc{var}(:,region)=allregionsyearc{var}(:,region)/stnceachregion(region);
                allregionsyearcnarr{var}(:,region)=allregionsyearcnarr{var}(:,region)/gridptceachregion(region);
            end
        end
        save(strcat(curDir,'extraarrays'),'allregionsyearc','allregionsyearcbystn','allregionsyearcbystnnoreg',...
            'allregionsyearcnarr','stnceachregion','-append');
    end
end



%Set up composite maps by separating regional hot days into 10-day windows
%The 10-day windows are necessarily different from those enumerated & used in 
    %the maptwbtdates loop of exploratorydataanalysis, as additional ones
    %both in early & late summer must be included here
if setupcompositemaps==1
    for var=1:3
        %OLD DEF'Nif var==1;regionalhotdays=regionalhotdayst;else regionalhotdays=regionalhotdayswbt;end
        %NEW DEF'N
        if var==1
            topXXbyregion=topXXtbyregionsorted;
        elseif var==2
            topXXbyregion=topXXwbtbyregionsorted;
        elseif var==3
            topXXbyregion=topXXqbyregionsorted;
        end
        for region=1:8;for window=1:11;hotdaysbywindow{region,window}=zeros(1,4);end;end
        for region=1:8
            windowc=ones(11,1);
            for i=1:numdates
                thisrowmonth=topXXbyregion{region}(i,2);
                thisrowday=topXXbyregion{region}(i,3);
                if thisrowmonth==5 %May
                    hotdaysbywindow{region,1}(windowc(1),:)=topXXbyregion{region}(i,:);
                    windowc(1)=windowc(1)+1;
                elseif thisrowmonth==6 && thisrowday<=10 %Jun 1-10
                    hotdaysbywindow{region,2}(windowc(2),:)=topXXbyregion{region}(i,:);
                    windowc(2)=windowc(2)+1;
                elseif thisrowmonth==6 && thisrowday<=20 %Jun 11-20
                    hotdaysbywindow{region,3}(windowc(3),:)=topXXbyregion{region}(i,:);
                    windowc(3)=windowc(3)+1;
                elseif thisrowmonth==6 %Jun 21-30
                    hotdaysbywindow{region,4}(windowc(4),:)=topXXbyregion{region}(i,:);
                    windowc(4)=windowc(4)+1;
                elseif thisrowmonth==7 && thisrowday<=10 %Jul 1-10
                    hotdaysbywindow{region,5}(windowc(5),:)=topXXbyregion{region}(i,:);
                    windowc(5)=windowc(5)+1;
                elseif thisrowmonth==7 && thisrowday<=20 %Jul 11-20
                    hotdaysbywindow{region,6}(windowc(6),:)=topXXbyregion{region}(i,:);
                    windowc(6)=windowc(6)+1;
                elseif thisrowmonth==7 %Jul 21-31
                    hotdaysbywindow{region,7}(windowc(7),:)=topXXbyregion{region}(i,:);
                    windowc(7)=windowc(7)+1;
                elseif thisrowmonth==8 && thisrowday<=10 %Aug 1-10
                    hotdaysbywindow{region,8}(windowc(8),:)=topXXbyregion{region}(i,:);
                    windowc(8)=windowc(8)+1;
                elseif thisrowmonth==8 && thisrowday<=20 %Aug 11-20
                    hotdaysbywindow{region,9}(windowc(9),:)=topXXbyregion{region}(i,:);
                    windowc(9)=windowc(9)+1;
                elseif thisrowmonth==8 %Aug 21-31
                    hotdaysbywindow{region,10}(windowc(10),:)=topXXbyregion{region}(i,:);
                    windowc(10)=windowc(10)+1;
                elseif thisrowmonth==9 %Sep
                    hotdaysbywindow{region,11}(windowc(11),:)=topXXbyregion{region}(i,:);
                    windowc(11)=windowc(11)+1;
                end
            end
            %To be sure no rows were somehow duplicated
            for window=1:11
                if size(hotdaysbywindow{region,window},1)~=0
                    temp=unique(hotdaysbywindow{region,window},'rows');
                    hotdaysbywindow{region,window}=temp;
                    %if region==3 && window==7;disp('hello');disp(temp);disp(hotdaysbywindow{3,7});end
                end
            end
            %if region==3;disp('goodbye');disp(hotdaysbywindow{3,7});end
            
            %Save to different array names depending on which var was just used
            if var==1
                hotdaysbywindowt=hotdaysbywindow;
            elseif var==2
                hotdaysbywindowwbt=hotdaysbywindow;
            elseif var==3
                hotdaysbywindowq=hotdaysbywindow;
            end
            tendaywindownames11={'May';'Jun 1-10';'Jun 11-20';'Jun 21-30';'Jul 1-10';'Jul 11-20';...
                'Jul 21-31';'Aug 1-10';'Aug 11-20';'Aug 21-31';'Sep'};
        end
    end
    save(strcat(curDir,'compositemapsarrays'),'hotdaysbywindowt','hotdaysbywindowwbt','hotdaysbywindowq','-append');
end


%Create a vector with all MJJASO T, WBT, and q, so that percentiles can be calculated against it
%For the same purpose, also compute the average daily-max T, WBT, and q by station & month
if createvectoralltwbtq==1
    dailymaxt={};dailymaxwbt={};dailymaxq={};
    dailymaxtstruc={};dailymaxwbtstruc={};dailymaxqstruc={};
    for stn=1:size(topXXtbystn,2)
        totaldayc=1;
        for relyear=1:yeariwl-yeariwf+1
            for relmonth=1:6
                numdaysinmonth=size(stndatat{stn,relyear,relmonth})/24;
                for intramonthdayc=1:numdaysinmonth
                    dailymaxt{stn}(totaldayc)=max(stndatat{stn,relyear,relmonth}(intramonthdayc*24-23:intramonthdayc*24));
                    dailymaxwbt{stn}(totaldayc)=max(stndatawbt{stn,relyear,relmonth}(intramonthdayc*24-23:intramonthdayc*24));
                    dailymaxq{stn}(totaldayc)=max(stndataq{stn,relyear,relmonth}(intramonthdayc*24-23:intramonthdayc*24));
                    dailymaxtstruc{stn,relyear,relmonth}(intramonthdayc)=max(stndatat{stn,relyear,relmonth}(intramonthdayc*24-23:intramonthdayc*24));
                    dailymaxwbtstruc{stn,relyear,relmonth}(intramonthdayc)=max(stndatawbt{stn,relyear,relmonth}(intramonthdayc*24-23:intramonthdayc*24));
                    dailymaxqstruc{stn,relyear,relmonth}(intramonthdayc)=max(stndataq{stn,relyear,relmonth}(intramonthdayc*24-23:intramonthdayc*24));
                    totaldayc=totaldayc+1;
                end
            end
        end
        temp=dailymaxt{stn};temp(temp>=60)=NaN;dailymaxt{stn}=temp;
        temp=dailymaxwbt{stn};temp(temp>=60)=NaN;dailymaxwbt{stn}=temp;
        temp=dailymaxq{stn};temp(temp>=60)=NaN;dailymaxq{stn}=temp;
        %Compute average daily-max T, WBT, and q by month for this station
        for relmonth=1:6
            monstnavgt(stn,relmonth)=0;monstnavgwbt(stn,relmonth)=0;monstnavgq(stn,relmonth)=0;
            validstntmonc(stn,relmonth)=0;validstnwbtmonc(stn,relmonth)=0;validstnqmonc(stn,relmonth)=0;
            for relyear=1:yeariwl-yeariwf+1
                if max(dailymaxtstruc{stn,relyear,relmonth})<missingdatavalt && ~isnan(sum(dailymaxtstruc{stn,relyear,relmonth}))
                    monstnavgt(stn,relmonth)=monstnavgt(stn,relmonth)+sum(dailymaxtstruc{stn,relyear,relmonth});
                    validstntmonc(stn,relmonth)=validstntmonc(stn,relmonth)+1;
                end
                if max(dailymaxwbtstruc{stn,relyear,relmonth})<missingdatavalwbt && ~isnan(sum(dailymaxwbtstruc{stn,relyear,relmonth}))
                    monstnavgwbt(stn,relmonth)=monstnavgwbt(stn,relmonth)+sum(dailymaxwbtstruc{stn,relyear,relmonth});
                    validstnwbtmonc(stn,relmonth)=validstnwbtmonc(stn,relmonth)+1;
                end
                if max(dailymaxqstruc{stn,relyear,relmonth})<missingdatavalwbt && ~isnan(sum(dailymaxqstruc{stn,relyear,relmonth}))
                    monstnavgq(stn,relmonth)=monstnavgq(stn,relmonth)+sum(dailymaxqstruc{stn,relyear,relmonth});
                    validstnqmonc(stn,relmonth)=validstnqmonc(stn,relmonth)+1;
                end
            end
            monstnavgt(stn,relmonth)=monstnavgt(stn,relmonth)./(monthlengthsdays(relmonth)*validstntmonc(stn,relmonth));
            monstnavgwbt(stn,relmonth)=monstnavgwbt(stn,relmonth)./(monthlengthsdays(relmonth)*validstnwbtmonc(stn,relmonth));
            monstnavgq(stn,relmonth)=monstnavgq(stn,relmonth)./(monthlengthsdays(relmonth)*validstnqmonc(stn,relmonth));
        end
    end
    save(strcat(curDir,'extraarrays'),'dailymaxt','dailymaxtstruc','dailymaxwbt','dailymaxwbtstruc','dailymaxq','dailymaxqstruc',...
        'monstnavgt','monstnavgwbt','monstnavgq','-append');
end

%Creates a vector of all WBT daily maxes for the NARR data
%These are height-adjusted to match the local terrain
%Dimensions of each year's array: 277x349x366
%Years are computed and saved one at a time so as not to computationally overwhelm Matlab
if createvectoralltwbtqnarr==1
    %Pressure at surface as represented in the NARR model
    ghofsfc=ncread('ghofsfcnarr.nc','hgt');
    temp=ghofsfc<0;ghofsfc(temp)=NaN;
    presofsfc=pressurefromheight(ghofsfc)';
    
    for year=1994:yeariwl
        relyear=year-yeariwf+1;
        if rem(year,4)==0;ly=1;else ly=0;end
        narrallwbtdailymaxesthisyear=NaN.*ones(277,349,366);
        for month=5:9
            fprintf('Computing NARR WBTmax climatologies for year %d, month %d\n',year,month);
            relmon=month-monthiwf+1;
            thismonlen=monthlengthsdays(relmon);
            if ly==1;monenddoy=121+sum(monthlengthsdays(1:relmon));else monenddoy=120+sum(monthlengthsdays(1:relmon));end
            monstartdoy=monenddoy-thismonlen+1;
            if month==10;addzero='';else addzero='0';end
            
            shumdatafile=load(strcat(narr3hourlydataDir,'shum/',num2str(year),'/shum_',num2str(year),...
                '_',addzero,num2str(month),'_01.mat'));
            shumdata=eval(['shumdatafile.shum_' num2str(year) '_' addzero num2str(month) '_01']);shumdata=shumdata{3};
            shumdata1000=shumdata(:,:,1,:);shumdata850=shumdata(:,:,2,:);shumdata700=shumdata(:,:,3,:);shumdata500=shumdata(:,:,4,:);
            clear shumdatafile;
            tdatafile=load(strcat(narr3hourlydataDir,'air/',num2str(year),'/air_',num2str(year),...
                '_',addzero,num2str(month),'_01.mat'));
            tdata=eval(['tdatafile.air_' num2str(year) '_' addzero num2str(month) '_01']);tdata=tdata{3}-273.15;
            tdata1000=tdata(:,:,1,:);tdata850=tdata(:,:,2,:);tdata700=tdata(:,:,3,:);tdata500=tdata(:,:,4,:);
            clear tdatafile;
            for i=1:277
                %if rem(i,100)==0;fprintf('i is %d\n',i);end
                for j=1:349
                    %Only need to calculate all this for land gridpts
                    if narrlsmask(i,j)==1
                        thisgridptwbtdailymaxes1000=zeros(thismonlen,1);
                        thisgridptwbtdailymaxes850=zeros(thismonlen,1);
                        thisgridptwbtdailymaxes700=zeros(thismonlen,1);
                        thisgridptwbtdailymaxes500=zeros(thismonlen,1);
                        
                        thisgridptshumdata1000=squeeze(shumdata1000(i,j,1,:)); %size ~ 240x1 -- every hour this month
                        thisgridpttdata1000=squeeze(tdata1000(i,j,1,:)); %size ~ 240x1
                        thisgridptshumdata850=squeeze(shumdata850(i,j,1,:)); %size ~ 240x1
                        thisgridpttdata850=squeeze(tdata850(i,j,1,:)); %size ~ 240x1
                        thisgridptshumdata700=squeeze(shumdata700(i,j,1,:)); %size ~ 240x1
                        thisgridpttdata700=squeeze(tdata700(i,j,1,:)); %size ~ 240x1
                        thisgridptshumdata500=squeeze(shumdata500(i,j,1,:)); %size ~ 240x1
                        thisgridpttdata500=squeeze(tdata500(i,j,1,:)); %size ~ 240x1
                        
                        %Now, use T and q data to calculate WBT
                        thisgridptwbtdata1000=calcwbtfromTandshum(thisgridpttdata1000,thisgridptshumdata1000,1);
                        thisgridptwbtdata850=calcwbtfromTandshum(thisgridpttdata850,thisgridptshumdata850,1);
                        thisgridptwbtdata700=calcwbtfromTandshum(thisgridpttdata700,thisgridptshumdata700,1);
                        thisgridptwbtdata500=calcwbtfromTandshum(thisgridpttdata500,thisgridptshumdata500,1);
                        
                        %Compute daily maxes of WBT from this 3-hourly data
                        day=0;
                        for hour=1:8:thismonlen*8-7
                            day=day+1;
                            thisgridptwbtdailymaxes1000(day)=max(thisgridptwbtdata1000(hour:hour+7));
                            thisgridptwbtdailymaxes850(day)=max(thisgridptwbtdata850(hour:hour+7));
                            thisgridptwbtdailymaxes700(day)=max(thisgridptwbtdata700(hour:hour+7));
                            thisgridptwbtdailymaxes500(day)=max(thisgridptwbtdata500(hour:hour+7));
                        end
                        
                        %Interpolate this month's WBTmax to the height of the terrain
                        temp1000=thisgridptwbtdailymaxes1000;
                        temp850=thisgridptwbtdailymaxes850;
                        temp700=thisgridptwbtdailymaxes700;
                        temp500=thisgridptwbtdailymaxes500;
                        if narrlsmask(i,j)==1
                            if presofsfc(i,j)==1000
                                thisgridptwbtdailymaxes=temp1000;
                            elseif presofsfc(i,j)>850
                                wgt1000=(presofsfc(i,j)-850)./(1000-850);
                                wgt850=(1000-presofsfc(i,j))./(1000-850);
                                thisgridptwbtdailymaxes=wgt1000.*temp1000+wgt850.*temp850;
                            elseif presofsfc(i,j)==850
                                thisgridptwbtdailymaxes=temp850;
                            elseif presofsfc(i,j)>700
                                wgt850=(presofsfc(i,j)-700)./(850-700);
                                wgt700=(850-presofsfc(i,j))./(850-700);
                                thisgridptwbtdailymaxes=wgt850.*temp850+wgt700.*temp700;
                            elseif presofsfc(i,j)==700
                                thisgridptwbtdailymaxes=temp700;
                            else
                                wgt700=(presofsfc(i,j)-500)./(700-500);
                                wgt500=(700-presofsfc(i,j))./(700-500);
                                thisgridptwbtdailymaxes=wgt700.*temp700+wgt500.*temp500;
                            end
                        end

                        %Save these daily maxes into this year's big array 
                        narrallwbtdailymaxesthisyear(i,j,monstartdoy:monenddoy)=thisgridptwbtdailymaxes;
                    end
                end
            end
            fclose('all');
        end
        eval(['narrallwbtdailymaxes' num2str(year) '=narrallwbtdailymaxesthisyear;']);
        savehelper; %saves and then clears so as not to overwhelm the workspace
    end
    disp(clock);
end

%Create NARR daily climatology of WBTmax
%Uses the arrays calculated in the previous loop
%5-day smoothing of 0.1-0.2-0.4-0.2-0.1 is applied for each day
if calcnarrdailyclimowbtmax==1
    narrwbtclimobydoy=NaN.*ones(277,349,366);
    for doy=121:274 %min and max possible DOY for May 1 and Sep 30, considering both leap and regular years
        for year=yeariwf:yeariwl
            relyear=year-yeariwf+1;
            temp=load(strcat('narrallwbtdailymaxes',num2str(year)));
            if doy>=123 && doy<=272
                yeararrays(relyear,:,:,doy-2:doy+2)=temp(:,:,doy-2:doy+2);
            elseif doy==122 || doy==273
                yeararrays(relyear,:,:,doy-1:doy+1)=temp(:,:,doy-1:doy+1);
            else
                yeararrays(relyear,:,:,doy)=temp(:,:,doy);
            end
            clear temp;
        end
        if doy>=123 && doy<=272
            narrwbtclimobydoy(:,:,doy)=0.1.*permute(nanmean(yeararrays(:,:,:,doy-2)),[2 3 1])+...
                0.2.*permute(mean(yeararrays(:,:,:,doy-1)),[2 3 1])+...
                0.4.*permute(mean(yeararrays(:,:,:,doy)),[2 3 1])+...
                0.2.*permute(mean(yeararrays(:,:,:,doy+1)),[2 3 1])+...
                0.1.*permute(mean(yeararrays(:,:,:,doy+2)),[2 3 1]);
        elseif doy==122 || doy==273
            narrwbtclimobydoy(:,:,doy)=0.25.*permute(nanmean(yeararrays(:,:,:,doy-1)),[2 3 1])+...
                0.5.*permute(mean(yeararrays(:,:,:,doy)),[2 3 1])+...
                0.25.*permute(mean(yeararrays(:,:,:,doy+1)),[2 3 1]);
        elseif doy==121 || doy==274
            narrwbtclimobydoy(:,:,doy)=permute(nanmean(yeararrays(:,:,:,doy)),[2 3 1]);
        end
        clear yeararrays;
    end
    disp(clock);
end

%Use both of the above loops to create anomalies of WBTmax for all NARR gridpts for every day
if calcnarrdailyanomwbtmax==1
    narrwbtanombydoy=NaN.*ones(yeariwl-yeariwf+1,277,349,366);
    for year=yeariwf:yeariwl
        relyear=year-yeariwf+1;
        thisyeardata=eval(['narrallwbtdailymaxes' num2str(year) ';']);
        narrwbtanombydoy(relyear,:,:,:)=thisyeardata-narrwbtclimobydoy;
    end
    disp(clock);
end

%Use dailymaxstruc to find seasonal-mean of max T, WBT, and q for each stn-year combo, and these
    %time series will then be compared in exploratorydataanalysis to the time series of top-XX counts
%Define 'season' as Jun-Aug for purposes of simplicity
%Also find the station & regional average of the top 3 days in each year
if calcseasonalmeantwbtq==1
    seasonalmeantbystn=0;seasonalmeanwbtbystn=0;seasonalmeanqbystn=0;
    for stn=1:maxnumstns
        for year=1:yeariwl-yeariwf+1
            top3dayst{stn,year}=zeros(3,4);top3dayswbt{stn,year}=zeros(3,4);top3daysq{stn,year}=zeros(3,4);
            
            %Eliminate zeros by turning them into NaN's
            for i=2:4 %just the rows of dailymaxtstruc
                temp1=dailymaxtstruc{stn,year,i};temp2=temp1==0;temp1(temp2)=NaN;dailymaxtstruc{stn,year,i}=temp1;
                temp1=dailymaxwbtstruc{stn,year,i};temp2=temp1==0;temp1(temp2)=NaN;dailymaxwbtstruc{stn,year,i}=temp1;
                temp1=dailymaxqstruc{stn,year,i};temp2=temp1==0;temp1(temp2)=NaN;dailymaxqstruc{stn,year,i}=temp1;
            end
            %Now calculate seasonal means excluding these NaN's, but only if there are relatively few of them (<10% of obs)
            %If there are too many, have to make seasonal mean for this stn-year NaN as well :-(
            seasonalmeantbystn(stn,year)=(nanmean(dailymaxtstruc{stn,year,2})+nanmean(dailymaxtstruc{stn,year,3})+...
                nanmean(dailymaxtstruc{stn,year,4}))/3;
            tnansthisstnyear=sum(isnan(dailymaxtstruc{stn,year,2}))+sum(isnan(dailymaxtstruc{stn,year,3}))+...
                sum(isnan(dailymaxtstruc{stn,year,4}));
            if tnansthisstnyear>=0.1*92;seasonalmeantbystn(stn,year)=NaN;end
            
            seasonalmeanwbtbystn(stn,year)=(nanmean(dailymaxwbtstruc{stn,year,2})+nanmean(dailymaxwbtstruc{stn,year,3})+...
                nanmean(dailymaxwbtstruc{stn,year,4}))/3;
            wbtnansthisstnyear=sum(isnan(dailymaxwbtstruc{stn,year,2}))+sum(isnan(dailymaxwbtstruc{stn,year,3}))+...
                sum(isnan(dailymaxwbtstruc{stn,year,4}));
            if wbtnansthisstnyear>=0.1*92;seasonalmeanwbtbystn(stn,year)=NaN;end
            
            seasonalmeanqbystn(stn,year)=(nanmean(dailymaxqstruc{stn,year,2})+nanmean(dailymaxqstruc{stn,year,3})+...
                nanmean(dailymaxqstruc{stn,year,4}))/3;
            qnansthisstnyear=sum(isnan(dailymaxqstruc{stn,year,2}))+sum(isnan(dailymaxqstruc{stn,year,3}))+...
                sum(isnan(dailymaxqstruc{stn,year,4}));
            if qnansthisstnyear>=0.1*92;seasonalmeanqbystn(stn,year)=NaN;end
            
            
            %Average of top 3 days from each year
            for month=1:6
                for day=1:monthlengthsdays(month)
                    if dailymaxtstruc{stn,year,month}(day)>top3dayst{stn,year}(3,1)
                        top3dayst{stn,year}(3,1)=dailymaxtstruc{stn,year,month}(day);
                        top3dayst{stn,year}(3,2)=year+yeariwf-1;top3dayst{stn,year}(3,3)=month+monthiwf-1;
                        top3dayst{stn,year}(3,4)=day;
                        top3dayst{stn,year}=sortrows(top3dayst{stn,year},-1);
                    end
                    if dailymaxwbtstruc{stn,year,month}(day)>top3dayswbt{stn,year}(3,1)
                        top3dayswbt{stn,year}(3,1)=dailymaxwbtstruc{stn,year,month}(day);
                        top3dayswbt{stn,year}(3,2)=year+yeariwf-1;top3dayswbt{stn,year}(3,3)=month+monthiwf-1;
                        top3dayswbt{stn,year}(3,4)=day;
                        top3dayswbt{stn,year}=sortrows(top3dayswbt{stn,year},-1);
                    end
                    if dailymaxqstruc{stn,year,month}(day)>top3daysq{stn,year}(3,1)
                        top3daysq{stn,year}(3,1)=dailymaxqstruc{stn,year,month}(day);
                        top3daysq{stn,year}(3,2)=year+yeariwf-1;top3daysq{stn,year}(3,3)=month+monthiwf-1;
                        top3daysq{stn,year}(3,4)=day;
                        top3daysq{stn,year}=sortrows(top3daysq{stn,year},-1);
                    end
                end
            end
        end
    end
    %Set zeros to NaN so they don't interfere with future sums or averages
    for stn=1:maxnumstns
        for year=1:yeariwl-yeariwf+1
            temp=top3dayst{stn,year}==0;top3dayst{stn,year}(temp)=NaN;temp=top3dayswbt{stn,year}==0;top3dayswbt{stn,year}(temp)=NaN;
            temp=top3daysq{stn,year}==0;top3daysq{stn,year}(temp)=NaN;
        end
    end

    tsumoverstns=zeros(8,yeariwl-yeariwf+1);wbtsumoverstns=zeros(8,yeariwl-yeariwf+1);qsumoverstns=zeros(8,yeariwl-yeariwf+1);
    tvalidstnc=zeros(8,yeariwl-yeariwf+1);wbtvalidstnc=zeros(8,yeariwl-yeariwf+1);qvalidstnc=zeros(8,yeariwl-yeariwf+1);
    for region=1:8
        %Seasonal means by region
        %Also: average of top-3 days by region and year
        thisregionstnlist=stnordinateseachregion{region};
        stncthisregion=1;temp1=zeros(1,yeariwl-yeariwf+1);temp2=zeros(1,yeariwl-yeariwf+1);temp3=zeros(1,yeariwl-yeariwf+1);
        for stn=1:size(thisregionstnlist,2)
            temp1(stncthisregion,:)=seasonalmeantbystn(thisregionstnlist(stn),:);
            temp2(stncthisregion,:)=seasonalmeanwbtbystn(thisregionstnlist(stn),:);
            temp3(stncthisregion,:)=seasonalmeanqbystn(thisregionstnlist(stn),:);
            for year=1:yeariwl-yeariwf+1
                if ~isnan(nanmean(top3dayst{thisregionstnlist(stn),year}(:,1)))
                    tsumoverstns(region,year)=tsumoverstns(region,year)+nanmean(top3dayst{thisregionstnlist(stn),year}(:,1));
                    tvalidstnc(region,year)=tvalidstnc(region,year)+1;
                end
                if ~isnan(nanmean(top3dayswbt{thisregionstnlist(stn),year}(:,1)))
                    wbtsumoverstns(region,year)=wbtsumoverstns(region,year)+nanmean(top3dayswbt{thisregionstnlist(stn),year}(:,1)); 
                    wbtvalidstnc(region,year)=wbtvalidstnc(region,year)+1;
                end
                if ~isnan(nanmean(top3daysq{thisregionstnlist(stn),year}(:,1)))
                    qsumoverstns(region,year)=qsumoverstns(region,year)+nanmean(top3daysq{thisregionstnlist(stn),year}(:,1));
                    qvalidstnc(region,year)=qvalidstnc(region,year)+1;
                end
            end
            stncthisregion=stncthisregion+1;
        end
        
        %Average of top-3 days by station
        for stn=1:maxnumstns
            for year=1:yeariwl-yeariwf+1
                tavgeachstn(stn,year)=0;wbtavgeachstn(stn,year)=0;qavgeachstn(stn,year)=0;
                
                tavgeachstn(stn,year)=tavgeachstn(stn,year)+nanmean(top3dayst{stn,year}(:,1));
                wbtavgeachstn(stn,year)=wbtavgeachstn(stn,year)+nanmean(top3dayswbt{stn,year}(:,1));
                qavgeachstn(stn,year)=qavgeachstn(stn,year)+nanmean(top3daysq{stn,year}(:,1));
            end
        end
        
        for year=1:yeariwl-yeariwf+1
            tavgoverstns(region,year)=tsumoverstns(region,year)./tvalidstnc(region,year);
            wbtavgoverstns(region,year)=wbtsumoverstns(region,year)./wbtvalidstnc(region,year);
            qavgoverstns(region,year)=qsumoverstns(region,year)./qvalidstnc(region,year);
        end
        seasonalmeantbyregion(region,:)=nanmean(temp1);
        seasonalmeanwbtbyregion(region,:)=nanmean(temp2);
        seasonalmeanqbyregion(region,:)=nanmean(temp3);
    end
    save(strcat(curDir,'extraarrays'),'seasonalmeantbystn','seasonalmeanwbtbystn','seasonalmeanqbystn',...
        'seasonalmeantbyregion','seasonalmeanwbtbyregion','seasonalmeanqbyregion','tavgoverstns',...
        'wbtavgoverstns','qavgoverstns','tavgeachstn','wbtavgeachstn','qavgeachstn','-append');
end

%T, WBT, and q averaged for each hour of the day, each month, and each stn
%Also computes climatologies of daily maxes at each month and each stn
if calchourlyclimotwbtqeachmonth==1
    allvaluesthishourofdayandmonth={};alldailymaxesthismonth={};
    for var=1:3
        if var==1
            finaldata=finaldatat;
        elseif var==2
            finaldata=finaldatawbt;
        elseif var==3
            finaldata=finaldataq;
        end
        
        for stn=1:maxnumstns
            fprintf('Hourly climo for var %d and stn %d\n',var,stn);
            curstnnum=newstnNumList(stn);[curstnname,~,~,curstntz]=stationinfofromnumber(curstnnum);
            sumthishourofdayandmonth=zeros(24,6);sumdailymaxesthismonth=zeros(1,6);
            totalc=zeros(24,6);dayc=zeros(1,6);
            for month=1:6
                tmstarth=monthhourstarts(month);tmstoph=monthhourstops(month);
                for year=1:35
                    %Same month selon both UTC and LST
                    %Hourly data
                    for hourinmonth=tmstarth+curstntz+1:tmstoph
                        thishourofdaylst=rem(hourinmonth-curstntz,24);
                        if thishourofdaylst<=0;thishourofdaylst=thishourofdaylst+24;end %so it can be used as an index in an array...
                        if ~isnan(finaldata{year,stn}(hourinmonth)) && finaldata{year,stn}(hourinmonth)~=0
                            sumthishourofdayandmonth(thishourofdaylst,month)=sumthishourofdayandmonth(thishourofdaylst,month)+...
                                finaldata{year,stn}(hourinmonth);
                            totalc(thishourofdaylst,month)=totalc(thishourofdaylst,month)+1;
                            allvaluesthishourofdayandmonth{var,stn,thishourofdaylst,month}(totalc(thishourofdaylst,month))=...
                                finaldata{year,stn}(hourinmonth);
                            %also do this for daily maxes
                            if rem(hourinmonth,24+tmstarth+curstntz)==0 %the end of another day
                                sumdailymaxesthismonth(month)=...
                                    sumdailymaxesthismonth(month)+max(finaldata{year,stn}(hourinmonth-23:hourinmonth));
                                dayc(month)=dayc(month)+1;
                                alldailymaxesthismonth{var,stn,month}(dayc(month))=max(finaldata{year,stn}(hourinmonth-23:hourinmonth));
                            end
                        end
                        %disp(finaldatat{year,stn}(hourinmonth));
                    end
                   
                    
                    %Next month selon UTC, same month selon LST -- don't bother
                    %for hourinmonth=1:curstntz+1
                    %    thishourofdaylst=rem(hourinmonth-curstntz,24);
                    %    if thishourofdaylst<=0;thishourofdaylst=thishourofdaylst+24;end
                    %    if ~isnan(finaldata{year,stn}(hourinmonth)) && finaldata{year,stn}(hourinmonth)>0
                    %        sumthishourofdayandmonth(thishourofdaylst,month)=sumthishourofdayandmonth(thishourofdaylst,month)+...
                    %            finaldata{year,stn}(hourinmonth);
                    %        totalc(thishourofdaylst,month)=totalc(thishourofdaylst,month)+1;
                    %        allvaluesthishourofdayandmonth{var,stn,thishourofdaylst,month}(totalc(thishourofdaylst,month))=...
                    %            finaldata{year,stn}(hourinmonth);
                    %    end
                    %end
                end
                for hourofday=1:24
                    avgthishourofdayandmonth{var}(stn,month,hourofday)=...
                        sumthishourofdayandmonth(hourofday,month)./(totalc(hourofday,month));
                    stdevthishourofdayandmonth{var}(stn,month,hourofday)=...
                        std(allvaluesthishourofdayandmonth{var,stn,hourofday,month});
                end
                avgdailymaxthismonth{var}(stn,month)=sumdailymaxesthismonth(month)./(dayc(month));
            end
        end
    end
    save(strcat(curDir,'essentialarrays'),'allvaluesthishourofdayandmonth','avgthishourofdayandmonth','stdevthishourofdayandmonth',...
        'alldailymaxesthismonth','avgdailymaxthismonth','-append');
end

%A further refined climatology calculation, where
%T, WBT, and q are averaged for each hour of the day, day of the year, and stn
    %Note that midnight is filed under LST=24:00
%Also computes climatologies of daily maxes for each day of the year and each stn
if calchourlyclimotwbtqeachdoy==1
    allvaluesthishourofdayanddoy={};alldailymaxesthisdoy={};
    for var=1:3
        if var==1
            finaldata=finaldatat;
        elseif var==2
            finaldata=finaldatawbt;
        elseif var==3
            finaldata=finaldataq;
        end
        
        for stn=1:maxnumstns
        %for stn=94:94
            fprintf('Hourly climo by doy for var %d and stn %d\n',var,stn);
            curstnnum=newstnNumList(stn);[curstnname,~,~,curstntz]=stationinfofromnumber(curstnnum);
            sumthishourofdayanddoy=zeros(24,366);sumdailymaxesthisdoy=zeros(1,366);
            totalc=zeros(24,366);dayc=zeros(1,366);
            for doy=doyiwf:doyiwl
                for year=2:35 %1981 data at many stations is mistimed and therefore unreliable
                    %Hourly data
                    for hourinday=curstntz+1:curstntz+24
                        thishourofdaylst=hourinday-curstntz;
                        if thishourofdaylst<=0;thishourofdaylst=thishourofdaylst+24;end %so it can be used as an index in an array...
                        if ~isnan(finaldata{year,stn}((doy-doyiwf+1)*24-23+hourinday)) && finaldata{year,stn}((doy-doyiwf+1)*24-23+hourinday)~=0
                            %if doy==181 && var==1;fprintf('For doy=181, stn=94, year=%d, hour of day lst=%d, t is %d\n',...
                            %        year,thishourofdaylst,finaldatat{year,stn}((doy-doyiwf+1)*24-23+hourinday));end
                            sumthishourofdayanddoy(thishourofdaylst,doy)=sumthishourofdayanddoy(thishourofdaylst,doy)+...
                                finaldata{year,stn}(hourinday);
                            totalc(thishourofdaylst,doy)=totalc(thishourofdaylst,doy)+1;
                            allvaluesthishourofdayanddoy{var,stn,thishourofdaylst,doy}(totalc(thishourofdaylst,doy))=...
                                finaldata{year,stn}((doy-doyiwf+1)*24-23+hourinday);
                            %also do this for daily maxes
                            if rem(hourinday,24+curstntz)==0 %the end of another day
                                sumdailymaxesthisdoy(doy)=...
                                    sumdailymaxesthisdoy(doy)+max(finaldata{year,stn}((doy-doyiwf+1)*24-23+hourinday:(doy-doyiwf+1)*24+hourinday));
                                dayc(doy)=dayc(doy)+1;
                                alldailymaxesthisdoy{var,stn,doy}(dayc(doy))=...
                                    max(finaldata{year,stn}((doy-doyiwf+1)*24-23+hourinday:(doy-doyiwf+1)*24+hourinday));
                            end
                        end
                        %disp(finaldatat{year,stn}(hourinday));
                    end
                end
            end
            
            %Climatology for each DOY is calculated using the days adjacent to it
            for hourofday=1:24
                %fprintf('Calculating climatology for hour %d\n',hourofday);
                for doy=doyiwf:doyiwl
                    if doy==doyiwf
                        avgthishourofdayanddoy{var}(stn,doy,hourofday)=...
                            0.7*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy})+...
                            0.3*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy+1});
                    elseif doy==doyiwf+1
                        avgthishourofdayanddoy{var}(stn,doy,hourofday)=...
                            0.25*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy-1})+...
                            0.5*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy})+...
                            0.25*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy+1});
                    elseif doy==doyiwf+2
                        avgthishourofdayanddoy{var}(stn,doy,hourofday)=...
                            0.1*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy-2})+...
                            0.2*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy-1})+...
                            0.4*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy})+...
                            0.2*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy+1})+...
                            0.1*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy+2});
                    elseif doy<=doyiwl-3
                        avgthishourofdayanddoy{var}(stn,doy,hourofday)=...
                            0.05*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy-3})+...
                            0.1*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy-2})+...
                            0.2*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy-1})+...
                            0.3*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy})+...
                            0.2*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy+1})+...
                            0.1*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy+2})+...
                            0.05*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy+3});
                    elseif doy==doyiwl-2
                        avgthishourofdayanddoy{var}(stn,doy,hourofday)=...
                            0.1*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy-2})+...
                            0.2*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy-1})+...
                            0.4*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy})+...
                            0.2*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy+1})+...
                            0.1*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy+2});
                    elseif doy==doyiwl-1
                        avgthishourofdayanddoy{var}(stn,doy,hourofday)=...
                            0.25*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy-1})+...
                            0.5*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy})+...
                            0.25*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy+1});
                    elseif doy==doyiwl
                        avgthishourofdayanddoy{var}(stn,doy,hourofday)=...
                            0.3*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy-1})+...
                            0.7*mean(allvaluesthishourofdayanddoy{var,stn,hourofday,doy});
                    end
                end
            end
        end
    end
    save(strcat(curDir,'essentialarrays'),'allvaluesthishourofdayanddoy','alldailymaxesthisdoy','avgthishourofdayanddoy','-append');
end

%Improved climatology, using harmonics, following the methodology of Lee & Grotjahn 2016
if calcimprovedhourlyclimo==1
    for var=1:3
        for stn=1:maxnumstns
            disp(stn);
            %First, calculate the raw mean of each hour of the day & day of the year, at each station
            for dayofyear=121:302
                for hourofday=1:24
                    improvedavgeachdayanddoy(var,stn,dayofyear,hourofday)=nanmean(allvaluesthishourofdayanddoy{var,stn,hourofday,dayofyear});
                    improvedstdeveachdayanddoy(var,stn,dayofyear,hourofday)=nanstd(allvaluesthishourofdayanddoy{var,stn,hourofday,dayofyear});
                end
            end
            temp=improvedavgeachdayanddoy==0;improvedavgeachdayanddoy(temp)=NaN;
            temp=improvedstdeveachdayanddoy==0;improvedstdeveachdayanddoy(temp)=NaN;
            
            %t=linspace(0,2*pi,182)'; 
            %thisfourier=squeeze(fft(improvedavgeachdayanddoy(var,stn,121:302,hourofday)));
            
            %dothefit=harmfit(t,temp,1:10);
            %Recombine into the full fit
            %fullfit=0;partialfit=zeros(4,182);
            %for i=1:size(dothefit,1)
            %    fullfit=fullfit+dothefit(i,2).*cos(i.*t+dothefit(i,3));
            %    partialfit(i,:)=dothefit(i,2).*cos(i.*t+dothefit(i,3));
            %end
            
            for hourofday=1:24
                avgsqueeze=squeeze(improvedavgeachdayanddoy(var,stn,121:302,hourofday));
                stdevsqueeze=squeeze(improvedstdeveachdayanddoy(var,stn,121:302,hourofday));
                %Compute best fit separately for each hour (using n=4 as suggested by reviewer #2), which can be verified with the interactive curve-fitting tool
                dayvec=[1:182]';
                thisfitavg=fit(dayvec,avgsqueeze,'fourier4');
                thisfitstdev=fit(dayvec,stdevsqueeze,'fourier4');
                %plot(thisfitavg,dayvec,temp) %verification
                fittedvalsavg=thisfitavg(dayvec);
                newfitavg(var,stn,:,hourofday)=fittedvalsavg;
                fittedvalsstdev=thisfitstdev(dayvec);
                newfitstdev(var,stn,:,hourofday)=fittedvalsstdev;
            end
        end
    end
    save(strcat(curDir,'essentialarrays'),'newfitavg','newfitstdev','-append');
    
    makeexampleplot=0;
    if makeexampleplot==1
        figure(figc);clf;figc=figc+1;curpart=1;highqualityfiguresetup;
        thingtoplot=[NaN.*ones(120,1);squeeze(newfitavg(1,179,:,6));NaN.*ones(63,1)];
        plot(thingtoplot,'linewidth',2);
        set(gca,'fontname','arial','fontsize',12,'fontweight','bold');
        title('Smoothed Climatology for Noon LST at JFK Airport, NY','fontname','arial','fontsize',16,'fontweight','bold');
        ylabel('Temperature (C)','fontname','arial','fontsize',14,'fontweight','bold');
        xlabel('Day of the Year','fontname','arial','fontsize',14,'fontweight','bold');
        xlim([0 365]);
        curpart=2;figloc=curDir;figname='exampleplotnewclimo';
        highqualityfiguresetup;
    end
end

%Uses the hourly month-by-month averages to calculate hourly anomalies of T and q for each station's every instance of extreme WBT
    %In exploratorydataanalysis, will plot the median (& maybe the 5th- & 95th-pctile) T and q anoms-from-hourly-climo at hour of extreme WBT
%Also finds the median, 5th, and 95th pctiles of the difference b/w the median hour when T stan anom > q stan anom, and when q stan anom > T stan anom
    %This little exercise is intended to replace the old maptqdiffs figures that are no longer as relevant with the T and q rankings having been scrapped
%This is effectively a simpler answer to the question addressed in the determinetandqeffectsonwbt loop
    %and thus hopefully more defensible
%Regions 9 and 10 can either be 'swcoast' and 'swinterior', OR 'aznm' and 'othersw' (need to find & replace if switching between)
if tqanomsextremewbt==1
    corresptval={};correspqval={};corresptanom={};correspqanom={};corresptanomreltomjjasoallhours={};correspqanomreltomjjasoallhours={};
    corresptanomstan={};correspqanomstan={};
    hoursofextremewbttstananomgreater={};hoursofextremewbtqstananomgreater={};
    datesofextremewbttstananomgreater={};datesofextremewbtqstananomgreater={};
    regcorresptanomstanbyregandyr={};regcorrespqanomstanbyregandyr={};
    regcorresptanomstanbyregandmn={};regcorrespqanomstanbyregandmn={};
    regcorresptvalbyregandmn={};regcorrespqvalbyregandmn={};
    regcorresptvalbyregandmnswcoast={};regcorrespqvalbyregandmnswcoast={};
    regcorresptvalbyregandmnaznm={};regcorrespqvalbyregandmnaznm={};
    regcorresptanomreltomjjasoallhoursbyregandmnswcoast={};regcorrespqanomreltomjjasoallhoursbyregandmnswcoast={};
    regcorresptanomreltomjjasoallhoursbyregandmnaznm={};regcorrespqanomreltomjjasoallhoursbyregandmnaznm={};
    regcorresptanomstanreltomjjasoallhoursbyregandmnswcoast={};regcorrespqanomstanreltomjjasoallhoursbyregandmnswcoast={};
    regcorresptanomstanreltomjjasoallhoursbyregandmnaznm={};regcorrespqanomstanreltomjjasoallhoursbyregandmnaznm={};
    for j=1:8
        eval(['reg' num2str(j) 'cbyyear=zeros(yeariwl-yeariwf+1,1);']);
        eval(['reg' num2str(j) 'cbymonth=zeros(monthiwl-monthiwf+1,1);']);
    end
    regcswcoastbymonth=ones(monthiwl-monthiwf+1,1);regcaznmbymonth=ones(monthiwl-monthiwf+1,1);
    for stn=1:maxnumstns
        extremewbt=topXXwbtbystn{stn};tstananomgtc=0;qstananomgtc=0;
        thisregion=ncaregionnum{stn};
        regcbyyear=eval(['reg' num2str(thisregion) 'cbyyear;']);
        regcbymonth=eval(['reg' num2str(thisregion) 'cbymonth;']);
        for row=1:numdates
            thisval=extremewbt(row,1);thisyear=extremewbt(row,2)-yeariwf+1;thismonth=extremewbt(row,3);thismonthrel=thismonth-monthiwf+1;
            thisday=extremewbt(row,4);thishour=extremewbt(row,5);if thishour==0;thishour=thishour+24;end
            thisdoy=DatetoDOY(thismonth,thisday,thisyear);if thisdoy>=303;thisdoy=302;end
            corresptval{stn}(row)=correspt{stn}(row);
            correspqval{stn}(row)=correspq{stn}(row);
            corresptanom{stn}(row)=corresptval{stn}(row)-newfitavg(1,stn,thisdoy-120,thishour);
            %correspqanom{stn}(row)=correspqval{stn}(row)-avgthishourofdayandmonth{3}(stn,thismonth,thishour);
            correspqanom{stn}(row)=correspqval{stn}(row)-newfitavg(3,stn,thisdoy-120,thishour);
            corresptanomreltomjjasoallhours{stn}(row)=corresptval{stn}(row)-mean(mean(newfitavg(1,stn,thisdoy-120,thishour)));
            correspqanomreltomjjasoallhours{stn}(row)=correspqval{stn}(row)-mean(mean(newfitavg(3,stn,thisdoy-120,thishour)));
            wbtanom{stn}(row)=thisval-newfitavg(2,stn,thisdoy-120,thishour);
            %Standardized anomalies
            corresptanomstan{stn}(row)=corresptanom{stn}(row)./newfitstdev(1,stn,thisdoy-120,thishour);
            correspqanomstan{stn}(row)=correspqanom{stn}(row)./newfitstdev(3,stn,thisdoy-120,thishour);
            corresptanomstanreltomjjasoallhours{stn}(row)=corresptanomreltomjjasoallhours{stn}(row)./mean(mean(newfitstdev(1,stn,thisdoy-120,thishour)));
            correspqanomstanreltomjjasoallhours{stn}(row)=correspqanomreltomjjasoallhours{stn}(row)./mean(mean(newfitstdev(3,stn,thisdoy-120,thishour)));
            wbtanomstan{stn}(row)=wbtanom{stn}(row)./newfitstdev(2,stn,thisdoy-120,thishour);
            %Save vals and stan anoms into a big matrix for regional analysis a little further down
            %Save for every incidence (i.e. day) of extreme WBT at every station within a region for that year
            regcbyyear(thisyear)=regcbyyear(thisyear)+1;
            regcorresptanomstanbyregandyr{thisregion,thisyear}(regcbyyear(thisyear))=corresptanomstan{stn}(row);
            regcorrespqanomstanbyregandyr{thisregion,thisyear}(regcbyyear(thisyear))=correspqanomstan{stn}(row);
            %Vals and stan anoms for every incidence of extreme WBT at every station within a region for each month
            regcbymonth(thismonthrel)=regcbymonth(thismonthrel)+1;
            regcorresptanomstanbyregandmn{thisregion,thismonthrel}(regcbymonth(thismonthrel))=corresptanomstan{stn}(row);
            regcorrespqanomstanbyregandmn{thisregion,thismonthrel}(regcbymonth(thismonthrel))=correspqanomstan{stn}(row);
            regcorresptvalbyregandmn{thisregion,thismonthrel}(regcbymonth(thismonthrel))=corresptval{stn}(row);
            regcorrespqvalbyregandmn{thisregion,thismonthrel}(regcbymonth(thismonthrel))=correspqval{stn}(row);
            regcorresptanomreltomjjasoallhoursbyregandmn{thisregion,thismonthrel}(regcbymonth(thismonthrel))=corresptanomreltomjjasoallhours{stn}(row);
            regcorrespqanomreltomjjasoallhoursbyregandmn{thisregion,thismonthrel}(regcbymonth(thismonthrel))=correspqanomreltomjjasoallhours{stn}(row);
            regcorresptanomstanreltomjjasoallhoursbyregandmn{thisregion,thismonthrel}(regcbymonth(thismonthrel))=corresptanomstanreltomjjasoallhours{stn}(row);
            regcorrespqanomstanreltomjjasoallhoursbyregandmn{thisregion,thismonthrel}(regcbymonth(thismonthrel))=correspqanomstanreltomjjasoallhours{stn}(row);
            if checkifthingsareelementsofvector(stnordinatesswcoast,stn)
                regcorresptanomstanbyregandmnswcoast{thismonthrel}(regcswcoastbymonth(thismonthrel))=corresptanomstan{stn}(row);
                regcorrespqanomstanbyregandmnswcoast{thismonthrel}(regcswcoastbymonth(thismonthrel))=correspqanomstan{stn}(row);
                regcorresptvalbyregandmnswcoast{thismonthrel}(regcswcoastbymonth(thismonthrel))=corresptval{stn}(row);
                regcorrespqvalbyregandmnswcoast{thismonthrel}(regcswcoastbymonth(thismonthrel))=correspqval{stn}(row);
                regcorresptanomreltomjjasoallhoursbyregandmnswcoast{thismonthrel}(regcswcoastbymonth(thismonthrel))=...
                    corresptanomreltomjjasoallhours{stn}(row);
                regcorrespqanomreltomjjasoallhoursbyregandmnswcoast{thismonthrel}(regcswcoastbymonth(thismonthrel))=...
                    correspqanomreltomjjasoallhours{stn}(row);
                regcorresptanomstanreltomjjasoallhoursbyregandmnswcoast{thismonthrel}(regcswcoastbymonth(thismonthrel))=...
                    corresptanomstanreltomjjasoallhours{stn}(row);
                regcorrespqanomstanreltomjjasoallhoursbyregandmnswcoast{thismonthrel}(regcswcoastbymonth(thismonthrel))=...
                    correspqanomstanreltomjjasoallhours{stn}(row);
                regcswcoastbymonth(thismonthrel)=regcswcoastbymonth(thismonthrel)+1;
            elseif checkifthingsareelementsofvector(stnordinatesaznm,stn)
                regcorresptanomstanbyregandmnaznm{thismonthrel}(regcaznmbymonth(thismonthrel))=corresptanomstan{stn}(row);
                regcorrespqanomstanbyregandmnaznm{thismonthrel}(regcaznmbymonth(thismonthrel))=correspqanomstan{stn}(row);
                regcorresptvalbyregandmnaznm{thismonthrel}(regcaznmbymonth(thismonthrel))=corresptval{stn}(row);
                regcorrespqvalbyregandmnaznm{thismonthrel}(regcaznmbymonth(thismonthrel))=correspqval{stn}(row);
                regcorresptanomreltomjjasoallhoursbyregandmnaznm{thismonthrel}(regcaznmbymonth(thismonthrel))=...
                    corresptanomreltomjjasoallhours{stn}(row);
                regcorrespqanomreltomjjasoallhoursbyregandmnaznm{thismonthrel}(regcaznmbymonth(thismonthrel))=...
                    correspqanomreltomjjasoallhours{stn}(row);
                regcorresptanomstanreltomjjasoallhoursbyregandmnaznm{thismonthrel}(regcaznmbymonth(thismonthrel))=...
                    corresptanomstanreltomjjasoallhours{stn}(row);
                regcorrespqanomstanreltomjjasoallhoursbyregandmnaznm{thismonthrel}(regcaznmbymonth(thismonthrel))=...
                    correspqanomstanreltomjjasoallhours{stn}(row);
                regcaznmbymonth(thismonthrel)=regcaznmbymonth(thismonthrel)+1;
            end
            %Difference between T and q stan anoms
            corresptanomstanqanomstan{stn}(row)=corresptanomstan{stn}(row)-correspqanomstan{stn}(row);
        end
        eval(['reg' num2str(thisregion) 'cbyyear=regcbyyear;']);
        eval(['reg' num2str(thisregion) 'cbymonth=regcbymonth;']);
        %Make two arrays for both hours and days of year, one only where (T stan anom > q stan anom)>stn median of this difference,
                %and the other vice versa
        corresptanomstanqanomstanmedian{stn}=quantile(corresptanomstanqanomstan{stn},0.5); %median (T stan anom minus q stan anom) for this stn
        for row=1:numdates
            thisval=extremewbt(row,1);thisyear=extremewbt(row,2)-yeariwf+1;thismonth=extremewbt(row,3)-monthiwf+1;
            thisday=extremewbt(row,4);thishour=extremewbt(row,5);if thishour==0;thishour=thishour+24;end
            thisdoy=DatetoDOY(thismonth,thisday,thisyear);
            if corresptanomstanqanomstan{stn}(row)>corresptanomstanqanomstanmedian{stn}
                tstananomgtc=tstananomgtc+1;
                hoursofextremewbttstananomgreater{stn}(tstananomgtc)=thishour;
                datesofextremewbttstananomgreater{stn}(tstananomgtc)=thisdoy;
            else
                qstananomgtc=qstananomgtc+1;
                hoursofextremewbtqstananomgreater{stn}(qstananomgtc)=thishour;
                datesofextremewbtqstananomgreater{stn}(qstananomgtc)=thisdoy;
            end
        end
        %To finish off this exercise, calculate the median in each case, and the difference between these medians
        %Conclusion: none of these differences are statistically significant
        p5hourofextremewbtwithtstananomgreater(stn)=quantile(hoursofextremewbttstananomgreater{stn},0.05);
        p5hourofextremewbtwithqstananomgreater(stn)=quantile(hoursofextremewbtqstananomgreater{stn},0.05);
        p50hourofextremewbtwithtstananomgreater(stn)=quantile(hoursofextremewbttstananomgreater{stn},0.5);
        p50hourofextremewbtwithqstananomgreater(stn)=quantile(hoursofextremewbtqstananomgreater{stn},0.5);
        p95hourofextremewbtwithtstananomgreater(stn)=quantile(hoursofextremewbttstananomgreater{stn},0.95);
        p95hourofextremewbtwithqstananomgreater(stn)=quantile(hoursofextremewbtqstananomgreater{stn},0.95);
        diffbetweenmedianhours(stn)=p50hourofextremewbtwithtstananomgreater(stn)-p50hourofextremewbtwithqstananomgreater(stn);
        p5dateofextremewbtwithtstananomgreater(stn)=quantile(datesofextremewbttstananomgreater{stn},0.05);
        p5dateofextremewbtwithqstananomgreater(stn)=quantile(datesofextremewbtqstananomgreater{stn},0.05);
        p50dateofextremewbtwithtstananomgreater(stn)=quantile(datesofextremewbttstananomgreater{stn},0.5);
        p50dateofextremewbtwithqstananomgreater(stn)=quantile(datesofextremewbtqstananomgreater{stn},0.5);
        p95dateofextremewbtwithtstananomgreater(stn)=quantile(datesofextremewbttstananomgreater{stn},0.95);
        p95dateofextremewbtwithqstananomgreater(stn)=quantile(datesofextremewbtqstananomgreater{stn},0.95);
        diffbetweenmediandates(stn)=p50dateofextremewbtwithtstananomgreater(stn)-p50dateofextremewbtwithqstananomgreater(stn);
        p5hourtstananomgreaterminusp95qstananomgreater(stn)=p5hourofextremewbtwithtstananomgreater(stn)-p95hourofextremewbtwithqstananomgreater(stn);
        p5datetstananomgreaterminusp95qstananomgreater(stn)=p5dateofextremewbtwithtstananomgreater(stn)-p95dateofextremewbtwithqstananomgreater(stn);
        p5hourqstananomgreaterminusp95tstananomgreater(stn)=p5hourofextremewbtwithqstananomgreater(stn)-p95hourofextremewbtwithtstananomgreater(stn);
        p5dateqstananomgreaterminusp95tstananomgreater(stn)=p5dateofextremewbtwithqstananomgreater(stn)-p95dateofextremewbtwithtstananomgreater(stn);
            
        %5th, 50th, and 95th percentiles of values, anomalies, and standardized anomalies of T and q during extreme WBT for this station
            %(defining the envelope for what happens during extreme WBT)
        p5correspt(stn)=quantile(correspt{stn},0.05);p50correspt(stn)=quantile(correspt{stn},0.5);p95correspt(stn)=quantile(correspt{stn},0.95);
        p5correspq(stn)=quantile(correspq{stn},0.05);p50correspq(stn)=quantile(correspq{stn},0.5);p95correspq(stn)=quantile(correspq{stn},0.95);
        p5corresptanom(stn)=quantile(corresptanom{stn},0.05);p5corresptanomstan(stn)=quantile(corresptanomstan{stn},0.05);
        p50corresptanom(stn)=quantile(corresptanom{stn},0.5);p50corresptanomstan(stn)=quantile(corresptanomstan{stn},0.5);
        p50corresptanomreltomjjasoallhours(stn)=quantile(corresptanomreltomjjasoallhours{stn},0.5);
        p95corresptanom(stn)=quantile(corresptanom{stn},0.95);p95corresptanomstan(stn)=quantile(corresptanomstan{stn},0.95);
        p5correspqanom(stn)=quantile(correspqanom{stn},0.05);p5correspqanomstan(stn)=quantile(correspqanomstan{stn},0.05);
        p50correspqanom(stn)=quantile(correspqanom{stn},0.5);p50correspqanomstan(stn)=quantile(correspqanomstan{stn},0.5);
        p50correspqanomreltomjjasoallhours(stn)=quantile(correspqanomreltomjjasoallhours{stn},0.5);
        p95correspqanom(stn)=quantile(correspqanom{stn},0.95);p95correspqanomstan(stn)=quantile(correspqanomstan{stn},0.95);
        %Percentiles of anomalies & standardized anoms of the top-XX WBT values -- in order to 
            %compare the relative extremeness of the top-XX WBT among the stations
        %i.e. suspicion is that for some stations (e.g. Phoenix) the top-XX WBT are actually not that extreme,
            %in other words there are no truly extreme WBT there, just some that are slightly higher than others
        p5wbtanom(stn)=quantile(wbtanom{stn},0.05);p5wbtanomstan(stn)=quantile(wbtanomstan{stn},0.05);
        p50wbtanom(stn)=quantile(wbtanom{stn},0.5);p50wbtanomstan(stn)=quantile(wbtanomstan{stn},0.5);
        p95wbtanom(stn)=quantile(wbtanom{stn},0.95);p95wbtanomstan(stn)=quantile(wbtanomstan{stn},0.95);
    end
    %50th percentile of standardized anomalies of T and q during extreme WBT for each region and year (all months)
    for region=1:8
        for year=1:yeariwl-yeariwf+1
            p50corresptanomstanbyregionandyear(region,year)=quantile(regcorresptanomstanbyregandyr{region,year},0.5);
            p50correspqanomstanbyregionandyear(region,year)=quantile(regcorrespqanomstanbyregandyr{region,year},0.5);
        end
        %datain=[p50corresptanomstanbyregionandyear(region,:)' (1:yeariwl-yeariwf+1)'];
        %[taub junk junk sig Z]=mannkendall(datain,0.05);sigt(region)=sig;
        %datain=[p50correspqanomstanbyregionandyear(region,:)' (1:yeariwl-yeariwf+1)'];
        %[taub junk junk sig Z]=mannkendall(datain,0.05);sigq(region)=sig;
    end
    %50th percentile of values and of standardized anomalies of T and q during extreme WBT for each region and month (all years)
    p50corresptanomstanbyregionandmonth=0;p50correspqanomstanbyregionandmonth=0;
    p50corresptvalbyregionandmonth=0;p50correspqvalbyregionandmonth=0;
    for region=1:8
        for month=1:monthiwl-monthiwf+1
            regc=eval(['reg' num2str(region) 'cbymonth']);
            if regc(month)>=5
                p50corresptanomstanbyregionandmonth(region,month)=quantile(regcorresptanomstanbyregandmn{region,month},0.5);
                p50correspqanomstanbyregionandmonth(region,month)=quantile(regcorrespqanomstanbyregandmn{region,month},0.5);
                p50corresptvalbyregionandmonth(region,month)=quantile(regcorresptvalbyregandmn{region,month},0.5);
                p50correspqvalbyregionandmonth(region,month)=quantile(regcorrespqvalbyregandmn{region,month},0.5);
            else
                p50corresptanomstanbyregionandmonth(region,month)=NaN;
                p50correspqanomstanbyregionandmonth(region,month)=NaN;
                p50corresptvalbyregionandmonth(region,month)=NaN;
                p50correspqvalbyregionandmonth(region,month)=NaN;
            end
        end
    end
    for month=1:monthiwl-monthiwf+1
        if regcswcoastbymonth(month)>=5 %enough months to reasonably compute an average
            p50corresptanomstanbyregionandmonth(9,month)=quantile(regcorresptanomstanbyregandmnswcoast{month},0.5);
            p50correspqanomstanbyregionandmonth(9,month)=quantile(regcorrespqanomstanbyregandmnswcoast{month},0.5);
            p50corresptvalbyregionandmonth(9,month)=quantile(regcorresptvalbyregandmnswcoast{month},0.5);
            p50correspqvalbyregionandmonth(9,month)=quantile(regcorrespqvalbyregandmnswcoast{month},0.5);
            p50corresptanomreltomjjasoallhoursbyregionandmonth(9,month)=quantile(regcorresptanomreltomjjasoallhoursbyregandmnswcoast{month},0.5);
            p50correspqanomreltomjjasoallhoursbyregionandmonth(9,month)=quantile(regcorrespqanomreltomjjasoallhoursbyregandmnswcoast{month},0.5);
            p50corresptanomstanreltomjjasoallhoursbyregionandmonth(9,month)=quantile(regcorresptanomstanreltomjjasoallhoursbyregandmnswcoast{month},0.5);
            p50correspqanomstanreltomjjasoallhoursbyregionandmonth(9,month)=quantile(regcorrespqanomstanreltomjjasoallhoursbyregandmnswcoast{month},0.5);
        else
            p50corresptanomstanbyregionandmonth(9,month)=NaN;
            p50correspqanomstanbyregionandmonth(9,month)=NaN;
            p50corresptvalbyregionandmonth(9,month)=NaN;
            p50correspqvalbyregionandmonth(9,month)=NaN;
            p50corresptanomreltomjjasoallhoursbyregionandmonth(9,month)=NaN;
            p50correspqanomreltomjjasoallhoursbyregionandmonth(9,month)=NaN;
            p50corresptanomstanreltomjjasoallhoursbyregionandmonth(9,month)=NaN;
            p50correspqanomstanreltomjjasoallhoursbyregionandmonth(9,month)=NaN;
        end
        if regcaznmbymonth(month)>=5
            p50corresptanomstanbyregionandmonth(10,month)=quantile(regcorresptanomstanbyregandmnaznm{month},0.5);
            p50correspqanomstanbyregionandmonth(10,month)=quantile(regcorrespqanomstanbyregandmnaznm{month},0.5);
            p50corresptvalbyregionandmonth(10,month)=quantile(regcorresptvalbyregandmnaznm{month},0.5);
            p50correspqvalbyregionandmonth(10,month)=quantile(regcorrespqvalbyregandmnaznm{month},0.5);
            p50corresptanomreltomjjasoallhoursbyregionandmonth(10,month)=quantile(regcorresptanomreltomjjasoallhoursbyregandmnaznm{month},0.5);
            p50correspqanomreltomjjasoallhoursbyregionandmonth(10,month)=quantile(regcorrespqanomreltomjjasoallhoursbyregandmnaznm{month},0.5);
            p50corresptanomstanreltomjjasoallhoursbyregionandmonth(10,month)=quantile(regcorresptanomstanreltomjjasoallhoursbyregandmnaznm{month},0.5);
            p50correspqanomstanreltomjjasoallhoursbyregionandmonth(10,month)=quantile(regcorrespqanomstanreltomjjasoallhoursbyregandmnaznm{month},0.5);
        else
            p50corresptanomstanbyregionandmonth(10,month)=NaN;
            p50correspqanomstanbyregionandmonth(10,month)=NaN;
            p50corresptvalbyregionandmonth(10,month)=NaN;
            p50correspqvalbyregionandmonth(10,month)=NaN;
            p50corresptanomreltomjjasoallhoursbyregionandmonth(10,month)=NaN;
            p50correspqanomreltomjjasoallhoursbyregionandmonth(10,month)=NaN;
            p50corresptanomstanreltomjjasoallhoursbyregionandmonth(10,month)=NaN;
            p50correspqanomstanreltomjjasoallhoursbyregionandmonth(10,month)=NaN;
        end
    end
end

%For each day with a T in the top 100, find the rank of that day's WBT
if findwbtranksoftop100t==1
    for stn=1:size(topXXtbystn,2)
        top100tthisstn=topXXtbystn{stn};
        for row=1:numdates
            thisyearrel=top100tthisstn(row,2)-yeariwf+1;
            thismonthrel=top100tthisstn(row,3)-monthiwf+1;
            thisday=top100tthisstn(row,4);
            thisdaydoy=DatetoDOY(top100tthisstn(row,3),top100tthisstn(row,4),top100tthisstn(row,2));
            thisdayswbtmax=dailymaxwbtstruc{stn,thisyearrel,thismonthrel}(thisday);
            thisdayswbtpct{stn}(row)=pctreltodistn(dailymaxwbt{stn}',thisdayswbtmax);
            thisdayswbtpctdoy{stn}(row)=thisdaydoy;
        end
    end
    save(strcat(curDir,'extraarrays'),'thisdayswbtpct','-append');
end

%Monthly SST anomaly index using NOAA ERSST or ESRL ICOADS, averaged over a region
if calcsstanomalyindex==1
    if justchangedsst==1 %5 min
        monthlysst=ncread(strcat(sstfileloc,sstfilename),'sst');
        monthlysst=monthlysst(:,:,moncorrtojanofyeariwf:moncorrtodecofyeariwl);
        if strcmp(monthlyssdataset,'esrlicoads');monthlysst=monthlysst(:,2:90,:);end
    end 
    %Dimensions of monthlysst are longitude,latitude,month, with a reduced size of (180,89,420)
    
    
    %Determine which points lie within the region of interest on this run
    if strcmp(regionofinterest,'Gulf of Mexico')
        necornerlat=30;necornerlon=-85;
        secornerlat=25;secornerlon=-85;
        swcornerlat=25;swcornerlon=-100;
        nwcornerlat=30;nwcornerlon=-100;
    elseif strcmp(regionofinterest,'Baja/California')
        necornerlat=35;necornerlon=-105;
        secornerlat=25;secornerlon=-105;
        swcornerlat=25;swcornerlon=-125;
        nwcornerlat=35;nwcornerlon=-125;
    end
    [necornerx,necornery]=closestersstgridptsfromlatlon(necornerlat,necornerlon);
    [secornerx,secornery]=closestersstgridptsfromlatlon(secornerlat,secornerlon);
    [swcornerx,swcornery]=closestersstgridptsfromlatlon(swcornerlat,swcornerlon);
    [nwcornerx,nwcornery]=closestersstgridptsfromlatlon(nwcornerlat,nwcornerlon);
    
    
    %Create a month-by-month index of SST in this region
    %For lack of a need for a more-complicated alternative, just average over all the points between the NE & SW corners
    year=1;
    for month=1:size(monthlysst,3)
        if rem(month,12)==1 && month~=1;year=year+1;end
        if rem(month,100)==1;fprintf('Current month is %d\n',month);end
        relmonth=rem(month,12);if relmonth==0;relmonth=12;end
        validptsthismonth=0;tempsum=0;
        for xindex=min(necornerx,swcornerx):max(necornerx,swcornerx)
            for yindex=min(necornery,swcornery):max(necornery,swcornery)
                if abs(monthlysst(xindex,yindex,month))<100 %i.e. if it's valid
                    tempsum=tempsum+monthlysst(xindex,yindex,month);
                    validptsthismonth=validptsthismonth+1;
                end
            end
        end
        monthbymonthroiavgsst(year,relmonth)=tempsum/validptsthismonth;
    end
    
    %Now that the actual values have been found, calculate the monthly averages so that anomalies can be used as well
    for month=1:12;roiclimosstmonth(month)=mean(monthbymonthroiavgsst(:,month));end
    
    %Calculate SST anomalies for this ROI for every month within 1981-2015
    for year=1:yeariwl-yeariwf+1
        for month=1:12
            monthbymonthroianomsst(year,month)=monthbymonthroiavgsst(year,month)-roiclimosstmonth(month);
        end
    end
    save(strcat(curDir,'correlsstarrays'),'monthlysst','monthbymonthroiavgsst','roiclimosstmonth','monthbymonthroianomsst','-append');
end


%Interannual correlation of SST anomalies in a region of interest with top-XX WBT (or T, an option added later) days at each station
%This is made much simpler by transforming the relevant vectors into 1D arrays
%Keep in mind that the arrays contain data for all months, not just the warm season
if correlsstwbtt==1
    newc=1;
    for year=1:yeariwl-yeariwf+1
        %if year~=1;newc=newc+12;end
        %monthbymonthroianomsst1d(newc:newc+11)=monthbymonthroianomsst(year,:); %works but may not be necessary
        allyearsroianomsstavg(year)=mean(monthbymonthroianomsst(year,6:8));
    end
    for var=1:3
        if var==1
            topXXbystn=topXXtbystn;
        elseif var==2
            topXXbystn=topXXwbtbystn;
        elseif var==3
            topXXbystn=topXXqbystn;
        end
        for stn=1:size(newstnNumList,1)
            topXX=topXXbystn{stn};
            thisstncbyyear=zeros(yeariwl-yeariwf+1,1);
            for row=1:numdates
                thisrowrelyear=topXX(row,2)-yeariwf+1;
                thisstncbyyear(thisrowrelyear)=thisstncbyyear(thisrowrelyear)+1;
            end
            stntopxxbyyear(:,stn)=thisstncbyyear;
        end

        %Get the single number that represents the correlation between the ROI SST anomaly & each station's extreme WBT count
        for stn=1:size(newstnNumList,1)
            temp=corrcoef(allyearsroianomsstavg,stntopxxbyyear(:,stn));
            correlsst(stn)=temp(2,1);
        end
        %Assign to T or WBT as appropriate for the purposes of posterity
        if var==1
            stntopxxtbyyear=stntopxxbyyear;correlsstt=correlsst;
        elseif var==2
            stntopxxwbtbyyear=stntopxxbyyear;correlsstwbt=correlsst;
        elseif var==3
            stntopxxqbyyear=stntopxxbyyear;correlsstq=correlsst;
        end
    end
    save(strcat(curDir,'correlsstarrays'),'stntopxxtbyyear','correlsstt','stntopxxwbtbyyear','correlsstwbt',...
        'stntopxxqbyyear','correlsstq','-append');
end


%Monthly SST anomaly index using 1. NOAA ERSST or 2. ESRL ICOADS, for every gridpoint on the planet
if calcsstanomalyindexeverygridpt==1 
    if justchangedsst==1 %1 min
        monthlysst=ncread(strcat(sstfileloc,sstfilename),'sst');
        monthlysst=monthlysst(:,:,moncorrtojanofyeariwf:moncorrtodecofyeariwl);
        if strcmp(monthlysstdataset,'esrlicoads');monthlysst=monthlysst(:,2:90,:);end 
        %removes a harmless extra latitude band in the Arctic, so both SST datasets are of size (180,89,420)
    end 
    %dimensions of monthlysst are longitude count,latitude count,month
        
    
    necornerx=size(monthlysst,1);necornery=83; %this must be set to the southernmost latitude with ocean, 
        %so that errors aren't created when it tries to find ocean gridpts in Antarctica
    swcornerx=1;swcornery=1;
    
    %Create a month-by-month index of SST for every gridpoint
    %For lack of a need for a more-complicated alternative, just average over all the points between the NE & SW corners
    year=1;
    for month=1:size(monthlysst,3)
        if rem(month,12)==1 && month~=1;year=year+1;end
        if rem(month,100)==1;fprintf('Current month is %d\n',month);end
        relmonth=rem(month,12);if relmonth==0;relmonth=12;end
        tempsum=0;
        for xindex=min(necornerx,swcornerx):max(necornerx,swcornerx)
            for yindex=min(necornery,swcornery):max(necornery,swcornery)
                if abs(monthlysst(xindex,yindex,month))<100 %i.e. if it's valid
                    monthbymonthgridptsst(xindex,yindex,year,relmonth)=monthlysst(xindex,yindex,month);
                    temp=monthbymonthgridptsst(xindex,yindex,year,relmonth)==0;
                    temp2=monthbymonthgridptsst(xindex,yindex,year,relmonth);temp2(temp)=NaN;
                    monthbymonthgridptsst(xindex,yindex,year,relmonth)=temp2;
                end
            end
        end
    end
    
    %Now that the actual values have been found, calculate the monthly averages so that anomalies can be used as well
    for xindex=min(necornerx,swcornerx):max(necornerx,swcornerx)
        for yindex=min(necornery,swcornery):max(necornery,swcornery)
            for month=1:12
                gridptclimosstmonth(xindex,yindex,month)=mean(squeeze(monthbymonthgridptsst(xindex,yindex,:,month)));
                temp=gridptclimosstmonth(xindex,yindex,month)==0;
                temp2=gridptclimosstmonth(xindex,yindex,month);temp2(temp)=NaN;
                gridptclimosstmonth(xindex,yindex,month)=temp2;
            end
        end
    end
    
    %Calculate SST anomalies for this gridpt for every month within 1981-2015
    for xindex=min(necornerx,swcornerx):max(necornerx,swcornerx)
        for yindex=min(necornery,swcornery):max(necornery,swcornery)
            for year=1:yeariwl-yeariwf+1
                for month=1:12
                    monthbymonthgridptanomsst(xindex,yindex,year,month)=...
                        monthbymonthgridptsst(xindex,yindex,year,month)-gridptclimosstmonth(xindex,yindex,month);
                end
            end
        end
    end
    save(strcat(curDir,'correlsstarrays'),'monthbymonthgridptsst','gridptclimosstmonth','monthbymonthgridptanomsst','-append');
end


%Daily SST climatology using NOAA OI SST High Resolution, for every gridpoint on the planet
%Because the data are so voluminous, unlike for the monthly loop above, anomalies will be calculated as needed in exploratorydataanalysis
    %Also, this climatology mat file will only be loaded if necessary
%Dimensions are 1440x720x# days (i.e. 0.25x0.25, daily resolution)
if calcsstanomalyindexdailyeverygridpt==1
    if rereadindata==1
        disp(clock);
        fullyearsumdailysst=zeros(1440,720,365);
        
        for year=yeariwf+1:yeariwl-1 %only 1982-2014 are available for this dataset
        %for year=1982:1983
            fprintf('Reading in daily SST data for %d\n',year);
            relyear=year-yeariwf+1;
            if rem(year,4)==0;leapyear=1;else leapyear=0;end
            
            dailysstfile=zeros(1440,720,181);
            dailysstfile=ncread(strcat(dailysstfileloc,'tos_OISST_L4_AVHRR-only-v2_',num2str(year),'0101-',...
                num2str(year),'0630.nc'),'tos'); %daily data from Jan 1 to Jun 30
            if leapyear==1 %don't include Feb 29 in climatologies
                temp1=dailysstfile(:,:,1:59);temp2=dailysstfile(:,:,61:182);
                dailysst1=cat(3,temp1,temp2)-273.15;
            else
                dailysst1=dailysstfile-273.15;
            end
            dailysstfile=zeros(1440,720,184);
            dailysstfile=ncread(strcat(dailysstfileloc,'tos_OISST_L4_AVHRR-only-v2_',num2str(year),'0701-',...
                num2str(year),'1231.nc'),'tos'); %daily data from Jul 1 to Dec 31
            dailysst2=dailysstfile-273.15;

            %fullyeardailysst(:,:,:,relyear)=cat(3,dailysst1,dailysst2);
            fullyearsumdailysst=fullyearsumdailysst+cat(3,dailysst1,dailysst2);
            fclose('all');
        end
        fullyearavgdailysst=fullyearsumdailysst./(yeariwl-1-(yeariwf+1)+1);
        %New idea: don't save all the data, just sum up and divide (don't need to calc percentiles this way anyway)
            %(percentiles for significance will be determined by how many of the 100 hottest days have anoms of the same sign
            %at a given gridpt)
        %h5create(strcat(curDir,'dailysstarrays.h5'),'/dailyoisstdata',[1440 720 365 yeariwl-yeariwf+1],...
        %    'ChunkSize',[20 20 5 1],'Deflate',5);
        %h5write(strcat(curDir,'dailysstarrays.h5'),'/dailyoisstdata',fullyeardailysst);
        save(strcat(curDir,'dailysstarrays'),'fullyearavgdailysst','-v7.3');
        disp(clock);
    end
end


%Interannual correlation of SST anomalies for every gridpt on the planet with top-XX WBT (or T, an option added later) days at each station
%This is made much simpler by transforming the relevant vectors into 1D arrays
%Further, correlations are improved/spurious ones eliminated by detrending the time series as well
%Keep in mind that the arrays contain data for all months, not just the warm season
if correlssteverygridptwbtt==1
    %Transform month-by-month anomalies into an average of the Jun-Aug anomalies (a single number for each gridpt for each year) 
    exist allyearsgridptanomsstavg;
    if ans==0 || justchangedsst==1
        firstmonthhere=6;lastmonthhere=8;
        for xindex=min(necornerx,swcornerx):max(necornerx,swcornerx)
            for yindex=min(necornery,swcornery):max(necornery,swcornery)
                for year=1:yeariwl-yeariwf+1
                    allyearsgridptanomsstavg(xindex,yindex,year)=mean(monthbymonthgridptanomsst(xindex,yindex,year,firstmonthhere:lastmonthhere));
                end
                %Also calculate a detrended version, with the same mean
                thists=squeeze(allyearsgridptanomsstavg(xindex,yindex,:));
                thistsdetr=detrend(thists)+mean(thists);
                allyearsgridptanomsstavgdetr(xindex,yindex,:)=thistsdetr;
            end
        end
    end

    
    for var=1:3
        correlssteverygridptstns=0;correlssteverygridptregions=0;
        if var==1
            topXXbystn=topXXtbystn;
        elseif var==2
            topXXbystn=topXXwbtbystn;
        elseif var==3
            topXXbystn=topXXqbystn;
        end
        %Define an array that consolidates the top-XX days into a yearly sum, for every station (already has been done for regions)
        for stn=1:size(newstnNumList,1)
            topXX=topXXbystn{stn};
            thisstncbyyear=zeros(yeariwl-yeariwf+1,1);
            for row=1:numdates
                thisrowrelyear=topXX(row,2)-yeariwf+1;
                thisstncbyyear(thisrowrelyear)=thisstncbyyear(thisrowrelyear)+1;
            end
            stntopxxbyyear(:,stn)=thisstncbyyear;
            %Also calculate detrended version
            thists=squeeze(stntopxxbyyear(:,stn));
            thistsdetr=detrend(thists)+mean(thists);
            stntopxxbyyeardetr(:,stn)=thistsdetr;
        end
        %Calculate detrended version of allregionsyearc
        for region=1:8
            thists=squeeze(allregionsyearc{var}(:,region));
            thistsdetr=detrend(thists)+mean(thists);
            allregionsyearcdetr{var}(:,region)=thistsdetr;
        end

        %Get the single number that represents the correlation between each gridpt's SST anomaly & each station's extreme WBT count
        if usedetrended==1
            gridptanomarray=allyearsgridptanomsstavgdetr;stntopxx=stntopxxbyyeardetr;allregionsc=allregionsyearcdetr;
            detrremark='detr';detrtitleremark=' (Detrended)';
        else
            gridptanomarray=allyearsgridptanomsstavg;stntopxx=stntopxxbyyear;allregionsc=allregionsyearc;
            detrremark='';detrtitleremark='';
        end
        %1. for stations
        if dostncorrels==1
            for stn=1:size(newstnNumList,1)
                fprintf('Correlations b/w station %d and SST anomalies for all gridpts\n',stn);
                for xindex=min(necornerx,swcornerx):max(necornerx,swcornerx)
                    for yindex=min(necornery,swcornery):max(necornery,swcornery)
                        temp=corrcoef(squeeze(gridptanomarray(xindex,yindex,:)),stntopxx(:,stn));
                        correlssteverygridptstns(xindex,yindex,stn)=temp(2,1);
                    end
                end
            end
        end
        %2. for regions
        if doregioncorrels==1
            for region=1:8
                fprintf('Correlations b/w region %d and SST anomalies for all gridpts\n',region);
                for xindex=min(necornerx,swcornerx):max(necornerx,swcornerx)
                    for yindex=min(necornery,swcornery):max(necornery,swcornery)
                        temp=corrcoef(squeeze(gridptanomarray(xindex,yindex,:)),allregionsc{var}(:,region));
                        correlssteverygridptregions(xindex,yindex,region)=temp(2,1);
                    end
                end
            end
        end
        
        %Assign to T or WBT as appropriate for the purposes of posterity
        if var==1
            stntopxxtbyyear=stntopxxbyyear;if dostncorrels==1;correlsstteverygridptstns=correlssteverygridptstns;end
            if doregioncorrels==1;correlsstteverygridptregions=correlssteverygridptregions;end
        elseif var==2
            stntopxxwbtbyyear=stntopxxbyyear;if dostncorrels==1;correlsstwbteverygridptstns=correlssteverygridptstns;end
            if doregioncorrels==1;correlsstwbteverygridptregions=correlssteverygridptregions;end
        elseif var==3
            stntopxxqbyyear=stntopxxbyyear;if dostncorrels==1;correlsstqeverygridptstns=correlssteverygridptstns;end
            if doregioncorrels==1;correlsstqeverygridptregions=correlssteverygridptregions;end
        end
    end
    save(strcat(curDir,'correlsstarrays'),'allyearsgridptanomsstavg','allyearsgridptanomsstavgdetr',...
        'correlsstteverygridptstns','correlsstwbteverygridptstns','correlsstqeverygridptstns',...
        'correlsstteverygridptregions','correlsstwbteverygridptregions','correlsstqeverygridptregions','-append');
end


%Compile list of all hot T/WBT days of any station in each region (topXXdatesbyregion);
%then, calculate the regional-average daily-max T/WBT on these dates using data from dailymaxtstruc
%Sort the regional-avg T or WBT (by value) to get a list of the 100 'regional hot days' -- this is topXXbyregionsorted
%Justification for seemingly-complex method: if a day is in the regional 100 hottest, it is surely in at least one station's 100 hottest
    %and from there would 'rise to the top' when ranking by e.g. average daily-max T/WBT
if compilelistreghotdaysfromstnlists==1
    for var=1:3
        if var==1
            for region=1:8;topXXtdatesbyregion{region}=zeros(1,3);end
            topXXbystn=topXXtbystn;topXXdatesbyregion=topXXtdatesbyregion;
            dailymaxstruc=dailymaxtstruc;
        elseif var==2
            for region=1:8;topXXwbtdatesbyregion{region}=zeros(1,3);end
            topXXbystn=topXXwbtbystn;topXXdatesbyregion=topXXwbtdatesbyregion;
            dailymaxstruc=dailymaxwbtstruc;
        elseif var==3
            for region=1:8;topXXqdatesbyregion{region}=zeros(1,3);end
            topXXbystn=topXXqbystn;topXXdatesbyregion=topXXqdatesbyregion;
            dailymaxstruc=dailymaxqstruc;
        end
        for stn=1:size(newstnNumList,1)
            reg=ncaregionnum{stn};
            for row=1:numdates
                thisyear=topXXbystn{stn}(row,2);
                thismon=topXXbystn{stn}(row,3);
                thisday=topXXbystn{stn}(row,4);
                thisdateval=topXXbystn{stn}(row,1);
                thisdatefound=0;
                %See if date already exists in the comprehensive regional list
                for i=1:size(topXXdatesbyregion{reg},1)
                    if topXXdatesbyregion{reg}(i,1)==thisyear && topXXdatesbyregion{reg}(i,2)==thismon && topXXdatesbyregion{reg}(i,3)==thisday
                        thisdatefound=1;
                    end
                end
                %If not, add it
                if thisdatefound==0
                    topXXdatesbyregion{reg}=[topXXdatesbyregion{reg};zeros(1,3)];lastrow=size(topXXdatesbyregion{reg},1);
                    topXXdatesbyregion{reg}(lastrow,1)=thisyear;
                    topXXdatesbyregion{reg}(lastrow,2)=thismon;
                    topXXdatesbyregion{reg}(lastrow,3)=thisday;
                end
            end
        end
        %Remove top row of zeros and then sort into chronological order
        for region=1:8
            topXXdatesbyregion{region}=topXXdatesbyregion{region}(2:size(topXXdatesbyregion{region},1),:);
            topXXdatesbyregion{region}=sortrows(topXXdatesbyregion{region},[1 2 3]);
        end
        
        %Now, calculate the average T or WBT on each day using data from dailymaxstruc
        regstnordinates={};topXXbyregion={};topXXbyregionsorted={};
        for region=1:8
            %Get the list of stations for this region -- i.e. their ordinate positions in the full list of 211
            %(because that's how dailymaxstruc is organized)
            regstnc=1;
            for stn=1:size(newstnNumList,1)
                if ncaregionnum{stn}==region
                    regstnordinates{region}(regstnc)=stn;
                    regstnc=regstnc+1;
                end
            end
            %Go through the list of top-XX dates that any station in this region has
            for row=1:size(topXXdatesbyregion{region},1)
                thisyear=topXXdatesbyregion{region}(row,1);
                thismon=topXXdatesbyregion{region}(row,2);
                thisday=topXXdatesbyregion{region}(row,3);
                %Now that the date is pinned down, go one-by-one through the list of stations and sum up the T, WBT, or q
                %There is a relatively small amount of NaN data so no special treatment or normalization is needed
                thisdatesum=0;thisdatevalidstns=0;
                for stnwithinregion=1:size(regstnordinates{region},2)
                    thisstnordinate=regstnordinates{region}(stnwithinregion);
                    thisstnval=dailymaxstruc{thisstnordinate,thisyear-yeariwf+1,thismon-monthiwf+1}(thisday);
                    if ~isnan(thisstnval);thisdatesum=thisdatesum+thisstnval;thisdatevalidstns=thisdatevalidstns+1;end
                end
                %Get the average T, WBT, or q for this date and save it
                thisdateavg=thisdatesum/thisdatevalidstns;
                topXXbyregion{region}(row,1)=thisyear;
                topXXbyregion{region}(row,2)=thismon;
                topXXbyregion{region}(row,3)=thisday;
                topXXbyregion{region}(row,4)=thisdateavg;
            end
            
            %Sort the final array by average T, WBT, or q across the region
            topXXbyregionsorted{region}=sortrows(topXXbyregion{region},-4);
            
            %Compute yearly count
            temp=zeros(35,1);
            for i=1:100;thisyearrel=topXXqbyregionsorted{region}(i,1)-yeariwf+1;temp(thisyearrel)=temp(thisyearrel)+1;end
            allregionscnewmethod{region}=temp;
        end
        
        if var==1
            topXXtbyregionsorted=topXXbyregionsorted;topXXtdatesbyregion=topXXdatesbyregion;
        elseif var==2
            topXXwbtbyregionsorted=topXXbyregionsorted;topXXwbtdatesbyregion=topXXdatesbyregion;
        elseif var==3
            topXXqbyregionsorted=topXXbyregionsorted;topXXqdatesbyregion=topXXdatesbyregion;
        end
        
    end
    save(strcat(curDir,'extraarrays'),'topXXtbyregionsorted','topXXwbtbyregionsorted','topXXqbyregionsorted',...
        'topXXtdatesbyregion','topXXwbtdatesbyregion','topXXqdatesbyregion','-append');
end

%Compiles list of hot T/WBT days, but for using data at every NARR gridcell
%For purposes of computational efficiency, for NARR data a slightly different method is used:
    %an average is calculated for all the days within the top-XX lists, only using the gridpts that have it
    %(i.e. not pulling data for those days for all gridpts), and then ranking the days by value,
    %requiring that at least 20% of the gridpts have that day as a top-XX one
    %--This minimum percentage is intended to ensure that a small heat wave in a hot part of a region
    %doesn't make it onto this list
if compilelistreghotdaysfromstnlistsnarr==1
    for var=1:1
        if var==1
            for region=1:8;topXXtdatesbyregionnarr{region}=zeros(1,3);end
            topXXbynarr=topXXtbynarr;topXXdatesbyregionnarr=topXXtdatesbyregionnarr;
        elseif var==2
            for region=1:8;topXXwbtdatesbyregionnarr{region}=zeros(1,3);end
            topXXbynarr=topXXwbtbynarr;topXXdatesbyregionnarr=topXXwbtdatesbyregionnarr;
        elseif var==3
            for region=1:8;topXXqdatesbyregionnarr{region}=zeros(1,3);end
            topXXbynarr=topXXqbynarr;topXXdatesbyregionnarr=topXXqdatesbyregionnarr;
        end
        %First order of business is to find all the days that are in the top-XX list of at least one gridpt in a region
        regionnarrgridptc=zeros(8,1);
        for i=1:8;eval(['reg' num2str(i) 'row=0;']);eval(['reg' num2str(i) 'hotdaylist{var}=zeros(1,5);']);end
        for i=1:277
            if rem(i,100)==0;fprintf('on row %d\n',i);end
            for j=1:349
                if narrlsmask(i,j)==1 && tzlist(i,j)~=0
                    if reglist(i,j)>=1;regionnarrgridptc(reglist(i,j))=regionnarrgridptc(reglist(i,j))+1;end
                    thistopXXarr=squeeze(topXXbynarr(i,j,:,:)); %100x5
                    for row=1:numdates
                        for reg=1:8
                            if reglist(i,j)==reg
                                reghotdaylist=eval(['reg' num2str(reg) 'hotdaylist{var};']);
                                regrow=eval(['reg' num2str(reg) 'row;']);
                                k1=find(reghotdaylist(:,2)==thistopXXarr(row,2));
                                k2=find(reghotdaylist(:,3)==thistopXXarr(row,3));
                                k3=find(reghotdaylist(:,4)==thistopXXarr(row,4));
                                k4=intersect(k1,k2);k5=intersect(k4,k3);
                                if size(k5,1)==0 %if date is not already in this region's list of hot days, add it in
                                    regrow=regrow+1;
                                    eval(['reg' num2str(reg) 'hotdaylist{var}(regrow,1:5)=thistopXXarr(row,1:5);']);
                                    eval(['reg' num2str(reg) 'hotdaylist{var}(regrow,6)=1;']);
                                else %if date already is in list, add to the count of gridpts that have it, and sum up values
                                    eval(['reg' num2str(reg) 'hotdaylist{var}(k5,1)=reg' num2str(reg) 'hotdaylist{var}(k5,1)+thistopXXarr(row,1);']);
                                    eval(['reg' num2str(reg) 'hotdaylist{var}(k5,6)=reg' num2str(reg) 'hotdaylist{var}(k5,6)+1;']);
                                end
                                eval(['reg' num2str(reg) 'row=regrow;']);
                            end
                        end
                    end
                end
            end
        end
        
        for region=1:8
            %Compute average on each day
            thisreglist=eval(['reg' num2str(region) 'hotdaylist{var};']);
            thisreglist(:,1)=thisreglist(:,1)./thisreglist(:,6);
            %Impose 15% minimum cutoff
            minnumgridpts=0.15*regionnarrgridptc(region);
            %Find where to cut off
            thisreglist=sortrows(thisreglist,-6);
            i=1;keepgoing=1;
            while i<=size(thisreglist,1) && keepgoing==1
            	if thisreglist(i,6)<minnumgridpts
                    keepgoing=0;stopat=i-1;
                else
                    i=i+1;
                end
            end
            %Implement cutoff, sort, and save
            thisreglist=thisreglist(1:stopat,:);
            thisreglist=sortrows(thisreglist,-1);
            thisreglist=thisreglist(1:numdates,:);
            topXXdatesbyregionnarr{region}(1:numdates,1:3)=thisreglist(:,2:4);
            topXXdatesbyregionnarr{region}(1:numdates,4)=thisreglist(:,1);
        end
        
        if var==1
            topXXtdatesbyregionnarr=topXXdatesbyregionnarr;
            for reg=1:8;eval(['reg' num2str(reg) 'hotdaylistt=reg' num2str(reg) 'hotdaylist{1};']);end
            save(strcat(curDir,'narrarrays'),'topXXtdatesbyregionnarr','reg1hotdaylistt',...
                'reg2hotdaylistt','reg3hotdaylistt','reg4hotdaylistt','reg5hotdaylistt','reg6hotdaylistt',...
                'reg7hotdaylistt','reg8hotdaylistt','regionnarrgridptc','-append');
        elseif var==2
            topXXwbtdatesbyregionnarr=topXXdatesbyregionnarr;
            for reg=1:8;eval(['reg' num2str(reg) 'hotdaylistwbt=reg' num2str(reg) 'hotdaylist{2};']);end
            save(strcat(curDir,'narrarrays'),'topXXwbtdatesbyregionnarr','reg1hotdaylistwbt',...
                'reg2hotdaylistwbt','reg3hotdaylistwbt','reg4hotdaylistwbt','reg5hotdaylistwbt','reg6hotdaylistwbt',...
                'reg7hotdaylistwbt','reg8hotdaylistwbt','regionnarrgridptc','-append');
        elseif var==3
            topXXqdatesbyregionnarr=topXXdatesbyregionnarr;
            for reg=1:8;eval(['reg' num2str(reg) 'hotdaylistq=reg' num2str(reg) 'hotdaylist{3};']);end
            save(strcat(curDir,'narrarrays'),'topXXqdatesbyregionnarr','reg1hotdaylistq',...
                'reg2hotdaylistq','reg3hotdaylistq','reg4hotdaylistq','reg5hotdaylistq','reg6hotdaylistq',...
                'reg7hotdaylistq','reg8hotdaylistq','regionnarrgridptc','-append');
        end
    end
end

%Calculate regional hot days as has been done above, but scrapping the non-linear count approach and using instead
    %the average of the 3 highest days per year for each variable, for both stations and regions
    %(with 35 years and a count of 100 before, this of course means that the number of days in consideration is about the same
    %even though the methods yield quite different results because temperature itself is the measure, rather than a count)
if reghotdays3highestperyear==1
    avg3highesttbyregion=0;avg3highestwbtbyregion=0;avg3highestqbyregion=0;
    for var=1:3
        if var==1
            dailymaxstruc=dailymaxtstruc;
        elseif var==2
            dailymaxstruc=dailymaxwbtstruc;
        elseif var==3
            dailymaxstruc=dailymaxqstruc;
        end
        regionyearc=zeros(8,35);
        for stn=1:maxnumstns
            thisregion=ncaregionnum{stn};
            for year=1:35
                regionyearc(thisregion,year)=regionyearc(thisregion,year)+1;
                highestvalsthisstnyear{stn,year}=zeros(3,3);          
                for mon=1:6
                    thismondata=dailymaxstruc{stn,year,mon};
                    for i=1:size(thismondata,2)
                        if thismondata(i)>highestvalsthisstnyear{stn,year}(3,1)
                            highestvalsthisstnyear{stn,year}(3,1)=thismondata(i); %value
                            highestvalsthisstnyear{stn,year}(3,2)=mon+monthiwf-1; %month of occurrence
                            highestvalsthisstnyear{stn,year}(3,3)=i; %day of occurrence
                            highestvalsthisstnyear{stn,year}=sortrows(highestvalsthisstnyear{stn,year},-1);
                        end
                    end
                end
                %Average of the 3 highest values for each stn-year combo
                avg3highestbystn(stn,year)=mean(highestvalsthisstnyear{stn,year}(:,1));
                avgthreehighestbyregioneachstn{thisregion,year}(regionyearc(thisregion,year))=mean(highestvalsthisstnyear{stn,year}(:,1));
                temp=avgthreehighestbyregioneachstn{thisregion,year}==0;avgthreehighestbyregioneachstn{thisregion,year}(temp)=NaN;
            end
        end
        temp=avg3highestbystn==0;avg3highestbystn(temp)=NaN;
        
        %Get regional averages
        for region=1:8
            for year=1:35
                avg3highestbyregion(region,year)=nanmean(avgthreehighestbyregioneachstn{region,year});
            end
        end
        if var==1
            avg3highesttbyregion=avg3highestbyregion;avg3highesttbystn=avg3highestbystn;
        elseif var==2
            avg3highestwbtbyregion=avg3highestbyregion;avg3highestwbtbystn=avg3highestbystn;
        elseif var==3
            avg3highestqbyregion=avg3highestbyregion;avg3highestqbystn=avg3highestbystn;
        end
    end
    save(strcat(curDir,'extraarrays'),'avg3highesttbyregion','avg3highestwbtbyregion','avg3highestqbyregion',...
        'avg3highesttbystn','avg3highestwbtbystn','avg3highestqbystn','-append');
end

%Define and calculate sudden spikes of q and T
%Expectation is that there will be many on the Plains, considering I first found this phenomenon
    %at Scottsbluff NE (in July 2003)
%Initial working definition of a q spike: >=5 g/kg increase in 2 hr
%of a T spike: >=7.5 K increase in 2 hr
if definecalcsuddenspikes==1
    stnqspikes={};stntspikes={};
    for stn=1:maxnumstns
        if rem(stn,10)==0;fprintf('Calculating sudden spikes for stn %d\n',stn);end
        stnqspikec=0;stntspikec=0;
        curstnnum=newstnNumList(stn);[~,~,~,curstntz]=stationinfofromnumber(curstnnum);
        %Create 1D vector of all JJA WBT hourly values at this station
        fullhourlywbt=0;
        for year=1:yeariwl-yeariwf+1
            fullhourlywbt=[fullhourlywbt;finaldatawbt{year,stn}];
        end
        fullhourlywbt=fullhourlywbt(2:size(fullhourlywbt,1));
        
        for year=1:yeariwl-yeariwf+1
            for month=1:6
                stndataqthismonth=stndataq{stn,year,month};
                stndatatthismonth=stndatat{stn,year,month};
                if month==1
                    monthstartfullhour=1;
                elseif month==2
                    monthstartfullhour=monthlengthsdays(1)*24+1;
                elseif month==3
                    monthstartfullhour=monthlengthsdays(1)*24+monthlengthsdays(2)*24+1;
                elseif month==4
                    monthstartfullhour=monthlengthsdays(1)*24+monthlengthsdays(2)*24+monthlengthsdays(3)*24+1;
                elseif month==5
                    monthstartfullhour=monthlengthsdays(1)*24+monthlengthsdays(2)*24+monthlengthsdays(3)*24+...
                        monthlengthsdays(4)*24+1;
                elseif month==6
                    monthstartfullhour=monthlengthsdays(1)*24+monthlengthsdays(2)*24+monthlengthsdays(3)*24+...
                        monthlengthsdays(4)*24+monthlengthsdays(5)*24+1;
                end
                hourforq=3;
                while hourforq<=size(stndataqthismonth,1)
                    if stndataqthismonth(hourforq)-stndataqthismonth(hourforq-2)>=5 %found a q spike
                        %disp('Found a q spike!');
                        %fprintf('Stn, year, month, and hourforq are %d, %d, %d, and %d\n',stn,year,month,hourforq);
                        stnqspikec=stnqspikec+1;
                        stnqspikes{stn}(stnqspikec,1)=stndataqthismonth(hourforq)-stndataqthismonth(hourforq-2);
                        stnqspikes{stn}(stnqspikec,2)=year;stnqspikes{stn}(stnqspikec,3)=month;stnqspikes{stn}(stnqspikec,4)=hourforq;
                        stnqspikes{stn}(stnqspikec,5)=rem(hourforq-curstntz-1,24);
                        
                        %Find the associated change in WBT (to see if it's sometimes a big increase, or if the increase in q
                            %is largely compensated by a decrease in T)
                        stnqspikes{stn}(stnqspikec,6)=finaldatawbt{year,stn}(monthstartfullhour+hourforq-1)-...
                            finaldatawbt{year,stn}(monthstartfullhour+hourforq-3); %associated change in WBT
                        newwbt=finaldatawbt{year,stn}(monthstartfullhour+hourforq-3);
                        stnqspikes{stn}(stnqspikec,7)=newwbt; %new WBT
                        stnqspikes{stn}(stnqspikec,8)=pctreltodistn(fullhourlywbt,newwbt); %percentile of new WBT relative to all hourly JJA values at this station
                        if stnqspikes{stn}(stnqspikec,5)<0 %fix problematic data
                            stnqspikes{stn}(stnqspikec,5)=stnqspikes{stn}(stnqspikec,5)+24;
                        end 
                        if stnqspikes{stn}(stnqspikec,7)<0;stnqspikec=stnqspikec-1;end %eliminate problematic data
                        hourforq=hourforq+3;
                    else
                        hourforq=hourforq+1;
                    end
                end
                hourfort=3;
                while hourfort<=size(stndatatthismonth,1)
                    if stndatatthismonth(hourfort)-stndatatthismonth(hourfort-2)>=7.5 %found a t spike
                        %disp('Found a t spike!');
                        %fprintf('Stn, year, month, and hourfort are %d, %d, %d, and %d\n',stn,year,month,hourfort);
                        stntspikec=stntspikec+1;
                        stntspikes{stn}(stntspikec,1)=stndatatthismonth(hourfort)-stndatatthismonth(hourfort-2);
                        stntspikes{stn}(stntspikec,2)=year;stntspikes{stn}(stntspikec,3)=month;stntspikes{stn}(stntspikec,4)=hourfort;
                        stntspikes{stn}(stntspikec,5)=rem(hourfort-curstntz-1,24);
                        
                        %Find the associated change in WBT (to see if it's sometimes a big increase, or if the increase in q
                            %is largely compensated by a decrease in T)
                        stntspikes{stn}(stntspikec,6)=finaldatawbt{year,stn}(monthstartfullhour+hourfort-1)-...
                            finaldatawbt{year,stn}(monthstartfullhour+hourfort-3); %associated change in WBT
                        newwbt=finaldatawbt{year,stn}(monthstartfullhour+hourfort-3);
                        stntspikes{stn}(stntspikec,7)=newwbt; %new WBT
                        stntspikes{stn}(stntspikec,8)=pctreltodistn(fullhourlywbt,newwbt); %percentile of new WBT relative to all hourly JJA values at this station
                        if stntspikes{stn}(stntspikec,5)<0 %fix problematic data
                            stntspikes{stn}(stntspikec,5)=stntspikes{stn}(stntspikec,5)+24;
                        end 
                        if stntspikes{stn}(stntspikec,7)<0;stntspikec=stntspikec-1;end %eliminate problematic data
                        hourfort=hourfort+3;
                    else
                        hourfort=hourfort+1;
                    end
                end
            end
        end
        stnqspikesc(stn)=stnqspikec./(yeariwl-yeariwf+1); %save the average yearly number of q spikes found at this station
        stntspikesc(stn)=stntspikec./(yeariwl-yeariwf+1);
        sumextremecontribq=0;sumextremecontribt=0;
        if stnqspikec~=0 && stnqspikec>=5
            for row=1:size(stnqspikes{stn},1)
                if stnqspikes{stn}(row,8)>=90 %q spike contributed to a WBT >=90th pctile
                    sumextremecontribq=sumextremecontribq+1;
                end
            end
            stnqspikespctcontribhighwbt(stn)=100*sumextremecontribq./(size(stnqspikes{stn},1));
        elseif stnqspikec==0
            stnqspikespctcontribhighwbt(stn)=0;
        else %too few obs --> make NaN
            stnqspikespctcontribhighwbt(stn)=NaN;
        end
        %Repeat for T
        if stntspikec~=0 && stntspikec>=5
            for row=1:size(stntspikes{stn},1)
                if stntspikes{stn}(row,8)>=90 %t spike contributed to a WBT >=90th pctile
                    sumextremecontribt=sumextremecontribt+1;
                end
            end
            stntspikespctcontribhighwbt(stn)=100*sumextremecontribt./(size(stntspikes{stn},1));
        elseif stntspikec==0
            stntspikespctcontribhighwbt(stn)=0;
        else %too few obs --> make NaN
            stntspikespctcontribhighwbt(stn)=NaN;
        end
    end
    save(strcat(curDir,'extraarrays'),'stnqspikes','stntspikes','stnqspikespctcontribhighwbt','stntspikespctcontribhighwbt','-append');
end

%Calculate 'daily' avgs of 500-hPa geopotential height at each NCEP gridpt
%To smooth out random noise, 'daily' avg is actually a 0.25-0.5-0.25 weighted average of the target day and the days just before & after
if calcncepghdailyavgs==1
    fullhgtdata={};
    for mon=1:monthiwl-monthiwf+1
        for dayinmonth=1:monthlengthsdays(mon)
            fullhgtdata{mon,dayinmonth}=zeros(144,73);
        end
    end
    for month=monthiwf:monthiwl
        fprintf('Current month is %d\n',month);
        if month<=9;addedzero='0';else addedzero='';end
        for year=yeariwf:yeariwl
            relevantmatfile=load(strcat(ncepdailydataDir,'hgt/',num2str(year),'/',...
                    'hgt_',num2str(year),'_',addedzero,num2str(month),'_500.mat'));
            if month~=monthiwf
                if month-1<=9;pmaddedzero='0';else pmaddedzero='';end
                prevmonmatfile=load(strcat(ncepdailydataDir,'hgt/',num2str(year),'/',...
                    'hgt_',num2str(year),'_',pmaddedzero,num2str(month-1),'_500.mat'));
            end
            if month~=monthiwl
                if month+1<=9;nmaddedzero='0';else nmaddedzero='';end
                nextmonmatfile=load(strcat(ncepdailydataDir,'hgt/',num2str(year),'/',...
                    'hgt_',num2str(year),'_',nmaddedzero,num2str(month+1),'_500.mat'));
            end
            actualdata=eval(['relevantmatfile.hgt_' num2str(year) '_' addedzero num2str(month) '_500']);
            if month~=monthiwf;actualdataprevmon=eval(['prevmonmatfile.hgt_' num2str(year) '_' pmaddedzero num2str(month-1) '_500']);end
            if month~=monthiwl;actualdatanextmon=eval(['nextmonmatfile.hgt_' num2str(year) '_' nmaddedzero num2str(month+1) '_500']);end
            actualdata=actualdata{3};
            if month~=monthiwf;actualdataprevmon=actualdataprevmon{3};end
            if month~=monthiwl;actualdatanextmon=actualdatanextmon{3};end
                %size of actualdata should now be (144)x(73)x(1 level)x(# days in month)
            relmon=month-monthiwf+1;    
            
            for dayinmonth=1:size(actualdata,4)
                todaysdata=actualdata(:,:,1,dayinmonth);
                if dayinmonth~=1 && dayinmonth~=size(actualdata,4) %normal situation
                    yesterdaysdata=actualdata(:,:,1,dayinmonth-1);
                    tomorrowsdata=actualdata(:,:,1,dayinmonth+1);
                elseif dayinmonth==1 && month~=monthiwf
                    yesterdaysdata=actualdataprevmon(:,:,1,size(actualdataprevmon,4)); %yesterday=last day of prev month
                    tomorrowsdata=actualdata(:,:,1,dayinmonth+1);
                elseif dayinmonth==size(actualdata,4) && month~=monthiwl
                    yesterdaysdata=actualdata(:,:,1,dayinmonth-1);
                    tomorrowsdata=actualdatanextmon(:,:,1,1); %tomorrow=first day of next month
                elseif dayinmonth==1 && month==monthiwf %just put double the weight on the target day
                    yesterdaysdata=actualdata(:,:,1,dayinmonth);
                    tomorrowsdata=actualdata(:,:,1,dayinmonth+1);
                elseif dayinmonth==size(actualdata,4) && month==monthiwl %ditto
                    yesterdaysdata=actualdata(:,:,1,dayinmonth-1);
                    tomorrowsdata=actualdata(:,:,1,dayinmonth);
                end
                fullhgtdata{relmon,dayinmonth}=fullhgtdata{relmon,dayinmonth}+...
                    0.25.*yesterdaysdata+0.5.*todaysdata+0.25.*tomorrowsdata;
                %disp(max(max(fullhgtdata{relmon,dayinmonth})));
            end
        end
    end
    %disp(max(max(fullhgtdata{relmon,dayinmonth})));
    
    %Divide by the number of years to get the daily average
    for month=monthiwf:monthiwl
        relmon=month-monthiwf+1;
        for dayinmonth=1:monthlengthsdays(relmon)
            fullhgtdata{relmon,dayinmonth}=fullhgtdata{relmon,dayinmonth}./(yeariwl-yeariwf+1);
        end
    end
    fullhgtdatancep=fullhgtdata;
    save(strcat(curDir,'griddedavgsarrays'),'fullhgtdatancep','-append');
end

%Calculate statistical significance of effect of ENSO on NCEP gh500 anomaly composites
%Methodology: 
%For each gridpt in a region's gh500 anomaly composite, 
if statsignifensopatterns==1
end

%Do grunt work to enable predictability of extreme WBT from certain gh500 patterns at various lead times
%This entails searching through the NCEP record for highs and lows of standardized magnitude >=0.4 from
%180 W to 50 W and from 0 N to 60 N, using 10x10 boxes to discretize, and then assessing in what percent of
%instances are these boxed highs and lows followed by regional-extreme-WBT days in various parts of the US
if predictabilityfromgh500==1
    %Step 1. Turn all the NCEP gh500 data into a standardized-anomaly height field, using a point-by-point approach
    %To view: imagescnan(squeeze(gh500stananomsncep{22,3}(1,:,:)))
    if dostep1==1
        for year=yeariwf:yeariwl
        %for year=2002:2002
            relyear=year-yeariwf+1;fprintf('Currently on year %d\n',year);
            for month=monthiwf:monthiwl
            %for month=7:7
                relmonth=month-monthiwf+1;
                if month<=9;addedzero='0';else addedzero='';end
                relevantmatfile=load(strcat(ncepdailydataDir,'hgt/',num2str(year),'/',...
                    'hgt_',num2str(year),'_',addedzero,num2str(month),'_500.mat'));
                actualdata=eval(['relevantmatfile.hgt_' num2str(year) '_' addedzero num2str(month) '_500']);
                actualdata=actualdata{3}; %size of actualdata should now be (144)x(73)x(1 level)x(# days in month)
                for day=1:size(actualdata,4)
                    actualdatathisday=actualdata(:,:,:,day);
                    thisdayavg=fullhgtdatancep{month-monthiwf+1,day};
                    thisdayanom=actualdatathisday-thisdayavg;
                    thisdaystananom=(actualdatathisday-thisdayavg)./stdevdatabymon{month-monthiwf+1};
                    gh500anomsncep{relyear,relmonth}(day,:,:)=thisdayanom;
                    gh500stananomsncep{relyear,relmonth}(day,:,:)=thisdaystananom;
                end
            end
        end
    end
    
    %Step 2. Search for (and make a list of the dates of) highs and lows of standardized magnitude >=0.5 within the boxes described above
    %If a pressure system exists for multiple days, choose to reference the day on which it is strongest a.k.a. most anomalous
    if dostep2==1
        categc=zeros(55,310,16);peaklist=0;
        for i=1:55;for j=1:310;if rem(i,5)~=0 || rem(j,5)~=0 || j<185 || rem(i,10)==0 || rem(j,10)==0;for k=1:16;categc(i,j,k)=NaN;end;end;end;end
        for year=yeariwf:yeariwl
        %for year=1981:1985
            relyear=year-yeariwf+1;
            fprintf('Year is %d\n',year);
            for month=monthiwf:monthiwl
            %for month=5:5
                relmonth=month-monthiwf+1;
                for day=1:monthlengthsdays(relmonth)
                    curstananommap=squeeze(gh500stananomsncep{relyear,relmonth}(day,:,:));

                    for i=1:144
                        for j=1:73
                            if nceplats(i,j)>=0 && nceplats(i,j)<=60 && ...
                                    nceplons(i,j)>=180 && nceplons(i,j)<=310
                                smalli=0;smallj=0;largei=0;largej=0;
                                foundpeak=0;boxnum=0;
                                if i==1 || i==144 || j==1 || j==73
                                    distfromedge=0;
                                    if i==1 && j~=1;smalli=1;else smalli=0;end
                                    if j==1 && i~=1;smallj=1;else smallj=0;end
                                    if i==144 && j~=73;largei=1;else largei=0;end
                                    if j==73 && i~=144;largej=1;else largej=0;end
                                elseif i==2 || i==143 || j==2 || j==72
                                    distfromedge=1;
                                    if i==2 && j~=2;smalli=1;else smalli=0;end
                                    if j==2 && i~=2;smallj=1;else smallj=0;end
                                    if i==143 && j~=72;largei=1;else largei=0;end
                                    if j==72 && i~=143;largej=1;else largej=0;end
                                elseif i==3 || i==142 || j==3 || j==71
                                    distfromedge=2;
                                    if i==3 && j~=3;smalli=1;else smalli=0;end
                                    if j==3 && i~=3;smallj=1;else smallj=0;end
                                    if i==142 && j~=71;largei=1;else largei=0;end
                                    if j==71 && i~=142;largej=1;else largej=0;end
                                else
                                    distfromedge=1000;
                                end
                                arraytouse=curstananommap;
                                peakfind2d;

                                if abs(curstananommap(i,j))>=0.4 && foundpeak==1
                                    boxedpeaklat=5+round2(peaklat,10,'floor');
                                        if boxedpeaklat==65;boxedpeaklat=55;end
                                    boxedpeaklon=5+round2(peaklon,10,'floor');
                                        if boxedpeaklon==315;boxedpeaklon=305;end
                                    if boxnum~=0
                                        categc(boxedpeaklat,boxedpeaklon,boxnum)=categc(boxedpeaklat,boxedpeaklon,boxnum)+1;
                                        temp=categc(boxedpeaklat,boxedpeaklon,boxnum);
                                    
                                        peaklist(boxedpeaklat,boxedpeaklon,boxnum,1,temp)=peakval;
                                        peaklist(boxedpeaklat,boxedpeaklon,boxnum,2,temp)=year;
                                        peaklist(boxedpeaklat,boxedpeaklon,boxnum,3,temp)=month;
                                        peaklist(boxedpeaklat,boxedpeaklon,boxnum,4,temp)=day;
                                        peaklist(boxedpeaklat,boxedpeaklon,boxnum,5,temp)=peaklat;
                                        peaklist(boxedpeaklat,boxedpeaklon,boxnum,6,temp)=peaklon;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    %Step 3. Determine what percentage of instances of a particular situation (e.g. a strong high-pressure at 45N, 135W)
        %result in extreme-WBT (top-100) days in the various regions of the country
    %As a system could hang around for multiple consecutive days, use the first day in such a series as the point of reference
    %To allow for inexactness of timing while still keeping useful discernible categories, 
    %the following system is used:
    %If an extreme-WBT day follows one of these peaks with X-Y days' lag, it is considered a 'hit' that falls under the category of Z as plotted in other figures
    %X=0,Y=0,Z=0 (categ 1)
    %X=1,Y=3,Z=2 (categ 2)
    %X=4,Y=7,Z=5 (categ 3)
    %X=8,Y=14,Z=10 (categ 4)
    %X=15,Y=25,Z=20 (categ 5)
    if dostep3==1
        pcthitlist=zeros(6,13,16,8,5); %dims are peak lat box, peak lon box, magnitude box, NCA region, lag category
        counthitlist=zeros(6,13,16,8,5);
        pcthitlistallhighs=zeros(6,13,8,5);pcthitlistallhighssm=zeros(6,13,8,5);
        peaklatc=0;
        for peaklat=5:10:55
        %for peaklat=45:45
            fprintf('peak lat is %d\n',peaklat);
            peaklatc=peaklatc+1;
            peaklonc=0;
            for peaklon=185:10:305
            %for peaklon=295:295
                fprintf('peak lon is %d\n',peaklon);
                peaklonc=peaklonc+1;
                for boxnum=1:16
                    %fprintf('boxnum is %d\n',boxnum);
                    temp={};for i=1:8;temp{i}=zeros(5,1);end %initialize NCA-region sums
                    colstocareabout=1;
                    cursectionofpeaklist=squeeze(peaklist(peaklat,peaklon,boxnum,:,:));
                    for col=2:size(cursectionofpeaklist,2)
                        if cursectionofpeaklist(1,col)~=0 %i.e. this entry isn't just a blank
                            if cursectionofpeaklist(2,col)==cursectionofpeaklist(2,col-1) &&...
                                abs(DatetoDOY(cursectionofpeaklist(3,col),cursectionofpeaklist(4,col),cursectionofpeaklist(2,col))-...
                                DatetoDOY(cursectionofpeaklist(3,col-1),cursectionofpeaklist(4,col-1),cursectionofpeaklist(2,col-1)))<=5
                            %disregard column as it's temporally redundant
                            else
                                colstocareabout=[colstocareabout;col];
                                %go ahead and see where (if anywhere) this peak was followed by an extreme-WBT (or extreme-T) day
                                yearthispeak=cursectionofpeaklist(2,col);
                                doythispeak=DatetoDOY(cursectionofpeaklist(3,col),cursectionofpeaklist(4,col),cursectionofpeaklist(2,col));
                                for ncareg=1:8
                                    thisreghitc=zeros(5,1);thisreghitplebiscite=zeros(5,1);
                                    for i=1:100
                                        yearthisi=arraytouse{ncareg}(i,1);
                                        monththisi=arraytouse{ncareg}(i,2);
                                        daythisi=arraytouse{ncareg}(i,3);
                                        doythisi=DatetoDOY(monththisi,daythisi,yearthisi);
                                        %See if there is a hit, i.e. if this extreme-WBT (or extreme-T) day in one of the regions follows this peak with a <=25-day lag
                                        if yearthisi==yearthispeak
                                            %disp('There is a potential match!');
                                            if doythisi-doythispeak==0 %same-day
                                                thisreghitc(1)=thisreghitc(1)+1;
                                            elseif doythisi-doythispeak>=1 && doythisi-doythispeak<=3 %1-3 days' lag
                                                thisreghitc(2)=thisreghitc(2)+1;
                                            elseif doythisi-doythispeak>=4 && doythisi-doythispeak<=7 %4-7 days' lag
                                                thisreghitc(3)=thisreghitc(3)+1;
                                            elseif doythisi-doythispeak>=8 && doythisi-doythispeak<=14 %8-14 days' lag
                                                thisreghitc(4)=thisreghitc(4)+1;
                                            elseif doythisi-doythispeak>=15 && doythisi-doythispeak<=25 %15-25 days' lag
                                                thisreghitc(5)=thisreghitc(5)+1;
                                            end
                                        end
                                    end
                                    for j=1:5;if thisreghitc(j)>=1;thisreghitplebiscite(j)=1;else thisreghitplebiscite(j)=0;end;end
                                    %if ncareg==8;disp(thisreghitc);disp(thisreghitplebiscite);end %thisreghitc should be mostly 0's, 1's or 2's
                                    temp{ncareg}=temp{ncareg}+thisreghitplebiscite;
                                end
                            end
                        end
                    end
                    %disp(size(colstocareabout,1)); %number of instances of this pattern that were checked
                    numinstances(peaklatc,peaklonc,boxnum)=size(colstocareabout,1);
                    for ncareg=1:8
                        pcthitlist(peaklatc,peaklonc,boxnum,ncareg,:)=round(100.*temp{ncareg}./size(colstocareabout,1));
                        counthitlist(peaklatc,peaklonc,boxnum,ncareg,:)=temp{ncareg};
                    end
                end
            end
        end
        for a=1:size(pcthitlist,1)
            for b=1:size(pcthitlist,2)
                for d=1:size(pcthitlist,4)
                    for e=1:size(pcthitlist,5)
                        pcthitlistallhighs(a,b,d,e)=round(100.*sum(counthitlist(a,b,1:8,d,e))./sum(numinstances(peaklatc,peaklonc,1:8)));
                    end
                end
            end
        end
        %Smoothed version of pcthitlistallhighs
        for d=1:size(pcthitlist,4)
            for e=1:size(pcthitlist,5)
                newtemp=squeeze(pcthitlistallhighs(:,:,d,e));
                for a=1:size(pcthitlist,1)
                    for b=1:size(pcthitlist,2)
                        if a==1 && (b~=1 && b~=size(pcthitlist,2)) %0.4 weight on self, 0.15 weight on 3 neighbors, 0.075 weight on corner neighbors
                            newtemp(a,b)=0.4*newtemp(a,b)+0.15*newtemp(a,b+1)+0.15*newtemp(a+1,b)+...
                                0.15*newtemp(a,b-1)+0.075*newtemp(a+1,b+1)+0.075*newtemp(a+1,b-1);
                        elseif a==size(pcthitlist,1) && (b~=1 && b~=size(pcthitlist,2))
                            newtemp(a,b)=0.4*newtemp(a,b)+0.15*newtemp(a,b+1)+0.15*newtemp(a-1,b)+...
                                0.15*newtemp(a,b-1)+0.075*newtemp(a-1,b+1)+0.075*newtemp(a-1,b-1);
                        elseif b==1 && (a~=1 && a~=size(pcthitlist,1))
                            newtemp(a,b)=0.4*newtemp(a,b)+0.15*newtemp(a,b+1)+0.15*newtemp(a+1,b)+...
                                0.15*newtemp(a-1,b)+0.075*newtemp(a+1,b+1)+0.075*newtemp(a-1,b+1);
                        elseif b==size(pcthitlist,2) && (a~=1 && a~=size(pcthitlist,1))
                            newtemp(a,b)=0.4*newtemp(a,b)+0.15*newtemp(a,b-1)+0.15*newtemp(a+1,b)+...
                                0.15*newtemp(a-1,b)+0.075*newtemp(a+1,b-1)+0.075*newtemp(a-1,b-1);
                        elseif a==1 && b==1 %in the corner, so do 0.5 on self, 0.2 on neighbors, and 0.1 on corner neighbor
                            newtemp(a,b)=0.5*newtemp(a,b)+0.2*newtemp(a+1,b)+0.2*newtemp(a,b+1)+0.1*newtemp(a+1,b+1);
                        elseif a==1 && b==size(pcthitlist,2)
                            newtemp(a,b)=0.5*newtemp(a,b)+0.2*newtemp(a+1,b)+0.2*newtemp(a,b-1)+0.1*newtemp(a+1,b-1);
                        elseif a==size(pcthitlist,1) && b==1
                            newtemp(a,b)=0.5*newtemp(a,b)+0.2*newtemp(a,b+1)+0.2*newtemp(a-1,b)+0.1*newtemp(a-1,b+1);
                        elseif a==size(pcthitlist,1) && b==size(pcthitlist,2)
                            newtemp(a,b)=0.5*newtemp(a,b)+0.2*newtemp(a-1,b)+0.2*newtemp(a,b-1)+0.1*newtemp(a-1,b-1);
                        else %somewhere in the middle, so do 0.3 on self, 0.1 on neighbors, and 0.075 on corner neighbors
                            %disp('line 3874');
                            newtemp(a,b)=0.3*newtemp(a,b)+0.1*newtemp(a,b+1)+0.1*newtemp(a+1,b)+...
                                0.1*newtemp(a,b-1)+0.1*newtemp(a-1,b)+0.075*newtemp(a+1,b+1)+0.075*newtemp(a+1,b-1)+...
                                0.075*newtemp(a-1,b+1)+0.075*newtemp(a-1,b-1);
                        end
                    end
                end
                pcthitlistallhighssm(:,:,d,e)=flipud(newtemp);
            end
        end
        eval(['counthitlist' wbtort '=counthitlist;']);
        eval(['numinstances' wbtort '=numinstances;']);
        eval(['pcthitlist' wbtort '=pcthitlist;']);
        eval(['pcthitlistallhighs' wbtort '=pcthitlistallhighs;']);
        eval(['pcthitlistallhighssm' wbtort '=pcthitlistallhighssm;']);
        if strcmp(wbtort,'wbt')
            save(strcat(curArrayDir,'nceparrays'),'counthitlistwbt','numinstanceswbt','pcthitlistwbt',...
                'pcthitlistallhighswbt','pcthitlistallhighssmwbt','-append');
        else
            save(strcat(curArrayDir,'nceparrays'),'counthitlistt','numinstancest','pcthitlistt',...
                'pcthitlistallhighst','pcthitlistallhighssmt','-append');
        end
    end
    
    %Set up for plotting (and otherwise analyze) the arrays just calculated
    %Be sure to know which version of pcthitlistallhighssm is currently in use (WBT or T) before proceeding!
    if dostep4==1
        %Start off by plotting the matrix of probabilities for NE extreme-WBT days, lag 4-7 days (i.e. (:,:,8,3))
        %Interpretation: for a H of any strength centered at each gridcell, shading indicates percent of time
            %it was followed at lag 4-7 days by NE extreme WBT
        
        for ncareg=1:8
            for lagcateg=1:5
                meanpct=mean(mean(pcthitlistallhighssm(:,:,ncareg,lagcateg))); %percent of all days that are extreme-WBT days
                pcthitlistallhighssm(1:5,:,ncareg,lagcateg)=squeeze(pcthitlistallhighssm(1:5,:,ncareg,lagcateg))./meanpct; %pcts are now multiplicative factors
            end
        end
        
        %Testing
        figure(figc);clf;figc=figc+1;
        imagescnan(squeeze(pcthitlistallhighssm(1:5,:,8,3))); 
        colorbar;
        
        %Define as georeferenced array
        georefarray=NaN.*ones(144,73,8,5);
        for ncareg=1:8
            for lagcateg=1:5
                for i=1:5
                    for j=1:13
                        georefarray(71+4*j,11+4*i,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j+1,11+4*i,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j-1,11+4*i,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j,11+4*i+1,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j,11+4*i-1,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j+1,11+4*i+1,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j+1,11+4*i-1,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j-1,11+4*i+1,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j-1,11+4*i-1,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j,11+4*i-2,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j+1,11+4*i-2,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j-1,11+4*i-2,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j-2,11+4*i,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j-2,11+4*i-1,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j-2,11+4*i-2,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                        georefarray(71+4*j-2,11+4*i+1,ncareg,lagcateg)=pcthitlistallhighssm(i,j,ncareg,lagcateg);
                    end
                end
            end
        end
    end
end


%Compute T and q advection
%Scheme is based on that defined (very briefly) at http://cola.gmu.edu/grads/gadoc/gradfunccdiff.html
if computetqadvection==1
    if readindata==1
        for year=2012:2015
            if rem(year,4)==0;yearlen=366;else yearlen=365;end
            if strcmp(sfcor850,'sfc')
                T_field=permute(ncread(strcat('air.2m.',num2str(year),'.nc'),'air'),[2 1 3]);
                q_field=permute(ncread(strcat('shum.2m.',num2str(year),'.nc'),'shum'),[2 1 3]);
                u_field=permute(ncread(strcat('uwnd.10m.',num2str(year),'.nc'),'uwnd'),[2 1 3]);
                v_field=permute(ncread(strcat('vwnd.10m.',num2str(year),'.nc'),'vwnd'),[2 1 3]);
            else %read data for 850-mb instead
                if yearlen==365;nanchunk1=NaN.*ones(277,349,120*8);else nanchunk1=NaN.*ones(277,349,121*8);end
                nanchunk2=NaN.*ones(277,349,92*8); %Oct 1-Dec 31 is the same number of days every year
                
                T_field1=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/air/',num2str(year),'/air_',...
                    num2str(year),'_05_01'));T_field1=eval(['T_field1.air_' num2str(year) '_05_01;']);T_field1=squeeze(T_field1{3}(:,:,2,:));
                T_field2=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/air/',num2str(year),'/air_',...
                    num2str(year),'_06_01'));T_field2=eval(['T_field2.air_' num2str(year) '_06_01;']);T_field2=squeeze(T_field2{3}(:,:,2,:));
                T_field3=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/air/',num2str(year),'/air_',...
                    num2str(year),'_07_01'));T_field3=eval(['T_field3.air_' num2str(year) '_07_01;']);T_field3=squeeze(T_field3{3}(:,:,2,:));
                T_field4=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/air/',num2str(year),'/air_',...
                    num2str(year),'_08_01'));T_field4=eval(['T_field4.air_' num2str(year) '_08_01;']);T_field4=squeeze(T_field4{3}(:,:,2,:));
                T_field5=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/air/',num2str(year),'/air_',...
                    num2str(year),'_09_01'));T_field5=eval(['T_field5.air_' num2str(year) '_09_01;']);T_field5=squeeze(T_field5{3}(:,:,2,:));
                T_field=cat(3,nanchunk1,T_field1,T_field2,T_field3,T_field4,T_field5,nanchunk2);
                clear T_field1;clear T_field2;clear T_field3;clear T_field4;clear T_field5;
                
                q_field1=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/shum/',num2str(year),'/shum_',...
                    num2str(year),'_05_01'));q_field1=eval(['q_field1.shum_' num2str(year) '_05_01;']);q_field1=squeeze(q_field1{3}(:,:,2,:));
                q_field2=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/shum/',num2str(year),'/shum_',...
                    num2str(year),'_06_01'));q_field2=eval(['q_field2.shum_' num2str(year) '_06_01;']);q_field2=squeeze(q_field2{3}(:,:,2,:));
                q_field3=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/shum/',num2str(year),'/shum_',...
                    num2str(year),'_07_01'));q_field3=eval(['q_field3.shum_' num2str(year) '_07_01;']);q_field3=squeeze(q_field3{3}(:,:,2,:));
                q_field4=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/shum/',num2str(year),'/shum_',...
                    num2str(year),'_08_01'));q_field4=eval(['q_field4.shum_' num2str(year) '_08_01;']);q_field4=squeeze(q_field4{3}(:,:,2,:));
                q_field5=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/shum/',num2str(year),'/shum_',...
                    num2str(year),'_09_01'));q_field5=eval(['q_field5.shum_' num2str(year) '_09_01;']);q_field5=squeeze(q_field5{3}(:,:,2,:));
                q_field=cat(3,nanchunk1,q_field1,q_field2,q_field3,q_field4,q_field5,nanchunk2);
                clear q_field1;clear q_field2;clear q_field3;clear q_field4;clear q_field5;
                
                uwnd_field1=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/uwnd/',num2str(year),'/uwnd_',...
                    num2str(year),'_05_01'));uwnd_field1=eval(['uwnd_field1.uwnd_' num2str(year) '_05_01;']);uwnd_field1=squeeze(uwnd_field1{3}(:,:,2,:));
                uwnd_field2=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/uwnd/',num2str(year),'/uwnd_',...
                    num2str(year),'_06_01'));uwnd_field2=eval(['uwnd_field2.uwnd_' num2str(year) '_06_01;']);uwnd_field2=squeeze(uwnd_field2{3}(:,:,2,:));
                uwnd_field3=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/uwnd/',num2str(year),'/uwnd_',...
                    num2str(year),'_07_01'));uwnd_field3=eval(['uwnd_field3.uwnd_' num2str(year) '_07_01;']);uwnd_field3=squeeze(uwnd_field3{3}(:,:,2,:));
                uwnd_field4=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/uwnd/',num2str(year),'/uwnd_',...
                    num2str(year),'_08_01'));uwnd_field4=eval(['uwnd_field4.uwnd_' num2str(year) '_08_01;']);uwnd_field4=squeeze(uwnd_field4{3}(:,:,2,:));
                uwnd_field5=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/uwnd/',num2str(year),'/uwnd_',...
                    num2str(year),'_09_01'));uwnd_field5=eval(['uwnd_field5.uwnd_' num2str(year) '_09_01;']);uwnd_field5=squeeze(uwnd_field5{3}(:,:,2,:));
                u_field=cat(3,nanchunk1,uwnd_field1,uwnd_field2,uwnd_field3,uwnd_field4,uwnd_field5,nanchunk2);
                clear uwnd_field1;clear uwnd_field2;clear uwnd_field3;clear uwnd_field4;clear uwnd_field5;
                
                vwnd_field1=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/vwnd/',num2str(year),'/vwnd_',...
                    num2str(year),'_05_01'));vwnd_field1=eval(['vwnd_field1.vwnd_' num2str(year) '_05_01;']);vwnd_field1=squeeze(vwnd_field1{3}(:,:,2,:));
                vwnd_field2=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/vwnd/',num2str(year),'/vwnd_',...
                    num2str(year),'_06_01'));vwnd_field2=eval(['vwnd_field2.vwnd_' num2str(year) '_06_01;']);vwnd_field2=squeeze(vwnd_field2{3}(:,:,2,:));
                vwnd_field3=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/vwnd/',num2str(year),'/vwnd_',...
                    num2str(year),'_07_01'));vwnd_field3=eval(['vwnd_field3.vwnd_' num2str(year) '_07_01;']);vwnd_field3=squeeze(vwnd_field3{3}(:,:,2,:));
                vwnd_field4=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/vwnd/',num2str(year),'/vwnd_',...
                    num2str(year),'_08_01'));vwnd_field4=eval(['vwnd_field4.vwnd_' num2str(year) '_08_01;']);vwnd_field4=squeeze(vwnd_field4{3}(:,:,2,:));
                vwnd_field5=load(strcat('/Volumes/ExternalDriveA/NARR_3-hourly_data_mat/vwnd/',num2str(year),'/vwnd_',...
                    num2str(year),'_09_01'));vwnd_field5=eval(['vwnd_field5.vwnd_' num2str(year) '_09_01;']);vwnd_field5=squeeze(vwnd_field5{3}(:,:,2,:));
                v_field=cat(3,nanchunk1,vwnd_field1,vwnd_field2,vwnd_field3,vwnd_field4,vwnd_field5,nanchunk2);
                clear vwnd_field1;clear vwnd_field2;clear vwnd_field3;clear vwnd_field4;clear vwnd_field5;
            end

            temp=abs(T_field)>10^3;T_field(temp)=NaN;temp=abs(q_field)>10^3;q_field(temp)=NaN;q_field=q_field.*1000;
            temp=abs(u_field)>10^3;u_field(temp)=NaN;temp=abs(v_field)>10^3;v_field(temp)=NaN;
            
            %Get gradients and compute advection
            if gradientmethod==1
                [dT_x,dT_y]=gradient(T_field);dT=gradient(T_field);if laboriousway~=1;clear T_field;end
                [dq_x,dq_y]=gradient(q_field);dq=gradient(q_field);if laboriousway~=1;clear q_field;end
                dx=gradient(narrlons).*3.1416./180; %deg converted to radians
                    dxinm=6.37*10^6.*dx; %radians to m
                [~,dy]=gradient(narrlats);dy=dy.*3.1416./180; %deg converted to radians
                    dyinm=6.37*10^6.*dy; %radians to m

                %Actually compute advection
                for i=1:yearlen*8;narrlatsextended(:,:,i)=narrlats;end
                Tadv=-((u_field.*dT_x)./(cos(narrlatsextended.*3.1416/180).*dx)+v_field.*dT_y.*dy)./(6.37*10^6); %in deg C per second
                qadv=-((u_field.*dq_x)./(cos(narrlatsextended.*3.1416/180).*dx)+v_field.*dq_y.*dy)./(6.37*10^6); %in g/kg per second
                if laboriousway~=1;clear u_field;clear v_field;end
                Tadv=Tadv.*3600; %in deg C per hour
                qadv=qadv.*3600; %in deg C per hour
            end
            %The workflow now goes right to the "Sum to get daily sums" part that's down past the interceding loops below
            
            %A more laborious but probably more-accurate way that involves looking through gridpoints one at a time
            if laboriousway==1
                advcomponent=zeros(277,349,2920);firstadjcomponent=zeros(277,349,2920);secondadjcomponent=zeros(277,349,2920);
                totalwesteastenergytransfer=zeros(277,349,2920);totalsouthnorthenergytransfer=zeros(277,349,2920);
                totalenergytransfer=zeros(277,349,2920);
                totalenergyadv=zeros(277,349,2920);totalenergyadj1=zeros(277,349,2920);totalenergyadj2=zeros(277,349,2920);
                for i=2:276
                    for j=2:348
                        %Only plotting usa, so points outside that can be ignored
                        if narrlats(i,j)>=25 && narrlats(i,j)<=50 && narrlons(i,j)>=-126 && narrlons(i,j)<=-64
                            thisptelev=double(sfcelev(i,j));
                            westptelev=double(sfcelev(i,j-1));eastptelev=double(sfcelev(i,j+1));
                            southptelev=double(sfcelev(i-1,j));northptelev=double(sfcelev(i+1,j));

                            %Get distances of each point from the central one,
                                %and convert these distances from deg to m
                            %This is complex because the gridpoints are arranged in a pattern skewed relative to the lat/lon grid
                            westtocentralxdistdeg=abs(narrlons(i,j-1)-narrlons(i,j));
                            westtocentralxdistm=(westtocentralxdistdeg.*cos(narrlats(i,j)*3.1416/180)).*1.11*10^5;
                            westtocentralydistm=abs(narrlats(i,j-1)-narrlats(i,j)).*1.11*10^5; %small but nonzero

                            easttocentralxdistdeg=abs(narrlons(i,j+1)-narrlons(i,j));
                            easttocentralxdistm=(easttocentralxdistdeg.*cos(narrlats(i,j)*3.1416/180)).*1.11*10^5;
                            easttocentralydistm=abs(narrlats(i,j+1)-narrlats(i,j)).*1.11*10^5;

                            southtocentralxdistdeg=abs(narrlons(i-1,j)-narrlons(i,j));
                            southtocentralxdistm=(southtocentralxdistdeg.*cos(narrlats(i,j)*3.1416/180)).*1.11*10^5;
                            southtocentralydistm=abs(narrlats(i-1,j)-narrlats(i,j)).*1.11*10^5;

                            northtocentralxdistdeg=abs(narrlons(i+1,j)-narrlons(i,j));
                            northtocentralxdistm=(northtocentralxdistdeg.*cos(narrlats(i,j)*3.1416/180)).*1.11*10^5;
                            northtocentralydistm=abs(narrlats(i+1,j)-narrlats(i,j)).*1.11*10^5;

                            %Compute advection at each 3-hour interval purely based on the T difference
                                %between each point and the center
                            %Advection is calculated using the T at the two
                                %relevant upwind points, and we know which those are simply from the wind direction
                            %Each difference is computed in the sense east-west and north-south
                            clear westtocentralTdiff;
                            westtocentralTdiff=squeeze(T_field(i,j,:)-T_field(i,j-1,:));
                            westtocentralTxgrad=westtocentralTdiff./westtocentralxdistm; %in K/m
                            if westtocentralydistm>5000 %otherwise unrealistic values are obtained
                                westtocentralTygrad=westtocentralTdiff./westtocentralydistm;
                            else
                                westtocentralTygrad=NaN.*ones(2920,1);
                            end

                            clear centraltoeastTdiff;
                            centraltoeastTdiff=squeeze(T_field(i,j+1,:)-T_field(i,j,:));
                            centraltoeastTxgrad=centraltoeastTdiff./easttocentralxdistm;
                            if easttocentralydistm>5000
                                centraltoeastTygrad=centraltoeastTdiff./easttocentralydistm;
                            else
                                centraltoeastTygrad=NaN.*ones(2920,1);
                            end
                            
                            clear southtocentralTdiff;
                            southtocentralTdiff=squeeze(T_field(i,j,:)-T_field(i-1,j,:));
                            southtocentralTygrad=southtocentralTdiff./southtocentralydistm; %in K/m
                            if southtocentralxdistm>5000 %otherwise unrealistic values are obtained
                                southtocentralTxgrad=southtocentralTdiff./southtocentralxdistm;
                            else
                                southtocentralTxgrad=NaN.*ones(2920,1);
                            end

                            clear centraltonorthTdiff;
                            centraltonorthTdiff=squeeze(T_field(i+1,j,:)-T_field(i,j,:));
                            centraltonorthTygrad=centraltonorthTdiff./northtocentralydistm;
                            if northtocentralxdistm>5000
                                centraltonorthTxgrad=centraltonorthTdiff./northtocentralxdistm;
                            else
                                centraltonorthTxgrad=NaN.*ones(2920,1);
                            end

                            %Advection in each direction is the product of the
                                %wind in that direction times the T gradient in that direction
                            westtocentralTxadv=squeeze(u_field(i,j,:)).*westtocentralTxgrad; %in K/s
                            westtocentralTyadv=squeeze(v_field(i,j,:)).*westtocentralTygrad;
                            centraltoeastTxadv=squeeze(u_field(i,j,:)).*centraltoeastTxgrad;
                            centraltoeastTyadv=squeeze(v_field(i,j,:)).*centraltoeastTygrad;
                            southtocentralTxadv=squeeze(u_field(i,j,:)).*southtocentralTxgrad; %in K/s
                            southtocentralTyadv=squeeze(v_field(i,j,:)).*southtocentralTygrad;
                            centraltonorthTxadv=squeeze(u_field(i,j,:)).*centraltonorthTxgrad;
                            centraltonorthTyadv=squeeze(v_field(i,j,:)).*centraltonorthTygrad;

                            westtocentraltotalTadv=nansum([westtocentralTxadv westtocentralTyadv],2).*10800; %in K/3 hr
                            westtocentraltotalenergyadv=squeeze(westtocentraltotalTadv.*1005.*10357./10800); %in W/m^2
                            %if max(westtocentraltotalenergyadv)>10^6;[a,b]=max(westtocentraltotalenergyadv);disp(a);disp(b);disp(i);disp(j);return;end
                            centraltoeasttotalTadv=nansum([centraltoeastTxadv centraltoeastTyadv],2).*10800; %in K/3 hr
                            centraltoeasttotalenergyadv=squeeze(centraltoeasttotalTadv.*1005.*10357./10800); %in W/m^2
                            southtocentraltotalTadv=nansum([southtocentralTxadv southtocentralTyadv],2).*10800; %in K/3 hr
                            southtocentraltotalenergyadv=squeeze(southtocentraltotalTadv.*1005.*10357./10800); %in W/m^2
                            centraltonorthtotalTadv=nansum([centraltonorthTxadv centraltonorthTyadv],2).*10800; %in K/3 hr
                            centraltonorthtotalenergyadv=squeeze(centraltonorthtotalTadv.*1005.*10357./10800); %in W/m^2

                            %First adjustment is simply adjusting for the temperature change due to the dry adiabatic lapse rate
                            if u_field(i,j,k)>0 %wind is from west
                                westtocentraldalrchange=-9.81*(thisptelev-westptelev)/1000; %in K
                                %Use cp*dtheta*mean mass of atmos in kg/m^2
                                westtocentralenergyadj1=1005.*westtocentraldalrchange.*10357./10800; %in W/m^2
                                westeastenergyadj1=repmat(westtocentralenergyadj1,2920,1);
                            else
                                centraltoeastdalrchange=-9.81*(thisptelev-eastptelev)/1000;
                                centraltoeastenergyadj1=1005.*centraltoeastdalrchange.*10357./10800; %in W/m^2
                                westeastenergyadj1=repmat(centraltoeastenergyadj1,2920,1);
                            end
                            if v_field(i,j,k)>0 %wind is from south
                                southtocentraldalrchange=-9.81*(thisptelev-southptelev)/1000; %in K
                                %Use cp*dtheta*mean mass of atmos in kg/m^2
                                southtocentralenergyadj1=1005.*southtocentraldalrchange.*10357./10800; %in W/m^2
                                southnorthenergyadj1=repmat(southtocentralenergyadj1,2920,1);
                            else
                                centraltonorthdalrchange=-9.81*(thisptelev-northptelev)/1000;
                                centraltonorthenergyadj1=1005.*centraltonorthdalrchange.*10357./10800; %in W/m^2
                                southnorthenergyadj1=repmat(centraltonorthenergyadj1,2920,1);
                            end

                            %Second adjustment is accounting for any condensation
                            westtocentralenergyadj2=zeros(2920,1);centraltoeastenergyadj2=zeros(2920,1);
                            westeastenergyadj2=zeros(2920,1);
                            southtocentralenergyadj2=zeros(2920,1);centraltonorthenergyadj2=zeros(2920,1);
                            southnorthenergyadj2=zeros(2920,1);
                            for k=1:2920
                                %Is the wind oriented from west to east, or vice versa?
                                if u_field(i,j,k)>=0 %wind is from west
                                    actualqatTofwestpt=q_field(i,j-1,k);
                                    satqatTofcentralpt=6.11*10.^(7.5*(T_field(i,j,k)-273.15)./(237.3+(T_field(i,j,k)-273.15)));
                                    if actualqatTofwestpt>satqatTofcentralpt
                                        westtocentralenergyadj2(k)=2260.*(actualqatTofwestpt-satqatTofcentralpt); %in J
                                        %Divide by the number of seconds in 3 hours, then multiply by the mean mass of the atmosphere in kg/m^2
                                        westeastenergyadj2(k)=westtocentralenergyadj2(k)./10800.*10357; %in W/m^2
                                    end
                                else %wind is from east
                                    actualqatTofeastpt=q_field(i,j+1,k);
                                    satqatTofcentralpt=6.11*10.^(7.5*(T_field(i,j,k)-273.15)./(237.3+(T_field(i,j,k)-273.15)));
                                    if actualqatTofeastpt>satqatTofcentralpt
                                        centraltoeastenergyadj2(k)=2260.*(actualqatTofeastpt-satqatTofcentralpt); %in J
                                        %Divide by the number of seconds in 3 hours, then multiply by the mean mass of the atmosphere in kg/m^2
                                        westeastenergyadj2(k)=centraltoeastenergyadj2(k)./10800.*10357; %in W/m^2
                                    end
                                end
                                
                                %Is the wind oriented from south to north, or vice versa?
                                %SHOULD THIS BE 1/CP*DQ/DZ??
                                if v_field(i,j,k)>=0 %wind is from south
                                    actualqatTofsouthpt=q_field(i-1,j,k);
                                    satqatTofcentralpt=6.11*10.^(7.5*(T_field(i,j,k)-273.15)./(237.3+(T_field(i,j,k)-273.15)));
                                    if actualqatTofsouthpt>satqatTofcentralpt
                                        southtocentralenergyadj2(k)=2260.*(actualqatTofsouthpt-satqatTofcentralpt); %in J
                                        %Divide by the number of seconds in 3 hours, then multiply by the mean mass of the atmosphere in kg/m^2
                                        southnorthenergyadj2(k)=southtocentralenergyadj2(k)./10800.*10357; %in W/m^2
                                    end
                                else %wind is from north
                                    actualqatTofnorthpt=q_field(i+1,j,k);
                                    satqatTofcentralpt=6.11*10.^(7.5*(T_field(i,j,k)-273.15)./(237.3+(T_field(i,j,k)-273.15)));
                                    if actualqatTofnorthpt>satqatTofcentralpt
                                        centraltonorthenergyadj2(k)=2260.*(actualqatTofnorthpt-satqatTofcentralpt); %in J
                                        %Divide by the number of seconds in 3 hours, then multiply by the mean mass of the atmosphere in kg/m^2
                                        southnorthenergyadj2(k)=centraltonorthenergyadj2(k)./10800.*10357; %in W/m^2
                                    end
                                end
                            end

                            %Compute final energy change (in W/m^2) due to advection and associated horizontal motions
                            %advcomponent(i,j,:)=westtocentraltotalenergyadv;
                            %firstadjcomponent(i,j,:)=westeastenergyadj1;
                            %secondadjcomponent(i,j,:)=westeastenergyadj2;
                            if u_field(i,j,k)>0
                                totalwesteastenergyadv=westtocentraltotalenergyadv-centraltoeasttotalenergyadv;
                            else
                                totalwesteastenergyadv=centraltoeasttotalenergyadv-westtocentraltotalenergyadv;
                            end
                            totalwesteastenergytransfer(i,j,:)=totalwesteastenergyadv+westeastenergyadj1+westeastenergyadj2;
                            
                            if v_field(i,j,k)>0
                                totalsouthnorthenergyadv=southtocentraltotalenergyadv-centraltonorthtotalenergyadv;
                            else
                                totalsouthnorthenergyadv=centraltonorthtotalenergyadv-southtocentraltotalenergyadv;
                            end
                            totalsouthnorthenergytransfer(i,j,:)=totalsouthnorthenergyadv+southnorthenergyadj1+southnorthenergyadj2;
                            
                            %Finally, the net total horizontal energy transfer for this gridpoint, and its components
                            totalenergyadv(i,j,:)=totalwesteastenergyadv+totalsouthnorthenergyadv;
                            totalenergyadj1(i,j,:)=westeastenergyadj1+southnorthenergyadj1;
                            totalenergyadj2(i,j,:)=westeastenergyadj2+southnorthenergyadj2;
                            totalenergytransfer(i,j,:)=totalwesteastenergytransfer(i,j,:)+totalsouthnorthenergytransfer(i,j,:);
                        end
                    end
                    if rem(i,20)==0;disp('line 4542');disp(i);disp(clock);end
                end
                save('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/tqadvstuff.mat','totalwesteastenergytransfer','totalsouthnorthenergytransfer','totalenergytransfer',...
                    'totalenergyadv','totalenergyadj1','totalenergyadj2','westeastenergyadj1','southnorthenergyadj1','westeastenergyadj2',...
                    'southnorthenergyadj2');
            end
            %Verification plots for above loop
            %figure(figc);clf;figc=figc+1;imagescnan(squeeze(totalenergytransfer(:,:,2000)));colorbar;caxis([-2000 2000]);
            %figure(figc);clf;figc=figc+1;imagescnan(squeeze(totalenergyadv(:,:,2000)));colorbar;caxis([-2000 2000]);
            %figure(figc);clf;figc=figc+1;imagescnan(squeeze(totalenergyadj1(:,:,2000)));colorbar;caxis([-2000 2000]);
            %figure(figc);clf;figc=figc+1;imagescnan(squeeze(totalenergyadj2(:,:,2000)));colorbar;caxis([-2000 2000]);
                
            %Eliminate the artificial cooling (warming) effect seen in areas where air is moving downhill (uphill)
            %1. Identify areas where the elevation gradient is large enough
                %for this to be a noticeable problem (>150 m/deg)
            if elimproblemsfirstattempt==1
                sfcelev=ncread('ghofsfcnarr.nc','hgt')';temp=abs(sfcelev)>10^5;sfcelev(temp)=NaN;
                elevgradient=gradient(sfcelev);%steepgradients=abs(elevgradient)>=150;
                steepuphillgradients=double(elevgradient>=150);steepdownhillgradients=double(elevgradient<=-150);
                steepgradients=NaN.*ones(277,349);
                %for i=1:277;for j=1:349;if steepuphillgradients(i,j)==1;steepgradients(i,j)=1;elseif steepdownhillgradients(i,j)==1;steepgradients(i,j)=-1;end;end;end
                %2. Identify steep areas where air is moving uphill or downhill
                %for i=1:yearlen*8;steepgradientsextended(:,:,i)=steepgradients;end
                steepuphill=u_field.*steepuphillgradients+v_field.*steepuphillgradients; %values >0 of this matrix are uphill motion, values <0 are actually downhill
                steepdownhill=u_field.*steepdownhillgradients+v_field.*steepdownhillgradients; %values >0 of this matrix are downhill motion, values <0 are actually uphill
                %3. Adjust Tadv for a. the amount of q condensed when moving from
                    %T1 to T2 (initially at the DALR, then the moist if necessary) and b. the resultant feedback effect on T
                [xelevgrad,yelevgrad]=gradient(sfcelev); %elev gradients are in m/deg -- want them to be in m (vertical) per m (horizontal)
                %relevantdist=sqrt(dxinm.^2+dyinm.^2);
                xelevdiffinm=xelevgrad.*(180/3.1416)./(6.37*10^6).*dxinm; %elev difference across this point in the east-west dir, in m
                yelevdiffinm=yelevgrad.*(180/3.1416)./(6.37*10^6).*dyinm; %elev difference across this point in the north-south dir, in m
                theta1=atan(abs(xelevdiffinm)./abs(yelevdiffinm)); %in radians, restricted to the 0->pi/2 window for the moment
                %Make theta an accurate representation of the orientation of
                    %the local slope, in radians (so in the 0->2*pi window)
                for i=1:277
                    for j=1:349
                        if xelevdiffinm(i,j)>=0 && yelevdiffinm(i,j)<=0
                            theta1(i,j)=theta1(i,j)+3.1416/2;
                        elseif xelevdiffinm(i,j)<=0 && yelevdiffinm(i,j)<=0
                            theta1(i,j)=theta1(i,j)+3.1416;
                        elseif xelevdiffinm(i,j)>=0 && yelevdiffinm(i,j)>=0
                            theta1(i,j)=theta1(i,j)+3*3.1416/2;
                        end
                    end
                end
                dTdz=dT./elevgradient;
                for i=1:277
                    for j=1:349
                        if steepuphill(i,j)==1 %westward- or southward-facing slope
                            %elevgrad=double(elevgradient(i,j));
                            for k=1:2920
                                tempdiff=dT(i,j,k);
                                satq=6.11*10.^(7.5*(T_field(i,j,k)-273.15)./(237.3+(T_field(i,j,k)-273.15)));
                                actualq=q_field(i,j,k).*1000;
                                %dTdz=tempgrad./elevgrad;
                            end
                        elseif steepdownhill(i,j)==-1 %eastward- or northward-facing slope

                        end
                    end
                end
            end
            clear u_field;clear v_field;clear T_field;clear q_field;

            %Sum to get daily sums of Tadv and qadv
            day=0;
            for hour=1:8:yearlen*8-7
                day=day+1;
                Tadvdailysums(:,:,day)=3.*sum(Tadv(:,:,hour:hour+7),3);
                qadvdailysums(:,:,day)=3.*sum(qadv(:,:,hour:hour+7),3);
            end
            
            %Have to clear variables or they'll get mixed up in size between leap & non-leap years
            clear Tadv;clear qadv;clear dT_x;clear dT_y;clear dq_x;clear dq_y;clear narrlatsextended;
            save(strcat('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/year',num2str(year),'tqadv'),...
                'Tadvdailysums','qadvdailysums','-v7.3');
            clear Tadvdailysums;clear qadvdailysums;
            disp(year);disp(clock);
        end
    end
    
    %Using the daily sums computed just above, calculate smoothed daily
        %climos of Tadv and qadv at each gridpoint -- possible for May-Sep
        %only, due to having T, q, wind data for just those months
    if computeclimo==1
        finalTadvclimo=NaN.*ones(277,349,153); %153 days in May-Sep
        finalqadvclimo=NaN.*ones(277,349,153);
        iint=90;jint=116;
        for iindex=1:iint:271-90 %most of the gridpoints
            for jindex=1:jint:348-116 %most of the gridpoints
                %Do necessary preparation by getting data for this section of the grid into a single matrix
                Tadvall=NaN.*ones(iint,jint,153,35); %153 days in May-Sep
                qadvall=NaN.*ones(iint,jint,153,35);
                for year=1981:2015
                    if rem(year,4)==0;yearlen=366;may1date=122;else yearlen=365;may1date=121;end
                    thisyearfile=load(strcat('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/year',...
                        num2str(year),'tqadv',num2str(sfcor850)));
                    Tadvthisyear=thisyearfile.Tadvdailysums;
                    qadvthisyear=thisyearfile.qadvdailysums;

                    Tadvall(:,:,:,year-1981+1)=Tadvthisyear(iindex:iindex+iint-1,jindex:jindex+jint-1,may1date:may1date+152);
                    qadvall(:,:,:,year-1981+1)=qadvthisyear(iindex:iindex+iint-1,jindex:jindex+jint-1,may1date:may1date+152);
                    fprintf('Year for climo computation is %d, with i=%d and j=%d\n',year,iindex,jindex);
                end

                %Now actually compute climo for this section of the grid --
                %by far the slowest part
                Tadvclimo=squeeze(nanmean(Tadvall,4));clear Tadvall;
                qadvclimo=squeeze(nanmean(qadvall,4));clear qadvall;
                for i=1:iint
                    for j=1:jint
                        if narrlats(iindex+i-1,jindex+j-1)>=25 && narrlats(iindex+i-1,jindex+j-1)<=50 &&...
                                narrlons(iindex+i-1,jindex+j-1)>=-126 && narrlons(iindex+i-1,jindex+j-1)<=-64
                            avgTsqueeze=squeeze(Tadvclimo(i,j,:));avgqsqueeze=squeeze(qadvclimo(i,j,:));
                            %Compute best fit separately for each gridpoint (using n=2), which can be verified with the interactive curve-fitting tool
                            dayvec=[1:153]';
                            thisfitTavg=fit(dayvec,avgTsqueeze,'fourier2');thisfitqavg=fit(dayvec,avgqsqueeze,'fourier2');
                            %plot(thisfitTavg,dayvec,avgTsqueeze); %verification
                            fittedvalsTavg=thisfitTavg(dayvec);fittedvalsqavg=thisfitqavg(dayvec);
                            
                            finalTadvclimo(iindex+i-1,jindex+j-1,:)=fittedvalsTavg;
                            finalqadvclimo(iindex+i-1,jindex+j-1,:)=fittedvalsqavg;
                        end
                    end
                    if rem(i,10)==0;fprintf('i=%d, jindex=%d, iiindex=%d\n',i,jindex,iindex);end
                end
            end
        end
        save('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/tqadvstuff.mat','finalTadvclimo','finalqadvclimo','-append');
        
        %Compute MW-avg and SW-avg climo Tadv and qadv for each day of the year
        theregions=ncaregionsfromlatlon(narrlats,narrlons);mwregion=theregions==6;swregion=theregions==3;
        mwtadvclimo=zeros(153,1);mwqadvclimo=zeros(153,1);
        swtadvclimo=zeros(153,1);swqadvclimo=zeros(153,1);
        for day=1:153
            tadvthisday=squeeze(finalTadvclimo(:,:,day));
            mwtadvthisday=tadvthisday;temp=mwregion~=1;mwtadvthisday(temp)=NaN;
            mwtadvclimo(day)=squeeze(nanmean(squeeze(nanmean(mwtadvthisday))));
            swtadvthisday=tadvthisday;temp=swregion~=1;swtadvthisday(temp)=NaN;
            swtadvclimo(day)=squeeze(nanmean(squeeze(nanmean(swtadvthisday))));

            qadvthisday=squeeze(finalqadvclimo(:,:,day));
            mwqadvthisday=qadvthisday;temp=mwregion~=1;mwqadvthisday(temp)=NaN;
            mwqadvclimo(day)=squeeze(nanmean(squeeze(nanmean(mwqadvthisday))));
            swqadvthisday=qadvthisday;temp=swregion~=1;swqadvthisday(temp)=NaN;
            swqadvclimo(day)=squeeze(nanmean(squeeze(nanmean(swqadvthisday))));
        end
        %Convert T values in bigtadvmatrix to energy fluxes in W/m^2
        %Use cp*dtheta*mean mass of atmos in kg/m^2
        numsecinaday=86400;cp=1005;meanatmosmass=10357;
        mwtadvclimoasflux=cp.*mwtadvclimo.*meanatmosmass./numsecinaday; %in W/m^2
        swtadvclimoasflux=cp.*swtadvclimo.*meanatmosmass./numsecinaday; %in W/m^2
        %Convert q values analogously, using L*q*mean atmos mass
        L=2260; %J/g
        mwqadvclimoasflux=L.*mwqadvclimo.*meanatmosmass./numsecinaday; %in W/m^2
        swqadvclimoasflux=L.*swqadvclimo.*meanatmosmass./numsecinaday; %in W/m^2
        
        save('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/tqadvstuff.mat',...
            'mwtadvclimoasflux','mwqadvclimoasflux','swtadvclimoasflux','swqadvclimoasflux','-append');
    end
    
    
    if analyzedata==1
        %Run through the top-XX extreme-WBT dates for each region (as
            %defined by NARR data) and, for each date, record the T & q adv up
            %to 20 days before and 5 days after, in both directions stopping if another extreme-WBT date is reached
        %Thus, the result of this computation is a 100x26x277x349 array
            %whose dimensions are number of extremes | days before/after extreme | daily sums of T & q adv
        sfcelev=ncread('ghofsfcnarr.nc','hgt')';
        for region=regtouse:regtouse
            %Set up matrices
            bigtadvmatrix=NaN.*ones(100,26,277,349);bigqadvmatrix=NaN.*ones(100,26,277,349);
            bigtadvmatrixanom=NaN.*ones(100,26,277,349);bigqadvmatrixanom=NaN.*ones(100,26,277,349);
            
            %Load climatological Tadv and qadv
            temp=load(strcat('tqadvstuff',num2str(sfcor850),'.mat'));
            mwtadvclimoasflux=temp.mwtadvclimoasflux;mwqadvclimoasflux=temp.mwqadvclimoasflux;
            swtadvclimoasflux=temp.swtadvclimoasflux;swqadvclimoasflux=temp.swqadvclimoasflux;
            
            %Chronologically sort this region's set of top-XX WBT dates
            thisset=topXXwbtdatesbyregionnarr{region};
            thisset=sortrows(thisset,[1 2 3]);
            for i=1:size(thisset,1)
                %Get date of this WBT extreme
                thisyr=thisset(i,1);if rem(thisyr,4)==0;apr30doy=121;else apr30doy=120;end
                thisdoy=DatetoDOY(thisset(i,2),thisset(i,3),thisset(i,1));
                
                %Load relevant year's Tadv & qadv matrices
                temp=load(strcat('year',num2str(thisyr),'tqadv850.mat'));
                Tadvdailysums=temp.Tadvdailysums;
                qadvdailysums=temp.qadvdailysums;
                
                %Get array of Tadv and qadv for this extreme-WBT day
                bigtadvmatrix(i,21,:,:)=Tadvdailysums(:,:,thisdoy);
                bigqadvmatrix(i,21,:,:)=qadvdailysums(:,:,thisdoy);
                bigtadvmatrixanom(i,21,:,:)=Tadvdailysums(:,:,thisdoy)-finalTadvclimo(:,:,thisdoy-apr30doy);
                bigqadvmatrixanom(i,21,:,:)=qadvdailysums(:,:,thisdoy)-finalqadvclimo(:,:,thisdoy-apr30doy);
                
                %Look forward 5 days from this day, stopping if necessary
                foundanotherextreme=0;
                for offsetforward=1:5
                    newdoy=thisdoy+offsetforward;
                    if i~=size(thisset,1)
                        nextextremedoy=DatetoDOY(thisset(i+1,2),thisset(i+1,3),thisset(i+1,1));
                        nextextremeyr=thisset(i+1,1);
                        if ~(newdoy==nextextremedoy && thisyr==nextextremeyr) && foundanotherextreme==0
                            %Go ahead
                            bigtadvmatrix(i,21+offsetforward,:,:)=Tadvdailysums(:,:,newdoy);
                            bigqadvmatrix(i,21+offsetforward,:,:)=qadvdailysums(:,:,newdoy);
                            bigtadvmatrixanom(i,21+offsetforward,:,:)=Tadvdailysums(:,:,newdoy)-finalTadvclimo(:,:,newdoy-apr30doy);
                            bigqadvmatrixanom(i,21+offsetforward,:,:)=qadvdailysums(:,:,newdoy)-finalqadvclimo(:,:,newdoy-apr30doy);
                        else
                            foundanotherextreme=1;
                        end
                    else
                        %Go ahead
                        bigtadvmatrix(i,21+offsetforward,:,:)=Tadvdailysums(:,:,newdoy);
                        bigqadvmatrix(i,21+offsetforward,:,:)=qadvdailysums(:,:,newdoy);
                        bigtadvmatrixanom(i,21+offsetforward,:,:)=Tadvdailysums(:,:,newdoy)-finalTadvclimo(:,:,newdoy-apr30doy);
                        bigqadvmatrixanom(i,21+offsetforward,:,:)=qadvdailysums(:,:,newdoy)-finalqadvclimo(:,:,newdoy-apr30doy);
                    end
                end
                
                %Look backward 20 days from this day, stopping if necessary
                foundanotherextreme=0;
                for offsetbackward=1:20
                    newdoy=thisdoy-offsetbackward;
                    if i~=1
                        prevextremedoy=DatetoDOY(thisset(i-1,2),thisset(i-1,3),thisset(i-1,1));
                        prevextremeyr=thisset(i-1,1);
                        if ~(newdoy==prevextremedoy && thisyr==prevextremeyr) && foundanotherextreme==0
                            %Go ahead
                            bigtadvmatrix(i,21-offsetbackward,:,:)=Tadvdailysums(:,:,newdoy);
                            bigqadvmatrix(i,21-offsetbackward,:,:)=qadvdailysums(:,:,newdoy);
                            bigtadvmatrixanom(i,21-offsetbackward,:,:)=Tadvdailysums(:,:,newdoy)-finalTadvclimo(:,:,newdoy-apr30doy);
                            bigqadvmatrixanom(i,21-offsetbackward,:,:)=qadvdailysums(:,:,newdoy)-finalqadvclimo(:,:,newdoy-apr30doy);
                        else
                            foundanotherextreme=1;
                        end
                    else
                        %Go ahead
                        bigtadvmatrix(i,21-offsetbackward,:,:)=Tadvdailysums(:,:,newdoy);
                        bigqadvmatrix(i,21-offsetbackward,:,:)=qadvdailysums(:,:,newdoy);
                        bigtadvmatrixanom(i,21-offsetbackward,:,:)=Tadvdailysums(:,:,newdoy)-finalTadvclimo(:,:,newdoy-apr30doy);
                        bigqadvmatrixanom(i,21-offsetbackward,:,:)=qadvdailysums(:,:,newdoy)-finalqadvclimo(:,:,newdoy-apr30doy);
                    end
                end
                %disp('line 4462');disp(i);
            end
            
            %Compute mean across top-XX extremes
            meantadvmatrix=squeeze(nanmean(bigtadvmatrix,1));
            meanqadvmatrix=squeeze(nanmean(bigqadvmatrix,1));
            meantadvmatrixanom=squeeze(nanmean(bigtadvmatrixanom,1));
            meanqadvmatrixanom=squeeze(nanmean(bigqadvmatrixanom,1));
            
            %Compute sum of advection over 48 hours leading up to the top-XX extremes
            sum48hrbeforetadv=squeeze(nanmean(squeeze(nanmean(bigtadvmatrix(:,19:20,:,:),1)),1));
            sum48hrbeforeqadv=squeeze(nanmean(squeeze(nanmean(bigqadvmatrix(:,19:20,:,:),1)),1));
            sum48hrbeforetadvanom=squeeze(nanmean(squeeze(nanmean(bigtadvmatrixanom(:,19:20,:,:),1)),1));
            sum48hrbeforeqadvanom=squeeze(nanmean(squeeze(nanmean(bigqadvmatrixanom(:,19:20,:,:),1)),1));
            
            save(strcat('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/region',...
                num2str(region),'tqadvmatrix',num2str(sfcor850)),...
                'bigtadvmatrix','bigqadvmatrix','meantadvmatrix','meanqadvmatrix','sum48hrbeforetadv','sum48hrbeforeqadv',...
                'bigtadvmatrixanom','bigqadvmatrixanom','-append');
            clear bigtadvmatrix;clear bigqadvmatrix;clear bigtadvmatrixanom;clear bigqadvmatrixanom;
            fprintf('Region just completed is %d\n',region);
        end
    end
    
    %Compute MW averages over various periods of interest
    if computeregavgs==1
        temp=load(strcat('region',num2str(regtouse),'tqadvmatrix',num2str(sfcor850)));
        bigtadvmatrix=temp.bigtadvmatrix;bigqadvmatrix=temp.bigqadvmatrix;
        bigtadvmatrixanom=temp.bigtadvmatrixanom;bigqadvmatrixanom=temp.bigqadvmatrixanom;
        theregions=ncaregionsfromlatlon(narrlats,narrlons);thisregion=theregions==regtouse;
        
        %Convert T values in bigtadvmatrix to energy fluxes in W/m^2
        %Use cp*dtheta*mean mass of atmos in kg/m^2
        numsecinaday=86400;cp=1005;meanatmosmass=10357;
        tadvasflux=cp.*bigtadvmatrix.*meanatmosmass./numsecinaday; %in W/m^2
        tadvanomasflux=cp.*bigtadvmatrixanom.*meanatmosmass./numsecinaday; %in W/m^2
        
        %Convert q values analogously, using the appropriate formula
        %Use L*dq*mean atmos mass
        L=2260; %J/g
        qadvasflux=L.*bigqadvmatrix.*meanatmosmass./numsecinaday; %in W/m^2
        qadvanomasflux=L.*bigqadvmatrixanom.*meanatmosmass./numsecinaday; %in W/m^2
        
        %Determine whether to use actual values or anomalies, and set up the
            %appropriate matrix
        if useanoms==1;tflux=tadvanomasflux;qflux=qadvanomasflux;else tflux=tadvasflux;qflux=qadvasflux;end
        
        %Compute the averages for each stage leading up to and encompassing the WBT extremes for the MW
        tadvavgdaysndb20tondb10=squeeze(nanmean(squeeze(nanmean(tflux(:,1:11,:,:),2)),1));
        regtadvavgdaysndb20tondb10=tadvavgdaysndb20tondb10;temp=thisregion~=1;regtadvavgdaysndb20tondb10(temp)=NaN; %still 277x349
        regtadvavgdaysndb20tondb10=nanmean(nanmean(regtadvavgdaysndb20tondb10)); %this is the daily average over each of these 11 days
        qadvavgdaysndb20tondb10=squeeze(nanmean(squeeze(nanmean(qflux(:,1:11,:,:),2)),1));
        regqadvavgdaysndb20tondb10=qadvavgdaysndb20tondb10;temp=thisregion~=1;regqadvavgdaysndb20tondb10(temp)=NaN; %still 277x349
        regqadvavgdaysndb20tondb10=nanmean(nanmean(regqadvavgdaysndb20tondb10)); %this is the daily average over each of these 11 days
        
        tadvstdevdaysndb20tondb10=squeeze(nanstd(squeeze(nanmean(tflux(:,1:11,:,:),2)),0,1));
        regtadvstdevdaysndb20tondb10=tadvstdevdaysndb20tondb10;temp=thisregion~=1;regtadvstdevdaysndb20tondb10(temp)=NaN; %still 277x349
        regtadvstdevdaysndb20tondb10=nanmean(nanmean(regtadvstdevdaysndb20tondb10));
        
        tadvavgdaysndb9tondb5=squeeze(nanmean(squeeze(nanmean(tflux(:,12:16,:,:),2)),1));
        regtadvavgdaysndb9tondb5=tadvavgdaysndb9tondb5;temp=thisregion~=1;regtadvavgdaysndb9tondb5(temp)=NaN; %still 277x349
        regtadvavgdaysndb9tondb5=nanmean(nanmean(regtadvavgdaysndb9tondb5)); %this is the daily average over each of these 5 days
        qadvavgdaysndb9tondb5=squeeze(nanmean(squeeze(nanmean(qflux(:,12:16,:,:),2)),1));
        regqadvavgdaysndb9tondb5=qadvavgdaysndb9tondb5;temp=thisregion~=1;regqadvavgdaysndb9tondb5(temp)=NaN; %still 277x349
        regqadvavgdaysndb9tondb5=nanmean(nanmean(regqadvavgdaysndb9tondb5)); %this is the daily average over each of these 5 days
        
        tadvavgdaysndb4tondb2=squeeze(nanmean(squeeze(nanmean(tflux(:,17:19,:,:),2)),1));
        regtadvavgdaysndb4tondb2=tadvavgdaysndb4tondb2;temp=thisregion~=1;regtadvavgdaysndb4tondb2(temp)=NaN; %still 277x349
        regtadvavgdaysndb4tondb2=nanmean(nanmean(regtadvavgdaysndb4tondb2)); %this is the daily average over each of these 3 days
        qadvavgdaysndb4tondb2=squeeze(nanmean(squeeze(nanmean(qflux(:,17:19,:,:),2)),1));
        regqadvavgdaysndb4tondb2=qadvavgdaysndb4tondb2;temp=thisregion~=1;regqadvavgdaysndb4tondb2(temp)=NaN; %still 277x349
        regqadvavgdaysndb4tondb2=nanmean(nanmean(regqadvavgdaysndb4tondb2)); %this is the daily average over each of these 3 days
        
        tadvavgdaysndb1=squeeze(nanmean(squeeze(nanmean(tflux(:,20,:,:),2)),1));
        regtadvavgdaysndb1=tadvavgdaysndb1;temp=thisregion~=1;regtadvavgdaysndb1(temp)=NaN; %still 277x349
        regtadvavgdaysndb1=nanmean(nanmean(regtadvavgdaysndb1)); %this is the daily average over this day
        qadvavgdaysndb1=squeeze(nanmean(squeeze(nanmean(qflux(:,20,:,:),2)),1));
        regqadvavgdaysndb1=qadvavgdaysndb1;temp=thisregion~=1;regqadvavgdaysndb1(temp)=NaN; %still 277x349
        regqadvavgdaysndb1=nanmean(nanmean(regqadvavgdaysndb1)); %this is the daily average over this day
        
        tadvavgdaysndb0=squeeze(nanmean(squeeze(nanmean(tflux(:,21,:,:),2)),1));
        regtadvavgdaysndb0=tadvavgdaysndb0;temp=thisregion~=1;regtadvavgdaysndb0(temp)=NaN; %still 277x349
        regtadvavgdaysndb0=nanmean(nanmean(regtadvavgdaysndb0)); %this is the daily average over this day
        qadvavgdaysndb0=squeeze(nanmean(squeeze(nanmean(qflux(:,21,:,:),2)),1));
        regqadvavgdaysndb0=qadvavgdaysndb0;temp=thisregion~=1;regqadvavgdaysndb0(temp)=NaN; %still 277x349
        regqadvavgdaysndb0=nanmean(nanmean(regqadvavgdaysndb0)); %this is the daily average over this day
        
        tadvavgdays1da=squeeze(nanmean(squeeze(nanmean(tflux(:,22,:,:),2)),1));
        regtadvavgdays1da=tadvavgdays1da;temp=thisregion~=1;regtadvavgdays1da(temp)=NaN; %still 277x349
        regtadvavgdays1da=nanmean(nanmean(regtadvavgdays1da)); %this is the daily average over this day
        qadvavgdays1da=squeeze(nanmean(squeeze(nanmean(qflux(:,22,:,:),2)),1));
        regqadvavgdays1da=qadvavgdays1da;temp=thisregion~=1;regqadvavgdays1da(temp)=NaN; %still 277x349
        regqadvavgdays1da=nanmean(nanmean(regqadvavgdays1da)); %this is the daily average over this day
        
        tadvavgdays2dato4da=squeeze(nanmean(squeeze(nanmean(tflux(:,23:25,:,:),2)),1));
        regtadvavgdays2dato4da=tadvavgdays2dato4da;temp=thisregion~=1;regtadvavgdays2dato4da(temp)=NaN; %still 277x349
        regtadvavgdays2dato4da=nanmean(nanmean(regtadvavgdays2dato4da)); %this is the daily average over each of these 3 days
        qadvavgdays2dato4da=squeeze(nanmean(squeeze(nanmean(qflux(:,23:25,:,:),2)),1));
        regqadvavgdays2dato4da=qadvavgdays2dato4da;temp=thisregion~=1;regqadvavgdays2dato4da(temp)=NaN; %still 277x349
        regqadvavgdays2dato4da=nanmean(nanmean(regqadvavgdays2dato4da)); %this is the daily average over each of these 3 days

        %Plots for this loop only
        figure(figc);clf;figc=figc+1;
        regtadvvector=[regtadvavgdaysndb20tondb10;regtadvavgdaysndb9tondb5;regtadvavgdaysndb4tondb2;...
            regtadvavgdaysndb1;regtadvavgdaysndb0;regtadvavgdays1da;regtadvavgdays2dato4da];
        regqadvvector=[regqadvavgdaysndb20tondb10;regqadvavgdaysndb9tondb5;regqadvavgdaysndb4tondb2;...
            regqadvavgdaysndb1;regqadvavgdaysndb0;regqadvavgdays1da;regqadvavgdays2dato4da];
        if regtouse==6
            mwtadvvector=regtadvvector;mwqadvvector=regqadvvector;
            %mwtadvvector(1)=mwtadvvector(1)+25;mwtadvvector(2)=mwtadvvector(2)+35;mwqadvvector(2)=mwqadvvector(2)+35; %necessary adjs
        elseif regtouse==3
            swtadvvector=regtadvvector;swqadvvector=regqadvvector;
        end
        dayvector=[-15;-7;-3;-1;0;1;3];
        scatter(dayvector,regtadvvector,'filled','r');hold on;
        scatter(dayvector,regqadvvector,'filled','b');
        
        %Save results
        save(strcat('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/region',...
            num2str(regtouse),'tqadvmatrix',num2str(sfcor850)),'regtadvvector','regqadvvector','-append');
    end
            
    %Plots to verify
    if verifplots==1
        for region=2:8
            savedfile=load(strcat('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/region',num2str(region),'tqadvmatrix'));
            bigtadvmatrix=savedfile.bigtadvmatrix;bigqadvmatrix=savedfile.bigqadvmatrix;
            bigtadvmatrixanom=savedfile.bigtadvmatrix;bigqadvmatrixanom=savedfile.bigqadvmatrix;
            meantadvmatrix=savedfile.meantadvmatrix;meanqadvmatrix=savedfile.meanqadvmatrix;
            sum48hrbeforetadv=savedfile.sum48hrbeforetadv;sum48hrbeforeqadv=savedfile.sum48hrbeforeqadv;
            regtadvvector=savedfile.regtadvvector;regqadvvector=savedfile.regqadvvector;
            
            temp=sfcelev>=1500;sum48hrbeforetadv(temp)=NaN; %gray out areas above 1500 m
            data={narrlats;narrlons;sum48hrbeforetadv};underlaydata=data;
            vararginnew={'underlayvariable';'generic scalar';'contour';1;'mystepunderlay';1;'plotCountries';1;...
            'underlaycaxismin';-7;'underlaycaxismax';7;'overlaynow';0;'anomavg';'avg'};
            regionformap='usa';datatype='NARR';
            plotModelData(data,regionformap,vararginnew,datatype);curpart=1;highqualityfiguresetup;
            title(sprintf('Tadv 48 hr before, for region %d\n',region));
            curpart=2;figloc='/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/';
            figname=strcat('verifplotregion',num2str(region),'tadv48hr');highqualityfiguresetup;

            temp=sfcelev>=1500;sum48hrbeforeqadv(temp)=NaN; %gray out areas above 1500 m
            data={narrlats;narrlons;sum48hrbeforeqadv};underlaydata=data;
            vararginnew={'underlayvariable';'generic scalar';'contour';1;'mystepunderlay';0.5;'plotCountries';1;...
            'underlaycaxismin';-5;'underlaycaxismax';5;'overlaynow';0;'anomavg';'avg'};
            regionformap='usa';datatype='NARR';
            plotModelData(data,regionformap,vararginnew,datatype);curpart=1;highqualityfiguresetup;
            title(sprintf('qadv 48 hr before, for region %d\n',region));
            curpart=2;figloc='/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/';
            figname=strcat('verifplotregion',num2str(region),'qadv48hr');highqualityfiguresetup;
        end
    end
end


%Analyze wave activity prior to and during extreme-WBT events (and perhaps their difference from those during extreme-T events)
    %using anomalies of v200 and z200
if v200andz200anoms==1
    %Establish climatology of v200 and z200
    if establishclimo==1
        %First, get all data
        for year=1981:2015
            vdata=ncread(strcat('vwnd.',num2str(year),'.nc'),'vwnd');vdata=squeeze(vdata(:,:,10,:));
            zdata=ncread(strcat('hgt.',num2str(year),'.nc'),'hgt');zdata=squeeze(zdata(:,:,10,:));

            allvdata(year-1981+1,:,:,:)=vdata(:,:,1:365);
            allzdata(year-1981+1,:,:,:)=zdata(:,:,1:365);
            disp(year);
        end
        
        %Now compute climo for each day of the year
        avgv200eachdoy=double(squeeze(nanmean(allvdata,1)));
        avgz200eachdoy=double(squeeze(nanmean(allzdata,1)));
        %Fit a smooth curve using harmonics -- has to be done separately for each gridpoint
        dayvec=[1:365]';
        for i=1:144
            for j=1:73
                v200fit=fit(dayvec,squeeze(avgv200eachdoy(i,j,:)),'fourier4');
                z200fit=fit(dayvec,squeeze(avgz200eachdoy(i,j,:)),'fourier3');
                %plot(v200fit,dayvec,temp) %for verification
                fittedvalsv200=v200fit(dayvec);
                fittedvalsz200=z200fit(dayvec);
                v200fitmatrix(i,j,:)=fittedvalsv200;
                z200fitmatrix(i,j,:)=fittedvalsz200;
            end
            %disp(i);
        end
        save('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/v200z500stuff',...
            'v200fitmatrix','z200fitmatrix','allvdata','allzdata','-append');
    end
    
    %Now read in data for top-XX T and WBT days
    if readinextremesdata==1
        clear vmatrixanomsbyregion;clear zmatrixanomsbyregion;
        topXXt=topXXtbyregionsorted;topXXwbt=topXXwbtbyregionsorted;
        daysbeforeopts=[20;10;5;2;1;0];
        for region=2:8
            for date=1:100
                thisdoy=DatetoDOY(topXXwbt{region}(date,2),topXXwbt{region}(date,3),topXXwbt{region}(date,1));
                thisyr=topXXwbt{region}(date,1);
                for daysbeforeindex=1:6
                    daysbefore=daysbeforeopts(daysbeforeindex);
                    
                    %Get actual v200 and z200 matrices for this day
                    thisvmatrix=squeeze(allvdata(thisyr-1981+1,:,:,thisdoy-daysbefore));
                    thiszmatrix=squeeze(allzdata(thisyr-1981+1,:,:,thisdoy-daysbefore));
                    %Get climo v200 and z200 matrices for this day
                    thisvmatrixclimo=squeeze(v200fitmatrix(:,:,thisdoy-daysbefore));
                    thiszmatrixclimo=squeeze(z200fitmatrix(:,:,thisdoy-daysbefore));
                    %Compute anomaly based on climo for this day
                    thisvmatrixanom(daysbeforeindex,:,:)=thisvmatrix-thisvmatrixclimo;
                    thiszmatrixanom(daysbeforeindex,:,:)=thiszmatrix-thiszmatrixclimo;
                    %Compile anomalies
                    allvmatrixanoms(daysbeforeindex,date,:,:)=squeeze(thisvmatrixanom(daysbeforeindex,:,:));
                    allzmatrixanoms(daysbeforeindex,date,:,:)=squeeze(thiszmatrixanom(daysbeforeindex,:,:));
                end
                
            end
            vmatrixanomsbyregion(region,:,:,:)=double(squeeze(nanmean(allvmatrixanoms,2))); %dims are region | daysbefore | i | j
            zmatrixanomsbyregion(region,:,:,:)=double(squeeze(nanmean(allzmatrixanoms,2)));
            vmatrixanomsbyregionincldates(region,:,:,:,:)=double(allvmatrixanoms); %dims are region | daysbefore | extreme ordinate | i | j
            zmatrixanomsbyregionincldates(region,:,:,:,:)=double(allzmatrixanoms);
            save('/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/Saved_Arrays/v200z500stuff',...
                'vmatrixanomsbyregion','zmatrixanomsbyregion','vmatrixanomsbyregionincldates','zmatrixanomsbyregionincldates','-append');
        end
    end
    
    if setupregression==1
        %x(t) is the v200 anoms corresponding to each of the 100 WBT extremes, averaged in each case over the region of interest
            %so, it's a 100x1 vector
        %y(t) is the v200 or z200 anoms corresponding to each of the 100 WBT extremes at a given gridpoint
        for dbi=1:6
            nceplonsadj=nceplons;temp=nceplons>180;nceplonsadj(temp)=nceplons(temp)-360;
            output=ncaregionsfromlatlon(nceplats,nceplonsadj);
            %Get data only for desired region
            outputregonly=output==region;
            %Compute regional average
            for date=1:100
                v200desregonly=NaN.*ones(144,73);
                colin=squeeze(vmatrixanomsbyregionincldates(region,dbi,date,:,:));
                for i=1:144
                    for j=1:73
                        if outputregonly(i,j)==1
                            v200desregonly(i,j)=colin(i,j);
                        end
                    end
                end
                %Compute average over desired region for each extreme -- this is x(t)
                v200desregavg(date)=nanmean(nanmean(v200desregonly));
            end
            v200desregavg=v200desregavg';

            %At each gridpoint, compute v200 and z200 anoms for each extreme -- these are y(t)
            for date=1:100
                for i=1:144
                    for j=1:73
                        v200anomseachgridpt(date,i,j)=vmatrixanomsbyregionincldates(region,dbi,date,i,j);
                        z200anomseachgridpt(date,i,j)=zmatrixanomsbyregionincldates(region,dbi,date,i,j);
                    end
                end
            end

            %Do regression by computing the correlation coeff of y & x, and
                %multiplying this by the ratio of their st devs
            stdevx=nanstd(v200desregavg);if size(v200desregavg,1)==1;v200desregavg=v200desregavg';end
            for i=1:144
                for j=1:73
                    stdevv200(i,j)=nanstd(squeeze(v200anomseachgridpt(:,i,j)));
                    v200corrcoeffyx(i,j)=corr(squeeze(v200anomseachgridpt(:,i,j)),v200desregavg);
                    stdevz200(i,j)=nanstd(squeeze(z200anomseachgridpt(:,i,j)));
                    z200corrcoeffyx(i,j)=corr(squeeze(z200anomseachgridpt(:,i,j)),v200desregavg);

                    v200regcoeffyx(dbi,i,j)=v200corrcoeffyx(i,j).*stdevv200(i,j)./stdevx;
                    z200regcoeffyx(dbi,i,j)=z200corrcoeffyx(i,j).*stdevz200(i,j)./stdevx;
                end
            end
        end
    end

    if verifplots==1
        figure(figc);clf;figc=figc+1;
        for dbi=1:6
            subplot(3,2,dbi);
            for region=5:5 %only plot one region at a time
                %Solve "too many polar vertices" problem
                nceplatstouse=nceplats;
                nceplatstouse(:,end)=-89.99;
                %nceplonstouse=flipud(nceplons);
                nceplonstouse=nceplons;
                
                temp=squeeze(vmatrixanomsbyregion(region,dbi,:,:)); %pure anomalies
                mystepunderlay=2;underlaycaxismin=-18;underlaycaxismax=18;
                %temp=squeeze(v200regcoeffyx(dbi,:,:)); %regressions
                %mystepunderlay=0.2;underlaycaxismin=-1.5;underlaycaxismax=1.5;
                data={nceplatstouse;nceplonstouse;temp};underlaydata=data;
                temp=squeeze(zmatrixanomsbyregion(region,dbi,:,:)); %pure anomalies
                mystep=20;caxismin=-100;caxismax=100;
                %temp=squeeze(z200regcoeffyx(dbi,:,:)); %regressions
                %mystep=2;caxismin=-10;caxismax=10;
                overlaydata={nceplatstouse;nceplons;temp};
                vararginnew={'underlayvariable';'generic scalar';'overlayvariable';'height';'contour';1;...
                'overlaynow';1;'datatooverlay';overlaydata;'mystep';mystep;'mystepunderlay';mystepunderlay;'plotCountries';1;...
                'caxismin';caxismin;'caxismax';caxismax;'underlaycaxismin';underlaycaxismin;'underlaycaxismax';underlaycaxismax;...
                'anomavg';'avg';'centeredon';180;'omitzerocontour';1;'plotasrasters';1;'nonewfig';1};
                regionformap='nhplustropics';datatype='NCEP';
                plotModelData(data,regionformap,vararginnew,datatype);curpart=1;highqualityfiguresetup;
                colormap(colormaps('t','more','not'));
                %title(sprintf('v200andz200anomsbyregion, for region %d\n',region));
                %curpart=2;figloc='/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/';
                %figname=strcat('verifplotv200z200region',num2str(region),'ndb',num2str(daysbeforeopts(dbi)));highqualityfiguresetup;
            end
            rownow=round2(dbi/2,1,'ceil');
            colnow=rem(dbi,2);if colnow==0;colnow=2;end
            %if rownow==1;rownowpos=0.323;elseif rownow==2;rownowpos=0.657;else rownowpos=0.99;end
            if rownow==1;rownowpos=0.29;elseif rownow==2;rownowpos=0.58;else rownowpos=0.87;end
            if colnow==1;colnowpos=0.01;else colnowpos=0.51;end
            %disp(rownowpos);disp(colnowpos);
            set(gca,'Position',[colnowpos 1-rownowpos 0.48 0.28]);
            text(0,0.95,figletterlabels{dbi},'units','normalized','fontname','arial','fontweight','bold','fontsize',16);
        end
        %Make one large colorbar, and then save
        cbar=colorbar('southoutside');
        set(get(cbar,'Ylabel'),'String','v200 Anomaly (m/s)','FontSize',14,'FontWeight','bold','FontName','Arial');
        set(cbar,'FontSize',14,'FontWeight','bold','FontName','Arial');
        cpos=get(cbar,'Position');cpos(1)=0.1;cpos(2)=0.08;cpos(3)=0.8;cpos(4)=0.03;
        set(cbar,'Position',cpos);
        curpart=2;figloc='/Users/craymon3/General_Academics/Research/WBTT_Overlap_Paper/';
        figname=strcat('verifplotv200z200region',num2str(region));highqualityfiguresetup;
    end
end
