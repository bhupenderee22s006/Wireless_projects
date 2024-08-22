%%%%%%%%%%%%%%%%%%%%%
% finding the Channel Impulse response:
tap_delay = [0, 7, 16, 22, 39, 54] % the delays index is defined
path_gain = [-7.57, -4.56, -5.55, -8.548, -13.546, -19.586] % the power gain at the delay index
is defined
l = max(tap_delay) + 1 % length of impulse response
g = zeros(1,l); % creating a 1*m zero vector
for i = 1:length(tap_delay)
g(tap_delay(i)+1) = 10^(path_gain(i)/10); % Insert the tap gains at the appropriate delays by
converting gains to linear scale
end
g % prints the channel impulse vector
% g vector is the impulse response
G = fft(g) % G vector represents the frequency response of channel using fft algorithm
% Plot the impulse response and frequency response
stem(0:l-1, g);
title('Impulse Response Snapshot');
xlabel('Tap Delay');
ylabel('Path Gain (linear)');
figure;
stem(0:l-1, abs(G));
title('Frequency Response Snapshot');
xlabel('Subcarrier Index');
ylabel('Magnitude');
%%%%%%%%%%%%%%%%%%%%%%%%%
% SYSTEM MODEL
fsub = 10e+3
% sub-carrier bandwidth
Tsub = 1/fsub
% time spacing of subcarriers
numCarr = 512
% no. of subcarriers
BW = 5.12e+6
% OFDM Tx. Bandwidth
Fs = 5.12e+6
% sampling frequency
Ts = 1/Fs
% sampling time
Tcp = 12.5e-6
% cyclic prefix duration
Tofdm = Tsub + Tcp % ofdm symbol duration
% the carriers are indexed from -255 to +256.
% guard index is : -241 to -255 and 241 to 256.
GBleft = -255:1:-241 % the indices of lower guard band
GBright = 241:1:256 % the indices of upper guard band
%%%%%%%%%%%%%%%%%%%%%%%%%
% Generating a digital signal
% Assuming 16 QAM modulation scheme
modOrder = 16 % 16 QAM modulation

