%Breaks files into <=25-MB chunks so that they can be uploaded to Github
thisdir='/Users/craymon3/Library/Mobile Documents/com~apple~CloudDocs/General_Academics/Research/WBTT_Overlap_Paper/Git_Repository_Files/';

readinarrays=0; %10 sec
dostndata=0; %30 sec
dostnmetadata=0; %5 sec
dotopxx=0; %2 min
dotopxxsupport=0; %1 min
dowaveactivity=0;

essentialarraysfile=load(strcat(arraydirextdrive,'essentialarrays'));
extraarraysfile=load(strcat(arraydirextdrive,'extraarrays'));

%Once all variables are loaded into the workspace, save them to mat files in forms that are easily digestible
%for my website and Github page
%Runtime: 30 sec


%First, read in stn data and metadata arrays if not already in workspace
if readinarrays==1
    stndatafile=load('/Volumes/ExternalDriveC/Basics_190USStns/mainstndata.mat');
    finaldatatorig=stndatafile.finaldatat;
    finaldatadewptorig=stndatafile.finaldatadewpt;
    finaldatawbtorig=stndatafile.finaldatawbt;
    finaldataqorig=stndatafile.finaldataq;
    stnmetadatafile=load('/Volumes/ExternalDriveC/Basics_190USStns/basicstuff.mat');
end
wheretosave='~/iclouddrive/General_Academics/Research/Polished_Datasets/Hourly_Station_Dataset/';


%1. Create station data files
if dostndata==1
    year=1981;
    for loop=1:17
        finaldatat={};finaldatadewpt={};finaldatawbt={};finaldataq={};
        for stn=16:190
            finaldatat{stn-15}=[finaldatatorig{loop*2-1,stn};finaldatatorig{loop*2,stn}];
            finaldatadewpt{stn-15}=[finaldatadewptorig{loop*2-1,stn};finaldatadewptorig{loop*2,stn}];
            finaldatawbt{stn-15}=[finaldatawbtorig{loop*2-1,stn};finaldatawbtorig{loop*2,stn}];
            finaldataq{stn-15}=[finaldataqorig{loop*2-1,stn};finaldataqorig{loop*2,stn}];
        end
        save(strcat(wheretosave,'stndata',num2str(year),'-',num2str(year+1),'.mat'),'finaldatat','finaldatadewpt','finaldatawbt','finaldataq');
        year=year+2;
        disp(loop);
    end
    year=2015;
    finaldatat={};finaldatadewpt={};finaldatawbt={};finaldataq={};
    for stn=16:190
        finaldatat{stn-15}=[finaldatatorig{35,stn}];
        finaldatadewpt{stn-15}=[finaldatadewptorig{35,stn}];
        finaldatawbt{stn-15}=[finaldatawbtorig{35,stn}];
        finaldataq{stn-15}=[finaldataqorig{35,stn}];
    end
    save(strcat(wheretosave,'stndata',num2str(year),'.mat'),'finaldatat','finaldatadewpt','finaldatawbt','finaldataq');
end


%2. Create station metadata file
if dostnmetadata==1
    temp=load('~/iclouddrive/General_Academics/Research/WBTT_Overlap_Paper/Git_Repository_Files/stnmetadata.mat');
    ncaregionnamemaster=temp.ncaregionnamemaster;
    newstnNumList=temp.newstnNumList;newstnNumList=newstnNumList(16:190);
    newstnNumListlats=temp.newstnNumListlats;newstnNumListlats=newstnNumListlats(16:190);
    newstnNumListlons=temp.newstnNumListlons;newstnNumListlons=newstnNumListlons(16:190);
    newstnNumListnames=temp.newstnNumListnames;newstnNumListnames=newstnNumListnames(16:190);
    newstntzlist=temp.newstntzlist;
    save(strcat(wheretosave,'stnmetadata.mat'),'ncaregionnamemaster','newstnNumList','newstnNumListlats',...
        'newstnNumListlons','newstnNumListnames','newstntzlist');
end


%3. Top-XX arrays
if dotopxx==1
    narrfile=load(strcat(arraydirextdrive,'narrarrays'));
    topXXtbyregionsorted=extraarraysfile.topXXtbyregionsorted;
    topXXwbtbyregionsorted=extraarraysfile.topXXwbtbyregionsorted;
    topXXqbyregionsorted=extraarraysfile.topXXqbyregionsorted;
    topXXfile=load(strcat(arraydirextdrive,'topXXarrays'));
    topXXtbystn=topXXfile.topXXtbystn;
    topXXwbtbystn=topXXfile.topXXwbtbystn;
    topXXqbystn=topXXfile.topXXqbystn;
    top1000tbystn=topXXfile.top1000tbystn;
    top1000wbtbystn=topXXfile.top1000wbtbystn;
    top1000qbystn=topXXfile.top1000qbystn;
    topXXtbynarr=narrfile.topXXtbynarr;
    topXXwbtbynarr=narrfile.topXXwbtbynarr;
    topXXqbynarr=narrfile.topXXqbynarr;
    save(strcat(thisdir,'extremesarraysstn'),'topXXtbyregionsorted','topXXwbtbyregionsorted','topXXqbyregionsorted',...
        'topXXtbystn','topXXwbtbystn','topXXqbystn','top1000tbystn','top1000wbtbystn','top1000qbystn');
    save(strcat(thisdir,'extremesarraytnarr'),'topXXtbynarr');
    save(strcat(thisdir,'extremesarraywbtnarr'),'topXXwbtbynarr');
    save(strcat(thisdir,'extremesarrayqnarr'),'topXXqbynarr');
end

%4. Top-XX overlap & supporting arrays
if dotopxxsupport==1
    correspt=extraarraysfile.correspt;
    correspq=extraarraysfile.correspq;
    corresptnext900=extraarraysfile.corresptnext900;
    correspqnext900=extraarraysfile.correspqnext900;
    pctoverlapwbtt=essentialarraysfile.pctoverlapwbtt;
    pctoverlapwbttnarr=essentialarraysfile.pctoverlapwbttnarr;
    pctoverlapwbtq=essentialarraysfile.pctoverlapwbtq;
    pctoverlapwbtqnarr=essentialarraysfile.pctoverlapwbtqnarr;
    wbttscorereg=essentialarraysfile.wbttscorereg;
    wbtqscorereg=essentialarraysfile.wbtqscorereg;
    save(strcat(thisdir,'extremessupportingarrays'),'correspt','correspq','corresptnext900','correspqnext900');
    save(strcat(thisdir,'overlapscorearrays'),'pctoverlapwbtt','pctoverlapwbttnarr','pctoverlapwbtq',...
        'pctoverlapwbtqnarr','wbttscorereg','wbtqscorereg','perct');
end

%5. Wave-activity data
if dowaveactivity==1
    v200z200file=load(strcat(arraydirextdrive,'v200z500stuff'));
    vmatrixanomsbyregion=v200z200file.vmatrixanomsbyregion;
    zmatrixanomsbyregion=v200z200file.zmatrixanomsbyregion;
    save(strcat(thisdir,'waveactivityarrays'),'vmatrixanomsbyregion','zmatrixanomsbyregion');
end