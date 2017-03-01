% Spine grows until it is attached with the dendrite defined by the
% insertion point
%
% Spine grows until it is attached with the dendrite defined by the
% insertion point
%
% @author Luengo-Sanchez, S.
%
% @param root_spines_repaired_path path to the root folder where folders of each
% dendrite containing the spines after the reparation of the fragmentation
% @param root_insertion_points_path path to the folder where the VRMLs of the 
% insertion points are placed 
% @param root_spines_neck_repaired_path path to the folder where the spines
% with the repaired neck should be saved
%
% @examples
% See Main.m
function repair_neck(root_spines_repaired_path, root_insertion_points_path, root_spines_neck_repaired_path)
    %List dendrites and generated folders if it is needed
    listDendrites = dir(root_spines_repaired_path);
    for i = 3:length(listDendrites)
        newFolder = [root_spines_neck_repaired_path filesep listDendrites(i).name];
        if(exist(newFolder,'dir') ~= 7)
            mkdir(newFolder);
        end
    end
    
    %For each spine repair the neck if it is needed
	for i = 1:(size(listDendrites,1) - 2)
        dendriteName = listDendrites(i + 2).name; %Get dendrite
        listSpines = dir([root_spines_repaired_path '\' dendriteName]); %List all the spines of the dendrite
        insertion_points=read_insertion_points([root_insertion_points_path '\' dendriteName '.vrml']); %Read the insertion points of the dendrite
		
        %For each spine in the dendrite
        for j = 1:(size(listSpines, 1) - 2)
				spineName = listSpines(j + 2).name;
				spinePath = [root_spines_repaired_path '\' dendriteName '\' spineName];
				[path, name, ext] = fileparts(spinePath);
				if strcmp(ext, '.mat')
					data = load(spinePath);
                    ip=insertion_points{j};
                    
                    %Search and sort closest points to the insertion point
                    [~,D]=knnsearch(ip,data.shifted_spine.vertices); 
                    [~,idx]=sort(D);

                    %Once the spine is voxelized, it denotes the number of
                    %rows in Z that must be used to reconstruct the neck
                    levelsup=3; 

                    %Assume that the insertion point is in the X=0,Y=0 and Z=0, translate the spine 
                    spine2origin=bsxfun(@minus,data.shifted_spine.vertices,ip);

                    %Compute the vector from the closest point to the insertion point (origin)
                    %Then rotate the spine according to this vector so closest point is in the Z axis. 
                    growth_vector=spine2origin(idx(1),:);
                    growth_vector_norm = growth_vector / norm(growth_vector);
                    u = cross(growth_vector_norm,[0 0 1]);
                    u = u / norm(u);
                    theta = acos(dot(growth_vector_norm, [0 0 1])); 
                    rotationMatrix=rotateMatrix(u,theta); 
        
                    rotated_spine=(rotationMatrix*spine2origin')';
      
                    %Save spine after rotation
                    turned_spine.vertices=rotated_spine;
                    turned_spine.faces=data.shifted_spine.faces;

                    %If the insertion point is far from the spine repair
                    %neck growing according to a gaussian filter.If it is 
                    %not proyect the insertion point to the closest vertex 
                    %of the spine
                    if(turned_spine.vertices(idx(1),3)>0.15)
                        %Voxelize the spine
                        A = [floor(min(rotated_spine(:,1))) ceil(max(rotated_spine(:,1)))];
                        B = [floor(min(rotated_spine(:,2))) ceil(max(rotated_spine(:,2)))];
                        C = [0 ceil(max(rotated_spine(:,3)))];

                        step = 0.05;
                        GridX = (A(1)):step:(A(2));
                        GridY = (B(1)):step:(B(2));
                        GridZ = (C(1)):step:(C(2));
                        vox_dendrite = VOXELISE(GridX, GridY, GridZ, turned_spine);

                        %Get closest point to the insertion point once the spine is voxelize
                        [x,y,z]=ind2sub(size(vox_dendrite),min(find(vox_dendrite)));
                        vox_dendrite=double(vox_dendrite);

                        %Get the number of voxels of the spine in the plane perpendicular to the Z axis
                        mask=double(vox_dendrite(:,:,z+levelsup));
                        [x,y]=ind2sub(size(mask),find(mask));

                        %Generate gaussian filter
                        init_X=max(x);
                        init_Y=max(y);
                        filter_size=max([max(x)-min(x) max(y)-min(y)])+2;
                        h=fspecial('gaussian',[filter_size filter_size],filter_size);
                        h=h.*(1./max(max(h)));
                        
                        %For each row in Z between the spine and the
                        %insertion point fill with the result obtained
                        %by the gaussian filter
                        for p=fliplr(2:z+levelsup)
                            vox_dendrite(:,:,p)=mask;
                            mask((init_X-filter_size+1):init_X,(init_Y-filter_size+1):init_Y)=mask((init_X-filter_size+1):init_X,(init_Y-filter_size+1):init_Y).*h;
                        end

                        %Recover mesh from the voxelized representation
                        [X,Y,Z]=meshgrid(GridY,GridX,GridZ);
                        fv=isosurface(Y,X,Z,vox_dendrite,0.5);

                        %Smooth results
                        repaired_spine=smoothpatch(fv,1,3);
                    else %If insertion point is close to the spine just copy
                        repaired_spine=turned_spine;
                    end
                    
                        [~,idx]=min(repaired_spine.vertices(:,3));
                        insertion_point_idx=idx;
                        path_2_save=char([root_spines_neck_repaired_path '/' dendriteName '/' name ext]);
                        Spine=data.Spine;
                        shifted_spine=data.shifted_spine
                        save(path_2_save, 'Spine', 'shifted_spine', 'repaired_spine', 'insertion_point_idx');
                end
        end	
    end  
end