% Develop by Jesus Pérez updated by Sergio Luengo-Sanchez.
% Get the raw model, the function values at each vertex and a limit value; 
% then, those vertex such that its function value is above (or below) the 
% limit are selected. In order to make each triangle belong to a single 
% factor, new vertices are introduced in the model.
%
% Parameters:
%       - model struct : The model to check the factorization.
%       - funcVals [1xN] double : The function value at each vertex.
%       - limitValue double : The function value limit.
%
% Returns:
%       - newModel struct : The new model with introduced vertices.
%       - newFuncVals [1xN] double : The function value at each vertex.
%
function [newModel, newFuncVals] = limitModel(model, funcVals, limitValue)
    % Get data
    faces = model.faces;
    vertices = model.vertices;
    nV = size(vertices,1);
    
    % Assign factors {0,1}. Indicates 0 if is under the level curve 1 if is
    % over the level curve
    cond = funcVals >= limitValue;
    factors = false(1, nV);
    factors(cond) = 1;

    % Check all triangles
    newFuncVals = funcVals;
    newvertices = vertices;
    newfaces = faces;
    
    erasefaces = []; % Initialize

    for i = 1:size(faces,1)

        face = faces(i,:);

        % Check if this face matters. If a face has equal factors for all
        % its vertices dont do anything. In other case, cut the edges
        % with the vertex with different value and generate new faces
        if (factors(face(1)) ~= factors(face(2)) || ...
            factors(face(2)) ~= factors(face(3)) || ...
            factors(face(1)) ~= factors(face(3)))

            erasefaces(end+1) = i;

            % Extract solo and pair vertices
            if (factors(face(2)) == factors(face(3)))
                vsoloIndex = face(1); vpairIndex = face([2,3]);
            elseif (factors(face(1)) == factors(face(3)))
                vsoloIndex = face(2); vpairIndex = face([1,3]); 
            elseif (factors(face(1)) == factors(face(2)))
                vsoloIndex = face(3); vpairIndex = face([1,2]);
            end;

            vsolo = newvertices(vsoloIndex,:);
            vpair = newvertices(vpairIndex,:);

            %Get the vector from the different vertex to one of the other
            %two vertices
             v1 = vpair(1,:) - vsolo;
             length_new_point = abs((limitValue - newFuncVals(vsoloIndex))) / norm(v1); %Values from 0 to 1
             vnew1 = (length_new_point * v1) + vsolo; %Position of the new vertex
            
    
            vnew1Index = length(newvertices(:, 1)) + 1;
            newFuncVals(vnew1Index) = limitValue;
            newvertices(vnew1Index,:) = vnew1;
            factors(vnew1Index) = 0;

             v2 = vpair(2,:) - vsolo;
             length_new_point = abs((limitValue - newFuncVals(vsoloIndex))) / norm(v2);
             vnew2 = (length_new_point * v2) + vsolo;

            vnew2Index = length(newvertices(:, 1)) + 1;
            newFuncVals(vnew2Index) = limitValue;
            newvertices(vnew2Index, :) = vnew2;
            factors(vnew2Index) = 0;

            %PELIGRO 2. MANIPULAMOS EL VECTOR QUE UTILIZAMOS COMO INDICE
            %PARA EL BUCLE
            % Create new faces
            newfaces(end+1, :) = [vsoloIndex vnew1Index vnew2Index];
            newfaces(end+1, :) = [vnew1Index vpairIndex(1) vpairIndex(2)];
            newfaces(end+1, :) = [vnew2Index vnew1Index vpairIndex(2)];

        end;
    end;

    % Erase faces that were split
    cond = true(length(newfaces), 1); 
    cond(erasefaces) = false; newfaces = newfaces(cond, :);
    
    % Create model
    newModel = model;
    newModel.faces = newfaces;
    newModel.vertices = newvertices;
    
end