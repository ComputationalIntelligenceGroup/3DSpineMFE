function compute_features(root_spines_neck_repaired_path,file_name)
%COMPUTE_FEATURES Computes features.
%Computes features for all repaired spines with level curves inside a 
%folder of dendrites. Then an XLS file with extracted features is created.
%
%   COMPUTE_FEATURES(root_spines_neck_repaired_path, file_name)
%
%   Parameters:
%       -root_spines_neck_repaired_path character-vector : The folder where
%           spines with repaired neck and level curves computed are stored.
%       - file_name character-vector : The name of the XLS file where
%           computed features are going to be saved.
%
%Author: Luengo-Sanchez, S.
%
%See also COMPUTE_SPINE_FEATURES

    [~,~,spine_ext]=fileparts(file_name);
    if(~ strcmp(spine_ext,'.xls'))
        warning('The extension of the file name does not correspond with an excel file, xls extension will be added');
        file_name=strcat(file_name,'.xls');
    end
    list_dendrites = dir(root_spines_neck_repaired_path);
    list_spines = dir([root_spines_neck_repaired_path filesep list_dendrites(3).name]);
    spine_path = [root_spines_neck_repaired_path filesep list_dendrites(3).name filesep list_spines(3).name];
    spine_data = load(spine_path);
    
    num_curves=length(spine_data.curve);
    
    header={'spineName'};
    header=[header regexp(deblank(sprintf('h_%d ', 1:(num_curves-1))), ' ', 'split')]; %Height
    header=[header regexp(deblank(sprintf('theta_%d ', 2:(num_curves-1))), ' ', 'split')]; %Growing direction elevation(theta)
    header=[header regexp(deblank(sprintf('cos_phi_%d ', 2:(num_curves-1))), ' ', 'split')]; %Growing direction cosine azimuth (phi)
    header=[header regexp(deblank(sprintf('B_r_%d ', 1:(num_curves-2))), ' ', 'split')]; %Minor axis
    header=[header regexp(deblank(sprintf('B_R_%d ', 1:(num_curves-2))), ' ', 'split')]; %Major axis
    
    ratio_ellipses_comb=combnk(1:(num_curves-2),2);
    num_elem=size(ratio_ellipses_comb,1);
    header=[header regexp(deblank(sprintf('ratio_%d_%d ', ratio_ellipses_comb')), ' ', 'split')]; %Ratio between sections
    header=[header regexp(deblank(sprintf('inst_Theta_%d ', 1:(num_curves-2))), ' ', 'split')]; %Instant direction elevation (Theta)
    header=[header regexp(deblank(sprintf('inst_Phi_%d ', 1:(num_curves-2))), ' ', 'split')]; %Instant direction azimuth (Phi)
    header=[header 'V']; %Volume
    header=[header regexp(deblank(sprintf('V_%d ', 1:(num_curves-1))), ' ', 'split')]; %Volume by section
    header=[header 'S']; %Volume by section
    header=[header regexp(deblank(sprintf('S_%d ', 1:(num_curves-1))), ' ', 'split')]; %Surface by section

    table_rows=[];
    row_names={};
    counter=1;
    
    for i=3:size(list_dendrites,1)
        dendrite_name = list_dendrites(i).name;
        list_spines = dir([root_spines_neck_repaired_path filesep dendrite_name]);
        
        for j=3:size(list_spines, 1)
            spine_name = list_spines(j).name;
            spine_path = [root_spines_neck_repaired_path filesep dendrite_name filesep spine_name];
            spine_data = load(spine_path);
            
            if(num_curves~=length(spine_data.curve))
                error(['The number of curves of spine ' spine_path ' is different']);
            end
            instance_row = compute_spine_features(spine_data.repaired_spine,spine_data.insertion_point_idx,spine_data.curve);
            
            table_rows=vertcat(table_rows,instance_row);
            row_names{counter}=spine_name;
            counter=counter+1;
        end
    end
    
    my_data=[row_names',num2cell(table_rows)];
    my_data=[header;my_data];
    xlswrite(file_name,my_data)
    
end