# Introduction
This project aims to develop a method for obtaining the group-level interpretation of EEG signals using a compact convolutional neural network (CNN). The group-level analysis comprises three procedures: feature extraction, clustering of convolutional filters, and selective interpretation of task-relevant clusters. The source code includes clustering of convolutional filters and selective interpretation. Feature extraction procedure can vary depending on the model and task, so you can make your feature extraction code using a model interpretability library (e.g., Captum). The source code for feature extraction is available upon reasonable request.

# Requirements
* MATLAB >= 2020b
* EEGLab >= 2021.1 (NEED FieldTrip Plugin)

# Function 1: Fx_cnn_group_level
### Overview
This function includes two procedures: clustering of convolutional filters and selective interpretation.
Feature extraction and dipole fitting should be preceded.
You may find the function for dipole fitting in the file in this directory (see Fx_dipfit_save.m).
### Key parameters
* feature: Feature array except with dipole location (NXM 2-D array)
  * N denotes the number of convolutional filters (our case: 800)
  * M denotes the number of features except with dipole location (our case: 3)
* weights: Weights for clustering process (1-D array, our case had two weights - spectral features, dipole location)
* draw_figures: Flag for drawing figures (0: off, 1: on)
  * For example, using [1, 1] will enable to visualize Figure 1 (task relevancy bar graph) and Figure 2 (dipole distribution)
* data_path: path which includes data (The EEGlab dataset containing the dipole fitting results must be saved in the dipfit folder in data_path).
### Outputs
* STUDY: A new STUDY set containing clustering results
* ALLEEG: A vector of EEG datasets included in the STUDY structure 
* group_output: A structure to contain the selected number of clusters and convolutional filters beloning to selected clusters.
 * convolutional filters represented with the subject number and branches, including convolutional filters.
* This function draw two figures, encompassing task relevancy bar graph and dipole distribution.
### Usage (see main.m)
```MATLAB
[STUDY, ALLEEG, group_output]=Fx_cnn_group_level(STUDY, ALLEEG, features, weights, draw_figures, data_path);
```

# Function 1: Fx_cnn_group_level
### Overview
This function includes dipole fitting procedure based on spatial pattern interpreted from compact CNN.
This function 1) read raw EEG datasets, 2) fit dipole, and 3) save EEG datasets which contain dipole fitting results  
### Key parameters
* spa_arr: Spatial pattern interpreted from compact CNN (NXM 2-D array)
  * N denotes the number of convolutional filters (our case: 800)
  * M denotes the number of EEG channels (our case: 64)
* sub_size: The number of subjects (our case: 52)
* bad_sub: 1-D array representing number of subjects (our case has two bad subjects - subject29, subject34)
* data_path: Path which includes data (The EEGlab dataset containing the dipole fitting results must be saved in the dipfit folder in data_path)
* matlab_path: matlab folder path 
### Usage (see main.m)
```MATLAB
Fx_dipfit_save(spa_arr, sub_size, bad_sub, data_path, matlab_path)
```

# Paper Citation

# Legal disclaimer
This project is governed by the terms of the Creative Commons Zero 1.0 Universal (CC0 1.0) Public Domain Dedication (the Agreement). You should have received a copy of the Agreement with a copy of this software. 
You may find the full license in the file LICENSE in this directory.
