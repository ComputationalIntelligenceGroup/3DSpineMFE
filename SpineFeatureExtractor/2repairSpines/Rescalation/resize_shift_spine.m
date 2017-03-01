% Resize and shift the spine to its original dimensions and place.
%
% Given a spine, spine is resize to its original size by means of resize
% the new bounding box to the lengths of the original bounding box. Also
% the spine is shifted to recover its original position.
%
% @author Luengo-Sanchez, S.
%
% @param root_spines_repaired_path path to the folder where repaired spines
% were saved
% @param original_spine original spine object, i.e., spine as it was read
% from the VRML file
% @param smoothed_spine repaired and smoothed spine obtained from
% fragmentation reparation
%
% @examples
% See reallocate_spine.m

function resize_shift_spine(root_spines_repaired_path, original_spine, smoothed_spine) 
    %Shift a corner of the bounding box of the original spine to the origin 
	shift_array = min(original_spine.vertices, [], 1);
	shifted_original_spine = original_spine;
	shifted_original_spine.vertices = bsxfun(@minus, original_spine.vertices, shift_array);

    %Shift a corner of the bounding box of the repaired spine to the origin 
	shift_array_smoothed = min(smoothed_spine.vertices, [], 1);
	shifted_smoothed_spine = smoothed_spine;
	shifted_smoothed_spine.vertices = bsxfun(@minus, smoothed_spine.vertices, shift_array_smoothed);

    %Length of the bounding box along the X axis of the original spine
	length_array = max(shifted_original_spine.vertices, [], 1) - min(shifted_original_spine.vertices, [], 1);
	%Length of the bounding box along the X axis of the original spine
    length_smoothed_spine = max(shifted_smoothed_spine.vertices, [], 1) - min(shifted_smoothed_spine.vertices, [], 1);
	%Proportion between both lengths
    proportion = length_array ./ length_smoothed_spine;
	resized_smoothed_spine = shifted_smoothed_spine;
    %Resize repaired spine according to the proportion
	resized_smoothed_spine.vertices = bsxfun(@times, shifted_smoothed_spine.vertices, proportion);

    %Shift smoothed spine to the position of the original spine
	shifted_spine = resized_smoothed_spine;
	shifted_spine.vertices = bsxfun(@plus, resized_smoothed_spine.vertices, shift_array);
	save(root_spines_repaired_path, 'shifted_spine', '-append')
end