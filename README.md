# Introduction
This project aims to develop a method for obtaining the group-level interpretation of EEG signals using a compact convolutional neural network (CNN). 
The group-level analysis comprises three procedures: feature extraction, clustering of convolutional filters, and selective interpretation of task-relevant clusters. 
The source code includes clustering of convolutional filters and selective interpretation.
The source code for feature extraction is available from the corresponding author upon reasonable request.

# Requirements
* MATLAB >= 2008b
* EEGLab >= 2021.1 (NEED FieldTriplite Plugin)

# Usage: Fx_cnn_group_level
### Key parameters
* feature: feature array except with dipole location (NXM 2-D array)
  * N denotes the number of convolutional filters (our case: 800)
  * M denotes the number of features except with dipole location (our case: 3)
* weights: weights for clustering process (1-D array, our data: 2 - spectral features, dipole location)
* draw_figures: flag for drawing figures (0: off, 1: on)
  * ex) For example, using [1, 1] will enable Figure 1 (task relevancy bar graph) and Figure 2 (dipole distribution)
* data_path: path which includes data
### Source code (see main.m)
```MATLAB
[STUDY, ALLEEG]=Fx_cnn_group_level(STUDY, ALLEEG, feature, weights, draw_figures, data_path);
```

# Paper Citation

# Legal disclaimer
This project is governed by the terms of the Creative Commons Zero 1.0 Universal (CC0 1.0) Public Domain Dedication (the Agreement). You should have received a copy of the Agreement with a copy of this software. 
You may find the full license in the file LICENSE in this directory.
