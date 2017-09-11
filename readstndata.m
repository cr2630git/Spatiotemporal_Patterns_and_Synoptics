%Read in data from NCDC-station text files (one file per station per year)
%Currently gets T & dewpt, could easily get pres & winds as well
%Station IDs are 6-digit numbers, the WMO ID with a zero tacked on

%%%8/19/16: EXCEPT FOR UNZIPPING, THIS FILE MAY BE COMPLETELY SUPERSEDED BY ncdcHourlyTxtToMat2%%%

%To copy this to remote server:
%scp readstndata.m cr2630@sonny.ldeo.columbia.edu:/cr/cr2630/NCDC_hourly_station_data_active/readstndata.m
%To run this on remote server:
%just log in, go to the directory housing everything, & use the command
%matlab -nodisplay -nodesktop -r "run readstndata.m"
%To delete all files whose title contains a specific string: ls *foo* | xargs rm

%Runtime options
runlocation='local'; %'local', 'remotesonny', 'remotenotsonny'
resetvectors=0;
unzipandelimstnswithmissingdata=1; %on remote computer, about 0.5 sec per stn-year on the first runthrough, 1 sec thereafter
                                   %on local computer, about 7 sec per stn-year
converttoneweststnlist=0;   %whether to convert validstnlist to neweststnlist (default is yes; 1 sec)
readinjustlatlon=0;         %for mapmaking purposes, whether to read in just lat & lon for each station in neweststnlist
readindatafromtextfiles=0;  %on remote computer, about 4 min per station (36 hours in total)
    readfromneweststnlist=0;%read from 560-stn neweststnlist -- if don't know which of these stns are good enough to use in the end
    readfromnewstnnumlist=1;%read from ~200-stn newstnNumList -- if preliminary work using this script & others have already whittled
        %down the number of stations, and simply additional testing/years is desired
bringinsavedarrays=0;       %2 sec
findhottestdays=0;          %15 sec
dorankingqc=0;              %1 sec
calcoverlapscore=0;
mapstns=0;                  %1 min
mapresults=0;
    regiontouse='usaminushawaii-tight'; %default is 'usaminushawaii-tight'

%Other key settings
startyear=1981;stopyear=2015;   %default is 1981-2015
stnstart=1;stnstop=10000;           %default is 1-10000 (i.e. all)
numdaystolookfor=30; %number for calculating T/WBT overlap scores



%Start things up
disp('Hello and welcome to my beautiful script');
if strcmp(runlocation,'local')==1
    scriptlocation='/Users/colin/Documents/General_Academics/Research/WBTT_Overlap_Paper/';
    textfilelocation='/Users/colin/Documents/General_Academics/Research/WBTT_Overlap_Paper/';
    datalocation='/Volumes/MacFormatted4TBExternalDrive/NCDC_hourly_station_data_active/';
elseif strcmp(runlocation,'remotesonny')==1
    scriptlocation='/cr/cr2630/';
    textfilelocation='/cr/cr2630/';
    datalocation='/cr/cr2630/NCDC_hourly_station_data_active/';
    addpath('/cr/cr2630/Scripts/GeneralPurposeScripts');
elseif strcmp(runlocation,'remotenotsonny')==1
    scriptlocation='/net/sonny/cr/cr2630/';
    textfilelocation='/net/sonny/cr/cr2630/';
    datalocation='/net/sonny/cr/cr2630/NCDC_hourly_station_data_active/';
    addpath('/net/sonny/cr/cr2630/Scripts/GeneralPurposeScripts');
end

%Load list of stations
stnlist=load(strcat(textfilelocation,'newstationlist.txt'));
if stnstop==10000;stnstop=size(stnlist,1);end
oldstnlist=stnlist;

if resetvectors==1
    maxobst=0;minobst=0;maxobswbt=0;minobswbt=0;maxobsdewpt=0;minobsdewpt=0;
    stnlat=0;stnlon=0;stnelev=0;
end