numBits = numCarr * log2(modOrder) % no. of bits txed
cycPrefLen = 128 %length of cyclic prefix
srcBits = randi([0,1],numBits,1); % generates a discrete sequence of bits 0 & 1
% modulating the signal using QAM scheme
qamModOut = qammod(srcBits,modOrder,"InputType","bit","UnitAveragePower",true)
title("16QAM SIGNAL")
% Converting the QAM signal into an OFDM signal
ofdm = ifft(qamModOut,numCarr) % ofdm of the QAM signal
% the cyclic prefix contains the last 128 samples of the ofdm signal in time domain
cycPref = ofdm(385:512)'
% we need to concatenate the cyclic prefix with the ofdm
ofdmOut = [cycPref ofdm']' % this is the actual ofdm signal to be txed over the noisy channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PREAMBLE DESIGN
delta_f_max = 28650 % max offset frequency in Hz allowed at the rxed signal
preamble = zeros(1,numCarr); % This line initializes a vector preamble of length 512 with all
elements set to zero. This vector will eventually hold the preamble symbol.
% Implementing Schmidl Cox Algorithm for offset Estimate: Q1 part(a):
% max offset allowed = 28650 and fsub = 10KHz so using formula :
%
f_offset <= fsub * D/2 to find D (in nearest power of 2)
% The preamble symbol uses every Dth subcarrier
D=8
p = nextpow2(D); % taking the log of D to base 2
GBleft_ = GBleft + 256; % modifies the indices of lower guard band to 1:1:15
GBright_= GBright + 256; % modifies the indices of upper guard band to 497:1:512
L2 = length(GBright_); % store the length of upper guard band indices
L1 = length(GBleft_); % store the length of lower guard band indices
L = numCarr - (L1+L2); % no. of useful subcarriers
for i =1:L %the preamble is generated for useful carrier indices
if (rem(i+L1+1,D) == 0)
data = randi([0 1],2,1); % assigning a random sequence of size 2 bits
preamble(1,i+L1) = nrSymbolModulate(data,'QPSK'); % modulating the random
sequence into QPSK signal and assigning it to preamble
else
preamble(1,L+1) = 0;
end
end
preamble2 = (1\sqrt(numCarr))*ifft(preamble,numCarr); % preamble is converted to time
domain using ifft
final_preamble = zeros(1,512+(512/D)); % assigning a vector 1*576
final_preamble(1,1:(512/D)) = preamble2(1,512-(512/D) + 1:512); % 512/D = 64
final_preamble(1,((512/D):512 + (512/D)-1)) = preamble2(1,1:512);

figure
plot(abs(final_preamble));
xlabel('Magnitude');
ylabel('Samples');
title('Time domain representation of Preamble symbol');
delta_f = (fsub*D)/2 % offset estimate

%%%%%%%%%%%%%%%%%%%%%
% finding the Channel Impulse response:
tap_delay = [0, 7, 16, 22, 39, 54] % the delays index is defined
path_gain = [-7.57, -4.56, -5.55, -8.548, -13.546, -19.586] % the power gain at the delay index
is defined
m = max(tap_delay) + 1 % length of impulse response
g = zeros(1,m); % creating a 1*m zero vector
for i = 1:length(tap_delay)
g(tap_delay(i)+1) = 10^(path_gain(i)/10); % Insert the tap gains at the appropriate delays by
converting gains to linear scale
end
g % prints the channel impulse vector
% g vector is the impulse response
G = fft(g) % G vector represents the frequency response of channel using fft algorithm
% Plot the impulse response and frequency response
stem(0:m-1, g);
title('Impulse Response Snapshot');
xlabel('Tap Delay');
ylabel('Path Gain (linear)');
figure;
stem(0:m-1, abs(G));
title('Frequency Response Snapshot');
xlabel('Subcarrier Index');
ylabel('Magnitude');
%%%%%%%%%%%%%%%%%%%%%%%
% SYSTEM MODEL
fsub = 10e+3
% sub-carrier bandwidth
Tsub = 1/fsub
% time spacing of subcarriers
numCarr = 512
% no. of subcarriers
BW = 5.12e+6
% OFDM Tx. Bandwidth
Fs = 5.12e+6
% sampling frequency
Ts = 1/Fs
% sampling time
Tcp = 12.5e-6
% cyclic prefix duration
Tofdm = Tsub + Tcp % ofdm symbol duration
% the carriers are indexed from -255 to +256.
% guard index is : -241 to -255 and 241 to 256.
GBleft = -255:1:-241 % the indices of lower guard band
GBright = 241:1:256 % the indices of upper guard band
%%%%%%%%%%%%%%%%%%%%%%%%%
% Generating a digital signal
% Assuming 16 QAM modulation scheme
modOrder = 16 % 16 QAM modulation
numBits = numCarr * log2(modOrder) % no. of bits txed

cycPrefLen = 128 %length of cyclic prefix
srcBits = randi([0,1],numBits,1); % generates a discrete sequence of bits 0 & 1
% modulating the signal using QAM scheme
qamModOut = qammod(srcBits,modOrder,"InputType","bit","UnitAveragePower",true)
title("16QAM SIGNAL")
% Converting the QAM signal into an OFDM signal
ofdm = ifft(qamModOut,numCarr) % ofdm of the QAM signal
% the cyclic prefix contains the last 128 samples of the ofdm signal in time domain
cycPref = ofdm(385:512)'
% we need to concatenate the cyclic prefix with the ofdm
ofdmOut = [cycPref ofdm']' % this is the actual ofdm signal to be txed over the noisy channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PREAMBLE DESIGN
delta_f_max = 28650 % max offset frequency in Hz allowed at the Rx. side
preamble = zeros(1,numCarr); % This line initializes a vector preamble of length 512 with all
elements set to zero. This vector will eventually hold the preamble symbo
% max offset allowed = 28650 and fsub = 10KHz so using formula :
%
f_offset <= fsub * D/2 to find D (in nearest power of 2)
% The preamble symbol uses every Dth subcarrier
D=8
p = nextpow2(D); % taking the log of D to base 2
GBleft_mod = GBleft + 256; % modifies the indices of lower guard band to 1:1:15
GBright_mod= GBright + 256; % modifies the indices of upper guard band to 497:1:512
L2 = length(GBright_mod); % store the length of upper guard band indices
L1 = length(GBleft_mod); % store the length of lower guard band indices
L = numCarr - (L1+L2); % no. of useful subcarriers
for i =1:L %the preamble is generated for useful carrier indices
if (rem(i+L1+1,D) == 0)
data = randi([0 1],2,1); % assigning a random sequence of size 2 bits if remainder = 0
preamble(1,i+L1) = nrSymbolModulate(data,'QPSK'); % modulating the random
sequence into QPSK signal and assigning it to preamble
else
preamble(1,L+1) = 0; % since the remainder isn't 0, the preamble is assigned bit 0
end
end
preamble2 = (1\sqrt(numCarr))*ifft(preamble,numCarr); % preamble is converted to time
domain using ifft
final_preamble = zeros(1,512+(512/D)); % assigning a vector 1*576
final_preamble(1,1:(512/D)) = preamble2(1,512-(512/D) + 1:512); % 512/D = 64
final_preamble(1,((512/D):512 + (512/D)-1)) = preamble2(1,1:512);
% the designed preamble symbol
figure
plot(abs(final_preamble));
xlabel('Magnitude');

ylabel('Samples');
title('Time domain representation of Preamble symbol');
delta_f = (fsub*D)/2

% offset estimate

f_offset = zeros(11,10); % a zero matrix of order 11*10
q = 1:length(0:2:20) % stores the no. of times the variance changes
p = 1:10
% Implementing Q1 part (b): Mean Square Error in the frequency estimate
SNR_dB = 0:2:20; % varying the snr from 0dB to 20dB in step of 2
SNR = 10.^(SNR_dB(q)/10); % converting snr from dB to linear scale

for i=1:length(tap_delay) % length =~6
ADC_input = conv(final_preamble,g); % input to ADC at the Rx. side
noise_power = (1/SNR).*mean((abs(ADC_input)).^2); % defining the noise power for the
variable SNR in linear scale
for i=1:length(ADC_input)
noise(1,i) = (1/sqrt(2))*(sqrt(1/noise_power))*(randn(1)+j*rand(1)); % AWGN complex noise of
size 1* length(ADC_input)
end
ADC_input_final = ADC_input + noise; % noise is added to ADC input to get the exact input to
it
ADC_output=0;
for i=1:length(ADC_input_final)
ADC_output(1,i) = (exp(j*(2*pi)*(delta_f_max)*(i)*(Ts)))*(ADC_input_final(1,i)); % defining the
ADC output
end
ADC_output
dummy = 0; % creating a dummy variable to carry out the sum
sum_1 = 0;
for m=1:length(final_preamble)-(2*(numCarr/D))
for i=1:numCarr/D
dummy = dummy + conj(ADC_output(1,i+(m-1)),ADC_output(1,i+(m-1)+(numCarr/D))); %
Numerator part
sum_1 = sum_1 + (abs(ADC_output(1,i+(m-1))))^(2); % Denominator part
end
SC_output(1,m) = dummy/sum_1; % SC ALGO output
end
SC_output % displays the MSE

% Q1 part (c)
dummy2_ = 0; % another dummy variable created for re evaluating the sum
sum_1 = 0;

ADC_output2 = cat(2,ADC_output,zeros(1,331)); % catenation of ADC output with a zero row
vector
for m=1:length(final_preamble)-(2*(numCarr/D))
for k = 1:D-1
for i=1:numCarr/D
dummy2 = dummy2 + conj(ADC_output2(1,i+(m-1)+(k-1)*(numCarr/
D)),ADC_output2(1,i+(m-1)+k*(numCarr/D))); % Numerator part
sum_1 = sum_1 + (abs(ADC_output2(1,i+(m-1)+(k-1)*(numCarr/D))))^(2); % Denminator
part
end
end
SC_output_mod(1,m) = dummy2/sum_1;
end
SC_output_mod % display the modified MSE of 2nd part
for i=1:length(SC_output)
magnitude_response(1,i) = (abs(SC_output(1,i)))^2; % finding the magnitude response to
know the peak
magnitude_response_mod(1,i) = (abs( SC_output_mod(1,i)))^2; % for both the case:
preamble symbol & more averaging
end
[value,index] = max(magnitude_response); % finding the peak value along with index for
preamble case
[value_mod,index_mod] = max(magnitude_response_mod); % finding the peak value for more
averaging
f_offset(q,p) = (1/(2*pi))*(angle(SC_output(index)))*fsub*D; % estimating the offset
f_offset_mod(q,p) = (1/(2*pi))*(angle( SC_output_mod(index_mod)))*fsub*D; % estimating the
offset for more averaging
sum_2 =0;
sum_3 =0;
for xr = 1:10
sum_2 = sum_2 + (delta_f_max-f_offset(q,xr))^2;
sum_3 = sum_3 + (delta_f_max-f_offset_mod(q,xr))^2;
end
MSE(q) = 10*log10(sum_2/xr); % MSE with preamble symbol
MSE_mod(q) = 10*log10(sum_3/xr); % MSE with more averaging
end
figure
plot(SNR_dB,MSE); % plotting the MSE for both cases
hold on
plot(SNR_dB,MSE_mod,'-');
xlabel('SNR ');
ylabel('MSE');
legend('SC without averaging','SC with averaging');

% SA#1 Question 2 part (a):
%%%%%%%%%%%%%%%%%%%%%%%%%%

% System Model

fsub = 10e3

% subcarrier frequency

Tsub = 1/fsub

% subcarrier spacing

numCarr = 512

% number of subcarriers/ FFT size

BW = 5.12e6;

% Band width of OFDM signal

Ts = 1/BW;

% sampling time interval

Tcp = 12.5e-6;

% cyclic prefix interval

T_ofdm = Ts + Tcp;

% OFDM symbol duration

% Preamble Design

delta_f_max = 28.65e3;

% max offset frequency in Hz allowed at the Rx. side

% max offset allowed = 28650 and fsub = 10KHz so using formula : % f_offset <=
fsub * D/2 to find D (in nearest power of 2)
% The preamble symbol uses every Dth subcarrier

D = (2*delta_f_max)/fsub; % actual value of D=5.73
p = nextpow2(D); % determines the nearest power of 2
D_roundoff = 2^(p); % rounded off value of D in terms of power of 2

SNR_dB = 6; % the snr value(in dB)
SNR = 10^(SNR_dB/10); % the snr value in linear scale

% Designing FRAME #1 denoted by variable M
M_preamble1 = zeros(1,512); % creating a vector to store the preamble symbol
m_preamble1 = preamble(M_preamble1,numCarr,D_roundoff); % creating a preamble
function to determine the preamble symbol

M_data1 = zeros(1,512); % creating a vector to store the data symbol
m_data1 = data_symbol(M_data1,numCarr,D_roundoff); % creating an arbitrary
function to deteremine the data symbol

M_data2 = zeros(1,512); % creating a vector to store the 2nd data symbol
m_data2 = data_symbol(M_data2,numCarr,D_roundoff); % creating an arbitrary
function to determine the 2nd data symbol

M_data3 = zeros(1,512);

% creating a vector to store the 3rd data symbol

m_data3 = data_symbol(M_data3,numCarr,D_roundoff); % using the srbitrary
function to determine 3rd symbol

M_data4 = zeros(1,512);

% creating a vector to store the 4th data symbol

m_data4 = data_symbol(M_data4,numCarr,D_roundoff); % using the arbitrary
function to determine 4rd symbol
% the frame has 1 preamble block & 4 OFDM blocks so we created 1 preamble &
% 4 data symbols

% Designing FRAME #2

denoted by variable N

N_preamble2 = zeros(1,512);
n_preamble2 = preamble(N_preamble2,numCarr,D_roundoff);

N_data1 = zeros(1,512);
n_data1 = data_symbol(N_data1,numCarr,D_roundoff);

N_data2 = zeros(1,512);
n_data2 = data_symbol(N_data2,numCarr,D_roundoff);

N_data3 = zeros(1,512);
n_data3 = data_symbol(N_data3,numCarr,D_roundoff);

N_data4 = zeros(1,512);
n_data4 = data_symbol(N_data4,numCarr,D_roundoff);
% the frame has 1 preamble block & 4 OFDM blocks so we created 1 preamble &

% 4 data symbols

% The noise is added to FRAME #1; the rxed signal is:
R_preamble1 = add_noise(m_preamble1,SNR); % noise added to preamble symbol

R_data1 = add_noise(m_data1,SNR);
R_data2 = add_noise(m_data2,SNR); % noise added to data symbols
R_data3 = add_noise(m_data3,SNR);
R_data4 = add_noise(m_data4,SNR);

% The noise is added to FRAME #2; th rxed signal is:
R2_preamble2 = add_noise(n_preamble2,SNR); % noise is added to preamble symbol

R2_data1 = add_noise(n_data1,SNR);
R2_data2 = add_noise(n_data2,SNR); % noise is added to data symbols
R2_data3 = add_noise(n_data3,SNR);
R2_data4 = add_noise(n_data4,SNR);

% ADC OUTPUT of FRAME #1
Y_preamble1 = out_adc(R_preamble1);
Y2_data1 = out_adc(R_data1);
Y_data2 = out_adc(R_data2);
Y_data3 = out_adc(R_data3);
Y_data4 = out_adc(R_data4);

% ADC OUTPUT of FRAME #2
Y2_preamble2 = out_adc(R2_preamble2);
Y2_data1 = out_adc(R2_data1);
Y2_data2 = out_adc(R2_data2);
Y2_data3 = out_adc(R2_data3);
Y2_data4 = out_adc(R2_data4);

Y_SC_input =
cat(2,Y_preamble1,Y2_data1,Y_data2,Y_data3,Y_data4,Y2_preamble2,yn_d1_f2,Y2_data
2,Y2_data3,Y2_data4); % concatenation of ADC OUTPUT
% for the two frames: frame by frame in sequence

% finding the MSE as in Q1 part (b)
for m=1:length(Y_SC_input)-(2*(numCarr/D_roundoff))
dummy_2 = 0;
sum_1 = 0;

for i=1:numCarr/D_roundoff
dummy_2 = dummy_2 + (conj(Y_SC_input(1,i+(m-1))))*(Y_SC_input(1,i+
(m-1)+(numCarr/D_roundoff)));

sum_1 = sum_1 + (abs(Y_SC_input(1,i+(m-1))))^(2);
end
SC_output(1,m) = dummy_2/sum_1;
end
magnitude_response_square = (abs(SC_output)).^2; % finding the magnitude
response square and plotting

figure
plot(magnitude_response_square);
xlabel('Samples');
ylabel('|z(k,m)|^{2}');
title('Square Magnitude response of SC output of 2 frames');

% defining the arbitrary functions initialised in the code above.

function op_adc = out_adc(r_n)

ip_adc = r_n;

% defining the output of ADC

OFDM_BW = 5.12e6;
T_s = 1/OFDM_BW;
max_cfo_f = 28.65e3; % max cfo
for i=1:length(ip_adc)
op_adc(1,i) = exp(j*(2*pi)*(max_cfo_f)*(i)*(T_s))*(ip_adc(1,i));
end
end

function symb_noise = add_noise(ip_sig,snr) % defining the noise function
noise_power = 1/snr;

for i=1:length(ip_sig)
noise(1,i) = (1/sqrt(2))*(sqrt(noise_power))*(randn(1)+j*rand(1)); % complex
noise
end
symb_noise = ip_sig + noise;
end

function xn_apnd = preamble(Xn,FFTsize,Dvar) % defining the preamble function
GB_left = -255:1:-241;
GB_right = 241:1:256;
GB_left_modified = GB_left + 256;
GB_right_modified = GB_right + 256;
length_2 = length(GB_right_modified);
length_1 = length(GB_left_modified);
lengt = 512 - length_1 - length_2;
fftsize_N = FFTsize;
D_roundoff = Dvar;

for i =1:lengt
if (rem(i+length_1+1,8) == 0)

data = randi([0 1],2,1);
Xn(1,i+length_1) = nrSymbolModulate(data,'QPSK'); % generating a QPSK
signal as the preamble
else
Xn(1,lengt+1) = 0;
end
end
xn = ifft(Xn,fftsize_N);

xn_apnd = zeros(1,512 + (512/D_roundoff));
xn_apnd(1,1:(512/D_roundoff)) = xn(1,512 - (512/D_roundoff) + 1:512);
xn_apnd(1,((512/D_roundoff)+1):512 + (512/D_roundoff)) = xn(1,1:512);
end

function xn_data_apnd = data_symbol(X_n_data,fft_size,D_var) % defining function
which generates the data symbol

GB_left = -255:1:-241;
GB_right = 241:1:256;
GB_left_modified = GB_left + 256;
GB_right_modified = GB_right + 256;
length_2 = length(GB_right_modified);
length_1 = length(GB_left_modified);
length = 512 - length_1 - length_2;
fftsize_N = fft_size;
D_roundoff = D_var;

for i=1:length
data = randi([0 1],2,1);
X_n_data(1,i+length_1+1) = nrSymbolModulate(data,'QPSK'); % generating OFDM
QPSK symbols
end
xn_data = ifft(X_n_data,fftsize_N);

xn_data_apnd = zeros(1,512 + (512/D_roundoff));
xn_data_apnd(1,1:(512/D_roundoff)) = xn_data(1,512 - (512/D_roundoff) + 1:512);
xn_data_apnd(1,((512/D_roundoff)+1):512 + (512/D_roundoff)) = xn_data(1,1:512);
end

% SA#1 Question 2 part (b):
%%%%%%%%%%%%%%%%%%%%%%%%%%

% System Model
fsub = 10e3; % subcarrier frequency
Tsub = 1/fsub; % subcarrier spacing
numCarr = 512; % no. of subcarriers
BW = 5.12e6;

% OFDM tx bandwidth

Ts= 1/BW;

% sampling time

Tcp = 12.5e-6; % cyclic prefix duration
T_ofdm = Tsub + Tcp; % OFDM symbol duration

% Preamble Design

delta_f_max = 28.65e3;

% max offset frequency in Hz allowed at the Rx. side

% max offset allowed = 28650 and fsub = 10KHz so using formula : % f_offset <=
fsub * D/2 to find D (in nearest power of 2)
% The preamble symbol uses every Dth subcarrier

D = (2*delta_f_max)/fsub;
p = nextpow2(D);
D_roundoff = 2^(p);
SNR_dB = 6;
SNR = 10^(SNR_dB/10);

% Designing FRAME #1 denoted by variable M
M_preamble1 = zeros(1,512);
m_preamble1 = preamble(M_preamble1,numCarr,D_roundoff);

M_data1 = zeros(1,512);
m_data1 = data_symbol(M_data1,numCarr,D_roundoff);

M_data2 = zeros(1,512);
m_data2 = data_symbol(M_data2,numCarr,D_roundoff);

M_data3 = zeros(1,512);
m_data3 = data_symbol(M_data3,numCarr,D_roundoff);

M_data4 = zeros(1,512);
m_data4 = data_symbol(M_data4,numCarr,D_roundoff);
% the frame has 1 preamble block & 4 OFDM blocks so we created 1 preamble &
% 4 data symbols

% Designing FRAME #2 denoted by variable N
N_preamble2 = zeros(1,512);
n_preamble2 = preamble(N_preamble2,numCarr,D_roundoff);

N_data1 = zeros(1,512);
n_data1 = data_symbol(N_data1,numCarr,D_roundoff);

N_data2 = zeros(1,512);
n_data2 = data_symbol(N_data2,numCarr,D_roundoff);

N_data3= zeros(1,512);
n_data3 = data_symbol(N_data3,numCarr,D_roundoff);

N_data4 = zeros(1,512);
n_data4 = data_symbol(N_data4,numCarr,D_roundoff);
% the frame has 1 preamble block & 4 OFDM blocks so we created 1 preamble &
% 4 data symbols

% Channel Model
g_channel = zeros(1,55);
path_gain_dB = [-3 0 -1 -4 -9 -15]

for i=1:length(path_gain_dB)
path_gain(1,i) = 10^(path_gain_dB(1,i)/10);
end
sum_gain = sum(path_gain);

path_gain_normalized = path_gain/sum_gain;

dummy_1 = [1 8 17 23 40 55];
for i=1:length(dummy_1)
g_channel(1,dummy_1(i)) = sqrt(path_gain_normalized(1,i)/
2)*(randn(1)+j*randn(1));
end
g_channel

% displays the normailised path gain

% tx over multipath channel: Frame #1: channel output:
R_preamble1_conv = conv(m_preamble1,g_channel); % convolution of path gain with
preamble symbol
r_preamble1 = add_noise(R_preamble1_conv,SNR); % noise added after convolution

R_data1_conv = conv(m_data1,g_channel); % convolution of ofdm data with path
gain
r_data1 = add_noise(R_data1_conv,SNR); % noise added

R_data2_conv = conv(xn_d2,g_channel);
r_data2 = add_noise(R_data2_conv,SNR);

R_data3_conv = conv(m_data3,g_channel);
r_data3 = add_noise(R_data3_conv,SNR);

R_data4_conv = conv(m_data4,g_channel);

r_data4 = add_noise(R_data4_conv,SNR);

% tx over multipath channel: Frame #2: channel output:
R2_preamble2_conv = conv(n_preamble2,g_channel); % convolution of path gain with
preamble symbol
r2_preamble2 = add_noise(R2_preamble2_conv,SNR); % noise added after convolution

R2_data1_conv = conv(n_data1,g_channel);
gain

% convolution of ofdm data with path

r2_data1 = add_noise(R2_data1_conv,SNR);

% noise added

R2_data2_conv = conv(n_data2,g_channel);
r2_data2 = add_noise(R2_data2_conv,SNR);

R2_data3_conv = conv(xn_d3_f2,g_channel);
r2_data3 = add_noise(R2_data3_conv,SNR);

R2_data4_conv = conv(n_data4,g_channel);
r_data4 = add_noise(R2_data4_conv,SNR);

% ADC OUTPUT: FRAME #1:
Y_preamble1 = out_adc(r_preamble1);

Y_data1 = out_adc(r_data1);
Y_data2 = out_adc(r_data2);
Y_data3 = out_adc(r_data3);
Y_data4 = out_adc(r_data4);

% ADC OUTPUT: FRAME #2:
Y_preamble2 = out_adc(r2_preamble2);

Y_data1 = out_adc(r2_data1);
Y_data2 = out_adc(r2_data2);
Y_data3 = out_adc(r2_data3);
Y_data4 = out_adc(rn_d4_f2);

Y_SC_input =
cat(2,Y_preamble1,Y_data1(1,55:length(Y_data1)),Y_data2(1,55:length(Y_data2)),Y_
data3(1,55:length(Y_data3)),Y_data4(1,55:length(Y_data4)),Y_preamble2(1,55:lengt
h(Y_preamble2)),Y_data1(1,55:length(Y_data1)),Y_data2(1,55:length(Y_data2)),Y_da
ta3(1,55:length(Y_data1)),Y_data4(1,55:length(Y_data4)-54));
% contaenating the adc output frame by frame sequence

% calculating the magnitude response square
for m=1:length(Y_SC_input)-(2*(numCarr/D_roundoff))
dummy2 = 0;
sum_1 = 0;

for i=1:numCarr/D_roundoff

dummy2 = dummy2 + (conj(Y_SC_input(1,i+(m-1))))*(Y_SC_input(1,i+(m-1)+
(numCarr/D_roundoff)));

sum_1 = sum_1 + (abs(Y_SC_input(1,i+(m-1))))^(2);
end
op_SC(1,m) = dummy2/sum_1; % MSE calculation
end
magnitude_response_square = (abs(op_SC)).^2;

figure
plot(magnitude_response_square);
xlabel('Samples----->');
ylabel('|z(k,m)|^{2}--->');
title('2b) Square Magnitude response of SC output of 2 frames with PDP as
channel');

% Defining the functions used in the above code.

function op_adc = out_adc(r_n)

% defining the ADC output function

ip_adc = r_n;
OFDM_BW = 5.12e6;
T_s = 1/OFDM_BW;
max_cfo_f = 28.65e3;
for i=1:length(ip_adc)
op_adc(1,i) = (exp(j*(2*pi)*(max_cfo_f)*(i)*(T_s)))*(ip_adc(1,i));
end
end

function symb_noise = add_noise(ip_sig,snr) % defining the function that adds
noise
noise_power = 1/snr;
for i=1:length(ip_sig)
noise(1,i) = (1/sqrt(2))*(sqrt(noise_power))*(randn(1)+j*rand(1));
end
symb_noise = ip_sig + noise;
end

function xn_apnd = preamble(Xn,N,Dvar) % defining function that generates
preamble symbol

GB_left = -255:1:-241;
GB_right = 241:1:256;
GB_left_modified = GB_left + 256;
GB_right_modified = GB_right + 256;
length2 = length(GB_right_modified);
length1 = length(GB_left_modified);

length = 512 - length1 - length2;
fftsize_N = N;
D_roundoff = Dvar;
for i =1:length
if (rem(i+length1+1,8) == 0)
data = randi([0 1],2,1);
Xn(1,i+length1) = nrSymbolModulate(data,'QPSK');
else
Xn(1,length+1) = 0;
end
end
x_n = ifft(Xn,fftsize_N);

xn_apnd = zeros(1,512 + (512/D_roundoff));
xn_apnd(1,1:(512/D_roundoff)) = x_n(1,512 - (512/D_roundoff) + 1:512);
xn_apnd(1,((512/D_roundoff)+1):512 + (512/D_roundoff)) = x_n(1,1:512);
end

function xn_data_append = data_symbol(Xn_data,N_d,Dvar_d) % defining the
function generates data symbol

GB_left = -255:1:-241;
GB_right = 241:1:256;
GB_left_modified = GB_left + 256;
GB_right_modified = GB_right + 256;
length2 = length(GB_right_modified);
length1 = length(GB_left_modified);
length = 512 - length1 - length2;
fftsize_N = N_d;
D_roundoff = Dvar_d;
for i=1:length
data = randi([0 1],2,1);

Xn_data(1,i+length1+1) = nrSymbolModulate(data,'QPSK');
end
x_n_data = ifft(Xn_data,fftsize_N);

xn_data_append = zeros(1,512 + (512/D_roundoff));
xn_data_append(1,1:(512/D_roundoff)) = x_n_data(1,512 - (512/D_roundoff) +
1:512);
xn_data_append(1,((512/D_roundoff)+1):512 + (512/D_roundoff)) =
x_n_data(1,1:512);
end

%%%%%%%%%%%%%%%%%%%%%
% Assignment #1: Q3:

% System Model:
fsub = 10e3;

% Sub-Carrier Frequency

Tsub = 1/fsub;

% Sub-Carrier spacing

numCarr = 512;

% No. of subcarriers/FFT size

BW = 5.12e6;

% OFDM tx Bandwidth

Ts = 1/BW;

% Sampling time

Tcp = 12.5e-6;

% Cyclic Prefix duration

T_ofdm = Tsub + Tcp; % OFDM symbol duration
%%%%%%%%%%%%%%%%%%%%%%

% Preamble Design

delta_f_max = 28.65e3;

% max offset frequency in Hz allowed at the Rx. side

% max offset allowed = 28650 and fsub = 10KHz so using formula : % f_offset <=
fsub * D/2 to find D (in nearest power of 2)
% The preamble symbol uses every Dth subcarrier

D = (2*delta_f_max)/fsub;

% actual value of D=5.73 % actual value of D=5.73

p = nextpow2(D);

% determines the nearest power of 2

D_roundoff = 2^(p);

% rounded off value of D in terms of power of 2

SNR_dB = 6;

%snr in dB scale

SNR = 10^(SNR_dB/10);

% snr in linear scale

% The Frame dont have a preamble symbol
% Designing Frame without preamble symbol
% The Frame consists of 5 OFDM blocks

% FRAME #1:

M_data0 = zeros(1,512);
m_data0 = data_symbol(M_data0,numCarr,D_roundoff);

%OFDM block 1

M_data1 = zeros(1,512);
m_data1 = data_symbol(M_data1,numCarr,D_roundoff); %OFDM block 2

M_data2 = zeros(1,512);
m_data2 = data_symbol(M_data2,numCarr,D_roundoff); %OFDM block 3

M_data3 = zeros(1,512);
m_data3 = data_symbol(M_data3,numCarr,D_roundoff); %OFDM block 4

M_data4 = zeros(1,512);
m_data4 = data_symbol(M_data4,numCarr,D_roundoff); %OFDM block 5
%%%%%%%%%%%%%%%%%%%%%%

% FRAME #2:
N_data0 = zeros(1,512);
n_data0 = data_symbol(N_data0,numCarr,D_roundoff);

%OFDM block 0

N_data1 = zeros(1,512);
n_data1 = data_symbol(N_data1,numCarr,D_roundoff);

%OFDM block 1

N_data2 = zeros(1,512);
n_data2 = data_symbol(N_data2,numCarr,D_roundoff);

%OFDM block 2

N_data3= zeros(1,512);
n_data3 = data_symbol(N_data3,numCarr,D_roundoff);

%OFDM block 3

N_data4 = zeros(1,512);
n_data4 = data_symbol(N_data4,numCarr,D_roundoff);
%%%%%%%%%%%%%%%%%%%%%%%

%OFDM block 4

% Channel Model
g_channel = zeros(1,55);
path_gain_dB = [-3 0 -1 -4 -9 -15];
for i=1:length(path_gain_dB)
path_gain(1,i) = 10^(path_gain_dB(1,i)/10);
end
sum_gain = sum(path_gain);
path_gain_normalized = path_gain/sum_gain;
dummy_1 = [1 8 17 23 40 55];
for i=1:length(dummy_1)
g_channel(1,dummy_1(i)) = sqrt(path_gain_normalized(1,i)/
2)*(randn(1)+j*randn(1));
end
g_channel % normalised Channel model
%%%%%%%%%%%%%%%%%%

% At the Rx. side: txed through Channel: Frame #1:

R_data0_conv = conv(m_data0,g_channel);

% the ofdm block is convoluted with CIR

r_data0 = add_noise(R_data0_conv,SNR);

% and then noise is added

R_data1_conv = conv(m_data1,g_channel);
r_data1 = add_noise(R_data1_conv,SNR);

R_data2_conv = conv(m_data2,g_channel);
r_data2 = add_noise(R_data2_conv,SNR);

R_data3_conv = conv(m_data3,g_channel);
r_data3 = add_noise(R_data3_conv,SNR);

R_data4_conv = conv(m_data4,g_channel);
r_data4 = add_noise(R_data4_conv,SNR);

% At the Rx. side: txed through Channel: Frame #2:

R2_data0_conv = conv(n_data0,g_channel);
CIR

% the ofdm block is convoluted with

r2_data0 = add_noise(R2_data0_conv,SNR);

% and then noise is added

R2_data1_conv = conv(n_data1,g_channel);
r2_data1 = add_noise(R2_data1_conv,SNR);

R2_data2_conv = conv(n_data2,g_channel);
r2_data2 = add_noise(R2_data2_conv,SNR);

R2_data3_conv = conv(n_data3,g_channel);
r2_data3 = add_noise(R2_data3_conv,SNR);

R2_data4_conv = conv(n_data4,g_channel);
r2_data4 = add_noise(R2_data4_conv,SNR);
% the rxed signal is then feeded to ADC for equalisation.

% ADC OUTPUT: Frame #1:
Y_data0 = out_adc(r_data0);
Y_data1 = out_adc(r_data1);
Y_data2 = out_adc(r_data2);
Y_data3 = out_adc(r_data3);
Y_data4 = out_adc(r_data4);

% ADC OUTPUT: Frame #2:

Y2_data0 = out_adc(r2_data0);
Y2_data1 = out_adc(r2_data1);
Y2_data2 = out_adc(r2_data2);
Y2_data3 = out_adc(r2_data3);
Y2_data4 = out_adc(r2_data4);

% concatenating the output of ADC for the two frames sequentially
Y_CP_input =
cat(2,Y_data0,Y_data1(1,55:length(Y_data1)),Y_data2(1,55:length(Y_data2)),Y_data
3(1,55:length(Y_data3)),Y_data4(1,55:length(Y_data4)),Y2_data0(1,55:length(Y2_da
ta0)),Y2_data1(1,55:length(Y2_data1)),Y2_data2(1,55:length(Y2_data2)),Y2_data3(1
,55:length(Y2_data3)),Y2_data4(1,55:length(Y2_data4)-54));

% determining the MSE for case without preamble
for m=1:length(Y_CP_input)-(2*(numCarr))
dummy_2 = 0;
sum_1 = 0;

for i=1:numCarr/D_roundoff
dummy_2 = dummy_2 + (conj(Y_CP_input(1,i+(m-1))))*(Y_CP_input(1,i+
(m-1)+(numCarr)));%Numerator part

sum_1 = sum_1 + (abs(Y_CP_input(1,i+(m-1))))^(2);
end
op_CP(1,m) = dummy_2/sum_1; % MSE
end
magnitude_response_square = (abs(op_CP)).^2;

figure
plot(magnitude_response_square,'-','LineWidth',2,'Color','r');
xlabel('Samples');
ylabel('|z(k,m)|^{2}');
title('3) Square Magnitude Response of CP Correlation o/p with PDP as channel &
no preambles');

% Defining the arbitrary function used in the code
% the arguments are passed by value to the function

function op_adc = out_adc(r_n) % defining the output of ADC
ip_adc = r_n;
BW = 5.12e6;
T_s = 1/BW;
f_cfo_max = 28.65e3;
for i=1:length(ip_adc)
op_adc(1,i) = (exp(j*(2*pi)*(f_cfo_max)*(i)*(T_s)))*(ip_adc(1,i));
end
end

function symb_noise = add_noise(ip_sig,snr) % defining addition of noise to the
channel output
noise_power = 1/snr;
for i=1:length(ip_sig)
noise(1,i) = (1/sqrt(2))*(sqrt(noise_power))*(randn(1)+j*rand(1)); % complex
noise
end
symb_noise = ip_sig + noise;
end

function xn_apnd = preamble(Xn,N,Dvar) % designing the preamble function
GB_left = -255:1:-241;
GB_right = 241:1:256;
GB_lrft_modified = GB_left + 256;
GB_right_modified = GB_right + 256;
length_2 = length(GB_right_modified);
length_1 = length(GB_lrft_modified);

length_= 512 - length_1 - length_2;

% length of useful subcarrier

fftsize_N = N;
D_roundoff = Dvar;
for i =1:length_
if (rem(i+length_1+1,8) == 0)

data = randi([0 1],2,1);
Xn(1,i+length_1) = nrSymbolModulate(data,'QPSK'); % preamble symbols
are random QPSK symbols
else
Xn(1,length+1) = 0;
end
end
x_n = ifft(Xn,fftsize_N);

xn_apnd = zeros(1,512 + (512/D_roundoff));
xn_apnd(1,1:(512/D_roundoff)) = x_n(1,512 - (512/D_roundoff) + 1:512);
xn_apnd(1,((512/D_roundoff)+1):512 + (512/D_roundoff)) = x_n(1,1:512);
end

function xn_data_apnd = data_symbol(X_n_data,N_d,Dvar_d)

GB_left = -255:1:-241;
GB_right = 241:1:256;
GB_left_modified = GB_left + 256;
GB_right_modified = GB_right + 256;
length2 = length(GB_right_modified);
length1 = length(GB_left_modified);
length_ = 512 - length1 - length2;
fftsize_N = N_d;
D_roundoff = Dvar_d;
for i=1:length_

% no of useful subcarrier

data = randi([0 1],2,1);
X_n_data(1,i+length1+1) = nrSymbolModulate(data,'QPSK'); %OFDM blocks are
random QPSK symbol
end
x_n_data = ifft(X_n_data,fftsize_N);

xn_data_apnd = zeros(1,512 + (512/D_roundoff));
xn_data_apnd(1,1:(512/D_roundoff)) = x_n_data(1,512 - (512/D_roundoff) + 1:512);
xn_data_apnd(1,((512/D_roundoff)+1):512 + (512/D_roundoff)) = x_n_data(1,1:512);
end


