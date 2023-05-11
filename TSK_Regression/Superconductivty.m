clc
clear 

dt = readmatrix('train.csv');

%Normalization to mean=0 and std=1
for i = 1 : size(dt,2)-1
    min_data = min(dt(:,i));
    max_data = max(dt(:,i));
    dtt(:,i) = (dt(:,i)-min_data)/(max_data-min_data); 
end

dt = cat(2, dtt, dt(:, end));

featuresNum = [5, 10, 15]; %number of features to test
r_a = [0.2, 0.8]; %values of radius for SC
mme = zeros(length(featuresNum), length(r_a)); %min mean error
rulesNum = zeros(length(featuresNum), length(r_a)); %number of rules
k=5;


for i=1:length(featuresNum)
    for j=1:length(r_a)
        val_err = zeros(k); 
        feature = featuresNum(i);
        ra = r_a(j);
        
        for m=1:k
            dt = dt(randperm(size(dt,1)),:);
            Dtrn = dt(1:floor(size(dt,1)*0.8),:);
            Dval = dt(size(Dtrn,1)+1:end,:);
            [idx, weights] = relieff(Dtrn(:, 1:end-1),Dtrn(:, end), 10);
            opt = genfisOptions('SubtractiveClustering', 'ClusterInfluenceRange', ra);
            fis = genfis(Dtrn(:, idx(1:feature)), Dtrn(:,end), opt);

            %training procedure
            trn_opt = anfisOptions('InitialFis', fis, 'EpochNumber', 25);
            trn_opt.ValidationData = [Dval(:,idx(1:feature)) Dval(:,end)];
            [trnFis,trnError,stepSize,valFis,valError] = anfis([Dtrn(:,idx(1:feature)) Dtrn(:,end)],trn_opt);

            val_err(k) = min(valError);
        end
        rulesNum(i, j) = size(showrule(valFis),1);
        mme(i, j) = sum(val_err(:))/ k;
    end
end

%error-number of rules and error-features plots
figure(1)
subplot(2,2,1);
plot(r_a, mme(1,:))
title('FeaturesNum = 5')
subplot(2,2,2);
plot(r_a, mme(2,:))
title('FeaturesNum = 10')
subplot(2,2,3);
plot(r_a, mme(3,:))
title('FeaturesNum = 15')
suptitle('Error - Number of Rules');

figure(2)
subplot(1,2,1);
plot(featuresNum, mme(:, 1))
title('Radius = 0.2')
subplot(1,2,2);
plot(featuresNum, mme(:, 2))
title('Radius = 0.8')
%subplot(2,2,3);
%plot(featuresNum, mme(:, 3))
%title('Radius = 0.8')
suptitle('Error - Number of Features relation');






    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


    