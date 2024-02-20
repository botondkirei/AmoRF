function REC=DCR(~)
%[1] build the RF blocks with nonidealities
%   [1.1] The Band Pass Filter (BPF)

        % [1.1.1] Frequency selectivity of the BPF
        Flt.b=1;
        Flt.a=1;
        fsBPF=FreqSelClass('FreqSelect',Flt);
        % [1.1.2] Adding NonlinearityClass to implement the gain of DBF
        nlBPF=NonlinearityClass('Gain');
        nlBPF.A1 = 10^(-3/20); 
        nlBPF.A3 = 10^(-15/20);
        % [1.1.3] Instanciating a wrapper class for the BPF and adding the
        % nonidealities to it
        BPF = BlockClass('BPF');
        BPF.Zout=50;
        BPF.Znext=50;
        BPF.add(nlBPF);
        BPF.add(fsBPF);
        
%   [1.2] The Low Noise Amplifier (LNA)
        % [1.2.2] Nonlinearity of the LNA
        nlLNA=NonlinearityClass('Gain');
        nlLNA.A1 = 10^(15/20); %15 dB
        nlLNA.A3 = 10^(-15/20); % add third order component
        % [1.2.3] Instanciating a wrapper class for the LNA and adding the
        % nonidealities to it
        LNA = BlockClass('LNA');
        LNA.add(nlLNA);
        
    %[1.3] Mixer (MIX)
        % [1.3.1] Nonlinearity in MIX
        nlMIX=NonlinearityClass('Gain');
        nlMIX.A1 = 10^(20/20); %20 dB
        nlMIX.A3 = 0.001; % no third order component
        % [1.3.2] I/Q imbalance in Mix
        iqMIX = IQImbalClass('IQImbalance');
        iqMIX.g=1.1;
        iqMIX.phi=10;
        % [1.3.3] CFO in MIX
        cfoMIX=FreqConvClass('CFO');
        cfoMIX.Offset=1e6;
        % [1.3.5] Instanciating a wrapper class for the MIX and adding the
        % nonidealities to it
        MIX = BlockClass('MIX');
        MIX.add(nlMIX);
        MIX.add(cfoMIX);
        MIX.add(iqMIX);
        
    % [1.4] Low Pass Filter (LPF)
        % [1.4.1] Nonlinearity of the LPF
        nlLPF=NonlinearityClass('Gain');
        nlLPF.A1 = 1; %1 dB
        nlLPF.A3 = 0.001; % no third order component
        % [1.4.2] Frequency selectivity

        %fsLPF.Flt=fir1(10,0.4e7/1.82857e7*2);
        %[b,a]=cheby2(6, 50, 0.15);
        load lowpassfilter.mat;
        Flt.a=a;
        Flt.b=b;
        fsLPF=FreqSelClass('FreqSelect',Flt);
        % [1.4.3]  Instanciating a aggregate object for  LPF and adding the
        % nonidealities to it
        LPF = BlockClass('LPF');
        LPF.add(nlLPF);
        LPF.add(fsLPF);

%   [1.5] The Automatic Gain Control (AGC)Block
        % [1.2.1] Nonlinearity of the LNA
        nlAGC=NonlinearityClass('Gain');
        nlAGC.A1 = 10^(25/20); %25 dB
        nlAGC.A3 = 0.0001; % no third order component
        % [1.2.2] Instanciating a wrapper class for the LNA and adding the
        % nonidealities to it
        AGC = BlockClass('AGC');
        AGC.add(nlAGC);

        % [2] Build the receiver
    REC = TunerClass('DCR');
    REC.add(BPF);
    REC.add(LNA);
    REC.add(MIX);
    REC.add(LPF);
    REC.add(AGC);
    % Display structure
    %proba(REC.getstructure);
% [3] Generate an input signal and runit trough the receiver
   % s=SignalClass(randn(10000,1)+1i*randn(10000,1),1);
   % s=effect(REC,s);
