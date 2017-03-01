function insertion_points=read_insertion_points(filename)
    fp = fopen(filename,'r');
    if fp == -1
      fclose all;
      str = sprintf('Cannot open file %s \n',filename);
      errordlg(str);
      error(str);
    end
   
    A=textscan(fp,'%s');
    index = find(cellfun('length',regexp(A{1},'^Coordinate')) == 1);
    index=index+4;
    insertion_points=cell(length(index),1);
    
     for i=1:length(index)
        %Compute vertices
        index_list = find(cellfun('length',regexp(A{1}(index(i):length(A{1})),']')) == 1);
        index2=index_list(1)-2;
    
        array_vertices=str2num(char(A{1}(index(i):(index2+index(i)))));
        insertion_points{i}=reshape(array_vertices,[3 length(array_vertices)/3])';
     end
      insertion_points=insertion_points(~cellfun('isempty',insertion_points));  
end