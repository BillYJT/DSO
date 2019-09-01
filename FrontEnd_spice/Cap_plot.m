[freq, real,imag] = textread('front_end.txt', '%f%f%f', 'delimiter',',')
freq = freq';
real = -real';
imag = -imag';

C = -1./(2*pi.*freq.*imag);
semilogx(freq,C);
title('Capacitance vs. frequency')
xlabel('Frequency')
ylabel('Capacitance')
