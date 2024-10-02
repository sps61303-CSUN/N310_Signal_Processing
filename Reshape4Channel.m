function A = Reshape4Channel(B)
%4CHANNELRESHAPE 
T = [1 0 0 0; 1j 0 0 0; 0 1 0 0; 0 1j 0 0; 0 0 1 0; 0 0 1j 0; 0 0 0 1; ...
     0 0 0 1j];
A = reshape(B,8,length(B)/8).'*T; 
end