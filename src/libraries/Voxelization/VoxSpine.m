function [u,fu,vu]=VoxSpine(Spine,Resolucion,PhysicalO,PhysicalL)

Paso=0.5;
Borde=Paso/2;
   
PhysicalOX=PhysicalO(1);
PhysicalOY=PhysicalO(2);
PhysicalOZ=PhysicalO(3);

PhysicalLX=PhysicalL(1);
PhysicalLY=PhysicalL(2);
PhysicalLZ=PhysicalL(3);
Stack=Resolucion(3);
VoxelVol=(PhysicalLX/1024)*(PhysicalLY/1024)*(PhysicalLZ/Stack);
    
 
    Points3d=Spine.vertices;
    %Paso los vertices a coordenadas de "pixeles". Primero se situa la malla en el origen de la imagen. A continuación se multiplica por el número de pixeles y se divide por la longitud de la imagen.
    Points3d(:,1)=(Points3d(:,1)-PhysicalOX)*Resolucion(1)*(1/PhysicalLX);
    Points3d(:,2)=(Points3d(:,2)-PhysicalOY)*Resolucion(2)*(1/PhysicalLY);
    Points3d(:,3)=(Points3d(:,3)-PhysicalOZ)*Stack*(1/PhysicalLZ);
    
    %Calculo y aproximo los valores de la Bounding Box
    A=[floor(min(Points3d(:,1))) ceil(max(Points3d(:,1)))];
    B=[floor(min(Points3d(:,2))) ceil(max(Points3d(:,2)))];
    C=[floor(min(Points3d(:,3))) ceil(max(Points3d(:,3)))];
    A=A+[-1 1];
    B=B+[-1 1];
    C=C+[-1 1];
   %Grillas en valores fisicos
    
	%Se genera un Grid en el que voxelizar la malla. Si se disminuye el valor de paso se obtiene una voxelizacion mas fina.
	
     GridX=A(1)+Borde:Paso:A(2)-Borde;
     %GridX=A(1)+Borde:Paso:A(2)+Borde;
     %GridX=(GridX*PhysicalLX/Resolucion(1))+PhysicalOX;
    
    GridY=B(1)+Borde:Paso:B(2)-Borde;
    %GridY=B(1)+Borde:Paso:B(2)+Borde;
    %GridY=(GridY*PhysicalLY/Resolucion(2))+PhysicalOY;

    GridZ=C(1)+Borde:Paso:C(2)-Borde;
    
    %GridZ=C(1)+Borde:Paso:C(2)+Borde;
    %GridZ=(GridZ*PhysicalLZ/Resolucion(3))+PhysicalOZ;
    
    Spine1.vertices=Points3d;
    Spine1.faces=Spine.faces;
    u=VOXELISE(GridX,GridY,GridZ,Spine1);
    
    %El resultado esta rotado --> Lo vuelvo a su posicion para que sea
    %comparable con el mesh original
    [a,b,c]=size(u);
    u=double(u);
    mask=[];
    for i=1:c
        mask(:,:,i)=flipud(rot90(u(:,:,i)));
    end
    clear u;
    u=mask;
 
      
     [fu,vu]=isosurface(u,0.5);
     
    vu=vu-0.5;
    vu=vu*Paso;
%     vuf(:,1)=vu(:,1)+A(1);
%     vuf(:,2)=vu(:,2)+B(1);
%     vuf(:,3)=vu(:,3)+C(1);
%     
%     figure(2)
%     patch('Vertices', vuf, 'Faces',fu,'FaceColor','green','facealpha',0.1);
%     hold on
%     patch('Vertices', Points3d, 'Faces',Spine.faces,'FaceColor','blue','facealpha',0.1);
  
  
     
     