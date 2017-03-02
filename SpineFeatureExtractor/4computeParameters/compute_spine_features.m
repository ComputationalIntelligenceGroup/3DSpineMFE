function [instance_row] = compute_spine_features(repaired_spine,insertion_point_idx,curve)
%COMPUTE_SPINE_FEATURES Computes the features of the spine. Because of the
%spine orientation dependency of some of the features, reorientation
%operations are performed to make the spine look to the top and to the
%right.
%
%   [instance_row] = compute_spine_features(repaired_spine,
%   insertion_point_idx, curve)
%
%   Input parameters:
%       - repaired_spine struct : Spine with repaired neck.
%       - insertion_point_idx integer : X coordinate in the
%           repaired_spine.vertices matrix that corresponds to the spine
%           insertion point.
%       - curve cell-array : Level curves of the spine.
%
%   Output parameters:
%       - instance_row [1xN] array : The row containing computed spine
%           features.
%
%   Computed features (some of them, like height, or ellipse axes produce
%   many features):
%       - Height.
%       - Major axis of ellipse.
%       - Minor axis of ellipse.
%       - Radio between sections.
%       - Growing direction of the spine.
%       - Instant direction.
%       - Volume.
%       - Volume of each region.
%
%Author: Luengo-Sanchez, S.
%
%See also CHECK_ORIENTATION

    %Spine is translated to place the insertion point as the origin
    insertion_point = repaired_spine.vertices(insertion_point_idx,:);
    repaired_spine.vertices=bsxfun(@minus,repaired_spine.vertices,insertion_point);
    for i=1:size(curve,2)
        curve{i}=bsxfun(@minus,curve{i},insertion_point);
    end
         
    insertion_point=check_orientation(repaired_spine,curve);
    if(sum(insertion_point)~=0)
        repaired_spine.vertices=bsxfun(@minus,repaired_spine.vertices,insertion_point);
        for i=1:size(curve,2)
            curve{i}=bsxfun(@minus,curve{i},insertion_point);
        end
        insertion_point=[0 0 0]; 
    end
    
   %Compute the parameters of the curve, i.e., centroids, semiaxes, angle
   %of the curve, perpendicular vector to the curve and coefficients for
   %the z axis.
   perp_vectors_sph=zeros(length(curve)-2,2);   %Perpendicular vector to curve in spherical coords.
   ellipse_angles=zeros(length(curve)-2,1);     %Angle of the elipse in the XY plane.     
   major_axis=zeros(length(curve)-2,1);       %Relation between semiaxes.
   curve_centroids=zeros(length(curve),3);      %Centroids of the curves.
   perp_PCA_matrix=zeros(length(curve)-2,3);    %Perpendicular vector to curve in cartesian coords.
   ellipse_angles_vectors=zeros(length(curve)-2,3); %Vector representation of the angle of the ellipse.
   minor_axis=zeros(length(curve)-2,1);           %One of the minor_axis of the ellipse.
    
     
   %Compute parameters of each curve.
   for i=2:(length(curve)-1)
        PCA=princomp(curve{i});
        perp_PCA_matrix(i-1,:)=PCA(:,3);
        if(isequal(perp_PCA_matrix(i-1,:),[0 0 1]))
            rotated_curve=curve{i};
            [center,semiaxes,angle]=EllipseDirectFit([rotated_curve(:,1),rotated_curve(:,2)]);
            ellipse_angles_vectors(i-1,:)=[cos(angle) sin(angle) 0];
            curve_centroids(i,:)=[center mean(rotated_curve(:,3))];
        else           
        u = cross(perp_PCA_matrix(i-1,:),[0 0 1]);
        u = u / norm(u);
        theta = acos(dot(perp_PCA_matrix(i-1,:), [0 0 1])); 
        rotationMatrix=rotateMatrix(u,theta); 
        
        rotated_curve=(rotationMatrix*curve{i}')';
        
        %Check that the ellipse is over the XY plane. It is necesary to
        %rotate always in the same direction, if we dont take care spine
        %would be rotated the other way around in some cases.
        if(mean(rotated_curve(:,3))<0) 
            perp_PCA_matrix(i-1,:)=-perp_PCA_matrix(i-1,:);
            
            u = cross(perp_PCA_matrix(i-1,:),[0 0 1]);
            u = u / norm(u);
            theta = acos(dot(perp_PCA_matrix(i-1,:), [0 0 1])); 
            rotationMatrix=rotateMatrix(u,theta); 
        
            rotated_curve=(rotationMatrix*curve{i}')';
        end
       
        [center,semiaxes,angle]=EllipseDirectFit([rotated_curve(:,1),rotated_curve(:,2)]);

        ellipse_angles_vectors(i-1,:)=rotationMatrix'*[cos(angle) sin(angle) 0]';
        curve_centroids(i,:)=rotationMatrix'*[center mean(rotated_curve(:,3))]';
        end
        major_axis(i-1)=max(semiaxes);
        minor_axis(i-1)=min(semiaxes);
        ellipse_angles(i-1)=angle; 
   end
   
   curve_centroids(end,:)=curve{end}(1,:);

    %Rotate the spine to align the vector between de inserction point and
    %the centroid of the first curve with the Z axis. Also, rotate the
    %curves and the centroids.
    %u=rotation axis, theta=rotation angle
    unit_vector=curve_centroids(2,:)/norm(curve_centroids(2,:));
    u = cross(unit_vector,[0 0 1]);
    u = u / norm(u);
    theta = acos(dot(unit_vector, [0 0 1])); 
 
   rotationMatrix=rotateMatrix(u,theta);
   repaired_spine.vertices=(rotationMatrix*repaired_spine.vertices')';
   
   
   for i=1:size(curve,2)
        curve{i}=(rotationMatrix*curve{i}')';
   end
   curve_centroids=(rotationMatrix*curve_centroids')';
   
    perp_PCA_matrix=(rotationMatrix*perp_PCA_matrix')';
   ellipse_angles_vectors=(rotationMatrix*ellipse_angles_vectors')';
   
    %Rotate the spine to place the farest point of the spine parallel to the
   %X axis. It is rotated around the Z axis.
      unit_vector=[curve{end}(1) curve{end}(2) 0]/norm([curve{end}(1) curve{end}(2) 0]);
      
      u = cross(unit_vector,[1 0 0]);
      u = u / norm(u);
      theta=acos(dot(unit_vector,[1 0 0]));
      
      rotationZ=rotateMatrix(u,theta);
    
    repaired_spine.vertices=(rotationZ*repaired_spine.vertices')';
    
    for i=1:size(curve,2)
         curve{i}=(rotationZ*curve{i}')';
    end
    curve_centroids=(rotationZ*curve_centroids')';
    perp_PCA_matrix=(rotationZ*perp_PCA_matrix')';
    ellipse_angles_vectors=(rotationZ*ellipse_angles_vectors')';
    
    for i=1:size(perp_PCA_matrix,1)
        u = cross(perp_PCA_matrix(i,:),[0 0 1]);
        u = u / norm(u);
        theta = acos(dot(perp_PCA_matrix(i,:), [0 0 1])); 
        rotationMatrix=rotateMatrix(u,theta);
        rotated_angle_matrix=(rotationMatrix*ellipse_angles_vectors(i,:)')';
        ellipse_angles(i)=cart2pol(rotated_angle_matrix(1),rotated_angle_matrix(2));
    end  
    
   [perp_vectors_sph(:,1),perp_vectors_sph(:,2)]=cart2sph(perp_PCA_matrix(:,1),perp_PCA_matrix(:,2),perp_PCA_matrix(:,3));
  
   %Compute the parameters needed to build the skeleton of the spine.
   %|h|, elevation, theta, alpha 
   vector_length=zeros(size(curve_centroids,1)-1,1);
   elevation=zeros(size(curve_centroids,1)-2,1);
   cos_phi=zeros(size(curve_centroids,1)-2,1);
   
   for i=1:(size(curve_centroids,1)-1)
        section_vector=curve_centroids(i+1,:)-curve_centroids(i,:);
        vector_length(i)=norm(section_vector);
   end 
   
   for i=2:(size(curve_centroids,1)-1)
        translation=bsxfun(@minus,curve_centroids((i-1):(i+1),:),curve_centroids(i,:));
        translation(1,:)=translation(1,:)./vector_length(i-1);
        translation(3,:)=translation(3,:)./vector_length(i);
        
        u = cross(translation(1,:),[1 0 0]);
        u = u / norm(u);
        theta = acos(dot(translation(1,:), [1 0 0])); 
        rotationMatrix=rotateMatrix(u,theta); 
        
        transRotated=(rotationMatrix*translation')';
        cos_phi(i-1)=dot(transRotated(1,:),transRotated(3,:));
        xyPosition=[cos_phi(i-1) sqrt(1-cos_phi(i-1)^2) 0];
        
        r=xyPosition(2:3)/norm(xyPosition(2:3));
        s=transRotated(3,2:3)/norm(transRotated(3,2:3));
        elevation(i-1)=atan2(s(2),dot(r,s));
   end 
    
    ellipse_area=pi*minor_axis.*major_axis;%Compute the area of the ellipses
    
    %Compute how many times is ellipse j bigger or smaller than ellipse i.
    %Results are saved in the lower triangular matrix
    proportional_areas=tril(ellipse_area*(1./ellipse_area)');
    proportional_areas=proportional_areas.*(ones(length(ellipse_area))-eye(length(ellipse_area)));
    ratio_sections=proportional_areas(find(proportional_areas~=0));
    
    volume=meshVolume(repaired_spine.vertices,repaired_spine.faces);
    surface=meshSurfaceArea(repaired_spine.vertices,repaired_spine.faces);
    volume_section=zeros(size(curve,2)-1,1);
    surface_section=zeros(size(curve,2)-1,1);
    ellipse_area=[0;ellipse_area; 0];
    for(i=2:size(curve,2))
        cv_vertex=[curve{i};curve{i-1}];
        [cv_faces,volume_section(i-1)]=convhull(cv_vertex);
        cv_edges = meshEdges(cv_faces);
        surface_section(i-1)=meshSurfaceArea(cv_vertex,cv_edges,cv_faces)-ellipse_area(i-1)-ellipse_area(i);
    end
    instance_row=(vertcat(vector_length,elevation,cos_phi,minor_axis,major_axis,ratio_sections,perp_vectors_sph(:,1),perp_vectors_sph(:,2),volume,volume_section,surface,surface_section))';
end