opts.evalCode=false;
opts.showCode=false;
opts.outputDir='./html/';
%main documents
publish('amorf_product_page',opts);
publish('amorf_getting_started',opts);
publish('amorf_user_guide',opts);
publish('amorf_classes',opts);
publish('amorf_example',opts);
%abstraction layer class documents
publish('BaseClass',opts);
publish('SignalClass',opts);
publish('BlockClass',opts);
publish('AttributeClass',opts);
publish('TunerClass',opts);
%nonideality layer class documents
publish('NoiseClass',opts);
publish('GainClass',opts);
publish('FreqSelClass',opts);
publish('FreqConvClass',opts);
publish('PhaseNoiseClass',opts);
publish('IQImbalClass',opts);