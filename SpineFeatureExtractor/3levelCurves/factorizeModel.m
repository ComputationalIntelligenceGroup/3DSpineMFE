function [newModel, newFuncVals, limits] = factorizeModel(model, funcVals, factorNum)
%FACTORIZEMODEL Gets the raw model, the function values at each vertex and
%a number of factors in which it should be divided; then, each vertex is 
%allocated in a factor based on the considered differentiation function. 
%In order to make each triangle belong to a single factor, some vertices 
%are moved.
%
%   [newModel, newFuncVals, limits] = factorizeModel(model, funcVals,
%   factorNum) 
%   
%   Input parameters:
%       - model struct : The model to check the factorization.
%       - funcVals [1xN double] : The function value at each vertex.
%       - factorNum integer : The number of factors to divide the model.
%
%   Output parameters:
%       - newModel struct : The new model with moved vertices.
%       - newFuncVals [1xN] double : The function value at each vertex.
%       - limits [1xL] double : The limits of the factors.
%
%Author: Jesus Pérez
%
%See also LIMITMODEL

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