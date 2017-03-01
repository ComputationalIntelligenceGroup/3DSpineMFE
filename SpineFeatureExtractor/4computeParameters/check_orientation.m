function [insertion_point] = check_orientation(repaired_spine, curve)
   curve_centroids=zeros(1,3); 
                     
   %Compute parameters of each curve.
   PCA=princomp(curve{2});
   perp_PCA_matrix=PCA(:,3)';

   if(isequal(perp_PCA_matrix,[0 0 1]))
       rotated_curve=curve{2}(:,1:2);
   else
       u = cross(perp_PCA_matrix,[0 0 1]);
       u = u / norm(u);
       theta = acos(dot(perp_PCA_matrix, [0 0 1])); 
       rotationMatrix=rotateMatrix(u,theta); 
        
       rotated_curve=(rotationMatrix*curve{2}')';
       
       %Check if the elipse is over the XY plane. It is needed to avoid
       %rotation in the wrong direction
       if(mean(rotated_curve(:,3))<0) 
           perp_PCA_matrix=-perp_PCA_matrix;
            
           u = cross(perp_PCA_matrix,[0 0 1]);
           u = u / norm(u);
           theta = acos(dot(perp_PCA_matrix, [0 0 1])); 
           rotationMatrix=rotateMatrix(u,theta); 
        
           rotated_curve=(rotationMatrix*curve{2}')';
       end
        
    [center,semiaxes,angle]=EllipseDirectFit([rotated_curve(:,1),rotated_curve(:,2)]);
    curve_centroids=rotationMatrix'*[center mean(rotated_curve(:,3))]';        
    end
  
    %Rotate the spine to align the vector between de insertion point and
    %the centroid of the first curve with the Z axis. Also, rotate the
    %curves and the centroids.
    %u=rotation axis, theta=rotation angle
    unit_vector=curve_centroids/norm(curve_centroids);
    u = cross(unit_vector,[0 0 1]);
    u = u / norm(u);
    theta = acos(dot(unit_vector, [0 0 1])); 
 
   rotationMatrix=rotateMatrix(u,theta);
   
   farest_point_rotation=(rotationMatrix*curve{end}');
   
   if(farest_point_rotation(3) < 0);
    insertion_point=2*curve_centroids';
   else
       insertion_point=[0 0 0];
   end
   end
 