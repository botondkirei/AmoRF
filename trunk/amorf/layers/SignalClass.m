% SignalClass The class for the 'signals' in amoRF toolbox
%
%    This class is due to the abstraction of the 'signal' notion. It is
%    derived form BaseClass.
%
% SignalClass properties:
%   Samples - Signal samples.
%   Fs - Sampling frequency of the samples
%   Fc - Center frecuency
%   Domain - Time of Frequncy
%   SNR - Signal-to-noise-ration of the stored signal.
%   
% SignalClass methods:
%   SignalClass - Constructor
% 	flip - Reverse signal samples
%	power - Measure the power of signal
%	length - Signal length 
%	plot - Plot signal
%	dB - Amplitude spectrum of signal in decibels
%	dBm - Amplitude spectrum of signal in dBm.
%	phase - Phase spectrum of the signal
%	freq - Set Domain to 'Frequency'
%	time - Set Domain to 'Time'
%	operations - arithmetic operations
%
% SignalClass parents:
%   BaseClass - Superclass of amoRF toolbox.
%
% See also: BaseClass, AttributeClass, BlockClass, TunerClass.

classdef SignalClass 
%% SignalClass
% Parent class: <BaseClass.html BaseClass>.
% SignalClass is one of the basic and most often used class by amoRF
% toolbox. This class is due to the abstraction of the 'signal' notion. 

