clear
close all
clc

%% HCW equations

MU=0.3986e15;                     
RE=6.38e6;
a=RE+400e3;
w=sqrt(MU/a^3);

A = [
    0	    0	0	    1	    0	0
    0	    0	0	    0	    1	0
    0	    0	0	    0	    0	1
    3*w^2	0	0	    0	    2*w	0
    0	    0	0	    -2*w	0	0
    0	    0	-w^2	0	    0	0
];

% eig(A)

B=[zeros(3);eye(3)];

LTI_system = ss(A,B,eye(6),zeros(6,3)); % init

%% NMPC design

par.model=@pred_model;
par.nlc=@nlcon;
par.n=6;
par.Ts=3;
par.Tp=100;
par.Q=0.1*eye(6);
par.P=10*eye(6);
par.R=1*eye(3);
par.lb=-1*ones(3,1);
par.ub=1*ones(3,1);

K=nmpc_design_st(par);

%% Simulation initialization

% % Reference
r=[5 0 0 0 0 0]';
x0=[-500 0 0 0 0 0]';

tfin=1000;

sim('sim_hcw_nmpc.slx')

%% Simulation and 3D figure

close all
fs=18;

tfin=2000;

for i=1:5
    
    clear Y

    if i==1
        x0=[-500 0 0 0 0 0]';

        figure('color','w')
        axis equal
        grid, hold on
        plot(0,0,'dk','markersize',8)
        circle(0,0,10,'b',1) 

        xlabel('$x_1$ [m]','interpreter','latex','fontsize',fs)
        ylabel('$x_2$ [m]','interpreter','latex','fontsize',fs)
        ylim([-400 400])
    else
        x0=[500*randn(); 5*randn(5,1)]
    end
    
    sim('sim_hcw_nmpc.slx')

    hold on, plot(Y.Data(:,1),Y.Data(:,2),'linewidth',1.2)

end

%% Plot for command effort

figure('position',[50 100 500 400],'color','w')
subplot(2,1,1)  
grid, box on, hold on
plot(Y.Time,Y.Data,'linewidth',1.2)
ylabel('position [m]','interpreter','latex','fontsize',fs)
le=legend('x_1','x_2','x_3');
set(le,'fontsize',fs-4)
subplot(2,1,2)
grid, box on, hold on
plot(U.Time,U.Data,'linewidth',1.2)
xlabel('time [s]','interpreter','latex','fontsize',fs)
ylabel('$u$ [m/s$^2$]','interpreter','latex','fontsize',fs)
