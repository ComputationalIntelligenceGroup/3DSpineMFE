% Compute level curves for all the spines under a root folder
%
% Compute level curves for all the spines under a root folder
%
% @author Luengo-Sanchez, S.
%
% @param root_spines_neck_repaired_path path to the folder where the spines
% with the repaired neck should be saved
%
% @param number_of_ranges the number of level curves that must be computed
% for each spine
%
% @examples
% See Main.m
function compute_level_curves(root_spines_neck_repaired_path,number_of_ranges,remove,threshold)
    list_dendrites = dir(root_spines_neck_repaired_path);

    for i=3:size(list_dendrites,1)
        dendrite_name = list_dendrites(i).name;
        list_spines = dir([root_spines_neck_repaired_path filesep dendrite_name]);
        
        for j=3:size(list_spines, 1)
            spine_name = list_spines(j).name;
            spine_path = [root_spines_neck_repaired_path filesep dendrite_name filesep spine_name];
            spine_data = load(spine_path);
            compute_spine_curves(spine_path, spine_data, number_of_ranges);    
        end
    end
    
    if(remove)
        [spine_path,~]=detect_double_curve(root_spines_neck_repaired_path,threshold);
        spine_path=unique(spine_path);
        for(i=1:length(spine_path))  
            delete(spine_path{i});
        end
    end 
end

