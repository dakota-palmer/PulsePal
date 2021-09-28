%% Load specific settings for all pulse pals!
%dp 9/28/21
%this loads specific settings for individual pulse pal channels
%currently choose either 10s or 1s for each box (ch1= boxA; ch3=boxB)
%a .mat will also be saved containing pulse pal parameters with datetime
saveDir= 'C:\MED-PC\Data\_pulsepal_params\'

%% Load a parameter matrix file as a template
paramTemplate= load('C:\Users\Univ. of Minnesota\Documents\PulsePal\MATLAB\STGTACR_10s_continuous_pulseGated.mat')
paramTemplate= paramTemplate.ParameterMatrix

%% Then identify all of the connected pulse pals
pals= table();

ports = FindPulsePalPorts;

pals.ports= ports';

%% Define COMs corresponding to boxes/pulse pals
%box 1&2= COM8
%box 3&4= COM3
%box 5&6= COM4
%box 7&8= COM6
%box 9&10= COM5
%box 11&12= COM7

pals.boxA= [3,5,9,7,11,1]';
pals.boxB= [4,6,10,8,12,2]';
pals.params= cell(6,1,1)


%% Define the parameters you want to have running for each box!!!

oneSecBoxes= [1,2,3,4,5,6];
tenSecBoxes= [7,8,9,10,11,12];

%% initialize a struct to keep track of parameters for each box (will save
%them so that we know the settings were correctly set and can review if needed later)
pulsePalParams= cell(13,2,1)
pulsePalParams(1,1)= {'box'}
pulsePalParams(1,2)= {'ParameterMatrix'}
% pulsePalParams{[1:12],1}= [1,2,3,4,5,6,7,8,9,10,11,12]';

%% Assign correct parameters
%for each pulse pal go through and 
%determine which I/O this box belongs to (A or B)
%then, change settings based on template and upload accordingly

success= zeros(size(ports)); %this will be used to check for errors (0=error, 1=success)

for thisPort= ports
    PulsePal(thisPort); 
    paramUpload= paramTemplate;

    for box= table2array(pals(strcmp(pals.ports,thisPort),'boxA'))
       if ismember(box,oneSecBoxes)
           %set durations to 1s
           %channel 1 for boxA
           paramUpload{5,2}=1;
           paramUpload{11,2}= 1;           
       elseif ismember(box,tenSecBoxes)
           %set durations to 10s
           %channel 1 for boxA
           paramUpload{5,2}=10;
           paramUpload{11,2}= 10;
       end      
    end
    
    for box= table2array(pals(strcmp(pals.ports,thisPort),'boxB'))
       if ismember(box,oneSecBoxes)
           %set durations to 1s
           %channel 3 for boxB
           paramUpload{5,4}=1;
           paramUpload{11,4}= 1;           
       elseif ismember(box,tenSecBoxes)
           %set durations to 10s
           %channel 3 for boxB
           paramUpload{5,4}=10;
           paramUpload{11,4}= 10;
       end      
    end
    %save settings
    pals(strcmp(pals.ports,thisPort),'params')= {paramUpload};
   
    %upload settings to this pal and disconnect
    success(strcmp(ports,thisPort))=ProgramPulsePal(paramUpload); %'success' here will keep track of output for each port (1=success, 0=error)
    EndPulsePal();
end

%check for errors and display any ports with error
  
if sum(success==0)>0 %if any invalid values found, report error
   disp('~~~ERROR~~~~ for port:')
   ports(success==0)    
else
    disp('all done!');
end

%% save the pals.mat so we can review parameters if needed later
dateStr = datetime('now', 'Format','yyyy_MM_dd_HH_mm');
dateStr=char(dateStr);

save(strcat(saveDir,dateStr, '_pulsepal_params.mat'), 'pals'); %the second argument here is the variable being saved, the first is the filename