%To be valid, stations must have data not just from 1981-2010, but 
%from every year within that period as well
%Uncompress zip files -- this enables us to go through 
%and eliminate stations that do not meet the aforementioned criterion
if unzipandelimstnswithmissingdata==1
    disp(clock);
    validstnlist=zeros(stnstop-stnstart+1,1);
    %stnlisttouse=neweststnlist;
    stnlisttouse=723400;
    if stnstop>size(stnlisttouse,1);stnstop=size(stnlisttouse,1);end
    for stn=stnstart:stnstop
        curstnnum=num2str(stnlisttouse(stn));
        fprintf('Current station number is %d\n',stnlisttouse(stn));
        year=startyear;stnisvalid=1; %an optimistic starting value
        while year<=stopyear && stnisvalid==1
            curyear=num2str(year);%disp(curyear);
            %Uncompress & then delete zip file if necessary
            fullzipname=strcat(datalocation,'*',num2str(curstnnum),'*',num2str(curyear),'.gz');
            if ~isempty(dir(fullzipname))
                disp('uncompressing and deleting zip file');
                gunzip(fullzipname);
                delete(fullzipname);
            end
            %Open text file with this station's data (if any exists for this year)
            realfilename=strcat(datalocation,'*',curstnnum,'*-',curyear);
            a=dir(realfilename);%disp(a);
            %If no data for this station/year combination was found, station should not be considered at all
            %disp('line 79');disp(stn);disp(year);disp(a);
            if isempty(a)==1 
                stnisvalid=0;
            else
                if ~strfind(a.name,curstnnum)
                    stnisvalid=0;
                end
            end
            year=year+1;
        end
        %This validstnlist stuff isn't necessary if the valid stations have already been determined (i.e. if newstnNumList already exists)
        validstnlist(stn-stnstart+1)=stnisvalid; %1 if valid, 0 if not
        fprintf('stnisvalid value for this station is %d\n',stnisvalid);
        if rem(stn,10)==0
            save(strcat(scriptlocation,'readstndatavalidlist2'),'validstnlist');
        end
    end
    disp(clock);
end

%Convert validstnlist into a list of stations that meet this more-stringent criterion,
%and save that as another text file
%This (building neweststnlist from validstnlist) can be done every time as it's almost instantaneous
%To bring back from remote to local, have to scp through Terminal using this command:
%scp cr2630@sonny.ldeo.columbia.edu:/cr/cr2630/readstndatavalidlist.mat readstndatavalidlist.mat
if converttoneweststnlist==1
    validstnlist=load(strcat(scriptlocation,'readstndatavalidlist'));validstnlist=validstnlist.validstnlist;
    newi=1;neweststnlist=0;
    for i=1:size(validstnlist,1)
        if validstnlist(i)==1
            neweststnlist(newi,1)=stnlist(i);
            newi=newi+1;
        end
    end
    neweststnlist=unique(sort(neweststnlist,'ascend'));
    %Remove a handful of pesky stations
    neweststnlist(43:size(neweststnlist,1)-2)=neweststnlist(45:size(neweststnlist,1)); %removes 722020 and 722025
    stnlist=neweststnlist;
    fileID=fopen(strcat(textfilelocation,'neweststationlist.txt'),'w');
    fprintf(fileID,'%0.0f\n',neweststnlist);
    fclose(fileID);
end

%A short precursor to the below loop, where just lat & lon are read in, for the purposes of 
%expediently making a map of where they are
if readinjustlatlon==1
    for stn=stnstart:min(size(neweststnlist,1),stnstop)
        curstnnum=num2str(neweststnlist(stn));
        fprintf('Current station number is %d\n',neweststnlist(stn));
        year=startyear;curyear=num2str(year);
        realfilename=strcat(datalocation,'*',curstnnum,'*-',curyear);
        a=dir(realfilename);%disp(a);
        fileID=fopen(strcat(datalocation,a.name));
        keepgoing=1;
        while keepgoing==1
            curline=fgets(fileID,50);
            stnlat(stn,1)=str2double(curline(30:34))/1000;
            stnlon(stn,1)=str2double(curline(36:41))/-1000; %b/c all in Western Hemisphere
            keepgoing=0;
            fprintf('Lat and lon for this station are %0.2f, %0.2f\n',stnlat(stn,1),stnlon(stn,1));
        end
        fclose(fileID);
    end
end

