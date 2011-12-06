close all;
clear all;

load cervix_data;

figure
for i=1:44
    if cervix_data(i,3)==1
        p(1)=plot(i,cervix_data(i,2),'bs');
        hold on;
    elseif cervix_data(i,3)==2
        p(2)=plot(i,cervix_data(i,2),'rs');
        hold on;
    end
end
legend(p,'Normal/Inflammtion','LG(CIN1/HPV) HG(CIN2/3)');
xlabel('Site')
ylabel('N/C ratio')

figure
for i=1:44
    if cervix_data(i,4)==1
        p(1)=plot(i,cervix_data(i,2),'bs');
        hold on;
    elseif cervix_data(i,4)==2
        p(2)=plot(i,cervix_data(i,2),'rs');
        hold on;
    end
end
legend(p,'Normal/Inflammtion LG(CIN1/HPV)','HG(CIN2/3)');
xlabel('Site')
ylabel('N/C ratio')
