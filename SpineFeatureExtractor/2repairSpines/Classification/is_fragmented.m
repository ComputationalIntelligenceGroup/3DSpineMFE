function file_to_save = is_fragmented(data)	
%IS_FRAGMENTED Checks level of fragmentation of the spine.
%
%   fragmentation = IS_FRAGMENTED(spine_object) given a Spine object, i.e.,
%   vertices and faces, the fragmentation of that spine is returned:
%   - fragmentation = 1, the spine is partially fragmented.
%   - fragmentation = 2, the spine is fragmented.
%   - fragmentation = 3, the spine is NOT fragmented.
%
%Author: Luengo-Sanchez, S.
%
%See also CLASSIFY_FRAGMENTED_SPINES, SPLITFV, BWLABELN

	%If the mesh is composed of 2 or more components it is fragmented if not it is correct.
	if(size(splitFV(data.Spine.faces, data.Spine.vertices), 1) > 1)
	
		%Check if it is a big fragmentation or a small one. Small fragmentations are not detected by voxelization+bwlabeln which consider them as a unique component.
		num_voxeles_threshold = 8;
		[voxelized_mesh, original_mesh_faces, original_mesh_vertices] = VoxSpine(data.Spine, data.resolution, data.physical_origin, data.physical_length);
		[L, NUM] = bwlabeln(voxelized_mesh, 6);
		
		%Compute number of voxeles per component.
		voxeles_per_component = [];
		for count = 1:NUM
			voxeles_per_component = [voxeles_per_component sum(sum(sum(L == count)))];     %Sumo la cantidad de valores por label. Cantidad de voxeles que pertenecen a la espina
		end
		
		%Some times voxelization introduce noise. This noise is avoided removing the components whose number of voxeles is less than a threshold.
		big_components = (voxeles_per_component > num_voxeles_threshold);
		
		%If there is a unique big component it is partially broken.If not, more than one component are detected and the spine is very fragmented.
		if(length(find(big_components)) == 1)
			file_to_save = 1;
        else
            file_to_save = 2;
		end
		
    else
            file_to_save = 3;
    end
end