%% Properties
% * <SignalClass.html#6 Samples>
% * <SignalClass.html#7 Fs>
% * <SignalClass.html#8 Fc>
% * <SignalClass.html#9 Domain>
% * <SignalClass.html#10 SNR>
% * <SignalClass.html#11 Name>
%
%% Methods
% * <SignalClass.html#13 SignalClass>
% * <SignalClass.html#14 power>
% * <SignalClass.html#15 length>
% * <SignalClass.html#16 plot>
% * <SignalClass.html#17 dB>
% * <SignalClass.html#18 dBm>
% * <SignalClass.html#19 phase>
% * <SignalClass.html#20 freq>
% * <SignalClass.html#21 time>
% * <SignalClass.html#22 operations>
%
    properties (Access = public)
        % A signal is composed of useful samples, noise (this is white
        % noise) and components due to nonlinearity. The intention is to
        % hide these components from the user, but the models will alter
        % their values using the public functions SignalClass@addSamples,
        % SignalClass@addNoise and SignalClass@addNonlin
        samples
        noise
        nonlinear
    end
    properties
        % The sampling frequency of the signal.
        Fs   
        %% Fs (or Bw)
        % The sampling frequency of the signal.
        %
        % <html>
        % <table border=1>
        % <tr><td>Model</td><td>Fs Behavior</td></tr>        
        % <tr><td>Passband</td><td>Fs is the sampling frequency of the signal</td></tr>        
        % <tr><td>Baseband</td><td>Fs stores the bandwidth of a baseband signal</td></tr>
        % </table>
        % </html>
        %
        
        % Center frequency.
        Fc=0 
        %% Fc
        % Center frequency - The amoRF allows both passband and baseband
        % (a.k.a.) lowpass equivalent models. The default value of *Fc* is
        % equal to 0 Hz, meaning the signal is a passband signal. Setting
        % *Fc* to a non-zero value will result in a lowpass equivalent signal. 
        
        % Domain property is used by the plot@SignalClass method.
        Domain='time'
        %% Domain
        % This property is used by the *plot* method of a signal object.
        %
        % <html>
        % <table border=1>
        % <tr><td>Domain</td><td>Behavior</td></tr>        
        % <tr><td>'Time'</td><td>The signal is plotted in the time domain</td></tr>        
        % <tr><td>'Frequency'</td><td>The signal is plotted in the frequency domain</td></tr>
        % </table>
        % </html>
        % 
        % Default value is 'time'
 
        %Name of the the object. Default values is empty string.
        Name=''
        %% Name
        %
        % Name of the the object. Default values is empty string.  

    end
    methods
        %% SignalClass 
        % The constructor function. When a SignalClass object is
        % initialized, the thermal noise floor is also added to the signal. 
        % The thermal noise floor is computed on a 1 Ohm impedance, 1 Hz
        % noise bandwidth at room temperature (300 Kelvin). This gives a
        % teoretical limit of -174 dBm noise floor.
        %
        %  OBJ=SignalClass(OBJECT);
        %
        % The copy constructor of SignalClass. The return
        % values |OBJ| is a copy of |OBJECT| that belongs to SignalClass.
        %
        %  OBJ=SignalClass(SAMPLES, FS)
        %
        % The input |SAMPLES| is recommended to be a column vector. |FS| is
        % a scalar value of the signal's sampling frequency. By default the
        % central frequency *Fc* property is set to 0 Hz. This constructor 
        % is recommended to be used for passband signal model.
        %
        %  OBJ=SignalClass(SAMPLES, BW, FC)
        %
        % This form of the constructor should be used to instantiate a 
        % baseband signal. |BW| is the bandwidth of the signal, |FC| the
        % central frequency and |SAMPLES| are the signal samples. 
        function obj=SignalClass(varargin)
        % SignalClass/SignalClass constructor function.  When a SignalClass
        % object is initialized, the thermal noise floor is also added to 
        % the signal. The thermal noise floor is computed on a 1 Ohm 
        % impedance, 1 Hz noise bandwidth at room temperature (300 Kelvin).
        % This gives a teoretical limit of -174 dBm noise floor.
        %
        %   OBJ=SignalClass(OBJECT) - The copy constructor of SignalClass.
        %   The return values OBJ is a copy of OBJECT that belongs to
        %   SignalClass. 
        %
        %	OBJ=SignalClass(SAMPLES, FS) -  The input SAMPLES is
        %	recommended to be a column vector. FS is a scalar value of
        %	the signal's sampling frequency. By default the central
        %	frequency Fc property is set to 0 Hz. This constructor is
        %	recommended to be used for passband signal model. 
        %
        %   OBJ=SignalClass(SAMPLES, BW, FC) - This form of the constructor
        %   should be used to instantiate a baseband signal. BW is the
        %   bandwidth of the signal, FC the central frequency and SAMPLES 
        %   are the signal samples.
        %
        % See also: SignalClass/flip, SignalClass/length, SignalClass/plot,
        % SignalClass/dB, SignalClass/phase, SignalClass/dBm,
        % SignalClass/power.
            obj.Fs = 1;
            obj.Fc = 0;
            switch nargin
                case 1
                    obj=varargin{1};
                    return;
                case 2
                    obj.samples=varargin{1};
                    obj.Fs=varargin{2};
                case 3
                    obj.samples=varargin{1};
                    obj.Fs=varargin{2};
                    obj.Fc=varargin{3};
            end
        end
        function obj= addSignal(obj, samples)
            try
                obj.samples = obj.samples + samples;
            catch
                obj.samples = samples;
            end
        end
        function obj = addNoise(obj, noise)
            try
                obj.noise = obj.noise + noise;
            catch
                 obj.noise = noise;
            end
        end        
        function obj = addNonlin(obj, nonlinear)
            try
                obj.nonlinear = obj.nonlinear + nonlinear;
            catch
                obj.nonlinear = nonlinear;
            end
        end
        function sum=getSignal(obj)
            try
                sum = obj.samples+obj.noise+obj.nonlinear;
            catch
                try
                    sum = obj.samples+obj.noise;
                catch
                    sum = obj.samples;
                end
            end
                
        end
        function obj = filter (obj,B,A)
             obj.samples = filter(B,A,obj.samples);
             obj.noise = filter(B,A,obj.noise);
             obj.nonlinear = filter(B,A,obj.nonlinear);
        end
        
        %% flip@SignalClass
        %
        %  flip(SIGNAL);
        %
        % The *flip* method reverses samples stored in |SIGNAL|.
        function obj=flip(obj)
        % FLIP - Reverse samples stored in SignalClass object
        %
        %   flip(SIGNAL) - The method reverses samples stored in SIGNAL.
        % 
        % See also: SignalClass/SignalClass, SignalClass/dB
            obj.samples=obj.samples(end:-1:1);
            obj.noise=obj.noise(end:-1:1);
            obj.nonlinear = obj.nonlinear (end:-1:1);
        end
        %% power@SignalClass
        %
        %  POWER=power(OBJECT)
        %
        % The return value |POWER| is the average power of the OBJECT,
        % measured on an |1 Ohm| resistor.
        %
        %  POWER=power(OBJECT,R)
        %
        % The return value |POWER| is the average power of the OBJECT,
        % measured on an |R| Ohm resistor.
        %
        function output=power(obj,R)
            % POWER - Measure average power
            %
            %   POWER=power(OBJECT) The return value POWER is the
            %   average power of the OBJECT, measured on an 1 Ohm
            %   resistor.
            %
            %   POWER=power(OBJECT,R) The return value POWER is the
            %   average power of the OBJECT, measured on an R Ohm
            %   resistor.
            % 
            % See also: SignalClass/SignalClass, SignalClass/dB
            output=sum(obj.getSignal().*conj(obj.getSignal()))/obj.length/R;
        end
        function power = sample_power(obj,R)
            power=sum(obj.samples.*conj(obj.samples))/obj.length/R;
        end
        function power = noise_power(obj,R)
            power=sum(obj.noise.*conj(obj.noise))/obj.length/R;
        end
        function power = nonlinear_power(obj,R)
            power=sum(obj.nonlinear.*conj(obj.nonlinear))/obj.length/R;
        end
        %% length@SignalClass
        %
        %  L=length(OBJECT);
        %
        % The return value |L| is the number of signal samples in |OBJECT|.
        function output=length(obj)
        % LENGTH - Signal samples length.
        %
        %	L=length(OBJECT) - The return value L|is the number of signal 
        %   samples in OBJECT. 
        %
        % See also: SignalClass/SignalClass, SignalClass/Flip
            output=length(obj.getSignal());
        end
        %% plot@SignalClass
        % 
        %  plot(OBJECT)
        %
        % Plots the signal samples according the properties *Domain*, *Fs*,
        % *Fc* and *Name*.
        %
        % <html>
        % <table border=1>
        % <tr><td>Domain</td><td>Samples</td><td>Behavior</td></tr>
        % <tr><td>Time</td><td>Real</td><td>The <b>Samples</b> property is plotted in the time domain</td></tr>
        % <tr><td>Time</td><td>Complex</td><td>The real and imaginary part of <b>Samples</b> property is plotted on two figures</td></tr>
        % <tr><td>Frequency</td><td>Don't care</td><td>The amplitude and phase spectrum of <b>Samples</b> property are plotted</td></tr>
        % </table>
        % </html>
        %
        function plot(obj)
            % PLOT - Plot SignalClass object.
            %
            %   plot(OBJECT) plots the SignalClass object according to
            %   it's properties. When Domain property is set to 'time' it
            %   will plot the signal in time domain, otherwise it will plot
            %   the aplitude and phase spectrum of the signal.
            %
            % See also: SignalClass/dB, SignalClass/dBm, SignalClass/phase,
            % SignalClass/power.
            switch upper(obj.Domain)
                case 'TIME'
                    T=length(obj.getSignal())/obj.Fs;
                    x=1/obj.Fs:1/obj.Fs:T;
                    switch isreal(obj.getSignal())
                        case 1
                            plot(x,obj.getSignal());
                        case 0
                            subplot(2,1,1);
                            plot(x,real(obj.getSignal()));
                            ylabel('Real part (V)');
                            subplot(2,1,2);
                            plot(x,imag(obj.getSignal()));
                            ylabel('Imaginary part (V)');
                            xlabel('Time (s)');
                    end
                case 'FREQUENCY'
                    subplot(2,1,1);
                    obj.dB;
                    title(obj.Name);
                    subplot(2,1,2);
                    obj.phase;
                    title(obj.Name);
                    xlabel(['Frequency (Fs = ' num2str(obj.Fs) ')']);
                    ylabel('Phase (rad)');                    
            end
        end
        %% dB@SignalClass
        %
        %  obj.dB
        %
        % Method *dB* plots the amplitude spectrum of *Samples* property in
        % dB.
        function dB(obj)
            % DB - Amplitude spectrum plot of SignalClass object.
            %
            %   db(OBJECT) Plots the amplitude spectrum of the OBJECT in
            %   decibel scale.
            % 
            % See also:  SignalClass/plot, SignalClass/dBm, SignalClass/phase,
            % SignalClass/power.
            l=length(obj.getSignal());
            a=abs(fftshift(fft(obj.getSignal())))/l;
            x=((1:l)/l*obj.Fs)-(obj.Fs/2)+obj.Fc;
            plot(x,db(a));
            xlabel(['Frequency (Fs = ' num2str(obj.Fs) ')']);
            ylabel('Amplitude (dB)');
            title(obj.Name);
        end
        %% dBm@SignalClass
        %
        %  dBm(OBJECT)
        %
        % Method *dBm* plots the ampltitude spectrum of the OBJECT
        % in dBm, when a 50 Ohm reference impedance is considered.
        %
        %  dBm(OBJECT, R)
        %
        % Method *dBm* plots the ampltitude spectrum of the OBJECT
        % in dBm, where a R Ohm reference impedance is used.
        function dBm(obj,R)
            % DBM - Plot the amplitude spectrum in dBm  of SignalClass object.
            %
            %	dBm(OBJECT) - Plots the ampltitude spectrum of
            %	the OBJECT in dBm, when a 50 Ohm reference impedance is
            %	considered. 
            %
            %	dBm(OBJECT, R) - Plots the ampltitude spectrum of the OBJECT
            %   in dBm, where a R Ohm reference impedance is used.
            %
            % See also:  SignalClass/plot, SignalClass/dB, SignalClass/phase,
            % SignalClass/power.

            l=obj.length;
            a=abs(fftshift(fft(obj.getSignal)))/l;
            %x=((1:l)/l*obj.Fs)-(obj.Fs/2)+obj.Fc;
            x=((1:l)/l*obj.Fs)-(obj.Fs/2);
            plot(x,10*log10(a.^2/0.001*R));
            title(obj.Name);
            xlabel(['Frequency (Fs = ' num2str(obj.Fs) ')']);
            ylabel(['Amplitude (dBm) with R = ',num2str(R),'_{Omega}']);

        end
        %% phase@SignalClass
        %
        %  phase(OBJECT)
        %
        % Method *phase* plots the phase spectrum of *Samples* property.
        function phase(obj)
            % PHASE - Plot the amplitude spectrum of SignalClass object.
            %
            %   phase(OBJECT)
            %
            % See also:  SignalClass/plot, SignalClass/dB, SignalClass/dBm,
            % SignalClass/power
                    p=phase(fftshift(fft(obj.getSignal())));
                    l=obj.length;
                    x=((1:l)/l*obj.Fs)-(obj.Fs/2)+obj.Fc;
                    plot(x,p/l);
                    title(obj.Name);
                    xlabel(['Frequency (Fs = ' num2str(obj.Fs) ')']);
                    ylabel('Phase (rad)');                    
        end
        %% freq@SignalClass
        %
        %  freq(OBJECT)
        %
        % Sets *Domain* property to 'Frequency'.
        function obj=freq(obj)
            % FREQ - Set Domain property to 'Frequency' of a SignalClass
            % object.
            %
            %   freq(OBJECT)
            %
            % See also: SignalClass/SignalClass, SignalClass/time.
            obj.Domain='FREQUENCY';
        end
        function val = SNR(obj)
            val = 10 * log10 (obj.sample_power(1)/obj.noise_power(1));
        end
        %% time@SignalClass
        %
        %  time(OBJECT)
        %
        % Sets *Domain* property to 'Time'.
        function obj=time(obj)
            % Time - Set Domain property to 'Time' of a SignalClass
            % object.
            %
            %   time(OBJECT)
            %
            % See also: SignalClass/SignalClass, SignalClass/freq.
            obj.Domain='Time';
        end
        %% operations
        %
        % Most arithmetic operations are overloaded for SignalClass
        % objects.
        %
        %  o1=SignalClass(sin(1:100),1);
        %  o2=SignalClass(cos(1:100),1);
        %  o3=o1+o2;
        %
