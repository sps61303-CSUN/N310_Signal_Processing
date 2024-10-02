function WriteF32Vector(A,FileName)
%WriteF32Vector Writes each column of a matrix into the specified files.
%The file format is equivalent to the complex float 32 in GNU radio
%Example: WriteF32(X_t, "RF")

p = length(A(:,1));
q = length(A(1,:));
for n = 1:q
    A32((2*n-1):2*q:(2*p*q+2*n-2*q-1)) = real(A(:,n));
    A32(2*n:2*q:(2*p*q+2*n-2*q)) = imag(A(:,n));
end
File = fopen(FileName,'w');
fwrite(File,A32,'float32');
fclose(File);