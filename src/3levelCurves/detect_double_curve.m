function [double_curve_spines,num_curve_level_problem]=detect_double_curve(root_spines_neck_repaired_path,threshold)
%DETECT_DOUBLE_CURVE Detects double curve defect. 
%Identifies the names of the spines that have two curves in place of only
%one for a level.
%
%   [double_curve_spines, num_curve_level_problem] =
%   DETECT_DOUBLE_CURVE(root_spines_neck_repaired_path, threshold) 
%
%   Input parameters:
%       - root_spines_neck_repaired_path character-vector : Folder where
%           spines with repaired neck are stored.
%       - threshold double : The smaller the threshold value, the more the
%           number of double curve defects detected, e.g., for a threshold
%           value of 0, all spines will have double curve defect.
%
%   Output parameters:
%       - double_curve_spines cell-array : Contains the path of those
%           spines with double curve defect.
%       - num_curve_level_problem cell-array : Contains the number of the
%           curve level that presents the problem.
%
%Author: Luengo-Sanchez, S.

    totalDistances = [];
    double_curve_spines = {};
    num_curve_level_problem={};

    count=1;
    list_dendrites = dir(root_spines_neck_repaired_path);
    for k=3:length(list_dendrites)
        dendrite_name = list_dendrites(k).name;
        list_spines = dir([root_spines_neck_repaired_path filesep dendrite_name]);
    
        for j=3:length(list_spines)
            spine_name = list_spines(j).name;
            spine_path = [root_spines_neck_repaired_path filesep dendrite_name filesep spine_name];
            spine_data = load(spine_path);

            %Compute a hierarchical clustering between the points of a
            %curve. When the distance between the two farest clusters is
            %more than the double of the previous more farest clusters it
            %means that there are at least two curves in place of one.
            for i=2:(size(spine_data.curve,2)-1)
                Y = pdist(spine_data.curve{i});
                Z = linkage(Y);
                
                proportion = Z(size(Z, 1), size(Z, 2)) / Z((size(Z, 1) - 1),(size(Z, 2)));
                totalDistances(1,(size(totalDistances, 2) + 1)) = proportion;
            
                if(proportion > threshold)
                    double_curve_spines{count} = spine_path;
                    num_curve_level_problem{count}=i;
                    count=count+1;
                end   
            end
        end
    end
    
end