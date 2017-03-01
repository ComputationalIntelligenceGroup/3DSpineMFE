% Classify spines in correct or fragmented
%
% The script read every spine under a root directory and classify it as correct or fragmented. 
% As a result 3 files are obtained with the paths and names of the spines
% that were not fragmented, were partially fragmented or were completely
% fragmented.
%
% @author Luengo-Sanchez, S.
%
% @param root_MAT_path path to the folder where MAT files will be saved
% @param spines_correct_file path to file where spines that are not fragmented are
% saved
% @param spines_partially_fragmented_file path to file where spines highly fragmented
% are saved
% @param spines_fragmented_file path to file where spines partially 
% fragmented are saved
% @examples
% See process_VRMLs.m

function classify_fragmented_spines(root_MAT_path, spines_correct_file, spines_partially_fragmented_file, spines_fragmented_file)
	list_dendrites = dir(root_MAT_path);
    
    %Open the connection to the files where path of the spines are saved
    %according their level of fragmentation 
    fid_partially = fopen(spines_partially_fragmented_file, 'a');
    fid_fragmented = fopen(spines_fragmented_file, 'a');
    fid_correct = fopen(spines_correct_file, 'a');
        
    %Compute fragmentation for the spines of the dendrite i
	for i = 1:(size(list_dendrites,1) - 2)
        dendrite_name = list_dendrites(i + 2).name;
        list_spines = dir([root_MAT_path filesep dendrite_name]);
        
        %Create a cell array to save the level of fragmentation and the
        %path of the spine
		spine_cell_number = cell(size(list_spines, 1) - 2,1);
        spine_cell_path = cell(size(list_spines, 1) - 2,1);
		
        %For each spine compute its level of fragmentation
        parfor j = 1:(size(list_spines, 1) - 2)
				spine_name = list_spines(j + 2).name;
				spine_path = [root_MAT_path filesep dendrite_name filesep spine_name];
				[path, name, ext] = fileparts(spine_path);
				
				if strcmp(ext, '.mat')
                    data = load(spine_path);
					spine_cell_number{j} = is_fragmented(data); %Check if a spine is correct, partially fragmented or completely fragmented 
                    spine_cell_path{j} = spine_path;
                end	%end if
        end	%end parfor
        
        %Write the name of the spine in one of the three files according to
        %its state
        for j = 1:(size(list_spines, 1) - 2)
            if(spine_cell_number{j} == 1)%If it is partially fragmented
                fprintf(fid_partially, '%s\n', spine_cell_path{j});
            else if(spine_cell_number{j} == 2) %If it is fragmented
                    fprintf(fid_fragmented, '%s\n', spine_cell_path{j});
                else  %If it is correct
                    fprintf(fid_correct, '%s\n', spine_cell_path{j});
                end%end second if
            end %end if
        end %end second for
    end %end for
         fclose all; %Close all streaming connections to the files
end %end function 
