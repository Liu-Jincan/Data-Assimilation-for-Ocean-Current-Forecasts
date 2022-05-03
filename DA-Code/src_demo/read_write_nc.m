%% 
% desciption: merge multiple netcdf files for sepcific domain

% usage: 
%    1. filenumber is up to the number of your netcdf file to be processed.
%    2. for different domain you want to process, you can change the number
% in the latitude0, longitude0, uwind0, vwind0.

% author:
%    huang xue zhi, dalian university of technology

% revison history
%    2018-09-25 first verison. 

%%

clear all;
clc;

% begin to merge multiple netcdf files,for example,ccmp wind field reanalysis.

%% batch reading from the netcdf file 

% define the data path and filelist
datadir='/home/wjc/wjc_work/ccmp/';
filelist=dir([datadir,'*.nc']);
% define the total numbers of netcdf files to be processed.
filenumber=length(filelist);
% batch reading the variable to another arrays.
 begin_lon=1060;
 end_lon=1282;
 begin_lat=394;
 end_lat=515;
for i=1:filenumber
    i
    ncid=[datadir,filelist(i).name];
    latitude0=ncread(ncid,'latitude');
    latitude=latitude0(begin_lat:end_lat);
    longitude0=ncread(ncid,'longitude');
    longitude=longitude0(begin_lon:end_lon);
    time(:,i)=ncread(ncid,'time');
    uwind0(:,:,:,i)=ncread(ncid,'uwnd');
    uwind(:,:,:,i)=uwind0(begin_lon:end_lon,begin_lat:end_lat,:,i);
    vwind0(:,:,:,i)=ncread(ncid,'vwnd');
    vwind(:,:,:,i)=vwind0(begin_lon:end_lon,begin_lat:end_lat,:,i);
end
%% end batch reading


%% create the merged netcdf file to store the result.

    cid=netcdf.create('ccmpwind.nc','clobber');   
%define global attributes
    netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'Conventions','CF-1.6');
    netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lat_min','-78.375 degrees');
    netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lat_max','78.375 degrees');
    netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lon_min','0.125 degrees');
    netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lon_max','359.875 degrees');
    netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'institution','RSS');
    
% define the variable dimension
    dimlon=netcdf.defDim(cid,'longitude',abs(end_lon-begin_lon)+1);
    dimlat=netcdf.defDim(cid,'latitude',abs(end_lat-begin_lat)+1);
    dimtime=netcdf.defDim(cid,'time',filenumber*4);% 4 hours one day
% end define the dimension
    
% define the variable and their attributes
    varid1=netcdf.defVar(cid,'time','NC_DOUBLE',dimtime);
    netcdf.putAtt(cid,varid1,'standard_name','time');
    netcdf.putAtt(cid,varid1,'long_name','Time of analysis');
    netcdf.putAtt(cid,varid1,'units','hours since 1987-01-01 00:00:00');
    netcdf.putAtt(cid,varid1,'calendar','proleptic_gregorian');
    netcdf.putAtt(cid,varid1,'delta_t','0000-00-00 06:00:00');

    varid2=netcdf.defVar(cid,'latitude','NC_FLOAT',dimlat);
    netcdf.putAtt(cid,varid2,'standard_name','time');
    netcdf.putAtt(cid,varid2,'units','degrees_north');
    netcdf.putAtt(cid,varid2,'long_name','Latitude in degrees north');
    netcdf.putAtt(cid,varid2,'_Fillvalue','-9999.0');
    netcdf.putAtt(cid,varid2,'axis','Y');

    
    varid3=netcdf.defVar(cid,'longitude','NC_FLOAT',dimlon);
    netcdf.putAtt(cid,varid3,'standard_name','longitude');
    netcdf.putAtt(cid,varid3,'units','degrees_east');
    netcdf.putAtt(cid,varid3,'long_name','Longitude in degrees east');
    netcdf.putAtt(cid,varid3,'_Fillvalue','-9999.0');
    netcdf.putAtt(cid,varid3,'axis','X');

    
    varid4=netcdf.defVar(cid,'windu','NC_FLOAT',[dimlon dimlat dimtime]);
    netcdf.putAtt(cid,varid4,'standard_name','eastward_wind');
    netcdf.putAtt(cid,varid4,'long_name','u-wind vector component at 10 meters');
    netcdf.putAtt(cid,varid4,'units','m s-1');
    netcdf.putAtt(cid,varid4,'_Fillvalue','-9999.0');
    netcdf.putAtt(cid,varid4,'coordinates','time latitude longitude')

    
    varid5=netcdf.defVar(cid,'windv','NC_FLOAT',[dimlon dimlat dimtime]);  
    netcdf.putAtt(cid,varid5,'standard_name','northward_wind');
    netcdf.putAtt(cid,varid5,'long_name','v-wind vector component at 10 meters');
    netcdf.putAtt(cid,varid5,'units','m s-1');
    netcdf.putAtt(cid,varid5,'_Fillvalue','-9999.0');
    netcdf.putAtt(cid,varid5,'coordinates','time latitude longitude')

    netcdf.endDef(cid);
% end define the varible and attributes


%% write variables value to merged netcdf file
    netcdf.putVar(cid,varid1,time);
    netcdf.putVar(cid,varid2,latitude);
    netcdf.putVar(cid,varid3,longitude);
    netcdf.putVar(cid,varid4,uwind);
    netcdf.putVar(cid,varid5,vwind);
    
    netcdf.close(cid);
