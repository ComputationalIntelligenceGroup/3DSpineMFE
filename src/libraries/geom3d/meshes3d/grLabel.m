function labels = grLabel(nodes, edges)
%GRLABEL associate a label to each connected component of the graph
%   LABELS = grLabel(NODES, EDGES)
%   Returns an array with as many rows as the array NODES, containing index
%   number of each connected component of the graph. If the graph is
%   totally connected, returns an array of 1.
%
%   Example
%       nodes = rand(6, 2);
%       edges = [1 2;1 3;4 6];
%       labels = grLabel(nodes, edges);
%   labels =
%       1
%       1
%       1
%       2
%       3
%       2   
%
%   See also
%   getNeighbourNodes
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2007-08-14,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

% init
Nn = size(nodes, 1);
labels = (1:Nn)';

% iteration
modif = true;
while modif
    modif = false;
    
    for i=1:Nn
        neigh = getNeighbourNodes(i, edges);
        neighLabels = labels([i;neigh]);
        
        % check for a modification
        if length(unique(neighLabels))>1
            modif = true;
        end
        
        % put new labels
        labels(ismember(labels, neighLabels)) = min(neighLabels);
    end
end

% change to have fewer labels
labels2 = unique(labels);
for i=1:length(labels2)
    labels(labels==labels2(i)) = i;
end


function nodes2 = getNeighbourNodes(node, edges)
%GETNEIGHBOURNODES find nodes adjacent to a given node
%
%   NEIGHS = getNeighbourNodes(NODE, EDGES)
%   NODE: index of the node
%   EDGES: the complete edges list
%   NEIGHS: the nodes adjacent to the given node.
%
%   NODE can also be a vector of node indices, in this case the result is
%   the set of neighbors of any input node.
%
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 16/08/2004.
%

%   HISTORY
%   10/02/2004 documentation
%   13/07/2004 faster algorithm
%   03/10/2007 can specify several input nodes

[i, j] = find(ismember(edges, node));
nodes2 = edges(i,1:2);
nodes2 = unique(nodes2(:));
nodes2 = sort(nodes2(~ismember(nodes2, node)));

function curves = graph2Contours(nodes, edges)
%GRAPH2CONTOURS convert a graph to a set of contour curves
% 
%   CONTOURS = GRAPH2CONTOURS(NODES, EDGES)
%   NODES, EDGES is a graph representation (type "help graph" for details)
%   The algorithm assume every node has degree 2, and the set of edges
%   forms only closed loops. The result is a list of indices arrays, each
%   array containing consecutive point indices of a contour.
%
%   To transform contours into drawable curves, please use :
%   CURVES{i} = NODES(CONTOURS{i}, :);
%
%
%   NOTE : contours are not oriented. To manage contour orientation, edges
%   also need to be oriented. So we must precise generation of edges.
%
%   -----
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 05/08/2004.
%


curves = {};
c = 0;

while size(edges,1)>0
	% find first point of the curve
	n0 = edges(1,1);   
    curve = n0;
    
    % second point of the curve
	n = edges(1,2);	
	e = 1;
    
	while true
        % add current point to the curve
		curve = [curve n];        
		
        % remove current edge from the list
        edges = edges((1:size(edges,1))~=e,:);
		
		% find index of edge containing reference to current node
		e = find(edges(:,1)==n | edges(:,2)==n);		    
        e = e(1);
        
		% get index of next current node
        % (this is the other node of the current edge)
		if edges(e,1)==n
            n = edges(e,2);
		else
            n = edges(e,1);
		end
		
        % if node is same as start node, loop is closed, and we stop 
        % node iteration.
        if n==n0
            break;
        end
	end
    
    % remove the last edge of the curve from edge list.
    edges = edges((1:size(edges,1))~=e,:);
    
    % add the current curve to the list, and start a new curve
    c = c+1;
    curves{c} = curve;
end