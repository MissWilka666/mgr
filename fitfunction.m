function fitfunction()
load('std_vector.mat','std_vector');
load('mean_vector.mat','mean_vector');
x=mean_vector;
y=std_vector;

fun=@(b,x)b(1)*exp(b(2)*x)+b(3)*exp(b(4)*x)+b(5);
parameters=[0.2,-0.5,-10,-0.001,10];
b_est=lsqcurvefit(fun,parameters,x,y);

x_fit=linspace(min(x),max(x),1000);
y_fit=fun(b_est,x_fit);

figure;
plot(x,y,'*'); 
hold on;
plot(x_fit,y_fit,'r');
xlabel('M'); ylabel('std');
grid on;
hold off;

tableM=zeros(256,2);
for ii=1:256
tableM(ii,1)=ii;
tableM(ii,2)=fun(b_est,ii);
end
save("tableM.mat",'tableM');
end