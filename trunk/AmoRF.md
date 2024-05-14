```mermaid
classDiagram
    Signal <|-- Noise
    Signal <|-- Tone
    Signal <|-- Band
    Noise <|-- ThermalNoise
    Noise <|-- QunatizationNoise
    class Signal {
        Constants/Defaults:
            defBandWidth 10e9
            defFreqRes 1e9
        Private:
            String name
            float[] freqBase
            float[] ampl
            float[] phase
        Methods:
            constructor(default)
            constructor(bandWidth, freqRes)
            constructor(bandWidth, nrOfPoint)
            add(signal, signal)
            gain(signal)
            dB()
            dBm(R)
    }
    class Noise{

    }
    class Tone{
      +float frequency
      +float amplitude
      +float phase
      -powerLevel(R)
    }
    class Band{
      +float frequency
      +float amplitude
      +float phase
      -powerLevel(R)
    }
    class ThermalNoise {
    +Property: Temperature
    +Property: Impedance
    }
    class QunatizationNoise {
    +Property: FullScale
    +Property: NrOfBits
    }     
```
