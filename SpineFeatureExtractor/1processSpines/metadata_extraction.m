
% Reads a TIF file and extract metadata from it.
%
% This function reads a .tif file and extracts metadata from it.
% Information about dimensions of the spines is saved as metadata in the .tif file. 
% All the images in the stack have the metadata so anyone of them can be used. 
% Needed for the Voxelization process.
%
% @author Luengo-Sanchez, S.
%
% @param filename path to the TIF file
%
% @examples
% See processVRMLs.m

function [physicalO, physicalL, stack, element_name] = metadata_extraction(filename)
	metadataInfo = imfinfo(filename);
	text = metadataInfo.ImageDescription;
	
	physicalO = zeros(1, 3);%Coords of the image respect to the origin of the neuron according to the microscope
	physicalL = zeros(1, 3);%Length of each dimension of the stack (X,Y,Z)
	
	%Metadata of the X axis
	split_str = regexp(text, '\[Image\]', 'split');
	str_name = regexp(split_str{2}, 'ElementName = ', 'split');
	str_CRLF = regexp(str_name{2}, '\n', 'split');
	element_name = str_CRLF{1};
	element_name(element_name == 13) = []; %Remove CRLF
	
	%Metadata of the X axis
	split_str = regexp(text, '\[Dimension X \]', 'split');
	str_length = regexp(split_str{2}, 'Length = ', 'split');
	str_CRLF = regexp(str_length{2}, '\n', 'split');
	physicalL(1) = str2num(str_CRLF{1}) * 10^6; %From 0.XXXXXe-05 to XX.XXXX
	str_origin = regexp(split_str{2}, 'Origin = ', 'split');
	str_CRLF = regexp(str_origin{2}, '\n', 'split');
	physicalO(1) = str2num(str_CRLF{1}) * 10^6; %From 0.XXXXXe-05 to XX.XXXX

	%Metadata of the Y axis
	split_str = regexp(text, '\[Dimension Y \]', 'split');
	str_length = regexp(split_str{2}, 'Length = ', 'split');
	str_CRLF = regexp(str_length{2}, '\n', 'split');
	physicalL(2) = str2num(str_CRLF{1}) * 10^6; %From 0.XXXXXe-05 to XX.XXXX
	str_origin = regexp(split_str{2}, 'Origin = ', 'split');
	str_CRLF = regexp(str_origin{2}, '\n', 'split');
	physicalO(2) = str2num(str_CRLF{1}) * 10^6; %From 0.XXXXXe-05 to XX.XXXX

	%Metadata of the Z axis
	split_str = regexp(text, '\[Dimension Z \]', 'split');
	str_length = regexp(split_str{2}, 'Length = ', 'split');
	str_CRLF = regexp(str_length{2}, '\n', 'split');
	physicalL(3) = str2num(str_CRLF{1}) * 10^6; %From 0.XXXXXe-05 to XX.XXXX
	str_origin = regexp(split_str{2}, 'Origin = ', 'split');
	str_CRLF = regexp(str_origin{2}, '\n', 'split');
	physicalO(3) = str2num(str_CRLF{1}) * 10^6; %From 0.XXXXXe-05 to XX.XXXX
	str_stack = regexp(split_str{2}, 'NumberOfElements = ', 'split');
	str_CRLF = regexp(str_stack{2}, '\n', 'split');
	stack = str2num(str_CRLF{1});
end
