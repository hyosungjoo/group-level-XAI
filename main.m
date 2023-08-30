close all;
clear all;
clc;

eeglab

%% load parameters
data_path='Z:\EEG\EEG_MI\results\for_public\';
matlab_path='C:\\Program Files\\MATLAB\\R2020b\\';
spa_arr=load([ data_path, '\spatial_pattern.mat']);
spa_arr=spa_arr.spa_arr;

sub_size=52;
bad_sub=[29, 34];
num_sub=50;
weights=[1, 2];
draw_figures=[1, 1];
features=load([ data_path, '\feature.mat']);
features=features.freq_feat_arr;

%% dipole fitting
Fx_dipfit_save(spa_arr, sub_size, bad_sub, data_path, matlab_path)

%% group-level analysis
[STUDY, ALLEEG, group_output]=Fx_cnn_group_level(STUDY, ALLEEG, features, weights, draw_figures, data_path);

