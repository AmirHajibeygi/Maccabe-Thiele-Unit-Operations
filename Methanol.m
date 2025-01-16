
%% Investigation and Analysis of Efficiency and Accuracy of McCabe Tilly Method in Bi-Component Distillation 
% Amir Hajibeygi
% June.2024 - Sharif University of Technology
clc
clear
%% 1: Getting Data for Water - Methanol

XD=input('please enter XD: ');  
XB=input('please enter XB: ');
XF=input('please enter ZF: ');
F=input('please enter F: ');
q=input('please enter q: ');
r=input('please enter R/Rmin: ');  % the ratio of R and Rmin  
tic;
X_methanol=[0,0.05,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1]; % the equ Data for Water and Methanol
y_methanol=[0,0.261,0.405,0.571,0.66,0.72,0.772,0.82,0.867,0.912,0.955,1]; % the equ Data for Water and Methanol
%% 2: Calculating B and D
syms B D
eqns = [B+D-F==0,
        B*XB+D*XD-F*XF==0];
S = solve(eqns, B, D);
B = S.B;
D = S.D;
%% 3: Finding All equations that we need to plot mcCabe Tilly Daiagram
% 3-1: first we find that eq_ equation with polyfit
    p = polyfit(X_methanol, y_methanol, 7);
    x_values = linspace(min(X_methanol), max(X_methanol), 100);
    y_fit = polyval(p, x_values);
    y_equation= @(x) p(1)*x^7+p(2)*x^6+p(3)*x^5+p(4)*x^4+p(5)*x^3+p(6)*x^2+p(7)*x+p(8);
% 3-2: find q-line equation
    q_slope=q/(q-1); 
    q_intercept=-XF/(q-1); 
    q_equation= @(x) q_slope*x+q_intercept;
% 3-3: find The Top operating line equation
  % 3-3-1: find The minimum Reflux Ratio
    options = optimset('display','off');
    if q==1 
      x_pinch = XF;
    else 
      x_pinch = fsolve(@(x) q_equation(x)-y_equation(x),XF,options);
    end
    y_pinch=y_equation(x_pinch);
    slope=(XD-y_pinch)/(XD-x_pinch);     %Slope=(Rmin/Rmin+1)
    Rmin=slope/(1-slope);
  % 3-3-2: Calculating Top operating line based on minimum rflux ratio
    R=r*Rmin;
    y_Top= @(x) (R/(R+1))*x+(XD/(R+1));
% 3-4: find The Bottom operating line equation
    y_pin = y_Top(XF);
    slope_Bottom=(XB-y_pin)/(XB-XF);          %%slope bol
    y_Bottom= @(x) slope_Bottom*(x-XB)+XB;
%% 4: Plotting The mcCabe Tilly Daiagram
% 4-1: Plot the 45-line 
    plot([0 1],[0 1],'-k','linewidth',0.2)  
    grid on
    hold on
    plot( x_values, y_fit);
% 4-2: Plot the q-line equation
    hold on
    if q>1 
        fplot(q_equation,[XF 1],'k')
        syms x
        y2=y_Top(x)-q_equation(x)==0;
        s1=vpasolve(y2,x);
        xq=double(s1(1));
    elseif q==1 
        plot([XF XF],[XF 1])
    elseif 0<q && q<1 
        fplot(q_equation,[0 XF],'k')
        y2=y_Bottom(x)-q_equation(x)==0;
        s1=vpasolve(y2,x);
        xq=double(s1(1));
    elseif q==0
        plot([XF 0],[XF XF])
    else
        fplot(q_equation,[0 XF],'k')
    end
% 4-3: plot the The Top and Bottom  operating line equations
    hold on
    fplot(y_Top,[XF XD],'k')
    hold on
    plot([XB,XF],[XB,y_pin])
    title('Fitting a Quadratic Curve to Data');
    legend('45 Line', 'Equ Curve','Feed Line');
    set(gca,'Xlim',[0 1]);
    set(gca,'ylim',[0 1]);

    x_top1=XD;
    y_top1=XD;
    i=0;
    j=0;
    while x_top1>XF
        y_top2=y_top1;
        syms x
        y=y_top2-y_equation(x)==0;
        x_s = vpasolve(y, x);
        x_top2=double(x_s(1));
        x_top3=x_top2;
        y_top3=y_Top(x_top3);
        plot([x_top1 x_top2],[y_top1 y_top2],'r')
        plot([x_top2 x_top3],[y_top2 y_top3],'r')

        if q>1 && xq<x_top1 && xq>x_top2
         A=i;
        end
        x_top1=x_top3;
        y_top1=y_top3;
        i=i+1;
    end

    x_bot1=x_top1;
    y_bot1=y_Bottom(x_top1);
    plot([x_top1 x_bot1],[y_top1 y_bot1],'r')
    while x_bot1>XB || x_bot1==XB
        y_bot2=y_bot1;
        syms x
        y=y_bot2-y_equation(x)==0;
        xs = vpasolve(y, x);
        x_bot2=double(xs(1));
        x_bot3=x_bot2
        y_bot3=y_Bottom(x_bot3);
        plot([x_bot1 x_bot2],[y_bot1 y_bot2],'r')
        plot([x_bot2 x_bot3],[y_bot2 y_bot3],'r')
        if q<1 && q>0 && xq<x_bot1 && xq>x_bot2
            A=j;
        end
        x_bot1=x_bot3;
        y_bot1=y_bot3;
        j=j+1;
    end
%% 5: Display Results
 if q>1
     n=sprintf('The Feed stage location is %sth stage  .',num2str(A+1));
 elseif q<1 && q>0
    n=sprintf('The Feed stage location is %sth stage  .',num2str(i+A+1));
 elseif q==1
    n=sprintf('The Feed stage location is %sth stage  .',num2str(i));
 elseif q==0
    n=sprintf('The Feed stage location is %sth stage  .',num2str(i+1));
 end
disp(n)
disp(['The number of ideal stages = ',num2str(i+j)]);
disp(['The molar rate of top product (kmol/hr) = ',num2str(double(D))]);
disp(['The molar rate of bottom product (kmol/hr)= ',num2str(double(B))]);

 toc





























