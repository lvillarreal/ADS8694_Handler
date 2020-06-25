clc, clear all, close all
fileID = fopen('data.bin','w');
N = 2^18;
for i=1:N
   
       fwrite(fileID,i-1,'int'); 

end
fclose(fileID);
fileID = fopen('data.bin');
x1 = fread(fileID,'long','n');
fclose(fileID);
plot(x1)
%%
%% RESULTADO SIMULACION
clc, clear all, close all

fileID = fopen('resul_deconv_data.bin');
x1 = fread(fileID,'long','n');
fclose(fileID);


fileID = fopen('data.bin');
x2 = fread(fileID,'long','n');
fclose(fileID);

fileID = fopen('data_conv_salida.bin');
x5 = fread(fileID,'long','n');
fclose(fileID);

x6 = x5*2^-14;
x3 = round((x6+10.24)*2^17/10.24);

x4 = abs(x2-x1(1:length(x2)));
max(x4)
figure
plot(x4)
figure
plot(x1)
hold on
plot(x2)
plot(x3)
legend('salida deconv','entrada','salida data conv')