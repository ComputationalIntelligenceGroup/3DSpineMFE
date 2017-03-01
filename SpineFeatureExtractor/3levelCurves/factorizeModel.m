% Develop by Jesus Pérez
% Get the raw model, the function values at each vertex and a number of 
% factors in which it should be divided; then, each vertex is allocated
% in a factor based on the considered differentiation function. In order 
% to make each triangle belong to a single factor, some vertices are moved.
%
% Parameters:
%       - model struct : The model to check the factorization.
%       - funcVals [1xN] double : The function value at each vertex.
%       - factorNum integer : The number of factors to divide the model.
%
% Returns:
%       - newModel struct : The new model with moved vertices.
%       - newFuncVals [1xN] double : The function value at each vertex.
%       - limits [1xL] double : The limits of the factors.
%
function [newModel, newFuncVals, limits] = factorizeModel(model, funcVals, factorNum)

    % Create upper limits
    minval = min(funcVals); 
    maxval = max(funcVals);
    range = maxval - minval; % Range of values
    limits = minval : range/factorNum : maxval;
    
    % Divide
    newModel = model;
    newFuncVals = funcVals;
    for f = 2:factorNum
        limitValue = limits(f); % Get limit
        [newModel, newFuncVals] = limitModel(newModel, newFuncVals, limitValue);
    end;
    
end