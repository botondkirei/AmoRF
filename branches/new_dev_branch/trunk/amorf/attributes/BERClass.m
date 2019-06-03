classdef BERClass < BaseClass
    properties
        modulation
        channel
    end
    methods
        function obj=BERClass(name)
            obj=obj@BaseClass(name);
        end
        function [ber, numBits] = bertooltemplate(EbNo, maxNumErrs, maxNumBits)
            % Import Java class for BERTool.
            import com.mathworks.toolbox.comm.BERTool;

            % Initialize variables related to exit criteria.
            totErr = 0;  % Number of errors observed
            numBits = 0; % Number of bits processed

            % --- Set up parameters. ---
            % --- INSERT YOUR CODE HERE.
            
            % Simulate until number of errors exceeds maxNumErrs
            % or number of bits processed exceeds maxNumBits.
            while((totErr < maxNumErrs) && (numBits < maxNumBits))

               % Check if the user clicked the Stop button of BERTool.
               if (BERTool.getSimulationStop)
                  break;
               end

               % --- Proceed with simulation.
               % --- Be sure to update totErr and numBits.
               % --- INSERT YOUR CODE HERE.
            end % End of loop

            % Compute the BER.
            ber = totErr/numBits;

        end
    end
end