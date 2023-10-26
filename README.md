# Introduction
This project aims to develop a method for obtaining the group-level interpretation of EEG signals using a compact convolutional neural network (CNN). The group-level analysis comprises three procedures: feature extraction, clustering of convolutional filters, and selective interpretation of task-relevant clusters. The source code includes clustering of convolutional filters and selective interpretation. Feature extraction procedure can vary depending on the model and task, so you can make your feature extraction code using a model interpretability library (e.g., Captum). The source code for feature extraction is available upon reasonable request.

# Requirements
* MATLAB >= 2020b
* EEGLab >= 2021.1 (REQUIRE FieldTrip Plugin)

# Function 1: Fx_cnn_group_level.m
### Overview
This function includes two procedures: clustering of convolutional filters and selective interpretation.
Feature extraction and dipole fitting should be preceded.
You may find the function for dipole fitting in the file in this directory (see Fx_dipfit_save.m).
### Key parameters
* feature: Feature array except with dipole location (NXM 2-D array)
  * N denotes the number of convolutional filters (our case: 800)
  * M denotes the number of features except with dipole location (our case: 3)
* weights: Weights for clustering process (1-D array, our case had two weights - spectral features, dipole location)
* draw_figures: Flag for drawing figures (0: off, 1: on). For example, using [1, 1] will enable us to visualize Figure 1 (task relevancy bar graph) and Figure 2 (dipole distribution)
* data_path: path which includes data (The EEGlab dataset containing the dipole fitting results must be saved in the dipfit folder in data_path).
### Outputs
* STUDY: A new STUDY set containing clustering results
* ALLEEG: A vector of EEG datasets included in the STUDY structure 
* group_output: A structure to contain the selected number of clusters and convolutional filters belonging to selected clusters. The "convolutional filters" variable represents indexes of the filters, including the subject number (first column) and branch number (second column).
* This function draws two figures: task relevancy bar graph and dipole distribution.
### Usage (see main.m)
```MATLAB
[STUDY, ALLEEG, group_output]=Fx_cnn_group_level(STUDY, ALLEEG, features, weights, draw_figures, data_path);
```

# Function 2: Fx_dipfit_save.m
### Overview
This function includes a dipole fitting procedure based on spatial patterns interpreted from compact CNN.
This function 1) reads raw EEG datasets, 2) fits dipole, and 3) saves EEG datasets that contain dipole-fitting results.
### Key parameters
* spa_arr: Spatial pattern interpreted from compact CNN. The spatial pattern will be used for dipole fitting (NXM 2-D array)
  * N denotes the number of convolutional filters (our case: 800)
  * M denotes the number of EEG channels (our case: 64)
* sub_size: The number of subjects (our case: 52)
* bad_sub: 1-D array representing the number of subjects (our case has two bad subjects - subject29, subject34)
* data_path: Path which includes data (The EEGLAB dataset containing the dipole fitting results must be saved in the dipfit folder in data_path)
* matlab_path: Matlab folder path 
### Usage (see main.m)
```MATLAB
Fx_dipfit_save(spa_arr, sub_size, bad_sub, data_path, matlab_path)
```

# Paper Citation
If you use our code in your research and found it helpful, please cite the following paper:
* H. Joo, L. D. A. Quan, L. T. Trang, D. Kim and J. Woo, "Group-Level Interpretation of Electroencephalography Signals Using Compact Convolutional Neural Networks," in IEEE Access, vol. 11, pp. 114992-115001, 2023, doi: 10.1109/ACCESS.2023.3325283.

# Legal disclaimer
This project is governed by the terms of the Creative Commons Zero 1.0 Universal (CC0 1.0) Public Domain Dedication (the Agreement). You should have received a copy of the Agreement with a copy of this software. You may find the full license in the file LICENSE in this directory.
