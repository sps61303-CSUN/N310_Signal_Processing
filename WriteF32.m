function WriteF32(A,FileNames)
%WriteF32 Writes each column of a matrix into the specified files.
%The file format is equivalent to the complex float 32 in GNU radio
%Example: WriteF32(X_t, ["RF0" "RF1" "RF2" "RF3"])

p = length(A(:,1));
for n = 1:length(FileNames)
    A32(1:2:2*p-1) = real(A(:,n));
    A32(2:2:2*p) = imag(A(:,n));
    File = fopen(FileNames(n),'w');
    fwrite(File,A32,'float32');
    fclose(File);
end
end