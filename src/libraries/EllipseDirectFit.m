function [center,semiaxes,angle] = EllipseDirectFit(XY)
%
%  Direct ellipse fit, proposed in article
%    A. W. Fitzgibbon, M. Pilu, R. B. Fisher
%     "Direct Least Squares Fitting of Ellipses"
%     IEEE Trans. PAMI, Vol. 21, pages 476-480 (1999)
%
%  Our code is based on a numerically stable version
%  of this fit published by R. Halir and J. Flusser
%
%     Input:  XY(n,2) is the array of coordinates of n points x(i)=XY(i,1), y(i)=XY(i,2)
%
%     Output: A = [a b c d e f]' is the vector of algebraic 
%             parameters of the fitting ellipse:
%             ax^2 + bxy + cy^2 +dx + ey + f = 0
%             the vector A is normed, so that ||A||=1
%
%  This is a fast non-iterative ellipse fit.
%
%  It returns ellipses only, even if points are
%  better approximated by a hyperbola.
%  It is somewhat biased toward smaller ellipses.
%
centroid = mean(XY);   % the centroid of the data set

D1 = [(XY(:,1)-centroid(1)).^2, (XY(:,1)-centroid(1)).*(XY(:,2)-centroid(2)),...
      (XY(:,2)-centroid(2)).^2];
D2 = [XY(:,1)-centroid(1), XY(:,2)-centroid(2), ones(size(XY,1),1)];
S1 = D1'*D1;
S2 = D1'*D2;
S3 = D2'*D2;
T = -inv(S3)*S2';
M = S1 + S2*T;
M = [M(3,:)./2; -M(2,:); M(1,:)./2];
[evec,eval] = eig(M);
cond = 4*evec(1,:).*evec(3,:)-evec(2,:).^2;
A1 = evec(:,find(cond>0));
A = [A1; T*A1];
A4 = A(4)-2*A(1)*centroid(1)-A(2)*centroid(2);
A5 = A(5)-2*A(3)*centroid(2)-A(2)*centroid(1);
A6 = A(6)+A(1)*centroid(1)^2+A(3)*centroid(2)^2+...
     A(2)*centroid(1)*centroid(2)-A(4)*centroid(1)-A(5)*centroid(2);
A(4) = A4;  A(5) = A5;  A(6) = A6;
% a = A/norm(A);
A=A/norm(A);
% 
% a=A(1); b=A(2); c=A(3); d=A(4); f=A(5); g=A(6); %To see how to compute parameters see http://mathworld.wolfram.com/Ellipse.html
% 
% center=zeros(2,1);
% center(1)=(c*d-b*f)/(b^2-a*c);
% center(2)=(a*f-b*d)/(b^2-a*c);
% 
% semiaxes=zeros(2,1);
% semiaxes(1)=sqrt((2*(a*f^2+c*d^2+g*b^2-2*b*d*f-a*c*g))/((b^2-a*c)*(sqrt((a-c)^2+4*b^2)-(a+c))))
% semiaxes(2)=sqrt((2*(a*f^2+c*d^2+g*b^2-2*b*d*f-a*c*g))/((b^2-a*c)*(-(sqrt((a-c)^2+4*b^2)-(a+c)))))

%     A=[2*a(1), a(2); a(2), 2*a(3)];
%     b=[-a(4) -a(5)];
%     soln=inv(A)*b';
%   
%     b2=a(2)^2 /4;
%     center=[soln(1) soln(2)];
%     
%     num=  2 * (a(1) * a(5)^2 / 4 + a(3) * a(4)^2 / 4 + a(6) * b2 - a(2)*a(4)*a(5)/4 - a(1)*a(3)*a(6));
%     den1=(b2-a(1)*a(3));
%     den2=sqrt((a(1)-a(3))^2 + 4*b2);
%     den3=a(1)+a(3);
%     
%     semiaxes= sqrt([num/(den1*(den2-den3)), num/ (den1 * (-den2 -den3))]);
%     minorAxis=min(semiaxes);
%     [majorAxis,idx]=max(semiaxes);
%     semiaxes(1)=majorAxis;
%     semiaxes(2)=minorAxis;
%     
% %     term =(a(1)-a(3))/a(2);
% %     angle=atan(1/term)/2;
%     angle=atan((a(1)-a(3))/a(2))/2;
    
%          angle=angle+pi/2;
     
        params=AtoG(A);
        center=[params(1) params(2)];
        semiaxes=[params(3) params(4)];
        angle=params(5);
    

end  %  EllipseDirectFit


