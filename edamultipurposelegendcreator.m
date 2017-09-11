%Some stuff that took up too much space in exploratorydataanalysis
%This is called in the course of that script; it obviously cannot stand alone

%Add custom colormap/colorbar
exist colorbarc;
if ans==1
    if colorbarc==1
        mycolormap=[colors('red');colors('orange');colors('green');colors('sky blue');...
            colors('blue');colors('purple');colors('brown');colors('gray')];
        colormap(flipud(mycolormap));
        h=colorbar;
        cbar=colorbar('YTick',[0 0.125 0.25 0.375 0.5 0.625 0.75 0.875 1.0],...
            'YTickLabel',{'Sep 10','Aug 31','Aug 20','Aug 10','Jul 31',...
            'Jul 20','Jul 10','Jun 30','Jun 20'});
            %the first y tick labels, for whatever reason, appear at the bottom and go upwards from there
        set(cbar,'FontSize',10,'FontWeight','bold','FontName','Arial');
    elseif colorbarc==2
        mycolormap=colormaps('category','fewereven');
        colormap(flipud(mycolormap));
        h=colorbar;
        p95val=round2(quantile(thingbeingplotted,0.95),prec);
        p80val=round2(quantile(thingbeingplotted,0.8),prec);
        p60val=round2(quantile(thingbeingplotted,0.6),prec);
        p40val=round2(quantile(thingbeingplotted,0.4),prec);
        p20val=round2(quantile(thingbeingplotted,0.2),prec);
        p5val=round2(quantile(thingbeingplotted,0.05),prec);
        ticklabel1=char(strcat('>=',num2str(p95val),{' '},units));
        ticklabel2=char(strcat(num2str(p80val),'-',num2str(p95val),{' '},units));
        ticklabel3=char(strcat(num2str(p60val),'-',num2str(p80val),{' '},units));
        ticklabel4=char(strcat(num2str(p40val),'-',num2str(p60val),{' '},units));
        ticklabel5=char(strcat(num2str(p20val),'-',num2str(p40val),{' '},units));
        ticklabel6=char(strcat(num2str(p5val),'-',num2str(p20val),{' '},units));
        exist hardlowerbound;
        if ans==1
            ticklabel7=char(strcat(num2str(p5val),{' '},units));
        else
            ticklabel7=char(strcat('<=',num2str(p5val),{' '},units));
        end
        clear hardlowerbound;
        cbar=colorbar('YTick',[0.071 0.214 0.357 0.5 0.643 0.786 0.929],...
            'YTickLabel',{ticklabel1,ticklabel2,ticklabel3,ticklabel4,ticklabel5,ticklabel6,ticklabel7});
        if inclcblabel==1;set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',18,'FontWeight','bold','FontName','Arial');end
        set(cbar,'FontSize',16,'FontWeight','bold','FontName','Arial');
    elseif colorbarc==2.25 %six-category rainbow plots
        mycolormap=colormaps('category','fewereven');
        colormap(flipud(mycolormap));
        h=colorbar;
        p90val=bp1;p75val=bp2;p50val=bp3;p25val=bp4;p10val=bp5;
        ticklabel1=char(strcat('>=',num2str(p90val),{' '},units));
        ticklabel2=char(strcat(num2str(p75val),'-',num2str(p90val),{' '},units));
        ticklabel3=char(strcat(num2str(p50val),'-',num2str(p75val),{' '},units));
        ticklabel4=char(strcat(num2str(p25val),'-',num2str(p50val),{' '},units));
        ticklabel5=char(strcat(num2str(p10val),'-',num2str(p25val),{' '},units));
        exist hardlowerbound;
        if ans==1
            ticklabel6=char(strcat(num2str(p10val),{' '},units));
        else
            ticklabel6=char(strcat('<=',num2str(p10val),{' '},units));
        end
        clear hardlowerbound;
        cbar=colorbar('YTick',[0.083 0.25 0.417 0.583 0.75 0.917],...
            'YTickLabel',{ticklabel1,ticklabel2,ticklabel3,ticklabel4,ticklabel5,ticklabel6});
        if inclcblabel==1;set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',18,'FontWeight','bold','FontName','Arial');end
        set(cbar,'FontSize',16,'FontWeight','bold','FontName','Arial');
    elseif colorbarc==2.5
        p90val=bp1;p75val=bp2;p50val=bp3;p25val=bp4;p10val=bp5;
        ticklabel1=char(strcat('>=',num2str(p90val),{' '},units));
        ticklabel2=char(strcat(num2str(p75val),'-',num2str(p90val),{' '},units));
        ticklabel3=char(strcat(num2str(p50val),'-',num2str(p75val),{' '},units));
        ticklabel4=char(strcat(num2str(p25val),'-',num2str(p50val),{' '},units));
        ticklabel5=char(strcat(num2str(p10val),'-',num2str(p25val),{' '},units));
        exist hardlowerbound;
        if ans==1
            ticklabel6=char(strcat(num2str(p10val),{' '},units));
        else
            ticklabel6=char(strcat('<=',num2str(p10val),{' '},units));
        end
        clear hardlowerbound;
        %Set & freeze colormap
        %mycolormap=colormaps(vartoplot,'fewereven');
        colormap(flipud(mycolormap));if makefinal==1;freezeColors;end
        %Set & freeze colorbar
        %cbar=colorbar('YTick',[0.083 0.25 0.417 0.583 0.75 0.917],...
        %    'YTickLabel',{ticklabel1,ticklabel2,ticklabel3,ticklabel4,ticklabel5,ticklabel6},...
        %    'Position',[0.85 1.006-0.5*panelnumber 0.02 0.48]);
        cbar=colorbar('YTick',[0.083 0.25 0.417 0.583 0.75 0.917],...
        'YTickLabel',{ticklabel1,ticklabel2,ticklabel3,ticklabel4,ticklabel5,ticklabel6});
        %if makefinal==1 %i.e. a multipanel figure
            %set(cbar,'Position',[0.85 1.006-0.5*panelnumber 0.02 0.48]);
        %end
        if inclcblabel==1;set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',18,'FontWeight','bold','FontName','Arial');end
        set(cbar,'FontSize',16,'FontWeight','bold','FontName','Arial');
        if makefinal==1;cbfreeze(cbar);end
    elseif colorbarc==2.75 %same as 2.5 but evenly spaced between p90val and p10val
        colormap(flipud(mycolormap));
        h=colorbar;
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
            'YTickLabel',{ticklabel1,ticklabel2,ticklabel3,ticklabel4,ticklabel5,ticklabel6},'units','normalized');
        if inclcblabel==1;set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',18,'FontWeight','bold','FontName','Arial');end
        set(cbar,'FontSize',16,'FontWeight','bold','FontName','Arial');
    elseif colorbarc==3
        mycolormap=[colors('red');colors('orange');colors('green');colors('sky blue');...
            colors('blue');colors('purple');colors('brown');colors('black')];
        %colormap(flipud(mycolormap));
        cbar=colorbar;
        set(cbar,'YTick',[0 0.125 0.25 0.375 0.5 0.625 0.75 0.875 1.0],...
            'YTickLabel',{'21:00','18:00','17:00','16:00',...
            '15:00','14:00','13:00','12:00','09:00'});
        set(cbar,'FontSize',16,'FontWeight','bold','FontName','Arial');
    elseif colorbarc==3.5
        mycolormap=[colors('red');colors('orange');colors('green');colors('sky blue');...
            colors('blue');colors('purple')];
        %colormap(flipud(mycolormap));
        cbar=colorbar;
        set(cbar,'YTick',[0 1/6 2/6 3/6 4/6 5/6 1.0],...
            'YTickLabel',{num2str(0),num2str(l1),num2str(l2),...
            num2str(l3),num2str(l4),num2str(l5),num2str(l6)});
        set(cbar,'FontSize',16,'FontWeight','bold','FontName','Arial');
    elseif colorbarc==4
        mycolormap=[colors('red');colors('orange');colors('green');colors('light blue');...
            colors('blue');colors('purple')];
        %colormap(flipud(mycolormap));
        colormap(mycolormap);
        h=colorbar;
        p90val=round2(quantile(thingbeingplotted,0.25),prec);
        p75val=round2(quantile(thingbeingplotted,0.125),prec);
        p50val=round2(quantile(thingbeingplotted,0.0625),prec);
        p25val=round2(quantile(thingbeingplotted,0.031),prec);
        p10val=round2(quantile(thingbeingplotted,0.0155),prec);
        ticklabel1=char(strcat('>=',num2str(p90val),{' '},units));
        ticklabel2=char(strcat(num2str(p75val),'-',num2str(p90val),{' '},units));
        ticklabel3=char(strcat(num2str(p50val),'-',num2str(p75val),{' '},units));
        ticklabel4=char(strcat(num2str(p25val),'-',num2str(p50val),{' '},units));
        ticklabel5=char(strcat(num2str(p10val),'-',num2str(p25val),{' '},units));
        ticklabel6=char(strcat('<',num2str(p10val),{' '},units));
        cbar=colorbar('YTick',[0.083 0.25 0.417 0.583 0.75 0.917],...
            'YTickLabel',{ticklabel1,ticklabel2,ticklabel3,ticklabel4,ticklabel5,ticklabel6});
        set(cbar,'FontSize',16,'FontWeight','bold','FontName','Arial');
    elseif colorbarc==5 %Same as 2 but with the order of the colors reversed
        mycolormap=[colors('purple');colors('blue');colors('sky blue');colors('green');colors('orange');colors('red')];
        %colormap(flipud(mycolormap));
        colormap(mycolormap);
        h=colorbar;
        p90val=round2(quantile(thingbeingplotted,0.9),prec);
        p75val=round2(quantile(thingbeingplotted,0.75),prec);
        p50val=round2(quantile(thingbeingplotted,0.5),prec);
        p25val=round2(quantile(thingbeingplotted,0.25),prec);
        p10val=round2(quantile(thingbeingplotted,0.1),prec);
        ticklabel1=char(strcat('>=',num2str(p90val),{' '},units));
        ticklabel2=char(strcat(num2str(p75val),'-',num2str(p90val),{' '},units));
        ticklabel3=char(strcat(num2str(p50val),'-',num2str(p75val),{' '},units));
        ticklabel4=char(strcat(num2str(p25val),'-',num2str(p50val),{' '},units));
        ticklabel5=char(strcat(num2str(p10val),'-',num2str(p25val),{' '},units));
        ticklabel6=char(strcat('<',num2str(p10val),{' '},units));
        cbar=colorbar('YTick',[0.083 0.25 0.417 0.583 0.75 0.917],...
            'YTickLabel',{ticklabel6,ticklabel5,ticklabel4,ticklabel3,ticklabel2,ticklabel1});
        set(cbar,'FontSize',16,'FontWeight','bold','FontName','Arial');
    elseif colorbarc==6 %Same as 4 but with the order of the colors reversed
        mycolormap=[colors('purple');colors('blue');colors('sky blue');colors('green');colors('orange');colors('red')];
        %colormap(flipud(mycolormap));
        colormap(mycolormap);
        h=colorbar;
        p90val=round2(quantile(thingbeingplotted,pctstouse(1)),prec);
        p75val=round2(quantile(thingbeingplotted,pctstouse(2)),prec);
        p50val=round2(quantile(thingbeingplotted,pctstouse(3)),prec);
        p25val=round2(quantile(thingbeingplotted,pctstouse(4)),prec);
        p10val=round2(quantile(thingbeingplotted,pctstouse(5)),prec);
        ticklabel1=char(strcat('>=',num2str(p90val),{' '},units));
        ticklabel2=char(strcat(num2str(p75val),'-',num2str(p90val),{' '},units));
        ticklabel3=char(strcat(num2str(p50val),'-',num2str(p75val),{' '},units));
        ticklabel4=char(strcat(num2str(p25val),'-',num2str(p50val),{' '},units));
        ticklabel5=char(strcat(num2str(p10val),'-',num2str(p25val),{' '},units));
        ticklabel6=char(strcat('<',num2str(p10val),{' '},units));
        cbar=colorbar('YTick',[0.083 0.25 0.417 0.583 0.75 0.917],...
            'YTickLabel',{ticklabel6,ticklabel5,ticklabel4,ticklabel3,ticklabel2,ticklabel1});
        set(cbar,'FontSize',16,'FontWeight','bold','FontName','Arial');
    elseif colorbarc==7 %for anything where a nice customizable colorbar is desired
        caxisRange=[cbmin cbmax];caxis(caxisRange);cbar=colorbar;
        set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',18,'FontWeight','bold','FontName','Arial');
        set(cbar,'FontSize',18,'FontWeight','bold','FontName','Arial');
    elseif colorbarc==8
        mycolormap=[colors('red');colors('orange');colors('green');colors('sky blue');...
            colors('blue');colors('purple')];
        colormap(mycolormap);
        ticklabel1=char(strcat('>=',num2str(breakvals(1)),{' '},units));
        ticklabel2=char(strcat(num2str(breakvals(2)),'-',num2str(breakvals(1)),{' '},units));
        ticklabel3=char(strcat(num2str(breakvals(3)),'-',num2str(breakvals(2)),{' '},units));
        ticklabel4=char(strcat(num2str(breakvals(4)),'-',num2str(breakvals(3)),{' '},units));
        ticklabel5=char(strcat(num2str(breakvals(5)),'-',num2str(breakvals(4)),{' '},units));
        ticklabel6=char(strcat('<',num2str(breakvals(5)),{' '},units));
        cbar=colorbar('YTick',[0.083 0.25 0.417 0.583 0.75 0.917],...
            'YTickLabel',{ticklabel1,ticklabel2,ticklabel3,ticklabel4,ticklabel5,ticklabel6});
        set(cbar,'FontSize',16,'FontWeight','bold','FontName','Arial');
    elseif colorbarc==9 %for anything where nothing special is needed, just a nice colorbar & label
        cbar=colorbar;
        set(get(cbar,'Ylabel'),'String',colorbarlabel,'FontSize',16,'FontWeight','bold','FontName','Arial');
        set(cbar,'FontSize',16,'FontWeight','bold','FontName','Arial');
    end
    clear colorbarc;inclcblabel=0;
