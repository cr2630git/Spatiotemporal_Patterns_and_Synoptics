%Simply loads variables in order to save space in exploratorydataanalysis
    %and make it look more streamlined
%Current runtime: several min (though it would be very rare to want to read
%in everything in this file all at once)

runremote=0;

if runremote==0
    arraydirextdrive='/Volumes/ExternalDriveA/WBTT_Overlap_Saved_Arrays/';
else
    arraydirextdrive='/cr/cr2630/WBTT_Overlap_Paper/Saved_Arrays/';
end
masterfile=load(strcat(arraydirextdrive,'temparrayholder220aug31'));
newstnNumList=masterfile.newstnNumList;
newstnNumListlats=masterfile.newstnNumListlats;
newstnNumListlons=masterfile.newstnNumListlons;
newstnNumListnames=masterfile.newstnNumListnames;
finaldatat=masterfile.finaldatat;
finaldatadewpt=masterfile.finaldatadewpt;
finaldatawbt=masterfile.finaldatawbt;
finaldataq=masterfile.finaldataq;
gosavethisstn=masterfile.gosavethisstn;
goodstnyearcombo=masterfile.goodstnyearcombo;
helpfulmanualarraycreator;
basicstuff=load(strcat(arraydirextdrive,'basicstuff'));
lons=basicstuff.lons;lats=basicstuff.lats;
narrlsmask=basicstuff.narrlsmask;
cutoffmatrix=basicstuff.cutoffmatrix;
narrlatmatrix=basicstuff.narrlatmatrix;
narrlonmatrix=basicstuff.narrlonmatrix;
tzlist=basicstuff.tzlist;
ncaregionnamemaster=basicstuff.ncaregionnamemaster;
monthlengthsdays=basicstuff.monthlengthsdays;

