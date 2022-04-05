# 主要内容

This project constructs an EnOI (Ensemble Optimal Interpolation) data assimilation model for ocean current forecasts. 

The model 
* constructs the background file from the restart files; 
* reads in observation;
* calculates W matrix for generating an analysis file;
* updates the restart files with the newly generated analysis file.

Next, NEMO restarts with the updated restart files, and another cycle of data assimilation begins...

# 分支目标
在v0.1.0的基础上，使用fpm对本项目进行管理；