%         function obj=plus(obj,obj2)
%             if isnumeric(obj)
%                 obj=SignalClass(obj,obj2.Fs,obj2.Fc);
%             elseif isnumeric(obj2)
%                 obj2=SignalClass(obj2,obj.Fs,obj.Fc);
%             end
%             SNR_1_lin = 10^(obj.SNR/10);
%             SNR_2_lin = 10^(obj2.SNR/10);
%             SNR_lin = (obj.sample_power + obj2.sample_power)./(obj.sample_power./SNR_1_lin + obj2.sample_power./SNR_2_lin);
%             obj.SNR = 10*log10(SNR_lin);
%             obj.Samples=obj.Samples+obj2.Samples;
%         end
%         function obj=minus(obj,obj2)
%             if isnumeric(obj)
%                 obj=SignalClass(obj,obj2.Fs,obj2.Fc,obj2.SNR);
%             elseif isnumeric(obj2)
%                 obj2=SignalClass(obj2,obj.Fs,obj.Fc,obj.SNR);
%             end
%             obj.Samples=obj.Samples-obj2.Samples;
%             SNR_1_lin = 10^(obj.SNR/10); 
%             SNR_2_lin = 10^(obj2.SNR/10);
%             SNR_lin = (obj.sample_power + obj2.sample_power)./...
%                 (obj.sample_power/SNR_1_lin + obj2.sample_power/SNR_2_lin);
%             obj.SNR = 10*log10(SNR_lin);
%         end
%         function obj=uminus(obj)
%             obj.Samples=-obj.Samples;
%         end
%          function obj=conj(obj)
%             obj.Samples=conj(obj.Samples);
%          end
%          function obj=abs(obj)
%             obj.Samples=obj.Samples.*conj(obj.Samples);
%         end
        function obj=times(multiplicand,multiplier)
                obj = multiplicand;
                if isnumeric(multiplier) 
                    obj.samples=(multiplicand.samples).*multiplier;
                    obj.noise=multiplicand.noise.*multiplier;
                    obj.nonlinear = multiplicand.nonlinear.*multiplier;
                else
                    obj.samples=(multiplicand.samples).*(multiplier.samples);
                    obj.noise=multiplicand.noise.*(multiplier.noise);
                    obj.nonlinear = multiplicand.nonlinear.*(multiplier.nonlinear);
                end
        end
