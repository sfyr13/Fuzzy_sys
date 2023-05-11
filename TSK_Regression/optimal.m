clc
clear


dt = readmatrix('train.csv');


%Normalization to mean=0 and std=1
for i = 1 : size(dt,2)
    min_data = min(dt(:,i));
    max_data = max(dt(:,i));
    dt(:,i) = (dt(:,i)-min_data)/(max_data-min_data); 
end

%shuffle data
dt = dt(randperm(size(dt,1)),:);

%creating training, validation and checking set
Dtrn = dt(1:floor(size(dt,1)*0.6),:);
Dval = dt(size(Dtrn,1)+1:size(Dtrn,1)+ceil(size(dt,1)*0.2),:);
Dchk = dt(size(Dtrn,1)+size(Dval,1)+1:end, :);


features = 15; %optimal number of features
r_a = 0.2; %optimal radius for SC



[idx,weights] = relieff(Dtrn(:, 1:end-1),Dtrn(:, end), 10);
opt = genfisOptions('SubtractiveClustering','ClusterInfluenceRange',r_a);
fis = genfis(Dtrn(:, idx(1:features)), Dtrn(:, end), opt);

%training procedure
trn_opt = anfisOptions('InitialFis', fis, 'EpochNumber', 50);
trn_opt.ValidationData = [Dval(:, idx(1:features)) Dval(:, end)];
[trnFis,trnError,stepSize,valFis,valError] = anfis([Dtrn(:,idx(1:features)) Dtrn(:,end)],trn_opt);


%Prediction plot
output = evalfis(valFis, Dchk(:, idx(1:features)));
figure;
plot([Dchk(:,end) output], 'LineWidth',2);
xlabel('Checking Data');
ylabel('Values');
legend('Real Value','Prediction Value')
title("Prediction and real values");


%learning plot
figure;
plot([trnError valError],'LineWidth',2); 
grid on;
xlabel('# of Iterations'); 
ylabel('Error');
legend('Training Error','Validation Error');
title(['ANFIS Hybrid Training - Validation']);

%MF initial plots
figure;
subplot(1,2,1)
plotmf(fis,'input',1);
xlabel('1. Frequency')
title('Initial Frequency MF');
        
subplot(1,2,2)
plotmf(fis,'input',2);
xlabel('2. Angle of attack')
title('Initial Angle of attack MF');

%MF final plots
figure;
subplot(1,2,1)
plotmf(valFis,'input',1);
xlabel('1. Frequency')
title('Final Frequency MF');

        
subplot(1,2,2)
plotmf(valFis,'input',2);
xlabel('2. Angle of attack')
title('Final Angle of attack MF');


%metrics
SSres = sum((Dchk(:,end) - output).^2);
SStot = sum((Dchk(:,end) - mean(Dchk(:,end))).^2);
R2 = 1- SSres/SStot;
RMSE=sqrt(mse(output, Dchk(:,end)));
NMSE = 1-R2;
NDEI = sqrt(NMSE);
    
fprintf('RMSE = %f\n NMSE = %f\n NDEI = %f\n R2 = %f\n', RMSE, NMSE, NDEI, R2);
     







