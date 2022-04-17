# wjc 老师创建的文件：myrecomand （已删除）
gfortran -c -g -C -o3 mod_params.f90
gfortran -c -g -C -o3 mod_date.f90 
gfortran -c -g -C -o3 mod_namelist.f90
gfortran -c -g -C -o3 mod_matrix_read.f90
gfortran -c -g -C -o3 mod_matrix_write.f90 
gfortran -c -g -C -o3 mod_matrix_inverse.f90
gfortran -c -g -C -o3 mod_matrix_H.f90
gfortran -c -g -C -o3 mod_matrix_R.f90
gfortran -c -g -C -o3 mod_matrix_W.f90
gfortran -c -g -C -o3 mod_analysis.f90
gfortran -c -g -C -o3 DA_cycle.f90

gfortran -o da.exe DA_cycle.f90
 
# wjc 老师创建的文件：wjc_analysis （未删除，需借鉴思路）

# 同化公式-->模块功能-->数据维度
```
!!!!!------------------------------------------------!!!!!

!!!!! Xa=Xb+P*H'(H*P*H'+R)^(-1)*(yo-H*Xb)------------!!!!!

!!!!! because: P=A*A'/(N-1),(where: A=enxemble-mean)-!!!!!

!!!!!-----so, in this program,is the following-------!!!!!

!!!!!------------------------------------------------!!!!!

!!!!! Xa=Xb+A(HA)'*[HA*(HA)'+(N-1)R]^(-1)*(yo-H*Xb)--!!!!!

!!!!! Xa=Xb+AHAT*(HA*HAT+(N-1)R)^(-1)*(yo-HXb)-------!!!!!

!!!!! Xa=Xb+W*(yo-HXb)=Xb+dX-------------------------!!!!!

!!!!!------------------------------------------------!!!!!

compute: A                        -----mod_matrix_A.f90

compute: H,HA,HAT,AHAT            -----mod_matrix_H.f90

compute: R                        -----mod_matrix_R.f90

compute: W=AHAT*(HA*HAT+R)^(-1)   -----mod_matrix_W.f90

compute: HXb=H*Xb,
         yo=yo-HXb,
         dX=W*yo,
         Xa=Xb+dX                 -----mod_analysis.f90 


N---number of state varible
NN---ensemble size
M---number of observation

Xa:  N*1
Xb:  N*1
yo:  M*1
R:   M*M
H:   M*N
A:   N*NN
HA:  M*NN
HAT: NN*M
AHAT:N*M
HXb: M*1
W:   N*M
dX:  N*1

```
nice~

# 




