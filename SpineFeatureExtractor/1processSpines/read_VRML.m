function read_VRML(filename, output_path, physical_origin, physical_length, stack, element_name)
%READ_VRML Reads spines from the VRML file saving each spine in a .mat
%file.
%
%   READ_VRML(filename, output_path, physical_origin, physical_length,
%   stack, element_name) reads spine definitions from filename (VRML file),
%   then .mat files will be stored inside output_path directory.
%   physical_origin refers to the coordinates of the origin of the stack of
%   images.
%   physical_length is the length of the space where the spines were
%   placed.
%   stack is the number of TIF images in the stack (Z coordinate).
%   element_name is the name of the dendrite where the spine is placed.
%
%Author: Baguear.
%
%See also: PROCESS_VRMLS

    spine_counter = 0;

    %Open file and read it line from line
    fid = fopen(filename, 'r'); 
    tline = fgetl(fid);

    %Variable definition
    points3d = [];%Vertices
    coord_index = [];%Faces
    normals = [];%Normals


    %Variable that tell us the information that we are reading now. 1=vertices, 2=normals and 3=faces.
    state = 0;

    %Read the whole file
    while ischar(tline)
   
        %Once vertices, normals or faces initial definition has been identified we
        %continue saving the all entries of the file corresponding to that component. 
        if(state == 1)
            A = sscanf(tline, '%f %f %f,');
            points3d = [points3d; A'];
        end %end if
   
        if(state == 2)
            A = sscanf(tline, '%f %f %f,');
            normals  =[normals; A'];
        end %end if
   
        if(state == 3)
            A = sscanf(tline, '%i, %i, %i, %i, %i, %i, %i, %i,');
            if(length(A) ~= 8)
                A = [A; zeros(1, 8 - length(A))'];
            end %end second if
        coord_index = [coord_index; A'];
        end %end if
   
        if(strfind(tline, 'Coordinate {'))    %If a Coordinate is found --> New Dendritic Spine
            spine_counter = spine_counter + 1;
        end %end if
    
        if(strfind(tline, 'point ['))        %Point coordinates
            A = sscanf(tline, '                                      point [  %f %f %f,');
            points3d = [points3d; A'];
            state = 1;
        end %end if
    
        if(strfind(tline, 'vector ['))        %Normals
            A = sscanf(tline, '                                      vector [  %f %f %f,');
            normals = [normals; A'];
            state = 2;
        end %end if
    
        if(strfind(tline, 'coordIndex ['))        %Faces
            %Read the string as integers and save it in face matrix. Change
            %state to faces.
            A = sscanf(tline, '                                      coordIndex [  %i, %i, %i, %i, %i, %i, %i, %i,');
            coord_index = [coord_index; A'];
            state = 3;
        end %end if
    
        tline = fgetl(fid);%Read next line
    
        if(strfind(tline, 'ccw'))        %End of the spine definition
            state = 0;                     %Restart state
            str = int2str(spine_counter);   
            str = [element_name '_Spine' str];%Spine name
        
            coord_index = vertcat(coord_index(:, 1:3), coord_index(:, 5:7));
            coord_index = coord_index + 1;
        
            %Create object Spine with all the recovered information
            Spine.vertices = points3d;
            Spine.normals = normals;
            Spine.faces = coord_index;
	
            resolution=[1024 1024 stack]; %All images are 1024x1024
     
            %Save spine as .mat file
            save([output_path str], 'Spine','physical_origin', 'physical_length', 'resolution');
        
            %Reboot properties of the spine
            points3d = [];
            normals = [];
            coord_index = [];
        end %end if
    
        if(strcmp(tline, ''))
            state = 0;
        end %end if
    end %end while

    fclose(fid);
end %end function