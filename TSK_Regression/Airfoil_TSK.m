clc
clear


dt = load('airfoil_self_noise.dat');


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

%models

%Singleton with 2 mfs
fis(1)=genfis1(Dtrn, 2, 'gbellmf','constant'); 
%Singleton with 3 mfs
fis(2)=genfis1(Dtrn, 3, 'gbellmf','constant');
%Polynomial with 2 mfs
fis(3)=genfis1(Dtrn, 2, 'gbellmf','linear');
%Polynomial with 3 mfs
fis(4)=genfis1(Dtrn, 3, 'gbellmf','linear');

for i = 1:4
    
    TSK(i) = fis(i) 
    trn_options = anfisOptions('InitialFis',TSK(i),'EpochNumber',50);
    trn_options.ValidationData = [Dval(:,1:end-1) Dval(:,end)];
    [trnFis,trnError,stepSize,valFis,valError] = anfis([Dtrn(:,1:end-1) Dtrn(:,end)],trn_options);
    
    
    %MF final plots
    figure;
    subplot(2,3,1)
    plotmf(valFis,'input',1);
    xlabel('1. Frequency')
        
    subplot(2,3,2)
    plotmf(valFis,'input',2);
    xlabel('2. Angle of attack')
        
    subplot(2,3,3)
    plotmf(valFis,'input',3);
    xlabel('3. Chord length')
        
    subplot(2,3,4)
    plotmf(valFis,'input',4);
    xlabel('4. Free-stream velocity')
        
    subplot(2,3,5)
    plotmf(valFis,'input',5);
    xlabel('5. Suction side displacement thickness')
     
    %learning plot
    figure;
    plot([trnError valError],'LineWidth',2); 
    grid on;
    xlabel('# of Iterations'); 
    ylabel('Error');
    legend('Training Error','Validation Error');
    title(['ANFIS Hybrid Training - Validation for i = ',num2str(i)]);
   
    
    
    %Prediction error plot
    output = evalfis(valFis, Dchk(:, 1:end-1));
    pred_err = Dchk(:, end)- output;
    figure;
    plot(pred_err, 'LineWidth',2);
    xlabel('Checking Data');
    ylabel('Error');
    title('Prediction Error');
     
    %metrics
    SSres = sum((Dchk(:,end) - output).^2);
    SStot = sum((Dchk(:,end) - mean(Dchk(:,end))).^2);
    R2 = 1- SSres/SStot;
    RMSE=sqrt(mse(output, Dchk(:,end)));
    NMSE = 1-R2;
    NDEI = sqrt(NMSE);
    
    fprintf('RMSE = %f\n NMSE = %f\n NDEI = %f\n R2 = %f\n', RMSE, NMSE, NDEI, R2);
     
end
    
     


