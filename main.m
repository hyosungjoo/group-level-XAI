close all;
clear all;
clc;

eeglab



%% group-level analysis
% load key parameters
num_sub=50;
num_brancehs=16;
weights=[1, 2];
draw_figures=[1, 1];
data_path='Z:\EEG\EEG_MI\results\for_public\';
feature=load([ data_path, '\feature.mat']);
feature=feature.freq_feat_arr;

% group-level analysis
[STUDY, ALLEEG]=Fx_cnn_group_level(STUDY, ALLEEG, feature, weights, draw_figures, data_path);

