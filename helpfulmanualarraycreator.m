%Creates a list of the regions corresponding to each station, using the stations as listed in
%newstnNumList and its derivatives

createncaregionlist=1;

if createncaregionlist==1
    ncaregionnames={};ncaregionnum={};
    for city=1:size(newstnNumListnames,1)
        thiscitynumletters=size(newstnNumListnames{city},2);
        thiscitystate=newstnNumListnames{city}(thiscitynumletters-1:thiscitynumletters);
        if strcmp(thiscitystate,'ak')
            ncaregionnames{city}='Alaska';ncaregionnum{city}=1;
        %elseif strcmp(thiscitystate,'hi') %eliminated since doing continental US only
        %    ncaregionnames{city}='Hawaii';ncaregionnum{city}=2;
        elseif strcmp(thiscitystate,'wa') || strcmp(thiscitystate,'or') || strcmp(thiscitystate,'id')
            ncaregionnames{city}='Northwest';ncaregionnum{city}=2;
        elseif strcmp(thiscitystate,'ca') || strcmp(thiscitystate,'nv') || strcmp(thiscitystate,'ut') ||...
            strcmp(thiscitystate,'co') || strcmp(thiscitystate,'az') || strcmp(thiscitystate,'nm')    
            ncaregionnames{city}='Southwest';ncaregionnum{city}=3;
        elseif strcmp(thiscitystate,'mt') || strcmp(thiscitystate,'wy') || strcmp(thiscitystate,'nd') ||...
            strcmp(thiscitystate,'sd') || strcmp(thiscitystate,'ne')    
            ncaregionnames{city}='Great Plains North';ncaregionnum{city}=4;
        elseif strcmp(thiscitystate,'ks') || strcmp(thiscitystate,'ok') || strcmp(thiscitystate,'tx')
            ncaregionnames{city}='Great Plains South';ncaregionnum{city}=5;
        elseif strcmp(thiscitystate,'mn') || strcmp(thiscitystate,'ia') || strcmp(thiscitystate,'mo') ||...
            strcmp(thiscitystate,'wi') || strcmp(thiscitystate,'mi') || strcmp(thiscitystate,'il') ||...
            strcmp(thiscitystate,'in') || strcmp(thiscitystate,'oh')
            ncaregionnames{city}='Midwest';ncaregionnum{city}=6;
        elseif strcmp(thiscitystate,'ar') || strcmp(thiscitystate,'la') || strcmp(thiscitystate,'ky') ||...
            strcmp(thiscitystate,'tn') || strcmp(thiscitystate,'ms') || strcmp(thiscitystate,'al') ||...
            strcmp(thiscitystate,'ga') || strcmp(thiscitystate,'fl') || strcmp(thiscitystate,'sc') ||...
            strcmp(thiscitystate,'nc') || strcmp(thiscitystate,'va')
            ncaregionnames{city}='Southeast';ncaregionnum{city}=7;
        elseif strcmp(thiscitystate,'wv') || strcmp(thiscitystate,'md') || strcmp(thiscitystate,'de') ||...
            strcmp(thiscitystate,'pa') || strcmp(thiscitystate,'nj') || strcmp(thiscitystate,'ny') ||...
            strcmp(thiscitystate,'ct') || strcmp(thiscitystate,'ri') || strcmp(thiscitystate,'ma') ||...
            strcmp(thiscitystate,'vt') || strcmp(thiscitystate,'nh') || strcmp(thiscitystate,'me')
            ncaregionnames{city}='Northeast';ncaregionnum{city}=8;
        end
    end
    ncaregionnamemaster={'Alaska';'Northwest';'Southwest';'Great Plains North';...
        'Great Plains South';'Midwest';'Southeast';'Northeast'}; %with Hawaii already eliminated
    %save('/Volumes/ExternalDriveA/WBTT_Overlap_Saved_Arrays/basicstuff','ncaregionnamemaster','-append');
end

%Last updated for n=190 stations

%These next arrays are used in the tqanomsextremewbt loop of findmaxtwbt
stnordinatesswcoast=[43;44;45;93];
stnordinatesswinterior=[41;42;61;62;63;64;65;90;91;92;131;134;135;186;189];
%Source for next two: http://www.cpc.ncep.noaa.gov/products/outreach/Report-to-the-Nation-Monsoon_aug04.pdf, fig 9
stnordinatesaznm=[41;42;61];
stnordinatesothersw=[43;44;45;62;63;64;65;90;91;92;93;131;134;135;186;189];



