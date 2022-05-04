%%	这是 colormap 的设置
set(groot,'DefaultFigureColormap',jet)

%%  区域
area = 'south_Africa';

%%	路径设置（绝对路径 or 相对路径）
bin_dir = '/home/jincanliu/BaiduNetdiskWorkspace/WaveModel2/work-griden/TUTORIAL_GRIDGEN/bin';				%	griden函数
ref_dir = '/home/jincanliu/BaiduNetdiskWorkspace/WaveModel2/work-griden/TUTORIAL_GRIDGEN/reference';		%	水深、边界数据
nml_dir = '/home/jincanliu/BaiduNetdiskWorkspace/WaveModel2/work-griden/TUTORIAL_GRIDGEN/namelist';			%	ww3网格参数的预设置
data_dir = '/home/jincanliu/BaiduNetdiskWorkspace/WaveModel2/work-griden/TUTORIAL_GRIDGEN/data'; 	%	输出数据

%%	经纬度设置
dx = 0.125; dy = 0.125;
lon_west = 12;
lon_east = 23;
lat_south = -38.9;
lat_north = -27.2;
lon1d = (lon_west:dx:lon_east);
lat1d = (lat_south:dy:lat_north);
[lon,lat] = meshgrid(lon1d,lat1d);

%%	要允许从任何地方调用 GRIDGEN 函数，请将它们添加到路径中
addpath(bin_dir,'-END');

%%	加载边界mat文件。 
%	用户可以从多个分辨率中进行选择，网格的生成速度越快，边界越粗。 
%	最佳做法是构建具有完整分辨率边界的网格，即使这可能需要更多时间。
load([ref_dir,'/coastal_bound_full.mat']);
%	加载这个边界文件应该已经生成了一个名为 "bound "变量；
%	你可以通过输入不带分号的bound来检查结构的性质和阵列的大小；
bound
%   bound 的图形展示
figure('NumberTitle','off','Name','bound 图形展示','Color','w');
subplot(2,2,1);
for i = 1:1000      %   总共188603个polygons;
    plot(bound(i).x,bound(i).y,'.','MarkerSize',0.5);
    hold all;
end
title('1:1000 polygons')
subplot(2,2,2);
for i = 1:10      
    plot(bound(i).x,bound(i).y,'.','MarkerSize',0.5);
    hold all;
end
title('1:10 polygons')
subplot(2,2,3);
for i = 1     
    plot(bound(i).x,bound(i).y,'.','MarkerSize',0.5);
    hold all;
end
title('1:1 polygons')



%%	水深文件
ref_grid = 'gebco'; % Name of the file without the '.nc' extension
xvar = 'lon'; 		% Name of the variable defining longitudes in file
yvar = 'lat'; 		% Name of the variable defining latitudes in file
zvar = 'elevation';	% Name of the variable defining depths in file

%%	创建水深网格的参数设置
CUT_OFF = 0.0;		% Cut-off depth to distinguish between dry & wet cells
					% 小于0，'wet'；大于0，'dry'；
LIM_BATHY = 0.4;	% Base bathymetry cells needing to be wet 
					% for the target cell to be considered wet.
DRY_VAL = 999999; 	% Depth value set for dry cells

%%	创建水深网格 depth
depth = generate_grid('rect',lon,lat,ref_dir,ref_grid,LIM_BATHY,CUT_OFF,DRY_VAL,xvar,yvar,zvar);
depth;
%	depth 的图形展示
figure('NumberTitle','off','Name',strcat(area,'的水深网格 depth 图形展示'),'Color','w');
d=depth;d(d==DRY_VAL)=nan; pcolor(lon,lat,d); shading flat; colorbar

%%	创建海陆掩码 m1
m1 = ones(size(depth));
m1(depth == DRY_VAL) = 0;
%	m1 的图形展示
figure('NumberTitle','off','Name',strcat(area,'的海陆掩码 m1 图形展示'),'Color','w');
pcolor(lon,lat,m1);shading flat;caxis([0 3]);colorbar

%%	确定 domain，比实际的网格大一点，以考虑到 domain 边缘的所有单元：
lon_start = min(min(lon))-dx;
lon_end = max(max(lon))+dx;
lat_start = min(min(lat))-dy;
lat_end = max(max(lat))+dy;
coord = [lat_start lon_start lat_end lon_end];

%%	确定沿海边界多边形b（b其实就是边界数据bound的子集?）
[b,N] = compute_boundary(coord,bound);
b
N
%	b 的图形展示
figure('NumberTitle','off','Name',strcat(area,'的沿海边界多边形 b 图形展示'),'Color','w');
for i = 1:N
	plot(b(i).x,b(i).y);
	hold on;
