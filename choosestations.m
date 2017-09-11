%As a preliminary filter, sort out which hourly US stations may be of high-enough quality to use
%source of list: ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.txt

%Notes:
%As written this script throws out (does not attempt to patch together)
%stations with discontinuous P.O.R.'s, however this could be modified
%Current runtime: 10 sec

%Choose runtime options
readindata=1;
purgestns=1;


%Read in station list
if readindata==1
    cd /Users/colin/Documents/General_Academics/Research/WBTT_Overlap_Paper;
    stationlist=csvimport('USStationList.csv'); %make sure nLines is set to the proper value in csvimport script
end

%Purge stations with fewer than 30 years of data, defining a newstationlist
%stationlist(i,13) is the end year for that station, stationlist(i,10) is its start year
%currently, requires that the full 1981-2010 period be available
if purgestns==1
    newstationlist={};newi=1;
    for i=1:size(stationlist,1)
        if strcmp(class(cell2mat(stationlist(i,13))),'char')
            if str2num(cell2mat(stationlist(i,13)))-str2num(cell2mat(stationlist(i,10)))>=30 &&...
                    str2num(cell2mat(stationlist(i,13)))>=2010 && str2num(cell2mat(stationlist(i,10)))<=1980
                %disp(stationlist(i,13));disp(stationlist(i,10));disp('end of this station');
                for j=1:size(stationlist,2);newstationlist{newi,j}=stationlist{i,j};end
                newi=newi+1;
            end
        elseif strcmp(class(cell2mat(stationlist(i,13))),'double')
            if cell2mat(stationlist(i,13))-cell2mat(stationlist(i,10))>=30 &&...
                   cell2mat(stationlist(i,13))>=2010 && cell2mat(stationlist(i,10))<=1980 
                %disp(stationlist(i,13));disp(stationlist(i,10));disp('end of this station');
                for j=1:size(stationlist,2);newstationlist{newi,j}=stationlist{i,j};end
                newi=newi+1;
            end
        end
    end
end


%Save station IDs within newstationlist to ASCII file so that it can be used in a bash script
%that automates the otherwise-tedious ftp process
stnidsonly=0;
for i=1:size(newstationlist,1)
    stnidsonly(i)=newstationlist{i,1}; %just need the station IDs here, none of the other info
end
fileID=fopen('newstationlist.txt','w');
fprintf(fileID,'%0.0f\n',stnidsonly);
fclose(fileID);