%The main body of work -- getting data from the text files and putting it in nicely organized arrays
if readindatafromtextfiles==1
    disp(clock);
    obstarrayv1=0;obsdewptarrayv1=0;obswbtarrayv1=0;
    obstarrayv2=0;obsdewptarrayv2=0;obswbtarrayv2=0;
    if readfromneweststnlist==1
        stnlisttouse=neweststnlist;
    elseif readfromnewstnnumlist==1
        stnlisttouse=newstnNumList;
    end
    
    for stn=stnstart:min(size(stnlisttouse,1),stnstop)
        curstnnum=num2str(stnlisttouse(stn));
        fprintf('Current station number is %d\n',stnlisttouse(stn));

        for year=startyear:stopyear
            curyear=num2str(year);disp(curyear);
            relyear=year-startyear+1;

            %Set up time-related vectors
            months={'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12'};
            monthlengths={'31';'28';'31';'30';'31';'30';'31';'31';'30';'31';'30';'31'};
            hours={'00';'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';...
                '13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23'};

            %Open text file with this station's data
            realfilename=strcat(datalocation,'*',curstnnum,'*-',curyear);
            a=dir(realfilename);%disp(a);
            fileID=fopen(strcat(datalocation,a.name));

            %Read in data from file
            %disp('Reading in data from file for this station/year combo');
            %n=3; %number of lines of file to read in
            k=1; %line counter
            hourwithinday=1; %not hour per se, but rather tracks the number of obs in a day
            %doy=1; %day of year
            oldcurday=1;curday=1;
            while ~feof(fileID)
                curline=fgets(fileID);

                %On first line only, get fixed metadata about this stn
                if k==1
                    stnlat(stn,1)=str2double(curline(30:34))/1000;
                    stnlon(stn,1)=str2double(curline(36:41))/-1000; %b/c all in Western Hemisphere
                    if strcmp(curline(47),'+')
                        stnelev(stn,1)=str2double(curline(48:51)); %in meters
                    elseif strcmp(curline(47),'-')
                        stnelev(stn,1)=str2double(curline(48:51));stnelev(stn,relyear,k,:)=-stnelev(stn,1);
                    end
                end

                stnnum(stn,relyear,k,1:6)=str2double(curline(5:10));
                obsyear(stn,relyear,k,1:4)=str2double(curline(16:19));
                obsmonth(stn,relyear,k,1:2)=str2double(curline(20:21));
                obsday(stn,relyear,k,1:2)=str2double(curline(22:23));
                obstime(stn,relyear,k,1:4)=str2double(curline(24:27)); %hour & min of obs time
                if obsday==1;fprintf('Current month and day are %d, %d\n',obsmonth,obsday);end

                if strcmp(curline(88),'+')
                    obsttodayonly(hourwithinday)=str2double(curline(89:92));
                elseif strcmp(curline(88),'-')
                    obsttodayonly(hourwithinday)=str2double(curline(89:92));
                    obsttodayonly(hourwithinday)=-obsttodayonly(hourwithinday);
                end
                obstqccode(stn,relyear,k,1:1)=str2double(curline(93));
                    %1 and 5 are best; 3, 6 and 7 indicate problems; 9 indicates missing data
                if strcmp(curline(94),'+')
                    obsdewpttodayonly(hourwithinday)=str2double(curline(95:98));
                elseif strcmp(curline(94),'-')
                    obsdewpttodayonly(hourwithinday)=str2double(curline(95:98));
                    obsdewpttodayonly(hourwithinday)=-obsdewpttodayonly(hourwithinday);
                end
                obsdewptqccode(stn,relyear,k,1:1)=str2double(curline(99));
                

                %Convert this hour's T & dewpt readings to WBT
                thist=obsttodayonly(hourwithinday)/10;
                thisdewpt=obsdewpttodayonly(hourwithinday)/10;
                thiswbt=calcwbtfromTanddewpt(thist,thisdewpt,0);
                thiswbt(thiswbt>50)=-99; %make missing if value is unphysical
                obswbttodayonly(hourwithinday)=thiswbt;
                %disp('T, dewpt T, and RH at this hour are:');disp(thist);disp(thisdewpt);disp(thisrh);
                %disp('WBT at this hour is:');disp(obswbttodayonly(hourwithinday));

                oldcurday=curday;
                curtime=str2double(curline(24:27));
                curday=str2double(curline(22:23));
                curmonth=str2double(curline(20:21));
                curyear=obsyear(stn,relyear,k,1);
                doy=DatetoDOY(curmonth,curday,curyear);
                if k>=2;lastreadingsyear=obsyear(stn,relyear,k-1,1);end

                %if k~=1 && k~=size(obsday,3) && obsday(stn,relyear,k,1)~=obsday(stn,relyear,k+1,1)
                %Divide by 10 to get from tenths of a degree to degrees
                %Save data to be able to rank days two ways: by max hourly T/WBT, and by avg daily T/WBT
                if k>=1 && curday~=oldcurday %i.e. if this line is the last hourly reading of a day
                    %disp('line 135');disp(doy);disp(k);
                    if size(max(obsttodayonly(abs(obsttodayonly)<1000)),2)>0
                        todaysdailyavg=mean(obsttodayonly(abs(obsttodayonly)<1000));
                        todaysmax=max(obsttodayonly(abs(obsttodayonly)<1000));
                        obstarrayv1(stn,relyear,doy)=todaysdailyavg/10;
                        obstarrayv2(stn,relyear,doy)=todaysmax/10;
                    end
                    if size(max(obsdewpttodayonly(abs(obsdewpttodayonly)<1000)),2)>0
                        todaysdailyavg=mean(obsdewpttodayonly(abs(obsdewpttodayonly)<1000));
                        todaysmax=max(obsdewpttodayonly(abs(obsdewpttodayonly)<1000));
                        obsdewptarrayv1(stn,relyear,doy)=todaysdailyavg/10;
                        obsdewptarrayv2(stn,relyear,doy)=todaysmax/10;
                    end
                    if size(max(obswbttodayonly(obswbttodayonly<1000)),2)>0
                        todaysdailyavg=mean(obswbttodayonly(obswbttodayonly<1000));
                        todaysmax=max(obswbttodayonly(obswbttodayonly<1000));
                        obswbtarrayv1(stn,relyear,doy)=todaysdailyavg;
                        obswbtarrayv2(stn,relyear,doy)=todaysmax;
                    end
                    obsttodayonly=0;
                    obsdewpttodayonly=0;
                    obswbttodayonly=0;
                    hourwithinday=1;
                    %doy=doy+1;
                elseif curtime>=2200 && curday==31 && curmonth==12 %pretty much the last hourly reading of a year
                    obsttodayonly=0;
                    obsdewpttodayonly=0;
                    obswbttodayonly=0;
                    hourwithinday=1;
                    %doy=1;
                else %day goes on
                    hourwithinday=hourwithinday+1;
                end

                k=k+1;
                %fwrite(1,curline);
                %disp(obst(k,:));disp(obsdewpt(k,:));
            end

            %Close text file
            fclose('all');
        end
        fprintf('Here are the max T and max WBT for this station (lat: %0.2f, lon: %0.2f)\n',stnlat(stn),stnlon(stn));
        disp(max(max(squeeze(obstarrayv2(stn,:,:)))));disp(max(max(squeeze(obswbtarrayv2(stn,:,:)))));
        %Save to a file that can then be transferred back to the local computer
        %Do this multiple times in case something goes wrong partway through
        if rem(stn,10)==0
            fprintf('Saving arrays; current station count is %d\n',stn);
            save('readstndataarrays2','obstarrayv1','obsdewptarrayv1','obswbtarrayv1',...
            'obstarrayv2','obsdewptarrayv2','obswbtarrayv2','stnlat','stnlon','stnelev');
        end
    end
    disp(clock);
