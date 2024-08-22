
clc;
clear all;
close all;

%Initialization of OFDM system parameters
fsub = 10e3;
Nfft = 512;
T = 1/fsub;
ofdm_bw = 5.12e6;
Tcp = 12.5e-6;
Tofdm = T+Tcp;

%Guard Subcarriers
lower_guard = (-255:-241)+256; %Adding 256 to allign with indexing in matlab
upper_guard = (241:256)+256;
useful_SCs = Nfft - length(lower_guard)-length(upper_guard);
dc_sc = 0+256;

SNR_dB = 0:3:30;
snr = 10.^(SNR_dB/10);

%Channel impulse response parameters
tap_delay = [1 8 17 23 40 55];
path_gain_dB = [-3 0 -1 -4 -9 -15];
path_gain = 10.^(path_gain_dB/10);



pilot_seqn = 239+256:-9:lower_guard(end)+1;
pilot_seq_arr = flip(pilot_seqn);
pilot_seq_arr2 = pilot_seq_arr(pilot_seq_arr~=dc_sc); %To make sure DC subcarrier not included
Np = length(pilot_seq_arr);

%Finding diagonal matrix X of size NpxNp
data_in = randi([0 1],2*Np,1);
X_pilot = diag(nrSymbolModulate(data_in,'QPSK'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%2a) Channel Estimation using Zero Forcing by considering pilot SCs
%Finding MSE using ZF channel estimation
MSE = zeros(1,length(snr));
g_time = zeros(Nfft,1); %Channel Impulse Response

for i1 = 1:length(snr)
    no_iterns = 100;
    for i2 = 1:no_iterns

for i=1:length(tap_delay)
    g_time(tap_delay(i)) = sqrt(path_gain(i)/2)*(randn(1) + j*randn(1));
end

%Finding G of length Npx1
G_matrix = (1/sqrt(length(g_time)))*(fft(g_time));
G_matrix_Np = G_matrix(pilot_seq_arr2);

%Generating noise matrix of length Npx1
Noise_pow = 1/snr(i1);
V = sqrt(Noise_pow/2)*(randn(Np,1)+j*randn(Np,1));

%Finding pilot channel estimate using Zero Forcing
G_estimate = G_matrix_Np + inv(X_pilot)*V;

MSE(i1) = MSE(i1) + norm(G_estimate - G_matrix_Np)^2;
    end
end

MSE_dB = 10*log10(MSE/no_iterns);

figure
plot(SNR_dB,MSE_dB,'r-*');
xlabel('SNR in dB');
ylabel('MSE');
title('1a) MSE using ZF estimation at pilot locations');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%2b) Finding MSE by using Linear Interpolation for the channel estimate
%obtained from ZF

MSE2 = zeros(1,length(snr));
g_time2 = zeros(Nfft,1);

for i1 = 1:length(snr)
    no_iterns = 100;
    for i2 = 1:no_iterns

for i=1:length(tap_delay)
    g_time2(tap_delay(i)) = sqrt(path_gain(i)/2)*(randn(1) + j*randn(1));
end

%Finding G of length Npx1
G_matrix2 = (1/sqrt(length(g_time2)))*(fft(g_time2));
G_matrix_Np2 = G_matrix2(pilot_seq_arr2);

%Generating noise matrix of length Npx1
Noise_pow2 = 1/snr(i1);
V2 = sqrt(Noise_pow2/2)*(randn(Np,1)+j*randn(Np,1));

%Finding pilot channel estimate using Zero Forcing
G_estimate2 = G_matrix_Np2 + inv(X_pilot)*V2;

%Using linear interpolation for finding other useful SC's barring pilot
%SC's
G_estimate2_interp = interp1(pilot_seq_arr2,G_estimate2,pilot_seq_arr2(1):pilot_seq_arr2(end));

MSE2(i1) = MSE2(i1) + norm(G_estimate2_interp - G_matrix2(pilot_seq_arr2(1):pilot_seq_arr2(end)))^2;
    end
end

MSE2_dB = 10*log10(MSE2/no_iterns);

figure
plot(SNR_dB,MSE_dB,'r-*');
hold on;
plot(SNR_dB,MSE2_dB,'b^-');
xlabel('SNR in dB');
ylabel('MSE');
legend('ZF with pilots', 'ZF with Interpolation');
title('1b) MSE Comparison for ZF with and without interpolation');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 2c) Using FFT based Channel Estimation


MSE3 = zeros(1,length(snr));
g_time3 = zeros(Nfft,1); 

for i1 = 1:length(snr)
    no_iterns = 100;
    for i2 = 1:no_iterns

for i=1:length(tap_delay)
    g_time3(tap_delay(i)) = sqrt(path_gain(i)/2)*(randn(1) + j*randn(1));
end

%Finding G of length Npx1
G_matrix3 = (1/sqrt(length(g_time3)))*(fft(g_time3));
G_matrix_Np3 = G_matrix3(pilot_seq_arr2);

%Generating noise matrix of length Npx1
Noise_pow3 = 1/snr(i1);
V3 = sqrt(Noise_pow3/2)*(randn(Np,1)+j*randn(Np,1));

%Finding pilot channel estimate using Zero Forcing
G_estimate3 = G_matrix_Np3 + inv(X_pilot)*V3;

G_est_upsamp = upsample(G_estimate3,9); % 9 is the pilot spacing
g_est_upsample = sqrt(length(G_est_upsamp))*ifft(G_est_upsamp);

%Keeping only one copy and removing all other copies
g_est_upsample(9+1:end) = 0;

%Taking FFT
G_est_truncated = (1/sqrt(length(g_est_upsample)))*fft(g_est_upsample);

