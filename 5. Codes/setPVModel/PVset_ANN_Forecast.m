function target = PVset_ANN_Forecast(predictors,~,path) 
    start_ANN_Forecast = tic;
    %% load .mat file
    building_num = num2str(predictors(2,1));
    load_name = '\PV_fitnet_ANN_';
    load_name = strcat(path,load_name,building_num,'.mat');
    load(load_name,'-mat');
    %% ForecastData
    predictors( ~any(predictors,2), : ) = []; 
    [time_steps, ~]= size(predictors);
    predictors(:,5)=predictors(:,5)+predictors(:,6)*0.25;
   %% Forecast solar using ANN
    % use ANN 3 times for reduce ANN's error
    for i_loop = 1:3
        net__solar_ANN = net_solar_ANN_loop{i_loop};
        result_solar_ANN_loop = zeros(time_steps,1);
        for i = 1:time_steps
                x1_ANN = transpose(predictors(i,feature1));
                result_solar_ANN_loop(i,:) = net__solar_ANN(x1_ANN);
        end
        result_solar_ANN{i_loop} = result_solar_ANN_loop;
    end
    result_solar_ANN_premean = result_solar_ANN{1}+result_solar_ANN{2}+result_solar_ANN{3};
    predictors(:,12) = max(result_solar_ANN_premean/3,0);
    %% Forecast PV using ANN
    % use ANN 3 times for reduce ANN's error
    for i_loop = 1:3
        net_PV_ANN = net_PV_ANN_loop{i_loop};
        resultPV_ANN_loop = zeros(time_steps,1);
        for i = 1:time_steps
                x2_ANN = transpose(predictors(i,feature2));
                result_PV_ANN_loop(i,:) = net_PV_ANN(x2_ANN);
        end
        result_PV_ANN{i_loop} = result_PV_ANN_loop;
    end
    result_PV_ANN_premean = result_PV_ANN{1}+result_PV_ANN{2}+result_PV_ANN{3};
    result_PV_ANN_mean = max(result_PV_ANN_premean/3,0);
    %% ResultingData File
    ResultingData_ANN(:,1:12) = predictors(:,1:12);
    ResultingData_ANN(:,13) = result_PV_ANN_mean;
    target = ResultingData_ANN(1:time_steps,13);
    end_ANN_Forecast = toc(start_ANN_Forecast)
end