%         function obj=lt(obj,obj2)
%             if isnumeric(obj)
%                 obj=SignalClass(obj,obj2.Fs,obj2.Fc,obj2.SNR);
%             elseif isnumeric(obj2)
%                 obj2=SignalClass(obj2,obj.Fs,obj.Fc,obj.SNR);
%             end
%             obj.Samples=lt(obj.Samples,obj2.Samples);
%         end
%         function obj=gt(obj,obj2)
%             if isnumeric(obj)
%                 obj=SignalClass(obj,obj2.Fs,obj2.Fc,obj2.SNR);
%             elseif isnumeric(obj2)
%                 obj2=SignalClass(obj2,obj.Fs,obj.Fc,obj.SNR);
%             end
%             obj.Samples=gt(obj.Samples,obj2.Samples);
%         end
%         function obj=le(obj,obj2)
%             if isnumeric(obj)
%                 obj=SignalClass(obj,obj2.Fs,obj2.Fc,obj2.SNR);
%             elseif isnumeric(obj2)
%                 obj2=SignalClass(obj2,obj.Fs,obj.Fc,obj.SNR);
%             end
%             obj.Samples=le(obj.Samples,obj2.Samples);
%         end
%         function obj=ge(obj,obj2)
%             if isnumeric(obj)
%                 obj=SignalClass(obj,obj2.Fs,obj2.Fc,obj2.SNR);
%             elseif isnumeric(obj2)
%                 obj2=SignalClass(obj2,obj.Fs,obj.Fc,obj.SNR);
%             end
%             obj.Samples=ge(obj.Samples,obj2.Samples);
%         end
%         function obj=and(obj,obj2)
%             if isnumeric(obj)
%                 obj=SignalClass(obj,obj2.Fs,obj2.Fc,obj2.SNR);
%             elseif isnumeric(obj2)
%                 obj2=SignalClass(obj2,obj.Fs,obj.Fc,obj.SNR);
%             end
%             obj.Samples=and(obj.Samples,obj2.Samples);
%         end
%         function obj=rdivide(obj,obj2)
%             if isnumeric(obj)
%                 obj=SignalClass(obj,obj2.Fs,obj2.Fc,obj2.SNR);
%             elseif isnumeric(obj2)
%                 obj2=SignalClass(obj2,obj.Fs,obj.Fc,obj.SNR);
%             end
%             obj.Samples=rdivide(obj.Samples,obj2.Samples);
%         end
%         
%         function obj=subsref(obj,val)
%             switch val(1).type
%                 case '()'
%                     %return the Samples shown by the index
%                     obj=obj.Samples(val(1).subs{1});
%                 case '.'
%                     switch val(1).subs
%                         case 'plot'
%                             obj.plot;
%                         case 'dB'
%                             obj.dB;
%                         case 'dBm'
%                             obj.dBm;
%                         case 'phase'
%                             obj.phase
%                         otherwise 
%                             try
%                                 obj=obj.(val(1).subs);
%                             catch
%                                 error('Attempt to reference field of non-structure array');
%                             end
%                     end
%             end
%         end
% 
%         function obj=subsasgn(obj,value)
%             obj.Samples(value)=obj.Samples;
%         end
%         
%         function obj=subsindex(obj,value)
%             obj.Samples=obj.Samples(value.subs{1});
%         end
        function stem(obj)
            switch upper(obj.Domain)
                case 'TIME'
                    T=length(obj.getSignal())/obj.Fs;
                    x=1/obj.Fs:1/obj.Fs:T;
                    stem(x,obj.getSignal());
                case 'FREQUENCY'
                    a=abs(fftshift(fft(obj.getSignal())));
                    p=phase(fftshift(fft(obj.getSignal())));
                    l=length(obj.getSignal());
                    x=((1:l)/l*obj.Fs)-(obj.Fs/2)+obj.Fc;
                    subplot(2,1,1);
                    stem(x,db(a/l));
                    title(obj.Name);
                    xlabel(['Frequency (Fs = ' num2str(obj.Fs) ')']);
                    ylabel('Amplitude (db)');
                    subplot(2,1,2);
                    stem(x,p/l);
                    title(obj.Name);
                    xlabel(['Frequency (Fs=' num2str(obj.Fs) ')']);
                    ylabel('Phase (rad)');                    
            end
        end
%         function obj=transpose(obj)
%             obj.Samples=obj.Samples.';
%         end
%         function obj=ctranspose(obj)
%             obj.Samples=obj.Samples';
%         end
    end
end
