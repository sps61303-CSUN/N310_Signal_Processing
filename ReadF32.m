function [A] = ReadF32(FileNames)
%ReadF32 takes an array of File Names in complex float32 format and
%outputs a matrix with column vectors containing the data of each file.
%Example: X_t = ReadF32(["RF0" "RF1" "RF2" "RF3"])

for n = 1:length(FileNames)
    File = fopen(FileNames(n),'r');
    F32 = fread(File,'float32');
    fclose(File);
    A(:,n) = reshape(F32,2,length(F32)/2).'*[1;1j];
end
end