end

%Open and examine this file of arrays
if bringinsavedarrays==1
    if strcmp(runlocation,'local')==1 %otherwise this doesn't make sense
        cd /Users/colin/Documents/General_Academics/Research/WBTT_Overlap_Paper;
        %Have to scp through Terminal, using this command
        %scp cr2630@sonny.ldeo.columbia.edu:/cr/cr2630/readstndataarrays.mat readstndataarrays.mat;
        readstndataarrays=load('readstndataarrays.mat');
        obstarrayv1=readstndataarrays.obstarrayv1;
        obsdewptarrayv1=readstndataarrays.obsdewptarrayv1;
        obswbtarrayv1=readstndataarrays.obswbtarrayv1;
        obstarrayv2=readstndataarrays.obstarrayv2;
        obsdewptarrayv2=readstndataarrays.obsdewptarrayv2;
        obswbtarrayv2=readstndataarrays.obswbtarrayv2;
        stnlat=readstndataarrays.stnlat;
        stnlon=readstndataarrays.stnlon;
        stnelev=readstndataarrays.stnelev;
    end
end

%Find hottest days by T and by WBT for each station (across all years of available data)
%v2 does things by the max hour which is probably most suitable for this purpose
%To display hottest days for station 1: disp(squeeze(allstnsmaxlistoft(:,1,:))) 
%Arrays are made with twice as much data as will ultimately be needed so that QC can be run
%Dimensions of allstnsmaxlistoft are top-XX day|station|data (value, date of occurrence)
if findhottestdays==1
    allstnsmaxlistoft=-1000*ones(numdaystolookfor*2,size(obstarrayv2,1),3);
    allstnsmaxlistofwbt=-1000*ones(numdaystolookfor*2,size(obstarrayv2,1),3);
    for stn=1:size(obstarrayv2,1)
        for year=1:size(obstarrayv2,2)
            for day=1:size(obstarrayv2,3)
                curdatat=obstarrayv2(stn,year,day);
                if curdatat~=0
                    if curdatat>allstnsmaxlistoft(numdaystolookfor*2,stn,1) %this day belongs on the max list of T
                        allstnsmaxlistoft(numdaystolookfor*2,stn,1)=curdatat;
                        allstnsmaxlistoft(numdaystolookfor*2,stn,2)=year+startyear-1;
                        allstnsmaxlistoft(numdaystolookfor*2,stn,3)=day;
                        temp=squeeze(allstnsmaxlistoft(:,stn,:));
                        allstnsmaxlistoft(:,stn,:)=sortrows(temp,-1); %sort so largest values are first
                    end
                end
                curdatawbt=obswbtarrayv2(stn,year,day);
                if curdatawbt~=0
                    if curdatawbt>allstnsmaxlistofwbt(numdaystolookfor*2,stn,1) %this day belongs on the max list of WBT
                        allstnsmaxlistofwbt(numdaystolookfor*2,stn,1)=curdatawbt;
                        allstnsmaxlistofwbt(numdaystolookfor*2,stn,2)=year+startyear-1;
                        allstnsmaxlistofwbt(numdaystolookfor*2,stn,3)=day;
                        temp=squeeze(allstnsmaxlistofwbt(:,stn,:));
                        allstnsmaxlistofwbt(:,stn,:)=sortrows(temp,-1); %sort so largest values are first
                    end
                end
            end
        end
    end
