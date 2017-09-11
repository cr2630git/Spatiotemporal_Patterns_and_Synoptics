%Essentially a helper script for exploratorydataanalysis, loop
%scatterplottqconstantwbtlines, that creates the final figure

figure(1);clf;curpart=1;highqualityfiguresetup;

%Do subplots 1 & 2
stnstouse=[93;187];
for i=1:2
    subplot(2,2,i);
    stntouse=stnstouse(i);
    plot([xi18(end) xi18(1)],[yi18(end) yi18(1)],'color',colors('gray'),'linewidth',3);hold on;
    plot([xi20(end) xi20(1)],[yi20(end) yi20(1)],'color',colors('purple'),'linewidth',3);
    plot([xi22(end) xi22(1)],[yi22(end) yi22(1)],'color',colors('blue'),'linewidth',3);
    plot([xi24(end) xi24(1)],[yi24(end) yi24(1)],'color',colors('light blue'),'linewidth',3);
    plot([xi26(end) xi26(1)],[yi26(end) yi26(1)],'color',colors('teal'),'linewidth',3);
    plot([xi28(end) xi28(1)],[yi28(end) yi28(1)],'color',colors('green'),'linewidth',3);
    plot([xi30(end) xi30(1)],[yi30(end) yi30(1)],'color',colors('orange'),'linewidth',3);
    plot([xi32(end) xi32(1)],[yi32(end) yi32(1)],'color',colors('red'),'linewidth',3);
    plot([xi34(end) xi34(1)],[yi34(end) yi34(1)],'color',colors('crimson'),'linewidth',3);
    text(15.7,13.2,sprintf('WBT=18%cC',char(176)),'fontsize',8,'fontweight','bold','fontname','arial');
    text(17.7,14.8,sprintf('WBT=20%cC',char(176)),'fontsize',8,'fontweight','bold','fontname','arial');
    text(19.7,16.7,sprintf('WBT=22%cC',char(176)),'fontsize',8,'fontweight','bold','fontname','arial');
    text(21.7,18.7,sprintf('WBT=24%cC',char(176)),'fontsize',8,'fontweight','bold','fontname','arial');
    text(23.7,20.9,sprintf('WBT=26%cC',char(176)),'fontsize',8,'fontweight','bold','fontname','arial');
    text(25.7,23.5,sprintf('WBT=28%cC',char(176)),'fontsize',8,'fontweight','bold','fontname','arial');
    text(27.7,26.1,sprintf('WBT=30%cC',char(176)),'fontsize',8,'fontweight','bold','fontname','arial');
    text(29.7,29.1,sprintf('WBT=32%cC',char(176)),'fontsize',8,'fontweight','bold','fontname','arial');

    %scatter(alltdatavec,allqdatavec,10,'filled');hold on;
    scatter(corresptnext900{stntouse}(101:1000),correspqnext900{stntouse}(101:1000),6,'k','filled');hold on;
        assoct=correspt{stntouse};assocq=correspq{stntouse};
    scatter(assoct(1:100),assocq(1:100),15,'r','filled');
        centroidtop100t=nanmean(assoct(1:100));centroidtop100q=nanmean(assocq(1:100));  
    scatter(centroidtop100t,centroidtop100q,150,'r','filled','marker','s','markeredgecolor','g');
            centroidnext900t=nanmean(corresptnext900{stntouse}(101:1000));
            centroidnext900q=nanmean(correspqnext900{stntouse}(101:1000));
    scatter(centroidnext900t,centroidnext900q,150,'k','filled','marker','s','markeredgecolor','g')

    ylim([0 30]);set(gca,'fontsize',12,'fontweight','bold','fontname','arial');
    ylabel('q (g/kg)','fontsize',14,'fontweight','bold','fontname','arial');
    xlabel(sprintf('T (%cC)',char(176)),'fontsize',14,'fontweight','bold','fontname','arial');
    title(sprintf('T and q for Extreme WBT at %s',newstnNumListnamesclean{stntouse}),'fontsize',14);
    
    if i==1
        cpos=[0.05 0.55 0.4 0.4];set(gca,'position',cpos);
    else
        cpos=[0.55 0.55 0.4 0.4];set(gca,'position',cpos);
    end
    text(-0.1,1.05,figletterlabels{i},'fontsize',14,'fontweight','bold','fontname','arial','units','normalized');
end

