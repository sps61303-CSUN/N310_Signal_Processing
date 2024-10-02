function [A] = ReadF32Vector(FileName,VectorLength)
%ReadF32Vector takes a vector created by GNU Radio in complex float32 format
%and outputs a matrix with column vectors containing the data of each
%element.
%Example: X_t = ReadF32Vector("RF",4)

File = fopen(FileName,'r');
F32 = fread(File,'float32');
fclose(File);
T = zeros(2*VectorLength,VectorLength);
for n = 1:VectorLength
    T(2*n-1,n) = 1;
    T(2*n,n) = 1j;
end
A = reshape(F32,2*VectorLength,length(F32)/(2*VectorLength)).'*T; 
end