% script for launching makeEducationSet according to specified period

% takes long time, needed to find interval and make regex according to it
% names = utils.getFilesByTime('seismic_data/covid_time', [63754985264.457993 63755262509.273994]);
makeEducationSet('seismic_data\covid_time\AZT-20201024T083856Z-003\AZT', true, '.+\\AZT_AZT_200625_228903[0-2]\\.+([01][0-9]|2[0-6])\.adb');