%Do subplot 3
subplot(2,2,3);
colorcutoffs=[63;54;45;36;27]; %smaller number --> WBT extremes are more T-dom --> appears as purple on map
    %numbers are chosen so that when converted to %qdom (by multiplying by 100/90) they are nice round numbers
title('% q-Domination of Top 100 WBT Extremes vs Next 900','FontSize',12,'FontWeight','bold','FontName','Arial');
mycolormap=[colors('red');colors('orange');colors('green');colors('light blue');colors('blue');colors('purple')];
%quicklymapsomethingusa(10/9.*perct',newstnNumListlats,newstnNumListlons,'s',colorcutoffs,mycolormap,7,curDir,figurename);
plotBlankMap(1,'usa');
valuestoplot=10/9.*perct';
colorcutoffs=10/9.*colorcutoffs;
markercolors=mycolormap;markersize=7;
%disp(colorcutoffs);return;
for i=1:size(valuestoplot,1)
    %disp(valuestoplot(i));
    %if i==1;disp(colorcutoffs);disp(markercolors);end
    if valuestoplot(i)>colorcutoffs(1)
        thiscolor=markercolors(6,:);
    elseif valuestoplot(i)>colorcutoffs(2)
        thiscolor=markercolors(5,:);
    elseif valuestoplot(i)>colorcutoffs(3)
        thiscolor=markercolors(4,:);
    elseif valuestoplot(i)>colorcutoffs(4)
        thiscolor=markercolors(3,:);
    elseif valuestoplot(i)>colorcutoffs(5)
        thiscolor=markercolors(2,:);
    else
        thiscolor=markercolors(1,:);
    end
    %disp(i);disp(thiscolor);
    h=geoshow(newstnNumListlats(i),newstnNumListlons(i),'DisplayType','Point','Marker','s',...
        'MarkerFaceColor',thiscolor,'MarkerEdgeColor',thiscolor,'MarkerSize',markersize);hold on;
end
colormap(mycolormap);
ctable=[0 229 0 0 30 229 0 0; %3-digit colors in table are from colors in colormap.*255
    30 249 115 6 40 249 115 6;
    40 21 176 26 50 21 176 26;
    50 149 208 252 60 149 208 252;
    60 3 67 223 70 3 67 223;
    70 126 30 156 100 126 30 156];
save mycol.cpt ctable -ascii;
h=text(0.27,-0.25,'Percent q-Domination','FontSize',12,'FontWeight','bold','FontName','Arial','units','normalized');%set(h,'rotation',90);
set(gca,'FontSize',12,'FontWeight','bold','FontName','Arial');
cpos=[0.05 0 0.4 0.45];set(gca,'position',cpos);
cptcmap('mycol','mapping','direct');
cbar=cptcbar(gca,'mycol','southoutside',false);cb=cbar.cb;
set(cbar.ax,'FontSize',12,'FontWeight','bold','FontName','Arial');
cbarpos=[0.1 0.07 0.3 0.02];
set(cbar.ax,'position',cbarpos);
text(-0.07,1.05,figletterlabels{3},'fontsize',14,'fontweight','bold','fontname','arial','units','normalized');

%Do subplot 4
subplot(2,2,4);
for stn=1:190;baselinet(stn)=nanmean(top1000tbystn{stn}(:,1));end
scatter(baselinet,perct.*10/9,'filled','o');hold on;
set(gca,'FontSize',12,'FontWeight','bold','FontName','Arial');
cpos=[0.55 0.1 0.4 0.35];set(gca,'position',cpos);
text(-0.1,1.05,figletterlabels{4},'fontsize',14,'fontweight','bold','fontname','arial','units','normalized');
%Fit curve to data
[f,gof]=fit(baselinet',perct'.*10/9,'poly2');
[a]=plot(f);a.LineStyle='--';a.LineWidth=2;
h=legend('off');
text(0.1,0.8,sprintf('r^2: %0.2f',gof.rsquare),'units','normalized','fontsize',12,'fontweight','bold','fontname','arial');
xlabel(sprintf('Average T (%cC) on 1000 hottest days',char(176)),'FontSize',12,'FontWeight','bold','FontName','Arial');
ylabel('Percent q-domination','FontSize',12,'FontWeight','bold','FontName','Arial');

curpart=2;figloc=figDir;figname='scatterplottqwbtfinal';highqualityfiguresetup;


