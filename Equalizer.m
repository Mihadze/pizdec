classdef Equalizer < handle
    properties(Constant = true)
        freqArray(10,1){double} = [31, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000];
    end
    properties(Access = public)
        gain(10,1){double} = ones;
    end
    properties(GetAccess = public, SetAccess = protected)
        order(1,1){double} = 64;
        fS(1,1){double} = 44100;
    end
    properties(Access = protected)
        bBank{double};
        initB{double} = [];
    end
    methods
        function obj = Equalizer(order, fS)
            obj.order = order;
            obj.fS = fS;
            obj.createFilter = createFilter();
        end
        function obj = Filtering(gain, bBank, signal)
            obj.bBank_new = sum(gain .* bBank);
            obj.signalOut = Filter(bBank_new, 1, signal);
        end
        function bBank = CreateFilters(obj)
            freqArrayNorm = obj.freqArray/(obj.fS/2);
            mLow = [1, 1, 0, 0];
            mBand = [0, 0, 1, 0, 0];
            mHigh = [0, 0, 1, 1];
            bBank = zeros(length(obj.freqArray), obj.order+1);
            for k = 1:length(obj.freqArray)
                if k == 1
                    freqLow = [0, freqArrayNorm(k), 2*freqArrayNorm(k), 1];
                    bBank(k,:) = fir2(obj.order, freqLow, mLow);
                elseif k == length(obj.freqArray)
                    freqHigh = [0, freqArrayNorm(k)/2, freqArrayNorm(k), 1];
                    bBank(k,:) = fir2(obj.order, freqHigh, mHigh);
                else
                    freqBand = [0, freqArrayNorm(k-1), freqArrayNorm(k), freqArrayNorm(k+1), 1];
                    bBank(k,:) = fir2(obj.order, freqBand, mBand);
                end
            end
        end
        function [h, w] = GetFreqResponce(obj)
            b = sum(obj.gain.*obj.bBank);
            [H, w] = freqz(b, 1, obj.order);
            todB = @(x)20*lpg10(x);
            h = todB(abs(H));
            w = w/pi*obj.fS/2;
        end
    end
end