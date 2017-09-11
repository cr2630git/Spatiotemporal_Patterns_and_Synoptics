%Corrections to finaldatat, finaldatawbt, finaldatadewpt, and finaldataq
    %deemed necessary after various additional quality-control
%More could certainly be done, but this is the least that was necessary to fix everything that is
    %drawn upon to make plots, etc
    
%Current runtime: 30 sec
    
for variab=1:4
    if variab==1
        finaldata=finaldatat;
    elseif variab==2
        finaldata=finaldatawbt;
    elseif variab==3
        finaldata=finaldatadewpt;
    elseif variab==4
        finaldata=finaldataq;
    end
    finaldata{8,100}=finaldata{8,101}-0.5; %oddly misaligned data for summer 1988 in Scranton PA
    for year=23:35;finaldata{year,178}=NaN.*ones(4416,1);end %bad data for 2003-2015 in Brunswick ME
    %Timing is off by 30 hours for 1981 in Kotzebue AK
    x=30;year=1;finaldata{year,1}(1:4416-x)=finaldata{year,1}(x+1:4416);finaldata{year,1}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 20 hours for 1981 in Bettles AK
    x=20;year=1;finaldata{year,2}(1:4416-x)=finaldata{year,2}(x+1:4416);finaldata{year,2}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 21 hours for 1981 in Nome AK
    x=21;year=1;finaldata{year,3}(1:4416-x)=finaldata{year,3}(x+1:4416);finaldata{year,3}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 24 hours for 1981 in Bethel AK
    x=24;year=1;finaldata{year,4}(1:4416-x)=finaldata{year,4}(x+1:4416);finaldata{year,4}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 27 hours for 1981 in McGrath AK
    x=27;year=1;finaldata{year,5}(1:4416-x)=finaldata{year,5}(x+1:4416);finaldata{year,5}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 135 hours for 1981 in Talkeetna AK
    x=135;year=1;finaldata{year,6}(1:4416-x)=finaldata{year,6}(x+1:4416);finaldata{year,6}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 28 hours for 1981 in Gulkana AK
    x=28;year=1;finaldata{year,8}(1:4416-x)=finaldata{year,8}(x+1:4416);finaldata{year,8}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 39 hours for 1981 in Cold Bay AK
    x=39;year=1;finaldata{year,10}(1:4416-x)=finaldata{year,10}(x+1:4416);finaldata{year,10}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 129 hours for 1981 in Homer AK
    x=129;year=1;finaldata{year,12}(1:4416-x)=finaldata{year,12}(x+1:4416);finaldata{year,12}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 38 hours for 1981 in Kodiak AK
    x=38;year=1;finaldata{year,13}(1:4416-x)=finaldata{year,13}(x+1:4416);finaldata{year,13}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 25 hours for 1981 in Yakutat AK
    x=25;year=1;finaldata{year,14}(1:4416-x)=finaldata{year,14}(x+1:4416);finaldata{year,14}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 30 hours for 1981 in Juneau AK
    x=30;year=1;finaldata{year,15}(1:4416-x)=finaldata{year,15}(x+1:4416);finaldata{year,15}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 42 hours for 1981 in West Palm Beach FL
    x=42;year=1;finaldata{year,17}(1:4416-x)=finaldata{year,17}(x+1:4416);finaldata{year,17}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 32 hours for 1981 in Augusta GA
    x=32;year=1;finaldata{year,25}(1:4416-x)=finaldata{year,25}(x+1:4416);finaldata{year,25}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 20 hours for 1981 in Victoria TX
    x=20;year=1;finaldata{year,38}(1:4416-x)=finaldata{year,38}(x+1:4416);finaldata{year,38}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 22 hours for 1981 in Waco TX
    x=22;year=1;finaldata{year,39}(1:4416-x)=finaldata{year,39}(x+1:4416);finaldata{year,39}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 16 hours for 1981 in San Diego CA
    x=16;year=1;finaldata{year,43}(1:4416-x)=finaldata{year,43}(x+1:4416);finaldata{year,43}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 24 hours for 1981 in Long Beach CA
    x=24;year=1;finaldata{year,45}(1:4416-x)=finaldata{year,45}(x+1:4416);finaldata{year,45}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 19 hours for 1981 in Greenville SC
    x=19;year=1;finaldata{year,51}(1:4416-x)=finaldata{year,51}(x+1:4416);finaldata{year,51}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 22 hours for 1981 in Huntsville AL
    x=22;year=1;finaldata{year,55}(1:4416-x)=finaldata{year,55}(x+1:4416);finaldata{year,55}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 1 hour for 1981 in Baltimore-Washington AP MD
    x=1;year=1;finaldata{year,69}(1:4416-x)=finaldata{year,69}(x+1:4416);finaldata{year,69}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 10 hours for 1981 in Charleston WV
    x=10;year=1;finaldata{year,73}(1:4416-x)=finaldata{year,73}(x+1:4416);finaldata{year,73}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 17 hours for 1981 in Port Columbus OH
    x=17;year=1;finaldata{year,78}(1:4416-x)=finaldata{year,78}(x+1:4416);finaldata{year,78}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 26 hours for 1981 in Concordia KS
    x=26;year=1;finaldata{year,89}(1:4416-x)=finaldata{year,89}(x+1:4416);finaldata{year,89}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 261 hours for 1981 in Alamosa CO
    x=261;year=1;finaldata{year,90}(1:4416-x)=finaldata{year,90}(x+1:4416);finaldata{year,90}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 8 hours for 1981 in Newark NJ
    x=8;year=1;finaldata{year,94}(1:4416-x)=finaldata{year,94}(x+1:4416);finaldata{year,94}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 47 hours for 1981 in Islip NY
    x=47;year=1;finaldata{year,96}(1:4416-x)=finaldata{year,96}(x+1:4416);finaldata{year,96}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 66 hours for 1981 in Scranton PA
    x=66;year=1;finaldata{year,100}(1:4416-x)=finaldata{year,100}(x+1:4416);finaldata{year,100}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 29 hours for 1981 in Pittsburgh PA
    x=29;year=1;finaldata{year,103}(1:4416-x)=finaldata{year,103}(x+1:4416);finaldata{year,103}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 34 hours for 1981 in Akron OH
    x=34;year=1;finaldata{year,104}(1:4416-x)=finaldata{year,104}(x+1:4416);finaldata{year,104}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 25 hours for 1981 in Toledo OH
    x=25;year=1;finaldata{year,114}(1:4416-x)=finaldata{year,114}(x+1:4416);finaldata{year,114}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 21 hours for 1981 in Rockford IL
    x=21;year=1;finaldata{year,117}(1:4416-x)=finaldata{year,117}(x+1:4416);finaldata{year,117}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 490 hours for 1981 in Waterloo IA
    x=490;year=1;finaldata{year,120}(1:4416-x)=finaldata{year,120}(x+1:4416);finaldata{year,120}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 25 hours for 1981 in Grand Island NE
    x=25;year=1;finaldata{year,123}(1:4416-x)=finaldata{year,123}(x+1:4416);finaldata{year,123}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 4 hours for 1981 in Valentine NE
    x=4;year=1;finaldata{year,129}(1:4416-x)=finaldata{year,129}(x+1:4416);finaldata{year,129}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 1 hour for 1981 in Casper WY
    x=1;year=1;finaldata{year,130}(1:4416-x)=finaldata{year,130}(x+1:4416);finaldata{year,130}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 19 hours for 1981 in Grand Rapids MI
    x=19;year=1;finaldata{year,140}(1:4416-x)=finaldata{year,140}(x+1:4416);finaldata{year,140}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 30 hours for 1981 in Muskegon MI
    x=30;year=1;finaldata{year,141}(1:4416-x)=finaldata{year,141}(x+1:4416);finaldata{year,141}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 478 hours for 1981 in Houghton Lake MI
    x=478;year=1;finaldata{year,143}(1:4416-x)=finaldata{year,143}(x+1:4416);finaldata{year,143}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 11 hours for 1981 in Sioux Falls SD
    x=11;year=1;finaldata{year,149}(1:4416-x)=finaldata{year,149}(x+1:4416);finaldata{year,149}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 389 hours for 1981 in Aberdeen SD
    x=389;year=1;finaldata{year,152}(1:4416-x)=finaldata{year,152}(x+1:4416);finaldata{year,152}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 28 hours for 1981 in Rapid City SD
    x=28;year=1;finaldata{year,153}(1:4416-x)=finaldata{year,153}(x+1:4416);finaldata{year,153}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 5 hours for 1981 in Pendleton OR
    x=5;year=1;finaldata{year,156}(1:4416-x)=finaldata{year,156}(x+1:4416);finaldata{year,156}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 33 hours for 1981 in International Falls MN
    x=33;year=1;finaldata{year,162}(1:4416-x)=finaldata{year,162}(x+1:4416);finaldata{year,162}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 28 hours for 1981 in Williston ND
    x=28;year=1;finaldata{year,165}(1:4416-x)=finaldata{year,165}(x+1:4416);finaldata{year,165}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 25 hours for 1981 in Helena MT
    x=25;year=1;finaldata{year,167}(1:4416-x)=finaldata{year,167}(x+1:4416);finaldata{year,167}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 24 hours for 1981 in Missoula MT
    x=24;year=1;finaldata{year,168}(1:4416-x)=finaldata{year,168}(x+1:4416);finaldata{year,168}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 21 hours for 1981 in Kalispell MT
    x=21;year=1;finaldata{year,170}(1:4416-x)=finaldata{year,170}(x+1:4416);finaldata{year,170}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 27 hours for 1981 in Yakima WA
    x=27;year=1;finaldata{year,171}(1:4416-x)=finaldata{year,171}(x+1:4416);finaldata{year,171}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 8 hours for 1981 in Lewiston ID
    x=8;year=1;finaldata{year,172}(1:4416-x)=finaldata{year,172}(x+1:4416);finaldata{year,172}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 21 hours for 1981 in Astoria OR
    x=21;year=1;finaldata{year,174}(1:4416-x)=finaldata{year,174}(x+1:4416);finaldata{year,174}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 17 hours for 1981 in Olympia WA
    x=17;year=1;finaldata{year,175}(1:4416-x)=finaldata{year,175}(x+1:4416);finaldata{year,175}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 19 hours for 1981 in Quillayute WA
    x=19;year=1;finaldata{year,177}(1:4416-x)=finaldata{year,177}(x+1:4416);finaldata{year,177}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 16 hours for 1981 in Abilene TX
    x=16;year=1;finaldata{year,184}(1:4416-x)=finaldata{year,184}(x+1:4416);finaldata{year,184}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 21 hours for 1981 in San Angelo TX
    x=21;year=1;finaldata{year,185}(1:4416-x)=finaldata{year,185}(x+1:4416);finaldata{year,185}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 13 hours for 1981 in Oklahoma City OK
    x=13;year=1;finaldata{year,187}(1:4416-x)=finaldata{year,187}(x+1:4416);finaldata{year,187}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 22 hours for 1981 in Fort Smith AR
    x=22;year=1;finaldata{year,188}(1:4416-x)=finaldata{year,188}(x+1:4416);finaldata{year,188}(4416-(x-1):4416)=NaN.*ones(x,1);
    %Timing is off by 25 hours for 1981 in Goodland KS
    x=25;year=1;finaldata{year,190}(1:4416-x)=finaldata{year,190}(x+1:4416);finaldata{year,190}(4416-(x-1):4416)=NaN.*ones(x,1);
    if variab==1
        finaldatat=finaldata;
    elseif variab==2
        finaldatawbt=finaldata;
    elseif variab==3
        finaldatadewpt=finaldata;
    elseif variab==4
        finaldataq=finaldata;
    end
end