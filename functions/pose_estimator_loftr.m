function [R, T] = pose_estimator_loftr(model,checkImageFile, method, testK)
disp('Loading test image...');
checkImg =  imread(checkImageFile);% 2nd Img from a different point of view
load('Loftr_points1019.mat')
%substitution scale invariant feature transform with LoFTR

%% Sift method
% sift match descriptors
disp('Computing test image descriptors...');
[fc, dc] = vl_sift(single(rgb2gray(checkImg)));
disp('Matching descriptors with reference image...');
[matches, scores] = vl_ubcmatch(model.d, dc);%ho già salvato i match del modello

[drop, perm] = sort(scores, 'ascend');

toPlot = size(perm,2);
fprintf('Found %i matched points\n', toPlot);
matches = matches(:, perm(1:toPlot));
% scores = scores(perm(1:toPlot));

% x_ref = model.f(1,matches(1,:));
% x_check = fc(1,matches(2,:))+size(model.image,2);
% y_ref = model.f(2,matches(1,:));
% y_check = fc(2,matches(2,:));
% p2D_refMatch = [x_ref', y_ref'];
p2D_check = fc(1:2,matches(2,:))';%Punti 2D che hanno corrispondenza e con descrittore associato
p3D_check = model.p3D(matches(1,:),:);%prendo punti 3D dai mie punti 2D con match


figure(800)
subplot(1,2,1)
imshow(checkImg)
title('Proiezione punti sift')
axis on
hold on;
% Plot cross at row 100, column 50
for i=1:length(p2D_check)
    plot(p2D_check(i,1),p2D_check(i,2), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
end
subplot(1,2,2)
imshow(checkImg)
title('Proiezione punti loftr')
axis on
hold on;
% Plot cross at row 100, column 50
for i=1:length(loftr_2D_check)
    plot(loftr_2D_check(i,1),loftr_2D_check(i,2), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
end

%% Loftr method
%INPUT: -devo avere struttura p2D_check nx2 con n= corrispondenze 2D
%       -struttura p3D_check nx3
%p2D_check rappresenta i punti 2D della seconda immagine che hanno una
%corrispondenza con l'immagine di riferimento
%p3D_check sono i rispettivi punti 3D di p2D_check
%%
save('pose_estimator')
%% find best model for matched points loftr
% %{
inlier_threshold = floor(length(loftr_2D_check)*0.5);
numIter = 5000;
fprintf('Applying ransac with %i iterations and a threshold of %i inliers...\n', ...
    numIter, inlier_threshold);
[inliers] = ransacPose(loftr_2D_check, loftr_3D_check,testK,numIter,8,inlier_threshold);
numInliers = length(inliers);
fprintf('Best model has %i inliers\n', numInliers);
if  numInliers < 10
    error('Too few matching points to estimate the camera pose')
end

if numInliers < inlier_threshold
    disp('Inliers matching points less than imposed threshold: MODEL COULD BE INACCURATE!')
end

modelPoints = 1:numInliers;
p2D_best = loftr_2D_check(inliers,:);
p3D_best = loftr_3D_check(inliers,:);

disp('Computing exterior parameters');
G = compute_exterior(testK,[eye(3) zeros(3,1)], p2D_best(modelPoints,:)',p3D_best(modelPoints,:)', method);
G %show on command line
plotOnImage(checkImg,p2D_best(modelPoints,:), p3D_best(modelPoints,:), testK, G);
title(strcat('Projection of best model points on test image with ',string(method)));

R = G(1:3,1:3);
T = G(1:3, 4);

% %}

%% find best model for matched points sift
%{
inlier_threshold = floor(length(p2D_check)*0.5);
numIter = 5000;
fprintf('Applying ransac with %i iterations and a threshold of %i inliers...\n', ...
    numIter, inlier_threshold);
[inliers] = ransacPose(p2D_check, p3D_check,testK,numIter,8,inlier_threshold);
numInliers = length(inliers);
fprintf('Best model has %i inliers\n', numInliers);
if  numInliers < 10
    error('Too few matching points to estimate the camera pose')
end

if numInliers < inlier_threshold
    disp('Inliers matching points less than imposed threshold: MODEL COULD BE INACCURATE!')
end

modelPoints = 1:numInliers;
p2D_best = p2D_check(inliers,:);
p3D_best = p3D_check(inliers,:);

disp('Computing exterior parameters');
G = compute_exterior(testK,[eye(3) zeros(3,1)], p2D_best(modelPoints,:)',p3D_best(modelPoints,:)', method);
G %show on command line
plotOnImage(checkImg,p2D_best(modelPoints,:), p3D_best(modelPoints,:), testK, G);
title(strcat('Projection of best model points on test image with ',string(method)));

R = G(1:3,1:3);
T = G(1:3, 4);
%}

end

