%env setup
clear all
close all
addpath 'functions' 'classes';
run('functions/sift/vlfeat-0.9.21-bin/vlfeat-0.9.21/toolbox/vl_setup');

%params
method = MethodName.Fiore;
modelFile = 'models/refDescriptorsDante1020';%load descriptors
load(modelFile); %variable referenceModel


for i = 1:1
checkImageFile = "dante/test/1020/test_"+num2str(i)+".jpg";
testK = getInternals(checkImageFile); % estimated internal params of test image
[R, T] = pose_estimator(referenceModel, checkImageFile, method, testK);
% if i == 1
%     figure(100)
%     scatter3(referenceModel.p3D(:,1),referenceModel.p3D(:,2),referenceModel.p3D(:,3),5,'r');
%     hold on
%     plotCameraPose(referenceModel.R, referenceModel.T, '  ref');
% end
figure(200)
ptCloud = pcread('dante/Mesh.ply');
pcshow(ptCloud)
set(gcf,'color','w');
set(gca,'color','w');
set(gca, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15]);
hold on
plotCameraPose(referenceModel.R, referenceModel.T, '  ref');
plotCameraPose(R, T, "  " + num2str(i));

axis equal
end