end

%Quality-control the resultant lists and cut them down to their final size
if dorankingqc==1
    allstnsmaxlistoftqcprelim=zeros(1,1,3);allstnsmaxlistofwbtqcprelim=zeros(1,1,3);
    allstnsmaxlistoftqc=zeros(1,1,3);allstnsmaxlistofwbtqc=zeros(1,1,3);
    for stn=1:size(obstarrayv2,1)
        cleanrowtc=1;cleanrowwbtc=1;
        ttemp=squeeze(allstnsmaxlistoft(:,stn,:));
        wbttemp=squeeze(allstnsmaxlistofwbt(:,stn,:));
        for i=1:numdaystolookfor*2-1
            if abs(ttemp(i+1,1)-ttemp(i,1))>3 %unusually large drop
            else
                allstnsmaxlistoftqcprelim(cleanrowtc,stn,:)=allstnsmaxlistoft(i,stn,:);
                cleanrowtc=cleanrowtc+1;
            end
            if abs(wbttemp(i+1,1)-wbttemp(i,1))>3 %unusually large drop
            else
                allstnsmaxlistofwbtqcprelim(cleanrowwbtc,stn,:)=allstnsmaxlistofwbt(i,stn,:);
                cleanrowwbtc=cleanrowwbtc+1;
            end
        end
        allstnsmaxlistoftqc(1:numdaystolookfor,stn,:)=allstnsmaxlistoftqcprelim(1:numdaystolookfor,stn,:);
        allstnsmaxlistofwbtqc(1:numdaystolookfor,stn,:)=allstnsmaxlistofwbtqcprelim(1:numdaystolookfor,stn,:);
    end
end
%Still have to manually check for outliers and bad data though


%Locations of 561 stations in neweststnlist
if mapstns==1
    plotBlankMap(figc,regiontouse);figc=figc+1;
    for stn=1:size(stnlat,1)
        thisstnlat=stnlat(stn);thisstnlon=stnlon(stn);
        h=geoshow(thisstnlat,thisstnlon,'DisplayType','Point','Marker','s',...
                        'MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',5);
        hold on;
    end
    title('Locations of Stations with 1981-2010 Data','FontName','Arial','FontSize',18,'FontWeight','bold');
end

%To be sure everything above is closed...
fclose('all');

    