otherfile=load(strcat(arraydirextdrive,'stndatatandwbt'));
stndatat=otherfile.stndatat;
stndatawbt=otherfile.stndatawbt;
stndataq=otherfile.stndataq;
stndatadewpt=otherfile.stndatadewpt;
topXXfile=load(strcat(arraydirextdrive,'topXXarrays'));
topXXtbystn=topXXfile.topXXtbystn;
topXXwbtbystn=topXXfile.topXXwbtbystn;
topXXqbystn=topXXfile.topXXqbystn;
top1000tbystn=topXXfile.top1000tbystn;
top1000wbtbystn=topXXfile.top1000wbtbystn;
top1000qbystn=topXXfile.top1000qbystn;
mediantopxxwbtbystn=topXXfile.mediantopxxwbtbystn;
mediantopxxwbtbynarr=topXXfile.mediantopxxwbtbynarr;
essentialarraysfile=load(strcat(arraydirextdrive,'essentialarrays'));
wbttscore=essentialarraysfile.wbttscore;
pctoverlapwbtt=essentialarraysfile.pctoverlapwbtt;
wbttscorenarr=essentialarraysfile.wbttscorenarr;
pctoverlapwbttnarr=essentialarraysfile.pctoverlapwbttnarr;
wbtqscore=essentialarraysfile.wbtqscore;
pctoverlapwbtq=essentialarraysfile.pctoverlapwbtq;
wbtqscorenarr=essentialarraysfile.wbtqscorenarr;
pctoverlapwbtqnarr=essentialarraysfile.pctoverlapwbtqnarr;
tqscore=essentialarraysfile.tqscore;
pctoverlaptq=essentialarraysfile.pctoverlaptq;
wbttscorereg=essentialarraysfile.wbttscorereg;
wbttscoreregnarr=essentialarraysfile.wbttscoreregnarr;
pctoverlapwbttreg=essentialarraysfile.pctoverlapwbttreg;
pctoverlapwbttregnarr=essentialarraysfile.pctoverlapwbttregnarr;
wbtqscorereg=essentialarraysfile.wbtqscorereg;
wbtqscoreregnarr=essentialarraysfile.wbtqscoreregnarr;
pctoverlapwbtqreg=essentialarraysfile.pctoverlapwbtqreg;
pctoverlapwbtqregnarr=essentialarraysfile.pctoverlapwbtqregnarr;
tqscorereg=essentialarraysfile.tqscorereg;
pctoverlaptqreg=essentialarraysfile.pctoverlaptqreg;
allvaluesthishourofdayandmonth=essentialarraysfile.allvaluesthishourofdayandmonth;
avgthishourofdayandmonth=essentialarraysfile.avgthishourofdayandmonth;
stdevthishourofdayandmonth=essentialarraysfile.stdevthishourofdayandmonth;
alldailymaxesthismonth=essentialarraysfile.alldailymaxesthismonth;
avgdailymaxthismonth=essentialarraysfile.avgdailymaxthismonth;
allvaluesthishourofdayanddoy=essentialarraysfile.allvaluesthishourofdayanddoy;
alldailymaxesthisdoy=essentialarraysfile.alldailymaxesthisdoy;
avgthishourofdayanddoy=essentialarraysfile.avgthishourofdayanddoy;
newfitavg=essentialarraysfile.newfitavg;
newfitstdev=essentialarraysfile.newfitstdev;
%narrallwbtdailymaxesyear1981=essentialarraysfile.narrallwbtdailymaxesyear1981;
extraarraysfile=load(strcat(arraydirextdrive,'extraarrays'));
numericgoodstns=extraarraysfile.numericgoodstns;
dailymaxt=extraarraysfile.dailymaxt;
dailymaxtstruc=extraarraysfile.dailymaxtstruc;
dailymaxwbt=extraarraysfile.dailymaxwbt;
dailymaxwbtstruc=extraarraysfile.dailymaxwbtstruc;
dailymaxq=extraarraysfile.dailymaxq;
dailymaxqstruc=extraarraysfile.dailymaxqstruc;
%thisdayswbtpct=extraarraysfile.thisdayswbtpct;
allregionsyearc=extraarraysfile.allregionsyearc;
allregionsyearcbystn=extraarraysfile.allregionsyearcbystn;
allregionsyearcbystnnoreg=extraarraysfile.allregionsyearcbystnnoreg;
allregionsyearcnarr=extraarraysfile.allregionsyearcnarr;
topXXtbyregionsorted=extraarraysfile.topXXtbyregionsorted;
topXXwbtbyregionsorted=extraarraysfile.topXXwbtbyregionsorted;
topXXqbyregionsorted=extraarraysfile.topXXqbyregionsorted;
stnlistbyregion=extraarraysfile.stnlistbyregion;
stnceachregion=extraarraysfile.stnceachregion;
stnnumseachregion=extraarraysfile.stnnumseachregion;
stnordinateseachregion=extraarraysfile.stnordinateseachregion;
badmonthspctbystn=extraarraysfile.badmonthspctbystn;
badmonthspctbyregion=extraarraysfile.badmonthspctbyregion;
seasonalmeantbystn=extraarraysfile.seasonalmeantbystn;
seasonalmeanwbtbystn=extraarraysfile.seasonalmeanwbtbystn;
seasonalmeanqbystn=extraarraysfile.seasonalmeanqbystn;
seasonalmeantbyregion=extraarraysfile.seasonalmeantbyregion;
seasonalmeanwbtbyregion=extraarraysfile.seasonalmeanwbtbyregion;
seasonalmeanqbyregion=extraarraysfile.seasonalmeanqbyregion;
avg3highesttbyregion=extraarraysfile.avg3highesttbyregion;
avg3highestwbtbyregion=extraarraysfile.avg3highestwbtbyregion;
avg3highestqbyregion=extraarraysfile.avg3highestqbyregion;
avg3highesttbystn=extraarraysfile.avg3highesttbystn;
avg3highestwbtbystn=extraarraysfile.avg3highestwbtbystn;
avg3highestqbystn=extraarraysfile.avg3highestqbystn;
correspt=extraarraysfile.correspt;
correspq=extraarraysfile.correspq;
corresptnext900=extraarraysfile.corresptnext900;
correspqnext900=extraarraysfile.correspqnext900;
perct=extraarraysfile.perct;
tavgoverstns=extraarraysfile.tavgoverstns;
wbtavgoverstns=extraarraysfile.wbtavgoverstns;
qavgoverstns=extraarraysfile.qavgoverstns;
topXXwbtbyregionfilter=extraarraysfile.topXXwbtbyregionfilter;
topXXwbtbyregionfilterqrt=extraarraysfile.topXXwbtbyregionfilterqrt;
regstnc=extraarraysfile.regstnc;
stnqspikes=extraarraysfile.stnqspikes;
stntspikes=extraarraysfile.stntspikes;
stnqspikespctcontribhighwbt=extraarraysfile.stnqspikespctcontribhighwbt;
stntspikespctcontribhighwbt=extraarraysfile.stntspikespctcontribhighwbt;
tanomtraceregavg=extraarraysfile.tanomtraceregavg;
wbtanomtraceregavg=extraarraysfile.wbtanomtraceregavg;
qanomtraceregavg=extraarraysfile.qanomtraceregavg;
stdevdatabymon=extraarraysfile.stdevdatabymon;
compmapsfile=load(strcat(arraydirextdrive,'compositemapsarrays'));
hotdaysbywindowt=compmapsfile.hotdaysbywindowt;
hotdaysbywindowwbt=compmapsfile.hotdaysbywindowwbt;
hotdaysbywindowq=compmapsfile.hotdaysbywindowq;
ghclimo300=compmapsfile.ghclimo300;ghclimo300months=compmapsfile.ghclimo300months;
ttopXXavg850=compmapsfile.ttopXXavg850;ttopXXavg850months=compmapsfile.ttopXXavg850months;
shumtopXXavg850=compmapsfile.shumtopXXavg850;shumtopXXavg850months=compmapsfile.shumtopXXavg850months;
utopXXavg850=compmapsfile.utopXXavg850;utopXXavg850months=compmapsfile.utopXXavg850months;
vtopXXavg850=compmapsfile.vtopXXavg850;vtopXXavg850months=compmapsfile.vtopXXavg850months;
%uwndtopXXavg300=compmapsfile.uwndtopXXavg300;uwndtopXXavg300months=compmapsfile.uwndtopXXavg300months;
%vwndtopXXavg300=compmapsfile.vwndtopXXavg300;vwndtopXXavg300months=compmapsfile.vwndtopXXavg300months;
ghtopXXavg500=compmapsfile.ghtopXXavg500;ghtopXXavg500months=compmapsfile.ghtopXXavg500months;
ghtopXXavg300=compmapsfile.ghtopXXavg300;ghtopXXavg300months=compmapsfile.ghtopXXavg300months;
tsum850=compmapsfile.tsum850;shumsum850=compmapsfile.shumsum850;
usum850=compmapsfile.usum850;vsum850=compmapsfile.vsum850;
usum300=compmapsfile.usum300;vsum300=compmapsfile.vsum300;
ghsum500=compmapsfile.ghsum500;ghsum300=compmapsfile.ghsum300;
ttopXXavg850all=compmapsfile.ttopXXavg850all;shumtopXXavg850all=compmapsfile.shumtopXXavg850all;
utopXXavg850all=compmapsfile.utopXXavg850all;vtopXXavg850all=compmapsfile.vtopXXavg850all;
utopXXavg300all=compmapsfile.utopXXavg300all;vtopXXavg300all=compmapsfile.vtopXXavg300all;
ghtopXXavg500all=compmapsfile.ghtopXXavg500all;ghtopXXavg300all=compmapsfile.ghtopXXavg300all;
ttopXXavganom850all=compmapsfile.ttopXXavganom850all;shumtopXXavganom850all=compmapsfile.shumtopXXavganom850all;
utopXXavganom850all=compmapsfile.utopXXavganom850all;vtopXXavganom850all=compmapsfile.vtopXXavganom850all;
utopXXavganom300all=compmapsfile.utopXXavganom300all;vtopXXavganom300all=compmapsfile.vtopXXavganom300all;
ghtopXXavganom500all=compmapsfile.ghtopXXavganom500all;ghtopXXavganom300all=compmapsfile.ghtopXXavganom300all;
ttopXXavgclimo850all=compmapsfile.ttopXXavgclimo850all;shumtopXXavgclimo850all=compmapsfile.shumtopXXavgclimo850all;
utopXXavgclimo850all=compmapsfile.utopXXavgclimo850all;vtopXXavgclimo850all=compmapsfile.vtopXXavgclimo850all;
utopXXavgclimo300all=compmapsfile.utopXXavgclimo300all;vtopXXavgclimo300all=compmapsfile.vtopXXavgclimo300all;
ghtopXXavgclimo500all=compmapsfile.ghtopXXavgclimo500all;ghtopXXavgclimo300all=compmapsfile.ghtopXXavgclimo300all;
tavganom850bytqstananom=compmapsfile.tavganom850bytqstananom;shumavganom850bytqstananom=compmapsfile.shumavganom850bytqstananom;
uavganom850bytqstananom=compmapsfile.uavganom850bytqstananom;vavganom850bytqstananom=compmapsfile.vavganom850bytqstananom;
uavganom300bytqstananom=compmapsfile.uavganom300bytqstananom;vavganom300bytqstananom=compmapsfile.vavganom300bytqstananom;
ghavganom500bytqstananom=compmapsfile.ghavganom500bytqstananom;ghavganom300bytqstananom=compmapsfile.ghavganom300bytqstananom;
wvconvdatatopXXdaysavg=compmapsfile.wvconvdatatopXXdaysavg;
wvconvdatatopXXdaysanommean=compmapsfile.wvconvdatatopXXdaysanommean;
wvconvdatatopXXdaysstananommean=compmapsfile.wvconvdatatopXXdaysstananommean;
wvconvdatatopXXdaysanommedian=compmapsfile.wvconvdatatopXXdaysanommedian;
wvconvdatatopXXdaysstananommedian=compmapsfile.wvconvdatatopXXdaysstananommedian;
wvconvclimo=compmapsfile.wvconvclimo;wvconvstdev=compmapsfile.wvconvstdev;
mconvclimo=compmapsfile.mconvclimo;mconvall=compmapsfile.mconvall;
sstcorrelfile=load(strcat(arraydirextdrive,'correlsstarrays'));
ersstlats=sstcorrelfile.ersstlats;
ersstlons=sstcorrelfile.ersstlons;
monthlysst=sstcorrelfile.monthlysst;
monthbymonthroiavgsst=sstcorrelfile.monthbymonthroiavgsst;
roiclimosstmonth=sstcorrelfile.roiclimosstmonth;
monthbymonthroianomsst=sstcorrelfile.monthbymonthroianomsst;
stntopxxtbyyear=sstcorrelfile.stntopxxtbyyear;
correlsstt=sstcorrelfile.correlsstt;
stntopxxwbtbyyear=sstcorrelfile.stntopxxwbtbyyear;
correlsstwbt=sstcorrelfile.correlsstwbt;
%stntopxxqbyyear=sstcorrelfile.stntopxxqbyyear;
%correlsstq=sstcorrelfile.correlsstq;
monthbymonthgridptsst=sstcorrelfile.monthbymonthgridptsst;
gridptclimosstmonth=sstcorrelfile.gridptclimosstmonth;
monthbymonthgridptanomsst=sstcorrelfile.monthbymonthgridptanomsst;
correlsstteverygridptstns=sstcorrelfile.correlsstteverygridptstns;
correlsstwbteverygridptstns=sstcorrelfile.correlsstwbteverygridptstns;
%correlsstqeverygridptstns=sstcorrelfile.correlsstqeverygridptstns;
correlsstteverygridptregions=sstcorrelfile.correlsstteverygridptregions;
correlsstwbteverygridptregions=sstcorrelfile.correlsstwbteverygridptregions;
%correlsstqeverygridptregions=sstcorrelfile.correlsstqeverygridptregions;
%gridptsignifarrayersst=sstcorrelfile.gridptsignifarrayersst;
%avgofanomsersst=sstcorrelfile.avgofanomsersst;
dailysstfile=load(strcat(arraydirextdrive,'dailysstarrays'));
oisstlats=dailysstfile.oisstlats;
oisstlons=dailysstfile.oisstlons;
fullyearavgdailysst=dailysstfile.fullyearavgdailysst;
avgofanomsoisst=dailysstfile.avgofanomsoisst;
oisststananombydoy=dailysstfile.oisststananombydoy;
surrogate2point5pctposanomsst=dailysstfile.surrogate2point5pctposanomsst;
surrogate5pctposanomsst=dailysstfile.surrogate5pctposanomsst;
surrogate95pctposanomsst=dailysstfile.surrogate95pctposanomsst;
surrogate97point5pctposanomsst=dailysstfile.surrogate97point5pctposanomsst;
actualfractionposanomaliessst=dailysstfile.actualfractionposanomaliessst;
surrogatefractionposanomaliessst=dailysstfile.surrogatefractionposanomaliessst;
%gridptsignifarrayoisst=dailysstfile.gridptsignifarrayoisst;
griddedavgsfile=load(strcat(arraydirextdrive,'griddedavgsarrays'));
fullhgtdatancep=griddedavgsfile.fullhgtdatancep;
avgofanomsactualdata=griddedavgsfile.avgofanomsactualdata;
avgofstananomsactualdata=griddedavgsfile.avgofstananomsactualdata;
stdevofanomsactualdata=griddedavgsfile.stdevofanomsactualdata;
stdevofstananomsactualdata=griddedavgsfile.stdevofstananomsactualdata;
allanomsactualdata=griddedavgsfile.allanomsactualdata;
gridptsignifarray=griddedavgsfile.gridptsignifarray;
avgofanomselninosummers=griddedavgsfile.avgofanomselninosummers;
avgofanomslaninasummers=griddedavgsfile.avgofanomslaninasummers;
narrfile=load(strcat(arraydirextdrive,'narrarrays'));
topXXdatatnarr=narrfile.topXXdatatnarr;
topXXdatawbtnarr=narrfile.topXXdatawbtnarr;
topXXdataqnarr=narrfile.topXXdataqnarr;
topXXtbynarr=narrfile.topXXtbynarr;
topXXwbtbynarr=narrfile.topXXwbtbynarr;
topXXqbynarr=narrfile.topXXqbynarr;
topXXtdatesbyregionnarr=narrfile.topXXtdatesbyregionnarr;
topXXwbtdatesbyregionnarr=narrfile.topXXwbtdatesbyregionnarr;
topXXqdatesbyregionnarr=narrfile.topXXqdatesbyregionnarr;
regionnarrgridptc=narrfile.regionnarrgridptc;
ncepfile=load(strcat(arraydirextdrive,'nceparrays'));
counthitlistwbt=ncepfile.counthitlistwbt;
numinstanceswbt=ncepfile.numinstanceswbt;
pcthitlistwbt=ncepfile.pcthitlistwbt;
pcthitlistallhighswbt=ncepfile.pcthitlistallhighswbt;
pcthitlistallhighssmwbt=ncepfile.pcthitlistallhighssmwbt;
counthitlistt=ncepfile.counthitlistt;
numinstancest=ncepfile.numinstancest;
pcthitlistt=ncepfile.pcthitlistt;
pcthitlistallhighst=ncepfile.pcthitlistallhighst;
pcthitlistallhighssmt=ncepfile.pcthitlistallhighssmt;
surrogate2point5pctposanom=ncepfile.surrogate2point5pctposanom;
surrogate5pctposanom=ncepfile.surrogate5pctposanom;
surrogate95pctposanom=ncepfile.surrogate95pctposanom;
surrogate97point5pctposanom=ncepfile.surrogate97point5pctposanom;
actualfractionposanomalies=ncepfile.actualfractionposanomalies;
stipplematrix90=ncepfile.stipplematrix90;
stipplematrix95=ncepfile.stipplematrix95;
finalarraysfile=load(strcat(arraydirextdrive,'finalarrays'));
shumavg=finalarraysfile.shumavg;
uwndavg=finalarraysfile.uwndavg;
vwndavg=finalarraysfile.vwndavg;
othercatchallarraysfile=load(strcat(arraydirextdrive,'othercatchallarrays'));
avgmontht=othercatchallarraysfile.avgmontht;
avgdayt=othercatchallarraysfile.avgdayt;
avgdoyt=othercatchallarraysfile.avgdoyt;
stdevdoyt=othercatchallarraysfile.stdevdoyt;
avgdoytnarr=othercatchallarraysfile.avgdoytnarr;
stdevdoytnarr=othercatchallarraysfile.stdevdoytnarr;
p25doyt=othercatchallarraysfile.p25doyt;
p25montht=othercatchallarraysfile.p25montht;
p75doyt=othercatchallarraysfile.p75doyt;
p75montht=othercatchallarraysfile.p75montht;
avgmonthwbt=othercatchallarraysfile.avgmonthwbt;
avgdaywbt=othercatchallarraysfile.avgdaywbt;
p25doywbt=othercatchallarraysfile.p25doywbt;
p25monthwbt=othercatchallarraysfile.p25monthwbt;
p75doywbt=othercatchallarraysfile.p75doywbt;
p75monthwbt=othercatchallarraysfile.p75monthwbt;
avgdoywbt=othercatchallarraysfile.avgdoywbt;
stdevdoywbt=othercatchallarraysfile.stdevdoywbt;
avgdoywbtnarr=othercatchallarraysfile.avgdoywbtnarr;
stdevdoywbtnarr=othercatchallarraysfile.stdevdoywbtnarr;
avgmonthwbtnarr=othercatchallarraysfile.avgmonthwbtnarr;
avgdaywbtnarr=othercatchallarraysfile.avgdaywbtnarr;
avgdoyq=othercatchallarraysfile.avgdoyq;
stdevdoyq=othercatchallarraysfile.stdevdoyq;
avgmonthq=othercatchallarraysfile.avgmonthq;
avgdayq=othercatchallarraysfile.avgdayq;
p25doyq=othercatchallarraysfile.p25doyq;
p25monthq=othercatchallarraysfile.p25monthq;
p75doyq=othercatchallarraysfile.p75doyq;
p75monthq=othercatchallarraysfile.p75monthq;
for year=1981:2015
    thisfile=load(strcat(arraydirextdrive,'year',num2str(year),'tqadv',num2str(sfcor850)));
