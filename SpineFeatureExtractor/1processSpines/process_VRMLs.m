% Process VRMLs in a folder and yields MAT files representing Spines
%
% Process VRMLs in a folder and yields MAT files representing Spines
%
% @author Luengo-Sanchez, S.
%
% @param root_VRML_path path to the VRML file where spine definitions are placed
% @param root_TIF_path path to the folder where .mat will be saved
% @param root_MAT_path coordinates of the origin of the stack of images 
% @param physical_length length of the space where the spines were placed
% @param stack number of tif images in the stack
% @param element_name name of the dendrite where the spine is placed
%
% @examples
% See Main.m

%This function processes VRMLs in a folder and yields MAT files representing Spines
function process_VRMLs(root_VRML_path, root_TIF_path, root_MAT_path)
	file_tree_VRML = dir(root_VRML_path); %Read all folders inside the VRML root path
	file_tree_TIF = dir(root_TIF_path); %Read all folders inside the TIF root path
    TIF_names = {file_tree_TIF.name}; %Names of the TIF folders
	
	%For each file in the root directory check if it is an VRML file and if it is create a folder for the VRML and save inside all the spines defined
	parfor i = 3:length(file_tree_VRML) 
		[path, name, ext] = fileparts(file_tree_VRML(i).name); 
		
		if strcmp(upper(ext), '.VRML')
            idx = find(strcmp(name, TIF_names));
			TIF_images_tree = dir([root_TIF_path filesep TIF_names{idx}]);
            
            %Obtain information of the image from metadata
            [physical_origin, physical_length, stack, element_name] = metadata_extraction([root_TIF_path filesep TIF_names{idx} filesep TIF_images_tree(3).name]); %Obtain metadata of the dendrite
            
            %Save all the spines of the dendrite in the same folder each
            %one in a .mat file
            MAT_save_path = [root_MAT_path filesep name filesep];
            mkdir(MAT_save_path);
            read_VRML([root_VRML_path filesep file_tree_VRML(i).name], MAT_save_path, physical_origin, physical_length, stack, element_name);%Read all spines in a dendrite
		end %end if
		
	end %end parfor

