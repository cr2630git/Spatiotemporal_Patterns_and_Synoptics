%Just a space-saving loop returning the right version of arrays given an input of 
%   This is a helper script for dothemapping part of plotnarrcompositemaps10daywindows in exploratorydataanalysis
if plotmonth==1 && strcmp(anomavg,'avg')
    for varc=1:varnum
        eval([char(vrs(varc)) char(levels(varc)) 'arr=' char(vrs(varc)) 'topXXavg' char(levels(varc)) 'months;']);
    end
elseif plotmonth==1 && strcmp(anomavg,'anom')
    for varc=1:varnum
        eval([char(vrs(varc)) char(levels(varc)) 'arr=' char(vrs(varc)) 'topXXanom' char(levels(varc)) 'months;']);
    end
elseif plotmonth==0 && strcmp(anomavg,'avg')
    for varc=1:varnum
        eval([char(vrs(varc)) char(levels(varc)) 'arr=' char(vrs(varc)) 'topXXavg' char(levels(varc)) ';']);
    end
elseif plotmonth==0 && strcmp(anomavg,'anom')
    for varc=1:varnum
        eval([char(vrs(varc)) char(levels(varc)) 'arr=' char(vrs(varc)) 'topXXanom' char(levels(varc)) ';']);
    end
elseif plotmonth==2 && tvsq==10
    if strcmp(anomavg,'avg')
        for varc=1:varnum
            eval([char(vrs(varc)) char(levels(varc)) 'arr=' char(vrs(varc)) 'topXXavg' char(levels(varc)) 'all;']);
        end
    elseif strcmp(anomavg,'anom')
        for varc=1:varnum
            eval([char(vrs(varc)) char(levels(varc)) 'arr=' char(vrs(varc)) 'topXXavganom' char(levels(varc)) 'all;']);
        end
        disp('this is where I should be');
    end
    for varc=1:varnum;eval([char(vrs(varc)) char(levels(varc)) 'climoarr=' char(vrs(varc)) 'topXXavgclimo' char(levels(varc)) 'all;']);end
elseif plotmonth==2 %will be plotting tdom and qdom
    if strcmp(anomavg,'anom')
        for varc=1:varnum
            eval([char(vrs(varc)) char(levels(varc)) 'arr=' char(vrs(varc)) 'avganom' char(levels(varc)) 'bytqstananom;']);
        end
    else
        disp('Invalid combination of parameters');return;
    end
end

if tvsq==10
    for varc=1:varnum
        if varc~=5 && varc~=6
        for tc=timeciwf:timeciwl
            for reg=regiwf:regiwl
                eval([char(vrs(varc)) char(levels(varc)) 'arr{var,reg,tc,ndbc,1}='...
                    char(vrs(varc)) char(levels(varc)) 'arr{var,reg,tc,ndbc};']);
            end
        end
        end
    end
end

