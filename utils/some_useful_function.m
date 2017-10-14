%% Some useful 
A=zeros(100,1);
for i=1:100
A(i)=i;
end
B=reshape(A,10,10);
B=B';
B_pad=padarray(B,[4 4],'symmetric','both');
imshow(B_pad);

h=ones(7,7)/49;
filtered=uint8(imfilter(B_pad,h));