end






%%	分割沿海边界多边形b的参数设置
MIN_DIST = 4;			% minimum distance between edge of polygon and boundary
SPLIT_LIM = 0.5;		% SPLIT_LIM通常定义为数组[dx dy]的最大值的5到10倍

%%	分割沿海边界多边形b
b_split = split_boundary(b,SPLIT_LIM,MIN_DIST);
%	b_split 的图形展示,
Nb = length(b_split);
figure('NumberTitle','off','Name',strcat(area,'的沿海边界多边形b分割后的 b_split 图形展示'),'Color','w');
for i = 1:Nb
	plot(b_split(i).x,b_split(i).y);
	hold on;
end



%%	海陆掩码考虑边界b_split所需参数
LIM_VAL = 0.5;			%截断值，如果cell domain位于多边形内，低于该值将被标记为 "dry"。
						%低于该值，说明水不够深呀，这么浅的水还是水嘛🤭
OFFSET = 0.125; 		%边界周围的额外缓冲区，设置为检查cell是否越过边界；
						%通常设置为max([dx dy])。

%%	海陆掩码考虑边界b_split
m2 = clean_mask(lon,lat,m1,b_split,LIM_VAL,OFFSET);
%	
figure('NumberTitle','off','Name',strcat(area,'的海陆掩码m1考虑边界b_split后m2的图形展示'),'Color','w');
pcolor(lon,lat,m2);shading flat;caxis([0 3]);colorbar









%%	清除m2中不需要水体的参数
LAKE_TOL = 100;		%决定对应于某一特定水体的所有wet单元是否应该被标记为 dry的Tolerance value。
					%如果LAKE_TOL > 0，所有水体的wet单元总数小于这个值，将被标记为 dry。
					%如果LAKE_TOL = 0，输出和输入掩码不变。
					%如果LAKE_TOL < 0，除了最大的水体外，其他水体都被标记为 dry。
IS_GLOBAL = 0;		%全球网格的标志设置为1，否则为0。决定单元格是否环绕经度。

%%	清除m2中不需要的水体
[m4,mask_map] = remove_lake(m2,LAKE_TOL,IS_GLOBAL);
					%m4是修改后的海陆掩码；
					%mask_map是为不同水体提供唯一ID的二维数组；
%	清除m2不需要水体的海陆掩码m4的图形展示
figure('NumberTitle','off','Name',strcat(area,'清除m2不需要水体的海陆掩码m4的图形展示'),'Color','w');
pcolor(lon,lat,m4);shading flat;caxis([0 3]);colorbar
%	海陆掩码m2不同水体的图形展示
figure('NumberTitle','off','Name',strcat(area,'海陆掩码m2不同水体的图形展示'),'Color','w');
pcolor(lon,lat,mask_map);shading flat;caxis([-1 6]);colorbar



%%	生成障碍物网格的参数
OBSTR_OFFSET = 1;		%OBSTR_OFFSET是决定是否应该考虑邻近（1）或不考虑（0）的标志，需要两次：
						%一次用于左/下邻居，一次用于右/上邻居。
						
%%	生成障碍物网格
[sx1,sy1] = create_obstr(lon,lat,b,m4,OBSTR_OFFSET,OBSTR_OFFSET);
%	障碍物网格图形展示
sx1(find(m4==0))=NaN;
sy1(find(m4==0))=NaN;
figure('NumberTitle','off','Name',strcat(area,'障碍物网格sx1的图形展示'),'Color','w');
pcolor(lon,lat,sx1);shading flat;caxis([0 1]); colorbar
figure('NumberTitle','off','Name',strcat(area,'障碍物网格sy1的图形展示'),'Color','w');
pcolor(lon,lat,sy1);shading flat;caxis([0 1]); colorbar



fname='ZA-7M';				%输出文件名称
depth_scale = 1000;			%水深的缩放因子
obstr_scale = 100;			%障碍物的缩放因子
d = round((depth)*depth_scale);
write_ww3file([data_dir,'/',fname,'.bot'],d);				%水深数据
write_ww3file([data_dir,'/',fname,'.mask_nobound'],m4);		%陆海掩码网格
d1 = round((sx1)*obstr_scale);								%障碍物网格sx1
d2 = round((sy1)*obstr_scale);								%障碍物网格sy1
write_ww3obstr([data_dir,'/',fname,'.obst'],d1,d2);         %障碍物网格，两个合在一起


write_ww3meta ([data_dir,'/',fname],[nml_dir,'/gridgen.',fname,'.nml'],'RECT',lon,lat,1/depth_scale,1/obstr_scale,1.0);
