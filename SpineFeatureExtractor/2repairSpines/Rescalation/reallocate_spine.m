function reallocate_spine(root_spines_repaired_path)
%REALLOCATE_SPINE Reallocates repaired spines to their original position.
%During the repairing process, spines are voxelized. Because the
%voxelization operation over the original mesh, the spines are misplaced in
%the space. We need to recover their original position to make their neck
%growth through the dendrite.
%
%   REALLOCATE_SPINE(root_spines_repaired_path) Given
%   root_spines_repaired_path, which is the path that contains repaired
%   spines for each dendrite, all spines are reallocated to their original
%   position.
%
%Author: Luengo-Sanchez, S.
%
%See also RESIZE_SHIFT_SPINE

    listDendrites = dir(root_spines_repaired_path);
    
    %For each repaired spine resize and shift to its original position
	for i = 1:(size(listDendrites,1) - 2)
	dendriteName = listDendrites(i + 2).name;
	listSpines = dir([root_spines_repaired_path '\' dendriteName]);
		
		parfor j = 1:(size(listSpines, 1) - 2)
				spineName = listSpines(j + 2).name;
				spinePath = [root_spines_repaired_path '\' dendriteName '\' spineName];
				[path, name, ext] = fileparts(spinePath);
				
				if strcmp(ext, '.mat')
					data = load(spinePath);
					resize_shift_spine(spinePath, data.Spine, data.smoothed_spine)%Check if a spine is correct or fragmented and write it in a file.
                end	
        end	
    end
end