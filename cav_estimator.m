%env setup
clear all
close all
addpath 'functions' 'classes';
run('functions/sift/toolbox/vl_setup');

%params
method = MethodName.Fiore;
modelFile = 'models/refDescriptorsCav';
load(modelFile); %referenceModel variable

for i = 1:6
checkImageFile = "cav/test/cav_test_"+num2str(i)+".jpg";
testK = getInternals(checkImageFile); % estimated internal params of test image
[R, T] = pose_estimator(referenceModel, checkImageFile, method, testK);
if i == 1
    figure(100)
    scatter3(referenceModel.p3D(:,1),referenceModel.p3D(:,2),referenceModel.p3D(:,3),5,'r');
    hold on
    plotCameraPose(referenceModel.R, referenceModel.T, '  ref');
end
figure(100)
hold on;
plotCameraPose(R, T, "  " + num2str(i));
axis equal
end