end
v200z200file=load(strcat(arraydirextdrive,'v200z500stuff'));
v200fitmatrix=v200z200file.v200fitmatrix;
z200fitmatrix=v200z200file.z200fitmatrix;
allvdata=v200z200file.allvdata;
allzdata=v200z200file.allzdata;
vmatrixanomsbyregion=v200z200file.vmatrixanomsbyregion;
zmatrixanomsbyregion=v200z200file.zmatrixanomsbyregion;
fluxarrays=load(strcat(arraydirextdrive,'fluxarrays'));
uswrfavg=fluxarrays.uswrfavg;uswrfanom=fluxarrays.uswrfanom;
ulwrfavg=fluxarrays.ulwrfavg;ulwrfanom=fluxarrays.ulwrfanom;
dswrfavg=fluxarrays.dswrfavg;dswrfanom=fluxarrays.dswrfanom;
dlwrfavg=fluxarrays.dlwrfavg;dlwrfanom=fluxarrays.dlwrfanom;
gfluxavg=fluxarrays.gfluxavg;gfluxanom=fluxarrays.gfluxanom;
shtflavg=fluxarrays.shtflavg;shtflanom=fluxarrays.shtflanom;
lhtflavg=fluxarrays.lhtflavg;lhtflanom=fluxarrays.lhtflanom;
uswrfclimo=fluxarrays.uswrfclimo;improveduswrfclimo=fluxarrays.improveduswrfclimo;
ulwrfclimo=fluxarrays.ulwrfclimo;improvedulwrfclimo=fluxarrays.improvedulwrfclimo;
dswrfclimo=fluxarrays.dswrfclimo;improveddswrfclimo=fluxarrays.improveddswrfclimo;
dlwrfclimo=fluxarrays.dlwrfclimo;improveddlwrfclimo=fluxarrays.improveddlwrfclimo;
gfluxclimo=fluxarrays.gfluxclimo;improvedgfluxclimo=fluxarrays.improvedgfluxclimo;
shtflclimo=fluxarrays.shtflclimo;improvedshtflclimo=fluxarrays.improvedshtflclimo;
lhtflclimo=fluxarrays.lhtflclimo;improvedlhtflclimo=fluxarrays.improvedlhtflclimo;

for reg=1:8
    for var=1:1
        if var==1;w='t';elseif var==2;w='wbt';elseif var==3;w='q';end
        eval(['reg' num2str(reg) 'hotdaylist' w '=narrfile.reg' num2str(reg) 'hotdaylist' w ';']);
    end
end


runremote=0;
if runremote==0
    arraydirextdrive='/Volumes/ExternalDriveA/Exploratory_Plots_Saved_Arrays/';
elseif runremote==1
    arraydirextdrive='/cr/cr2630/Exploratory_Plots/';
    addpath('/cr/cr2630/GeneralPurposeScripts/');
end

temp=load(strcat(arraydirextdrive,'basicstuff.mat'));
stnlocsh=temp.stnlocsh;
hourly90prctiles=temp.hourly90prctiles;
regTvecsavedforlater=temp.regTvecsavedforlater;
narrlats=temp.narrlats;
narrlons=temp.narrlons;
narrsz=temp.narrsz;
ncalist=temp.ncalist;