%Making CIR (g_time) same size to that of g_est_upsample
G_matrix3 = G_matrix3(pilot_seq_arr2(1):pilot_seq_arr2(end) + 9 - 1);


MSE3(i1) = MSE3(i1) + norm(G_est_truncated - G_matrix3)^2;

    end
end

MSE3_dB = 10*log10(MSE3/no_iterns);

figure
plot(SNR_dB,MSE2_dB,'r*-');
hold on;
plot(SNR_dB,MSE3_dB,'b^-');
xlabel('SNR in dB');
ylabel('MSE');
legend('ZF with Interpolation', 'FFT Interpolation');
title('1c) MSE Comparison for ZF with interpolation and FFT Interpolation');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%2d) Channel Estimation using modified Least Square(mLS) by confining CIR
%to Ncp by finding Pseudoinverse

Ncp = 64; %Cyclic prefix length

%Obtaining reduced FFT matrix
FFT_mat = (1/sqrt(Nfft))*dftmtx(Nfft);
FFT_mat_red = FFT_mat(pilot_seq_arr2,1:Ncp);

MSE4 = zeros(1,length(snr));
g_time4 = zeros(Nfft,1); 

for i1 = 1:length(snr)
    no_iterns = 100;
    for i2 = 1:no_iterns

for i=1:length(tap_delay)
    g_time4(tap_delay(i)) = sqrt(path_gain(i)/2)*(randn(1) + j*randn(1));
end

%Finding G of length Npx1
G_matrix4 = (1/sqrt(length(g_time4)))*(fft(g_time4));
G_matrix_Np4 = G_matrix4(pilot_seq_arr2);

%Generating noise matrix of length Npx1
Noise_pow4 = 1/snr(i1);
V4 = sqrt(Noise_pow4/2)*(randn(Np,1)+j*randn(Np,1));

%Finding pilot channel estimate using Zero Forcing
%G_estimate4 = G_matrix_Np4 + inv(X_pilot)*V4;

Y_p = (X_pilot)*(G_matrix_Np4) + V4; 

%Finding A matrix of size NpxNcp such that A = Xpilot * FFTreduced
A_mat = X_pilot*FFT_mat_red;

%Finding pseudo inverse
pseudo_inv_A = inv((A_mat')*(A_mat))*(A_mat');

%Finding Channel estimate

g_estimate4 = (pinv(A_mat))*Y_p;

%Considering CIR with same size as that of channel estimate i.e of CP
%length
g_time4_cp = g_time4(1:length(g_estimate4));

MSE4(i1) = MSE4(i1) + norm(g_estimate4 - g_time4_cp)^2;

    end
end

MSE4_dB = 10*log10(MSE4/no_iterns);

figure
plot(SNR_dB,MSE2_dB,'r*-');
hold on;
plot(SNR_dB,MSE3_dB,'b^-');
hold on;
plot(SNR_dB,MSE4_dB,'mo-');
xlabel('SNR in dB');
ylabel('MSE');
legend('ZF with Interpolation', 'FFT Interpolation','mLS');
title('1d) MSE Comparison for ZF with interpolation, FFT Interpolation and mLS');



%2f) Channel Estimation using modified Least Square(mLS) by confining CIR
%to Ncp by finding Pseudoinverse

Ncp = 64; %Cyclic prefix length

%Obtaining reduced FFT matrix
FFT_mat2 = (1/sqrt(Nfft))*dftmtx(Nfft);
FFT_mat_red2 = FFT_mat2(pilot_seq_arr2,tap_delay);

MSE5 = zeros(1,length(snr));
g_time5 = zeros(Nfft,1); 

for i1 = 1:length(snr)
    no_iterns = 100;
    for i2 = 1:no_iterns

for i=1:length(tap_delay)
    g_time5(tap_delay(i)) = sqrt(path_gain(i)/2)*(randn(1) + j*randn(1));
end

%Finding G of length Npx1
G_matrix5 = (1/sqrt(length(g_time5)))*(fft(g_time5));
G_matrix_Np5 = G_matrix5(pilot_seq_arr2);

%Generating noise matrix of length Npx1
Noise_pow5 = 1/snr(i1);
V5 = sqrt(Noise_pow5/2)*(randn(Np,1)+j*randn(Np,1));

%Finding pilot channel estimate using Zero Forcing
%G_estimate4 = G_matrix_Np4 + inv(X_pilot)*V4;

Y_p2 = (X_pilot)*(G_matrix_Np5) + V5; 

%Finding A matrix of size NpxNcp such that A = Xpilot * FFTreduced
A_mat2 = X_pilot*FFT_mat_red2;

%Using pseudo inverse 'pinv' matlab function in finding pseudo inverse

%Finding Channel estimate

g_estimate5 = (pinv(A_mat2))*Y_p2;

%Considering CIR with same size as that of channel estimate i.e of CP
%length
g_time5_cp = g_time5(tap_delay);

MSE5(i1) = MSE5(i1) + norm(g_estimate5 - g_time5_cp)^2;

    end
end

MSE5_dB = 10*log10(MSE5/no_iterns);

figure
plot(SNR_dB,MSE2_dB,'r*-');
hold on;
plot(SNR_dB,MSE3_dB,'b^-');
hold on;
plot(SNR_dB,MSE4_dB,'mo-');
hold on;
plot(SNR_dB,MSE5_dB,'g>-');
xlabel('SNR in dB');
ylabel('MSE');
legend('ZF with Interpolation', 'FFT Interpolation','mLS','mLS with PDP known');
title('1e) MSE Comparison for ZF with interpolation, FFT Interpolation, mLS and mLS with PDP');
