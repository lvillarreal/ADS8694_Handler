% TESTING DATA_CONVERT
% EXITACION SENIAL ADC
close all, clear all, clc

fileID = fopen('Prueba11_VertimientoAgua1.bin');
x1 = fread(fileID,'single','b');
fclose(fileID);

Fs = 20000;
N = length(x1);
n = (0:1:N-1);
t = n/Fs;
x = round((x1/10.24+1)*2^17); 

%x(:) = 131000;
%x(1:10) = 0;

data(:,1) = t';
data(:,2) = x1;


fileID = fopen('data.bin','w');
format long

for i=1:N
   
       fwrite(fileID,x(i),'int'); 
      %fprintf(fileID,'%d\n',x(i));
%     fprintf(fileID,'filter_in <= std_logic_vector(to_signed(%d,19));\n',(x(i)));
%     fprintf(fileID,'wait for clk_period;\n');
%     %fprintf(fileID,'write(l,to_integer(signed(filter_out)));\n');
% 	fprintf(fileID,'write(f,to_integer(signed(filter_out)));\n\n');
    %fprintf(fileID,'writeline(f,l);\n\n');
end 
fclose(fileID);

figure
plot(t,x)

%% RESULTADO SIMULACION
clc, clear all, close all

Fs = 20000;
fileID = fopen('resul_iir.bin');
x1 = fread(fileID,'long','n');
fclose(fileID);

x1(1:2) = x1(3);

x1 = x1*2^-14;

n1 =  (0:1:length(x1)-1);
t1 =  n1/Fs;

fileID = fopen('data.bin');
x2 = fread(fileID,'int','n');
fclose(fileID);

x2(1:2) = x2(3);


n2 =  (0:1:length(x2)-1);
t2 =  n2/Fs;

% fileID = fopen('data_readed.bin');
% x3 = fread(fileID,'int','n');
% fclose(fileID);
% 
% x3(1:2) = x3(3);
% 


x3 = abs((x2*2^-17-1)*10.24-x1);
n3 =  (0:1:length(x3)-1);
t3 =  n3/Fs;
figure
plot(t1,x1)
hold on
%plot(t2,x2)
title 'Dato convertido'

figure
plot(t2,x2)
title ' Dato de entrada'

figure
plot(t3,x3)
title 'dato convertido'

data(:,1) = t1';
data(:,2) = x1;
%%
x = 0;
for i=-14:3
    x = x + 2^i;
end
