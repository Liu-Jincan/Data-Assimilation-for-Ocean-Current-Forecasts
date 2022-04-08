# 主要内容

This project constructs an EnOI (Ensemble Optimal Interpolation) data assimilation model for ocean current forecasts. 

The model constructs the background file from the restart files; 
          reads in observation;
          calculates W matrix for generating an analysis file;
          updates the restart files with the newly generated analysis file.

Next, NEMO restarts with the updated restart files, and another cycle of data assimilation begins...

本分支`v0.1.0`是fork的项目，～～

