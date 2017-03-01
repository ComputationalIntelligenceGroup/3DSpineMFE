function tif_images_to_stack(root_TIF_path, root_stack_TIF_path)
%TIF_IMAGES_TO_STACK Group all TIF images of a dendrite in a stack of TIF
%images.
%
%   TIF_IMAGES_TO_STACK(root_TIF_path, root_stack_TIF_path) reads all
%   folders of dendrites containing TIF images from root_TIF_path, groups
%   all images of each dendrite in a stack of TIF images, and saves into
%   root_stack_TIF_path folder.
%
%Author: Luengo-Sanchez, S.

	dendrites = dir(root_TIF_path);%Load all names of the folders inside root directory
	
    %Group TIF images in a stack for each dendrite.
	parfor j = 3:size(dendrites, 1)
		dendrite = dendrites(j).name;
		list_file_TIF = dir([root_TIF_path filesep dendrite]); %Read all images inside the dendrite folder
        
        %An image is read to compute parameters of TIF images like
        %resolution or size of the stack
		tif = imread([root_TIF_path filesep dendrite filesep list_file_TIF(3).name]); 

		nrow = size(tif, 1);
		ncol = size(tif, 2);
		stack = size(list_file_TIF, 1) - 3;

		I = zeros(nrow, ncol, stack, 'uint16');  %preallocate block 
		split_str = regexp(list_file_TIF(3).name, '_', 'split');
		
        %Read each TIF image in the folder
		for i = 0:stack 
			if(i < 10)
				I(:, :, i + 1) = imread([root_TIF_path filesep dendrite filesep split_str{1, 1} sprintf('_Z00%i.tif', i)]);  %Set each image to slice
			elseif(i < 100)
					I(:, :, i + 1) = imread([root_TIF_path filesep dendrite filesep  split_str{1, 1} sprintf('_Z0%i.tif', i)]); % Set each image to slice
				else
					I(:, :, i + 1) = imread([root_TIF_path filesep dendrite filesep  split_str{1, 1} sprintf('_Z%i.tif', i)]);  %Set each image to slice
            end %end if
        end %end for

        %Group images in a stack
		for K = 1:length(I(1, 1, :))
			imwrite(I(:, :, K), [root_stack_TIF_path filesep dendrite '.tif'], 'WriteMode', 'append', 'Compression', 'none');
        end %end for
	
    end %end parfor
end