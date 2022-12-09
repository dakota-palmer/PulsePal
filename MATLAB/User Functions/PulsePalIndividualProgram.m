%% Load specific settings for all pulse pals!
%dp 9/28/21
%this loads ~specific settings for individual pulse pal channels~
%currently choose either 10s or 1s for each box (ch1= boxA; ch3=boxB)
%a .mat will also be saved containing pulse pal parameters with datetime
saveDir= 'C:\MED-PC\Data\_pulsepal_params\'

%% WARNING ~~~~~~~~~~~~~~

%-- -NEED TO MAKE SURE COMs MATCH BOXES (in pals table) ----

% COMs seem to be determined by order of devices plugged into PC
% so if pulse pals are disconnected and reconnected the COM # may change
% and you need to make sure the correct boxes are defined for each COM

%% Define the parameters you want to have running for each box!!!
%keep track of virus so can change frequency based on virus (e.g. chr2 stimulation may want 20hz
%instead of continuous for stgtacr inhibition)
% stimBoxes= [5,6,9,10] %non continuous, pulse train
% inhibBoxes= [4,8] %continuous
% 
% 
% %for now simply choosing between 1s or 10s durations
% oneSecBoxes= [4,5,6,9,10]%[1,2,4,5,6,7,8,9,11,3,10,12];
% tenSecBoxes= [8]   %[3,10,12];
% 
% %define frequency in hz you want for non-continuous laser delivery
% pulseFreq= 20 %hz

stimBoxes= [7,9,10,11] %non continuous, pulse train
inhibBoxes= [3,8] %continuous

%for now simply choosing between 1s or 10s durations
oneSecBoxes= [7,8,9,10,11]%[1,2,4,5,6,7,8,9,11,3,10,12];
tenSecBoxes= [3]   %[3,10,12];

%define frequency in hz you want for non-continuous laser delivery
pulseFreq= 40 %hz


%interpulse interval will be calculated based on hz defined above
ipi= 1/pulseFreq


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

%TODO: Box 6 is not accepting parameters for some reason? may need to
% manually change it
pals.boxA= [3,5,9,7,11,1]';
pals.boxB= [4,6,10,8,12,2]';

% % 2022-12-09 discovered COMs 4 and 6 were swapped so changing to update
% pals.boxA= [3,7,9,5,11,1]';
% pals.boxB= [4,8,10,6,12,2]';

pals.params= cell(6,1,1)

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
          %change to noncontinuous pulse train if stimBox
           if ismember(box,stimBoxes)
               paramUpload{5,2}= 0.01; %10ms pulse width
               paramUpload{8,2}= ipi; %inter pulse interval, defined at beginning based on frequency in hz
               paramUpload{9,2}= 1; %1s long 'train'
               paramUpload{11,2}= 1; %1s long 'burst' containing train
           end
       elseif ismember(box,tenSecBoxes)
           %set durations to 10s
           %channel 1 for boxA
           paramUpload{5,2}=10;
           paramUpload{11,2}= 10;
           if ismember(box,stimBoxes)
               paramUpload{5,2}= 0.01; %10ms pulse width
               paramUpload{8,2}= ipi; %inter pulse interval, defined at beginning based on frequency in hz
               paramUpload{9,2}= 10; %1s long 'train'
               paramUpload{11,2}= 10; %1s long 'burst' containing train
           end
           
       elseif ~ismember(box,oneSecBoxes) & ~ismember(box, tenSecBoxes)
           %if this box is left out of both lists, set durations to nan?
           paramUpload{5,2}= nan;
           paramUpload{11,2}= nan;
       end
       
    end
    
    for box= table2array(pals(strcmp(pals.ports,thisPort),'boxB'))
       if ismember(box,oneSecBoxes)
           %set durations to 1s
           %channel 3 for boxB
           paramUpload{5,4}=1;
           paramUpload{11,4}= 1; 
          %change to noncontinuous pulse train if stimBox
           if ismember(box,stimBoxes)
               paramUpload{5,4}= 0.01;
               paramUpload{8,4}= ipi;
               paramUpload{9,4}= 1;
               paramUpload{11,4}= 1;
           end
       elseif ismember(box,tenSecBoxes)
           %set durations to 10s
           %channel 3 for boxB
           paramUpload{5,4}=10;
           paramUpload{11,4}= 10;
           if ismember(box,stimBoxes)
               paramUpload{5,4}= 0.01;
               paramUpload{8,4}= ipi;
               paramUpload{9,4}= 10;
               paramUpload{11,4}= 10;
           end
       elseif ~ismember(box,oneSecBoxes) & ~ismember(box, tenSecBoxes)
           %if this box is left out of both lists, set durations to nan?
           paramUpload{5,4}= nan;
           paramUpload{11,4}= nan;
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
