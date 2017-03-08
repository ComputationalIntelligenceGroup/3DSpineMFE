classdef newsfe
    %NEWSFE Creates a new Spine Feature Extractor (sfe) object.
    %Using this tool, dendritic spines can be processed, repaired, computed
    %their level curves and extracted their features.
    %
    %   sfe = NEWSFE(outputPath)
    %
    %   Input parameters:
    %       - outputPath character-vector : Path of the folder where
    %           outputs of this algorithm will be saved.
    %
    %   Output parameters:
    %       - sfe Object : A new spine feature extractor object.
    %
    %Author: Luengo-Sanchez, S.
    %Author: Juez-Gil, M.
    
    properties (Constant)
        %Folder name where unzipped dendrite TIF images will be saved.
        OUTPUT_PATH_TIF = 'DENDRITE_TIF';
        %Folder name where unzipped dendrite VRML files will be saved.
        OUTPUT_PATH_VRML = 'DENDRITE_VRML';
        %Folder name where unzipped dendrite insertion points will be saved.
        OUTPUT_PATH_IPOINTS = 'DENDRITE_INSERTION_POINTS_VRML';
        %Folder name where stacked dendrite TIF images will be saved.
        %OUTPUT_PATH_STACK_TIF = 'DENDRITE_STACK_TIF';
        %Folder name where spine .MAT files will be saved.
        OUTPUT_PATH_MAT = 'SPINE_MAT';
        %Folder name where repaired spines will be saved.
        OUTPUT_PATH_REPAIRED = 'SPINE_REPAIRED';
        %Folder name where spines with repaired neck will be saved.
        OUTPUT_PATH_NECK_REPAIRED = 'SPINE_NECK_REPAIRED';
        %File name for saving the paths of correct spines.
        OUTPUT_FILE_CORRECT_SPINES_PATHS = 'CORRECT_SPINES_PATHS.txt';
        %File name for saving the paths of partially fragmented spines.
        OUTPUT_FILE_PARTIALLY_FRAGMENTED_SPINES_PATHS = 'PARTIALLY_FRAGMENTED_SPINES_PATHS.txt';
        %File name for saving the paths of fragmented spines.
        OUTPUT_FILE_FRAGMENTED_SPINES_PATHS = 'FRAGMENTED_SPINES_PATHS.txt';
        %Default file name for saving the extracted features
        OUTPUT_FILE_FEATURES_CSV = 'EXTRACTED_FEATURES.csv';
    end
    
    properties (Access = private)
        OutputPath
    end
    
    methods 
        function obj = newsfe(outputPath)
            exception = MException('NEWSFE:BadParameter','Unable to create Spine feature extractor');
            if(isdir(outputPath))
                obj.OutputPath = outputPath;
            else
                cause = MException('NEWSFE:BadOutputPath', 'Output path is not a folder');
                exception = addCause(exception, cause);
                throw(exception);
            end
        end
        
        function MAT_folder = processSpines(obj, root_TIF, root_VRML)
            %Processes spine TIF and VRML files to obtain spine .MAT files.
            %Given dendrite TIF images and dendrite VRML files, dendritic
            %spines .MAT files are generated.
            %
            %Usage:
            %   MAT_folder = sfe.PROCESSSPINES(root_TIF, root_VRML)
            %
            %   Input parameters:
            %       - root_TIF character-vector : Path to the dendrite TIF
            %           files, can be a .ZIP file or a folder.
            %       - root_VRML character-vector : Path to the dendrite
            %           VRML files, can be a .ZIP file or a folder.
            %
            %   Output parameters:
            %       - MAT_folder character-vector : Path to the folder with
            %           generated MAT files of spines.
            %
            %See also PROCESS_VRMLS
            
            TIF_folder = obj.getFolder(root_TIF, obj.OUTPUT_PATH_TIF);
            %stack_TIF_folder = obj.createOutputFolder(obj.OUTPUT_PATH_STACK_TIF);
            %tif_images_to_stack(TIF_folder, stack_TIF_folder);
            
            VRML_folder = obj.getFolder(root_VRML, obj.OUTPUT_PATH_VRML);
            MAT_folder = obj.createOutputFolder(obj.OUTPUT_PATH_MAT);
            process_VRMLs(VRML_folder, TIF_folder, MAT_folder);
        end
        
        function neck_repaired_folder = repairSpines(obj, root_MAT, root_insertion_points, repair_neck)
            %Repairs fragmented spines and neck of the spines.
            %A spine is fragmented when the VRML 3D model contains more
            %than one part. Reparation process is to try to merge all parts
            %into one.
            %
            %There are three fragmentation levels, correct, partially
            %fragmented and fragmented. Reparation process will generate
            %three files in the output folder containing the paths of the
            %spines depending their fragmentation level. Filenames are as
            %follows:
            %   - CORRECT_SPINES_PATHS.txt for correct ones.
            %   - PARTIALLY_FRAGMENTED_SPINES_PATHS.txt for partially
            %       fragmented ones.
            %   - FRAGMENTED_SPINES_PATHS.txt for fragmented ones.
            %
            %Repaired spines will be saved in the output folder into a
            %folder called SPINE_REPAIRED.
            %
            %This process also performs spine neck reparation which is to
            %rebuild the neck of those spines which do not appear to be
            %attached to the dendrite. Spines with repaired neck will be
            %saved in the output folder into a folder called
            %SPINE_NECK_REPAIRED.
            %
            %Usage:
            %   neck_repaired_folder = 
            %       sfe.REPAIRSPINES(root_MAT, root_ipoints, repair_neck)
            %
            %   Input parameters:
            %       - root_MAT character-vector : Path to the spines .MAT
            %           files, can be a .ZIP file or a folder.
            %       - root_ipoints character-vector : Path to the dendrite
            %           insertion points VRML files, can be a .ZIP file or
            %           a folder.
            %
            %   Output parameters:
            %       - neck_repaired_folder character-vector : Path to the
            %           folder with repaired spines.
            %
            %See also CLASSIFY_FRAGMENTED_SPINES, REPAIR_FRAGMENTATION,
            %REALLOCATE_SPINE, REPAIR_NECK
            
            MAT_folder = obj.getFolder(root_MAT, obj.OUTPUT_PATH_MAT);
            spines_correct_file = [obj.OutputPath filesep obj.OUTPUT_FILE_CORRECT_SPINES_PATHS];
            spines_pfragmented_file = [obj.OutputPath filesep obj.OUTPUT_FILE_PARTIALLY_FRAGMENTED_SPINES_PATHS];
            spines_fragmented_file = [obj.OutputPath filesep obj.OUTPUT_FILE_FRAGMENTED_SPINES_PATHS];
            classify_fragmented_spines(MAT_folder, spines_correct_file, spines_pfragmented_file, spines_fragmented_file);
            
            repaired_folder = [obj.OutputPath filesep obj.OUTPUT_PATH_REPAIRED];
            repair_fragmentation(spines_pfragmented_file, spines_fragmented_file, spines_correct_file, repaired_folder, MAT_folder);
            
            reallocate_spine(repaired_folder);
            
            insertion_points_folder = obj.getFolder(root_insertion_points, obj.OUTPUT_PATH_IPOINTS);
            neck_repaired_folder = [obj.OutputPath filesep obj.OUTPUT_PATH_NECK_REPAIRED];
            repair_neck(repaired_folder, insertion_points_folder, neck_repaired_folder);
        end
        
        function computeLevelCurves(obj, root_neck_repaired, num_curves, remove_auto, threshold)
            %Computes spine level curves.
            %Spine level curves are computed as a definition of the
            %morphology of the spine. This curves are useful to extract
            %spine features and also to be able to rebuild the spine.
            %
            %In this step, those spines which are considered bad (double
            %curve defect) can be removed automatically or manually.
            %
            %Usage:
            %   sfe.COMPUTELEVELCURVES(root_neck_repaired, num_curves,
            %   remove_auto, threshold)
            %
            %   Parameters:
            %       - root_neck_repaired character-vector : Path to the
            %           folder with repaired spines used to calculate their
            %           level curves.
            %       - num_curves integer : Number of computed level curves.
            %       - remove_auto boolean : If is TRUE, those spines with
            %           double curve defect will be removed automatically,
            %           otherwise user will be asked for removing spines
            %           which could present double curve defect.
            %       - threshold double : Used to decide when double curve
            %       	defect exists. The smaller the threshold value, the
            %       	more the number of double curve defects detected.
            %
            %See also COMPUTE_LEVEL_CURVES,
            %REMOVE_DOUBLE_CURVATURE_MANUALLY
            
            neck_repaired_folder = obj.getFolder(root_neck_repaired, obj.OUTPUT_PATH_NECK_REPAIRED);
            if remove_auto
                compute_level_curves(neck_repaired_folder, num_curves, remove_auto, threshold);
            else
                compute_level_curves(neck_repaired_folder, num_curves, false);
                remove_double_curvature_manually(neck_repaired_folder, threshold);
            end
        end
        
        function extractFeatures(obj, root_neck_repaired, output_csv_filename)
            %Computes and extracts spine features.
            %Features are saved to a CSV file. Each row contains features
            %of one spine.
            %
            %Computed features (some of them, like height, or ellipse axes
            %produce many features):
            %   - Height.
            %   - Major axis of ellipse.
            %   - Minor axis of ellipse.
            %   - Radio between sections.
            %   - Growing direction of the spine.
            %   - Instant direction.
            %   - Volume.
            %   - Volume of each region.
            %
            %Usage:
            %   sfe.extractFeatures(root_neck_repaired,
            %   output_csv_filename)
            %
            %   Parameters:
            %       - root_neck_repaired character-vector : Path to the
            %           folder that contains repaired spines with computed
            %           level curves used to compute their features.
            %       - output_csv_filename character-vector : The name of
            %           the output CSV file with all computed features.
            %           This parameter is optional, if not set, the output
            %           file name will be EXTRACTED_FEATURES.csv 
            %
            %See also COMPUTE_FEATURES
            
            if ~exist('output_csv_filename','var')
                compute_features(root_neck_repaired, [obj.OutputPath filesep obj.OUTPUT_FILE_FEATURES_CSV]);
            else
                compute_features(root_neck_repaired, output_csv_filename);
            end
        end
        
        function runAll(obj, root_TIF, root_VRML, root_ipoints, num_curves, remove_auto, threshold, output_csv_filename)
            %Runs all steps of feature extraction algorithm. 
            %Spines will be processed, repaired, computed their level
            %curves and extracted their features.
            %
            %Usage:
            %   sfe.runAll(root_TIF, root_VRML, root_ipoints, num_curves,
            %   remove_auto, threshold, output_xls_filename)
            %
            %   Parameters:
            %       - root_TIF character-vector : Path to the dendrite TIF
            %           files, can be a .ZIP file or a folder.
            %       - root_VRML character-vector : Path to the dendrite
            %           VRML files, can be a .ZIP file or a folder.
            %       - root_ipoints character-vector : Path to the dendrite
            %           insertion points VRML files, can be a .ZIP file or
            %           a folder.
            %       - num_curves integer : Number of computed level curves.
            %       - remove_auto boolean : If is TRUE, those spines with
            %           double curve defect will be removed automatically,
            %           otherwise user will be asked for removing spines
            %           which could present double curve defect.
            %       - threshold double : Used to decide when double curve
            %       	defect exists. The smaller the threshold value, the
            %       	more the number of double curve defects detected.
            %       - output_csv_filename character-vector : The name of
            %           the output CSV file with all computed features.
            %           This parameter is optional, if not set, the output
            %           file name will be EXTRACTED_FEATURES.csv 
            %
            %See also NEWSFE/PROCESSSPINES, NEWSFE/REPAIRSPINES,
            %NEWSFE/COMPUTELEVELCURVES, NEWSFE/EXTRACTFEATURES
            
            MAT_folder = obj.processSpines(root_TIF, root_VRML);
            neck_repaired_folder = obj.repairSpines(MAT_folder, root_ipoints);
            obj.computeLevelCurves(neck_repaired_folder, num_curves, remove_auto, threshold);
            if ~exist('output_csv_filename','var')
                obj.extractFeatures(neck_repaired_folder);
            else
                obj.extractFeatures(neck_repaired_folder, output_csv_filename);
            end
        end
        
    end
    
    methods (Access = private)
        
        function folder = getFolder(obj, path, outputPath)
            %Gets an input folder, if a .ZIP is given, a new folder will be
            %created and the file will be uncompressed there.
            folder = path;
            if obj.isZip(path)
                folder = obj.createOutputFolder(outputPath);
                unzip(path, folder);
            else
                if ~exist(path,'dir')
                    exception = MException('GETFOLDER:DirNotExists','Input file/folder does not exists.');
                    throw(exception);
                end
            end
        end
        
        function output_folder_path = createOutputFolder(obj, folder_name)
            % Creates an output folder if does not exists before.
            output_folder_path = [obj.OutputPath filesep folder_name];
            if(exist(output_folder_path, 'dir') ~= 7)
                mkdir(output_folder_path);
            end
        end
        
    end
    
    methods(Static, Access = private)
        
        function ok = isZip(zip_file_path)
            % Checks if the file is a .zip.
            ok = false;
            [~, ~, ext] = fileparts(zip_file_path);
            if exist(zip_file_path, 'file')
                if strcmpi(ext, '.ZIP')
                    ok = true;
                end
            end   
        end
        
    end
    
end