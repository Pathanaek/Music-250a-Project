declare filename "FaustEffect.dsp";
declare name "FaustEffect";
import("stdfaust.lib");

window = hslider("stutter", 20, 20, 500, 0.01) : si.smoo;
transpose(w, x, s, sig) = de.fdelay(maxDelay,d,sig)*ma.fmin(d/x,1) + de.fdelay(maxDelay,d+w,sig)*(1-ma.fmin(d/x,1))with { maxDelay = 160; i = 1 - pow(2, s/12); d = i : (+ : +(w) : fmod(_,w)) ~ _;};

inGain = hslider("inGain",0.1,0,1,0.01);
d = hslider("damping",0.25,0.25,40,0.01);
f = hslider("freq",300,50,1300,0.01);

modalModel(freq,damp) = _ <: par(i,nModes,pm.modeFilter(freq*modesFreqRat(i),modesT60s(i)*damp,modesGains(i))) :> /(nModes)
with{
   nModes = 4; // may be add more modes?
   modesFreqRat(n) = ba.take(n+1,(1,2,3,4)); // change modes freqs to change the timbre of the sound
   modesGains(n) = ba.take(n+1,(1,0.9,0.7,0.5)); // change modes gains to change the timbre of the sound
   modesT60s(n) = ba.take(n+1,(1,0.9,0.7,0.5)); // change modes T60 to change the timbre of the sound
};

plsWork = sy.dubDub(f, 1000, 7, 1);
voco = ve.vocoder(9, 0.02, 0.05, 0.8, _, plsWork) : transpose(window, 500, 19);
vocoddd = _ <: *(0.9) * voco :> *(0.1) :> _;

process = *(0.1) : fi.dcblocker : modalModel(f,d) : vocoddd : co.limiter_1176_R4_mono <: _,_;









// (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
