% Compute the level curves of a spine according to the geodesic distance
% from the insertion point to the vertices of the spine.
%
% Compute the curve levels of a spine according to the geodesic distance
% from the insertion point to the vertices of the spine.
%
% @author Luengo-Sanchez, S.
%
% @param spine_path path to the spine
% @param spine_data a spine object 
% @param number_of_ranges number of level curves
%
% @examples
% See Main.m
function compute_spine_curves(spine_path, spine_data, number_of_ranges)
    %Compute geodesic distance from the insertion point to the other points
    %of the mesh.
    [geodesic_dist,~,~] = perform_fast_marching_mesh(spine_data.repaired_spine.vertices, spine_data.repaired_spine.faces, spine_data.insertion_point_idx);
    
    idx=fliplr(find(geodesic_dist==Inf)');
    spine_data.repaired_spine.vertices(idx,:)=[];
     geodesic_dist(idx)=[];
    for i=1:length(idx) 
        spine_data.repaired_spine.faces(find(any(spine_data.repaired_spine.faces==idx(i),2)),:)=[];
        over_idx=find(spine_data.repaired_spine.faces>idx(i));
        spine_data.repaired_spine.faces(over_idx)=spine_data.repaired_spine.faces(over_idx)-1;
    end
    
    %Divide the mesh according to the geodesic distance in different
    %sections.
    [newModel, newFuncVals, limits] = factorizeModel(spine_data.repaired_spine, geodesic_dist, number_of_ranges);
    
    %Save curves and factorized model
    curve = cell(1, length(limits));
    for i=1:length(limits)
        curve{i} = newModel.vertices(find(newFuncVals == limits(i)), :);
    end
    
    factorized_spine = newModel;
    save(spine_path, 'factorized_spine', 'curve', '-append')

end


