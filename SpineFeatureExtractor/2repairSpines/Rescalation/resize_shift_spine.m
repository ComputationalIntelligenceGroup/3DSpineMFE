function resize_shift_spine(root_spines_repaired_path, original_spine, smoothed_spine)
%RESIZE_SHIFT_SPINE Resizes and shifts the spine.
%Resizes and shifts the spine to its original dimensions and place.
%
%   RESIZE_SHIFT_SPINE(root_spines_repaired_path, original_spine,
%   smoothed_spine)
%
%   Parameters:
%       - root_spines_repaired_path character-vector : Path to the folder
%           where resized and shifted smoothed spine is going to be saved.
%       - original_spine struct : The original spine as it was read from
%           the VRML file. Is used to obtain original size and position.
%       - smoothed_spine struct : A repaired and smoothed spine obtained
%           from fragmentation reparation. will be resized to the original
%           size (by means of resizing the new bounding box to the lengths
%           of the original bounding box and shifted to the original
%           position.
%
%Author: Luengo-Sanchez, S.
%
%See also REALLOCATE_SPINE

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