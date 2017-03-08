sfe = newsfe('E:\HBP\Espinas\data_1');
MAT_folder = sfe.processSpines('E:\HBP\Espinas\data_1\zip\ROOT_TIFs.zip', 'E:\HBP\Espinas\data_1\zip\ROOT_VRMLs.zip');
neck_repaired_folder = sfe.repairSpines(MAT_folder, 'E:\HBP\Espinas\data_1\zip\ROOT_insertion_points.zip');
sfe.computeLevelCurves(neck_repaired_folder, 8, true, 2);
sfe.extractFeatures(neck_repaired_folder);

disp('running data2');

sfe = newsfe('E:\HBP\Espinas\data_2');
sfe.runAll('E:\HBP\Espinas\data_2\ROOT_TIFs', 'E:\HBP\Espinas\data_2\ROOT_VRMLs', 'E:\HBP\Espinas\data_2\ROOT_insertion_points', 8, false, 0);