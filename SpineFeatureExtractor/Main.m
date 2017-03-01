%Main function
%
%This function calls all the other functions of the project to preprocess,
%model and simulate new spines
%
% @author Luengo-Sanchez, S.
%
% @param root_ZIP_path path to the ZIP files where VRMLs and TIF are compressed
% @param root_VRML_path path to the folder where VRML files will be saved
% @param root_stack_TIF_path path to the folder where the stack of TIFs images will be saved
% @param root_MAT_path path to the folder where MAT files will be saved
% @param root_spines_repaired_path path to the folder where the initially
% fragmented spines will be saved after repaired them
% @param root_spines_neck_repaired_path path to the folder where spines
% will be saved once we have repaired their neck
% spines will be saved
%
% @param spines_correct_file path to file where spines that are not fragmented are
% saved
% @param spines_fragmented_file path to file where spines highly fragmented
% are saved
% @param spines_partially_fragmented_file path to file where spines partially 
% fragmented are saved
% @examples
% See process_VRMLs.m

%Add files needed to execute the code
addpath(genpath('.'))

%Place where VRMLs are placed
root_insertion_points_path='./data/ROOT_insertion_points';
if(exist(root_insertion_points_path,'dir')~=7)
	mkdir(root_insertion_points_path);
end

%Place where VRMLs are placed
root_VRML_path='./data/ROOT_VRMLs';
if(exist(root_VRML_path,'dir')~=7)
	mkdir(root_VRML_path);
end

%Place where TIF images are placed
root_TIF_path='./data/ROOT_TIFs';
if(exist(root_TIF_path,'dir')~=7)
	mkdir(root_TIF_path);
end

%Place where stacks TIF images are placed
root_stack_TIF_path='./data/ROOT_stack_TIFs';
if(exist(root_stack_TIF_path,'dir')~=7)
	mkdir(root_stack_TIF_path);
end

root_MAT_path='./data/ROOT_MATs';
if(exist(root_MAT_path,'dir')~=7)
	mkdir(root_MAT_path);
end

root_spines_repaired_path='./data/ROOT_REPAIREDs';

if(exist(root_spines_repaired_path,'dir')~=7)
	mkdir(root_spines_repaired_path);
end

root_spines_neck_repaired_path='./data/ROOT_new_neck';

if(exist(root_spines_neck_repaired_path,'dir')~=7)
	mkdir(root_spines_neck_repaired_path);
end

spines_correct_file='./indexCorrect.txt'; %Root to the file where correct spines must be saved
spines_fragmented_file='./indexFragmented.txt'; %Root to the file where fragmented spines must be saved
spines_partially_fragmented_file='./indexPartiallyFragmented.txt'; %Root to the file where partially fragmented spines must be saved

%Unzip ZIP files to extract VRMLs and TIF 
%unzipVRMLs (root_ZIP_path,root_VRML_path,root_TIF_path)
unzip('./data/Ficheros originales/ROOT_TIFs.zip', root_TIF_path); %Unzip file in temp folder
unzip('./data/Ficheros originales/ROOT_VRMLs.zip', root_VRML_path); %Unzip file in temp folder
unzip('./data/Ficheros originales/ROOT_insertion_points.zip', root_insertion_points_path); %Unzip file in temp folder


%Save all TIF images together obtaining a stack of TIF images
tif_images_to_stack(root_TIF_path,root_stack_TIF_path)

%Read VRML_file and write each of its defined spines as a .MAT file in MAT_save_path. Also include metadata information.
process_VRMLs(root_VRML_path,root_TIF_path,root_MAT_path);

%Classify spines as correct if they represent a unique component or fragmented if they are composed of different fragments or components
classify_fragmented_spines(root_MAT_path,spines_correct_file,spines_partially_fragmented_file,spines_fragmented_file);

%Repair the spines that were fragmented
repair_fragmentation(spines_partially_fragmented_file, spines_fragmented_file, spines_correct_file, root_spines_repaired_path, root_MAT_path);

%Resize and shift repaired spines to place them in the original position.
%It is needed because previous function shifts the spine
reallocate_spine(root_spines_repaired_path);

%Repair the neck of the spines. Spines grow until they are attached to
%dendrite represented by the insertion point
repair_neck(root_spines_repaired_path,ROOT_insertion_points, root_spines_neck_repaired_path);

%Compute level curves of the spines. Spines that present double curve can
%be removed automatically if third parameters is true. It must be regarded
%that some spines that do not present double curvature problem can be
%removed in the process. If the user prefers,
%spine can be evaluated manually one by one.
compute_level_curves(root_spines_neck_repaired_path, num_curves, false, threshold);

%Check and remove manually those spine which present the double curve
%problem. This step is optional, not needed if the third parameter of
%compute_level_curve is true.
remove_double_curvature_manually(root_spines_neck_repaired_path, threshold)

%Compute the features of the spines according to the level curves and save
%in a xls file
compute_features(root_spines_neck_repaired_path, file_name)


