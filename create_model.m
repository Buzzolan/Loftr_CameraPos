%%
addpath 'dante' 'cav' 'functions' 'classes';
run('functions\sift\toolbox\vl_setup');

env = 'dante'; %dante or cav
disp('Loading points...');
% Load reference camera info
if strcmp(env,'cav')
    load('cav/imgInfo.mat')
    refImg = imread('cav/cav.jpg');
    p2D = imgInfo.punti2DImg;
    p3D = imgInfo.punti3DImg;
    K_ref = imgInfo.K;
    R_ref = imgInfo.R;
    T_ref = imgInfo.T;
else
    imageIndex = '1020';
     [K_ref, R_ref, T_ref, p2D, p3D] = dante_get_points_loftr('dante/SamPointCloud.ply', ...
        "dante/testoutput.txt", ...
        "Zephyr_Dante_Statue_Dataset/_SAM"+imageIndex+".xmp");
  %{
comments
    [K_ref, R_ref, T_ref, p2D, p3D] = dante_get_points('dante/SamPointCloud.ply', ...
         "dante/VisibilityRef"+imageIndex+".txt", ...
        "Zephyr_Dante_Statue_Dataset/_SAM"+imageIndex+".xmp");
    % "dante/VisibilityRef"+imageIndex+".txt"
         %}
    refImg = imread("Zephyr_Dante_Statue_Dataset/Sub_SAM"+imageIndex+".JPG");
    
end

%{
comments
 %}
nPoint = length(p3D);
fprintf('Found %i points\n',nPoint);
disp('Building descriptors...');
run('functions/sift/vlfeat-0.9.21-bin/vlfeat-0.9.21/toolbox/vl_setup');
[f, d] = vl_sift(single(rgb2gray(refImg))) ;
[sel, dist] = dsearchn(f(1:2,:)',p2D);
threshold = 4; 
valid = dist < threshold;
sel = sel(valid);

[p2D_ref, p3D_ref, f_ref, d_ref] = getRefDescriptors(p2D, p3D, f(:,sel), d(:,sel));

fprintf('Attached descriptors to %i points\n', length(p2D_ref));

if strcmp(env,'cav')
    fileName = 'models/refDescriptorsCav.mat';
else
    fileName = "models/Sub_refDescriptorsDante_1_"+imageIndex+".mat";
end
%referenceModel = ReferenceModel(refImg, p2D_ref, p3D_ref, K_ref, R_ref, T_ref, f_ref, d_ref);
sub_referenceModel= ReferenceModel(refImg,p2D_ref, p3D_ref, K_ref, R_ref, T_ref,f_ref,d_ref);
save(fileName, 'sub_referenceModel');
fprintf('Saved model in %s\n', fileName);


imshow(refImg)
axis on
hold on;
% Plot cross at row 100, column 50
for i=1:length(p2D_ref)
    plot(p2D_ref(i,2),length(refImg)-p2D_ref(i,1), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
end