%Function to remove manually those spines that could present double
%curvature problem. Spines are render one by one and user must select if
%the spine has to be removed depending on the degree of separation between
%the two curves. For each spine the program ask to the user if he wants to
%continue (Press Enter) or if the spine must be deleted (Press D and then
%Enter).


%Input parameters:
%    root_spines_neck_repaired_path: The path to the repaired spines are
%    placed. Curves must be computed previously.
%    threshold: A value that represents the distance between the two sets
%    of points dictaminated by a hierarchical cluster. Default value is 2.
function remove_double_curvature_manually(root_spines_neck_repaired_path,threshold)
    if (nargin<2 & exist('root_spines_neck_repaired_path','var'))
        threshold=2;
    end

    [spine_path,~]=detect_double_curve(root_spines_neck_repaired_path,threshold);
    spine_path=unique(spine_path);
    for(i=1:length(spine_path))
        spine_data=load(spine_path{i});
        repaired_spine=spine_data.repaired_spine;
        curve=spine_data.curve;
       
        patch('Vertices',repaired_spine.vertices,'Faces',repaired_spine.faces,'facealpha',0.2)
        axis equal
        hold on
        for j=1:size(curve,2)
            scatter3(curve{j}(:,1),curve{j}(:,2),curve{j}(:,3),'fill');
        end
        
        disp(['Spine: ' spine_path{i} ' could present double curve problem']);
      
        show=input('Press ENTER to render next spine or D+Enter  to delete current spine: ','s');
        if(strcmp('d',lower(show)))
            delete(spine_path{i});
            disp(['Spine: ' spine_path{i} ' has been removed']);
        end
        if(strcmp('e',lower(show)))
            break;
        end
        close('all');
    end
end
