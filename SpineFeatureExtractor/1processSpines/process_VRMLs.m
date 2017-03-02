function process_VRMLs(root_VRML_path, root_TIF_path, root_MAT_path)
%PROCESS_VRMLS Processes VRMLs in a folder
%And yields MAT files representing Spines.
%
%   PROCESS_VRMLS(root_VRML_path, root_TIF_path, root_MAT_path) 
%
%   Parameters:
%       - root_VRML_path character-vector : Path of the folder that
%           contains all VRML files to be processed for creating spine .MAT
%           files.
%       - root_TIF_path character-vector : Path of the folder that contains
%           the TIF images that corresponds to the VRML files for
%           extracting the metadata needed.
%       - root_MAT_path character-vector : Path where spine .MAT files are
%           going to be saved.
%
%Author: Luengo-Sanchez, S.
%
%See also METADATA_EXTRACTION, READ_VRML

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

