
dosigniftest=1;redoactualtopXXanoms=1;
usinganomdata=0;altapproach=2;
numdates=100;yeariwf=1981;yeariwl=2015;monthiwf=5;monthiwl=10;
dailysstmatfileloc='/Volumes/MacFormatted4TBExternalDrive/NOAA_OISST_Daily_Data_Mat/';
dailysstncfileloc='/Volumes/MacFormatted4TBExternalDrive/NOAA_OISST_Daily_Data/';

%Runtime: about 1 min for 1 surrogate (composed of 35 random dates,
    %some of them repeated so total 'dates' evaluated via percentiles is 100 = numdates),
    %so for e.g. 100 of these surrogates total time is
    %100 surrogates x 1 variable x 7 regions x 2 ndb loops = 24 hours

if dosigniftest==1 %various approaches to ascertain the signif of OISST anomalies
    meananom={};
    for var=2:2
        for region=2:8
            for ndbloop=1:2
                if ndbloop==1;ndbcateg=1;numdaysbefore=0;elseif ndbloop==2;ndbcateg=3;numdaysbefore=5;end
                fprintf('Var is %d, region is %d, and ndbloop is %d\n',var,region,ndbloop);
                disp(clock);
                if var==1
                    reghotdaylist=topXXtbyregionsorted{region}(1:numdates,:);
                elseif var==2
                    reghotdaylist=topXXwbtbyregionsorted{region}(1:numdates,:);
                elseif var==3
                    reghotdaylist=topXXqbyregionsorted{region}(1:numdates,:);
                end
                if redoactualtopXXanoms==1
                    actualtopXXanoms=zeros(numdates,1440,720);numdaysdatafound=0;
                    for row=1:size(reghotdaylist,1)
                        if rem(row,25)==0;fprintf('row is %d\n',row);end
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

                        datafoundthisday=0;
                        %Load in data for this day -- ACTUAL OR ANOMALY, ACCORDING TO WHICH DATASET IS BEING USED
                        if usinganomdata==1
                            dailysstfile=ncread(strcat(dailyanomsstfileloc,'sst.day.anom.',num2str(thisyear),'.v2.nc'),'anom');
                            thisdayavg=dailysstfile(:,:,thisdoy);
                            thisdayanomgivenactualdata=thisdayavg; %data IS the anomaly
                            datafoundthisday=1;numdaysdatafound=numdaysdatafound+1;
                            fclose('all');
                        else
                            if thisyear>=1982 && thisyear<=2014 %don't have daily data for 1981 or 2015
                                if thismon<=9
                                    dailysstfile=load(strcat(dailysstmatfileloc,num2str(thisyear),...
                                        '/tos_',num2str(thisyear),'_0',num2str(thismon),'.mat'));
                                    dailysstfile=eval(['dailysstfile.tos_' num2str(thisyear) '_0' num2str(thismon)]);
                                else
                                    dailysstfile=load(strcat(dailysstmatfileloc,num2str(thisyear),...
                                        '/tos_',num2str(thisyear),'_',num2str(thismon),'.mat'));
                                    dailysstfile=eval(['dailysstfile.tos_' num2str(thisyear) '_' num2str(thismon)]);
                                end

                                thisdayavg=dailysstfile{3}(:,:,thisday);
                                fclose('all');

                                %Get this day's climatology
                                thisdayclimo=fullyearavgdailysst(:,:,thisdoy);
                                %Now, it's straightforward to calculate this day's anomaly
                                thisdayanomgivenactualdata=thisdayavg-thisdayclimo;
                                datafoundthisday=1;numdaysdatafound=numdaysdatafound+1;
                            end

                            actualtopXXanoms(row,:,:)=thisdayanomgivenactualdata;
                        end
                    end
                end
                
                %a. for hot days, at each gridpt, what % of days have a pos vs neg anomaly?
                        %--> this defines the pattern which will be tested against
                for row=1:1440
                    for col=1:720
                        temp=actualtopXXanoms(:,row,col)>=0;
                        posc=sum(temp);
                        actualfractionposanomaliessst{var,region,ndbcateg}(row,col)=posc;
                    end
                end
                
                reghotdaylistchron=sortrows(reghotdaylistinclndb,[1 2 3]);
                
                %Make the surrogates and prepare to do the actual significance testing
                surrogatetopXXanomssst=zeros(numdates,1440,720);
                if altapproach==2
                    %Alternative approach 2: simply do a categorical test, rather than a magnitude-based one
                    %Point is to test: are patterns on hot days *robust*, even if they're not especially *strong*?

                    %b. get 100 sets of 35 days each, and, for each set, compute the % of days with a pos vs neg anomaly
                    %Though we have 100 hot days, we know that SST varies slowly, and so to account for this
                        %autocorrelation we only pick from as many separate months as are represented
                        %in the 100 hot days (i.e. in reghotdaylistinclndb)
                    %Establish how many dates from each month we want to pick
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
                    for surrnum=1:100
                        if rem(surrnum,20)==0;fprintf('Computing surrogate %d for var %d, region %d\n',surrnum,var,region);end
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
                            if i>=2
                                if randdatessetup(i-1,2)==1 %shortcut if this date is same as previous
                                    surrogatetopXXanomssst(i,:,:)=thisdayanomgivenactualdata;
                                    dorestofloop=0;
                                else
                                    dorestofloop=1;
                                end
                            else
                                dorestofloop=1;
                            end
                            
                            if dorestofloop==1
                                thismon=randdatessetup(i,1);thisday=randdatessetup(i,3);thisyear=randdatessetup(i,4);
                                thisdoy=DatetoDOY(thismon,thisday,thisyear);

                                %Load in data for this day -- ACTUAL OR ANOMALY, ACCORDING TO WHICH DATASET IS BEING USED
                                if usinganomdata==1
                                    dailysstfile=ncread(strcat(dailysstncfileloc,'sst.day.anom.',num2str(thisyear),'.v2.nc'),'anom');
                                    thisdayavg=dailysstfile(:,:,thisdoy);
                                    thisdayanomgivenactualdata=thisdayavg; %data IS the anomaly
                                    datafoundthisday=1;numdaysdatafound=numdaysdatafound+1;
                                    fclose('all');
                                else
                                    if thisyear>=1982 && thisyear<=2014 %don't have daily data for 1981 or 2015
                                        if thismon<=9
                                            dailysstfile=load(strcat(dailysstmatfileloc,num2str(thisyear),...
                                                '/tos_',num2str(thisyear),'_0',num2str(thismon),'.mat'));
                                            dailysstfile=eval(['dailysstfile.tos_' num2str(thisyear) '_0' num2str(thismon)]);
                                        else
                                            dailysstfile=load(strcat(dailysstmatfileloc,num2str(thisyear),...
                                                '/tos_',num2str(thisyear),'_',num2str(thismon),'.mat'));
                                            dailysstfile=eval(['dailysstfile.tos_' num2str(thisyear) '_' num2str(thismon)]);
                                        end

                                        thisdayavg=dailysstfile{3}(:,:,thisday);
                                        fclose('all');

                                        %Get this day's climatology
                                        thisdayclimo=fullyearavgdailysst(:,:,thisdoy);
                                        %Now, it's straightforward to calculate this day's anomaly
                                        thisdayanomgivenactualdata=thisdayavg-thisdayclimo;
                                        datafoundthisday=1;numdaysdatafound=numdaysdatafound+1;
                                    end

                                    surrogatetopXXanomssst(i,:,:)=thisdayanomgivenactualdata;
                                end
                            end
                        end
                        %For this set of surrogate dates, compute the % of anomalies that are pos vs neg for each gridbox
                        for row=1:1440
                            for col=1:720
                                temp=surrogatetopXXanomssst(:,row,col)>=0;
                                posc=sum(temp);
                                surrogatefractionposanomaliessst{var,region,ndbcateg}(surrnum,row,col)=100*posc./size(surrogatetopXXanomssst,1);
                            end
                        end
                        clear surrogatetopXXanomssst;
                    end
                    %90th & 95th pct of these pos/neg percentages for each gridbox,
                        %for comparison to the actual number computed in part (a)
                    surrogate2point5pctposanomsst{var,region,ndbcateg}=squeeze(quantile(surrogatefractionposanomaliessst{var,region,ndbcateg},0.025));
                    surrogate5pctposanomsst{var,region,ndbcateg}=squeeze(quantile(surrogatefractionposanomaliessst{var,region,ndbcateg},0.05));
                    surrogate95pctposanomsst{var,region,ndbcateg}=squeeze(quantile(surrogatefractionposanomaliessst{var,region,ndbcateg},0.95));
                    surrogate97point5pctposanomsst{var,region,ndbcateg}=squeeze(quantile(surrogatefractionposanomaliessst{var,region,ndbcateg},0.975));
                    save(strcat(curArrayDir,'dailysstarrays'),'surrogate2point5pctposanomsst','surrogate5pctposanomsst',...
                        'surrogate95pctposanomsst','surrogate97point5pctposanomsst','actualfractionposanomaliessst',...
                        'surrogatefractionposanomaliessst','-append');
                end
            end
        end
    end
end