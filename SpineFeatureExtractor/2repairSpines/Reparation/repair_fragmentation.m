function repair_fragmentation(spines_partially_fragmented_file, spines_fragmented_file, spines_correct_file, root_spines_repaired_path, root_MAT_path)
%REPAIR_FRAGMENTATION Repairs spines according to the level of
%fragmentation of the spine. For repairing, dilation and erosion is used, 
%depending the level of fragmentation, the size of the dilation mask
%changes.
%
%   REPAIR_FRAGMENTATION(spines_partially_fragmented_file,
%   spines_fragmented_file, spines_correct_file, root_spines_repaired_path,
%   root_MAT_path) Given three files with spine paths (divided into
%   partially fragmented, fragmented, and correct), correct ones are copied
%   directly to repaired spines folder (root_spines_repaired_path), and
%   partially fragmented and fragmented are repaired and then copied to
%   repaired spines folder. root_MAT_path is used to create path tree for
%   repaired spines.
%
%Author: Luengo-Sanchez, S.

	%Create path tree for repaired spines
	tree_MAT = dir(root_MAT_path);
	for i = 3:length(tree_MAT)
        newFolder = [root_spines_repaired_path filesep tree_MAT(i).name];
        if(exist(newFolder,'dir') ~= 7)
            mkdir(newFolder);
        end
    end
    
    %%%%%%%%%%%%%%Spines that are correct%%%%%%%%%%%%%
	fid = fopen(spines_correct_file);
	% Get file size.
	fseek(fid, 0, 'eof');
	file_size = ftell(fid);
	frewind(fid);
	
    % Read whole file.
	data = fread(fid, file_size, 'uint8');
	
    % Count number of line-feeds and increase by one.
	num_lines = sum(data == 10);
	fclose(fid);
    
    %Read and save the names of the spines that are not fragmented
    fid = fopen(spines_correct_file, 'rt');
    for i = 1:num_lines
        spine_names{i} = fgetl(fid);
    end
    fclose(fid);
    
    %Copy the correct spines to the repaired folder
    parfor i = 1:num_lines
        data = load(spine_names{i});
         
        [original_path, name, ext] = fileparts(spine_names{i});
		sep_ind = findstr(original_path, filesep);
		n_sep = length(sep_ind);
		deepest_folder = original_path(sep_ind(n_sep):length(original_path));
        
        parsave([root_spines_repaired_path deepest_folder filesep name ext], data.Spine, data.Spine, data.physical_length, data.physical_origin, data.resolution);		
    end
	
	%%%%%%%%%%%%%%Spines partially fragmented repairment%%%%%%%%%%%%%
	fid = fopen(spines_partially_fragmented_file);
	
    % Get file size.
	fseek(fid, 0, 'eof');
	file_size = ftell(fid);
	frewind(fid);
	
    % Read whole file.
	data = fread(fid, file_size, 'uint8');
	
    % Count number of line-feeds and increase by one.
	num_lines = sum(data == 10);
	fclose(fid);
	
    %To repair the spine it is voxelize and dilated until all its fragments
    %are a unique piece. After that spine is smoothed.
  
    %To be able to dilate spine without achieve the bounds of the space, space where spine is placed is increased.
    %This variable is the number of times that the space is increased
	resize_space = 2; 
	
    %Get spine names
    spine_names = cell(1,num_lines);
    fid = fopen(spines_partially_fragmented_file, 'rt');
    for i = 1:num_lines
        spine_names{i} = fgetl(fid);
    end
    fclose(fid);
    
    %Reparation steps
	parfor i = 1:num_lines
		data = load(spine_names{i});
        
		%Voxelize the spine to apply dilation
		[u, foriginal, voriginal] = VoxSpine(data.Spine, data.resolution, data.physical_origin, data.physical_length);
		
		%Space is too small. It is aumented with the aim to let spine grow in any direction.
		spine_space = zeros(size(u) * resize_space);
		half_voxeles = size(u) / 2;
		space_size = (size(spine_space) / 2);
		
		%Place the spine in the middle of the space
		spine_space((space_size(1) - half_voxeles(1)):(((space_size(1) + half_voxeles(1))) - 1),(space_size(2) - half_voxeles(2)):(((space_size(2) + half_voxeles(2))) - 1),(space_size(3) - half_voxeles(3)):(((space_size(3) + half_voxeles(3))) - 1)) = u;

       
		%Spherical mask to apply to voxelized spine
		mask_size = 3;
		[x, y, z] = meshgrid(-mask_size:mask_size, -mask_size:mask_size, -mask_size:mask_size); r = mask_size;
		mask = (x / r).^2 + (y / r).^2 + (z / r).^2 <= 1;

        %Apply close operation, first dilation then erosion
		spine_close_part_frag = imclose(spine_space, mask);

		repaired_spine_part_frag = isosurface(spine_close_part_frag, 0.5);%Voxelize spine to mesh
		smoothed_spine = smoothpatch(repaired_spine_part_frag, 1, 3);%Smooth mesh. Parameters where selected heuristically
	
		[original_path, name,ext] = fileparts(spine_names{i});
		sep_ind = findstr(original_path, filesep);
		n_sep = length(sep_ind);
		deepest_folder = original_path(sep_ind(n_sep):length(original_path));
		
		parsave([root_spines_repaired_path deepest_folder filesep name ext], data.Spine, smoothed_spine, data.physical_length, data.physical_origin, data.resolution);		
    end
    
	%%%%%%%%Spines fragmented repairment%%%%%%%%%%%%%
	fid = fopen(spines_fragmented_file);
	
    % Get file size.
	fseek(fid, 0, 'eof');
	file_size = ftell(fid);
	frewind(fid);
	
    % Read the whole file.
	data = fread(fid, file_size, 'uint8');
	
    % Count number of line-feeds and increase by one.
	num_lines = sum(data == 10);
	fclose(fid);
	
	spine_names = cell(1, num_lines);
    
    fid = fopen(spines_fragmented_file, 'rt');
    for i = 1:num_lines
        spine_names{i} = fgetl(fid);
    end
    fclose(fid);
	
    %To be able to dilate spine without achieve the bounds of the space, space where spine is placed is increased.
    %This variable is the number of times that the space is increased
	resize_space = 2;
	
     %Reparation steps
	parfor i = 1:num_lines
        data = load(spine_names{i}); %Read spine
		
		%Voxelize the spine to apply dilation
		[u, foriginal, voriginal] = VoxSpine(data.Spine, data.resolution, data.physical_origin, data.physical_length);
		
		%Space is too small. It is aumented with the aim to let spine grow in any direction.
		spine_space = zeros(size(u) * resize_space);
		half_voxeles = size(u) / 2;
		space_size = (size(spine_space) / 2);
		
		%Place the spine in the middle of the space
		spine_space((space_size(1) - half_voxeles(1)):(((space_size(1) + half_voxeles(1))) - 1),(space_size(2) - half_voxeles(2)):(((space_size(2) + half_voxeles(2))) - 1),(space_size(3) - half_voxeles(3)):(((space_size(3) + half_voxeles(3))) - 1)) = u;

		%Mask for dilation
		mask_size = 3;
		[x, y, z] = meshgrid( - mask_size:mask_size, - mask_size:mask_size, - mask_size:mask_size); r = mask_size;
		mask = (x / r).^2 + (y / r).^2 + (z / r).^2 <= 1;
        
        %Mask for erosion
        mask_size_erosion = 2;
        [x, y, z] = meshgrid(-mask_size_erosion:mask_size_erosion, -mask_size_erosion:mask_size_erosion, -mask_size_erosion:mask_size_erosion); r = mask_size_erosion;
		mask_erode = (x / r).^2 + (y / r).^2 + (z / r).^2 <= 1;
		
        % Spine is dilated and then eroded (close operation). Thus, if the
		% components are close the mesh is inmediatly repaired
		spine_dilated = imdilate(spine_space, mask);
		spine_erode = imerode(spine_dilated, mask_erode);;
        
        %Check if the spine has been repaired after close operation
		[L, NUM] = bwlabeln(spine_erode, 6);
        dilation_num = 1;
        
        %If the number of components is over 1 it means that close
        %operation does not repair the spine. We let the spine grow up
        %until there is a unique component.
        while NUM > 1
			spine_dilated = imdilate(spine_dilated, mask);
			spine_erode = imerode(spine_dilated, mask_erode);
			[L, NUM] = bwlabeln(spine_erode, 6);
			dilation_num = dilation_num + 1;
        end
      
		repaired_spine = isosurface(spine_dilated, 0.5);%Voxelize spine to mesh
		smoothed_spine = smoothpatch(repaired_spine, 0, (20 * (dilation_num)^2));%Smooth mesh. Parameters where selected heuristically
         
		[original_path, name, ext] = fileparts(spine_names{i});
		sep_ind = findstr(original_path, filesep);
		n_sep = length(sep_ind);
		deepest_folder = original_path(sep_ind(n_sep):length(original_path));
		
		parsave([root_spines_repaired_path deepest_folder filesep name ext], data.Spine, smoothed_spine, data.physical_length, data.physical_origin, data.resolution);		
    end
end

