%% Load specific settings for all pulse pals!
%dp 6/9/2021
%this loads the ~same settings for every connected pulse pal~, but with changes to code could
%identify specific ones and load differently based on COM port

%% First, choose the .mat file with the ParameterMatrix you want to load
%(you can make one of these using the PulsePalGUI() function and
%saving that file)

load(uigetfile); %this will load the ParameterMatrix variable


%% Then identify all of the connected pulse pals
ports = FindPulsePalPorts



%% Finally,upload the parameters for each pulse pal
%loop through each COM port, connect to pulse pal, upload parameters, ensure success,
%and then terminate connection
success= zeros(size(ports)); %this will be used to check for errors (0=error, 1=success)
for thisPort= ports
    PulsePal(thisPort);
    
    success(strcmp(ports,thisPort))=ProgramPulsePal(ParameterMatrix); %'success' here will keep track of output for each port (1=success, 0=error)

    EndPulsePal();
end

%check for errors and display any ports with error
  
if sum(success==0)>0 %if any invalid values found, report error
   disp('~~~ERROR~~~~ for port:')
   ports(success==0)    
else
    disp('all done!');
end