end

%Add title
exist titlec;
if ans==1
    if titlec==1
        title(sprintf('Average Date of Occurrence of the %d Highest %s',numdates,varname),...
            'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==2
        title(sprintf('St. Dev. of Date of Occurrence of the %d Highest %s',numdates,varname),...
            'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==3
        title(sprintf('Number of Days in the Union of the %d Highest %s and %d Highest %s Occurrences',...
            numdates,var1name,numdates,var2name),'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==3.5
        title(sprintf('Percent Overlap between the %d Highest %s and %d Highest %s Days',...
            numdates,var1name,numdates,var2name),'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==3.75
        title('Ratio of WBT-T Percent Overlap to WBT-q Percent Overlap','FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==4
        title(sprintf('Average Hour of Occurrence of the %d Highest %s',numdates,varname),...
            'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==5
        title(sprintf('St. Dev. of Hour of Occurrence of the %d Highest %s',numdates,varname),...
            'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==6
        title(sprintf('Number of Events Represented by the %d Highest %s',numdates,varname),...
            'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==7
        title(sprintf('Number of Years Required to Represent Half of the %d Highest %s',numdates,varname),...
            'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==8
        title(sprintf('Interannual St. Dev. of the Occurrence of the %d Highest %s',numdates,varname),...
            'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==9
        phr1=sprintf('Interannual Correlation Between %s-%s SST Anomalies in %s and',month1,month2,regionofinterest);
        phr2=sprintf('the Number of %d Highest %s Days at Each Station',numdates,varname);
        title({phr1,phr2},'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==10
        phr1=sprintf('Interannual Correlation Between the Number of Hot %s Days in %s%s',varname,theornot,roiname);
        phr2=sprintf('and %s-%s SST Anomalies at Each Gridpoint%s',month1,month2,detrtitleremark);
        title({phr1,phr2},'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==11
        phr1=sprintf('Average of Monthly SST Anomalies For Hot %s Days in %s%s',varname,theornot,roiname);
        title({phr1},'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==12
        title('Difference Between Relative Contributions of T and q to Extreme WBT',...
            'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==13
        title(sprintf('Median Standardized Anomaly of %s at Hours of Extreme WBT',varname),...
            'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==14
        title(sprintf('Ratio of Median Standardized Anomalies of T and q at Hours of Extreme WBT'),...
            'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==15
        title(sprintf('Difference Between Avg %s of Extreme T and Avg %s of Extreme q',optionnametitle,optionnametitle),...
            'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==16
        title('Average Number of q Spikes Per Year','FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==17
        title(sprintf('Percent of %s Spikes Contributing to an Extreme-WBT Observation',titlename),...
            'FontSize',20,'FontName','Arial','FontWeight','bold');
    elseif titlec==18
        title('Median Value of Top-100 WBT Daily Maxes',...
            'FontSize',24,'FontName','Arial','FontWeight','bold');
    end
    clear titlec;
end


