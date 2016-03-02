function Params = DefaultPulsePalParameters
Params = struct;
Params.IsBiphasic = zeros(1,4);
Params.Phase1Voltage = ones(1,4)*5;
Params.Phase2Voltage = ones(1,4)*-5;
Params.RestingVoltage = ones(1,4)*0;
Params.Phase1Duration = ones(1,4)*0.001;
Params.InterPhaseInterval = ones(1,4)*0.001;
Params.Phase2Duration = ones(1,4)*0.001;
Params.InterPulseInterval = ones(1,4)*0.01;
Params.BurstDuration = zeros(1,4);
Params.InterBurstInterval = zeros(1,4);
Params.PulseTrainDuration = ones(1,4);
Params.PulseTrainDelay = zeros(1,4);
Params.LinkTriggerChannel1 = ones(1,4);
Params.LinkTriggerChannel2 = zeros(1,4);
Params.CustomTrainID = zeros(1,4);
Params.CustomTrainTarget = zeros(1,4);
Params.CustomTrainLoop = zeros(1,4);
Params.TriggerMode = zeros(1,2);